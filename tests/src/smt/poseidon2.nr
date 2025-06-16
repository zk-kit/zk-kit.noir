use std::hash::poseidon2::Poseidon2::hash;
use trees::sparse_merkle::{
    MembershipProver, Modifier, NonMembershipProver, SMT_Creator, SparseMerkleTree,
};

#[test]
fn test_verify_membership_proof() {
    // Test creation - ts
    //
    // const smt = new SMT(poseidon2, /*bigNumbers=*/ true)
    // await smt.add(0n, 1n);
    // await smt.add(1n, 1n);
    // await smt.add(3n, 1n);
    // await smt.add(7n, 1n);
    //
    // console.log(await smt.createProof(3n));

    let root = 15740799470832712523661862171247648862152403636674762657371926786049235733479;
    let smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 3;
    let value = 1;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[251] = 5041667225684811700620602399322232548771414912182476411155481313569336770064;
    siblings[252] = 17995823880102478500203231984351592100342421224652575177474080420521335032391;
    siblings[253] = 6251068641219821617228532485380646097274252458374366123561775799484560721534;

    smt.membership(entry, entry.0, siblings);
}

#[test]
fn test_verify_non_membership_proof() {
    // Test creation - ts
    //
    // const smt = new SMT(poseidon2, /*bigNumbers=*/ true)
    // await smt.add(0n, 1n);
    // await smt.add(1n, 1n);
    // await smt.add(3n, 1n);
    // await smt.add(7n, 1n);
    //
    // console.log(await smt.createProof(5n));

    let root = 15740799470832712523661862171247648862152403636674762657371926786049235733479;
    let smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 5;
    let matching_entry = (1, 1);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 2835373096206826515306028463035600443700853060018546442897789133838014643230;
    siblings[253] = 6251068641219821617228532485380646097274252458374366123561775799484560721534;

    smt.non_membership(matching_entry, key, siblings);
}

// // Note: This test demonstrates that the tree implementation is broken.
// #[test]
// fn test_one_non_inclusion() {
//     // Make a tree in typescript
//     // const smt = new SMT(poseidon2, /*bigNumbers=*/ true)

//     // await smt.add(0n, 1n);
//     // await smt.add(1n, 1n);
//     // await smt.add(3n, 1n);

//     let root = 2303121422260472849100122966319912943661567788597739446207139579234486076956;
//     let smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

//     // proof that 1 does not exist in the tree, but the matching entry is 1, 1 - so it literally must exist in the tree
//     let key = 1;
//     let matching = (1, 1);

//     let mut siblings = [0; 254];
//     siblings[252] = 10491038750216827372905818545066985839831454851938278937578062954218492497577;
//     siblings[253] = 4925234744530858171417654075256589666688346860022878524242846880227987649233;

//     smt.non_membership(matching, key, siblings);
// }

#[test]
fn test_add_first_element() {
    // const smt = new SMT(poseidon2, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // console.log(await smt.root);

    let mut smt = SparseMerkleTree::new(|h| hash(h, 3), |h| hash(h, 2));

    let key = 0x01;
    let value = 0x01;
    let entry = (key, value);
    let siblings: [Field; 254] = [0; 254];
    smt.add(entry, entry.0, siblings);

    assert(
        smt.root == 17995823880102478500203231984351592100342421224652575177474080420521335032391,
    );
}

#[test]
fn test_add_element_to_one_element_tree() {
    // const smt = new SMT(poseidon2, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // console.log(smt.root);

    // await smt.add(2n, 1n);
    // console.log(smt.createProof(2n));
    // console.log(smt.root);

    let root = 17995823880102478500203231984351592100342421224652575177474080420521335032391;
    let mut smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x02;
    let value = 0x01;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[253] = 17995823880102478500203231984351592100342421224652575177474080420521335032391;
    smt.add(entry, entry.0, siblings);
    assert(
        smt.root == 16058757511805712529049335348535912780563433336560935851454685880412142612052,
    );
}

#[test]
fn test_add_element_to_existing_tree() {
    // const smt = new SMT(poseidon2, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // await smt.add(2n, 1n);
    // console.log(smt.root);
    // await smt.add(3n, 1n);
    // console.log(await smt.createProof(3n));
    // console.log(smt.root);

    let root = 16058757511805712529049335348535912780563433336560935851454685880412142612052;
    let mut smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x03;
    let value = 0x01;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 17995823880102478500203231984351592100342421224652575177474080420521335032391;
    siblings[253] = 4351025609187410138517147353174980014484414724355405228481677219379672570316;

    smt.add(entry, entry.0, siblings);

    assert(
        smt.root == 11534251239942724646933208453818441409824239394141121769604885325827212784372,
    );
}

#[test]
fn test_delete() {
    // const smt = new SMT(poseidon2, /*bigNumbers=*/ true)
    //
    // await smt.add(1n, 1n);
    // await smt.add(2n, 1n);
    // await smt.add(3n, 1n);
    // console.log(await smt.createProof(3n));
    // await smt.delete(3n);
    // console.log(await smt.createProof(3n));

    let root = 11534251239942724646933208453818441409824239394141121769604885325827212784372;
    let mut smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x03;
    let value = 0x01;
    let entry = (key, value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 17995823880102478500203231984351592100342421224652575177474080420521335032391;
    siblings[253] = 4351025609187410138517147353174980014484414724355405228481677219379672570316;

    smt.delete(entry, entry.0, siblings);

    assert(
        smt.root == 16058757511805712529049335348535912780563433336560935851454685880412142612052,
    );
}

#[test]
fn test_update() {
    // const smt = new SMT(poseidon2, /*bigNumbers=*/ true)
    // await smt.add(1n, 1n);
    // await smt.add(2n, 1n);
    // await smt.add(3n, 1n);
    // console.log(await smt.createProof(3n));
    // await smt.update(3n, 2n);
    // console.log(await smt.createProof(3n));

    let root = 11534251239942724646933208453818441409824239394141121769604885325827212784372;
    let mut smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

    let key = 0x03;
    let old_value = 0x01;
    let new_value = 0x02;
    let old_entry = (key, old_value);
    let new_entry = (key, new_value);
    let mut siblings: [Field; 254] = [0; 254];
    siblings[252] = 17995823880102478500203231984351592100342421224652575177474080420521335032391;
    siblings[253] = 4351025609187410138517147353174980014484414724355405228481677219379672570316;

    smt.update(new_entry, old_entry, old_entry.0, siblings);

    assert(
        smt.root == 13041316809261208141489398387327710115783904431042199682397773891759279592856,
    );
}
