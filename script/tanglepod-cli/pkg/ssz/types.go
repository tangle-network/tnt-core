package ssz

import (
	"crypto/sha256"
	"encoding/binary"
)

// Constants for beacon chain SSZ structures
const (
	// Validator container has 8 fields
	ValidatorFieldCount = 8

	// Balance is packed 4 per leaf (4 * 8 bytes = 32 bytes)
	BalancesPerLeaf = 4

	// Beacon state field indices (generalized indices)
	StateGenesisTimeIndex           = 0
	StateGenesisValidatorsRootIndex = 1
	StateSlotIndex                  = 2
	StateForkIndex                  = 3
	StateLatestBlockHeaderIndex     = 4
	StateBlockRootsIndex            = 5
	StateStateRootsIndex            = 6
	StateHistoricalRootsIndex       = 7
	StateEth1DataIndex              = 8
	StateEth1DataVotesIndex         = 9
	StateEth1DepositIndexIndex      = 10
	StateValidatorsIndex            = 11
	StateBalancesIndex              = 12
	// ... more fields follow

	// Beacon block body field indices
	BlockBodyRandaoIndex          = 0
	BlockBodyEth1DataIndex        = 1
	BlockBodyGraffitiIndex        = 2
	BlockBodyProposerSlashings    = 3
	BlockBodyAttesterSlashings    = 4
	BlockBodyAttestations         = 5
	BlockBodyDeposits             = 6
	BlockBodyVoluntaryExits       = 7
	BlockBodySyncAggregate        = 8
	BlockBodyExecutionPayload     = 9
	BlockBodyBlsToExecutionChange = 10
	BlockBodyBlobKzgCommitments   = 11

	// Tree heights
	ValidatorTreeHeight = 40 // 2^40 max validators
	BalanceTreeHeight   = 38 // 2^40 / 4 balances per leaf

	// Generalized indices for beacon block
	StateRootGIndexInBlock = 3 // state_root is field 3 in BeaconBlockHeader

	// Generalized indices for beacon state
	ValidatorContainerGIndex = 43 // (1 << 5) | 11
	BalanceContainerGIndex   = 44 // (1 << 5) | 12
)

// Validator represents a beacon chain validator in SSZ format
type Validator struct {
	Pubkey                     [48]byte
	WithdrawalCredentials      [32]byte
	EffectiveBalance           uint64
	Slashed                    bool
	ActivationEligibilityEpoch uint64
	ActivationEpoch            uint64
	ExitEpoch                  uint64
	WithdrawableEpoch          uint64
}

// HashTreeRoot computes the hash tree root of a validator
func (v *Validator) HashTreeRoot() [32]byte {
	// Validator container has 8 fields
	leaves := make([][32]byte, 8)

	// Field 0: pubkey (48 bytes, padded to 64)
	pubkeyFirst := sha256Hash(v.Pubkey[:32])
	pubkeySecond := make([]byte, 32)
	copy(pubkeySecond, v.Pubkey[32:])
	pubkeySecondHash := sha256Hash(pubkeySecond)
	leaves[0] = sha256Hash(append(pubkeyFirst[:], pubkeySecondHash[:]...))

	// Field 1: withdrawal_credentials
	leaves[1] = v.WithdrawalCredentials

	// Field 2: effective_balance
	leaves[2] = uint64ToBytes32(v.EffectiveBalance)

	// Field 3: slashed
	leaves[3] = boolToBytes32(v.Slashed)

	// Field 4: activation_eligibility_epoch
	leaves[4] = uint64ToBytes32(v.ActivationEligibilityEpoch)

	// Field 5: activation_epoch
	leaves[5] = uint64ToBytes32(v.ActivationEpoch)

	// Field 6: exit_epoch
	leaves[6] = uint64ToBytes32(v.ExitEpoch)

	// Field 7: withdrawable_epoch
	leaves[7] = uint64ToBytes32(v.WithdrawableEpoch)

	return merkleize(leaves)
}

// GetFields returns the 8 validator fields as bytes32 array
func (v *Validator) GetFields() [][32]byte {
	fields := make([][32]byte, 8)

	// Field 0: pubkey hash
	pubkeyHash := sha256.Sum256(v.Pubkey[:])
	fields[0] = pubkeyHash

	// Field 1: withdrawal_credentials
	fields[1] = v.WithdrawalCredentials

	// Field 2: effective_balance (little-endian)
	fields[2] = uint64ToBytes32LE(v.EffectiveBalance)

	// Field 3: slashed
	fields[3] = boolToBytes32(v.Slashed)

	// Field 4: activation_eligibility_epoch
	fields[4] = uint64ToBytes32LE(v.ActivationEligibilityEpoch)

	// Field 5: activation_epoch
	fields[5] = uint64ToBytes32LE(v.ActivationEpoch)

	// Field 6: exit_epoch
	fields[6] = uint64ToBytes32LE(v.ExitEpoch)

	// Field 7: withdrawable_epoch
	fields[7] = uint64ToBytes32LE(v.WithdrawableEpoch)

	return fields
}

// BalanceLeaf packs 4 balances into a single 32-byte leaf
func BalanceLeaf(balances [4]uint64) [32]byte {
	var leaf [32]byte
	for i, b := range balances {
		binary.LittleEndian.PutUint64(leaf[i*8:], b)
	}
	return leaf
}

// ExtractBalance extracts a balance from a balance leaf
func ExtractBalance(leaf [32]byte, indexInLeaf int) uint64 {
	return binary.LittleEndian.Uint64(leaf[indexInLeaf*8:])
}

// HashTreeRoot computes the SHA256 hash tree root of arbitrary data
func HashTreeRoot(data []byte) [32]byte {
	return sha256.Sum256(data)
}

// Helper functions

func sha256Hash(data []byte) [32]byte {
	return sha256.Sum256(data)
}

func uint64ToBytes32(v uint64) [32]byte {
	var result [32]byte
	binary.BigEndian.PutUint64(result[24:], v)
	return result
}

func uint64ToBytes32LE(v uint64) [32]byte {
	var result [32]byte
	binary.LittleEndian.PutUint64(result[:8], v)
	return result
}

func boolToBytes32(v bool) [32]byte {
	var result [32]byte
	if v {
		result[0] = 1
	}
	return result
}

// merkleize computes the merkle root of a list of leaves
func merkleize(leaves [][32]byte) [32]byte {
	if len(leaves) == 0 {
		return [32]byte{}
	}

	// Pad to power of 2
	n := nextPowerOfTwo(len(leaves))
	padded := make([][32]byte, n)
	copy(padded, leaves)

	// Build tree bottom-up
	for n > 1 {
		for i := 0; i < n/2; i++ {
			padded[i] = sha256Hash(append(padded[i*2][:], padded[i*2+1][:]...))
		}
		n /= 2
	}

	return padded[0]
}

func nextPowerOfTwo(n int) int {
	if n <= 1 {
		return 1
	}
	n--
	n |= n >> 1
	n |= n >> 2
	n |= n >> 4
	n |= n >> 8
	n |= n >> 16
	return n + 1
}
