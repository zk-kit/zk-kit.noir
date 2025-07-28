pub use crate::types::{Calculator, MembershipProver, Modifier, NonMembershipProver, SMT_Creator};

pub struct SparseMerkleTree<T> {
    pub root: T,
    pub leaf_hasher: fn([T; 3]) -> T,
    pub hasher: fn([T; 2]) -> T,
}

impl<T> SMT_Creator<T> for SparseMerkleTree<T>
where
    T: Eq + Default,
{
    fn default(root: T, leaf_hasher: fn([T; 3]) -> T, hasher: fn([T; 2]) -> T) -> Self {
        Self { root, leaf_hasher, hasher }
    }

    fn from(root: T, leaf_hasher: fn([T; 3]) -> T, hasher: fn([T; 2]) -> T) -> Self {
        Self::default(root, leaf_hasher, hasher)
    }

    fn new(leaf_hasher: fn([T; 3]) -> T, hasher: fn([T; 2]) -> T) -> Self {
        Self::from(T::default(), leaf_hasher, hasher)
    }
}

impl<T> MembershipProver<T, (T, T)> for SparseMerkleTree<T>
where
    T: Eq + Default,
{
    fn membership<let N: u32>(self, entry: (T, T), indexes: Field, hash_path: [T; N]) {
        // membership proof: the root is calculated based on the entry, the siblings,
        // and the path determined by the key of entry through consecutive hashing
        assert(self.calculate_root(entry, indexes, hash_path) == self.root);
    }
}

impl<T> NonMembershipProver<T, (T, T)> for SparseMerkleTree<T>
where
    T: Eq + Default,
{
    fn non_membership<let N: u32>(self, matching_entry: (T, T), index: Field, siblings: [T; N]) {
        if (self.root != T::default()) {
            // non-membership proof: the root is calculated based on the matching_entry, the siblings
            // and the path that is determined by the key of entry. This makes sure that matching_entry is in fact
            // a matching entry for entry meaning that it shares the same first bits as path
            let mut calculated_root = self.calculate_root(matching_entry, index, siblings);
            assert(calculated_root == self.root);
        }
    }
}

impl<T> Modifier<T, (T, T)> for SparseMerkleTree<T>
where
    T: Eq + Default,
{
    fn add<let N: u32>(&mut self, new_entry: (T, T), index: Field, hash_path: [T; N]) {
        // if the root node is zero the first leaf is added to the tree in which case
        // the new root equals H(k,v,T::default())
        // otherwise the correctness of the old root is validated based on the siblings after which
        // the new root is calculated and returned
        if (self.root == T::default()) {
            self.root = (self.leaf_hasher)([new_entry.0, new_entry.1, T::default()]);
        } else {
            let (old, new) = self.calculate_two_roots(new_entry, index, hash_path);
            assert(old == self.root);
            self.root = new;
        }
    }

    fn delete<let N: u32>(&mut self, entry: (T, T), indexes: Field, hash_path: [T; N]) {
        // proves membership of entry in the old root, then calculates and returns the new root
        let (new, old) = self.calculate_two_roots(entry, indexes, hash_path);

        assert(old == self.root);
        self.root = new;
    }

    fn update<let N: u32>(
        &mut self,
        new_value: (T, T),
        old_value: (T, T),
        index: Field,
        hash_path: [T; N],
    ) {
        let key = index;
        // both the old entry and new entry share the same key that is used to calculate the path
        let path: [u1; N] = key.to_be_bits();

        // old_parent is a container to temporarily store the nodes that ultimately lead to the OLD root
        let mut old_parent = (self.leaf_hasher)([old_value.0, old_value.1, T::default()]);
        // new_parent is a container to temporarily store the nodes that ultimately lead to the NEW root
        let mut new_parent = (self.leaf_hasher)([new_value.0, new_value.1, T::default()]);
        // starting from the bottom of the tree, for each level it checks whether there is a sibling and if
        // that is the case, it hashes the two containers with the sibling and updates the containers with the
        // resulting hashes until the uppermost level is reached aka the root node
        for i in 0..hash_path.len() {
            let sibling = hash_path[i];
            if sibling != T::default() {
                if path[i] != 0 {
                    new_parent = (self.hasher)([sibling, new_parent]);
                    old_parent = (self.hasher)([sibling, old_parent]);
                } else {
                    new_parent = (self.hasher)([new_parent, sibling]);
                    old_parent = (self.hasher)([old_parent, sibling]);
                }
            }
        }
        assert(old_parent == self.root);
        self.root = new_parent;
    }
}

