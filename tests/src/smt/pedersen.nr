use std::hash::pedersen_hash;
use trees::sparse_merkle::{SparseMerkleTree, Modifier, NonMembershipProver, MembershipProver, SMT_Creator};

#[test]
fn test_verify_membership_proof() {
    let root = 0x7ca084dd359e77ce4a7a683ccd717c45ecee547a73e73fd1a1cb62ec2a30961;
    let smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x01;
    let value = 0x01;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 0x1a68908828c1c04d18fffa09d2357ac40e717b27a3dbf3f793cdb3fe27d6d17b;
    siblings[253] = 0x206456a6a1f0ee74ce95061dfbbc35ddc4ac3644988b324b5fe50e77215f1702;

    smt.membership(entry, entry.0, siblings);
}

#[test]
fn test_verify_non_membership_proof() {
    let root = 0x7ca084dd359e77ce4a7a683ccd717c45ecee547a73e73fd1a1cb62ec2a30961;
    let smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x04;
    let value = 0x04;
    let entry = (key, value);
    let matching_entry = (0x02, 0x02);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[253] = 0x1891383341c9ba47346ab2cf7dfcf6ba42491d17f3fa692a5c1029732029aa53;

    smt.non_membership(matching_entry, entry.0, siblings);
}

#[test]
fn test_add_first_element() {
    let mut smt = SparseMerkleTree::new(pedersen_hash, pedersen_hash);

    let key = 0x01;
    let value = 0x01;
    let entry = (key, value);
    let siblings: [Field; 254] = [0; 254];

    smt.add(entry, entry.0, siblings);
    assert(smt.root == 0xe51bb5b5db9cc2c7dfd9c38ed5db39f784973f7235da39923a78793b28fe13a);
}

#[test]
fn test_add_element_to_one_element_tree() {
    let root = 0xe51bb5b5db9cc2c7dfd9c38ed5db39f784973f7235da39923a78793b28fe13a;
    let mut smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x02;
    let value = 0x02;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[253] = 0xe51bb5b5db9cc2c7dfd9c38ed5db39f784973f7235da39923a78793b28fe13a;

    smt.add(entry, entry.0, siblings);
    assert(smt.root == 0x2d395dd3307368077b47a4841cc7cf2bf37281e2de15be3ed50a4d96fda04072);
}

#[test]
fn test_add_element_to_existing_tree() {
    let root = 0x2d395dd3307368077b47a4841cc7cf2bf37281e2de15be3ed50a4d96fda04072;
    let mut smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x03;
    let value = 0x03;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 0xe51bb5b5db9cc2c7dfd9c38ed5db39f784973f7235da39923a78793b28fe13a;
    siblings[253] = 0x206456a6a1f0ee74ce95061dfbbc35ddc4ac3644988b324b5fe50e77215f1702;
    let big_tree_root = 0x7ca084dd359e77ce4a7a683ccd717c45ecee547a73e73fd1a1cb62ec2a30961;

    smt.add(entry, entry.0, siblings);
    assert(smt.root == big_tree_root);
}

#[test]
fn test_delete() {
    let root = 0x7ca084dd359e77ce4a7a683ccd717c45ecee547a73e73fd1a1cb62ec2a30961;
    let mut smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x03;
    let value = 0x03;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 0xe51bb5b5db9cc2c7dfd9c38ed5db39f784973f7235da39923a78793b28fe13a;
    siblings[253] = 0x206456a6a1f0ee74ce95061dfbbc35ddc4ac3644988b324b5fe50e77215f1702;
    let small_tree_root = 0x2d395dd3307368077b47a4841cc7cf2bf37281e2de15be3ed50a4d96fda04072;

    smt.delete(entry, entry.0, siblings);
    assert(smt.root == small_tree_root);
}

#[test]
fn test_update() {
    let root = 0x7ca084dd359e77ce4a7a683ccd717c45ecee547a73e73fd1a1cb62ec2a30961;
    let mut smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x03;
    let old_value = 0x03;
    let new_value = 0x04;
    let old_entry = (key, old_value);
    let new_entry = (key, new_value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 0xe51bb5b5db9cc2c7dfd9c38ed5db39f784973f7235da39923a78793b28fe13a;
    siblings[253] = 0x206456a6a1f0ee74ce95061dfbbc35ddc4ac3644988b324b5fe50e77215f1702;
    let big_tree_root = 0x1136738f1460de1ca7bc0c64ed09046070f8e47f5bfa045013262dbce1e0ab3a;

    smt.update(new_entry, old_entry, old_entry.0, siblings);
    assert(smt.root == big_tree_root);
}
