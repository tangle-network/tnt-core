package proofs

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/tangle-network/tnt-core/script/tanglepod-cli/pkg/beacon"
	"github.com/tangle-network/tnt-core/script/tanglepod-cli/pkg/execution"
	"github.com/tangle-network/tnt-core/script/tanglepod-cli/pkg/ssz"
)

// ProofGenerator generates beacon chain proofs for TanglePod
type ProofGenerator struct {
	beaconURL    string
	execURL      string
	beaconClient *beacon.Client
	execClient   *execution.Client
	genesisTime  uint64
	useProver    bool
	proverClient *beacon.LightClientProver
}

// NewProofGenerator creates a new proof generator
func NewProofGenerator(beaconURL, execURL string) *ProofGenerator {
	return &ProofGenerator{
		beaconURL:    beaconURL,
		execURL:      execURL,
		beaconClient: beacon.NewClient(beaconURL),
		execClient:   execution.NewClient(execURL),
		genesisTime:  1606824023, // Default to mainnet
		useProver:    false,
	}
}

// EnableProverAPI enables using the Lodestar prover API for proof generation
// This is more efficient than fetching the full state
func (g *ProofGenerator) EnableProverAPI(proverURL string) {
	g.proverClient = beacon.NewLightClientProver(proverURL)
	g.useProver = true
}

// DetectNetwork auto-detects network from execution client and sets genesis time
func (g *ProofGenerator) DetectNetwork(ctx context.Context) error {
	config, err := g.execClient.GetNetworkConfig(ctx)
	if err != nil {
		return err
	}
	g.genesisTime = config.GenesisTime
	return nil
}

// SetNetwork manually sets the network configuration
func (g *ProofGenerator) SetNetwork(network string) error {
	switch strings.ToLower(network) {
	case "mainnet":
		g.genesisTime = 1606824023
	case "holesky":
		g.genesisTime = 1695902400
	case "sepolia":
		g.genesisTime = 1655733600
	default:
		return fmt.Errorf("unknown network: %s", network)
	}
	return nil
}

// GenerateCredentialProof generates withdrawal credential proofs
func (g *ProofGenerator) GenerateCredentialProof(podAddress string, validatorIndices []uint64) (*CredentialProof, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()

	// Get the latest finalized block header
	header, err := g.beaconClient.GetBlockHeader(ctx, "finalized")
	if err != nil {
		return nil, fmt.Errorf("failed to get block header: %w", err)
	}

	// Get the block root
	blockRoot, err := g.beaconClient.GetBlockRoot(ctx, "finalized")
	if err != nil {
		return nil, fmt.Errorf("failed to get block root: %w", err)
	}

	// Calculate timestamp from slot
	timestamp := beacon.SlotToTimestamp(header.Slot, g.genesisTime)

	// Validate beacon root is in EIP-4788 oracle (if execution client available)
	if g.execURL != "" {
		valid, err := g.execClient.ValidateBeaconRoot(ctx, timestamp, blockRoot)
		if err != nil {
			// Log warning but continue - oracle might not have this timestamp yet
			fmt.Printf("Warning: Could not validate beacon root in EIP-4788 oracle: %v\n", err)
		} else if !valid {
			return nil, fmt.Errorf("beacon root does not match EIP-4788 oracle - timestamp may be too old")
		}
	}

	// Generate state root proof (block root -> state root)
	stateRootProof, err := g.generateStateRootProofFromHeader(header, blockRoot)
	if err != nil {
		return nil, fmt.Errorf("failed to generate state root proof: %w", err)
	}

	// Generate validator proofs using full state or prover API
	validatorProofs := make([]ValidatorProof, len(validatorIndices))

	if g.useProver && g.proverClient != nil {
		// Use prover API for efficient proof generation
		for i, validatorIndex := range validatorIndices {
			proof, err := g.generateValidatorProofFromProver(ctx, validatorIndex, header.StateRoot)
			if err != nil {
				return nil, fmt.Errorf("failed to generate proof for validator %d: %w", validatorIndex, err)
			}
			validatorProofs[i] = *proof
		}
	} else {
		// Fetch full state and generate proofs locally
		stateSSZ, err := g.beaconClient.GetBeaconStateSSZ(ctx, "finalized")
		if err != nil {
			return nil, fmt.Errorf("failed to fetch beacon state (ensure debug API is enabled): %w", err)
		}

		state, err := ssz.ParseBeaconStateSSZ(stateSSZ)
		if err != nil {
			return nil, fmt.Errorf("failed to parse beacon state: %w", err)
		}

		// Fetch validator data and generate proofs
		validators, err := g.beaconClient.GetValidators(ctx, "finalized", validatorIndices)
		if err != nil {
			return nil, fmt.Errorf("failed to get validators: %w", err)
		}

		for i, v := range validators {
			proof, err := g.generateValidatorProofFromState(state, v)
			if err != nil {
				return nil, fmt.Errorf("failed to generate proof for validator %d: %w", v.Index, err)
			}
			validatorProofs[i] = *proof
		}
	}

	return &CredentialProof{
		BeaconTimestamp:  timestamp,
		BeaconBlockRoot:  blockRoot,
		StateRootProof:   *stateRootProof,
		ValidatorIndices: validatorIndices,
		ValidatorProofs:  validatorProofs,
	}, nil
}

