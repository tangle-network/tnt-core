package ssz

import (
	"crypto/sha256"
	"fmt"
)

// MerkleTree represents a binary merkle tree
type MerkleTree struct {
	leaves [][32]byte
	layers [][][32]byte
	depth  int
}

// NewMerkleTree creates a new merkle tree from leaves
func NewMerkleTree(leaves [][32]byte, depth int) *MerkleTree {
	if depth == 0 {
		depth = ceilLog2(len(leaves))
	}

	// Pad leaves to 2^depth
	paddedSize := 1 << depth
	padded := make([][32]byte, paddedSize)
	copy(padded, leaves)

	tree := &MerkleTree{
		leaves: padded,
		depth:  depth,
	}
	tree.build()
	return tree
}

// build constructs all layers of the tree
func (t *MerkleTree) build() {
	t.layers = make([][][32]byte, t.depth+1)
	t.layers[0] = t.leaves

	current := t.leaves
	for i := 0; i < t.depth; i++ {
		next := make([][32]byte, len(current)/2)
		for j := 0; j < len(next); j++ {
			next[j] = hashPair(current[j*2], current[j*2+1])
		}
		t.layers[i+1] = next
		current = next
	}
}

// Root returns the merkle root
func (t *MerkleTree) Root() [32]byte {
	if len(t.layers) == 0 || len(t.layers[t.depth]) == 0 {
		return [32]byte{}
	}
	return t.layers[t.depth][0]
}

// GenerateProof generates a merkle proof for a leaf at the given index
func (t *MerkleTree) GenerateProof(index int) ([][32]byte, error) {
	if index < 0 || index >= len(t.leaves) {
		return nil, fmt.Errorf("index %d out of bounds", index)
	}

	proof := make([][32]byte, t.depth)
	idx := index

	for i := 0; i < t.depth; i++ {
		// Get sibling index
		siblingIdx := idx ^ 1
		proof[i] = t.layers[i][siblingIdx]
		idx /= 2
	}

	return proof, nil
}

// VerifyProof verifies a merkle proof
func VerifyProof(leaf [32]byte, index int, proof [][32]byte, root [32]byte) bool {
	current := leaf
	idx := index

	for _, sibling := range proof {
		if idx%2 == 0 {
			current = hashPair(current, sibling)
		} else {
			current = hashPair(sibling, current)
		}
		idx /= 2
	}

	return current == root
}

// GeneralizedIndex computes the generalized index for a given path
// path is a list of child indices (0 = left, 1 = right)
func GeneralizedIndex(path []int) int {
	gindex := 1
	for _, p := range path {
		gindex = gindex*2 + p
	}
	return gindex
}

// GeneralizedIndexToPath converts a generalized index to a path
func GeneralizedIndexToPath(gindex int) []int {
	if gindex <= 0 {
		return nil
	}

	// Find depth
	depth := 0
	temp := gindex
	for temp > 1 {
		temp /= 2
		depth++
	}

	// Extract path
	path := make([]int, depth)
	for i := depth - 1; i >= 0; i-- {
		path[i] = gindex % 2
		gindex /= 2
	}

	return path
}

// GetBranchIndices returns the generalized indices of all nodes in a proof
func GetBranchIndices(gindex int) []int {
	indices := []int{}
	current := gindex
	for current > 1 {
		// Sibling index
		sibling := current ^ 1
		indices = append(indices, sibling)
		current /= 2
	}
	return indices
}

// ProofFromGeneralizedIndex generates a proof for a generalized index
func (t *MerkleTree) ProofFromGeneralizedIndex(gindex int) ([][32]byte, error) {
	path := GeneralizedIndexToPath(gindex)
	if len(path) != t.depth {
		return nil, fmt.Errorf("generalized index depth %d doesn't match tree depth %d", len(path), t.depth)
	}

	// Convert path to leaf index
	index := 0
	for _, p := range path {
		index = index*2 + p
	}

	return t.GenerateProof(index)
}

// MixInLength mixes in a length value to create a list root
func MixInLength(root [32]byte, length uint64) [32]byte {
	lengthBytes := uint64ToBytes32LE(length)
	return hashPair(root, lengthBytes)
}

// ConcatGeneralizedIndices combines generalized indices for nested containers
func ConcatGeneralizedIndices(indices ...int) int {
	if len(indices) == 0 {
		return 1
	}

	result := indices[0]
	for i := 1; i < len(indices); i++ {
		// Get depth of current index
		depth := floorLog2(indices[i])
		// Shift result and add index bits
		result = (result << depth) | (indices[i] & ((1 << depth) - 1))
	}
	return result
}

// ValidatorGIndex computes the generalized index for a validator at given index
func ValidatorGIndex(validatorIndex uint64) uint64 {
	// validators is at index 11 in beacon state (gindex 43 = (1<<5)|11)
	// Each validator is in the validators list which is merkleized
	// gindex = (VALIDATOR_CONTAINER_GINDEX << VALIDATOR_TREE_HEIGHT) | validatorIndex
	return (ValidatorContainerGIndex << ValidatorTreeHeight) | validatorIndex
}

