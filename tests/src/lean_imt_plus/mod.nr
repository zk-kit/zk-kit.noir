use lean_imt_plus::lean_imt_plus_root;
use poseidon::poseidon::bn254::hash_2 as poseidon2;
use poseidon::poseidon::bn254::hash_3 as poseidon3;

// These tests were generated using the LeanIMT+ library:
// https://github.com/zk-kit/zk-kit/tree/main/packages/lean-imt-plus
//
// Every fixture below comes from the same tree, built by inserting
// [10, 25, 7, 3, 41, 18] in that order (unless the test says otherwise):
//
//                                   Root
//                       /                        \
//                      D                          E
//                  /       \                  /       \
//                 A         B                C         L6
//               /   \     /   \            /   \        |
//             L0     L1  L2    L3        L4     L5      L6
//           (0,3)(10,18)(25,41)(7,10)  (3,7) (41,0)   (18,25)
//
//   Lk = leaf_hash([value, next_value, TAG_LEAF]) of the leaf record shown
//   A  = h(L0, L1)     B = h(L2, L3)     C = h(L4, L5)
//   D  = h(A, B)       E = h(C, L6)      Root = h(D, E)
//
// A leaf record is `(value, next_value)`. The records form the sorted linked
// list 0 -> 3 -> 7 -> 10 -> 18 -> 25 -> 41 -> 0, where the leaf at index 0 is
// the sentinel and a `next_value` of 0 marks the tail. The sorted order is
// independent of the physical leaf order, which is insertion order.
//
// The tree has 7 leaves, so L6 is unpaired and is promoted unchanged (the
// LeanIMT construction). That is why the proof for L6 has depth 2 while every
// other proof has depth 3.

// Static maximum tree depth the tests are instantiated with. Proofs are padded
// to this many siblings.
global MAX_DEPTH: u32 = 10;

// Root of the tree built from [10, 25, 7, 3, 41, 18].
global ROOT: Field = 18320681808949032185474688441904447859679638873743640995751743244161153587152;

fn verify(
    proof_type: bool,
    value: Field,
    leaf_value: Field,
    leaf_next_value: Field,
    depth: u32,
    indices: [bool; MAX_DEPTH],
    siblings: [Field; MAX_DEPTH],
) -> Field {
    lean_imt_plus_root::<MAX_DEPTH>(
        poseidon3,
        poseidon2,
        proof_type,
        value,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        siblings,
    )
}

// Membership proof for the value 25, held by leaf L2.
// Path: L2 -> B -> D -> Root, so the siblings are [L3, A, E].
fn membership_proof() -> (bool, Field, Field, Field, u32, [bool; MAX_DEPTH], [Field; MAX_DEPTH]) {
    (
        false, 25, 25, 41, 3, [false, true, false, false, false, false, false, false, false, false],
        [
            7713000925643888747415759216302115073278419167771690470331299538696849273031,
            12415230993349633856578648540012736441088925890577073937978084222292399896466,
            11175222510662612811689640339836167643898952564261102425916147959914802843869,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ],
    )
}

// Non-membership proof for the value 20, whose low leaf is L6, the record
// (18, 25). L6 is promoted, so its path is L6 -> E -> Root and the siblings
// are [C, D].
fn non_membership_proof() -> (bool, Field, Field, Field, u32, [bool; MAX_DEPTH], [Field; MAX_DEPTH]) {
    (
        true, 20, 18, 25, 2, [true, true, false, false, false, false, false, false, false, false],
        [
            19865898576055370084355537845451793856618260926881349144497239851167185096130,
            9108671635997395931857715030397463242756024013119895822330952656184287220478,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ],
    )
}

#[test]
fn test_membership() {
    let (proof_type, value, leaf_value, leaf_next_value, depth, indices, siblings) =
        membership_proof();
    let root = verify(
        proof_type,
        value,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        siblings,
    );

    assert(root == ROOT);
}

#[test]
fn test_non_membership_between_two_leaves() {
    // 20 is absent: its low leaf is L6 = (18, 25), so 18 < 20 < 25.
    let (proof_type, value, leaf_value, leaf_next_value, depth, indices, siblings) =
        non_membership_proof();
    let root = verify(
        proof_type,
        value,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        siblings,
    );

    assert(root == ROOT);
}

