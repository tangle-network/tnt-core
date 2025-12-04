package beacon

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

// LightClientProver fetches proofs using the Lodestar light client prover API
// This API is available on Lodestar beacon nodes with the prover enabled
type LightClientProver struct {
	baseURL    string
	httpClient *http.Client
}

// NewLightClientProver creates a new prover client
func NewLightClientProver(baseURL string) *LightClientProver {
	return &LightClientProver{
		baseURL:    strings.TrimSuffix(baseURL, "/"),
		httpClient: &http.Client{},
	}
}

// StateProof represents a proof from the Lodestar prover API
type StateProof struct {
	Leaf   string   `json:"leaf"`
	Proof  []string `json:"proof"`
	GIndex uint64   `json:"gindex"`
}

// ValidatorProofResponse from the prover API
type ValidatorProofResponse struct {
	Data struct {
		ValidatorIndex uint64   `json:"validatorIndex"`
		Proof          []string `json:"proof"`
		Leaf           string   `json:"leaf"`
	} `json:"data"`
}

// BalancesProofResponse from the prover API
type BalancesProofResponse struct {
	Data struct {
		Proof          []string `json:"proof"`
		BalancesRoot   string   `json:"balancesRoot"`
		ValidatorCount uint64   `json:"validatorCount"`
	} `json:"data"`
}

// GetValidatorProof fetches a validator proof from the prover API
// This is specific to Lodestar's prover endpoint
func (p *LightClientProver) GetValidatorProof(ctx context.Context, stateID string, validatorIndex uint64) (*StateProof, error) {
	url := fmt.Sprintf("%s/eth/v1/lightclient/proof/%s?paths=validators/%d", p.baseURL, stateID, validatorIndex)

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/json")

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("prover API error %d: %s", resp.StatusCode, string(body))
	}

	var result struct {
		Data StateProof `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	return &result.Data, nil
}

// GetBalancesProof fetches a proof for the balances container
func (p *LightClientProver) GetBalancesProof(ctx context.Context, stateID string) (*StateProof, error) {
	url := fmt.Sprintf("%s/eth/v1/lightclient/proof/%s?paths=balances", p.baseURL, stateID)

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/json")

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("prover API error %d: %s", resp.StatusCode, string(body))
	}

	var result struct {
		Data StateProof `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	return &result.Data, nil
}

// GetMultiProof fetches proofs for multiple paths in a single request
func (p *LightClientProver) GetMultiProof(ctx context.Context, stateID string, paths []string) (map[string]StateProof, error) {
	pathsQuery := strings.Join(paths, ",")
	url := fmt.Sprintf("%s/eth/v1/lightclient/proof/%s?paths=%s", p.baseURL, stateID, pathsQuery)

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/json")

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("prover API error %d: %s", resp.StatusCode, string(body))
	}

	var result struct {
		Data map[string]StateProof `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, err
	}

	return result.Data, nil
}

// ExecutionPayloadProof represents a proof for execution payload values
type ExecutionPayloadProof struct {
	StateRoot        string   `json:"stateRoot"`
	BlockNumber      uint64   `json:"blockNumber"`
	Timestamp        uint64   `json:"timestamp"`
	StateRootProof   []string `json:"stateRootProof"`
	BlockNumberProof []string `json:"blockNumberProof"`
	TimestampProof   []string `json:"timestampProof"`
}

// GetExecutionPayloadProof fetches proofs for execution payload fields
func (p *LightClientProver) GetExecutionPayloadProof(ctx context.Context, stateID string) (*ExecutionPayloadProof, error) {
	paths := []string{
		"latestExecutionPayloadHeader/stateRoot",
		"latestExecutionPayloadHeader/blockNumber",
		"latestExecutionPayloadHeader/timestamp",
	}

	proofs, err := p.GetMultiProof(ctx, stateID, paths)
	if err != nil {
		return nil, err
	}

	result := &ExecutionPayloadProof{}

	if p, ok := proofs["latestExecutionPayloadHeader/stateRoot"]; ok {
		result.StateRoot = p.Leaf
		result.StateRootProof = p.Proof
	}
	if p, ok := proofs["latestExecutionPayloadHeader/blockNumber"]; ok {
		result.BlockNumberProof = p.Proof
	}
	if p, ok := proofs["latestExecutionPayloadHeader/timestamp"]; ok {
		result.TimestampProof = p.Proof
	}

	return result, nil
}
