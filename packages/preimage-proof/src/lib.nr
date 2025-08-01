/// @title Generic Preimage Proof Circuit for ZK-Kit
/// @dev This circuit proves knowledge of a preimage for a given hash without revealing it.
/// It is designed to be generic and support any hash function.

mod preimage;

pub use preimage::PreimageProof;