#[test]
fn test_non_membership_with_sentinel_as_low_leaf() {
    // 1 is smaller than every value in the tree, so the low leaf is the
    // sentinel L0 = (0, 3). Path: L0 -> A -> D -> Root, siblings [L1, B, E].
    let root = verify(
        true,
        1,
        0,
        3,
        3,
        [false, false, false, false, false, false, false, false, false, false],
        [
            11280780642151651022578533037284723339341609779586704378986597432029961664432,
            17725170470030514310300453234383404221019013523782160316863058251644475072663,
            11175222510662612811689640339836167643898952564261102425916147959914802843869,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ],
    );

    assert(root == ROOT);
}

#[test]
fn test_non_membership_with_tail_as_low_leaf() {
    // 100 is larger than every value in the tree, so the low leaf is the tail
    // L5 = (41, 0). Path: L5 -> C -> E -> Root, siblings [L4, L6, D].
    let root = verify(
        true,
        100,
        41,
        0,
        3,
        [true, false, true, false, false, false, false, false, false, false],
        [
            7921082650327604767918283174938328368312820602706338903177979794627700177991,
            18935144215641620866384183620551515812711311290291408911018017054508032652096,
            9108671635997395931857715030397463242756024013119895822330952656184287220478,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ],
    );

    assert(root == ROOT);
}

#[test]
fn test_membership_after_update() {
    // Same tree, then update(25, 22). The new value is written in place, so
    // L2 becomes (22, 41) and L6 is relinked to (18, 22):
    //
    //             L0     L1  L2    L3        L4     L5      L6
    //           (0,3)(10,18)(22,41)(7,10)  (3,7) (41,0)   (18,22)
    //
    // The path of L2 is unchanged, but E is rehashed because L6 changed.
    let root = verify(
        false,
        22,
        22,
        41,
        3,
        [false, true, false, false, false, false, false, false, false, false],
        [
            7713000925643888747415759216302115073278419167771690470331299538696849273031,
            12415230993349633856578648540012736441088925890577073937978084222292399896466,
            20077395612755608401199279230610867619658516956584377397491686793516986838481,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ],
    );

    assert(root == 19977620354597677093495509925704930555842079327932706225623162838188038174920);
}

#[test]
fn test_non_membership_after_remove() {
    // Same tree, then remove(25). L2 is tombstoned and L6 is relinked to skip
    // over it:
    //
    //             L0     L1  L2    L3        L4     L5      L6
    //           (0,3)(10,18) (0,0)(7,10)  (3,7) (41,0)   (18,41)
    //
    // The low leaf of the now-absent 25 is L6 = (18, 41).
    let root = verify(
        true,
        25,
        18,
        41,
        2,
        [true, true, false, false, false, false, false, false, false, false],
        [
            19865898576055370084355537845451793856618260926881349144497239851167185096130,
            15081635018953584357841560524288351338775370159495036924222107828208932326310,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ],
    );

    assert(root == 10708076496401472728008526916715680347605104473532367695555135350547745973601);
}

#[test(should_fail_with = "LeanIMTPlus: leaf value does not match value")]
fn test_membership_with_mismatched_leaf_value() {
    // This test is expected to fail because a membership proof requires the
    // proven leaf to hold exactly `value`, and L2 holds 25, not 26.
    let (proof_type, _, leaf_value, leaf_next_value, depth, indices, siblings) = membership_proof();
    let _ = verify(
        proof_type,
        26,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        siblings,
    );
}

#[test(should_fail_with = "LeanIMTPlus: low leaf value is not below value")]
fn test_non_membership_of_an_actual_member() {
    // This test is expected to fail because 18 is in the tree: it is held by
    // the low leaf L6 itself, so `leaf_value < value` does not hold.
    let (proof_type, _, leaf_value, leaf_next_value, depth, indices, siblings) =
        non_membership_proof();
    let _ = verify(
        proof_type,
        18,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        siblings,
    );
}