// GenerateCheckpointProof generates checkpoint balance proofs
func (g *ProofGenerator) GenerateCheckpointProof(podAddress string, validatorIndices []uint64) (*CheckpointProof, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 180*time.Second)
	defer cancel()

	// Get the latest finalized block header
	header, err := g.beaconClient.GetBlockHeader(ctx, "finalized")
	if err != nil {
		return nil, fmt.Errorf("failed to get block header: %w", err)
	}

	blockRoot, err := g.beaconClient.GetBlockRoot(ctx, "finalized")
	if err != nil {
		return nil, fmt.Errorf("failed to get block root: %w", err)
	}

	timestamp := beacon.SlotToTimestamp(header.Slot, g.genesisTime)

	// Generate state root proof
	stateRootProof, err := g.generateStateRootProofFromHeader(header, blockRoot)
	if err != nil {
		return nil, fmt.Errorf("failed to generate state root proof: %w", err)
	}

	// Fetch state for balance proofs
	stateSSZ, err := g.beaconClient.GetBeaconStateSSZ(ctx, "finalized")
	if err != nil {
		return nil, fmt.Errorf("failed to fetch beacon state: %w", err)
	}

	state, err := ssz.ParseBeaconStateSSZ(stateSSZ)
	if err != nil {
		return nil, fmt.Errorf("failed to parse beacon state: %w", err)
	}

	// Generate balance container proof (state root -> balances root)
	balanceContainerProof, err := g.generateBalanceContainerProofFromState(state)
	if err != nil {
		return nil, fmt.Errorf("failed to generate balance container proof: %w", err)
	}

	// Generate individual balance proofs
	balanceProofs := make([]BalanceProofData, len(validatorIndices))
	for i, validatorIndex := range validatorIndices {
		proof, balanceLeaf, err := state.GetBalanceProof(validatorIndex)
		if err != nil {
			return nil, fmt.Errorf("failed to generate balance proof for validator %d: %w", validatorIndex, err)
		}

		// Get pubkey hash for this validator
		if int(validatorIndex) >= len(state.Validators) {
			return nil, fmt.Errorf("validator index %d out of range", validatorIndex)
		}
		pubkeyHash := ssz.HashTreeRoot(state.Validators[validatorIndex].Pubkey[:])

		balanceProofs[i] = BalanceProofData{
			PubkeyHash:  beacon.BytesToHex(pubkeyHash[:]),
			BalanceRoot: beacon.BytesToHex(balanceLeaf[:]),
			Proof:       bytes32SliceToHex(proof),
		}
	}

	return &CheckpointProof{
		BeaconTimestamp:       timestamp,
		BeaconBlockRoot:       blockRoot,
		StateRootProof:        *stateRootProof,
		BalanceContainerProof: *balanceContainerProof,
		BalanceProofs:         balanceProofs,
	}, nil
}

