package proofs

// CredentialProof contains data for verifyWithdrawalCredentials
type CredentialProof struct {
	BeaconTimestamp  uint64             `json:"beaconTimestamp"`
	BeaconBlockRoot  string             `json:"beaconBlockRoot"`
	StateRootProof   StateRootProofData `json:"stateRootProof"`
	ValidatorIndices []uint64           `json:"validatorIndices"`
	ValidatorProofs  []ValidatorProof   `json:"validatorProofs"`
}

// CheckpointProof contains data for verifyCheckpointProofs
type CheckpointProof struct {
	BeaconTimestamp       uint64               `json:"beaconTimestamp"`
	BeaconBlockRoot       string               `json:"beaconBlockRoot"`
	StateRootProof        StateRootProofData   `json:"stateRootProof"`
	BalanceContainerProof BalanceContainerData `json:"balanceContainerProof"`
	BalanceProofs         []BalanceProofData   `json:"balanceProofs"`
}

// StaleBalanceProof contains data for verifyStaleBalance
type StaleBalanceProof struct {
	BeaconTimestamp    uint64             `json:"beaconTimestamp"`
	BeaconBlockRoot    string             `json:"beaconBlockRoot"`
	StateRootProof     StateRootProofData `json:"stateRootProof"`
	ValidatorProof     ValidatorProof     `json:"validatorProof"`
	ValidatorSlashed   bool               `json:"validatorSlashed"`
	CurrentBalanceGwei uint64             `json:"currentBalanceGwei"`
}

// StateRootProofData matches ValidatorTypes.StateRootProof
type StateRootProofData struct {
	BeaconStateRoot string   `json:"beaconStateRoot"`
	Proof           []string `json:"proof"`
}

// ValidatorProof matches ValidatorTypes.ValidatorFieldsProof
type ValidatorProof struct {
	ValidatorIndex  uint64   `json:"validatorIndex"`
	ValidatorFields []string `json:"validatorFields"`
	Proof           []string `json:"proof"`
}

// BalanceContainerData matches ValidatorTypes.BalanceContainerProof
type BalanceContainerData struct {
	BalanceContainerRoot string   `json:"balanceContainerRoot"`
	Proof                []string `json:"proof"`
}

// BalanceProofData matches ValidatorTypes.BalanceProof
type BalanceProofData struct {
	PubkeyHash  string   `json:"pubkeyHash"`
	BalanceRoot string   `json:"balanceRoot"`
	Proof       []string `json:"proof"`
}

// PodStatus represents current TanglePod state
type PodStatus struct {
	PodAddress            string            `json:"podAddress"`
	PodOwner              string            `json:"podOwner"`
	WithdrawalCredentials string            `json:"withdrawalCredentials"`
	HasRestaked           bool              `json:"hasRestaked"`
	ActiveValidatorCount  uint64            `json:"activeValidatorCount"`
	TotalRestakedGwei     uint64            `json:"totalRestakedGwei"`
	SlashingFactor        uint64            `json:"slashingFactor"`
	CheckpointActive      bool              `json:"checkpointActive"`
	CheckpointTimestamp   uint64            `json:"checkpointTimestamp"`
	ProofsRemaining       uint32            `json:"proofsRemaining"`
	Validators            []ValidatorStatus `json:"validators"`
}

// ValidatorStatus represents a validator's state in the pod
type ValidatorStatus struct {
	Index       uint64 `json:"index"`
	PubkeyHash  string `json:"pubkeyHash"`
	BalanceGwei uint64 `json:"balanceGwei"`
	Status      uint8  `json:"status"` // 0=INACTIVE, 1=ACTIVE, 2=WITHDRAWN
}
