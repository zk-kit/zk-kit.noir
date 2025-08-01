/// @title Preimage Proof Implementation for Fields
/// @dev This module provides a simple implementation for hash preimage proofs.
///      It allows proving knowledge of a preimage of a hash without revealing the preimage itself.

/// PreimageProof struct for proving knowledge of a preimage without revealing it.
pub struct PreimageProof {}

impl PreimageProof {
    /// Main circuit entry point for proving knowledge of a preimage.
    ///
    /// # Arguments
    /// * `preimage` - The private input (preimage) that should be kept secret
    /// * `expected_hash` - The public hash value to verify against
    /// * `hash_fn` - The hash function to use
    pub fn prove_field(preimage: Field, expected_hash: Field, hash_fn: fn(Field) -> Field) {
        let computed_hash = hash_fn(preimage);
        assert(computed_hash == expected_hash);
    }

    /// Main circuit entry point for proving knowledge of a bytes32 preimage.
    ///
    /// # Arguments
    /// * `preimage` - The private input (preimage) that should be kept secret
    /// * `expected_hash` - The public hash value to verify against
    /// * `hash_fn` - The hash function to use
    pub fn prove_bytes32(
        preimage: [u8; 32],
        expected_hash: [u8; 32],
        hash_fn: fn([u8; 32]) -> [u8; 32],
    ) {
        let computed_hash = hash_fn(preimage);

        // We need to compare arrays element by element
        let mut valid = true;
        for i in 0..32 {
            valid &= (computed_hash[i] == expected_hash[i]);
        }

        assert(valid);
    }
}
