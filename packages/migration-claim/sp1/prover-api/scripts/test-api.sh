#!/bin/bash
# Integration test script for SP1 Prover API
# Run this script after starting the API server

set -e

API_URL="${API_URL:-http://localhost:8080}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}PASS${NC}: $1"
}

fail() {
    echo -e "${RED}FAIL${NC}: $1"
    exit 1
}

warn() {
    echo -e "${YELLOW}WARN${NC}: $1"
}

# Test data
VALID_SS58="5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY"
VALID_SIGNATURE="0x$(printf 'ab%.0s' {1..64})"
VALID_EVM_ADDRESS="0x742d35Cc6634C0532925a3b844Bc9e7595f4a3b2"
VALID_CHALLENGE="0x$(printf '12%.0s' {1..32})"
VALID_AMOUNT="1000000000000000000"

echo "======================================"
echo "SP1 Prover API Integration Tests"
echo "API URL: $API_URL"
echo "======================================"
echo

# Test 1: Health endpoint
echo "Test 1: Health endpoint"
HEALTH=$(curl -s "$API_URL/health")
if echo "$HEALTH" | grep -q '"status":"ok"'; then
    pass "Health endpoint returns ok"
    echo "  Response: $HEALTH"
else
    fail "Health endpoint failed: $HEALTH"
fi
echo

# Test 2: Missing required fields
echo "Test 2: Missing required fields -> 400"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d '{"ss58Address": ""}')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "400" ]; then
    pass "Missing fields returns 400"
    echo "  Response: $BODY"
else
    fail "Expected 400, got $HTTP_CODE: $BODY"
fi
echo

# Test 3: Invalid signature length
echo "Test 3: Invalid signature length -> 400"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"ss58Address\": \"$VALID_SS58\",
        \"signature\": \"0x1234\",
        \"evmAddress\": \"$VALID_EVM_ADDRESS\",
        \"challenge\": \"$VALID_CHALLENGE\",
        \"amount\": \"$VALID_AMOUNT\"
    }")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "400" ]; then
    pass "Invalid signature length returns 400"
    echo "  Response: $BODY"
else
    fail "Expected 400, got $HTTP_CODE: $BODY"
fi
echo

# Test 4: Invalid amount (hex instead of decimal)
echo "Test 4: Invalid amount format -> 400"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"ss58Address\": \"$VALID_SS58\",
        \"signature\": \"$VALID_SIGNATURE\",
        \"evmAddress\": \"$VALID_EVM_ADDRESS\",
        \"challenge\": \"$VALID_CHALLENGE\",
        \"amount\": \"0x1234\"
    }")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "400" ]; then
    pass "Hex amount returns 400"
    echo "  Response: $BODY"
else
    fail "Expected 400, got $HTTP_CODE: $BODY"
fi
echo

# Test 5: Invalid SS58 address
echo "Test 5: Invalid SS58 address -> 400"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"ss58Address\": \"invalid_address_here\",
        \"signature\": \"$VALID_SIGNATURE\",
        \"evmAddress\": \"$VALID_EVM_ADDRESS\",
        \"challenge\": \"$VALID_CHALLENGE\",
        \"amount\": \"$VALID_AMOUNT\"
    }")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "400" ]; then
    pass "Invalid SS58 address returns 400"
    echo "  Response: $BODY"
else
    fail "Expected 400, got $HTTP_CODE: $BODY"
fi
echo

# Test 6: Unknown job ID -> 404
echo "Test 6: Unknown job ID -> 404"
RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/status/non-existent-job-id")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "404" ]; then
    pass "Unknown job ID returns 404"
    echo "  Response: $BODY"
else
    fail "Expected 404, got $HTTP_CODE: $BODY"
fi
echo

# Test 7: Valid request (only if in mock mode)
echo "Test 7: Valid request submission"
if echo "$HEALTH" | grep -q '"prover_mode":"mock"'; then
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"ss58Address\": \"$VALID_SS58\",
            \"signature\": \"$VALID_SIGNATURE\",
            \"evmAddress\": \"$VALID_EVM_ADDRESS\",
            \"challenge\": \"$VALID_CHALLENGE\",
            \"amount\": \"$VALID_AMOUNT\"
        }")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)

    if [ "$HTTP_CODE" = "200" ]; then
        pass "Valid request accepted"
        echo "  Response: $BODY"

        # Extract job ID and poll status
        JOB_ID=$(echo "$BODY" | grep -o '"jobId":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$JOB_ID" ]; then
            echo "  Polling status for job: $JOB_ID"
            for i in {1..10}; do
                STATUS=$(curl -s "$API_URL/status/$JOB_ID")
                echo "  Status: $STATUS"
                if echo "$STATUS" | grep -q '"status":"completed"'; then
                    pass "Job completed successfully"
                    break
                elif echo "$STATUS" | grep -q '"status":"failed"'; then
                    warn "Job failed (expected in mock mode without proper setup)"
                    break
                fi
                sleep 1
            done
        fi
    else
        fail "Expected 200, got $HTTP_CODE: $BODY"
    fi
else
    warn "Skipping - API is not in mock mode (prover_mode != mock)"
fi
echo

# Test 8: Rate limiting test
echo "Test 8: Rate limiting"
if echo "$HEALTH" | grep -q '"prover_mode":"mock"'; then
    echo "  Sending multiple rapid requests..."
    for i in {1..5}; do
        RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
            -H "Content-Type: application/json" \
            -d "{
                \"ss58Address\": \"$VALID_SS58\",
                \"signature\": \"$VALID_SIGNATURE\",
                \"evmAddress\": \"$VALID_EVM_ADDRESS\",
                \"challenge\": \"$VALID_CHALLENGE\",
                \"amount\": \"$VALID_AMOUNT\"
            }")
        HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
        BODY=$(echo "$RESPONSE" | head -n-1)
        echo "  Request $i: HTTP $HTTP_CODE"

        if [ "$HTTP_CODE" = "429" ]; then
            pass "Rate limiting kicked in on request $i"
            echo "  Response: $BODY"
            break
        fi
    done
else
    warn "Skipping - API is not in mock mode"
fi
echo

echo "======================================"
echo "Integration tests completed"
echo "======================================"
