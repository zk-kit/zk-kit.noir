// This circuit is designed to calculate the root of a binary Merkle
// tree given a hash function, a leaf, its depth, and the necessary sibling
// information (aka proof of membership).
// A circuit is designed without the capability to iterate through
// a dynamic array. To address this, a parameter with the static maximum
// tree depth is defined (i.e. 'MAX_DEPTH'). And additionally, the circuit
// receives a dynamic depth as an input, which is utilized in calculating the
// true root of the Merkle tree. The actual depth of the Merkle tree
// may be equal to or less than the static maximum depth.
pub fn binary_merkle_root<let MAX_DEPTH: u32>(
    hasher: fn([Field; 2]) -> Field,
    leaf: Field,
    depth: u32,
    indices: [u1; MAX_DEPTH],
    siblings: [Field; MAX_DEPTH],
) -> Field {
    // Start from the leaf node
    let mut node = leaf;

    // Validate that the provided depth does not exceed the static MAX_DEPTH
    assert(depth <= MAX_DEPTH);

    // Iterate through the Merkle proof up to MAX_DEPTH
    for i in 0..MAX_DEPTH {
        // Only compute hash if the current level is within the tree depth
        if i < depth {
            let sibling = siblings[i];

            // Determine the ordering of node and sibling based on the index bit
            // If indices[i] == 0, node is on the left; otherwise, it's on the right
            let (left, right) = if indices[i] == 0 {
                (node, sibling)
            } else {
                (sibling, node)
            };

            // Hash the pair to move one level up the tree
            node = hasher([left, right]);
        }
    }

    // Return the root computed
    node
}
