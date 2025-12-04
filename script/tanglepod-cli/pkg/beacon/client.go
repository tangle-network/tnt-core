package beacon

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

// Client interfaces with a beacon node API
type Client struct {
	baseURL    string
	httpClient *http.Client
}

// NewClient creates a new beacon node client
func NewClient(baseURL string) *Client {
	return &Client{
		baseURL: strings.TrimSuffix(baseURL, "/"),
		httpClient: &http.Client{
			Timeout: 60 * time.Second,
		},
	}
}

// BeaconBlockHeader represents a beacon block header
type BeaconBlockHeader struct {
	Slot          uint64 `json:"slot,string"`
	ProposerIndex uint64 `json:"proposer_index,string"`
	ParentRoot    string `json:"parent_root"`
	StateRoot     string `json:"state_root"`
	BodyRoot      string `json:"body_root"`
}

// BeaconBlock represents a beacon block
type BeaconBlock struct {
	Slot          uint64 `json:"slot,string"`
	ProposerIndex uint64 `json:"proposer_index,string"`
	ParentRoot    string `json:"parent_root"`
	StateRoot     string `json:"state_root"`
	Body          struct {
		ExecutionPayload struct {
			BlockNumber uint64 `json:"block_number,string"`
			Timestamp   uint64 `json:"timestamp,string"`
		} `json:"execution_payload"`
	} `json:"body"`
}

// ValidatorData represents validator information from the beacon chain
type ValidatorData struct {
	Index     uint64 `json:"index,string"`
	Balance   uint64 `json:"balance,string"`
	Status    string `json:"status"`
	Validator struct {
		Pubkey                     string `json:"pubkey"`
		WithdrawalCredentials      string `json:"withdrawal_credentials"`
		EffectiveBalance           uint64 `json:"effective_balance,string"`
		Slashed                    bool   `json:"slashed"`
		ActivationEligibilityEpoch uint64 `json:"activation_eligibility_epoch,string"`
		ActivationEpoch            uint64 `json:"activation_epoch,string"`
		ExitEpoch                  uint64 `json:"exit_epoch,string"`
		WithdrawableEpoch          uint64 `json:"withdrawable_epoch,string"`
	} `json:"validator"`
}

// BeaconState represents the beacon chain state (simplified)
type BeaconState struct {
	GenesisTime           uint64           `json:"genesis_time,string"`
	GenesisValidatorsRoot string           `json:"genesis_validators_root"`
	Slot                  uint64           `json:"slot,string"`
	Fork                  Fork             `json:"fork"`
	Validators            []*ValidatorData `json:"validators"`
	Balances              []uint64         `json:"balances"`
}

// Fork represents the fork data
type Fork struct {
	PreviousVersion string `json:"previous_version"`
	CurrentVersion  string `json:"current_version"`
	Epoch           uint64 `json:"epoch,string"`
}

// StateRootResponse represents the response from /eth/v1/beacon/states/{state_id}/root
type StateRootResponse struct {
	Data struct {
		Root string `json:"root"`
	} `json:"data"`
}

// BlockRootResponse represents the response from /eth/v1/beacon/blocks/{block_id}/root
type BlockRootResponse struct {
	Data struct {
		Root string `json:"root"`
	} `json:"data"`
}

// FinalityCheckpoints represents finality checkpoint data
type FinalityCheckpoints struct {
	Data struct {
		PreviousJustified struct {
			Epoch uint64 `json:"epoch,string"`
			Root  string `json:"root"`
		} `json:"previous_justified"`
		CurrentJustified struct {
			Epoch uint64 `json:"epoch,string"`
			Root  string `json:"root"`
		} `json:"current_justified"`
		Finalized struct {
			Epoch uint64 `json:"epoch,string"`
			Root  string `json:"root"`
		} `json:"finalized"`
	} `json:"data"`
}

// GetBlockRoot gets the block root for a given block ID
func (c *Client) GetBlockRoot(ctx context.Context, blockID string) (string, error) {
	url := fmt.Sprintf("%s/eth/v1/beacon/blocks/%s/root", c.baseURL, blockID)

	var resp BlockRootResponse
	if err := c.get(ctx, url, &resp); err != nil {
		return "", err
	}

	return resp.Data.Root, nil
}

