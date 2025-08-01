mod poseidon;
mod sha256;

#[test]
fn test_all() {
    poseidon::test_poseidon_preimage();
    sha256::test_sha256_preimage();
}
