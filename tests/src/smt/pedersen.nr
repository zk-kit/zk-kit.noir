use std::hash::pedersen_hash;
use trees::sparse_merkle::{
    MembershipProver, Modifier, NonMembershipProver, SMT_Creator, SparseMerkleTree,
};

#[test]
fn test_verify_membership_proof() {
    // const smt = new SMT(pedersen, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // await smt.add(2n, 1n);
    // await smt.add(3n, 1n);
    // console.log(await smt.createProof(3n));

    let root = 3439023489997334517340272627539669774252862926023359414968830614710567119971;
    let smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x03;
    let value = 0x01;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 12370909072915806427988438183920359632375878301691967399275296521385347658529;
    siblings[253] = 11366775620726042635177670832665911414620763237784497684881724129107587672687;

    smt.membership(entry, entry.0, siblings);
}

#[test]
fn test_verify_non_membership_proof() {
    // const smt = new SMT(pedersen, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // await smt.add(2n, 1n);
    // await smt.add(3n, 1n);
    // console.log(await smt.createProof(5n));

    let root = 3439023489997334517340272627539669774252862926023359414968830614710567119971;
    let smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x05;
    let matching_entry = (0x01, 0x01);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 3710803976499088632826613451666944763817750663979943222410841648797656524311;
    siblings[253] = 11366775620726042635177670832665911414620763237784497684881724129107587672687;

    smt.non_membership(matching_entry, key, siblings);
}

#[test]
fn test_add_first_element() {
    // const smt = new SMT(pedersen, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // console.log(await smt.createProof(1n));
    let mut smt = SparseMerkleTree::new(pedersen_hash, pedersen_hash);

    let key = 0x01;
    let value = 0x01;
    let entry = (key, value);
    let siblings: [Field; 254] = [0; 254];

    smt.add(entry, entry.0, siblings);
    assert(
        smt.root == 12370909072915806427988438183920359632375878301691967399275296521385347658529,
    );
}

#[test]
fn test_add_element_to_one_element_tree() {
    // const smt = new SMT(pedersen, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // await smt.add(2n, 1n);
    // console.log(await smt.createProof(2n));

    let root = 12370909072915806427988438183920359632375878301691967399275296521385347658529;
    let mut smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x02;
    let value = 0x01;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[253] = 12370909072915806427988438183920359632375878301691967399275296521385347658529;

    smt.add(entry, entry.0, siblings);
    assert(
        smt.root == 2743707517940053166706827311251601830213132317720096824374730149304699404864,
    );
}

#[test]
fn test_add_element_to_existing_tree() {
    // const smt = new SMT(pedersen, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // await smt.add(2n, 1n);
    // await smt.add(3n, 1n);
    // console.log(await smt.createProof(2n));

    let root = 2743707517940053166706827311251601830213132317720096824374730149304699404864;
    let mut smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x03;
    let value = 0x01;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 12370909072915806427988438183920359632375878301691967399275296521385347658529;
    siblings[253] = 11366775620726042635177670832665911414620763237784497684881724129107587672687;

    smt.add(entry, entry.0, siblings);
    assert(
        smt.root == 3439023489997334517340272627539669774252862926023359414968830614710567119971,
    );
}

#[test]
fn test_delete() {
    // const smt = new SMT(pedersen, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // await smt.add(2n, 1n);
    // await smt.add(3n, 1n);
    // console.log(await smt.createProof(3n));
    // await smt.delete(3n);
    // console.log(smt.root)

    let root = 3439023489997334517340272627539669774252862926023359414968830614710567119971;
    let mut smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x03;
    let value = 0x01;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 12370909072915806427988438183920359632375878301691967399275296521385347658529;
    siblings[253] = 11366775620726042635177670832665911414620763237784497684881724129107587672687;

    smt.delete(entry, entry.0, siblings);
    assert(
        smt.root == 2743707517940053166706827311251601830213132317720096824374730149304699404864,
    );
}

#[test]
fn test_update() {
    // const smt = new SMT(pedersen, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // await smt.add(2n, 1n);
    // await smt.add(3n, 1n);
    // console.log(await smt.createProof(3n));
    // await smt.update(3n, 2n);
    // console.log(smt.root);

    let root = 3439023489997334517340272627539669774252862926023359414968830614710567119971;
    let mut smt = SparseMerkleTree::from(root, pedersen_hash, pedersen_hash);

    let key = 0x03;
    let old_value = 0x01;
    let new_value = 0x02;
    let old_entry = (key, old_value);
    let new_entry = (key, new_value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 12370909072915806427988438183920359632375878301691967399275296521385347658529;
    siblings[253] = 11366775620726042635177670832665911414620763237784497684881724129107587672687;

    smt.update(new_entry, old_entry, old_entry.0, siblings);
    assert(
        smt.root == 15173714637614968026038664633344727571083254758879871186915150224086765726948,
    );
}
