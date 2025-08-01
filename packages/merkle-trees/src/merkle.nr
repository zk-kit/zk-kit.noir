pub use crate::types::{Calculator, MembershipProver, Modifier, MT_Creator};

pub struct MerkleTree<T> {
    pub root: T,
    pub hasher: fn([T; 2]) -> T,
}

impl<T> MT_Creator<T> for MerkleTree<T>
where
    T: Eq + Default,
{
    fn default(root: T, hasher: fn([T; 2]) -> T) -> Self {
        Self { root, hasher }
    }

    fn from(root: T, hasher: fn([T; 2]) -> T) -> Self {
        Self::default(root, hasher)
    }

    fn new(hasher: fn([T; 2]) -> T) -> Self {
        Self::from(T::default(), hasher)
    }
}

impl<T> MembershipProver<T, T> for MerkleTree<T>
where
    T: Eq + Default,
{
    fn membership<let N: u32>(self, leaf: T, indexes: Field, hash_path: [T; N]) {
        let root = self.calculate_root(leaf, indexes, hash_path);
        assert(self.root == root);
    }
}

impl<T> Modifier<T, T> for MerkleTree<T>
where
    T: Eq + Default,
{
    fn add<let N: u32>(&mut self, leaf: T, indexes: Field, hash_path: [T; N]) {
        let (old, new) = self.calculate_two_roots(leaf, indexes, hash_path);
        assert(old == self.root);
        self.root = new;
    }

    fn delete<let N: u32>(&mut self, leaf: T, indexes: Field, hash_path: [T; N]) {
        let (new, old) = self.calculate_two_roots(leaf, indexes, hash_path);
        assert(old == self.root);
        self.root = new;
    }

    fn update<let N: u32>(&mut self, leaf: T, old_leaf: T, indexes: Field, hash_path: [T; N]) {
        let index_bits: [u1; N] = indexes.to_le_bits();

        let mut old_parent = old_leaf;
        let mut new_parent = leaf;

        for i in 0..hash_path.len() {
            let sibling = hash_path[i];
            if index_bits[i] == 0 {
                new_parent = (self.hasher)([new_parent, sibling]);
                old_parent = (self.hasher)([old_parent, sibling]);
            } else {
                new_parent = (self.hasher)([sibling, new_parent]);
                old_parent = (self.hasher)([sibling, old_parent]);
            }
        }
        assert(old_parent == self.root);
        self.root = new_parent;
    }
}

impl<T> Calculator<T, T> for MerkleTree<T>
where
    T: Eq + Default,
{
    fn calculate_root<let N: u32>(self, leaf: T, indexes: Field, hash_path: [T; N]) -> T {
        let index_bits: [u1; N] = indexes.to_le_bits();
        let mut node = leaf;
        for i in 0..hash_path.len() {
            let sibling = hash_path[i];
            if index_bits[i] == 0 {
                let left = node;
                let right = sibling;
                node = (self.hasher)([left, right]);
            } else {
                let left = sibling;
                let right = node;
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
    fn calculate_two_roots<let N: u32>(self, leaf: T, indexes: Field, hash_path: [T; N]) -> (T, T) {
        let index_bits: [u1; N] = indexes.to_le_bits();

        // root_with_leaf is a container for hashes to derive the root node for the tree that
        // includes the entry
        let mut root_with_leaf = leaf;
        // root_without_leaf is a container for hashes to derive the root node for the tree that
        // doesn't include the entry
        let mut root_without_leaf = T::default();

        // iterate over the levels of the tree from bottom to top
        for i in 0..hash_path.len() {
            if i == 0 {
                root_without_leaf = hash_path[i];
            }
            let sibling = hash_path[i];
            // After the first sibling is found, the processes are started to calculate the two root nodes.
            // The calulcation of the root node that includes the entry is comparable to `calculate_root`.
            // To calc the root node that doesn't include entry, the first sibling is put into the container
            // and starting from each SUBSEQUENT iteration it is hashed with its sibling and the resulting hash
            // again stored in the container until the root is reached
            if index_bits[i] == 0 {
                root_with_leaf = (self.hasher)([root_with_leaf, sibling]);
                if (root_without_leaf != sibling) {
                    root_without_leaf = (self.hasher)([root_without_leaf, sibling]);
                }
            } else {
                root_with_leaf = (self.hasher)([sibling, root_with_leaf]);
                if (root_without_leaf != sibling) {
                    root_without_leaf = (self.hasher)([sibling, root_without_leaf]);
                }
            }
        }
        (root_without_leaf, root_with_leaf)
    }
}
