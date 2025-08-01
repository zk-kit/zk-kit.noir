# @zk-kit/preimage-proof.noir

Preimage proof circuit written in Noir.

## Description

This package provides a preimage proof implementation that allows you to prove knowledge of a preimage for a given hash without revealing it. It supports both Field elements and 32-byte arrays as preimages.

## Features

- Works with any hash function that can be passed as a function parameter
- Simple and easy-to-use API
- Compatible with `@zk-kit/poseidon-proof.circom`

## Usage

### Using with Field inputs and outputs

```rust
use dep::preimage_proof::PreimageProof;

// Define a hash function for Field elements
fn poseidon_hash(input: Field) -> Field {
    // Use your preferred hash function
    // This is just a simple example
    input * input + 42
}

// In your circuit
fn main(preimage: Field, expected_hash: pub Field) {
    // This will assert that the hash of the preimage matches the expected hash
    PreimageProof::prove_field(preimage, expected_hash, poseidon_hash);
}
```

### Using with byte arrays

```rust
use dep::preimage_proof::PreimageProof;

// Define a hash function for byte arrays
fn sha256_hash(input: [u8; 32]) -> [u8; 32] {
    // Use your preferred hash function implementation
    // This is just a placeholder
    let mut output = [0; 32];
    for i in 0..32 {
        output[i] = input[i] + 1;
    }
    output
}

// In your circuit
fn main(preimage: [u8; 32], expected_hash: pub [u8; 32]) {
    // Prove knowledge of a byte array preimage
    PreimageProof::prove_bytes32(preimage, expected_hash, sha256_hash);
}
```

## License

The code in this repository is licensed under the [MIT License](../../LICENSE).
