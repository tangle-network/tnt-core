use alloy_primitives::U256;
use axum::http::HeaderMap;
use sr25519_claim_lib::ss58_decode;

use crate::types::{error_codes, ProveRequest};

/// Validation error with code and message
#[derive(Debug, Clone)]
pub struct ValidationError {
    pub code: String,
    pub message: String,
}

impl ValidationError {
    pub fn new(code: &str, message: impl Into<String>) -> Self {
        Self {
            code: code.to_string(),
            message: message.into(),
        }
    }

    pub fn invalid_input(message: impl Into<String>) -> Self {
        Self::new(error_codes::INVALID_INPUT, message)
    }
}

impl std::fmt::Display for ValidationError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}: {}", self.code, self.message)
    }
}

impl std::error::Error for ValidationError {}

/// Validated proof request with parsed fields
#[derive(Debug, Clone)]
pub struct ValidatedRequest {
    pub pubkey: [u8; 32],
    pub signature: [u8; 64],
    pub challenge: [u8; 32],
    pub amount: [u8; 32],
}

/// Validate and parse a proof request
pub fn validate_request(request: &ProveRequest) -> Result<ValidatedRequest, ValidationError> {
    // Check for empty fields
    if request.ss58_address.trim().is_empty() {
        return Err(ValidationError::invalid_input("ss58Address is required"));
    }
    if request.signature.trim().is_empty() {
        return Err(ValidationError::invalid_input("signature is required"));
    }
    if request.evm_address.trim().is_empty() {
        return Err(ValidationError::invalid_input("evmAddress is required"));
    }
    if request.challenge.trim().is_empty() {
        return Err(ValidationError::invalid_input("challenge is required"));
    }
    if request.amount.trim().is_empty() {
        return Err(ValidationError::invalid_input("amount is required"));
    }

    // Validate amount is decimal
    if !is_decimal(&request.amount) {
        return Err(ValidationError::invalid_input(
            "amount must be a base-10 decimal string",
        ));
    }

    // Parse and validate SS58 address
    let pubkey = ss58_decode(&request.ss58_address)
        .map_err(|e| ValidationError::invalid_input(format!("Invalid ss58Address: {e}")))?;

    // Parse and validate signature (64 bytes)
    let signature = parse_hex_bytes::<64>(&request.signature)
        .map_err(|e| ValidationError::invalid_input(format!("Invalid signature: {e}")))?;

    // Validate EVM address format (20 bytes) - we check but don't store
    parse_hex_bytes::<20>(&request.evm_address)
        .map_err(|e| ValidationError::invalid_input(format!("Invalid evmAddress: {e}")))?;

    // Parse and validate challenge (32 bytes)
    let challenge = parse_hex_bytes::<32>(&request.challenge)
        .map_err(|e| ValidationError::invalid_input(format!("Invalid challenge: {e}")))?;

    // Parse amount
    let amount = parse_amount(&request.amount)
        .map_err(|e| ValidationError::invalid_input(format!("Invalid amount: {e}")))?;

    Ok(ValidatedRequest {
        pubkey,
        signature,
        challenge,
        amount,
    })
}

/// Parse hex string to fixed-size byte array
pub fn parse_hex_bytes<const N: usize>(value: &str) -> Result<[u8; N], String> {
    let trimmed = value.strip_prefix("0x").unwrap_or(value);
    let bytes = hex::decode(trimmed).map_err(|e| format!("invalid hex: {e}"))?;
    if bytes.len() != N {
        return Err(format!("expected {} bytes, got {}", N, bytes.len()));
    }
    let mut out = [0u8; N];
    out.copy_from_slice(&bytes);
    Ok(out)
}

/// Parse decimal string to U256 bytes
pub fn parse_amount(value: &str) -> Result<[u8; 32], String> {
    let amount: U256 = value.parse().map_err(|_| "invalid decimal number")?;
    Ok(amount.to_be_bytes())
}

/// Check if string is a valid decimal number
pub fn is_decimal(value: &str) -> bool {
    !value.is_empty() && value.chars().all(|c| c.is_ascii_digit())
}

/// Generate cache key from request fields
pub fn cache_key(request: &ProveRequest) -> String {
    format!(
        "{}|{}|{}|{}",
        request.ss58_address, request.evm_address, request.amount, request.challenge
    )
}

