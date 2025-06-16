use std::hash::pedersen_hash;
use trees::merkle::{MembershipProver, MerkleTree, Modifier, MT_Creator};

#[test]
fn test_merkle_tree_membership() {
    let root = 0x1c59022dba1d97f63021cc5a23e4fe80f019465e0ccb54de9aa91935495354a3;
    let mt = MerkleTree::from(root, pedersen_hash);

    let leaf = 0x00;
    let paths = [0x01, 0x67635fc829435949ed0ced751d11f3f823087ec463ca6ee53e253fb7e390e74, 0x04];

    mt.membership(leaf, 0x00, paths);
}

#[test]
fn test_merkle_tree_add() {
    let old_root = 0x00;
    let mut mt = MerkleTree::from(old_root, pedersen_hash);

    let leaf = 0x67635fc829435949ed0ced751d11f3f823087ec463ca6ee53e253fb7e390e74;
    let paths = [];
    mt.add(leaf, 0x00, paths);
    assert(mt.root == leaf);
}

#[test]
fn test_merkle_tree_delete() {
    let old_root = 0x0899a3021f7e10044eb552c4715b1bda60f56573cd6d7a190168207f031729ad;
    let mut mt = MerkleTree::from(old_root, pedersen_hash);

    let leaf = 0x67635fc829435949ed0ced751d11f3f823087ec463ca6ee53e253fb7e390e74;
    let paths = [0x1c59022dba1d97f63021cc5a23e4fe80f019465e0ccb54de9aa91935495354a3];

    mt.delete(leaf, 0x01, paths);
    assert(mt.root == 0x1c59022dba1d97f63021cc5a23e4fe80f019465e0ccb54de9aa91935495354a3);
}

#[test]
fn test_merkle_tree_update() {
    let old_root = 0x04756079a344d691b095311ac35c99e2e33a84457d5d27b728c0cce1b23cbd4b;
    let mut mt = MerkleTree::from(old_root, pedersen_hash);

    let old_leaf = 0x67635fc829435949ed0ced751d11f3f823087ec463ca6ee53e253fb7e390e74;
    let leaf = 0xd98561fb02ca04d00801dfdc118b2a24cea0351963587712a28d368041370e1;
    let paths = [0x1c59022dba1d97f63021cc5a23e4fe80f019465e0ccb54de9aa91935495354a3];

    mt.update(leaf, old_leaf, 0x00, paths);

    assert(
        mt.root
            == pedersen_hash([
                0xd98561fb02ca04d00801dfdc118b2a24cea0351963587712a28d368041370e1,
                0x1c59022dba1d97f63021cc5a23e4fe80f019465e0ccb54de9aa91935495354a3,
            ]),
    );
}