#[test(should_fail_with = "LeanIMTPlus: value is not below the low leaf next value")]
fn test_non_membership_with_a_low_leaf_that_is_not_adjacent() {
    // This test is expected to fail because the low leaf of 30 is not L6: the
    // sorted list continues 18 -> 25 -> 41, so a low leaf whose next value is
    // 25 does not bracket 30. Without this check a proof could skip over the
    // leaves lying between the low leaf and the value.
    let (proof_type, _, leaf_value, leaf_next_value, depth, indices, siblings) =
        non_membership_proof();
    let _ = verify(
        proof_type,
        30,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        siblings,
    );
}

#[test(should_fail_with = "LeanIMTPlus: value is not below the low leaf next value")]
fn test_non_membership_of_the_low_leaf_successor() {
    // This test is expected to fail because 25 is in the tree: it is the very
    // value the low leaf L6 = (18, 25) points at. This is the equality
    // boundary of the upper-bound check, `value < leaf_next_value` must be
    // strict, otherwise a member could be proven absent through its
    // predecessor.
    let (proof_type, _, leaf_value, leaf_next_value, depth, indices, siblings) =
        non_membership_proof();
    let _ = verify(
        proof_type,
        25,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        siblings,
    );
}

#[test(should_fail_with = "LeanIMTPlus: value must not be zero")]
fn test_zero_value() {
    // This test is expected to fail because the zero value is reserved for the
    // sentinel and for tombstones, so it can never be a proof target.
    let (proof_type, _, leaf_value, leaf_next_value, depth, indices, siblings) = membership_proof();
    let _ = verify(
        proof_type,
        0,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        siblings,
    );
}

#[test(should_fail_with = "LeanIMTPlus: non-canonical leaf index")]
fn test_non_canonical_leaf_index() {
    // This test is expected to fail because an index bit is set beyond
    // `depth - 1`, encoding the same physical position non-canonically.
    let (proof_type, value, leaf_value, leaf_next_value, depth, _, siblings) = membership_proof();
    let _ = verify(
        proof_type,
        value,
        leaf_value,
        leaf_next_value,
        depth,
        [false, true, false, true, false, false, false, false, false, false],
        siblings,
    );
}

#[test(should_fail_with = "LeanIMTPlus: low leaf is a tombstone")]
fn test_non_membership_with_a_tombstone_as_low_leaf() {
    // This test is expected to fail because the low leaf has the tombstone
    // shape (0, 0) at a non-zero leaf index, the shape L2 takes in the
    // remove test above. Only the sentinel L0 may hold the zero value.
    let (proof_type, value, _, _, depth, indices, siblings) = non_membership_proof();
    let _ = verify(proof_type, value, 0, 0, depth, indices, siblings);
}

#[test(should_fail)]
fn test_incorrect_siblings_values() {
    // This test is expected to fail because the siblings are not the [L3, A, E]
    // used to generate the expected root.
    let (proof_type, value, leaf_value, leaf_next_value, depth, indices, _) = membership_proof();
    let root = verify(
        proof_type,
        value,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        [1, 2, 3, 0, 0, 0, 0, 0, 0, 0],
    );

    assert(root == ROOT);
}

#[test(should_fail)]
fn test_incorrect_depth_value() {
    // This test is expected to fail because the depth is 3, not 2, so the walk
    // stops one level short of the root.
    let (proof_type, value, leaf_value, leaf_next_value, _, indices, siblings) = membership_proof();
    let root = verify(
        proof_type,
        value,
        leaf_value,
        leaf_next_value,
        2,
        indices,
        siblings,
    );

    assert(root == ROOT);
}

#[test(should_fail_with = "LeanIMTPlus: depth exceeds MAX_DEPTH")]
fn test_depth_greater_than_max_depth() {
    // This test is expected to fail because the depth exceeds MAX_DEPTH.
    let (proof_type, value, leaf_value, leaf_next_value, _, indices, siblings) = membership_proof();
    let _ = verify(
        proof_type,
        value,
        leaf_value,
        leaf_next_value,
        MAX_DEPTH + 1,
        indices,
        siblings,
    );
}

