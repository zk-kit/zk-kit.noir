use std::hash::poseidon2::Poseidon2::hash;
use trees::sparse_merkle::{
    MembershipProver, Modifier, NonMembershipProver, SMT_Creator, SparseMerkleTree,
};

#[test]
fn test_verify_membership_proof() {
    let root = 0x24d11b806679284b8b632c3356c87edac24b8eb17ec71284579e0ad3a7cd62ee;
    let smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x01;
    let value = 0x01;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 0x18ff110fac007ab061c17af9b831d12aabc3b0024fc240be77b0ed4823495531;
    siblings[253] = 0xaef80d5d5b3a2fe223a3e532befc46ce5f542ff516a917886e30c97f5f6b832;

    smt.membership(entry, entry.0, siblings);
}

#[test]
fn test_verify_non_membership_proof() {
    let root = 0x2151c2f9fdef58b8a33921d853d54895d2d9c7446bc5c9cdbe71e344a5cea1ed;
    let smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x04;
    let value = 0x04;
    let entry = (key, value);
    let matching_entry = (0x02, 0x02);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[253] = 0x2caff4d2bbd06504be02b53bf953596476bec9448d5a365c05daf1f39812f42;

    smt.non_membership(matching_entry, entry.0, siblings);
}

#[test]
fn test_add_first_element() {
    let mut smt = SparseMerkleTree::new(|h| hash(h, 3), |h| hash(h, 2));

    let key = 0x01;
    let value = 0x01;
    let entry = (key, value);
    let siblings: [Field; 254] = [0; 254];
    smt.add(entry, entry.0, siblings);

    assert(smt.root == 0x2494b80a540ec0a0124a9dba7d5922e3250507677700e9eb680e30a279a72742);
}

#[test]
fn test_add_element_to_one_element_tree() {
    let root = 0x2494b80a540ec0a0124a9dba7d5922e3250507677700e9eb680e30a279a72742;
    let mut smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x02;
    let value = 0x02;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[253] = 0x2494b80a540ec0a0124a9dba7d5922e3250507677700e9eb680e30a279a72742;
    smt.add(entry, entry.0, siblings);
    assert(smt.root == 0x19a364a28acf3e9de291ea791e0e7f798062926fb4fb286d0038ce048748b49b);
}

#[test]
fn test_add_element_to_existing_tree() {
    let root = 0x19a364a28acf3e9de291ea791e0e7f798062926fb4fb286d0038ce048748b49b;
    let mut smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x03;
    let value = 0x03;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 0x2494b80a540ec0a0124a9dba7d5922e3250507677700e9eb680e30a279a72742;
    siblings[253] = 0x30065fe2f3e2a11bb56ee7dd53657ffa4681ffcfd9403ef43b306996e2c2d022;
    let big_tree_root = 0x2151c2f9fdef58b8a33921d853d54895d2d9c7446bc5c9cdbe71e344a5cea1ed;

    smt.add(entry, entry.0, siblings);

    assert(smt.root == big_tree_root);
}

#[test]
fn test_delete() {
    let root = 0x2151c2f9fdef58b8a33921d853d54895d2d9c7446bc5c9cdbe71e344a5cea1ed;
    let mut smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x03;
    let value = 0x03;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 0x2494b80a540ec0a0124a9dba7d5922e3250507677700e9eb680e30a279a72742;
    siblings[253] = 0x30065fe2f3e2a11bb56ee7dd53657ffa4681ffcfd9403ef43b306996e2c2d022;
    let small_tree_root = 0x19a364a28acf3e9de291ea791e0e7f798062926fb4fb286d0038ce048748b49b;

    smt.delete(entry, entry.0, siblings);

    assert(smt.root == small_tree_root);
}

#[test]
fn test_update() {
    let root = 0x2151c2f9fdef58b8a33921d853d54895d2d9c7446bc5c9cdbe71e344a5cea1ed;
    let mut smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x03;
    let old_value = 0x03;
    let new_value = 0x04;
    let old_entry = (key, old_value);
    let new_entry = (key, new_value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 0x2494b80a540ec0a0124a9dba7d5922e3250507677700e9eb680e30a279a72742;
    siblings[253] = 0x30065fe2f3e2a11bb56ee7dd53657ffa4681ffcfd9403ef43b306996e2c2d022;
    let big_tree_root = 0x2e5b3426d92c302ae39a83d4269d9cf53f008f20b1dbda456d7fee525be320bb;

    smt.update(new_entry, old_entry, old_entry.0, siblings);

    assert(smt.root == big_tree_root);
}
