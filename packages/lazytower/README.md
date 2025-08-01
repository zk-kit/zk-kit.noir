# LazyTower Library

This Noir library provides a LazyTower recursive hash-chain circuit implementation. It's designed to verify membership proofs over a multi-level Merkle-like tree structure using Poseidon hashing.

These implementations follow the ones in [zk-kit](https://github.com/privacy-scaling-explorations/zk-kit).

You can use this library for recursive inclusion proofs across stacked Merkle-like levels with compact encoding of tree structure.

## Usage

To use LazyTower in your project, add the library to your `Nargo.toml` file. For example:

```toml
[dependencies]
lazy_tower = { git = "https://github.com/privacy-scaling-explorations/zk-kit.noir", tag = "lazy-tower-v0.0.1", directory = "packages/lazy-tower" }
```

And import it in your file.

## LazyTower

The `LazyTower` circuit is generic over three parameters:

- `H`: Number of levels (tree height)
- `W`: Max number of elements per level
- `W_BITS`: Bit-width used to encode each level's length (must satisfy `W < 2^W_BITS`)

### Examples

A LazyTower:

```rust
use lazy_tower::tower::LazyTower;

// Define global parameters
global H: u32 = 8;
global W: u32 = 4;
global W_BITS: u32 = 4;

fn main(
    level_lengths: pub u32,
    digest_of_digest: pub Field,
    top_down_digest: pub [Field; H],
    root_lv: pub u32,
    root_level: pub [Field; W],
    childrens: pub [[Field; W]; H - 1],
    item: pub Field,
) {
    LazyTower::<H, W, W_BITS>::lazy_tower_hash_chain(
        level_lengths,
        digest_of_digest,
        top_down_digest,
        root_lv,
        root_level,
        childrens,
        item,
    );
}
```

