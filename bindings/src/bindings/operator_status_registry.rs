///Module containing a contract's types and functions.
/**

```solidity
library IOperatorStatusRegistry {
    type StatusCode is uint8;
    struct HeartbeatConfig { uint64 interval; uint8 maxMissed; bool customMetrics; }
    struct MetricDefinition { string name; uint256 minValue; uint256 maxValue; bool required; }
    struct MetricPair { string name; uint256 value; }
    struct OperatorState { uint256 lastHeartbeat; uint64 consecutiveBeats; uint8 missedBeats; StatusCode status; bytes32 lastMetricsHash; }
}
```*/
#[allow(
    non_camel_case_types,
    non_snake_case,
    clippy::pub_underscore_fields,
    clippy::style,
    clippy::empty_structs_with_brackets
)]
pub mod IOperatorStatusRegistry {
    use super::*;
    use alloy::sol_types as alloy_sol_types;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct StatusCode(u8);
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<StatusCode> for u8 {
            #[inline]
            fn stv_to_tokens(
                &self,
            ) -> <alloy::sol_types::sol_data::Uint<
                8,
            > as alloy_sol_types::SolType>::Token<'_> {
                alloy_sol_types::private::SolTypeValue::<
                    alloy::sol_types::sol_data::Uint<8>,
                >::stv_to_tokens(self)
            }
            #[inline]
            fn stv_eip712_data_word(&self) -> alloy_sol_types::Word {
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::SolType>::tokenize(self)
                    .0
            }
            #[inline]
            fn stv_abi_encode_packed_to(
                &self,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::SolType>::abi_encode_packed_to(self, out)
            }
            #[inline]
            fn stv_abi_packed_encoded_size(&self) -> usize {
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::SolType>::abi_encoded_size(self)
            }
        }
        impl StatusCode {
            /// The Solidity type name.
            pub const NAME: &'static str = stringify!(@ name);
            /// Convert from the underlying value type.
            #[inline]
            pub const fn from_underlying(value: u8) -> Self {
                Self(value)
            }
            /// Return the underlying value.
            #[inline]
            pub const fn into_underlying(self) -> u8 {
                self.0
            }
            /// Return the single encoding of this value, delegating to the
            /// underlying type.
            #[inline]
            pub fn abi_encode(&self) -> alloy_sol_types::private::Vec<u8> {
                <Self as alloy_sol_types::SolType>::abi_encode(&self.0)
            }
            /// Return the packed encoding of this value, delegating to the
            /// underlying type.
            #[inline]
            pub fn abi_encode_packed(&self) -> alloy_sol_types::private::Vec<u8> {
                <Self as alloy_sol_types::SolType>::abi_encode_packed(&self.0)
            }
        }
        #[automatically_derived]
        impl From<u8> for StatusCode {
            fn from(value: u8) -> Self {
                Self::from_underlying(value)
            }
        }
        #[automatically_derived]
        impl From<StatusCode> for u8 {
            fn from(value: StatusCode) -> Self {
                value.into_underlying()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolType for StatusCode {
            type RustType = u8;
            type Token<'a> = <alloy::sol_types::sol_data::Uint<
                8,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SOL_NAME: &'static str = Self::NAME;
            const ENCODED_SIZE: Option<usize> = <alloy::sol_types::sol_data::Uint<
                8,
            > as alloy_sol_types::SolType>::ENCODED_SIZE;
            const PACKED_ENCODED_SIZE: Option<usize> = <alloy::sol_types::sol_data::Uint<
                8,
            > as alloy_sol_types::SolType>::PACKED_ENCODED_SIZE;
            #[inline]
            fn valid_token(token: &Self::Token<'_>) -> bool {
                Self::type_check(token).is_ok()
            }
            #[inline]
            fn type_check(token: &Self::Token<'_>) -> alloy_sol_types::Result<()> {
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::SolType>::type_check(token)
            }
            #[inline]
            fn detokenize(token: Self::Token<'_>) -> Self::RustType {
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::SolType>::detokenize(token)
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::EventTopic for StatusCode {
            #[inline]
            fn topic_preimage_length(rust: &Self::RustType) -> usize {
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::EventTopic>::topic_preimage_length(rust)
            }
            #[inline]
            fn encode_topic_preimage(
                rust: &Self::RustType,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(rust, out)
            }
            #[inline]
            fn encode_topic(
                rust: &Self::RustType,
            ) -> alloy_sol_types::abi::token::WordToken {
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::EventTopic>::encode_topic(rust)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**```solidity
struct HeartbeatConfig { uint64 interval; uint8 maxMissed; bool customMetrics; }
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct HeartbeatConfig {
        #[allow(missing_docs)]
        pub interval: u64,
        #[allow(missing_docs)]
        pub maxMissed: u8,
        #[allow(missing_docs)]
        pub customMetrics: bool,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (
            alloy::sol_types::sol_data::Uint<64>,
            alloy::sol_types::sol_data::Uint<8>,
            alloy::sol_types::sol_data::Bool,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (u64, u8, bool);
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<HeartbeatConfig> for UnderlyingRustTuple<'_> {
            fn from(value: HeartbeatConfig) -> Self {
                (value.interval, value.maxMissed, value.customMetrics)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for HeartbeatConfig {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    interval: tuple.0,
                    maxMissed: tuple.1,
                    customMetrics: tuple.2,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolValue for HeartbeatConfig {
            type SolType = Self;
        }
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<Self> for HeartbeatConfig {
            #[inline]
            fn stv_to_tokens(&self) -> <Self as alloy_sol_types::SolType>::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.interval),
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.maxMissed),
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        &self.customMetrics,
                    ),
                )
            }
            #[inline]
            fn stv_abi_encoded_size(&self) -> usize {
                if let Some(size) = <Self as alloy_sol_types::SolType>::ENCODED_SIZE {
                    return size;
                }
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_encoded_size(&tuple)
            }
            #[inline]
            fn stv_eip712_data_word(&self) -> alloy_sol_types::Word {
                <Self as alloy_sol_types::SolStruct>::eip712_hash_struct(self)
            }
            #[inline]
            fn stv_abi_encode_packed_to(
                &self,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_encode_packed_to(&tuple, out)
            }
            #[inline]
            fn stv_abi_packed_encoded_size(&self) -> usize {
                if let Some(size) = <Self as alloy_sol_types::SolType>::PACKED_ENCODED_SIZE {
                    return size;
                }
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_packed_encoded_size(&tuple)
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolType for HeartbeatConfig {
            type RustType = Self;
            type Token<'a> = <UnderlyingSolTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SOL_NAME: &'static str = <Self as alloy_sol_types::SolStruct>::NAME;
            const ENCODED_SIZE: Option<usize> = <UnderlyingSolTuple<
                '_,
            > as alloy_sol_types::SolType>::ENCODED_SIZE;
            const PACKED_ENCODED_SIZE: Option<usize> = <UnderlyingSolTuple<
                '_,
            > as alloy_sol_types::SolType>::PACKED_ENCODED_SIZE;
            #[inline]
            fn valid_token(token: &Self::Token<'_>) -> bool {
                <UnderlyingSolTuple<'_> as alloy_sol_types::SolType>::valid_token(token)
            }
            #[inline]
            fn detokenize(token: Self::Token<'_>) -> Self::RustType {
                let tuple = <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::detokenize(token);
                <Self as ::core::convert::From<UnderlyingRustTuple<'_>>>::from(tuple)
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolStruct for HeartbeatConfig {
            const NAME: &'static str = "HeartbeatConfig";
            #[inline]
            fn eip712_root_type() -> alloy_sol_types::private::Cow<'static, str> {
                alloy_sol_types::private::Cow::Borrowed(
                    "HeartbeatConfig(uint64 interval,uint8 maxMissed,bool customMetrics)",
                )
            }
            #[inline]
            fn eip712_components() -> alloy_sol_types::private::Vec<
                alloy_sol_types::private::Cow<'static, str>,
            > {
                alloy_sol_types::private::Vec::new()
            }
            #[inline]
            fn eip712_encode_type() -> alloy_sol_types::private::Cow<'static, str> {
                <Self as alloy_sol_types::SolStruct>::eip712_root_type()
            }
            #[inline]
            fn eip712_encode_data(&self) -> alloy_sol_types::private::Vec<u8> {
                [
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.interval)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.maxMissed)
                        .0,
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::eip712_data_word(
                            &self.customMetrics,
                        )
                        .0,
                ]
                    .concat()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::EventTopic for HeartbeatConfig {
            #[inline]
            fn topic_preimage_length(rust: &Self::RustType) -> usize {
                0usize
                    + <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.interval,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.maxMissed,
                    )
                    + <alloy::sol_types::sol_data::Bool as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.customMetrics,
                    )
            }
            #[inline]
            fn encode_topic_preimage(
                rust: &Self::RustType,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                out.reserve(
                    <Self as alloy_sol_types::EventTopic>::topic_preimage_length(rust),
                );
                <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.interval,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.maxMissed,
                    out,
                );
                <alloy::sol_types::sol_data::Bool as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.customMetrics,
                    out,
                );
            }
            #[inline]
            fn encode_topic(
                rust: &Self::RustType,
            ) -> alloy_sol_types::abi::token::WordToken {
                let mut out = alloy_sol_types::private::Vec::new();
                <Self as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    rust,
                    &mut out,
                );
                alloy_sol_types::abi::token::WordToken(
                    alloy_sol_types::private::keccak256(out),
                )
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**```solidity
struct MetricDefinition { string name; uint256 minValue; uint256 maxValue; bool required; }
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MetricDefinition {
        #[allow(missing_docs)]
        pub name: alloy::sol_types::private::String,
        #[allow(missing_docs)]
        pub minValue: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub maxValue: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub required: bool,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (
            alloy::sol_types::sol_data::String,
            alloy::sol_types::sol_data::Uint<256>,
            alloy::sol_types::sol_data::Uint<256>,
            alloy::sol_types::sol_data::Bool,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (
            alloy::sol_types::private::String,
            alloy::sol_types::private::primitives::aliases::U256,
            alloy::sol_types::private::primitives::aliases::U256,
            bool,
        );
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<MetricDefinition> for UnderlyingRustTuple<'_> {
            fn from(value: MetricDefinition) -> Self {
                (value.name, value.minValue, value.maxValue, value.required)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for MetricDefinition {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    name: tuple.0,
                    minValue: tuple.1,
                    maxValue: tuple.2,
                    required: tuple.3,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolValue for MetricDefinition {
            type SolType = Self;
        }
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<Self> for MetricDefinition {
            #[inline]
            fn stv_to_tokens(&self) -> <Self as alloy_sol_types::SolType>::Token<'_> {
                (
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.name,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.minValue),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.maxValue),
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        &self.required,
                    ),
                )
            }
            #[inline]
            fn stv_abi_encoded_size(&self) -> usize {
                if let Some(size) = <Self as alloy_sol_types::SolType>::ENCODED_SIZE {
                    return size;
                }
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_encoded_size(&tuple)
            }
            #[inline]
            fn stv_eip712_data_word(&self) -> alloy_sol_types::Word {
                <Self as alloy_sol_types::SolStruct>::eip712_hash_struct(self)
            }
            #[inline]
            fn stv_abi_encode_packed_to(
                &self,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_encode_packed_to(&tuple, out)
            }
            #[inline]
            fn stv_abi_packed_encoded_size(&self) -> usize {
                if let Some(size) = <Self as alloy_sol_types::SolType>::PACKED_ENCODED_SIZE {
                    return size;
                }
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_packed_encoded_size(&tuple)
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolType for MetricDefinition {
            type RustType = Self;
            type Token<'a> = <UnderlyingSolTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SOL_NAME: &'static str = <Self as alloy_sol_types::SolStruct>::NAME;
            const ENCODED_SIZE: Option<usize> = <UnderlyingSolTuple<
                '_,
            > as alloy_sol_types::SolType>::ENCODED_SIZE;
            const PACKED_ENCODED_SIZE: Option<usize> = <UnderlyingSolTuple<
                '_,
            > as alloy_sol_types::SolType>::PACKED_ENCODED_SIZE;
            #[inline]
            fn valid_token(token: &Self::Token<'_>) -> bool {
                <UnderlyingSolTuple<'_> as alloy_sol_types::SolType>::valid_token(token)
            }
            #[inline]
            fn detokenize(token: Self::Token<'_>) -> Self::RustType {
                let tuple = <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::detokenize(token);
                <Self as ::core::convert::From<UnderlyingRustTuple<'_>>>::from(tuple)
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolStruct for MetricDefinition {
            const NAME: &'static str = "MetricDefinition";
            #[inline]
            fn eip712_root_type() -> alloy_sol_types::private::Cow<'static, str> {
                alloy_sol_types::private::Cow::Borrowed(
                    "MetricDefinition(string name,uint256 minValue,uint256 maxValue,bool required)",
                )
            }
            #[inline]
            fn eip712_components() -> alloy_sol_types::private::Vec<
                alloy_sol_types::private::Cow<'static, str>,
            > {
                alloy_sol_types::private::Vec::new()
            }
            #[inline]
            fn eip712_encode_type() -> alloy_sol_types::private::Cow<'static, str> {
                <Self as alloy_sol_types::SolStruct>::eip712_root_type()
            }
            #[inline]
            fn eip712_encode_data(&self) -> alloy_sol_types::private::Vec<u8> {
                [
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::eip712_data_word(
                            &self.name,
                        )
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.minValue)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.maxValue)
                        .0,
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::eip712_data_word(
                            &self.required,
                        )
                        .0,
                ]
                    .concat()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::EventTopic for MetricDefinition {
            #[inline]
            fn topic_preimage_length(rust: &Self::RustType) -> usize {
                0usize
                    + <alloy::sol_types::sol_data::String as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.name,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.minValue,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.maxValue,
                    )
                    + <alloy::sol_types::sol_data::Bool as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.required,
                    )
            }
            #[inline]
            fn encode_topic_preimage(
                rust: &Self::RustType,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                out.reserve(
                    <Self as alloy_sol_types::EventTopic>::topic_preimage_length(rust),
                );
                <alloy::sol_types::sol_data::String as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.name,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.minValue,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.maxValue,
                    out,
                );
                <alloy::sol_types::sol_data::Bool as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.required,
                    out,
                );
            }
            #[inline]
            fn encode_topic(
                rust: &Self::RustType,
            ) -> alloy_sol_types::abi::token::WordToken {
                let mut out = alloy_sol_types::private::Vec::new();
                <Self as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    rust,
                    &mut out,
                );
                alloy_sol_types::abi::token::WordToken(
                    alloy_sol_types::private::keccak256(out),
                )
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**```solidity
struct MetricPair { string name; uint256 value; }
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MetricPair {
        #[allow(missing_docs)]
        pub name: alloy::sol_types::private::String,
        #[allow(missing_docs)]
        pub value: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (
            alloy::sol_types::sol_data::String,
            alloy::sol_types::sol_data::Uint<256>,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (
            alloy::sol_types::private::String,
            alloy::sol_types::private::primitives::aliases::U256,
        );
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<MetricPair> for UnderlyingRustTuple<'_> {
            fn from(value: MetricPair) -> Self {
                (value.name, value.value)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for MetricPair {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    name: tuple.0,
                    value: tuple.1,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolValue for MetricPair {
            type SolType = Self;
        }
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<Self> for MetricPair {
            #[inline]
            fn stv_to_tokens(&self) -> <Self as alloy_sol_types::SolType>::Token<'_> {
                (
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.name,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.value),
                )
            }
            #[inline]
            fn stv_abi_encoded_size(&self) -> usize {
                if let Some(size) = <Self as alloy_sol_types::SolType>::ENCODED_SIZE {
                    return size;
                }
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_encoded_size(&tuple)
            }
            #[inline]
            fn stv_eip712_data_word(&self) -> alloy_sol_types::Word {
                <Self as alloy_sol_types::SolStruct>::eip712_hash_struct(self)
            }
            #[inline]
            fn stv_abi_encode_packed_to(
                &self,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_encode_packed_to(&tuple, out)
            }
            #[inline]
            fn stv_abi_packed_encoded_size(&self) -> usize {
                if let Some(size) = <Self as alloy_sol_types::SolType>::PACKED_ENCODED_SIZE {
                    return size;
                }
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_packed_encoded_size(&tuple)
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolType for MetricPair {
            type RustType = Self;
            type Token<'a> = <UnderlyingSolTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SOL_NAME: &'static str = <Self as alloy_sol_types::SolStruct>::NAME;
            const ENCODED_SIZE: Option<usize> = <UnderlyingSolTuple<
                '_,
            > as alloy_sol_types::SolType>::ENCODED_SIZE;
            const PACKED_ENCODED_SIZE: Option<usize> = <UnderlyingSolTuple<
                '_,
            > as alloy_sol_types::SolType>::PACKED_ENCODED_SIZE;
            #[inline]
            fn valid_token(token: &Self::Token<'_>) -> bool {
                <UnderlyingSolTuple<'_> as alloy_sol_types::SolType>::valid_token(token)
            }
            #[inline]
            fn detokenize(token: Self::Token<'_>) -> Self::RustType {
                let tuple = <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::detokenize(token);
                <Self as ::core::convert::From<UnderlyingRustTuple<'_>>>::from(tuple)
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolStruct for MetricPair {
            const NAME: &'static str = "MetricPair";
            #[inline]
            fn eip712_root_type() -> alloy_sol_types::private::Cow<'static, str> {
                alloy_sol_types::private::Cow::Borrowed(
                    "MetricPair(string name,uint256 value)",
                )
            }
            #[inline]
            fn eip712_components() -> alloy_sol_types::private::Vec<
                alloy_sol_types::private::Cow<'static, str>,
            > {
                alloy_sol_types::private::Vec::new()
            }
            #[inline]
            fn eip712_encode_type() -> alloy_sol_types::private::Cow<'static, str> {
                <Self as alloy_sol_types::SolStruct>::eip712_root_type()
            }
            #[inline]
            fn eip712_encode_data(&self) -> alloy_sol_types::private::Vec<u8> {
                [
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::eip712_data_word(
                            &self.name,
                        )
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.value)
                        .0,
                ]
                    .concat()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::EventTopic for MetricPair {
            #[inline]
            fn topic_preimage_length(rust: &Self::RustType) -> usize {
                0usize
                    + <alloy::sol_types::sol_data::String as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.name,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(&rust.value)
            }
            #[inline]
            fn encode_topic_preimage(
                rust: &Self::RustType,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                out.reserve(
                    <Self as alloy_sol_types::EventTopic>::topic_preimage_length(rust),
                );
                <alloy::sol_types::sol_data::String as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.name,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.value,
                    out,
                );
            }
            #[inline]
            fn encode_topic(
                rust: &Self::RustType,
            ) -> alloy_sol_types::abi::token::WordToken {
                let mut out = alloy_sol_types::private::Vec::new();
                <Self as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    rust,
                    &mut out,
                );
                alloy_sol_types::abi::token::WordToken(
                    alloy_sol_types::private::keccak256(out),
                )
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**```solidity
struct OperatorState { uint256 lastHeartbeat; uint64 consecutiveBeats; uint8 missedBeats; StatusCode status; bytes32 lastMetricsHash; }
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct OperatorState {
        #[allow(missing_docs)]
        pub lastHeartbeat: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub consecutiveBeats: u64,
        #[allow(missing_docs)]
        pub missedBeats: u8,
        #[allow(missing_docs)]
        pub status: <StatusCode as alloy::sol_types::SolType>::RustType,
        #[allow(missing_docs)]
        pub lastMetricsHash: alloy::sol_types::private::FixedBytes<32>,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (
            alloy::sol_types::sol_data::Uint<256>,
            alloy::sol_types::sol_data::Uint<64>,
            alloy::sol_types::sol_data::Uint<8>,
            StatusCode,
            alloy::sol_types::sol_data::FixedBytes<32>,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (
            alloy::sol_types::private::primitives::aliases::U256,
            u64,
            u8,
            <StatusCode as alloy::sol_types::SolType>::RustType,
            alloy::sol_types::private::FixedBytes<32>,
        );
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<OperatorState> for UnderlyingRustTuple<'_> {
            fn from(value: OperatorState) -> Self {
                (
                    value.lastHeartbeat,
                    value.consecutiveBeats,
                    value.missedBeats,
                    value.status,
                    value.lastMetricsHash,
                )
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for OperatorState {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    lastHeartbeat: tuple.0,
                    consecutiveBeats: tuple.1,
                    missedBeats: tuple.2,
                    status: tuple.3,
                    lastMetricsHash: tuple.4,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolValue for OperatorState {
            type SolType = Self;
        }
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<Self> for OperatorState {
            #[inline]
            fn stv_to_tokens(&self) -> <Self as alloy_sol_types::SolType>::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.lastHeartbeat),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.consecutiveBeats),
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.missedBeats),
                    <StatusCode as alloy_sol_types::SolType>::tokenize(&self.status),
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(&self.lastMetricsHash),
                )
            }
            #[inline]
            fn stv_abi_encoded_size(&self) -> usize {
                if let Some(size) = <Self as alloy_sol_types::SolType>::ENCODED_SIZE {
                    return size;
                }
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_encoded_size(&tuple)
            }
            #[inline]
            fn stv_eip712_data_word(&self) -> alloy_sol_types::Word {
                <Self as alloy_sol_types::SolStruct>::eip712_hash_struct(self)
            }
            #[inline]
            fn stv_abi_encode_packed_to(
                &self,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_encode_packed_to(&tuple, out)
            }
            #[inline]
            fn stv_abi_packed_encoded_size(&self) -> usize {
                if let Some(size) = <Self as alloy_sol_types::SolType>::PACKED_ENCODED_SIZE {
                    return size;
                }
                let tuple = <UnderlyingRustTuple<
                    '_,
                > as ::core::convert::From<Self>>::from(self.clone());
                <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_packed_encoded_size(&tuple)
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolType for OperatorState {
            type RustType = Self;
            type Token<'a> = <UnderlyingSolTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SOL_NAME: &'static str = <Self as alloy_sol_types::SolStruct>::NAME;
            const ENCODED_SIZE: Option<usize> = <UnderlyingSolTuple<
                '_,
            > as alloy_sol_types::SolType>::ENCODED_SIZE;
            const PACKED_ENCODED_SIZE: Option<usize> = <UnderlyingSolTuple<
                '_,
            > as alloy_sol_types::SolType>::PACKED_ENCODED_SIZE;
            #[inline]
            fn valid_token(token: &Self::Token<'_>) -> bool {
                <UnderlyingSolTuple<'_> as alloy_sol_types::SolType>::valid_token(token)
            }
            #[inline]
            fn detokenize(token: Self::Token<'_>) -> Self::RustType {
                let tuple = <UnderlyingSolTuple<
                    '_,
                > as alloy_sol_types::SolType>::detokenize(token);
                <Self as ::core::convert::From<UnderlyingRustTuple<'_>>>::from(tuple)
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolStruct for OperatorState {
            const NAME: &'static str = "OperatorState";
            #[inline]
            fn eip712_root_type() -> alloy_sol_types::private::Cow<'static, str> {
                alloy_sol_types::private::Cow::Borrowed(
                    "OperatorState(uint256 lastHeartbeat,uint64 consecutiveBeats,uint8 missedBeats,uint8 status,bytes32 lastMetricsHash)",
                )
            }
            #[inline]
            fn eip712_components() -> alloy_sol_types::private::Vec<
                alloy_sol_types::private::Cow<'static, str>,
            > {
                alloy_sol_types::private::Vec::new()
            }
            #[inline]
            fn eip712_encode_type() -> alloy_sol_types::private::Cow<'static, str> {
                <Self as alloy_sol_types::SolStruct>::eip712_root_type()
            }
            #[inline]
            fn eip712_encode_data(&self) -> alloy_sol_types::private::Vec<u8> {
                [
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.lastHeartbeat)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::eip712_data_word(
                            &self.consecutiveBeats,
                        )
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.missedBeats)
                        .0,
                    <StatusCode as alloy_sol_types::SolType>::eip712_data_word(
                            &self.status,
                        )
                        .0,
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::eip712_data_word(
                            &self.lastMetricsHash,
                        )
                        .0,
                ]
                    .concat()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::EventTopic for OperatorState {
            #[inline]
            fn topic_preimage_length(rust: &Self::RustType) -> usize {
                0usize
                    + <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.lastHeartbeat,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.consecutiveBeats,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.missedBeats,
                    )
                    + <StatusCode as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.status,
                    )
                    + <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.lastMetricsHash,
                    )
            }
            #[inline]
            fn encode_topic_preimage(
                rust: &Self::RustType,
                out: &mut alloy_sol_types::private::Vec<u8>,
            ) {
                out.reserve(
                    <Self as alloy_sol_types::EventTopic>::topic_preimage_length(rust),
                );
                <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.lastHeartbeat,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.consecutiveBeats,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    8,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.missedBeats,
                    out,
                );
                <StatusCode as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.status,
                    out,
                );
                <alloy::sol_types::sol_data::FixedBytes<
                    32,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.lastMetricsHash,
                    out,
                );
            }
            #[inline]
            fn encode_topic(
                rust: &Self::RustType,
            ) -> alloy_sol_types::abi::token::WordToken {
                let mut out = alloy_sol_types::private::Vec::new();
                <Self as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    rust,
                    &mut out,
                );
                alloy_sol_types::abi::token::WordToken(
                    alloy_sol_types::private::keccak256(out),
                )
            }
        }
    };
    use alloy::contract as alloy_contract;
    /**Creates a new wrapper around an on-chain [`IOperatorStatusRegistry`](self) contract instance.

See the [wrapper's documentation](`IOperatorStatusRegistryInstance`) for more details.*/
    #[inline]
    pub const fn new<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(
        address: alloy_sol_types::private::Address,
        __provider: P,
    ) -> IOperatorStatusRegistryInstance<P, N> {
        IOperatorStatusRegistryInstance::<P, N>::new(address, __provider)
    }
    /**A [`IOperatorStatusRegistry`](self) instance.

Contains type-safe methods for interacting with an on-chain instance of the
[`IOperatorStatusRegistry`](self) contract located at a given `address`, using a given
provider `P`.

If the contract bytecode is available (see the [`sol!`](alloy_sol_types::sol!)
documentation on how to provide it), the `deploy` and `deploy_builder` methods can
be used to deploy a new instance of the contract.

See the [module-level documentation](self) for all the available methods.*/
    #[derive(Clone)]
    pub struct IOperatorStatusRegistryInstance<
        P,
        N = alloy_contract::private::Ethereum,
    > {
        address: alloy_sol_types::private::Address,
        provider: P,
        _network: ::core::marker::PhantomData<N>,
    }
    #[automatically_derived]
    impl<P, N> ::core::fmt::Debug for IOperatorStatusRegistryInstance<P, N> {
        #[inline]
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            f.debug_tuple("IOperatorStatusRegistryInstance")
                .field(&self.address)
                .finish()
        }
    }
    /// Instantiation and getters/setters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > IOperatorStatusRegistryInstance<P, N> {
        /**Creates a new wrapper around an on-chain [`IOperatorStatusRegistry`](self) contract instance.

See the [wrapper's documentation](`IOperatorStatusRegistryInstance`) for more details.*/
        #[inline]
        pub const fn new(
            address: alloy_sol_types::private::Address,
            __provider: P,
        ) -> Self {
            Self {
                address,
                provider: __provider,
                _network: ::core::marker::PhantomData,
            }
        }
        /// Returns a reference to the address.
        #[inline]
        pub const fn address(&self) -> &alloy_sol_types::private::Address {
            &self.address
        }
        /// Sets the address.
        #[inline]
        pub fn set_address(&mut self, address: alloy_sol_types::private::Address) {
            self.address = address;
        }
        /// Sets the address and returns `self`.
        pub fn at(mut self, address: alloy_sol_types::private::Address) -> Self {
            self.set_address(address);
            self
        }
        /// Returns a reference to the provider.
        #[inline]
        pub const fn provider(&self) -> &P {
            &self.provider
        }
    }
    impl<P: ::core::clone::Clone, N> IOperatorStatusRegistryInstance<&P, N> {
        /// Clones the provider and returns a new instance with the cloned provider.
        #[inline]
        pub fn with_cloned_provider(self) -> IOperatorStatusRegistryInstance<P, N> {
            IOperatorStatusRegistryInstance {
                address: self.address,
                provider: ::core::clone::Clone::clone(&self.provider),
                _network: ::core::marker::PhantomData,
            }
        }
    }
    /// Function calls.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > IOperatorStatusRegistryInstance<P, N> {
        /// Creates a new call builder using this contract instance's provider and address.
        ///
        /// Note that the call can be any function call, not just those defined in this
        /// contract. Prefer using the other methods for building type-safe contract calls.
        pub fn call_builder<C: alloy_sol_types::SolCall>(
            &self,
            call: &C,
        ) -> alloy_contract::SolCallBuilder<&P, C, N> {
            alloy_contract::SolCallBuilder::new_sol(&self.provider, &self.address, call)
        }
    }
    /// Event filters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > IOperatorStatusRegistryInstance<P, N> {
        /// Creates a new event filter using this contract instance's provider and address.
        ///
        /// Note that the type can be any event, not just those defined in this contract.
        /// Prefer using the other methods for building type-safe event filters.
        pub fn event_filter<E: alloy_sol_types::SolEvent>(
            &self,
        ) -> alloy_contract::Event<&P, E, N> {
            alloy_contract::Event::new_sol(&self.provider, &self.address)
        }
    }
}
/**

Generated by the following Solidity interface...
```solidity
library IOperatorStatusRegistry {
    type StatusCode is uint8;
    struct HeartbeatConfig {
        uint64 interval;
        uint8 maxMissed;
        bool customMetrics;
    }
    struct MetricDefinition {
        string name;
        uint256 minValue;
        uint256 maxValue;
        bool required;
    }
    struct MetricPair {
        string name;
        uint256 value;
    }
    struct OperatorState {
        uint256 lastHeartbeat;
        uint64 consecutiveBeats;
        uint8 missedBeats;
        StatusCode status;
        bytes32 lastMetricsHash;
    }
}

interface OperatorStatusRegistry {
    error ECDSAInvalidSignature();
    error ECDSAInvalidSignatureLength(uint256 length);
    error ECDSAInvalidSignatureS(bytes32 s);
    error HeartbeatFromFuture(uint64 signed, uint64 now_);
    error HeartbeatStale(uint64 signed, uint64 now_);
    error OwnableInvalidOwner(address owner);
    error OwnableUnauthorizedAccount(address account);

    event HeartbeatConfigUpdated(uint64 indexed serviceId, uint64 interval, uint8 maxMissed);
    event HeartbeatReceived(uint64 indexed serviceId, uint64 indexed blueprintId, address indexed operator, uint8 statusCode, uint256 timestamp);
    event MetricReported(uint64 indexed serviceId, address indexed operator, string metricName, uint256 value);
    event MetricViolation(uint64 indexed serviceId, address indexed operator, string metricName, string reason);
    event OperatorCameOnline(uint64 indexed serviceId, address indexed operator);
    event OperatorDeregistered(uint64 indexed serviceId, address indexed operator);
    event OperatorRegistered(uint64 indexed serviceId, address indexed operator);
    event OperatorWentOffline(uint64 indexed serviceId, address indexed operator, uint8 missedBeats);
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SlashingTriggered(uint64 indexed serviceId, address indexed operator, string reason);
    event StatusChanged(uint64 indexed serviceId, address indexed operator, IOperatorStatusRegistry.StatusCode oldStatus, IOperatorStatusRegistry.StatusCode newStatus);

    constructor(address _tangleCore, address initialOwner);

    function DEFAULT_HEARTBEAT_INTERVAL() external view returns (uint64);
    function DEFAULT_MAX_MISSED_HEARTBEATS() external view returns (uint8);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function HEARTBEAT_MAX_AGE() external view returns (uint64);
    function HEARTBEAT_TYPEHASH() external view returns (bytes32);
    function MAX_METRIC_DEFINITIONS() external view returns (uint256);
    function MAX_METRIC_NAME_LENGTH() external view returns (uint256);
    function MAX_PAGE_SIZE() external view returns (uint256);
    function SLASH_ALERT_COOLDOWN() external view returns (uint64);
    function acceptOwnership() external;
    function addMetricDefinition(uint64 serviceId, string memory name, uint256 minValue, uint256 maxValue, bool required) external;
    function checkOperatorStatus(uint64 serviceId, address operator) external;
    function checkOperatorsStatus(uint64 serviceId, address[] memory operators) external;
    function configureHeartbeat(uint64 serviceId, uint64 interval, uint8 maxMissed) external;
    function decodeMetricPairs(bytes memory payload) external pure returns (IOperatorStatusRegistry.MetricPair[] memory pairs);
    function deregisterOperator(uint64 serviceId, address operator) external;
    function enableCustomMetrics(uint64 serviceId, bool enabled) external;
    function getAllOperatorCount(uint64 serviceId) external view returns (uint256);
    function getHeartbeatConfig(uint64 serviceId) external view returns (IOperatorStatusRegistry.HeartbeatConfig memory);
    function getLastCriticalHeartbeat(uint64 serviceId, address operator) external view returns (uint64);
    function getLastHeartbeat(uint64 serviceId, address operator) external view returns (uint256);
    function getMetricDefinitions(uint64 serviceId) external view returns (IOperatorStatusRegistry.MetricDefinition[] memory);
    function getMetricValue(uint64 serviceId, address operator, string memory metricName) external view returns (uint256);
    function getOnlineOperatorCount(uint64 serviceId) external view returns (uint256);
    function getOnlineOperators(uint64 serviceId) external view returns (address[] memory);
    function getOperatorState(uint64 serviceId, address operator) external view returns (IOperatorStatusRegistry.OperatorState memory);
    function getOperatorStatus(uint64 serviceId, address operator) external view returns (IOperatorStatusRegistry.StatusCode);
    function getSlashableOperators(uint64 serviceId) external view returns (address[] memory operators);
    function getSlashableOperatorsPaginated(uint64 serviceId, uint256 offset, uint256 limit) external view returns (address[] memory operators, uint256 total);
    function goOffline(uint64 serviceId) external;
    function goOnline(uint64 serviceId) external;
    function heartbeatConfigs(uint64) external view returns (uint64 interval, uint8 maxMissed, bool customMetrics);
    function isHeartbeatCurrent(uint64 serviceId, address operator) external view returns (bool);
    function isOnline(uint64 serviceId, address operator) external view returns (bool);
    function isRegisteredOperator(uint64 serviceId, address operator) external view returns (bool);
    function metricValues(uint64, address, string memory) external view returns (uint256);
    function metricsRecorder() external view returns (address);
    function operatorStates(uint64, address) external view returns (uint256 lastHeartbeat, uint64 consecutiveBeats, uint8 missedBeats, IOperatorStatusRegistry.StatusCode status, bytes32 lastMetricsHash);
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function registerOperator(uint64 serviceId, address operator) external;
    function registerServiceOwner(uint64 serviceId, address owner) external;
    function removeInactiveOperator(uint64 serviceId, address operator) external;
    function renounceOwnership() external;
    function reportForSlashing(uint64 serviceId, address operator, string memory reason) external;
    function serviceMetrics(uint64, uint256) external view returns (string memory name, uint256 minValue, uint256 maxValue, bool required);
    function serviceOwners(uint64) external view returns (address);
    function setMetricDefinitions(uint64 serviceId, IOperatorStatusRegistry.MetricDefinition[] memory definitions) external;
    function setMetricsRecorder(address recorder) external;
    function setSlashingOracle(address oracle) external;
    function slashingOracle() external view returns (address);
    function submitHeartbeat(uint64 serviceId, uint64 blueprintId, uint8 statusCode, bytes memory metrics, uint64 timestamp, bytes memory signature) external;
    function submitHeartbeatDirect(uint64 serviceId, uint64 blueprintId, uint8 statusCode, bytes memory metrics) external;
    function tangleCore() external view returns (address);
    function transferOwnership(address newOwner) external;
    function validateAndStoreMetrics(uint64 serviceId, address operator, IOperatorStatusRegistry.MetricPair[] memory pairs, uint256 pairsLen) external;
}
```

...which was generated by the following JSON ABI:
```json
[
  {
    "type": "constructor",
    "inputs": [
      {
        "name": "_tangleCore",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "initialOwner",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "DEFAULT_HEARTBEAT_INTERVAL",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "DEFAULT_MAX_MISSED_HEARTBEATS",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "DOMAIN_SEPARATOR",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "HEARTBEAT_MAX_AGE",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "HEARTBEAT_TYPEHASH",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MAX_METRIC_DEFINITIONS",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MAX_METRIC_NAME_LENGTH",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MAX_PAGE_SIZE",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "SLASH_ALERT_COOLDOWN",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "acceptOwnership",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "addMetricDefinition",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "name",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "minValue",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "maxValue",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "required",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "checkOperatorStatus",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "checkOperatorsStatus",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operators",
        "type": "address[]",
        "internalType": "address[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "configureHeartbeat",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "interval",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "maxMissed",
        "type": "uint8",
        "internalType": "uint8"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "decodeMetricPairs",
    "inputs": [
      {
        "name": "payload",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [
      {
        "name": "pairs",
        "type": "tuple[]",
        "internalType": "struct IOperatorStatusRegistry.MetricPair[]",
        "components": [
          {
            "name": "name",
            "type": "string",
            "internalType": "string"
          },
          {
            "name": "value",
            "type": "uint256",
            "internalType": "uint256"
          }
        ]
      }
    ],
    "stateMutability": "pure"
  },
  {
    "type": "function",
    "name": "deregisterOperator",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "enableCustomMetrics",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "enabled",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getAllOperatorCount",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getHeartbeatConfig",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple",
        "internalType": "struct IOperatorStatusRegistry.HeartbeatConfig",
        "components": [
          {
            "name": "interval",
            "type": "uint64",
            "internalType": "uint64"
          },
          {
            "name": "maxMissed",
            "type": "uint8",
            "internalType": "uint8"
          },
          {
            "name": "customMetrics",
            "type": "bool",
            "internalType": "bool"
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getLastCriticalHeartbeat",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getLastHeartbeat",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getMetricDefinitions",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple[]",
        "internalType": "struct IOperatorStatusRegistry.MetricDefinition[]",
        "components": [
          {
            "name": "name",
            "type": "string",
            "internalType": "string"
          },
          {
            "name": "minValue",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "maxValue",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "required",
            "type": "bool",
            "internalType": "bool"
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getMetricValue",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "metricName",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getOnlineOperatorCount",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getOnlineOperators",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "address[]",
        "internalType": "address[]"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getOperatorState",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple",
        "internalType": "struct IOperatorStatusRegistry.OperatorState",
        "components": [
          {
            "name": "lastHeartbeat",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "consecutiveBeats",
            "type": "uint64",
            "internalType": "uint64"
          },
          {
            "name": "missedBeats",
            "type": "uint8",
            "internalType": "uint8"
          },
          {
            "name": "status",
            "type": "uint8",
            "internalType": "enum IOperatorStatusRegistry.StatusCode"
          },
          {
            "name": "lastMetricsHash",
            "type": "bytes32",
            "internalType": "bytes32"
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getOperatorStatus",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint8",
        "internalType": "enum IOperatorStatusRegistry.StatusCode"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getSlashableOperators",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "operators",
        "type": "address[]",
        "internalType": "address[]"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getSlashableOperatorsPaginated",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "offset",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "limit",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "operators",
        "type": "address[]",
        "internalType": "address[]"
      },
      {
        "name": "total",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "goOffline",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "goOnline",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "heartbeatConfigs",
    "inputs": [
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "interval",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "maxMissed",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "customMetrics",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "isHeartbeatCurrent",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "isOnline",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "isRegisteredOperator",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "metricValues",
    "inputs": [
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "metricsRecorder",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "operatorStates",
    "inputs": [
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "lastHeartbeat",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "consecutiveBeats",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "missedBeats",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "status",
        "type": "uint8",
        "internalType": "enum IOperatorStatusRegistry.StatusCode"
      },
      {
        "name": "lastMetricsHash",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "owner",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "pendingOwner",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "registerOperator",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "registerServiceOwner",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "owner",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "removeInactiveOperator",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "renounceOwnership",
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "reportForSlashing",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "internalType": "string"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "serviceMetrics",
    "inputs": [
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [
      {
        "name": "name",
        "type": "string",
        "internalType": "string"
      },
      {
        "name": "minValue",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "maxValue",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "required",
        "type": "bool",
        "internalType": "bool"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "serviceOwners",
    "inputs": [
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "setMetricDefinitions",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "definitions",
        "type": "tuple[]",
        "internalType": "struct IOperatorStatusRegistry.MetricDefinition[]",
        "components": [
          {
            "name": "name",
            "type": "string",
            "internalType": "string"
          },
          {
            "name": "minValue",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "maxValue",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "required",
            "type": "bool",
            "internalType": "bool"
          }
        ]
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setMetricsRecorder",
    "inputs": [
      {
        "name": "recorder",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setSlashingOracle",
    "inputs": [
      {
        "name": "oracle",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "slashingOracle",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "submitHeartbeat",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "blueprintId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "statusCode",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "metrics",
        "type": "bytes",
        "internalType": "bytes"
      },
      {
        "name": "timestamp",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "signature",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "submitHeartbeatDirect",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "blueprintId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "statusCode",
        "type": "uint8",
        "internalType": "uint8"
      },
      {
        "name": "metrics",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "tangleCore",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "transferOwnership",
    "inputs": [
      {
        "name": "newOwner",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "validateAndStoreMetrics",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "pairs",
        "type": "tuple[]",
        "internalType": "struct IOperatorStatusRegistry.MetricPair[]",
        "components": [
          {
            "name": "name",
            "type": "string",
            "internalType": "string"
          },
          {
            "name": "value",
            "type": "uint256",
            "internalType": "uint256"
          }
        ]
      },
      {
        "name": "pairsLen",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "HeartbeatConfigUpdated",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "interval",
        "type": "uint64",
        "indexed": false,
        "internalType": "uint64"
      },
      {
        "name": "maxMissed",
        "type": "uint8",
        "indexed": false,
        "internalType": "uint8"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "HeartbeatReceived",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "blueprintId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "statusCode",
        "type": "uint8",
        "indexed": false,
        "internalType": "uint8"
      },
      {
        "name": "timestamp",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "MetricReported",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "metricName",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "value",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "MetricViolation",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "metricName",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      },
      {
        "name": "reason",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorCameOnline",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorDeregistered",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorRegistered",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorWentOffline",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "missedBeats",
        "type": "uint8",
        "indexed": false,
        "internalType": "uint8"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OwnershipTransferStarted",
    "inputs": [
      {
        "name": "previousOwner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "newOwner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OwnershipTransferred",
    "inputs": [
      {
        "name": "previousOwner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "newOwner",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "SlashingTriggered",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "reason",
        "type": "string",
        "indexed": false,
        "internalType": "string"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "StatusChanged",
    "inputs": [
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "oldStatus",
        "type": "uint8",
        "indexed": false,
        "internalType": "enum IOperatorStatusRegistry.StatusCode"
      },
      {
        "name": "newStatus",
        "type": "uint8",
        "indexed": false,
        "internalType": "enum IOperatorStatusRegistry.StatusCode"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "ECDSAInvalidSignature",
    "inputs": []
  },
  {
    "type": "error",
    "name": "ECDSAInvalidSignatureLength",
    "inputs": [
      {
        "name": "length",
        "type": "uint256",
        "internalType": "uint256"
      }
    ]
  },
  {
    "type": "error",
    "name": "ECDSAInvalidSignatureS",
    "inputs": [
      {
        "name": "s",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ]
  },
  {
    "type": "error",
    "name": "HeartbeatFromFuture",
    "inputs": [
      {
        "name": "signed",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "now_",
        "type": "uint64",
        "internalType": "uint64"
      }
    ]
  },
  {
    "type": "error",
    "name": "HeartbeatStale",
    "inputs": [
      {
        "name": "signed",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "now_",
        "type": "uint64",
        "internalType": "uint64"
      }
    ]
  },
  {
    "type": "error",
    "name": "OwnableInvalidOwner",
    "inputs": [
      {
        "name": "owner",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "OwnableUnauthorizedAccount",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ]
  }
]
```*/
#[allow(
    non_camel_case_types,
    non_snake_case,
    clippy::pub_underscore_fields,
    clippy::style,
    clippy::empty_structs_with_brackets
)]
pub mod OperatorStatusRegistry {
    use super::*;
    use alloy::sol_types as alloy_sol_types;
    /// The creation / init bytecode of the contract.
    ///
    /// ```text
    ///0x60c0604052346100655761001a610014610139565b90610216565b61002261006a565b617a9c6104d38239608051818181610ecf01526138f1015260a05181818161144e015281816126a3015281816133f4015281816156f501526162b00152617a9c90f35b610070565b60405190565b5f80fd5b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b9061009c90610074565b810190811060018060401b038211176100b457604052565b61007e565b906100cc6100c561006a565b9283610092565b565b5f80fd5b60018060a01b031690565b6100e6906100d2565b90565b6100f2816100dd565b036100f957565b5f80fd5b9050519061010a826100e9565b565b91906040838203126101345780610128610131925f86016100fd565b936020016100fd565b90565b6100ce565b610157617f6f8038038061014c816100b9565b92833981019061010c565b9091565b90565b61017261016d610177926100d2565b61015b565b6100d2565b90565b6101839061015e565b90565b61018f9061017a565b90565b90565b61019e90610192565b9052565b90565b6101ae906101a2565b9052565b6101bb906100dd565b9052565b9095949261020a946101f9610203926101ef6080966101e560a088019c5f890190610195565b6020870190610195565b6040850190610195565b60608301906101a5565b01906101b2565b565b60200190565b5190565b90610220906102d3565b60a0527f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f6102bb7f36ffc258c865193ae10c3cf640450ab772fdb8da1dfcae7862ad1205a5567f4c916102ac7fc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc64661029730610186565b916102a061006a565b968795602087016101bf565b60208201810382520382610092565b6102cd6102c782610212565b9161020c565b20608052565b6102dc9061031e565b565b90565b6102f56102f06102fa926102de565b61015b565b6100d2565b90565b610306906102e1565b90565b919061031c905f602085019401906101b2565b565b8061033961033361032e5f6102fd565b6100dd565b916100dd565b1461034957610347906103e7565b565b61036c6103555f6102fd565b5f918291631e4fbdf760e01b835260048301610309565b0390fd5b1b90565b9190600861039491029161038e60018060a01b0384610370565b92610370565b9181191691161790565b6103a79061017a565b90565b90565b91906103c36103be6103cb9361039e565b6103aa565b908354610374565b9055565b5f90565b6103e5916103df6103cf565b916103ad565b565b6103fb906103f65f60016103d3565b610473565b565b5f1c90565b60018060a01b031690565b61041961041e916103fd565b610402565b90565b61042b905461040d565b90565b5f1b90565b9061044460018060a01b039161042e565b9181191691161790565b9061046361045e61046a9261039e565b6103aa565b8254610433565b9055565b5f0190565b61047c5f610421565b610486825f61044e565b906104ba6104b47f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09361039e565b9161039e565b916104c361006a565b806104cd8161046e565b0390a356fe60806040526004361015610013575b6124f9565b61001d5f3561039c565b806305778550146103975780630758236f146103925780630c76697a1461038d578063191cbd1a146103885780631e8f5ee514610383578063208129561461037e57806322f1ec93146103795780632bf4d6a7146103745780632c9576881461036f5780632dae18851461036a5780632f4bd7b81461036557806331e3bd1b146103605780633644e5151461035b5780633ac3cbe6146103565780633e6e34a7146103515780633fd62c6d1461034c57806340235a9c1461034757806348f4da20146103425780635685cf681461033d57806356c4e17d1461033857806359dcea12146103335780635a936dc61461032e5780635cce98a6146103295780636076439c1461032457806360cf09911461031f57806361d6b86c1461031a57806362c7e8fc1461031557806365a6936e146103105780636bfe06a61461030b578063715018a61461030657806371e7388c146103015780637639d227146102fc57806379ba5097146102f75780637b9f64b2146102f257806381beac2e146102ed57806384ef7322146102e85780638da5cb5b146102e357806396686c1e146102de5780639cbdae22146102d9578063adff830c146102d4578063ae470a85146102cf578063b074e9dd146102ca578063b99f6759146102c5578063ba1fb103146102c0578063c1ef9ddf146102bb578063c5d960bb146102b6578063cfe34749146102b1578063d551162c146102ac578063da435a7c146102a7578063e30c3978146102a2578063e65cafcb1461029d578063ee1c039014610298578063f2fde38b14610293578063f9107f3b1461028e578063f9f16762146102895763ffcf08f00361000e576124c5565b612490565b61242d565b6123cd565b612397565b612363565b61232e565b6122f6565b612224565b6121ef565b6121ad565b612178565b61204e565b61201a565b611fad565b611f73565b611eaa565b611de7565b611c60565b611baa565b611b77565b611b40565b611aab565b611a78565b611a42565b611a0c565b611950565b61191b565b6118ad565b611672565b611628565b6115a6565b611571565b611503565b611470565b611417565b6113e2565b61137d565b611333565b6112c7565b6111f3565b6111b9565b610f83565b610f16565b610e97565b610d1e565b610cd0565b610c35565b610b8f565b610a62565b6106c0565b61066e565b61063a565b610577565b61051d565b61044e565b60e01c90565b60405190565b5f80fd5b5f80fd5b5f80fd5b60018060401b031690565b6103c8816103b4565b036103cf57565b5f80fd5b905035906103e0826103bf565b565b60018060a01b031690565b6103f6906103e2565b90565b610402816103ed565b0361040957565b5f80fd5b9050359061041a826103f9565b565b91906040838203126104445780610438610441925f86016103d3565b9360200161040d565b90565b6103ac565b5f0190565b3461047d5761046761046136600461041c565b90612690565b61046f6103a2565b8061047981610449565b0390f35b6103a8565b9060208282031261049b57610498915f016103d3565b90565b6103ac565b6104a9906103b4565b9052565b60ff1690565b6104bc906104ad565b9052565b151590565b6104ce906104c0565b9052565b90604080610506936104ea5f8201515f8601906104a0565b6104fc602082015160208601906104b3565b01519101906104c5565b565b919061051b905f606085019401906104d2565b565b3461054d57610549610538610533366004610482565b61276f565b6105406103a2565b91829182610508565b0390f35b6103a8565b90565b61055e90610552565b9052565b9190610575905f60208501940190610555565b565b346105a8576105a461059361058d36600461041c565b90612788565b61059b6103a2565b91829182610562565b0390f35b6103a8565b5f80fd5b5f80fd5b5f80fd5b909182601f830112156105f15781359160018060401b0383116105ec5760200192602083028401116105e757565b6105b5565b6105b1565b6105ad565b9190916040818403126106355761060f835f83016103d3565b92602082013560018060401b0381116106305761062c92016105b9565b9091565b6103b0565b6103ac565b346106695761065361064d3660046105f6565b916130fe565b61065b6103a2565b8061066581610449565b0390f35b6103a8565b3461069d5761068761068136600461041c565b906133e8565b61068f6103a2565b8061069981610449565b0390f35b6103a8565b906020828203126106bb576106b8915f0161040d565b90565b6103ac565b346106ee576106d86106d33660046106a2565b61351d565b6106e06103a2565b806106ea81610449565b0390f35b6103a8565b6106fc81610552565b0361070357565b5f80fd5b90503590610714826106f3565b565b919060408382031261073e578061073261073b925f86016103d3565b93602001610707565b90565b6103ac565b90565b61075a61075561075f926103b4565b610743565b6103b4565b90565b9061076c90610746565b5f5260205260405f2090565b634e487b7160e01b5f52603260045260245ffd5b5490565b5f5260205f2090565b5f5260205f2090565b6107ab8161078c565b8210156107c5576107bd600491610790565b910201905f90565b610778565b634e487b7160e01b5f52602260045260245ffd5b90600160028304921680156107fe575b60208310146107f957565b6107ca565b91607f16916107ee565b60209181520190565b5f5260205f2090565b905f929180549061083461082d836107de565b8094610808565b916001811690815f1461088b575060011461084f575b505050565b61085c9192939450610811565b915f925b81841061087357505001905f808061084a565b60018160209295939554848601520191019290610860565b92949550505060ff19168252151560200201905f808061084a565b906108b09161081a565b90565b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b906108db906108b3565b810190811060018060401b038211176108f357604052565b6108bd565b90610918610911926109086103a2565b938480926108a6565b03836108d1565b565b5f1c90565b90565b61092e6109339161091a565b61091f565b90565b6109409054610922565b90565b60ff1690565b61095561095a9161091a565b610943565b90565b6109679054610949565b90565b610975906008610762565b9061097f8261078c565b8110156109c55761098f916107a2565b509061099c5f83016108f8565b916109a960018201610936565b916109c260036109bb60028501610936565b930161095d565b90565b5f80fd5b5190565b60209181520190565b90825f9392825e0152565b610a00610a09602093610a0e936109f7816109c9565b938480936109cd565b958691016109d6565b6108b3565b0190565b610a1b906104c0565b9052565b610a59610a6094610a4f610a446060959998969960808601908682035f8801526109e1565b986020850190610555565b6040830190610555565b0190610a12565b565b34610a9757610a93610a7e610a78366004610716565b9061096a565b90610a8a9492946103a2565b94859485610a1f565b0390f35b6103a8565b610aa5816104ad565b03610aac57565b5f80fd5b90503590610abd82610a9c565b565b909182601f83011215610af75781359160018060401b038311610af2576020019260018302840111610aed57565b6105b5565b6105b1565b6105ad565b919060c083820312610b8a57610b14815f85016103d3565b92610b2282602083016103d3565b92610b308360408401610ab0565b92606083013560018060401b038111610b855781610b4f918501610abf565b929093610b5f83608083016103d3565b9260a082013560018060401b038111610b8057610b7c9201610abf565b9091565b6103b0565b6103b0565b6103ac565b34610bc757610bb1610ba2366004610afc565b969590959491949392936139ca565b610bb96103a2565b80610bc381610449565b0390f35b6103a8565b5f910312610bd657565b6103ac565b90565b610bf2610bed610bf792610bdb565b610743565b6103b4565b90565b610c0561012c610bde565b90565b610c10610bfa565b90565b610c1c906103b4565b9052565b9190610c33905f60208501940190610c13565b565b34610c6557610c45366004610bcc565b610c61610c50610c08565b610c586103a2565b91829182610c20565b0390f35b6103a8565b1c90565b60018060a01b031690565b610c89906008610c8e9302610c6a565b610c6e565b90565b90610c9c9154610c79565b90565b610cab600b5f90610c91565b90565b610cb7906103ed565b9052565b9190610cce905f60208501940190610cae565b565b34610d0057610ce0366004610bcc565b610cfc610ceb610c9f565b610cf36103a2565b91829182610cbb565b0390f35b6103a8565b610d1061012c610bde565b90565b610d1b610d05565b90565b34610d4e57610d2e366004610bcc565b610d4a610d39610d13565b610d416103a2565b91829182610c20565b0390f35b6103a8565b90602082820312610d82575f82013560018060401b038111610d7d57610d799201610abf565b9091565b6103b0565b6103ac565b5190565b60209181520190565b60200190565b610db9610dc2602093610dc793610db0816109c9565b93848093610808565b958691016109d6565b6108b3565b0190565b610dd490610552565b9052565b90610e0290602080610df7604084015f8701518582035f870152610d9a565b940151910190610dcb565b90565b90610e0f91610dd8565b90565b60200190565b90610e2c610e2583610d87565b8092610d8b565b9081610e3d60208302840194610d94565b925f915b838310610e5057505050505090565b90919293946020610e72610e6c83856001950387528951610e05565b97610e12565b9301930191939290610e41565b610e949160208201915f818403910152610e18565b90565b34610ec857610ec4610eb3610ead366004610d53565b90613a14565b610ebb6103a2565b91829182610e7f565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b90565b610efd90610ef1565b9052565b9190610f14905f60208501940190610ef4565b565b34610f4657610f26366004610bcc565b610f42610f31610ecd565b610f396103a2565b91829182610f01565b0390f35b6103a8565b90565b610f62610f5d610f6792610f4b565b610743565b6103b4565b90565b610f75610e10610f4e565b90565b610f80610f6a565b90565b34610fb357610f93366004610bcc565b610faf610f9e610f78565b610fa66103a2565b91829182610c20565b0390f35b6103a8565b90610fc290610746565b5f5260205260405f2090565b610fe2610fdd610fe7926103e2565b610743565b6103e2565b90565b610ff390610fce565b90565b610fff90610fea565b90565b9061100c90610ff6565b5f5260205260405f2090565b60018060401b031690565b61102f6110349161091a565b611018565b90565b6110419054611023565b90565b60401c90565b60ff1690565b61105c61106191611044565b61104a565b90565b61106e9054611050565b90565b60481c90565b60ff1690565b61108961108e91611071565b611077565b90565b61109b905461107d565b90565b90565b6110ad6110b29161091a565b61109e565b90565b6110bf90546110a1565b90565b906110d16110d6926003610fb8565b611002565b6110e15f8201610936565b916110ee60018301611037565b916110fb60018201611064565b91611114600261110d60018501611091565b93016110b5565b90565b611120906104ad565b9052565b634e487b7160e01b5f52602160045260245ffd5b6005111561114257565b611124565b9061115182611138565b565b61115c90611147565b90565b61116890611153565b9052565b909594926111b7946111a66111b09261119c60809661119260a088019c5f890190610555565b6020870190610c13565b6040850190611117565b606083019061115f565b0190610ef4565b565b346111ee576111ea6111d56111cf36600461041c565b906110c2565b916111e19593956103a2565b9586958661116c565b0390f35b6103a8565b346112235761121f61120e611209366004610482565b613a2e565b6112166103a2565b91829182610562565b0390f35b6103a8565b5190565b60209181520190565b60200190565b611244906103ed565b9052565b906112558160209361123b565b0190565b60200190565b9061127c61127661126f84611228565b809361122c565b92611235565b905f5b81811061128c5750505090565b9091926112a561129f6001928651611248565b94611259565b910191909161127f565b6112c49160208201915f81840391015261125f565b90565b346112f7576112f36112e26112dd366004610482565b613ae6565b6112ea6103a2565b918291826112af565b0390f35b6103a8565b90565b61131361130e611318926112fc565b610743565b610552565b90565b61132560c86112ff565b90565b61133061131b565b90565b3461136357611343366004610bcc565b61135f61134e611328565b6113566103a2565b91829182610562565b0390f35b6103a8565b919061137b905f60208501940190610a12565b565b346113ae576113aa61139961139336600461041c565b90613b86565b6113a16103a2565b91829182611368565b0390f35b6103a8565b906113bd90610746565b5f5260205260405f2090565b6113df906113da6007915f926113b3565b610c91565b90565b346114125761140e6113fd6113f8366004610482565b6113c9565b6114056103a2565b91829182610cbb565b0390f35b6103a8565b346114475761144361143261142d366004610482565b613c0d565b61143a6103a2565b918291826112af565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b346114a057611480366004610bcc565b61149c61148b61144c565b6114936103a2565b91829182610cbb565b0390f35b6103a8565b906080828203126114fe576114bc815f84016103d3565b926114ca82602085016103d3565b926114d88360408301610ab0565b92606082013560018060401b0381116114f9576114f59201610abf565b9091565b6103b0565b6103ac565b346115355761151f6115163660046114a5565b93929092613c7f565b6115276103a2565b8061153181610449565b0390f35b6103a8565b90565b61155161154c6115569261153a565b610743565b610552565b90565b611563603261153d565b90565b61156e611559565b90565b346115a157611581366004610bcc565b61159d61158c611566565b6115946103a2565b91829182610562565b0390f35b6103a8565b346115d7576115d36115c26115bc36600461041c565b90613c8e565b6115ca6103a2565b91829182611368565b0390f35b6103a8565b90565b6115f36115ee6115f8926115dc565b610743565b6104ad565b90565b61160560036115df565b90565b6116106115fb565b90565b9190611626905f60208501940190611117565b565b3461165857611638366004610bcc565b611654611643611608565b61164b6103a2565b91829182611613565b0390f35b6103a8565b9190611670905f6020850194019061115f565b565b346116a35761169f61168e61168836600461041c565b90613cba565b6116966103a2565b9182918261165d565b0390f35b6103a8565b906116bb6116b46103a2565b92836108d1565b565b60018060401b0381116116d35760208091020190565b6108bd565b5f80fd5b5f80fd5b5f80fd5b60018060401b038111611700576116fc6020916108b3565b0190565b6108bd565b90825f939282370152565b90929192611725611720826116e4565b6116a8565b938185526020850190828401116117415761173f92611705565b565b6116e0565b9080601f830112156117645781602061176193359101611710565b90565b6105ad565b9190916040818403126117ba5761178060406116a8565b925f8201359160018060401b0383116117b5576117a2826117ae948301611746565b5f860152602001610707565b6020830152565b6116dc565b6116d8565b9291906117d36117ce826116bd565b6116a8565b93818552602080860192028101918383116118285781905b8382106117f9575050505050565b813560018060401b038111611823576020916118188784938701611769565b8152019101906117eb565b6105ad565b6105b5565b9080601f8301121561184b57816020611848933591016117bf565b90565b6105ad565b6080818303126118a857611866825f83016103d3565b92611874836020840161040d565b9260408301359060018060401b0382116118a357611897816118a093860161182d565b93606001610707565b90565b6103b0565b6103ac565b346118df576118c96118c0366004611850565b9291909161409e565b6118d16103a2565b806118db81610449565b0390f35b6103a8565b90565b6118fb6118f6611900926118e4565b610743565b610552565b90565b61190d60406118e7565b90565b611918611903565b90565b3461194b5761192b366004610bcc565b611947611936611910565b61193e6103a2565b91829182610562565b0390f35b6103a8565b3461197e57611960366004610bcc565b6119686146cd565b6119706103a2565b8061197a81610449565b0390f35b6103a8565b61198c90611153565b9052565b61199990610ef1565b9052565b906080806119f5936119b55f8201515f860190610dcb565b6119c7602082015160208601906104a0565b6119d9604082015160408601906104b3565b6119eb60608201516060860190611983565b0151910190611990565b565b9190611a0a905f60a0850194019061199d565b565b34611a3d57611a39611a28611a2236600461041c565b9061480a565b611a306103a2565b918291826119f7565b0390f35b6103a8565b34611a7357611a6f611a5e611a5836600461041c565b90614862565b611a666103a2565b91829182610c20565b0390f35b6103a8565b34611aa657611a88366004610bcc565b611a9061488a565b611a986103a2565b80611aa281610449565b0390f35b6103a8565b34611adb57611ad7611ac6611ac1366004610482565b6148db565b611ace6103a2565b91829182610562565b0390f35b6103a8565b9091606082840312611b1557611b12611afb845f85016103d3565b93611b098160208601610707565b93604001610707565b90565b6103ac565b92916020611b36611b3e9360408701908782035f89015261125f565b940190610555565b565b34611b7257611b59611b53366004611ae0565b91614979565b90611b6e611b656103a2565b92839283611b1a565b0390f35b6103a8565b34611ba557611b8f611b8a3660046106a2565b614b00565b611b976103a2565b80611ba181610449565b0390f35b6103a8565b34611bda57611bba366004610bcc565b611bd6611bc5614b0f565b611bcd6103a2565b91829182610cbb565b0390f35b6103a8565b909182601f83011215611c175781359160018060401b038311611c12576020019260208302840111611c0d57565b6105b5565b6105b1565b6105ad565b919091604081840312611c5b57611c35835f83016103d3565b92602082013560018060401b038111611c5657611c529201611bdf565b9091565b6103b0565b6103ac565b34611c8f57611c79611c73366004611c1c565b91614b96565b611c816103a2565b80611c8b81610449565b0390f35b6103a8565b91606083830312611cde57611cab825f85016103d3565b92611cb9836020830161040d565b92604082013560018060401b038111611cd957611cd69201611746565b90565b6103b0565b6103ac565b90611ced90610746565b5f5260205260405f2090565b90611d0390610ff6565b5f5260205260405f2090565b905090565b611d39611d3092602092611d27816109c9565b94858093611d0f565b938491016109d6565b0190565b90565b611d4c611d5191610552565b611d3d565b9052565b611d65611d6c9160209493611d14565b8092611d40565b0190565b611d84611d7b6103a2565b92839283611d55565b03902090565b611d9391611d70565b90565b611da6906008611dab9302610c6a565b61091f565b90565b90611db99154611d96565b90565b90611de492611dda611ddf92611dd56009955f96611ce3565b611cf9565b611d8a565b611dae565b90565b34611e1857611e14611e03611dfd366004611c94565b91611dbc565b611e0b6103a2565b91829182610562565b0390f35b6103a8565b909182601f83011215611e555781359160018060401b038311611e50576020019260018302840111611e4b57565b6105b5565b6105b1565b6105ad565b91606083830312611ea557611e71825f85016103d3565b92611e7f836020830161040d565b92604082013560018060401b038111611ea057611e9c9201611e1d565b9091565b6103b0565b6103ac565b34611edc57611ec6611ebd366004611e5a565b92919091614df9565b611ece6103a2565b80611ed881610449565b0390f35b6103a8565b611eea816104c0565b03611ef157565b5f80fd5b90503590611f0282611ee1565b565b91909160a081840312611f6e57611f1d835f83016103d3565b92602082013560018060401b038111611f695781611f3c918401611e1d565b929093611f66611f4f8460408501610707565b93611f5d8160608601610707565b93608001611ef5565b90565b6103b0565b6103ac565b34611fa857611f92611f86366004611f04565b949390939291926150c7565b611f9a6103a2565b80611fa481610449565b0390f35b6103a8565b34611fdb57611fc5611fc0366004610482565b615477565b611fcd6103a2565b80611fd781610449565b0390f35b6103a8565b909160608284031261201557612012611ffb845f85016103d3565b9361200981602086016103d3565b93604001610ab0565b90565b6103ac565b346120495761203361202d366004611fe0565b916156ec565b61203b6103a2565b8061204581610449565b0390f35b6103a8565b3461207d5761206761206136600461041c565b906158ab565b61206f6103a2565b8061207981610449565b0390f35b6103a8565b5190565b60209181520190565b60200190565b906120e3906060806120b4608084015f8701518582035f870152610d9a565b946120c760208201516020860190610dcb565b6120d960408201516040860190610dcb565b01519101906104c5565b90565b906120f091612095565b90565b60200190565b9061210d61210683612082565b8092612086565b908161211e6020830284019461208f565b925f915b83831061213157505050505090565b9091929394602061215361214d838560019503875289516120e6565b976120f3565b9301930191939290612122565b6121759160208201915f8184039101526120f9565b90565b346121a8576121a461219361218e366004610482565b615c20565b61219b6103a2565b91829182612160565b0390f35b6103a8565b346121db576121c56121c0366004610482565b615db0565b6121cd6103a2565b806121d781610449565b0390f35b6103a8565b6121ec600a5f90610c91565b90565b3461221f576121ff366004610bcc565b61221b61220a6121e0565b6122126103a2565b91829182610cbb565b0390f35b6103a8565b346122585761225461224361223a366004611e5a565b92919091615e1d565b61224b6103a2565b91829182610562565b0390f35b6103a8565b9061226790610746565b5f5260205260405f2090565b61227f61228491611071565b610943565b90565b6122919054612273565b90565b61229f90600261225d565b6122aa5f8201611037565b916122c15f6122ba818501611064565b9301612287565b90565b6040906122ed6122f494969593966122e360608401985f850190610c13565b6020830190611117565b0190610a12565b565b346123295761232561231161230c366004610482565b612294565b61231c9391936103a2565b938493846122c4565b0390f35b6103a8565b3461235e5761233e366004610bcc565b61235a612349615e52565b6123516103a2565b91829182610cbb565b0390f35b6103a8565b346123925761237c61237636600461041c565b90615f3c565b6123846103a2565b8061238e81610449565b0390f35b6103a8565b346123c8576123c46123b36123ad36600461041c565b906160d1565b6123bb6103a2565b91829182611368565b0390f35b6103a8565b346123fb576123e56123e03660046106a2565b6161d0565b6123ed6103a2565b806123f781610449565b0390f35b6103a8565b9190604083820312612428578061241c612425925f86016103d3565b93602001611ef5565b90565b6103ac565b3461245c57612446612440366004612400565b906161db565b61244e6103a2565b8061245881610449565b0390f35b6103a8565b7f32721f8dc67e953c540da90f663059c23fc47f70d11e317ed6d5a24c8b85637490565b61248d612461565b90565b346124c0576124a0366004610bcc565b6124bc6124ab612485565b6124b36103a2565b91829182610f01565b0390f35b6103a8565b346124f4576124de6124d836600461041c565b906162a4565b6124e66103a2565b806124f081610449565b0390f35b6103a8565b5f80fd5b5f7f4f6e6c792054616e676c6520636f726500000000000000000000000000000000910152565b61253160106020926109cd565b61253a816124fd565b0190565b6125539060208101905f818303910152612524565b90565b1561255d57565b6125656103a2565b62461bcd60e51b81528061257b6004820161253e565b0390fd5b61258b6125909161091a565b610c6e565b90565b61259d905461257f565b90565b90565b6125b76125b26125bc926125a0565b610743565b6103e2565b90565b6125c8906125a3565b90565b5f7f416c726561647920726567697374657265640000000000000000000000000000910152565b6125ff60126020926109cd565b612608816125cb565b0190565b6126219060208101905f8183039101526125f2565b90565b1561262b57565b6126336103a2565b62461bcd60e51b8152806126496004820161260c565b0390fd5b5f1b90565b9061266360018060a01b039161264d565b9181191691161790565b90565b9061268561268061268c92610ff6565b61266d565b8254612652565b9055565b612712612717926126d3336126cd6126c77f00000000000000000000000000000000000000000000000000000000000000006103ed565b916103ed565b14612556565b61270a6126ea6126e5600786906113b3565b612593565b6127046126fe6126f95f6125bf565b6103ed565b916103ed565b14612624565b9160076113b3565b612670565b565b61272360606116a8565b90565b5f90565b5f90565b5f90565b61273a612719565b906020808084612748612726565b81520161275361272a565b81520161275e61272e565b81525050565b61276c612732565b90565b6127819061277b612764565b506163cc565b90565b5f90565b6127a96127af926127a45f9361279c612784565b506003610fb8565b611002565b01610936565b90565b5f7f4e6f742073657276696365206f776e6572000000000000000000000000000000910152565b6127e660116020926109cd565b6127ef816127b2565b0190565b6128089060208101905f8183039101526127d9565b90565b1561281257565b61281a6103a2565b62461bcd60e51b815280612830600482016127f3565b0390fd5b5090565b5f7f546f6f206d616e7920646566696e6974696f6e73000000000000000000000000910152565b61286c60146020926109cd565b61287581612838565b0190565b61288e9060208101905f81830391015261285f565b90565b1561289857565b6128a06103a2565b62461bcd60e51b8152806128b660048201612879565b0390fd5b634e487b7160e01b5f52601160045260245ffd5b6128dd6128e391939293610552565b92610552565b916128ef838202610552565b9281840414901517156128fe57565b6128ba565b61290e9060046128ce565b90565b90612924905f1990602003600802610c6a565b8154169055565b1b90565b9190600861294a9102916129445f198461292b565b9261292b565b9181191691161790565b61296861296361296d92610552565b610743565b610552565b90565b90565b919061298961298461299193612954565b612970565b90835461292f565b9055565b6129a7916129a1612784565b91612973565b565b5b8181106129b5575050565b806129c25f600193612995565b016129aa565b906129d8905f1990600802610c6a565b191690565b816129e7916129c8565b906002021790565b905f91612a066129fe82610811565b9283546129dd565b905555565b601f602091010490565b919290602082105f14612a6e57601f8411600114612a3e57612a389293506129dd565b90555b5b565b5090612a64612a69936001612a5b612a5585610811565b92612a0b565b820191016129a9565b6129ef565b612a3b565b50612aa58293612a7f600194610811565b612a9e612a8b85612a0b565b820192601f861680612ab0575b50612a0b565b01906129a9565b600202179055612a3c565b612abc90888603612911565b5f612a98565b929091600160401b8211612b1d576020115f14612b0e57602081105f14612af257612aec916129dd565b90555b5b565b60019160ff1916612b0284610811565b55600202019055612aef565b60019150600202019055612af0565b6108bd565b908154612b2e816107de565b90818311612b57575b818310612b45575b50505050565b612b4e93612a15565b5f808080612b3f565b612b6383838387612ac2565b612b37565b5f612b7291612b22565b565b634e487b7160e01b5f525f60045260245ffd5b905f03612b9957612b9790612b68565b565b612b74565b60035f91612bae83808301612b87565b612bbb8360018301612995565b612bc88360028301612995565b0155565b905f03612bde57612bdc90612b9e565b565b612b74565b5b818110612bef575050565b80612bfc5f600493612bcc565b01612be4565b9091828110612c11575b505050565b612c2f612c29612c23612c3a95612903565b92612903565b92610790565b918201910190612be3565b5f8080612c0c565b90600160401b8111612c665781612c5b612c649361078c565b90828155612c02565b565b6108bd565b5f612c7591612c42565b565b905f03612c8957612c8790612c6b565b565b612b74565b612ca2612c9d612ca7926125a0565b610743565b610552565b90565b6001612cb69101610552565b90565b5f80fd5b5f80fd5b5f80fd5b903590600160800381360303821215612cdc570190565b612cb9565b90821015612cfb576020612cf89202810190612cc5565b90565b610778565b903590600160200381360303821215612d40570180359060018060401b038211612d3b57602001916001820236038313612d3657565b612cc1565b612cbd565b612cb9565b91565b5090565b5f7f4e616d6520746f6f206c6f6e6700000000000000000000000000000000000000910152565b612d80600d6020926109cd565b612d8981612d4c565b0190565b612da29060208101905f818303910152612d73565b90565b15612dac57565b612db46103a2565b62461bcd60e51b815280612dca60048201612d8d565b0390fd5b35612dd8816106f3565b90565b5f7f496e76616c696420626f756e6473000000000000000000000000000000000000910152565b612e0f600e6020926109cd565b612e1881612ddb565b0190565b612e319060208101905f818303910152612e02565b90565b15612e3b57565b612e436103a2565b62461bcd60e51b815280612e5960048201612e1c565b0390fd5b90565b5f5260205f2090565b5490565b612e7681612e69565b821015612e9057612e88600491612e60565b910201905f90565b610778565b5090565b9190601f8111612ea9575b505050565b612eb5612eda93610811565b906020612ec184612a0b565b83019310612ee2575b612ed390612a0b565b01906129a9565b5f8080612ea4565b9150612ed381929050612eca565b91612efb9082612e95565b9060018060401b038211612fb857612f1d82612f1785546107de565b85612e99565b5f90601f8311600114612f5057918091612f3f935f92612f44575b50506129dd565b90555b565b90915001355f80612f38565b601f19831691612f5f85610811565b925f5b818110612fa057509160029391856001969410612f86575b50505002019055612f42565b612f96910135601f8416906129c8565b90555f8080612f7a565b91936020600181928787013581550195019201612f62565b6108bd565b90612fc89291612ef0565b565b90612fd65f199161264d565b9181191691161790565b90612ff5612ff0612ffc92612954565b612970565b8254612fca565b9055565b3561300a81611ee1565b90565b9061301960ff9161264d565b9181191691161790565b61302c906104c0565b90565b90565b9061304761304261304e92613023565b61302f565b825461300d565b9055565b906130b0606060036130b6946130765f82016130705f880188612d00565b91612fbd565b61308f6001820161308960208801612dce565b90612fe0565b6130a8600282016130a260408801612dce565b90612fe0565b019201613000565b90613032565b565b91906130c9576130c791613052565b565b612b74565b90815491600160401b8310156130f957826130f19160016130f795018155612e6d565b906130b8565b565b6108bd565b929190926131313361312b61312561312061311b600787906113b3565b612593565b6103ed565b916103ed565b1461280b565b61315f61313f858490612834565b61315861315261314d611559565b610552565b91610552565b1115612891565b6131745f61316f60088490610762565b612c77565b61317d5f612c8e565b5b8061319b613195613190888790612834565b610552565b91610552565b101561326e57613269906131f26131d26131cc6131c66131bd8a898791612ce1565b5f810190612d00565b90612d45565b90612d48565b6131eb6131e56131e0611903565b610552565b91610552565b1115612da5565b61323b61320c604061320689888691612ce1565b01612dce565b61323461322e61322960206132238c8b8991612ce1565b01612dce565b610552565b91610552565b1015612e34565b61326461325261324d60088690610762565b612e5d565b61325e88878591612ce1565b906130ce565b612caa565b61317e565b5050509050565b5f7f5a65726f20616464726573730000000000000000000000000000000000000000910152565b6132a9600c6020926109cd565b6132b281613275565b0190565b6132cb9060208101905f81830391015261329c565b90565b156132d557565b6132dd6103a2565b62461bcd60e51b8152806132f3600482016132b6565b0390fd5b9061330190610746565b5f5260205260405f2090565b90565b61331990610ef1565b90565b6133259061091a565b90565b919061333e61333961334693613310565b61331c565b90835461292f565b9055565b5f90565b6133609161335a61334a565b91613328565b565b5f60026133819261337583808301612995565b8260018201550161334e565b565b905f036133955761339390613362565b565b612b74565b60481b90565b906133af60ff60481b9161339a565b9181191691161790565b6133c290611147565b90565b90565b906133dd6133d86133e4926133b9565b6133c5565b82546133a0565b9055565b6134243361341e6134187f00000000000000000000000000000000000000000000000000000000000000006103ed565b916103ed565b14612556565b6134498261344261343c6134375f6125bf565b6103ed565b916103ed565b14156132ce565b61346f61346a61346361345e600685906132f7565b61330d565b84906164aa565b612624565b61348e5f61348961348260038590610fb8565b8590611002565b613383565b6134b1600260016134ab6134a460038690610fb8565b8690611002565b016133c8565b906134e56134df7f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b93610746565b91610ff6565b916134ee6103a2565b806134f881610449565b0390a3565b61350e906135096164e4565b613510565b565b61351b90600b612670565b565b613526906134fd565b565b5f7f4e6f742072656769737465726564206f70657261746f72000000000000000000910152565b61355c60176020926109cd565b61356581613528565b0190565b61357e9060208101905f81830391015261354f565b90565b1561358857565b6135906103a2565b62461bcd60e51b8152806135a660048201613569565b0390fd5b906135df979695949392916135da6135d56135ce6135c98460066132f7565b61330d565b3390616532565b613581565b61381e565b565b6135f56135f06135fa926103b4565b610743565b610552565b90565b61361161360c61361692610552565b610743565b6103b4565b90565b91602061363a92949361363360408201965f830190610c13565b0190610c13565b565b61364b61365191939293610552565b92610552565b820391821161365c57565b6128ba565b60018060401b03811161367d576136796020916108b3565b0190565b6108bd565b9092919261369761369282613661565b6116a8565b938185526020850190828401116136b3576136b192611705565b565b6116e0565b6136c3913691613682565b90565b60200190565b5190565b949290979695939160e08601985f87016136e991610ef4565b602086016136f691610cae565b6040850161370391610c13565b6060840161371091610c13565b6080830161371d91611117565b60a0820161372a91610ef4565b60c00161373691610c13565b565b5f61190160f01b910152565b61375060028092611d0f565b61375981613738565b0190565b90565b61376c61377191610ef1565b61375d565b9052565b602080939261379061378961379894613744565b8092613760565b018092613760565b0190565b5f7f496e76616c6964207369676e6174757265000000000000000000000000000000910152565b6137d060116020926109cd565b6137d98161379c565b0190565b6137f29060208101905f8183039101526137c3565b90565b156137fc57565b6138046103a2565b62461bcd60e51b81528061381a600482016137dd565b0390fd5b9192939497969095978061383a61383442610552565b916135e1565b116139a2576138524261384c836135e1565b9061363c565b61386b613865613860610d05565b6135e1565b91610552565b1161397a57613978979861394f61396d93856138d98a6138ca8d613955988d8d6138a1613896612461565b9633999592936136b8565b6138b36138ad826136cc565b916136c6565b2092936138be6103a2565b988997602089016136d0565b602082018103825203826108d1565b6138eb6138e5826136cc565b916136c6565b206139367f000000000000000000000000000000000000000000000000000000000000000061392761391b6103a2565b93849260208401613775565b602082018103825203826108d1565b613948613942826136cc565b916136c6565b20926136b8565b9061656c565b613967613961336103ed565b916103ed565b146137f5565b9333919293946166e9565b565b613983426135fd565b9061399e5f9283926318355b7560e21b845260048401613619565b0390fd5b6139ab426135fd565b906139c65f9283926357ea02e960e01b845260048401613619565b0390fd5b906139da979695949392916135aa565b565b606090565b90602082820312613a0f575f82013560018060401b038111613a0a57613a07920161182d565b90565b6103b0565b6103ac565b90613a2b91613a216139dc565b50908101906139e1565b90565b613a4d613a48613a5292613a40612784565b5060056132f7565b61330d565b616afb565b90565b606090565b60018060401b038111613a705760208091020190565b6108bd565b90613a87613a8283613a5a565b6116a8565b918252565b369037565b90613ab6613a9e83613a75565b92602080613aac8693613a5a565b9201910390613a8c565b565b90613ac282611228565b811015613ad3576020809102010190565b610778565b90613ae2906103ed565b9052565b90613aef613a55565b50613b0c613b07613b02600485906132f7565b61330d565b616afb565b91613b1683613a91565b91613b205f612c8e565b5b80613b34613b2e87610552565b91610552565b1015613b7b57613b7690613b71613b5f613b58613b53600488906132f7565b61330d565b8390616b4a565b613b6c8791849092613ab8565b613ad8565b612caa565b613b21565b5092505090565b5f90565b90613b8f613b82565b50613bb16001613bab613ba460038690610fb8565b8490611002565b01611091565b613bc3613bbd5f611147565b91611147565b14918215613bd1575b505090565b613bf29250600191613be7613bec926003610fb8565b611002565b01611091565b613c05613bff6001611147565b91611147565b145f80613bcc565b613c3390613c19613a55565b505f90613c2d613c2761131b565b92612c8e565b90614979565b5090565b90613c6994939291613c64613c5f613c58613c538460066132f7565b61330d565b3390616532565b613581565b613c6b565b565b91613c7d9492939133919293946166e9565b565b90613c8c94939291613c37565b565b90613cae613ca9613cb393613ca1613b82565b5060066132f7565b61330d565b616532565b90565b5f90565b613cdc613ce292613cd7600193613ccf613cb6565b506003610fb8565b611002565b01611091565b90565b613cee90610fea565b90565b5f7f496e7465726e616c206f6e6c7900000000000000000000000000000000000000910152565b613d25600d6020926109cd565b613d2e81613cf1565b0190565b613d479060208101905f818303910152613d18565b90565b15613d5157565b613d596103a2565b62461bcd60e51b815280613d6f60048201613d32565b0390fd5b60018060401b038111613d895760208091020190565b6108bd565b90613da0613d9b83613d73565b6116a8565b918252565b369037565b90613dcf613db783613d8e565b92602080613dc58693613d73565b9201910390613da5565b565b90613ddb82610d87565b811015613dec576020809102010190565b610778565b90565b5190565b90613e0282613df4565b811015613e13576020809102010190565b610778565b90613e2290610ef1565b9052565b606090565b90565b60209181520190565b905f9291805490613e51613e4a836107de565b8094613e2e565b916001811690815f14613ea85750600114613e6c575b505050565b613e799192939450610799565b915f925b818410613e9057505001905f8080613e67565b60018160209295939554848601520191019290613e7d565b92949550505060ff19168252151560200201905f8080613e67565b90613ecd91613e37565b90565b90613ef0613ee992613ee06103a2565b93848092613ec3565b03836108d1565b565b613efb90613ed0565b90565b613f089051610ef1565b90565b613f159051610552565b90565b5f7f56616c7565206f7574206f6620626f756e647300000000000000000000000000910152565b613f4c60136020926109cd565b613f5581613f18565b0190565b613f71613f7f9260408301908382035f8501526109e1565b906020818303910152613f3f565b90565b92916020613f9e613fa69360408701908782035f8901526109e1565b940190610555565b565b905f9291805490613fc2613fbb836107de565b80946109cd565b916001811690815f146140195750600114613fdd575b505050565b613fea9192939450610811565b915f925b81841061400157505001905f8080613fd8565b60018160209295939554848601520191019290613fee565b92949550505060ff19168252151560200201905f8080613fd8565b5f7f5265717569726564206d6574726963206d697373696e67000000000000000000910152565b61406860176020926109cd565b61407181614034565b0190565b61408d61409b9260408301908382035f850152613fa8565b90602081830391015261405b565b90565b929390936140c6336140c06140ba6140b530613ce5565b6103ed565b916103ed565b14613d4a565b6140da6140d560088690610762565b612e5d565b946140e482613daa565b946140ee5f612c8e565b5b806141026140fc86610552565b91610552565b1015614155576141509061414b6141265f61411e8a8590613dd1565b510151613df1565b614138614132826136cc565b916136c6565b206141468a91849092613df8565b613e18565b612caa565b6140ef565b50919490929561416481612e69565b6141766141705f612c8e565b91610552565b1196614180613e26565b9088614600575b6141905f612c8e565b5b806141a461419e8b610552565b91610552565b10156144635760015f8b614297575b50908887896141c9946141ce575b505050612caa565b614191565b825f61420c614204614215946141ff6141f760206141f061421a9b8d90613dd1565b5101613f0b565b976009611ce3565b611cf9565b928790613dd1565b51015190611d8a565b612fe0565b88878990614244602061423d5f614232878990613dd1565b510151958790613dd1565b5101613f0b565b6142776142717f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd93610746565b93610ff6565b9361428c6142836103a2565b92839283613f82565b0390a38887896141c1565b9a90959291996142a65f612c8e565b5b806142c26142bc6142b78a612e69565b610552565b91610552565b101561444d576142da6142d58d87613df8565b613efe565b6142fe6142f86142f36142ee8a8690613df8565b613efe565b610ef1565b91610ef1565b146143115761430c90612caa565b6142a7565b8a919b929c50896141c99495988a926001908a61433b6020614334898b90613dd1565b5101613f0b565b61436361435d6143586001614351868890612e6d565b5001610936565b610552565b91610552565b109188888415614403575b50505050614398575b614382905b156104c0565b614391575b93945050506141b3565b505f614387565b905082825f6143a8878990613dd1565b510151916143f46143e26143dc7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad631593610746565b93610ff6565b936143eb6103a2565b91829182613f59565b0390a36143825f919050614377565b61444393945061443161443d9361442b602061442461443896600296613dd1565b5101613f0b565b96612e6d565b5001610936565b610552565b91610552565b118a5f888861436e565b5099909a87896141c99495986143828d9461437c565b5097505092935093506144755f612c8e565b935b8461449261448c61448786612e69565b610552565b91610552565b10156145f9576144b86144b260036144ab868990612e6d565b500161095d565b156104c0565b6145ee576144da6144d55f6144ce868990612e6d565b5001613e2b565b613ef2565b6144ec6144e6826136cc565b916136c6565b20905f966144f95f612c8e565b5b8061451561450f61450a86613df4565b610552565b91610552565b10156145dc5761452e614529848390613df8565b613efe565b61454061453a86610ef1565b91610ef1565b146145535761454e90612caa565b6144fa565b5095909650614574915061456960015b156104c0565b61457b575b5b612caa565b9394614477565b82855f614589878590612e6d565b5001916145d46145c26145bc7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad631593610746565b93610ff6565b936145cb6103a2565b91829182614075565b0390a361456e565b50959096614574925061456990614563565b94936145749061456f565b5050505050565b9693905061461a614615839794999693612e69565b613daa565b976146245f612c8e565b5b8061464061463a6146358b612e69565b610552565b91610552565b101561469a576146959061469061466b6146665f61465f8d8690612e6d565b5001613e2b565b613ef2565b61467d614677826136cc565b916136c6565b2061468b8d91849092613df8565b613e18565b612caa565b614625565b509295919497909396614187565b6146b06164e4565b6146b86146ba565b565b6146cb6146c65f6125bf565b616be2565b565b6146d56146a8565b565b6146e160a06116a8565b90565b5f90565b5f90565b5f90565b6146f86146d7565b90602080808080866147086146e4565b815201614713612726565b81520161471e61272a565b8152016147296146e8565b8152016147346146ec565b81525050565b6147426146f0565b90565b9061474f90610552565b9052565b9061475d906103b4565b9052565b9061476b906104ad565b9052565b9061477990611147565b9052565b906147fc6147f3600261478e6146d7565b946147a561479d5f8301610936565b5f8801614745565b6147bd6147b460018301611037565b60208801614753565b6147d56147cc60018301611064565b60408801614761565b6147ed6147e460018301611091565b6060880161476f565b016110b5565b60808401613e18565b565b6148079061477d565b90565b61482f9161482561482a9261481d61473a565b506003610fb8565b611002565b6147fe565b90565b5f90565b9061484090610746565b5f5260205260405f2090565b9061485690610ff6565b5f5260205260405f2090565b6148879161487d61488292614875614832565b50600c614836565b61484c565b611037565b90565b614892616bf8565b61489a615e52565b6148ac6148a6836103ed565b916103ed565b036148bc576148ba90616be2565b565b6148d7905f91829163118cdaa760e01b835260048301610cbb565b0390fd5b6148fa6148f56148ff926148ed612784565b5060046132f7565b61330d565b616afb565b90565b61490c90516104ad565b90565b61492361491e614928926125a0565b610743565b6104ad565b90565b61493590516103b4565b90565b61494c614947614951926104ad565b610743565b610552565b90565b61496361496991939293610552565b92610552565b820180921161497457565b6128ba565b90929192614985613a55565b5061498e612784565b50614998826163cc565b936149b56149b06149ab600586906132f7565b61330d565b616afb565b926149c260208701614902565b6149d46149ce5f61490f565b916104ad565b148015614ac6575b8015614aab575b614a9157614a1d86614a17614a126020614a0b614a065f614a7a9b9c9d0161492b565b6135e1565b9301614902565b614938565b906128ce565b9180614a38614a32614a2d61131b565b610552565b91610552565b115f14614a8c5750614a4861131b565b5b614a54848290614954565b614a66614a6088610552565b91610552565b115f14614a7d5750845b9092909192616c2e565b91565b614a879084614954565b614a70565b614a49565b5050509150614aa7614aa25f612c8e565b613a91565b9190565b5082614abf614ab986610552565b91610552565b10156149e3565b5083614ada614ad45f612c8e565b91610552565b146149dc565b614af190614aec6164e4565b614af3565b565b614afe90600a612670565b565b614b0990614ae0565b565b5f90565b614b17614b0b565b50614b215f612593565b90565b5090565b9190811015614b38576020020190565b610778565b35614b47816103f9565b90565b5f80fd5b60e01b90565b5f910312614b5e57565b6103ac565b916020614b84929493614b7d60408201965f830190610c13565b0190610cae565b565b614b8e6103a2565b3d5f823e3d90fd5b90929192614ba35f612c8e565b5b80614bc1614bbb614bb6858990614b24565b610552565b91610552565b1015614c7057614bd030613ce5565b9063ba1fb10384614beb614be6868a8691614b28565b614b3d565b93803b15614c6b57614c105f8094614c1b614c046103a2565b98899687958694614b4e565b845260048401614b63565b03925af1918215614c6657614c3592614c3a575b50612caa565b614ba4565b614c59905f3d8111614c5f575b614c5181836108d1565b810190614b54565b5f614c2f565b503d614c47565b614b86565b614b4a565b5050509050565b5f7f4e6f7420736c617368696e67206f7261636c6500000000000000000000000000910152565b614cab60136020926109cd565b614cb481614c77565b0190565b614ccd9060208101905f818303910152614c9e565b90565b15614cd757565b614cdf6103a2565b62461bcd60e51b815280614cf560048201614cb8565b0390fd5b5f7f4f70657261746f7220756e6b6e6f776e00000000000000000000000000000000910152565b614d2d60106020926109cd565b614d3681614cf9565b0190565b614d4f9060208101905f818303910152614d20565b90565b15614d5957565b614d616103a2565b62461bcd60e51b815280614d7760048201614d3a565b0390fd5b90565b90614d8f60018060401b039161264d565b9181191691161790565b90565b90614db1614dac614db892610746565b614d99565b8254614d7e565b9055565b9190614dd681614dcf81614ddb956109cd565b8095611705565b6108b3565b0190565b9091614df69260208301925f818503910152614dbc565b90565b614e1e33614e18614e12614e0d600a612593565b6103ed565b916103ed565b14614cd0565b614e44614e3f614e38614e33600585906132f7565b61330d565b8490616532565b614d52565b614e70614e65614e60614e5960038590610fb8565b8590611002565b614d7b565b6001600391016133c8565b614e8e614e87614e82600484906132f7565b61330d565b8390616d4a565b50614eb6614e9b426135fd565b614eb1614eaa600c8590614836565b859061484c565b614d9c565b909192614eec614ee67f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c79193610746565b93610ff6565b93614f01614ef86103a2565b92839283614ddf565b0390a3565b614f1060806116a8565b90565b614f1e913691611710565b90565b52565b90614f2e906104c0565b9052565b5190565b90614f40816109c9565b9060018060401b038211614ffe57614f6282614f5c85546107de565b85612e99565b602090601f8311600114614f9657918091614f85935f92614f8a575b50506129dd565b90555b565b90915001515f80614f7e565b601f19831691614fa585610811565b925f5b818110614fe657509160029391856001969410614fcc575b50505002019055614f88565b614fdc910151601f8416906129c8565b90555f8080614fc0565b91936020600181928787015181550195019201614fa8565b6108bd565b9061500d91614f36565b565b61501990516104c0565b90565b906150796060600361507f9461503f5f82016150395f8801614f32565b90615003565b6150586001820161505260208801613f0b565b90612fe0565b6150716002820161506b60408801613f0b565b90612fe0565b01920161500f565b90613032565b565b9190615092576150909161501c565b565b612b74565b90815491600160401b8310156150c257826150ba9160016150c095018155612e6d565b90615081565b565b6108bd565b6151e5956151ce84966151c56151bd6151a96151a46151d79761514a61512a6151246151e09d8d9f9d61511f3361511961511361510e61510960078c906113b3565b612593565b6103ed565b916103ed565b1461280b565b612d45565b90612d48565b61514361513d615138611903565b610552565b91610552565b1115612da5565b6151678661516061515a8d610552565b91610552565b1015612e34565b61519d61517e61517960088490610762565b61078c565b61519761519161518c611559565b610552565b91610552565b10612891565b6008610762565b612e5d565b9899969294966151b7614f06565b9a614f13565b5f8a01614f21565b60208801614745565b60408601614745565b60608401614f24565b615097565b565b6152159061521061520b6152046151ff8460066132f7565b61330d565b3390616532565b613581565b6152f1565b565b5f7f43616e6e6f7420676f206f6e6c696e65207768696c6520736c61736865640000910152565b61524b601e6020926109cd565b61525481615217565b0190565b61526d9060208101905f81830391015261523e565b90565b60401b90565b9061528560ff60401b91615270565b9181191691161790565b6152a361529e6152a8926104ad565b610743565b6104ad565b90565b90565b906152c36152be6152ca9261528f565b6152ab565b8254615276565b9055565b9160206152ef9294936152e860408201965f83019061115f565b019061115f565b565b61530f61530a61530360038490610fb8565b3390611002565b614d7b565b9061531c60018301611091565b918261533161532b6003611147565b91611147565b1461545557826153496153435f611147565b91611147565b14801561543a575b615435576153789061536660018083016133c8565b60016153715f61490f565b91016152ae565b61539661538f61538a600484906132f7565b61330d565b33906164aa565b5080336153cc6153c67fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c93610746565b91610ff6565b916153d56103a2565b806153df81610449565b0390a390339091600161541b6154157f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a0993610746565b93610ff6565b936154306154276103a2565b928392836152ce565b0390a3565b505050565b508261544f6154496001611147565b91611147565b14615351565b61545d6103a2565b62461bcd60e51b81528061547360048201615258565b0390fd5b615480906151e7565b565b5f7f4e6f7420617574686f72697a6564000000000000000000000000000000000000910152565b6154b6600e6020926109cd565b6154bf81615482565b0190565b6154d89060208101905f8183039101526154a9565b90565b156154e257565b6154ea6103a2565b62461bcd60e51b815280615500600482016154c3565b0390fd5b90565b61551b61551661552092615504565b610743565b6103b4565b90565b5f7f496e74657276616c20746f6f2073686f72740000000000000000000000000000910152565b61555760126020926109cd565b61556081615523565b0190565b6155799060208101905f81830391015261554a565b90565b1561558357565b61558b6103a2565b62461bcd60e51b8152806155a160048201615564565b0390fd5b90565b6155bc6155b76155c1926155a5565b610743565b6104ad565b90565b5f7f4d6178206d6973736564206d757374206265203e3d2031000000000000000000910152565b6155f860176020926109cd565b615601816155c4565b0190565b61561a9060208101905f8183039101526155eb565b90565b1561562457565b61562c6103a2565b62461bcd60e51b81528061564260048201615605565b0390fd5b61565060606116a8565b90565b9061566861566361566f92613023565b61302f565b82546133a0565b9055565b906156b560405f6156bb9461569582820161568f84880161492b565b90614d9c565b6156ad8282016156a760208801614902565b906152ae565b01920161500f565b90615653565b565b906156c791615673565b565b9160206156ea9294936156e360408201965f830190610c13565b0190611117565b565b3361571f6157197f00000000000000000000000000000000000000000000000000000000000000006103ed565b916103ed565b14801561580b575b615730906154db565b61574e82615747615741603c615507565b916103b4565b101561557c565b61576c8361576561575f60016155a8565b916104ad565b101561561d565b6157c5826157b4856157ab61578d5f6157876002899061225d565b01612287565b916157a2615799615646565b955f8701614753565b60208501614761565b60408301614f24565b6157c06002849061225d565b6156bd565b90916157f17fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea56492610746565b926158066157fd6103a2565b928392836156c9565b0390a2565b506157303361583561582f61582a615825600787906113b3565b612593565b6103ed565b916103ed565b149050615727565b634e487b7160e01b5f52601260045260245ffd5b61585d61586391610552565b91610552565b90811561586e570490565b61583d565b61588761588261588c92610552565b610743565b6104ad565b90565b6158a361589e6158a8926125a0565b610743565b6103b4565b90565b6158c96158c46158bd60038490610fb8565b8490611002565b614d7b565b906158d3816163cc565b6158df60018401611091565b6158f26158ec6003611147565b91611147565b14615b06576159025f8401610936565b61591461590e5f612c8e565b91610552565b14615b005761594a6159314261592b5f8701610936565b9061363c565b61594461593f5f850161492b565b6135e1565b90615851565b8061595e61595860ff614938565b91610552565b115f14615af2575060ff5b908161598861598261597d60018801611064565b6104ad565b916104ad565b11615995575b5050505050565b6159a282600186016152ae565b6159b76159ae5f61588f565b60018601614d9c565b6159d56159cf6159ca6020859401614902565b6104ad565b916104ad565b101580615acb575b6159e8575b8061598e565b615a036159f760018501611091565b936001600291016133c8565b615a21615a1a615a15600485906132f7565b61330d565b8590616d4a565b508190849091615a6f615a5d615a577f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d93610746565b93610ff6565b93615a666103a2565b91829182611613565b0390a39190916002615aaa615aa47f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a0993610746565b93610ff6565b93615abf615ab66103a2565b928392836152ce565b0390a35f8080806159e2565b50615ad860018401611091565b615aeb615ae56002611147565b91611147565b14156159dd565b615afb90615873565b615969565b50505050565b50505050565b606090565b60018060401b038111615b275760208091020190565b6108bd565b90615b3e615b3983615b11565b6116a8565b918252565b615b4d60806116a8565b90565b90615bb7615bae6003615b61615b43565b94615b78615b705f83016108f8565b5f8801614f21565b615b90615b8760018301610936565b60208801614745565b615ba8615b9f60028301610936565b60408801614745565b0161095d565b60608401614f24565b565b615bc290615b50565b90565b90615bcf8261078c565b615bd881615b2c565b92615be66020850191610790565b5f915b838310615bf65750505050565b60046020600192615c0685615bb9565b815201920192019190615be9565b615c1d90615bc5565b90565b615c37615c3c91615c2f615b0c565b506008610762565b615c14565b90565b615c6d90615c68615c63615c5c615c578460066132f7565b61330d565b3390616532565b613581565b615cc8565b565b5f7f43616e6e6f7420676f206f66666c696e65207768696c6520736c617368656400910152565b615ca3601f6020926109cd565b615cac81615c6f565b0190565b615cc59060208101905f818303910152615c96565b90565b615ce6615ce1615cda60038490610fb8565b3390611002565b614d7b565b90615cf360018301611091565b9182615d08615d026003611147565b91611147565b14615d8e57615d1c906001600491016133c8565b615d3a615d33615d2e600484906132f7565b61330d565b3390616d4a565b50903390916004615d74615d6e7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a0993610746565b93610ff6565b93615d89615d806103a2565b928392836152ce565b0390a3565b615d966103a2565b62461bcd60e51b815280615dac60048201615cb0565b0390fd5b615db990615c3f565b565b909182615dcb81615dd293611d0f565b8093611705565b0190565b615de79060209493615dee93615dbb565b8092611d40565b0190565b9091615e0990615e006103a2565b93849384615dd6565b03902090565b9091615e1a92615df2565b90565b92615e42615e4a9392615e3d615e4f96615e35612784565b506009611ce3565b611cf9565b919091615e0f565b610936565b90565b615e5a614b0b565b50615e656001612593565b90565b615e729051611147565b90565b90565b615e8c615e87615e9192615e75565b610743565b610552565b90565b60207f6c00000000000000000000000000000000000000000000000000000000000000917f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76615f8201520152565b615eee60216040926109cd565b615ef781615e94565b0190565b615f109060208101905f818303910152615ee1565b90565b15615f1a57565b615f226103a2565b62461bcd60e51b815280615f3860048201615efb565b0390fd5b90615fed615fe8615ff29333615f6d615f67615f62615f5d600786906113b3565b612593565b6103ed565b916103ed565b1480156160ab575b615f7e906154db565b615f9c615f97615f9060038490610fb8565b8690611002565b6147fe565b615fa860608201615e68565b615fbb615fb56003611147565b91611147565b03615ff5575b50615fe0615fd9615fd4600584906132f7565b61330d565b8590616d4a565b5060046132f7565b61330d565b616d4a565b50565b61607190616045616035616008856163cc565b61602f61602a602061602361601e5f860161492b565b6135e1565b9301614902565b614938565b906128ce565b61603f600a615e78565b906128ce565b6160505f8301613f0b565b61606261605c5f612c8e565b91610552565b119182616077575b5050615f13565b5f615fc1565b6160a291925061609661609c916160905f429201613f0b565b9061363c565b92610552565b91610552565b10155f8061606a565b50615f7e336160c96160c36160be614b0f565b6103ed565b916103ed565b149050615f75565b906160fb616100916160e1613b82565b506160f66160ee856163cc565b946003610fb8565b611002565b6147fe565b61610b5f8201613f0b565b61611d6161175f612c8e565b91610552565b146161585761614e6161495f6161426161549461613c83429201613f0b565b9061363c565b940161492b565b6135e1565b91610552565b1090565b50505f90565b61616f9061616a6164e4565b616171565b565b61617c816001612670565b616184614b0f565b906161b86161b27f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e2270093610ff6565b91610ff6565b916161c16103a2565b806161cb81610449565b0390a3565b6161d99061615e565b565b5f61621a616220936162123361620c6162066162016161fc60078a906113b3565b612593565b6103ed565b916103ed565b1461280b565b92600261225d565b01615653565b565b5f7f4e6f742072656769737465726564000000000000000000000000000000000000910152565b616256600e6020926109cd565b61625f81616222565b0190565b6162789060208101905f818303910152616249565b90565b1561628257565b61628a6103a2565b62461bcd60e51b8152806162a060048201616263565b0390fd5b6162e0336162da6162d47f00000000000000000000000000000000000000000000000000000000000000006103ed565b916103ed565b14612556565b6163066163016162fa6162f5600685906132f7565b61330d565b8490616d4a565b61627b565b61632461631d616318600484906132f7565b61330d565b8390616d4a565b50906163596163537f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e93610746565b91610ff6565b916163626103a2565b8061636c81610449565b0390a3565b906163be6163b55f616381612719565b94616398616390838301611037565b838801614753565b6163af6163a6838301611064565b60208801614761565b01612287565b60408401614f24565b565b6163c990616371565b90565b6163e36163e8916163db612764565b50600261225d565b6163c0565b6163f35f820161492b565b6164056163ff5f61588f565b916103b4565b1461644b575b61641760208201614902565b6164296164235f61490f565b916104ad565b14616432575b90565b61644661643d6115fb565b60208301614761565b61642f565b61645e616456610bfa565b5f8301614753565b61640b565b61646c90610fce565b90565b61648361647e616488926103e2565b610743565b610552565b90565b61649f61649a6164a492610552565b61264d565b610ef1565b90565b90565b906164dc6164d66164d16164cc5f6164e1966164c4613b82565b500194616463565b61646f565b61648b565b916164a7565b616e06565b90565b6164ec614b0f565b6165056164ff6164fa616bf8565b6103ed565b916103ed565b0361650c57565b61652e616517616bf8565b5f91829163118cdaa760e01b835260048301610cbb565b0390fd5b9061656461655e6165596165545f6165699661654c613b82565b500194616463565b61646f565b61648b565b916164a7565b616e69565b90565b61658b916165829161657c614b0b565b50616ec5565b90929192616f85565b90565b5f7f4f70657261746f7220697320736c617368656400000000000000000000000000910152565b6165c260136020926109cd565b6165cb8161658e565b0190565b6165e49060208101905f8183039101526165b5565b90565b156165ee57565b6165f66103a2565b62461bcd60e51b81528061660c600482016165cf565b0390fd5b9061662561662061662c92613310565b61331c565b8254612fca565b9055565b616639906103b4565b60018060401b03811461664c5760010190565b6128ba565b90565b61666861666361666d92616651565b610743565b6104ad565b90565b91602061669192949361668a60408201965f830190611117565b0190610555565b565b61669c90610fce565b90565b6166a890616693565b90565b6166b490610fea565b90565b6040906166e06166e794969593966166d660608401985f850190610cae565b6020830190610c13565b0190610c13565b565b949293919361670c61670761670060038990610fb8565b8790611002565b614d7b565b93616716876163cc565b9361674061672660018801611091565b6167396167336003611147565b91611147565b14156165e7565b61675e61675761675260058b906132f7565b61330d565b88906164aa565b50616833604061677060018901611091565b9661677d425f8b01612fe0565b6167a761678b8587906136b8565b61679d616797826136cc565b916136c6565b2060028b01616610565b6167bc6167b35f61490f565b60018b016152ae565b6167da60018a016167d46167cf82611037565b616630565b90614d9c565b6167e2613cb6565b50856167f66167f05f61490f565b916104ad565b145f14616ab75761680d5f995b60018b91016133c8565b8761682161681b6002611147565b91611147565b1480616a9b575b616a2d575b0161500f565b80616a09575b6169f3575b505085918591924261688261687c6168767f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b994610746565b94610746565b94610ff6565b9461689761688e6103a2565b92839283616670565b0390a4806168ad6168a784611147565b91611147565b0361699d575b50506168bf600b612593565b6168d96168d36168ce5f6125bf565b6103ed565b916103ed565b036168e3575b5050565b6168fd6168f86168f3600b612593565b61669f565b6166ab565b9163d47853b691909261690f426135fd565b92813b15616998575f6169359161694082966169296103a2565b98899788968795614b4e565b8552600485016166b7565b03925af1908161696c575b50155f14616967576001616962575b5b5f806168df565b61695a565b61695b565b61698b905f3d8111616991575b61698381836108d1565b810190614b54565b5f61694b565b503d616979565b614b4a565b838391926169d46169ce7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a0993610746565b93610ff6565b936169e96169e06103a2565b928392836152ce565b0390a35f806168b3565b616a029188918890919261743a565b5f8061683e565b50616a15818390612d48565b616a27616a215f612c8e565b91610552565b11616839565b616a4a616a43616a3e8d60046132f7565b61330d565b8b906164aa565b508a8a616a80616a7a7fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c93610746565b91610ff6565b91616a896103a2565b80616a9381610449565b0390a361682d565b5088616ab0616aaa6002611147565b91611147565b1415616828565b85616acb616ac56064616654565b916104ad565b105f14616ade5761680d6001995b616803565b61680d600199616af68d8d8b908b908a928c946170f4565b616ad9565b616b125f616b1792616b0b612784565b50016164a7565b6175f8565b90565b616b26616b2b9161091a565b612954565b90565b616b42616b3d616b4792610552565b610743565b6103e2565b90565b616b75616b70616b7f93616b6b5f616b7a95616b64614b0b565b50016164a7565b617666565b616b1a565b616b2e565b610fea565b90565b91906008616ba2910291616b9c60018060a01b038461292b565b9261292b565b9181191691161790565b9190616bc2616bbd616bca93610ff6565b61266d565b908354616b82565b9055565b616be091616bda614b0b565b91616bac565b565b616bf690616bf15f6001616bce565b617687565b565b616c00614b0b565b503390565b616c0e90610552565b5f198114616c1c5760010190565b6128ba565b616c2b90516103ed565b90565b93919293616c3a613a55565b50616c4e616c4985849061363c565b613a91565b92616c585f612c8e565b925b80616c6d616c6788610552565b91610552565b1015616cdb57616c91616c8a616c85600586906132f7565b61330d565b8290616b4a565b616c9d84828a916176e6565b616cb1575b50616cac90612caa565b616c5a565b616cac9194616ccf616cd492616cca8991849092613ab8565b613ad8565b616c05565b9390616ca2565b509450509150616cea82613a91565b92616cf45f612c8e565b5b80616d08616d0286610552565b91610552565b1015616d4457616d3f90616d3a616d28616d23868490613ab8565b616c21565b616d358891849092613ab8565b613ad8565b612caa565b616cf5565b50915050565b90616d7c616d76616d71616d6c5f616d8196616d64613b82565b500194616463565b61646f565b61648b565b916164a7565b61781e565b90565b90565b5f5260205f2090565b5490565b616d9d81616d90565b821015616db757616daf600191616d87565b910201905f90565b610778565b90815491600160401b831015616de75782616ddf916001616de595018155616d94565b90613328565b565b6108bd565b5490565b90616dfa90613310565b5f5260205260405f2090565b616e0e613b82565b50616e23616e1d828490616e69565b156104c0565b5f14616e6357616e59616e5e92616e45616e3e5f8501616d84565b8290616dbc565b6001616e525f8501616dec565b9301616df0565b612fe0565b600190565b50505f90565b616e87916001616e8292616e7b613b82565b5001616df0565b610936565b616e99616e935f612c8e565b91610552565b141590565b5f90565b90565b616eb9616eb4616ebe92616ea2565b610743565b610552565b90565b5f90565b919091616ed0614b0b565b50616ed9616e9e565b50616ee261334a565b50616eec836136cc565b616eff616ef96041616ea5565b91610552565b145f14616f4657616f3f9192616f1361334a565b50616f1c61334a565b50616f25616ec1565b506020810151606060408301519201515f1a90919261799d565b9192909190565b50616f505f6125bf565b90616f64616f5f6002946136cc565b61648b565b91929190565b60041115616f7457565b611124565b90616f8382616f6a565b565b80616f98616f925f616f79565b91616f79565b145f14616fa3575050565b80616fb7616fb16001616f79565b91616f79565b145f14616fda575f63f645eedf60e01b815280616fd660048201610449565b0390fd5b80616fee616fe86002616f79565b91616f79565b145f1461701c5761701861700183616b1a565b5f91829163fce698f760e01b835260048301610562565b0390fd5b61702f6170296003616f79565b91616f79565b146170375750565b617052905f9182916335e2f38360e21b835260048301610f01565b0390fd5b61706a61706561706f926112fc565b610743565b6104ad565b90565b61707e617084916103b4565b916103b4565b90039060018060401b03821161709657565b6128ba565b5f7f50726f746f636f6c2076696f6c6174696f6e207265706f727465640000000000910152565b6170cf601b6020926109cd565b6170d88161709b565b0190565b6170f19060208101905f8183039101526170c2565b90565b935050925061710c61710660c8617056565b916104ad565b1015617117575b5050565b617120426135fd565b61713e617139617132600c8590614836565b859061484c565b611037565b8061715161714b5f61588f565b916103b4565b149081156171d7575b50617166575b50617113565b61718590617180617179600c8590614836565b859061484c565b614d9c565b906171b96171b37f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c79193610746565b91610ff6565b916171c26103a2565b806171cc816170dc565b0390a35f8080617160565b6171e2915082617072565b6171fb6171f56171f0610f6a565b6103b4565b916103b4565b10155f61715a565b90565b61721a61721561721f92617203565b610743565b610552565b90565b90929192617237617232826116e4565b6116a8565b9381855260208501908284011161725357617251926109d6565b565b6116e0565b9080601f830112156172765781602061727393519101617222565b90565b6105ad565b90505190617288826106f3565b565b9190916040818403126172db576172a160406116a8565b925f8201519160018060401b0383116172d6576172c3826172cf948301617258565b5f86015260200161727b565b6020830152565b6116dc565b6116d8565b9291906172f46172ef826116bd565b6116a8565b93818552602080860192028101918383116173495781905b83821061731a575050505050565b815160018060401b03811161734457602091617339878493870161728a565b81520191019061730c565b6105ad565b6105b5565b9080601f8301121561736c57816020617369935191016172e0565b90565b6105ad565b9060208282031261739f575f82015160018060401b03811161739a57617397920161734e565b90565b6103b0565b6103ac565b60209181520190565b91906173c7816173c0816173cc956173a4565b8095611705565b6108b3565b0190565b90916173e79260208301925f8185039101526173ad565b90565b6173f4603261153d565b90565b949391606091617438946174236174309361741960808b01945f8c0190610c13565b60208a0190610cae565b8782036040890152610e18565b940190610555565b565b91617446818590612d48565b6174586174525f612c8e565b91610552565b146175f257617468818590612d48565b61747c61747661c350617206565b91610552565b116175ec575f61748a6139dc565b9461749430613ce5565b6174b66331e3bd1b9492946174c16174aa6103a2565b96879586948594614b4e565b8452600484016173d0565b03915afa80915f926175c8575b50155f146175bf575060016175ba575b6174e783610d87565b6175006174fa6174f56173ea565b610552565b91610552565b115f146175ac5761750f6173ea565b5b61751930613ce5565b906365a6936e93929490823b156175a7575f9461755486926175499461753d6103a2565b998a9889978896614b4e565b8652600486016173f7565b03925af1908161757b575b50155f14617576576001617571575b5b565b61756e565b61756f565b61759a905f3d81116175a0575b61759281836108d1565b810190614b54565b5f61755f565b503d617588565b614b4a565b6175b583610d87565b617510565b505050565b909250916174de565b6175e59192503d805f833e6175dd81836108d1565b810190617371565b905f6174ce565b50505050565b50505050565b5f61760c91617605612784565b5001616dec565b90565b5f5260205f2090565b61762181616dec565b82101561763b5761763360019161760f565b910201905f90565b610778565b6176509060086176559302610c6a565b61109e565b90565b906176639154617640565b90565b617684915f61767e9261767761334a565b5001617618565b90617658565b90565b6176905f612593565b61769a825f612670565b906176ce6176c87f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e093610ff6565b91610ff6565b916176d76103a2565b806176e181610449565b0390a3565b6176ee613b82565b50617716617710617709617704600685906132f7565b61330d565b8490616532565b156104c0565b6177b8576177369161772c617731926003610fb8565b611002565b6147fe565b6177415f8201613f0b565b61775361774d5f612c8e565b91610552565b148015617792575b61778c5761778161777b617787926177755f429201613f0b565b9061363c565b92610552565b91610552565b101590565b50505f90565b5061779f60608201615e68565b6177b26177ac6003611147565b91611147565b1461775b565b5050505f90565b6177d36177ce6177d8926155a5565b610743565b610552565b90565b634e487b7160e01b5f52603160045260245ffd5b6177f881616d90565b80156178195760019003906178166178108383616d94565b9061334e565b55565b6177db565b617826613b82565b5061783d617838600183018490616df0565b610936565b908161785161784b5f612c8e565b91610552565b14155f1461791d576178cf9260016178ca92846178785f96617872856177bf565b9061363c565b617895617886888501616dec565b61788f866177bf565b9061363c565b816178a86178a283610552565b91610552565b036178d4575b5050506178c46178bf868301616d84565b6177ef565b01616df0565b612995565b600190565b617915926179076178f36178ed617910948c8901617618565b90617658565b9361790185918c8901617618565b90613328565b91858501616df0565b612fe0565b5f80806178ae565b5050505f90565b90565b61793b61793661794092617924565b610743565b610552565b90565b61797861797f9461796e606094989795617964608086019a5f870190610ef4565b6020850190611117565b6040830190610ef4565b0190610ef4565b565b61799561799061799a926125a0565b61264d565b610ef1565b90565b9392936179a8614b0b565b506179b1616e9e565b506179ba61334a565b506179c485616b1a565b6179ec6179e66fa2a8918ca85bafe22016d0b997e4df60600160ff1b03617927565b91610552565b11617a795790617a0f602094955f94939293617a066103a2565b94859485617943565b838052039060015afa15617a7457617a275f5161264d565b80617a42617a3c617a375f6125bf565b6103ed565b916103ed565b14617a58575f91617a525f617981565b91929190565b50617a625f6125bf565b600191617a6e5f617981565b91929190565b614b86565b505050617a855f6125bf565b906003929192919056fea164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\xC0`@R4a\0eWa\0\x1Aa\0\x14a\x019V[\x90a\x02\x16V[a\0\"a\0jV[az\x9Ca\x04\xD3\x829`\x80Q\x81\x81\x81a\x0E\xCF\x01Ra8\xF1\x01R`\xA0Q\x81\x81\x81a\x14N\x01R\x81\x81a&\xA3\x01R\x81\x81a3\xF4\x01R\x81\x81aV\xF5\x01Rab\xB0\x01Raz\x9C\x90\xF3[a\0pV[`@Q\x90V[_\x80\xFD[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\0\x9C\x90a\0tV[\x81\x01\x90\x81\x10`\x01\x80`@\x1B\x03\x82\x11\x17a\0\xB4W`@RV[a\0~V[\x90a\0\xCCa\0\xC5a\0jV[\x92\x83a\0\x92V[V[_\x80\xFD[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\0\xE6\x90a\0\xD2V[\x90V[a\0\xF2\x81a\0\xDDV[\x03a\0\xF9WV[_\x80\xFD[\x90PQ\x90a\x01\n\x82a\0\xE9V[V[\x91\x90`@\x83\x82\x03\x12a\x014W\x80a\x01(a\x011\x92_\x86\x01a\0\xFDV[\x93` \x01a\0\xFDV[\x90V[a\0\xCEV[a\x01Wa\x7Fo\x808\x03\x80a\x01L\x81a\0\xB9V[\x92\x839\x81\x01\x90a\x01\x0CV[\x90\x91V[\x90V[a\x01ra\x01ma\x01w\x92a\0\xD2V[a\x01[V[a\0\xD2V[\x90V[a\x01\x83\x90a\x01^V[\x90V[a\x01\x8F\x90a\x01zV[\x90V[\x90V[a\x01\x9E\x90a\x01\x92V[\x90RV[\x90V[a\x01\xAE\x90a\x01\xA2V[\x90RV[a\x01\xBB\x90a\0\xDDV[\x90RV[\x90\x95\x94\x92a\x02\n\x94a\x01\xF9a\x02\x03\x92a\x01\xEF`\x80\x96a\x01\xE5`\xA0\x88\x01\x9C_\x89\x01\x90a\x01\x95V[` \x87\x01\x90a\x01\x95V[`@\x85\x01\x90a\x01\x95V[``\x83\x01\x90a\x01\xA5V[\x01\x90a\x01\xB2V[V[` \x01\x90V[Q\x90V[\x90a\x02 \x90a\x02\xD3V[`\xA0R\x7F\x8Bs\xC3\xC6\x9B\xB8\xFE=Q.\xCCL\xF7Y\xCCy#\x9F{\x17\x9B\x0F\xFA\xCA\xA9\xA7]R+9@\x0Fa\x02\xBB\x7F6\xFF\xC2X\xC8e\x19:\xE1\x0C<\xF6@E\n\xB7r\xFD\xB8\xDA\x1D\xFC\xAExb\xAD\x12\x05\xA5V\x7FL\x91a\x02\xAC\x7F\xC8\x9E\xFD\xAAT\xC0\xF2\x0Cz\xDFa(\x82\xDF\tP\xF5\xA9Qc~\x03\x07\xCD\xCBLg/)\x8B\x8B\xC6Fa\x02\x970a\x01\x86V[\x91a\x02\xA0a\0jV[\x96\x87\x95` \x87\x01a\x01\xBFV[` \x82\x01\x81\x03\x82R\x03\x82a\0\x92V[a\x02\xCDa\x02\xC7\x82a\x02\x12V[\x91a\x02\x0CV[ `\x80RV[a\x02\xDC\x90a\x03\x1EV[V[\x90V[a\x02\xF5a\x02\xF0a\x02\xFA\x92a\x02\xDEV[a\x01[V[a\0\xD2V[\x90V[a\x03\x06\x90a\x02\xE1V[\x90V[\x91\x90a\x03\x1C\x90_` \x85\x01\x94\x01\x90a\x01\xB2V[V[\x80a\x039a\x033a\x03._a\x02\xFDV[a\0\xDDV[\x91a\0\xDDV[\x14a\x03IWa\x03G\x90a\x03\xE7V[V[a\x03la\x03U_a\x02\xFDV[_\x91\x82\x91c\x1EO\xBD\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x03\tV[\x03\x90\xFD[\x1B\x90V[\x91\x90`\x08a\x03\x94\x91\x02\x91a\x03\x8E`\x01\x80`\xA0\x1B\x03\x84a\x03pV[\x92a\x03pV[\x91\x81\x19\x16\x91\x16\x17\x90V[a\x03\xA7\x90a\x01zV[\x90V[\x90V[\x91\x90a\x03\xC3a\x03\xBEa\x03\xCB\x93a\x03\x9EV[a\x03\xAAV[\x90\x83Ta\x03tV[\x90UV[_\x90V[a\x03\xE5\x91a\x03\xDFa\x03\xCFV[\x91a\x03\xADV[V[a\x03\xFB\x90a\x03\xF6_`\x01a\x03\xD3V[a\x04sV[V[_\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x04\x19a\x04\x1E\x91a\x03\xFDV[a\x04\x02V[\x90V[a\x04+\x90Ta\x04\rV[\x90V[_\x1B\x90V[\x90a\x04D`\x01\x80`\xA0\x1B\x03\x91a\x04.V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a\x04ca\x04^a\x04j\x92a\x03\x9EV[a\x03\xAAV[\x82Ta\x043V[\x90UV[_\x01\x90V[a\x04|_a\x04!V[a\x04\x86\x82_a\x04NV[\x90a\x04\xBAa\x04\xB4\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x03\x9EV[\x91a\x03\x9EV[\x91a\x04\xC3a\0jV[\x80a\x04\xCD\x81a\x04nV[\x03\x90\xA3V\xFE`\x80`@R`\x046\x10\x15a\0\x13W[a$\xF9V[a\0\x1D_5a\x03\x9CV[\x80c\x05w\x85P\x14a\x03\x97W\x80c\x07X#o\x14a\x03\x92W\x80c\x0Cviz\x14a\x03\x8DW\x80c\x19\x1C\xBD\x1A\x14a\x03\x88W\x80c\x1E\x8F^\xE5\x14a\x03\x83W\x80c \x81)V\x14a\x03~W\x80c\"\xF1\xEC\x93\x14a\x03yW\x80c+\xF4\xD6\xA7\x14a\x03tW\x80c,\x95v\x88\x14a\x03oW\x80c-\xAE\x18\x85\x14a\x03jW\x80c/K\xD7\xB8\x14a\x03eW\x80c1\xE3\xBD\x1B\x14a\x03`W\x80c6D\xE5\x15\x14a\x03[W\x80c:\xC3\xCB\xE6\x14a\x03VW\x80c>n4\xA7\x14a\x03QW\x80c?\xD6,m\x14a\x03LW\x80c@#Z\x9C\x14a\x03GW\x80cH\xF4\xDA \x14a\x03BW\x80cV\x85\xCFh\x14a\x03=W\x80cV\xC4\xE1}\x14a\x038W\x80cY\xDC\xEA\x12\x14a\x033W\x80cZ\x93m\xC6\x14a\x03.W\x80c\\\xCE\x98\xA6\x14a\x03)W\x80c`vC\x9C\x14a\x03$W\x80c`\xCF\t\x91\x14a\x03\x1FW\x80ca\xD6\xB8l\x14a\x03\x1AW\x80cb\xC7\xE8\xFC\x14a\x03\x15W\x80ce\xA6\x93n\x14a\x03\x10W\x80ck\xFE\x06\xA6\x14a\x03\x0BW\x80cqP\x18\xA6\x14a\x03\x06W\x80cq\xE78\x8C\x14a\x03\x01W\x80cv9\xD2'\x14a\x02\xFCW\x80cy\xBAP\x97\x14a\x02\xF7W\x80c{\x9Fd\xB2\x14a\x02\xF2W\x80c\x81\xBE\xAC.\x14a\x02\xEDW\x80c\x84\xEFs\"\x14a\x02\xE8W\x80c\x8D\xA5\xCB[\x14a\x02\xE3W\x80c\x96hl\x1E\x14a\x02\xDEW\x80c\x9C\xBD\xAE\"\x14a\x02\xD9W\x80c\xAD\xFF\x83\x0C\x14a\x02\xD4W\x80c\xAEG\n\x85\x14a\x02\xCFW\x80c\xB0t\xE9\xDD\x14a\x02\xCAW\x80c\xB9\x9FgY\x14a\x02\xC5W\x80c\xBA\x1F\xB1\x03\x14a\x02\xC0W\x80c\xC1\xEF\x9D\xDF\x14a\x02\xBBW\x80c\xC5\xD9`\xBB\x14a\x02\xB6W\x80c\xCF\xE3GI\x14a\x02\xB1W\x80c\xD5Q\x16,\x14a\x02\xACW\x80c\xDACZ|\x14a\x02\xA7W\x80c\xE3\x0C9x\x14a\x02\xA2W\x80c\xE6\\\xAF\xCB\x14a\x02\x9DW\x80c\xEE\x1C\x03\x90\x14a\x02\x98W\x80c\xF2\xFD\xE3\x8B\x14a\x02\x93W\x80c\xF9\x10\x7F;\x14a\x02\x8EW\x80c\xF9\xF1gb\x14a\x02\x89Wc\xFF\xCF\x08\xF0\x03a\0\x0EWa$\xC5V[a$\x90V[a$-V[a#\xCDV[a#\x97V[a#cV[a#.V[a\"\xF6V[a\"$V[a!\xEFV[a!\xADV[a!xV[a NV[a \x1AV[a\x1F\xADV[a\x1FsV[a\x1E\xAAV[a\x1D\xE7V[a\x1C`V[a\x1B\xAAV[a\x1BwV[a\x1B@V[a\x1A\xABV[a\x1AxV[a\x1ABV[a\x1A\x0CV[a\x19PV[a\x19\x1BV[a\x18\xADV[a\x16rV[a\x16(V[a\x15\xA6V[a\x15qV[a\x15\x03V[a\x14pV[a\x14\x17V[a\x13\xE2V[a\x13}V[a\x133V[a\x12\xC7V[a\x11\xF3V[a\x11\xB9V[a\x0F\x83V[a\x0F\x16V[a\x0E\x97V[a\r\x1EV[a\x0C\xD0V[a\x0C5V[a\x0B\x8FV[a\nbV[a\x06\xC0V[a\x06nV[a\x06:V[a\x05wV[a\x05\x1DV[a\x04NV[`\xE0\x1C\x90V[`@Q\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[`\x01\x80`@\x1B\x03\x16\x90V[a\x03\xC8\x81a\x03\xB4V[\x03a\x03\xCFWV[_\x80\xFD[\x90P5\x90a\x03\xE0\x82a\x03\xBFV[V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x03\xF6\x90a\x03\xE2V[\x90V[a\x04\x02\x81a\x03\xEDV[\x03a\x04\tWV[_\x80\xFD[\x90P5\x90a\x04\x1A\x82a\x03\xF9V[V[\x91\x90`@\x83\x82\x03\x12a\x04DW\x80a\x048a\x04A\x92_\x86\x01a\x03\xD3V[\x93` \x01a\x04\rV[\x90V[a\x03\xACV[_\x01\x90V[4a\x04}Wa\x04ga\x04a6`\x04a\x04\x1CV[\x90a&\x90V[a\x04oa\x03\xA2V[\x80a\x04y\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x04\x9BWa\x04\x98\x91_\x01a\x03\xD3V[\x90V[a\x03\xACV[a\x04\xA9\x90a\x03\xB4V[\x90RV[`\xFF\x16\x90V[a\x04\xBC\x90a\x04\xADV[\x90RV[\x15\x15\x90V[a\x04\xCE\x90a\x04\xC0V[\x90RV[\x90`@\x80a\x05\x06\x93a\x04\xEA_\x82\x01Q_\x86\x01\x90a\x04\xA0V[a\x04\xFC` \x82\x01Q` \x86\x01\x90a\x04\xB3V[\x01Q\x91\x01\x90a\x04\xC5V[V[\x91\x90a\x05\x1B\x90_``\x85\x01\x94\x01\x90a\x04\xD2V[V[4a\x05MWa\x05Ia\x058a\x0536`\x04a\x04\x82V[a'oV[a\x05@a\x03\xA2V[\x91\x82\x91\x82a\x05\x08V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x05^\x90a\x05RV[\x90RV[\x91\x90a\x05u\x90_` \x85\x01\x94\x01\x90a\x05UV[V[4a\x05\xA8Wa\x05\xA4a\x05\x93a\x05\x8D6`\x04a\x04\x1CV[\x90a'\x88V[a\x05\x9Ba\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x05\xF1W\x815\x91`\x01\x80`@\x1B\x03\x83\x11a\x05\xECW` \x01\x92` \x83\x02\x84\x01\x11a\x05\xE7WV[a\x05\xB5V[a\x05\xB1V[a\x05\xADV[\x91\x90\x91`@\x81\x84\x03\x12a\x065Wa\x06\x0F\x83_\x83\x01a\x03\xD3V[\x92` \x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x060Wa\x06,\x92\x01a\x05\xB9V[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x06iWa\x06Sa\x06M6`\x04a\x05\xF6V[\x91a0\xFEV[a\x06[a\x03\xA2V[\x80a\x06e\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a\x06\x9DWa\x06\x87a\x06\x816`\x04a\x04\x1CV[\x90a3\xE8V[a\x06\x8Fa\x03\xA2V[\x80a\x06\x99\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x06\xBBWa\x06\xB8\x91_\x01a\x04\rV[\x90V[a\x03\xACV[4a\x06\xEEWa\x06\xD8a\x06\xD36`\x04a\x06\xA2V[a5\x1DV[a\x06\xE0a\x03\xA2V[\x80a\x06\xEA\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[a\x06\xFC\x81a\x05RV[\x03a\x07\x03WV[_\x80\xFD[\x90P5\x90a\x07\x14\x82a\x06\xF3V[V[\x91\x90`@\x83\x82\x03\x12a\x07>W\x80a\x072a\x07;\x92_\x86\x01a\x03\xD3V[\x93` \x01a\x07\x07V[\x90V[a\x03\xACV[\x90V[a\x07Za\x07Ua\x07_\x92a\x03\xB4V[a\x07CV[a\x03\xB4V[\x90V[\x90a\x07l\x90a\x07FV[_R` R`@_ \x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[T\x90V[_R` _ \x90V[_R` _ \x90V[a\x07\xAB\x81a\x07\x8CV[\x82\x10\x15a\x07\xC5Wa\x07\xBD`\x04\x91a\x07\x90V[\x91\x02\x01\x90_\x90V[a\x07xV[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x90`\x01`\x02\x83\x04\x92\x16\x80\x15a\x07\xFEW[` \x83\x10\x14a\x07\xF9WV[a\x07\xCAV[\x91`\x7F\x16\x91a\x07\xEEV[` \x91\x81R\x01\x90V[_R` _ \x90V[\x90_\x92\x91\x80T\x90a\x084a\x08-\x83a\x07\xDEV[\x80\x94a\x08\x08V[\x91`\x01\x81\x16\x90\x81_\x14a\x08\x8BWP`\x01\x14a\x08OW[PPPV[a\x08\\\x91\x92\x93\x94Pa\x08\x11V[\x91_\x92[\x81\x84\x10a\x08sWPP\x01\x90_\x80\x80a\x08JV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a\x08`V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a\x08JV[\x90a\x08\xB0\x91a\x08\x1AV[\x90V[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\x08\xDB\x90a\x08\xB3V[\x81\x01\x90\x81\x10`\x01\x80`@\x1B\x03\x82\x11\x17a\x08\xF3W`@RV[a\x08\xBDV[\x90a\t\x18a\t\x11\x92a\t\x08a\x03\xA2V[\x93\x84\x80\x92a\x08\xA6V[\x03\x83a\x08\xD1V[V[_\x1C\x90V[\x90V[a\t.a\t3\x91a\t\x1AV[a\t\x1FV[\x90V[a\t@\x90Ta\t\"V[\x90V[`\xFF\x16\x90V[a\tUa\tZ\x91a\t\x1AV[a\tCV[\x90V[a\tg\x90Ta\tIV[\x90V[a\tu\x90`\x08a\x07bV[\x90a\t\x7F\x82a\x07\x8CV[\x81\x10\x15a\t\xC5Wa\t\x8F\x91a\x07\xA2V[P\x90a\t\x9C_\x83\x01a\x08\xF8V[\x91a\t\xA9`\x01\x82\x01a\t6V[\x91a\t\xC2`\x03a\t\xBB`\x02\x85\x01a\t6V[\x93\x01a\t]V[\x90V[_\x80\xFD[Q\x90V[` \x91\x81R\x01\x90V[\x90\x82_\x93\x92\x82^\x01RV[a\n\0a\n\t` \x93a\n\x0E\x93a\t\xF7\x81a\t\xC9V[\x93\x84\x80\x93a\t\xCDV[\x95\x86\x91\x01a\t\xD6V[a\x08\xB3V[\x01\x90V[a\n\x1B\x90a\x04\xC0V[\x90RV[a\nYa\n`\x94a\nOa\nD``\x95\x99\x98\x96\x99`\x80\x86\x01\x90\x86\x82\x03_\x88\x01Ra\t\xE1V[\x98` \x85\x01\x90a\x05UV[`@\x83\x01\x90a\x05UV[\x01\x90a\n\x12V[V[4a\n\x97Wa\n\x93a\n~a\nx6`\x04a\x07\x16V[\x90a\tjV[\x90a\n\x8A\x94\x92\x94a\x03\xA2V[\x94\x85\x94\x85a\n\x1FV[\x03\x90\xF3[a\x03\xA8V[a\n\xA5\x81a\x04\xADV[\x03a\n\xACWV[_\x80\xFD[\x90P5\x90a\n\xBD\x82a\n\x9CV[V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\n\xF7W\x815\x91`\x01\x80`@\x1B\x03\x83\x11a\n\xF2W` \x01\x92`\x01\x83\x02\x84\x01\x11a\n\xEDWV[a\x05\xB5V[a\x05\xB1V[a\x05\xADV[\x91\x90`\xC0\x83\x82\x03\x12a\x0B\x8AWa\x0B\x14\x81_\x85\x01a\x03\xD3V[\x92a\x0B\"\x82` \x83\x01a\x03\xD3V[\x92a\x0B0\x83`@\x84\x01a\n\xB0V[\x92``\x83\x015`\x01\x80`@\x1B\x03\x81\x11a\x0B\x85W\x81a\x0BO\x91\x85\x01a\n\xBFV[\x92\x90\x93a\x0B_\x83`\x80\x83\x01a\x03\xD3V[\x92`\xA0\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x0B\x80Wa\x0B|\x92\x01a\n\xBFV[\x90\x91V[a\x03\xB0V[a\x03\xB0V[a\x03\xACV[4a\x0B\xC7Wa\x0B\xB1a\x0B\xA26`\x04a\n\xFCV[\x96\x95\x90\x95\x94\x91\x94\x93\x92\x93a9\xCAV[a\x0B\xB9a\x03\xA2V[\x80a\x0B\xC3\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[_\x91\x03\x12a\x0B\xD6WV[a\x03\xACV[\x90V[a\x0B\xF2a\x0B\xEDa\x0B\xF7\x92a\x0B\xDBV[a\x07CV[a\x03\xB4V[\x90V[a\x0C\x05a\x01,a\x0B\xDEV[\x90V[a\x0C\x10a\x0B\xFAV[\x90V[a\x0C\x1C\x90a\x03\xB4V[\x90RV[\x91\x90a\x0C3\x90_` \x85\x01\x94\x01\x90a\x0C\x13V[V[4a\x0CeWa\x0CE6`\x04a\x0B\xCCV[a\x0Caa\x0CPa\x0C\x08V[a\x0CXa\x03\xA2V[\x91\x82\x91\x82a\x0C V[\x03\x90\xF3[a\x03\xA8V[\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x0C\x89\x90`\x08a\x0C\x8E\x93\x02a\x0CjV[a\x0CnV[\x90V[\x90a\x0C\x9C\x91Ta\x0CyV[\x90V[a\x0C\xAB`\x0B_\x90a\x0C\x91V[\x90V[a\x0C\xB7\x90a\x03\xEDV[\x90RV[\x91\x90a\x0C\xCE\x90_` \x85\x01\x94\x01\x90a\x0C\xAEV[V[4a\r\0Wa\x0C\xE06`\x04a\x0B\xCCV[a\x0C\xFCa\x0C\xEBa\x0C\x9FV[a\x0C\xF3a\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[a\r\x10a\x01,a\x0B\xDEV[\x90V[a\r\x1Ba\r\x05V[\x90V[4a\rNWa\r.6`\x04a\x0B\xCCV[a\rJa\r9a\r\x13V[a\rAa\x03\xA2V[\x91\x82\x91\x82a\x0C V[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\r\x82W_\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\r}Wa\ry\x92\x01a\n\xBFV[\x90\x91V[a\x03\xB0V[a\x03\xACV[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\r\xB9a\r\xC2` \x93a\r\xC7\x93a\r\xB0\x81a\t\xC9V[\x93\x84\x80\x93a\x08\x08V[\x95\x86\x91\x01a\t\xD6V[a\x08\xB3V[\x01\x90V[a\r\xD4\x90a\x05RV[\x90RV[\x90a\x0E\x02\x90` \x80a\r\xF7`@\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\x9AV[\x94\x01Q\x91\x01\x90a\r\xCBV[\x90V[\x90a\x0E\x0F\x91a\r\xD8V[\x90V[` \x01\x90V[\x90a\x0E,a\x0E%\x83a\r\x87V[\x80\x92a\r\x8BV[\x90\x81a\x0E=` \x83\x02\x84\x01\x94a\r\x94V[\x92_\x91[\x83\x83\x10a\x0EPWPPPPP\x90V[\x90\x91\x92\x93\x94` a\x0Era\x0El\x83\x85`\x01\x95\x03\x87R\x89Qa\x0E\x05V[\x97a\x0E\x12V[\x93\x01\x93\x01\x91\x93\x92\x90a\x0EAV[a\x0E\x94\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x0E\x18V[\x90V[4a\x0E\xC8Wa\x0E\xC4a\x0E\xB3a\x0E\xAD6`\x04a\rSV[\x90a:\x14V[a\x0E\xBBa\x03\xA2V[\x91\x82\x91\x82a\x0E\x7FV[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[\x90V[a\x0E\xFD\x90a\x0E\xF1V[\x90RV[\x91\x90a\x0F\x14\x90_` \x85\x01\x94\x01\x90a\x0E\xF4V[V[4a\x0FFWa\x0F&6`\x04a\x0B\xCCV[a\x0FBa\x0F1a\x0E\xCDV[a\x0F9a\x03\xA2V[\x91\x82\x91\x82a\x0F\x01V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x0Fba\x0F]a\x0Fg\x92a\x0FKV[a\x07CV[a\x03\xB4V[\x90V[a\x0Fua\x0E\x10a\x0FNV[\x90V[a\x0F\x80a\x0FjV[\x90V[4a\x0F\xB3Wa\x0F\x936`\x04a\x0B\xCCV[a\x0F\xAFa\x0F\x9Ea\x0FxV[a\x0F\xA6a\x03\xA2V[\x91\x82\x91\x82a\x0C V[\x03\x90\xF3[a\x03\xA8V[\x90a\x0F\xC2\x90a\x07FV[_R` R`@_ \x90V[a\x0F\xE2a\x0F\xDDa\x0F\xE7\x92a\x03\xE2V[a\x07CV[a\x03\xE2V[\x90V[a\x0F\xF3\x90a\x0F\xCEV[\x90V[a\x0F\xFF\x90a\x0F\xEAV[\x90V[\x90a\x10\x0C\x90a\x0F\xF6V[_R` R`@_ \x90V[`\x01\x80`@\x1B\x03\x16\x90V[a\x10/a\x104\x91a\t\x1AV[a\x10\x18V[\x90V[a\x10A\x90Ta\x10#V[\x90V[`@\x1C\x90V[`\xFF\x16\x90V[a\x10\\a\x10a\x91a\x10DV[a\x10JV[\x90V[a\x10n\x90Ta\x10PV[\x90V[`H\x1C\x90V[`\xFF\x16\x90V[a\x10\x89a\x10\x8E\x91a\x10qV[a\x10wV[\x90V[a\x10\x9B\x90Ta\x10}V[\x90V[\x90V[a\x10\xADa\x10\xB2\x91a\t\x1AV[a\x10\x9EV[\x90V[a\x10\xBF\x90Ta\x10\xA1V[\x90V[\x90a\x10\xD1a\x10\xD6\x92`\x03a\x0F\xB8V[a\x10\x02V[a\x10\xE1_\x82\x01a\t6V[\x91a\x10\xEE`\x01\x83\x01a\x107V[\x91a\x10\xFB`\x01\x82\x01a\x10dV[\x91a\x11\x14`\x02a\x11\r`\x01\x85\x01a\x10\x91V[\x93\x01a\x10\xB5V[\x90V[a\x11 \x90a\x04\xADV[\x90RV[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[`\x05\x11\x15a\x11BWV[a\x11$V[\x90a\x11Q\x82a\x118V[V[a\x11\\\x90a\x11GV[\x90V[a\x11h\x90a\x11SV[\x90RV[\x90\x95\x94\x92a\x11\xB7\x94a\x11\xA6a\x11\xB0\x92a\x11\x9C`\x80\x96a\x11\x92`\xA0\x88\x01\x9C_\x89\x01\x90a\x05UV[` \x87\x01\x90a\x0C\x13V[`@\x85\x01\x90a\x11\x17V[``\x83\x01\x90a\x11_V[\x01\x90a\x0E\xF4V[V[4a\x11\xEEWa\x11\xEAa\x11\xD5a\x11\xCF6`\x04a\x04\x1CV[\x90a\x10\xC2V[\x91a\x11\xE1\x95\x93\x95a\x03\xA2V[\x95\x86\x95\x86a\x11lV[\x03\x90\xF3[a\x03\xA8V[4a\x12#Wa\x12\x1Fa\x12\x0Ea\x12\t6`\x04a\x04\x82V[a:.V[a\x12\x16a\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x12D\x90a\x03\xEDV[\x90RV[\x90a\x12U\x81` \x93a\x12;V[\x01\x90V[` \x01\x90V[\x90a\x12|a\x12va\x12o\x84a\x12(V[\x80\x93a\x12,V[\x92a\x125V[\x90_[\x81\x81\x10a\x12\x8CWPPP\x90V[\x90\x91\x92a\x12\xA5a\x12\x9F`\x01\x92\x86Qa\x12HV[\x94a\x12YV[\x91\x01\x91\x90\x91a\x12\x7FV[a\x12\xC4\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x12_V[\x90V[4a\x12\xF7Wa\x12\xF3a\x12\xE2a\x12\xDD6`\x04a\x04\x82V[a:\xE6V[a\x12\xEAa\x03\xA2V[\x91\x82\x91\x82a\x12\xAFV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x13\x13a\x13\x0Ea\x13\x18\x92a\x12\xFCV[a\x07CV[a\x05RV[\x90V[a\x13%`\xC8a\x12\xFFV[\x90V[a\x130a\x13\x1BV[\x90V[4a\x13cWa\x13C6`\x04a\x0B\xCCV[a\x13_a\x13Na\x13(V[a\x13Va\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x13{\x90_` \x85\x01\x94\x01\x90a\n\x12V[V[4a\x13\xAEWa\x13\xAAa\x13\x99a\x13\x936`\x04a\x04\x1CV[\x90a;\x86V[a\x13\xA1a\x03\xA2V[\x91\x82\x91\x82a\x13hV[\x03\x90\xF3[a\x03\xA8V[\x90a\x13\xBD\x90a\x07FV[_R` R`@_ \x90V[a\x13\xDF\x90a\x13\xDA`\x07\x91_\x92a\x13\xB3V[a\x0C\x91V[\x90V[4a\x14\x12Wa\x14\x0Ea\x13\xFDa\x13\xF86`\x04a\x04\x82V[a\x13\xC9V[a\x14\x05a\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[4a\x14GWa\x14Ca\x142a\x14-6`\x04a\x04\x82V[a<\rV[a\x14:a\x03\xA2V[\x91\x82\x91\x82a\x12\xAFV[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[4a\x14\xA0Wa\x14\x806`\x04a\x0B\xCCV[a\x14\x9Ca\x14\x8Ba\x14LV[a\x14\x93a\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[\x90`\x80\x82\x82\x03\x12a\x14\xFEWa\x14\xBC\x81_\x84\x01a\x03\xD3V[\x92a\x14\xCA\x82` \x85\x01a\x03\xD3V[\x92a\x14\xD8\x83`@\x83\x01a\n\xB0V[\x92``\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x14\xF9Wa\x14\xF5\x92\x01a\n\xBFV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x155Wa\x15\x1Fa\x15\x166`\x04a\x14\xA5V[\x93\x92\x90\x92a<\x7FV[a\x15'a\x03\xA2V[\x80a\x151\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x15Qa\x15La\x15V\x92a\x15:V[a\x07CV[a\x05RV[\x90V[a\x15c`2a\x15=V[\x90V[a\x15na\x15YV[\x90V[4a\x15\xA1Wa\x15\x816`\x04a\x0B\xCCV[a\x15\x9Da\x15\x8Ca\x15fV[a\x15\x94a\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[4a\x15\xD7Wa\x15\xD3a\x15\xC2a\x15\xBC6`\x04a\x04\x1CV[\x90a<\x8EV[a\x15\xCAa\x03\xA2V[\x91\x82\x91\x82a\x13hV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x15\xF3a\x15\xEEa\x15\xF8\x92a\x15\xDCV[a\x07CV[a\x04\xADV[\x90V[a\x16\x05`\x03a\x15\xDFV[\x90V[a\x16\x10a\x15\xFBV[\x90V[\x91\x90a\x16&\x90_` \x85\x01\x94\x01\x90a\x11\x17V[V[4a\x16XWa\x1686`\x04a\x0B\xCCV[a\x16Ta\x16Ca\x16\x08V[a\x16Ka\x03\xA2V[\x91\x82\x91\x82a\x16\x13V[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x16p\x90_` \x85\x01\x94\x01\x90a\x11_V[V[4a\x16\xA3Wa\x16\x9Fa\x16\x8Ea\x16\x886`\x04a\x04\x1CV[\x90a<\xBAV[a\x16\x96a\x03\xA2V[\x91\x82\x91\x82a\x16]V[\x03\x90\xF3[a\x03\xA8V[\x90a\x16\xBBa\x16\xB4a\x03\xA2V[\x92\x83a\x08\xD1V[V[`\x01\x80`@\x1B\x03\x81\x11a\x16\xD3W` \x80\x91\x02\x01\x90V[a\x08\xBDV[_\x80\xFD[_\x80\xFD[_\x80\xFD[`\x01\x80`@\x1B\x03\x81\x11a\x17\0Wa\x16\xFC` \x91a\x08\xB3V[\x01\x90V[a\x08\xBDV[\x90\x82_\x93\x92\x827\x01RV[\x90\x92\x91\x92a\x17%a\x17 \x82a\x16\xE4V[a\x16\xA8V[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a\x17AWa\x17?\x92a\x17\x05V[V[a\x16\xE0V[\x90\x80`\x1F\x83\x01\x12\x15a\x17dW\x81` a\x17a\x935\x91\x01a\x17\x10V[\x90V[a\x05\xADV[\x91\x90\x91`@\x81\x84\x03\x12a\x17\xBAWa\x17\x80`@a\x16\xA8V[\x92_\x82\x015\x91`\x01\x80`@\x1B\x03\x83\x11a\x17\xB5Wa\x17\xA2\x82a\x17\xAE\x94\x83\x01a\x17FV[_\x86\x01R` \x01a\x07\x07V[` \x83\x01RV[a\x16\xDCV[a\x16\xD8V[\x92\x91\x90a\x17\xD3a\x17\xCE\x82a\x16\xBDV[a\x16\xA8V[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11a\x18(W\x81\x90[\x83\x82\x10a\x17\xF9WPPPPPV[\x815`\x01\x80`@\x1B\x03\x81\x11a\x18#W` \x91a\x18\x18\x87\x84\x93\x87\x01a\x17iV[\x81R\x01\x91\x01\x90a\x17\xEBV[a\x05\xADV[a\x05\xB5V[\x90\x80`\x1F\x83\x01\x12\x15a\x18KW\x81` a\x18H\x935\x91\x01a\x17\xBFV[\x90V[a\x05\xADV[`\x80\x81\x83\x03\x12a\x18\xA8Wa\x18f\x82_\x83\x01a\x03\xD3V[\x92a\x18t\x83` \x84\x01a\x04\rV[\x92`@\x83\x015\x90`\x01\x80`@\x1B\x03\x82\x11a\x18\xA3Wa\x18\x97\x81a\x18\xA0\x93\x86\x01a\x18-V[\x93``\x01a\x07\x07V[\x90V[a\x03\xB0V[a\x03\xACV[4a\x18\xDFWa\x18\xC9a\x18\xC06`\x04a\x18PV[\x92\x91\x90\x91a@\x9EV[a\x18\xD1a\x03\xA2V[\x80a\x18\xDB\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x18\xFBa\x18\xF6a\x19\0\x92a\x18\xE4V[a\x07CV[a\x05RV[\x90V[a\x19\r`@a\x18\xE7V[\x90V[a\x19\x18a\x19\x03V[\x90V[4a\x19KWa\x19+6`\x04a\x0B\xCCV[a\x19Ga\x196a\x19\x10V[a\x19>a\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[4a\x19~Wa\x19`6`\x04a\x0B\xCCV[a\x19haF\xCDV[a\x19pa\x03\xA2V[\x80a\x19z\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[a\x19\x8C\x90a\x11SV[\x90RV[a\x19\x99\x90a\x0E\xF1V[\x90RV[\x90`\x80\x80a\x19\xF5\x93a\x19\xB5_\x82\x01Q_\x86\x01\x90a\r\xCBV[a\x19\xC7` \x82\x01Q` \x86\x01\x90a\x04\xA0V[a\x19\xD9`@\x82\x01Q`@\x86\x01\x90a\x04\xB3V[a\x19\xEB``\x82\x01Q``\x86\x01\x90a\x19\x83V[\x01Q\x91\x01\x90a\x19\x90V[V[\x91\x90a\x1A\n\x90_`\xA0\x85\x01\x94\x01\x90a\x19\x9DV[V[4a\x1A=Wa\x1A9a\x1A(a\x1A\"6`\x04a\x04\x1CV[\x90aH\nV[a\x1A0a\x03\xA2V[\x91\x82\x91\x82a\x19\xF7V[\x03\x90\xF3[a\x03\xA8V[4a\x1AsWa\x1Aoa\x1A^a\x1AX6`\x04a\x04\x1CV[\x90aHbV[a\x1Afa\x03\xA2V[\x91\x82\x91\x82a\x0C V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xA6Wa\x1A\x886`\x04a\x0B\xCCV[a\x1A\x90aH\x8AV[a\x1A\x98a\x03\xA2V[\x80a\x1A\xA2\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xDBWa\x1A\xD7a\x1A\xC6a\x1A\xC16`\x04a\x04\x82V[aH\xDBV[a\x1A\xCEa\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a\x1B\x15Wa\x1B\x12a\x1A\xFB\x84_\x85\x01a\x03\xD3V[\x93a\x1B\t\x81` \x86\x01a\x07\x07V[\x93`@\x01a\x07\x07V[\x90V[a\x03\xACV[\x92\x91` a\x1B6a\x1B>\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\x12_V[\x94\x01\x90a\x05UV[V[4a\x1BrWa\x1BYa\x1BS6`\x04a\x1A\xE0V[\x91aIyV[\x90a\x1Bna\x1Bea\x03\xA2V[\x92\x83\x92\x83a\x1B\x1AV[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xA5Wa\x1B\x8Fa\x1B\x8A6`\x04a\x06\xA2V[aK\0V[a\x1B\x97a\x03\xA2V[\x80a\x1B\xA1\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xDAWa\x1B\xBA6`\x04a\x0B\xCCV[a\x1B\xD6a\x1B\xC5aK\x0FV[a\x1B\xCDa\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1C\x17W\x815\x91`\x01\x80`@\x1B\x03\x83\x11a\x1C\x12W` \x01\x92` \x83\x02\x84\x01\x11a\x1C\rWV[a\x05\xB5V[a\x05\xB1V[a\x05\xADV[\x91\x90\x91`@\x81\x84\x03\x12a\x1C[Wa\x1C5\x83_\x83\x01a\x03\xD3V[\x92` \x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x1CVWa\x1CR\x92\x01a\x1B\xDFV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1C\x8FWa\x1Cya\x1Cs6`\x04a\x1C\x1CV[\x91aK\x96V[a\x1C\x81a\x03\xA2V[\x80a\x1C\x8B\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x91``\x83\x83\x03\x12a\x1C\xDEWa\x1C\xAB\x82_\x85\x01a\x03\xD3V[\x92a\x1C\xB9\x83` \x83\x01a\x04\rV[\x92`@\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x1C\xD9Wa\x1C\xD6\x92\x01a\x17FV[\x90V[a\x03\xB0V[a\x03\xACV[\x90a\x1C\xED\x90a\x07FV[_R` R`@_ \x90V[\x90a\x1D\x03\x90a\x0F\xF6V[_R` R`@_ \x90V[\x90P\x90V[a\x1D9a\x1D0\x92` \x92a\x1D'\x81a\t\xC9V[\x94\x85\x80\x93a\x1D\x0FV[\x93\x84\x91\x01a\t\xD6V[\x01\x90V[\x90V[a\x1DLa\x1DQ\x91a\x05RV[a\x1D=V[\x90RV[a\x1Dea\x1Dl\x91` \x94\x93a\x1D\x14V[\x80\x92a\x1D@V[\x01\x90V[a\x1D\x84a\x1D{a\x03\xA2V[\x92\x83\x92\x83a\x1DUV[\x03\x90 \x90V[a\x1D\x93\x91a\x1DpV[\x90V[a\x1D\xA6\x90`\x08a\x1D\xAB\x93\x02a\x0CjV[a\t\x1FV[\x90V[\x90a\x1D\xB9\x91Ta\x1D\x96V[\x90V[\x90a\x1D\xE4\x92a\x1D\xDAa\x1D\xDF\x92a\x1D\xD5`\t\x95_\x96a\x1C\xE3V[a\x1C\xF9V[a\x1D\x8AV[a\x1D\xAEV[\x90V[4a\x1E\x18Wa\x1E\x14a\x1E\x03a\x1D\xFD6`\x04a\x1C\x94V[\x91a\x1D\xBCV[a\x1E\x0Ba\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1EUW\x815\x91`\x01\x80`@\x1B\x03\x83\x11a\x1EPW` \x01\x92`\x01\x83\x02\x84\x01\x11a\x1EKWV[a\x05\xB5V[a\x05\xB1V[a\x05\xADV[\x91``\x83\x83\x03\x12a\x1E\xA5Wa\x1Eq\x82_\x85\x01a\x03\xD3V[\x92a\x1E\x7F\x83` \x83\x01a\x04\rV[\x92`@\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x1E\xA0Wa\x1E\x9C\x92\x01a\x1E\x1DV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1E\xDCWa\x1E\xC6a\x1E\xBD6`\x04a\x1EZV[\x92\x91\x90\x91aM\xF9V[a\x1E\xCEa\x03\xA2V[\x80a\x1E\xD8\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[a\x1E\xEA\x81a\x04\xC0V[\x03a\x1E\xF1WV[_\x80\xFD[\x90P5\x90a\x1F\x02\x82a\x1E\xE1V[V[\x91\x90\x91`\xA0\x81\x84\x03\x12a\x1FnWa\x1F\x1D\x83_\x83\x01a\x03\xD3V[\x92` \x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x1FiW\x81a\x1F<\x91\x84\x01a\x1E\x1DV[\x92\x90\x93a\x1Ffa\x1FO\x84`@\x85\x01a\x07\x07V[\x93a\x1F]\x81``\x86\x01a\x07\x07V[\x93`\x80\x01a\x1E\xF5V[\x90V[a\x03\xB0V[a\x03\xACV[4a\x1F\xA8Wa\x1F\x92a\x1F\x866`\x04a\x1F\x04V[\x94\x93\x90\x93\x92\x91\x92aP\xC7V[a\x1F\x9Aa\x03\xA2V[\x80a\x1F\xA4\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a\x1F\xDBWa\x1F\xC5a\x1F\xC06`\x04a\x04\x82V[aTwV[a\x1F\xCDa\x03\xA2V[\x80a\x1F\xD7\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a \x15Wa \x12a\x1F\xFB\x84_\x85\x01a\x03\xD3V[\x93a \t\x81` \x86\x01a\x03\xD3V[\x93`@\x01a\n\xB0V[\x90V[a\x03\xACV[4a IWa 3a -6`\x04a\x1F\xE0V[\x91aV\xECV[a ;a\x03\xA2V[\x80a E\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a }Wa ga a6`\x04a\x04\x1CV[\x90aX\xABV[a oa\x03\xA2V[\x80a y\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[\x90a \xE3\x90``\x80a \xB4`\x80\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\x9AV[\x94a \xC7` \x82\x01Q` \x86\x01\x90a\r\xCBV[a \xD9`@\x82\x01Q`@\x86\x01\x90a\r\xCBV[\x01Q\x91\x01\x90a\x04\xC5V[\x90V[\x90a \xF0\x91a \x95V[\x90V[` \x01\x90V[\x90a!\ra!\x06\x83a \x82V[\x80\x92a \x86V[\x90\x81a!\x1E` \x83\x02\x84\x01\x94a \x8FV[\x92_\x91[\x83\x83\x10a!1WPPPPP\x90V[\x90\x91\x92\x93\x94` a!Sa!M\x83\x85`\x01\x95\x03\x87R\x89Qa \xE6V[\x97a \xF3V[\x93\x01\x93\x01\x91\x93\x92\x90a!\"V[a!u\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra \xF9V[\x90V[4a!\xA8Wa!\xA4a!\x93a!\x8E6`\x04a\x04\x82V[a\\ V[a!\x9Ba\x03\xA2V[\x91\x82\x91\x82a!`V[\x03\x90\xF3[a\x03\xA8V[4a!\xDBWa!\xC5a!\xC06`\x04a\x04\x82V[a]\xB0V[a!\xCDa\x03\xA2V[\x80a!\xD7\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[a!\xEC`\n_\x90a\x0C\x91V[\x90V[4a\"\x1FWa!\xFF6`\x04a\x0B\xCCV[a\"\x1Ba\"\na!\xE0V[a\"\x12a\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[4a\"XWa\"Ta\"Ca\":6`\x04a\x1EZV[\x92\x91\x90\x91a^\x1DV[a\"Ka\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[\x90a\"g\x90a\x07FV[_R` R`@_ \x90V[a\"\x7Fa\"\x84\x91a\x10qV[a\tCV[\x90V[a\"\x91\x90Ta\"sV[\x90V[a\"\x9F\x90`\x02a\"]V[a\"\xAA_\x82\x01a\x107V[\x91a\"\xC1_a\"\xBA\x81\x85\x01a\x10dV[\x93\x01a\"\x87V[\x90V[`@\x90a\"\xEDa\"\xF4\x94\x96\x95\x93\x96a\"\xE3``\x84\x01\x98_\x85\x01\x90a\x0C\x13V[` \x83\x01\x90a\x11\x17V[\x01\x90a\n\x12V[V[4a#)Wa#%a#\x11a#\x0C6`\x04a\x04\x82V[a\"\x94V[a#\x1C\x93\x91\x93a\x03\xA2V[\x93\x84\x93\x84a\"\xC4V[\x03\x90\xF3[a\x03\xA8V[4a#^Wa#>6`\x04a\x0B\xCCV[a#Za#Ia^RV[a#Qa\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[4a#\x92Wa#|a#v6`\x04a\x04\x1CV[\x90a_<V[a#\x84a\x03\xA2V[\x80a#\x8E\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a#\xC8Wa#\xC4a#\xB3a#\xAD6`\x04a\x04\x1CV[\x90a`\xD1V[a#\xBBa\x03\xA2V[\x91\x82\x91\x82a\x13hV[\x03\x90\xF3[a\x03\xA8V[4a#\xFBWa#\xE5a#\xE06`\x04a\x06\xA2V[aa\xD0V[a#\xEDa\x03\xA2V[\x80a#\xF7\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x91\x90`@\x83\x82\x03\x12a$(W\x80a$\x1Ca$%\x92_\x86\x01a\x03\xD3V[\x93` \x01a\x1E\xF5V[\x90V[a\x03\xACV[4a$\\Wa$Fa$@6`\x04a$\0V[\x90aa\xDBV[a$Na\x03\xA2V[\x80a$X\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x7F2r\x1F\x8D\xC6~\x95<T\r\xA9\x0Ff0Y\xC2?\xC4\x7Fp\xD1\x1E1~\xD6\xD5\xA2L\x8B\x85ct\x90V[a$\x8Da$aV[\x90V[4a$\xC0Wa$\xA06`\x04a\x0B\xCCV[a$\xBCa$\xABa$\x85V[a$\xB3a\x03\xA2V[\x91\x82\x91\x82a\x0F\x01V[\x03\x90\xF3[a\x03\xA8V[4a$\xF4Wa$\xDEa$\xD86`\x04a\x04\x1CV[\x90ab\xA4V[a$\xE6a\x03\xA2V[\x80a$\xF0\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x7FOnly Tangle core\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%1`\x10` \x92a\t\xCDV[a%:\x81a$\xFDV[\x01\x90V[a%S\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%$V[\x90V[\x15a%]WV[a%ea\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a%{`\x04\x82\x01a%>V[\x03\x90\xFD[a%\x8Ba%\x90\x91a\t\x1AV[a\x0CnV[\x90V[a%\x9D\x90Ta%\x7FV[\x90V[\x90V[a%\xB7a%\xB2a%\xBC\x92a%\xA0V[a\x07CV[a\x03\xE2V[\x90V[a%\xC8\x90a%\xA3V[\x90V[_\x7FAlready registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%\xFF`\x12` \x92a\t\xCDV[a&\x08\x81a%\xCBV[\x01\x90V[a&!\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%\xF2V[\x90V[\x15a&+WV[a&3a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a&I`\x04\x82\x01a&\x0CV[\x03\x90\xFD[_\x1B\x90V[\x90a&c`\x01\x80`\xA0\x1B\x03\x91a&MV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90a&\x85a&\x80a&\x8C\x92a\x0F\xF6V[a&mV[\x82Ta&RV[\x90UV[a'\x12a'\x17\x92a&\xD33a&\xCDa&\xC7\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEDV[\x91a\x03\xEDV[\x14a%VV[a'\na&\xEAa&\xE5`\x07\x86\x90a\x13\xB3V[a%\x93V[a'\x04a&\xFEa&\xF9_a%\xBFV[a\x03\xEDV[\x91a\x03\xEDV[\x14a&$V[\x91`\x07a\x13\xB3V[a&pV[V[a'#``a\x16\xA8V[\x90V[_\x90V[_\x90V[_\x90V[a':a'\x19V[\x90` \x80\x80\x84a'Ha'&V[\x81R\x01a'Sa'*V[\x81R\x01a'^a'.V[\x81RPPV[a'la'2V[\x90V[a'\x81\x90a'{a'dV[Pac\xCCV[\x90V[_\x90V[a'\xA9a'\xAF\x92a'\xA4_\x93a'\x9Ca'\x84V[P`\x03a\x0F\xB8V[a\x10\x02V[\x01a\t6V[\x90V[_\x7FNot service owner\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a'\xE6`\x11` \x92a\t\xCDV[a'\xEF\x81a'\xB2V[\x01\x90V[a(\x08\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra'\xD9V[\x90V[\x15a(\x12WV[a(\x1Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(0`\x04\x82\x01a'\xF3V[\x03\x90\xFD[P\x90V[_\x7FToo many definitions\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(l`\x14` \x92a\t\xCDV[a(u\x81a(8V[\x01\x90V[a(\x8E\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(_V[\x90V[\x15a(\x98WV[a(\xA0a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(\xB6`\x04\x82\x01a(yV[\x03\x90\xFD[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[a(\xDDa(\xE3\x91\x93\x92\x93a\x05RV[\x92a\x05RV[\x91a(\xEF\x83\x82\x02a\x05RV[\x92\x81\x84\x04\x14\x90\x15\x17\x15a(\xFEWV[a(\xBAV[a)\x0E\x90`\x04a(\xCEV[\x90V[\x90a)$\x90_\x19\x90` \x03`\x08\x02a\x0CjV[\x81T\x16\x90UV[\x1B\x90V[\x91\x90`\x08a)J\x91\x02\x91a)D_\x19\x84a)+V[\x92a)+V[\x91\x81\x19\x16\x91\x16\x17\x90V[a)ha)ca)m\x92a\x05RV[a\x07CV[a\x05RV[\x90V[\x90V[\x91\x90a)\x89a)\x84a)\x91\x93a)TV[a)pV[\x90\x83Ta)/V[\x90UV[a)\xA7\x91a)\xA1a'\x84V[\x91a)sV[V[[\x81\x81\x10a)\xB5WPPV[\x80a)\xC2_`\x01\x93a)\x95V[\x01a)\xAAV[\x90a)\xD8\x90_\x19\x90`\x08\x02a\x0CjV[\x19\x16\x90V[\x81a)\xE7\x91a)\xC8V[\x90`\x02\x02\x17\x90V[\x90_\x91a*\x06a)\xFE\x82a\x08\x11V[\x92\x83Ta)\xDDV[\x90UUV[`\x1F` \x91\x01\x04\x90V[\x91\x92\x90` \x82\x10_\x14a*nW`\x1F\x84\x11`\x01\x14a*>Wa*8\x92\x93Pa)\xDDV[\x90U[[V[P\x90a*da*i\x93`\x01a*[a*U\x85a\x08\x11V[\x92a*\x0BV[\x82\x01\x91\x01a)\xA9V[a)\xEFV[a*;V[Pa*\xA5\x82\x93a*\x7F`\x01\x94a\x08\x11V[a*\x9Ea*\x8B\x85a*\x0BV[\x82\x01\x92`\x1F\x86\x16\x80a*\xB0W[Pa*\x0BV[\x01\x90a)\xA9V[`\x02\x02\x17\x90Ua*<V[a*\xBC\x90\x88\x86\x03a)\x11V[_a*\x98V[\x92\x90\x91`\x01`@\x1B\x82\x11a+\x1DW` \x11_\x14a+\x0EW` \x81\x10_\x14a*\xF2Wa*\xEC\x91a)\xDDV[\x90U[[V[`\x01\x91`\xFF\x19\x16a+\x02\x84a\x08\x11V[U`\x02\x02\x01\x90Ua*\xEFV[`\x01\x91P`\x02\x02\x01\x90Ua*\xF0V[a\x08\xBDV[\x90\x81Ta+.\x81a\x07\xDEV[\x90\x81\x83\x11a+WW[\x81\x83\x10a+EW[PPPPV[a+N\x93a*\x15V[_\x80\x80\x80a+?V[a+c\x83\x83\x83\x87a*\xC2V[a+7V[_a+r\x91a+\"V[V[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[\x90_\x03a+\x99Wa+\x97\x90a+hV[V[a+tV[`\x03_\x91a+\xAE\x83\x80\x83\x01a+\x87V[a+\xBB\x83`\x01\x83\x01a)\x95V[a+\xC8\x83`\x02\x83\x01a)\x95V[\x01UV[\x90_\x03a+\xDEWa+\xDC\x90a+\x9EV[V[a+tV[[\x81\x81\x10a+\xEFWPPV[\x80a+\xFC_`\x04\x93a+\xCCV[\x01a+\xE4V[\x90\x91\x82\x81\x10a,\x11W[PPPV[a,/a,)a,#a,:\x95a)\x03V[\x92a)\x03V[\x92a\x07\x90V[\x91\x82\x01\x91\x01\x90a+\xE3V[_\x80\x80a,\x0CV[\x90`\x01`@\x1B\x81\x11a,fW\x81a,[a,d\x93a\x07\x8CV[\x90\x82\x81Ua,\x02V[V[a\x08\xBDV[_a,u\x91a,BV[V[\x90_\x03a,\x89Wa,\x87\x90a,kV[V[a+tV[a,\xA2a,\x9Da,\xA7\x92a%\xA0V[a\x07CV[a\x05RV[\x90V[`\x01a,\xB6\x91\x01a\x05RV[\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x905\x90`\x01`\x80\x03\x816\x03\x03\x82\x12\x15a,\xDCW\x01\x90V[a,\xB9V[\x90\x82\x10\x15a,\xFBW` a,\xF8\x92\x02\x81\x01\x90a,\xC5V[\x90V[a\x07xV[\x905\x90`\x01` \x03\x816\x03\x03\x82\x12\x15a-@W\x01\x805\x90`\x01\x80`@\x1B\x03\x82\x11a-;W` \x01\x91`\x01\x82\x026\x03\x83\x13a-6WV[a,\xC1V[a,\xBDV[a,\xB9V[\x91V[P\x90V[_\x7FName too long\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-\x80`\r` \x92a\t\xCDV[a-\x89\x81a-LV[\x01\x90V[a-\xA2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-sV[\x90V[\x15a-\xACWV[a-\xB4a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a-\xCA`\x04\x82\x01a-\x8DV[\x03\x90\xFD[5a-\xD8\x81a\x06\xF3V[\x90V[_\x7FInvalid bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a.\x0F`\x0E` \x92a\t\xCDV[a.\x18\x81a-\xDBV[\x01\x90V[a.1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra.\x02V[\x90V[\x15a.;WV[a.Ca\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.Y`\x04\x82\x01a.\x1CV[\x03\x90\xFD[\x90V[_R` _ \x90V[T\x90V[a.v\x81a.iV[\x82\x10\x15a.\x90Wa.\x88`\x04\x91a.`V[\x91\x02\x01\x90_\x90V[a\x07xV[P\x90V[\x91\x90`\x1F\x81\x11a.\xA9W[PPPV[a.\xB5a.\xDA\x93a\x08\x11V[\x90` a.\xC1\x84a*\x0BV[\x83\x01\x93\x10a.\xE2W[a.\xD3\x90a*\x0BV[\x01\x90a)\xA9V[_\x80\x80a.\xA4V[\x91Pa.\xD3\x81\x92\x90Pa.\xCAV[\x91a.\xFB\x90\x82a.\x95V[\x90`\x01\x80`@\x1B\x03\x82\x11a/\xB8Wa/\x1D\x82a/\x17\x85Ta\x07\xDEV[\x85a.\x99V[_\x90`\x1F\x83\x11`\x01\x14a/PW\x91\x80\x91a/?\x93_\x92a/DW[PPa)\xDDV[\x90U[V[\x90\x91P\x015_\x80a/8V[`\x1F\x19\x83\x16\x91a/_\x85a\x08\x11V[\x92_[\x81\x81\x10a/\xA0WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10a/\x86W[PPP\x02\x01\x90Ua/BV[a/\x96\x91\x015`\x1F\x84\x16\x90a)\xC8V[\x90U_\x80\x80a/zV[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a/bV[a\x08\xBDV[\x90a/\xC8\x92\x91a.\xF0V[V[\x90a/\xD6_\x19\x91a&MV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a/\xF5a/\xF0a/\xFC\x92a)TV[a)pV[\x82Ta/\xCAV[\x90UV[5a0\n\x81a\x1E\xE1V[\x90V[\x90a0\x19`\xFF\x91a&MV[\x91\x81\x19\x16\x91\x16\x17\x90V[a0,\x90a\x04\xC0V[\x90V[\x90V[\x90a0Ga0Ba0N\x92a0#V[a0/V[\x82Ta0\rV[\x90UV[\x90a0\xB0```\x03a0\xB6\x94a0v_\x82\x01a0p_\x88\x01\x88a-\0V[\x91a/\xBDV[a0\x8F`\x01\x82\x01a0\x89` \x88\x01a-\xCEV[\x90a/\xE0V[a0\xA8`\x02\x82\x01a0\xA2`@\x88\x01a-\xCEV[\x90a/\xE0V[\x01\x92\x01a0\0V[\x90a02V[V[\x91\x90a0\xC9Wa0\xC7\x91a0RV[V[a+tV[\x90\x81T\x91`\x01`@\x1B\x83\x10\x15a0\xF9W\x82a0\xF1\x91`\x01a0\xF7\x95\x01\x81Ua.mV[\x90a0\xB8V[V[a\x08\xBDV[\x92\x91\x90\x92a113a1+a1%a1 a1\x1B`\x07\x87\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14a(\x0BV[a1_a1?\x85\x84\x90a(4V[a1Xa1Ra1Ma\x15YV[a\x05RV[\x91a\x05RV[\x11\x15a(\x91V[a1t_a1o`\x08\x84\x90a\x07bV[a,wV[a1}_a,\x8EV[[\x80a1\x9Ba1\x95a1\x90\x88\x87\x90a(4V[a\x05RV[\x91a\x05RV[\x10\x15a2nWa2i\x90a1\xF2a1\xD2a1\xCCa1\xC6a1\xBD\x8A\x89\x87\x91a,\xE1V[_\x81\x01\x90a-\0V[\x90a-EV[\x90a-HV[a1\xEBa1\xE5a1\xE0a\x19\x03V[a\x05RV[\x91a\x05RV[\x11\x15a-\xA5V[a2;a2\x0C`@a2\x06\x89\x88\x86\x91a,\xE1V[\x01a-\xCEV[a24a2.a2)` a2#\x8C\x8B\x89\x91a,\xE1V[\x01a-\xCEV[a\x05RV[\x91a\x05RV[\x10\x15a.4V[a2da2Ra2M`\x08\x86\x90a\x07bV[a.]V[a2^\x88\x87\x85\x91a,\xE1V[\x90a0\xCEV[a,\xAAV[a1~V[PPP\x90PV[_\x7FZero address\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a2\xA9`\x0C` \x92a\t\xCDV[a2\xB2\x81a2uV[\x01\x90V[a2\xCB\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra2\x9CV[\x90V[\x15a2\xD5WV[a2\xDDa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a2\xF3`\x04\x82\x01a2\xB6V[\x03\x90\xFD[\x90a3\x01\x90a\x07FV[_R` R`@_ \x90V[\x90V[a3\x19\x90a\x0E\xF1V[\x90V[a3%\x90a\t\x1AV[\x90V[\x91\x90a3>a39a3F\x93a3\x10V[a3\x1CV[\x90\x83Ta)/V[\x90UV[_\x90V[a3`\x91a3Za3JV[\x91a3(V[V[_`\x02a3\x81\x92a3u\x83\x80\x83\x01a)\x95V[\x82`\x01\x82\x01U\x01a3NV[V[\x90_\x03a3\x95Wa3\x93\x90a3bV[V[a+tV[`H\x1B\x90V[\x90a3\xAF`\xFF`H\x1B\x91a3\x9AV[\x91\x81\x19\x16\x91\x16\x17\x90V[a3\xC2\x90a\x11GV[\x90V[\x90V[\x90a3\xDDa3\xD8a3\xE4\x92a3\xB9V[a3\xC5V[\x82Ta3\xA0V[\x90UV[a4$3a4\x1Ea4\x18\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEDV[\x91a\x03\xEDV[\x14a%VV[a4I\x82a4Ba4<a47_a%\xBFV[a\x03\xEDV[\x91a\x03\xEDV[\x14\x15a2\xCEV[a4oa4ja4ca4^`\x06\x85\x90a2\xF7V[a3\rV[\x84\x90ad\xAAV[a&$V[a4\x8E_a4\x89a4\x82`\x03\x85\x90a\x0F\xB8V[\x85\x90a\x10\x02V[a3\x83V[a4\xB1`\x02`\x01a4\xABa4\xA4`\x03\x86\x90a\x0F\xB8V[\x86\x90a\x10\x02V[\x01a3\xC8V[\x90a4\xE5a4\xDF\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK\x93a\x07FV[\x91a\x0F\xF6V[\x91a4\xEEa\x03\xA2V[\x80a4\xF8\x81a\x04IV[\x03\x90\xA3V[a5\x0E\x90a5\tad\xE4V[a5\x10V[V[a5\x1B\x90`\x0Ba&pV[V[a5&\x90a4\xFDV[V[_\x7FNot registered operator\0\0\0\0\0\0\0\0\0\x91\x01RV[a5\\`\x17` \x92a\t\xCDV[a5e\x81a5(V[\x01\x90V[a5~\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra5OV[\x90V[\x15a5\x88WV[a5\x90a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a5\xA6`\x04\x82\x01a5iV[\x03\x90\xFD[\x90a5\xDF\x97\x96\x95\x94\x93\x92\x91a5\xDAa5\xD5a5\xCEa5\xC9\x84`\x06a2\xF7V[a3\rV[3\x90ae2V[a5\x81V[a8\x1EV[V[a5\xF5a5\xF0a5\xFA\x92a\x03\xB4V[a\x07CV[a\x05RV[\x90V[a6\x11a6\x0Ca6\x16\x92a\x05RV[a\x07CV[a\x03\xB4V[\x90V[\x91` a6:\x92\x94\x93a63`@\x82\x01\x96_\x83\x01\x90a\x0C\x13V[\x01\x90a\x0C\x13V[V[a6Ka6Q\x91\x93\x92\x93a\x05RV[\x92a\x05RV[\x82\x03\x91\x82\x11a6\\WV[a(\xBAV[`\x01\x80`@\x1B\x03\x81\x11a6}Wa6y` \x91a\x08\xB3V[\x01\x90V[a\x08\xBDV[\x90\x92\x91\x92a6\x97a6\x92\x82a6aV[a\x16\xA8V[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a6\xB3Wa6\xB1\x92a\x17\x05V[V[a\x16\xE0V[a6\xC3\x916\x91a6\x82V[\x90V[` \x01\x90V[Q\x90V[\x94\x92\x90\x97\x96\x95\x93\x91`\xE0\x86\x01\x98_\x87\x01a6\xE9\x91a\x0E\xF4V[` \x86\x01a6\xF6\x91a\x0C\xAEV[`@\x85\x01a7\x03\x91a\x0C\x13V[``\x84\x01a7\x10\x91a\x0C\x13V[`\x80\x83\x01a7\x1D\x91a\x11\x17V[`\xA0\x82\x01a7*\x91a\x0E\xF4V[`\xC0\x01a76\x91a\x0C\x13V[V[_a\x19\x01`\xF0\x1B\x91\x01RV[a7P`\x02\x80\x92a\x1D\x0FV[a7Y\x81a78V[\x01\x90V[\x90V[a7la7q\x91a\x0E\xF1V[a7]V[\x90RV[` \x80\x93\x92a7\x90a7\x89a7\x98\x94a7DV[\x80\x92a7`V[\x01\x80\x92a7`V[\x01\x90V[_\x7FInvalid signature\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a7\xD0`\x11` \x92a\t\xCDV[a7\xD9\x81a7\x9CV[\x01\x90V[a7\xF2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra7\xC3V[\x90V[\x15a7\xFCWV[a8\x04a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a8\x1A`\x04\x82\x01a7\xDDV[\x03\x90\xFD[\x91\x92\x93\x94\x97\x96\x90\x95\x97\x80a8:a84Ba\x05RV[\x91a5\xE1V[\x11a9\xA2Wa8RBa8L\x83a5\xE1V[\x90a6<V[a8ka8ea8`a\r\x05V[a5\xE1V[\x91a\x05RV[\x11a9zWa9x\x97\x98a9Oa9m\x93\x85a8\xD9\x8Aa8\xCA\x8Da9U\x98\x8D\x8Da8\xA1a8\x96a$aV[\x963\x99\x95\x92\x93a6\xB8V[a8\xB3a8\xAD\x82a6\xCCV[\x91a6\xC6V[ \x92\x93a8\xBEa\x03\xA2V[\x98\x89\x97` \x89\x01a6\xD0V[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD1V[a8\xEBa8\xE5\x82a6\xCCV[\x91a6\xC6V[ a96\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a9'a9\x1Ba\x03\xA2V[\x93\x84\x92` \x84\x01a7uV[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD1V[a9Ha9B\x82a6\xCCV[\x91a6\xC6V[ \x92a6\xB8V[\x90aelV[a9ga9a3a\x03\xEDV[\x91a\x03\xEDV[\x14a7\xF5V[\x933\x91\x92\x93\x94af\xE9V[V[a9\x83Ba5\xFDV[\x90a9\x9E_\x92\x83\x92c\x185[u`\xE2\x1B\x84R`\x04\x84\x01a6\x19V[\x03\x90\xFD[a9\xABBa5\xFDV[\x90a9\xC6_\x92\x83\x92cW\xEA\x02\xE9`\xE0\x1B\x84R`\x04\x84\x01a6\x19V[\x03\x90\xFD[\x90a9\xDA\x97\x96\x95\x94\x93\x92\x91a5\xAAV[V[``\x90V[\x90` \x82\x82\x03\x12a:\x0FW_\x82\x015`\x01\x80`@\x1B\x03\x81\x11a:\nWa:\x07\x92\x01a\x18-V[\x90V[a\x03\xB0V[a\x03\xACV[\x90a:+\x91a:!a9\xDCV[P\x90\x81\x01\x90a9\xE1V[\x90V[a:Ma:Ha:R\x92a:@a'\x84V[P`\x05a2\xF7V[a3\rV[aj\xFBV[\x90V[``\x90V[`\x01\x80`@\x1B\x03\x81\x11a:pW` \x80\x91\x02\x01\x90V[a\x08\xBDV[\x90a:\x87a:\x82\x83a:ZV[a\x16\xA8V[\x91\x82RV[6\x907V[\x90a:\xB6a:\x9E\x83a:uV[\x92` \x80a:\xAC\x86\x93a:ZV[\x92\x01\x91\x03\x90a:\x8CV[V[\x90a:\xC2\x82a\x12(V[\x81\x10\x15a:\xD3W` \x80\x91\x02\x01\x01\x90V[a\x07xV[\x90a:\xE2\x90a\x03\xEDV[\x90RV[\x90a:\xEFa:UV[Pa;\x0Ca;\x07a;\x02`\x04\x85\x90a2\xF7V[a3\rV[aj\xFBV[\x91a;\x16\x83a:\x91V[\x91a; _a,\x8EV[[\x80a;4a;.\x87a\x05RV[\x91a\x05RV[\x10\x15a;{Wa;v\x90a;qa;_a;Xa;S`\x04\x88\x90a2\xF7V[a3\rV[\x83\x90akJV[a;l\x87\x91\x84\x90\x92a:\xB8V[a:\xD8V[a,\xAAV[a;!V[P\x92PP\x90V[_\x90V[\x90a;\x8Fa;\x82V[Pa;\xB1`\x01a;\xABa;\xA4`\x03\x86\x90a\x0F\xB8V[\x84\x90a\x10\x02V[\x01a\x10\x91V[a;\xC3a;\xBD_a\x11GV[\x91a\x11GV[\x14\x91\x82\x15a;\xD1W[PP\x90V[a;\xF2\x92P`\x01\x91a;\xE7a;\xEC\x92`\x03a\x0F\xB8V[a\x10\x02V[\x01a\x10\x91V[a<\x05a;\xFF`\x01a\x11GV[\x91a\x11GV[\x14_\x80a;\xCCV[a<3\x90a<\x19a:UV[P_\x90a<-a<'a\x13\x1BV[\x92a,\x8EV[\x90aIyV[P\x90V[\x90a<i\x94\x93\x92\x91a<da<_a<Xa<S\x84`\x06a2\xF7V[a3\rV[3\x90ae2V[a5\x81V[a<kV[V[\x91a<}\x94\x92\x93\x913\x91\x92\x93\x94af\xE9V[V[\x90a<\x8C\x94\x93\x92\x91a<7V[V[\x90a<\xAEa<\xA9a<\xB3\x93a<\xA1a;\x82V[P`\x06a2\xF7V[a3\rV[ae2V[\x90V[_\x90V[a<\xDCa<\xE2\x92a<\xD7`\x01\x93a<\xCFa<\xB6V[P`\x03a\x0F\xB8V[a\x10\x02V[\x01a\x10\x91V[\x90V[a<\xEE\x90a\x0F\xEAV[\x90V[_\x7FInternal only\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a=%`\r` \x92a\t\xCDV[a=.\x81a<\xF1V[\x01\x90V[a=G\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra=\x18V[\x90V[\x15a=QWV[a=Ya\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a=o`\x04\x82\x01a=2V[\x03\x90\xFD[`\x01\x80`@\x1B\x03\x81\x11a=\x89W` \x80\x91\x02\x01\x90V[a\x08\xBDV[\x90a=\xA0a=\x9B\x83a=sV[a\x16\xA8V[\x91\x82RV[6\x907V[\x90a=\xCFa=\xB7\x83a=\x8EV[\x92` \x80a=\xC5\x86\x93a=sV[\x92\x01\x91\x03\x90a=\xA5V[V[\x90a=\xDB\x82a\r\x87V[\x81\x10\x15a=\xECW` \x80\x91\x02\x01\x01\x90V[a\x07xV[\x90V[Q\x90V[\x90a>\x02\x82a=\xF4V[\x81\x10\x15a>\x13W` \x80\x91\x02\x01\x01\x90V[a\x07xV[\x90a>\"\x90a\x0E\xF1V[\x90RV[``\x90V[\x90V[` \x91\x81R\x01\x90V[\x90_\x92\x91\x80T\x90a>Qa>J\x83a\x07\xDEV[\x80\x94a>.V[\x91`\x01\x81\x16\x90\x81_\x14a>\xA8WP`\x01\x14a>lW[PPPV[a>y\x91\x92\x93\x94Pa\x07\x99V[\x91_\x92[\x81\x84\x10a>\x90WPP\x01\x90_\x80\x80a>gV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a>}V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a>gV[\x90a>\xCD\x91a>7V[\x90V[\x90a>\xF0a>\xE9\x92a>\xE0a\x03\xA2V[\x93\x84\x80\x92a>\xC3V[\x03\x83a\x08\xD1V[V[a>\xFB\x90a>\xD0V[\x90V[a?\x08\x90Qa\x0E\xF1V[\x90V[a?\x15\x90Qa\x05RV[\x90V[_\x7FValue out of bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a?L`\x13` \x92a\t\xCDV[a?U\x81a?\x18V[\x01\x90V[a?qa?\x7F\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra\t\xE1V[\x90` \x81\x83\x03\x91\x01Ra??V[\x90V[\x92\x91` a?\x9Ea?\xA6\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\t\xE1V[\x94\x01\x90a\x05UV[V[\x90_\x92\x91\x80T\x90a?\xC2a?\xBB\x83a\x07\xDEV[\x80\x94a\t\xCDV[\x91`\x01\x81\x16\x90\x81_\x14a@\x19WP`\x01\x14a?\xDDW[PPPV[a?\xEA\x91\x92\x93\x94Pa\x08\x11V[\x91_\x92[\x81\x84\x10a@\x01WPP\x01\x90_\x80\x80a?\xD8V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a?\xEEV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a?\xD8V[_\x7FRequired metric missing\0\0\0\0\0\0\0\0\0\x91\x01RV[a@h`\x17` \x92a\t\xCDV[a@q\x81a@4V[\x01\x90V[a@\x8Da@\x9B\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra?\xA8V[\x90` \x81\x83\x03\x91\x01Ra@[V[\x90V[\x92\x93\x90\x93a@\xC63a@\xC0a@\xBAa@\xB50a<\xE5V[a\x03\xEDV[\x91a\x03\xEDV[\x14a=JV[a@\xDAa@\xD5`\x08\x86\x90a\x07bV[a.]V[\x94a@\xE4\x82a=\xAAV[\x94a@\xEE_a,\x8EV[[\x80aA\x02a@\xFC\x86a\x05RV[\x91a\x05RV[\x10\x15aAUWaAP\x90aAKaA&_aA\x1E\x8A\x85\x90a=\xD1V[Q\x01Qa=\xF1V[aA8aA2\x82a6\xCCV[\x91a6\xC6V[ aAF\x8A\x91\x84\x90\x92a=\xF8V[a>\x18V[a,\xAAV[a@\xEFV[P\x91\x94\x90\x92\x95aAd\x81a.iV[aAvaAp_a,\x8EV[\x91a\x05RV[\x11\x96aA\x80a>&V[\x90\x88aF\0W[aA\x90_a,\x8EV[[\x80aA\xA4aA\x9E\x8Ba\x05RV[\x91a\x05RV[\x10\x15aDcW`\x01_\x8BaB\x97W[P\x90\x88\x87\x89aA\xC9\x94aA\xCEW[PPPa,\xAAV[aA\x91V[\x82_aB\x0CaB\x04aB\x15\x94aA\xFFaA\xF7` aA\xF0aB\x1A\x9B\x8D\x90a=\xD1V[Q\x01a?\x0BV[\x97`\ta\x1C\xE3V[a\x1C\xF9V[\x92\x87\x90a=\xD1V[Q\x01Q\x90a\x1D\x8AV[a/\xE0V[\x88\x87\x89\x90aBD` aB=_aB2\x87\x89\x90a=\xD1V[Q\x01Q\x95\x87\x90a=\xD1V[Q\x01a?\x0BV[aBwaBq\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD\x93a\x07FV[\x93a\x0F\xF6V[\x93aB\x8CaB\x83a\x03\xA2V[\x92\x83\x92\x83a?\x82V[\x03\x90\xA3\x88\x87\x89aA\xC1V[\x9A\x90\x95\x92\x91\x99aB\xA6_a,\x8EV[[\x80aB\xC2aB\xBCaB\xB7\x8Aa.iV[a\x05RV[\x91a\x05RV[\x10\x15aDMWaB\xDAaB\xD5\x8D\x87a=\xF8V[a>\xFEV[aB\xFEaB\xF8aB\xF3aB\xEE\x8A\x86\x90a=\xF8V[a>\xFEV[a\x0E\xF1V[\x91a\x0E\xF1V[\x14aC\x11WaC\x0C\x90a,\xAAV[aB\xA7V[\x8A\x91\x9B\x92\x9CP\x89aA\xC9\x94\x95\x98\x8A\x92`\x01\x90\x8AaC;` aC4\x89\x8B\x90a=\xD1V[Q\x01a?\x0BV[aCcaC]aCX`\x01aCQ\x86\x88\x90a.mV[P\x01a\t6V[a\x05RV[\x91a\x05RV[\x10\x91\x88\x88\x84\x15aD\x03W[PPPPaC\x98W[aC\x82\x90[\x15a\x04\xC0V[aC\x91W[\x93\x94PPPaA\xB3V[P_aC\x87V[\x90P\x82\x82_aC\xA8\x87\x89\x90a=\xD1V[Q\x01Q\x91aC\xF4aC\xE2aC\xDC\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07FV[\x93a\x0F\xF6V[\x93aC\xEBa\x03\xA2V[\x91\x82\x91\x82a?YV[\x03\x90\xA3aC\x82_\x91\x90PaCwV[aDC\x93\x94PaD1aD=\x93aD+` aD$aD8\x96`\x02\x96a=\xD1V[Q\x01a?\x0BV[\x96a.mV[P\x01a\t6V[a\x05RV[\x91a\x05RV[\x11\x8A_\x88\x88aCnV[P\x99\x90\x9A\x87\x89aA\xC9\x94\x95\x98aC\x82\x8D\x94aC|V[P\x97PP\x92\x93P\x93PaDu_a,\x8EV[\x93[\x84aD\x92aD\x8CaD\x87\x86a.iV[a\x05RV[\x91a\x05RV[\x10\x15aE\xF9WaD\xB8aD\xB2`\x03aD\xAB\x86\x89\x90a.mV[P\x01a\t]V[\x15a\x04\xC0V[aE\xEEWaD\xDAaD\xD5_aD\xCE\x86\x89\x90a.mV[P\x01a>+V[a>\xF2V[aD\xECaD\xE6\x82a6\xCCV[\x91a6\xC6V[ \x90_\x96aD\xF9_a,\x8EV[[\x80aE\x15aE\x0FaE\n\x86a=\xF4V[a\x05RV[\x91a\x05RV[\x10\x15aE\xDCWaE.aE)\x84\x83\x90a=\xF8V[a>\xFEV[aE@aE:\x86a\x0E\xF1V[\x91a\x0E\xF1V[\x14aESWaEN\x90a,\xAAV[aD\xFAV[P\x95\x90\x96PaEt\x91PaEi`\x01[\x15a\x04\xC0V[aE{W[[a,\xAAV[\x93\x94aDwV[\x82\x85_aE\x89\x87\x85\x90a.mV[P\x01\x91aE\xD4aE\xC2aE\xBC\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07FV[\x93a\x0F\xF6V[\x93aE\xCBa\x03\xA2V[\x91\x82\x91\x82a@uV[\x03\x90\xA3aEnV[P\x95\x90\x96aEt\x92PaEi\x90aEcV[\x94\x93aEt\x90aEoV[PPPPPV[\x96\x93\x90PaF\x1AaF\x15\x83\x97\x94\x99\x96\x93a.iV[a=\xAAV[\x97aF$_a,\x8EV[[\x80aF@aF:aF5\x8Ba.iV[a\x05RV[\x91a\x05RV[\x10\x15aF\x9AWaF\x95\x90aF\x90aFkaFf_aF_\x8D\x86\x90a.mV[P\x01a>+V[a>\xF2V[aF}aFw\x82a6\xCCV[\x91a6\xC6V[ aF\x8B\x8D\x91\x84\x90\x92a=\xF8V[a>\x18V[a,\xAAV[aF%V[P\x92\x95\x91\x94\x97\x90\x93\x96aA\x87V[aF\xB0ad\xE4V[aF\xB8aF\xBAV[V[aF\xCBaF\xC6_a%\xBFV[ak\xE2V[V[aF\xD5aF\xA8V[V[aF\xE1`\xA0a\x16\xA8V[\x90V[_\x90V[_\x90V[_\x90V[aF\xF8aF\xD7V[\x90` \x80\x80\x80\x80\x86aG\x08aF\xE4V[\x81R\x01aG\x13a'&V[\x81R\x01aG\x1Ea'*V[\x81R\x01aG)aF\xE8V[\x81R\x01aG4aF\xECV[\x81RPPV[aGBaF\xF0V[\x90V[\x90aGO\x90a\x05RV[\x90RV[\x90aG]\x90a\x03\xB4V[\x90RV[\x90aGk\x90a\x04\xADV[\x90RV[\x90aGy\x90a\x11GV[\x90RV[\x90aG\xFCaG\xF3`\x02aG\x8EaF\xD7V[\x94aG\xA5aG\x9D_\x83\x01a\t6V[_\x88\x01aGEV[aG\xBDaG\xB4`\x01\x83\x01a\x107V[` \x88\x01aGSV[aG\xD5aG\xCC`\x01\x83\x01a\x10dV[`@\x88\x01aGaV[aG\xEDaG\xE4`\x01\x83\x01a\x10\x91V[``\x88\x01aGoV[\x01a\x10\xB5V[`\x80\x84\x01a>\x18V[V[aH\x07\x90aG}V[\x90V[aH/\x91aH%aH*\x92aH\x1DaG:V[P`\x03a\x0F\xB8V[a\x10\x02V[aG\xFEV[\x90V[_\x90V[\x90aH@\x90a\x07FV[_R` R`@_ \x90V[\x90aHV\x90a\x0F\xF6V[_R` R`@_ \x90V[aH\x87\x91aH}aH\x82\x92aHuaH2V[P`\x0CaH6V[aHLV[a\x107V[\x90V[aH\x92ak\xF8V[aH\x9Aa^RV[aH\xACaH\xA6\x83a\x03\xEDV[\x91a\x03\xEDV[\x03aH\xBCWaH\xBA\x90ak\xE2V[V[aH\xD7\x90_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xBBV[\x03\x90\xFD[aH\xFAaH\xF5aH\xFF\x92aH\xEDa'\x84V[P`\x04a2\xF7V[a3\rV[aj\xFBV[\x90V[aI\x0C\x90Qa\x04\xADV[\x90V[aI#aI\x1EaI(\x92a%\xA0V[a\x07CV[a\x04\xADV[\x90V[aI5\x90Qa\x03\xB4V[\x90V[aILaIGaIQ\x92a\x04\xADV[a\x07CV[a\x05RV[\x90V[aIcaIi\x91\x93\x92\x93a\x05RV[\x92a\x05RV[\x82\x01\x80\x92\x11aItWV[a(\xBAV[\x90\x92\x91\x92aI\x85a:UV[PaI\x8Ea'\x84V[PaI\x98\x82ac\xCCV[\x93aI\xB5aI\xB0aI\xAB`\x05\x86\x90a2\xF7V[a3\rV[aj\xFBV[\x92aI\xC2` \x87\x01aI\x02V[aI\xD4aI\xCE_aI\x0FV[\x91a\x04\xADV[\x14\x80\x15aJ\xC6W[\x80\x15aJ\xABW[aJ\x91WaJ\x1D\x86aJ\x17aJ\x12` aJ\x0BaJ\x06_aJz\x9B\x9C\x9D\x01aI+V[a5\xE1V[\x93\x01aI\x02V[aI8V[\x90a(\xCEV[\x91\x80aJ8aJ2aJ-a\x13\x1BV[a\x05RV[\x91a\x05RV[\x11_\x14aJ\x8CWPaJHa\x13\x1BV[[aJT\x84\x82\x90aITV[aJfaJ`\x88a\x05RV[\x91a\x05RV[\x11_\x14aJ}WP\x84[\x90\x92\x90\x91\x92al.V[\x91V[aJ\x87\x90\x84aITV[aJpV[aJIV[PPP\x91PaJ\xA7aJ\xA2_a,\x8EV[a:\x91V[\x91\x90V[P\x82aJ\xBFaJ\xB9\x86a\x05RV[\x91a\x05RV[\x10\x15aI\xE3V[P\x83aJ\xDAaJ\xD4_a,\x8EV[\x91a\x05RV[\x14aI\xDCV[aJ\xF1\x90aJ\xECad\xE4V[aJ\xF3V[V[aJ\xFE\x90`\na&pV[V[aK\t\x90aJ\xE0V[V[_\x90V[aK\x17aK\x0BV[PaK!_a%\x93V[\x90V[P\x90V[\x91\x90\x81\x10\x15aK8W` \x02\x01\x90V[a\x07xV[5aKG\x81a\x03\xF9V[\x90V[_\x80\xFD[`\xE0\x1B\x90V[_\x91\x03\x12aK^WV[a\x03\xACV[\x91` aK\x84\x92\x94\x93aK}`@\x82\x01\x96_\x83\x01\x90a\x0C\x13V[\x01\x90a\x0C\xAEV[V[aK\x8Ea\x03\xA2V[=_\x82>=\x90\xFD[\x90\x92\x91\x92aK\xA3_a,\x8EV[[\x80aK\xC1aK\xBBaK\xB6\x85\x89\x90aK$V[a\x05RV[\x91a\x05RV[\x10\x15aLpWaK\xD00a<\xE5V[\x90c\xBA\x1F\xB1\x03\x84aK\xEBaK\xE6\x86\x8A\x86\x91aK(V[aK=V[\x93\x80;\x15aLkWaL\x10_\x80\x94aL\x1BaL\x04a\x03\xA2V[\x98\x89\x96\x87\x95\x86\x94aKNV[\x84R`\x04\x84\x01aKcV[\x03\x92Z\xF1\x91\x82\x15aLfWaL5\x92aL:W[Pa,\xAAV[aK\xA4V[aLY\x90_=\x81\x11aL_W[aLQ\x81\x83a\x08\xD1V[\x81\x01\x90aKTV[_aL/V[P=aLGV[aK\x86V[aKJV[PPP\x90PV[_\x7FNot slashing oracle\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aL\xAB`\x13` \x92a\t\xCDV[aL\xB4\x81aLwV[\x01\x90V[aL\xCD\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaL\x9EV[\x90V[\x15aL\xD7WV[aL\xDFa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aL\xF5`\x04\x82\x01aL\xB8V[\x03\x90\xFD[_\x7FOperator unknown\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aM-`\x10` \x92a\t\xCDV[aM6\x81aL\xF9V[\x01\x90V[aMO\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaM V[\x90V[\x15aMYWV[aMaa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aMw`\x04\x82\x01aM:V[\x03\x90\xFD[\x90V[\x90aM\x8F`\x01\x80`@\x1B\x03\x91a&MV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90aM\xB1aM\xACaM\xB8\x92a\x07FV[aM\x99V[\x82TaM~V[\x90UV[\x91\x90aM\xD6\x81aM\xCF\x81aM\xDB\x95a\t\xCDV[\x80\x95a\x17\x05V[a\x08\xB3V[\x01\x90V[\x90\x91aM\xF6\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaM\xBCV[\x90V[aN\x1E3aN\x18aN\x12aN\r`\na%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14aL\xD0V[aNDaN?aN8aN3`\x05\x85\x90a2\xF7V[a3\rV[\x84\x90ae2V[aMRV[aNpaNeaN`aNY`\x03\x85\x90a\x0F\xB8V[\x85\x90a\x10\x02V[aM{V[`\x01`\x03\x91\x01a3\xC8V[aN\x8EaN\x87aN\x82`\x04\x84\x90a2\xF7V[a3\rV[\x83\x90amJV[PaN\xB6aN\x9BBa5\xFDV[aN\xB1aN\xAA`\x0C\x85\x90aH6V[\x85\x90aHLV[aM\x9CV[\x90\x91\x92aN\xECaN\xE6\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07FV[\x93a\x0F\xF6V[\x93aO\x01aN\xF8a\x03\xA2V[\x92\x83\x92\x83aM\xDFV[\x03\x90\xA3V[aO\x10`\x80a\x16\xA8V[\x90V[aO\x1E\x916\x91a\x17\x10V[\x90V[RV[\x90aO.\x90a\x04\xC0V[\x90RV[Q\x90V[\x90aO@\x81a\t\xC9V[\x90`\x01\x80`@\x1B\x03\x82\x11aO\xFEWaOb\x82aO\\\x85Ta\x07\xDEV[\x85a.\x99V[` \x90`\x1F\x83\x11`\x01\x14aO\x96W\x91\x80\x91aO\x85\x93_\x92aO\x8AW[PPa)\xDDV[\x90U[V[\x90\x91P\x01Q_\x80aO~V[`\x1F\x19\x83\x16\x91aO\xA5\x85a\x08\x11V[\x92_[\x81\x81\x10aO\xE6WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10aO\xCCW[PPP\x02\x01\x90UaO\x88V[aO\xDC\x91\x01Q`\x1F\x84\x16\x90a)\xC8V[\x90U_\x80\x80aO\xC0V[\x91\x93` `\x01\x81\x92\x87\x87\x01Q\x81U\x01\x95\x01\x92\x01aO\xA8V[a\x08\xBDV[\x90aP\r\x91aO6V[V[aP\x19\x90Qa\x04\xC0V[\x90V[\x90aPy```\x03aP\x7F\x94aP?_\x82\x01aP9_\x88\x01aO2V[\x90aP\x03V[aPX`\x01\x82\x01aPR` \x88\x01a?\x0BV[\x90a/\xE0V[aPq`\x02\x82\x01aPk`@\x88\x01a?\x0BV[\x90a/\xE0V[\x01\x92\x01aP\x0FV[\x90a02V[V[\x91\x90aP\x92WaP\x90\x91aP\x1CV[V[a+tV[\x90\x81T\x91`\x01`@\x1B\x83\x10\x15aP\xC2W\x82aP\xBA\x91`\x01aP\xC0\x95\x01\x81Ua.mV[\x90aP\x81V[V[a\x08\xBDV[aQ\xE5\x95aQ\xCE\x84\x96aQ\xC5aQ\xBDaQ\xA9aQ\xA4aQ\xD7\x97aQJaQ*aQ$aQ\xE0\x9D\x8D\x9F\x9DaQ\x1F3aQ\x19aQ\x13aQ\x0EaQ\t`\x07\x8C\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14a(\x0BV[a-EV[\x90a-HV[aQCaQ=aQ8a\x19\x03V[a\x05RV[\x91a\x05RV[\x11\x15a-\xA5V[aQg\x86aQ`aQZ\x8Da\x05RV[\x91a\x05RV[\x10\x15a.4V[aQ\x9DaQ~aQy`\x08\x84\x90a\x07bV[a\x07\x8CV[aQ\x97aQ\x91aQ\x8Ca\x15YV[a\x05RV[\x91a\x05RV[\x10a(\x91V[`\x08a\x07bV[a.]V[\x98\x99\x96\x92\x94\x96aQ\xB7aO\x06V[\x9AaO\x13V[_\x8A\x01aO!V[` \x88\x01aGEV[`@\x86\x01aGEV[``\x84\x01aO$V[aP\x97V[V[aR\x15\x90aR\x10aR\x0BaR\x04aQ\xFF\x84`\x06a2\xF7V[a3\rV[3\x90ae2V[a5\x81V[aR\xF1V[V[_\x7FCannot go online while slashed\0\0\x91\x01RV[aRK`\x1E` \x92a\t\xCDV[aRT\x81aR\x17V[\x01\x90V[aRm\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaR>V[\x90V[`@\x1B\x90V[\x90aR\x85`\xFF`@\x1B\x91aRpV[\x91\x81\x19\x16\x91\x16\x17\x90V[aR\xA3aR\x9EaR\xA8\x92a\x04\xADV[a\x07CV[a\x04\xADV[\x90V[\x90V[\x90aR\xC3aR\xBEaR\xCA\x92aR\x8FV[aR\xABV[\x82TaRvV[\x90UV[\x91` aR\xEF\x92\x94\x93aR\xE8`@\x82\x01\x96_\x83\x01\x90a\x11_V[\x01\x90a\x11_V[V[aS\x0FaS\naS\x03`\x03\x84\x90a\x0F\xB8V[3\x90a\x10\x02V[aM{V[\x90aS\x1C`\x01\x83\x01a\x10\x91V[\x91\x82aS1aS+`\x03a\x11GV[\x91a\x11GV[\x14aTUW\x82aSIaSC_a\x11GV[\x91a\x11GV[\x14\x80\x15aT:W[aT5WaSx\x90aSf`\x01\x80\x83\x01a3\xC8V[`\x01aSq_aI\x0FV[\x91\x01aR\xAEV[aS\x96aS\x8FaS\x8A`\x04\x84\x90a2\xF7V[a3\rV[3\x90ad\xAAV[P\x803aS\xCCaS\xC6\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07FV[\x91a\x0F\xF6V[\x91aS\xD5a\x03\xA2V[\x80aS\xDF\x81a\x04IV[\x03\x90\xA3\x903\x90\x91`\x01aT\x1BaT\x15\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07FV[\x93a\x0F\xF6V[\x93aT0aT'a\x03\xA2V[\x92\x83\x92\x83aR\xCEV[\x03\x90\xA3V[PPPV[P\x82aTOaTI`\x01a\x11GV[\x91a\x11GV[\x14aSQV[aT]a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aTs`\x04\x82\x01aRXV[\x03\x90\xFD[aT\x80\x90aQ\xE7V[V[_\x7FNot authorized\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aT\xB6`\x0E` \x92a\t\xCDV[aT\xBF\x81aT\x82V[\x01\x90V[aT\xD8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaT\xA9V[\x90V[\x15aT\xE2WV[aT\xEAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aU\0`\x04\x82\x01aT\xC3V[\x03\x90\xFD[\x90V[aU\x1BaU\x16aU \x92aU\x04V[a\x07CV[a\x03\xB4V[\x90V[_\x7FInterval too short\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aUW`\x12` \x92a\t\xCDV[aU`\x81aU#V[\x01\x90V[aUy\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaUJV[\x90V[\x15aU\x83WV[aU\x8Ba\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aU\xA1`\x04\x82\x01aUdV[\x03\x90\xFD[\x90V[aU\xBCaU\xB7aU\xC1\x92aU\xA5V[a\x07CV[a\x04\xADV[\x90V[_\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\xF8`\x17` \x92a\t\xCDV[aV\x01\x81aU\xC4V[\x01\x90V[aV\x1A\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaU\xEBV[\x90V[\x15aV$WV[aV,a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aVB`\x04\x82\x01aV\x05V[\x03\x90\xFD[aVP``a\x16\xA8V[\x90V[\x90aVhaVcaVo\x92a0#V[a0/V[\x82Ta3\xA0V[\x90UV[\x90aV\xB5`@_aV\xBB\x94aV\x95\x82\x82\x01aV\x8F\x84\x88\x01aI+V[\x90aM\x9CV[aV\xAD\x82\x82\x01aV\xA7` \x88\x01aI\x02V[\x90aR\xAEV[\x01\x92\x01aP\x0FV[\x90aVSV[V[\x90aV\xC7\x91aVsV[V[\x91` aV\xEA\x92\x94\x93aV\xE3`@\x82\x01\x96_\x83\x01\x90a\x0C\x13V[\x01\x90a\x11\x17V[V[3aW\x1FaW\x19\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEDV[\x91a\x03\xEDV[\x14\x80\x15aX\x0BW[aW0\x90aT\xDBV[aWN\x82aWGaWA`<aU\x07V[\x91a\x03\xB4V[\x10\x15aU|V[aWl\x83aWeaW_`\x01aU\xA8V[\x91a\x04\xADV[\x10\x15aV\x1DV[aW\xC5\x82aW\xB4\x85aW\xABaW\x8D_aW\x87`\x02\x89\x90a\"]V[\x01a\"\x87V[\x91aW\xA2aW\x99aVFV[\x95_\x87\x01aGSV[` \x85\x01aGaV[`@\x83\x01aO$V[aW\xC0`\x02\x84\x90a\"]V[aV\xBDV[\x90\x91aW\xF1\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x92a\x07FV[\x92aX\x06aW\xFDa\x03\xA2V[\x92\x83\x92\x83aV\xC9V[\x03\x90\xA2V[PaW03aX5aX/aX*aX%`\x07\x87\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14\x90PaW'V[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[aX]aXc\x91a\x05RV[\x91a\x05RV[\x90\x81\x15aXnW\x04\x90V[aX=V[aX\x87aX\x82aX\x8C\x92a\x05RV[a\x07CV[a\x04\xADV[\x90V[aX\xA3aX\x9EaX\xA8\x92a%\xA0V[a\x07CV[a\x03\xB4V[\x90V[aX\xC9aX\xC4aX\xBD`\x03\x84\x90a\x0F\xB8V[\x84\x90a\x10\x02V[aM{V[\x90aX\xD3\x81ac\xCCV[aX\xDF`\x01\x84\x01a\x10\x91V[aX\xF2aX\xEC`\x03a\x11GV[\x91a\x11GV[\x14a[\x06WaY\x02_\x84\x01a\t6V[aY\x14aY\x0E_a,\x8EV[\x91a\x05RV[\x14a[\0WaYJaY1BaY+_\x87\x01a\t6V[\x90a6<V[aYDaY?_\x85\x01aI+V[a5\xE1V[\x90aXQV[\x80aY^aYX`\xFFaI8V[\x91a\x05RV[\x11_\x14aZ\xF2WP`\xFF[\x90\x81aY\x88aY\x82aY}`\x01\x88\x01a\x10dV[a\x04\xADV[\x91a\x04\xADV[\x11aY\x95W[PPPPPV[aY\xA2\x82`\x01\x86\x01aR\xAEV[aY\xB7aY\xAE_aX\x8FV[`\x01\x86\x01aM\x9CV[aY\xD5aY\xCFaY\xCA` \x85\x94\x01aI\x02V[a\x04\xADV[\x91a\x04\xADV[\x10\x15\x80aZ\xCBW[aY\xE8W[\x80aY\x8EV[aZ\x03aY\xF7`\x01\x85\x01a\x10\x91V[\x93`\x01`\x02\x91\x01a3\xC8V[aZ!aZ\x1AaZ\x15`\x04\x85\x90a2\xF7V[a3\rV[\x85\x90amJV[P\x81\x90\x84\x90\x91aZoaZ]aZW\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM\x93a\x07FV[\x93a\x0F\xF6V[\x93aZfa\x03\xA2V[\x91\x82\x91\x82a\x16\x13V[\x03\x90\xA3\x91\x90\x91`\x02aZ\xAAaZ\xA4\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07FV[\x93a\x0F\xF6V[\x93aZ\xBFaZ\xB6a\x03\xA2V[\x92\x83\x92\x83aR\xCEV[\x03\x90\xA3_\x80\x80\x80aY\xE2V[PaZ\xD8`\x01\x84\x01a\x10\x91V[aZ\xEBaZ\xE5`\x02a\x11GV[\x91a\x11GV[\x14\x15aY\xDDV[aZ\xFB\x90aXsV[aYiV[PPPPV[PPPPV[``\x90V[`\x01\x80`@\x1B\x03\x81\x11a['W` \x80\x91\x02\x01\x90V[a\x08\xBDV[\x90a[>a[9\x83a[\x11V[a\x16\xA8V[\x91\x82RV[a[M`\x80a\x16\xA8V[\x90V[\x90a[\xB7a[\xAE`\x03a[aa[CV[\x94a[xa[p_\x83\x01a\x08\xF8V[_\x88\x01aO!V[a[\x90a[\x87`\x01\x83\x01a\t6V[` \x88\x01aGEV[a[\xA8a[\x9F`\x02\x83\x01a\t6V[`@\x88\x01aGEV[\x01a\t]V[``\x84\x01aO$V[V[a[\xC2\x90a[PV[\x90V[\x90a[\xCF\x82a\x07\x8CV[a[\xD8\x81a[,V[\x92a[\xE6` \x85\x01\x91a\x07\x90V[_\x91[\x83\x83\x10a[\xF6WPPPPV[`\x04` `\x01\x92a\\\x06\x85a[\xB9V[\x81R\x01\x92\x01\x92\x01\x91\x90a[\xE9V[a\\\x1D\x90a[\xC5V[\x90V[a\\7a\\<\x91a\\/a[\x0CV[P`\x08a\x07bV[a\\\x14V[\x90V[a\\m\x90a\\ha\\ca\\\\a\\W\x84`\x06a2\xF7V[a3\rV[3\x90ae2V[a5\x81V[a\\\xC8V[V[_\x7FCannot go offline while slashed\0\x91\x01RV[a\\\xA3`\x1F` \x92a\t\xCDV[a\\\xAC\x81a\\oV[\x01\x90V[a\\\xC5\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra\\\x96V[\x90V[a\\\xE6a\\\xE1a\\\xDA`\x03\x84\x90a\x0F\xB8V[3\x90a\x10\x02V[aM{V[\x90a\\\xF3`\x01\x83\x01a\x10\x91V[\x91\x82a]\x08a]\x02`\x03a\x11GV[\x91a\x11GV[\x14a]\x8EWa]\x1C\x90`\x01`\x04\x91\x01a3\xC8V[a]:a]3a].`\x04\x84\x90a2\xF7V[a3\rV[3\x90amJV[P\x903\x90\x91`\x04a]ta]n\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07FV[\x93a\x0F\xF6V[\x93a]\x89a]\x80a\x03\xA2V[\x92\x83\x92\x83aR\xCEV[\x03\x90\xA3V[a]\x96a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a]\xAC`\x04\x82\x01a\\\xB0V[\x03\x90\xFD[a]\xB9\x90a\\?V[V[\x90\x91\x82a]\xCB\x81a]\xD2\x93a\x1D\x0FV[\x80\x93a\x17\x05V[\x01\x90V[a]\xE7\x90` \x94\x93a]\xEE\x93a]\xBBV[\x80\x92a\x1D@V[\x01\x90V[\x90\x91a^\t\x90a^\0a\x03\xA2V[\x93\x84\x93\x84a]\xD6V[\x03\x90 \x90V[\x90\x91a^\x1A\x92a]\xF2V[\x90V[\x92a^Ba^J\x93\x92a^=a^O\x96a^5a'\x84V[P`\ta\x1C\xE3V[a\x1C\xF9V[\x91\x90\x91a^\x0FV[a\t6V[\x90V[a^ZaK\x0BV[Pa^e`\x01a%\x93V[\x90V[a^r\x90Qa\x11GV[\x90V[\x90V[a^\x8Ca^\x87a^\x91\x92a^uV[a\x07CV[a\x05RV[\x90V[` \x7Fl\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x7FOperator not eligible for remova_\x82\x01R\x01RV[a^\xEE`!`@\x92a\t\xCDV[a^\xF7\x81a^\x94V[\x01\x90V[a_\x10\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra^\xE1V[\x90V[\x15a_\x1AWV[a_\"a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a_8`\x04\x82\x01a^\xFBV[\x03\x90\xFD[\x90a_\xEDa_\xE8a_\xF2\x933a_ma_ga_ba_]`\x07\x86\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14\x80\x15a`\xABW[a_~\x90aT\xDBV[a_\x9Ca_\x97a_\x90`\x03\x84\x90a\x0F\xB8V[\x86\x90a\x10\x02V[aG\xFEV[a_\xA8``\x82\x01a^hV[a_\xBBa_\xB5`\x03a\x11GV[\x91a\x11GV[\x03a_\xF5W[Pa_\xE0a_\xD9a_\xD4`\x05\x84\x90a2\xF7V[a3\rV[\x85\x90amJV[P`\x04a2\xF7V[a3\rV[amJV[PV[a`q\x90a`Ea`5a`\x08\x85ac\xCCV[a`/a`*` a`#a`\x1E_\x86\x01aI+V[a5\xE1V[\x93\x01aI\x02V[aI8V[\x90a(\xCEV[a`?`\na^xV[\x90a(\xCEV[a`P_\x83\x01a?\x0BV[a`ba`\\_a,\x8EV[\x91a\x05RV[\x11\x91\x82a`wW[PPa_\x13V[_a_\xC1V[a`\xA2\x91\x92Pa`\x96a`\x9C\x91a`\x90_B\x92\x01a?\x0BV[\x90a6<V[\x92a\x05RV[\x91a\x05RV[\x10\x15_\x80a`jV[Pa_~3a`\xC9a`\xC3a`\xBEaK\x0FV[a\x03\xEDV[\x91a\x03\xEDV[\x14\x90Pa_uV[\x90a`\xFBaa\0\x91a`\xE1a;\x82V[Pa`\xF6a`\xEE\x85ac\xCCV[\x94`\x03a\x0F\xB8V[a\x10\x02V[aG\xFEV[aa\x0B_\x82\x01a?\x0BV[aa\x1Daa\x17_a,\x8EV[\x91a\x05RV[\x14aaXWaaNaaI_aaBaaT\x94aa<\x83B\x92\x01a?\x0BV[\x90a6<V[\x94\x01aI+V[a5\xE1V[\x91a\x05RV[\x10\x90V[PP_\x90V[aao\x90aajad\xE4V[aaqV[V[aa|\x81`\x01a&pV[aa\x84aK\x0FV[\x90aa\xB8aa\xB2\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0\x93a\x0F\xF6V[\x91a\x0F\xF6V[\x91aa\xC1a\x03\xA2V[\x80aa\xCB\x81a\x04IV[\x03\x90\xA3V[aa\xD9\x90aa^V[V[_ab\x1Aab \x93ab\x123ab\x0Cab\x06ab\x01aa\xFC`\x07\x8A\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14a(\x0BV[\x92`\x02a\"]V[\x01aVSV[V[_\x7FNot registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[abV`\x0E` \x92a\t\xCDV[ab_\x81ab\"V[\x01\x90V[abx\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RabIV[\x90V[\x15ab\x82WV[ab\x8Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80ab\xA0`\x04\x82\x01abcV[\x03\x90\xFD[ab\xE03ab\xDAab\xD4\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEDV[\x91a\x03\xEDV[\x14a%VV[ac\x06ac\x01ab\xFAab\xF5`\x06\x85\x90a2\xF7V[a3\rV[\x84\x90amJV[ab{V[ac$ac\x1Dac\x18`\x04\x84\x90a2\xF7V[a3\rV[\x83\x90amJV[P\x90acYacS\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E\x93a\x07FV[\x91a\x0F\xF6V[\x91acba\x03\xA2V[\x80acl\x81a\x04IV[\x03\x90\xA3V[\x90ac\xBEac\xB5_ac\x81a'\x19V[\x94ac\x98ac\x90\x83\x83\x01a\x107V[\x83\x88\x01aGSV[ac\xAFac\xA6\x83\x83\x01a\x10dV[` \x88\x01aGaV[\x01a\"\x87V[`@\x84\x01aO$V[V[ac\xC9\x90acqV[\x90V[ac\xE3ac\xE8\x91ac\xDBa'dV[P`\x02a\"]V[ac\xC0V[ac\xF3_\x82\x01aI+V[ad\x05ac\xFF_aX\x8FV[\x91a\x03\xB4V[\x14adKW[ad\x17` \x82\x01aI\x02V[ad)ad#_aI\x0FV[\x91a\x04\xADV[\x14ad2W[\x90V[adFad=a\x15\xFBV[` \x83\x01aGaV[ad/V[ad^adVa\x0B\xFAV[_\x83\x01aGSV[ad\x0BV[adl\x90a\x0F\xCEV[\x90V[ad\x83ad~ad\x88\x92a\x03\xE2V[a\x07CV[a\x05RV[\x90V[ad\x9Fad\x9Aad\xA4\x92a\x05RV[a&MV[a\x0E\xF1V[\x90V[\x90V[\x90ad\xDCad\xD6ad\xD1ad\xCC_ad\xE1\x96ad\xC4a;\x82V[P\x01\x94adcV[adoV[ad\x8BV[\x91ad\xA7V[an\x06V[\x90V[ad\xECaK\x0FV[ae\x05ad\xFFad\xFAak\xF8V[a\x03\xEDV[\x91a\x03\xEDV[\x03ae\x0CWV[ae.ae\x17ak\xF8V[_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xBBV[\x03\x90\xFD[\x90aedae^aeYaeT_aei\x96aeLa;\x82V[P\x01\x94adcV[adoV[ad\x8BV[\x91ad\xA7V[aniV[\x90V[ae\x8B\x91ae\x82\x91ae|aK\x0BV[Pan\xC5V[\x90\x92\x91\x92ao\x85V[\x90V[_\x7FOperator is slashed\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[ae\xC2`\x13` \x92a\t\xCDV[ae\xCB\x81ae\x8EV[\x01\x90V[ae\xE4\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rae\xB5V[\x90V[\x15ae\xEEWV[ae\xF6a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80af\x0C`\x04\x82\x01ae\xCFV[\x03\x90\xFD[\x90af%af af,\x92a3\x10V[a3\x1CV[\x82Ta/\xCAV[\x90UV[af9\x90a\x03\xB4V[`\x01\x80`@\x1B\x03\x81\x14afLW`\x01\x01\x90V[a(\xBAV[\x90V[afhafcafm\x92afQV[a\x07CV[a\x04\xADV[\x90V[\x91` af\x91\x92\x94\x93af\x8A`@\x82\x01\x96_\x83\x01\x90a\x11\x17V[\x01\x90a\x05UV[V[af\x9C\x90a\x0F\xCEV[\x90V[af\xA8\x90af\x93V[\x90V[af\xB4\x90a\x0F\xEAV[\x90V[`@\x90af\xE0af\xE7\x94\x96\x95\x93\x96af\xD6``\x84\x01\x98_\x85\x01\x90a\x0C\xAEV[` \x83\x01\x90a\x0C\x13V[\x01\x90a\x0C\x13V[V[\x94\x92\x93\x91\x93ag\x0Cag\x07ag\0`\x03\x89\x90a\x0F\xB8V[\x87\x90a\x10\x02V[aM{V[\x93ag\x16\x87ac\xCCV[\x93ag@ag&`\x01\x88\x01a\x10\x91V[ag9ag3`\x03a\x11GV[\x91a\x11GV[\x14\x15ae\xE7V[ag^agWagR`\x05\x8B\x90a2\xF7V[a3\rV[\x88\x90ad\xAAV[Pah3`@agp`\x01\x89\x01a\x10\x91V[\x96ag}B_\x8B\x01a/\xE0V[ag\xA7ag\x8B\x85\x87\x90a6\xB8V[ag\x9Dag\x97\x82a6\xCCV[\x91a6\xC6V[ `\x02\x8B\x01af\x10V[ag\xBCag\xB3_aI\x0FV[`\x01\x8B\x01aR\xAEV[ag\xDA`\x01\x8A\x01ag\xD4ag\xCF\x82a\x107V[af0V[\x90aM\x9CV[ag\xE2a<\xB6V[P\x85ag\xF6ag\xF0_aI\x0FV[\x91a\x04\xADV[\x14_\x14aj\xB7Wah\r_\x99[`\x01\x8B\x91\x01a3\xC8V[\x87ah!ah\x1B`\x02a\x11GV[\x91a\x11GV[\x14\x80aj\x9BW[aj-W[\x01aP\x0FV[\x80aj\tW[ai\xF3W[PP\x85\x91\x85\x91\x92Bah\x82ah|ahv\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x94a\x07FV[\x94a\x07FV[\x94a\x0F\xF6V[\x94ah\x97ah\x8Ea\x03\xA2V[\x92\x83\x92\x83afpV[\x03\x90\xA4\x80ah\xADah\xA7\x84a\x11GV[\x91a\x11GV[\x03ai\x9DW[PPah\xBF`\x0Ba%\x93V[ah\xD9ah\xD3ah\xCE_a%\xBFV[a\x03\xEDV[\x91a\x03\xEDV[\x03ah\xE3W[PPV[ah\xFDah\xF8ah\xF3`\x0Ba%\x93V[af\x9FV[af\xABV[\x91c\xD4xS\xB6\x91\x90\x92ai\x0FBa5\xFDV[\x92\x81;\x15ai\x98W_ai5\x91ai@\x82\x96ai)a\x03\xA2V[\x98\x89\x97\x88\x96\x87\x95aKNV[\x85R`\x04\x85\x01af\xB7V[\x03\x92Z\xF1\x90\x81ailW[P\x15_\x14aigW`\x01aibW[[_\x80ah\xDFV[aiZV[ai[V[ai\x8B\x90_=\x81\x11ai\x91W[ai\x83\x81\x83a\x08\xD1V[\x81\x01\x90aKTV[_aiKV[P=aiyV[aKJV[\x83\x83\x91\x92ai\xD4ai\xCE\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07FV[\x93a\x0F\xF6V[\x93ai\xE9ai\xE0a\x03\xA2V[\x92\x83\x92\x83aR\xCEV[\x03\x90\xA3_\x80ah\xB3V[aj\x02\x91\x88\x91\x88\x90\x91\x92at:V[_\x80ah>V[Paj\x15\x81\x83\x90a-HV[aj'aj!_a,\x8EV[\x91a\x05RV[\x11ah9V[ajJajCaj>\x8D`\x04a2\xF7V[a3\rV[\x8B\x90ad\xAAV[P\x8A\x8Aaj\x80ajz\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07FV[\x91a\x0F\xF6V[\x91aj\x89a\x03\xA2V[\x80aj\x93\x81a\x04IV[\x03\x90\xA3ah-V[P\x88aj\xB0aj\xAA`\x02a\x11GV[\x91a\x11GV[\x14\x15ah(V[\x85aj\xCBaj\xC5`dafTV[\x91a\x04\xADV[\x10_\x14aj\xDEWah\r`\x01\x99[ah\x03V[ah\r`\x01\x99aj\xF6\x8D\x8D\x8B\x90\x8B\x90\x8A\x92\x8C\x94ap\xF4V[aj\xD9V[ak\x12_ak\x17\x92ak\x0Ba'\x84V[P\x01ad\xA7V[au\xF8V[\x90V[ak&ak+\x91a\t\x1AV[a)TV[\x90V[akBak=akG\x92a\x05RV[a\x07CV[a\x03\xE2V[\x90V[akuakpak\x7F\x93akk_akz\x95akdaK\x0BV[P\x01ad\xA7V[avfV[ak\x1AV[ak.V[a\x0F\xEAV[\x90V[\x91\x90`\x08ak\xA2\x91\x02\x91ak\x9C`\x01\x80`\xA0\x1B\x03\x84a)+V[\x92a)+V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x91\x90ak\xC2ak\xBDak\xCA\x93a\x0F\xF6V[a&mV[\x90\x83Tak\x82V[\x90UV[ak\xE0\x91ak\xDAaK\x0BV[\x91ak\xACV[V[ak\xF6\x90ak\xF1_`\x01ak\xCEV[av\x87V[V[al\0aK\x0BV[P3\x90V[al\x0E\x90a\x05RV[_\x19\x81\x14al\x1CW`\x01\x01\x90V[a(\xBAV[al+\x90Qa\x03\xEDV[\x90V[\x93\x91\x92\x93al:a:UV[PalNalI\x85\x84\x90a6<V[a:\x91V[\x92alX_a,\x8EV[\x92[\x80almalg\x88a\x05RV[\x91a\x05RV[\x10\x15al\xDBWal\x91al\x8Aal\x85`\x05\x86\x90a2\xF7V[a3\rV[\x82\x90akJV[al\x9D\x84\x82\x8A\x91av\xE6V[al\xB1W[Pal\xAC\x90a,\xAAV[alZV[al\xAC\x91\x94al\xCFal\xD4\x92al\xCA\x89\x91\x84\x90\x92a:\xB8V[a:\xD8V[al\x05V[\x93\x90al\xA2V[P\x94PP\x91Pal\xEA\x82a:\x91V[\x92al\xF4_a,\x8EV[[\x80am\x08am\x02\x86a\x05RV[\x91a\x05RV[\x10\x15amDWam?\x90am:am(am#\x86\x84\x90a:\xB8V[al!V[am5\x88\x91\x84\x90\x92a:\xB8V[a:\xD8V[a,\xAAV[al\xF5V[P\x91PPV[\x90am|amvamqaml_am\x81\x96amda;\x82V[P\x01\x94adcV[adoV[ad\x8BV[\x91ad\xA7V[ax\x1EV[\x90V[\x90V[_R` _ \x90V[T\x90V[am\x9D\x81am\x90V[\x82\x10\x15am\xB7Wam\xAF`\x01\x91am\x87V[\x91\x02\x01\x90_\x90V[a\x07xV[\x90\x81T\x91`\x01`@\x1B\x83\x10\x15am\xE7W\x82am\xDF\x91`\x01am\xE5\x95\x01\x81Uam\x94V[\x90a3(V[V[a\x08\xBDV[T\x90V[\x90am\xFA\x90a3\x10V[_R` R`@_ \x90V[an\x0Ea;\x82V[Pan#an\x1D\x82\x84\x90aniV[\x15a\x04\xC0V[_\x14ancWanYan^\x92anEan>_\x85\x01am\x84V[\x82\x90am\xBCV[`\x01anR_\x85\x01am\xECV[\x93\x01am\xF0V[a/\xE0V[`\x01\x90V[PP_\x90V[an\x87\x91`\x01an\x82\x92an{a;\x82V[P\x01am\xF0V[a\t6V[an\x99an\x93_a,\x8EV[\x91a\x05RV[\x14\x15\x90V[_\x90V[\x90V[an\xB9an\xB4an\xBE\x92an\xA2V[a\x07CV[a\x05RV[\x90V[_\x90V[\x91\x90\x91an\xD0aK\x0BV[Pan\xD9an\x9EV[Pan\xE2a3JV[Pan\xEC\x83a6\xCCV[an\xFFan\xF9`Aan\xA5V[\x91a\x05RV[\x14_\x14aoFWao?\x91\x92ao\x13a3JV[Pao\x1Ca3JV[Pao%an\xC1V[P` \x81\x01Q```@\x83\x01Q\x92\x01Q_\x1A\x90\x91\x92ay\x9DV[\x91\x92\x90\x91\x90V[PaoP_a%\xBFV[\x90aodao_`\x02\x94a6\xCCV[ad\x8BV[\x91\x92\x91\x90V[`\x04\x11\x15aotWV[a\x11$V[\x90ao\x83\x82aojV[V[\x80ao\x98ao\x92_aoyV[\x91aoyV[\x14_\x14ao\xA3WPPV[\x80ao\xB7ao\xB1`\x01aoyV[\x91aoyV[\x14_\x14ao\xDAW_c\xF6E\xEE\xDF`\xE0\x1B\x81R\x80ao\xD6`\x04\x82\x01a\x04IV[\x03\x90\xFD[\x80ao\xEEao\xE8`\x02aoyV[\x91aoyV[\x14_\x14ap\x1CWap\x18ap\x01\x83ak\x1AV[_\x91\x82\x91c\xFC\xE6\x98\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x05bV[\x03\x90\xFD[ap/ap)`\x03aoyV[\x91aoyV[\x14ap7WPV[apR\x90_\x91\x82\x91c5\xE2\xF3\x83`\xE2\x1B\x83R`\x04\x83\x01a\x0F\x01V[\x03\x90\xFD[apjapeapo\x92a\x12\xFCV[a\x07CV[a\x04\xADV[\x90V[ap~ap\x84\x91a\x03\xB4V[\x91a\x03\xB4V[\x90\x03\x90`\x01\x80`@\x1B\x03\x82\x11ap\x96WV[a(\xBAV[_\x7FProtocol violation reported\0\0\0\0\0\x91\x01RV[ap\xCF`\x1B` \x92a\t\xCDV[ap\xD8\x81ap\x9BV[\x01\x90V[ap\xF1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rap\xC2V[\x90V[\x93PP\x92Paq\x0Caq\x06`\xC8apVV[\x91a\x04\xADV[\x10\x15aq\x17W[PPV[aq Ba5\xFDV[aq>aq9aq2`\x0C\x85\x90aH6V[\x85\x90aHLV[a\x107V[\x80aqQaqK_aX\x8FV[\x91a\x03\xB4V[\x14\x90\x81\x15aq\xD7W[PaqfW[Paq\x13V[aq\x85\x90aq\x80aqy`\x0C\x85\x90aH6V[\x85\x90aHLV[aM\x9CV[\x90aq\xB9aq\xB3\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07FV[\x91a\x0F\xF6V[\x91aq\xC2a\x03\xA2V[\x80aq\xCC\x81ap\xDCV[\x03\x90\xA3_\x80\x80aq`V[aq\xE2\x91P\x82aprV[aq\xFBaq\xF5aq\xF0a\x0FjV[a\x03\xB4V[\x91a\x03\xB4V[\x10\x15_aqZV[\x90V[ar\x1Aar\x15ar\x1F\x92ar\x03V[a\x07CV[a\x05RV[\x90V[\x90\x92\x91\x92ar7ar2\x82a\x16\xE4V[a\x16\xA8V[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11arSWarQ\x92a\t\xD6V[V[a\x16\xE0V[\x90\x80`\x1F\x83\x01\x12\x15arvW\x81` ars\x93Q\x91\x01ar\"V[\x90V[a\x05\xADV[\x90PQ\x90ar\x88\x82a\x06\xF3V[V[\x91\x90\x91`@\x81\x84\x03\x12ar\xDBWar\xA1`@a\x16\xA8V[\x92_\x82\x01Q\x91`\x01\x80`@\x1B\x03\x83\x11ar\xD6War\xC3\x82ar\xCF\x94\x83\x01arXV[_\x86\x01R` \x01ar{V[` \x83\x01RV[a\x16\xDCV[a\x16\xD8V[\x92\x91\x90ar\xF4ar\xEF\x82a\x16\xBDV[a\x16\xA8V[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11asIW\x81\x90[\x83\x82\x10as\x1AWPPPPPV[\x81Q`\x01\x80`@\x1B\x03\x81\x11asDW` \x91as9\x87\x84\x93\x87\x01ar\x8AV[\x81R\x01\x91\x01\x90as\x0CV[a\x05\xADV[a\x05\xB5V[\x90\x80`\x1F\x83\x01\x12\x15aslW\x81` asi\x93Q\x91\x01ar\xE0V[\x90V[a\x05\xADV[\x90` \x82\x82\x03\x12as\x9FW_\x82\x01Q`\x01\x80`@\x1B\x03\x81\x11as\x9AWas\x97\x92\x01asNV[\x90V[a\x03\xB0V[a\x03\xACV[` \x91\x81R\x01\x90V[\x91\x90as\xC7\x81as\xC0\x81as\xCC\x95as\xA4V[\x80\x95a\x17\x05V[a\x08\xB3V[\x01\x90V[\x90\x91as\xE7\x92` \x83\x01\x92_\x81\x85\x03\x91\x01Ras\xADV[\x90V[as\xF4`2a\x15=V[\x90V[\x94\x93\x91``\x91at8\x94at#at0\x93at\x19`\x80\x8B\x01\x94_\x8C\x01\x90a\x0C\x13V[` \x8A\x01\x90a\x0C\xAEV[\x87\x82\x03`@\x89\x01Ra\x0E\x18V[\x94\x01\x90a\x05UV[V[\x91atF\x81\x85\x90a-HV[atXatR_a,\x8EV[\x91a\x05RV[\x14au\xF2Wath\x81\x85\x90a-HV[at|atva\xC3Par\x06V[\x91a\x05RV[\x11au\xECW_at\x8Aa9\xDCV[\x94at\x940a<\xE5V[at\xB6c1\xE3\xBD\x1B\x94\x92\x94at\xC1at\xAAa\x03\xA2V[\x96\x87\x95\x86\x94\x85\x94aKNV[\x84R`\x04\x84\x01as\xD0V[\x03\x91Z\xFA\x80\x91_\x92au\xC8W[P\x15_\x14au\xBFWP`\x01au\xBAW[at\xE7\x83a\r\x87V[au\0at\xFAat\xF5as\xEAV[a\x05RV[\x91a\x05RV[\x11_\x14au\xACWau\x0Fas\xEAV[[au\x190a<\xE5V[\x90ce\xA6\x93n\x93\x92\x94\x90\x82;\x15au\xA7W_\x94auT\x86\x92auI\x94au=a\x03\xA2V[\x99\x8A\x98\x89\x97\x88\x96aKNV[\x86R`\x04\x86\x01as\xF7V[\x03\x92Z\xF1\x90\x81au{W[P\x15_\x14auvW`\x01auqW[[V[aunV[auoV[au\x9A\x90_=\x81\x11au\xA0W[au\x92\x81\x83a\x08\xD1V[\x81\x01\x90aKTV[_au_V[P=au\x88V[aKJV[au\xB5\x83a\r\x87V[au\x10V[PPPV[\x90\x92P\x91at\xDEV[au\xE5\x91\x92P=\x80_\x83>au\xDD\x81\x83a\x08\xD1V[\x81\x01\x90asqV[\x90_at\xCEV[PPPPV[PPPPV[_av\x0C\x91av\x05a'\x84V[P\x01am\xECV[\x90V[_R` _ \x90V[av!\x81am\xECV[\x82\x10\x15av;Wav3`\x01\x91av\x0FV[\x91\x02\x01\x90_\x90V[a\x07xV[avP\x90`\x08avU\x93\x02a\x0CjV[a\x10\x9EV[\x90V[\x90avc\x91Tav@V[\x90V[av\x84\x91_av~\x92avwa3JV[P\x01av\x18V[\x90avXV[\x90V[av\x90_a%\x93V[av\x9A\x82_a&pV[\x90av\xCEav\xC8\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x0F\xF6V[\x91a\x0F\xF6V[\x91av\xD7a\x03\xA2V[\x80av\xE1\x81a\x04IV[\x03\x90\xA3V[av\xEEa;\x82V[Paw\x16aw\x10aw\taw\x04`\x06\x85\x90a2\xF7V[a3\rV[\x84\x90ae2V[\x15a\x04\xC0V[aw\xB8Waw6\x91aw,aw1\x92`\x03a\x0F\xB8V[a\x10\x02V[aG\xFEV[awA_\x82\x01a?\x0BV[awSawM_a,\x8EV[\x91a\x05RV[\x14\x80\x15aw\x92W[aw\x8CWaw\x81aw{aw\x87\x92awu_B\x92\x01a?\x0BV[\x90a6<V[\x92a\x05RV[\x91a\x05RV[\x10\x15\x90V[PP_\x90V[Paw\x9F``\x82\x01a^hV[aw\xB2aw\xAC`\x03a\x11GV[\x91a\x11GV[\x14aw[V[PPP_\x90V[aw\xD3aw\xCEaw\xD8\x92aU\xA5V[a\x07CV[a\x05RV[\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[aw\xF8\x81am\x90V[\x80\x15ax\x19W`\x01\x90\x03\x90ax\x16ax\x10\x83\x83am\x94V[\x90a3NV[UV[aw\xDBV[ax&a;\x82V[Pax=ax8`\x01\x83\x01\x84\x90am\xF0V[a\t6V[\x90\x81axQaxK_a,\x8EV[\x91a\x05RV[\x14\x15_\x14ay\x1DWax\xCF\x92`\x01ax\xCA\x92\x84axx_\x96axr\x85aw\xBFV[\x90a6<V[ax\x95ax\x86\x88\x85\x01am\xECV[ax\x8F\x86aw\xBFV[\x90a6<V[\x81ax\xA8ax\xA2\x83a\x05RV[\x91a\x05RV[\x03ax\xD4W[PPPax\xC4ax\xBF\x86\x83\x01am\x84V[aw\xEFV[\x01am\xF0V[a)\x95V[`\x01\x90V[ay\x15\x92ay\x07ax\xF3ax\xEDay\x10\x94\x8C\x89\x01av\x18V[\x90avXV[\x93ay\x01\x85\x91\x8C\x89\x01av\x18V[\x90a3(V[\x91\x85\x85\x01am\xF0V[a/\xE0V[_\x80\x80ax\xAEV[PPP_\x90V[\x90V[ay;ay6ay@\x92ay$V[a\x07CV[a\x05RV[\x90V[ayxay\x7F\x94ayn``\x94\x98\x97\x95ayd`\x80\x86\x01\x9A_\x87\x01\x90a\x0E\xF4V[` \x85\x01\x90a\x11\x17V[`@\x83\x01\x90a\x0E\xF4V[\x01\x90a\x0E\xF4V[V[ay\x95ay\x90ay\x9A\x92a%\xA0V[a&MV[a\x0E\xF1V[\x90V[\x93\x92\x93ay\xA8aK\x0BV[Pay\xB1an\x9EV[Pay\xBAa3JV[Pay\xC4\x85ak\x1AV[ay\xECay\xE6o\xA2\xA8\x91\x8C\xA8[\xAF\xE2 \x16\xD0\xB9\x97\xE4\xDF``\x01`\xFF\x1B\x03ay'V[\x91a\x05RV[\x11azyW\x90az\x0F` \x94\x95_\x94\x93\x92\x93az\x06a\x03\xA2V[\x94\x85\x94\x85ayCV[\x83\x80R\x03\x90`\x01Z\xFA\x15aztWaz'_Qa&MV[\x80azBaz<az7_a%\xBFV[a\x03\xEDV[\x91a\x03\xEDV[\x14azXW_\x91azR_ay\x81V[\x91\x92\x91\x90V[Pazb_a%\xBFV[`\x01\x91azn_ay\x81V[\x91\x92\x91\x90V[aK\x86V[PPPaz\x85_a%\xBFV[\x90`\x03\x92\x91\x92\x91\x90V\xFE\xA1dsolcC\0\x08\x1A\0\n",
    );
    /// The runtime bytecode of the contract, as deployed on the network.
    ///
    /// ```text
    ///0x60806040526004361015610013575b6124f9565b61001d5f3561039c565b806305778550146103975780630758236f146103925780630c76697a1461038d578063191cbd1a146103885780631e8f5ee514610383578063208129561461037e57806322f1ec93146103795780632bf4d6a7146103745780632c9576881461036f5780632dae18851461036a5780632f4bd7b81461036557806331e3bd1b146103605780633644e5151461035b5780633ac3cbe6146103565780633e6e34a7146103515780633fd62c6d1461034c57806340235a9c1461034757806348f4da20146103425780635685cf681461033d57806356c4e17d1461033857806359dcea12146103335780635a936dc61461032e5780635cce98a6146103295780636076439c1461032457806360cf09911461031f57806361d6b86c1461031a57806362c7e8fc1461031557806365a6936e146103105780636bfe06a61461030b578063715018a61461030657806371e7388c146103015780637639d227146102fc57806379ba5097146102f75780637b9f64b2146102f257806381beac2e146102ed57806384ef7322146102e85780638da5cb5b146102e357806396686c1e146102de5780639cbdae22146102d9578063adff830c146102d4578063ae470a85146102cf578063b074e9dd146102ca578063b99f6759146102c5578063ba1fb103146102c0578063c1ef9ddf146102bb578063c5d960bb146102b6578063cfe34749146102b1578063d551162c146102ac578063da435a7c146102a7578063e30c3978146102a2578063e65cafcb1461029d578063ee1c039014610298578063f2fde38b14610293578063f9107f3b1461028e578063f9f16762146102895763ffcf08f00361000e576124c5565b612490565b61242d565b6123cd565b612397565b612363565b61232e565b6122f6565b612224565b6121ef565b6121ad565b612178565b61204e565b61201a565b611fad565b611f73565b611eaa565b611de7565b611c60565b611baa565b611b77565b611b40565b611aab565b611a78565b611a42565b611a0c565b611950565b61191b565b6118ad565b611672565b611628565b6115a6565b611571565b611503565b611470565b611417565b6113e2565b61137d565b611333565b6112c7565b6111f3565b6111b9565b610f83565b610f16565b610e97565b610d1e565b610cd0565b610c35565b610b8f565b610a62565b6106c0565b61066e565b61063a565b610577565b61051d565b61044e565b60e01c90565b60405190565b5f80fd5b5f80fd5b5f80fd5b60018060401b031690565b6103c8816103b4565b036103cf57565b5f80fd5b905035906103e0826103bf565b565b60018060a01b031690565b6103f6906103e2565b90565b610402816103ed565b0361040957565b5f80fd5b9050359061041a826103f9565b565b91906040838203126104445780610438610441925f86016103d3565b9360200161040d565b90565b6103ac565b5f0190565b3461047d5761046761046136600461041c565b90612690565b61046f6103a2565b8061047981610449565b0390f35b6103a8565b9060208282031261049b57610498915f016103d3565b90565b6103ac565b6104a9906103b4565b9052565b60ff1690565b6104bc906104ad565b9052565b151590565b6104ce906104c0565b9052565b90604080610506936104ea5f8201515f8601906104a0565b6104fc602082015160208601906104b3565b01519101906104c5565b565b919061051b905f606085019401906104d2565b565b3461054d57610549610538610533366004610482565b61276f565b6105406103a2565b91829182610508565b0390f35b6103a8565b90565b61055e90610552565b9052565b9190610575905f60208501940190610555565b565b346105a8576105a461059361058d36600461041c565b90612788565b61059b6103a2565b91829182610562565b0390f35b6103a8565b5f80fd5b5f80fd5b5f80fd5b909182601f830112156105f15781359160018060401b0383116105ec5760200192602083028401116105e757565b6105b5565b6105b1565b6105ad565b9190916040818403126106355761060f835f83016103d3565b92602082013560018060401b0381116106305761062c92016105b9565b9091565b6103b0565b6103ac565b346106695761065361064d3660046105f6565b916130fe565b61065b6103a2565b8061066581610449565b0390f35b6103a8565b3461069d5761068761068136600461041c565b906133e8565b61068f6103a2565b8061069981610449565b0390f35b6103a8565b906020828203126106bb576106b8915f0161040d565b90565b6103ac565b346106ee576106d86106d33660046106a2565b61351d565b6106e06103a2565b806106ea81610449565b0390f35b6103a8565b6106fc81610552565b0361070357565b5f80fd5b90503590610714826106f3565b565b919060408382031261073e578061073261073b925f86016103d3565b93602001610707565b90565b6103ac565b90565b61075a61075561075f926103b4565b610743565b6103b4565b90565b9061076c90610746565b5f5260205260405f2090565b634e487b7160e01b5f52603260045260245ffd5b5490565b5f5260205f2090565b5f5260205f2090565b6107ab8161078c565b8210156107c5576107bd600491610790565b910201905f90565b610778565b634e487b7160e01b5f52602260045260245ffd5b90600160028304921680156107fe575b60208310146107f957565b6107ca565b91607f16916107ee565b60209181520190565b5f5260205f2090565b905f929180549061083461082d836107de565b8094610808565b916001811690815f1461088b575060011461084f575b505050565b61085c9192939450610811565b915f925b81841061087357505001905f808061084a565b60018160209295939554848601520191019290610860565b92949550505060ff19168252151560200201905f808061084a565b906108b09161081a565b90565b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b906108db906108b3565b810190811060018060401b038211176108f357604052565b6108bd565b90610918610911926109086103a2565b938480926108a6565b03836108d1565b565b5f1c90565b90565b61092e6109339161091a565b61091f565b90565b6109409054610922565b90565b60ff1690565b61095561095a9161091a565b610943565b90565b6109679054610949565b90565b610975906008610762565b9061097f8261078c565b8110156109c55761098f916107a2565b509061099c5f83016108f8565b916109a960018201610936565b916109c260036109bb60028501610936565b930161095d565b90565b5f80fd5b5190565b60209181520190565b90825f9392825e0152565b610a00610a09602093610a0e936109f7816109c9565b938480936109cd565b958691016109d6565b6108b3565b0190565b610a1b906104c0565b9052565b610a59610a6094610a4f610a446060959998969960808601908682035f8801526109e1565b986020850190610555565b6040830190610555565b0190610a12565b565b34610a9757610a93610a7e610a78366004610716565b9061096a565b90610a8a9492946103a2565b94859485610a1f565b0390f35b6103a8565b610aa5816104ad565b03610aac57565b5f80fd5b90503590610abd82610a9c565b565b909182601f83011215610af75781359160018060401b038311610af2576020019260018302840111610aed57565b6105b5565b6105b1565b6105ad565b919060c083820312610b8a57610b14815f85016103d3565b92610b2282602083016103d3565b92610b308360408401610ab0565b92606083013560018060401b038111610b855781610b4f918501610abf565b929093610b5f83608083016103d3565b9260a082013560018060401b038111610b8057610b7c9201610abf565b9091565b6103b0565b6103b0565b6103ac565b34610bc757610bb1610ba2366004610afc565b969590959491949392936139ca565b610bb96103a2565b80610bc381610449565b0390f35b6103a8565b5f910312610bd657565b6103ac565b90565b610bf2610bed610bf792610bdb565b610743565b6103b4565b90565b610c0561012c610bde565b90565b610c10610bfa565b90565b610c1c906103b4565b9052565b9190610c33905f60208501940190610c13565b565b34610c6557610c45366004610bcc565b610c61610c50610c08565b610c586103a2565b91829182610c20565b0390f35b6103a8565b1c90565b60018060a01b031690565b610c89906008610c8e9302610c6a565b610c6e565b90565b90610c9c9154610c79565b90565b610cab600b5f90610c91565b90565b610cb7906103ed565b9052565b9190610cce905f60208501940190610cae565b565b34610d0057610ce0366004610bcc565b610cfc610ceb610c9f565b610cf36103a2565b91829182610cbb565b0390f35b6103a8565b610d1061012c610bde565b90565b610d1b610d05565b90565b34610d4e57610d2e366004610bcc565b610d4a610d39610d13565b610d416103a2565b91829182610c20565b0390f35b6103a8565b90602082820312610d82575f82013560018060401b038111610d7d57610d799201610abf565b9091565b6103b0565b6103ac565b5190565b60209181520190565b60200190565b610db9610dc2602093610dc793610db0816109c9565b93848093610808565b958691016109d6565b6108b3565b0190565b610dd490610552565b9052565b90610e0290602080610df7604084015f8701518582035f870152610d9a565b940151910190610dcb565b90565b90610e0f91610dd8565b90565b60200190565b90610e2c610e2583610d87565b8092610d8b565b9081610e3d60208302840194610d94565b925f915b838310610e5057505050505090565b90919293946020610e72610e6c83856001950387528951610e05565b97610e12565b9301930191939290610e41565b610e949160208201915f818403910152610e18565b90565b34610ec857610ec4610eb3610ead366004610d53565b90613a14565b610ebb6103a2565b91829182610e7f565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b90565b610efd90610ef1565b9052565b9190610f14905f60208501940190610ef4565b565b34610f4657610f26366004610bcc565b610f42610f31610ecd565b610f396103a2565b91829182610f01565b0390f35b6103a8565b90565b610f62610f5d610f6792610f4b565b610743565b6103b4565b90565b610f75610e10610f4e565b90565b610f80610f6a565b90565b34610fb357610f93366004610bcc565b610faf610f9e610f78565b610fa66103a2565b91829182610c20565b0390f35b6103a8565b90610fc290610746565b5f5260205260405f2090565b610fe2610fdd610fe7926103e2565b610743565b6103e2565b90565b610ff390610fce565b90565b610fff90610fea565b90565b9061100c90610ff6565b5f5260205260405f2090565b60018060401b031690565b61102f6110349161091a565b611018565b90565b6110419054611023565b90565b60401c90565b60ff1690565b61105c61106191611044565b61104a565b90565b61106e9054611050565b90565b60481c90565b60ff1690565b61108961108e91611071565b611077565b90565b61109b905461107d565b90565b90565b6110ad6110b29161091a565b61109e565b90565b6110bf90546110a1565b90565b906110d16110d6926003610fb8565b611002565b6110e15f8201610936565b916110ee60018301611037565b916110fb60018201611064565b91611114600261110d60018501611091565b93016110b5565b90565b611120906104ad565b9052565b634e487b7160e01b5f52602160045260245ffd5b6005111561114257565b611124565b9061115182611138565b565b61115c90611147565b90565b61116890611153565b9052565b909594926111b7946111a66111b09261119c60809661119260a088019c5f890190610555565b6020870190610c13565b6040850190611117565b606083019061115f565b0190610ef4565b565b346111ee576111ea6111d56111cf36600461041c565b906110c2565b916111e19593956103a2565b9586958661116c565b0390f35b6103a8565b346112235761121f61120e611209366004610482565b613a2e565b6112166103a2565b91829182610562565b0390f35b6103a8565b5190565b60209181520190565b60200190565b611244906103ed565b9052565b906112558160209361123b565b0190565b60200190565b9061127c61127661126f84611228565b809361122c565b92611235565b905f5b81811061128c5750505090565b9091926112a561129f6001928651611248565b94611259565b910191909161127f565b6112c49160208201915f81840391015261125f565b90565b346112f7576112f36112e26112dd366004610482565b613ae6565b6112ea6103a2565b918291826112af565b0390f35b6103a8565b90565b61131361130e611318926112fc565b610743565b610552565b90565b61132560c86112ff565b90565b61133061131b565b90565b3461136357611343366004610bcc565b61135f61134e611328565b6113566103a2565b91829182610562565b0390f35b6103a8565b919061137b905f60208501940190610a12565b565b346113ae576113aa61139961139336600461041c565b90613b86565b6113a16103a2565b91829182611368565b0390f35b6103a8565b906113bd90610746565b5f5260205260405f2090565b6113df906113da6007915f926113b3565b610c91565b90565b346114125761140e6113fd6113f8366004610482565b6113c9565b6114056103a2565b91829182610cbb565b0390f35b6103a8565b346114475761144361143261142d366004610482565b613c0d565b61143a6103a2565b918291826112af565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b346114a057611480366004610bcc565b61149c61148b61144c565b6114936103a2565b91829182610cbb565b0390f35b6103a8565b906080828203126114fe576114bc815f84016103d3565b926114ca82602085016103d3565b926114d88360408301610ab0565b92606082013560018060401b0381116114f9576114f59201610abf565b9091565b6103b0565b6103ac565b346115355761151f6115163660046114a5565b93929092613c7f565b6115276103a2565b8061153181610449565b0390f35b6103a8565b90565b61155161154c6115569261153a565b610743565b610552565b90565b611563603261153d565b90565b61156e611559565b90565b346115a157611581366004610bcc565b61159d61158c611566565b6115946103a2565b91829182610562565b0390f35b6103a8565b346115d7576115d36115c26115bc36600461041c565b90613c8e565b6115ca6103a2565b91829182611368565b0390f35b6103a8565b90565b6115f36115ee6115f8926115dc565b610743565b6104ad565b90565b61160560036115df565b90565b6116106115fb565b90565b9190611626905f60208501940190611117565b565b3461165857611638366004610bcc565b611654611643611608565b61164b6103a2565b91829182611613565b0390f35b6103a8565b9190611670905f6020850194019061115f565b565b346116a35761169f61168e61168836600461041c565b90613cba565b6116966103a2565b9182918261165d565b0390f35b6103a8565b906116bb6116b46103a2565b92836108d1565b565b60018060401b0381116116d35760208091020190565b6108bd565b5f80fd5b5f80fd5b5f80fd5b60018060401b038111611700576116fc6020916108b3565b0190565b6108bd565b90825f939282370152565b90929192611725611720826116e4565b6116a8565b938185526020850190828401116117415761173f92611705565b565b6116e0565b9080601f830112156117645781602061176193359101611710565b90565b6105ad565b9190916040818403126117ba5761178060406116a8565b925f8201359160018060401b0383116117b5576117a2826117ae948301611746565b5f860152602001610707565b6020830152565b6116dc565b6116d8565b9291906117d36117ce826116bd565b6116a8565b93818552602080860192028101918383116118285781905b8382106117f9575050505050565b813560018060401b038111611823576020916118188784938701611769565b8152019101906117eb565b6105ad565b6105b5565b9080601f8301121561184b57816020611848933591016117bf565b90565b6105ad565b6080818303126118a857611866825f83016103d3565b92611874836020840161040d565b9260408301359060018060401b0382116118a357611897816118a093860161182d565b93606001610707565b90565b6103b0565b6103ac565b346118df576118c96118c0366004611850565b9291909161409e565b6118d16103a2565b806118db81610449565b0390f35b6103a8565b90565b6118fb6118f6611900926118e4565b610743565b610552565b90565b61190d60406118e7565b90565b611918611903565b90565b3461194b5761192b366004610bcc565b611947611936611910565b61193e6103a2565b91829182610562565b0390f35b6103a8565b3461197e57611960366004610bcc565b6119686146cd565b6119706103a2565b8061197a81610449565b0390f35b6103a8565b61198c90611153565b9052565b61199990610ef1565b9052565b906080806119f5936119b55f8201515f860190610dcb565b6119c7602082015160208601906104a0565b6119d9604082015160408601906104b3565b6119eb60608201516060860190611983565b0151910190611990565b565b9190611a0a905f60a0850194019061199d565b565b34611a3d57611a39611a28611a2236600461041c565b9061480a565b611a306103a2565b918291826119f7565b0390f35b6103a8565b34611a7357611a6f611a5e611a5836600461041c565b90614862565b611a666103a2565b91829182610c20565b0390f35b6103a8565b34611aa657611a88366004610bcc565b611a9061488a565b611a986103a2565b80611aa281610449565b0390f35b6103a8565b34611adb57611ad7611ac6611ac1366004610482565b6148db565b611ace6103a2565b91829182610562565b0390f35b6103a8565b9091606082840312611b1557611b12611afb845f85016103d3565b93611b098160208601610707565b93604001610707565b90565b6103ac565b92916020611b36611b3e9360408701908782035f89015261125f565b940190610555565b565b34611b7257611b59611b53366004611ae0565b91614979565b90611b6e611b656103a2565b92839283611b1a565b0390f35b6103a8565b34611ba557611b8f611b8a3660046106a2565b614b00565b611b976103a2565b80611ba181610449565b0390f35b6103a8565b34611bda57611bba366004610bcc565b611bd6611bc5614b0f565b611bcd6103a2565b91829182610cbb565b0390f35b6103a8565b909182601f83011215611c175781359160018060401b038311611c12576020019260208302840111611c0d57565b6105b5565b6105b1565b6105ad565b919091604081840312611c5b57611c35835f83016103d3565b92602082013560018060401b038111611c5657611c529201611bdf565b9091565b6103b0565b6103ac565b34611c8f57611c79611c73366004611c1c565b91614b96565b611c816103a2565b80611c8b81610449565b0390f35b6103a8565b91606083830312611cde57611cab825f85016103d3565b92611cb9836020830161040d565b92604082013560018060401b038111611cd957611cd69201611746565b90565b6103b0565b6103ac565b90611ced90610746565b5f5260205260405f2090565b90611d0390610ff6565b5f5260205260405f2090565b905090565b611d39611d3092602092611d27816109c9565b94858093611d0f565b938491016109d6565b0190565b90565b611d4c611d5191610552565b611d3d565b9052565b611d65611d6c9160209493611d14565b8092611d40565b0190565b611d84611d7b6103a2565b92839283611d55565b03902090565b611d9391611d70565b90565b611da6906008611dab9302610c6a565b61091f565b90565b90611db99154611d96565b90565b90611de492611dda611ddf92611dd56009955f96611ce3565b611cf9565b611d8a565b611dae565b90565b34611e1857611e14611e03611dfd366004611c94565b91611dbc565b611e0b6103a2565b91829182610562565b0390f35b6103a8565b909182601f83011215611e555781359160018060401b038311611e50576020019260018302840111611e4b57565b6105b5565b6105b1565b6105ad565b91606083830312611ea557611e71825f85016103d3565b92611e7f836020830161040d565b92604082013560018060401b038111611ea057611e9c9201611e1d565b9091565b6103b0565b6103ac565b34611edc57611ec6611ebd366004611e5a565b92919091614df9565b611ece6103a2565b80611ed881610449565b0390f35b6103a8565b611eea816104c0565b03611ef157565b5f80fd5b90503590611f0282611ee1565b565b91909160a081840312611f6e57611f1d835f83016103d3565b92602082013560018060401b038111611f695781611f3c918401611e1d565b929093611f66611f4f8460408501610707565b93611f5d8160608601610707565b93608001611ef5565b90565b6103b0565b6103ac565b34611fa857611f92611f86366004611f04565b949390939291926150c7565b611f9a6103a2565b80611fa481610449565b0390f35b6103a8565b34611fdb57611fc5611fc0366004610482565b615477565b611fcd6103a2565b80611fd781610449565b0390f35b6103a8565b909160608284031261201557612012611ffb845f85016103d3565b9361200981602086016103d3565b93604001610ab0565b90565b6103ac565b346120495761203361202d366004611fe0565b916156ec565b61203b6103a2565b8061204581610449565b0390f35b6103a8565b3461207d5761206761206136600461041c565b906158ab565b61206f6103a2565b8061207981610449565b0390f35b6103a8565b5190565b60209181520190565b60200190565b906120e3906060806120b4608084015f8701518582035f870152610d9a565b946120c760208201516020860190610dcb565b6120d960408201516040860190610dcb565b01519101906104c5565b90565b906120f091612095565b90565b60200190565b9061210d61210683612082565b8092612086565b908161211e6020830284019461208f565b925f915b83831061213157505050505090565b9091929394602061215361214d838560019503875289516120e6565b976120f3565b9301930191939290612122565b6121759160208201915f8184039101526120f9565b90565b346121a8576121a461219361218e366004610482565b615c20565b61219b6103a2565b91829182612160565b0390f35b6103a8565b346121db576121c56121c0366004610482565b615db0565b6121cd6103a2565b806121d781610449565b0390f35b6103a8565b6121ec600a5f90610c91565b90565b3461221f576121ff366004610bcc565b61221b61220a6121e0565b6122126103a2565b91829182610cbb565b0390f35b6103a8565b346122585761225461224361223a366004611e5a565b92919091615e1d565b61224b6103a2565b91829182610562565b0390f35b6103a8565b9061226790610746565b5f5260205260405f2090565b61227f61228491611071565b610943565b90565b6122919054612273565b90565b61229f90600261225d565b6122aa5f8201611037565b916122c15f6122ba818501611064565b9301612287565b90565b6040906122ed6122f494969593966122e360608401985f850190610c13565b6020830190611117565b0190610a12565b565b346123295761232561231161230c366004610482565b612294565b61231c9391936103a2565b938493846122c4565b0390f35b6103a8565b3461235e5761233e366004610bcc565b61235a612349615e52565b6123516103a2565b91829182610cbb565b0390f35b6103a8565b346123925761237c61237636600461041c565b90615f3c565b6123846103a2565b8061238e81610449565b0390f35b6103a8565b346123c8576123c46123b36123ad36600461041c565b906160d1565b6123bb6103a2565b91829182611368565b0390f35b6103a8565b346123fb576123e56123e03660046106a2565b6161d0565b6123ed6103a2565b806123f781610449565b0390f35b6103a8565b9190604083820312612428578061241c612425925f86016103d3565b93602001611ef5565b90565b6103ac565b3461245c57612446612440366004612400565b906161db565b61244e6103a2565b8061245881610449565b0390f35b6103a8565b7f32721f8dc67e953c540da90f663059c23fc47f70d11e317ed6d5a24c8b85637490565b61248d612461565b90565b346124c0576124a0366004610bcc565b6124bc6124ab612485565b6124b36103a2565b91829182610f01565b0390f35b6103a8565b346124f4576124de6124d836600461041c565b906162a4565b6124e66103a2565b806124f081610449565b0390f35b6103a8565b5f80fd5b5f7f4f6e6c792054616e676c6520636f726500000000000000000000000000000000910152565b61253160106020926109cd565b61253a816124fd565b0190565b6125539060208101905f818303910152612524565b90565b1561255d57565b6125656103a2565b62461bcd60e51b81528061257b6004820161253e565b0390fd5b61258b6125909161091a565b610c6e565b90565b61259d905461257f565b90565b90565b6125b76125b26125bc926125a0565b610743565b6103e2565b90565b6125c8906125a3565b90565b5f7f416c726561647920726567697374657265640000000000000000000000000000910152565b6125ff60126020926109cd565b612608816125cb565b0190565b6126219060208101905f8183039101526125f2565b90565b1561262b57565b6126336103a2565b62461bcd60e51b8152806126496004820161260c565b0390fd5b5f1b90565b9061266360018060a01b039161264d565b9181191691161790565b90565b9061268561268061268c92610ff6565b61266d565b8254612652565b9055565b612712612717926126d3336126cd6126c77f00000000000000000000000000000000000000000000000000000000000000006103ed565b916103ed565b14612556565b61270a6126ea6126e5600786906113b3565b612593565b6127046126fe6126f95f6125bf565b6103ed565b916103ed565b14612624565b9160076113b3565b612670565b565b61272360606116a8565b90565b5f90565b5f90565b5f90565b61273a612719565b906020808084612748612726565b81520161275361272a565b81520161275e61272e565b81525050565b61276c612732565b90565b6127819061277b612764565b506163cc565b90565b5f90565b6127a96127af926127a45f9361279c612784565b506003610fb8565b611002565b01610936565b90565b5f7f4e6f742073657276696365206f776e6572000000000000000000000000000000910152565b6127e660116020926109cd565b6127ef816127b2565b0190565b6128089060208101905f8183039101526127d9565b90565b1561281257565b61281a6103a2565b62461bcd60e51b815280612830600482016127f3565b0390fd5b5090565b5f7f546f6f206d616e7920646566696e6974696f6e73000000000000000000000000910152565b61286c60146020926109cd565b61287581612838565b0190565b61288e9060208101905f81830391015261285f565b90565b1561289857565b6128a06103a2565b62461bcd60e51b8152806128b660048201612879565b0390fd5b634e487b7160e01b5f52601160045260245ffd5b6128dd6128e391939293610552565b92610552565b916128ef838202610552565b9281840414901517156128fe57565b6128ba565b61290e9060046128ce565b90565b90612924905f1990602003600802610c6a565b8154169055565b1b90565b9190600861294a9102916129445f198461292b565b9261292b565b9181191691161790565b61296861296361296d92610552565b610743565b610552565b90565b90565b919061298961298461299193612954565b612970565b90835461292f565b9055565b6129a7916129a1612784565b91612973565b565b5b8181106129b5575050565b806129c25f600193612995565b016129aa565b906129d8905f1990600802610c6a565b191690565b816129e7916129c8565b906002021790565b905f91612a066129fe82610811565b9283546129dd565b905555565b601f602091010490565b919290602082105f14612a6e57601f8411600114612a3e57612a389293506129dd565b90555b5b565b5090612a64612a69936001612a5b612a5585610811565b92612a0b565b820191016129a9565b6129ef565b612a3b565b50612aa58293612a7f600194610811565b612a9e612a8b85612a0b565b820192601f861680612ab0575b50612a0b565b01906129a9565b600202179055612a3c565b612abc90888603612911565b5f612a98565b929091600160401b8211612b1d576020115f14612b0e57602081105f14612af257612aec916129dd565b90555b5b565b60019160ff1916612b0284610811565b55600202019055612aef565b60019150600202019055612af0565b6108bd565b908154612b2e816107de565b90818311612b57575b818310612b45575b50505050565b612b4e93612a15565b5f808080612b3f565b612b6383838387612ac2565b612b37565b5f612b7291612b22565b565b634e487b7160e01b5f525f60045260245ffd5b905f03612b9957612b9790612b68565b565b612b74565b60035f91612bae83808301612b87565b612bbb8360018301612995565b612bc88360028301612995565b0155565b905f03612bde57612bdc90612b9e565b565b612b74565b5b818110612bef575050565b80612bfc5f600493612bcc565b01612be4565b9091828110612c11575b505050565b612c2f612c29612c23612c3a95612903565b92612903565b92610790565b918201910190612be3565b5f8080612c0c565b90600160401b8111612c665781612c5b612c649361078c565b90828155612c02565b565b6108bd565b5f612c7591612c42565b565b905f03612c8957612c8790612c6b565b565b612b74565b612ca2612c9d612ca7926125a0565b610743565b610552565b90565b6001612cb69101610552565b90565b5f80fd5b5f80fd5b5f80fd5b903590600160800381360303821215612cdc570190565b612cb9565b90821015612cfb576020612cf89202810190612cc5565b90565b610778565b903590600160200381360303821215612d40570180359060018060401b038211612d3b57602001916001820236038313612d3657565b612cc1565b612cbd565b612cb9565b91565b5090565b5f7f4e616d6520746f6f206c6f6e6700000000000000000000000000000000000000910152565b612d80600d6020926109cd565b612d8981612d4c565b0190565b612da29060208101905f818303910152612d73565b90565b15612dac57565b612db46103a2565b62461bcd60e51b815280612dca60048201612d8d565b0390fd5b35612dd8816106f3565b90565b5f7f496e76616c696420626f756e6473000000000000000000000000000000000000910152565b612e0f600e6020926109cd565b612e1881612ddb565b0190565b612e319060208101905f818303910152612e02565b90565b15612e3b57565b612e436103a2565b62461bcd60e51b815280612e5960048201612e1c565b0390fd5b90565b5f5260205f2090565b5490565b612e7681612e69565b821015612e9057612e88600491612e60565b910201905f90565b610778565b5090565b9190601f8111612ea9575b505050565b612eb5612eda93610811565b906020612ec184612a0b565b83019310612ee2575b612ed390612a0b565b01906129a9565b5f8080612ea4565b9150612ed381929050612eca565b91612efb9082612e95565b9060018060401b038211612fb857612f1d82612f1785546107de565b85612e99565b5f90601f8311600114612f5057918091612f3f935f92612f44575b50506129dd565b90555b565b90915001355f80612f38565b601f19831691612f5f85610811565b925f5b818110612fa057509160029391856001969410612f86575b50505002019055612f42565b612f96910135601f8416906129c8565b90555f8080612f7a565b91936020600181928787013581550195019201612f62565b6108bd565b90612fc89291612ef0565b565b90612fd65f199161264d565b9181191691161790565b90612ff5612ff0612ffc92612954565b612970565b8254612fca565b9055565b3561300a81611ee1565b90565b9061301960ff9161264d565b9181191691161790565b61302c906104c0565b90565b90565b9061304761304261304e92613023565b61302f565b825461300d565b9055565b906130b0606060036130b6946130765f82016130705f880188612d00565b91612fbd565b61308f6001820161308960208801612dce565b90612fe0565b6130a8600282016130a260408801612dce565b90612fe0565b019201613000565b90613032565b565b91906130c9576130c791613052565b565b612b74565b90815491600160401b8310156130f957826130f19160016130f795018155612e6d565b906130b8565b565b6108bd565b929190926131313361312b61312561312061311b600787906113b3565b612593565b6103ed565b916103ed565b1461280b565b61315f61313f858490612834565b61315861315261314d611559565b610552565b91610552565b1115612891565b6131745f61316f60088490610762565b612c77565b61317d5f612c8e565b5b8061319b613195613190888790612834565b610552565b91610552565b101561326e57613269906131f26131d26131cc6131c66131bd8a898791612ce1565b5f810190612d00565b90612d45565b90612d48565b6131eb6131e56131e0611903565b610552565b91610552565b1115612da5565b61323b61320c604061320689888691612ce1565b01612dce565b61323461322e61322960206132238c8b8991612ce1565b01612dce565b610552565b91610552565b1015612e34565b61326461325261324d60088690610762565b612e5d565b61325e88878591612ce1565b906130ce565b612caa565b61317e565b5050509050565b5f7f5a65726f20616464726573730000000000000000000000000000000000000000910152565b6132a9600c6020926109cd565b6132b281613275565b0190565b6132cb9060208101905f81830391015261329c565b90565b156132d557565b6132dd6103a2565b62461bcd60e51b8152806132f3600482016132b6565b0390fd5b9061330190610746565b5f5260205260405f2090565b90565b61331990610ef1565b90565b6133259061091a565b90565b919061333e61333961334693613310565b61331c565b90835461292f565b9055565b5f90565b6133609161335a61334a565b91613328565b565b5f60026133819261337583808301612995565b8260018201550161334e565b565b905f036133955761339390613362565b565b612b74565b60481b90565b906133af60ff60481b9161339a565b9181191691161790565b6133c290611147565b90565b90565b906133dd6133d86133e4926133b9565b6133c5565b82546133a0565b9055565b6134243361341e6134187f00000000000000000000000000000000000000000000000000000000000000006103ed565b916103ed565b14612556565b6134498261344261343c6134375f6125bf565b6103ed565b916103ed565b14156132ce565b61346f61346a61346361345e600685906132f7565b61330d565b84906164aa565b612624565b61348e5f61348961348260038590610fb8565b8590611002565b613383565b6134b1600260016134ab6134a460038690610fb8565b8690611002565b016133c8565b906134e56134df7f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b93610746565b91610ff6565b916134ee6103a2565b806134f881610449565b0390a3565b61350e906135096164e4565b613510565b565b61351b90600b612670565b565b613526906134fd565b565b5f7f4e6f742072656769737465726564206f70657261746f72000000000000000000910152565b61355c60176020926109cd565b61356581613528565b0190565b61357e9060208101905f81830391015261354f565b90565b1561358857565b6135906103a2565b62461bcd60e51b8152806135a660048201613569565b0390fd5b906135df979695949392916135da6135d56135ce6135c98460066132f7565b61330d565b3390616532565b613581565b61381e565b565b6135f56135f06135fa926103b4565b610743565b610552565b90565b61361161360c61361692610552565b610743565b6103b4565b90565b91602061363a92949361363360408201965f830190610c13565b0190610c13565b565b61364b61365191939293610552565b92610552565b820391821161365c57565b6128ba565b60018060401b03811161367d576136796020916108b3565b0190565b6108bd565b9092919261369761369282613661565b6116a8565b938185526020850190828401116136b3576136b192611705565b565b6116e0565b6136c3913691613682565b90565b60200190565b5190565b949290979695939160e08601985f87016136e991610ef4565b602086016136f691610cae565b6040850161370391610c13565b6060840161371091610c13565b6080830161371d91611117565b60a0820161372a91610ef4565b60c00161373691610c13565b565b5f61190160f01b910152565b61375060028092611d0f565b61375981613738565b0190565b90565b61376c61377191610ef1565b61375d565b9052565b602080939261379061378961379894613744565b8092613760565b018092613760565b0190565b5f7f496e76616c6964207369676e6174757265000000000000000000000000000000910152565b6137d060116020926109cd565b6137d98161379c565b0190565b6137f29060208101905f8183039101526137c3565b90565b156137fc57565b6138046103a2565b62461bcd60e51b81528061381a600482016137dd565b0390fd5b9192939497969095978061383a61383442610552565b916135e1565b116139a2576138524261384c836135e1565b9061363c565b61386b613865613860610d05565b6135e1565b91610552565b1161397a57613978979861394f61396d93856138d98a6138ca8d613955988d8d6138a1613896612461565b9633999592936136b8565b6138b36138ad826136cc565b916136c6565b2092936138be6103a2565b988997602089016136d0565b602082018103825203826108d1565b6138eb6138e5826136cc565b916136c6565b206139367f000000000000000000000000000000000000000000000000000000000000000061392761391b6103a2565b93849260208401613775565b602082018103825203826108d1565b613948613942826136cc565b916136c6565b20926136b8565b9061656c565b613967613961336103ed565b916103ed565b146137f5565b9333919293946166e9565b565b613983426135fd565b9061399e5f9283926318355b7560e21b845260048401613619565b0390fd5b6139ab426135fd565b906139c65f9283926357ea02e960e01b845260048401613619565b0390fd5b906139da979695949392916135aa565b565b606090565b90602082820312613a0f575f82013560018060401b038111613a0a57613a07920161182d565b90565b6103b0565b6103ac565b90613a2b91613a216139dc565b50908101906139e1565b90565b613a4d613a48613a5292613a40612784565b5060056132f7565b61330d565b616afb565b90565b606090565b60018060401b038111613a705760208091020190565b6108bd565b90613a87613a8283613a5a565b6116a8565b918252565b369037565b90613ab6613a9e83613a75565b92602080613aac8693613a5a565b9201910390613a8c565b565b90613ac282611228565b811015613ad3576020809102010190565b610778565b90613ae2906103ed565b9052565b90613aef613a55565b50613b0c613b07613b02600485906132f7565b61330d565b616afb565b91613b1683613a91565b91613b205f612c8e565b5b80613b34613b2e87610552565b91610552565b1015613b7b57613b7690613b71613b5f613b58613b53600488906132f7565b61330d565b8390616b4a565b613b6c8791849092613ab8565b613ad8565b612caa565b613b21565b5092505090565b5f90565b90613b8f613b82565b50613bb16001613bab613ba460038690610fb8565b8490611002565b01611091565b613bc3613bbd5f611147565b91611147565b14918215613bd1575b505090565b613bf29250600191613be7613bec926003610fb8565b611002565b01611091565b613c05613bff6001611147565b91611147565b145f80613bcc565b613c3390613c19613a55565b505f90613c2d613c2761131b565b92612c8e565b90614979565b5090565b90613c6994939291613c64613c5f613c58613c538460066132f7565b61330d565b3390616532565b613581565b613c6b565b565b91613c7d9492939133919293946166e9565b565b90613c8c94939291613c37565b565b90613cae613ca9613cb393613ca1613b82565b5060066132f7565b61330d565b616532565b90565b5f90565b613cdc613ce292613cd7600193613ccf613cb6565b506003610fb8565b611002565b01611091565b90565b613cee90610fea565b90565b5f7f496e7465726e616c206f6e6c7900000000000000000000000000000000000000910152565b613d25600d6020926109cd565b613d2e81613cf1565b0190565b613d479060208101905f818303910152613d18565b90565b15613d5157565b613d596103a2565b62461bcd60e51b815280613d6f60048201613d32565b0390fd5b60018060401b038111613d895760208091020190565b6108bd565b90613da0613d9b83613d73565b6116a8565b918252565b369037565b90613dcf613db783613d8e565b92602080613dc58693613d73565b9201910390613da5565b565b90613ddb82610d87565b811015613dec576020809102010190565b610778565b90565b5190565b90613e0282613df4565b811015613e13576020809102010190565b610778565b90613e2290610ef1565b9052565b606090565b90565b60209181520190565b905f9291805490613e51613e4a836107de565b8094613e2e565b916001811690815f14613ea85750600114613e6c575b505050565b613e799192939450610799565b915f925b818410613e9057505001905f8080613e67565b60018160209295939554848601520191019290613e7d565b92949550505060ff19168252151560200201905f8080613e67565b90613ecd91613e37565b90565b90613ef0613ee992613ee06103a2565b93848092613ec3565b03836108d1565b565b613efb90613ed0565b90565b613f089051610ef1565b90565b613f159051610552565b90565b5f7f56616c7565206f7574206f6620626f756e647300000000000000000000000000910152565b613f4c60136020926109cd565b613f5581613f18565b0190565b613f71613f7f9260408301908382035f8501526109e1565b906020818303910152613f3f565b90565b92916020613f9e613fa69360408701908782035f8901526109e1565b940190610555565b565b905f9291805490613fc2613fbb836107de565b80946109cd565b916001811690815f146140195750600114613fdd575b505050565b613fea9192939450610811565b915f925b81841061400157505001905f8080613fd8565b60018160209295939554848601520191019290613fee565b92949550505060ff19168252151560200201905f8080613fd8565b5f7f5265717569726564206d6574726963206d697373696e67000000000000000000910152565b61406860176020926109cd565b61407181614034565b0190565b61408d61409b9260408301908382035f850152613fa8565b90602081830391015261405b565b90565b929390936140c6336140c06140ba6140b530613ce5565b6103ed565b916103ed565b14613d4a565b6140da6140d560088690610762565b612e5d565b946140e482613daa565b946140ee5f612c8e565b5b806141026140fc86610552565b91610552565b1015614155576141509061414b6141265f61411e8a8590613dd1565b510151613df1565b614138614132826136cc565b916136c6565b206141468a91849092613df8565b613e18565b612caa565b6140ef565b50919490929561416481612e69565b6141766141705f612c8e565b91610552565b1196614180613e26565b9088614600575b6141905f612c8e565b5b806141a461419e8b610552565b91610552565b10156144635760015f8b614297575b50908887896141c9946141ce575b505050612caa565b614191565b825f61420c614204614215946141ff6141f760206141f061421a9b8d90613dd1565b5101613f0b565b976009611ce3565b611cf9565b928790613dd1565b51015190611d8a565b612fe0565b88878990614244602061423d5f614232878990613dd1565b510151958790613dd1565b5101613f0b565b6142776142717f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd93610746565b93610ff6565b9361428c6142836103a2565b92839283613f82565b0390a38887896141c1565b9a90959291996142a65f612c8e565b5b806142c26142bc6142b78a612e69565b610552565b91610552565b101561444d576142da6142d58d87613df8565b613efe565b6142fe6142f86142f36142ee8a8690613df8565b613efe565b610ef1565b91610ef1565b146143115761430c90612caa565b6142a7565b8a919b929c50896141c99495988a926001908a61433b6020614334898b90613dd1565b5101613f0b565b61436361435d6143586001614351868890612e6d565b5001610936565b610552565b91610552565b109188888415614403575b50505050614398575b614382905b156104c0565b614391575b93945050506141b3565b505f614387565b905082825f6143a8878990613dd1565b510151916143f46143e26143dc7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad631593610746565b93610ff6565b936143eb6103a2565b91829182613f59565b0390a36143825f919050614377565b61444393945061443161443d9361442b602061442461443896600296613dd1565b5101613f0b565b96612e6d565b5001610936565b610552565b91610552565b118a5f888861436e565b5099909a87896141c99495986143828d9461437c565b5097505092935093506144755f612c8e565b935b8461449261448c61448786612e69565b610552565b91610552565b10156145f9576144b86144b260036144ab868990612e6d565b500161095d565b156104c0565b6145ee576144da6144d55f6144ce868990612e6d565b5001613e2b565b613ef2565b6144ec6144e6826136cc565b916136c6565b20905f966144f95f612c8e565b5b8061451561450f61450a86613df4565b610552565b91610552565b10156145dc5761452e614529848390613df8565b613efe565b61454061453a86610ef1565b91610ef1565b146145535761454e90612caa565b6144fa565b5095909650614574915061456960015b156104c0565b61457b575b5b612caa565b9394614477565b82855f614589878590612e6d565b5001916145d46145c26145bc7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad631593610746565b93610ff6565b936145cb6103a2565b91829182614075565b0390a361456e565b50959096614574925061456990614563565b94936145749061456f565b5050505050565b9693905061461a614615839794999693612e69565b613daa565b976146245f612c8e565b5b8061464061463a6146358b612e69565b610552565b91610552565b101561469a576146959061469061466b6146665f61465f8d8690612e6d565b5001613e2b565b613ef2565b61467d614677826136cc565b916136c6565b2061468b8d91849092613df8565b613e18565b612caa565b614625565b509295919497909396614187565b6146b06164e4565b6146b86146ba565b565b6146cb6146c65f6125bf565b616be2565b565b6146d56146a8565b565b6146e160a06116a8565b90565b5f90565b5f90565b5f90565b6146f86146d7565b90602080808080866147086146e4565b815201614713612726565b81520161471e61272a565b8152016147296146e8565b8152016147346146ec565b81525050565b6147426146f0565b90565b9061474f90610552565b9052565b9061475d906103b4565b9052565b9061476b906104ad565b9052565b9061477990611147565b9052565b906147fc6147f3600261478e6146d7565b946147a561479d5f8301610936565b5f8801614745565b6147bd6147b460018301611037565b60208801614753565b6147d56147cc60018301611064565b60408801614761565b6147ed6147e460018301611091565b6060880161476f565b016110b5565b60808401613e18565b565b6148079061477d565b90565b61482f9161482561482a9261481d61473a565b506003610fb8565b611002565b6147fe565b90565b5f90565b9061484090610746565b5f5260205260405f2090565b9061485690610ff6565b5f5260205260405f2090565b6148879161487d61488292614875614832565b50600c614836565b61484c565b611037565b90565b614892616bf8565b61489a615e52565b6148ac6148a6836103ed565b916103ed565b036148bc576148ba90616be2565b565b6148d7905f91829163118cdaa760e01b835260048301610cbb565b0390fd5b6148fa6148f56148ff926148ed612784565b5060046132f7565b61330d565b616afb565b90565b61490c90516104ad565b90565b61492361491e614928926125a0565b610743565b6104ad565b90565b61493590516103b4565b90565b61494c614947614951926104ad565b610743565b610552565b90565b61496361496991939293610552565b92610552565b820180921161497457565b6128ba565b90929192614985613a55565b5061498e612784565b50614998826163cc565b936149b56149b06149ab600586906132f7565b61330d565b616afb565b926149c260208701614902565b6149d46149ce5f61490f565b916104ad565b148015614ac6575b8015614aab575b614a9157614a1d86614a17614a126020614a0b614a065f614a7a9b9c9d0161492b565b6135e1565b9301614902565b614938565b906128ce565b9180614a38614a32614a2d61131b565b610552565b91610552565b115f14614a8c5750614a4861131b565b5b614a54848290614954565b614a66614a6088610552565b91610552565b115f14614a7d5750845b9092909192616c2e565b91565b614a879084614954565b614a70565b614a49565b5050509150614aa7614aa25f612c8e565b613a91565b9190565b5082614abf614ab986610552565b91610552565b10156149e3565b5083614ada614ad45f612c8e565b91610552565b146149dc565b614af190614aec6164e4565b614af3565b565b614afe90600a612670565b565b614b0990614ae0565b565b5f90565b614b17614b0b565b50614b215f612593565b90565b5090565b9190811015614b38576020020190565b610778565b35614b47816103f9565b90565b5f80fd5b60e01b90565b5f910312614b5e57565b6103ac565b916020614b84929493614b7d60408201965f830190610c13565b0190610cae565b565b614b8e6103a2565b3d5f823e3d90fd5b90929192614ba35f612c8e565b5b80614bc1614bbb614bb6858990614b24565b610552565b91610552565b1015614c7057614bd030613ce5565b9063ba1fb10384614beb614be6868a8691614b28565b614b3d565b93803b15614c6b57614c105f8094614c1b614c046103a2565b98899687958694614b4e565b845260048401614b63565b03925af1918215614c6657614c3592614c3a575b50612caa565b614ba4565b614c59905f3d8111614c5f575b614c5181836108d1565b810190614b54565b5f614c2f565b503d614c47565b614b86565b614b4a565b5050509050565b5f7f4e6f7420736c617368696e67206f7261636c6500000000000000000000000000910152565b614cab60136020926109cd565b614cb481614c77565b0190565b614ccd9060208101905f818303910152614c9e565b90565b15614cd757565b614cdf6103a2565b62461bcd60e51b815280614cf560048201614cb8565b0390fd5b5f7f4f70657261746f7220756e6b6e6f776e00000000000000000000000000000000910152565b614d2d60106020926109cd565b614d3681614cf9565b0190565b614d4f9060208101905f818303910152614d20565b90565b15614d5957565b614d616103a2565b62461bcd60e51b815280614d7760048201614d3a565b0390fd5b90565b90614d8f60018060401b039161264d565b9181191691161790565b90565b90614db1614dac614db892610746565b614d99565b8254614d7e565b9055565b9190614dd681614dcf81614ddb956109cd565b8095611705565b6108b3565b0190565b9091614df69260208301925f818503910152614dbc565b90565b614e1e33614e18614e12614e0d600a612593565b6103ed565b916103ed565b14614cd0565b614e44614e3f614e38614e33600585906132f7565b61330d565b8490616532565b614d52565b614e70614e65614e60614e5960038590610fb8565b8590611002565b614d7b565b6001600391016133c8565b614e8e614e87614e82600484906132f7565b61330d565b8390616d4a565b50614eb6614e9b426135fd565b614eb1614eaa600c8590614836565b859061484c565b614d9c565b909192614eec614ee67f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c79193610746565b93610ff6565b93614f01614ef86103a2565b92839283614ddf565b0390a3565b614f1060806116a8565b90565b614f1e913691611710565b90565b52565b90614f2e906104c0565b9052565b5190565b90614f40816109c9565b9060018060401b038211614ffe57614f6282614f5c85546107de565b85612e99565b602090601f8311600114614f9657918091614f85935f92614f8a575b50506129dd565b90555b565b90915001515f80614f7e565b601f19831691614fa585610811565b925f5b818110614fe657509160029391856001969410614fcc575b50505002019055614f88565b614fdc910151601f8416906129c8565b90555f8080614fc0565b91936020600181928787015181550195019201614fa8565b6108bd565b9061500d91614f36565b565b61501990516104c0565b90565b906150796060600361507f9461503f5f82016150395f8801614f32565b90615003565b6150586001820161505260208801613f0b565b90612fe0565b6150716002820161506b60408801613f0b565b90612fe0565b01920161500f565b90613032565b565b9190615092576150909161501c565b565b612b74565b90815491600160401b8310156150c257826150ba9160016150c095018155612e6d565b90615081565b565b6108bd565b6151e5956151ce84966151c56151bd6151a96151a46151d79761514a61512a6151246151e09d8d9f9d61511f3361511961511361510e61510960078c906113b3565b612593565b6103ed565b916103ed565b1461280b565b612d45565b90612d48565b61514361513d615138611903565b610552565b91610552565b1115612da5565b6151678661516061515a8d610552565b91610552565b1015612e34565b61519d61517e61517960088490610762565b61078c565b61519761519161518c611559565b610552565b91610552565b10612891565b6008610762565b612e5d565b9899969294966151b7614f06565b9a614f13565b5f8a01614f21565b60208801614745565b60408601614745565b60608401614f24565b615097565b565b6152159061521061520b6152046151ff8460066132f7565b61330d565b3390616532565b613581565b6152f1565b565b5f7f43616e6e6f7420676f206f6e6c696e65207768696c6520736c61736865640000910152565b61524b601e6020926109cd565b61525481615217565b0190565b61526d9060208101905f81830391015261523e565b90565b60401b90565b9061528560ff60401b91615270565b9181191691161790565b6152a361529e6152a8926104ad565b610743565b6104ad565b90565b90565b906152c36152be6152ca9261528f565b6152ab565b8254615276565b9055565b9160206152ef9294936152e860408201965f83019061115f565b019061115f565b565b61530f61530a61530360038490610fb8565b3390611002565b614d7b565b9061531c60018301611091565b918261533161532b6003611147565b91611147565b1461545557826153496153435f611147565b91611147565b14801561543a575b615435576153789061536660018083016133c8565b60016153715f61490f565b91016152ae565b61539661538f61538a600484906132f7565b61330d565b33906164aa565b5080336153cc6153c67fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c93610746565b91610ff6565b916153d56103a2565b806153df81610449565b0390a390339091600161541b6154157f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a0993610746565b93610ff6565b936154306154276103a2565b928392836152ce565b0390a3565b505050565b508261544f6154496001611147565b91611147565b14615351565b61545d6103a2565b62461bcd60e51b81528061547360048201615258565b0390fd5b615480906151e7565b565b5f7f4e6f7420617574686f72697a6564000000000000000000000000000000000000910152565b6154b6600e6020926109cd565b6154bf81615482565b0190565b6154d89060208101905f8183039101526154a9565b90565b156154e257565b6154ea6103a2565b62461bcd60e51b815280615500600482016154c3565b0390fd5b90565b61551b61551661552092615504565b610743565b6103b4565b90565b5f7f496e74657276616c20746f6f2073686f72740000000000000000000000000000910152565b61555760126020926109cd565b61556081615523565b0190565b6155799060208101905f81830391015261554a565b90565b1561558357565b61558b6103a2565b62461bcd60e51b8152806155a160048201615564565b0390fd5b90565b6155bc6155b76155c1926155a5565b610743565b6104ad565b90565b5f7f4d6178206d6973736564206d757374206265203e3d2031000000000000000000910152565b6155f860176020926109cd565b615601816155c4565b0190565b61561a9060208101905f8183039101526155eb565b90565b1561562457565b61562c6103a2565b62461bcd60e51b81528061564260048201615605565b0390fd5b61565060606116a8565b90565b9061566861566361566f92613023565b61302f565b82546133a0565b9055565b906156b560405f6156bb9461569582820161568f84880161492b565b90614d9c565b6156ad8282016156a760208801614902565b906152ae565b01920161500f565b90615653565b565b906156c791615673565b565b9160206156ea9294936156e360408201965f830190610c13565b0190611117565b565b3361571f6157197f00000000000000000000000000000000000000000000000000000000000000006103ed565b916103ed565b14801561580b575b615730906154db565b61574e82615747615741603c615507565b916103b4565b101561557c565b61576c8361576561575f60016155a8565b916104ad565b101561561d565b6157c5826157b4856157ab61578d5f6157876002899061225d565b01612287565b916157a2615799615646565b955f8701614753565b60208501614761565b60408301614f24565b6157c06002849061225d565b6156bd565b90916157f17fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea56492610746565b926158066157fd6103a2565b928392836156c9565b0390a2565b506157303361583561582f61582a615825600787906113b3565b612593565b6103ed565b916103ed565b149050615727565b634e487b7160e01b5f52601260045260245ffd5b61585d61586391610552565b91610552565b90811561586e570490565b61583d565b61588761588261588c92610552565b610743565b6104ad565b90565b6158a361589e6158a8926125a0565b610743565b6103b4565b90565b6158c96158c46158bd60038490610fb8565b8490611002565b614d7b565b906158d3816163cc565b6158df60018401611091565b6158f26158ec6003611147565b91611147565b14615b06576159025f8401610936565b61591461590e5f612c8e565b91610552565b14615b005761594a6159314261592b5f8701610936565b9061363c565b61594461593f5f850161492b565b6135e1565b90615851565b8061595e61595860ff614938565b91610552565b115f14615af2575060ff5b908161598861598261597d60018801611064565b6104ad565b916104ad565b11615995575b5050505050565b6159a282600186016152ae565b6159b76159ae5f61588f565b60018601614d9c565b6159d56159cf6159ca6020859401614902565b6104ad565b916104ad565b101580615acb575b6159e8575b8061598e565b615a036159f760018501611091565b936001600291016133c8565b615a21615a1a615a15600485906132f7565b61330d565b8590616d4a565b508190849091615a6f615a5d615a577f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d93610746565b93610ff6565b93615a666103a2565b91829182611613565b0390a39190916002615aaa615aa47f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a0993610746565b93610ff6565b93615abf615ab66103a2565b928392836152ce565b0390a35f8080806159e2565b50615ad860018401611091565b615aeb615ae56002611147565b91611147565b14156159dd565b615afb90615873565b615969565b50505050565b50505050565b606090565b60018060401b038111615b275760208091020190565b6108bd565b90615b3e615b3983615b11565b6116a8565b918252565b615b4d60806116a8565b90565b90615bb7615bae6003615b61615b43565b94615b78615b705f83016108f8565b5f8801614f21565b615b90615b8760018301610936565b60208801614745565b615ba8615b9f60028301610936565b60408801614745565b0161095d565b60608401614f24565b565b615bc290615b50565b90565b90615bcf8261078c565b615bd881615b2c565b92615be66020850191610790565b5f915b838310615bf65750505050565b60046020600192615c0685615bb9565b815201920192019190615be9565b615c1d90615bc5565b90565b615c37615c3c91615c2f615b0c565b506008610762565b615c14565b90565b615c6d90615c68615c63615c5c615c578460066132f7565b61330d565b3390616532565b613581565b615cc8565b565b5f7f43616e6e6f7420676f206f66666c696e65207768696c6520736c617368656400910152565b615ca3601f6020926109cd565b615cac81615c6f565b0190565b615cc59060208101905f818303910152615c96565b90565b615ce6615ce1615cda60038490610fb8565b3390611002565b614d7b565b90615cf360018301611091565b9182615d08615d026003611147565b91611147565b14615d8e57615d1c906001600491016133c8565b615d3a615d33615d2e600484906132f7565b61330d565b3390616d4a565b50903390916004615d74615d6e7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a0993610746565b93610ff6565b93615d89615d806103a2565b928392836152ce565b0390a3565b615d966103a2565b62461bcd60e51b815280615dac60048201615cb0565b0390fd5b615db990615c3f565b565b909182615dcb81615dd293611d0f565b8093611705565b0190565b615de79060209493615dee93615dbb565b8092611d40565b0190565b9091615e0990615e006103a2565b93849384615dd6565b03902090565b9091615e1a92615df2565b90565b92615e42615e4a9392615e3d615e4f96615e35612784565b506009611ce3565b611cf9565b919091615e0f565b610936565b90565b615e5a614b0b565b50615e656001612593565b90565b615e729051611147565b90565b90565b615e8c615e87615e9192615e75565b610743565b610552565b90565b60207f6c00000000000000000000000000000000000000000000000000000000000000917f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76615f8201520152565b615eee60216040926109cd565b615ef781615e94565b0190565b615f109060208101905f818303910152615ee1565b90565b15615f1a57565b615f226103a2565b62461bcd60e51b815280615f3860048201615efb565b0390fd5b90615fed615fe8615ff29333615f6d615f67615f62615f5d600786906113b3565b612593565b6103ed565b916103ed565b1480156160ab575b615f7e906154db565b615f9c615f97615f9060038490610fb8565b8690611002565b6147fe565b615fa860608201615e68565b615fbb615fb56003611147565b91611147565b03615ff5575b50615fe0615fd9615fd4600584906132f7565b61330d565b8590616d4a565b5060046132f7565b61330d565b616d4a565b50565b61607190616045616035616008856163cc565b61602f61602a602061602361601e5f860161492b565b6135e1565b9301614902565b614938565b906128ce565b61603f600a615e78565b906128ce565b6160505f8301613f0b565b61606261605c5f612c8e565b91610552565b119182616077575b5050615f13565b5f615fc1565b6160a291925061609661609c916160905f429201613f0b565b9061363c565b92610552565b91610552565b10155f8061606a565b50615f7e336160c96160c36160be614b0f565b6103ed565b916103ed565b149050615f75565b906160fb616100916160e1613b82565b506160f66160ee856163cc565b946003610fb8565b611002565b6147fe565b61610b5f8201613f0b565b61611d6161175f612c8e565b91610552565b146161585761614e6161495f6161426161549461613c83429201613f0b565b9061363c565b940161492b565b6135e1565b91610552565b1090565b50505f90565b61616f9061616a6164e4565b616171565b565b61617c816001612670565b616184614b0f565b906161b86161b27f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e2270093610ff6565b91610ff6565b916161c16103a2565b806161cb81610449565b0390a3565b6161d99061615e565b565b5f61621a616220936162123361620c6162066162016161fc60078a906113b3565b612593565b6103ed565b916103ed565b1461280b565b92600261225d565b01615653565b565b5f7f4e6f742072656769737465726564000000000000000000000000000000000000910152565b616256600e6020926109cd565b61625f81616222565b0190565b6162789060208101905f818303910152616249565b90565b1561628257565b61628a6103a2565b62461bcd60e51b8152806162a060048201616263565b0390fd5b6162e0336162da6162d47f00000000000000000000000000000000000000000000000000000000000000006103ed565b916103ed565b14612556565b6163066163016162fa6162f5600685906132f7565b61330d565b8490616d4a565b61627b565b61632461631d616318600484906132f7565b61330d565b8390616d4a565b50906163596163537f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e93610746565b91610ff6565b916163626103a2565b8061636c81610449565b0390a3565b906163be6163b55f616381612719565b94616398616390838301611037565b838801614753565b6163af6163a6838301611064565b60208801614761565b01612287565b60408401614f24565b565b6163c990616371565b90565b6163e36163e8916163db612764565b50600261225d565b6163c0565b6163f35f820161492b565b6164056163ff5f61588f565b916103b4565b1461644b575b61641760208201614902565b6164296164235f61490f565b916104ad565b14616432575b90565b61644661643d6115fb565b60208301614761565b61642f565b61645e616456610bfa565b5f8301614753565b61640b565b61646c90610fce565b90565b61648361647e616488926103e2565b610743565b610552565b90565b61649f61649a6164a492610552565b61264d565b610ef1565b90565b90565b906164dc6164d66164d16164cc5f6164e1966164c4613b82565b500194616463565b61646f565b61648b565b916164a7565b616e06565b90565b6164ec614b0f565b6165056164ff6164fa616bf8565b6103ed565b916103ed565b0361650c57565b61652e616517616bf8565b5f91829163118cdaa760e01b835260048301610cbb565b0390fd5b9061656461655e6165596165545f6165699661654c613b82565b500194616463565b61646f565b61648b565b916164a7565b616e69565b90565b61658b916165829161657c614b0b565b50616ec5565b90929192616f85565b90565b5f7f4f70657261746f7220697320736c617368656400000000000000000000000000910152565b6165c260136020926109cd565b6165cb8161658e565b0190565b6165e49060208101905f8183039101526165b5565b90565b156165ee57565b6165f66103a2565b62461bcd60e51b81528061660c600482016165cf565b0390fd5b9061662561662061662c92613310565b61331c565b8254612fca565b9055565b616639906103b4565b60018060401b03811461664c5760010190565b6128ba565b90565b61666861666361666d92616651565b610743565b6104ad565b90565b91602061669192949361668a60408201965f830190611117565b0190610555565b565b61669c90610fce565b90565b6166a890616693565b90565b6166b490610fea565b90565b6040906166e06166e794969593966166d660608401985f850190610cae565b6020830190610c13565b0190610c13565b565b949293919361670c61670761670060038990610fb8565b8790611002565b614d7b565b93616716876163cc565b9361674061672660018801611091565b6167396167336003611147565b91611147565b14156165e7565b61675e61675761675260058b906132f7565b61330d565b88906164aa565b50616833604061677060018901611091565b9661677d425f8b01612fe0565b6167a761678b8587906136b8565b61679d616797826136cc565b916136c6565b2060028b01616610565b6167bc6167b35f61490f565b60018b016152ae565b6167da60018a016167d46167cf82611037565b616630565b90614d9c565b6167e2613cb6565b50856167f66167f05f61490f565b916104ad565b145f14616ab75761680d5f995b60018b91016133c8565b8761682161681b6002611147565b91611147565b1480616a9b575b616a2d575b0161500f565b80616a09575b6169f3575b505085918591924261688261687c6168767f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b994610746565b94610746565b94610ff6565b9461689761688e6103a2565b92839283616670565b0390a4806168ad6168a784611147565b91611147565b0361699d575b50506168bf600b612593565b6168d96168d36168ce5f6125bf565b6103ed565b916103ed565b036168e3575b5050565b6168fd6168f86168f3600b612593565b61669f565b6166ab565b9163d47853b691909261690f426135fd565b92813b15616998575f6169359161694082966169296103a2565b98899788968795614b4e565b8552600485016166b7565b03925af1908161696c575b50155f14616967576001616962575b5b5f806168df565b61695a565b61695b565b61698b905f3d8111616991575b61698381836108d1565b810190614b54565b5f61694b565b503d616979565b614b4a565b838391926169d46169ce7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a0993610746565b93610ff6565b936169e96169e06103a2565b928392836152ce565b0390a35f806168b3565b616a029188918890919261743a565b5f8061683e565b50616a15818390612d48565b616a27616a215f612c8e565b91610552565b11616839565b616a4a616a43616a3e8d60046132f7565b61330d565b8b906164aa565b508a8a616a80616a7a7fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c93610746565b91610ff6565b91616a896103a2565b80616a9381610449565b0390a361682d565b5088616ab0616aaa6002611147565b91611147565b1415616828565b85616acb616ac56064616654565b916104ad565b105f14616ade5761680d6001995b616803565b61680d600199616af68d8d8b908b908a928c946170f4565b616ad9565b616b125f616b1792616b0b612784565b50016164a7565b6175f8565b90565b616b26616b2b9161091a565b612954565b90565b616b42616b3d616b4792610552565b610743565b6103e2565b90565b616b75616b70616b7f93616b6b5f616b7a95616b64614b0b565b50016164a7565b617666565b616b1a565b616b2e565b610fea565b90565b91906008616ba2910291616b9c60018060a01b038461292b565b9261292b565b9181191691161790565b9190616bc2616bbd616bca93610ff6565b61266d565b908354616b82565b9055565b616be091616bda614b0b565b91616bac565b565b616bf690616bf15f6001616bce565b617687565b565b616c00614b0b565b503390565b616c0e90610552565b5f198114616c1c5760010190565b6128ba565b616c2b90516103ed565b90565b93919293616c3a613a55565b50616c4e616c4985849061363c565b613a91565b92616c585f612c8e565b925b80616c6d616c6788610552565b91610552565b1015616cdb57616c91616c8a616c85600586906132f7565b61330d565b8290616b4a565b616c9d84828a916176e6565b616cb1575b50616cac90612caa565b616c5a565b616cac9194616ccf616cd492616cca8991849092613ab8565b613ad8565b616c05565b9390616ca2565b509450509150616cea82613a91565b92616cf45f612c8e565b5b80616d08616d0286610552565b91610552565b1015616d4457616d3f90616d3a616d28616d23868490613ab8565b616c21565b616d358891849092613ab8565b613ad8565b612caa565b616cf5565b50915050565b90616d7c616d76616d71616d6c5f616d8196616d64613b82565b500194616463565b61646f565b61648b565b916164a7565b61781e565b90565b90565b5f5260205f2090565b5490565b616d9d81616d90565b821015616db757616daf600191616d87565b910201905f90565b610778565b90815491600160401b831015616de75782616ddf916001616de595018155616d94565b90613328565b565b6108bd565b5490565b90616dfa90613310565b5f5260205260405f2090565b616e0e613b82565b50616e23616e1d828490616e69565b156104c0565b5f14616e6357616e59616e5e92616e45616e3e5f8501616d84565b8290616dbc565b6001616e525f8501616dec565b9301616df0565b612fe0565b600190565b50505f90565b616e87916001616e8292616e7b613b82565b5001616df0565b610936565b616e99616e935f612c8e565b91610552565b141590565b5f90565b90565b616eb9616eb4616ebe92616ea2565b610743565b610552565b90565b5f90565b919091616ed0614b0b565b50616ed9616e9e565b50616ee261334a565b50616eec836136cc565b616eff616ef96041616ea5565b91610552565b145f14616f4657616f3f9192616f1361334a565b50616f1c61334a565b50616f25616ec1565b506020810151606060408301519201515f1a90919261799d565b9192909190565b50616f505f6125bf565b90616f64616f5f6002946136cc565b61648b565b91929190565b60041115616f7457565b611124565b90616f8382616f6a565b565b80616f98616f925f616f79565b91616f79565b145f14616fa3575050565b80616fb7616fb16001616f79565b91616f79565b145f14616fda575f63f645eedf60e01b815280616fd660048201610449565b0390fd5b80616fee616fe86002616f79565b91616f79565b145f1461701c5761701861700183616b1a565b5f91829163fce698f760e01b835260048301610562565b0390fd5b61702f6170296003616f79565b91616f79565b146170375750565b617052905f9182916335e2f38360e21b835260048301610f01565b0390fd5b61706a61706561706f926112fc565b610743565b6104ad565b90565b61707e617084916103b4565b916103b4565b90039060018060401b03821161709657565b6128ba565b5f7f50726f746f636f6c2076696f6c6174696f6e207265706f727465640000000000910152565b6170cf601b6020926109cd565b6170d88161709b565b0190565b6170f19060208101905f8183039101526170c2565b90565b935050925061710c61710660c8617056565b916104ad565b1015617117575b5050565b617120426135fd565b61713e617139617132600c8590614836565b859061484c565b611037565b8061715161714b5f61588f565b916103b4565b149081156171d7575b50617166575b50617113565b61718590617180617179600c8590614836565b859061484c565b614d9c565b906171b96171b37f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c79193610746565b91610ff6565b916171c26103a2565b806171cc816170dc565b0390a35f8080617160565b6171e2915082617072565b6171fb6171f56171f0610f6a565b6103b4565b916103b4565b10155f61715a565b90565b61721a61721561721f92617203565b610743565b610552565b90565b90929192617237617232826116e4565b6116a8565b9381855260208501908284011161725357617251926109d6565b565b6116e0565b9080601f830112156172765781602061727393519101617222565b90565b6105ad565b90505190617288826106f3565b565b9190916040818403126172db576172a160406116a8565b925f8201519160018060401b0383116172d6576172c3826172cf948301617258565b5f86015260200161727b565b6020830152565b6116dc565b6116d8565b9291906172f46172ef826116bd565b6116a8565b93818552602080860192028101918383116173495781905b83821061731a575050505050565b815160018060401b03811161734457602091617339878493870161728a565b81520191019061730c565b6105ad565b6105b5565b9080601f8301121561736c57816020617369935191016172e0565b90565b6105ad565b9060208282031261739f575f82015160018060401b03811161739a57617397920161734e565b90565b6103b0565b6103ac565b60209181520190565b91906173c7816173c0816173cc956173a4565b8095611705565b6108b3565b0190565b90916173e79260208301925f8185039101526173ad565b90565b6173f4603261153d565b90565b949391606091617438946174236174309361741960808b01945f8c0190610c13565b60208a0190610cae565b8782036040890152610e18565b940190610555565b565b91617446818590612d48565b6174586174525f612c8e565b91610552565b146175f257617468818590612d48565b61747c61747661c350617206565b91610552565b116175ec575f61748a6139dc565b9461749430613ce5565b6174b66331e3bd1b9492946174c16174aa6103a2565b96879586948594614b4e565b8452600484016173d0565b03915afa80915f926175c8575b50155f146175bf575060016175ba575b6174e783610d87565b6175006174fa6174f56173ea565b610552565b91610552565b115f146175ac5761750f6173ea565b5b61751930613ce5565b906365a6936e93929490823b156175a7575f9461755486926175499461753d6103a2565b998a9889978896614b4e565b8652600486016173f7565b03925af1908161757b575b50155f14617576576001617571575b5b565b61756e565b61756f565b61759a905f3d81116175a0575b61759281836108d1565b810190614b54565b5f61755f565b503d617588565b614b4a565b6175b583610d87565b617510565b505050565b909250916174de565b6175e59192503d805f833e6175dd81836108d1565b810190617371565b905f6174ce565b50505050565b50505050565b5f61760c91617605612784565b5001616dec565b90565b5f5260205f2090565b61762181616dec565b82101561763b5761763360019161760f565b910201905f90565b610778565b6176509060086176559302610c6a565b61109e565b90565b906176639154617640565b90565b617684915f61767e9261767761334a565b5001617618565b90617658565b90565b6176905f612593565b61769a825f612670565b906176ce6176c87f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e093610ff6565b91610ff6565b916176d76103a2565b806176e181610449565b0390a3565b6176ee613b82565b50617716617710617709617704600685906132f7565b61330d565b8490616532565b156104c0565b6177b8576177369161772c617731926003610fb8565b611002565b6147fe565b6177415f8201613f0b565b61775361774d5f612c8e565b91610552565b148015617792575b61778c5761778161777b617787926177755f429201613f0b565b9061363c565b92610552565b91610552565b101590565b50505f90565b5061779f60608201615e68565b6177b26177ac6003611147565b91611147565b1461775b565b5050505f90565b6177d36177ce6177d8926155a5565b610743565b610552565b90565b634e487b7160e01b5f52603160045260245ffd5b6177f881616d90565b80156178195760019003906178166178108383616d94565b9061334e565b55565b6177db565b617826613b82565b5061783d617838600183018490616df0565b610936565b908161785161784b5f612c8e565b91610552565b14155f1461791d576178cf9260016178ca92846178785f96617872856177bf565b9061363c565b617895617886888501616dec565b61788f866177bf565b9061363c565b816178a86178a283610552565b91610552565b036178d4575b5050506178c46178bf868301616d84565b6177ef565b01616df0565b612995565b600190565b617915926179076178f36178ed617910948c8901617618565b90617658565b9361790185918c8901617618565b90613328565b91858501616df0565b612fe0565b5f80806178ae565b5050505f90565b90565b61793b61793661794092617924565b610743565b610552565b90565b61797861797f9461796e606094989795617964608086019a5f870190610ef4565b6020850190611117565b6040830190610ef4565b0190610ef4565b565b61799561799061799a926125a0565b61264d565b610ef1565b90565b9392936179a8614b0b565b506179b1616e9e565b506179ba61334a565b506179c485616b1a565b6179ec6179e66fa2a8918ca85bafe22016d0b997e4df60600160ff1b03617927565b91610552565b11617a795790617a0f602094955f94939293617a066103a2565b94859485617943565b838052039060015afa15617a7457617a275f5161264d565b80617a42617a3c617a375f6125bf565b6103ed565b916103ed565b14617a58575f91617a525f617981565b91929190565b50617a625f6125bf565b600191617a6e5f617981565b91929190565b614b86565b505050617a855f6125bf565b906003929192919056fea164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static DEPLOYED_BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\x80`@R`\x046\x10\x15a\0\x13W[a$\xF9V[a\0\x1D_5a\x03\x9CV[\x80c\x05w\x85P\x14a\x03\x97W\x80c\x07X#o\x14a\x03\x92W\x80c\x0Cviz\x14a\x03\x8DW\x80c\x19\x1C\xBD\x1A\x14a\x03\x88W\x80c\x1E\x8F^\xE5\x14a\x03\x83W\x80c \x81)V\x14a\x03~W\x80c\"\xF1\xEC\x93\x14a\x03yW\x80c+\xF4\xD6\xA7\x14a\x03tW\x80c,\x95v\x88\x14a\x03oW\x80c-\xAE\x18\x85\x14a\x03jW\x80c/K\xD7\xB8\x14a\x03eW\x80c1\xE3\xBD\x1B\x14a\x03`W\x80c6D\xE5\x15\x14a\x03[W\x80c:\xC3\xCB\xE6\x14a\x03VW\x80c>n4\xA7\x14a\x03QW\x80c?\xD6,m\x14a\x03LW\x80c@#Z\x9C\x14a\x03GW\x80cH\xF4\xDA \x14a\x03BW\x80cV\x85\xCFh\x14a\x03=W\x80cV\xC4\xE1}\x14a\x038W\x80cY\xDC\xEA\x12\x14a\x033W\x80cZ\x93m\xC6\x14a\x03.W\x80c\\\xCE\x98\xA6\x14a\x03)W\x80c`vC\x9C\x14a\x03$W\x80c`\xCF\t\x91\x14a\x03\x1FW\x80ca\xD6\xB8l\x14a\x03\x1AW\x80cb\xC7\xE8\xFC\x14a\x03\x15W\x80ce\xA6\x93n\x14a\x03\x10W\x80ck\xFE\x06\xA6\x14a\x03\x0BW\x80cqP\x18\xA6\x14a\x03\x06W\x80cq\xE78\x8C\x14a\x03\x01W\x80cv9\xD2'\x14a\x02\xFCW\x80cy\xBAP\x97\x14a\x02\xF7W\x80c{\x9Fd\xB2\x14a\x02\xF2W\x80c\x81\xBE\xAC.\x14a\x02\xEDW\x80c\x84\xEFs\"\x14a\x02\xE8W\x80c\x8D\xA5\xCB[\x14a\x02\xE3W\x80c\x96hl\x1E\x14a\x02\xDEW\x80c\x9C\xBD\xAE\"\x14a\x02\xD9W\x80c\xAD\xFF\x83\x0C\x14a\x02\xD4W\x80c\xAEG\n\x85\x14a\x02\xCFW\x80c\xB0t\xE9\xDD\x14a\x02\xCAW\x80c\xB9\x9FgY\x14a\x02\xC5W\x80c\xBA\x1F\xB1\x03\x14a\x02\xC0W\x80c\xC1\xEF\x9D\xDF\x14a\x02\xBBW\x80c\xC5\xD9`\xBB\x14a\x02\xB6W\x80c\xCF\xE3GI\x14a\x02\xB1W\x80c\xD5Q\x16,\x14a\x02\xACW\x80c\xDACZ|\x14a\x02\xA7W\x80c\xE3\x0C9x\x14a\x02\xA2W\x80c\xE6\\\xAF\xCB\x14a\x02\x9DW\x80c\xEE\x1C\x03\x90\x14a\x02\x98W\x80c\xF2\xFD\xE3\x8B\x14a\x02\x93W\x80c\xF9\x10\x7F;\x14a\x02\x8EW\x80c\xF9\xF1gb\x14a\x02\x89Wc\xFF\xCF\x08\xF0\x03a\0\x0EWa$\xC5V[a$\x90V[a$-V[a#\xCDV[a#\x97V[a#cV[a#.V[a\"\xF6V[a\"$V[a!\xEFV[a!\xADV[a!xV[a NV[a \x1AV[a\x1F\xADV[a\x1FsV[a\x1E\xAAV[a\x1D\xE7V[a\x1C`V[a\x1B\xAAV[a\x1BwV[a\x1B@V[a\x1A\xABV[a\x1AxV[a\x1ABV[a\x1A\x0CV[a\x19PV[a\x19\x1BV[a\x18\xADV[a\x16rV[a\x16(V[a\x15\xA6V[a\x15qV[a\x15\x03V[a\x14pV[a\x14\x17V[a\x13\xE2V[a\x13}V[a\x133V[a\x12\xC7V[a\x11\xF3V[a\x11\xB9V[a\x0F\x83V[a\x0F\x16V[a\x0E\x97V[a\r\x1EV[a\x0C\xD0V[a\x0C5V[a\x0B\x8FV[a\nbV[a\x06\xC0V[a\x06nV[a\x06:V[a\x05wV[a\x05\x1DV[a\x04NV[`\xE0\x1C\x90V[`@Q\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[`\x01\x80`@\x1B\x03\x16\x90V[a\x03\xC8\x81a\x03\xB4V[\x03a\x03\xCFWV[_\x80\xFD[\x90P5\x90a\x03\xE0\x82a\x03\xBFV[V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x03\xF6\x90a\x03\xE2V[\x90V[a\x04\x02\x81a\x03\xEDV[\x03a\x04\tWV[_\x80\xFD[\x90P5\x90a\x04\x1A\x82a\x03\xF9V[V[\x91\x90`@\x83\x82\x03\x12a\x04DW\x80a\x048a\x04A\x92_\x86\x01a\x03\xD3V[\x93` \x01a\x04\rV[\x90V[a\x03\xACV[_\x01\x90V[4a\x04}Wa\x04ga\x04a6`\x04a\x04\x1CV[\x90a&\x90V[a\x04oa\x03\xA2V[\x80a\x04y\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x04\x9BWa\x04\x98\x91_\x01a\x03\xD3V[\x90V[a\x03\xACV[a\x04\xA9\x90a\x03\xB4V[\x90RV[`\xFF\x16\x90V[a\x04\xBC\x90a\x04\xADV[\x90RV[\x15\x15\x90V[a\x04\xCE\x90a\x04\xC0V[\x90RV[\x90`@\x80a\x05\x06\x93a\x04\xEA_\x82\x01Q_\x86\x01\x90a\x04\xA0V[a\x04\xFC` \x82\x01Q` \x86\x01\x90a\x04\xB3V[\x01Q\x91\x01\x90a\x04\xC5V[V[\x91\x90a\x05\x1B\x90_``\x85\x01\x94\x01\x90a\x04\xD2V[V[4a\x05MWa\x05Ia\x058a\x0536`\x04a\x04\x82V[a'oV[a\x05@a\x03\xA2V[\x91\x82\x91\x82a\x05\x08V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x05^\x90a\x05RV[\x90RV[\x91\x90a\x05u\x90_` \x85\x01\x94\x01\x90a\x05UV[V[4a\x05\xA8Wa\x05\xA4a\x05\x93a\x05\x8D6`\x04a\x04\x1CV[\x90a'\x88V[a\x05\x9Ba\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x05\xF1W\x815\x91`\x01\x80`@\x1B\x03\x83\x11a\x05\xECW` \x01\x92` \x83\x02\x84\x01\x11a\x05\xE7WV[a\x05\xB5V[a\x05\xB1V[a\x05\xADV[\x91\x90\x91`@\x81\x84\x03\x12a\x065Wa\x06\x0F\x83_\x83\x01a\x03\xD3V[\x92` \x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x060Wa\x06,\x92\x01a\x05\xB9V[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x06iWa\x06Sa\x06M6`\x04a\x05\xF6V[\x91a0\xFEV[a\x06[a\x03\xA2V[\x80a\x06e\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a\x06\x9DWa\x06\x87a\x06\x816`\x04a\x04\x1CV[\x90a3\xE8V[a\x06\x8Fa\x03\xA2V[\x80a\x06\x99\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x06\xBBWa\x06\xB8\x91_\x01a\x04\rV[\x90V[a\x03\xACV[4a\x06\xEEWa\x06\xD8a\x06\xD36`\x04a\x06\xA2V[a5\x1DV[a\x06\xE0a\x03\xA2V[\x80a\x06\xEA\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[a\x06\xFC\x81a\x05RV[\x03a\x07\x03WV[_\x80\xFD[\x90P5\x90a\x07\x14\x82a\x06\xF3V[V[\x91\x90`@\x83\x82\x03\x12a\x07>W\x80a\x072a\x07;\x92_\x86\x01a\x03\xD3V[\x93` \x01a\x07\x07V[\x90V[a\x03\xACV[\x90V[a\x07Za\x07Ua\x07_\x92a\x03\xB4V[a\x07CV[a\x03\xB4V[\x90V[\x90a\x07l\x90a\x07FV[_R` R`@_ \x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[T\x90V[_R` _ \x90V[_R` _ \x90V[a\x07\xAB\x81a\x07\x8CV[\x82\x10\x15a\x07\xC5Wa\x07\xBD`\x04\x91a\x07\x90V[\x91\x02\x01\x90_\x90V[a\x07xV[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x90`\x01`\x02\x83\x04\x92\x16\x80\x15a\x07\xFEW[` \x83\x10\x14a\x07\xF9WV[a\x07\xCAV[\x91`\x7F\x16\x91a\x07\xEEV[` \x91\x81R\x01\x90V[_R` _ \x90V[\x90_\x92\x91\x80T\x90a\x084a\x08-\x83a\x07\xDEV[\x80\x94a\x08\x08V[\x91`\x01\x81\x16\x90\x81_\x14a\x08\x8BWP`\x01\x14a\x08OW[PPPV[a\x08\\\x91\x92\x93\x94Pa\x08\x11V[\x91_\x92[\x81\x84\x10a\x08sWPP\x01\x90_\x80\x80a\x08JV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a\x08`V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a\x08JV[\x90a\x08\xB0\x91a\x08\x1AV[\x90V[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\x08\xDB\x90a\x08\xB3V[\x81\x01\x90\x81\x10`\x01\x80`@\x1B\x03\x82\x11\x17a\x08\xF3W`@RV[a\x08\xBDV[\x90a\t\x18a\t\x11\x92a\t\x08a\x03\xA2V[\x93\x84\x80\x92a\x08\xA6V[\x03\x83a\x08\xD1V[V[_\x1C\x90V[\x90V[a\t.a\t3\x91a\t\x1AV[a\t\x1FV[\x90V[a\t@\x90Ta\t\"V[\x90V[`\xFF\x16\x90V[a\tUa\tZ\x91a\t\x1AV[a\tCV[\x90V[a\tg\x90Ta\tIV[\x90V[a\tu\x90`\x08a\x07bV[\x90a\t\x7F\x82a\x07\x8CV[\x81\x10\x15a\t\xC5Wa\t\x8F\x91a\x07\xA2V[P\x90a\t\x9C_\x83\x01a\x08\xF8V[\x91a\t\xA9`\x01\x82\x01a\t6V[\x91a\t\xC2`\x03a\t\xBB`\x02\x85\x01a\t6V[\x93\x01a\t]V[\x90V[_\x80\xFD[Q\x90V[` \x91\x81R\x01\x90V[\x90\x82_\x93\x92\x82^\x01RV[a\n\0a\n\t` \x93a\n\x0E\x93a\t\xF7\x81a\t\xC9V[\x93\x84\x80\x93a\t\xCDV[\x95\x86\x91\x01a\t\xD6V[a\x08\xB3V[\x01\x90V[a\n\x1B\x90a\x04\xC0V[\x90RV[a\nYa\n`\x94a\nOa\nD``\x95\x99\x98\x96\x99`\x80\x86\x01\x90\x86\x82\x03_\x88\x01Ra\t\xE1V[\x98` \x85\x01\x90a\x05UV[`@\x83\x01\x90a\x05UV[\x01\x90a\n\x12V[V[4a\n\x97Wa\n\x93a\n~a\nx6`\x04a\x07\x16V[\x90a\tjV[\x90a\n\x8A\x94\x92\x94a\x03\xA2V[\x94\x85\x94\x85a\n\x1FV[\x03\x90\xF3[a\x03\xA8V[a\n\xA5\x81a\x04\xADV[\x03a\n\xACWV[_\x80\xFD[\x90P5\x90a\n\xBD\x82a\n\x9CV[V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\n\xF7W\x815\x91`\x01\x80`@\x1B\x03\x83\x11a\n\xF2W` \x01\x92`\x01\x83\x02\x84\x01\x11a\n\xEDWV[a\x05\xB5V[a\x05\xB1V[a\x05\xADV[\x91\x90`\xC0\x83\x82\x03\x12a\x0B\x8AWa\x0B\x14\x81_\x85\x01a\x03\xD3V[\x92a\x0B\"\x82` \x83\x01a\x03\xD3V[\x92a\x0B0\x83`@\x84\x01a\n\xB0V[\x92``\x83\x015`\x01\x80`@\x1B\x03\x81\x11a\x0B\x85W\x81a\x0BO\x91\x85\x01a\n\xBFV[\x92\x90\x93a\x0B_\x83`\x80\x83\x01a\x03\xD3V[\x92`\xA0\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x0B\x80Wa\x0B|\x92\x01a\n\xBFV[\x90\x91V[a\x03\xB0V[a\x03\xB0V[a\x03\xACV[4a\x0B\xC7Wa\x0B\xB1a\x0B\xA26`\x04a\n\xFCV[\x96\x95\x90\x95\x94\x91\x94\x93\x92\x93a9\xCAV[a\x0B\xB9a\x03\xA2V[\x80a\x0B\xC3\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[_\x91\x03\x12a\x0B\xD6WV[a\x03\xACV[\x90V[a\x0B\xF2a\x0B\xEDa\x0B\xF7\x92a\x0B\xDBV[a\x07CV[a\x03\xB4V[\x90V[a\x0C\x05a\x01,a\x0B\xDEV[\x90V[a\x0C\x10a\x0B\xFAV[\x90V[a\x0C\x1C\x90a\x03\xB4V[\x90RV[\x91\x90a\x0C3\x90_` \x85\x01\x94\x01\x90a\x0C\x13V[V[4a\x0CeWa\x0CE6`\x04a\x0B\xCCV[a\x0Caa\x0CPa\x0C\x08V[a\x0CXa\x03\xA2V[\x91\x82\x91\x82a\x0C V[\x03\x90\xF3[a\x03\xA8V[\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x0C\x89\x90`\x08a\x0C\x8E\x93\x02a\x0CjV[a\x0CnV[\x90V[\x90a\x0C\x9C\x91Ta\x0CyV[\x90V[a\x0C\xAB`\x0B_\x90a\x0C\x91V[\x90V[a\x0C\xB7\x90a\x03\xEDV[\x90RV[\x91\x90a\x0C\xCE\x90_` \x85\x01\x94\x01\x90a\x0C\xAEV[V[4a\r\0Wa\x0C\xE06`\x04a\x0B\xCCV[a\x0C\xFCa\x0C\xEBa\x0C\x9FV[a\x0C\xF3a\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[a\r\x10a\x01,a\x0B\xDEV[\x90V[a\r\x1Ba\r\x05V[\x90V[4a\rNWa\r.6`\x04a\x0B\xCCV[a\rJa\r9a\r\x13V[a\rAa\x03\xA2V[\x91\x82\x91\x82a\x0C V[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\r\x82W_\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\r}Wa\ry\x92\x01a\n\xBFV[\x90\x91V[a\x03\xB0V[a\x03\xACV[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\r\xB9a\r\xC2` \x93a\r\xC7\x93a\r\xB0\x81a\t\xC9V[\x93\x84\x80\x93a\x08\x08V[\x95\x86\x91\x01a\t\xD6V[a\x08\xB3V[\x01\x90V[a\r\xD4\x90a\x05RV[\x90RV[\x90a\x0E\x02\x90` \x80a\r\xF7`@\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\x9AV[\x94\x01Q\x91\x01\x90a\r\xCBV[\x90V[\x90a\x0E\x0F\x91a\r\xD8V[\x90V[` \x01\x90V[\x90a\x0E,a\x0E%\x83a\r\x87V[\x80\x92a\r\x8BV[\x90\x81a\x0E=` \x83\x02\x84\x01\x94a\r\x94V[\x92_\x91[\x83\x83\x10a\x0EPWPPPPP\x90V[\x90\x91\x92\x93\x94` a\x0Era\x0El\x83\x85`\x01\x95\x03\x87R\x89Qa\x0E\x05V[\x97a\x0E\x12V[\x93\x01\x93\x01\x91\x93\x92\x90a\x0EAV[a\x0E\x94\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x0E\x18V[\x90V[4a\x0E\xC8Wa\x0E\xC4a\x0E\xB3a\x0E\xAD6`\x04a\rSV[\x90a:\x14V[a\x0E\xBBa\x03\xA2V[\x91\x82\x91\x82a\x0E\x7FV[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[\x90V[a\x0E\xFD\x90a\x0E\xF1V[\x90RV[\x91\x90a\x0F\x14\x90_` \x85\x01\x94\x01\x90a\x0E\xF4V[V[4a\x0FFWa\x0F&6`\x04a\x0B\xCCV[a\x0FBa\x0F1a\x0E\xCDV[a\x0F9a\x03\xA2V[\x91\x82\x91\x82a\x0F\x01V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x0Fba\x0F]a\x0Fg\x92a\x0FKV[a\x07CV[a\x03\xB4V[\x90V[a\x0Fua\x0E\x10a\x0FNV[\x90V[a\x0F\x80a\x0FjV[\x90V[4a\x0F\xB3Wa\x0F\x936`\x04a\x0B\xCCV[a\x0F\xAFa\x0F\x9Ea\x0FxV[a\x0F\xA6a\x03\xA2V[\x91\x82\x91\x82a\x0C V[\x03\x90\xF3[a\x03\xA8V[\x90a\x0F\xC2\x90a\x07FV[_R` R`@_ \x90V[a\x0F\xE2a\x0F\xDDa\x0F\xE7\x92a\x03\xE2V[a\x07CV[a\x03\xE2V[\x90V[a\x0F\xF3\x90a\x0F\xCEV[\x90V[a\x0F\xFF\x90a\x0F\xEAV[\x90V[\x90a\x10\x0C\x90a\x0F\xF6V[_R` R`@_ \x90V[`\x01\x80`@\x1B\x03\x16\x90V[a\x10/a\x104\x91a\t\x1AV[a\x10\x18V[\x90V[a\x10A\x90Ta\x10#V[\x90V[`@\x1C\x90V[`\xFF\x16\x90V[a\x10\\a\x10a\x91a\x10DV[a\x10JV[\x90V[a\x10n\x90Ta\x10PV[\x90V[`H\x1C\x90V[`\xFF\x16\x90V[a\x10\x89a\x10\x8E\x91a\x10qV[a\x10wV[\x90V[a\x10\x9B\x90Ta\x10}V[\x90V[\x90V[a\x10\xADa\x10\xB2\x91a\t\x1AV[a\x10\x9EV[\x90V[a\x10\xBF\x90Ta\x10\xA1V[\x90V[\x90a\x10\xD1a\x10\xD6\x92`\x03a\x0F\xB8V[a\x10\x02V[a\x10\xE1_\x82\x01a\t6V[\x91a\x10\xEE`\x01\x83\x01a\x107V[\x91a\x10\xFB`\x01\x82\x01a\x10dV[\x91a\x11\x14`\x02a\x11\r`\x01\x85\x01a\x10\x91V[\x93\x01a\x10\xB5V[\x90V[a\x11 \x90a\x04\xADV[\x90RV[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[`\x05\x11\x15a\x11BWV[a\x11$V[\x90a\x11Q\x82a\x118V[V[a\x11\\\x90a\x11GV[\x90V[a\x11h\x90a\x11SV[\x90RV[\x90\x95\x94\x92a\x11\xB7\x94a\x11\xA6a\x11\xB0\x92a\x11\x9C`\x80\x96a\x11\x92`\xA0\x88\x01\x9C_\x89\x01\x90a\x05UV[` \x87\x01\x90a\x0C\x13V[`@\x85\x01\x90a\x11\x17V[``\x83\x01\x90a\x11_V[\x01\x90a\x0E\xF4V[V[4a\x11\xEEWa\x11\xEAa\x11\xD5a\x11\xCF6`\x04a\x04\x1CV[\x90a\x10\xC2V[\x91a\x11\xE1\x95\x93\x95a\x03\xA2V[\x95\x86\x95\x86a\x11lV[\x03\x90\xF3[a\x03\xA8V[4a\x12#Wa\x12\x1Fa\x12\x0Ea\x12\t6`\x04a\x04\x82V[a:.V[a\x12\x16a\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x12D\x90a\x03\xEDV[\x90RV[\x90a\x12U\x81` \x93a\x12;V[\x01\x90V[` \x01\x90V[\x90a\x12|a\x12va\x12o\x84a\x12(V[\x80\x93a\x12,V[\x92a\x125V[\x90_[\x81\x81\x10a\x12\x8CWPPP\x90V[\x90\x91\x92a\x12\xA5a\x12\x9F`\x01\x92\x86Qa\x12HV[\x94a\x12YV[\x91\x01\x91\x90\x91a\x12\x7FV[a\x12\xC4\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x12_V[\x90V[4a\x12\xF7Wa\x12\xF3a\x12\xE2a\x12\xDD6`\x04a\x04\x82V[a:\xE6V[a\x12\xEAa\x03\xA2V[\x91\x82\x91\x82a\x12\xAFV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x13\x13a\x13\x0Ea\x13\x18\x92a\x12\xFCV[a\x07CV[a\x05RV[\x90V[a\x13%`\xC8a\x12\xFFV[\x90V[a\x130a\x13\x1BV[\x90V[4a\x13cWa\x13C6`\x04a\x0B\xCCV[a\x13_a\x13Na\x13(V[a\x13Va\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x13{\x90_` \x85\x01\x94\x01\x90a\n\x12V[V[4a\x13\xAEWa\x13\xAAa\x13\x99a\x13\x936`\x04a\x04\x1CV[\x90a;\x86V[a\x13\xA1a\x03\xA2V[\x91\x82\x91\x82a\x13hV[\x03\x90\xF3[a\x03\xA8V[\x90a\x13\xBD\x90a\x07FV[_R` R`@_ \x90V[a\x13\xDF\x90a\x13\xDA`\x07\x91_\x92a\x13\xB3V[a\x0C\x91V[\x90V[4a\x14\x12Wa\x14\x0Ea\x13\xFDa\x13\xF86`\x04a\x04\x82V[a\x13\xC9V[a\x14\x05a\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[4a\x14GWa\x14Ca\x142a\x14-6`\x04a\x04\x82V[a<\rV[a\x14:a\x03\xA2V[\x91\x82\x91\x82a\x12\xAFV[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[4a\x14\xA0Wa\x14\x806`\x04a\x0B\xCCV[a\x14\x9Ca\x14\x8Ba\x14LV[a\x14\x93a\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[\x90`\x80\x82\x82\x03\x12a\x14\xFEWa\x14\xBC\x81_\x84\x01a\x03\xD3V[\x92a\x14\xCA\x82` \x85\x01a\x03\xD3V[\x92a\x14\xD8\x83`@\x83\x01a\n\xB0V[\x92``\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x14\xF9Wa\x14\xF5\x92\x01a\n\xBFV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x155Wa\x15\x1Fa\x15\x166`\x04a\x14\xA5V[\x93\x92\x90\x92a<\x7FV[a\x15'a\x03\xA2V[\x80a\x151\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x15Qa\x15La\x15V\x92a\x15:V[a\x07CV[a\x05RV[\x90V[a\x15c`2a\x15=V[\x90V[a\x15na\x15YV[\x90V[4a\x15\xA1Wa\x15\x816`\x04a\x0B\xCCV[a\x15\x9Da\x15\x8Ca\x15fV[a\x15\x94a\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[4a\x15\xD7Wa\x15\xD3a\x15\xC2a\x15\xBC6`\x04a\x04\x1CV[\x90a<\x8EV[a\x15\xCAa\x03\xA2V[\x91\x82\x91\x82a\x13hV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x15\xF3a\x15\xEEa\x15\xF8\x92a\x15\xDCV[a\x07CV[a\x04\xADV[\x90V[a\x16\x05`\x03a\x15\xDFV[\x90V[a\x16\x10a\x15\xFBV[\x90V[\x91\x90a\x16&\x90_` \x85\x01\x94\x01\x90a\x11\x17V[V[4a\x16XWa\x1686`\x04a\x0B\xCCV[a\x16Ta\x16Ca\x16\x08V[a\x16Ka\x03\xA2V[\x91\x82\x91\x82a\x16\x13V[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x16p\x90_` \x85\x01\x94\x01\x90a\x11_V[V[4a\x16\xA3Wa\x16\x9Fa\x16\x8Ea\x16\x886`\x04a\x04\x1CV[\x90a<\xBAV[a\x16\x96a\x03\xA2V[\x91\x82\x91\x82a\x16]V[\x03\x90\xF3[a\x03\xA8V[\x90a\x16\xBBa\x16\xB4a\x03\xA2V[\x92\x83a\x08\xD1V[V[`\x01\x80`@\x1B\x03\x81\x11a\x16\xD3W` \x80\x91\x02\x01\x90V[a\x08\xBDV[_\x80\xFD[_\x80\xFD[_\x80\xFD[`\x01\x80`@\x1B\x03\x81\x11a\x17\0Wa\x16\xFC` \x91a\x08\xB3V[\x01\x90V[a\x08\xBDV[\x90\x82_\x93\x92\x827\x01RV[\x90\x92\x91\x92a\x17%a\x17 \x82a\x16\xE4V[a\x16\xA8V[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a\x17AWa\x17?\x92a\x17\x05V[V[a\x16\xE0V[\x90\x80`\x1F\x83\x01\x12\x15a\x17dW\x81` a\x17a\x935\x91\x01a\x17\x10V[\x90V[a\x05\xADV[\x91\x90\x91`@\x81\x84\x03\x12a\x17\xBAWa\x17\x80`@a\x16\xA8V[\x92_\x82\x015\x91`\x01\x80`@\x1B\x03\x83\x11a\x17\xB5Wa\x17\xA2\x82a\x17\xAE\x94\x83\x01a\x17FV[_\x86\x01R` \x01a\x07\x07V[` \x83\x01RV[a\x16\xDCV[a\x16\xD8V[\x92\x91\x90a\x17\xD3a\x17\xCE\x82a\x16\xBDV[a\x16\xA8V[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11a\x18(W\x81\x90[\x83\x82\x10a\x17\xF9WPPPPPV[\x815`\x01\x80`@\x1B\x03\x81\x11a\x18#W` \x91a\x18\x18\x87\x84\x93\x87\x01a\x17iV[\x81R\x01\x91\x01\x90a\x17\xEBV[a\x05\xADV[a\x05\xB5V[\x90\x80`\x1F\x83\x01\x12\x15a\x18KW\x81` a\x18H\x935\x91\x01a\x17\xBFV[\x90V[a\x05\xADV[`\x80\x81\x83\x03\x12a\x18\xA8Wa\x18f\x82_\x83\x01a\x03\xD3V[\x92a\x18t\x83` \x84\x01a\x04\rV[\x92`@\x83\x015\x90`\x01\x80`@\x1B\x03\x82\x11a\x18\xA3Wa\x18\x97\x81a\x18\xA0\x93\x86\x01a\x18-V[\x93``\x01a\x07\x07V[\x90V[a\x03\xB0V[a\x03\xACV[4a\x18\xDFWa\x18\xC9a\x18\xC06`\x04a\x18PV[\x92\x91\x90\x91a@\x9EV[a\x18\xD1a\x03\xA2V[\x80a\x18\xDB\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x18\xFBa\x18\xF6a\x19\0\x92a\x18\xE4V[a\x07CV[a\x05RV[\x90V[a\x19\r`@a\x18\xE7V[\x90V[a\x19\x18a\x19\x03V[\x90V[4a\x19KWa\x19+6`\x04a\x0B\xCCV[a\x19Ga\x196a\x19\x10V[a\x19>a\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[4a\x19~Wa\x19`6`\x04a\x0B\xCCV[a\x19haF\xCDV[a\x19pa\x03\xA2V[\x80a\x19z\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[a\x19\x8C\x90a\x11SV[\x90RV[a\x19\x99\x90a\x0E\xF1V[\x90RV[\x90`\x80\x80a\x19\xF5\x93a\x19\xB5_\x82\x01Q_\x86\x01\x90a\r\xCBV[a\x19\xC7` \x82\x01Q` \x86\x01\x90a\x04\xA0V[a\x19\xD9`@\x82\x01Q`@\x86\x01\x90a\x04\xB3V[a\x19\xEB``\x82\x01Q``\x86\x01\x90a\x19\x83V[\x01Q\x91\x01\x90a\x19\x90V[V[\x91\x90a\x1A\n\x90_`\xA0\x85\x01\x94\x01\x90a\x19\x9DV[V[4a\x1A=Wa\x1A9a\x1A(a\x1A\"6`\x04a\x04\x1CV[\x90aH\nV[a\x1A0a\x03\xA2V[\x91\x82\x91\x82a\x19\xF7V[\x03\x90\xF3[a\x03\xA8V[4a\x1AsWa\x1Aoa\x1A^a\x1AX6`\x04a\x04\x1CV[\x90aHbV[a\x1Afa\x03\xA2V[\x91\x82\x91\x82a\x0C V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xA6Wa\x1A\x886`\x04a\x0B\xCCV[a\x1A\x90aH\x8AV[a\x1A\x98a\x03\xA2V[\x80a\x1A\xA2\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xDBWa\x1A\xD7a\x1A\xC6a\x1A\xC16`\x04a\x04\x82V[aH\xDBV[a\x1A\xCEa\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a\x1B\x15Wa\x1B\x12a\x1A\xFB\x84_\x85\x01a\x03\xD3V[\x93a\x1B\t\x81` \x86\x01a\x07\x07V[\x93`@\x01a\x07\x07V[\x90V[a\x03\xACV[\x92\x91` a\x1B6a\x1B>\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\x12_V[\x94\x01\x90a\x05UV[V[4a\x1BrWa\x1BYa\x1BS6`\x04a\x1A\xE0V[\x91aIyV[\x90a\x1Bna\x1Bea\x03\xA2V[\x92\x83\x92\x83a\x1B\x1AV[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xA5Wa\x1B\x8Fa\x1B\x8A6`\x04a\x06\xA2V[aK\0V[a\x1B\x97a\x03\xA2V[\x80a\x1B\xA1\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xDAWa\x1B\xBA6`\x04a\x0B\xCCV[a\x1B\xD6a\x1B\xC5aK\x0FV[a\x1B\xCDa\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1C\x17W\x815\x91`\x01\x80`@\x1B\x03\x83\x11a\x1C\x12W` \x01\x92` \x83\x02\x84\x01\x11a\x1C\rWV[a\x05\xB5V[a\x05\xB1V[a\x05\xADV[\x91\x90\x91`@\x81\x84\x03\x12a\x1C[Wa\x1C5\x83_\x83\x01a\x03\xD3V[\x92` \x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x1CVWa\x1CR\x92\x01a\x1B\xDFV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1C\x8FWa\x1Cya\x1Cs6`\x04a\x1C\x1CV[\x91aK\x96V[a\x1C\x81a\x03\xA2V[\x80a\x1C\x8B\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x91``\x83\x83\x03\x12a\x1C\xDEWa\x1C\xAB\x82_\x85\x01a\x03\xD3V[\x92a\x1C\xB9\x83` \x83\x01a\x04\rV[\x92`@\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x1C\xD9Wa\x1C\xD6\x92\x01a\x17FV[\x90V[a\x03\xB0V[a\x03\xACV[\x90a\x1C\xED\x90a\x07FV[_R` R`@_ \x90V[\x90a\x1D\x03\x90a\x0F\xF6V[_R` R`@_ \x90V[\x90P\x90V[a\x1D9a\x1D0\x92` \x92a\x1D'\x81a\t\xC9V[\x94\x85\x80\x93a\x1D\x0FV[\x93\x84\x91\x01a\t\xD6V[\x01\x90V[\x90V[a\x1DLa\x1DQ\x91a\x05RV[a\x1D=V[\x90RV[a\x1Dea\x1Dl\x91` \x94\x93a\x1D\x14V[\x80\x92a\x1D@V[\x01\x90V[a\x1D\x84a\x1D{a\x03\xA2V[\x92\x83\x92\x83a\x1DUV[\x03\x90 \x90V[a\x1D\x93\x91a\x1DpV[\x90V[a\x1D\xA6\x90`\x08a\x1D\xAB\x93\x02a\x0CjV[a\t\x1FV[\x90V[\x90a\x1D\xB9\x91Ta\x1D\x96V[\x90V[\x90a\x1D\xE4\x92a\x1D\xDAa\x1D\xDF\x92a\x1D\xD5`\t\x95_\x96a\x1C\xE3V[a\x1C\xF9V[a\x1D\x8AV[a\x1D\xAEV[\x90V[4a\x1E\x18Wa\x1E\x14a\x1E\x03a\x1D\xFD6`\x04a\x1C\x94V[\x91a\x1D\xBCV[a\x1E\x0Ba\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1EUW\x815\x91`\x01\x80`@\x1B\x03\x83\x11a\x1EPW` \x01\x92`\x01\x83\x02\x84\x01\x11a\x1EKWV[a\x05\xB5V[a\x05\xB1V[a\x05\xADV[\x91``\x83\x83\x03\x12a\x1E\xA5Wa\x1Eq\x82_\x85\x01a\x03\xD3V[\x92a\x1E\x7F\x83` \x83\x01a\x04\rV[\x92`@\x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x1E\xA0Wa\x1E\x9C\x92\x01a\x1E\x1DV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1E\xDCWa\x1E\xC6a\x1E\xBD6`\x04a\x1EZV[\x92\x91\x90\x91aM\xF9V[a\x1E\xCEa\x03\xA2V[\x80a\x1E\xD8\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[a\x1E\xEA\x81a\x04\xC0V[\x03a\x1E\xF1WV[_\x80\xFD[\x90P5\x90a\x1F\x02\x82a\x1E\xE1V[V[\x91\x90\x91`\xA0\x81\x84\x03\x12a\x1FnWa\x1F\x1D\x83_\x83\x01a\x03\xD3V[\x92` \x82\x015`\x01\x80`@\x1B\x03\x81\x11a\x1FiW\x81a\x1F<\x91\x84\x01a\x1E\x1DV[\x92\x90\x93a\x1Ffa\x1FO\x84`@\x85\x01a\x07\x07V[\x93a\x1F]\x81``\x86\x01a\x07\x07V[\x93`\x80\x01a\x1E\xF5V[\x90V[a\x03\xB0V[a\x03\xACV[4a\x1F\xA8Wa\x1F\x92a\x1F\x866`\x04a\x1F\x04V[\x94\x93\x90\x93\x92\x91\x92aP\xC7V[a\x1F\x9Aa\x03\xA2V[\x80a\x1F\xA4\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a\x1F\xDBWa\x1F\xC5a\x1F\xC06`\x04a\x04\x82V[aTwV[a\x1F\xCDa\x03\xA2V[\x80a\x1F\xD7\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a \x15Wa \x12a\x1F\xFB\x84_\x85\x01a\x03\xD3V[\x93a \t\x81` \x86\x01a\x03\xD3V[\x93`@\x01a\n\xB0V[\x90V[a\x03\xACV[4a IWa 3a -6`\x04a\x1F\xE0V[\x91aV\xECV[a ;a\x03\xA2V[\x80a E\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a }Wa ga a6`\x04a\x04\x1CV[\x90aX\xABV[a oa\x03\xA2V[\x80a y\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[\x90a \xE3\x90``\x80a \xB4`\x80\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\x9AV[\x94a \xC7` \x82\x01Q` \x86\x01\x90a\r\xCBV[a \xD9`@\x82\x01Q`@\x86\x01\x90a\r\xCBV[\x01Q\x91\x01\x90a\x04\xC5V[\x90V[\x90a \xF0\x91a \x95V[\x90V[` \x01\x90V[\x90a!\ra!\x06\x83a \x82V[\x80\x92a \x86V[\x90\x81a!\x1E` \x83\x02\x84\x01\x94a \x8FV[\x92_\x91[\x83\x83\x10a!1WPPPPP\x90V[\x90\x91\x92\x93\x94` a!Sa!M\x83\x85`\x01\x95\x03\x87R\x89Qa \xE6V[\x97a \xF3V[\x93\x01\x93\x01\x91\x93\x92\x90a!\"V[a!u\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra \xF9V[\x90V[4a!\xA8Wa!\xA4a!\x93a!\x8E6`\x04a\x04\x82V[a\\ V[a!\x9Ba\x03\xA2V[\x91\x82\x91\x82a!`V[\x03\x90\xF3[a\x03\xA8V[4a!\xDBWa!\xC5a!\xC06`\x04a\x04\x82V[a]\xB0V[a!\xCDa\x03\xA2V[\x80a!\xD7\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[a!\xEC`\n_\x90a\x0C\x91V[\x90V[4a\"\x1FWa!\xFF6`\x04a\x0B\xCCV[a\"\x1Ba\"\na!\xE0V[a\"\x12a\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[4a\"XWa\"Ta\"Ca\":6`\x04a\x1EZV[\x92\x91\x90\x91a^\x1DV[a\"Ka\x03\xA2V[\x91\x82\x91\x82a\x05bV[\x03\x90\xF3[a\x03\xA8V[\x90a\"g\x90a\x07FV[_R` R`@_ \x90V[a\"\x7Fa\"\x84\x91a\x10qV[a\tCV[\x90V[a\"\x91\x90Ta\"sV[\x90V[a\"\x9F\x90`\x02a\"]V[a\"\xAA_\x82\x01a\x107V[\x91a\"\xC1_a\"\xBA\x81\x85\x01a\x10dV[\x93\x01a\"\x87V[\x90V[`@\x90a\"\xEDa\"\xF4\x94\x96\x95\x93\x96a\"\xE3``\x84\x01\x98_\x85\x01\x90a\x0C\x13V[` \x83\x01\x90a\x11\x17V[\x01\x90a\n\x12V[V[4a#)Wa#%a#\x11a#\x0C6`\x04a\x04\x82V[a\"\x94V[a#\x1C\x93\x91\x93a\x03\xA2V[\x93\x84\x93\x84a\"\xC4V[\x03\x90\xF3[a\x03\xA8V[4a#^Wa#>6`\x04a\x0B\xCCV[a#Za#Ia^RV[a#Qa\x03\xA2V[\x91\x82\x91\x82a\x0C\xBBV[\x03\x90\xF3[a\x03\xA8V[4a#\x92Wa#|a#v6`\x04a\x04\x1CV[\x90a_<V[a#\x84a\x03\xA2V[\x80a#\x8E\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[4a#\xC8Wa#\xC4a#\xB3a#\xAD6`\x04a\x04\x1CV[\x90a`\xD1V[a#\xBBa\x03\xA2V[\x91\x82\x91\x82a\x13hV[\x03\x90\xF3[a\x03\xA8V[4a#\xFBWa#\xE5a#\xE06`\x04a\x06\xA2V[aa\xD0V[a#\xEDa\x03\xA2V[\x80a#\xF7\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x91\x90`@\x83\x82\x03\x12a$(W\x80a$\x1Ca$%\x92_\x86\x01a\x03\xD3V[\x93` \x01a\x1E\xF5V[\x90V[a\x03\xACV[4a$\\Wa$Fa$@6`\x04a$\0V[\x90aa\xDBV[a$Na\x03\xA2V[\x80a$X\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[\x7F2r\x1F\x8D\xC6~\x95<T\r\xA9\x0Ff0Y\xC2?\xC4\x7Fp\xD1\x1E1~\xD6\xD5\xA2L\x8B\x85ct\x90V[a$\x8Da$aV[\x90V[4a$\xC0Wa$\xA06`\x04a\x0B\xCCV[a$\xBCa$\xABa$\x85V[a$\xB3a\x03\xA2V[\x91\x82\x91\x82a\x0F\x01V[\x03\x90\xF3[a\x03\xA8V[4a$\xF4Wa$\xDEa$\xD86`\x04a\x04\x1CV[\x90ab\xA4V[a$\xE6a\x03\xA2V[\x80a$\xF0\x81a\x04IV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x7FOnly Tangle core\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%1`\x10` \x92a\t\xCDV[a%:\x81a$\xFDV[\x01\x90V[a%S\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%$V[\x90V[\x15a%]WV[a%ea\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a%{`\x04\x82\x01a%>V[\x03\x90\xFD[a%\x8Ba%\x90\x91a\t\x1AV[a\x0CnV[\x90V[a%\x9D\x90Ta%\x7FV[\x90V[\x90V[a%\xB7a%\xB2a%\xBC\x92a%\xA0V[a\x07CV[a\x03\xE2V[\x90V[a%\xC8\x90a%\xA3V[\x90V[_\x7FAlready registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%\xFF`\x12` \x92a\t\xCDV[a&\x08\x81a%\xCBV[\x01\x90V[a&!\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%\xF2V[\x90V[\x15a&+WV[a&3a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a&I`\x04\x82\x01a&\x0CV[\x03\x90\xFD[_\x1B\x90V[\x90a&c`\x01\x80`\xA0\x1B\x03\x91a&MV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90a&\x85a&\x80a&\x8C\x92a\x0F\xF6V[a&mV[\x82Ta&RV[\x90UV[a'\x12a'\x17\x92a&\xD33a&\xCDa&\xC7\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEDV[\x91a\x03\xEDV[\x14a%VV[a'\na&\xEAa&\xE5`\x07\x86\x90a\x13\xB3V[a%\x93V[a'\x04a&\xFEa&\xF9_a%\xBFV[a\x03\xEDV[\x91a\x03\xEDV[\x14a&$V[\x91`\x07a\x13\xB3V[a&pV[V[a'#``a\x16\xA8V[\x90V[_\x90V[_\x90V[_\x90V[a':a'\x19V[\x90` \x80\x80\x84a'Ha'&V[\x81R\x01a'Sa'*V[\x81R\x01a'^a'.V[\x81RPPV[a'la'2V[\x90V[a'\x81\x90a'{a'dV[Pac\xCCV[\x90V[_\x90V[a'\xA9a'\xAF\x92a'\xA4_\x93a'\x9Ca'\x84V[P`\x03a\x0F\xB8V[a\x10\x02V[\x01a\t6V[\x90V[_\x7FNot service owner\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a'\xE6`\x11` \x92a\t\xCDV[a'\xEF\x81a'\xB2V[\x01\x90V[a(\x08\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra'\xD9V[\x90V[\x15a(\x12WV[a(\x1Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(0`\x04\x82\x01a'\xF3V[\x03\x90\xFD[P\x90V[_\x7FToo many definitions\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(l`\x14` \x92a\t\xCDV[a(u\x81a(8V[\x01\x90V[a(\x8E\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(_V[\x90V[\x15a(\x98WV[a(\xA0a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(\xB6`\x04\x82\x01a(yV[\x03\x90\xFD[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[a(\xDDa(\xE3\x91\x93\x92\x93a\x05RV[\x92a\x05RV[\x91a(\xEF\x83\x82\x02a\x05RV[\x92\x81\x84\x04\x14\x90\x15\x17\x15a(\xFEWV[a(\xBAV[a)\x0E\x90`\x04a(\xCEV[\x90V[\x90a)$\x90_\x19\x90` \x03`\x08\x02a\x0CjV[\x81T\x16\x90UV[\x1B\x90V[\x91\x90`\x08a)J\x91\x02\x91a)D_\x19\x84a)+V[\x92a)+V[\x91\x81\x19\x16\x91\x16\x17\x90V[a)ha)ca)m\x92a\x05RV[a\x07CV[a\x05RV[\x90V[\x90V[\x91\x90a)\x89a)\x84a)\x91\x93a)TV[a)pV[\x90\x83Ta)/V[\x90UV[a)\xA7\x91a)\xA1a'\x84V[\x91a)sV[V[[\x81\x81\x10a)\xB5WPPV[\x80a)\xC2_`\x01\x93a)\x95V[\x01a)\xAAV[\x90a)\xD8\x90_\x19\x90`\x08\x02a\x0CjV[\x19\x16\x90V[\x81a)\xE7\x91a)\xC8V[\x90`\x02\x02\x17\x90V[\x90_\x91a*\x06a)\xFE\x82a\x08\x11V[\x92\x83Ta)\xDDV[\x90UUV[`\x1F` \x91\x01\x04\x90V[\x91\x92\x90` \x82\x10_\x14a*nW`\x1F\x84\x11`\x01\x14a*>Wa*8\x92\x93Pa)\xDDV[\x90U[[V[P\x90a*da*i\x93`\x01a*[a*U\x85a\x08\x11V[\x92a*\x0BV[\x82\x01\x91\x01a)\xA9V[a)\xEFV[a*;V[Pa*\xA5\x82\x93a*\x7F`\x01\x94a\x08\x11V[a*\x9Ea*\x8B\x85a*\x0BV[\x82\x01\x92`\x1F\x86\x16\x80a*\xB0W[Pa*\x0BV[\x01\x90a)\xA9V[`\x02\x02\x17\x90Ua*<V[a*\xBC\x90\x88\x86\x03a)\x11V[_a*\x98V[\x92\x90\x91`\x01`@\x1B\x82\x11a+\x1DW` \x11_\x14a+\x0EW` \x81\x10_\x14a*\xF2Wa*\xEC\x91a)\xDDV[\x90U[[V[`\x01\x91`\xFF\x19\x16a+\x02\x84a\x08\x11V[U`\x02\x02\x01\x90Ua*\xEFV[`\x01\x91P`\x02\x02\x01\x90Ua*\xF0V[a\x08\xBDV[\x90\x81Ta+.\x81a\x07\xDEV[\x90\x81\x83\x11a+WW[\x81\x83\x10a+EW[PPPPV[a+N\x93a*\x15V[_\x80\x80\x80a+?V[a+c\x83\x83\x83\x87a*\xC2V[a+7V[_a+r\x91a+\"V[V[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[\x90_\x03a+\x99Wa+\x97\x90a+hV[V[a+tV[`\x03_\x91a+\xAE\x83\x80\x83\x01a+\x87V[a+\xBB\x83`\x01\x83\x01a)\x95V[a+\xC8\x83`\x02\x83\x01a)\x95V[\x01UV[\x90_\x03a+\xDEWa+\xDC\x90a+\x9EV[V[a+tV[[\x81\x81\x10a+\xEFWPPV[\x80a+\xFC_`\x04\x93a+\xCCV[\x01a+\xE4V[\x90\x91\x82\x81\x10a,\x11W[PPPV[a,/a,)a,#a,:\x95a)\x03V[\x92a)\x03V[\x92a\x07\x90V[\x91\x82\x01\x91\x01\x90a+\xE3V[_\x80\x80a,\x0CV[\x90`\x01`@\x1B\x81\x11a,fW\x81a,[a,d\x93a\x07\x8CV[\x90\x82\x81Ua,\x02V[V[a\x08\xBDV[_a,u\x91a,BV[V[\x90_\x03a,\x89Wa,\x87\x90a,kV[V[a+tV[a,\xA2a,\x9Da,\xA7\x92a%\xA0V[a\x07CV[a\x05RV[\x90V[`\x01a,\xB6\x91\x01a\x05RV[\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x905\x90`\x01`\x80\x03\x816\x03\x03\x82\x12\x15a,\xDCW\x01\x90V[a,\xB9V[\x90\x82\x10\x15a,\xFBW` a,\xF8\x92\x02\x81\x01\x90a,\xC5V[\x90V[a\x07xV[\x905\x90`\x01` \x03\x816\x03\x03\x82\x12\x15a-@W\x01\x805\x90`\x01\x80`@\x1B\x03\x82\x11a-;W` \x01\x91`\x01\x82\x026\x03\x83\x13a-6WV[a,\xC1V[a,\xBDV[a,\xB9V[\x91V[P\x90V[_\x7FName too long\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-\x80`\r` \x92a\t\xCDV[a-\x89\x81a-LV[\x01\x90V[a-\xA2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-sV[\x90V[\x15a-\xACWV[a-\xB4a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a-\xCA`\x04\x82\x01a-\x8DV[\x03\x90\xFD[5a-\xD8\x81a\x06\xF3V[\x90V[_\x7FInvalid bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a.\x0F`\x0E` \x92a\t\xCDV[a.\x18\x81a-\xDBV[\x01\x90V[a.1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra.\x02V[\x90V[\x15a.;WV[a.Ca\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.Y`\x04\x82\x01a.\x1CV[\x03\x90\xFD[\x90V[_R` _ \x90V[T\x90V[a.v\x81a.iV[\x82\x10\x15a.\x90Wa.\x88`\x04\x91a.`V[\x91\x02\x01\x90_\x90V[a\x07xV[P\x90V[\x91\x90`\x1F\x81\x11a.\xA9W[PPPV[a.\xB5a.\xDA\x93a\x08\x11V[\x90` a.\xC1\x84a*\x0BV[\x83\x01\x93\x10a.\xE2W[a.\xD3\x90a*\x0BV[\x01\x90a)\xA9V[_\x80\x80a.\xA4V[\x91Pa.\xD3\x81\x92\x90Pa.\xCAV[\x91a.\xFB\x90\x82a.\x95V[\x90`\x01\x80`@\x1B\x03\x82\x11a/\xB8Wa/\x1D\x82a/\x17\x85Ta\x07\xDEV[\x85a.\x99V[_\x90`\x1F\x83\x11`\x01\x14a/PW\x91\x80\x91a/?\x93_\x92a/DW[PPa)\xDDV[\x90U[V[\x90\x91P\x015_\x80a/8V[`\x1F\x19\x83\x16\x91a/_\x85a\x08\x11V[\x92_[\x81\x81\x10a/\xA0WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10a/\x86W[PPP\x02\x01\x90Ua/BV[a/\x96\x91\x015`\x1F\x84\x16\x90a)\xC8V[\x90U_\x80\x80a/zV[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a/bV[a\x08\xBDV[\x90a/\xC8\x92\x91a.\xF0V[V[\x90a/\xD6_\x19\x91a&MV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a/\xF5a/\xF0a/\xFC\x92a)TV[a)pV[\x82Ta/\xCAV[\x90UV[5a0\n\x81a\x1E\xE1V[\x90V[\x90a0\x19`\xFF\x91a&MV[\x91\x81\x19\x16\x91\x16\x17\x90V[a0,\x90a\x04\xC0V[\x90V[\x90V[\x90a0Ga0Ba0N\x92a0#V[a0/V[\x82Ta0\rV[\x90UV[\x90a0\xB0```\x03a0\xB6\x94a0v_\x82\x01a0p_\x88\x01\x88a-\0V[\x91a/\xBDV[a0\x8F`\x01\x82\x01a0\x89` \x88\x01a-\xCEV[\x90a/\xE0V[a0\xA8`\x02\x82\x01a0\xA2`@\x88\x01a-\xCEV[\x90a/\xE0V[\x01\x92\x01a0\0V[\x90a02V[V[\x91\x90a0\xC9Wa0\xC7\x91a0RV[V[a+tV[\x90\x81T\x91`\x01`@\x1B\x83\x10\x15a0\xF9W\x82a0\xF1\x91`\x01a0\xF7\x95\x01\x81Ua.mV[\x90a0\xB8V[V[a\x08\xBDV[\x92\x91\x90\x92a113a1+a1%a1 a1\x1B`\x07\x87\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14a(\x0BV[a1_a1?\x85\x84\x90a(4V[a1Xa1Ra1Ma\x15YV[a\x05RV[\x91a\x05RV[\x11\x15a(\x91V[a1t_a1o`\x08\x84\x90a\x07bV[a,wV[a1}_a,\x8EV[[\x80a1\x9Ba1\x95a1\x90\x88\x87\x90a(4V[a\x05RV[\x91a\x05RV[\x10\x15a2nWa2i\x90a1\xF2a1\xD2a1\xCCa1\xC6a1\xBD\x8A\x89\x87\x91a,\xE1V[_\x81\x01\x90a-\0V[\x90a-EV[\x90a-HV[a1\xEBa1\xE5a1\xE0a\x19\x03V[a\x05RV[\x91a\x05RV[\x11\x15a-\xA5V[a2;a2\x0C`@a2\x06\x89\x88\x86\x91a,\xE1V[\x01a-\xCEV[a24a2.a2)` a2#\x8C\x8B\x89\x91a,\xE1V[\x01a-\xCEV[a\x05RV[\x91a\x05RV[\x10\x15a.4V[a2da2Ra2M`\x08\x86\x90a\x07bV[a.]V[a2^\x88\x87\x85\x91a,\xE1V[\x90a0\xCEV[a,\xAAV[a1~V[PPP\x90PV[_\x7FZero address\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a2\xA9`\x0C` \x92a\t\xCDV[a2\xB2\x81a2uV[\x01\x90V[a2\xCB\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra2\x9CV[\x90V[\x15a2\xD5WV[a2\xDDa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a2\xF3`\x04\x82\x01a2\xB6V[\x03\x90\xFD[\x90a3\x01\x90a\x07FV[_R` R`@_ \x90V[\x90V[a3\x19\x90a\x0E\xF1V[\x90V[a3%\x90a\t\x1AV[\x90V[\x91\x90a3>a39a3F\x93a3\x10V[a3\x1CV[\x90\x83Ta)/V[\x90UV[_\x90V[a3`\x91a3Za3JV[\x91a3(V[V[_`\x02a3\x81\x92a3u\x83\x80\x83\x01a)\x95V[\x82`\x01\x82\x01U\x01a3NV[V[\x90_\x03a3\x95Wa3\x93\x90a3bV[V[a+tV[`H\x1B\x90V[\x90a3\xAF`\xFF`H\x1B\x91a3\x9AV[\x91\x81\x19\x16\x91\x16\x17\x90V[a3\xC2\x90a\x11GV[\x90V[\x90V[\x90a3\xDDa3\xD8a3\xE4\x92a3\xB9V[a3\xC5V[\x82Ta3\xA0V[\x90UV[a4$3a4\x1Ea4\x18\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEDV[\x91a\x03\xEDV[\x14a%VV[a4I\x82a4Ba4<a47_a%\xBFV[a\x03\xEDV[\x91a\x03\xEDV[\x14\x15a2\xCEV[a4oa4ja4ca4^`\x06\x85\x90a2\xF7V[a3\rV[\x84\x90ad\xAAV[a&$V[a4\x8E_a4\x89a4\x82`\x03\x85\x90a\x0F\xB8V[\x85\x90a\x10\x02V[a3\x83V[a4\xB1`\x02`\x01a4\xABa4\xA4`\x03\x86\x90a\x0F\xB8V[\x86\x90a\x10\x02V[\x01a3\xC8V[\x90a4\xE5a4\xDF\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK\x93a\x07FV[\x91a\x0F\xF6V[\x91a4\xEEa\x03\xA2V[\x80a4\xF8\x81a\x04IV[\x03\x90\xA3V[a5\x0E\x90a5\tad\xE4V[a5\x10V[V[a5\x1B\x90`\x0Ba&pV[V[a5&\x90a4\xFDV[V[_\x7FNot registered operator\0\0\0\0\0\0\0\0\0\x91\x01RV[a5\\`\x17` \x92a\t\xCDV[a5e\x81a5(V[\x01\x90V[a5~\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra5OV[\x90V[\x15a5\x88WV[a5\x90a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a5\xA6`\x04\x82\x01a5iV[\x03\x90\xFD[\x90a5\xDF\x97\x96\x95\x94\x93\x92\x91a5\xDAa5\xD5a5\xCEa5\xC9\x84`\x06a2\xF7V[a3\rV[3\x90ae2V[a5\x81V[a8\x1EV[V[a5\xF5a5\xF0a5\xFA\x92a\x03\xB4V[a\x07CV[a\x05RV[\x90V[a6\x11a6\x0Ca6\x16\x92a\x05RV[a\x07CV[a\x03\xB4V[\x90V[\x91` a6:\x92\x94\x93a63`@\x82\x01\x96_\x83\x01\x90a\x0C\x13V[\x01\x90a\x0C\x13V[V[a6Ka6Q\x91\x93\x92\x93a\x05RV[\x92a\x05RV[\x82\x03\x91\x82\x11a6\\WV[a(\xBAV[`\x01\x80`@\x1B\x03\x81\x11a6}Wa6y` \x91a\x08\xB3V[\x01\x90V[a\x08\xBDV[\x90\x92\x91\x92a6\x97a6\x92\x82a6aV[a\x16\xA8V[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a6\xB3Wa6\xB1\x92a\x17\x05V[V[a\x16\xE0V[a6\xC3\x916\x91a6\x82V[\x90V[` \x01\x90V[Q\x90V[\x94\x92\x90\x97\x96\x95\x93\x91`\xE0\x86\x01\x98_\x87\x01a6\xE9\x91a\x0E\xF4V[` \x86\x01a6\xF6\x91a\x0C\xAEV[`@\x85\x01a7\x03\x91a\x0C\x13V[``\x84\x01a7\x10\x91a\x0C\x13V[`\x80\x83\x01a7\x1D\x91a\x11\x17V[`\xA0\x82\x01a7*\x91a\x0E\xF4V[`\xC0\x01a76\x91a\x0C\x13V[V[_a\x19\x01`\xF0\x1B\x91\x01RV[a7P`\x02\x80\x92a\x1D\x0FV[a7Y\x81a78V[\x01\x90V[\x90V[a7la7q\x91a\x0E\xF1V[a7]V[\x90RV[` \x80\x93\x92a7\x90a7\x89a7\x98\x94a7DV[\x80\x92a7`V[\x01\x80\x92a7`V[\x01\x90V[_\x7FInvalid signature\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a7\xD0`\x11` \x92a\t\xCDV[a7\xD9\x81a7\x9CV[\x01\x90V[a7\xF2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra7\xC3V[\x90V[\x15a7\xFCWV[a8\x04a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a8\x1A`\x04\x82\x01a7\xDDV[\x03\x90\xFD[\x91\x92\x93\x94\x97\x96\x90\x95\x97\x80a8:a84Ba\x05RV[\x91a5\xE1V[\x11a9\xA2Wa8RBa8L\x83a5\xE1V[\x90a6<V[a8ka8ea8`a\r\x05V[a5\xE1V[\x91a\x05RV[\x11a9zWa9x\x97\x98a9Oa9m\x93\x85a8\xD9\x8Aa8\xCA\x8Da9U\x98\x8D\x8Da8\xA1a8\x96a$aV[\x963\x99\x95\x92\x93a6\xB8V[a8\xB3a8\xAD\x82a6\xCCV[\x91a6\xC6V[ \x92\x93a8\xBEa\x03\xA2V[\x98\x89\x97` \x89\x01a6\xD0V[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD1V[a8\xEBa8\xE5\x82a6\xCCV[\x91a6\xC6V[ a96\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a9'a9\x1Ba\x03\xA2V[\x93\x84\x92` \x84\x01a7uV[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD1V[a9Ha9B\x82a6\xCCV[\x91a6\xC6V[ \x92a6\xB8V[\x90aelV[a9ga9a3a\x03\xEDV[\x91a\x03\xEDV[\x14a7\xF5V[\x933\x91\x92\x93\x94af\xE9V[V[a9\x83Ba5\xFDV[\x90a9\x9E_\x92\x83\x92c\x185[u`\xE2\x1B\x84R`\x04\x84\x01a6\x19V[\x03\x90\xFD[a9\xABBa5\xFDV[\x90a9\xC6_\x92\x83\x92cW\xEA\x02\xE9`\xE0\x1B\x84R`\x04\x84\x01a6\x19V[\x03\x90\xFD[\x90a9\xDA\x97\x96\x95\x94\x93\x92\x91a5\xAAV[V[``\x90V[\x90` \x82\x82\x03\x12a:\x0FW_\x82\x015`\x01\x80`@\x1B\x03\x81\x11a:\nWa:\x07\x92\x01a\x18-V[\x90V[a\x03\xB0V[a\x03\xACV[\x90a:+\x91a:!a9\xDCV[P\x90\x81\x01\x90a9\xE1V[\x90V[a:Ma:Ha:R\x92a:@a'\x84V[P`\x05a2\xF7V[a3\rV[aj\xFBV[\x90V[``\x90V[`\x01\x80`@\x1B\x03\x81\x11a:pW` \x80\x91\x02\x01\x90V[a\x08\xBDV[\x90a:\x87a:\x82\x83a:ZV[a\x16\xA8V[\x91\x82RV[6\x907V[\x90a:\xB6a:\x9E\x83a:uV[\x92` \x80a:\xAC\x86\x93a:ZV[\x92\x01\x91\x03\x90a:\x8CV[V[\x90a:\xC2\x82a\x12(V[\x81\x10\x15a:\xD3W` \x80\x91\x02\x01\x01\x90V[a\x07xV[\x90a:\xE2\x90a\x03\xEDV[\x90RV[\x90a:\xEFa:UV[Pa;\x0Ca;\x07a;\x02`\x04\x85\x90a2\xF7V[a3\rV[aj\xFBV[\x91a;\x16\x83a:\x91V[\x91a; _a,\x8EV[[\x80a;4a;.\x87a\x05RV[\x91a\x05RV[\x10\x15a;{Wa;v\x90a;qa;_a;Xa;S`\x04\x88\x90a2\xF7V[a3\rV[\x83\x90akJV[a;l\x87\x91\x84\x90\x92a:\xB8V[a:\xD8V[a,\xAAV[a;!V[P\x92PP\x90V[_\x90V[\x90a;\x8Fa;\x82V[Pa;\xB1`\x01a;\xABa;\xA4`\x03\x86\x90a\x0F\xB8V[\x84\x90a\x10\x02V[\x01a\x10\x91V[a;\xC3a;\xBD_a\x11GV[\x91a\x11GV[\x14\x91\x82\x15a;\xD1W[PP\x90V[a;\xF2\x92P`\x01\x91a;\xE7a;\xEC\x92`\x03a\x0F\xB8V[a\x10\x02V[\x01a\x10\x91V[a<\x05a;\xFF`\x01a\x11GV[\x91a\x11GV[\x14_\x80a;\xCCV[a<3\x90a<\x19a:UV[P_\x90a<-a<'a\x13\x1BV[\x92a,\x8EV[\x90aIyV[P\x90V[\x90a<i\x94\x93\x92\x91a<da<_a<Xa<S\x84`\x06a2\xF7V[a3\rV[3\x90ae2V[a5\x81V[a<kV[V[\x91a<}\x94\x92\x93\x913\x91\x92\x93\x94af\xE9V[V[\x90a<\x8C\x94\x93\x92\x91a<7V[V[\x90a<\xAEa<\xA9a<\xB3\x93a<\xA1a;\x82V[P`\x06a2\xF7V[a3\rV[ae2V[\x90V[_\x90V[a<\xDCa<\xE2\x92a<\xD7`\x01\x93a<\xCFa<\xB6V[P`\x03a\x0F\xB8V[a\x10\x02V[\x01a\x10\x91V[\x90V[a<\xEE\x90a\x0F\xEAV[\x90V[_\x7FInternal only\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a=%`\r` \x92a\t\xCDV[a=.\x81a<\xF1V[\x01\x90V[a=G\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra=\x18V[\x90V[\x15a=QWV[a=Ya\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a=o`\x04\x82\x01a=2V[\x03\x90\xFD[`\x01\x80`@\x1B\x03\x81\x11a=\x89W` \x80\x91\x02\x01\x90V[a\x08\xBDV[\x90a=\xA0a=\x9B\x83a=sV[a\x16\xA8V[\x91\x82RV[6\x907V[\x90a=\xCFa=\xB7\x83a=\x8EV[\x92` \x80a=\xC5\x86\x93a=sV[\x92\x01\x91\x03\x90a=\xA5V[V[\x90a=\xDB\x82a\r\x87V[\x81\x10\x15a=\xECW` \x80\x91\x02\x01\x01\x90V[a\x07xV[\x90V[Q\x90V[\x90a>\x02\x82a=\xF4V[\x81\x10\x15a>\x13W` \x80\x91\x02\x01\x01\x90V[a\x07xV[\x90a>\"\x90a\x0E\xF1V[\x90RV[``\x90V[\x90V[` \x91\x81R\x01\x90V[\x90_\x92\x91\x80T\x90a>Qa>J\x83a\x07\xDEV[\x80\x94a>.V[\x91`\x01\x81\x16\x90\x81_\x14a>\xA8WP`\x01\x14a>lW[PPPV[a>y\x91\x92\x93\x94Pa\x07\x99V[\x91_\x92[\x81\x84\x10a>\x90WPP\x01\x90_\x80\x80a>gV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a>}V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a>gV[\x90a>\xCD\x91a>7V[\x90V[\x90a>\xF0a>\xE9\x92a>\xE0a\x03\xA2V[\x93\x84\x80\x92a>\xC3V[\x03\x83a\x08\xD1V[V[a>\xFB\x90a>\xD0V[\x90V[a?\x08\x90Qa\x0E\xF1V[\x90V[a?\x15\x90Qa\x05RV[\x90V[_\x7FValue out of bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a?L`\x13` \x92a\t\xCDV[a?U\x81a?\x18V[\x01\x90V[a?qa?\x7F\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra\t\xE1V[\x90` \x81\x83\x03\x91\x01Ra??V[\x90V[\x92\x91` a?\x9Ea?\xA6\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\t\xE1V[\x94\x01\x90a\x05UV[V[\x90_\x92\x91\x80T\x90a?\xC2a?\xBB\x83a\x07\xDEV[\x80\x94a\t\xCDV[\x91`\x01\x81\x16\x90\x81_\x14a@\x19WP`\x01\x14a?\xDDW[PPPV[a?\xEA\x91\x92\x93\x94Pa\x08\x11V[\x91_\x92[\x81\x84\x10a@\x01WPP\x01\x90_\x80\x80a?\xD8V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a?\xEEV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a?\xD8V[_\x7FRequired metric missing\0\0\0\0\0\0\0\0\0\x91\x01RV[a@h`\x17` \x92a\t\xCDV[a@q\x81a@4V[\x01\x90V[a@\x8Da@\x9B\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra?\xA8V[\x90` \x81\x83\x03\x91\x01Ra@[V[\x90V[\x92\x93\x90\x93a@\xC63a@\xC0a@\xBAa@\xB50a<\xE5V[a\x03\xEDV[\x91a\x03\xEDV[\x14a=JV[a@\xDAa@\xD5`\x08\x86\x90a\x07bV[a.]V[\x94a@\xE4\x82a=\xAAV[\x94a@\xEE_a,\x8EV[[\x80aA\x02a@\xFC\x86a\x05RV[\x91a\x05RV[\x10\x15aAUWaAP\x90aAKaA&_aA\x1E\x8A\x85\x90a=\xD1V[Q\x01Qa=\xF1V[aA8aA2\x82a6\xCCV[\x91a6\xC6V[ aAF\x8A\x91\x84\x90\x92a=\xF8V[a>\x18V[a,\xAAV[a@\xEFV[P\x91\x94\x90\x92\x95aAd\x81a.iV[aAvaAp_a,\x8EV[\x91a\x05RV[\x11\x96aA\x80a>&V[\x90\x88aF\0W[aA\x90_a,\x8EV[[\x80aA\xA4aA\x9E\x8Ba\x05RV[\x91a\x05RV[\x10\x15aDcW`\x01_\x8BaB\x97W[P\x90\x88\x87\x89aA\xC9\x94aA\xCEW[PPPa,\xAAV[aA\x91V[\x82_aB\x0CaB\x04aB\x15\x94aA\xFFaA\xF7` aA\xF0aB\x1A\x9B\x8D\x90a=\xD1V[Q\x01a?\x0BV[\x97`\ta\x1C\xE3V[a\x1C\xF9V[\x92\x87\x90a=\xD1V[Q\x01Q\x90a\x1D\x8AV[a/\xE0V[\x88\x87\x89\x90aBD` aB=_aB2\x87\x89\x90a=\xD1V[Q\x01Q\x95\x87\x90a=\xD1V[Q\x01a?\x0BV[aBwaBq\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD\x93a\x07FV[\x93a\x0F\xF6V[\x93aB\x8CaB\x83a\x03\xA2V[\x92\x83\x92\x83a?\x82V[\x03\x90\xA3\x88\x87\x89aA\xC1V[\x9A\x90\x95\x92\x91\x99aB\xA6_a,\x8EV[[\x80aB\xC2aB\xBCaB\xB7\x8Aa.iV[a\x05RV[\x91a\x05RV[\x10\x15aDMWaB\xDAaB\xD5\x8D\x87a=\xF8V[a>\xFEV[aB\xFEaB\xF8aB\xF3aB\xEE\x8A\x86\x90a=\xF8V[a>\xFEV[a\x0E\xF1V[\x91a\x0E\xF1V[\x14aC\x11WaC\x0C\x90a,\xAAV[aB\xA7V[\x8A\x91\x9B\x92\x9CP\x89aA\xC9\x94\x95\x98\x8A\x92`\x01\x90\x8AaC;` aC4\x89\x8B\x90a=\xD1V[Q\x01a?\x0BV[aCcaC]aCX`\x01aCQ\x86\x88\x90a.mV[P\x01a\t6V[a\x05RV[\x91a\x05RV[\x10\x91\x88\x88\x84\x15aD\x03W[PPPPaC\x98W[aC\x82\x90[\x15a\x04\xC0V[aC\x91W[\x93\x94PPPaA\xB3V[P_aC\x87V[\x90P\x82\x82_aC\xA8\x87\x89\x90a=\xD1V[Q\x01Q\x91aC\xF4aC\xE2aC\xDC\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07FV[\x93a\x0F\xF6V[\x93aC\xEBa\x03\xA2V[\x91\x82\x91\x82a?YV[\x03\x90\xA3aC\x82_\x91\x90PaCwV[aDC\x93\x94PaD1aD=\x93aD+` aD$aD8\x96`\x02\x96a=\xD1V[Q\x01a?\x0BV[\x96a.mV[P\x01a\t6V[a\x05RV[\x91a\x05RV[\x11\x8A_\x88\x88aCnV[P\x99\x90\x9A\x87\x89aA\xC9\x94\x95\x98aC\x82\x8D\x94aC|V[P\x97PP\x92\x93P\x93PaDu_a,\x8EV[\x93[\x84aD\x92aD\x8CaD\x87\x86a.iV[a\x05RV[\x91a\x05RV[\x10\x15aE\xF9WaD\xB8aD\xB2`\x03aD\xAB\x86\x89\x90a.mV[P\x01a\t]V[\x15a\x04\xC0V[aE\xEEWaD\xDAaD\xD5_aD\xCE\x86\x89\x90a.mV[P\x01a>+V[a>\xF2V[aD\xECaD\xE6\x82a6\xCCV[\x91a6\xC6V[ \x90_\x96aD\xF9_a,\x8EV[[\x80aE\x15aE\x0FaE\n\x86a=\xF4V[a\x05RV[\x91a\x05RV[\x10\x15aE\xDCWaE.aE)\x84\x83\x90a=\xF8V[a>\xFEV[aE@aE:\x86a\x0E\xF1V[\x91a\x0E\xF1V[\x14aESWaEN\x90a,\xAAV[aD\xFAV[P\x95\x90\x96PaEt\x91PaEi`\x01[\x15a\x04\xC0V[aE{W[[a,\xAAV[\x93\x94aDwV[\x82\x85_aE\x89\x87\x85\x90a.mV[P\x01\x91aE\xD4aE\xC2aE\xBC\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07FV[\x93a\x0F\xF6V[\x93aE\xCBa\x03\xA2V[\x91\x82\x91\x82a@uV[\x03\x90\xA3aEnV[P\x95\x90\x96aEt\x92PaEi\x90aEcV[\x94\x93aEt\x90aEoV[PPPPPV[\x96\x93\x90PaF\x1AaF\x15\x83\x97\x94\x99\x96\x93a.iV[a=\xAAV[\x97aF$_a,\x8EV[[\x80aF@aF:aF5\x8Ba.iV[a\x05RV[\x91a\x05RV[\x10\x15aF\x9AWaF\x95\x90aF\x90aFkaFf_aF_\x8D\x86\x90a.mV[P\x01a>+V[a>\xF2V[aF}aFw\x82a6\xCCV[\x91a6\xC6V[ aF\x8B\x8D\x91\x84\x90\x92a=\xF8V[a>\x18V[a,\xAAV[aF%V[P\x92\x95\x91\x94\x97\x90\x93\x96aA\x87V[aF\xB0ad\xE4V[aF\xB8aF\xBAV[V[aF\xCBaF\xC6_a%\xBFV[ak\xE2V[V[aF\xD5aF\xA8V[V[aF\xE1`\xA0a\x16\xA8V[\x90V[_\x90V[_\x90V[_\x90V[aF\xF8aF\xD7V[\x90` \x80\x80\x80\x80\x86aG\x08aF\xE4V[\x81R\x01aG\x13a'&V[\x81R\x01aG\x1Ea'*V[\x81R\x01aG)aF\xE8V[\x81R\x01aG4aF\xECV[\x81RPPV[aGBaF\xF0V[\x90V[\x90aGO\x90a\x05RV[\x90RV[\x90aG]\x90a\x03\xB4V[\x90RV[\x90aGk\x90a\x04\xADV[\x90RV[\x90aGy\x90a\x11GV[\x90RV[\x90aG\xFCaG\xF3`\x02aG\x8EaF\xD7V[\x94aG\xA5aG\x9D_\x83\x01a\t6V[_\x88\x01aGEV[aG\xBDaG\xB4`\x01\x83\x01a\x107V[` \x88\x01aGSV[aG\xD5aG\xCC`\x01\x83\x01a\x10dV[`@\x88\x01aGaV[aG\xEDaG\xE4`\x01\x83\x01a\x10\x91V[``\x88\x01aGoV[\x01a\x10\xB5V[`\x80\x84\x01a>\x18V[V[aH\x07\x90aG}V[\x90V[aH/\x91aH%aH*\x92aH\x1DaG:V[P`\x03a\x0F\xB8V[a\x10\x02V[aG\xFEV[\x90V[_\x90V[\x90aH@\x90a\x07FV[_R` R`@_ \x90V[\x90aHV\x90a\x0F\xF6V[_R` R`@_ \x90V[aH\x87\x91aH}aH\x82\x92aHuaH2V[P`\x0CaH6V[aHLV[a\x107V[\x90V[aH\x92ak\xF8V[aH\x9Aa^RV[aH\xACaH\xA6\x83a\x03\xEDV[\x91a\x03\xEDV[\x03aH\xBCWaH\xBA\x90ak\xE2V[V[aH\xD7\x90_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xBBV[\x03\x90\xFD[aH\xFAaH\xF5aH\xFF\x92aH\xEDa'\x84V[P`\x04a2\xF7V[a3\rV[aj\xFBV[\x90V[aI\x0C\x90Qa\x04\xADV[\x90V[aI#aI\x1EaI(\x92a%\xA0V[a\x07CV[a\x04\xADV[\x90V[aI5\x90Qa\x03\xB4V[\x90V[aILaIGaIQ\x92a\x04\xADV[a\x07CV[a\x05RV[\x90V[aIcaIi\x91\x93\x92\x93a\x05RV[\x92a\x05RV[\x82\x01\x80\x92\x11aItWV[a(\xBAV[\x90\x92\x91\x92aI\x85a:UV[PaI\x8Ea'\x84V[PaI\x98\x82ac\xCCV[\x93aI\xB5aI\xB0aI\xAB`\x05\x86\x90a2\xF7V[a3\rV[aj\xFBV[\x92aI\xC2` \x87\x01aI\x02V[aI\xD4aI\xCE_aI\x0FV[\x91a\x04\xADV[\x14\x80\x15aJ\xC6W[\x80\x15aJ\xABW[aJ\x91WaJ\x1D\x86aJ\x17aJ\x12` aJ\x0BaJ\x06_aJz\x9B\x9C\x9D\x01aI+V[a5\xE1V[\x93\x01aI\x02V[aI8V[\x90a(\xCEV[\x91\x80aJ8aJ2aJ-a\x13\x1BV[a\x05RV[\x91a\x05RV[\x11_\x14aJ\x8CWPaJHa\x13\x1BV[[aJT\x84\x82\x90aITV[aJfaJ`\x88a\x05RV[\x91a\x05RV[\x11_\x14aJ}WP\x84[\x90\x92\x90\x91\x92al.V[\x91V[aJ\x87\x90\x84aITV[aJpV[aJIV[PPP\x91PaJ\xA7aJ\xA2_a,\x8EV[a:\x91V[\x91\x90V[P\x82aJ\xBFaJ\xB9\x86a\x05RV[\x91a\x05RV[\x10\x15aI\xE3V[P\x83aJ\xDAaJ\xD4_a,\x8EV[\x91a\x05RV[\x14aI\xDCV[aJ\xF1\x90aJ\xECad\xE4V[aJ\xF3V[V[aJ\xFE\x90`\na&pV[V[aK\t\x90aJ\xE0V[V[_\x90V[aK\x17aK\x0BV[PaK!_a%\x93V[\x90V[P\x90V[\x91\x90\x81\x10\x15aK8W` \x02\x01\x90V[a\x07xV[5aKG\x81a\x03\xF9V[\x90V[_\x80\xFD[`\xE0\x1B\x90V[_\x91\x03\x12aK^WV[a\x03\xACV[\x91` aK\x84\x92\x94\x93aK}`@\x82\x01\x96_\x83\x01\x90a\x0C\x13V[\x01\x90a\x0C\xAEV[V[aK\x8Ea\x03\xA2V[=_\x82>=\x90\xFD[\x90\x92\x91\x92aK\xA3_a,\x8EV[[\x80aK\xC1aK\xBBaK\xB6\x85\x89\x90aK$V[a\x05RV[\x91a\x05RV[\x10\x15aLpWaK\xD00a<\xE5V[\x90c\xBA\x1F\xB1\x03\x84aK\xEBaK\xE6\x86\x8A\x86\x91aK(V[aK=V[\x93\x80;\x15aLkWaL\x10_\x80\x94aL\x1BaL\x04a\x03\xA2V[\x98\x89\x96\x87\x95\x86\x94aKNV[\x84R`\x04\x84\x01aKcV[\x03\x92Z\xF1\x91\x82\x15aLfWaL5\x92aL:W[Pa,\xAAV[aK\xA4V[aLY\x90_=\x81\x11aL_W[aLQ\x81\x83a\x08\xD1V[\x81\x01\x90aKTV[_aL/V[P=aLGV[aK\x86V[aKJV[PPP\x90PV[_\x7FNot slashing oracle\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aL\xAB`\x13` \x92a\t\xCDV[aL\xB4\x81aLwV[\x01\x90V[aL\xCD\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaL\x9EV[\x90V[\x15aL\xD7WV[aL\xDFa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aL\xF5`\x04\x82\x01aL\xB8V[\x03\x90\xFD[_\x7FOperator unknown\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aM-`\x10` \x92a\t\xCDV[aM6\x81aL\xF9V[\x01\x90V[aMO\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaM V[\x90V[\x15aMYWV[aMaa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aMw`\x04\x82\x01aM:V[\x03\x90\xFD[\x90V[\x90aM\x8F`\x01\x80`@\x1B\x03\x91a&MV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90aM\xB1aM\xACaM\xB8\x92a\x07FV[aM\x99V[\x82TaM~V[\x90UV[\x91\x90aM\xD6\x81aM\xCF\x81aM\xDB\x95a\t\xCDV[\x80\x95a\x17\x05V[a\x08\xB3V[\x01\x90V[\x90\x91aM\xF6\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaM\xBCV[\x90V[aN\x1E3aN\x18aN\x12aN\r`\na%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14aL\xD0V[aNDaN?aN8aN3`\x05\x85\x90a2\xF7V[a3\rV[\x84\x90ae2V[aMRV[aNpaNeaN`aNY`\x03\x85\x90a\x0F\xB8V[\x85\x90a\x10\x02V[aM{V[`\x01`\x03\x91\x01a3\xC8V[aN\x8EaN\x87aN\x82`\x04\x84\x90a2\xF7V[a3\rV[\x83\x90amJV[PaN\xB6aN\x9BBa5\xFDV[aN\xB1aN\xAA`\x0C\x85\x90aH6V[\x85\x90aHLV[aM\x9CV[\x90\x91\x92aN\xECaN\xE6\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07FV[\x93a\x0F\xF6V[\x93aO\x01aN\xF8a\x03\xA2V[\x92\x83\x92\x83aM\xDFV[\x03\x90\xA3V[aO\x10`\x80a\x16\xA8V[\x90V[aO\x1E\x916\x91a\x17\x10V[\x90V[RV[\x90aO.\x90a\x04\xC0V[\x90RV[Q\x90V[\x90aO@\x81a\t\xC9V[\x90`\x01\x80`@\x1B\x03\x82\x11aO\xFEWaOb\x82aO\\\x85Ta\x07\xDEV[\x85a.\x99V[` \x90`\x1F\x83\x11`\x01\x14aO\x96W\x91\x80\x91aO\x85\x93_\x92aO\x8AW[PPa)\xDDV[\x90U[V[\x90\x91P\x01Q_\x80aO~V[`\x1F\x19\x83\x16\x91aO\xA5\x85a\x08\x11V[\x92_[\x81\x81\x10aO\xE6WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10aO\xCCW[PPP\x02\x01\x90UaO\x88V[aO\xDC\x91\x01Q`\x1F\x84\x16\x90a)\xC8V[\x90U_\x80\x80aO\xC0V[\x91\x93` `\x01\x81\x92\x87\x87\x01Q\x81U\x01\x95\x01\x92\x01aO\xA8V[a\x08\xBDV[\x90aP\r\x91aO6V[V[aP\x19\x90Qa\x04\xC0V[\x90V[\x90aPy```\x03aP\x7F\x94aP?_\x82\x01aP9_\x88\x01aO2V[\x90aP\x03V[aPX`\x01\x82\x01aPR` \x88\x01a?\x0BV[\x90a/\xE0V[aPq`\x02\x82\x01aPk`@\x88\x01a?\x0BV[\x90a/\xE0V[\x01\x92\x01aP\x0FV[\x90a02V[V[\x91\x90aP\x92WaP\x90\x91aP\x1CV[V[a+tV[\x90\x81T\x91`\x01`@\x1B\x83\x10\x15aP\xC2W\x82aP\xBA\x91`\x01aP\xC0\x95\x01\x81Ua.mV[\x90aP\x81V[V[a\x08\xBDV[aQ\xE5\x95aQ\xCE\x84\x96aQ\xC5aQ\xBDaQ\xA9aQ\xA4aQ\xD7\x97aQJaQ*aQ$aQ\xE0\x9D\x8D\x9F\x9DaQ\x1F3aQ\x19aQ\x13aQ\x0EaQ\t`\x07\x8C\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14a(\x0BV[a-EV[\x90a-HV[aQCaQ=aQ8a\x19\x03V[a\x05RV[\x91a\x05RV[\x11\x15a-\xA5V[aQg\x86aQ`aQZ\x8Da\x05RV[\x91a\x05RV[\x10\x15a.4V[aQ\x9DaQ~aQy`\x08\x84\x90a\x07bV[a\x07\x8CV[aQ\x97aQ\x91aQ\x8Ca\x15YV[a\x05RV[\x91a\x05RV[\x10a(\x91V[`\x08a\x07bV[a.]V[\x98\x99\x96\x92\x94\x96aQ\xB7aO\x06V[\x9AaO\x13V[_\x8A\x01aO!V[` \x88\x01aGEV[`@\x86\x01aGEV[``\x84\x01aO$V[aP\x97V[V[aR\x15\x90aR\x10aR\x0BaR\x04aQ\xFF\x84`\x06a2\xF7V[a3\rV[3\x90ae2V[a5\x81V[aR\xF1V[V[_\x7FCannot go online while slashed\0\0\x91\x01RV[aRK`\x1E` \x92a\t\xCDV[aRT\x81aR\x17V[\x01\x90V[aRm\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaR>V[\x90V[`@\x1B\x90V[\x90aR\x85`\xFF`@\x1B\x91aRpV[\x91\x81\x19\x16\x91\x16\x17\x90V[aR\xA3aR\x9EaR\xA8\x92a\x04\xADV[a\x07CV[a\x04\xADV[\x90V[\x90V[\x90aR\xC3aR\xBEaR\xCA\x92aR\x8FV[aR\xABV[\x82TaRvV[\x90UV[\x91` aR\xEF\x92\x94\x93aR\xE8`@\x82\x01\x96_\x83\x01\x90a\x11_V[\x01\x90a\x11_V[V[aS\x0FaS\naS\x03`\x03\x84\x90a\x0F\xB8V[3\x90a\x10\x02V[aM{V[\x90aS\x1C`\x01\x83\x01a\x10\x91V[\x91\x82aS1aS+`\x03a\x11GV[\x91a\x11GV[\x14aTUW\x82aSIaSC_a\x11GV[\x91a\x11GV[\x14\x80\x15aT:W[aT5WaSx\x90aSf`\x01\x80\x83\x01a3\xC8V[`\x01aSq_aI\x0FV[\x91\x01aR\xAEV[aS\x96aS\x8FaS\x8A`\x04\x84\x90a2\xF7V[a3\rV[3\x90ad\xAAV[P\x803aS\xCCaS\xC6\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07FV[\x91a\x0F\xF6V[\x91aS\xD5a\x03\xA2V[\x80aS\xDF\x81a\x04IV[\x03\x90\xA3\x903\x90\x91`\x01aT\x1BaT\x15\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07FV[\x93a\x0F\xF6V[\x93aT0aT'a\x03\xA2V[\x92\x83\x92\x83aR\xCEV[\x03\x90\xA3V[PPPV[P\x82aTOaTI`\x01a\x11GV[\x91a\x11GV[\x14aSQV[aT]a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aTs`\x04\x82\x01aRXV[\x03\x90\xFD[aT\x80\x90aQ\xE7V[V[_\x7FNot authorized\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aT\xB6`\x0E` \x92a\t\xCDV[aT\xBF\x81aT\x82V[\x01\x90V[aT\xD8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaT\xA9V[\x90V[\x15aT\xE2WV[aT\xEAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aU\0`\x04\x82\x01aT\xC3V[\x03\x90\xFD[\x90V[aU\x1BaU\x16aU \x92aU\x04V[a\x07CV[a\x03\xB4V[\x90V[_\x7FInterval too short\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aUW`\x12` \x92a\t\xCDV[aU`\x81aU#V[\x01\x90V[aUy\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaUJV[\x90V[\x15aU\x83WV[aU\x8Ba\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aU\xA1`\x04\x82\x01aUdV[\x03\x90\xFD[\x90V[aU\xBCaU\xB7aU\xC1\x92aU\xA5V[a\x07CV[a\x04\xADV[\x90V[_\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\xF8`\x17` \x92a\t\xCDV[aV\x01\x81aU\xC4V[\x01\x90V[aV\x1A\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaU\xEBV[\x90V[\x15aV$WV[aV,a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aVB`\x04\x82\x01aV\x05V[\x03\x90\xFD[aVP``a\x16\xA8V[\x90V[\x90aVhaVcaVo\x92a0#V[a0/V[\x82Ta3\xA0V[\x90UV[\x90aV\xB5`@_aV\xBB\x94aV\x95\x82\x82\x01aV\x8F\x84\x88\x01aI+V[\x90aM\x9CV[aV\xAD\x82\x82\x01aV\xA7` \x88\x01aI\x02V[\x90aR\xAEV[\x01\x92\x01aP\x0FV[\x90aVSV[V[\x90aV\xC7\x91aVsV[V[\x91` aV\xEA\x92\x94\x93aV\xE3`@\x82\x01\x96_\x83\x01\x90a\x0C\x13V[\x01\x90a\x11\x17V[V[3aW\x1FaW\x19\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEDV[\x91a\x03\xEDV[\x14\x80\x15aX\x0BW[aW0\x90aT\xDBV[aWN\x82aWGaWA`<aU\x07V[\x91a\x03\xB4V[\x10\x15aU|V[aWl\x83aWeaW_`\x01aU\xA8V[\x91a\x04\xADV[\x10\x15aV\x1DV[aW\xC5\x82aW\xB4\x85aW\xABaW\x8D_aW\x87`\x02\x89\x90a\"]V[\x01a\"\x87V[\x91aW\xA2aW\x99aVFV[\x95_\x87\x01aGSV[` \x85\x01aGaV[`@\x83\x01aO$V[aW\xC0`\x02\x84\x90a\"]V[aV\xBDV[\x90\x91aW\xF1\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x92a\x07FV[\x92aX\x06aW\xFDa\x03\xA2V[\x92\x83\x92\x83aV\xC9V[\x03\x90\xA2V[PaW03aX5aX/aX*aX%`\x07\x87\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14\x90PaW'V[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[aX]aXc\x91a\x05RV[\x91a\x05RV[\x90\x81\x15aXnW\x04\x90V[aX=V[aX\x87aX\x82aX\x8C\x92a\x05RV[a\x07CV[a\x04\xADV[\x90V[aX\xA3aX\x9EaX\xA8\x92a%\xA0V[a\x07CV[a\x03\xB4V[\x90V[aX\xC9aX\xC4aX\xBD`\x03\x84\x90a\x0F\xB8V[\x84\x90a\x10\x02V[aM{V[\x90aX\xD3\x81ac\xCCV[aX\xDF`\x01\x84\x01a\x10\x91V[aX\xF2aX\xEC`\x03a\x11GV[\x91a\x11GV[\x14a[\x06WaY\x02_\x84\x01a\t6V[aY\x14aY\x0E_a,\x8EV[\x91a\x05RV[\x14a[\0WaYJaY1BaY+_\x87\x01a\t6V[\x90a6<V[aYDaY?_\x85\x01aI+V[a5\xE1V[\x90aXQV[\x80aY^aYX`\xFFaI8V[\x91a\x05RV[\x11_\x14aZ\xF2WP`\xFF[\x90\x81aY\x88aY\x82aY}`\x01\x88\x01a\x10dV[a\x04\xADV[\x91a\x04\xADV[\x11aY\x95W[PPPPPV[aY\xA2\x82`\x01\x86\x01aR\xAEV[aY\xB7aY\xAE_aX\x8FV[`\x01\x86\x01aM\x9CV[aY\xD5aY\xCFaY\xCA` \x85\x94\x01aI\x02V[a\x04\xADV[\x91a\x04\xADV[\x10\x15\x80aZ\xCBW[aY\xE8W[\x80aY\x8EV[aZ\x03aY\xF7`\x01\x85\x01a\x10\x91V[\x93`\x01`\x02\x91\x01a3\xC8V[aZ!aZ\x1AaZ\x15`\x04\x85\x90a2\xF7V[a3\rV[\x85\x90amJV[P\x81\x90\x84\x90\x91aZoaZ]aZW\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM\x93a\x07FV[\x93a\x0F\xF6V[\x93aZfa\x03\xA2V[\x91\x82\x91\x82a\x16\x13V[\x03\x90\xA3\x91\x90\x91`\x02aZ\xAAaZ\xA4\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07FV[\x93a\x0F\xF6V[\x93aZ\xBFaZ\xB6a\x03\xA2V[\x92\x83\x92\x83aR\xCEV[\x03\x90\xA3_\x80\x80\x80aY\xE2V[PaZ\xD8`\x01\x84\x01a\x10\x91V[aZ\xEBaZ\xE5`\x02a\x11GV[\x91a\x11GV[\x14\x15aY\xDDV[aZ\xFB\x90aXsV[aYiV[PPPPV[PPPPV[``\x90V[`\x01\x80`@\x1B\x03\x81\x11a['W` \x80\x91\x02\x01\x90V[a\x08\xBDV[\x90a[>a[9\x83a[\x11V[a\x16\xA8V[\x91\x82RV[a[M`\x80a\x16\xA8V[\x90V[\x90a[\xB7a[\xAE`\x03a[aa[CV[\x94a[xa[p_\x83\x01a\x08\xF8V[_\x88\x01aO!V[a[\x90a[\x87`\x01\x83\x01a\t6V[` \x88\x01aGEV[a[\xA8a[\x9F`\x02\x83\x01a\t6V[`@\x88\x01aGEV[\x01a\t]V[``\x84\x01aO$V[V[a[\xC2\x90a[PV[\x90V[\x90a[\xCF\x82a\x07\x8CV[a[\xD8\x81a[,V[\x92a[\xE6` \x85\x01\x91a\x07\x90V[_\x91[\x83\x83\x10a[\xF6WPPPPV[`\x04` `\x01\x92a\\\x06\x85a[\xB9V[\x81R\x01\x92\x01\x92\x01\x91\x90a[\xE9V[a\\\x1D\x90a[\xC5V[\x90V[a\\7a\\<\x91a\\/a[\x0CV[P`\x08a\x07bV[a\\\x14V[\x90V[a\\m\x90a\\ha\\ca\\\\a\\W\x84`\x06a2\xF7V[a3\rV[3\x90ae2V[a5\x81V[a\\\xC8V[V[_\x7FCannot go offline while slashed\0\x91\x01RV[a\\\xA3`\x1F` \x92a\t\xCDV[a\\\xAC\x81a\\oV[\x01\x90V[a\\\xC5\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra\\\x96V[\x90V[a\\\xE6a\\\xE1a\\\xDA`\x03\x84\x90a\x0F\xB8V[3\x90a\x10\x02V[aM{V[\x90a\\\xF3`\x01\x83\x01a\x10\x91V[\x91\x82a]\x08a]\x02`\x03a\x11GV[\x91a\x11GV[\x14a]\x8EWa]\x1C\x90`\x01`\x04\x91\x01a3\xC8V[a]:a]3a].`\x04\x84\x90a2\xF7V[a3\rV[3\x90amJV[P\x903\x90\x91`\x04a]ta]n\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07FV[\x93a\x0F\xF6V[\x93a]\x89a]\x80a\x03\xA2V[\x92\x83\x92\x83aR\xCEV[\x03\x90\xA3V[a]\x96a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a]\xAC`\x04\x82\x01a\\\xB0V[\x03\x90\xFD[a]\xB9\x90a\\?V[V[\x90\x91\x82a]\xCB\x81a]\xD2\x93a\x1D\x0FV[\x80\x93a\x17\x05V[\x01\x90V[a]\xE7\x90` \x94\x93a]\xEE\x93a]\xBBV[\x80\x92a\x1D@V[\x01\x90V[\x90\x91a^\t\x90a^\0a\x03\xA2V[\x93\x84\x93\x84a]\xD6V[\x03\x90 \x90V[\x90\x91a^\x1A\x92a]\xF2V[\x90V[\x92a^Ba^J\x93\x92a^=a^O\x96a^5a'\x84V[P`\ta\x1C\xE3V[a\x1C\xF9V[\x91\x90\x91a^\x0FV[a\t6V[\x90V[a^ZaK\x0BV[Pa^e`\x01a%\x93V[\x90V[a^r\x90Qa\x11GV[\x90V[\x90V[a^\x8Ca^\x87a^\x91\x92a^uV[a\x07CV[a\x05RV[\x90V[` \x7Fl\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x7FOperator not eligible for remova_\x82\x01R\x01RV[a^\xEE`!`@\x92a\t\xCDV[a^\xF7\x81a^\x94V[\x01\x90V[a_\x10\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra^\xE1V[\x90V[\x15a_\x1AWV[a_\"a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a_8`\x04\x82\x01a^\xFBV[\x03\x90\xFD[\x90a_\xEDa_\xE8a_\xF2\x933a_ma_ga_ba_]`\x07\x86\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14\x80\x15a`\xABW[a_~\x90aT\xDBV[a_\x9Ca_\x97a_\x90`\x03\x84\x90a\x0F\xB8V[\x86\x90a\x10\x02V[aG\xFEV[a_\xA8``\x82\x01a^hV[a_\xBBa_\xB5`\x03a\x11GV[\x91a\x11GV[\x03a_\xF5W[Pa_\xE0a_\xD9a_\xD4`\x05\x84\x90a2\xF7V[a3\rV[\x85\x90amJV[P`\x04a2\xF7V[a3\rV[amJV[PV[a`q\x90a`Ea`5a`\x08\x85ac\xCCV[a`/a`*` a`#a`\x1E_\x86\x01aI+V[a5\xE1V[\x93\x01aI\x02V[aI8V[\x90a(\xCEV[a`?`\na^xV[\x90a(\xCEV[a`P_\x83\x01a?\x0BV[a`ba`\\_a,\x8EV[\x91a\x05RV[\x11\x91\x82a`wW[PPa_\x13V[_a_\xC1V[a`\xA2\x91\x92Pa`\x96a`\x9C\x91a`\x90_B\x92\x01a?\x0BV[\x90a6<V[\x92a\x05RV[\x91a\x05RV[\x10\x15_\x80a`jV[Pa_~3a`\xC9a`\xC3a`\xBEaK\x0FV[a\x03\xEDV[\x91a\x03\xEDV[\x14\x90Pa_uV[\x90a`\xFBaa\0\x91a`\xE1a;\x82V[Pa`\xF6a`\xEE\x85ac\xCCV[\x94`\x03a\x0F\xB8V[a\x10\x02V[aG\xFEV[aa\x0B_\x82\x01a?\x0BV[aa\x1Daa\x17_a,\x8EV[\x91a\x05RV[\x14aaXWaaNaaI_aaBaaT\x94aa<\x83B\x92\x01a?\x0BV[\x90a6<V[\x94\x01aI+V[a5\xE1V[\x91a\x05RV[\x10\x90V[PP_\x90V[aao\x90aajad\xE4V[aaqV[V[aa|\x81`\x01a&pV[aa\x84aK\x0FV[\x90aa\xB8aa\xB2\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0\x93a\x0F\xF6V[\x91a\x0F\xF6V[\x91aa\xC1a\x03\xA2V[\x80aa\xCB\x81a\x04IV[\x03\x90\xA3V[aa\xD9\x90aa^V[V[_ab\x1Aab \x93ab\x123ab\x0Cab\x06ab\x01aa\xFC`\x07\x8A\x90a\x13\xB3V[a%\x93V[a\x03\xEDV[\x91a\x03\xEDV[\x14a(\x0BV[\x92`\x02a\"]V[\x01aVSV[V[_\x7FNot registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[abV`\x0E` \x92a\t\xCDV[ab_\x81ab\"V[\x01\x90V[abx\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RabIV[\x90V[\x15ab\x82WV[ab\x8Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80ab\xA0`\x04\x82\x01abcV[\x03\x90\xFD[ab\xE03ab\xDAab\xD4\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEDV[\x91a\x03\xEDV[\x14a%VV[ac\x06ac\x01ab\xFAab\xF5`\x06\x85\x90a2\xF7V[a3\rV[\x84\x90amJV[ab{V[ac$ac\x1Dac\x18`\x04\x84\x90a2\xF7V[a3\rV[\x83\x90amJV[P\x90acYacS\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E\x93a\x07FV[\x91a\x0F\xF6V[\x91acba\x03\xA2V[\x80acl\x81a\x04IV[\x03\x90\xA3V[\x90ac\xBEac\xB5_ac\x81a'\x19V[\x94ac\x98ac\x90\x83\x83\x01a\x107V[\x83\x88\x01aGSV[ac\xAFac\xA6\x83\x83\x01a\x10dV[` \x88\x01aGaV[\x01a\"\x87V[`@\x84\x01aO$V[V[ac\xC9\x90acqV[\x90V[ac\xE3ac\xE8\x91ac\xDBa'dV[P`\x02a\"]V[ac\xC0V[ac\xF3_\x82\x01aI+V[ad\x05ac\xFF_aX\x8FV[\x91a\x03\xB4V[\x14adKW[ad\x17` \x82\x01aI\x02V[ad)ad#_aI\x0FV[\x91a\x04\xADV[\x14ad2W[\x90V[adFad=a\x15\xFBV[` \x83\x01aGaV[ad/V[ad^adVa\x0B\xFAV[_\x83\x01aGSV[ad\x0BV[adl\x90a\x0F\xCEV[\x90V[ad\x83ad~ad\x88\x92a\x03\xE2V[a\x07CV[a\x05RV[\x90V[ad\x9Fad\x9Aad\xA4\x92a\x05RV[a&MV[a\x0E\xF1V[\x90V[\x90V[\x90ad\xDCad\xD6ad\xD1ad\xCC_ad\xE1\x96ad\xC4a;\x82V[P\x01\x94adcV[adoV[ad\x8BV[\x91ad\xA7V[an\x06V[\x90V[ad\xECaK\x0FV[ae\x05ad\xFFad\xFAak\xF8V[a\x03\xEDV[\x91a\x03\xEDV[\x03ae\x0CWV[ae.ae\x17ak\xF8V[_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xBBV[\x03\x90\xFD[\x90aedae^aeYaeT_aei\x96aeLa;\x82V[P\x01\x94adcV[adoV[ad\x8BV[\x91ad\xA7V[aniV[\x90V[ae\x8B\x91ae\x82\x91ae|aK\x0BV[Pan\xC5V[\x90\x92\x91\x92ao\x85V[\x90V[_\x7FOperator is slashed\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[ae\xC2`\x13` \x92a\t\xCDV[ae\xCB\x81ae\x8EV[\x01\x90V[ae\xE4\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rae\xB5V[\x90V[\x15ae\xEEWV[ae\xF6a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80af\x0C`\x04\x82\x01ae\xCFV[\x03\x90\xFD[\x90af%af af,\x92a3\x10V[a3\x1CV[\x82Ta/\xCAV[\x90UV[af9\x90a\x03\xB4V[`\x01\x80`@\x1B\x03\x81\x14afLW`\x01\x01\x90V[a(\xBAV[\x90V[afhafcafm\x92afQV[a\x07CV[a\x04\xADV[\x90V[\x91` af\x91\x92\x94\x93af\x8A`@\x82\x01\x96_\x83\x01\x90a\x11\x17V[\x01\x90a\x05UV[V[af\x9C\x90a\x0F\xCEV[\x90V[af\xA8\x90af\x93V[\x90V[af\xB4\x90a\x0F\xEAV[\x90V[`@\x90af\xE0af\xE7\x94\x96\x95\x93\x96af\xD6``\x84\x01\x98_\x85\x01\x90a\x0C\xAEV[` \x83\x01\x90a\x0C\x13V[\x01\x90a\x0C\x13V[V[\x94\x92\x93\x91\x93ag\x0Cag\x07ag\0`\x03\x89\x90a\x0F\xB8V[\x87\x90a\x10\x02V[aM{V[\x93ag\x16\x87ac\xCCV[\x93ag@ag&`\x01\x88\x01a\x10\x91V[ag9ag3`\x03a\x11GV[\x91a\x11GV[\x14\x15ae\xE7V[ag^agWagR`\x05\x8B\x90a2\xF7V[a3\rV[\x88\x90ad\xAAV[Pah3`@agp`\x01\x89\x01a\x10\x91V[\x96ag}B_\x8B\x01a/\xE0V[ag\xA7ag\x8B\x85\x87\x90a6\xB8V[ag\x9Dag\x97\x82a6\xCCV[\x91a6\xC6V[ `\x02\x8B\x01af\x10V[ag\xBCag\xB3_aI\x0FV[`\x01\x8B\x01aR\xAEV[ag\xDA`\x01\x8A\x01ag\xD4ag\xCF\x82a\x107V[af0V[\x90aM\x9CV[ag\xE2a<\xB6V[P\x85ag\xF6ag\xF0_aI\x0FV[\x91a\x04\xADV[\x14_\x14aj\xB7Wah\r_\x99[`\x01\x8B\x91\x01a3\xC8V[\x87ah!ah\x1B`\x02a\x11GV[\x91a\x11GV[\x14\x80aj\x9BW[aj-W[\x01aP\x0FV[\x80aj\tW[ai\xF3W[PP\x85\x91\x85\x91\x92Bah\x82ah|ahv\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x94a\x07FV[\x94a\x07FV[\x94a\x0F\xF6V[\x94ah\x97ah\x8Ea\x03\xA2V[\x92\x83\x92\x83afpV[\x03\x90\xA4\x80ah\xADah\xA7\x84a\x11GV[\x91a\x11GV[\x03ai\x9DW[PPah\xBF`\x0Ba%\x93V[ah\xD9ah\xD3ah\xCE_a%\xBFV[a\x03\xEDV[\x91a\x03\xEDV[\x03ah\xE3W[PPV[ah\xFDah\xF8ah\xF3`\x0Ba%\x93V[af\x9FV[af\xABV[\x91c\xD4xS\xB6\x91\x90\x92ai\x0FBa5\xFDV[\x92\x81;\x15ai\x98W_ai5\x91ai@\x82\x96ai)a\x03\xA2V[\x98\x89\x97\x88\x96\x87\x95aKNV[\x85R`\x04\x85\x01af\xB7V[\x03\x92Z\xF1\x90\x81ailW[P\x15_\x14aigW`\x01aibW[[_\x80ah\xDFV[aiZV[ai[V[ai\x8B\x90_=\x81\x11ai\x91W[ai\x83\x81\x83a\x08\xD1V[\x81\x01\x90aKTV[_aiKV[P=aiyV[aKJV[\x83\x83\x91\x92ai\xD4ai\xCE\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07FV[\x93a\x0F\xF6V[\x93ai\xE9ai\xE0a\x03\xA2V[\x92\x83\x92\x83aR\xCEV[\x03\x90\xA3_\x80ah\xB3V[aj\x02\x91\x88\x91\x88\x90\x91\x92at:V[_\x80ah>V[Paj\x15\x81\x83\x90a-HV[aj'aj!_a,\x8EV[\x91a\x05RV[\x11ah9V[ajJajCaj>\x8D`\x04a2\xF7V[a3\rV[\x8B\x90ad\xAAV[P\x8A\x8Aaj\x80ajz\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07FV[\x91a\x0F\xF6V[\x91aj\x89a\x03\xA2V[\x80aj\x93\x81a\x04IV[\x03\x90\xA3ah-V[P\x88aj\xB0aj\xAA`\x02a\x11GV[\x91a\x11GV[\x14\x15ah(V[\x85aj\xCBaj\xC5`dafTV[\x91a\x04\xADV[\x10_\x14aj\xDEWah\r`\x01\x99[ah\x03V[ah\r`\x01\x99aj\xF6\x8D\x8D\x8B\x90\x8B\x90\x8A\x92\x8C\x94ap\xF4V[aj\xD9V[ak\x12_ak\x17\x92ak\x0Ba'\x84V[P\x01ad\xA7V[au\xF8V[\x90V[ak&ak+\x91a\t\x1AV[a)TV[\x90V[akBak=akG\x92a\x05RV[a\x07CV[a\x03\xE2V[\x90V[akuakpak\x7F\x93akk_akz\x95akdaK\x0BV[P\x01ad\xA7V[avfV[ak\x1AV[ak.V[a\x0F\xEAV[\x90V[\x91\x90`\x08ak\xA2\x91\x02\x91ak\x9C`\x01\x80`\xA0\x1B\x03\x84a)+V[\x92a)+V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x91\x90ak\xC2ak\xBDak\xCA\x93a\x0F\xF6V[a&mV[\x90\x83Tak\x82V[\x90UV[ak\xE0\x91ak\xDAaK\x0BV[\x91ak\xACV[V[ak\xF6\x90ak\xF1_`\x01ak\xCEV[av\x87V[V[al\0aK\x0BV[P3\x90V[al\x0E\x90a\x05RV[_\x19\x81\x14al\x1CW`\x01\x01\x90V[a(\xBAV[al+\x90Qa\x03\xEDV[\x90V[\x93\x91\x92\x93al:a:UV[PalNalI\x85\x84\x90a6<V[a:\x91V[\x92alX_a,\x8EV[\x92[\x80almalg\x88a\x05RV[\x91a\x05RV[\x10\x15al\xDBWal\x91al\x8Aal\x85`\x05\x86\x90a2\xF7V[a3\rV[\x82\x90akJV[al\x9D\x84\x82\x8A\x91av\xE6V[al\xB1W[Pal\xAC\x90a,\xAAV[alZV[al\xAC\x91\x94al\xCFal\xD4\x92al\xCA\x89\x91\x84\x90\x92a:\xB8V[a:\xD8V[al\x05V[\x93\x90al\xA2V[P\x94PP\x91Pal\xEA\x82a:\x91V[\x92al\xF4_a,\x8EV[[\x80am\x08am\x02\x86a\x05RV[\x91a\x05RV[\x10\x15amDWam?\x90am:am(am#\x86\x84\x90a:\xB8V[al!V[am5\x88\x91\x84\x90\x92a:\xB8V[a:\xD8V[a,\xAAV[al\xF5V[P\x91PPV[\x90am|amvamqaml_am\x81\x96amda;\x82V[P\x01\x94adcV[adoV[ad\x8BV[\x91ad\xA7V[ax\x1EV[\x90V[\x90V[_R` _ \x90V[T\x90V[am\x9D\x81am\x90V[\x82\x10\x15am\xB7Wam\xAF`\x01\x91am\x87V[\x91\x02\x01\x90_\x90V[a\x07xV[\x90\x81T\x91`\x01`@\x1B\x83\x10\x15am\xE7W\x82am\xDF\x91`\x01am\xE5\x95\x01\x81Uam\x94V[\x90a3(V[V[a\x08\xBDV[T\x90V[\x90am\xFA\x90a3\x10V[_R` R`@_ \x90V[an\x0Ea;\x82V[Pan#an\x1D\x82\x84\x90aniV[\x15a\x04\xC0V[_\x14ancWanYan^\x92anEan>_\x85\x01am\x84V[\x82\x90am\xBCV[`\x01anR_\x85\x01am\xECV[\x93\x01am\xF0V[a/\xE0V[`\x01\x90V[PP_\x90V[an\x87\x91`\x01an\x82\x92an{a;\x82V[P\x01am\xF0V[a\t6V[an\x99an\x93_a,\x8EV[\x91a\x05RV[\x14\x15\x90V[_\x90V[\x90V[an\xB9an\xB4an\xBE\x92an\xA2V[a\x07CV[a\x05RV[\x90V[_\x90V[\x91\x90\x91an\xD0aK\x0BV[Pan\xD9an\x9EV[Pan\xE2a3JV[Pan\xEC\x83a6\xCCV[an\xFFan\xF9`Aan\xA5V[\x91a\x05RV[\x14_\x14aoFWao?\x91\x92ao\x13a3JV[Pao\x1Ca3JV[Pao%an\xC1V[P` \x81\x01Q```@\x83\x01Q\x92\x01Q_\x1A\x90\x91\x92ay\x9DV[\x91\x92\x90\x91\x90V[PaoP_a%\xBFV[\x90aodao_`\x02\x94a6\xCCV[ad\x8BV[\x91\x92\x91\x90V[`\x04\x11\x15aotWV[a\x11$V[\x90ao\x83\x82aojV[V[\x80ao\x98ao\x92_aoyV[\x91aoyV[\x14_\x14ao\xA3WPPV[\x80ao\xB7ao\xB1`\x01aoyV[\x91aoyV[\x14_\x14ao\xDAW_c\xF6E\xEE\xDF`\xE0\x1B\x81R\x80ao\xD6`\x04\x82\x01a\x04IV[\x03\x90\xFD[\x80ao\xEEao\xE8`\x02aoyV[\x91aoyV[\x14_\x14ap\x1CWap\x18ap\x01\x83ak\x1AV[_\x91\x82\x91c\xFC\xE6\x98\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x05bV[\x03\x90\xFD[ap/ap)`\x03aoyV[\x91aoyV[\x14ap7WPV[apR\x90_\x91\x82\x91c5\xE2\xF3\x83`\xE2\x1B\x83R`\x04\x83\x01a\x0F\x01V[\x03\x90\xFD[apjapeapo\x92a\x12\xFCV[a\x07CV[a\x04\xADV[\x90V[ap~ap\x84\x91a\x03\xB4V[\x91a\x03\xB4V[\x90\x03\x90`\x01\x80`@\x1B\x03\x82\x11ap\x96WV[a(\xBAV[_\x7FProtocol violation reported\0\0\0\0\0\x91\x01RV[ap\xCF`\x1B` \x92a\t\xCDV[ap\xD8\x81ap\x9BV[\x01\x90V[ap\xF1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rap\xC2V[\x90V[\x93PP\x92Paq\x0Caq\x06`\xC8apVV[\x91a\x04\xADV[\x10\x15aq\x17W[PPV[aq Ba5\xFDV[aq>aq9aq2`\x0C\x85\x90aH6V[\x85\x90aHLV[a\x107V[\x80aqQaqK_aX\x8FV[\x91a\x03\xB4V[\x14\x90\x81\x15aq\xD7W[PaqfW[Paq\x13V[aq\x85\x90aq\x80aqy`\x0C\x85\x90aH6V[\x85\x90aHLV[aM\x9CV[\x90aq\xB9aq\xB3\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07FV[\x91a\x0F\xF6V[\x91aq\xC2a\x03\xA2V[\x80aq\xCC\x81ap\xDCV[\x03\x90\xA3_\x80\x80aq`V[aq\xE2\x91P\x82aprV[aq\xFBaq\xF5aq\xF0a\x0FjV[a\x03\xB4V[\x91a\x03\xB4V[\x10\x15_aqZV[\x90V[ar\x1Aar\x15ar\x1F\x92ar\x03V[a\x07CV[a\x05RV[\x90V[\x90\x92\x91\x92ar7ar2\x82a\x16\xE4V[a\x16\xA8V[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11arSWarQ\x92a\t\xD6V[V[a\x16\xE0V[\x90\x80`\x1F\x83\x01\x12\x15arvW\x81` ars\x93Q\x91\x01ar\"V[\x90V[a\x05\xADV[\x90PQ\x90ar\x88\x82a\x06\xF3V[V[\x91\x90\x91`@\x81\x84\x03\x12ar\xDBWar\xA1`@a\x16\xA8V[\x92_\x82\x01Q\x91`\x01\x80`@\x1B\x03\x83\x11ar\xD6War\xC3\x82ar\xCF\x94\x83\x01arXV[_\x86\x01R` \x01ar{V[` \x83\x01RV[a\x16\xDCV[a\x16\xD8V[\x92\x91\x90ar\xF4ar\xEF\x82a\x16\xBDV[a\x16\xA8V[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11asIW\x81\x90[\x83\x82\x10as\x1AWPPPPPV[\x81Q`\x01\x80`@\x1B\x03\x81\x11asDW` \x91as9\x87\x84\x93\x87\x01ar\x8AV[\x81R\x01\x91\x01\x90as\x0CV[a\x05\xADV[a\x05\xB5V[\x90\x80`\x1F\x83\x01\x12\x15aslW\x81` asi\x93Q\x91\x01ar\xE0V[\x90V[a\x05\xADV[\x90` \x82\x82\x03\x12as\x9FW_\x82\x01Q`\x01\x80`@\x1B\x03\x81\x11as\x9AWas\x97\x92\x01asNV[\x90V[a\x03\xB0V[a\x03\xACV[` \x91\x81R\x01\x90V[\x91\x90as\xC7\x81as\xC0\x81as\xCC\x95as\xA4V[\x80\x95a\x17\x05V[a\x08\xB3V[\x01\x90V[\x90\x91as\xE7\x92` \x83\x01\x92_\x81\x85\x03\x91\x01Ras\xADV[\x90V[as\xF4`2a\x15=V[\x90V[\x94\x93\x91``\x91at8\x94at#at0\x93at\x19`\x80\x8B\x01\x94_\x8C\x01\x90a\x0C\x13V[` \x8A\x01\x90a\x0C\xAEV[\x87\x82\x03`@\x89\x01Ra\x0E\x18V[\x94\x01\x90a\x05UV[V[\x91atF\x81\x85\x90a-HV[atXatR_a,\x8EV[\x91a\x05RV[\x14au\xF2Wath\x81\x85\x90a-HV[at|atva\xC3Par\x06V[\x91a\x05RV[\x11au\xECW_at\x8Aa9\xDCV[\x94at\x940a<\xE5V[at\xB6c1\xE3\xBD\x1B\x94\x92\x94at\xC1at\xAAa\x03\xA2V[\x96\x87\x95\x86\x94\x85\x94aKNV[\x84R`\x04\x84\x01as\xD0V[\x03\x91Z\xFA\x80\x91_\x92au\xC8W[P\x15_\x14au\xBFWP`\x01au\xBAW[at\xE7\x83a\r\x87V[au\0at\xFAat\xF5as\xEAV[a\x05RV[\x91a\x05RV[\x11_\x14au\xACWau\x0Fas\xEAV[[au\x190a<\xE5V[\x90ce\xA6\x93n\x93\x92\x94\x90\x82;\x15au\xA7W_\x94auT\x86\x92auI\x94au=a\x03\xA2V[\x99\x8A\x98\x89\x97\x88\x96aKNV[\x86R`\x04\x86\x01as\xF7V[\x03\x92Z\xF1\x90\x81au{W[P\x15_\x14auvW`\x01auqW[[V[aunV[auoV[au\x9A\x90_=\x81\x11au\xA0W[au\x92\x81\x83a\x08\xD1V[\x81\x01\x90aKTV[_au_V[P=au\x88V[aKJV[au\xB5\x83a\r\x87V[au\x10V[PPPV[\x90\x92P\x91at\xDEV[au\xE5\x91\x92P=\x80_\x83>au\xDD\x81\x83a\x08\xD1V[\x81\x01\x90asqV[\x90_at\xCEV[PPPPV[PPPPV[_av\x0C\x91av\x05a'\x84V[P\x01am\xECV[\x90V[_R` _ \x90V[av!\x81am\xECV[\x82\x10\x15av;Wav3`\x01\x91av\x0FV[\x91\x02\x01\x90_\x90V[a\x07xV[avP\x90`\x08avU\x93\x02a\x0CjV[a\x10\x9EV[\x90V[\x90avc\x91Tav@V[\x90V[av\x84\x91_av~\x92avwa3JV[P\x01av\x18V[\x90avXV[\x90V[av\x90_a%\x93V[av\x9A\x82_a&pV[\x90av\xCEav\xC8\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x0F\xF6V[\x91a\x0F\xF6V[\x91av\xD7a\x03\xA2V[\x80av\xE1\x81a\x04IV[\x03\x90\xA3V[av\xEEa;\x82V[Paw\x16aw\x10aw\taw\x04`\x06\x85\x90a2\xF7V[a3\rV[\x84\x90ae2V[\x15a\x04\xC0V[aw\xB8Waw6\x91aw,aw1\x92`\x03a\x0F\xB8V[a\x10\x02V[aG\xFEV[awA_\x82\x01a?\x0BV[awSawM_a,\x8EV[\x91a\x05RV[\x14\x80\x15aw\x92W[aw\x8CWaw\x81aw{aw\x87\x92awu_B\x92\x01a?\x0BV[\x90a6<V[\x92a\x05RV[\x91a\x05RV[\x10\x15\x90V[PP_\x90V[Paw\x9F``\x82\x01a^hV[aw\xB2aw\xAC`\x03a\x11GV[\x91a\x11GV[\x14aw[V[PPP_\x90V[aw\xD3aw\xCEaw\xD8\x92aU\xA5V[a\x07CV[a\x05RV[\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[aw\xF8\x81am\x90V[\x80\x15ax\x19W`\x01\x90\x03\x90ax\x16ax\x10\x83\x83am\x94V[\x90a3NV[UV[aw\xDBV[ax&a;\x82V[Pax=ax8`\x01\x83\x01\x84\x90am\xF0V[a\t6V[\x90\x81axQaxK_a,\x8EV[\x91a\x05RV[\x14\x15_\x14ay\x1DWax\xCF\x92`\x01ax\xCA\x92\x84axx_\x96axr\x85aw\xBFV[\x90a6<V[ax\x95ax\x86\x88\x85\x01am\xECV[ax\x8F\x86aw\xBFV[\x90a6<V[\x81ax\xA8ax\xA2\x83a\x05RV[\x91a\x05RV[\x03ax\xD4W[PPPax\xC4ax\xBF\x86\x83\x01am\x84V[aw\xEFV[\x01am\xF0V[a)\x95V[`\x01\x90V[ay\x15\x92ay\x07ax\xF3ax\xEDay\x10\x94\x8C\x89\x01av\x18V[\x90avXV[\x93ay\x01\x85\x91\x8C\x89\x01av\x18V[\x90a3(V[\x91\x85\x85\x01am\xF0V[a/\xE0V[_\x80\x80ax\xAEV[PPP_\x90V[\x90V[ay;ay6ay@\x92ay$V[a\x07CV[a\x05RV[\x90V[ayxay\x7F\x94ayn``\x94\x98\x97\x95ayd`\x80\x86\x01\x9A_\x87\x01\x90a\x0E\xF4V[` \x85\x01\x90a\x11\x17V[`@\x83\x01\x90a\x0E\xF4V[\x01\x90a\x0E\xF4V[V[ay\x95ay\x90ay\x9A\x92a%\xA0V[a&MV[a\x0E\xF1V[\x90V[\x93\x92\x93ay\xA8aK\x0BV[Pay\xB1an\x9EV[Pay\xBAa3JV[Pay\xC4\x85ak\x1AV[ay\xECay\xE6o\xA2\xA8\x91\x8C\xA8[\xAF\xE2 \x16\xD0\xB9\x97\xE4\xDF``\x01`\xFF\x1B\x03ay'V[\x91a\x05RV[\x11azyW\x90az\x0F` \x94\x95_\x94\x93\x92\x93az\x06a\x03\xA2V[\x94\x85\x94\x85ayCV[\x83\x80R\x03\x90`\x01Z\xFA\x15aztWaz'_Qa&MV[\x80azBaz<az7_a%\xBFV[a\x03\xEDV[\x91a\x03\xEDV[\x14azXW_\x91azR_ay\x81V[\x91\x92\x91\x90V[Pazb_a%\xBFV[`\x01\x91azn_ay\x81V[\x91\x92\x91\x90V[aK\x86V[PPPaz\x85_a%\xBFV[\x90`\x03\x92\x91\x92\x91\x90V\xFE\xA1dsolcC\0\x08\x1A\0\n",
    );
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Custom error with signature `ECDSAInvalidSignature()` and selector `0xf645eedf`.
```solidity
error ECDSAInvalidSignature();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ECDSAInvalidSignature;
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = ();
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = ();
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<ECDSAInvalidSignature> for UnderlyingRustTuple<'_> {
            fn from(value: ECDSAInvalidSignature) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for ECDSAInvalidSignature {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for ECDSAInvalidSignature {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ECDSAInvalidSignature()";
            const SELECTOR: [u8; 4] = [246u8, 69u8, 238u8, 223u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn abi_decode_raw_validate(data: &[u8]) -> alloy_sol_types::Result<Self> {
                <Self::Parameters<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Self::new)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Custom error with signature `ECDSAInvalidSignatureLength(uint256)` and selector `0xfce698f7`.
```solidity
error ECDSAInvalidSignatureLength(uint256 length);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ECDSAInvalidSignatureLength {
        #[allow(missing_docs)]
        pub length: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (
            alloy::sol_types::private::primitives::aliases::U256,
        );
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<ECDSAInvalidSignatureLength>
        for UnderlyingRustTuple<'_> {
            fn from(value: ECDSAInvalidSignatureLength) -> Self {
                (value.length,)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>>
        for ECDSAInvalidSignatureLength {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self { length: tuple.0 }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for ECDSAInvalidSignatureLength {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ECDSAInvalidSignatureLength(uint256)";
            const SELECTOR: [u8; 4] = [252u8, 230u8, 152u8, 247u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.length),
                )
            }
            #[inline]
            fn abi_decode_raw_validate(data: &[u8]) -> alloy_sol_types::Result<Self> {
                <Self::Parameters<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Self::new)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Custom error with signature `ECDSAInvalidSignatureS(bytes32)` and selector `0xd78bce0c`.
```solidity
error ECDSAInvalidSignatureS(bytes32 s);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ECDSAInvalidSignatureS {
        #[allow(missing_docs)]
        pub s: alloy::sol_types::private::FixedBytes<32>,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (alloy::sol_types::private::FixedBytes<32>,);
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<ECDSAInvalidSignatureS> for UnderlyingRustTuple<'_> {
            fn from(value: ECDSAInvalidSignatureS) -> Self {
                (value.s,)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for ECDSAInvalidSignatureS {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self { s: tuple.0 }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for ECDSAInvalidSignatureS {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ECDSAInvalidSignatureS(bytes32)";
            const SELECTOR: [u8; 4] = [215u8, 139u8, 206u8, 12u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(&self.s),
                )
            }
            #[inline]
            fn abi_decode_raw_validate(data: &[u8]) -> alloy_sol_types::Result<Self> {
                <Self::Parameters<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Self::new)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Custom error with signature `HeartbeatFromFuture(uint64,uint64)` and selector `0x57ea02e9`.
```solidity
error HeartbeatFromFuture(uint64 signed, uint64 now_);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct HeartbeatFromFuture {
        #[allow(missing_docs)]
        pub signed: u64,
        #[allow(missing_docs)]
        pub now_: u64,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (
            alloy::sol_types::sol_data::Uint<64>,
            alloy::sol_types::sol_data::Uint<64>,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (u64, u64);
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<HeartbeatFromFuture> for UnderlyingRustTuple<'_> {
            fn from(value: HeartbeatFromFuture) -> Self {
                (value.signed, value.now_)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for HeartbeatFromFuture {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    signed: tuple.0,
                    now_: tuple.1,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for HeartbeatFromFuture {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "HeartbeatFromFuture(uint64,uint64)";
            const SELECTOR: [u8; 4] = [87u8, 234u8, 2u8, 233u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.signed),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.now_),
                )
            }
            #[inline]
            fn abi_decode_raw_validate(data: &[u8]) -> alloy_sol_types::Result<Self> {
                <Self::Parameters<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Self::new)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Custom error with signature `HeartbeatStale(uint64,uint64)` and selector `0x60d56dd4`.
```solidity
error HeartbeatStale(uint64 signed, uint64 now_);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct HeartbeatStale {
        #[allow(missing_docs)]
        pub signed: u64,
        #[allow(missing_docs)]
        pub now_: u64,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (
            alloy::sol_types::sol_data::Uint<64>,
            alloy::sol_types::sol_data::Uint<64>,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (u64, u64);
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<HeartbeatStale> for UnderlyingRustTuple<'_> {
            fn from(value: HeartbeatStale) -> Self {
                (value.signed, value.now_)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for HeartbeatStale {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    signed: tuple.0,
                    now_: tuple.1,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for HeartbeatStale {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "HeartbeatStale(uint64,uint64)";
            const SELECTOR: [u8; 4] = [96u8, 213u8, 109u8, 212u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.signed),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.now_),
                )
            }
            #[inline]
            fn abi_decode_raw_validate(data: &[u8]) -> alloy_sol_types::Result<Self> {
                <Self::Parameters<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Self::new)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Custom error with signature `OwnableInvalidOwner(address)` and selector `0x1e4fbdf7`.
```solidity
error OwnableInvalidOwner(address owner);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct OwnableInvalidOwner {
        #[allow(missing_docs)]
        pub owner: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<OwnableInvalidOwner> for UnderlyingRustTuple<'_> {
            fn from(value: OwnableInvalidOwner) -> Self {
                (value.owner,)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for OwnableInvalidOwner {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self { owner: tuple.0 }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for OwnableInvalidOwner {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "OwnableInvalidOwner(address)";
            const SELECTOR: [u8; 4] = [30u8, 79u8, 189u8, 247u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.owner,
                    ),
                )
            }
            #[inline]
            fn abi_decode_raw_validate(data: &[u8]) -> alloy_sol_types::Result<Self> {
                <Self::Parameters<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Self::new)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Custom error with signature `OwnableUnauthorizedAccount(address)` and selector `0x118cdaa7`.
```solidity
error OwnableUnauthorizedAccount(address account);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct OwnableUnauthorizedAccount {
        #[allow(missing_docs)]
        pub account: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[doc(hidden)]
        #[allow(dead_code)]
        type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<OwnableUnauthorizedAccount>
        for UnderlyingRustTuple<'_> {
            fn from(value: OwnableUnauthorizedAccount) -> Self {
                (value.account,)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>>
        for OwnableUnauthorizedAccount {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self { account: tuple.0 }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for OwnableUnauthorizedAccount {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "OwnableUnauthorizedAccount(address)";
            const SELECTOR: [u8; 4] = [17u8, 140u8, 218u8, 167u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.account,
                    ),
                )
            }
            #[inline]
            fn abi_decode_raw_validate(data: &[u8]) -> alloy_sol_types::Result<Self> {
                <Self::Parameters<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Self::new)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `HeartbeatConfigUpdated(uint64,uint64,uint8)` and selector `0xc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea564`.
```solidity
event HeartbeatConfigUpdated(uint64 indexed serviceId, uint64 interval, uint8 maxMissed);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct HeartbeatConfigUpdated {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub interval: u64,
        #[allow(missing_docs)]
        pub maxMissed: u8,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for HeartbeatConfigUpdated {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
            );
            const SIGNATURE: &'static str = "HeartbeatConfigUpdated(uint64,uint64,uint8)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                201u8, 89u8, 158u8, 217u8, 98u8, 98u8, 74u8, 133u8, 142u8, 197u8, 155u8,
                174u8, 14u8, 216u8, 108u8, 117u8, 244u8, 219u8, 101u8, 254u8, 4u8, 87u8,
                0u8, 33u8, 39u8, 126u8, 219u8, 237u8, 208u8, 78u8, 165u8, 100u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    interval: data.0,
                    maxMissed: data.1,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.interval),
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.maxMissed),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.serviceId.clone())
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for HeartbeatConfigUpdated {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&HeartbeatConfigUpdated> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &HeartbeatConfigUpdated) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `HeartbeatReceived(uint64,uint64,address,uint8,uint256)` and selector `0x658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b9`.
```solidity
event HeartbeatReceived(uint64 indexed serviceId, uint64 indexed blueprintId, address indexed operator, uint8 statusCode, uint256 timestamp);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct HeartbeatReceived {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub blueprintId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub statusCode: u8,
        #[allow(missing_docs)]
        pub timestamp: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for HeartbeatReceived {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<8>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "HeartbeatReceived(uint64,uint64,address,uint8,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                101u8, 137u8, 24u8, 227u8, 20u8, 127u8, 19u8, 221u8, 6u8, 142u8, 194u8,
                20u8, 55u8, 180u8, 194u8, 92u8, 33u8, 104u8, 42u8, 141u8, 194u8, 18u8,
                147u8, 72u8, 103u8, 30u8, 173u8, 0u8, 13u8, 179u8, 231u8, 185u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    blueprintId: topics.2,
                    operator: topics.3,
                    statusCode: data.0,
                    timestamp: data.1,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.statusCode),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.timestamp),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.serviceId.clone(),
                    self.blueprintId.clone(),
                    self.operator.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[2usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.blueprintId);
                out[3usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for HeartbeatReceived {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&HeartbeatReceived> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &HeartbeatReceived) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `MetricReported(uint64,address,string,uint256)` and selector `0x23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd`.
```solidity
event MetricReported(uint64 indexed serviceId, address indexed operator, string metricName, uint256 value);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct MetricReported {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub metricName: alloy::sol_types::private::String,
        #[allow(missing_docs)]
        pub value: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for MetricReported {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::String,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "MetricReported(uint64,address,string,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                35u8, 237u8, 2u8, 189u8, 54u8, 5u8, 189u8, 234u8, 106u8, 138u8, 250u8,
                118u8, 196u8, 111u8, 0u8, 210u8, 116u8, 134u8, 11u8, 166u8, 206u8, 169u8,
                128u8, 242u8, 88u8, 91u8, 105u8, 109u8, 249u8, 225u8, 130u8, 189u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    operator: topics.2,
                    metricName: data.0,
                    value: data.1,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                (
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.metricName,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.value),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.serviceId.clone(),
                    self.operator.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for MetricReported {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&MetricReported> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &MetricReported) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `MetricViolation(uint64,address,string,string)` and selector `0xe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad6315`.
```solidity
event MetricViolation(uint64 indexed serviceId, address indexed operator, string metricName, string reason);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct MetricViolation {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub metricName: alloy::sol_types::private::String,
        #[allow(missing_docs)]
        pub reason: alloy::sol_types::private::String,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for MetricViolation {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::String,
                alloy::sol_types::sol_data::String,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "MetricViolation(uint64,address,string,string)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                224u8, 143u8, 66u8, 137u8, 108u8, 227u8, 174u8, 194u8, 255u8, 125u8,
                169u8, 90u8, 0u8, 55u8, 47u8, 51u8, 207u8, 103u8, 126u8, 117u8, 173u8,
                96u8, 37u8, 144u8, 131u8, 42u8, 141u8, 255u8, 205u8, 173u8, 99u8, 21u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    operator: topics.2,
                    metricName: data.0,
                    reason: data.1,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                (
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.metricName,
                    ),
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.reason,
                    ),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.serviceId.clone(),
                    self.operator.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for MetricViolation {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&MetricViolation> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &MetricViolation) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorCameOnline(uint64,address)` and selector `0xc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c`.
```solidity
event OperatorCameOnline(uint64 indexed serviceId, address indexed operator);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorCameOnline {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for OperatorCameOnline {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorCameOnline(uint64,address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                201u8, 134u8, 44u8, 95u8, 2u8, 238u8, 251u8, 220u8, 234u8, 1u8, 194u8,
                7u8, 174u8, 83u8, 142u8, 29u8, 48u8, 77u8, 201u8, 48u8, 38u8, 135u8,
                15u8, 72u8, 149u8, 30u8, 72u8, 160u8, 244u8, 200u8, 71u8, 12u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    operator: topics.2,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                ()
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.serviceId.clone(),
                    self.operator.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorCameOnline {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorCameOnline> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &OperatorCameOnline) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorDeregistered(uint64,address)` and selector `0x08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e`.
```solidity
event OperatorDeregistered(uint64 indexed serviceId, address indexed operator);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorDeregistered {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for OperatorDeregistered {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorDeregistered(uint64,address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                8u8, 187u8, 147u8, 229u8, 68u8, 66u8, 9u8, 177u8, 81u8, 85u8, 7u8, 138u8,
                19u8, 246u8, 227u8, 65u8, 41u8, 157u8, 116u8, 141u8, 12u8, 41u8, 159u8,
                114u8, 44u8, 156u8, 188u8, 7u8, 35u8, 240u8, 254u8, 158u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    operator: topics.2,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                ()
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.serviceId.clone(),
                    self.operator.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorDeregistered {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorDeregistered> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &OperatorDeregistered) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorRegistered(uint64,address)` and selector `0x8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b`.
```solidity
event OperatorRegistered(uint64 indexed serviceId, address indexed operator);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorRegistered {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for OperatorRegistered {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorRegistered(uint64,address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                142u8, 45u8, 136u8, 121u8, 90u8, 60u8, 102u8, 113u8, 154u8, 40u8, 118u8,
                88u8, 203u8, 246u8, 139u8, 62u8, 178u8, 184u8, 225u8, 131u8, 203u8, 24u8,
                244u8, 111u8, 72u8, 19u8, 145u8, 63u8, 200u8, 170u8, 252u8, 75u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    operator: topics.2,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                ()
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.serviceId.clone(),
                    self.operator.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorRegistered {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorRegistered> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &OperatorRegistered) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorWentOffline(uint64,address,uint8)` and selector `0x44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d`.
```solidity
event OperatorWentOffline(uint64 indexed serviceId, address indexed operator, uint8 missedBeats);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorWentOffline {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub missedBeats: u8,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for OperatorWentOffline {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<8>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorWentOffline(uint64,address,uint8)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                68u8, 253u8, 50u8, 182u8, 119u8, 112u8, 76u8, 230u8, 142u8, 119u8, 99u8,
                137u8, 124u8, 73u8, 115u8, 59u8, 143u8, 82u8, 137u8, 1u8, 138u8, 198u8,
                10u8, 92u8, 146u8, 104u8, 2u8, 214u8, 55u8, 89u8, 219u8, 77u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    operator: topics.2,
                    missedBeats: data.0,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.missedBeats),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.serviceId.clone(),
                    self.operator.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorWentOffline {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorWentOffline> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &OperatorWentOffline) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OwnershipTransferStarted(address,address)` and selector `0x38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e22700`.
```solidity
event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OwnershipTransferStarted {
        #[allow(missing_docs)]
        pub previousOwner: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub newOwner: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for OwnershipTransferStarted {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OwnershipTransferStarted(address,address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                56u8, 209u8, 107u8, 140u8, 172u8, 34u8, 217u8, 159u8, 199u8, 193u8, 36u8,
                185u8, 205u8, 13u8, 226u8, 211u8, 250u8, 31u8, 174u8, 244u8, 32u8, 191u8,
                231u8, 145u8, 216u8, 195u8, 98u8, 215u8, 101u8, 226u8, 39u8, 0u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    previousOwner: topics.1,
                    newOwner: topics.2,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                ()
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.previousOwner.clone(),
                    self.newOwner.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.previousOwner,
                );
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.newOwner,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OwnershipTransferStarted {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OwnershipTransferStarted> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(
                this: &OwnershipTransferStarted,
            ) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OwnershipTransferred(address,address)` and selector `0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0`.
```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OwnershipTransferred {
        #[allow(missing_docs)]
        pub previousOwner: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub newOwner: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for OwnershipTransferred {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OwnershipTransferred(address,address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                139u8, 224u8, 7u8, 156u8, 83u8, 22u8, 89u8, 20u8, 19u8, 68u8, 205u8,
                31u8, 208u8, 164u8, 242u8, 132u8, 25u8, 73u8, 127u8, 151u8, 34u8, 163u8,
                218u8, 175u8, 227u8, 180u8, 24u8, 111u8, 107u8, 100u8, 87u8, 224u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    previousOwner: topics.1,
                    newOwner: topics.2,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                ()
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.previousOwner.clone(),
                    self.newOwner.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.previousOwner,
                );
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.newOwner,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OwnershipTransferred {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OwnershipTransferred> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &OwnershipTransferred) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `SlashingTriggered(uint64,address,string)` and selector `0x1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c791`.
```solidity
event SlashingTriggered(uint64 indexed serviceId, address indexed operator, string reason);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct SlashingTriggered {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub reason: alloy::sol_types::private::String,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for SlashingTriggered {
            type DataTuple<'a> = (alloy::sol_types::sol_data::String,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "SlashingTriggered(uint64,address,string)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                30u8, 41u8, 9u8, 207u8, 69u8, 215u8, 12u8, 240u8, 3u8, 243u8, 52u8,
                183u8, 60u8, 147u8, 51u8, 12u8, 231u8, 229u8, 114u8, 120u8, 45u8, 252u8,
                130u8, 250u8, 183u8, 157u8, 235u8, 136u8, 85u8, 167u8, 199u8, 145u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    operator: topics.2,
                    reason: data.0,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                (
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.reason,
                    ),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.serviceId.clone(),
                    self.operator.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for SlashingTriggered {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&SlashingTriggered> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &SlashingTriggered) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `StatusChanged(uint64,address,uint8,uint8)` and selector `0x228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a09`.
```solidity
event StatusChanged(uint64 indexed serviceId, address indexed operator, IOperatorStatusRegistry.StatusCode oldStatus, IOperatorStatusRegistry.StatusCode newStatus);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct StatusChanged {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub oldStatus: <IOperatorStatusRegistry::StatusCode as alloy::sol_types::SolType>::RustType,
        #[allow(missing_docs)]
        pub newStatus: <IOperatorStatusRegistry::StatusCode as alloy::sol_types::SolType>::RustType,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for StatusChanged {
            type DataTuple<'a> = (
                IOperatorStatusRegistry::StatusCode,
                IOperatorStatusRegistry::StatusCode,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "StatusChanged(uint64,address,uint8,uint8)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                34u8, 136u8, 36u8, 184u8, 108u8, 37u8, 100u8, 105u8, 18u8, 95u8, 82u8,
                92u8, 225u8, 140u8, 108u8, 45u8, 10u8, 158u8, 19u8, 61u8, 19u8, 184u8,
                236u8, 122u8, 44u8, 150u8, 161u8, 147u8, 176u8, 194u8, 138u8, 9u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    serviceId: topics.1,
                    operator: topics.2,
                    oldStatus: data.0,
                    newStatus: data.1,
                }
            }
            #[inline]
            fn check_signature(
                topics: &<Self::TopicList as alloy_sol_types::SolType>::RustType,
            ) -> alloy_sol_types::Result<()> {
                if topics.0 != Self::SIGNATURE_HASH {
                    return Err(
                        alloy_sol_types::Error::invalid_event_signature_hash(
                            Self::SIGNATURE,
                            topics.0,
                            Self::SIGNATURE_HASH,
                        ),
                    );
                }
                Ok(())
            }
            #[inline]
            fn tokenize_body(&self) -> Self::DataToken<'_> {
                (
                    <IOperatorStatusRegistry::StatusCode as alloy_sol_types::SolType>::tokenize(
                        &self.oldStatus,
                    ),
                    <IOperatorStatusRegistry::StatusCode as alloy_sol_types::SolType>::tokenize(
                        &self.newStatus,
                    ),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.serviceId.clone(),
                    self.operator.clone(),
                )
            }
            #[inline]
            fn encode_topics_raw(
                &self,
                out: &mut [alloy_sol_types::abi::token::WordToken],
            ) -> alloy_sol_types::Result<()> {
                if out.len() < <Self::TopicList as alloy_sol_types::TopicList>::COUNT {
                    return Err(alloy_sol_types::Error::Overrun);
                }
                out[0usize] = alloy_sol_types::abi::token::WordToken(
                    Self::SIGNATURE_HASH,
                );
                out[1usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for StatusChanged {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&StatusChanged> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &StatusChanged) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    /**Constructor`.
```solidity
constructor(address _tangleCore, address initialOwner);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct constructorCall {
        #[allow(missing_docs)]
        pub _tangleCore: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub initialOwner: alloy::sol_types::private::Address,
    }
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Address,
                alloy::sol_types::private::Address,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<constructorCall> for UnderlyingRustTuple<'_> {
                fn from(value: constructorCall) -> Self {
                    (value._tangleCore, value.initialOwner)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for constructorCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        _tangleCore: tuple.0,
                        initialOwner: tuple.1,
                    }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolConstructor for constructorCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self._tangleCore,
                    ),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.initialOwner,
                    ),
                )
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `DEFAULT_HEARTBEAT_INTERVAL()` and selector `0x2c957688`.
```solidity
function DEFAULT_HEARTBEAT_INTERVAL() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct DEFAULT_HEARTBEAT_INTERVALCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`DEFAULT_HEARTBEAT_INTERVAL()`](DEFAULT_HEARTBEAT_INTERVALCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct DEFAULT_HEARTBEAT_INTERVALReturn {
        #[allow(missing_docs)]
        pub _0: u64,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<DEFAULT_HEARTBEAT_INTERVALCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: DEFAULT_HEARTBEAT_INTERVALCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for DEFAULT_HEARTBEAT_INTERVALCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<DEFAULT_HEARTBEAT_INTERVALReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: DEFAULT_HEARTBEAT_INTERVALReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for DEFAULT_HEARTBEAT_INTERVALReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for DEFAULT_HEARTBEAT_INTERVALCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "DEFAULT_HEARTBEAT_INTERVAL()";
            const SELECTOR: [u8; 4] = [44u8, 149u8, 118u8, 136u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: DEFAULT_HEARTBEAT_INTERVALReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: DEFAULT_HEARTBEAT_INTERVALReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `DEFAULT_MAX_MISSED_HEARTBEATS()` and selector `0x61d6b86c`.
```solidity
function DEFAULT_MAX_MISSED_HEARTBEATS() external view returns (uint8);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct DEFAULT_MAX_MISSED_HEARTBEATSCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`DEFAULT_MAX_MISSED_HEARTBEATS()`](DEFAULT_MAX_MISSED_HEARTBEATSCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct DEFAULT_MAX_MISSED_HEARTBEATSReturn {
        #[allow(missing_docs)]
        pub _0: u8,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<DEFAULT_MAX_MISSED_HEARTBEATSCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: DEFAULT_MAX_MISSED_HEARTBEATSCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for DEFAULT_MAX_MISSED_HEARTBEATSCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<8>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u8,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<DEFAULT_MAX_MISSED_HEARTBEATSReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: DEFAULT_MAX_MISSED_HEARTBEATSReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for DEFAULT_MAX_MISSED_HEARTBEATSReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for DEFAULT_MAX_MISSED_HEARTBEATSCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u8;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<8>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "DEFAULT_MAX_MISSED_HEARTBEATS()";
            const SELECTOR: [u8; 4] = [97u8, 214u8, 184u8, 108u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: DEFAULT_MAX_MISSED_HEARTBEATSReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: DEFAULT_MAX_MISSED_HEARTBEATSReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `DOMAIN_SEPARATOR()` and selector `0x3644e515`.
```solidity
function DOMAIN_SEPARATOR() external view returns (bytes32);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct DOMAIN_SEPARATORCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`DOMAIN_SEPARATOR()`](DOMAIN_SEPARATORCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct DOMAIN_SEPARATORReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::FixedBytes<32>,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<DOMAIN_SEPARATORCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: DOMAIN_SEPARATORCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for DOMAIN_SEPARATORCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::FixedBytes<32>,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<DOMAIN_SEPARATORReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: DOMAIN_SEPARATORReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for DOMAIN_SEPARATORReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for DOMAIN_SEPARATORCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::FixedBytes<32>;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "DOMAIN_SEPARATOR()";
            const SELECTOR: [u8; 4] = [54u8, 68u8, 229u8, 21u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: DOMAIN_SEPARATORReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: DOMAIN_SEPARATORReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `HEARTBEAT_MAX_AGE()` and selector `0x2f4bd7b8`.
```solidity
function HEARTBEAT_MAX_AGE() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct HEARTBEAT_MAX_AGECall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`HEARTBEAT_MAX_AGE()`](HEARTBEAT_MAX_AGECall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct HEARTBEAT_MAX_AGEReturn {
        #[allow(missing_docs)]
        pub _0: u64,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<HEARTBEAT_MAX_AGECall>
            for UnderlyingRustTuple<'_> {
                fn from(value: HEARTBEAT_MAX_AGECall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for HEARTBEAT_MAX_AGECall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<HEARTBEAT_MAX_AGEReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: HEARTBEAT_MAX_AGEReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for HEARTBEAT_MAX_AGEReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for HEARTBEAT_MAX_AGECall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "HEARTBEAT_MAX_AGE()";
            const SELECTOR: [u8; 4] = [47u8, 75u8, 215u8, 184u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: HEARTBEAT_MAX_AGEReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: HEARTBEAT_MAX_AGEReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `HEARTBEAT_TYPEHASH()` and selector `0xf9f16762`.
```solidity
function HEARTBEAT_TYPEHASH() external view returns (bytes32);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct HEARTBEAT_TYPEHASHCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`HEARTBEAT_TYPEHASH()`](HEARTBEAT_TYPEHASHCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct HEARTBEAT_TYPEHASHReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::FixedBytes<32>,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<HEARTBEAT_TYPEHASHCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: HEARTBEAT_TYPEHASHCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for HEARTBEAT_TYPEHASHCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::FixedBytes<32>,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<HEARTBEAT_TYPEHASHReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: HEARTBEAT_TYPEHASHReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for HEARTBEAT_TYPEHASHReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for HEARTBEAT_TYPEHASHCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::FixedBytes<32>;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "HEARTBEAT_TYPEHASH()";
            const SELECTOR: [u8; 4] = [249u8, 241u8, 103u8, 98u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: HEARTBEAT_TYPEHASHReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: HEARTBEAT_TYPEHASHReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `MAX_METRIC_DEFINITIONS()` and selector `0x6076439c`.
```solidity
function MAX_METRIC_DEFINITIONS() external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MAX_METRIC_DEFINITIONSCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`MAX_METRIC_DEFINITIONS()`](MAX_METRIC_DEFINITIONSCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MAX_METRIC_DEFINITIONSReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MAX_METRIC_DEFINITIONSCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: MAX_METRIC_DEFINITIONSCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MAX_METRIC_DEFINITIONSCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MAX_METRIC_DEFINITIONSReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: MAX_METRIC_DEFINITIONSReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MAX_METRIC_DEFINITIONSReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for MAX_METRIC_DEFINITIONSCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "MAX_METRIC_DEFINITIONS()";
            const SELECTOR: [u8; 4] = [96u8, 118u8, 67u8, 156u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: MAX_METRIC_DEFINITIONSReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: MAX_METRIC_DEFINITIONSReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `MAX_METRIC_NAME_LENGTH()` and selector `0x6bfe06a6`.
```solidity
function MAX_METRIC_NAME_LENGTH() external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MAX_METRIC_NAME_LENGTHCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`MAX_METRIC_NAME_LENGTH()`](MAX_METRIC_NAME_LENGTHCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MAX_METRIC_NAME_LENGTHReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MAX_METRIC_NAME_LENGTHCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: MAX_METRIC_NAME_LENGTHCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MAX_METRIC_NAME_LENGTHCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MAX_METRIC_NAME_LENGTHReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: MAX_METRIC_NAME_LENGTHReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MAX_METRIC_NAME_LENGTHReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for MAX_METRIC_NAME_LENGTHCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "MAX_METRIC_NAME_LENGTH()";
            const SELECTOR: [u8; 4] = [107u8, 254u8, 6u8, 166u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: MAX_METRIC_NAME_LENGTHReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: MAX_METRIC_NAME_LENGTHReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `MAX_PAGE_SIZE()` and selector `0x48f4da20`.
```solidity
function MAX_PAGE_SIZE() external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MAX_PAGE_SIZECall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`MAX_PAGE_SIZE()`](MAX_PAGE_SIZECall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MAX_PAGE_SIZEReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MAX_PAGE_SIZECall> for UnderlyingRustTuple<'_> {
                fn from(value: MAX_PAGE_SIZECall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for MAX_PAGE_SIZECall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MAX_PAGE_SIZEReturn> for UnderlyingRustTuple<'_> {
                fn from(value: MAX_PAGE_SIZEReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for MAX_PAGE_SIZEReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for MAX_PAGE_SIZECall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "MAX_PAGE_SIZE()";
            const SELECTOR: [u8; 4] = [72u8, 244u8, 218u8, 32u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: MAX_PAGE_SIZEReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: MAX_PAGE_SIZEReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `SLASH_ALERT_COOLDOWN()` and selector `0x3ac3cbe6`.
```solidity
function SLASH_ALERT_COOLDOWN() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct SLASH_ALERT_COOLDOWNCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`SLASH_ALERT_COOLDOWN()`](SLASH_ALERT_COOLDOWNCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct SLASH_ALERT_COOLDOWNReturn {
        #[allow(missing_docs)]
        pub _0: u64,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<SLASH_ALERT_COOLDOWNCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: SLASH_ALERT_COOLDOWNCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for SLASH_ALERT_COOLDOWNCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<SLASH_ALERT_COOLDOWNReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: SLASH_ALERT_COOLDOWNReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for SLASH_ALERT_COOLDOWNReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for SLASH_ALERT_COOLDOWNCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "SLASH_ALERT_COOLDOWN()";
            const SELECTOR: [u8; 4] = [58u8, 195u8, 203u8, 230u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: SLASH_ALERT_COOLDOWNReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: SLASH_ALERT_COOLDOWNReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `acceptOwnership()` and selector `0x79ba5097`.
```solidity
function acceptOwnership() external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct acceptOwnershipCall;
    ///Container type for the return parameters of the [`acceptOwnership()`](acceptOwnershipCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct acceptOwnershipReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<acceptOwnershipCall> for UnderlyingRustTuple<'_> {
                fn from(value: acceptOwnershipCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for acceptOwnershipCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<acceptOwnershipReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: acceptOwnershipReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for acceptOwnershipReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl acceptOwnershipReturn {
            fn _tokenize(
                &self,
            ) -> <acceptOwnershipCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for acceptOwnershipCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = acceptOwnershipReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "acceptOwnership()";
            const SELECTOR: [u8; 4] = [121u8, 186u8, 80u8, 151u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                acceptOwnershipReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `addMetricDefinition(uint64,string,uint256,uint256,bool)` and selector `0xae470a85`.
```solidity
function addMetricDefinition(uint64 serviceId, string memory name, uint256 minValue, uint256 maxValue, bool required) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct addMetricDefinitionCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub name: alloy::sol_types::private::String,
        #[allow(missing_docs)]
        pub minValue: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub maxValue: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub required: bool,
    }
    ///Container type for the return parameters of the [`addMetricDefinition(uint64,string,uint256,uint256,bool)`](addMetricDefinitionCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct addMetricDefinitionReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::String,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Bool,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::String,
                alloy::sol_types::private::primitives::aliases::U256,
                alloy::sol_types::private::primitives::aliases::U256,
                bool,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<addMetricDefinitionCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: addMetricDefinitionCall) -> Self {
                    (
                        value.serviceId,
                        value.name,
                        value.minValue,
                        value.maxValue,
                        value.required,
                    )
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for addMetricDefinitionCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        name: tuple.1,
                        minValue: tuple.2,
                        maxValue: tuple.3,
                        required: tuple.4,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<addMetricDefinitionReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: addMetricDefinitionReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for addMetricDefinitionReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl addMetricDefinitionReturn {
            fn _tokenize(
                &self,
            ) -> <addMetricDefinitionCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for addMetricDefinitionCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::String,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Bool,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = addMetricDefinitionReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "addMetricDefinition(uint64,string,uint256,uint256,bool)";
            const SELECTOR: [u8; 4] = [174u8, 71u8, 10u8, 133u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.name,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.minValue),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.maxValue),
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        &self.required,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                addMetricDefinitionReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `checkOperatorStatus(uint64,address)` and selector `0xba1fb103`.
```solidity
function checkOperatorStatus(uint64 serviceId, address operator) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct checkOperatorStatusCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`checkOperatorStatus(uint64,address)`](checkOperatorStatusCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct checkOperatorStatusReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<checkOperatorStatusCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: checkOperatorStatusCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for checkOperatorStatusCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<checkOperatorStatusReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: checkOperatorStatusReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for checkOperatorStatusReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl checkOperatorStatusReturn {
            fn _tokenize(
                &self,
            ) -> <checkOperatorStatusCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for checkOperatorStatusCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = checkOperatorStatusReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "checkOperatorStatus(uint64,address)";
            const SELECTOR: [u8; 4] = [186u8, 31u8, 177u8, 3u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                checkOperatorStatusReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `checkOperatorsStatus(uint64,address[])` and selector `0x96686c1e`.
```solidity
function checkOperatorsStatus(uint64 serviceId, address[] memory operators) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct checkOperatorsStatusCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operators: alloy::sol_types::private::Vec<
            alloy::sol_types::private::Address,
        >,
    }
    ///Container type for the return parameters of the [`checkOperatorsStatus(uint64,address[])`](checkOperatorsStatusCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct checkOperatorsStatusReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Address>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::Vec<alloy::sol_types::private::Address>,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<checkOperatorsStatusCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: checkOperatorsStatusCall) -> Self {
                    (value.serviceId, value.operators)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for checkOperatorsStatusCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operators: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<checkOperatorsStatusReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: checkOperatorsStatusReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for checkOperatorsStatusReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl checkOperatorsStatusReturn {
            fn _tokenize(
                &self,
            ) -> <checkOperatorsStatusCall as alloy_sol_types::SolCall>::ReturnToken<
                '_,
            > {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for checkOperatorsStatusCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Address>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = checkOperatorsStatusReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "checkOperatorsStatus(uint64,address[])";
            const SELECTOR: [u8; 4] = [150u8, 104u8, 108u8, 30u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Array<
                        alloy::sol_types::sol_data::Address,
                    > as alloy_sol_types::SolType>::tokenize(&self.operators),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                checkOperatorsStatusReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `configureHeartbeat(uint64,uint64,uint8)` and selector `0xb99f6759`.
```solidity
function configureHeartbeat(uint64 serviceId, uint64 interval, uint8 maxMissed) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct configureHeartbeatCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub interval: u64,
        #[allow(missing_docs)]
        pub maxMissed: u8,
    }
    ///Container type for the return parameters of the [`configureHeartbeat(uint64,uint64,uint8)`](configureHeartbeatCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct configureHeartbeatReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, u64, u8);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<configureHeartbeatCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: configureHeartbeatCall) -> Self {
                    (value.serviceId, value.interval, value.maxMissed)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for configureHeartbeatCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        interval: tuple.1,
                        maxMissed: tuple.2,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<configureHeartbeatReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: configureHeartbeatReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for configureHeartbeatReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl configureHeartbeatReturn {
            fn _tokenize(
                &self,
            ) -> <configureHeartbeatCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for configureHeartbeatCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = configureHeartbeatReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "configureHeartbeat(uint64,uint64,uint8)";
            const SELECTOR: [u8; 4] = [185u8, 159u8, 103u8, 89u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.interval),
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.maxMissed),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                configureHeartbeatReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `decodeMetricPairs(bytes)` and selector `0x31e3bd1b`.
```solidity
function decodeMetricPairs(bytes memory payload) external pure returns (IOperatorStatusRegistry.MetricPair[] memory pairs);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct decodeMetricPairsCall {
        #[allow(missing_docs)]
        pub payload: alloy::sol_types::private::Bytes,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`decodeMetricPairs(bytes)`](decodeMetricPairsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct decodeMetricPairsReturn {
        #[allow(missing_docs)]
        pub pairs: alloy::sol_types::private::Vec<
            <IOperatorStatusRegistry::MetricPair as alloy::sol_types::SolType>::RustType,
        >,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Bytes,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Bytes,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<decodeMetricPairsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: decodeMetricPairsCall) -> Self {
                    (value.payload,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for decodeMetricPairsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { payload: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Array<IOperatorStatusRegistry::MetricPair>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Vec<
                    <IOperatorStatusRegistry::MetricPair as alloy::sol_types::SolType>::RustType,
                >,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<decodeMetricPairsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: decodeMetricPairsReturn) -> Self {
                    (value.pairs,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for decodeMetricPairsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { pairs: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for decodeMetricPairsCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Bytes,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Vec<
                <IOperatorStatusRegistry::MetricPair as alloy::sol_types::SolType>::RustType,
            >;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Array<IOperatorStatusRegistry::MetricPair>,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "decodeMetricPairs(bytes)";
            const SELECTOR: [u8; 4] = [49u8, 227u8, 189u8, 27u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Bytes as alloy_sol_types::SolType>::tokenize(
                        &self.payload,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Array<
                        IOperatorStatusRegistry::MetricPair,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: decodeMetricPairsReturn = r.into();
                        r.pairs
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: decodeMetricPairsReturn = r.into();
                        r.pairs
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `deregisterOperator(uint64,address)` and selector `0xffcf08f0`.
```solidity
function deregisterOperator(uint64 serviceId, address operator) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct deregisterOperatorCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`deregisterOperator(uint64,address)`](deregisterOperatorCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct deregisterOperatorReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<deregisterOperatorCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: deregisterOperatorCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for deregisterOperatorCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<deregisterOperatorReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: deregisterOperatorReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for deregisterOperatorReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl deregisterOperatorReturn {
            fn _tokenize(
                &self,
            ) -> <deregisterOperatorCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for deregisterOperatorCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = deregisterOperatorReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "deregisterOperator(uint64,address)";
            const SELECTOR: [u8; 4] = [255u8, 207u8, 8u8, 240u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                deregisterOperatorReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `enableCustomMetrics(uint64,bool)` and selector `0xf9107f3b`.
```solidity
function enableCustomMetrics(uint64 serviceId, bool enabled) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct enableCustomMetricsCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub enabled: bool,
    }
    ///Container type for the return parameters of the [`enableCustomMetrics(uint64,bool)`](enableCustomMetricsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct enableCustomMetricsReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Bool,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, bool);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<enableCustomMetricsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: enableCustomMetricsCall) -> Self {
                    (value.serviceId, value.enabled)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for enableCustomMetricsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        enabled: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<enableCustomMetricsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: enableCustomMetricsReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for enableCustomMetricsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl enableCustomMetricsReturn {
            fn _tokenize(
                &self,
            ) -> <enableCustomMetricsCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for enableCustomMetricsCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Bool,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = enableCustomMetricsReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "enableCustomMetrics(uint64,bool)";
            const SELECTOR: [u8; 4] = [249u8, 16u8, 127u8, 59u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        &self.enabled,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                enableCustomMetricsReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getAllOperatorCount(uint64)` and selector `0x3fd62c6d`.
```solidity
function getAllOperatorCount(uint64 serviceId) external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getAllOperatorCountCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getAllOperatorCount(uint64)`](getAllOperatorCountCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getAllOperatorCountReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getAllOperatorCountCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getAllOperatorCountCall) -> Self {
                    (value.serviceId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getAllOperatorCountCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { serviceId: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getAllOperatorCountReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getAllOperatorCountReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getAllOperatorCountReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getAllOperatorCountCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getAllOperatorCount(uint64)";
            const SELECTOR: [u8; 4] = [63u8, 214u8, 44u8, 109u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getAllOperatorCountReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getAllOperatorCountReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getHeartbeatConfig(uint64)` and selector `0x0758236f`.
```solidity
function getHeartbeatConfig(uint64 serviceId) external view returns (IOperatorStatusRegistry.HeartbeatConfig memory);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getHeartbeatConfigCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getHeartbeatConfig(uint64)`](getHeartbeatConfigCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getHeartbeatConfigReturn {
        #[allow(missing_docs)]
        pub _0: <IOperatorStatusRegistry::HeartbeatConfig as alloy::sol_types::SolType>::RustType,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getHeartbeatConfigCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getHeartbeatConfigCall) -> Self {
                    (value.serviceId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getHeartbeatConfigCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { serviceId: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (IOperatorStatusRegistry::HeartbeatConfig,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                <IOperatorStatusRegistry::HeartbeatConfig as alloy::sol_types::SolType>::RustType,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getHeartbeatConfigReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getHeartbeatConfigReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getHeartbeatConfigReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getHeartbeatConfigCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = <IOperatorStatusRegistry::HeartbeatConfig as alloy::sol_types::SolType>::RustType;
            type ReturnTuple<'a> = (IOperatorStatusRegistry::HeartbeatConfig,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getHeartbeatConfig(uint64)";
            const SELECTOR: [u8; 4] = [7u8, 88u8, 35u8, 111u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <IOperatorStatusRegistry::HeartbeatConfig as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getHeartbeatConfigReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getHeartbeatConfigReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getLastCriticalHeartbeat(uint64,address)` and selector `0x7639d227`.
```solidity
function getLastCriticalHeartbeat(uint64 serviceId, address operator) external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getLastCriticalHeartbeatCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getLastCriticalHeartbeat(uint64,address)`](getLastCriticalHeartbeatCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getLastCriticalHeartbeatReturn {
        #[allow(missing_docs)]
        pub _0: u64,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getLastCriticalHeartbeatCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getLastCriticalHeartbeatCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getLastCriticalHeartbeatCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getLastCriticalHeartbeatReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getLastCriticalHeartbeatReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getLastCriticalHeartbeatReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getLastCriticalHeartbeatCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getLastCriticalHeartbeat(uint64,address)";
            const SELECTOR: [u8; 4] = [118u8, 57u8, 210u8, 39u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getLastCriticalHeartbeatReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getLastCriticalHeartbeatReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getLastHeartbeat(uint64,address)` and selector `0x0c76697a`.
```solidity
function getLastHeartbeat(uint64 serviceId, address operator) external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getLastHeartbeatCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getLastHeartbeat(uint64,address)`](getLastHeartbeatCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getLastHeartbeatReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getLastHeartbeatCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getLastHeartbeatCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getLastHeartbeatCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getLastHeartbeatReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getLastHeartbeatReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getLastHeartbeatReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getLastHeartbeatCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getLastHeartbeat(uint64,address)";
            const SELECTOR: [u8; 4] = [12u8, 118u8, 105u8, 122u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getLastHeartbeatReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getLastHeartbeatReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getMetricDefinitions(uint64)` and selector `0xc1ef9ddf`.
```solidity
function getMetricDefinitions(uint64 serviceId) external view returns (IOperatorStatusRegistry.MetricDefinition[] memory);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getMetricDefinitionsCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getMetricDefinitions(uint64)`](getMetricDefinitionsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getMetricDefinitionsReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::Vec<
            <IOperatorStatusRegistry::MetricDefinition as alloy::sol_types::SolType>::RustType,
        >,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getMetricDefinitionsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getMetricDefinitionsCall) -> Self {
                    (value.serviceId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getMetricDefinitionsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { serviceId: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Array<
                    IOperatorStatusRegistry::MetricDefinition,
                >,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Vec<
                    <IOperatorStatusRegistry::MetricDefinition as alloy::sol_types::SolType>::RustType,
                >,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getMetricDefinitionsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getMetricDefinitionsReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getMetricDefinitionsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getMetricDefinitionsCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Vec<
                <IOperatorStatusRegistry::MetricDefinition as alloy::sol_types::SolType>::RustType,
            >;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Array<
                    IOperatorStatusRegistry::MetricDefinition,
                >,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getMetricDefinitions(uint64)";
            const SELECTOR: [u8; 4] = [193u8, 239u8, 157u8, 223u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Array<
                        IOperatorStatusRegistry::MetricDefinition,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getMetricDefinitionsReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getMetricDefinitionsReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getMetricValue(uint64,address,string)` and selector `0xd551162c`.
```solidity
function getMetricValue(uint64 serviceId, address operator, string memory metricName) external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getMetricValueCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub metricName: alloy::sol_types::private::String,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getMetricValue(uint64,address,string)`](getMetricValueCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getMetricValueReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::String,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::Address,
                alloy::sol_types::private::String,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getMetricValueCall> for UnderlyingRustTuple<'_> {
                fn from(value: getMetricValueCall) -> Self {
                    (value.serviceId, value.operator, value.metricName)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getMetricValueCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                        metricName: tuple.2,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getMetricValueReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getMetricValueReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getMetricValueReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getMetricValueCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::String,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getMetricValue(uint64,address,string)";
            const SELECTOR: [u8; 4] = [213u8, 81u8, 22u8, 44u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.metricName,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getMetricValueReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getMetricValueReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getOnlineOperatorCount(uint64)` and selector `0x7b9f64b2`.
```solidity
function getOnlineOperatorCount(uint64 serviceId) external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOnlineOperatorCountCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getOnlineOperatorCount(uint64)`](getOnlineOperatorCountCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOnlineOperatorCountReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getOnlineOperatorCountCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOnlineOperatorCountCall) -> Self {
                    (value.serviceId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOnlineOperatorCountCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { serviceId: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getOnlineOperatorCountReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOnlineOperatorCountReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOnlineOperatorCountReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getOnlineOperatorCountCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getOnlineOperatorCount(uint64)";
            const SELECTOR: [u8; 4] = [123u8, 159u8, 100u8, 178u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getOnlineOperatorCountReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getOnlineOperatorCountReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getOnlineOperators(uint64)` and selector `0x40235a9c`.
```solidity
function getOnlineOperators(uint64 serviceId) external view returns (address[] memory);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOnlineOperatorsCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getOnlineOperators(uint64)`](getOnlineOperatorsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOnlineOperatorsReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::Vec<alloy::sol_types::private::Address>,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getOnlineOperatorsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOnlineOperatorsCall) -> Self {
                    (value.serviceId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOnlineOperatorsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { serviceId: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Address>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Vec<alloy::sol_types::private::Address>,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getOnlineOperatorsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOnlineOperatorsReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOnlineOperatorsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getOnlineOperatorsCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Vec<
                alloy::sol_types::private::Address,
            >;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Address>,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getOnlineOperators(uint64)";
            const SELECTOR: [u8; 4] = [64u8, 35u8, 90u8, 156u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Array<
                        alloy::sol_types::sol_data::Address,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getOnlineOperatorsReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getOnlineOperatorsReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getOperatorState(uint64,address)` and selector `0x71e7388c`.
```solidity
function getOperatorState(uint64 serviceId, address operator) external view returns (IOperatorStatusRegistry.OperatorState memory);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOperatorStateCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive()]
    ///Container type for the return parameters of the [`getOperatorState(uint64,address)`](getOperatorStateCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOperatorStateReturn {
        #[allow(missing_docs)]
        pub _0: <IOperatorStatusRegistry::OperatorState as alloy::sol_types::SolType>::RustType,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getOperatorStateCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOperatorStateCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOperatorStateCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (IOperatorStatusRegistry::OperatorState,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                <IOperatorStatusRegistry::OperatorState as alloy::sol_types::SolType>::RustType,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getOperatorStateReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOperatorStateReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOperatorStateReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getOperatorStateCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = <IOperatorStatusRegistry::OperatorState as alloy::sol_types::SolType>::RustType;
            type ReturnTuple<'a> = (IOperatorStatusRegistry::OperatorState,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getOperatorState(uint64,address)";
            const SELECTOR: [u8; 4] = [113u8, 231u8, 56u8, 140u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <IOperatorStatusRegistry::OperatorState as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getOperatorStateReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getOperatorStateReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getOperatorStatus(uint64,address)` and selector `0x62c7e8fc`.
```solidity
function getOperatorStatus(uint64 serviceId, address operator) external view returns (IOperatorStatusRegistry.StatusCode);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOperatorStatusCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getOperatorStatus(uint64,address)`](getOperatorStatusCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOperatorStatusReturn {
        #[allow(missing_docs)]
        pub _0: <IOperatorStatusRegistry::StatusCode as alloy::sol_types::SolType>::RustType,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getOperatorStatusCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOperatorStatusCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOperatorStatusCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (IOperatorStatusRegistry::StatusCode,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                <IOperatorStatusRegistry::StatusCode as alloy::sol_types::SolType>::RustType,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getOperatorStatusReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOperatorStatusReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOperatorStatusReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getOperatorStatusCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = <IOperatorStatusRegistry::StatusCode as alloy::sol_types::SolType>::RustType;
            type ReturnTuple<'a> = (IOperatorStatusRegistry::StatusCode,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getOperatorStatus(uint64,address)";
            const SELECTOR: [u8; 4] = [98u8, 199u8, 232u8, 252u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <IOperatorStatusRegistry::StatusCode as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getOperatorStatusReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getOperatorStatusReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getSlashableOperators(uint64)` and selector `0x59dcea12`.
```solidity
function getSlashableOperators(uint64 serviceId) external view returns (address[] memory operators);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashableOperatorsCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getSlashableOperators(uint64)`](getSlashableOperatorsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashableOperatorsReturn {
        #[allow(missing_docs)]
        pub operators: alloy::sol_types::private::Vec<
            alloy::sol_types::private::Address,
        >,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getSlashableOperatorsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashableOperatorsCall) -> Self {
                    (value.serviceId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashableOperatorsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { serviceId: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Address>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Vec<alloy::sol_types::private::Address>,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getSlashableOperatorsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashableOperatorsReturn) -> Self {
                    (value.operators,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashableOperatorsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { operators: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getSlashableOperatorsCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Vec<
                alloy::sol_types::private::Address,
            >;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Address>,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getSlashableOperators(uint64)";
            const SELECTOR: [u8; 4] = [89u8, 220u8, 234u8, 18u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Array<
                        alloy::sol_types::sol_data::Address,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getSlashableOperatorsReturn = r.into();
                        r.operators
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: getSlashableOperatorsReturn = r.into();
                        r.operators
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getSlashableOperatorsPaginated(uint64,uint256,uint256)` and selector `0x81beac2e`.
```solidity
function getSlashableOperatorsPaginated(uint64 serviceId, uint256 offset, uint256 limit) external view returns (address[] memory operators, uint256 total);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashableOperatorsPaginatedCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub offset: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub limit: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getSlashableOperatorsPaginated(uint64,uint256,uint256)`](getSlashableOperatorsPaginatedCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashableOperatorsPaginatedReturn {
        #[allow(missing_docs)]
        pub operators: alloy::sol_types::private::Vec<
            alloy::sol_types::private::Address,
        >,
        #[allow(missing_docs)]
        pub total: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::primitives::aliases::U256,
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getSlashableOperatorsPaginatedCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashableOperatorsPaginatedCall) -> Self {
                    (value.serviceId, value.offset, value.limit)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashableOperatorsPaginatedCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        offset: tuple.1,
                        limit: tuple.2,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Address>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Vec<alloy::sol_types::private::Address>,
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getSlashableOperatorsPaginatedReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashableOperatorsPaginatedReturn) -> Self {
                    (value.operators, value.total)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashableOperatorsPaginatedReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        operators: tuple.0,
                        total: tuple.1,
                    }
                }
            }
        }
        impl getSlashableOperatorsPaginatedReturn {
            fn _tokenize(
                &self,
            ) -> <getSlashableOperatorsPaginatedCall as alloy_sol_types::SolCall>::ReturnToken<
                '_,
            > {
                (
                    <alloy::sol_types::sol_data::Array<
                        alloy::sol_types::sol_data::Address,
                    > as alloy_sol_types::SolType>::tokenize(&self.operators),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.total),
                )
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getSlashableOperatorsPaginatedCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = getSlashableOperatorsPaginatedReturn;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Address>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getSlashableOperatorsPaginated(uint64,uint256,uint256)";
            const SELECTOR: [u8; 4] = [129u8, 190u8, 172u8, 46u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.offset),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.limit),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                getSlashableOperatorsPaginatedReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `goOffline(uint64)` and selector `0xc5d960bb`.
```solidity
function goOffline(uint64 serviceId) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct goOfflineCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
    }
    ///Container type for the return parameters of the [`goOffline(uint64)`](goOfflineCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct goOfflineReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<goOfflineCall> for UnderlyingRustTuple<'_> {
                fn from(value: goOfflineCall) -> Self {
                    (value.serviceId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for goOfflineCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { serviceId: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<goOfflineReturn> for UnderlyingRustTuple<'_> {
                fn from(value: goOfflineReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for goOfflineReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl goOfflineReturn {
            fn _tokenize(
                &self,
            ) -> <goOfflineCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for goOfflineCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = goOfflineReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "goOffline(uint64)";
            const SELECTOR: [u8; 4] = [197u8, 217u8, 96u8, 187u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                goOfflineReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `goOnline(uint64)` and selector `0xb074e9dd`.
```solidity
function goOnline(uint64 serviceId) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct goOnlineCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
    }
    ///Container type for the return parameters of the [`goOnline(uint64)`](goOnlineCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct goOnlineReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<goOnlineCall> for UnderlyingRustTuple<'_> {
                fn from(value: goOnlineCall) -> Self {
                    (value.serviceId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for goOnlineCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { serviceId: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<goOnlineReturn> for UnderlyingRustTuple<'_> {
                fn from(value: goOnlineReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for goOnlineReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl goOnlineReturn {
            fn _tokenize(
                &self,
            ) -> <goOnlineCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for goOnlineCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = goOnlineReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "goOnline(uint64)";
            const SELECTOR: [u8; 4] = [176u8, 116u8, 233u8, 221u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                goOnlineReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `heartbeatConfigs(uint64)` and selector `0xda435a7c`.
```solidity
function heartbeatConfigs(uint64) external view returns (uint64 interval, uint8 maxMissed, bool customMetrics);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct heartbeatConfigsCall(pub u64);
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`heartbeatConfigs(uint64)`](heartbeatConfigsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct heartbeatConfigsReturn {
        #[allow(missing_docs)]
        pub interval: u64,
        #[allow(missing_docs)]
        pub maxMissed: u8,
        #[allow(missing_docs)]
        pub customMetrics: bool,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<heartbeatConfigsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: heartbeatConfigsCall) -> Self {
                    (value.0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for heartbeatConfigsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self(tuple.0)
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
                alloy::sol_types::sol_data::Bool,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, u8, bool);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<heartbeatConfigsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: heartbeatConfigsReturn) -> Self {
                    (value.interval, value.maxMissed, value.customMetrics)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for heartbeatConfigsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        interval: tuple.0,
                        maxMissed: tuple.1,
                        customMetrics: tuple.2,
                    }
                }
            }
        }
        impl heartbeatConfigsReturn {
            fn _tokenize(
                &self,
            ) -> <heartbeatConfigsCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.interval),
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.maxMissed),
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        &self.customMetrics,
                    ),
                )
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for heartbeatConfigsCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = heartbeatConfigsReturn;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
                alloy::sol_types::sol_data::Bool,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "heartbeatConfigs(uint64)";
            const SELECTOR: [u8; 4] = [218u8, 67u8, 90u8, 124u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.0),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                heartbeatConfigsReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `isHeartbeatCurrent(uint64,address)` and selector `0xee1c0390`.
```solidity
function isHeartbeatCurrent(uint64 serviceId, address operator) external view returns (bool);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct isHeartbeatCurrentCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`isHeartbeatCurrent(uint64,address)`](isHeartbeatCurrentCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct isHeartbeatCurrentReturn {
        #[allow(missing_docs)]
        pub _0: bool,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<isHeartbeatCurrentCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: isHeartbeatCurrentCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for isHeartbeatCurrentCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (bool,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<isHeartbeatCurrentReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: isHeartbeatCurrentReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for isHeartbeatCurrentReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for isHeartbeatCurrentCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = bool;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "isHeartbeatCurrent(uint64,address)";
            const SELECTOR: [u8; 4] = [238u8, 28u8, 3u8, 144u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: isHeartbeatCurrentReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: isHeartbeatCurrentReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `isOnline(uint64,address)` and selector `0x5685cf68`.
```solidity
function isOnline(uint64 serviceId, address operator) external view returns (bool);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct isOnlineCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`isOnline(uint64,address)`](isOnlineCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct isOnlineReturn {
        #[allow(missing_docs)]
        pub _0: bool,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<isOnlineCall> for UnderlyingRustTuple<'_> {
                fn from(value: isOnlineCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for isOnlineCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (bool,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<isOnlineReturn> for UnderlyingRustTuple<'_> {
                fn from(value: isOnlineReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for isOnlineReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for isOnlineCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = bool;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "isOnline(uint64,address)";
            const SELECTOR: [u8; 4] = [86u8, 133u8, 207u8, 104u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: isOnlineReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: isOnlineReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `isRegisteredOperator(uint64,address)` and selector `0x60cf0991`.
```solidity
function isRegisteredOperator(uint64 serviceId, address operator) external view returns (bool);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct isRegisteredOperatorCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`isRegisteredOperator(uint64,address)`](isRegisteredOperatorCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct isRegisteredOperatorReturn {
        #[allow(missing_docs)]
        pub _0: bool,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<isRegisteredOperatorCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: isRegisteredOperatorCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for isRegisteredOperatorCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (bool,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<isRegisteredOperatorReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: isRegisteredOperatorReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for isRegisteredOperatorReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for isRegisteredOperatorCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = bool;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "isRegisteredOperator(uint64,address)";
            const SELECTOR: [u8; 4] = [96u8, 207u8, 9u8, 145u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: isRegisteredOperatorReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: isRegisteredOperatorReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `metricValues(uint64,address,string)` and selector `0x9cbdae22`.
```solidity
function metricValues(uint64, address, string memory) external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct metricValuesCall {
        #[allow(missing_docs)]
        pub _0: u64,
        #[allow(missing_docs)]
        pub _1: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub _2: alloy::sol_types::private::String,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`metricValues(uint64,address,string)`](metricValuesCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct metricValuesReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::String,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::Address,
                alloy::sol_types::private::String,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<metricValuesCall> for UnderlyingRustTuple<'_> {
                fn from(value: metricValuesCall) -> Self {
                    (value._0, value._1, value._2)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for metricValuesCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        _0: tuple.0,
                        _1: tuple.1,
                        _2: tuple.2,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<metricValuesReturn> for UnderlyingRustTuple<'_> {
                fn from(value: metricValuesReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for metricValuesReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for metricValuesCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::String,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "metricValues(uint64,address,string)";
            const SELECTOR: [u8; 4] = [156u8, 189u8, 174u8, 34u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self._0),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self._1,
                    ),
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self._2,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: metricValuesReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: metricValuesReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `metricsRecorder()` and selector `0x2dae1885`.
```solidity
function metricsRecorder() external view returns (address);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct metricsRecorderCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`metricsRecorder()`](metricsRecorderCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct metricsRecorderReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<metricsRecorderCall> for UnderlyingRustTuple<'_> {
                fn from(value: metricsRecorderCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for metricsRecorderCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<metricsRecorderReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: metricsRecorderReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for metricsRecorderReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for metricsRecorderCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Address;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "metricsRecorder()";
            const SELECTOR: [u8; 4] = [45u8, 174u8, 24u8, 133u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: metricsRecorderReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: metricsRecorderReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `operatorStates(uint64,address)` and selector `0x3e6e34a7`.
```solidity
function operatorStates(uint64, address) external view returns (uint256 lastHeartbeat, uint64 consecutiveBeats, uint8 missedBeats, IOperatorStatusRegistry.StatusCode status, bytes32 lastMetricsHash);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct operatorStatesCall {
        #[allow(missing_docs)]
        pub _0: u64,
        #[allow(missing_docs)]
        pub _1: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`operatorStates(uint64,address)`](operatorStatesCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct operatorStatesReturn {
        #[allow(missing_docs)]
        pub lastHeartbeat: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub consecutiveBeats: u64,
        #[allow(missing_docs)]
        pub missedBeats: u8,
        #[allow(missing_docs)]
        pub status: <IOperatorStatusRegistry::StatusCode as alloy::sol_types::SolType>::RustType,
        #[allow(missing_docs)]
        pub lastMetricsHash: alloy::sol_types::private::FixedBytes<32>,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<operatorStatesCall> for UnderlyingRustTuple<'_> {
                fn from(value: operatorStatesCall) -> Self {
                    (value._0, value._1)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for operatorStatesCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0, _1: tuple.1 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
                IOperatorStatusRegistry::StatusCode,
                alloy::sol_types::sol_data::FixedBytes<32>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::primitives::aliases::U256,
                u64,
                u8,
                <IOperatorStatusRegistry::StatusCode as alloy::sol_types::SolType>::RustType,
                alloy::sol_types::private::FixedBytes<32>,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<operatorStatesReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: operatorStatesReturn) -> Self {
                    (
                        value.lastHeartbeat,
                        value.consecutiveBeats,
                        value.missedBeats,
                        value.status,
                        value.lastMetricsHash,
                    )
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for operatorStatesReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        lastHeartbeat: tuple.0,
                        consecutiveBeats: tuple.1,
                        missedBeats: tuple.2,
                        status: tuple.3,
                        lastMetricsHash: tuple.4,
                    }
                }
            }
        }
        impl operatorStatesReturn {
            fn _tokenize(
                &self,
            ) -> <operatorStatesCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.lastHeartbeat),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.consecutiveBeats),
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.missedBeats),
                    <IOperatorStatusRegistry::StatusCode as alloy_sol_types::SolType>::tokenize(
                        &self.status,
                    ),
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(&self.lastMetricsHash),
                )
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for operatorStatesCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = operatorStatesReturn;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
                IOperatorStatusRegistry::StatusCode,
                alloy::sol_types::sol_data::FixedBytes<32>,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "operatorStates(uint64,address)";
            const SELECTOR: [u8; 4] = [62u8, 110u8, 52u8, 167u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self._0),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self._1,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                operatorStatesReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `owner()` and selector `0x8da5cb5b`.
```solidity
function owner() external view returns (address);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ownerCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`owner()`](ownerCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ownerReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<ownerCall> for UnderlyingRustTuple<'_> {
                fn from(value: ownerCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for ownerCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<ownerReturn> for UnderlyingRustTuple<'_> {
                fn from(value: ownerReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for ownerReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for ownerCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Address;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "owner()";
            const SELECTOR: [u8; 4] = [141u8, 165u8, 203u8, 91u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: ownerReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: ownerReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `pendingOwner()` and selector `0xe30c3978`.
```solidity
function pendingOwner() external view returns (address);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct pendingOwnerCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`pendingOwner()`](pendingOwnerCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct pendingOwnerReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<pendingOwnerCall> for UnderlyingRustTuple<'_> {
                fn from(value: pendingOwnerCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for pendingOwnerCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<pendingOwnerReturn> for UnderlyingRustTuple<'_> {
                fn from(value: pendingOwnerReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for pendingOwnerReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for pendingOwnerCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Address;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "pendingOwner()";
            const SELECTOR: [u8; 4] = [227u8, 12u8, 57u8, 120u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: pendingOwnerReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: pendingOwnerReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `registerOperator(uint64,address)` and selector `0x1e8f5ee5`.
```solidity
function registerOperator(uint64 serviceId, address operator) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct registerOperatorCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`registerOperator(uint64,address)`](registerOperatorCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct registerOperatorReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<registerOperatorCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: registerOperatorCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for registerOperatorCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<registerOperatorReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: registerOperatorReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for registerOperatorReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl registerOperatorReturn {
            fn _tokenize(
                &self,
            ) -> <registerOperatorCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for registerOperatorCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = registerOperatorReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "registerOperator(uint64,address)";
            const SELECTOR: [u8; 4] = [30u8, 143u8, 94u8, 229u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                registerOperatorReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `registerServiceOwner(uint64,address)` and selector `0x05778550`.
```solidity
function registerServiceOwner(uint64 serviceId, address owner) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct registerServiceOwnerCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub owner: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`registerServiceOwner(uint64,address)`](registerServiceOwnerCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct registerServiceOwnerReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<registerServiceOwnerCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: registerServiceOwnerCall) -> Self {
                    (value.serviceId, value.owner)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for registerServiceOwnerCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        owner: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<registerServiceOwnerReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: registerServiceOwnerReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for registerServiceOwnerReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl registerServiceOwnerReturn {
            fn _tokenize(
                &self,
            ) -> <registerServiceOwnerCall as alloy_sol_types::SolCall>::ReturnToken<
                '_,
            > {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for registerServiceOwnerCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = registerServiceOwnerReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "registerServiceOwner(uint64,address)";
            const SELECTOR: [u8; 4] = [5u8, 119u8, 133u8, 80u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.owner,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                registerServiceOwnerReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `removeInactiveOperator(uint64,address)` and selector `0xe65cafcb`.
```solidity
function removeInactiveOperator(uint64 serviceId, address operator) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct removeInactiveOperatorCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`removeInactiveOperator(uint64,address)`](removeInactiveOperatorCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct removeInactiveOperatorReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::Address);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<removeInactiveOperatorCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: removeInactiveOperatorCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for removeInactiveOperatorCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<removeInactiveOperatorReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: removeInactiveOperatorReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for removeInactiveOperatorReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl removeInactiveOperatorReturn {
            fn _tokenize(
                &self,
            ) -> <removeInactiveOperatorCall as alloy_sol_types::SolCall>::ReturnToken<
                '_,
            > {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for removeInactiveOperatorCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = removeInactiveOperatorReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "removeInactiveOperator(uint64,address)";
            const SELECTOR: [u8; 4] = [230u8, 92u8, 175u8, 203u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                removeInactiveOperatorReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `renounceOwnership()` and selector `0x715018a6`.
```solidity
function renounceOwnership() external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct renounceOwnershipCall;
    ///Container type for the return parameters of the [`renounceOwnership()`](renounceOwnershipCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct renounceOwnershipReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<renounceOwnershipCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: renounceOwnershipCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for renounceOwnershipCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<renounceOwnershipReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: renounceOwnershipReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for renounceOwnershipReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl renounceOwnershipReturn {
            fn _tokenize(
                &self,
            ) -> <renounceOwnershipCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for renounceOwnershipCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = renounceOwnershipReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "renounceOwnership()";
            const SELECTOR: [u8; 4] = [113u8, 80u8, 24u8, 166u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                renounceOwnershipReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `reportForSlashing(uint64,address,string)` and selector `0xadff830c`.
```solidity
function reportForSlashing(uint64 serviceId, address operator, string memory reason) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct reportForSlashingCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub reason: alloy::sol_types::private::String,
    }
    ///Container type for the return parameters of the [`reportForSlashing(uint64,address,string)`](reportForSlashingCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct reportForSlashingReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::String,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::Address,
                alloy::sol_types::private::String,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<reportForSlashingCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: reportForSlashingCall) -> Self {
                    (value.serviceId, value.operator, value.reason)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for reportForSlashingCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                        reason: tuple.2,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<reportForSlashingReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: reportForSlashingReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for reportForSlashingReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl reportForSlashingReturn {
            fn _tokenize(
                &self,
            ) -> <reportForSlashingCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for reportForSlashingCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::String,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = reportForSlashingReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "reportForSlashing(uint64,address,string)";
            const SELECTOR: [u8; 4] = [173u8, 255u8, 131u8, 12u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.reason,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                reportForSlashingReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `serviceMetrics(uint64,uint256)` and selector `0x22f1ec93`.
```solidity
function serviceMetrics(uint64, uint256) external view returns (string memory name, uint256 minValue, uint256 maxValue, bool required);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct serviceMetricsCall {
        #[allow(missing_docs)]
        pub _0: u64,
        #[allow(missing_docs)]
        pub _1: alloy::sol_types::private::primitives::aliases::U256,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`serviceMetrics(uint64,uint256)`](serviceMetricsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct serviceMetricsReturn {
        #[allow(missing_docs)]
        pub name: alloy::sol_types::private::String,
        #[allow(missing_docs)]
        pub minValue: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub maxValue: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub required: bool,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<serviceMetricsCall> for UnderlyingRustTuple<'_> {
                fn from(value: serviceMetricsCall) -> Self {
                    (value._0, value._1)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for serviceMetricsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0, _1: tuple.1 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::String,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Bool,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::String,
                alloy::sol_types::private::primitives::aliases::U256,
                alloy::sol_types::private::primitives::aliases::U256,
                bool,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<serviceMetricsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: serviceMetricsReturn) -> Self {
                    (value.name, value.minValue, value.maxValue, value.required)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for serviceMetricsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        name: tuple.0,
                        minValue: tuple.1,
                        maxValue: tuple.2,
                        required: tuple.3,
                    }
                }
            }
        }
        impl serviceMetricsReturn {
            fn _tokenize(
                &self,
            ) -> <serviceMetricsCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.name,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.minValue),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.maxValue),
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        &self.required,
                    ),
                )
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for serviceMetricsCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = serviceMetricsReturn;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::String,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Bool,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "serviceMetrics(uint64,uint256)";
            const SELECTOR: [u8; 4] = [34u8, 241u8, 236u8, 147u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self._0),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self._1),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                serviceMetricsReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `serviceOwners(uint64)` and selector `0x56c4e17d`.
```solidity
function serviceOwners(uint64) external view returns (address);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct serviceOwnersCall(pub u64);
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`serviceOwners(uint64)`](serviceOwnersCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct serviceOwnersReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<serviceOwnersCall> for UnderlyingRustTuple<'_> {
                fn from(value: serviceOwnersCall) -> Self {
                    (value.0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for serviceOwnersCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self(tuple.0)
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<serviceOwnersReturn> for UnderlyingRustTuple<'_> {
                fn from(value: serviceOwnersReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for serviceOwnersReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for serviceOwnersCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Address;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "serviceOwners(uint64)";
            const SELECTOR: [u8; 4] = [86u8, 196u8, 225u8, 125u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.0),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: serviceOwnersReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: serviceOwnersReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `setMetricDefinitions(uint64,(string,uint256,uint256,bool)[])` and selector `0x191cbd1a`.
```solidity
function setMetricDefinitions(uint64 serviceId, IOperatorStatusRegistry.MetricDefinition[] memory definitions) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct setMetricDefinitionsCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub definitions: alloy::sol_types::private::Vec<
            <IOperatorStatusRegistry::MetricDefinition as alloy::sol_types::SolType>::RustType,
        >,
    }
    ///Container type for the return parameters of the [`setMetricDefinitions(uint64,(string,uint256,uint256,bool)[])`](setMetricDefinitionsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct setMetricDefinitionsReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Array<
                    IOperatorStatusRegistry::MetricDefinition,
                >,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::Vec<
                    <IOperatorStatusRegistry::MetricDefinition as alloy::sol_types::SolType>::RustType,
                >,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<setMetricDefinitionsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: setMetricDefinitionsCall) -> Self {
                    (value.serviceId, value.definitions)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for setMetricDefinitionsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        definitions: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<setMetricDefinitionsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: setMetricDefinitionsReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for setMetricDefinitionsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl setMetricDefinitionsReturn {
            fn _tokenize(
                &self,
            ) -> <setMetricDefinitionsCall as alloy_sol_types::SolCall>::ReturnToken<
                '_,
            > {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for setMetricDefinitionsCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Array<
                    IOperatorStatusRegistry::MetricDefinition,
                >,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = setMetricDefinitionsReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "setMetricDefinitions(uint64,(string,uint256,uint256,bool)[])";
            const SELECTOR: [u8; 4] = [25u8, 28u8, 189u8, 26u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Array<
                        IOperatorStatusRegistry::MetricDefinition,
                    > as alloy_sol_types::SolType>::tokenize(&self.definitions),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                setMetricDefinitionsReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `setMetricsRecorder(address)` and selector `0x20812956`.
```solidity
function setMetricsRecorder(address recorder) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct setMetricsRecorderCall {
        #[allow(missing_docs)]
        pub recorder: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`setMetricsRecorder(address)`](setMetricsRecorderCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct setMetricsRecorderReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<setMetricsRecorderCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: setMetricsRecorderCall) -> Self {
                    (value.recorder,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for setMetricsRecorderCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { recorder: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<setMetricsRecorderReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: setMetricsRecorderReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for setMetricsRecorderReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl setMetricsRecorderReturn {
            fn _tokenize(
                &self,
            ) -> <setMetricsRecorderCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for setMetricsRecorderCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Address,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = setMetricsRecorderReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "setMetricsRecorder(address)";
            const SELECTOR: [u8; 4] = [32u8, 129u8, 41u8, 86u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.recorder,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                setMetricsRecorderReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `setSlashingOracle(address)` and selector `0x84ef7322`.
```solidity
function setSlashingOracle(address oracle) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct setSlashingOracleCall {
        #[allow(missing_docs)]
        pub oracle: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`setSlashingOracle(address)`](setSlashingOracleCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct setSlashingOracleReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<setSlashingOracleCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: setSlashingOracleCall) -> Self {
                    (value.oracle,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for setSlashingOracleCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { oracle: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<setSlashingOracleReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: setSlashingOracleReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for setSlashingOracleReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl setSlashingOracleReturn {
            fn _tokenize(
                &self,
            ) -> <setSlashingOracleCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for setSlashingOracleCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Address,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = setSlashingOracleReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "setSlashingOracle(address)";
            const SELECTOR: [u8; 4] = [132u8, 239u8, 115u8, 34u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.oracle,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                setSlashingOracleReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `slashingOracle()` and selector `0xcfe34749`.
```solidity
function slashingOracle() external view returns (address);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct slashingOracleCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`slashingOracle()`](slashingOracleCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct slashingOracleReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<slashingOracleCall> for UnderlyingRustTuple<'_> {
                fn from(value: slashingOracleCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for slashingOracleCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<slashingOracleReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: slashingOracleReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for slashingOracleReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for slashingOracleCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Address;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "slashingOracle()";
            const SELECTOR: [u8; 4] = [207u8, 227u8, 71u8, 73u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: slashingOracleReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: slashingOracleReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `submitHeartbeat(uint64,uint64,uint8,bytes,uint64,bytes)` and selector `0x2bf4d6a7`.
```solidity
function submitHeartbeat(uint64 serviceId, uint64 blueprintId, uint8 statusCode, bytes memory metrics, uint64 timestamp, bytes memory signature) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct submitHeartbeatCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub blueprintId: u64,
        #[allow(missing_docs)]
        pub statusCode: u8,
        #[allow(missing_docs)]
        pub metrics: alloy::sol_types::private::Bytes,
        #[allow(missing_docs)]
        pub timestamp: u64,
        #[allow(missing_docs)]
        pub signature: alloy::sol_types::private::Bytes,
    }
    ///Container type for the return parameters of the [`submitHeartbeat(uint64,uint64,uint8,bytes,uint64,bytes)`](submitHeartbeatCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct submitHeartbeatReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
                alloy::sol_types::sol_data::Bytes,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Bytes,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                u64,
                u8,
                alloy::sol_types::private::Bytes,
                u64,
                alloy::sol_types::private::Bytes,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<submitHeartbeatCall> for UnderlyingRustTuple<'_> {
                fn from(value: submitHeartbeatCall) -> Self {
                    (
                        value.serviceId,
                        value.blueprintId,
                        value.statusCode,
                        value.metrics,
                        value.timestamp,
                        value.signature,
                    )
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for submitHeartbeatCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        blueprintId: tuple.1,
                        statusCode: tuple.2,
                        metrics: tuple.3,
                        timestamp: tuple.4,
                        signature: tuple.5,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<submitHeartbeatReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: submitHeartbeatReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for submitHeartbeatReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl submitHeartbeatReturn {
            fn _tokenize(
                &self,
            ) -> <submitHeartbeatCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for submitHeartbeatCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
                alloy::sol_types::sol_data::Bytes,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Bytes,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = submitHeartbeatReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "submitHeartbeat(uint64,uint64,uint8,bytes,uint64,bytes)";
            const SELECTOR: [u8; 4] = [43u8, 244u8, 214u8, 167u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.blueprintId),
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.statusCode),
                    <alloy::sol_types::sol_data::Bytes as alloy_sol_types::SolType>::tokenize(
                        &self.metrics,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.timestamp),
                    <alloy::sol_types::sol_data::Bytes as alloy_sol_types::SolType>::tokenize(
                        &self.signature,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                submitHeartbeatReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `submitHeartbeatDirect(uint64,uint64,uint8,bytes)` and selector `0x5cce98a6`.
```solidity
function submitHeartbeatDirect(uint64 serviceId, uint64 blueprintId, uint8 statusCode, bytes memory metrics) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct submitHeartbeatDirectCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub blueprintId: u64,
        #[allow(missing_docs)]
        pub statusCode: u8,
        #[allow(missing_docs)]
        pub metrics: alloy::sol_types::private::Bytes,
    }
    ///Container type for the return parameters of the [`submitHeartbeatDirect(uint64,uint64,uint8,bytes)`](submitHeartbeatDirectCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct submitHeartbeatDirectReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
                alloy::sol_types::sol_data::Bytes,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                u64,
                u8,
                alloy::sol_types::private::Bytes,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<submitHeartbeatDirectCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: submitHeartbeatDirectCall) -> Self {
                    (value.serviceId, value.blueprintId, value.statusCode, value.metrics)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for submitHeartbeatDirectCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        blueprintId: tuple.1,
                        statusCode: tuple.2,
                        metrics: tuple.3,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<submitHeartbeatDirectReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: submitHeartbeatDirectReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for submitHeartbeatDirectReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl submitHeartbeatDirectReturn {
            fn _tokenize(
                &self,
            ) -> <submitHeartbeatDirectCall as alloy_sol_types::SolCall>::ReturnToken<
                '_,
            > {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for submitHeartbeatDirectCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<8>,
                alloy::sol_types::sol_data::Bytes,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = submitHeartbeatDirectReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "submitHeartbeatDirect(uint64,uint64,uint8,bytes)";
            const SELECTOR: [u8; 4] = [92u8, 206u8, 152u8, 166u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.blueprintId),
                    <alloy::sol_types::sol_data::Uint<
                        8,
                    > as alloy_sol_types::SolType>::tokenize(&self.statusCode),
                    <alloy::sol_types::sol_data::Bytes as alloy_sol_types::SolType>::tokenize(
                        &self.metrics,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                submitHeartbeatDirectReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `tangleCore()` and selector `0x5a936dc6`.
```solidity
function tangleCore() external view returns (address);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct tangleCoreCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`tangleCore()`](tangleCoreCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct tangleCoreReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::Address,
    }
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<tangleCoreCall> for UnderlyingRustTuple<'_> {
                fn from(value: tangleCoreCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for tangleCoreCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<tangleCoreReturn> for UnderlyingRustTuple<'_> {
                fn from(value: tangleCoreReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for tangleCoreReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for tangleCoreCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Address;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "tangleCore()";
            const SELECTOR: [u8; 4] = [90u8, 147u8, 109u8, 198u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                ()
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        ret,
                    ),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: tangleCoreReturn = r.into();
                        r._0
                    })
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(|r| {
                        let r: tangleCoreReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `transferOwnership(address)` and selector `0xf2fde38b`.
```solidity
function transferOwnership(address newOwner) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct transferOwnershipCall {
        #[allow(missing_docs)]
        pub newOwner: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`transferOwnership(address)`](transferOwnershipCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct transferOwnershipReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Address,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<transferOwnershipCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: transferOwnershipCall) -> Self {
                    (value.newOwner,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for transferOwnershipCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { newOwner: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<transferOwnershipReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: transferOwnershipReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for transferOwnershipReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl transferOwnershipReturn {
            fn _tokenize(
                &self,
            ) -> <transferOwnershipCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for transferOwnershipCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Address,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = transferOwnershipReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "transferOwnership(address)";
            const SELECTOR: [u8; 4] = [242u8, 253u8, 227u8, 139u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.newOwner,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                transferOwnershipReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `validateAndStoreMetrics(uint64,address,(string,uint256)[],uint256)` and selector `0x65a6936e`.
```solidity
function validateAndStoreMetrics(uint64 serviceId, address operator, IOperatorStatusRegistry.MetricPair[] memory pairs, uint256 pairsLen) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct validateAndStoreMetricsCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub pairs: alloy::sol_types::private::Vec<
            <IOperatorStatusRegistry::MetricPair as alloy::sol_types::SolType>::RustType,
        >,
        #[allow(missing_docs)]
        pub pairsLen: alloy::sol_types::private::primitives::aliases::U256,
    }
    ///Container type for the return parameters of the [`validateAndStoreMetrics(uint64,address,(string,uint256)[],uint256)`](validateAndStoreMetricsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct validateAndStoreMetricsReturn {}
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Array<IOperatorStatusRegistry::MetricPair>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::Address,
                alloy::sol_types::private::Vec<
                    <IOperatorStatusRegistry::MetricPair as alloy::sol_types::SolType>::RustType,
                >,
                alloy::sol_types::private::primitives::aliases::U256,
            );
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<validateAndStoreMetricsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: validateAndStoreMetricsCall) -> Self {
                    (value.serviceId, value.operator, value.pairs, value.pairsLen)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for validateAndStoreMetricsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                        pairs: tuple.2,
                        pairsLen: tuple.3,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = ();
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = ();
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<validateAndStoreMetricsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: validateAndStoreMetricsReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for validateAndStoreMetricsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl validateAndStoreMetricsReturn {
            fn _tokenize(
                &self,
            ) -> <validateAndStoreMetricsCall as alloy_sol_types::SolCall>::ReturnToken<
                '_,
            > {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for validateAndStoreMetricsCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Array<IOperatorStatusRegistry::MetricPair>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = validateAndStoreMetricsReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "validateAndStoreMetrics(uint64,address,(string,uint256)[],uint256)";
            const SELECTOR: [u8; 4] = [101u8, 166u8, 147u8, 110u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                    <alloy::sol_types::sol_data::Array<
                        IOperatorStatusRegistry::MetricPair,
                    > as alloy_sol_types::SolType>::tokenize(&self.pairs),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.pairsLen),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                validateAndStoreMetricsReturn::_tokenize(ret)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(Into::into)
            }
            #[inline]
            fn abi_decode_returns_validate(
                data: &[u8],
            ) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence_validate(data)
                    .map(Into::into)
            }
        }
    };
    ///Container for all the [`OperatorStatusRegistry`](self) function calls.
    #[derive(Clone)]
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive()]
    pub enum OperatorStatusRegistryCalls {
        #[allow(missing_docs)]
        DEFAULT_HEARTBEAT_INTERVAL(DEFAULT_HEARTBEAT_INTERVALCall),
        #[allow(missing_docs)]
        DEFAULT_MAX_MISSED_HEARTBEATS(DEFAULT_MAX_MISSED_HEARTBEATSCall),
        #[allow(missing_docs)]
        DOMAIN_SEPARATOR(DOMAIN_SEPARATORCall),
        #[allow(missing_docs)]
        HEARTBEAT_MAX_AGE(HEARTBEAT_MAX_AGECall),
        #[allow(missing_docs)]
        HEARTBEAT_TYPEHASH(HEARTBEAT_TYPEHASHCall),
        #[allow(missing_docs)]
        MAX_METRIC_DEFINITIONS(MAX_METRIC_DEFINITIONSCall),
        #[allow(missing_docs)]
        MAX_METRIC_NAME_LENGTH(MAX_METRIC_NAME_LENGTHCall),
        #[allow(missing_docs)]
        MAX_PAGE_SIZE(MAX_PAGE_SIZECall),
        #[allow(missing_docs)]
        SLASH_ALERT_COOLDOWN(SLASH_ALERT_COOLDOWNCall),
        #[allow(missing_docs)]
        acceptOwnership(acceptOwnershipCall),
        #[allow(missing_docs)]
        addMetricDefinition(addMetricDefinitionCall),
        #[allow(missing_docs)]
        checkOperatorStatus(checkOperatorStatusCall),
        #[allow(missing_docs)]
        checkOperatorsStatus(checkOperatorsStatusCall),
        #[allow(missing_docs)]
        configureHeartbeat(configureHeartbeatCall),
        #[allow(missing_docs)]
        decodeMetricPairs(decodeMetricPairsCall),
        #[allow(missing_docs)]
        deregisterOperator(deregisterOperatorCall),
        #[allow(missing_docs)]
        enableCustomMetrics(enableCustomMetricsCall),
        #[allow(missing_docs)]
        getAllOperatorCount(getAllOperatorCountCall),
        #[allow(missing_docs)]
        getHeartbeatConfig(getHeartbeatConfigCall),
        #[allow(missing_docs)]
        getLastCriticalHeartbeat(getLastCriticalHeartbeatCall),
        #[allow(missing_docs)]
        getLastHeartbeat(getLastHeartbeatCall),
        #[allow(missing_docs)]
        getMetricDefinitions(getMetricDefinitionsCall),
        #[allow(missing_docs)]
        getMetricValue(getMetricValueCall),
        #[allow(missing_docs)]
        getOnlineOperatorCount(getOnlineOperatorCountCall),
        #[allow(missing_docs)]
        getOnlineOperators(getOnlineOperatorsCall),
        #[allow(missing_docs)]
        getOperatorState(getOperatorStateCall),
        #[allow(missing_docs)]
        getOperatorStatus(getOperatorStatusCall),
        #[allow(missing_docs)]
        getSlashableOperators(getSlashableOperatorsCall),
        #[allow(missing_docs)]
        getSlashableOperatorsPaginated(getSlashableOperatorsPaginatedCall),
        #[allow(missing_docs)]
        goOffline(goOfflineCall),
        #[allow(missing_docs)]
        goOnline(goOnlineCall),
        #[allow(missing_docs)]
        heartbeatConfigs(heartbeatConfigsCall),
        #[allow(missing_docs)]
        isHeartbeatCurrent(isHeartbeatCurrentCall),
        #[allow(missing_docs)]
        isOnline(isOnlineCall),
        #[allow(missing_docs)]
        isRegisteredOperator(isRegisteredOperatorCall),
        #[allow(missing_docs)]
        metricValues(metricValuesCall),
        #[allow(missing_docs)]
        metricsRecorder(metricsRecorderCall),
        #[allow(missing_docs)]
        operatorStates(operatorStatesCall),
        #[allow(missing_docs)]
        owner(ownerCall),
        #[allow(missing_docs)]
        pendingOwner(pendingOwnerCall),
        #[allow(missing_docs)]
        registerOperator(registerOperatorCall),
        #[allow(missing_docs)]
        registerServiceOwner(registerServiceOwnerCall),
        #[allow(missing_docs)]
        removeInactiveOperator(removeInactiveOperatorCall),
        #[allow(missing_docs)]
        renounceOwnership(renounceOwnershipCall),
        #[allow(missing_docs)]
        reportForSlashing(reportForSlashingCall),
        #[allow(missing_docs)]
        serviceMetrics(serviceMetricsCall),
        #[allow(missing_docs)]
        serviceOwners(serviceOwnersCall),
        #[allow(missing_docs)]
        setMetricDefinitions(setMetricDefinitionsCall),
        #[allow(missing_docs)]
        setMetricsRecorder(setMetricsRecorderCall),
        #[allow(missing_docs)]
        setSlashingOracle(setSlashingOracleCall),
        #[allow(missing_docs)]
        slashingOracle(slashingOracleCall),
        #[allow(missing_docs)]
        submitHeartbeat(submitHeartbeatCall),
        #[allow(missing_docs)]
        submitHeartbeatDirect(submitHeartbeatDirectCall),
        #[allow(missing_docs)]
        tangleCore(tangleCoreCall),
        #[allow(missing_docs)]
        transferOwnership(transferOwnershipCall),
        #[allow(missing_docs)]
        validateAndStoreMetrics(validateAndStoreMetricsCall),
    }
    impl OperatorStatusRegistryCalls {
        /// All the selectors of this enum.
        ///
        /// Note that the selectors might not be in the same order as the variants.
        /// No guarantees are made about the order of the selectors.
        ///
        /// Prefer using `SolInterface` methods instead.
        pub const SELECTORS: &'static [[u8; 4usize]] = &[
            [5u8, 119u8, 133u8, 80u8],
            [7u8, 88u8, 35u8, 111u8],
            [12u8, 118u8, 105u8, 122u8],
            [25u8, 28u8, 189u8, 26u8],
            [30u8, 143u8, 94u8, 229u8],
            [32u8, 129u8, 41u8, 86u8],
            [34u8, 241u8, 236u8, 147u8],
            [43u8, 244u8, 214u8, 167u8],
            [44u8, 149u8, 118u8, 136u8],
            [45u8, 174u8, 24u8, 133u8],
            [47u8, 75u8, 215u8, 184u8],
            [49u8, 227u8, 189u8, 27u8],
            [54u8, 68u8, 229u8, 21u8],
            [58u8, 195u8, 203u8, 230u8],
            [62u8, 110u8, 52u8, 167u8],
            [63u8, 214u8, 44u8, 109u8],
            [64u8, 35u8, 90u8, 156u8],
            [72u8, 244u8, 218u8, 32u8],
            [86u8, 133u8, 207u8, 104u8],
            [86u8, 196u8, 225u8, 125u8],
            [89u8, 220u8, 234u8, 18u8],
            [90u8, 147u8, 109u8, 198u8],
            [92u8, 206u8, 152u8, 166u8],
            [96u8, 118u8, 67u8, 156u8],
            [96u8, 207u8, 9u8, 145u8],
            [97u8, 214u8, 184u8, 108u8],
            [98u8, 199u8, 232u8, 252u8],
            [101u8, 166u8, 147u8, 110u8],
            [107u8, 254u8, 6u8, 166u8],
            [113u8, 80u8, 24u8, 166u8],
            [113u8, 231u8, 56u8, 140u8],
            [118u8, 57u8, 210u8, 39u8],
            [121u8, 186u8, 80u8, 151u8],
            [123u8, 159u8, 100u8, 178u8],
            [129u8, 190u8, 172u8, 46u8],
            [132u8, 239u8, 115u8, 34u8],
            [141u8, 165u8, 203u8, 91u8],
            [150u8, 104u8, 108u8, 30u8],
            [156u8, 189u8, 174u8, 34u8],
            [173u8, 255u8, 131u8, 12u8],
            [174u8, 71u8, 10u8, 133u8],
            [176u8, 116u8, 233u8, 221u8],
            [185u8, 159u8, 103u8, 89u8],
            [186u8, 31u8, 177u8, 3u8],
            [193u8, 239u8, 157u8, 223u8],
            [197u8, 217u8, 96u8, 187u8],
            [207u8, 227u8, 71u8, 73u8],
            [213u8, 81u8, 22u8, 44u8],
            [218u8, 67u8, 90u8, 124u8],
            [227u8, 12u8, 57u8, 120u8],
            [230u8, 92u8, 175u8, 203u8],
            [238u8, 28u8, 3u8, 144u8],
            [242u8, 253u8, 227u8, 139u8],
            [249u8, 16u8, 127u8, 59u8],
            [249u8, 241u8, 103u8, 98u8],
            [255u8, 207u8, 8u8, 240u8],
        ];
        /// The names of the variants in the same order as `SELECTORS`.
        pub const VARIANT_NAMES: &'static [&'static str] = &[
            ::core::stringify!(registerServiceOwner),
            ::core::stringify!(getHeartbeatConfig),
            ::core::stringify!(getLastHeartbeat),
            ::core::stringify!(setMetricDefinitions),
            ::core::stringify!(registerOperator),
            ::core::stringify!(setMetricsRecorder),
            ::core::stringify!(serviceMetrics),
            ::core::stringify!(submitHeartbeat),
            ::core::stringify!(DEFAULT_HEARTBEAT_INTERVAL),
            ::core::stringify!(metricsRecorder),
            ::core::stringify!(HEARTBEAT_MAX_AGE),
            ::core::stringify!(decodeMetricPairs),
            ::core::stringify!(DOMAIN_SEPARATOR),
            ::core::stringify!(SLASH_ALERT_COOLDOWN),
            ::core::stringify!(operatorStates),
            ::core::stringify!(getAllOperatorCount),
            ::core::stringify!(getOnlineOperators),
            ::core::stringify!(MAX_PAGE_SIZE),
            ::core::stringify!(isOnline),
            ::core::stringify!(serviceOwners),
            ::core::stringify!(getSlashableOperators),
            ::core::stringify!(tangleCore),
            ::core::stringify!(submitHeartbeatDirect),
            ::core::stringify!(MAX_METRIC_DEFINITIONS),
            ::core::stringify!(isRegisteredOperator),
            ::core::stringify!(DEFAULT_MAX_MISSED_HEARTBEATS),
            ::core::stringify!(getOperatorStatus),
            ::core::stringify!(validateAndStoreMetrics),
            ::core::stringify!(MAX_METRIC_NAME_LENGTH),
            ::core::stringify!(renounceOwnership),
            ::core::stringify!(getOperatorState),
            ::core::stringify!(getLastCriticalHeartbeat),
            ::core::stringify!(acceptOwnership),
            ::core::stringify!(getOnlineOperatorCount),
            ::core::stringify!(getSlashableOperatorsPaginated),
            ::core::stringify!(setSlashingOracle),
            ::core::stringify!(owner),
            ::core::stringify!(checkOperatorsStatus),
            ::core::stringify!(metricValues),
            ::core::stringify!(reportForSlashing),
            ::core::stringify!(addMetricDefinition),
            ::core::stringify!(goOnline),
            ::core::stringify!(configureHeartbeat),
            ::core::stringify!(checkOperatorStatus),
            ::core::stringify!(getMetricDefinitions),
            ::core::stringify!(goOffline),
            ::core::stringify!(slashingOracle),
            ::core::stringify!(getMetricValue),
            ::core::stringify!(heartbeatConfigs),
            ::core::stringify!(pendingOwner),
            ::core::stringify!(removeInactiveOperator),
            ::core::stringify!(isHeartbeatCurrent),
            ::core::stringify!(transferOwnership),
            ::core::stringify!(enableCustomMetrics),
            ::core::stringify!(HEARTBEAT_TYPEHASH),
            ::core::stringify!(deregisterOperator),
        ];
        /// The signatures in the same order as `SELECTORS`.
        pub const SIGNATURES: &'static [&'static str] = &[
            <registerServiceOwnerCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getHeartbeatConfigCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getLastHeartbeatCall as alloy_sol_types::SolCall>::SIGNATURE,
            <setMetricDefinitionsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <registerOperatorCall as alloy_sol_types::SolCall>::SIGNATURE,
            <setMetricsRecorderCall as alloy_sol_types::SolCall>::SIGNATURE,
            <serviceMetricsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <submitHeartbeatCall as alloy_sol_types::SolCall>::SIGNATURE,
            <DEFAULT_HEARTBEAT_INTERVALCall as alloy_sol_types::SolCall>::SIGNATURE,
            <metricsRecorderCall as alloy_sol_types::SolCall>::SIGNATURE,
            <HEARTBEAT_MAX_AGECall as alloy_sol_types::SolCall>::SIGNATURE,
            <decodeMetricPairsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <DOMAIN_SEPARATORCall as alloy_sol_types::SolCall>::SIGNATURE,
            <SLASH_ALERT_COOLDOWNCall as alloy_sol_types::SolCall>::SIGNATURE,
            <operatorStatesCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getAllOperatorCountCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getOnlineOperatorsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <MAX_PAGE_SIZECall as alloy_sol_types::SolCall>::SIGNATURE,
            <isOnlineCall as alloy_sol_types::SolCall>::SIGNATURE,
            <serviceOwnersCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getSlashableOperatorsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <tangleCoreCall as alloy_sol_types::SolCall>::SIGNATURE,
            <submitHeartbeatDirectCall as alloy_sol_types::SolCall>::SIGNATURE,
            <MAX_METRIC_DEFINITIONSCall as alloy_sol_types::SolCall>::SIGNATURE,
            <isRegisteredOperatorCall as alloy_sol_types::SolCall>::SIGNATURE,
            <DEFAULT_MAX_MISSED_HEARTBEATSCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getOperatorStatusCall as alloy_sol_types::SolCall>::SIGNATURE,
            <validateAndStoreMetricsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <MAX_METRIC_NAME_LENGTHCall as alloy_sol_types::SolCall>::SIGNATURE,
            <renounceOwnershipCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getOperatorStateCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getLastCriticalHeartbeatCall as alloy_sol_types::SolCall>::SIGNATURE,
            <acceptOwnershipCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getOnlineOperatorCountCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getSlashableOperatorsPaginatedCall as alloy_sol_types::SolCall>::SIGNATURE,
            <setSlashingOracleCall as alloy_sol_types::SolCall>::SIGNATURE,
            <ownerCall as alloy_sol_types::SolCall>::SIGNATURE,
            <checkOperatorsStatusCall as alloy_sol_types::SolCall>::SIGNATURE,
            <metricValuesCall as alloy_sol_types::SolCall>::SIGNATURE,
            <reportForSlashingCall as alloy_sol_types::SolCall>::SIGNATURE,
            <addMetricDefinitionCall as alloy_sol_types::SolCall>::SIGNATURE,
            <goOnlineCall as alloy_sol_types::SolCall>::SIGNATURE,
            <configureHeartbeatCall as alloy_sol_types::SolCall>::SIGNATURE,
            <checkOperatorStatusCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getMetricDefinitionsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <goOfflineCall as alloy_sol_types::SolCall>::SIGNATURE,
            <slashingOracleCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getMetricValueCall as alloy_sol_types::SolCall>::SIGNATURE,
            <heartbeatConfigsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <pendingOwnerCall as alloy_sol_types::SolCall>::SIGNATURE,
            <removeInactiveOperatorCall as alloy_sol_types::SolCall>::SIGNATURE,
            <isHeartbeatCurrentCall as alloy_sol_types::SolCall>::SIGNATURE,
            <transferOwnershipCall as alloy_sol_types::SolCall>::SIGNATURE,
            <enableCustomMetricsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <HEARTBEAT_TYPEHASHCall as alloy_sol_types::SolCall>::SIGNATURE,
            <deregisterOperatorCall as alloy_sol_types::SolCall>::SIGNATURE,
        ];
        /// Returns the signature for the given selector, if known.
        #[inline]
        pub fn signature_by_selector(
            selector: [u8; 4usize],
        ) -> ::core::option::Option<&'static str> {
            match Self::SELECTORS.binary_search(&selector) {
                ::core::result::Result::Ok(idx) => {
                    ::core::option::Option::Some(Self::SIGNATURES[idx])
                }
                ::core::result::Result::Err(_) => ::core::option::Option::None,
            }
        }
        /// Returns the enum variant name for the given selector, if known.
        #[inline]
        pub fn name_by_selector(
            selector: [u8; 4usize],
        ) -> ::core::option::Option<&'static str> {
            let sig = Self::signature_by_selector(selector)?;
            sig.split_once('(').map(|(name, _)| name)
        }
    }
    #[automatically_derived]
    impl alloy_sol_types::SolInterface for OperatorStatusRegistryCalls {
        const NAME: &'static str = "OperatorStatusRegistryCalls";
        const MIN_DATA_LENGTH: usize = 0usize;
        const COUNT: usize = 56usize;
        #[inline]
        fn selector(&self) -> [u8; 4] {
            match self {
                Self::DEFAULT_HEARTBEAT_INTERVAL(_) => {
                    <DEFAULT_HEARTBEAT_INTERVALCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::DEFAULT_MAX_MISSED_HEARTBEATS(_) => {
                    <DEFAULT_MAX_MISSED_HEARTBEATSCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::DOMAIN_SEPARATOR(_) => {
                    <DOMAIN_SEPARATORCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::HEARTBEAT_MAX_AGE(_) => {
                    <HEARTBEAT_MAX_AGECall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::HEARTBEAT_TYPEHASH(_) => {
                    <HEARTBEAT_TYPEHASHCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::MAX_METRIC_DEFINITIONS(_) => {
                    <MAX_METRIC_DEFINITIONSCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::MAX_METRIC_NAME_LENGTH(_) => {
                    <MAX_METRIC_NAME_LENGTHCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::MAX_PAGE_SIZE(_) => {
                    <MAX_PAGE_SIZECall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::SLASH_ALERT_COOLDOWN(_) => {
                    <SLASH_ALERT_COOLDOWNCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::acceptOwnership(_) => {
                    <acceptOwnershipCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::addMetricDefinition(_) => {
                    <addMetricDefinitionCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::checkOperatorStatus(_) => {
                    <checkOperatorStatusCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::checkOperatorsStatus(_) => {
                    <checkOperatorsStatusCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::configureHeartbeat(_) => {
                    <configureHeartbeatCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::decodeMetricPairs(_) => {
                    <decodeMetricPairsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::deregisterOperator(_) => {
                    <deregisterOperatorCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::enableCustomMetrics(_) => {
                    <enableCustomMetricsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getAllOperatorCount(_) => {
                    <getAllOperatorCountCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getHeartbeatConfig(_) => {
                    <getHeartbeatConfigCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getLastCriticalHeartbeat(_) => {
                    <getLastCriticalHeartbeatCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getLastHeartbeat(_) => {
                    <getLastHeartbeatCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getMetricDefinitions(_) => {
                    <getMetricDefinitionsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getMetricValue(_) => {
                    <getMetricValueCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getOnlineOperatorCount(_) => {
                    <getOnlineOperatorCountCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getOnlineOperators(_) => {
                    <getOnlineOperatorsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getOperatorState(_) => {
                    <getOperatorStateCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getOperatorStatus(_) => {
                    <getOperatorStatusCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getSlashableOperators(_) => {
                    <getSlashableOperatorsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getSlashableOperatorsPaginated(_) => {
                    <getSlashableOperatorsPaginatedCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::goOffline(_) => {
                    <goOfflineCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::goOnline(_) => <goOnlineCall as alloy_sol_types::SolCall>::SELECTOR,
                Self::heartbeatConfigs(_) => {
                    <heartbeatConfigsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::isHeartbeatCurrent(_) => {
                    <isHeartbeatCurrentCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::isOnline(_) => <isOnlineCall as alloy_sol_types::SolCall>::SELECTOR,
                Self::isRegisteredOperator(_) => {
                    <isRegisteredOperatorCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::metricValues(_) => {
                    <metricValuesCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::metricsRecorder(_) => {
                    <metricsRecorderCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::operatorStates(_) => {
                    <operatorStatesCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::owner(_) => <ownerCall as alloy_sol_types::SolCall>::SELECTOR,
                Self::pendingOwner(_) => {
                    <pendingOwnerCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::registerOperator(_) => {
                    <registerOperatorCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::registerServiceOwner(_) => {
                    <registerServiceOwnerCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::removeInactiveOperator(_) => {
                    <removeInactiveOperatorCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::renounceOwnership(_) => {
                    <renounceOwnershipCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::reportForSlashing(_) => {
                    <reportForSlashingCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::serviceMetrics(_) => {
                    <serviceMetricsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::serviceOwners(_) => {
                    <serviceOwnersCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::setMetricDefinitions(_) => {
                    <setMetricDefinitionsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::setMetricsRecorder(_) => {
                    <setMetricsRecorderCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::setSlashingOracle(_) => {
                    <setSlashingOracleCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::slashingOracle(_) => {
                    <slashingOracleCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::submitHeartbeat(_) => {
                    <submitHeartbeatCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::submitHeartbeatDirect(_) => {
                    <submitHeartbeatDirectCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::tangleCore(_) => {
                    <tangleCoreCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::transferOwnership(_) => {
                    <transferOwnershipCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::validateAndStoreMetrics(_) => {
                    <validateAndStoreMetricsCall as alloy_sol_types::SolCall>::SELECTOR
                }
            }
        }
        #[inline]
        fn selector_at(i: usize) -> ::core::option::Option<[u8; 4]> {
            Self::SELECTORS.get(i).copied()
        }
        #[inline]
        fn valid_selector(selector: [u8; 4]) -> bool {
            Self::SELECTORS.binary_search(&selector).is_ok()
        }
        #[inline]
        #[allow(non_snake_case)]
        fn abi_decode_raw(
            selector: [u8; 4],
            data: &[u8],
        ) -> alloy_sol_types::Result<Self> {
            static DECODE_SHIMS: &[fn(
                &[u8],
            ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls>] = &[
                {
                    fn registerServiceOwner(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <registerServiceOwnerCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::registerServiceOwner)
                    }
                    registerServiceOwner
                },
                {
                    fn getHeartbeatConfig(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getHeartbeatConfigCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getHeartbeatConfig)
                    }
                    getHeartbeatConfig
                },
                {
                    fn getLastHeartbeat(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getLastHeartbeatCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getLastHeartbeat)
                    }
                    getLastHeartbeat
                },
                {
                    fn setMetricDefinitions(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <setMetricDefinitionsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::setMetricDefinitions)
                    }
                    setMetricDefinitions
                },
                {
                    fn registerOperator(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <registerOperatorCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::registerOperator)
                    }
                    registerOperator
                },
                {
                    fn setMetricsRecorder(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <setMetricsRecorderCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::setMetricsRecorder)
                    }
                    setMetricsRecorder
                },
                {
                    fn serviceMetrics(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <serviceMetricsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::serviceMetrics)
                    }
                    serviceMetrics
                },
                {
                    fn submitHeartbeat(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <submitHeartbeatCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::submitHeartbeat)
                    }
                    submitHeartbeat
                },
                {
                    fn DEFAULT_HEARTBEAT_INTERVAL(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <DEFAULT_HEARTBEAT_INTERVALCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::DEFAULT_HEARTBEAT_INTERVAL)
                    }
                    DEFAULT_HEARTBEAT_INTERVAL
                },
                {
                    fn metricsRecorder(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <metricsRecorderCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::metricsRecorder)
                    }
                    metricsRecorder
                },
                {
                    fn HEARTBEAT_MAX_AGE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <HEARTBEAT_MAX_AGECall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::HEARTBEAT_MAX_AGE)
                    }
                    HEARTBEAT_MAX_AGE
                },
                {
                    fn decodeMetricPairs(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <decodeMetricPairsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::decodeMetricPairs)
                    }
                    decodeMetricPairs
                },
                {
                    fn DOMAIN_SEPARATOR(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <DOMAIN_SEPARATORCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::DOMAIN_SEPARATOR)
                    }
                    DOMAIN_SEPARATOR
                },
                {
                    fn SLASH_ALERT_COOLDOWN(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <SLASH_ALERT_COOLDOWNCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::SLASH_ALERT_COOLDOWN)
                    }
                    SLASH_ALERT_COOLDOWN
                },
                {
                    fn operatorStates(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <operatorStatesCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::operatorStates)
                    }
                    operatorStates
                },
                {
                    fn getAllOperatorCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getAllOperatorCountCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getAllOperatorCount)
                    }
                    getAllOperatorCount
                },
                {
                    fn getOnlineOperators(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getOnlineOperatorsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getOnlineOperators)
                    }
                    getOnlineOperators
                },
                {
                    fn MAX_PAGE_SIZE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <MAX_PAGE_SIZECall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::MAX_PAGE_SIZE)
                    }
                    MAX_PAGE_SIZE
                },
                {
                    fn isOnline(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <isOnlineCall as alloy_sol_types::SolCall>::abi_decode_raw(data)
                            .map(OperatorStatusRegistryCalls::isOnline)
                    }
                    isOnline
                },
                {
                    fn serviceOwners(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <serviceOwnersCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::serviceOwners)
                    }
                    serviceOwners
                },
                {
                    fn getSlashableOperators(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getSlashableOperatorsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getSlashableOperators)
                    }
                    getSlashableOperators
                },
                {
                    fn tangleCore(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <tangleCoreCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::tangleCore)
                    }
                    tangleCore
                },
                {
                    fn submitHeartbeatDirect(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <submitHeartbeatDirectCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::submitHeartbeatDirect)
                    }
                    submitHeartbeatDirect
                },
                {
                    fn MAX_METRIC_DEFINITIONS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <MAX_METRIC_DEFINITIONSCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::MAX_METRIC_DEFINITIONS)
                    }
                    MAX_METRIC_DEFINITIONS
                },
                {
                    fn isRegisteredOperator(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <isRegisteredOperatorCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::isRegisteredOperator)
                    }
                    isRegisteredOperator
                },
                {
                    fn DEFAULT_MAX_MISSED_HEARTBEATS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <DEFAULT_MAX_MISSED_HEARTBEATSCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(
                                OperatorStatusRegistryCalls::DEFAULT_MAX_MISSED_HEARTBEATS,
                            )
                    }
                    DEFAULT_MAX_MISSED_HEARTBEATS
                },
                {
                    fn getOperatorStatus(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getOperatorStatusCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getOperatorStatus)
                    }
                    getOperatorStatus
                },
                {
                    fn validateAndStoreMetrics(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <validateAndStoreMetricsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::validateAndStoreMetrics)
                    }
                    validateAndStoreMetrics
                },
                {
                    fn MAX_METRIC_NAME_LENGTH(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <MAX_METRIC_NAME_LENGTHCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::MAX_METRIC_NAME_LENGTH)
                    }
                    MAX_METRIC_NAME_LENGTH
                },
                {
                    fn renounceOwnership(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <renounceOwnershipCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::renounceOwnership)
                    }
                    renounceOwnership
                },
                {
                    fn getOperatorState(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getOperatorStateCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getOperatorState)
                    }
                    getOperatorState
                },
                {
                    fn getLastCriticalHeartbeat(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getLastCriticalHeartbeatCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getLastCriticalHeartbeat)
                    }
                    getLastCriticalHeartbeat
                },
                {
                    fn acceptOwnership(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <acceptOwnershipCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::acceptOwnership)
                    }
                    acceptOwnership
                },
                {
                    fn getOnlineOperatorCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getOnlineOperatorCountCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getOnlineOperatorCount)
                    }
                    getOnlineOperatorCount
                },
                {
                    fn getSlashableOperatorsPaginated(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getSlashableOperatorsPaginatedCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(
                                OperatorStatusRegistryCalls::getSlashableOperatorsPaginated,
                            )
                    }
                    getSlashableOperatorsPaginated
                },
                {
                    fn setSlashingOracle(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <setSlashingOracleCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::setSlashingOracle)
                    }
                    setSlashingOracle
                },
                {
                    fn owner(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <ownerCall as alloy_sol_types::SolCall>::abi_decode_raw(data)
                            .map(OperatorStatusRegistryCalls::owner)
                    }
                    owner
                },
                {
                    fn checkOperatorsStatus(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <checkOperatorsStatusCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::checkOperatorsStatus)
                    }
                    checkOperatorsStatus
                },
                {
                    fn metricValues(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <metricValuesCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::metricValues)
                    }
                    metricValues
                },
                {
                    fn reportForSlashing(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <reportForSlashingCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::reportForSlashing)
                    }
                    reportForSlashing
                },
                {
                    fn addMetricDefinition(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <addMetricDefinitionCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::addMetricDefinition)
                    }
                    addMetricDefinition
                },
                {
                    fn goOnline(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <goOnlineCall as alloy_sol_types::SolCall>::abi_decode_raw(data)
                            .map(OperatorStatusRegistryCalls::goOnline)
                    }
                    goOnline
                },
                {
                    fn configureHeartbeat(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <configureHeartbeatCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::configureHeartbeat)
                    }
                    configureHeartbeat
                },
                {
                    fn checkOperatorStatus(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <checkOperatorStatusCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::checkOperatorStatus)
                    }
                    checkOperatorStatus
                },
                {
                    fn getMetricDefinitions(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getMetricDefinitionsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getMetricDefinitions)
                    }
                    getMetricDefinitions
                },
                {
                    fn goOffline(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <goOfflineCall as alloy_sol_types::SolCall>::abi_decode_raw(data)
                            .map(OperatorStatusRegistryCalls::goOffline)
                    }
                    goOffline
                },
                {
                    fn slashingOracle(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <slashingOracleCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::slashingOracle)
                    }
                    slashingOracle
                },
                {
                    fn getMetricValue(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getMetricValueCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getMetricValue)
                    }
                    getMetricValue
                },
                {
                    fn heartbeatConfigs(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <heartbeatConfigsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::heartbeatConfigs)
                    }
                    heartbeatConfigs
                },
                {
                    fn pendingOwner(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <pendingOwnerCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::pendingOwner)
                    }
                    pendingOwner
                },
                {
                    fn removeInactiveOperator(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <removeInactiveOperatorCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::removeInactiveOperator)
                    }
                    removeInactiveOperator
                },
                {
                    fn isHeartbeatCurrent(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <isHeartbeatCurrentCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::isHeartbeatCurrent)
                    }
                    isHeartbeatCurrent
                },
                {
                    fn transferOwnership(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <transferOwnershipCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::transferOwnership)
                    }
                    transferOwnership
                },
                {
                    fn enableCustomMetrics(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <enableCustomMetricsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::enableCustomMetrics)
                    }
                    enableCustomMetrics
                },
                {
                    fn HEARTBEAT_TYPEHASH(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <HEARTBEAT_TYPEHASHCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::HEARTBEAT_TYPEHASH)
                    }
                    HEARTBEAT_TYPEHASH
                },
                {
                    fn deregisterOperator(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <deregisterOperatorCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::deregisterOperator)
                    }
                    deregisterOperator
                },
            ];
            let Ok(idx) = Self::SELECTORS.binary_search(&selector) else {
                return Err(
                    alloy_sol_types::Error::unknown_selector(
                        <Self as alloy_sol_types::SolInterface>::NAME,
                        selector,
                    ),
                );
            };
            DECODE_SHIMS[idx](data)
        }
        #[inline]
        #[allow(non_snake_case)]
        fn abi_decode_raw_validate(
            selector: [u8; 4],
            data: &[u8],
        ) -> alloy_sol_types::Result<Self> {
            static DECODE_VALIDATE_SHIMS: &[fn(
                &[u8],
            ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls>] = &[
                {
                    fn registerServiceOwner(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <registerServiceOwnerCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::registerServiceOwner)
                    }
                    registerServiceOwner
                },
                {
                    fn getHeartbeatConfig(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getHeartbeatConfigCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getHeartbeatConfig)
                    }
                    getHeartbeatConfig
                },
                {
                    fn getLastHeartbeat(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getLastHeartbeatCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getLastHeartbeat)
                    }
                    getLastHeartbeat
                },
                {
                    fn setMetricDefinitions(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <setMetricDefinitionsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::setMetricDefinitions)
                    }
                    setMetricDefinitions
                },
                {
                    fn registerOperator(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <registerOperatorCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::registerOperator)
                    }
                    registerOperator
                },
                {
                    fn setMetricsRecorder(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <setMetricsRecorderCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::setMetricsRecorder)
                    }
                    setMetricsRecorder
                },
                {
                    fn serviceMetrics(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <serviceMetricsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::serviceMetrics)
                    }
                    serviceMetrics
                },
                {
                    fn submitHeartbeat(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <submitHeartbeatCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::submitHeartbeat)
                    }
                    submitHeartbeat
                },
                {
                    fn DEFAULT_HEARTBEAT_INTERVAL(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <DEFAULT_HEARTBEAT_INTERVALCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::DEFAULT_HEARTBEAT_INTERVAL)
                    }
                    DEFAULT_HEARTBEAT_INTERVAL
                },
                {
                    fn metricsRecorder(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <metricsRecorderCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::metricsRecorder)
                    }
                    metricsRecorder
                },
                {
                    fn HEARTBEAT_MAX_AGE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <HEARTBEAT_MAX_AGECall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::HEARTBEAT_MAX_AGE)
                    }
                    HEARTBEAT_MAX_AGE
                },
                {
                    fn decodeMetricPairs(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <decodeMetricPairsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::decodeMetricPairs)
                    }
                    decodeMetricPairs
                },
                {
                    fn DOMAIN_SEPARATOR(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <DOMAIN_SEPARATORCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::DOMAIN_SEPARATOR)
                    }
                    DOMAIN_SEPARATOR
                },
                {
                    fn SLASH_ALERT_COOLDOWN(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <SLASH_ALERT_COOLDOWNCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::SLASH_ALERT_COOLDOWN)
                    }
                    SLASH_ALERT_COOLDOWN
                },
                {
                    fn operatorStates(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <operatorStatesCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::operatorStates)
                    }
                    operatorStates
                },
                {
                    fn getAllOperatorCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getAllOperatorCountCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getAllOperatorCount)
                    }
                    getAllOperatorCount
                },
                {
                    fn getOnlineOperators(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getOnlineOperatorsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getOnlineOperators)
                    }
                    getOnlineOperators
                },
                {
                    fn MAX_PAGE_SIZE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <MAX_PAGE_SIZECall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::MAX_PAGE_SIZE)
                    }
                    MAX_PAGE_SIZE
                },
                {
                    fn isOnline(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <isOnlineCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::isOnline)
                    }
                    isOnline
                },
                {
                    fn serviceOwners(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <serviceOwnersCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::serviceOwners)
                    }
                    serviceOwners
                },
                {
                    fn getSlashableOperators(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getSlashableOperatorsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getSlashableOperators)
                    }
                    getSlashableOperators
                },
                {
                    fn tangleCore(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <tangleCoreCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::tangleCore)
                    }
                    tangleCore
                },
                {
                    fn submitHeartbeatDirect(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <submitHeartbeatDirectCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::submitHeartbeatDirect)
                    }
                    submitHeartbeatDirect
                },
                {
                    fn MAX_METRIC_DEFINITIONS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <MAX_METRIC_DEFINITIONSCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::MAX_METRIC_DEFINITIONS)
                    }
                    MAX_METRIC_DEFINITIONS
                },
                {
                    fn isRegisteredOperator(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <isRegisteredOperatorCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::isRegisteredOperator)
                    }
                    isRegisteredOperator
                },
                {
                    fn DEFAULT_MAX_MISSED_HEARTBEATS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <DEFAULT_MAX_MISSED_HEARTBEATSCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(
                                OperatorStatusRegistryCalls::DEFAULT_MAX_MISSED_HEARTBEATS,
                            )
                    }
                    DEFAULT_MAX_MISSED_HEARTBEATS
                },
                {
                    fn getOperatorStatus(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getOperatorStatusCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getOperatorStatus)
                    }
                    getOperatorStatus
                },
                {
                    fn validateAndStoreMetrics(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <validateAndStoreMetricsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::validateAndStoreMetrics)
                    }
                    validateAndStoreMetrics
                },
                {
                    fn MAX_METRIC_NAME_LENGTH(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <MAX_METRIC_NAME_LENGTHCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::MAX_METRIC_NAME_LENGTH)
                    }
                    MAX_METRIC_NAME_LENGTH
                },
                {
                    fn renounceOwnership(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <renounceOwnershipCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::renounceOwnership)
                    }
                    renounceOwnership
                },
                {
                    fn getOperatorState(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getOperatorStateCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getOperatorState)
                    }
                    getOperatorState
                },
                {
                    fn getLastCriticalHeartbeat(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getLastCriticalHeartbeatCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getLastCriticalHeartbeat)
                    }
                    getLastCriticalHeartbeat
                },
                {
                    fn acceptOwnership(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <acceptOwnershipCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::acceptOwnership)
                    }
                    acceptOwnership
                },
                {
                    fn getOnlineOperatorCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getOnlineOperatorCountCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getOnlineOperatorCount)
                    }
                    getOnlineOperatorCount
                },
                {
                    fn getSlashableOperatorsPaginated(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getSlashableOperatorsPaginatedCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(
                                OperatorStatusRegistryCalls::getSlashableOperatorsPaginated,
                            )
                    }
                    getSlashableOperatorsPaginated
                },
                {
                    fn setSlashingOracle(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <setSlashingOracleCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::setSlashingOracle)
                    }
                    setSlashingOracle
                },
                {
                    fn owner(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <ownerCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::owner)
                    }
                    owner
                },
                {
                    fn checkOperatorsStatus(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <checkOperatorsStatusCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::checkOperatorsStatus)
                    }
                    checkOperatorsStatus
                },
                {
                    fn metricValues(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <metricValuesCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::metricValues)
                    }
                    metricValues
                },
                {
                    fn reportForSlashing(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <reportForSlashingCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::reportForSlashing)
                    }
                    reportForSlashing
                },
                {
                    fn addMetricDefinition(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <addMetricDefinitionCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::addMetricDefinition)
                    }
                    addMetricDefinition
                },
                {
                    fn goOnline(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <goOnlineCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::goOnline)
                    }
                    goOnline
                },
                {
                    fn configureHeartbeat(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <configureHeartbeatCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::configureHeartbeat)
                    }
                    configureHeartbeat
                },
                {
                    fn checkOperatorStatus(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <checkOperatorStatusCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::checkOperatorStatus)
                    }
                    checkOperatorStatus
                },
                {
                    fn getMetricDefinitions(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getMetricDefinitionsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getMetricDefinitions)
                    }
                    getMetricDefinitions
                },
                {
                    fn goOffline(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <goOfflineCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::goOffline)
                    }
                    goOffline
                },
                {
                    fn slashingOracle(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <slashingOracleCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::slashingOracle)
                    }
                    slashingOracle
                },
                {
                    fn getMetricValue(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <getMetricValueCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::getMetricValue)
                    }
                    getMetricValue
                },
                {
                    fn heartbeatConfigs(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <heartbeatConfigsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::heartbeatConfigs)
                    }
                    heartbeatConfigs
                },
                {
                    fn pendingOwner(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <pendingOwnerCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::pendingOwner)
                    }
                    pendingOwner
                },
                {
                    fn removeInactiveOperator(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <removeInactiveOperatorCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::removeInactiveOperator)
                    }
                    removeInactiveOperator
                },
                {
                    fn isHeartbeatCurrent(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <isHeartbeatCurrentCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::isHeartbeatCurrent)
                    }
                    isHeartbeatCurrent
                },
                {
                    fn transferOwnership(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <transferOwnershipCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::transferOwnership)
                    }
                    transferOwnership
                },
                {
                    fn enableCustomMetrics(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <enableCustomMetricsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::enableCustomMetrics)
                    }
                    enableCustomMetrics
                },
                {
                    fn HEARTBEAT_TYPEHASH(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <HEARTBEAT_TYPEHASHCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::HEARTBEAT_TYPEHASH)
                    }
                    HEARTBEAT_TYPEHASH
                },
                {
                    fn deregisterOperator(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryCalls> {
                        <deregisterOperatorCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryCalls::deregisterOperator)
                    }
                    deregisterOperator
                },
            ];
            let Ok(idx) = Self::SELECTORS.binary_search(&selector) else {
                return Err(
                    alloy_sol_types::Error::unknown_selector(
                        <Self as alloy_sol_types::SolInterface>::NAME,
                        selector,
                    ),
                );
            };
            DECODE_VALIDATE_SHIMS[idx](data)
        }
        #[inline]
        fn abi_encoded_size(&self) -> usize {
            match self {
                Self::DEFAULT_HEARTBEAT_INTERVAL(inner) => {
                    <DEFAULT_HEARTBEAT_INTERVALCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::DEFAULT_MAX_MISSED_HEARTBEATS(inner) => {
                    <DEFAULT_MAX_MISSED_HEARTBEATSCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::DOMAIN_SEPARATOR(inner) => {
                    <DOMAIN_SEPARATORCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::HEARTBEAT_MAX_AGE(inner) => {
                    <HEARTBEAT_MAX_AGECall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::HEARTBEAT_TYPEHASH(inner) => {
                    <HEARTBEAT_TYPEHASHCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::MAX_METRIC_DEFINITIONS(inner) => {
                    <MAX_METRIC_DEFINITIONSCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::MAX_METRIC_NAME_LENGTH(inner) => {
                    <MAX_METRIC_NAME_LENGTHCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::MAX_PAGE_SIZE(inner) => {
                    <MAX_PAGE_SIZECall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::SLASH_ALERT_COOLDOWN(inner) => {
                    <SLASH_ALERT_COOLDOWNCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::acceptOwnership(inner) => {
                    <acceptOwnershipCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::addMetricDefinition(inner) => {
                    <addMetricDefinitionCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::checkOperatorStatus(inner) => {
                    <checkOperatorStatusCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::checkOperatorsStatus(inner) => {
                    <checkOperatorsStatusCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::configureHeartbeat(inner) => {
                    <configureHeartbeatCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::decodeMetricPairs(inner) => {
                    <decodeMetricPairsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::deregisterOperator(inner) => {
                    <deregisterOperatorCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::enableCustomMetrics(inner) => {
                    <enableCustomMetricsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getAllOperatorCount(inner) => {
                    <getAllOperatorCountCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getHeartbeatConfig(inner) => {
                    <getHeartbeatConfigCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getLastCriticalHeartbeat(inner) => {
                    <getLastCriticalHeartbeatCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getLastHeartbeat(inner) => {
                    <getLastHeartbeatCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getMetricDefinitions(inner) => {
                    <getMetricDefinitionsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getMetricValue(inner) => {
                    <getMetricValueCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getOnlineOperatorCount(inner) => {
                    <getOnlineOperatorCountCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getOnlineOperators(inner) => {
                    <getOnlineOperatorsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getOperatorState(inner) => {
                    <getOperatorStateCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getOperatorStatus(inner) => {
                    <getOperatorStatusCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getSlashableOperators(inner) => {
                    <getSlashableOperatorsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getSlashableOperatorsPaginated(inner) => {
                    <getSlashableOperatorsPaginatedCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::goOffline(inner) => {
                    <goOfflineCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::goOnline(inner) => {
                    <goOnlineCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::heartbeatConfigs(inner) => {
                    <heartbeatConfigsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::isHeartbeatCurrent(inner) => {
                    <isHeartbeatCurrentCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::isOnline(inner) => {
                    <isOnlineCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::isRegisteredOperator(inner) => {
                    <isRegisteredOperatorCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::metricValues(inner) => {
                    <metricValuesCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::metricsRecorder(inner) => {
                    <metricsRecorderCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::operatorStates(inner) => {
                    <operatorStatesCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::owner(inner) => {
                    <ownerCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::pendingOwner(inner) => {
                    <pendingOwnerCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::registerOperator(inner) => {
                    <registerOperatorCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::registerServiceOwner(inner) => {
                    <registerServiceOwnerCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::removeInactiveOperator(inner) => {
                    <removeInactiveOperatorCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::renounceOwnership(inner) => {
                    <renounceOwnershipCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::reportForSlashing(inner) => {
                    <reportForSlashingCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::serviceMetrics(inner) => {
                    <serviceMetricsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::serviceOwners(inner) => {
                    <serviceOwnersCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::setMetricDefinitions(inner) => {
                    <setMetricDefinitionsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::setMetricsRecorder(inner) => {
                    <setMetricsRecorderCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::setSlashingOracle(inner) => {
                    <setSlashingOracleCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::slashingOracle(inner) => {
                    <slashingOracleCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::submitHeartbeat(inner) => {
                    <submitHeartbeatCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::submitHeartbeatDirect(inner) => {
                    <submitHeartbeatDirectCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::tangleCore(inner) => {
                    <tangleCoreCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::transferOwnership(inner) => {
                    <transferOwnershipCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::validateAndStoreMetrics(inner) => {
                    <validateAndStoreMetricsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
            }
        }
        #[inline]
        fn abi_encode_raw(&self, out: &mut alloy_sol_types::private::Vec<u8>) {
            match self {
                Self::DEFAULT_HEARTBEAT_INTERVAL(inner) => {
                    <DEFAULT_HEARTBEAT_INTERVALCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::DEFAULT_MAX_MISSED_HEARTBEATS(inner) => {
                    <DEFAULT_MAX_MISSED_HEARTBEATSCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::DOMAIN_SEPARATOR(inner) => {
                    <DOMAIN_SEPARATORCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::HEARTBEAT_MAX_AGE(inner) => {
                    <HEARTBEAT_MAX_AGECall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::HEARTBEAT_TYPEHASH(inner) => {
                    <HEARTBEAT_TYPEHASHCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::MAX_METRIC_DEFINITIONS(inner) => {
                    <MAX_METRIC_DEFINITIONSCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::MAX_METRIC_NAME_LENGTH(inner) => {
                    <MAX_METRIC_NAME_LENGTHCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::MAX_PAGE_SIZE(inner) => {
                    <MAX_PAGE_SIZECall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::SLASH_ALERT_COOLDOWN(inner) => {
                    <SLASH_ALERT_COOLDOWNCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::acceptOwnership(inner) => {
                    <acceptOwnershipCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::addMetricDefinition(inner) => {
                    <addMetricDefinitionCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::checkOperatorStatus(inner) => {
                    <checkOperatorStatusCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::checkOperatorsStatus(inner) => {
                    <checkOperatorsStatusCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::configureHeartbeat(inner) => {
                    <configureHeartbeatCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::decodeMetricPairs(inner) => {
                    <decodeMetricPairsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::deregisterOperator(inner) => {
                    <deregisterOperatorCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::enableCustomMetrics(inner) => {
                    <enableCustomMetricsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getAllOperatorCount(inner) => {
                    <getAllOperatorCountCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getHeartbeatConfig(inner) => {
                    <getHeartbeatConfigCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getLastCriticalHeartbeat(inner) => {
                    <getLastCriticalHeartbeatCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getLastHeartbeat(inner) => {
                    <getLastHeartbeatCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getMetricDefinitions(inner) => {
                    <getMetricDefinitionsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getMetricValue(inner) => {
                    <getMetricValueCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getOnlineOperatorCount(inner) => {
                    <getOnlineOperatorCountCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getOnlineOperators(inner) => {
                    <getOnlineOperatorsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getOperatorState(inner) => {
                    <getOperatorStateCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getOperatorStatus(inner) => {
                    <getOperatorStatusCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getSlashableOperators(inner) => {
                    <getSlashableOperatorsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getSlashableOperatorsPaginated(inner) => {
                    <getSlashableOperatorsPaginatedCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::goOffline(inner) => {
                    <goOfflineCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::goOnline(inner) => {
                    <goOnlineCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::heartbeatConfigs(inner) => {
                    <heartbeatConfigsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::isHeartbeatCurrent(inner) => {
                    <isHeartbeatCurrentCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::isOnline(inner) => {
                    <isOnlineCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::isRegisteredOperator(inner) => {
                    <isRegisteredOperatorCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::metricValues(inner) => {
                    <metricValuesCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::metricsRecorder(inner) => {
                    <metricsRecorderCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::operatorStates(inner) => {
                    <operatorStatesCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::owner(inner) => {
                    <ownerCall as alloy_sol_types::SolCall>::abi_encode_raw(inner, out)
                }
                Self::pendingOwner(inner) => {
                    <pendingOwnerCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::registerOperator(inner) => {
                    <registerOperatorCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::registerServiceOwner(inner) => {
                    <registerServiceOwnerCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::removeInactiveOperator(inner) => {
                    <removeInactiveOperatorCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::renounceOwnership(inner) => {
                    <renounceOwnershipCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::reportForSlashing(inner) => {
                    <reportForSlashingCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::serviceMetrics(inner) => {
                    <serviceMetricsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::serviceOwners(inner) => {
                    <serviceOwnersCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::setMetricDefinitions(inner) => {
                    <setMetricDefinitionsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::setMetricsRecorder(inner) => {
                    <setMetricsRecorderCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::setSlashingOracle(inner) => {
                    <setSlashingOracleCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::slashingOracle(inner) => {
                    <slashingOracleCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::submitHeartbeat(inner) => {
                    <submitHeartbeatCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::submitHeartbeatDirect(inner) => {
                    <submitHeartbeatDirectCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::tangleCore(inner) => {
                    <tangleCoreCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::transferOwnership(inner) => {
                    <transferOwnershipCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::validateAndStoreMetrics(inner) => {
                    <validateAndStoreMetricsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
            }
        }
    }
    ///Container for all the [`OperatorStatusRegistry`](self) custom errors.
    #[derive(Clone)]
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Debug, PartialEq, Eq, Hash)]
    pub enum OperatorStatusRegistryErrors {
        #[allow(missing_docs)]
        ECDSAInvalidSignature(ECDSAInvalidSignature),
        #[allow(missing_docs)]
        ECDSAInvalidSignatureLength(ECDSAInvalidSignatureLength),
        #[allow(missing_docs)]
        ECDSAInvalidSignatureS(ECDSAInvalidSignatureS),
        #[allow(missing_docs)]
        HeartbeatFromFuture(HeartbeatFromFuture),
        #[allow(missing_docs)]
        HeartbeatStale(HeartbeatStale),
        #[allow(missing_docs)]
        OwnableInvalidOwner(OwnableInvalidOwner),
        #[allow(missing_docs)]
        OwnableUnauthorizedAccount(OwnableUnauthorizedAccount),
    }
    impl OperatorStatusRegistryErrors {
        /// All the selectors of this enum.
        ///
        /// Note that the selectors might not be in the same order as the variants.
        /// No guarantees are made about the order of the selectors.
        ///
        /// Prefer using `SolInterface` methods instead.
        pub const SELECTORS: &'static [[u8; 4usize]] = &[
            [17u8, 140u8, 218u8, 167u8],
            [30u8, 79u8, 189u8, 247u8],
            [87u8, 234u8, 2u8, 233u8],
            [96u8, 213u8, 109u8, 212u8],
            [215u8, 139u8, 206u8, 12u8],
            [246u8, 69u8, 238u8, 223u8],
            [252u8, 230u8, 152u8, 247u8],
        ];
        /// The names of the variants in the same order as `SELECTORS`.
        pub const VARIANT_NAMES: &'static [&'static str] = &[
            ::core::stringify!(OwnableUnauthorizedAccount),
            ::core::stringify!(OwnableInvalidOwner),
            ::core::stringify!(HeartbeatFromFuture),
            ::core::stringify!(HeartbeatStale),
            ::core::stringify!(ECDSAInvalidSignatureS),
            ::core::stringify!(ECDSAInvalidSignature),
            ::core::stringify!(ECDSAInvalidSignatureLength),
        ];
        /// The signatures in the same order as `SELECTORS`.
        pub const SIGNATURES: &'static [&'static str] = &[
            <OwnableUnauthorizedAccount as alloy_sol_types::SolError>::SIGNATURE,
            <OwnableInvalidOwner as alloy_sol_types::SolError>::SIGNATURE,
            <HeartbeatFromFuture as alloy_sol_types::SolError>::SIGNATURE,
            <HeartbeatStale as alloy_sol_types::SolError>::SIGNATURE,
            <ECDSAInvalidSignatureS as alloy_sol_types::SolError>::SIGNATURE,
            <ECDSAInvalidSignature as alloy_sol_types::SolError>::SIGNATURE,
            <ECDSAInvalidSignatureLength as alloy_sol_types::SolError>::SIGNATURE,
        ];
        /// Returns the signature for the given selector, if known.
        #[inline]
        pub fn signature_by_selector(
            selector: [u8; 4usize],
        ) -> ::core::option::Option<&'static str> {
            match Self::SELECTORS.binary_search(&selector) {
                ::core::result::Result::Ok(idx) => {
                    ::core::option::Option::Some(Self::SIGNATURES[idx])
                }
                ::core::result::Result::Err(_) => ::core::option::Option::None,
            }
        }
        /// Returns the enum variant name for the given selector, if known.
        #[inline]
        pub fn name_by_selector(
            selector: [u8; 4usize],
        ) -> ::core::option::Option<&'static str> {
            let sig = Self::signature_by_selector(selector)?;
            sig.split_once('(').map(|(name, _)| name)
        }
    }
    #[automatically_derived]
    impl alloy_sol_types::SolInterface for OperatorStatusRegistryErrors {
        const NAME: &'static str = "OperatorStatusRegistryErrors";
        const MIN_DATA_LENGTH: usize = 0usize;
        const COUNT: usize = 7usize;
        #[inline]
        fn selector(&self) -> [u8; 4] {
            match self {
                Self::ECDSAInvalidSignature(_) => {
                    <ECDSAInvalidSignature as alloy_sol_types::SolError>::SELECTOR
                }
                Self::ECDSAInvalidSignatureLength(_) => {
                    <ECDSAInvalidSignatureLength as alloy_sol_types::SolError>::SELECTOR
                }
                Self::ECDSAInvalidSignatureS(_) => {
                    <ECDSAInvalidSignatureS as alloy_sol_types::SolError>::SELECTOR
                }
                Self::HeartbeatFromFuture(_) => {
                    <HeartbeatFromFuture as alloy_sol_types::SolError>::SELECTOR
                }
                Self::HeartbeatStale(_) => {
                    <HeartbeatStale as alloy_sol_types::SolError>::SELECTOR
                }
                Self::OwnableInvalidOwner(_) => {
                    <OwnableInvalidOwner as alloy_sol_types::SolError>::SELECTOR
                }
                Self::OwnableUnauthorizedAccount(_) => {
                    <OwnableUnauthorizedAccount as alloy_sol_types::SolError>::SELECTOR
                }
            }
        }
        #[inline]
        fn selector_at(i: usize) -> ::core::option::Option<[u8; 4]> {
            Self::SELECTORS.get(i).copied()
        }
        #[inline]
        fn valid_selector(selector: [u8; 4]) -> bool {
            Self::SELECTORS.binary_search(&selector).is_ok()
        }
        #[inline]
        #[allow(non_snake_case)]
        fn abi_decode_raw(
            selector: [u8; 4],
            data: &[u8],
        ) -> alloy_sol_types::Result<Self> {
            static DECODE_SHIMS: &[fn(
                &[u8],
            ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors>] = &[
                {
                    fn OwnableUnauthorizedAccount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <OwnableUnauthorizedAccount as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(
                                OperatorStatusRegistryErrors::OwnableUnauthorizedAccount,
                            )
                    }
                    OwnableUnauthorizedAccount
                },
                {
                    fn OwnableInvalidOwner(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <OwnableInvalidOwner as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::OwnableInvalidOwner)
                    }
                    OwnableInvalidOwner
                },
                {
                    fn HeartbeatFromFuture(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <HeartbeatFromFuture as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::HeartbeatFromFuture)
                    }
                    HeartbeatFromFuture
                },
                {
                    fn HeartbeatStale(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <HeartbeatStale as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::HeartbeatStale)
                    }
                    HeartbeatStale
                },
                {
                    fn ECDSAInvalidSignatureS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <ECDSAInvalidSignatureS as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::ECDSAInvalidSignatureS)
                    }
                    ECDSAInvalidSignatureS
                },
                {
                    fn ECDSAInvalidSignature(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <ECDSAInvalidSignature as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::ECDSAInvalidSignature)
                    }
                    ECDSAInvalidSignature
                },
                {
                    fn ECDSAInvalidSignatureLength(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <ECDSAInvalidSignatureLength as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(
                                OperatorStatusRegistryErrors::ECDSAInvalidSignatureLength,
                            )
                    }
                    ECDSAInvalidSignatureLength
                },
            ];
            let Ok(idx) = Self::SELECTORS.binary_search(&selector) else {
                return Err(
                    alloy_sol_types::Error::unknown_selector(
                        <Self as alloy_sol_types::SolInterface>::NAME,
                        selector,
                    ),
                );
            };
            DECODE_SHIMS[idx](data)
        }
        #[inline]
        #[allow(non_snake_case)]
        fn abi_decode_raw_validate(
            selector: [u8; 4],
            data: &[u8],
        ) -> alloy_sol_types::Result<Self> {
            static DECODE_VALIDATE_SHIMS: &[fn(
                &[u8],
            ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors>] = &[
                {
                    fn OwnableUnauthorizedAccount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <OwnableUnauthorizedAccount as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(
                                OperatorStatusRegistryErrors::OwnableUnauthorizedAccount,
                            )
                    }
                    OwnableUnauthorizedAccount
                },
                {
                    fn OwnableInvalidOwner(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <OwnableInvalidOwner as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::OwnableInvalidOwner)
                    }
                    OwnableInvalidOwner
                },
                {
                    fn HeartbeatFromFuture(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <HeartbeatFromFuture as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::HeartbeatFromFuture)
                    }
                    HeartbeatFromFuture
                },
                {
                    fn HeartbeatStale(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <HeartbeatStale as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::HeartbeatStale)
                    }
                    HeartbeatStale
                },
                {
                    fn ECDSAInvalidSignatureS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <ECDSAInvalidSignatureS as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::ECDSAInvalidSignatureS)
                    }
                    ECDSAInvalidSignatureS
                },
                {
                    fn ECDSAInvalidSignature(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <ECDSAInvalidSignature as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(OperatorStatusRegistryErrors::ECDSAInvalidSignature)
                    }
                    ECDSAInvalidSignature
                },
                {
                    fn ECDSAInvalidSignatureLength(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<OperatorStatusRegistryErrors> {
                        <ECDSAInvalidSignatureLength as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(
                                OperatorStatusRegistryErrors::ECDSAInvalidSignatureLength,
                            )
                    }
                    ECDSAInvalidSignatureLength
                },
            ];
            let Ok(idx) = Self::SELECTORS.binary_search(&selector) else {
                return Err(
                    alloy_sol_types::Error::unknown_selector(
                        <Self as alloy_sol_types::SolInterface>::NAME,
                        selector,
                    ),
                );
            };
            DECODE_VALIDATE_SHIMS[idx](data)
        }
        #[inline]
        fn abi_encoded_size(&self) -> usize {
            match self {
                Self::ECDSAInvalidSignature(inner) => {
                    <ECDSAInvalidSignature as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::ECDSAInvalidSignatureLength(inner) => {
                    <ECDSAInvalidSignatureLength as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::ECDSAInvalidSignatureS(inner) => {
                    <ECDSAInvalidSignatureS as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::HeartbeatFromFuture(inner) => {
                    <HeartbeatFromFuture as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::HeartbeatStale(inner) => {
                    <HeartbeatStale as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::OwnableInvalidOwner(inner) => {
                    <OwnableInvalidOwner as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::OwnableUnauthorizedAccount(inner) => {
                    <OwnableUnauthorizedAccount as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
            }
        }
        #[inline]
        fn abi_encode_raw(&self, out: &mut alloy_sol_types::private::Vec<u8>) {
            match self {
                Self::ECDSAInvalidSignature(inner) => {
                    <ECDSAInvalidSignature as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::ECDSAInvalidSignatureLength(inner) => {
                    <ECDSAInvalidSignatureLength as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::ECDSAInvalidSignatureS(inner) => {
                    <ECDSAInvalidSignatureS as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::HeartbeatFromFuture(inner) => {
                    <HeartbeatFromFuture as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::HeartbeatStale(inner) => {
                    <HeartbeatStale as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::OwnableInvalidOwner(inner) => {
                    <OwnableInvalidOwner as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::OwnableUnauthorizedAccount(inner) => {
                    <OwnableUnauthorizedAccount as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
            }
        }
    }
    ///Container for all the [`OperatorStatusRegistry`](self) events.
    #[derive(Clone)]
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Debug, PartialEq, Eq, Hash)]
    pub enum OperatorStatusRegistryEvents {
        #[allow(missing_docs)]
        HeartbeatConfigUpdated(HeartbeatConfigUpdated),
        #[allow(missing_docs)]
        HeartbeatReceived(HeartbeatReceived),
        #[allow(missing_docs)]
        MetricReported(MetricReported),
        #[allow(missing_docs)]
        MetricViolation(MetricViolation),
        #[allow(missing_docs)]
        OperatorCameOnline(OperatorCameOnline),
        #[allow(missing_docs)]
        OperatorDeregistered(OperatorDeregistered),
        #[allow(missing_docs)]
        OperatorRegistered(OperatorRegistered),
        #[allow(missing_docs)]
        OperatorWentOffline(OperatorWentOffline),
        #[allow(missing_docs)]
        OwnershipTransferStarted(OwnershipTransferStarted),
        #[allow(missing_docs)]
        OwnershipTransferred(OwnershipTransferred),
        #[allow(missing_docs)]
        SlashingTriggered(SlashingTriggered),
        #[allow(missing_docs)]
        StatusChanged(StatusChanged),
    }
    impl OperatorStatusRegistryEvents {
        /// All the selectors of this enum.
        ///
        /// Note that the selectors might not be in the same order as the variants.
        /// No guarantees are made about the order of the selectors.
        ///
        /// Prefer using `SolInterface` methods instead.
        pub const SELECTORS: &'static [[u8; 32usize]] = &[
            [
                8u8, 187u8, 147u8, 229u8, 68u8, 66u8, 9u8, 177u8, 81u8, 85u8, 7u8, 138u8,
                19u8, 246u8, 227u8, 65u8, 41u8, 157u8, 116u8, 141u8, 12u8, 41u8, 159u8,
                114u8, 44u8, 156u8, 188u8, 7u8, 35u8, 240u8, 254u8, 158u8,
            ],
            [
                30u8, 41u8, 9u8, 207u8, 69u8, 215u8, 12u8, 240u8, 3u8, 243u8, 52u8,
                183u8, 60u8, 147u8, 51u8, 12u8, 231u8, 229u8, 114u8, 120u8, 45u8, 252u8,
                130u8, 250u8, 183u8, 157u8, 235u8, 136u8, 85u8, 167u8, 199u8, 145u8,
            ],
            [
                34u8, 136u8, 36u8, 184u8, 108u8, 37u8, 100u8, 105u8, 18u8, 95u8, 82u8,
                92u8, 225u8, 140u8, 108u8, 45u8, 10u8, 158u8, 19u8, 61u8, 19u8, 184u8,
                236u8, 122u8, 44u8, 150u8, 161u8, 147u8, 176u8, 194u8, 138u8, 9u8,
            ],
            [
                35u8, 237u8, 2u8, 189u8, 54u8, 5u8, 189u8, 234u8, 106u8, 138u8, 250u8,
                118u8, 196u8, 111u8, 0u8, 210u8, 116u8, 134u8, 11u8, 166u8, 206u8, 169u8,
                128u8, 242u8, 88u8, 91u8, 105u8, 109u8, 249u8, 225u8, 130u8, 189u8,
            ],
            [
                56u8, 209u8, 107u8, 140u8, 172u8, 34u8, 217u8, 159u8, 199u8, 193u8, 36u8,
                185u8, 205u8, 13u8, 226u8, 211u8, 250u8, 31u8, 174u8, 244u8, 32u8, 191u8,
                231u8, 145u8, 216u8, 195u8, 98u8, 215u8, 101u8, 226u8, 39u8, 0u8,
            ],
            [
                68u8, 253u8, 50u8, 182u8, 119u8, 112u8, 76u8, 230u8, 142u8, 119u8, 99u8,
                137u8, 124u8, 73u8, 115u8, 59u8, 143u8, 82u8, 137u8, 1u8, 138u8, 198u8,
                10u8, 92u8, 146u8, 104u8, 2u8, 214u8, 55u8, 89u8, 219u8, 77u8,
            ],
            [
                101u8, 137u8, 24u8, 227u8, 20u8, 127u8, 19u8, 221u8, 6u8, 142u8, 194u8,
                20u8, 55u8, 180u8, 194u8, 92u8, 33u8, 104u8, 42u8, 141u8, 194u8, 18u8,
                147u8, 72u8, 103u8, 30u8, 173u8, 0u8, 13u8, 179u8, 231u8, 185u8,
            ],
            [
                139u8, 224u8, 7u8, 156u8, 83u8, 22u8, 89u8, 20u8, 19u8, 68u8, 205u8,
                31u8, 208u8, 164u8, 242u8, 132u8, 25u8, 73u8, 127u8, 151u8, 34u8, 163u8,
                218u8, 175u8, 227u8, 180u8, 24u8, 111u8, 107u8, 100u8, 87u8, 224u8,
            ],
            [
                142u8, 45u8, 136u8, 121u8, 90u8, 60u8, 102u8, 113u8, 154u8, 40u8, 118u8,
                88u8, 203u8, 246u8, 139u8, 62u8, 178u8, 184u8, 225u8, 131u8, 203u8, 24u8,
                244u8, 111u8, 72u8, 19u8, 145u8, 63u8, 200u8, 170u8, 252u8, 75u8,
            ],
            [
                201u8, 89u8, 158u8, 217u8, 98u8, 98u8, 74u8, 133u8, 142u8, 197u8, 155u8,
                174u8, 14u8, 216u8, 108u8, 117u8, 244u8, 219u8, 101u8, 254u8, 4u8, 87u8,
                0u8, 33u8, 39u8, 126u8, 219u8, 237u8, 208u8, 78u8, 165u8, 100u8,
            ],
            [
                201u8, 134u8, 44u8, 95u8, 2u8, 238u8, 251u8, 220u8, 234u8, 1u8, 194u8,
                7u8, 174u8, 83u8, 142u8, 29u8, 48u8, 77u8, 201u8, 48u8, 38u8, 135u8,
                15u8, 72u8, 149u8, 30u8, 72u8, 160u8, 244u8, 200u8, 71u8, 12u8,
            ],
            [
                224u8, 143u8, 66u8, 137u8, 108u8, 227u8, 174u8, 194u8, 255u8, 125u8,
                169u8, 90u8, 0u8, 55u8, 47u8, 51u8, 207u8, 103u8, 126u8, 117u8, 173u8,
                96u8, 37u8, 144u8, 131u8, 42u8, 141u8, 255u8, 205u8, 173u8, 99u8, 21u8,
            ],
        ];
        /// The names of the variants in the same order as `SELECTORS`.
        pub const VARIANT_NAMES: &'static [&'static str] = &[
            ::core::stringify!(OperatorDeregistered),
            ::core::stringify!(SlashingTriggered),
            ::core::stringify!(StatusChanged),
            ::core::stringify!(MetricReported),
            ::core::stringify!(OwnershipTransferStarted),
            ::core::stringify!(OperatorWentOffline),
            ::core::stringify!(HeartbeatReceived),
            ::core::stringify!(OwnershipTransferred),
            ::core::stringify!(OperatorRegistered),
            ::core::stringify!(HeartbeatConfigUpdated),
            ::core::stringify!(OperatorCameOnline),
            ::core::stringify!(MetricViolation),
        ];
        /// The signatures in the same order as `SELECTORS`.
        pub const SIGNATURES: &'static [&'static str] = &[
            <OperatorDeregistered as alloy_sol_types::SolEvent>::SIGNATURE,
            <SlashingTriggered as alloy_sol_types::SolEvent>::SIGNATURE,
            <StatusChanged as alloy_sol_types::SolEvent>::SIGNATURE,
            <MetricReported as alloy_sol_types::SolEvent>::SIGNATURE,
            <OwnershipTransferStarted as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorWentOffline as alloy_sol_types::SolEvent>::SIGNATURE,
            <HeartbeatReceived as alloy_sol_types::SolEvent>::SIGNATURE,
            <OwnershipTransferred as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorRegistered as alloy_sol_types::SolEvent>::SIGNATURE,
            <HeartbeatConfigUpdated as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorCameOnline as alloy_sol_types::SolEvent>::SIGNATURE,
            <MetricViolation as alloy_sol_types::SolEvent>::SIGNATURE,
        ];
        /// Returns the signature for the given selector, if known.
        #[inline]
        pub fn signature_by_selector(
            selector: [u8; 32usize],
        ) -> ::core::option::Option<&'static str> {
            match Self::SELECTORS.binary_search(&selector) {
                ::core::result::Result::Ok(idx) => {
                    ::core::option::Option::Some(Self::SIGNATURES[idx])
                }
                ::core::result::Result::Err(_) => ::core::option::Option::None,
            }
        }
        /// Returns the enum variant name for the given selector, if known.
        #[inline]
        pub fn name_by_selector(
            selector: [u8; 32usize],
        ) -> ::core::option::Option<&'static str> {
            let sig = Self::signature_by_selector(selector)?;
            sig.split_once('(').map(|(name, _)| name)
        }
    }
    #[automatically_derived]
    impl alloy_sol_types::SolEventInterface for OperatorStatusRegistryEvents {
        const NAME: &'static str = "OperatorStatusRegistryEvents";
        const COUNT: usize = 12usize;
        fn decode_raw_log(
            topics: &[alloy_sol_types::Word],
            data: &[u8],
        ) -> alloy_sol_types::Result<Self> {
            match topics.first().copied() {
                Some(
                    <HeartbeatConfigUpdated as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <HeartbeatConfigUpdated as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::HeartbeatConfigUpdated)
                }
                Some(
                    <HeartbeatReceived as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <HeartbeatReceived as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::HeartbeatReceived)
                }
                Some(<MetricReported as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <MetricReported as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::MetricReported)
                }
                Some(<MetricViolation as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <MetricViolation as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::MetricViolation)
                }
                Some(
                    <OperatorCameOnline as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorCameOnline as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorCameOnline)
                }
                Some(
                    <OperatorDeregistered as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorDeregistered as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorDeregistered)
                }
                Some(
                    <OperatorRegistered as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorRegistered as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorRegistered)
                }
                Some(
                    <OperatorWentOffline as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorWentOffline as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorWentOffline)
                }
                Some(
                    <OwnershipTransferStarted as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OwnershipTransferStarted as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OwnershipTransferStarted)
                }
                Some(
                    <OwnershipTransferred as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OwnershipTransferred as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OwnershipTransferred)
                }
                Some(
                    <SlashingTriggered as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <SlashingTriggered as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::SlashingTriggered)
                }
                Some(<StatusChanged as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <StatusChanged as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::StatusChanged)
                }
                _ => {
                    alloy_sol_types::private::Err(alloy_sol_types::Error::InvalidLog {
                        name: <Self as alloy_sol_types::SolEventInterface>::NAME,
                        log: alloy_sol_types::private::Box::new(
                            alloy_sol_types::private::LogData::new_unchecked(
                                topics.to_vec(),
                                data.to_vec().into(),
                            ),
                        ),
                    })
                }
            }
        }
    }
    #[automatically_derived]
    impl alloy_sol_types::private::IntoLogData for OperatorStatusRegistryEvents {
        fn to_log_data(&self) -> alloy_sol_types::private::LogData {
            match self {
                Self::HeartbeatConfigUpdated(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::HeartbeatReceived(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::MetricReported(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::MetricViolation(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorCameOnline(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorDeregistered(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorRegistered(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorWentOffline(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OwnershipTransferStarted(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OwnershipTransferred(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::SlashingTriggered(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::StatusChanged(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
            }
        }
        fn into_log_data(self) -> alloy_sol_types::private::LogData {
            match self {
                Self::HeartbeatConfigUpdated(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::HeartbeatReceived(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::MetricReported(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::MetricViolation(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorCameOnline(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorDeregistered(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorRegistered(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorWentOffline(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OwnershipTransferStarted(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OwnershipTransferred(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::SlashingTriggered(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::StatusChanged(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
            }
        }
    }
    use alloy::contract as alloy_contract;
    /**Creates a new wrapper around an on-chain [`OperatorStatusRegistry`](self) contract instance.

See the [wrapper's documentation](`OperatorStatusRegistryInstance`) for more details.*/
    #[inline]
    pub const fn new<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(
        address: alloy_sol_types::private::Address,
        __provider: P,
    ) -> OperatorStatusRegistryInstance<P, N> {
        OperatorStatusRegistryInstance::<P, N>::new(address, __provider)
    }
    /**Deploys this contract using the given `provider` and constructor arguments, if any.

Returns a new instance of the contract, if the deployment was successful.

For more fine-grained control over the deployment process, use [`deploy_builder`] instead.*/
    #[inline]
    pub fn deploy<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(
        __provider: P,
        _tangleCore: alloy::sol_types::private::Address,
        initialOwner: alloy::sol_types::private::Address,
    ) -> impl ::core::future::Future<
        Output = alloy_contract::Result<OperatorStatusRegistryInstance<P, N>>,
    > {
        OperatorStatusRegistryInstance::<
            P,
            N,
        >::deploy(__provider, _tangleCore, initialOwner)
    }
    /**Creates a `RawCallBuilder` for deploying this contract using the given `provider`
and constructor arguments, if any.

This is a simple wrapper around creating a `RawCallBuilder` with the data set to
the bytecode concatenated with the constructor's ABI-encoded arguments.*/
    #[inline]
    pub fn deploy_builder<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(
        __provider: P,
        _tangleCore: alloy::sol_types::private::Address,
        initialOwner: alloy::sol_types::private::Address,
    ) -> alloy_contract::RawCallBuilder<P, N> {
        OperatorStatusRegistryInstance::<
            P,
            N,
        >::deploy_builder(__provider, _tangleCore, initialOwner)
    }
    /**A [`OperatorStatusRegistry`](self) instance.

Contains type-safe methods for interacting with an on-chain instance of the
[`OperatorStatusRegistry`](self) contract located at a given `address`, using a given
provider `P`.

If the contract bytecode is available (see the [`sol!`](alloy_sol_types::sol!)
documentation on how to provide it), the `deploy` and `deploy_builder` methods can
be used to deploy a new instance of the contract.

See the [module-level documentation](self) for all the available methods.*/
    #[derive(Clone)]
    pub struct OperatorStatusRegistryInstance<P, N = alloy_contract::private::Ethereum> {
        address: alloy_sol_types::private::Address,
        provider: P,
        _network: ::core::marker::PhantomData<N>,
    }
    #[automatically_derived]
    impl<P, N> ::core::fmt::Debug for OperatorStatusRegistryInstance<P, N> {
        #[inline]
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            f.debug_tuple("OperatorStatusRegistryInstance").field(&self.address).finish()
        }
    }
    /// Instantiation and getters/setters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > OperatorStatusRegistryInstance<P, N> {
        /**Creates a new wrapper around an on-chain [`OperatorStatusRegistry`](self) contract instance.

See the [wrapper's documentation](`OperatorStatusRegistryInstance`) for more details.*/
        #[inline]
        pub const fn new(
            address: alloy_sol_types::private::Address,
            __provider: P,
        ) -> Self {
            Self {
                address,
                provider: __provider,
                _network: ::core::marker::PhantomData,
            }
        }
        /**Deploys this contract using the given `provider` and constructor arguments, if any.

Returns a new instance of the contract, if the deployment was successful.

For more fine-grained control over the deployment process, use [`deploy_builder`] instead.*/
        #[inline]
        pub async fn deploy(
            __provider: P,
            _tangleCore: alloy::sol_types::private::Address,
            initialOwner: alloy::sol_types::private::Address,
        ) -> alloy_contract::Result<OperatorStatusRegistryInstance<P, N>> {
            let call_builder = Self::deploy_builder(
                __provider,
                _tangleCore,
                initialOwner,
            );
            let contract_address = call_builder.deploy().await?;
            Ok(Self::new(contract_address, call_builder.provider))
        }
        /**Creates a `RawCallBuilder` for deploying this contract using the given `provider`
and constructor arguments, if any.

This is a simple wrapper around creating a `RawCallBuilder` with the data set to
the bytecode concatenated with the constructor's ABI-encoded arguments.*/
        #[inline]
        pub fn deploy_builder(
            __provider: P,
            _tangleCore: alloy::sol_types::private::Address,
            initialOwner: alloy::sol_types::private::Address,
        ) -> alloy_contract::RawCallBuilder<P, N> {
            alloy_contract::RawCallBuilder::new_raw_deploy(
                __provider,
                [
                    &BYTECODE[..],
                    &alloy_sol_types::SolConstructor::abi_encode(
                        &constructorCall {
                            _tangleCore,
                            initialOwner,
                        },
                    )[..],
                ]
                    .concat()
                    .into(),
            )
        }
        /// Returns a reference to the address.
        #[inline]
        pub const fn address(&self) -> &alloy_sol_types::private::Address {
            &self.address
        }
        /// Sets the address.
        #[inline]
        pub fn set_address(&mut self, address: alloy_sol_types::private::Address) {
            self.address = address;
        }
        /// Sets the address and returns `self`.
        pub fn at(mut self, address: alloy_sol_types::private::Address) -> Self {
            self.set_address(address);
            self
        }
        /// Returns a reference to the provider.
        #[inline]
        pub const fn provider(&self) -> &P {
            &self.provider
        }
    }
    impl<P: ::core::clone::Clone, N> OperatorStatusRegistryInstance<&P, N> {
        /// Clones the provider and returns a new instance with the cloned provider.
        #[inline]
        pub fn with_cloned_provider(self) -> OperatorStatusRegistryInstance<P, N> {
            OperatorStatusRegistryInstance {
                address: self.address,
                provider: ::core::clone::Clone::clone(&self.provider),
                _network: ::core::marker::PhantomData,
            }
        }
    }
    /// Function calls.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > OperatorStatusRegistryInstance<P, N> {
        /// Creates a new call builder using this contract instance's provider and address.
        ///
        /// Note that the call can be any function call, not just those defined in this
        /// contract. Prefer using the other methods for building type-safe contract calls.
        pub fn call_builder<C: alloy_sol_types::SolCall>(
            &self,
            call: &C,
        ) -> alloy_contract::SolCallBuilder<&P, C, N> {
            alloy_contract::SolCallBuilder::new_sol(&self.provider, &self.address, call)
        }
        ///Creates a new call builder for the [`DEFAULT_HEARTBEAT_INTERVAL`] function.
        pub fn DEFAULT_HEARTBEAT_INTERVAL(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, DEFAULT_HEARTBEAT_INTERVALCall, N> {
            self.call_builder(&DEFAULT_HEARTBEAT_INTERVALCall)
        }
        ///Creates a new call builder for the [`DEFAULT_MAX_MISSED_HEARTBEATS`] function.
        pub fn DEFAULT_MAX_MISSED_HEARTBEATS(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, DEFAULT_MAX_MISSED_HEARTBEATSCall, N> {
            self.call_builder(&DEFAULT_MAX_MISSED_HEARTBEATSCall)
        }
        ///Creates a new call builder for the [`DOMAIN_SEPARATOR`] function.
        pub fn DOMAIN_SEPARATOR(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, DOMAIN_SEPARATORCall, N> {
            self.call_builder(&DOMAIN_SEPARATORCall)
        }
        ///Creates a new call builder for the [`HEARTBEAT_MAX_AGE`] function.
        pub fn HEARTBEAT_MAX_AGE(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, HEARTBEAT_MAX_AGECall, N> {
            self.call_builder(&HEARTBEAT_MAX_AGECall)
        }
        ///Creates a new call builder for the [`HEARTBEAT_TYPEHASH`] function.
        pub fn HEARTBEAT_TYPEHASH(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, HEARTBEAT_TYPEHASHCall, N> {
            self.call_builder(&HEARTBEAT_TYPEHASHCall)
        }
        ///Creates a new call builder for the [`MAX_METRIC_DEFINITIONS`] function.
        pub fn MAX_METRIC_DEFINITIONS(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, MAX_METRIC_DEFINITIONSCall, N> {
            self.call_builder(&MAX_METRIC_DEFINITIONSCall)
        }
        ///Creates a new call builder for the [`MAX_METRIC_NAME_LENGTH`] function.
        pub fn MAX_METRIC_NAME_LENGTH(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, MAX_METRIC_NAME_LENGTHCall, N> {
            self.call_builder(&MAX_METRIC_NAME_LENGTHCall)
        }
        ///Creates a new call builder for the [`MAX_PAGE_SIZE`] function.
        pub fn MAX_PAGE_SIZE(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, MAX_PAGE_SIZECall, N> {
            self.call_builder(&MAX_PAGE_SIZECall)
        }
        ///Creates a new call builder for the [`SLASH_ALERT_COOLDOWN`] function.
        pub fn SLASH_ALERT_COOLDOWN(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, SLASH_ALERT_COOLDOWNCall, N> {
            self.call_builder(&SLASH_ALERT_COOLDOWNCall)
        }
        ///Creates a new call builder for the [`acceptOwnership`] function.
        pub fn acceptOwnership(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, acceptOwnershipCall, N> {
            self.call_builder(&acceptOwnershipCall)
        }
        ///Creates a new call builder for the [`addMetricDefinition`] function.
        pub fn addMetricDefinition(
            &self,
            serviceId: u64,
            name: alloy::sol_types::private::String,
            minValue: alloy::sol_types::private::primitives::aliases::U256,
            maxValue: alloy::sol_types::private::primitives::aliases::U256,
            required: bool,
        ) -> alloy_contract::SolCallBuilder<&P, addMetricDefinitionCall, N> {
            self.call_builder(
                &addMetricDefinitionCall {
                    serviceId,
                    name,
                    minValue,
                    maxValue,
                    required,
                },
            )
        }
        ///Creates a new call builder for the [`checkOperatorStatus`] function.
        pub fn checkOperatorStatus(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, checkOperatorStatusCall, N> {
            self.call_builder(
                &checkOperatorStatusCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`checkOperatorsStatus`] function.
        pub fn checkOperatorsStatus(
            &self,
            serviceId: u64,
            operators: alloy::sol_types::private::Vec<alloy::sol_types::private::Address>,
        ) -> alloy_contract::SolCallBuilder<&P, checkOperatorsStatusCall, N> {
            self.call_builder(
                &checkOperatorsStatusCall {
                    serviceId,
                    operators,
                },
            )
        }
        ///Creates a new call builder for the [`configureHeartbeat`] function.
        pub fn configureHeartbeat(
            &self,
            serviceId: u64,
            interval: u64,
            maxMissed: u8,
        ) -> alloy_contract::SolCallBuilder<&P, configureHeartbeatCall, N> {
            self.call_builder(
                &configureHeartbeatCall {
                    serviceId,
                    interval,
                    maxMissed,
                },
            )
        }
        ///Creates a new call builder for the [`decodeMetricPairs`] function.
        pub fn decodeMetricPairs(
            &self,
            payload: alloy::sol_types::private::Bytes,
        ) -> alloy_contract::SolCallBuilder<&P, decodeMetricPairsCall, N> {
            self.call_builder(&decodeMetricPairsCall { payload })
        }
        ///Creates a new call builder for the [`deregisterOperator`] function.
        pub fn deregisterOperator(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, deregisterOperatorCall, N> {
            self.call_builder(
                &deregisterOperatorCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`enableCustomMetrics`] function.
        pub fn enableCustomMetrics(
            &self,
            serviceId: u64,
            enabled: bool,
        ) -> alloy_contract::SolCallBuilder<&P, enableCustomMetricsCall, N> {
            self.call_builder(
                &enableCustomMetricsCall {
                    serviceId,
                    enabled,
                },
            )
        }
        ///Creates a new call builder for the [`getAllOperatorCount`] function.
        pub fn getAllOperatorCount(
            &self,
            serviceId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, getAllOperatorCountCall, N> {
            self.call_builder(
                &getAllOperatorCountCall {
                    serviceId,
                },
            )
        }
        ///Creates a new call builder for the [`getHeartbeatConfig`] function.
        pub fn getHeartbeatConfig(
            &self,
            serviceId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, getHeartbeatConfigCall, N> {
            self.call_builder(
                &getHeartbeatConfigCall {
                    serviceId,
                },
            )
        }
        ///Creates a new call builder for the [`getLastCriticalHeartbeat`] function.
        pub fn getLastCriticalHeartbeat(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getLastCriticalHeartbeatCall, N> {
            self.call_builder(
                &getLastCriticalHeartbeatCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`getLastHeartbeat`] function.
        pub fn getLastHeartbeat(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getLastHeartbeatCall, N> {
            self.call_builder(
                &getLastHeartbeatCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`getMetricDefinitions`] function.
        pub fn getMetricDefinitions(
            &self,
            serviceId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, getMetricDefinitionsCall, N> {
            self.call_builder(
                &getMetricDefinitionsCall {
                    serviceId,
                },
            )
        }
        ///Creates a new call builder for the [`getMetricValue`] function.
        pub fn getMetricValue(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
            metricName: alloy::sol_types::private::String,
        ) -> alloy_contract::SolCallBuilder<&P, getMetricValueCall, N> {
            self.call_builder(
                &getMetricValueCall {
                    serviceId,
                    operator,
                    metricName,
                },
            )
        }
        ///Creates a new call builder for the [`getOnlineOperatorCount`] function.
        pub fn getOnlineOperatorCount(
            &self,
            serviceId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, getOnlineOperatorCountCall, N> {
            self.call_builder(
                &getOnlineOperatorCountCall {
                    serviceId,
                },
            )
        }
        ///Creates a new call builder for the [`getOnlineOperators`] function.
        pub fn getOnlineOperators(
            &self,
            serviceId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, getOnlineOperatorsCall, N> {
            self.call_builder(
                &getOnlineOperatorsCall {
                    serviceId,
                },
            )
        }
        ///Creates a new call builder for the [`getOperatorState`] function.
        pub fn getOperatorState(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getOperatorStateCall, N> {
            self.call_builder(
                &getOperatorStateCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`getOperatorStatus`] function.
        pub fn getOperatorStatus(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getOperatorStatusCall, N> {
            self.call_builder(
                &getOperatorStatusCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`getSlashableOperators`] function.
        pub fn getSlashableOperators(
            &self,
            serviceId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, getSlashableOperatorsCall, N> {
            self.call_builder(
                &getSlashableOperatorsCall {
                    serviceId,
                },
            )
        }
        ///Creates a new call builder for the [`getSlashableOperatorsPaginated`] function.
        pub fn getSlashableOperatorsPaginated(
            &self,
            serviceId: u64,
            offset: alloy::sol_types::private::primitives::aliases::U256,
            limit: alloy::sol_types::private::primitives::aliases::U256,
        ) -> alloy_contract::SolCallBuilder<&P, getSlashableOperatorsPaginatedCall, N> {
            self.call_builder(
                &getSlashableOperatorsPaginatedCall {
                    serviceId,
                    offset,
                    limit,
                },
            )
        }
        ///Creates a new call builder for the [`goOffline`] function.
        pub fn goOffline(
            &self,
            serviceId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, goOfflineCall, N> {
            self.call_builder(&goOfflineCall { serviceId })
        }
        ///Creates a new call builder for the [`goOnline`] function.
        pub fn goOnline(
            &self,
            serviceId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, goOnlineCall, N> {
            self.call_builder(&goOnlineCall { serviceId })
        }
        ///Creates a new call builder for the [`heartbeatConfigs`] function.
        pub fn heartbeatConfigs(
            &self,
            _0: u64,
        ) -> alloy_contract::SolCallBuilder<&P, heartbeatConfigsCall, N> {
            self.call_builder(&heartbeatConfigsCall(_0))
        }
        ///Creates a new call builder for the [`isHeartbeatCurrent`] function.
        pub fn isHeartbeatCurrent(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, isHeartbeatCurrentCall, N> {
            self.call_builder(
                &isHeartbeatCurrentCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`isOnline`] function.
        pub fn isOnline(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, isOnlineCall, N> {
            self.call_builder(
                &isOnlineCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`isRegisteredOperator`] function.
        pub fn isRegisteredOperator(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, isRegisteredOperatorCall, N> {
            self.call_builder(
                &isRegisteredOperatorCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`metricValues`] function.
        pub fn metricValues(
            &self,
            _0: u64,
            _1: alloy::sol_types::private::Address,
            _2: alloy::sol_types::private::String,
        ) -> alloy_contract::SolCallBuilder<&P, metricValuesCall, N> {
            self.call_builder(&metricValuesCall { _0, _1, _2 })
        }
        ///Creates a new call builder for the [`metricsRecorder`] function.
        pub fn metricsRecorder(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, metricsRecorderCall, N> {
            self.call_builder(&metricsRecorderCall)
        }
        ///Creates a new call builder for the [`operatorStates`] function.
        pub fn operatorStates(
            &self,
            _0: u64,
            _1: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, operatorStatesCall, N> {
            self.call_builder(&operatorStatesCall { _0, _1 })
        }
        ///Creates a new call builder for the [`owner`] function.
        pub fn owner(&self) -> alloy_contract::SolCallBuilder<&P, ownerCall, N> {
            self.call_builder(&ownerCall)
        }
        ///Creates a new call builder for the [`pendingOwner`] function.
        pub fn pendingOwner(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, pendingOwnerCall, N> {
            self.call_builder(&pendingOwnerCall)
        }
        ///Creates a new call builder for the [`registerOperator`] function.
        pub fn registerOperator(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, registerOperatorCall, N> {
            self.call_builder(
                &registerOperatorCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`registerServiceOwner`] function.
        pub fn registerServiceOwner(
            &self,
            serviceId: u64,
            owner: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, registerServiceOwnerCall, N> {
            self.call_builder(
                &registerServiceOwnerCall {
                    serviceId,
                    owner,
                },
            )
        }
        ///Creates a new call builder for the [`removeInactiveOperator`] function.
        pub fn removeInactiveOperator(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, removeInactiveOperatorCall, N> {
            self.call_builder(
                &removeInactiveOperatorCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`renounceOwnership`] function.
        pub fn renounceOwnership(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, renounceOwnershipCall, N> {
            self.call_builder(&renounceOwnershipCall)
        }
        ///Creates a new call builder for the [`reportForSlashing`] function.
        pub fn reportForSlashing(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
            reason: alloy::sol_types::private::String,
        ) -> alloy_contract::SolCallBuilder<&P, reportForSlashingCall, N> {
            self.call_builder(
                &reportForSlashingCall {
                    serviceId,
                    operator,
                    reason,
                },
            )
        }
        ///Creates a new call builder for the [`serviceMetrics`] function.
        pub fn serviceMetrics(
            &self,
            _0: u64,
            _1: alloy::sol_types::private::primitives::aliases::U256,
        ) -> alloy_contract::SolCallBuilder<&P, serviceMetricsCall, N> {
            self.call_builder(&serviceMetricsCall { _0, _1 })
        }
        ///Creates a new call builder for the [`serviceOwners`] function.
        pub fn serviceOwners(
            &self,
            _0: u64,
        ) -> alloy_contract::SolCallBuilder<&P, serviceOwnersCall, N> {
            self.call_builder(&serviceOwnersCall(_0))
        }
        ///Creates a new call builder for the [`setMetricDefinitions`] function.
        pub fn setMetricDefinitions(
            &self,
            serviceId: u64,
            definitions: alloy::sol_types::private::Vec<
                <IOperatorStatusRegistry::MetricDefinition as alloy::sol_types::SolType>::RustType,
            >,
        ) -> alloy_contract::SolCallBuilder<&P, setMetricDefinitionsCall, N> {
            self.call_builder(
                &setMetricDefinitionsCall {
                    serviceId,
                    definitions,
                },
            )
        }
        ///Creates a new call builder for the [`setMetricsRecorder`] function.
        pub fn setMetricsRecorder(
            &self,
            recorder: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, setMetricsRecorderCall, N> {
            self.call_builder(&setMetricsRecorderCall { recorder })
        }
        ///Creates a new call builder for the [`setSlashingOracle`] function.
        pub fn setSlashingOracle(
            &self,
            oracle: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, setSlashingOracleCall, N> {
            self.call_builder(&setSlashingOracleCall { oracle })
        }
        ///Creates a new call builder for the [`slashingOracle`] function.
        pub fn slashingOracle(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, slashingOracleCall, N> {
            self.call_builder(&slashingOracleCall)
        }
        ///Creates a new call builder for the [`submitHeartbeat`] function.
        pub fn submitHeartbeat(
            &self,
            serviceId: u64,
            blueprintId: u64,
            statusCode: u8,
            metrics: alloy::sol_types::private::Bytes,
            timestamp: u64,
            signature: alloy::sol_types::private::Bytes,
        ) -> alloy_contract::SolCallBuilder<&P, submitHeartbeatCall, N> {
            self.call_builder(
                &submitHeartbeatCall {
                    serviceId,
                    blueprintId,
                    statusCode,
                    metrics,
                    timestamp,
                    signature,
                },
            )
        }
        ///Creates a new call builder for the [`submitHeartbeatDirect`] function.
        pub fn submitHeartbeatDirect(
            &self,
            serviceId: u64,
            blueprintId: u64,
            statusCode: u8,
            metrics: alloy::sol_types::private::Bytes,
        ) -> alloy_contract::SolCallBuilder<&P, submitHeartbeatDirectCall, N> {
            self.call_builder(
                &submitHeartbeatDirectCall {
                    serviceId,
                    blueprintId,
                    statusCode,
                    metrics,
                },
            )
        }
        ///Creates a new call builder for the [`tangleCore`] function.
        pub fn tangleCore(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, tangleCoreCall, N> {
            self.call_builder(&tangleCoreCall)
        }
        ///Creates a new call builder for the [`transferOwnership`] function.
        pub fn transferOwnership(
            &self,
            newOwner: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, transferOwnershipCall, N> {
            self.call_builder(&transferOwnershipCall { newOwner })
        }
        ///Creates a new call builder for the [`validateAndStoreMetrics`] function.
        pub fn validateAndStoreMetrics(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
            pairs: alloy::sol_types::private::Vec<
                <IOperatorStatusRegistry::MetricPair as alloy::sol_types::SolType>::RustType,
            >,
            pairsLen: alloy::sol_types::private::primitives::aliases::U256,
        ) -> alloy_contract::SolCallBuilder<&P, validateAndStoreMetricsCall, N> {
            self.call_builder(
                &validateAndStoreMetricsCall {
                    serviceId,
                    operator,
                    pairs,
                    pairsLen,
                },
            )
        }
    }
    /// Event filters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > OperatorStatusRegistryInstance<P, N> {
        /// Creates a new event filter using this contract instance's provider and address.
        ///
        /// Note that the type can be any event, not just those defined in this contract.
        /// Prefer using the other methods for building type-safe event filters.
        pub fn event_filter<E: alloy_sol_types::SolEvent>(
            &self,
        ) -> alloy_contract::Event<&P, E, N> {
            alloy_contract::Event::new_sol(&self.provider, &self.address)
        }
        ///Creates a new event filter for the [`HeartbeatConfigUpdated`] event.
        pub fn HeartbeatConfigUpdated_filter(
            &self,
        ) -> alloy_contract::Event<&P, HeartbeatConfigUpdated, N> {
            self.event_filter::<HeartbeatConfigUpdated>()
        }
        ///Creates a new event filter for the [`HeartbeatReceived`] event.
        pub fn HeartbeatReceived_filter(
            &self,
        ) -> alloy_contract::Event<&P, HeartbeatReceived, N> {
            self.event_filter::<HeartbeatReceived>()
        }
        ///Creates a new event filter for the [`MetricReported`] event.
        pub fn MetricReported_filter(
            &self,
        ) -> alloy_contract::Event<&P, MetricReported, N> {
            self.event_filter::<MetricReported>()
        }
        ///Creates a new event filter for the [`MetricViolation`] event.
        pub fn MetricViolation_filter(
            &self,
        ) -> alloy_contract::Event<&P, MetricViolation, N> {
            self.event_filter::<MetricViolation>()
        }
        ///Creates a new event filter for the [`OperatorCameOnline`] event.
        pub fn OperatorCameOnline_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorCameOnline, N> {
            self.event_filter::<OperatorCameOnline>()
        }
        ///Creates a new event filter for the [`OperatorDeregistered`] event.
        pub fn OperatorDeregistered_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorDeregistered, N> {
            self.event_filter::<OperatorDeregistered>()
        }
        ///Creates a new event filter for the [`OperatorRegistered`] event.
        pub fn OperatorRegistered_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorRegistered, N> {
            self.event_filter::<OperatorRegistered>()
        }
        ///Creates a new event filter for the [`OperatorWentOffline`] event.
        pub fn OperatorWentOffline_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorWentOffline, N> {
            self.event_filter::<OperatorWentOffline>()
        }
        ///Creates a new event filter for the [`OwnershipTransferStarted`] event.
        pub fn OwnershipTransferStarted_filter(
            &self,
        ) -> alloy_contract::Event<&P, OwnershipTransferStarted, N> {
            self.event_filter::<OwnershipTransferStarted>()
        }
        ///Creates a new event filter for the [`OwnershipTransferred`] event.
        pub fn OwnershipTransferred_filter(
            &self,
        ) -> alloy_contract::Event<&P, OwnershipTransferred, N> {
            self.event_filter::<OwnershipTransferred>()
        }
        ///Creates a new event filter for the [`SlashingTriggered`] event.
        pub fn SlashingTriggered_filter(
            &self,
        ) -> alloy_contract::Event<&P, SlashingTriggered, N> {
            self.event_filter::<SlashingTriggered>()
        }
        ///Creates a new event filter for the [`StatusChanged`] event.
        pub fn StatusChanged_filter(
            &self,
        ) -> alloy_contract::Event<&P, StatusChanged, N> {
            self.event_filter::<StatusChanged>()
        }
    }
}