// GenerateStaleBalanceProof generates a proof for verifyStaleBalance
func (g *ProofGenerator) GenerateStaleBalanceProof(podAddress string, validatorIndex uint64) (*StaleBalanceProof, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()

	// Get the latest finalized block header
	header, err := g.beaconClient.GetBlockHeader(ctx, "finalized")
	if err != nil {
		return nil, fmt.Errorf("failed to get block header: %w", err)
	}

	blockRoot, err := g.beaconClient.GetBlockRoot(ctx, "finalized")
	if err != nil {
		return nil, fmt.Errorf("failed to get block root: %w", err)
	}

	timestamp := beacon.SlotToTimestamp(header.Slot, g.genesisTime)

	// Generate state root proof
	stateRootProof, err := g.generateStateRootProofFromHeader(header, blockRoot)
	if err != nil {
		return nil, fmt.Errorf("failed to generate state root proof: %w", err)
	}

	// Get validator data
	validator, err := g.beaconClient.GetValidator(ctx, "finalized", validatorIndex)
	if err != nil {
		return nil, fmt.Errorf("failed to get validator: %w", err)
	}

	// Generate validator proof
	var validatorProof *ValidatorProof
	if g.useProver && g.proverClient != nil {
		validatorProof, err = g.generateValidatorProofFromProver(ctx, validatorIndex, header.StateRoot)
	} else {
		stateSSZ, err := g.beaconClient.GetBeaconStateSSZ(ctx, "finalized")
		if err != nil {
			return nil, fmt.Errorf("failed to fetch beacon state: %w", err)
		}
		state, err := ssz.ParseBeaconStateSSZ(stateSSZ)
		if err != nil {
			return nil, fmt.Errorf("failed to parse beacon state: %w", err)
		}
		validatorProof, err = g.generateValidatorProofFromState(state, validator)
	}

	if err != nil {
		return nil, fmt.Errorf("failed to generate validator proof: %w", err)
	}

	return &StaleBalanceProof{
		BeaconTimestamp:    timestamp,
		BeaconBlockRoot:    blockRoot,
		StateRootProof:     *stateRootProof,
		ValidatorProof:     *validatorProof,
		ValidatorSlashed:   validator.Validator.Slashed,
		CurrentBalanceGwei: validator.Balance,
	}, nil
}

// GetPodStatus fetches current pod status from beacon chain and contract
func (g *ProofGenerator) GetPodStatus(podAddress string) (*PodStatus, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Query beacon chain for validators with this withdrawal credential
	withdrawalCreds := computeWithdrawalCredentials(podAddress)
	withdrawalCreds02 := computeWithdrawalCredentials02(podAddress)

	// Get all validators and filter by withdrawal credentials
	// Note: In production, use a more efficient query
	validators, err := g.beaconClient.GetValidators(ctx, "finalized", nil)
	if err != nil {
		return nil, fmt.Errorf("failed to get validators: %w", err)
	}

	var matchingValidators []ValidatorStatus
	var totalRestakedGwei uint64

	for _, v := range validators {
		creds := strings.ToLower(v.Validator.WithdrawalCredentials)
		if creds == strings.ToLower(withdrawalCreds) || creds == strings.ToLower(withdrawalCreds02) {
			status := ValidatorStatus{
				Index:       v.Index,
				PubkeyHash:  v.Validator.Pubkey[:10] + "...",
				BalanceGwei: v.Balance,
				Status:      mapValidatorStatus(v.Status),
			}
			matchingValidators = append(matchingValidators, status)

			if v.Status == "active_ongoing" || v.Status == "active_exiting" || v.Status == "active_slashed" {
				totalRestakedGwei += v.Validator.EffectiveBalance
			}
		}
	}

	return &PodStatus{
		PodAddress:            podAddress,
		PodOwner:              "0x0000000000000000000000000000000000000000", // Would query contract
		WithdrawalCredentials: withdrawalCreds,
		HasRestaked:           len(matchingValidators) > 0,
		ActiveValidatorCount:  uint64(len(matchingValidators)),
		TotalRestakedGwei:     totalRestakedGwei,
		SlashingFactor:        1e18, // Would query contract
		CheckpointActive:      false,
		Validators:            matchingValidators,
	}, nil
}

