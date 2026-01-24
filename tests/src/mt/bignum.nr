use bignum::BigNum;
use bignum::fields::bn254Fq::BN254_Fq;
use poseidon::poseidon2::Poseidon2::hash;
use trees::merkle::{MerkleTree, Modifier, MT_Creator};

fn hasher<let N: u32>(input: [BN254_Fq; N]) -> BN254_Fq {
    let mut limbs: [Field] = &[];
    for i in 0..N {
        limbs = limbs.append(input[i].get_limbs().map(|limb| limb as Field));
    }
    let limbs_arr: [Field; 3 * N] = limbs.as_array();
    let hash_field: [u8; 32] = hash(limbs_arr, 3 * N).to_be_bytes();
    BN254_Fq::from_be_bytes(hash_field)
}

#[test]
fn test_merkle_tree_add_bignum() {
    let old_root = BN254_Fq::from_limbs([0x447efbbddb57d6fc5ad24d90638849, 0x00, 0x00]);
    let mut mt: MerkleTree<BN254_Fq> = MerkleTree::from(old_root, hasher);

    let leaf = BN254_Fq::from_limbs([0xc00d90b885b09d12764e764410f7f6, 0x00, 0x00]);
    let paths: [BN254_Fq; 1] =
        [BN254_Fq::from_limbs([0x447efbbddb57d6fc5ad24d90638849, 0x00, 0x00])];

    mt.add(leaf, 0x01, paths);
    assert(
        mt.root
            == BN254_Fq::from_limbs([
                0xdc7016068f254e01eaa7e042ea7ba2,
                0x502c6d7fbcf4951b7a5db95d8c911b,
                0x1a7,
            ]),
    );
}

#[test]
fn test_merkle_tree_add_really_bignum() {
    let old_root = BN254_Fq::from_limbs([0x494b80a540ec0a0124a9dba7d5922e, 0x00, 0x00]);
    let mut mt: MerkleTree<BN254_Fq> = MerkleTree::from(old_root, hasher);

    let leaf = BN254_Fq::from_limbs([0x644e72e131a029b85045b68181585, 0x30, 0x30]);
    let paths: [BN254_Fq; 1] =
        [BN254_Fq::from_limbs([0x494b80a540ec0a0124a9dba7d5922e, 0x00, 0x00])];

    mt.add(leaf, 0x01, paths);
    assert(
        mt.root
            == BN254_Fq::from_limbs([
                0x8a29abcba3d944fdafa66c79b0c21d,
                0xec833c052ac0441135568743defbcb,
                0x199c,
            ]),
    );
}
