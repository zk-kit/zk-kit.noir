use std::hash::poseidon2::Poseidon2::hash;
use trees::merkle::{MembershipProver, MerkleTree, Modifier, MT_Creator};

#[test]
fn test_merkle_tree_membership() {
    let root = 0x21447efbbddb57d6fc5ad24d906388492e82c44e5160425258dd4ea995e3a06e;
    let mt = MerkleTree::from(root, |h| hash(h, 2));

    let leaf = 0x00;
    let paths = [0x01, 0x2bc00d90b885b09d12764e764410f7f693f514f7f3ca14d916741ff3968b3079, 0x04];

    mt.membership(leaf, 0x00, paths);
}

#[test]
fn test_merkle_tree_add() {
    let old_root = 0x21447efbbddb57d6fc5ad24d906388492e82c44e5160425258dd4ea995e3a06e;
    let mut mt = MerkleTree::from(old_root, |h| hash(h, 2));

    let leaf = 0x2bc00d90b885b09d12764e764410f7f693f514f7f3ca14d916741ff3968b3079;
    let paths = [0x21447efbbddb57d6fc5ad24d906388492e82c44e5160425258dd4ea995e3a06e];
    mt.add(leaf, 0x01, paths);
}

#[test]
fn test_merkle_tree_delete() {
    let old_root = 0x2890b3cf709936f1fa3974a83ba6d680afed4892663ad0aa7f51dea313107b61;
    let mut mt = MerkleTree::from(old_root, |h| hash(h, 2));

    let leaf = 0x2bc00d90b885b09d12764e764410f7f693f514f7f3ca14d916741ff3968b3079;
    let paths = [0x21447efbbddb57d6fc5ad24d906388492e82c44e5160425258dd4ea995e3a06e];

    mt.delete(leaf, 0x01, paths);

    assert(mt.root == 0x21447efbbddb57d6fc5ad24d906388492e82c44e5160425258dd4ea995e3a06e);
}

#[test]
fn test_merkle_tree_update() {
    let old_root = 0x2bad56e4964d2660a1785faca4cb13a00c662723a8e8941b4a47e15f36e9968e;
    let mut mt = MerkleTree::from(old_root, |h| hash(h, 2));

    let old_leaf = 0x2bc00d90b885b09d12764e764410f7f693f514f7f3ca14d916741ff3968b3079;
    let leaf = 0xd98561fb02ca04d00801dfdc118b2a24cea0351963587712a28d368041370e1;

    let paths = [0x21447efbbddb57d6fc5ad24d906388492e82c44e5160425258dd4ea995e3a06e];
    mt.update(leaf, old_leaf, 0x00, paths);

    assert(
        mt.root
            == hash(
                [
                    0xd98561fb02ca04d00801dfdc118b2a24cea0351963587712a28d368041370e1,
                    0x21447efbbddb57d6fc5ad24d906388492e82c44e5160425258dd4ea995e3a06e,
                ],
                2,
            ),
    );
}
