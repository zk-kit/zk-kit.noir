// =======================================================================
//                             LazyTower Circuit
// =======================================================================
// A recursive hash-chain circuit that verifies membership proofs over a
// multi-level tree structure, similar to a Merkle tree.
//
// Parameters:
// - H (u32): Max number of levels (tree height).
// - W (u32): Max number of elements per level.
// - W_BITS (u32): Bit-width used to encode each level's length.
//
// - Verifies that a claimed item is covered by a valid Merkle-like
//   proof rooted at `digest_of_digest`.
//
// See `lazy_tower_hash_chain()` for expected inputs and proof structure.
// =======================================================================

use poseidon::poseidon::bn254::hash_2;

pub struct LazyTower<let H: u32, let W: u32, let W_BITS: u32> {}

impl<let H: u32, let W: u32, let W_BITS: u32> LazyTower<H, W, W_BITS> {
    // len 0:          0
    // len 1        in[0]
    // len 2:     H(in[0], in[1])
    // len 3:   H(H(in[0], in[1]), in[2])
    // len 4: H(H(H(in[0], in[1]), in[2]), in[3])
    /// Compute hash chain of given length using Poseidon.
    fn hash_chain<let N: u32>(inputs: [Field; N], len: u32) -> Field {
        let mut outs = [0; (N + 1)];
        outs[1] = inputs[0];

        // outs[0] = 0;
        // outs[1] = inputs[0]
        // Start from i = 2: outs[2] = H(inputs[0], inputs[1])
        for i in 2..(N + 1) {
            outs[i] = hash_2([outs[i - 1], inputs[i - 1]]);
        }
        outs[len]
    }

    /// Check if `inputs` is in array (returns 1 or 0).
    fn include(inputs: [Field; W], item: Field) -> u32 {
        let mut acc = 1;

        for i in 0..inputs.len() {
            acc *= inputs[i] - item;
        }

        (acc == 0) as u32
    }

    //             (N)(len)
    // leading_ones(4)(0) = [0, 0, 0, 0]
    // leading_ones(4)(1) = [1, 0, 0, 0]
    // leading_ones(4)(2) = [1, 1, 0, 0]
    // leading_ones(4)(3) = [1, 1, 1, 0]
    // leading_ones(4)(4) = [1, 1, 1, 1]
    // leading_ones(4)(5) = fail
    /// Return array of N bits with `len` leading ones.
    fn leading_ones<let N: u32>(len: u32) -> [u32; N] {
        let mut output = [0; N];
        let mut one_count = 0;

        for i in 0..N {
            if i < len { output[i] = 1; };
            let val = output[i] as Field;
            assert(val * (val - 1) == 0);
            one_count += output[i];
        }
        assert(one_count == len);

        let mut from_0_to_1 = [0; (N - 1)];
        let mut from_0_to_1_count = 0;

        for i in 0..(N - 1) {
            from_0_to_1[i] = (1 - output[i]) * output[i + 1];
            from_0_to_1_count += from_0_to_1[i];
        }
        assert(from_0_to_1_count == 0);

        output
    }

    // Is root being included in the first prefix_len elements of inputs[]?
    /// Ensure root appears within the first `prefix_len` items.
    fn include_prefix(inputs: [Field; W], prefix_len: u32, root: Field) -> u32 {
        let leading_ones: [u32; W] = Self::leading_ones(prefix_len);
        let mut is_good = [0; W];
        let mut good_count = 0;

        for i in 0..W {
            let result = if inputs[i] == root { 1 } else { 0 };
            is_good[i] = result & leading_ones[i];
            good_count += is_good[i];
        }

        assert(good_count == 1);
        good_count
    }

    // Computes a Merkle root at root_lv made from childrens[0 .. root_lv - 1][] and leaf.
    //
    // Each childrens[i] must include the digest of childrens[i - 1] for i = 1 ... root_lv - 1
    // childrens[0] must include leaf.
    //
    // root = digest of childrens[root_lv - 1] if root_lv > 0
    // root = leaf if root_lv == 0
    /// Verify Merkle proof up to root_lv and return root.
    fn check_merkle_proof_and_compute_root(
        childrens: [[Field; W]; H - 1],
        root_lv: u32,
        leaf: Field,
    ) -> Field {
        // TBI: to be included
        //
        // childrens[lv] must include TBI[lv]  for all lv in [0 ... root_lv - 1]
        //
        // TBI[0] = leaf
        // TBI[lv] = digest of children[lv - 1]  for all lv in [1 ... root_lv]
        // TBI[root_lv] is the root
        //
        // For root_lv = 3, H = 5:                                                   mustInclude[]
        //                                  TBI[4]                                        0
        // root_lv =>                       TBI[3] <== digest of childrens[2] ==> *root*  0
        //           childrens[2]  include  TBI[2] <== digest of childrens[1]             1
        //           childrens[1]  include  TBI[1] <== digest of childrens[0]             1
        //           childrens[0]  include  TBI[0] <== *leaf*                             1
        let mut TBI = [0; H];
        TBI[0] = leaf;

        let must_include: [u32; H - 1] = Self::leading_ones(root_lv);

        for lv in 0..(H - 1) {
            let not_must_include = 1 - (must_include[lv] != 0) as u32;
            assert((Self::include(childrens[lv], TBI[lv]) | not_must_include) == 1);

            TBI[lv + 1] = Self::hash_chain(childrens[lv], W);
        }

        let root = TBI[root_lv];

        root
    }

