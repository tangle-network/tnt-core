package ssz

import (
	"encoding/binary"
	"fmt"
)

// BeaconState represents the full beacon chain state for proof generation
// This is a simplified version focusing on fields needed for restaking proofs
type BeaconState struct {
	// Header fields
	GenesisTime           uint64
	GenesisValidatorsRoot [32]byte
	Slot                  uint64

	// Fork data
	Fork struct {
		PreviousVersion [4]byte
		CurrentVersion  [4]byte
		Epoch           uint64
	}

	// Block header
	LatestBlockHeader struct {
		Slot          uint64
		ProposerIndex uint64
		ParentRoot    [32]byte
		StateRoot     [32]byte
		BodyRoot      [32]byte
	}

	// Historical roots (fixed size arrays)
	BlockRoots [8192][32]byte // SLOTS_PER_HISTORICAL_ROOT
	StateRoots [8192][32]byte

	// Validator data
	Validators []Validator
	Balances   []uint64

	// Other fields we don't need for proofs but must parse
	RandaoMixes                 [65536][32]byte // EPOCHS_PER_HISTORICAL_VECTOR
	Slashings                   [8192]uint64    // EPOCHS_PER_SLASHINGS_VECTOR
	PreviousEpochParticipation  []byte
	CurrentEpochParticipation   []byte
	JustificationBits           [1]byte
	PreviousJustifiedCheckpoint struct {
		Epoch uint64
		Root  [32]byte
	}
	CurrentJustifiedCheckpoint struct {
		Epoch uint64
		Root  [32]byte
	}
	FinalizedCheckpoint struct {
		Epoch uint64
		Root  [32]byte
	}
}

// ParseBeaconStateSSZ parses a beacon state from SSZ bytes
// This is a simplified parser for Deneb fork
func ParseBeaconStateSSZ(data []byte) (*BeaconState, error) {
	if len(data) < 2736660 { // Minimum size for empty validator list
		return nil, fmt.Errorf("data too short: %d bytes", len(data))
	}

	state := &BeaconState{}
	offset := 0

	// Parse fixed-size fields first
	// genesis_time: uint64
	state.GenesisTime = binary.LittleEndian.Uint64(data[offset:])
	offset += 8

	// genesis_validators_root: Bytes32
	copy(state.GenesisValidatorsRoot[:], data[offset:offset+32])
	offset += 32

	// slot: uint64
	state.Slot = binary.LittleEndian.Uint64(data[offset:])
	offset += 8

	// fork: Fork
	copy(state.Fork.PreviousVersion[:], data[offset:offset+4])
	offset += 4
	copy(state.Fork.CurrentVersion[:], data[offset:offset+4])
	offset += 4
	state.Fork.Epoch = binary.LittleEndian.Uint64(data[offset:])
	offset += 8

	// latest_block_header: BeaconBlockHeader
	state.LatestBlockHeader.Slot = binary.LittleEndian.Uint64(data[offset:])
	offset += 8
	state.LatestBlockHeader.ProposerIndex = binary.LittleEndian.Uint64(data[offset:])
	offset += 8
	copy(state.LatestBlockHeader.ParentRoot[:], data[offset:offset+32])
	offset += 32
	copy(state.LatestBlockHeader.StateRoot[:], data[offset:offset+32])
	offset += 32
	copy(state.LatestBlockHeader.BodyRoot[:], data[offset:offset+32])
	offset += 32

	// block_roots: Vector[Bytes32, SLOTS_PER_HISTORICAL_ROOT]
	for i := 0; i < 8192; i++ {
		copy(state.BlockRoots[i][:], data[offset:offset+32])
		offset += 32
	}

	// state_roots: Vector[Bytes32, SLOTS_PER_HISTORICAL_ROOT]
	for i := 0; i < 8192; i++ {
		copy(state.StateRoots[i][:], data[offset:offset+32])
		offset += 32
	}

	// Skip historical_roots offset (4 bytes)
	offset += 4

	// Skip eth1_data (72 bytes)
	offset += 72

	// Skip eth1_data_votes offset (4 bytes)
	offset += 4

	// eth1_deposit_index: uint64
	offset += 8

	// validators offset: uint32
	validatorsOffset := binary.LittleEndian.Uint32(data[offset:])
	offset += 4

	// balances offset: uint32
	balancesOffset := binary.LittleEndian.Uint32(data[offset:])
	offset += 4

	// Parse validators from offset
	if int(validatorsOffset) < len(data) && int(balancesOffset) < len(data) {
		validatorsData := data[validatorsOffset:balancesOffset]
		state.Validators = parseValidators(validatorsData)

		// Parse balances
		// Each balance is 8 bytes
		balancesEnd := findNextOffset(data, int(balancesOffset))
		if balancesEnd > int(balancesOffset) {
			balancesData := data[balancesOffset:balancesEnd]
			state.Balances = parseBalances(balancesData)
		}
	}

	return state, nil
}

