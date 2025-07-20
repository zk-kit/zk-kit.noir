use bignum::BigNum;
use bignum::fields::bn254Fq::BN254_Fq;
use poseidon::poseidon2::Poseidon2::hash;
use trees::sparse_merkle::{Modifier, NonMembershipProver, SMT_Creator, SparseMerkleTree};

type BN = BN254_Fq;

fn hasher<let N: u32>(input: [BN; N]) -> BN {
    let mut limbs: [Field] = &[];
    for i in 0..N {
        limbs = limbs.append(input[i].get_limbs().map(|limb| limb as Field));
    }
    let limbs_arr: [Field; 3 * N] = limbs.as_array();
    let hash_field: [u8; 32] = hash(limbs_arr, 3 * N).to_be_bytes();
    BN254_Fq::from_be_bytes(hash_field)
}

#[test]
fn test_sparse_merkle_tree_add_bignum() {
    let mut smt: SparseMerkleTree<BN> = SparseMerkleTree::new(hasher, hasher);

    let key = BN::from_limbs([0x01, 0x00, 0x00]);
    let value = BN::from_limbs([
        0x6b231cbc70b3c0d69bc398bd006eb5,
        0x412fba0629bcca2a2295b619e5c5c6,
        0x03fa,
    ]);
    let siblings: [BN; 254] = [BN::zero(); 254];
    smt.add((key, value), 0x01, siblings);
    assert(
        smt.root
            == BN::from_limbs([
                0xd62299775a0f2bf81e430c4b922592,
                0x422445e518efc86eab855bd6eb7f7f,
                0x023c,
            ]),
    );
}

#[test]
fn test_sparse_merkle_tree_add_really_bignum() {
    let root: BN = BN::from_limbs([
        0x1be857787743ed2a6e1243c3c4234c,
        0x282e99f6ba97ce4a5e6c6dcc1987b3,
        0x3ed4,
    ]);
    let mut smt = SparseMerkleTree::from(root, hasher, hasher);

    let key: BN = BN::from_limbs([0x02, 0x00, 0x00]);
    let value: BN = BN::from_limbs([
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
    ]);

    let mut siblings: [BN; 254] = [BN::default(); 254];
    siblings[253] = BN::from_limbs([
        0x1be857787743ed2a6e1243c3c4234c,
        0x282e99f6ba97ce4a5e6c6dcc1987b3,
        0x3ed4,
    ]);
    smt.add((key, value), 0x02, siblings);
    assert(
        smt.root
            == BN::from_limbs([
                0xc6f622dabf46b66be9785ab95216ce,
                0xd58446696eceac31a7af4e23d0269e,
                0x0f39,
            ]),
    );
}

#[test]
fn test_sparse_merkle_tree_non_membership_bignum() {
    let root = BN::from_limbs([
        0x05c0696110efae45316e89dd47f5f7,
        0xf8e0b03aa850c8eb7967c9c5aa02ae,
        0x24b0,
    ]);

    let mut smt = SparseMerkleTree::from(root, hasher, hasher);

    let mut siblings: [BN; 254] = [BN::zero(); 254];
    siblings[253] = BN::from_limbs([
        0x1be857787743ed2a6e1243c3c4234c,
        0x282e99f6ba97ce4a5e6c6dcc1987b3,
        0x3ed4,
    ]);
    let matching_entry = (
        BN::from_limbs([0x02, 0x00, 0x00]),
        BN::from_limbs([
            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
        ]),
    );

    smt.non_membership(matching_entry, 0x01, siblings);
}

// #[test]
// fn test_verify_non_membership_proof() {
//     let root = 0x2151c2f9fdef58b8a33921d853d54895d2d9c7446bc5c9cdbe71e344a5cea1ed;
//     let smt = SparseMerkleTree::from(root, |h| hash(h, 3), |h| hash(h, 2));

//     let key = 0x04;
//     let value = 0x04;
//     let entry = (key, value);
//     let matching_entry = (0x02, 0x02);
//     let mut siblings: [Field; 254] = [0; 254];
//     siblings[253] = 0x2caff4d2bbd06504be02b53bf953596476bec9448d5a365c05daf1f39812f42;

//     smt.non_membership(entry, matching_entry, entry.0, siblings);
// }