// generateStateRootProofFromHeader generates a proof from block root to state root
func (g *ProofGenerator) generateStateRootProofFromHeader(header *beacon.BeaconBlockHeader, blockRoot string) (*StateRootProofData, error) {
	// Build merkle tree from header fields
	// BeaconBlockHeader: slot, proposer_index, parent_root, state_root, body_root
	leaves := make([][32]byte, 8) // Padded to power of 2

	leaves[0] = uint64ToBytes32LE(header.Slot)
	leaves[1] = uint64ToBytes32LE(header.ProposerIndex)
	leaves[2] = hexToBytes32(header.ParentRoot)
	leaves[3] = hexToBytes32(header.StateRoot) // This is what we're proving
	leaves[4] = hexToBytes32(header.BodyRoot)
	// leaves[5-7] are zero (padding)

	tree := ssz.NewMerkleTree(leaves, 3) // depth 3 for 8 leaves

	// Generate proof for index 3 (state_root)
	proof, err := tree.GenerateProof(3)
	if err != nil {
		return nil, fmt.Errorf("failed to generate proof: %w", err)
	}

	return &StateRootProofData{
		BeaconStateRoot: header.StateRoot,
		Proof:           bytes32SliceToHex(proof),
	}, nil
}

// generateValidatorProofFromState generates a merkle proof for a validator from parsed state
func (g *ProofGenerator) generateValidatorProofFromState(state *ssz.BeaconState, v *beacon.ValidatorData) (*ValidatorProof, error) {
	// Get validator fields from beacon API data
	validator := &ssz.Validator{
		EffectiveBalance:           v.Validator.EffectiveBalance,
		Slashed:                    v.Validator.Slashed,
		ActivationEligibilityEpoch: v.Validator.ActivationEligibilityEpoch,
		ActivationEpoch:            v.Validator.ActivationEpoch,
		ExitEpoch:                  v.Validator.ExitEpoch,
		WithdrawableEpoch:          v.Validator.WithdrawableEpoch,
	}

	// Parse pubkey
	pubkeyBytes, err := beacon.HexToBytes(v.Validator.Pubkey)
	if err != nil {
		return nil, fmt.Errorf("failed to parse pubkey: %w", err)
	}
	copy(validator.Pubkey[:], pubkeyBytes)

	// Parse withdrawal credentials
	wcBytes, err := beacon.HexToBytes(v.Validator.WithdrawalCredentials)
	if err != nil {
		return nil, fmt.Errorf("failed to parse withdrawal credentials: %w", err)
	}
	copy(validator.WithdrawalCredentials[:], wcBytes)

	// Get validator fields as bytes32
	fields := validator.GetFields()
	fieldStrings := make([]string, len(fields))
	for i, f := range fields {
		fieldStrings[i] = beacon.BytesToHex(f[:])
	}

	// Generate proof from validators tree
	proof, err := state.GetValidatorProof(v.Index)
	if err != nil {
		return nil, fmt.Errorf("failed to generate validator proof: %w", err)
	}

	// Prepend state field proof (state root -> validators container)
	stateFieldProof, err := state.GetStateFieldProof(11) // validators at index 11
	if err != nil {
		return nil, fmt.Errorf("failed to generate state field proof: %w", err)
	}

	// Combine proofs: validator tree proof + state field proof
	fullProof := append(proof, stateFieldProof...)

	return &ValidatorProof{
		ValidatorIndex:  v.Index,
		ValidatorFields: fieldStrings,
		Proof:           bytes32SliceToHex(fullProof),
	}, nil
}

