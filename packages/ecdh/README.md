# ECDH Library

This repository introduces a set of functions and utilities for elliptic curve cryptography using. The library provides essential operations for the Elliptic Curve Diffie-Hellman (ECDH) protocol, along with utility functions for key generation, field element conversion, and shared key computation.

At the moment only Baby JubJub is supported, feel free to contribute with more curves.

## Features

- **Public Key Generation:** Generate public keys from private keys.
- **Shared Key Computation:** Compute shared keys for secure communication.

## Usage

To use this library, add the dependency to your `Nargo.toml`:

```toml
ecdh = { git = "https://github.com/zk-kit/zk-kit.noir", tag = "ecdh-v0.0.3", directory = "packages/ecdh" }
```

You can then import the ECDH implementation for the curve you're working with, like so:

```rust
use ecdh::bjj::BJJ; // only Baby JubJub is supported at the moment
let ecdh = BJJ::new(your_private_key);
let public_key = ecdh.derive_public_key();

let shared_key = ecdh.derive_shared_key(someone_elses_public_key);
```
