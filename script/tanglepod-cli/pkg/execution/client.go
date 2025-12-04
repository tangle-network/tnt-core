package execution

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math/big"
	"net/http"
	"strings"
	"time"
)

// EIP-4788 Beacon Root Oracle contract address (same on all chains)
const BeaconRootOracleAddress = "0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02"

// Client interfaces with an execution layer JSON-RPC API
type Client struct {
	rpcURL     string
	httpClient *http.Client
	chainID    uint64
}

// NetworkConfig holds chain-specific configuration
type NetworkConfig struct {
	ChainID     uint64
	GenesisTime uint64
	Name        string
}

// Known network configurations
var Networks = map[uint64]NetworkConfig{
	1: {
		ChainID:     1,
		GenesisTime: 1606824023, // Mainnet genesis
		Name:        "mainnet",
	},
	17000: {
		ChainID:     17000,
		GenesisTime: 1695902400, // Holesky genesis
		Name:        "holesky",
	},
	11155111: {
		ChainID:     11155111,
		GenesisTime: 1655733600, // Sepolia genesis
		Name:        "sepolia",
	},
}

// NewClient creates a new execution layer client
func NewClient(rpcURL string) *Client {
	return &Client{
		rpcURL: rpcURL,
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// GetChainID fetches and caches the chain ID
func (c *Client) GetChainID(ctx context.Context) (uint64, error) {
	if c.chainID != 0 {
		return c.chainID, nil
	}

	var result string
	if err := c.call(ctx, "eth_chainId", []interface{}{}, &result); err != nil {
		return 0, err
	}

	chainID, err := hexToUint64(result)
	if err != nil {
		return 0, fmt.Errorf("failed to parse chain ID: %w", err)
	}

	c.chainID = chainID
	return chainID, nil
}

// GetNetworkConfig returns the network configuration for the current chain
func (c *Client) GetNetworkConfig(ctx context.Context) (*NetworkConfig, error) {
	chainID, err := c.GetChainID(ctx)
	if err != nil {
		return nil, err
	}

	config, ok := Networks[chainID]
	if !ok {
		return nil, fmt.Errorf("unknown chain ID: %d", chainID)
	}

	return &config, nil
}

// GetBeaconRoot queries the EIP-4788 beacon root oracle for a given timestamp
// Returns the beacon block root that was valid at the given timestamp
func (c *Client) GetBeaconRoot(ctx context.Context, timestamp uint64) (string, error) {
	// The beacon root oracle is called with the timestamp as calldata
	// It returns the beacon block root for that timestamp
	callData := fmt.Sprintf("0x%016x", timestamp)

	var result string
	err := c.call(ctx, "eth_call", []interface{}{
		map[string]string{
			"to":   BeaconRootOracleAddress,
			"data": callData,
		},
		"latest",
	}, &result)

	if err != nil {
		return "", fmt.Errorf("beacon root oracle call failed: %w", err)
	}

	// Check if result is empty or zero (timestamp not in buffer)
	if result == "" || result == "0x" || result == "0x0000000000000000000000000000000000000000000000000000000000000000" {
		return "", fmt.Errorf("beacon root not available for timestamp %d (may be outside 27-hour buffer)", timestamp)
	}

	return result, nil
}

// GetBeaconRootForSlot queries the beacon root oracle for a specific slot
func (c *Client) GetBeaconRootForSlot(ctx context.Context, slot uint64, genesisTime uint64) (string, error) {
	timestamp := genesisTime + (slot * 12)
	return c.GetBeaconRoot(ctx, timestamp)
}

// GetBlockNumber returns the current block number
func (c *Client) GetBlockNumber(ctx context.Context) (uint64, error) {
	var result string
	if err := c.call(ctx, "eth_blockNumber", []interface{}{}, &result); err != nil {
		return 0, err
	}
	return hexToUint64(result)
}

// GetBlockTimestamp returns the timestamp of a specific block
func (c *Client) GetBlockTimestamp(ctx context.Context, blockNumber uint64) (uint64, error) {
	blockHex := fmt.Sprintf("0x%x", blockNumber)

	var block struct {
		Timestamp string `json:"timestamp"`
	}

	if err := c.call(ctx, "eth_getBlockByNumber", []interface{}{blockHex, false}, &block); err != nil {
		return 0, err
	}

	return hexToUint64(block.Timestamp)
}

// GetLatestBeaconRoot returns the beacon root for the most recent available slot
func (c *Client) GetLatestBeaconRoot(ctx context.Context) (string, uint64, error) {
	// Get current block timestamp
	blockNumber, err := c.GetBlockNumber(ctx)
	if err != nil {
		return "", 0, err
	}

	timestamp, err := c.GetBlockTimestamp(ctx, blockNumber)
	if err != nil {
		return "", 0, err
	}

	// Round down to nearest slot boundary (12 seconds)
	slotTimestamp := (timestamp / 12) * 12

	// Try to get beacon root, working backwards if needed
	for attempts := 0; attempts < 10; attempts++ {
		root, err := c.GetBeaconRoot(ctx, slotTimestamp)
		if err == nil {
			return root, slotTimestamp, nil
		}
		slotTimestamp -= 12 // Try previous slot
	}

	return "", 0, fmt.Errorf("could not find recent beacon root")
}

// ValidateBeaconRoot checks if a beacon root matches what's in the oracle
func (c *Client) ValidateBeaconRoot(ctx context.Context, timestamp uint64, expectedRoot string) (bool, error) {
	root, err := c.GetBeaconRoot(ctx, timestamp)
	if err != nil {
		return false, err
	}

	// Normalize both roots for comparison
	expectedRoot = strings.ToLower(strings.TrimPrefix(expectedRoot, "0x"))
	root = strings.ToLower(strings.TrimPrefix(root, "0x"))

	return root == expectedRoot, nil
}

// CallContract makes a generic eth_call to a contract
func (c *Client) CallContract(ctx context.Context, to string, data string) (string, error) {
	var result string
	err := c.call(ctx, "eth_call", []interface{}{
		map[string]string{
			"to":   to,
			"data": data,
		},
		"latest",
	}, &result)

	return result, err
}

// GetStorageAt reads a storage slot from a contract
func (c *Client) GetStorageAt(ctx context.Context, address string, slot string) (string, error) {
	var result string
	err := c.call(ctx, "eth_getStorageAt", []interface{}{address, slot, "latest"}, &result)
	return result, err
}

// JSON-RPC request/response types
type jsonRPCRequest struct {
	JSONRPC string        `json:"jsonrpc"`
	Method  string        `json:"method"`
	Params  []interface{} `json:"params"`
	ID      int           `json:"id"`
}

type jsonRPCResponse struct {
	JSONRPC string          `json:"jsonrpc"`
	Result  json.RawMessage `json:"result"`
	Error   *jsonRPCError   `json:"error"`
	ID      int             `json:"id"`
}

type jsonRPCError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (c *Client) call(ctx context.Context, method string, params []interface{}, result interface{}) error {
	reqBody, err := json.Marshal(jsonRPCRequest{
		JSONRPC: "2.0",
		Method:  method,
		Params:  params,
		ID:      1,
	})
	if err != nil {
		return err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", c.rpcURL, strings.NewReader(string(reqBody)))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("RPC request failed: %w", err)
	}
	defer resp.Body.Close()

	var rpcResp jsonRPCResponse
	if err := json.NewDecoder(resp.Body).Decode(&rpcResp); err != nil {
		return fmt.Errorf("failed to decode response: %w", err)
	}

	if rpcResp.Error != nil {
		return fmt.Errorf("RPC error %d: %s", rpcResp.Error.Code, rpcResp.Error.Message)
	}

	return json.Unmarshal(rpcResp.Result, result)
}

func hexToUint64(s string) (uint64, error) {
	s = strings.TrimPrefix(s, "0x")
	n := new(big.Int)
	_, ok := n.SetString(s, 16)
	if !ok {
		return 0, fmt.Errorf("invalid hex: %s", s)
	}
	return n.Uint64(), nil
}

func hexToBytes(s string) ([]byte, error) {
	s = strings.TrimPrefix(s, "0x")
	return hex.DecodeString(s)
}
