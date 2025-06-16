pub use crate::types::{Calculator, MembershipProver, Modifier, MT_Creator};

pub struct MerkleTree {
    pub root: Field,
    pub hasher: fn([Field; 2]) -> Field,
}

impl MT_Creator for MerkleTree {
    fn default(root: Field, hasher: fn([Field; 2]) -> Field) -> Self {
        Self { root, hasher }
    }

    fn from(root: Field, hasher: fn([Field; 2]) -> Field) -> Self {
        Self::default(root, hasher)
    }

    fn new(hasher: fn([Field; 2]) -> Field) -> Self {
        Self::from(Field::default(), hasher)
    }
}

impl MembershipProver<Field> for MerkleTree {
    fn membership<let N: u32>(self, leaf: Field, indexes: Field, hash_path: [Field; N]) {
        let root = self.calculate_root(leaf, indexes, hash_path);
        assert(self.root == root);
    }
}

impl Modifier<Field> for MerkleTree {
    fn add<let N: u32>(&mut self, leaf: Field, indexes: Field, hash_path: [Field; N]) {
        let (old, new) = self.calculate_two_roots(leaf, indexes, hash_path);
        assert(old == self.root);
        self.root = new;
    }

    fn delete<let N: u32>(&mut self, leaf: Field, indexes: Field, hash_path: [Field; N]) {
        let (new, old) = self.calculate_two_roots(leaf, indexes, hash_path);
        assert(old == self.root);
        self.root = new;
    }

    fn update<let N: u32>(
        &mut self,
        leaf: Field,
        old_leaf: Field,
        indexes: Field,
        hash_path: [Field; N],
    ) {
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

impl Calculator<Field> for MerkleTree {
    fn calculate_root<let N: u32>(
        self,
        leaf: Field,
        indexes: Field,
        hash_path: [Field; N],
    ) -> Field {
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
    fn calculate_two_roots<let N: u32>(
        self,
        leaf: Field,
        indexes: Field,
        hash_path: [Field; N],
    ) -> (Field, Field) {
        let index_bits: [u1; N] = indexes.to_be_bits();

        // root_with_leaf is a container for hashes to derive the root node for the tree that
        // includes the entry
        let mut root_with_leaf = leaf;
        // root_without_leaf is a container for hashes to derive the root node for the tree that
        // doesn't include the entry
        let mut root_without_leaf = Field::default();

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
