// Domain-separation tag mixed into every leaf commitment.
pub global TAG_LEAF: Field = 1;

// LeanIMT+ proof verifier.
//
// Recomputes the Merkle root from a unified LeanIMT+ proof and enforces the
// `proof_type`-specific check.
//
//   proof_type = false (membership):
//       leaf_value == value
//
//   proof_type = true (non-membership):
//       leaf_value < value
//       AND (leaf_next_value > value OR leaf_next_value == 0)
//       AND (leaf_value != 0 OR the leaf is at index 0)
//
// The recomputed root is RETURNED, not asserted: nothing is proven until the
// caller compares it against a root it trusts.
//
// A LeanIMT+ extends the LeanIMT with non-membership proofs by turning the
// leaves into an implicit sorted linked list (indexed Merkle tree).
//
// A circuit is designed without the capability to iterate through a dynamic
// array. To address this, a parameter with the static maximum tree depth is
// defined (i.e. 'MAX_DEPTH'). And additionally, the circuit receives a
// dynamic `depth` as an input, which is utilized in calculating the true root
// of the Merkle tree. The actual depth of the Merkle tree may be equal to or
// less than the static maximum depth.
//
// Hash functions are injected:
//
//   - `leaf_hasher` is a 3-input hash used to commit to indexed leaves:
//     `leaf_hasher([value, next_value, TAG_LEAF])`.
//   - `hasher` is the 2-input hash used for internal nodes.
//
// The two must be domain separated from each other, so that a leaf commitment
// can never coincide with an internal-node hash. That closes a second-preimage
// attack specific to indexed Merkle trees, in which an attacker repackages an
// internal node as a leaf. Differing arities give this for free (Poseidon-3
// against Poseidon-2); with a hash whose arity is fixed at 2, fold the tag in
// with an extra pass, e.g. `h([h([value, next_value]), TAG_LEAF])`.
//
// Security properties:
//
//   - Zero-value guard: `value != 0` is enforced for both proof types so the
//     zero value (reserved for the sentinel and tombstones) cannot be used as
//     a proof target.
//
//   - Tombstone replay guard: in non-membership, the low leaf may have
//     `value == 0` ONLY at index 0 (the sentinel). A tombstoned slot
//     (`value == 0` at index > 0) is rejected as a low leaf.
//
//   - Canonical leaf index: index bits at positions `>= depth` must be zero,
//     so each physical leaf has a unique encoding. This matters if the leaf
//     index is bound to a downstream identifier (e.g. a nullifier).
//
// The Merkle walk follows the LeanIMT construction used in
// `binary_merkle_root`: an unpaired right child is promoted unchanged,
// encoded by stopping the walk at `depth` rather than always climbing
// MAX_DEPTH levels.
pub fn lean_imt_plus_root<let MAX_DEPTH: u32>(
    leaf_hasher: fn([Field; 3]) -> Field,
    hasher: fn([Field; 2]) -> Field,
    proof_type: bool,
    value: Field,
    leaf_value: Field,
    leaf_next_value: Field,
    depth: u32,
    indices: [bool; MAX_DEPTH],
    siblings: [Field; MAX_DEPTH],
) -> Field {
    assert(depth <= MAX_DEPTH, "LeanIMTPlus: depth exceeds MAX_DEPTH");

    // Reject the zero value as a proof target. The sentinel has value == 0 and
    // tombstones have value == 0; accepting `value == 0` would either let an
    // attacker claim membership of the sentinel or trivialize non-membership
    // of zero.
    assert(value != 0, "LeanIMTPlus: value must not be zero");

    // Canonical leaf index: every index bit at or beyond `depth` must be
    // false, so each physical leaf has a unique encoding. Given that, the leaf
    // is at index 0 exactly when every bit is false.
    let mut leaf_index_is_zero = true;
    for i in 0..MAX_DEPTH {
        if i >= depth {
            assert(!indices[i], "LeanIMTPlus: non-canonical leaf index");
        }
        leaf_index_is_zero &= !indices[i];
    }

    if !proof_type {
        // Membership: the proven leaf must hold exactly `value`.
        assert(leaf_value == value, "LeanIMTPlus: leaf value does not match value");
    } else {
        // Non-membership lower bound: leaf_value < value.
        assert(leaf_value.lt(value), "LeanIMTPlus: low leaf value is not below value");

        // Non-membership upper bound: leaf_next_value > value OR the low leaf
        // is the tail of the sorted list (leaf_next_value == 0).
        assert(
            value.lt(leaf_next_value) | (leaf_next_value == 0),
            "LeanIMTPlus: value is not below the low leaf next value",
        );

        // Tombstone replay guard: the low leaf may hold the zero value only
        // when it is the sentinel at index 0.
        assert((leaf_value != 0) | leaf_index_is_zero, "LeanIMTPlus: low leaf is a tombstone");
    }

    // Leaf commitment. TAG_LEAF is what separates it from an internal node.
    let mut node = leaf_hasher([leaf_value, leaf_next_value, TAG_LEAF]);

    // Iterate through the Merkle proof up to MAX_DEPTH.
    for i in 0..MAX_DEPTH {
        // Only compute the hash if the current level is within the tree depth.
        if i < depth {
            let sibling = siblings[i];

            // If indices[i] is false, node is on the left; otherwise it's on
            // the right.
            let (left, right) = if !indices[i] {
                (node, sibling)
            } else {
                (sibling, node)
            };

            node = hasher([left, right]);
        }
    }

    // Return the root computed.
    node
}
