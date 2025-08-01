use binary_merkle_root::binary_merkle_root;
use poseidon::poseidon::bn254::hash_2 as poseidon2;

// These tests were generated using the LeanIMT library:
// https://github.com/privacy-scaling-explorations/zk-kit/tree/main/packages/lean-imt

#[test]
fn test_one_level() {
    //          Root: 6691153974608186212136798648834496237771156483253230205533658046584008158327
    //         /    \
    //        1      1280033553760815678764770846139155613435155939625621669696967390845036381755

    let identity_commitment =
        1280033553760815678764770846139155613435155939625621669696967390845036381755;
    // One level, depth = 1
    let merkle_proof_length = 1;
    let merkle_proof_indices = [1];
    let merkle_proof_siblings = [1];
    let root = 6691153974608186212136798648834496237771156483253230205533658046584008158327;
    let root_result = binary_merkle_root(
        poseidon2,
        identity_commitment,
        merkle_proof_length,
        merkle_proof_indices,
        merkle_proof_siblings,
    );

    assert(root_result == root);
}

#[test]
fn test_odd_number_of_leaves() {
    //              Root: 15315337189723426960706634029226413344761453738246667319973793912339492411933
    //                    /                                                                     \
    //  7853200120776062878684798364095072458815029376092732009249414926327459813530   1280033553760815678764770846139155613435155939625621669696967390845036381755
    //        /              \                                                                   |
    //       1                2                                                        1280033553760815678764770846139155613435155939625621669696967390845036381755

    let identity_commitment =
        1280033553760815678764770846139155613435155939625621669696967390845036381755;
    let merkle_proof_length = 1;
    let merkle_proof_indices = [1];
    let merkle_proof_siblings =
        [7853200120776062878684798364095072458815029376092732009249414926327459813530];
    let root = 15315337189723426960706634029226413344761453738246667319973793912339492411933;
    let root_result = binary_merkle_root(
        poseidon2,
        identity_commitment,
        merkle_proof_length,
        merkle_proof_indices,
        merkle_proof_siblings,
    );

    assert(root_result == root);
}

#[test]
fn test_depth_less_than_max_depth() {
    //               Root: 15284653082059996996538149234009626848177941683781918204717362906726802990849
    //                      /                                                                     \
    // 7853200120776062878684798364095072458815029376092732009249414926327459813530   6154259385489079115171215860933192146876662540007832765216854648093568746477
    //          /              \                                                                             /                                    \
    //         1                2                        1280033553760815678764770846139155613435155939625621669696967390845036381755               3

    let identity_commitment =
        1280033553760815678764770846139155613435155939625621669696967390845036381755;
    // depth = 2 which is < max depth = 5
    let merkle_proof_length = 2;
    let merkle_proof_indices = [0, 1, 0, 0, 0];
    let merkle_proof_siblings =
        [3, 7853200120776062878684798364095072458815029376092732009249414926327459813530, 0, 0, 0];
    let root = 15284653082059996996538149234009626848177941683781918204717362906726802990849;
    let root_result = binary_merkle_root(
        poseidon2,
        identity_commitment,
        merkle_proof_length,
        merkle_proof_indices,
        merkle_proof_siblings,
    );

    assert(root_result == root);
}

#[test]
fn test_depth_equals_max_depth() {
    //              Root: 19646466727209028632368918362567300896600724196464472518263335051880792850046
    //                    /                                                                     \
    //  7853200120776062878684798364095072458815029376092732009249414926327459813530   3477366564967156727841823348488314755036194240340197326130499876568103937279
    //        /              \                                                                   /              \
    //       1                2                                                                 3       1280033553760815678764770846139155613435155939625621669696967390845036381755

    let identity_commitment =
        1280033553760815678764770846139155613435155939625621669696967390845036381755;
    // depth = 2 which is = max depth = 2
    let merkle_proof_length = 2;
    let merkle_proof_indices = [1, 1];
    let merkle_proof_siblings =
        [3, 7853200120776062878684798364095072458815029376092732009249414926327459813530];
    let root = 19646466727209028632368918362567300896600724196464472518263335051880792850046;
    let root_result = binary_merkle_root(
        poseidon2,
        identity_commitment,
        merkle_proof_length,
        merkle_proof_indices,
        merkle_proof_siblings,
    );

    assert(root_result == root);
}

fn dummy_hasher(input: [Field; 2]) -> Field {
    input[0] + input[1]
}

#[test(should_fail)]
fn test_incorrect_hash_function() {
    //              Root: 19646466727209028632368918362567300896600724196464472518263335051880792850046
    //                    /                                                                     \
    //  7853200120776062878684798364095072458815029376092732009249414926327459813530   3477366564967156727841823348488314755036194240340197326130499876568103937279
    //        /              \                                                                   /              \
    //       1                2                                                                 3       1280033553760815678764770846139155613435155939625621669696967390845036381755

    let identity_commitment =
        1280033553760815678764770846139155613435155939625621669696967390845036381755;
    let merkle_proof_length = 2;
    let merkle_proof_indices = [1, 1];
    let merkle_proof_siblings =
        [3, 7853200120776062878684798364095072458815029376092732009249414926327459813530];
    let root = 19646466727209028632368918362567300896600724196464472518263335051880792850046;
    // This test is expected to fail because the hasher function is incorrect. The root was generated using poseidon2.
    let root_result = binary_merkle_root(
        dummy_hasher,
        identity_commitment,
        merkle_proof_length,
        merkle_proof_indices,
        merkle_proof_siblings,
    );

    assert(root_result == root);
}

