# Lean Incremental Merkle Tree Plus Library

This project contains the LeanIMT+ Noir circuit. It's used to verify membership and non-membership proofs for a [LeanIMT+](https://pse.dev/blog/lean-imt-plus-efficient-merkle-tree-for-membership-and-non-membership-proofs).

LeanIMT+ extends the [LeanIMT](https://zkkit.org/leanimt-paper.pdf) with non-membership proofs by turning the leaves into an implicit sorted linked list (indexed Merkle tree). A single proof can attest to either:

- `proof_type = false` (membership): `leaf_value == value`.
- `proof_type = true` (non-membership): the leaf is the low leaf of `value`, i.e. `leaf_value < value` and either `leaf_next_value > value` or `leaf_next_value == 0` (tail), and the low leaf is not a tombstone.

> [!IMPORTANT]
> If you only need **membership** proofs, use [binary-merkle-root](https://github.com/zk-kit/zk-kit.noir/tree/main/packages/binary-merkle-root) instead: it is the circuit for membership proofs for binary Merkle trees (including the LeanIMT) and is more optimized for that use case. Reach for LeanIMT+ only when you need efficient **non-membership** proofs.

## Import the library

To import the library, add the lib to the `Nargo.toml` file. For example:

```toml
[dependencies]
lean_imt_plus = { git = "https://github.com/zk-kit/zk-kit.noir", tag = "lean-imt-plus-v0.0.1", directory = "packages/lean-imt-plus" }
poseidon = { git = "https://github.com/noir-lang/poseidon", tag = "v0.3.0" }
```

You can find all released versions of the `lean-imt-plus` circuit at the following link: https://github.com/zk-kit/zk-kit.noir/releases?q=lean-imt-plus&expanded=true

## Usage

The circuit is instantiated with a static maximum tree depth (`MAX_DEPTH`), and it returns the Merkle root recomputed from the proof. Compare that root against your own trusted root.

```nr
use lean_imt_plus::lean_imt_plus_root;
use poseidon::poseidon::bn254::hash_2 as poseidon2;
use poseidon::poseidon::bn254::hash_3 as poseidon3;

fn main(
    proof_type: bool,
    value: Field,
    leaf_value: Field,
    leaf_next_value: Field,
    depth: u32,
    indices: [bool; MAX_DEPTH],
    siblings: [Field; MAX_DEPTH],
) {

    // Calculate Merkle root.
    let merkle_root = lean_imt_plus_root(poseidon3, poseidon2, proof_type, value, leaf_value, leaf_next_value, depth, indices, siblings);
}
```

## Generic hash function

The hash functions are parameters, so the construction is generic in the hash function: the example above uses Poseidon, but any other hash, such as SHA-256, can be used instead. Only two are required:

- `leaf_hasher`, a 3-input hash used to commit to the indexed leaves as `leaf_hasher([value, next_value, TAG_LEAF])`.
- `hasher`, a 2-input hash used for the internal nodes.

Both must be `fn` items (Noir function pointers), and the same pair must be used off-circuit to build the tree, so the roots match.
