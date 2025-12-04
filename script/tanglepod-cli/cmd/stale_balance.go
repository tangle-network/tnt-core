package cmd

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/spf13/cobra"
	"github.com/tangle-network/tnt-core/script/tanglepod-cli/pkg/proofs"
)

var (
	targetValidator uint64
)

var staleBalanceCmd = &cobra.Command{
	Use:   "stale-balance",
	Short: "Generate stale balance proof for slashing enforcement",
	Long: `Generate a proof that a validator has been slashed on the beacon chain.

This proof can be submitted by anyone to TanglePod.verifyStaleBalance() to force
the pod to update its beacon chain slashing factor, preventing pod owners from
avoiding slashing updates.

Example:
  tanglepod-cli stale-balance \
    --beaconNode http://localhost:5052 \
    --execNode http://localhost:8545 \
    --podAddress 0x1234... \
    --validator 123456 \
    --output stale_balance_proof.json`,
	RunE: runStaleBalance,
}

func init() {
	staleBalanceCmd.Flags().Uint64Var(&targetValidator, "validator", 0, "Validator index to prove slashing for")
}

func runStaleBalance(cmd *cobra.Command, args []string) error {
	if podAddress == "" {
		return fmt.Errorf("--podAddress is required")
	}
	if targetValidator == 0 {
		return fmt.Errorf("--validator is required")
	}

	// Get endpoints (uses defaults if not specified)
	beaconURL, execURL := GetEndpoints()

	fmt.Printf("Generating stale balance proof...\n")
	fmt.Printf("  Beacon Node:     %s\n", beaconURL)
	fmt.Printf("  Exec Node:       %s\n", execURL)
	fmt.Printf("  Pod Address:     %s\n", podAddress)
	fmt.Printf("  Validator Index: %d\n", targetValidator)

	// Create proof generator
	generator := proofs.NewProofGenerator(beaconURL, execURL)

	// Configure network
	if network != "" {
		if err := generator.SetNetwork(network); err != nil {
			return fmt.Errorf("invalid network: %w", err)
		}
		fmt.Printf("  Network:         %s\n", network)
	} else if execNode != "" {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := generator.DetectNetwork(ctx); err != nil {
			fmt.Printf("  Warning: Could not auto-detect network: %v\n", err)
		} else {
			fmt.Printf("  Network:         auto-detected\n")
		}
	}

	// Enable prover API if requested
	if useProver {
		generator.EnableProverAPI(beaconNode)
		fmt.Printf("  Mode:            prover API\n")
	} else {
		fmt.Printf("  Mode:            full state\n")
	}

	fmt.Println()
	fmt.Println("Fetching beacon chain state...")

	// Generate proof
	proof, err := generator.GenerateStaleBalanceProof(podAddress, targetValidator)
	if err != nil {
		return fmt.Errorf("failed to generate proof: %w", err)
	}

	// Show validator status
	fmt.Printf("\nValidator %d status:\n", targetValidator)
	fmt.Printf("  Slashed:         %v\n", proof.ValidatorSlashed)
	fmt.Printf("  Current Balance: %d gwei (%.4f ETH)\n", proof.CurrentBalanceGwei, float64(proof.CurrentBalanceGwei)/1e9)

	// Check if validator is actually slashed
	if !proof.ValidatorSlashed {
		fmt.Printf("\n⚠️  WARNING: Validator %d is NOT slashed on beacon chain.\n", targetValidator)
		fmt.Printf("   The verifyStaleBalance call will revert.\n")
	} else {
		fmt.Printf("\n✅ Validator %d is SLASHED. Proof can be submitted to enforce slashing factor update.\n", targetValidator)
	}

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
