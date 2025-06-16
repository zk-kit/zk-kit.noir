use super::merkle::MerkleTree;
use super::sparse_merkle::SparseMerkleTree;

pub trait Calculator<T> {
    fn calculate_root<let N: u32>(self, entry: T, indexes: Field, hash_path: [Field; N]) -> Field;
    fn calculate_two_roots<let N: u32>(self, entry: T, indexes: Field, hash_path: [Field; N]) -> (Field, Field);
}

pub trait EntryMark {
    fn entry_mark() -> Self;
}

pub trait SMT_Creator {
    fn default(
        root: Field,
        leaf_hasher: fn([Field; 3]) -> Field,
        hasher: fn([Field; 2]) -> Field,
    ) -> SparseMerkleTree;

    /**
     * Imports an existing Sparse Merkle Tree (SparseMerkleTree) instance.
     * @param hasher The hash function that is used to hash the nodes of the tree
     * @param root The root of the tree
     */
    fn from(root: Field, leaf_hasher: fn([Field; 3]) -> Field, hasher: fn([Field; 2]) -> Field) -> SparseMerkleTree;

    /**
     * Creates a new Sparse Merkle Tree (SparseMerkleTree) instance.
     * @param hasher The hash function that is used to hash the nodes of the tree
     */
    fn new(leaf_hasher: fn([Field; 3]) -> Field, hasher: fn([Field; 2]) -> Field) -> SparseMerkleTree;
}

pub trait MT_Creator {
    fn default(root: Field, hasher: fn([Field; 2]) -> Field) -> MerkleTree;

    /**
     * Imports an existing Sparse Merkle Tree (SparseMerkleTree) instance.
     * @param hasher The hash function that is used to hash the nodes of the tree
     * @param root The root of the tree
     */
    fn from(root: Field, hasher: fn([Field; 2]) -> Field) -> MerkleTree;

    /**
     * Creates a new Sparse Merkle Tree (SparseMerkleTree) instance.
     * @param hasher The hash function that is used to hash the nodes of the tree
     */
    fn new(hasher: fn([Field; 2]) -> Field) -> MerkleTree;
}

pub trait MembershipProver<T> {
    /**
     * Proves that a leaf is a member of the tree.
     * @param leaf The leaf to prove
     * @param path The hash path and indices
     */
    fn membership<let N: u32>(self, entry: T, indexes: Field, hash_path: [Field; N]);
}

pub trait NonMembershipProver {
    /**
     * Verifies a non-membership proof, ie it calculates the tree root
     * based on an entry and a matching_entry and all siblings and compares that calculated root
     * with the root that is passed to this function.
     * @param entry Contains key and value of an entry: (key, value)
     * @param matching_entry Contains (key, value) of a matching entry
     * @param siblings Contains array of siblings the matching_entry
     */
    fn non_membership<let N: u32>(self, matching_entry: (Field, Field), index: Field, siblings: [Field; N]);
}

pub trait Modifier<T> {
    /**
     * Proves the addition of a NEW entry to an existing tree. Based on the siblings first validates the correctness of
     * the old root. Then uses the new entry and the siblings to calculate the new tree root.
     * NOTE: this function doesn't validate if the key for the new entry already exists in the tree, ie
     * if the operation is actually an update. For this operation there is a separate function.
     * @param new_entry The new entry to prove addition
     * @param siblings The siblings (and indices for MT proofs)
     */
    fn add<let N: u32>(&mut self, new_entry: T, indexes: Field, hash_path: [Field; N]);

    /**
     * Proves the deletion of an existing entry from a tree. Based on the siblings first does a membership proof
     * of that existing entry and then calculates the new root (without the entry).
     * @param entry Contains key and value of the to-be-deleted entry: (key, value)
     * @param siblings The siblings (and indices for MT proofs)
     */
    fn delete<let N: u32>(&mut self, entry: T, indexes: Field, hash_path: [Field; N]);

    /**
     * Proves the update of the value of an existing entry in a tree. Based on the siblings first does a membership proof
     * first verifies the membership of the old entry. Then recalculates the new root.
     * @param new_value The new value to be added (instead of old_entry[1])
     * @param old_entry Contains key and value of the entry to be updated: (key, value)
     * @param siblings The siblings (and indices for MT proofs)
     */
    fn update<let N: u32>(&mut self, new_value: T, old_entry: T, index: Field, hash_path: [Field; N]);
}