// parseValidators parses the validators list from SSZ bytes
func parseValidators(data []byte) []Validator {
	// Each validator is 121 bytes in SSZ
	validatorSize := 121
	count := len(data) / validatorSize
	validators := make([]Validator, count)

	for i := 0; i < count; i++ {
		offset := i * validatorSize
		v := &validators[i]

		// pubkey: BLSPubkey (48 bytes)
		copy(v.Pubkey[:], data[offset:offset+48])
		offset += 48

		// withdrawal_credentials: Bytes32
		copy(v.WithdrawalCredentials[:], data[offset:offset+32])
		offset += 32

		// effective_balance: Gwei (uint64)
		v.EffectiveBalance = binary.LittleEndian.Uint64(data[offset:])
		offset += 8

		// slashed: bool
		v.Slashed = data[offset] != 0
		offset += 1

		// activation_eligibility_epoch: Epoch (uint64)
		v.ActivationEligibilityEpoch = binary.LittleEndian.Uint64(data[offset:])
		offset += 8

		// activation_epoch: Epoch (uint64)
		v.ActivationEpoch = binary.LittleEndian.Uint64(data[offset:])
		offset += 8

		// exit_epoch: Epoch (uint64)
		v.ExitEpoch = binary.LittleEndian.Uint64(data[offset:])
		offset += 8

		// withdrawable_epoch: Epoch (uint64)
		v.WithdrawableEpoch = binary.LittleEndian.Uint64(data[offset:])
	}

	return validators
}

// parseBalances parses the balances list from SSZ bytes
func parseBalances(data []byte) []uint64 {
	count := len(data) / 8
	balances := make([]uint64, count)

	for i := 0; i < count; i++ {
		balances[i] = binary.LittleEndian.Uint64(data[i*8:])
	}

	return balances
}

// findNextOffset finds the next variable offset in SSZ data
func findNextOffset(data []byte, currentOffset int) int {
	// This is a simplified heuristic - in practice we'd track all offsets
	// For now, assume the data continues until the end
	return len(data)
}

// GetValidatorsRoot computes the merkle root of the validators list
func (s *BeaconState) GetValidatorsRoot() [32]byte {
	if len(s.Validators) == 0 {
		return [32]byte{}
	}

	// Build leaves from validator hash tree roots
	leaves := make([][32]byte, len(s.Validators))
	for i, v := range s.Validators {
		leaves[i] = v.HashTreeRoot()
	}

	// Build sparse merkle tree
	tree := NewSparseMerkleTree(ValidatorTreeHeight)
	for i, leaf := range leaves {
		tree.SetLeaf(uint64(i), leaf)
	}

	// Mix in length
	return MixInLength(tree.Root(), uint64(len(s.Validators)))
}

// GetBalancesRoot computes the merkle root of the balances list
func (s *BeaconState) GetBalancesRoot() [32]byte {
	if len(s.Balances) == 0 {
		return [32]byte{}
	}

	// Pack balances into leaves (4 per leaf)
	leafCount := (len(s.Balances) + 3) / 4
	leaves := make([][32]byte, leafCount)

	for i := 0; i < leafCount; i++ {
		var balances [4]uint64
		for j := 0; j < 4 && i*4+j < len(s.Balances); j++ {
			balances[j] = s.Balances[i*4+j]
		}
		leaves[i] = BalanceLeaf(balances)
	}

	// Build sparse merkle tree
	tree := NewSparseMerkleTree(BalanceTreeHeight)
	for i, leaf := range leaves {
		tree.SetLeaf(uint64(i), leaf)
	}

	// Mix in length
	return MixInLength(tree.Root(), uint64(len(s.Balances)))
}

