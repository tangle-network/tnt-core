package cmd

import (
	"github.com/spf13/cobra"
)

var (
	beaconNode string
	execNode   string
	podAddress string
	output     string
	verbose    bool
	network    string
	useProver  bool
)

// Default public node endpoints
// Note: For full proof generation, you need a beacon node with full state SSZ access.
// The Nimbus testing endpoint provides validator state queries for mainnet.
const (
	// Mainnet public endpoints
	DefaultMainnetBeacon = "http://testing.mainnet.beacon-api.nimbus.team" // Nimbus testing (limited)
	DefaultMainnetExec   = "https://ethereum-rpc.publicnode.com"

	// Holesky testnet public endpoints (no public beacon API available)
	DefaultHoleskyExec = "https://ethereum-holesky-rpc.publicnode.com"

	// Sepolia testnet public endpoints (no public beacon API available)
	DefaultSepoliaExec = "https://ethereum-sepolia-rpc.publicnode.com"

	// beaconcha.in API for validator info (works for status command)
	BeaconchainMainnet = "https://beaconcha.in/api/v1"
	BeaconchainHolesky = "https://holesky.beaconcha.in/api/v1"
	BeaconchainSepolia = "https://sepolia.beaconcha.in/api/v1"
)

var rootCmd = &cobra.Command{
	Use:   "tanglepod-cli",
	Short: "TanglePod CLI - Generate beacon chain proofs for TanglePod",
	Long: `TanglePod CLI generates and submits beacon chain proofs for TanglePod contracts.

Similar to EigenLayer's eigenpod-proofs-generation, this tool helps you:
- Generate withdrawal credential proofs for restaking
- Generate checkpoint proofs for balance updates
- Generate stale balance proofs for slashing enforcement

Networks (use --network to select):
  mainnet  - Ethereum mainnet (default)
  holesky  - Holesky testnet
  sepolia  - Sepolia testnet

IMPORTANT: Proof generation requires a beacon node with full state API access.
Most public APIs (publicnode, dRPC free tier) don't support this.
Options:
  1. Run your own beacon node (Lighthouse, Prysm, Teku, Lodestar)
  2. Use a paid provider (QuickNode, Infura, Alchemy)
  3. Use --use-prover with a Lodestar node's prover API

The 'status' command uses beaconcha.in API and works without a beacon node.

Example:
  tanglepod-cli status --network holesky --validators 1,2,3
  tanglepod-cli credentials --beaconNode http://localhost:5052 --podAddress 0x... --validators 123456
  tanglepod-cli checkpoint --beaconNode http://localhost:5052 --podAddress 0x... --validators 123456,789012`,
}

func Execute() error {
	return rootCmd.Execute()
}

// GetEndpoints returns beacon and execution endpoints based on network or explicit flags
func GetEndpoints() (beaconURL, execURL string) {
	// If explicit flags provided, use them
	if beaconNode != "" {
		beaconURL = beaconNode
	}
	if execNode != "" {
		execURL = execNode
	}

	// Set defaults based on network
	switch network {
	case "holesky":
		if execURL == "" {
			execURL = DefaultHoleskyExec
		}
		// No public beacon API for Holesky - user must provide
	case "sepolia":
		if execURL == "" {
			execURL = DefaultSepoliaExec
		}
		// No public beacon API for Sepolia - user must provide
	default: // mainnet or empty
		if beaconURL == "" {
			beaconURL = DefaultMainnetBeacon // Nimbus testing endpoint
		}
		if execURL == "" {
			execURL = DefaultMainnetExec
		}
	}

	return beaconURL, execURL
}

// GetBeaconchainAPI returns the beaconcha.in API URL for the selected network
func GetBeaconchainAPI() string {
	switch network {
	case "holesky":
		return BeaconchainHolesky
	case "sepolia":
		return BeaconchainSepolia
	default:
		return BeaconchainMainnet
	}
}

// GetNetwork returns the selected network name
func GetNetwork() string {
	if network == "" {
		return "mainnet"
	}
	return network
}

func init() {
	// Global flags
	rootCmd.PersistentFlags().StringVar(&beaconNode, "beaconNode", "", "Beacon node HTTP URL (e.g., http://localhost:5052)")
	rootCmd.PersistentFlags().StringVar(&execNode, "execNode", "", "Execution node HTTP URL (e.g., http://localhost:8545)")
	rootCmd.PersistentFlags().StringVar(&podAddress, "podAddress", "", "TanglePod contract address")
	rootCmd.PersistentFlags().StringVarP(&output, "output", "o", "", "Output file for proofs (JSON)")
	rootCmd.PersistentFlags().BoolVarP(&verbose, "verbose", "v", false, "Verbose output")
	rootCmd.PersistentFlags().StringVar(&network, "network", "", "Network name (mainnet, holesky, sepolia) - auto-detected if execNode provided")
	rootCmd.PersistentFlags().BoolVar(&useProver, "use-prover", false, "Use Lodestar prover API for proof generation (more efficient)")

	// Add subcommands
	rootCmd.AddCommand(credentialsCmd)
	rootCmd.AddCommand(checkpointCmd)
	rootCmd.AddCommand(statusCmd)
	rootCmd.AddCommand(staleBalanceCmd)
}