impl<T> Calculator<T, (T, T)> for SparseMerkleTree<T>
where
    T: Eq + Default,
{
    /*
     * Calculates the root for a given tree entry based on the passed array of siblings and the passed path.
     * @param entry The key and value of an entry [k, v]
     * @param siblings Contains the siblings from bottom to top
     * @param path The position of the entry in the tree as represented by bits from bottom to top
     * @returns The calculated root node
     */
    fn calculate_root<let N: u32>(self, entry: (T, T), indexes: Field, hash_path: [T; N]) -> T {
        let index_bits: [u1; N] = indexes.to_be_bits(); // TODO: does to_be_bits range check the output array?

        // serves as container for hashes and is initialized to be the leaf node
        let mut node = (self.leaf_hasher)([entry.0, entry.1, T::default()]);
        // iterates over the list of siblings until the first sibling is found
        // arbitrarily assigns the sibling to be the left and the node to be the
        // right element of the hashing pair unless the path indicates the opposite
        // order in which case the order is changed. The new hash is stored in the container
        // until the root node is reached and returned.
        for i in 0..hash_path.len() {
            let sibling = hash_path[i];
            if sibling != T::default() {
                let mut left = sibling;
                let mut right = node;
                if index_bits[i] == 0 {
                    left = node;
                    right = sibling;
                }
                node = (self.hasher)([left, right]);
            }
        }
        node
    }

    /*
     * Calculates two roots for a given leaf entry based on the passed array of siblings: one root
     * for if the leaf entry was included in the tree and one for if the leaf entry was not included
     * in the tree. This is useful for efficiently proving the membership of leaf entries for a
     * tree while simultaneously modifying the tree.
     * @param entry The key and value of an entry [k, v]
     * @param siblings Contains the siblings from bottom to top
     * @returns Two root nodes: the first one doesn't include entry, the second does
     */
    fn calculate_two_roots<let N: u32>(
        self,
        entry: (T, T),
        indexes: Field,
        hash_path: [T; N],
    ) -> (T, T) {
        let index_bits: [u1; N] = indexes.to_be_bits();

        // root_with_leaf is a container for hashes to derive the root node for the tree that
        // includes the entry
        let mut root_with_leaf = (self.leaf_hasher)([entry.0, entry.1, T::default()]);
        // root_without_leaf is a container for hashes to derive the root node for the tree that
        // doesn't include the entry
        let mut root_without_leaf = T::default();
        // iterate over the levels of the tree from bottom to top
        for i in 0..hash_path.len() {
            let sibling = hash_path[i];
            // After the first sibling is found, the processes are started to calculate the two root nodes.
            // The calulcation of the root node that includes the entry is comparable to `calculate_root`.
            // To calc the root node that doesn't include entry, the first sibling is put into the container
            // and starting from each SUBSEQUENT iteration it is hashed with its sibling and the resulting hash
            // again stored in the container until the root is reached
            if sibling != T::default() {
                if (i > 0) & (hash_path[i - 1] == T::default()) {
                    root_without_leaf = hash_path[i];
                }

                if index_bits[i] != 0 {
                    root_with_leaf = (self.hasher)([sibling, root_with_leaf]);
                    if (root_without_leaf != sibling) {
                        root_without_leaf = (self.hasher)([sibling, root_without_leaf]);
                    }
                } else {
                    root_with_leaf = (self.hasher)([root_with_leaf, sibling]);

                    if (root_without_leaf != sibling) {
                        root_without_leaf = (self.hasher)([root_without_leaf, sibling]);
                    }
                }
            }
        }

        (root_without_leaf, root_with_leaf)
    }
}