#[test(should_fail)]
fn test_incorrect_commitment_value() {
    //              Root: 19646466727209028632368918362567300896600724196464472518263335051880792850046
    //                    /                                                                     \
    //  7853200120776062878684798364095072458815029376092732009249414926327459813530   3477366564967156727841823348488314755036194240340197326130499876568103937279
    //        /              \                                                                   /              \
    //       1                2                                                                 3       1280033553760815678764770846139155613435155939625621669696967390845036381755

    // This test is expected to fail because the identity_commitment value is incorrect, this was not the one used to generate the root expected.
    let identity_commitment = 4;
    let merkle_proof_length = 2;
    let merkle_proof_indices = [1, 1];
    let merkle_proof_siblings =
        [3, 7853200120776062878684798364095072458815029376092732009249414926327459813530];
    let root = 19646466727209028632368918362567300896600724196464472518263335051880792850046;
    let root_result = binary_merkle_root(
        poseidon2,
        identity_commitment,
        merkle_proof_length,
        merkle_proof_indices,
        merkle_proof_siblings,
    );

    assert(root_result == root);
}

#[test(should_fail)]
fn test_incorrect_depth_value() {
    //              Root: 19646466727209028632368918362567300896600724196464472518263335051880792850046
    //                    /                                                                     \
    //  7853200120776062878684798364095072458815029376092732009249414926327459813530   3477366564967156727841823348488314755036194240340197326130499876568103937279
    //        /              \                                                                   /              \
    //       1                2                                                                 3       1280033553760815678764770846139155613435155939625621669696967390845036381755

    let identity_commitment =
        1280033553760815678764770846139155613435155939625621669696967390845036381755;
    // This test is expected to fail because the depth value is incorrect, it should be 2.
    let merkle_proof_length = 1;
    let merkle_proof_indices = [1, 1];
    let merkle_proof_siblings =
        [3, 7853200120776062878684798364095072458815029376092732009249414926327459813530];
    let root = 19646466727209028632368918362567300896600724196464472518263335051880792850046;
    let root_result = binary_merkle_root(
        poseidon2,
        identity_commitment,
        merkle_proof_length,
        merkle_proof_indices,
        merkle_proof_siblings,
    );

    assert(root_result == root);
}

#[test(should_fail)]
fn test_incorrect_proof_indices_values() {
    //              Root: 19646466727209028632368918362567300896600724196464472518263335051880792850046
    //                    /                                                                     \
    //  7853200120776062878684798364095072458815029376092732009249414926327459813530   3477366564967156727841823348488314755036194240340197326130499876568103937279
    //        /              \                                                                   /              \
    //       1                2                                                                 3       1280033553760815678764770846139155613435155939625621669696967390845036381755

    let identity_commitment =
        1280033553760815678764770846139155613435155939625621669696967390845036381755;
    let merkle_proof_length = 2;
    // This test is expected to fail because the proof indices values are incorrect.
    let merkle_proof_indices = [0, 0];
    let merkle_proof_siblings =
        [3, 7853200120776062878684798364095072458815029376092732009249414926327459813530];
    let root = 19646466727209028632368918362567300896600724196464472518263335051880792850046;
    let root_result = binary_merkle_root(
        poseidon2,
        identity_commitment,
        merkle_proof_length,
        merkle_proof_indices,
        merkle_proof_siblings,
    );

    assert(root_result == root);
}

#[test(should_fail)]
fn test_incorrect_siblings_values() {
    //              Root: 19646466727209028632368918362567300896600724196464472518263335051880792850046
    //                    /                                                                     \
    //  7853200120776062878684798364095072458815029376092732009249414926327459813530   3477366564967156727841823348488314755036194240340197326130499876568103937279
    //        /              \                                                                   /              \
    //       1                2                                                                 3       1280033553760815678764770846139155613435155939625621669696967390845036381755

    let identity_commitment =
        1280033553760815678764770846139155613435155939625621669696967390845036381755;
    let merkle_proof_length = 2;
    let merkle_proof_indices = [1, 1];
    // This test is expected to fail because the proof siblings values are incorrect, these were not the ones used to generate the root expected.
    let merkle_proof_siblings = [3, 4];
    let root = 19646466727209028632368918362567300896600724196464472518263335051880792850046;
    let root_result = binary_merkle_root(
        poseidon2,
        identity_commitment,
        merkle_proof_length,
        merkle_proof_indices,
        merkle_proof_siblings,
    );

    assert(root_result == root);
}