/// Generate rate limit key from pubkey
pub fn rate_limit_key_pubkey(pubkey: &[u8; 32]) -> String {
    format!("pubkey:{}", hex::encode(pubkey))
}

/// Generate rate limit key from IP address
pub fn rate_limit_key_ip(ip: &str) -> String {
    format!("ip:{}", ip)
}

/// Extract client IP from headers (supports proxies)
///
/// Priority: X-Forwarded-For (first IP) → X-Real-IP → socket address
pub fn extract_client_ip(headers: &HeaderMap, socket_addr: Option<&str>) -> String {
    // Check X-Forwarded-For (first IP in chain is the original client)
    if let Some(xff) = headers.get("x-forwarded-for") {
        if let Ok(value) = xff.to_str() {
            if let Some(first_ip) = value.split(',').next() {
                let trimmed = first_ip.trim();
                if !trimmed.is_empty() {
                    return trimmed.to_string();
                }
            }
        }
    }

    // Check X-Real-IP
    if let Some(xri) = headers.get("x-real-ip") {
        if let Ok(value) = xri.to_str() {
            let trimmed = value.trim();
            if !trimmed.is_empty() {
                return trimmed.to_string();
            }
        }
    }

    // Fallback to socket address
    socket_addr.unwrap_or("unknown").to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn valid_request() -> ProveRequest {
        ProveRequest {
            ss58_address: "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY".to_string(),
            signature: format!("0x{}", "ab".repeat(64)),
            evm_address: "0x742d35Cc6634C0532925a3b844Bc9e7595f4a3b2".to_string(),
            challenge: format!("0x{}", "12".repeat(32)),
            amount: "1000000000000000000".to_string(),
        }
    }

    #[test]
    fn test_validate_request_valid() {
        let request = valid_request();
        let result = validate_request(&request);
        assert!(result.is_ok());
        let validated = result.unwrap();
        assert_eq!(validated.signature.len(), 64);
        assert_eq!(validated.challenge.len(), 32);
        assert_eq!(validated.amount.len(), 32);
        assert_eq!(validated.pubkey.len(), 32);
    }

    #[test]
    fn test_validate_request_empty_ss58() {
        let mut request = valid_request();
        request.ss58_address = "".to_string();
        let result = validate_request(&request);
        assert!(result.is_err());
        assert!(result.unwrap_err().message.contains("ss58Address"));
    }

    #[test]
    fn test_validate_request_empty_signature() {
        let mut request = valid_request();
        request.signature = "  ".to_string();
        let result = validate_request(&request);
        assert!(result.is_err());
        assert!(result.unwrap_err().message.contains("signature"));
    }

    #[test]
    fn test_validate_request_invalid_ss58() {
        let mut request = valid_request();
        request.ss58_address = "invalid_address".to_string();
        let result = validate_request(&request);
        assert!(result.is_err());
        assert!(result.unwrap_err().message.contains("ss58Address"));
    }

    #[test]
    fn test_validate_request_wrong_signature_length() {
        let mut request = valid_request();
        request.signature = "0x1234".to_string(); // Only 2 bytes
        let result = validate_request(&request);
        assert!(result.is_err());
        let err = result.unwrap_err();
        assert!(err.message.contains("signature"));
        assert!(err.message.contains("64 bytes"));
    }

    #[test]
    fn test_validate_request_wrong_evm_address_length() {
        let mut request = valid_request();
        request.evm_address = "0x1234".to_string(); // Only 2 bytes
        let result = validate_request(&request);
        assert!(result.is_err());
        let err = result.unwrap_err();
        assert!(err.message.contains("evmAddress"));
        assert!(err.message.contains("20 bytes"));
    }

    #[test]
    fn test_validate_request_wrong_challenge_length() {
        let mut request = valid_request();
        request.challenge = "0x1234".to_string(); // Only 2 bytes
        let result = validate_request(&request);
        assert!(result.is_err());
        let err = result.unwrap_err();
        assert!(err.message.contains("challenge"));
        assert!(err.message.contains("32 bytes"));
    }

    #[test]
    fn test_validate_request_hex_amount() {
        let mut request = valid_request();
        request.amount = "0x1234".to_string(); // Hex, not decimal
        let result = validate_request(&request);
        assert!(result.is_err());
        assert!(result.unwrap_err().message.contains("amount"));
    }

    #[test]
    fn test_validate_request_negative_amount() {
        let mut request = valid_request();
        request.amount = "-100".to_string();
        let result = validate_request(&request);
        assert!(result.is_err());
        assert!(result.unwrap_err().message.contains("amount"));
    }

    #[test]
    fn test_validate_request_invalid_hex() {
        let mut request = valid_request();
        request.signature = "0xGGGG".to_string(); // Invalid hex
        let result = validate_request(&request);
        assert!(result.is_err());
        assert!(result.unwrap_err().message.contains("signature"));
    }

    #[test]
    fn test_parse_hex_bytes_with_prefix() {
        let result = parse_hex_bytes::<4>("0xdeadbeef");
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), [0xde, 0xad, 0xbe, 0xef]);
    }

    #[test]
    fn test_parse_hex_bytes_without_prefix() {
        let result = parse_hex_bytes::<4>("deadbeef");
        assert!(result.is_ok());
        assert_eq!(result.unwrap(), [0xde, 0xad, 0xbe, 0xef]);
    }

    #[test]
    fn test_parse_hex_bytes_wrong_length() {
        let result = parse_hex_bytes::<4>("0x1234");
        assert!(result.is_err());
        assert!(result.unwrap_err().contains("expected 4 bytes"));
    }

    #[test]
    fn test_is_decimal() {
        assert!(is_decimal("123456789"));
        assert!(is_decimal("0"));
        assert!(is_decimal("1000000000000000000"));
        assert!(!is_decimal(""));
        assert!(!is_decimal("-100"));
        assert!(!is_decimal("12.34"));
        assert!(!is_decimal("0x1234"));
        assert!(!is_decimal("abc"));
        assert!(!is_decimal("123abc"));
    }

    #[test]
    fn test_parse_amount() {
        let result = parse_amount("1000000000000000000");
        assert!(result.is_ok());
        let bytes = result.unwrap();
        // 1e18 = 0x0de0b6b3a7640000
        assert_eq!(
            &bytes[24..],
            &[0x0d, 0xe0, 0xb6, 0xb3, 0xa7, 0x64, 0x00, 0x00]
        );
    }

    #[test]
    fn test_cache_key() {
        let request = valid_request();
        let key = cache_key(&request);
        assert!(key.contains(&request.ss58_address));
        assert!(key.contains(&request.evm_address));
        assert!(key.contains(&request.amount));
        assert!(key.contains(&request.challenge));
    }

    #[test]
    fn test_rate_limit_key_pubkey() {
        let pubkey = [0xab; 32];
        let key = rate_limit_key_pubkey(&pubkey);
        assert!(key.starts_with("pubkey:"));
        assert!(key.contains(&hex::encode(&pubkey)));
    }

    #[test]
    fn test_rate_limit_key_ip() {
        let key = rate_limit_key_ip("192.168.1.1");
        assert_eq!(key, "ip:192.168.1.1");
    }

    #[test]
    fn test_extract_client_ip_xff() {
        let mut headers = HeaderMap::new();
        headers.insert(
            "x-forwarded-for",
            "203.0.113.195, 70.41.3.18, 150.172.238.178"
                .parse()
                .unwrap(),
        );
        let ip = extract_client_ip(&headers, Some("127.0.0.1:8080"));
        assert_eq!(ip, "203.0.113.195");
    }

    #[test]
    fn test_extract_client_ip_xri() {
        let mut headers = HeaderMap::new();
        headers.insert("x-real-ip", "203.0.113.195".parse().unwrap());
        let ip = extract_client_ip(&headers, Some("127.0.0.1:8080"));
        assert_eq!(ip, "203.0.113.195");
    }

    #[test]
    fn test_extract_client_ip_socket() {
        let headers = HeaderMap::new();
        let ip = extract_client_ip(&headers, Some("192.168.1.100:54321"));
        assert_eq!(ip, "192.168.1.100:54321");
    }

    #[test]
    fn test_extract_client_ip_unknown() {
        let headers = HeaderMap::new();
        let ip = extract_client_ip(&headers, None);
        assert_eq!(ip, "unknown");
    }
}