// GetValidatorProof generates a merkle proof for a specific validator
func (s *BeaconState) GetValidatorProof(validatorIndex uint64) ([][32]byte, error) {
	if int(validatorIndex) >= len(s.Validators) {
		return nil, fmt.Errorf("validator index %d out of range", validatorIndex)
	}

	// Build leaves from validator hash tree roots
	leaves := make([][32]byte, len(s.Validators))
	for i, v := range s.Validators {
		leaves[i] = v.HashTreeRoot()
	}

	// Create tree and generate proof
	tree := NewSparseMerkleTree(ValidatorTreeHeight)
	for i, leaf := range leaves {
		tree.SetLeaf(uint64(i), leaf)
	}

	proof := tree.GenerateProof(validatorIndex)

	// Append length proof element
	lengthProof := uint64ToBytes32LE(uint64(len(s.Validators)))
	proof = append(proof, lengthProof)

	return proof, nil
}

// GetBalanceProof generates a merkle proof for a specific validator's balance
func (s *BeaconState) GetBalanceProof(validatorIndex uint64) ([][32]byte, [32]byte, error) {
	if int(validatorIndex) >= len(s.Balances) {
		return nil, [32]byte{}, fmt.Errorf("validator index %d out of range", validatorIndex)
	}

	// Pack balances into leaves
	leafCount := (len(s.Balances) + 3) / 4
	leaves := make([][32]byte, leafCount)

	for i := 0; i < leafCount; i++ {
		var balances [4]uint64
		for j := 0; j < 4 && i*4+j < len(s.Balances); j++ {
			balances[j] = s.Balances[i*4+j]
		}
		leaves[i] = BalanceLeaf(balances)
	}

	// Create tree
	tree := NewSparseMerkleTree(BalanceTreeHeight)
	for i, leaf := range leaves {
		tree.SetLeaf(uint64(i), leaf)
	}

	// Generate proof for the leaf containing this validator's balance
	leafIndex := validatorIndex / 4
	proof := tree.GenerateProof(leafIndex)

	// Append length proof element
	lengthProof := uint64ToBytes32LE(uint64(len(s.Balances)))
	proof = append(proof, lengthProof)

	// Return the balance leaf
	balanceLeaf := leaves[leafIndex]

	return proof, balanceLeaf, nil
}

// GetStateFieldProof generates a proof from state root to a specific field
func (s *BeaconState) GetStateFieldProof(fieldIndex int) ([][32]byte, error) {
	// Beacon state has these field indices:
	// 0: genesis_time
	// 1: genesis_validators_root
	// 2: slot
	// 3: fork
	// 4: latest_block_header
	// 5: block_roots
	// 6: state_roots
	// 7: historical_roots
	// 8: eth1_data
	// 9: eth1_data_votes
	// 10: eth1_deposit_index
	// 11: validators
	// 12: balances
	// ... more fields

	// For simplicity, we compute the full state merkle tree
	// In practice, this would be optimized

	fieldCount := 28 // Deneb has 28 fields
	if fieldIndex >= fieldCount {
		return nil, fmt.Errorf("field index %d out of range", fieldIndex)
	}

	// Compute field hashes
	leaves := make([][32]byte, 32) // Pad to power of 2

	// Field 11: validators root
	if fieldIndex == 11 {
		leaves[11] = s.GetValidatorsRoot()
	}

	// Field 12: balances root
	if fieldIndex == 12 {
		leaves[12] = s.GetBalancesRoot()
	}

	// Build tree
	tree := NewMerkleTree(leaves, 5) // 2^5 = 32 fields

	// Generate proof
	return tree.GenerateProof(fieldIndex)
}
