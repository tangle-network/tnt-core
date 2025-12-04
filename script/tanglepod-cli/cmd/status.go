package cmd

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"

	"github.com/spf13/cobra"
	"github.com/tangle-network/tnt-core/script/tanglepod-cli/pkg/proofs"
)

var statusValidatorsStr string

var statusCmd = &cobra.Command{
	Use:   "status",
	Short: "Check validator or TanglePod status",
	Long: `Check the status of validators or a TanglePod.

When --validators is provided (without --podAddress), uses beaconcha.in API
to fetch validator info. This works without a beacon node.

When --podAddress is provided with --beaconNode, fetches full pod status
including restaking info from the beacon chain.

Example:
  # Check validator status (uses beaconcha.in, no beacon node needed)
  tanglepod-cli status --network holesky --validators 1,2,3

  # Check full pod status (requires beacon node)
  tanglepod-cli status --beaconNode http://localhost:5052 --podAddress 0x1234...`,
	RunE: runStatus,
}

func init() {
	statusCmd.Flags().StringVar(&statusValidatorsStr, "validators", "", "Validator indices to check (comma-separated)")
}

// BeaconchainValidator represents validator data from beaconcha.in API
type BeaconchainValidator struct {
	ValidatorIndex        uint64 `json:"validatorindex"`
	Pubkey                string `json:"pubkey"`
	WithdrawalCredentials string `json:"withdrawalcredentials"`
	EffectiveBalance      uint64 `json:"effectivebalance"`
	Balance               uint64 `json:"balance"`
	Status                string `json:"status"`
	Slashed               bool   `json:"slashed"`
	ActivationEpoch       uint64 `json:"activationepoch"`
	ExitEpoch             uint64 `json:"exitepoch"`
}

func runStatus(cmd *cobra.Command, args []string) error {
	// Parse validators if provided
	var validatorIndices []uint64
	if statusValidatorsStr != "" {
		for _, part := range strings.Split(statusValidatorsStr, ",") {
			part = strings.TrimSpace(part)
			if part == "" {
				continue
			}
			idx, err := strconv.ParseUint(part, 10, 64)
			if err != nil {
				return fmt.Errorf("invalid validator index %q: %w", part, err)
			}
			validatorIndices = append(validatorIndices, idx)
		}
	}

	// If only validators specified (no podAddress), use beaconcha.in
	if len(validatorIndices) > 0 && podAddress == "" {
		return runValidatorStatus(validatorIndices)
	}

	// If podAddress specified, use beacon node API for full pod status
	if podAddress != "" {
		return runPodStatus()
	}

	return fmt.Errorf("either --validators or --podAddress is required")
}

func runValidatorStatus(indices []uint64) error {
	apiURL := GetBeaconchainAPI()
	networkName := GetNetwork()

	fmt.Printf("Fetching validator status from beaconcha.in...\n")
	fmt.Printf("  Network: %s\n", networkName)
	fmt.Printf("  API URL: %s\n\n", apiURL)

	// Fetch each validator
	fmt.Printf("=== Validators ===\n\n")

	for _, idx := range indices {
		url := fmt.Sprintf("%s/validator/%d", apiURL, idx)
		resp, err := http.Get(url)
		if err != nil {
			fmt.Printf("Validator %d: ERROR - %v\n", idx, err)
			continue
		}
		defer resp.Body.Close()

		body, _ := io.ReadAll(resp.Body)

		var result struct {
			Status string               `json:"status"`
			Data   BeaconchainValidator `json:"data"`
		}

		if err := json.Unmarshal(body, &result); err != nil {
			fmt.Printf("Validator %d: ERROR parsing response - %v\n", idx, err)
			continue
		}

		if result.Status != "OK" {
			fmt.Printf("Validator %d: NOT FOUND\n", idx)
			continue
		}

		v := result.Data
		balanceETH := float64(v.Balance) / 1e9
		effectiveETH := float64(v.EffectiveBalance) / 1e9

		fmt.Printf("Validator %d:\n", v.ValidatorIndex)
		fmt.Printf("  Status:       %s\n", v.Status)
		fmt.Printf("  Balance:      %.6f ETH\n", balanceETH)
		fmt.Printf("  Effective:    %.6f ETH\n", effectiveETH)
		fmt.Printf("  Slashed:      %v\n", v.Slashed)
		fmt.Printf("  Pubkey:       %s...\n", v.Pubkey[:20])
		fmt.Printf("  Withdrawal:   %s\n", v.WithdrawalCredentials)
		fmt.Println()
	}

	return nil
}

func runPodStatus() error {
	beaconURL, execURL := GetEndpoints()

	if beaconURL == "" {
		return fmt.Errorf("--beaconNode is required for pod status")
	}

	fmt.Printf("Fetching TanglePod status...\n")
	fmt.Printf("  Beacon Node: %s\n", beaconURL)
	fmt.Printf("  Exec Node:   %s\n", execURL)
	fmt.Printf("  Pod Address: %s\n\n", podAddress)

	// Get status
	generator := proofs.NewProofGenerator(beaconURL, execURL)
	status, err := generator.GetPodStatus(podAddress)
	if err != nil {
		return fmt.Errorf("failed to get status: %w", err)
	}

	// Print status
	fmt.Printf("=== TanglePod Status ===\n\n")
	fmt.Printf("Pod Owner:              %s\n", status.PodOwner)
	fmt.Printf("Withdrawal Credentials: %s\n", status.WithdrawalCredentials)
	fmt.Printf("Has Restaked:           %v\n", status.HasRestaked)
	fmt.Printf("Active Validators:      %d\n", status.ActiveValidatorCount)
	fmt.Printf("Total Restaked (ETH):   %.4f\n", float64(status.TotalRestakedGwei)/1e9)
	fmt.Printf("Slashing Factor:        %.6f%%\n", float64(status.SlashingFactor)/1e16)
	fmt.Printf("Checkpoint Active:      %v\n", status.CheckpointActive)

	if status.CheckpointActive {
		fmt.Printf("\n=== Active Checkpoint ===\n")
		fmt.Printf("Timestamp:        %d\n", status.CheckpointTimestamp)
		fmt.Printf("Proofs Remaining: %d\n", status.ProofsRemaining)
	}

	if len(status.Validators) > 0 {
		fmt.Printf("\n=== Validators ===\n")
		for _, v := range status.Validators {
			statusStr := "INACTIVE"
			if v.Status == 1 {
				statusStr = "ACTIVE"
			} else if v.Status == 2 {
				statusStr = "WITHDRAWN"
			}
			fmt.Printf("  Index %d: %s, Balance: %.4f ETH\n",
				v.Index, statusStr, float64(v.BalanceGwei)/1e9)
		}
	}

	return nil
}