// BalanceGIndex computes the generalized index for a balance at given validator index
func BalanceGIndex(validatorIndex uint64) uint64 {
	// balances is at index 12 in beacon state (gindex 44 = (1<<5)|12)
	// Balances are packed 4 per leaf
	leafIndex := validatorIndex / 4
	return (BalanceContainerGIndex << BalanceTreeHeight) | leafIndex
}

// Helper functions

func hashPair(left, right [32]byte) [32]byte {
	combined := make([]byte, 64)
	copy(combined[:32], left[:])
	copy(combined[32:], right[:])
	return sha256.Sum256(combined)
}

func ceilLog2(n int) int {
	if n <= 1 {
		return 0
	}
	result := 0
	n--
	for n > 0 {
		n >>= 1
		result++
	}
	return result
}

func floorLog2(n int) int {
	if n <= 0 {
		return 0
	}
	result := 0
	for n > 1 {
		n >>= 1
		result++
	}
	return result
}

// ZeroHashes returns precomputed zero hashes for each depth level
func ZeroHashes(depth int) [][32]byte {
	zeros := make([][32]byte, depth+1)
	zeros[0] = [32]byte{}

	for i := 1; i <= depth; i++ {
		zeros[i] = hashPair(zeros[i-1], zeros[i-1])
	}

	return zeros
}

// SparseMerkleTree represents a sparse merkle tree
// Used for large trees where most leaves are zero
type SparseMerkleTree struct {
	leaves     map[uint64][32]byte
	depth      int
	zeroHashes [][32]byte
}

// NewSparseMerkleTree creates a new sparse merkle tree
func NewSparseMerkleTree(depth int) *SparseMerkleTree {
	return &SparseMerkleTree{
		leaves:     make(map[uint64][32]byte),
		depth:      depth,
		zeroHashes: ZeroHashes(depth),
	}
}

// SetLeaf sets a leaf value at the given index
func (t *SparseMerkleTree) SetLeaf(index uint64, value [32]byte) {
	t.leaves[index] = value
}

// GetLeaf gets a leaf value at the given index
func (t *SparseMerkleTree) GetLeaf(index uint64) [32]byte {
	if v, ok := t.leaves[index]; ok {
		return v
	}
	return t.zeroHashes[0]
}

// Root computes the root of the sparse merkle tree
func (t *SparseMerkleTree) Root() [32]byte {
	return t.computeNode(0, t.depth)
}

func (t *SparseMerkleTree) computeNode(index uint64, depth int) [32]byte {
	if depth == 0 {
		return t.GetLeaf(index)
	}

	leftIndex := index * 2
	rightIndex := index*2 + 1

	// Check if subtree has any non-zero leaves
	leftHasLeaves := t.hasLeavesInSubtree(leftIndex, depth-1)
	rightHasLeaves := t.hasLeavesInSubtree(rightIndex, depth-1)

	var left, right [32]byte

	if leftHasLeaves {
		left = t.computeNode(leftIndex, depth-1)
	} else {
		left = t.zeroHashes[depth-1]
	}

	if rightHasLeaves {
		right = t.computeNode(rightIndex, depth-1)
	} else {
		right = t.zeroHashes[depth-1]
	}

	return hashPair(left, right)
}

func (t *SparseMerkleTree) hasLeavesInSubtree(nodeIndex uint64, depth int) bool {
	start := nodeIndex << depth
	end := (nodeIndex + 1) << depth

	for idx := range t.leaves {
		if idx >= start && idx < end {
			return true
		}
	}
	return false
}

// GenerateProof generates a proof for a leaf at the given index
func (t *SparseMerkleTree) GenerateProof(index uint64) [][32]byte {
	proof := make([][32]byte, t.depth)

	for i := 0; i < t.depth; i++ {
		siblingIndex := index ^ 1
		siblingDepth := t.depth - i - 1

		if t.hasLeavesInSubtree(siblingIndex>>(t.depth-i-1), siblingDepth) {
			proof[i] = t.computeNodeAtLevel(siblingIndex, i)
		} else {
			proof[i] = t.zeroHashes[i]
		}

		index /= 2
	}

	return proof
}

func (t *SparseMerkleTree) computeNodeAtLevel(index uint64, level int) [32]byte {
	if level == 0 {
		return t.GetLeaf(index)
	}

	leftIndex := index * 2
	rightIndex := index*2 + 1
	targetDepth := level - 1

	var left, right [32]byte

	if t.hasLeavesInSubtree(leftIndex, targetDepth) {
		left = t.computeNodeAtLevel(leftIndex, targetDepth)
	} else {
		left = t.zeroHashes[targetDepth]
	}

	if t.hasLeavesInSubtree(rightIndex, targetDepth) {
		right = t.computeNodeAtLevel(rightIndex, targetDepth)
	} else {
		right = t.zeroHashes[targetDepth]
	}

	return hashPair(left, right)
}