    /// Count nonzero level slots in packed level_lengths.
    fn compute_data_height(mut level_lengths: u32) -> u32 {
        let mut h = 0;

        for _ in 0..(32 / W_BITS) {
            let is_nonzero = (level_lengths != 0) as u32;
            h += is_nonzero;
            level_lengths >>= W_BITS;
        }

        h
    }

    /// Extract W_BITS-wide level length at index lv.
    fn compute_single_level_length(level_lengths: u32, lv: u32) -> u32 {
        let mask = (1 << W_BITS) - 1;
        level_lengths >> (lv * W_BITS) & mask
    }

    // The code relies on the following statement:
    // If
    //   1. levelLengthArray[i] belongs to [1, W] for i in [0, dataHeight - 1], otherwise levelLengthArray[i] = 0
    //   2. dataHeight belongs to [0, H - 1]
    //   3. the W^i weighted sum of levelLengthArray = levelLengths
    //
    // , then levelLengthArray[] and dataHeight will be unique.
    //
    // A very rough analogy would be like in the 10-base system,
    // the only sequence matches with 492 could only be the length 3 [2, 9, 4].
    /// Parse packed level_lengths into array and data height.
    fn compute_data_height_and_level_length_array(level_lengths: u32) -> (u32, [u32; H]) {
        let mut level_length_array = [0; H];
        let data_height = Self::compute_data_height(level_lengths);

        for lv in 0..H {
            level_length_array[lv] = Self::compute_single_level_length(level_lengths, lv);
        }

        let ones: [u32; H] = Self::leading_ones(data_height);
        let mut dummy = [[0; W_BITS]; H];
        let mut s = 0;

        for lv in 0..H {
            let level_length_array_to_field = level_length_array[lv] as Field;
            dummy[lv] = level_length_array_to_field.to_le_bits();
            assert(level_length_array[lv] <= W);
            assert((level_length_array[lv] != 0) == (ones[lv] == 1));
            s += level_length_array[lv] as Field * 2.pow_32(lv as Field * W_BITS as Field);
        }

        assert(level_lengths as Field == s);
        (data_height, level_length_array)
    }

    /// Verifies a claimed item's inclusion in a multi-level hash chain ending in `digest_of_digest`.
    pub fn lazy_tower_hash_chain(
        level_lengths: u32,
        digest_of_digest: Field,
        top_down_digest: [Field; H],
        root_lv: u32,
        root_level: [Field; W],
        childrens: [[Field; W]; H - 1],
        item: Field,
    ) {
        // Ensure at least one level exists; cannot prove inclusion with no data.
        assert(level_lengths != 0);

        // Unpack level_lengths and compute how many levels have non-zero data.
        let (data_height, level_length_array) =
            Self::compute_data_height_and_level_length_array(level_lengths);

        // Ensure dataHeight < 2^8
        assert(data_height < (2.pow_32(8)) as u32);

        // Ensure the claimed root level is within the active levels.
        assert(root_lv < data_height);

        // Fetch the number of elements at the root level.
        let root_level_length = level_length_array[root_lv];

        // Root level index must be valid.
        assert(root_lv < H);

        // Confirm that top-down digests compress correctly to digest_of_digest.
        assert(Self::hash_chain(top_down_digest, data_height) == digest_of_digest);

        // Reconstruct root_level digest and compare it to expected value.
        let root_level_digest = top_down_digest[data_height - root_lv - 1];
        assert(Self::hash_chain(root_level, root_level_length) == root_level_digest);

        // Check that the Merkle root includes the item and is present in root_level.
        let root = Self::check_merkle_proof_and_compute_root(childrens, root_lv, item);
        assert(Self::include_prefix(root_level, root_level_length, root) == 1);
    }
}
