use bignum::BigNum;
use bignum::fields::bn254Fq::BN254_Fq;
use poseidon::poseidon2::Poseidon2::hash;
use trees::merkle::{MerkleTree, Modifier, MT_Creator};

<<<<<<< HEAD
type BN = BN254_Fq;

fn hasher(input: [BN; 2]) -> BN {
    let limbs: [u128; 6] = &[].append(input[0].get_limbs()).append(input[1].get_limbs()).as_array();
    let hash_field = hash(limbs.map(|limb| limb as Field), 6);
    BigNum::from_limbs([hash_field as u128, 0x00, 0x00])
=======
fn hasher<let N: u32>(input: [BN254_Fq; N]) -> BN254_Fq {
    let mut limbs: [Field] = &[];
    for i in 0..N {
        limbs = limbs.append(input[i].get_limbs().map(|limb| limb as Field));
    }
    let limbs_arr: [Field; 3 * N] = limbs.as_array();
    let hash_field: [u8; 32] = hash(limbs_arr, 3 * N).to_be_bytes();
    BN254_Fq::from_be_bytes(hash_field)
>>>>>>> origin
}

#[test]
fn test_merkle_tree_add_bignum() {
<<<<<<< HEAD
    let old_root = BigNum::from_limbs([0x21447efbbddb57d6fc5ad24d90638849, 0x00, 0x00]);
    let mut mt = MerkleTree::from(old_root, hasher);

    let leaf = BigNum::from_limbs([0x2bc00d90b885b09d12764e764410f7f6, 0x00, 0x00]);
    let paths = [BigNum::from_limbs([0x21447efbbddb57d6fc5ad24d90638849, 0x00, 0x00])];
=======
    let old_root = BN254_Fq::from_limbs([0x21447efbbddb57d6fc5ad24d90638849, 0x00, 0x00]);
    let mut mt: MerkleTree<BN254_Fq> = MerkleTree::from(old_root, hasher);

    let leaf = BN254_Fq::from_limbs([0x2bc00d90b885b09d12764e764410f7f6, 0x00, 0x00]);
    let paths: [BN254_Fq; 1] =
        [BN254_Fq::from_limbs([0x21447efbbddb57d6fc5ad24d90638849, 0x00, 0x00])];
>>>>>>> origin

    mt.add(leaf, 0x01, paths);
}

#[test]
fn test_merkle_tree_add_really_bignum() {
<<<<<<< HEAD
    let old_root = BigNum::from_limbs([0x2494b80a540ec0a0124a9dba7d5922e, 0x00, 0x00]);
    let mut mt = MerkleTree::from(old_root, hasher);

    let leaf = BN::from_limbs([
=======
    let old_root = BN254_Fq::from_limbs([0x2494b80a540ec0a0124a9dba7d5922e, 0x00, 0x00]);
    let mut mt: MerkleTree<BN254_Fq> = MerkleTree::from(old_root, hasher);

    let leaf = BN254_Fq::from_limbs([
>>>>>>> origin
        0x30644e72e131a029b85045b68181585,
        0x30644e72e131a029b85045b68181585,
        0x30644e72e131a029b85045b68181585,
    ]);

<<<<<<< HEAD
    let paths = [BigNum::from_limbs([0x2494b80a540ec0a0124a9dba7d5922e, 0x00, 0x00])];
    mt.add(leaf, 0x01, paths);
    assert(mt.root == BN::from_limbs([198795359253477292896825724889155436891, 0x00, 0x00]));
=======
    let paths: [BN254_Fq; 1] =
        [BN254_Fq::from_limbs([0x2494b80a540ec0a0124a9dba7d5922e, 0x00, 0x00])];
    mt.add(leaf, 0x01, paths);
    assert(
        mt.root
            == BN254_Fq::from_limbs([
                740387881524827834158472907384095067,
                1030682176101042812431910616255430037,
                4050,
            ]),
    );
>>>>>>> origin
}