// generateValidatorProofFromProver uses the Lodestar prover API
func (g *ProofGenerator) generateValidatorProofFromProver(ctx context.Context, validatorIndex uint64, stateRoot string) (*ValidatorProof, error) {
	// Get proof from prover API
	stateProof, err := g.proverClient.GetValidatorProof(ctx, "finalized", validatorIndex)
	if err != nil {
		return nil, fmt.Errorf("prover API failed: %w", err)
	}

	// Get validator data
	validator, err := g.beaconClient.GetValidator(ctx, "finalized", validatorIndex)
	if err != nil {
		return nil, fmt.Errorf("failed to get validator data: %w", err)
	}

	// Build validator fields
	v := &ssz.Validator{
		EffectiveBalance:           validator.Validator.EffectiveBalance,
		Slashed:                    validator.Validator.Slashed,
		ActivationEligibilityEpoch: validator.Validator.ActivationEligibilityEpoch,
		ActivationEpoch:            validator.Validator.ActivationEpoch,
		ExitEpoch:                  validator.Validator.ExitEpoch,
		WithdrawableEpoch:          validator.Validator.WithdrawableEpoch,
	}
	pubkeyBytes, _ := beacon.HexToBytes(validator.Validator.Pubkey)
	copy(v.Pubkey[:], pubkeyBytes)
	wcBytes, _ := beacon.HexToBytes(validator.Validator.WithdrawalCredentials)
	copy(v.WithdrawalCredentials[:], wcBytes)

	fields := v.GetFields()
	fieldStrings := make([]string, len(fields))
	for i, f := range fields {
		fieldStrings[i] = beacon.BytesToHex(f[:])
	}

	return &ValidatorProof{
		ValidatorIndex:  validatorIndex,
		ValidatorFields: fieldStrings,
		Proof:           stateProof.Proof,
	}, nil
}

// generateBalanceContainerProofFromState generates a proof for the balance container
func (g *ProofGenerator) generateBalanceContainerProofFromState(state *ssz.BeaconState) (*BalanceContainerData, error) {
	// Get balances root
	balancesRoot := state.GetBalancesRoot()

	// Get state field proof for balances (index 12)
	proof, err := state.GetStateFieldProof(12)
	if err != nil {
		return nil, fmt.Errorf("failed to generate state field proof: %w", err)
	}

	return &BalanceContainerData{
		BalanceContainerRoot: beacon.BytesToHex(balancesRoot[:]),
		Proof:                bytes32SliceToHex(proof),
	}, nil
}

// Helper functions

func computeWithdrawalCredentials(address string) string {
	addr := strings.TrimPrefix(address, "0x")
	return "0x010000000000000000000000" + strings.ToLower(addr)
}

func computeWithdrawalCredentials02(address string) string {
	addr := strings.TrimPrefix(address, "0x")
	return "0x020000000000000000000000" + strings.ToLower(addr)
}

func hexToBytes32(s string) [32]byte {
	var result [32]byte
	bytes, err := beacon.HexToBytes(s)
	if err != nil {
		return result
	}
	copy(result[:], bytes)
	return result
}

func uint64ToBytes32LE(v uint64) [32]byte {
	var result [32]byte
	result[0] = byte(v)
	result[1] = byte(v >> 8)
	result[2] = byte(v >> 16)
	result[3] = byte(v >> 24)
	result[4] = byte(v >> 32)
	result[5] = byte(v >> 40)
	result[6] = byte(v >> 48)
	result[7] = byte(v >> 56)
	return result
}

func bytes32SliceToHex(proof [][32]byte) []string {
	result := make([]string, len(proof))
	for i, p := range proof {
		result[i] = beacon.BytesToHex(p[:])
	}
	return result
}

func mapValidatorStatus(status string) uint8 {
	switch status {
	case "pending_initialized", "pending_queued":
		return 0 // INACTIVE
	case "active_ongoing", "active_exiting", "active_slashed":
		return 1 // ACTIVE
	case "exited_unslashed", "exited_slashed", "withdrawal_possible", "withdrawal_done":
		return 2 // WITHDRAWN
	default:
		return 0
	}
}
