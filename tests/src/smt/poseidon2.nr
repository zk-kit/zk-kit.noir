use poseidon::poseidon2::Poseidon2;
use trees::sparse_merkle::{
    MembershipProver, Modifier, NonMembershipProver, SMT_Creator, SparseMerkleTree,
};

#[test]
fn test_verify_membership_proof() {
    let root = 0x24d11b806679284b8b632c3356c87edac24b8eb17ec71284579e0ad3a7cd62ee;
    let smt = SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

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
    let smt = SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

    let key = 0x04;
    let value = 0x04;
    let entry = (key, value);
    let matching_entry = (0x02, 0x02);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[253] = 0x2caff4d2bbd06504be02b53bf953596476bec9448d5a365c05daf1f39812f42;

    smt.non_membership(matching_entry, entry.0, entry.0, siblings);
}

#[test]
fn test_add_first_element() {
    let mut smt = SparseMerkleTree::new(|h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

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
    let mut smt =
        SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

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
    let mut smt =
        SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

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
    let mut smt =
        SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

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
    let mut smt =
        SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

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

// The fixtures below come from the zk-kit JS implementation with the leaf marker set to 0.
// In the tree {1, 5} the two keys share their first two bits, so key 1 sits at depth 3 with
// zero siblings at depths 1 and 2 that are hashed like any other node.

#[test]
fn test_verify_membership_proof_with_zero_siblings_above_leaf() {
    let root = 0x5031db24d9aac5f6e188f688ea323173efdb6fc46285e1f6f0c56462850f6c1;
    let smt = SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

    let entry = (0x01, 0x01);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[251] = 0x2520be3283e6f589edb2ca00d845ca917467410de10336dab15df75f2c0747d0;

    smt.membership(entry, entry.0, siblings);
}

#[test]
fn test_verify_non_membership_proof_with_zero_siblings_above_leaf() {
    let root = 0x5031db24d9aac5f6e188f688ea323173efdb6fc46285e1f6f0c56462850f6c1;
    let smt = SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

    // key 9 shares its first three bits with key 1, so its path ends at the entry (1, 1)
    let key = 0x09;
    let matching_entry = (0x01, 0x01);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[251] = 0x2520be3283e6f589edb2ca00d845ca917467410de10336dab15df75f2c0747d0;

    smt.non_membership(matching_entry, key, key, siblings);
}

#[test]
fn test_add_element_below_zero_siblings() {
    let root = 0x5031db24d9aac5f6e188f688ea323173efdb6fc46285e1f6f0c56462850f6c1;
    let mut smt =
        SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

    // key 9 diverges from key 1 at bit 3, so entry (1, 1) becomes its sibling at depth 4
    let entry = (0x09, 0x09);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[250] = 0x2494b80a540ec0a0124a9dba7d5922e3250507677700e9eb680e30a279a72742;
    siblings[251] = 0x2520be3283e6f589edb2ca00d845ca917467410de10336dab15df75f2c0747d0;

    smt.add(entry, entry.0, siblings);

    assert(smt.root == 0x23a558dd3b5db965c2f8b47613fb3de2e23d28ff9b3270f4e8f294d455617987);
}

#[test]
fn test_add_element_with_zero_siblings_between_old_and_new_depth() {
    // tree {1, 2}: key 1 sits at depth 1
    let root = 0x19a364a28acf3e9de291ea791e0e7f798062926fb4fb286d0038ce048748b49b;
    let mut smt =
        SparseMerkleTree::from(root, |h| Poseidon2::hash(h, 3), |h| Poseidon2::hash(h, 2));

    // key 5 diverges from key 1 at bit 2, so entry (1, 1) moves down to depth 3 and the zero
    // sibling at depth 1 is new: it is hashed into the new root but was not part of the old one
    let entry = (0x05, 0x05);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[251] = 0x2494b80a540ec0a0124a9dba7d5922e3250507677700e9eb680e30a279a72742;
    siblings[253] = 0x30065fe2f3e2a11bb56ee7dd53657ffa4681ffcfd9403ef43b306996e2c2d022;

    smt.add(entry, entry.0, siblings);

    assert(smt.root == 0x58035a94bb80951df5f3e3d99dce73a43301d45779fed60fd5a34352be2901c);
}