// GetStateRoot gets the state root for a given state ID
func (c *Client) GetStateRoot(ctx context.Context, stateID string) (string, error) {
	url := fmt.Sprintf("%s/eth/v1/beacon/states/%s/root", c.baseURL, stateID)

	var resp StateRootResponse
	if err := c.get(ctx, url, &resp); err != nil {
		return "", err
	}

	return resp.Data.Root, nil
}

// GetBlockHeader gets the block header for a given block ID
func (c *Client) GetBlockHeader(ctx context.Context, blockID string) (*BeaconBlockHeader, error) {
	url := fmt.Sprintf("%s/eth/v1/beacon/headers/%s", c.baseURL, blockID)

	var resp struct {
		Data struct {
			Root   string `json:"root"`
			Header struct {
				Message BeaconBlockHeader `json:"message"`
			} `json:"header"`
		} `json:"data"`
	}

	if err := c.get(ctx, url, &resp); err != nil {
		return nil, err
	}

	return &resp.Data.Header.Message, nil
}

// GetValidator gets validator data by index
func (c *Client) GetValidator(ctx context.Context, stateID string, validatorIndex uint64) (*ValidatorData, error) {
	url := fmt.Sprintf("%s/eth/v1/beacon/states/%s/validators/%d", c.baseURL, stateID, validatorIndex)

	var resp struct {
		Data ValidatorData `json:"data"`
	}

	if err := c.get(ctx, url, &resp); err != nil {
		return nil, err
	}

	return &resp.Data, nil
}

// GetValidators gets all validators for a state
func (c *Client) GetValidators(ctx context.Context, stateID string, indices []uint64) ([]*ValidatorData, error) {
	url := fmt.Sprintf("%s/eth/v1/beacon/states/%s/validators", c.baseURL, stateID)

	// Add validator indices as query params if specified
	if len(indices) > 0 {
		idStrs := make([]string, len(indices))
		for i, idx := range indices {
			idStrs[i] = fmt.Sprintf("%d", idx)
		}
		url = fmt.Sprintf("%s?id=%s", url, strings.Join(idStrs, ","))
	}

	var resp struct {
		Data []*ValidatorData `json:"data"`
	}

	if err := c.get(ctx, url, &resp); err != nil {
		return nil, err
	}

	return resp.Data, nil
}

// GetFinalityCheckpoints gets finality checkpoint information
func (c *Client) GetFinalityCheckpoints(ctx context.Context, stateID string) (*FinalityCheckpoints, error) {
	url := fmt.Sprintf("%s/eth/v1/beacon/states/%s/finality_checkpoints", c.baseURL, stateID)

	var resp FinalityCheckpoints
	if err := c.get(ctx, url, &resp); err != nil {
		return nil, err
	}

	return &resp, nil
}

// GetBeaconStateSSZ gets the full beacon state in SSZ format
// This requires debug endpoints to be enabled on the beacon node
func (c *Client) GetBeaconStateSSZ(ctx context.Context, stateID string) ([]byte, error) {
	url := fmt.Sprintf("%s/eth/v2/debug/beacon/states/%s", c.baseURL, stateID)

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/octet-stream")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch state: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("beacon API error %d: %s", resp.StatusCode, string(body))
	}

	return io.ReadAll(resp.Body)
}

// GetSlot returns the current slot from the beacon chain
func (c *Client) GetSlot(ctx context.Context) (uint64, error) {
	header, err := c.GetBlockHeader(ctx, "head")
	if err != nil {
		return 0, err
	}
	return header.Slot, nil
}

// SlotToTimestamp converts a slot number to a Unix timestamp
// Assumes mainnet genesis time and 12-second slots
func SlotToTimestamp(slot uint64, genesisTime uint64) uint64 {
	return genesisTime + (slot * 12)
}

// TimestampToSlot converts a Unix timestamp to a slot number
func TimestampToSlot(timestamp uint64, genesisTime uint64) uint64 {
	if timestamp <= genesisTime {
		return 0
	}
	return (timestamp - genesisTime) / 12
}

// Helper to parse hex bytes
func HexToBytes(s string) ([]byte, error) {
	s = strings.TrimPrefix(s, "0x")
	return hex.DecodeString(s)
}

// Helper to format bytes as hex
func BytesToHex(b []byte) string {
	return "0x" + hex.EncodeToString(b)
}

func (c *Client) get(ctx context.Context, url string, result interface{}) error {
	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return err
	}
	req.Header.Set("Accept", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("beacon API error %d: %s", resp.StatusCode, string(body))
	}

	return json.NewDecoder(resp.Body).Decode(result)
}
