use bignum::BigNum;
use bignum::fields::bn254Fq::BN254_Fq;
use poseidon::poseidon2::Poseidon2::hash;
use trees::merkle::{MerkleTree, Modifier, MT_Creator};

type BN = BN254_Fq;

fn hasher(input: [BN; 2]) -> BN {
    let limbs: [u128; 6] = &[].append(input[0].get_limbs()).append(input[1].get_limbs()).as_array();
    let hash_field = hash(limbs.map(|limb| limb as Field), 6);
    BigNum::from_limbs([hash_field as u128, 0x00, 0x00])
}

#[test]
fn test_merkle_tree_add_bignum() {
    let old_root = BigNum::from_limbs([0x21447efbbddb57d6fc5ad24d90638849, 0x00, 0x00]);
    let mut mt = MerkleTree::from(old_root, hasher);

    let leaf = BigNum::from_limbs([0x2bc00d90b885b09d12764e764410f7f6, 0x00, 0x00]);
    let paths = [BigNum::from_limbs([0x21447efbbddb57d6fc5ad24d90638849, 0x00, 0x00])];

    mt.add(leaf, 0x01, paths);
}

#[test]
fn test_merkle_tree_add_really_bignum() {
    let old_root = BigNum::from_limbs([0x2494b80a540ec0a0124a9dba7d5922e, 0x00, 0x00]);
    let mut mt = MerkleTree::from(old_root, hasher);

    let leaf = BN::from_limbs([
        0x30644e72e131a029b85045b68181585,
        0x30644e72e131a029b85045b68181585,
        0x30644e72e131a029b85045b68181585,
    ]);

    let paths = [BigNum::from_limbs([0x2494b80a540ec0a0124a9dba7d5922e, 0x00, 0x00])];
    mt.add(leaf, 0x01, paths);
    assert(mt.root == BN::from_limbs([198795359253477292896825724889155436891, 0x00, 0x00]));
}
