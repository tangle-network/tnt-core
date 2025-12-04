package cmd

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/spf13/cobra"
	"github.com/tangle-network/tnt-core/script/tanglepod-cli/pkg/proofs"
)

var (
	checkpointValidatorsStr string
)

var checkpointCmd = &cobra.Command{
	Use:   "checkpoint",
	Short: "Generate checkpoint proofs",
	Long: `Generate proofs for a TanglePod checkpoint.

Checkpoints sync validator balances from the beacon chain to the TanglePod.
This command generates balance proofs for specified validators.

Example:
  tanglepod-cli checkpoint \
    --beaconNode http://localhost:5052 \
    --execNode http://localhost:8545 \
    --podAddress 0x1234... \
    --validators 123456,789012 \
    --output checkpoint_proof.json`,
	RunE: runCheckpoint,
}

func init() {
	checkpointCmd.Flags().StringVar(&checkpointValidatorsStr, "validators", "", "Validator indices to include in checkpoint (comma-separated)")
}

// parseCheckpointValidators parses a comma-separated string of validator indices
func parseCheckpointValidators(s string) ([]uint64, error) {
	if s == "" {
		return nil, nil
	}
	parts := strings.Split(s, ",")
	indices := make([]uint64, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p == "" {
			continue
		}
		idx, err := strconv.ParseUint(p, 10, 64)
		if err != nil {
			return nil, fmt.Errorf("invalid validator index %q: %w", p, err)
		}
		indices = append(indices, idx)
	}
	return indices, nil
}

func runCheckpoint(cmd *cobra.Command, args []string) error {
	if podAddress == "" {
		return fmt.Errorf("--podAddress is required")
	}
	checkpointValidators, err := parseCheckpointValidators(checkpointValidatorsStr)
	if err != nil {
		return fmt.Errorf("invalid --validators: %w", err)
	}
	if len(checkpointValidators) == 0 {
		return fmt.Errorf("--validators is required")
	}

	// Get endpoints (uses defaults if not specified)
	beaconURL, execURL := GetEndpoints()

	fmt.Printf("Generating checkpoint proofs...\n")
	fmt.Printf("  Beacon Node: %s\n", beaconURL)
	fmt.Printf("  Exec Node:   %s\n", execURL)
	fmt.Printf("  Pod Address: %s\n", podAddress)
	fmt.Printf("  Validators:  %v\n", checkpointValidators)

	// Create proof generator
	generator := proofs.NewProofGenerator(beaconURL, execURL)

	// Configure network
	if network != "" {
		if err := generator.SetNetwork(network); err != nil {
			return fmt.Errorf("invalid network: %w", err)
		}
		fmt.Printf("  Network:     %s\n", network)
	} else if execNode != "" {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := generator.DetectNetwork(ctx); err != nil {
			fmt.Printf("  Warning: Could not auto-detect network: %v\n", err)
		} else {
			fmt.Printf("  Network:     auto-detected\n")
		}
	}

	fmt.Println()
	fmt.Println("Fetching beacon chain state (this may take a while for large state)...")

	// Generate proofs
	proof, err := generator.GenerateCheckpointProof(podAddress, checkpointValidators)
	if err != nil {
		return fmt.Errorf("failed to generate proof: %w", err)
	}

	fmt.Printf("Generated checkpoint proofs for %d validators\n", len(proof.BalanceProofs))
	fmt.Printf("Beacon timestamp: %d\n", proof.BeaconTimestamp)
	fmt.Printf("Beacon block root: %s\n", proof.BeaconBlockRoot)
	fmt.Printf("Balance container root: %s\n", proof.BalanceContainerProof.BalanceContainerRoot)

	// Output
	proofJSON, err := json.MarshalIndent(proof, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal proof: %w", err)
	}

	if output != "" {
		if err := os.WriteFile(output, proofJSON, 0644); err != nil {
			return fmt.Errorf("failed to write output: %w", err)
		}
		fmt.Printf("\nProof written to %s\n", output)
	} else {
		fmt.Println("\n--- Proof JSON ---")
		fmt.Println(string(proofJSON))
	}

	return nil
}