// Tree shapes: one level, an odd number of leaves (which the LeanIMT handles
// by promoting an unpaired node unchanged), and a proof whose depth equals
// MAX_DEPTH.

#[test]
fn test_one_level() {
    //                    Root
    //                  /      \
    //                L0        L1
    //              (0,10)    (10,0)
    //
    // Tree built from [10] alone: the sentinel plus a single value, so the
    // proof for L1 has one level and depth = 1.
    let root = verify(
        false,
        10,
        10,
        0,
        1,
        [true, false, false, false, false, false, false, false, false, false],
        [
            18069132284520201727832024694996019315677027866342868341249356941629964797693,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ],
    );

    assert(root == 8759517305270632741161295306876400022843839594683540810233909226427512299732);
}

#[test]
fn test_odd_number_of_leaves() {
    //                    Root
    //                  /      \
    //                 A         L2
    //               /   \        |
    //             L0     L1      L2
    //           (0,10)(10,25)  (25,0)
    //
    //   A = h(L0, L1)     Root = h(A, L2)
    //
    // Tree built from [10, 25]: three leaves, so L2 is unpaired and is
    // promoted unchanged. Its proof is [A] alone, stopping at depth = 1.
    let root = verify(
        false,
        25,
        25,
        0,
        1,
        [true, false, false, false, false, false, false, false, false, false],
        [
            1809755786113815759503290694067211682714200745291079719151502762610400007925,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ],
    );

    assert(root == 16010581774365453385082367267042004669284353860194929370158097553983460197982);
}

#[test]
fn test_depth_equals_max_depth() {
    // The same L2 membership proof for 25, but with the circuit instantiated
    // at MAX_DEPTH = 3, so depth = 3 = MAX_DEPTH and no padding is involved.
    let root = lean_imt_plus_root::<3>(
        poseidon3,
        poseidon2,
        false,
        25,
        25,
        41,
        3,
        [false, true, false],
        [
            7713000925643888747415759216302115073278419167771690470331299538696849273031,
            12415230993349633856578648540012736441088925890577073937978084222292399896466,
            11175222510662612811689640339836167643898952564261102425916147959914802843869,
        ],
    );

    assert(root == ROOT);
}

fn dummy_leaf_hasher(input: [Field; 3]) -> Field {
    input[0] + input[1] + input[2]
}

fn dummy_hasher(input: [Field; 2]) -> Field {
    input[0] + input[1]
}

#[test(should_fail)]
fn test_incorrect_hash_function() {
    // This test is expected to fail because the hasher functions are
    // incorrect. The root was generated using poseidon.
    let (proof_type, value, leaf_value, leaf_next_value, depth, indices, siblings) =
        membership_proof();
    let root = lean_imt_plus_root::<MAX_DEPTH>(
        dummy_leaf_hasher,
        dummy_hasher,
        proof_type,
        value,
        leaf_value,
        leaf_next_value,
        depth,
        indices,
        siblings,
    );

    assert(root == ROOT);
}

#[test(should_fail)]
fn test_incorrect_proof_indices_values() {
    // This test is expected to fail because the proof indices values are
    // incorrect: L2 is placed on the wrong side at every level.
    let (proof_type, value, leaf_value, leaf_next_value, depth, _, siblings) = membership_proof();
    let root = verify(
        proof_type,
        value,
        leaf_value,
        leaf_next_value,
        depth,
        [true, false, true, false, false, false, false, false, false, false],
        siblings,
    );

    assert(root == ROOT);
}

#[test(should_fail)]
fn test_incorrect_leaf_next_value() {
    // This test is expected to fail because the next value of the low leaf L6
    // was tampered with, turning the record (18, 25) into (18, 30). The forged
    // 30 still satisfies 18 < 20 < 30, so the ordering checks pass, but L6
    // changes and the recomputed root no longer matches.
    let (proof_type, value, leaf_value, _, depth, indices, siblings) = non_membership_proof();
    let root = verify(proof_type, value, leaf_value, 30, depth, indices, siblings);

    assert(root == ROOT);
}
