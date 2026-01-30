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
	validatorIndicesStr string
)

var credentialsCmd = &cobra.Command{
	Use:   "credentials",
	Short: "Generate withdrawal credential proofs",
	Long: `Generate proofs to verify validator withdrawal credentials point to a TanglePod.

This command fetches beacon chain state and generates Merkle proofs that can be
submitted to TanglePod.verifyWithdrawalCredentials() to restake validators.

Example:
  tanglepod-cli credentials \
    --beaconNode http://localhost:5052 \
    --execNode http://localhost:8545 \
    --podAddress 0x1234... \
    --validators 123456,789012 \
    --output proof.json`,
	RunE: runCredentials,
}

func init() {
	credentialsCmd.Flags().StringVar(&validatorIndicesStr, "validators", "", "Validator indices to prove (comma-separated)")
}

// parseValidatorIndices parses a comma-separated string of validator indices
func parseValidatorIndices(s string) ([]uint64, error) {
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

func runCredentials(cmd *cobra.Command, args []string) error {
	if podAddress == "" {
		return fmt.Errorf("--podAddress is required")
	}
	validatorIndices, err := parseValidatorIndices(validatorIndicesStr)
	if err != nil {
		return fmt.Errorf("invalid --validators: %w", err)
	}
	if len(validatorIndices) == 0 {
		return fmt.Errorf("--validators is required")
	}

	// Get endpoints (uses defaults if not specified)
	beaconURL, execURL := GetEndpoints()

	fmt.Printf("Generating withdrawal credential proofs...\n")
	fmt.Printf("  Beacon Node: %s\n", beaconURL)
	fmt.Printf("  Exec Node:   %s\n", execURL)
	fmt.Printf("  Pod Address: %s\n", podAddress)
	fmt.Printf("  Validators:  %v\n", validatorIndices)

	// Create proof generator
	generator := proofs.NewProofGenerator(beaconURL, execURL)

	// Configure network
	if network != "" {
		if err := generator.SetNetwork(network); err != nil {
			return fmt.Errorf("invalid network: %w", err)
		}
		fmt.Printf("  Network:     %s\n", network)
	} else if execNode != "" {
		// Auto-detect network from execution client
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := generator.DetectNetwork(ctx); err != nil {
			fmt.Printf("  Warning: Could not auto-detect network: %v\n", err)
			fmt.Printf("  Using default: mainnet\n")
		} else {
			fmt.Printf("  Network:     auto-detected\n")
		}
	}

	// Enable prover API if requested
	if useProver {
		generator.EnableProverAPI(beaconNode) // Lodestar uses same endpoint
		fmt.Printf("  Mode:        prover API\n")
	} else {
		fmt.Printf("  Mode:        full state\n")
	}

	fmt.Println()
	fmt.Println("Fetching beacon chain state...")

	// Generate proofs
	proof, err := generator.GenerateCredentialProof(podAddress, validatorIndices)
	if err != nil {
		return fmt.Errorf("failed to generate proof: %w", err)
	}

	fmt.Printf("Generated proofs for %d validators\n", len(proof.ValidatorProofs))
	fmt.Printf("Beacon timestamp: %d\n", proof.BeaconTimestamp)
	fmt.Printf("Beacon block root: %s\n", proof.BeaconBlockRoot)

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
