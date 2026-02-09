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
    function submitHeartbeat(uint64 serviceId, uint64 blueprintId, uint8 statusCode, bytes memory metrics, bytes memory signature) external;
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
    ///0x60c080604052346101885760408161416c803803809161001f828561018c565b83398101031261018857610032816101c3565b906001600160a01b0390610048906020016101c3565b1690811561017557600180546001600160a01b03199081169091555f80549182168417815560405193916001600160a01b0316907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09080a360a05260208101907f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f82527f36ffc258c865193ae10c3cf640450ab772fdb8da1dfcae7862ad1205a5567f4c60408201527fc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc660608201524660808201523060a082015260a0815261013260c08261018c565b519020608052604051613f9490816101d8823960805181611f66015260a0518181816102a601528181610c2801528181611c590152818161213701526125900152f35b631e4fbdf760e01b5f525f60045260245ffd5b5f80fd5b601f909101601f19168101906001600160401b038211908210176101af57604052565b634e487b7160e01b5f52604160045260245ffd5b51906001600160a01b03821682036101885756fe60806040526004361015610011575f80fd5b5f3560e01c806305778550146125605780630758236f1461250a5780630c76697a146124b7578063191cbd1a1461221f5780631e8f5ee51461211057806320812956146120cd57806322f1ec931461203d5780632c957688146120215780632dae188514611ff957806331e3bd1b14611f895780633644e51514611f4f5780633ac3cbe614611f335780633e6e34a714611ea05780633fd62c6d14611e6857806340235a9c14611dd057806348f4da2014611db55780635685cf6814611d0557806356c4e17d14611cc557806359dcea1214611c885780635a936dc614611c445780635cce98a614611bbc5780636076439c14611ba157806360cf099114611b4857806361d6b86c14611b2d57806362c7e8fc14611aca57806365a6936e146116535780636bfe06a614611638578063715018a6146115d557806371e7388c146114d75780637639d2271461147b57806379ba5097146113f65780637b9f64b2146113be57806381beac2e1461137457806384ef7322146113315780638da5cb5b1461130a57806396686c1e146112715780639cbdae22146111e6578063adff830c14611060578063ae470a8514610e3c578063b074e9dd14610deb578063b99f675914610bf3578063ba1fb10314610bc9578063c1ef9ddf14610a8d578063c5d960bb14610973578063cfe347491461094b578063d413a58014610790578063d551162c1461073d578063da435a7c146106e3578063e30c3978146106bb578063e65cafcb146104cb578063ee1c039014610495578063f2fde38b14610423578063f9107f3b146103a9578063f9f167621461036f5763ffcf08f014610276575f80fd5b3461036b57604036600319011261036b5761028f61260c565b6001600160401b0361029f612638565b916102d4337f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031614612b06565b16805f5260066020526102f460405f209260018060a01b03168093613d86565b1561033557805f52600460205261030e8260405f20613d86565b507f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e5f80a3005b60405162461bcd60e51b815260206004820152600e60248201526d139bdd081c9959da5cdd195c995960921b6044820152606490fd5b5f80fd5b3461036b575f36600319011261036b5760206040517fe1675f8364c07a4d60a07503f0d700a7bcacd82251dff0f070e5235de6c6d28a8152f35b3461036b57604036600319011261036b576103c261260c565b602435801515810361036b576001600160401b036104219216805f5260076020526103fa60018060a01b0360405f2054163314612ba4565b5f52600260205260405f209060ff60481b825491151560481b169060ff60481b1916179055565b005b3461036b57602036600319011261036b5761043c61264e565b610444613719565b60018060a01b0316806bffffffffffffffffffffffff60a01b600154161760015560018060a01b035f54167f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e227005f80a3005b3461036b57604036600319011261036b5760206104c16104b361260c565b6104bb612638565b906135fd565b6040519015158152f35b3461036b57604036600319011261036b576104e461260c565b6104ec612638565b6001600160401b03821691825f52600760205260018060a01b0360405f205416331480156106a8575b61051e9061341d565b825f52600360205260405f2060018060a01b0383165f5260205260405f20906040519161054a8361272e565b8054835260ff60018201546001600160401b0381166020860152818160401c16604086015260481c16600581101561069457600260039282606087015201546080850152036105c9575b6104218385805f5260056020526105b860405f209260018060a01b03168093613d86565b505f52600460205260405f20613d86565b6105d56105ee916136a3565b60ff60206001600160401b038351169201511690612c27565b90600a820291808304600a1490151715610680575190811515918261066b575b50501561061c578280610594565b60405162461bcd60e51b815260206004820152602160248201527f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76616044820152601b60fa1b6064820152608490fd5b61067791925042612e80565b1015838061060e565b634e487b7160e01b5f52601160045260245ffd5b634e487b7160e01b5f52602160045260245ffd5b505f546001600160a01b03163314610515565b3461036b575f36600319011261036b576001546040516001600160a01b039091168152602090f35b3461036b57602036600319011261036b576001600160401b0361070461260c565b165f526002602052606060405f205460ff604051916001600160401b0381168352818160401c16602084015260481c1615156040820152f35b3461036b5760206001600160401b038161075636612ab0565b949092165f526009835260405f209060018060a01b03165f52825260405f2083604051948593843782019081520301902054604051908152f35b3461036b5760a036600319011261036b576107a961260c565b6107b1612622565b906107ba612961565b906064356001600160401b03811161036b576107da90369060040161287f565b9290916084356001600160401b03811161036b576108ed6108e76108056108f693369060040161287f565b91906001600160401b0386165f52600660205261083c61083760405f2033906001915f520160205260405f2054151590565b612da6565b60405160c087811b6001600160c01b031990811660208401908152918d901b16602883015260f889901b6001600160f81b0319166030830152908a8a603183013761089a6031828d81015f838201520301601f19810183528261279a565b51902060405160208101917f19457468657265756d205369676e6564204d6573736167653a0a3332000000008352603c820152603c81526108dc605c8261279a565b5190209236916129a3565b90613e4b565b90929192613e85565b336001600160a01b03909116036109125761042194339161372c565b60405162461bcd60e51b8152602060048201526011602482015270496e76616c6964207369676e617475726560781b6044820152606490fd5b3461036b575f36600319011261036b57600a546040516001600160a01b039091168152602090f35b3461036b57602036600319011261036b576001600160401b0361099461260c565b16805f5260066020526109bc61083760405f2033906001915f520160205260405f2054151590565b5f8181526003602090815260408083203384529091529020600101805460481c60ff16919060058310156106945760038314610a4857690400000000000000000060ff60481b19825416179055805f526004602052610a1e3360405f20613d86565b50610a2c6040518093612918565b600460208301525f80516020613f6883398151915260403393a3005b60405162461bcd60e51b815260206004820152601f60248201527f43616e6e6f7420676f206f66666c696e65207768696c6520736c6173686564006044820152606490fd5b3461036b57602036600319011261036b576001600160401b03610aae61260c565b165f52600860205260405f20805490610ac682612971565b91610ad4604051938461279a565b8083526020830180925f5260205f205f915b838310610b7c57848660405191829160208301906020845251809152604083019060408160051b85010192915f905b828210610b2457505050500390f35b919360019193955060208091603f19898203018552875190606080610b52845160808552608085019061285b565b93858101518685015260408101516040850152015115159101529601920192018594939192610b15565b60046020600192604051610b8f81612749565b610b98866127bb565b815284860154838201526002860154604082015260ff60038701541615156060820152815201920192019190610ae6565b3461036b57604036600319011261036b57610421610be561260c565b610bed612638565b9061345a565b3461036b57606036600319011261036b57610c0c61260c565b610c14612622565b6001600160401b03610c24612961565b91337f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316148015610dc9575b610c619061341d565b1690603c8210610d8f5760ff169160018310610d4a577fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea564916001600160401b036040921693845f526002602052610d3d60ff845f205460481c16845190610cc782612764565b848252610d2260ff6020840186815288850193151584528a5f5260026020526001600160401b03808a5f20965116166001600160401b03198654161785555116839060ff60401b82549160401b169060ff60401b1916179055565b51815460ff60481b191690151560481b60ff60481b16179055565b82519182526020820152a2005b60405162461bcd60e51b815260206004820152601760248201527f4d6178206d6973736564206d757374206265203e3d20310000000000000000006044820152606490fd5b60405162461bcd60e51b8152602060048201526012602482015271125b9d195c9d985b081d1bdbc81cda1bdc9d60721b6044820152606490fd5b508184165f908152600760205260409020546001600160a01b03163314610c58565b3461036b57602036600319011261036b57610421610e0761260c565b6001600160401b0381165f526006602052610e3761083760405f2033906001915f520160205260405f2054151590565b6132f8565b3461036b5760a036600319011261036b57610e5561260c565b6024356001600160401b03811161036b57610e7490369060040161287f565b90604435606435916084359485151580960361036b576001600160401b0316805f526007602052610eb260018060a01b0360405f2054163314612ba4565b610ebf6040861115612ca4565b610ecb83851015612ce0565b805f526008602052610ee3603260405f205410612be4565b5f526008602052610f0660405f209160405195610eff87612749565b36916129a3565b84526020840191825260408401928352606084019485528054600160401b81101561103957610f3a916001820181556126c9565b93909361104d57518051906001600160401b03821161103957610f6782610f6187546126f6565b87612d1d565b602090601f8311600114610fcf578260039593610421989593610f9f935f92610fc4575b50508160011b915f199060031b1c19161790565b85555b51600185015551600284015551151591019060ff801983541691151516179055565b015190508980610f8b565b90601f19831691865f52815f20925f5b8181106110215750926001928592600398966104219b98961061100a575b505050811b018555610fa2565b01515f1983891b60f8161c19169055888080610ffd565b92936020600181928786015181550195019301610fdf565b634e487b7160e01b5f52604160045260245ffd5b634e487b7160e01b5f525f60045260245ffd5b3461036b5761106e36612ab0565b90919260018060a01b03600a541633036111ab576001600160401b031691825f5260056020526110b960405f209460018060a01b031680956001915f520160205260405f2054151590565b15611173577f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c79191835f52600360205260405f20855f52602052600160405f2001690300000000000000000060ff60481b19825416179055835f5260046020526111258560405f20613d86565b50835f52600c60205260405f20855f5260205260405f206001600160401b03804216166001600160401b031982541617905561116e6040519283926020845260208401916132d8565b0390a3005b60405162461bcd60e51b815260206004820152601060248201526f27b832b930ba37b9103ab735b737bbb760811b6044820152606490fd5b60405162461bcd60e51b81526020600482015260136024820152724e6f7420736c617368696e67206f7261636c6560681b6044820152606490fd5b3461036b57606036600319011261036b576111ff61260c565b611207612638565b6044356001600160401b03811161036b5760209283926001600160401b03611234859436906004016129d9565b92165f526009835260405f209060018060a01b03165f52825260405f20604051938285935191829101845e82019081520301902054604051908152f35b3461036b5761127f36612664565b906001600160401b035f9316925b8281101561042157600581901b8201356001600160a01b038116919082900361036b57303b1561036b576040519163ba1fb10360e01b835285600484015260248301525f8260448183305af19182156112ff576001926112ef575b500161128d565b5f6112f99161279a565b856112e8565b6040513d5f823e3d90fd5b3461036b575f36600319011261036b575f546040516001600160a01b039091168152602090f35b3461036b57602036600319011261036b5761134a61264e565b611352613719565b600a80546001600160a01b0319166001600160a01b0392909216919091179055005b3461036b57606036600319011261036b576113b46113a061139361260c565b604435906024359061309e565b604051928392604084526040840190612925565b9060208301520390f35b3461036b57602036600319011261036b576001600160401b036113df61260c565b165f526004602052602060405f2054604051908152f35b3461036b575f36600319011261036b57600154336001600160a01b039091160361146857600180546001600160a01b03199081169091555f805433928116831782556001600160a01b0316907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09080a3005b63118cdaa760e01b5f523360045260245ffd5b3461036b57604036600319011261036b5761149461260c565b6001600160401b036114a4612638565b91165f52600c60205260405f209060018060a01b03165f5260205260206001600160401b0360405f205416604051908152f35b3461036b57604036600319011261036b576114f061260c565b6001600160401b03611500612638565b915f60806040516115108161272e565b8281528260208201528260408201528260608201520152165f52600360205260405f209060018060a01b03165f5260205260405f206040516115518161272e565b8154815260018201549160208201906001600160401b038416825260ff6040840194818160401c16865260481c16606084019060058110156106945760a0956001600160401b0360026115cd9560ff94865201549560808801968752604051975188525116602087015251166040850152516060840190612918565b516080820152f35b3461036b575f36600319011261036b576115ed613719565b600180546001600160a01b03199081169091555f80549182168155906001600160a01b03167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e08280a3005b3461036b575f36600319011261036b57602060405160408152f35b3461036b57608036600319011261036b5761166c61260c565b611674612638565b6044356001600160401b03811161036b576116939036906004016129f7565b60643592303303611a95576001600160401b031691825f52600860205260405f20936116be81612d60565b925f5b828110611a6e575085548015158091606092611a25575b505f5b8481106118175750505050505f928454945b8585106116f657005b60ff600361170487846126c9565b500154161561180d5761172a61173161171d87846126c9565b5060405192838092612df2565b038261279a565b602081519101205f945f5b81518110156117ff57826117508284612d92565b511461175e5760010161173c565b509450509493600190815b15611777575b0193946116ed565b61178181886126c9565b50837fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63156117b960405193604085526040850190612df2565b927f5265717569726564206d6574726963206d697373696e6700000000000000000060208286039586828501526017815201526040868060a01b038916940190a361176f565b509460019297969150611769565b949360019061176f565b60015f836118ef575b5090600191611830575b016116db565b602061183c8287612d92565b510151895f52600960205260405f20838060a01b0389165f5260205260208060405f20611869858a612d92565b515190604051938285935191829101845e8201908152030190205561188e8186612d92565b5151897f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd60206118be858a612d92565b510151926118d76040519160408352604083019061285b565b93602082015280868060a01b038c16940390a361182a565b8a545f5b818110611916575b505090600192911561190f575b9091611820565b505f611908565b611920858c612d92565b5161192b8289612d92565b5114611939576001016118f3565b6001949392508491508c602061194f868b612d92565b5101518361195d84846126c9565b500154119182156119fc575b5050611979575b9091928c6118fb565b90506119858287612d92565b51518a7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63156119be6040519360408552604085019061285b565b927256616c7565206f7574206f6620626f756e647360681b60208286039586828501526013815201526040878060a01b038d16940190a35f90611970565b6002919250611a1a906020611a11888d612d92565b510151936126c9565b500154108c8e611969565b9150611a3082612d60565b91885f5b828110611a425750506116d8565b61172a611a5461171d836001956126c9565b60208151910120611a658287612d92565b52018990611a34565b80611a7b60019284612d92565b515160208151910120611a8e8288612d92565b52016116c1565b60405162461bcd60e51b815260206004820152600d60248201526c496e7465726e616c206f6e6c7960981b6044820152606490fd5b3461036b57604036600319011261036b57611ae361260c565b6001600160401b03611af3612638565b91165f52600360205260405f209060018060a01b03165f52602052602060ff600160405f20015460481c16611b2b6040518092612918565bf35b3461036b575f36600319011261036b57602060405160038152f35b3461036b57604036600319011261036b5760206104c1611b6661260c565b6001600160401b03611b76612638565b91165f9081526006845260408082206001600160a01b03909316825260019092016020522054151590565b3461036b575f36600319011261036b57602060405160328152f35b3461036b57608036600319011261036b57611bd561260c565b611bdd612622565b90611be6612961565b91606435926001600160401b03841161036b57611c0a61042194369060040161287f565b9390926001600160401b0382165f526006602052611c3d61083760405f2033906001915f520160205260405f2054151590565b339161372c565b3461036b575f36600319011261036b576040517f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03168152602090f35b3461036b57602036600319011261036b57611cc1611cac611ca761260c565b612e8d565b50604051918291602083526020830190612925565b0390f35b3461036b57602036600319011261036b576001600160401b03611ce661260c565b165f526007602052602060018060a01b0360405f205416604051908152f35b3461036b57604036600319011261036b57611d1e61260c565b6001600160401b03611d2e612638565b9116805f52600360205260405f2060018060a01b0383165f5260205260ff600160405f20015460481c1660058110156106945715908115611d77575b6020826040519015158152f35b90505f52600360205260405f209060018060a01b03165f5260205260ff600160405f20015460481c1660058110156106945760016020911482611d6a565b3461036b575f36600319011261036b57602060405160c88152f35b3461036b57602036600319011261036b576001600160401b03611df161260c565b16805f52600460205260405f2054611e0881612d60565b915f5b828110611e285760405160208082528190611cc190820187612925565b600190825f526004602052611e408160405f20613b10565b838060a01b0391549060031b1c16611e588287612d92565b90838060a01b0316905201611e0b565b3461036b57602036600319011261036b576001600160401b03611e8961260c565b165f526005602052602060405f2054604051908152f35b3461036b57604036600319011261036b57611eb961260c565b6001600160401b03611ec9612638565b91165f52600360205260405f209060018060a01b03165f5260205260a060405f20805490611f2c60026001830154920154916040519384526001600160401b038116602085015260ff8160401c16604085015260ff606085019160481c16612918565b6080820152f35b3461036b575f36600319011261036b576020604051610e108152f35b3461036b575f36600319011261036b5760206040517f00000000000000000000000000000000000000000000000000000000000000008152f35b3461036b57602036600319011261036b576004356001600160401b03811161036b57611fb990369060040161287f565b81019060208183031261036b578035916001600160401b03831161036b57611cc192611fe592016129f7565b6040519182916020835260208301906128ac565b3461036b575f36600319011261036b57600b546040516001600160a01b039091168152602090f35b3461036b575f36600319011261036b57602060405161012c8152f35b3461036b57604036600319011261036b5761205661260c565b6001600160401b0360243591165f52600860205260405f20805482101561036b576120b791612084916126c9565b5061208e816127bb565b9060018101549060ff60036002830154920154169060405194859460808652608086019061285b565b9260208501526040840152151560608301520390f35b3461036b57602036600319011261036b576120e661264e565b6120ee613719565b600b80546001600160a01b0319166001600160a01b0392909216919091179055005b3461036b57604036600319011261036b5761212961260c565b612131612638565b612165337f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031614612b06565b6001600160a01b03169081156121eb576001600160401b0316805f52600660205261219b6121968360405f20613b25565b612b45565b805f52600360205260405f20825f52602052600160405f2001600160491b60ff60481b198254161790557f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b5f80a3005b60405162461bcd60e51b815260206004820152600c60248201526b5a65726f206164647265737360a01b6044820152606490fd5b3461036b576001600160401b0361223536612664565b919290921690815f52600760205261225a60018060a01b0360405f2054163314612ba4565b6122676032821115612be4565b815f52600860205260405f208054905f815581612421575b50505f5b81811061228c57005b6122ae60406122a561229f848689612c50565b80612c72565b90501115612ca4565b6122d660406122be838588612c50565b013560206122cd848689612c50565b01351115612ce0565b825f52600860205260405f20906122ee818487612c50565b918054600160401b8110156110395761230c916001820181556126c9565b92909261104d5761231d8180612c72565b906001600160401b0382116110395761233a82610f6187546126f6565b5f90601f83116001146123ba57918061236b92606095945f926123af5750508160011b915f199060031b1c19161790565b84555b6020810135600185015560408101356002850155013591821515830361036b5760019260036123a992019060ff801983541691151516179055565b01612283565b013590508a80610f8b565b601f19831691865f5260205f20925f5b81811061240957509160019391856060979694106123f0575b505050811b01845561236e565b01355f19600384901b60f8161c191690558980806123e3565b919360206001819287870135815501950192016123ca565b6001600160fe1b0382168203610680575f5260205f209060021b8101905b8181101561227f5780612454600492546126f6565b80612473575b505f60018201555f60028201555f60038201550161243f565b601f811160011461248957505f81555b8661245a565b6124a690825f526001601f60205f20920160051c82019101612c3a565b805f525f6020812081835555612483565b3461036b57604036600319011261036b576124d061260c565b6001600160401b036124e0612638565b91165f52600360205260405f209060018060a01b03165f52602052602060405f2054604051908152f35b3461036b57602036600319011261036b57606061253661252861260c565b612530612b86565b506136a3565b60408051916001600160401b03815116835260ff6020820151166020840152015115156040820152f35b3461036b57604036600319011261036b5761257961260c565b6001600160401b03612589612638565b916125be337f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031614612b06565b165f818152600760205260409020546125e0906001600160a01b031615612b45565b5f90815260076020526040902080546001600160a01b0319166001600160a01b03909216919091179055005b600435906001600160401b038216820361036b57565b602435906001600160401b038216820361036b57565b602435906001600160a01b038216820361036b57565b600435906001600160a01b038216820361036b57565b604060031982011261036b576004356001600160401b038116810361036b57916024356001600160401b03811161036b5760040182601f8201121561036b578035926001600160401b03841161036b576020808301928560051b01011161036b579190565b80548210156126e2575f5260205f209060021b01905f90565b634e487b7160e01b5f52603260045260245ffd5b90600182811c92168015612724575b602083101461271057565b634e487b7160e01b5f52602260045260245ffd5b91607f1691612705565b60a081019081106001600160401b0382111761103957604052565b608081019081106001600160401b0382111761103957604052565b606081019081106001600160401b0382111761103957604052565b604081019081106001600160401b0382111761103957604052565b90601f801991011681019081106001600160401b0382111761103957604052565b9060405191825f8254926127ce846126f6565b808452936001811690811561283957506001146127f5575b506127f39250038361279a565b565b90505f9291925260205f20905f915b81831061281d5750509060206127f3928201015f6127e6565b6020919350806001915483858901015201910190918492612804565b9050602092506127f394915060ff191682840152151560051b8201015f6127e6565b805180835260209291819084018484015e5f828201840152601f01601f1916010190565b9181601f8401121561036b578235916001600160401b03831161036b576020838186019501011161036b57565b9080602083519182815201916020808360051b8301019401925f915b8383106128d757505050505090565b9091929394602080600192601f198582030186528851908280612903845160408552604085019061285b565b930151910152970193019301919392906128c8565b9060058210156106945752565b90602080835192838152019201905f5b8181106129425750505090565b82516001600160a01b0316845260209384019390920191600101612935565b6044359060ff8216820361036b57565b6001600160401b0381116110395760051b60200190565b6001600160401b03811161103957601f01601f191660200190565b9291926129af82612988565b916129bd604051938461279a565b82948184528183011161036b578281602093845f960137010152565b9080601f8301121561036b578160206129f4933591016129a3565b90565b81601f8201121561036b57803590612a0e82612971565b92612a1c604051948561279a565b82845260208085019360051b8301019181831161036b5760208101935b838510612a4857505050505090565b84356001600160401b03811161036b5782016040818503601f19011261036b5760405191612a758361277f565b6020820135926001600160401b03841161036b57604083612a9d8860208098819801016129d9565b8352013583820152815201940193612a39565b606060031982011261036b576004356001600160401b038116810361036b57916024356001600160a01b038116810361036b5791604435906001600160401b03821161036b57612b029160040161287f565b9091565b15612b0d57565b60405162461bcd60e51b815260206004820152601060248201526f4f6e6c792054616e676c6520636f726560801b6044820152606490fd5b15612b4c57565b60405162461bcd60e51b8152602060048201526012602482015271105b1c9958591e481c9959da5cdd195c995960721b6044820152606490fd5b60405190612b9382612764565b5f6040838281528260208201520152565b15612bab57565b60405162461bcd60e51b81526020600482015260116024820152702737ba1039b2b93b34b1b29037bbb732b960791b6044820152606490fd5b15612beb57565b60405162461bcd60e51b8152602060048201526014602482015273546f6f206d616e7920646566696e6974696f6e7360601b6044820152606490fd5b8181029291811591840414171561068057565b818110612c45575050565b5f8155600101612c3a565b91908110156126e25760051b81013590607e198136030182121561036b570190565b903590601e198136030182121561036b57018035906001600160401b03821161036b5760200191813603831361036b57565b15612cab57565b60405162461bcd60e51b815260206004820152600d60248201526c4e616d6520746f6f206c6f6e6760981b6044820152606490fd5b15612ce757565b60405162461bcd60e51b815260206004820152600e60248201526d496e76616c696420626f756e647360901b6044820152606490fd5b9190601f8111612d2c57505050565b6127f3925f5260205f20906020601f840160051c83019310612d56575b601f0160051c0190612c3a565b9091508190612d49565b90612d6a82612971565b612d77604051918261279a565b8281528092612d88601f1991612971565b0190602036910137565b80518210156126e25760209160051b010190565b15612dad57565b60405162461bcd60e51b815260206004820152601760248201527f4e6f742072656769737465726564206f70657261746f720000000000000000006044820152606490fd5b5f9291815491612e01836126f6565b8083529260018116908115612e565750600114612e1d57505050565b5f9081526020812093945091925b838310612e3c575060209250010190565b600181602092949394548385870101520191019190612e2b565b915050602093945060ff929192191683830152151560051b010190565b9190820180921161068057565b9190820391821161068057565b6001600160401b03612e9e826136a3565b911691825f52600560205260405f205491602081019060ff825116158015613096575b801561308e575b613070579060ff6001600160401b03612ee693511691511690612c27565b60c883101561306957825b612efa81612d60565b945f925f5b838110612f4a5750505050612f1381612d60565b935f5b828110612f2257505050565b6001906001600160a01b03612f378285612d92565b5116612f438289612d92565b5201612f16565b825f526005602052612f5f8160405f20613b10565b90545f85815260066020908152604080832060039590951b9390931c6001600160a01b0316808352600194909401905220541561306057835f52600360205260405f20815f5260205260405f20604051612fb88161272e565b8154815260ff60018301546001600160401b0381166020840152818160401c16604084015260481c166005811015610694576002869382606085015201546080830152815115908115613055575b5061304a57613016905142612e80565b1015613028575b506001905b01612eff565b613035868a979397612d92565b525f198114610680576001809101949061301d565b505050600190613022565b60039150145f613006565b50600190613022565b60c8612ef1565b505090915060405161308360208261279a565b5f81525f3681379190565b508315612ec8565b508315612ec1565b9192906001600160401b036130b2846136a3565b9316805f52600560205260405f205493602081019060ff8251161580156132d0575b80156132c6575b6132b1579060ff6001600160401b036130f993511691511690612c27565b9460c88111156132ac575060c85b846131128285612e73565b111561329c575083905b61312e6131298484612e80565b612d60565b955f935b83811061317d575050505061314681612d60565b935f5b82811061315557505050565b6001906001600160a01b0361316a8285612d92565b51166131768289612d92565b5201613149565b825f5260056020526131928160405f20613b10565b90545f85815260066020908152604080832060039590951b9390931c6001600160a01b0316808352600194909401905220541561329357835f52600360205260405f20815f5260205260405f206040516131eb8161272e565b8154815260ff60018301546001600160401b0381166020840152818160401c16604084015260481c166005811015610694576002869382606085015201546080830152815115908115613288575b5061327d57613249905142612e80565b101561325b575b506001905b01613132565b613268868a979397612d92565b525f1981146106805760018091019490613250565b505050600190613255565b60039150145f613239565b50600190613255565b6132a69083612e73565b9061311c565b613107565b5050505090915060405161308360208261279a565b50858410156130db565b5085156130d4565b908060209392818452848401375f828201840152601f01601f1916010190565b6001600160401b03165f8181526003602090815260408083203384529091529020600101805460481c60ff169190600583101561069457600383146133d857821580156133ce575b6133c957805469ffff0000000000000000191669010000000000000000001790555f818152600460205260409020613379903390613b25565b506133ad604051809333847fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c5f80a3612918565b600160208301525f80516020613f6883398151915260403393a3565b505050565b5060018314613340565b60405162461bcd60e51b815260206004820152601e60248201527f43616e6e6f7420676f206f6e6c696e65207768696c6520736c617368656400006044820152606490fd5b1561342457565b60405162461bcd60e51b815260206004820152600e60248201526d139bdd08185d5d1a1bdc9a5e995960921b6044820152606490fd5b906001600160401b03821690815f52600360205260405f2060018060a01b0382165f5260205261348d60405f20936136a3565b92600181019384549160ff8360481c166005811015610694576003146134ef575480156134ef576134be9042612e80565b6001600160401b038251169081156135e9570460ff8111156135e1575060ff5b60ff8082169360401c1683116134f7575b505050505050565b855460409190911b60ff60401b1668ffffffffffffffffff199091161785556020015160ff16811015806135c6575b613532575b80806134ef565b835f80516020613f6883398151915292847f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d602060409560ff6135a29a5460481c1695600160491b60ff60481b19825416179055835f5260048252865f209460018060a01b0316998a8096613d86565b508651908152a36135b582518092612918565b60026020820152a35f80808061352b565b5060ff845460481c1660058110156106945760021415613526565b60ff166134de565b634e487b7160e01b5f52601260045260245ffd5b906001600160401b0361360f836136a3565b92165f52600360205260405f209060018060a01b03165f5260205260405f206040519061363b8261272e565b8054825260ff60018201546001600160401b0381166020850152818160401c16604085015260481c169060058210156106945760029160608401520154608082015251801561369d576136966001600160401b039142612e80565b9151161190565b50505f90565b6001600160401b03906136b4612b86565b50165f52600260205260405f20604051906136ce82612764565b546001600160401b03811680835260ff8260401c169060ff602085019383855260481c16151560408501521561370f575b15613708575090565b6003905290565b61012c83526136ff565b5f546001600160a01b0316330361146857565b909293916001600160401b03821695865f52600360205260405f2060018060a01b0383165f5260205260405f2094613763846136a3565b90600187019460ff865460481c16600581101561069457600314613ad5575f8a81526005602052604090206001600160a01b03861699906137a5908b90613b25565b5060ff875460481c169842815560026137bf36888c6129a3565b6020815191012091015560ff60401b1987541687556001600160401b03875416906001600160401b038214610680576001600160401b03600160ff9301166001600160401b0319895416178855169384155f146139c3575f975b6005891015978861069457805460ff60481b191660488b901b60ff60481b1617905560058a1015610694578a968c9560028c148b816139b4575b509260409592866001600160401b0396937f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b99996613974575b015115158061396b575b613959575b5050505082519586524260208701521693a46106945782918491808203613924575b5050600b546001600160a01b03169391508390506138da57505050565b823b1561036b5760645f92836040519586948593636a3c29db60e11b8552600485015260248401526001600160401b03421660448401525af161391a5750565b5f6127f39161279a565b5f80516020613f688339815191529161394f60409261394584518094612918565b6020830190612918565ba380825f806138bd565b61396293613b88565b5f80808061389b565b50821515613896565b8a5f5260046020526139888d835f20613b25565b508c8b7fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c5f80a361388c565b5f9b506002141590508b613853565b60648510156139d457600197613819565b60019760c88610613819576001600160401b0342168c5f52600c60205260405f208c5f526020526001600160401b0360405f2054168015908115613aae575b50613a1f575b50613819565b8c5f52600c60205260405f208c5f526020526001600160401b0360405f2091166001600160401b03198254161790558a8c7f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c791606060405160208152601b60208201527f50726f746f636f6c2076696f6c6174696f6e207265706f7274656400000000006040820152a35f613a19565b905081036001600160401b038111610680576001600160401b03610e10911610155f613a13565b60405162461bcd60e51b815260206004820152601360248201527213dc195c985d1bdc881a5cc81cdb185cda1959606a1b6044820152606490fd5b80548210156126e2575f5260205f2001905f90565b5f82815260018201602052604090205461369d57805490600160401b8210156110395782613b73613b5d846001809601855584613b10565b819391549060031b91821b915f19901b19161790565b90558054925f520160205260405f2055600190565b9190928015613d805761c3508111613d80576040516331e3bd1b60e01b815260206004820152915f9183918291613bc4916024840191906132d8565b0381305afa5f9181613c55575b50613bdb57505050565b80516032811115613c4f57506032915b303b1561036b576040516332d349b760e11b81526001600160401b039190911660048201526001600160a01b039093166024840152608060448401525f918391829190613c3c9060848401906128ac565b906064830152038183305af161391a5750565b91613beb565b9091503d805f833e613c67818361279a565b81019060208183031261036b578051906001600160401b03821161036b57019080601f8301121561036b57815191613c9e83612971565b92613cac604051948561279a565b80845260208085019160051b8301019183831161036b5760208101915b838310613cdc575050505050905f613bd1565b82516001600160401b03811161036b578201906040828703601f19011261036b5760405190613d0a8261277f565b60208301516001600160401b03811161036b576020908401019187601f8401121561036b57825192613d3b84612988565b94613d49604051968761279a565b848652896020868401011161036b576020955f8787819882604097018386015e830101528352015183820152815201920191613cc9565b50505050565b906001820191815f528260205260405f20548015155f14613e43575f1981018181116106805782545f1981019190821161068057818103613e0e575b50505080548015613dfa575f190190613ddb8282613b10565b8154905f199060031b1b19169055555f526020525f6040812055600190565b634e487b7160e01b5f52603160045260245ffd5b613e2e613e1e613b5d9386613b10565b90549060031b1c92839286613b10565b90555f528360205260405f20555f8080613dc2565b505050505f90565b8151919060418303613e7b57613e749250602082015190606060408401519301515f1a90613ee5565b9192909190565b50505f9160029190565b60048110156106945780613e97575050565b60018103613eae5763f645eedf60e01b5f5260045ffd5b60028103613ec9575063fce698f760e01b5f5260045260245ffd5b600314613ed35750565b6335e2f38360e21b5f5260045260245ffd5b91907f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a08411613f5c579160209360809260ff5f9560405194855216868401526040830152606082015282805260015afa156112ff575f516001600160a01b03811615613f5257905f905f90565b505f906001905f90565b5050505f916003919056fe228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a09a164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\xC0\x80`@R4a\x01\x88W`@\x81aAl\x808\x03\x80\x91a\0\x1F\x82\x85a\x01\x8CV[\x839\x81\x01\x03\x12a\x01\x88Wa\x002\x81a\x01\xC3V[\x90`\x01`\x01`\xA0\x1B\x03\x90a\0H\x90` \x01a\x01\xC3V[\x16\x90\x81\x15a\x01uW`\x01\x80T`\x01`\x01`\xA0\x1B\x03\x19\x90\x81\x16\x90\x91U_\x80T\x91\x82\x16\x84\x17\x81U`@Q\x93\x91`\x01`\x01`\xA0\x1B\x03\x16\x90\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x90\x80\xA3`\xA0R` \x81\x01\x90\x7F\x8Bs\xC3\xC6\x9B\xB8\xFE=Q.\xCCL\xF7Y\xCCy#\x9F{\x17\x9B\x0F\xFA\xCA\xA9\xA7]R+9@\x0F\x82R\x7F6\xFF\xC2X\xC8e\x19:\xE1\x0C<\xF6@E\n\xB7r\xFD\xB8\xDA\x1D\xFC\xAExb\xAD\x12\x05\xA5V\x7FL`@\x82\x01R\x7F\xC8\x9E\xFD\xAAT\xC0\xF2\x0Cz\xDFa(\x82\xDF\tP\xF5\xA9Qc~\x03\x07\xCD\xCBLg/)\x8B\x8B\xC6``\x82\x01RF`\x80\x82\x01R0`\xA0\x82\x01R`\xA0\x81Ra\x012`\xC0\x82a\x01\x8CV[Q\x90 `\x80R`@Qa?\x94\x90\x81a\x01\xD8\x829`\x80Q\x81a\x1Ff\x01R`\xA0Q\x81\x81\x81a\x02\xA6\x01R\x81\x81a\x0C(\x01R\x81\x81a\x1CY\x01R\x81\x81a!7\x01Ra%\x90\x01R\xF3[c\x1EO\xBD\xF7`\xE0\x1B_R_`\x04R`$_\xFD[_\x80\xFD[`\x1F\x90\x91\x01`\x1F\x19\x16\x81\x01\x90`\x01`\x01`@\x1B\x03\x82\x11\x90\x82\x10\x17a\x01\xAFW`@RV[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[Q\x90`\x01`\x01`\xA0\x1B\x03\x82\x16\x82\x03a\x01\x88WV\xFE`\x80`@R`\x046\x10\x15a\0\x11W_\x80\xFD[_5`\xE0\x1C\x80c\x05w\x85P\x14a%`W\x80c\x07X#o\x14a%\nW\x80c\x0Cviz\x14a$\xB7W\x80c\x19\x1C\xBD\x1A\x14a\"\x1FW\x80c\x1E\x8F^\xE5\x14a!\x10W\x80c \x81)V\x14a \xCDW\x80c\"\xF1\xEC\x93\x14a =W\x80c,\x95v\x88\x14a !W\x80c-\xAE\x18\x85\x14a\x1F\xF9W\x80c1\xE3\xBD\x1B\x14a\x1F\x89W\x80c6D\xE5\x15\x14a\x1FOW\x80c:\xC3\xCB\xE6\x14a\x1F3W\x80c>n4\xA7\x14a\x1E\xA0W\x80c?\xD6,m\x14a\x1EhW\x80c@#Z\x9C\x14a\x1D\xD0W\x80cH\xF4\xDA \x14a\x1D\xB5W\x80cV\x85\xCFh\x14a\x1D\x05W\x80cV\xC4\xE1}\x14a\x1C\xC5W\x80cY\xDC\xEA\x12\x14a\x1C\x88W\x80cZ\x93m\xC6\x14a\x1CDW\x80c\\\xCE\x98\xA6\x14a\x1B\xBCW\x80c`vC\x9C\x14a\x1B\xA1W\x80c`\xCF\t\x91\x14a\x1BHW\x80ca\xD6\xB8l\x14a\x1B-W\x80cb\xC7\xE8\xFC\x14a\x1A\xCAW\x80ce\xA6\x93n\x14a\x16SW\x80ck\xFE\x06\xA6\x14a\x168W\x80cqP\x18\xA6\x14a\x15\xD5W\x80cq\xE78\x8C\x14a\x14\xD7W\x80cv9\xD2'\x14a\x14{W\x80cy\xBAP\x97\x14a\x13\xF6W\x80c{\x9Fd\xB2\x14a\x13\xBEW\x80c\x81\xBE\xAC.\x14a\x13tW\x80c\x84\xEFs\"\x14a\x131W\x80c\x8D\xA5\xCB[\x14a\x13\nW\x80c\x96hl\x1E\x14a\x12qW\x80c\x9C\xBD\xAE\"\x14a\x11\xE6W\x80c\xAD\xFF\x83\x0C\x14a\x10`W\x80c\xAEG\n\x85\x14a\x0E<W\x80c\xB0t\xE9\xDD\x14a\r\xEBW\x80c\xB9\x9FgY\x14a\x0B\xF3W\x80c\xBA\x1F\xB1\x03\x14a\x0B\xC9W\x80c\xC1\xEF\x9D\xDF\x14a\n\x8DW\x80c\xC5\xD9`\xBB\x14a\tsW\x80c\xCF\xE3GI\x14a\tKW\x80c\xD4\x13\xA5\x80\x14a\x07\x90W\x80c\xD5Q\x16,\x14a\x07=W\x80c\xDACZ|\x14a\x06\xE3W\x80c\xE3\x0C9x\x14a\x06\xBBW\x80c\xE6\\\xAF\xCB\x14a\x04\xCBW\x80c\xEE\x1C\x03\x90\x14a\x04\x95W\x80c\xF2\xFD\xE3\x8B\x14a\x04#W\x80c\xF9\x10\x7F;\x14a\x03\xA9W\x80c\xF9\xF1gb\x14a\x03oWc\xFF\xCF\x08\xF0\x14a\x02vW_\x80\xFD[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x02\x8Fa&\x0CV[`\x01`\x01`@\x1B\x03a\x02\x9Fa&8V[\x91a\x02\xD43\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x14a+\x06V[\x16\x80_R`\x06` Ra\x02\xF4`@_ \x92`\x01\x80`\xA0\x1B\x03\x16\x80\x93a=\x86V[\x15a\x035W\x80_R`\x04` Ra\x03\x0E\x82`@_ a=\x86V[P\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E_\x80\xA3\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x0E`$\x82\x01Rm\x13\x9B\xDD\x08\x1C\x99Y\xDA\\\xDD\x19\\\x99Y`\x92\x1B`D\x82\x01R`d\x90\xFD[_\x80\xFD[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q\x7F\xE1g_\x83d\xC0zM`\xA0u\x03\xF0\xD7\0\xA7\xBC\xAC\xD8\"Q\xDF\xF0\xF0p\xE5#]\xE6\xC6\xD2\x8A\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x03\xC2a&\x0CV[`$5\x80\x15\x15\x81\x03a\x03kW`\x01`\x01`@\x1B\x03a\x04!\x92\x16\x80_R`\x07` Ra\x03\xFA`\x01\x80`\xA0\x1B\x03`@_ T\x163\x14a+\xA4V[_R`\x02` R`@_ \x90`\xFF`H\x1B\x82T\x91\x15\x15`H\x1B\x16\x90`\xFF`H\x1B\x19\x16\x17\x90UV[\0[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa\x04<a&NV[a\x04Da7\x19V[`\x01\x80`\xA0\x1B\x03\x16\x80k\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF`\xA0\x1B`\x01T\x16\x17`\x01U`\x01\x80`\xA0\x1B\x03_T\x16\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0_\x80\xA3\0[4a\x03kW`@6`\x03\x19\x01\x12a\x03kW` a\x04\xC1a\x04\xB3a&\x0CV[a\x04\xBBa&8V[\x90a5\xFDV[`@Q\x90\x15\x15\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x04\xE4a&\x0CV[a\x04\xECa&8V[`\x01`\x01`@\x1B\x03\x82\x16\x91\x82_R`\x07` R`\x01\x80`\xA0\x1B\x03`@_ T\x163\x14\x80\x15a\x06\xA8W[a\x05\x1E\x90a4\x1DV[\x82_R`\x03` R`@_ `\x01\x80`\xA0\x1B\x03\x83\x16_R` R`@_ \x90`@Q\x91a\x05J\x83a'.V[\x80T\x83R`\xFF`\x01\x82\x01T`\x01`\x01`@\x1B\x03\x81\x16` \x86\x01R\x81\x81`@\x1C\x16`@\x86\x01R`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x02`\x03\x92\x82``\x87\x01R\x01T`\x80\x85\x01R\x03a\x05\xC9W[a\x04!\x83\x85\x80_R`\x05` Ra\x05\xB8`@_ \x92`\x01\x80`\xA0\x1B\x03\x16\x80\x93a=\x86V[P_R`\x04` R`@_ a=\x86V[a\x05\xD5a\x05\xEE\x91a6\xA3V[`\xFF` `\x01`\x01`@\x1B\x03\x83Q\x16\x92\x01Q\x16\x90a,'V[\x90`\n\x82\x02\x91\x80\x83\x04`\n\x14\x90\x15\x17\x15a\x06\x80WQ\x90\x81\x15\x15\x91\x82a\x06kW[PP\x15a\x06\x1CW\x82\x80a\x05\x94V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`!`$\x82\x01R\x7FOperator not eligible for remova`D\x82\x01R`\x1B`\xFA\x1B`d\x82\x01R`\x84\x90\xFD[a\x06w\x91\x92PBa.\x80V[\x10\x15\x83\x80a\x06\x0EV[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[P_T`\x01`\x01`\xA0\x1B\x03\x163\x14a\x05\x15V[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`\x01T`@Q`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x81R` \x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x07\x04a&\x0CV[\x16_R`\x02` R```@_ T`\xFF`@Q\x91`\x01`\x01`@\x1B\x03\x81\x16\x83R\x81\x81`@\x1C\x16` \x84\x01R`H\x1C\x16\x15\x15`@\x82\x01R\xF3[4a\x03kW` `\x01`\x01`@\x1B\x03\x81a\x07V6a*\xB0V[\x94\x90\x92\x16_R`\t\x83R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R\x82R`@_ \x83`@Q\x94\x85\x93\x847\x82\x01\x90\x81R\x03\x01\x90 T`@Q\x90\x81R\xF3[4a\x03kW`\xA06`\x03\x19\x01\x12a\x03kWa\x07\xA9a&\x0CV[a\x07\xB1a&\"V[\x90a\x07\xBAa)aV[\x90`d5`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x07\xDA\x906\x90`\x04\x01a(\x7FV[\x92\x90\x91`\x845`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x08\xEDa\x08\xE7a\x08\x05a\x08\xF6\x936\x90`\x04\x01a(\x7FV[\x91\x90`\x01`\x01`@\x1B\x03\x86\x16_R`\x06` Ra\x08<a\x087`@_ 3\x90`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[a-\xA6V[`@Q`\xC0\x87\x81\x1B`\x01`\x01`\xC0\x1B\x03\x19\x90\x81\x16` \x84\x01\x90\x81R\x91\x8D\x90\x1B\x16`(\x83\x01R`\xF8\x89\x90\x1B`\x01`\x01`\xF8\x1B\x03\x19\x16`0\x83\x01R\x90\x8A\x8A`1\x83\x017a\x08\x9A`1\x82\x8D\x81\x01_\x83\x82\x01R\x03\x01`\x1F\x19\x81\x01\x83R\x82a'\x9AV[Q\x90 `@Q` \x81\x01\x91\x7F\x19Ethereum Signed Message:\n32\0\0\0\0\x83R`<\x82\x01R`<\x81Ra\x08\xDC`\\\x82a'\x9AV[Q\x90 \x926\x91a)\xA3V[\x90a>KV[\x90\x92\x91\x92a>\x85V[3`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x03a\t\x12Wa\x04!\x943\x91a7,V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x11`$\x82\x01RpInvalid signature`x\x1B`D\x82\x01R`d\x90\xFD[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`\nT`@Q`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x81R` \x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\t\x94a&\x0CV[\x16\x80_R`\x06` Ra\t\xBCa\x087`@_ 3\x90`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[_\x81\x81R`\x03` \x90\x81R`@\x80\x83 3\x84R\x90\x91R\x90 `\x01\x01\x80T`H\x1C`\xFF\x16\x91\x90`\x05\x83\x10\x15a\x06\x94W`\x03\x83\x14a\nHWi\x04\0\0\0\0\0\0\0\0\0`\xFF`H\x1B\x19\x82T\x16\x17\x90U\x80_R`\x04` Ra\n\x1E3`@_ a=\x86V[Pa\n,`@Q\x80\x93a)\x18V[`\x04` \x83\x01R_\x80Q` a?h\x839\x81Q\x91R`@3\x93\xA3\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x1F`$\x82\x01R\x7FCannot go offline while slashed\0`D\x82\x01R`d\x90\xFD[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\n\xAEa&\x0CV[\x16_R`\x08` R`@_ \x80T\x90a\n\xC6\x82a)qV[\x91a\n\xD4`@Q\x93\x84a'\x9AV[\x80\x83R` \x83\x01\x80\x92_R` _ _\x91[\x83\x83\x10a\x0B|W\x84\x86`@Q\x91\x82\x91` \x83\x01\x90` \x84RQ\x80\x91R`@\x83\x01\x90`@\x81`\x05\x1B\x85\x01\x01\x92\x91_\x90[\x82\x82\x10a\x0B$WPPPP\x03\x90\xF3[\x91\x93`\x01\x91\x93\x95P` \x80\x91`?\x19\x89\x82\x03\x01\x85R\x87Q\x90``\x80a\x0BR\x84Q`\x80\x85R`\x80\x85\x01\x90a([V[\x93\x85\x81\x01Q\x86\x85\x01R`@\x81\x01Q`@\x85\x01R\x01Q\x15\x15\x91\x01R\x96\x01\x92\x01\x92\x01\x85\x94\x93\x91\x92a\x0B\x15V[`\x04` `\x01\x92`@Qa\x0B\x8F\x81a'IV[a\x0B\x98\x86a'\xBBV[\x81R\x84\x86\x01T\x83\x82\x01R`\x02\x86\x01T`@\x82\x01R`\xFF`\x03\x87\x01T\x16\x15\x15``\x82\x01R\x81R\x01\x92\x01\x92\x01\x91\x90a\n\xE6V[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x04!a\x0B\xE5a&\x0CV[a\x0B\xEDa&8V[\x90a4ZV[4a\x03kW``6`\x03\x19\x01\x12a\x03kWa\x0C\x0Ca&\x0CV[a\x0C\x14a&\"V[`\x01`\x01`@\x1B\x03a\x0C$a)aV[\x913\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x14\x80\x15a\r\xC9W[a\x0Ca\x90a4\x1DV[\x16\x90`<\x82\x10a\r\x8FW`\xFF\x16\x91`\x01\x83\x10a\rJW\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x91`\x01`\x01`@\x1B\x03`@\x92\x16\x93\x84_R`\x02` Ra\r=`\xFF\x84_ T`H\x1C\x16\x84Q\x90a\x0C\xC7\x82a'dV[\x84\x82Ra\r\"`\xFF` \x84\x01\x86\x81R\x88\x85\x01\x93\x15\x15\x84R\x8A_R`\x02` R`\x01`\x01`@\x1B\x03\x80\x8A_ \x96Q\x16\x16`\x01`\x01`@\x1B\x03\x19\x86T\x16\x17\x85UQ\x16\x83\x90`\xFF`@\x1B\x82T\x91`@\x1B\x16\x90`\xFF`@\x1B\x19\x16\x17\x90UV[Q\x81T`\xFF`H\x1B\x19\x16\x90\x15\x15`H\x1B`\xFF`H\x1B\x16\x17\x90UV[\x82Q\x91\x82R` \x82\x01R\xA2\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x17`$\x82\x01R\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0`D\x82\x01R`d\x90\xFD[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x12`$\x82\x01Rq\x12[\x9D\x19\\\x9D\x98[\x08\x1D\x1B\xDB\xC8\x1C\xDA\x1B\xDC\x9D`r\x1B`D\x82\x01R`d\x90\xFD[P\x81\x84\x16_\x90\x81R`\x07` R`@\x90 T`\x01`\x01`\xA0\x1B\x03\x163\x14a\x0CXV[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa\x04!a\x0E\x07a&\x0CV[`\x01`\x01`@\x1B\x03\x81\x16_R`\x06` Ra\x0E7a\x087`@_ 3\x90`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[a2\xF8V[4a\x03kW`\xA06`\x03\x19\x01\x12a\x03kWa\x0EUa&\x0CV[`$5`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x0Et\x906\x90`\x04\x01a(\x7FV[\x90`D5`d5\x91`\x845\x94\x85\x15\x15\x80\x96\x03a\x03kW`\x01`\x01`@\x1B\x03\x16\x80_R`\x07` Ra\x0E\xB2`\x01\x80`\xA0\x1B\x03`@_ T\x163\x14a+\xA4V[a\x0E\xBF`@\x86\x11\x15a,\xA4V[a\x0E\xCB\x83\x85\x10\x15a,\xE0V[\x80_R`\x08` Ra\x0E\xE3`2`@_ T\x10a+\xE4V[_R`\x08` Ra\x0F\x06`@_ \x91`@Q\x95a\x0E\xFF\x87a'IV[6\x91a)\xA3V[\x84R` \x84\x01\x91\x82R`@\x84\x01\x92\x83R``\x84\x01\x94\x85R\x80T`\x01`@\x1B\x81\x10\x15a\x109Wa\x0F:\x91`\x01\x82\x01\x81Ua&\xC9V[\x93\x90\x93a\x10MWQ\x80Q\x90`\x01`\x01`@\x1B\x03\x82\x11a\x109Wa\x0Fg\x82a\x0Fa\x87Ta&\xF6V[\x87a-\x1DV[` \x90`\x1F\x83\x11`\x01\x14a\x0F\xCFW\x82`\x03\x95\x93a\x04!\x98\x95\x93a\x0F\x9F\x93_\x92a\x0F\xC4W[PP\x81`\x01\x1B\x91_\x19\x90`\x03\x1B\x1C\x19\x16\x17\x90V[\x85U[Q`\x01\x85\x01UQ`\x02\x84\x01UQ\x15\x15\x91\x01\x90`\xFF\x80\x19\x83T\x16\x91\x15\x15\x16\x17\x90UV[\x01Q\x90P\x89\x80a\x0F\x8BV[\x90`\x1F\x19\x83\x16\x91\x86_R\x81_ \x92_[\x81\x81\x10a\x10!WP\x92`\x01\x92\x85\x92`\x03\x98\x96a\x04!\x9B\x98\x96\x10a\x10\nW[PPP\x81\x1B\x01\x85Ua\x0F\xA2V[\x01Q_\x19\x83\x89\x1B`\xF8\x16\x1C\x19\x16\x90U\x88\x80\x80a\x0F\xFDV[\x92\x93` `\x01\x81\x92\x87\x86\x01Q\x81U\x01\x95\x01\x93\x01a\x0F\xDFV[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[4a\x03kWa\x10n6a*\xB0V[\x90\x91\x92`\x01\x80`\xA0\x1B\x03`\nT\x163\x03a\x11\xABW`\x01`\x01`@\x1B\x03\x16\x91\x82_R`\x05` Ra\x10\xB9`@_ \x94`\x01\x80`\xA0\x1B\x03\x16\x80\x95`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[\x15a\x11sW\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x91\x83_R`\x03` R`@_ \x85_R` R`\x01`@_ \x01i\x03\0\0\0\0\0\0\0\0\0`\xFF`H\x1B\x19\x82T\x16\x17\x90U\x83_R`\x04` Ra\x11%\x85`@_ a=\x86V[P\x83_R`\x0C` R`@_ \x85_R` R`@_ `\x01`\x01`@\x1B\x03\x80B\x16\x16`\x01`\x01`@\x1B\x03\x19\x82T\x16\x17\x90Ua\x11n`@Q\x92\x83\x92` \x84R` \x84\x01\x91a2\xD8V[\x03\x90\xA3\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x10`$\x82\x01Ro'\xB82\xB90\xBA7\xB9\x10:\xB75\xB77\xBB\xB7`\x81\x1B`D\x82\x01R`d\x90\xFD[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x13`$\x82\x01RrNot slashing oracle`h\x1B`D\x82\x01R`d\x90\xFD[4a\x03kW``6`\x03\x19\x01\x12a\x03kWa\x11\xFFa&\x0CV[a\x12\x07a&8V[`D5`\x01`\x01`@\x1B\x03\x81\x11a\x03kW` \x92\x83\x92`\x01`\x01`@\x1B\x03a\x124\x85\x946\x90`\x04\x01a)\xD9V[\x92\x16_R`\t\x83R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R\x82R`@_ `@Q\x93\x82\x85\x93Q\x91\x82\x91\x01\x84^\x82\x01\x90\x81R\x03\x01\x90 T`@Q\x90\x81R\xF3[4a\x03kWa\x12\x7F6a&dV[\x90`\x01`\x01`@\x1B\x03_\x93\x16\x92[\x82\x81\x10\x15a\x04!W`\x05\x81\x90\x1B\x82\x015`\x01`\x01`\xA0\x1B\x03\x81\x16\x91\x90\x82\x90\x03a\x03kW0;\x15a\x03kW`@Q\x91c\xBA\x1F\xB1\x03`\xE0\x1B\x83R\x85`\x04\x84\x01R`$\x83\x01R_\x82`D\x81\x830Z\xF1\x91\x82\x15a\x12\xFFW`\x01\x92a\x12\xEFW[P\x01a\x12\x8DV[_a\x12\xF9\x91a'\x9AV[\x85a\x12\xE8V[`@Q=_\x82>=\x90\xFD[4a\x03kW_6`\x03\x19\x01\x12a\x03kW_T`@Q`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x81R` \x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa\x13Ja&NV[a\x13Ra7\x19V[`\n\x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x92\x90\x92\x16\x91\x90\x91\x17\x90U\0[4a\x03kW``6`\x03\x19\x01\x12a\x03kWa\x13\xB4a\x13\xA0a\x13\x93a&\x0CV[`D5\x90`$5\x90a0\x9EV[`@Q\x92\x83\x92`@\x84R`@\x84\x01\x90a)%V[\x90` \x83\x01R\x03\x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x13\xDFa&\x0CV[\x16_R`\x04` R` `@_ T`@Q\x90\x81R\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`\x01T3`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x03a\x14hW`\x01\x80T`\x01`\x01`\xA0\x1B\x03\x19\x90\x81\x16\x90\x91U_\x80T3\x92\x81\x16\x83\x17\x82U`\x01`\x01`\xA0\x1B\x03\x16\x90\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x90\x80\xA3\0[c\x11\x8C\xDA\xA7`\xE0\x1B_R3`\x04R`$_\xFD[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x14\x94a&\x0CV[`\x01`\x01`@\x1B\x03a\x14\xA4a&8V[\x91\x16_R`\x0C` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R` `\x01`\x01`@\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x14\xF0a&\x0CV[`\x01`\x01`@\x1B\x03a\x15\0a&8V[\x91_`\x80`@Qa\x15\x10\x81a'.V[\x82\x81R\x82` \x82\x01R\x82`@\x82\x01R\x82``\x82\x01R\x01R\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ `@Qa\x15Q\x81a'.V[\x81T\x81R`\x01\x82\x01T\x91` \x82\x01\x90`\x01`\x01`@\x1B\x03\x84\x16\x82R`\xFF`@\x84\x01\x94\x81\x81`@\x1C\x16\x86R`H\x1C\x16``\x84\x01\x90`\x05\x81\x10\x15a\x06\x94W`\xA0\x95`\x01`\x01`@\x1B\x03`\x02a\x15\xCD\x95`\xFF\x94\x86R\x01T\x95`\x80\x88\x01\x96\x87R`@Q\x97Q\x88RQ\x16` \x87\x01RQ\x16`@\x85\x01RQ``\x84\x01\x90a)\x18V[Q`\x80\x82\x01R\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kWa\x15\xEDa7\x19V[`\x01\x80T`\x01`\x01`\xA0\x1B\x03\x19\x90\x81\x16\x90\x91U_\x80T\x91\x82\x16\x81U\x90`\x01`\x01`\xA0\x1B\x03\x16\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x82\x80\xA3\0[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q`@\x81R\xF3[4a\x03kW`\x806`\x03\x19\x01\x12a\x03kWa\x16la&\x0CV[a\x16ta&8V[`D5`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x16\x93\x906\x90`\x04\x01a)\xF7V[`d5\x9203\x03a\x1A\x95W`\x01`\x01`@\x1B\x03\x16\x91\x82_R`\x08` R`@_ \x93a\x16\xBE\x81a-`V[\x92_[\x82\x81\x10a\x1AnWP\x85T\x80\x15\x15\x80\x91``\x92a\x1A%W[P_[\x84\x81\x10a\x18\x17WPPPPP_\x92\x84T\x94[\x85\x85\x10a\x16\xF6W\0[`\xFF`\x03a\x17\x04\x87\x84a&\xC9V[P\x01T\x16\x15a\x18\rWa\x17*a\x171a\x17\x1D\x87\x84a&\xC9V[P`@Q\x92\x83\x80\x92a-\xF2V[\x03\x82a'\x9AV[` \x81Q\x91\x01 _\x94_[\x81Q\x81\x10\x15a\x17\xFFW\x82a\x17P\x82\x84a-\x92V[Q\x14a\x17^W`\x01\x01a\x17<V[P\x94PP\x94\x93`\x01\x90\x81[\x15a\x17wW[\x01\x93\x94a\x16\xEDV[a\x17\x81\x81\x88a&\xC9V[P\x83\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15a\x17\xB9`@Q\x93`@\x85R`@\x85\x01\x90a-\xF2V[\x92\x7FRequired metric missing\0\0\0\0\0\0\0\0\0` \x82\x86\x03\x95\x86\x82\x85\x01R`\x17\x81R\x01R`@\x86\x80`\xA0\x1B\x03\x89\x16\x94\x01\x90\xA3a\x17oV[P\x94`\x01\x92\x97\x96\x91Pa\x17iV[\x94\x93`\x01\x90a\x17oV[`\x01_\x83a\x18\xEFW[P\x90`\x01\x91a\x180W[\x01a\x16\xDBV[` a\x18<\x82\x87a-\x92V[Q\x01Q\x89_R`\t` R`@_ \x83\x80`\xA0\x1B\x03\x89\x16_R` R` \x80`@_ a\x18i\x85\x8Aa-\x92V[QQ\x90`@Q\x93\x82\x85\x93Q\x91\x82\x91\x01\x84^\x82\x01\x90\x81R\x03\x01\x90 Ua\x18\x8E\x81\x86a-\x92V[QQ\x89\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD` a\x18\xBE\x85\x8Aa-\x92V[Q\x01Q\x92a\x18\xD7`@Q\x91`@\x83R`@\x83\x01\x90a([V[\x93` \x82\x01R\x80\x86\x80`\xA0\x1B\x03\x8C\x16\x94\x03\x90\xA3a\x18*V[\x8AT_[\x81\x81\x10a\x19\x16W[PP\x90`\x01\x92\x91\x15a\x19\x0FW[\x90\x91a\x18 V[P_a\x19\x08V[a\x19 \x85\x8Ca-\x92V[Qa\x19+\x82\x89a-\x92V[Q\x14a\x199W`\x01\x01a\x18\xF3V[`\x01\x94\x93\x92P\x84\x91P\x8C` a\x19O\x86\x8Ba-\x92V[Q\x01Q\x83a\x19]\x84\x84a&\xC9V[P\x01T\x11\x91\x82\x15a\x19\xFCW[PPa\x19yW[\x90\x91\x92\x8Ca\x18\xFBV[\x90Pa\x19\x85\x82\x87a-\x92V[QQ\x8A\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15a\x19\xBE`@Q\x93`@\x85R`@\x85\x01\x90a([V[\x92rValue out of bounds`h\x1B` \x82\x86\x03\x95\x86\x82\x85\x01R`\x13\x81R\x01R`@\x87\x80`\xA0\x1B\x03\x8D\x16\x94\x01\x90\xA3_\x90a\x19pV[`\x02\x91\x92Pa\x1A\x1A\x90` a\x1A\x11\x88\x8Da-\x92V[Q\x01Q\x93a&\xC9V[P\x01T\x10\x8C\x8Ea\x19iV[\x91Pa\x1A0\x82a-`V[\x91\x88_[\x82\x81\x10a\x1ABWPPa\x16\xD8V[a\x17*a\x1ATa\x17\x1D\x83`\x01\x95a&\xC9V[` \x81Q\x91\x01 a\x1Ae\x82\x87a-\x92V[R\x01\x89\x90a\x1A4V[\x80a\x1A{`\x01\x92\x84a-\x92V[QQ` \x81Q\x91\x01 a\x1A\x8E\x82\x88a-\x92V[R\x01a\x16\xC1V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\r`$\x82\x01RlInternal only`\x98\x1B`D\x82\x01R`d\x90\xFD[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x1A\xE3a&\x0CV[`\x01`\x01`@\x1B\x03a\x1A\xF3a&8V[\x91\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R` `\xFF`\x01`@_ \x01T`H\x1C\x16a\x1B+`@Q\x80\x92a)\x18V[\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q`\x03\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kW` a\x04\xC1a\x1Bfa&\x0CV[`\x01`\x01`@\x1B\x03a\x1Bva&8V[\x91\x16_\x90\x81R`\x06\x84R`@\x80\x82 `\x01`\x01`\xA0\x1B\x03\x90\x93\x16\x82R`\x01\x90\x92\x01` R T\x15\x15\x90V[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q`2\x81R\xF3[4a\x03kW`\x806`\x03\x19\x01\x12a\x03kWa\x1B\xD5a&\x0CV[a\x1B\xDDa&\"V[\x90a\x1B\xE6a)aV[\x91`d5\x92`\x01`\x01`@\x1B\x03\x84\x11a\x03kWa\x1C\na\x04!\x946\x90`\x04\x01a(\x7FV[\x93\x90\x92`\x01`\x01`@\x1B\x03\x82\x16_R`\x06` Ra\x1C=a\x087`@_ 3\x90`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[3\x91a7,V[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`@Q\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x81R` \x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa\x1C\xC1a\x1C\xACa\x1C\xA7a&\x0CV[a.\x8DV[P`@Q\x91\x82\x91` \x83R` \x83\x01\x90a)%V[\x03\x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x1C\xE6a&\x0CV[\x16_R`\x07` R` `\x01\x80`\xA0\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x1D\x1Ea&\x0CV[`\x01`\x01`@\x1B\x03a\x1D.a&8V[\x91\x16\x80_R`\x03` R`@_ `\x01\x80`\xA0\x1B\x03\x83\x16_R` R`\xFF`\x01`@_ \x01T`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W\x15\x90\x81\x15a\x1DwW[` \x82`@Q\x90\x15\x15\x81R\xF3[\x90P_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`\xFF`\x01`@_ \x01T`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x01` \x91\x14\x82a\x1DjV[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q`\xC8\x81R\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x1D\xF1a&\x0CV[\x16\x80_R`\x04` R`@_ Ta\x1E\x08\x81a-`V[\x91_[\x82\x81\x10a\x1E(W`@Q` \x80\x82R\x81\x90a\x1C\xC1\x90\x82\x01\x87a)%V[`\x01\x90\x82_R`\x04` Ra\x1E@\x81`@_ a;\x10V[\x83\x80`\xA0\x1B\x03\x91T\x90`\x03\x1B\x1C\x16a\x1EX\x82\x87a-\x92V[\x90\x83\x80`\xA0\x1B\x03\x16\x90R\x01a\x1E\x0BV[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x1E\x89a&\x0CV[\x16_R`\x05` R` `@_ T`@Q\x90\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x1E\xB9a&\x0CV[`\x01`\x01`@\x1B\x03a\x1E\xC9a&8V[\x91\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`\xA0`@_ \x80T\x90a\x1F,`\x02`\x01\x83\x01T\x92\x01T\x91`@Q\x93\x84R`\x01`\x01`@\x1B\x03\x81\x16` \x85\x01R`\xFF\x81`@\x1C\x16`@\x85\x01R`\xFF``\x85\x01\x91`H\x1C\x16a)\x18V[`\x80\x82\x01R\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Qa\x0E\x10\x81R\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x045`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x1F\xB9\x906\x90`\x04\x01a(\x7FV[\x81\x01\x90` \x81\x83\x03\x12a\x03kW\x805\x91`\x01`\x01`@\x1B\x03\x83\x11a\x03kWa\x1C\xC1\x92a\x1F\xE5\x92\x01a)\xF7V[`@Q\x91\x82\x91` \x83R` \x83\x01\x90a(\xACV[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`\x0BT`@Q`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x81R` \x90\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Qa\x01,\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa Va&\x0CV[`\x01`\x01`@\x1B\x03`$5\x91\x16_R`\x08` R`@_ \x80T\x82\x10\x15a\x03kWa \xB7\x91a \x84\x91a&\xC9V[Pa \x8E\x81a'\xBBV[\x90`\x01\x81\x01T\x90`\xFF`\x03`\x02\x83\x01T\x92\x01T\x16\x90`@Q\x94\x85\x94`\x80\x86R`\x80\x86\x01\x90a([V[\x92` \x85\x01R`@\x84\x01R\x15\x15``\x83\x01R\x03\x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa \xE6a&NV[a \xEEa7\x19V[`\x0B\x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x92\x90\x92\x16\x91\x90\x91\x17\x90U\0[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa!)a&\x0CV[a!1a&8V[a!e3\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x14a+\x06V[`\x01`\x01`\xA0\x1B\x03\x16\x90\x81\x15a!\xEBW`\x01`\x01`@\x1B\x03\x16\x80_R`\x06` Ra!\x9Ba!\x96\x83`@_ a;%V[a+EV[\x80_R`\x03` R`@_ \x82_R` R`\x01`@_ \x01`\x01`I\x1B`\xFF`H\x1B\x19\x82T\x16\x17\x90U\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK_\x80\xA3\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x0C`$\x82\x01RkZero address`\xA0\x1B`D\x82\x01R`d\x90\xFD[4a\x03kW`\x01`\x01`@\x1B\x03a\"56a&dV[\x91\x92\x90\x92\x16\x90\x81_R`\x07` Ra\"Z`\x01\x80`\xA0\x1B\x03`@_ T\x163\x14a+\xA4V[a\"g`2\x82\x11\x15a+\xE4V[\x81_R`\x08` R`@_ \x80T\x90_\x81U\x81a$!W[PP_[\x81\x81\x10a\"\x8CW\0[a\"\xAE`@a\"\xA5a\"\x9F\x84\x86\x89a,PV[\x80a,rV[\x90P\x11\x15a,\xA4V[a\"\xD6`@a\"\xBE\x83\x85\x88a,PV[\x015` a\"\xCD\x84\x86\x89a,PV[\x015\x11\x15a,\xE0V[\x82_R`\x08` R`@_ \x90a\"\xEE\x81\x84\x87a,PV[\x91\x80T`\x01`@\x1B\x81\x10\x15a\x109Wa#\x0C\x91`\x01\x82\x01\x81Ua&\xC9V[\x92\x90\x92a\x10MWa#\x1D\x81\x80a,rV[\x90`\x01`\x01`@\x1B\x03\x82\x11a\x109Wa#:\x82a\x0Fa\x87Ta&\xF6V[_\x90`\x1F\x83\x11`\x01\x14a#\xBAW\x91\x80a#k\x92``\x95\x94_\x92a#\xAFWPP\x81`\x01\x1B\x91_\x19\x90`\x03\x1B\x1C\x19\x16\x17\x90V[\x84U[` \x81\x015`\x01\x85\x01U`@\x81\x015`\x02\x85\x01U\x015\x91\x82\x15\x15\x83\x03a\x03kW`\x01\x92`\x03a#\xA9\x92\x01\x90`\xFF\x80\x19\x83T\x16\x91\x15\x15\x16\x17\x90UV[\x01a\"\x83V[\x015\x90P\x8A\x80a\x0F\x8BV[`\x1F\x19\x83\x16\x91\x86_R` _ \x92_[\x81\x81\x10a$\tWP\x91`\x01\x93\x91\x85``\x97\x96\x94\x10a#\xF0W[PPP\x81\x1B\x01\x84Ua#nV[\x015_\x19`\x03\x84\x90\x1B`\xF8\x16\x1C\x19\x16\x90U\x89\x80\x80a#\xE3V[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a#\xCAV[`\x01`\x01`\xFE\x1B\x03\x82\x16\x82\x03a\x06\x80W_R` _ \x90`\x02\x1B\x81\x01\x90[\x81\x81\x10\x15a\"\x7FW\x80a$T`\x04\x92Ta&\xF6V[\x80a$sW[P_`\x01\x82\x01U_`\x02\x82\x01U_`\x03\x82\x01U\x01a$?V[`\x1F\x81\x11`\x01\x14a$\x89WP_\x81U[\x86a$ZV[a$\xA6\x90\x82_R`\x01`\x1F` _ \x92\x01`\x05\x1C\x82\x01\x91\x01a,:V[\x80_R_` \x81 \x81\x83UUa$\x83V[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa$\xD0a&\x0CV[`\x01`\x01`@\x1B\x03a$\xE0a&8V[\x91\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R` `@_ T`@Q\x90\x81R\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW``a%6a%(a&\x0CV[a%0a+\x86V[Pa6\xA3V[`@\x80Q\x91`\x01`\x01`@\x1B\x03\x81Q\x16\x83R`\xFF` \x82\x01Q\x16` \x84\x01R\x01Q\x15\x15`@\x82\x01R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa%ya&\x0CV[`\x01`\x01`@\x1B\x03a%\x89a&8V[\x91a%\xBE3\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x14a+\x06V[\x16_\x81\x81R`\x07` R`@\x90 Ta%\xE0\x90`\x01`\x01`\xA0\x1B\x03\x16\x15a+EV[_\x90\x81R`\x07` R`@\x90 \x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x90\x92\x16\x91\x90\x91\x17\x90U\0[`\x045\x90`\x01`\x01`@\x1B\x03\x82\x16\x82\x03a\x03kWV[`$5\x90`\x01`\x01`@\x1B\x03\x82\x16\x82\x03a\x03kWV[`$5\x90`\x01`\x01`\xA0\x1B\x03\x82\x16\x82\x03a\x03kWV[`\x045\x90`\x01`\x01`\xA0\x1B\x03\x82\x16\x82\x03a\x03kWV[`@`\x03\x19\x82\x01\x12a\x03kW`\x045`\x01`\x01`@\x1B\x03\x81\x16\x81\x03a\x03kW\x91`$5`\x01`\x01`@\x1B\x03\x81\x11a\x03kW`\x04\x01\x82`\x1F\x82\x01\x12\x15a\x03kW\x805\x92`\x01`\x01`@\x1B\x03\x84\x11a\x03kW` \x80\x83\x01\x92\x85`\x05\x1B\x01\x01\x11a\x03kW\x91\x90V[\x80T\x82\x10\x15a&\xE2W_R` _ \x90`\x02\x1B\x01\x90_\x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[\x90`\x01\x82\x81\x1C\x92\x16\x80\x15a'$W[` \x83\x10\x14a'\x10WV[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x91`\x7F\x16\x91a'\x05V[`\xA0\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[`\x80\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[``\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[`@\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[\x90`\x1F\x80\x19\x91\x01\x16\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[\x90`@Q\x91\x82_\x82T\x92a'\xCE\x84a&\xF6V[\x80\x84R\x93`\x01\x81\x16\x90\x81\x15a(9WP`\x01\x14a'\xF5W[Pa'\xF3\x92P\x03\x83a'\x9AV[V[\x90P_\x92\x91\x92R` _ \x90_\x91[\x81\x83\x10a(\x1DWPP\x90` a'\xF3\x92\x82\x01\x01_a'\xE6V[` \x91\x93P\x80`\x01\x91T\x83\x85\x89\x01\x01R\x01\x91\x01\x90\x91\x84\x92a(\x04V[\x90P` \x92Pa'\xF3\x94\x91P`\xFF\x19\x16\x82\x84\x01R\x15\x15`\x05\x1B\x82\x01\x01_a'\xE6V[\x80Q\x80\x83R` \x92\x91\x81\x90\x84\x01\x84\x84\x01^_\x82\x82\x01\x84\x01R`\x1F\x01`\x1F\x19\x16\x01\x01\x90V[\x91\x81`\x1F\x84\x01\x12\x15a\x03kW\x825\x91`\x01`\x01`@\x1B\x03\x83\x11a\x03kW` \x83\x81\x86\x01\x95\x01\x01\x11a\x03kWV[\x90\x80` \x83Q\x91\x82\x81R\x01\x91` \x80\x83`\x05\x1B\x83\x01\x01\x94\x01\x92_\x91[\x83\x83\x10a(\xD7WPPPPP\x90V[\x90\x91\x92\x93\x94` \x80`\x01\x92`\x1F\x19\x85\x82\x03\x01\x86R\x88Q\x90\x82\x80a)\x03\x84Q`@\x85R`@\x85\x01\x90a([V[\x93\x01Q\x91\x01R\x97\x01\x93\x01\x93\x01\x91\x93\x92\x90a(\xC8V[\x90`\x05\x82\x10\x15a\x06\x94WRV[\x90` \x80\x83Q\x92\x83\x81R\x01\x92\x01\x90_[\x81\x81\x10a)BWPPP\x90V[\x82Q`\x01`\x01`\xA0\x1B\x03\x16\x84R` \x93\x84\x01\x93\x90\x92\x01\x91`\x01\x01a)5V[`D5\x90`\xFF\x82\x16\x82\x03a\x03kWV[`\x01`\x01`@\x1B\x03\x81\x11a\x109W`\x05\x1B` \x01\x90V[`\x01`\x01`@\x1B\x03\x81\x11a\x109W`\x1F\x01`\x1F\x19\x16` \x01\x90V[\x92\x91\x92a)\xAF\x82a)\x88V[\x91a)\xBD`@Q\x93\x84a'\x9AV[\x82\x94\x81\x84R\x81\x83\x01\x11a\x03kW\x82\x81` \x93\x84_\x96\x017\x01\x01RV[\x90\x80`\x1F\x83\x01\x12\x15a\x03kW\x81` a)\xF4\x935\x91\x01a)\xA3V[\x90V[\x81`\x1F\x82\x01\x12\x15a\x03kW\x805\x90a*\x0E\x82a)qV[\x92a*\x1C`@Q\x94\x85a'\x9AV[\x82\x84R` \x80\x85\x01\x93`\x05\x1B\x83\x01\x01\x91\x81\x83\x11a\x03kW` \x81\x01\x93[\x83\x85\x10a*HWPPPPP\x90V[\x845`\x01`\x01`@\x1B\x03\x81\x11a\x03kW\x82\x01`@\x81\x85\x03`\x1F\x19\x01\x12a\x03kW`@Q\x91a*u\x83a'\x7FV[` \x82\x015\x92`\x01`\x01`@\x1B\x03\x84\x11a\x03kW`@\x83a*\x9D\x88` \x80\x98\x81\x98\x01\x01a)\xD9V[\x83R\x015\x83\x82\x01R\x81R\x01\x94\x01\x93a*9V[```\x03\x19\x82\x01\x12a\x03kW`\x045`\x01`\x01`@\x1B\x03\x81\x16\x81\x03a\x03kW\x91`$5`\x01`\x01`\xA0\x1B\x03\x81\x16\x81\x03a\x03kW\x91`D5\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03kWa+\x02\x91`\x04\x01a(\x7FV[\x90\x91V[\x15a+\rWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x10`$\x82\x01RoOnly Tangle core`\x80\x1B`D\x82\x01R`d\x90\xFD[\x15a+LWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x12`$\x82\x01Rq\x10[\x1C\x99XY\x1EH\x1C\x99Y\xDA\\\xDD\x19\\\x99Y`r\x1B`D\x82\x01R`d\x90\xFD[`@Q\x90a+\x93\x82a'dV[_`@\x83\x82\x81R\x82` \x82\x01R\x01RV[\x15a+\xABWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x11`$\x82\x01Rp'7\xBA\x109\xB2\xB9;4\xB1\xB2\x907\xBB\xB72\xB9`y\x1B`D\x82\x01R`d\x90\xFD[\x15a+\xEBWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x14`$\x82\x01RsToo many definitions``\x1B`D\x82\x01R`d\x90\xFD[\x81\x81\x02\x92\x91\x81\x15\x91\x84\x04\x14\x17\x15a\x06\x80WV[\x81\x81\x10a,EWPPV[_\x81U`\x01\x01a,:V[\x91\x90\x81\x10\x15a&\xE2W`\x05\x1B\x81\x015\x90`~\x19\x816\x03\x01\x82\x12\x15a\x03kW\x01\x90V[\x905\x90`\x1E\x19\x816\x03\x01\x82\x12\x15a\x03kW\x01\x805\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03kW` \x01\x91\x816\x03\x83\x13a\x03kWV[\x15a,\xABWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\r`$\x82\x01RlName too long`\x98\x1B`D\x82\x01R`d\x90\xFD[\x15a,\xE7WV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x0E`$\x82\x01RmInvalid bounds`\x90\x1B`D\x82\x01R`d\x90\xFD[\x91\x90`\x1F\x81\x11a-,WPPPV[a'\xF3\x92_R` _ \x90` `\x1F\x84\x01`\x05\x1C\x83\x01\x93\x10a-VW[`\x1F\x01`\x05\x1C\x01\x90a,:V[\x90\x91P\x81\x90a-IV[\x90a-j\x82a)qV[a-w`@Q\x91\x82a'\x9AV[\x82\x81R\x80\x92a-\x88`\x1F\x19\x91a)qV[\x01\x90` 6\x91\x017V[\x80Q\x82\x10\x15a&\xE2W` \x91`\x05\x1B\x01\x01\x90V[\x15a-\xADWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x17`$\x82\x01R\x7FNot registered operator\0\0\0\0\0\0\0\0\0`D\x82\x01R`d\x90\xFD[_\x92\x91\x81T\x91a.\x01\x83a&\xF6V[\x80\x83R\x92`\x01\x81\x16\x90\x81\x15a.VWP`\x01\x14a.\x1DWPPPV[_\x90\x81R` \x81 \x93\x94P\x91\x92[\x83\x83\x10a.<WP` \x92P\x01\x01\x90V[`\x01\x81` \x92\x94\x93\x94T\x83\x85\x87\x01\x01R\x01\x91\x01\x91\x90a.+V[\x91PP` \x93\x94P`\xFF\x92\x91\x92\x19\x16\x83\x83\x01R\x15\x15`\x05\x1B\x01\x01\x90V[\x91\x90\x82\x01\x80\x92\x11a\x06\x80WV[\x91\x90\x82\x03\x91\x82\x11a\x06\x80WV[`\x01`\x01`@\x1B\x03a.\x9E\x82a6\xA3V[\x91\x16\x91\x82_R`\x05` R`@_ T\x91` \x81\x01\x90`\xFF\x82Q\x16\x15\x80\x15a0\x96W[\x80\x15a0\x8EW[a0pW\x90`\xFF`\x01`\x01`@\x1B\x03a.\xE6\x93Q\x16\x91Q\x16\x90a,'V[`\xC8\x83\x10\x15a0iW\x82[a.\xFA\x81a-`V[\x94_\x92_[\x83\x81\x10a/JWPPPPa/\x13\x81a-`V[\x93_[\x82\x81\x10a/\"WPPPV[`\x01\x90`\x01`\x01`\xA0\x1B\x03a/7\x82\x85a-\x92V[Q\x16a/C\x82\x89a-\x92V[R\x01a/\x16V[\x82_R`\x05` Ra/_\x81`@_ a;\x10V[\x90T_\x85\x81R`\x06` \x90\x81R`@\x80\x83 `\x03\x95\x90\x95\x1B\x93\x90\x93\x1C`\x01`\x01`\xA0\x1B\x03\x16\x80\x83R`\x01\x94\x90\x94\x01\x90R T\x15a0`W\x83_R`\x03` R`@_ \x81_R` R`@_ `@Qa/\xB8\x81a'.V[\x81T\x81R`\xFF`\x01\x83\x01T`\x01`\x01`@\x1B\x03\x81\x16` \x84\x01R\x81\x81`@\x1C\x16`@\x84\x01R`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x02\x86\x93\x82``\x85\x01R\x01T`\x80\x83\x01R\x81Q\x15\x90\x81\x15a0UW[Pa0JWa0\x16\x90QBa.\x80V[\x10\x15a0(W[P`\x01\x90[\x01a.\xFFV[a05\x86\x8A\x97\x93\x97a-\x92V[R_\x19\x81\x14a\x06\x80W`\x01\x80\x91\x01\x94\x90a0\x1DV[PPP`\x01\x90a0\"V[`\x03\x91P\x14_a0\x06V[P`\x01\x90a0\"V[`\xC8a.\xF1V[PP\x90\x91P`@Qa0\x83` \x82a'\x9AV[_\x81R_6\x817\x91\x90V[P\x83\x15a.\xC8V[P\x83\x15a.\xC1V[\x91\x92\x90`\x01`\x01`@\x1B\x03a0\xB2\x84a6\xA3V[\x93\x16\x80_R`\x05` R`@_ T\x93` \x81\x01\x90`\xFF\x82Q\x16\x15\x80\x15a2\xD0W[\x80\x15a2\xC6W[a2\xB1W\x90`\xFF`\x01`\x01`@\x1B\x03a0\xF9\x93Q\x16\x91Q\x16\x90a,'V[\x94`\xC8\x81\x11\x15a2\xACWP`\xC8[\x84a1\x12\x82\x85a.sV[\x11\x15a2\x9CWP\x83\x90[a1.a1)\x84\x84a.\x80V[a-`V[\x95_\x93[\x83\x81\x10a1}WPPPPa1F\x81a-`V[\x93_[\x82\x81\x10a1UWPPPV[`\x01\x90`\x01`\x01`\xA0\x1B\x03a1j\x82\x85a-\x92V[Q\x16a1v\x82\x89a-\x92V[R\x01a1IV[\x82_R`\x05` Ra1\x92\x81`@_ a;\x10V[\x90T_\x85\x81R`\x06` \x90\x81R`@\x80\x83 `\x03\x95\x90\x95\x1B\x93\x90\x93\x1C`\x01`\x01`\xA0\x1B\x03\x16\x80\x83R`\x01\x94\x90\x94\x01\x90R T\x15a2\x93W\x83_R`\x03` R`@_ \x81_R` R`@_ `@Qa1\xEB\x81a'.V[\x81T\x81R`\xFF`\x01\x83\x01T`\x01`\x01`@\x1B\x03\x81\x16` \x84\x01R\x81\x81`@\x1C\x16`@\x84\x01R`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x02\x86\x93\x82``\x85\x01R\x01T`\x80\x83\x01R\x81Q\x15\x90\x81\x15a2\x88W[Pa2}Wa2I\x90QBa.\x80V[\x10\x15a2[W[P`\x01\x90[\x01a12V[a2h\x86\x8A\x97\x93\x97a-\x92V[R_\x19\x81\x14a\x06\x80W`\x01\x80\x91\x01\x94\x90a2PV[PPP`\x01\x90a2UV[`\x03\x91P\x14_a29V[P`\x01\x90a2UV[a2\xA6\x90\x83a.sV[\x90a1\x1CV[a1\x07V[PPPP\x90\x91P`@Qa0\x83` \x82a'\x9AV[P\x85\x84\x10\x15a0\xDBV[P\x85\x15a0\xD4V[\x90\x80` \x93\x92\x81\x84R\x84\x84\x017_\x82\x82\x01\x84\x01R`\x1F\x01`\x1F\x19\x16\x01\x01\x90V[`\x01`\x01`@\x1B\x03\x16_\x81\x81R`\x03` \x90\x81R`@\x80\x83 3\x84R\x90\x91R\x90 `\x01\x01\x80T`H\x1C`\xFF\x16\x91\x90`\x05\x83\x10\x15a\x06\x94W`\x03\x83\x14a3\xD8W\x82\x15\x80\x15a3\xCEW[a3\xC9W\x80Ti\xFF\xFF\0\0\0\0\0\0\0\0\x19\x16i\x01\0\0\0\0\0\0\0\0\0\x17\x90U_\x81\x81R`\x04` R`@\x90 a3y\x903\x90a;%V[Pa3\xAD`@Q\x80\x933\x84\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C_\x80\xA3a)\x18V[`\x01` \x83\x01R_\x80Q` a?h\x839\x81Q\x91R`@3\x93\xA3V[PPPV[P`\x01\x83\x14a3@V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x1E`$\x82\x01R\x7FCannot go online while slashed\0\0`D\x82\x01R`d\x90\xFD[\x15a4$WV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x0E`$\x82\x01Rm\x13\x9B\xDD\x08\x18]]\x1A\x1B\xDC\x9A^\x99Y`\x92\x1B`D\x82\x01R`d\x90\xFD[\x90`\x01`\x01`@\x1B\x03\x82\x16\x90\x81_R`\x03` R`@_ `\x01\x80`\xA0\x1B\x03\x82\x16_R` Ra4\x8D`@_ \x93a6\xA3V[\x92`\x01\x81\x01\x93\x84T\x91`\xFF\x83`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x03\x14a4\xEFWT\x80\x15a4\xEFWa4\xBE\x90Ba.\x80V[`\x01`\x01`@\x1B\x03\x82Q\x16\x90\x81\x15a5\xE9W\x04`\xFF\x81\x11\x15a5\xE1WP`\xFF[`\xFF\x80\x82\x16\x93`@\x1C\x16\x83\x11a4\xF7W[PPPPPPV[\x85T`@\x91\x90\x91\x1B`\xFF`@\x1B\x16h\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x19\x90\x91\x16\x17\x85U` \x01Q`\xFF\x16\x81\x10\x15\x80a5\xC6W[a52W[\x80\x80a4\xEFV[\x83_\x80Q` a?h\x839\x81Q\x91R\x92\x84\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM` `@\x95`\xFFa5\xA2\x9AT`H\x1C\x16\x95`\x01`I\x1B`\xFF`H\x1B\x19\x82T\x16\x17\x90U\x83_R`\x04\x82R\x86_ \x94`\x01\x80`\xA0\x1B\x03\x16\x99\x8A\x80\x96a=\x86V[P\x86Q\x90\x81R\xA3a5\xB5\x82Q\x80\x92a)\x18V[`\x02` \x82\x01R\xA3_\x80\x80\x80a5+V[P`\xFF\x84T`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x02\x14\x15a5&V[`\xFF\x16a4\xDEV[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[\x90`\x01`\x01`@\x1B\x03a6\x0F\x83a6\xA3V[\x92\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ `@Q\x90a6;\x82a'.V[\x80T\x82R`\xFF`\x01\x82\x01T`\x01`\x01`@\x1B\x03\x81\x16` \x85\x01R\x81\x81`@\x1C\x16`@\x85\x01R`H\x1C\x16\x90`\x05\x82\x10\x15a\x06\x94W`\x02\x91``\x84\x01R\x01T`\x80\x82\x01RQ\x80\x15a6\x9DWa6\x96`\x01`\x01`@\x1B\x03\x91Ba.\x80V[\x91Q\x16\x11\x90V[PP_\x90V[`\x01`\x01`@\x1B\x03\x90a6\xB4a+\x86V[P\x16_R`\x02` R`@_ `@Q\x90a6\xCE\x82a'dV[T`\x01`\x01`@\x1B\x03\x81\x16\x80\x83R`\xFF\x82`@\x1C\x16\x90`\xFF` \x85\x01\x93\x83\x85R`H\x1C\x16\x15\x15`@\x85\x01R\x15a7\x0FW[\x15a7\x08WP\x90V[`\x03\x90R\x90V[a\x01,\x83Ra6\xFFV[_T`\x01`\x01`\xA0\x1B\x03\x163\x03a\x14hWV[\x90\x92\x93\x91`\x01`\x01`@\x1B\x03\x82\x16\x95\x86_R`\x03` R`@_ `\x01\x80`\xA0\x1B\x03\x83\x16_R` R`@_ \x94a7c\x84a6\xA3V[\x90`\x01\x87\x01\x94`\xFF\x86T`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x03\x14a:\xD5W_\x8A\x81R`\x05` R`@\x90 `\x01`\x01`\xA0\x1B\x03\x86\x16\x99\x90a7\xA5\x90\x8B\x90a;%V[P`\xFF\x87T`H\x1C\x16\x98B\x81U`\x02a7\xBF6\x88\x8Ca)\xA3V[` \x81Q\x91\x01 \x91\x01U`\xFF`@\x1B\x19\x87T\x16\x87U`\x01`\x01`@\x1B\x03\x87T\x16\x90`\x01`\x01`@\x1B\x03\x82\x14a\x06\x80W`\x01`\x01`@\x1B\x03`\x01`\xFF\x93\x01\x16`\x01`\x01`@\x1B\x03\x19\x89T\x16\x17\x88U\x16\x93\x84\x15_\x14a9\xC3W_\x97[`\x05\x89\x10\x15\x97\x88a\x06\x94W\x80T`\xFF`H\x1B\x19\x16`H\x8B\x90\x1B`\xFF`H\x1B\x16\x17\x90U`\x05\x8A\x10\x15a\x06\x94W\x8A\x96\x8C\x95`\x02\x8C\x14\x8B\x81a9\xB4W[P\x92`@\x95\x92\x86`\x01`\x01`@\x1B\x03\x96\x93\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x99\x96a9tW[\x01Q\x15\x15\x80a9kW[a9YW[PPPP\x82Q\x95\x86RB` \x87\x01R\x16\x93\xA4a\x06\x94W\x82\x91\x84\x91\x80\x82\x03a9$W[PP`\x0BT`\x01`\x01`\xA0\x1B\x03\x16\x93\x91P\x83\x90Pa8\xDAWPPPV[\x82;\x15a\x03kW`d_\x92\x83`@Q\x95\x86\x94\x85\x93cj<)\xDB`\xE1\x1B\x85R`\x04\x85\x01R`$\x84\x01R`\x01`\x01`@\x1B\x03B\x16`D\x84\x01RZ\xF1a9\x1AWPV[_a'\xF3\x91a'\x9AV[_\x80Q` a?h\x839\x81Q\x91R\x91a9O`@\x92a9E\x84Q\x80\x94a)\x18V[` \x83\x01\x90a)\x18V[\xA3\x80\x82_\x80a8\xBDV[a9b\x93a;\x88V[_\x80\x80\x80a8\x9BV[P\x82\x15\x15a8\x96V[\x8A_R`\x04` Ra9\x88\x8D\x83_ a;%V[P\x8C\x8B\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C_\x80\xA3a8\x8CV[_\x9BP`\x02\x14\x15\x90P\x8Ba8SV[`d\x85\x10\x15a9\xD4W`\x01\x97a8\x19V[`\x01\x97`\xC8\x86\x10a8\x19W`\x01`\x01`@\x1B\x03B\x16\x8C_R`\x0C` R`@_ \x8C_R` R`\x01`\x01`@\x1B\x03`@_ T\x16\x80\x15\x90\x81\x15a:\xAEW[Pa:\x1FW[Pa8\x19V[\x8C_R`\x0C` R`@_ \x8C_R` R`\x01`\x01`@\x1B\x03`@_ \x91\x16`\x01`\x01`@\x1B\x03\x19\x82T\x16\x17\x90U\x8A\x8C\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91```@Q` \x81R`\x1B` \x82\x01R\x7FProtocol violation reported\0\0\0\0\0`@\x82\x01R\xA3_a:\x19V[\x90P\x81\x03`\x01`\x01`@\x1B\x03\x81\x11a\x06\x80W`\x01`\x01`@\x1B\x03a\x0E\x10\x91\x16\x10\x15_a:\x13V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x13`$\x82\x01Rr\x13\xDC\x19\\\x98]\x1B\xDC\x88\x1A\\\xC8\x1C\xDB\x18\\\xDA\x19Y`j\x1B`D\x82\x01R`d\x90\xFD[\x80T\x82\x10\x15a&\xE2W_R` _ \x01\x90_\x90V[_\x82\x81R`\x01\x82\x01` R`@\x90 Ta6\x9DW\x80T\x90`\x01`@\x1B\x82\x10\x15a\x109W\x82a;sa;]\x84`\x01\x80\x96\x01\x85U\x84a;\x10V[\x81\x93\x91T\x90`\x03\x1B\x91\x82\x1B\x91_\x19\x90\x1B\x19\x16\x17\x90V[\x90U\x80T\x92_R\x01` R`@_ U`\x01\x90V[\x91\x90\x92\x80\x15a=\x80Wa\xC3P\x81\x11a=\x80W`@Qc1\xE3\xBD\x1B`\xE0\x1B\x81R` `\x04\x82\x01R\x91_\x91\x83\x91\x82\x91a;\xC4\x91`$\x84\x01\x91\x90a2\xD8V[\x03\x810Z\xFA_\x91\x81a<UW[Pa;\xDBWPPPV[\x80Q`2\x81\x11\x15a<OWP`2\x91[0;\x15a\x03kW`@Qc2\xD3I\xB7`\xE1\x1B\x81R`\x01`\x01`@\x1B\x03\x91\x90\x91\x16`\x04\x82\x01R`\x01`\x01`\xA0\x1B\x03\x90\x93\x16`$\x84\x01R`\x80`D\x84\x01R_\x91\x83\x91\x82\x91\x90a<<\x90`\x84\x84\x01\x90a(\xACV[\x90`d\x83\x01R\x03\x81\x830Z\xF1a9\x1AWPV[\x91a;\xEBV[\x90\x91P=\x80_\x83>a<g\x81\x83a'\x9AV[\x81\x01\x90` \x81\x83\x03\x12a\x03kW\x80Q\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03kW\x01\x90\x80`\x1F\x83\x01\x12\x15a\x03kW\x81Q\x91a<\x9E\x83a)qV[\x92a<\xAC`@Q\x94\x85a'\x9AV[\x80\x84R` \x80\x85\x01\x91`\x05\x1B\x83\x01\x01\x91\x83\x83\x11a\x03kW` \x81\x01\x91[\x83\x83\x10a<\xDCWPPPPP\x90_a;\xD1V[\x82Q`\x01`\x01`@\x1B\x03\x81\x11a\x03kW\x82\x01\x90`@\x82\x87\x03`\x1F\x19\x01\x12a\x03kW`@Q\x90a=\n\x82a'\x7FV[` \x83\x01Q`\x01`\x01`@\x1B\x03\x81\x11a\x03kW` \x90\x84\x01\x01\x91\x87`\x1F\x84\x01\x12\x15a\x03kW\x82Q\x92a=;\x84a)\x88V[\x94a=I`@Q\x96\x87a'\x9AV[\x84\x86R\x89` \x86\x84\x01\x01\x11a\x03kW` \x95_\x87\x87\x81\x98\x82`@\x97\x01\x83\x86\x01^\x83\x01\x01R\x83R\x01Q\x83\x82\x01R\x81R\x01\x92\x01\x91a<\xC9V[PPPPV[\x90`\x01\x82\x01\x91\x81_R\x82` R`@_ T\x80\x15\x15_\x14a>CW_\x19\x81\x01\x81\x81\x11a\x06\x80W\x82T_\x19\x81\x01\x91\x90\x82\x11a\x06\x80W\x81\x81\x03a>\x0EW[PPP\x80T\x80\x15a=\xFAW_\x19\x01\x90a=\xDB\x82\x82a;\x10V[\x81T\x90_\x19\x90`\x03\x1B\x1B\x19\x16\x90UU_R` R_`@\x81 U`\x01\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[a>.a>\x1Ea;]\x93\x86a;\x10V[\x90T\x90`\x03\x1B\x1C\x92\x83\x92\x86a;\x10V[\x90U_R\x83` R`@_ U_\x80\x80a=\xC2V[PPPP_\x90V[\x81Q\x91\x90`A\x83\x03a>{Wa>t\x92P` \x82\x01Q\x90```@\x84\x01Q\x93\x01Q_\x1A\x90a>\xE5V[\x91\x92\x90\x91\x90V[PP_\x91`\x02\x91\x90V[`\x04\x81\x10\x15a\x06\x94W\x80a>\x97WPPV[`\x01\x81\x03a>\xAEWc\xF6E\xEE\xDF`\xE0\x1B_R`\x04_\xFD[`\x02\x81\x03a>\xC9WPc\xFC\xE6\x98\xF7`\xE0\x1B_R`\x04R`$_\xFD[`\x03\x14a>\xD3WPV[c5\xE2\xF3\x83`\xE2\x1B_R`\x04R`$_\xFD[\x91\x90\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0\x84\x11a?\\W\x91` \x93`\x80\x92`\xFF_\x95`@Q\x94\x85R\x16\x86\x84\x01R`@\x83\x01R``\x82\x01R\x82\x80R`\x01Z\xFA\x15a\x12\xFFW_Q`\x01`\x01`\xA0\x1B\x03\x81\x16\x15a?RW\x90_\x90_\x90V[P_\x90`\x01\x90_\x90V[PPP_\x91`\x03\x91\x90V\xFE\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\xA1dsolcC\0\x08\x1A\0\n",
    );
    /// The runtime bytecode of the contract, as deployed on the network.
    ///
    /// ```text
    ///0x60806040526004361015610011575f80fd5b5f3560e01c806305778550146125605780630758236f1461250a5780630c76697a146124b7578063191cbd1a1461221f5780631e8f5ee51461211057806320812956146120cd57806322f1ec931461203d5780632c957688146120215780632dae188514611ff957806331e3bd1b14611f895780633644e51514611f4f5780633ac3cbe614611f335780633e6e34a714611ea05780633fd62c6d14611e6857806340235a9c14611dd057806348f4da2014611db55780635685cf6814611d0557806356c4e17d14611cc557806359dcea1214611c885780635a936dc614611c445780635cce98a614611bbc5780636076439c14611ba157806360cf099114611b4857806361d6b86c14611b2d57806362c7e8fc14611aca57806365a6936e146116535780636bfe06a614611638578063715018a6146115d557806371e7388c146114d75780637639d2271461147b57806379ba5097146113f65780637b9f64b2146113be57806381beac2e1461137457806384ef7322146113315780638da5cb5b1461130a57806396686c1e146112715780639cbdae22146111e6578063adff830c14611060578063ae470a8514610e3c578063b074e9dd14610deb578063b99f675914610bf3578063ba1fb10314610bc9578063c1ef9ddf14610a8d578063c5d960bb14610973578063cfe347491461094b578063d413a58014610790578063d551162c1461073d578063da435a7c146106e3578063e30c3978146106bb578063e65cafcb146104cb578063ee1c039014610495578063f2fde38b14610423578063f9107f3b146103a9578063f9f167621461036f5763ffcf08f014610276575f80fd5b3461036b57604036600319011261036b5761028f61260c565b6001600160401b0361029f612638565b916102d4337f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031614612b06565b16805f5260066020526102f460405f209260018060a01b03168093613d86565b1561033557805f52600460205261030e8260405f20613d86565b507f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e5f80a3005b60405162461bcd60e51b815260206004820152600e60248201526d139bdd081c9959da5cdd195c995960921b6044820152606490fd5b5f80fd5b3461036b575f36600319011261036b5760206040517fe1675f8364c07a4d60a07503f0d700a7bcacd82251dff0f070e5235de6c6d28a8152f35b3461036b57604036600319011261036b576103c261260c565b602435801515810361036b576001600160401b036104219216805f5260076020526103fa60018060a01b0360405f2054163314612ba4565b5f52600260205260405f209060ff60481b825491151560481b169060ff60481b1916179055565b005b3461036b57602036600319011261036b5761043c61264e565b610444613719565b60018060a01b0316806bffffffffffffffffffffffff60a01b600154161760015560018060a01b035f54167f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e227005f80a3005b3461036b57604036600319011261036b5760206104c16104b361260c565b6104bb612638565b906135fd565b6040519015158152f35b3461036b57604036600319011261036b576104e461260c565b6104ec612638565b6001600160401b03821691825f52600760205260018060a01b0360405f205416331480156106a8575b61051e9061341d565b825f52600360205260405f2060018060a01b0383165f5260205260405f20906040519161054a8361272e565b8054835260ff60018201546001600160401b0381166020860152818160401c16604086015260481c16600581101561069457600260039282606087015201546080850152036105c9575b6104218385805f5260056020526105b860405f209260018060a01b03168093613d86565b505f52600460205260405f20613d86565b6105d56105ee916136a3565b60ff60206001600160401b038351169201511690612c27565b90600a820291808304600a1490151715610680575190811515918261066b575b50501561061c578280610594565b60405162461bcd60e51b815260206004820152602160248201527f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76616044820152601b60fa1b6064820152608490fd5b61067791925042612e80565b1015838061060e565b634e487b7160e01b5f52601160045260245ffd5b634e487b7160e01b5f52602160045260245ffd5b505f546001600160a01b03163314610515565b3461036b575f36600319011261036b576001546040516001600160a01b039091168152602090f35b3461036b57602036600319011261036b576001600160401b0361070461260c565b165f526002602052606060405f205460ff604051916001600160401b0381168352818160401c16602084015260481c1615156040820152f35b3461036b5760206001600160401b038161075636612ab0565b949092165f526009835260405f209060018060a01b03165f52825260405f2083604051948593843782019081520301902054604051908152f35b3461036b5760a036600319011261036b576107a961260c565b6107b1612622565b906107ba612961565b906064356001600160401b03811161036b576107da90369060040161287f565b9290916084356001600160401b03811161036b576108ed6108e76108056108f693369060040161287f565b91906001600160401b0386165f52600660205261083c61083760405f2033906001915f520160205260405f2054151590565b612da6565b60405160c087811b6001600160c01b031990811660208401908152918d901b16602883015260f889901b6001600160f81b0319166030830152908a8a603183013761089a6031828d81015f838201520301601f19810183528261279a565b51902060405160208101917f19457468657265756d205369676e6564204d6573736167653a0a3332000000008352603c820152603c81526108dc605c8261279a565b5190209236916129a3565b90613e4b565b90929192613e85565b336001600160a01b03909116036109125761042194339161372c565b60405162461bcd60e51b8152602060048201526011602482015270496e76616c6964207369676e617475726560781b6044820152606490fd5b3461036b575f36600319011261036b57600a546040516001600160a01b039091168152602090f35b3461036b57602036600319011261036b576001600160401b0361099461260c565b16805f5260066020526109bc61083760405f2033906001915f520160205260405f2054151590565b5f8181526003602090815260408083203384529091529020600101805460481c60ff16919060058310156106945760038314610a4857690400000000000000000060ff60481b19825416179055805f526004602052610a1e3360405f20613d86565b50610a2c6040518093612918565b600460208301525f80516020613f6883398151915260403393a3005b60405162461bcd60e51b815260206004820152601f60248201527f43616e6e6f7420676f206f66666c696e65207768696c6520736c6173686564006044820152606490fd5b3461036b57602036600319011261036b576001600160401b03610aae61260c565b165f52600860205260405f20805490610ac682612971565b91610ad4604051938461279a565b8083526020830180925f5260205f205f915b838310610b7c57848660405191829160208301906020845251809152604083019060408160051b85010192915f905b828210610b2457505050500390f35b919360019193955060208091603f19898203018552875190606080610b52845160808552608085019061285b565b93858101518685015260408101516040850152015115159101529601920192018594939192610b15565b60046020600192604051610b8f81612749565b610b98866127bb565b815284860154838201526002860154604082015260ff60038701541615156060820152815201920192019190610ae6565b3461036b57604036600319011261036b57610421610be561260c565b610bed612638565b9061345a565b3461036b57606036600319011261036b57610c0c61260c565b610c14612622565b6001600160401b03610c24612961565b91337f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316148015610dc9575b610c619061341d565b1690603c8210610d8f5760ff169160018310610d4a577fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea564916001600160401b036040921693845f526002602052610d3d60ff845f205460481c16845190610cc782612764565b848252610d2260ff6020840186815288850193151584528a5f5260026020526001600160401b03808a5f20965116166001600160401b03198654161785555116839060ff60401b82549160401b169060ff60401b1916179055565b51815460ff60481b191690151560481b60ff60481b16179055565b82519182526020820152a2005b60405162461bcd60e51b815260206004820152601760248201527f4d6178206d6973736564206d757374206265203e3d20310000000000000000006044820152606490fd5b60405162461bcd60e51b8152602060048201526012602482015271125b9d195c9d985b081d1bdbc81cda1bdc9d60721b6044820152606490fd5b508184165f908152600760205260409020546001600160a01b03163314610c58565b3461036b57602036600319011261036b57610421610e0761260c565b6001600160401b0381165f526006602052610e3761083760405f2033906001915f520160205260405f2054151590565b6132f8565b3461036b5760a036600319011261036b57610e5561260c565b6024356001600160401b03811161036b57610e7490369060040161287f565b90604435606435916084359485151580960361036b576001600160401b0316805f526007602052610eb260018060a01b0360405f2054163314612ba4565b610ebf6040861115612ca4565b610ecb83851015612ce0565b805f526008602052610ee3603260405f205410612be4565b5f526008602052610f0660405f209160405195610eff87612749565b36916129a3565b84526020840191825260408401928352606084019485528054600160401b81101561103957610f3a916001820181556126c9565b93909361104d57518051906001600160401b03821161103957610f6782610f6187546126f6565b87612d1d565b602090601f8311600114610fcf578260039593610421989593610f9f935f92610fc4575b50508160011b915f199060031b1c19161790565b85555b51600185015551600284015551151591019060ff801983541691151516179055565b015190508980610f8b565b90601f19831691865f52815f20925f5b8181106110215750926001928592600398966104219b98961061100a575b505050811b018555610fa2565b01515f1983891b60f8161c19169055888080610ffd565b92936020600181928786015181550195019301610fdf565b634e487b7160e01b5f52604160045260245ffd5b634e487b7160e01b5f525f60045260245ffd5b3461036b5761106e36612ab0565b90919260018060a01b03600a541633036111ab576001600160401b031691825f5260056020526110b960405f209460018060a01b031680956001915f520160205260405f2054151590565b15611173577f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c79191835f52600360205260405f20855f52602052600160405f2001690300000000000000000060ff60481b19825416179055835f5260046020526111258560405f20613d86565b50835f52600c60205260405f20855f5260205260405f206001600160401b03804216166001600160401b031982541617905561116e6040519283926020845260208401916132d8565b0390a3005b60405162461bcd60e51b815260206004820152601060248201526f27b832b930ba37b9103ab735b737bbb760811b6044820152606490fd5b60405162461bcd60e51b81526020600482015260136024820152724e6f7420736c617368696e67206f7261636c6560681b6044820152606490fd5b3461036b57606036600319011261036b576111ff61260c565b611207612638565b6044356001600160401b03811161036b5760209283926001600160401b03611234859436906004016129d9565b92165f526009835260405f209060018060a01b03165f52825260405f20604051938285935191829101845e82019081520301902054604051908152f35b3461036b5761127f36612664565b906001600160401b035f9316925b8281101561042157600581901b8201356001600160a01b038116919082900361036b57303b1561036b576040519163ba1fb10360e01b835285600484015260248301525f8260448183305af19182156112ff576001926112ef575b500161128d565b5f6112f99161279a565b856112e8565b6040513d5f823e3d90fd5b3461036b575f36600319011261036b575f546040516001600160a01b039091168152602090f35b3461036b57602036600319011261036b5761134a61264e565b611352613719565b600a80546001600160a01b0319166001600160a01b0392909216919091179055005b3461036b57606036600319011261036b576113b46113a061139361260c565b604435906024359061309e565b604051928392604084526040840190612925565b9060208301520390f35b3461036b57602036600319011261036b576001600160401b036113df61260c565b165f526004602052602060405f2054604051908152f35b3461036b575f36600319011261036b57600154336001600160a01b039091160361146857600180546001600160a01b03199081169091555f805433928116831782556001600160a01b0316907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09080a3005b63118cdaa760e01b5f523360045260245ffd5b3461036b57604036600319011261036b5761149461260c565b6001600160401b036114a4612638565b91165f52600c60205260405f209060018060a01b03165f5260205260206001600160401b0360405f205416604051908152f35b3461036b57604036600319011261036b576114f061260c565b6001600160401b03611500612638565b915f60806040516115108161272e565b8281528260208201528260408201528260608201520152165f52600360205260405f209060018060a01b03165f5260205260405f206040516115518161272e565b8154815260018201549160208201906001600160401b038416825260ff6040840194818160401c16865260481c16606084019060058110156106945760a0956001600160401b0360026115cd9560ff94865201549560808801968752604051975188525116602087015251166040850152516060840190612918565b516080820152f35b3461036b575f36600319011261036b576115ed613719565b600180546001600160a01b03199081169091555f80549182168155906001600160a01b03167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e08280a3005b3461036b575f36600319011261036b57602060405160408152f35b3461036b57608036600319011261036b5761166c61260c565b611674612638565b6044356001600160401b03811161036b576116939036906004016129f7565b60643592303303611a95576001600160401b031691825f52600860205260405f20936116be81612d60565b925f5b828110611a6e575085548015158091606092611a25575b505f5b8481106118175750505050505f928454945b8585106116f657005b60ff600361170487846126c9565b500154161561180d5761172a61173161171d87846126c9565b5060405192838092612df2565b038261279a565b602081519101205f945f5b81518110156117ff57826117508284612d92565b511461175e5760010161173c565b509450509493600190815b15611777575b0193946116ed565b61178181886126c9565b50837fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63156117b960405193604085526040850190612df2565b927f5265717569726564206d6574726963206d697373696e6700000000000000000060208286039586828501526017815201526040868060a01b038916940190a361176f565b509460019297969150611769565b949360019061176f565b60015f836118ef575b5090600191611830575b016116db565b602061183c8287612d92565b510151895f52600960205260405f20838060a01b0389165f5260205260208060405f20611869858a612d92565b515190604051938285935191829101845e8201908152030190205561188e8186612d92565b5151897f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd60206118be858a612d92565b510151926118d76040519160408352604083019061285b565b93602082015280868060a01b038c16940390a361182a565b8a545f5b818110611916575b505090600192911561190f575b9091611820565b505f611908565b611920858c612d92565b5161192b8289612d92565b5114611939576001016118f3565b6001949392508491508c602061194f868b612d92565b5101518361195d84846126c9565b500154119182156119fc575b5050611979575b9091928c6118fb565b90506119858287612d92565b51518a7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63156119be6040519360408552604085019061285b565b927256616c7565206f7574206f6620626f756e647360681b60208286039586828501526013815201526040878060a01b038d16940190a35f90611970565b6002919250611a1a906020611a11888d612d92565b510151936126c9565b500154108c8e611969565b9150611a3082612d60565b91885f5b828110611a425750506116d8565b61172a611a5461171d836001956126c9565b60208151910120611a658287612d92565b52018990611a34565b80611a7b60019284612d92565b515160208151910120611a8e8288612d92565b52016116c1565b60405162461bcd60e51b815260206004820152600d60248201526c496e7465726e616c206f6e6c7960981b6044820152606490fd5b3461036b57604036600319011261036b57611ae361260c565b6001600160401b03611af3612638565b91165f52600360205260405f209060018060a01b03165f52602052602060ff600160405f20015460481c16611b2b6040518092612918565bf35b3461036b575f36600319011261036b57602060405160038152f35b3461036b57604036600319011261036b5760206104c1611b6661260c565b6001600160401b03611b76612638565b91165f9081526006845260408082206001600160a01b03909316825260019092016020522054151590565b3461036b575f36600319011261036b57602060405160328152f35b3461036b57608036600319011261036b57611bd561260c565b611bdd612622565b90611be6612961565b91606435926001600160401b03841161036b57611c0a61042194369060040161287f565b9390926001600160401b0382165f526006602052611c3d61083760405f2033906001915f520160205260405f2054151590565b339161372c565b3461036b575f36600319011261036b576040517f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03168152602090f35b3461036b57602036600319011261036b57611cc1611cac611ca761260c565b612e8d565b50604051918291602083526020830190612925565b0390f35b3461036b57602036600319011261036b576001600160401b03611ce661260c565b165f526007602052602060018060a01b0360405f205416604051908152f35b3461036b57604036600319011261036b57611d1e61260c565b6001600160401b03611d2e612638565b9116805f52600360205260405f2060018060a01b0383165f5260205260ff600160405f20015460481c1660058110156106945715908115611d77575b6020826040519015158152f35b90505f52600360205260405f209060018060a01b03165f5260205260ff600160405f20015460481c1660058110156106945760016020911482611d6a565b3461036b575f36600319011261036b57602060405160c88152f35b3461036b57602036600319011261036b576001600160401b03611df161260c565b16805f52600460205260405f2054611e0881612d60565b915f5b828110611e285760405160208082528190611cc190820187612925565b600190825f526004602052611e408160405f20613b10565b838060a01b0391549060031b1c16611e588287612d92565b90838060a01b0316905201611e0b565b3461036b57602036600319011261036b576001600160401b03611e8961260c565b165f526005602052602060405f2054604051908152f35b3461036b57604036600319011261036b57611eb961260c565b6001600160401b03611ec9612638565b91165f52600360205260405f209060018060a01b03165f5260205260a060405f20805490611f2c60026001830154920154916040519384526001600160401b038116602085015260ff8160401c16604085015260ff606085019160481c16612918565b6080820152f35b3461036b575f36600319011261036b576020604051610e108152f35b3461036b575f36600319011261036b5760206040517f00000000000000000000000000000000000000000000000000000000000000008152f35b3461036b57602036600319011261036b576004356001600160401b03811161036b57611fb990369060040161287f565b81019060208183031261036b578035916001600160401b03831161036b57611cc192611fe592016129f7565b6040519182916020835260208301906128ac565b3461036b575f36600319011261036b57600b546040516001600160a01b039091168152602090f35b3461036b575f36600319011261036b57602060405161012c8152f35b3461036b57604036600319011261036b5761205661260c565b6001600160401b0360243591165f52600860205260405f20805482101561036b576120b791612084916126c9565b5061208e816127bb565b9060018101549060ff60036002830154920154169060405194859460808652608086019061285b565b9260208501526040840152151560608301520390f35b3461036b57602036600319011261036b576120e661264e565b6120ee613719565b600b80546001600160a01b0319166001600160a01b0392909216919091179055005b3461036b57604036600319011261036b5761212961260c565b612131612638565b612165337f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031614612b06565b6001600160a01b03169081156121eb576001600160401b0316805f52600660205261219b6121968360405f20613b25565b612b45565b805f52600360205260405f20825f52602052600160405f2001600160491b60ff60481b198254161790557f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b5f80a3005b60405162461bcd60e51b815260206004820152600c60248201526b5a65726f206164647265737360a01b6044820152606490fd5b3461036b576001600160401b0361223536612664565b919290921690815f52600760205261225a60018060a01b0360405f2054163314612ba4565b6122676032821115612be4565b815f52600860205260405f208054905f815581612421575b50505f5b81811061228c57005b6122ae60406122a561229f848689612c50565b80612c72565b90501115612ca4565b6122d660406122be838588612c50565b013560206122cd848689612c50565b01351115612ce0565b825f52600860205260405f20906122ee818487612c50565b918054600160401b8110156110395761230c916001820181556126c9565b92909261104d5761231d8180612c72565b906001600160401b0382116110395761233a82610f6187546126f6565b5f90601f83116001146123ba57918061236b92606095945f926123af5750508160011b915f199060031b1c19161790565b84555b6020810135600185015560408101356002850155013591821515830361036b5760019260036123a992019060ff801983541691151516179055565b01612283565b013590508a80610f8b565b601f19831691865f5260205f20925f5b81811061240957509160019391856060979694106123f0575b505050811b01845561236e565b01355f19600384901b60f8161c191690558980806123e3565b919360206001819287870135815501950192016123ca565b6001600160fe1b0382168203610680575f5260205f209060021b8101905b8181101561227f5780612454600492546126f6565b80612473575b505f60018201555f60028201555f60038201550161243f565b601f811160011461248957505f81555b8661245a565b6124a690825f526001601f60205f20920160051c82019101612c3a565b805f525f6020812081835555612483565b3461036b57604036600319011261036b576124d061260c565b6001600160401b036124e0612638565b91165f52600360205260405f209060018060a01b03165f52602052602060405f2054604051908152f35b3461036b57602036600319011261036b57606061253661252861260c565b612530612b86565b506136a3565b60408051916001600160401b03815116835260ff6020820151166020840152015115156040820152f35b3461036b57604036600319011261036b5761257961260c565b6001600160401b03612589612638565b916125be337f00000000000000000000000000000000000000000000000000000000000000006001600160a01b031614612b06565b165f818152600760205260409020546125e0906001600160a01b031615612b45565b5f90815260076020526040902080546001600160a01b0319166001600160a01b03909216919091179055005b600435906001600160401b038216820361036b57565b602435906001600160401b038216820361036b57565b602435906001600160a01b038216820361036b57565b600435906001600160a01b038216820361036b57565b604060031982011261036b576004356001600160401b038116810361036b57916024356001600160401b03811161036b5760040182601f8201121561036b578035926001600160401b03841161036b576020808301928560051b01011161036b579190565b80548210156126e2575f5260205f209060021b01905f90565b634e487b7160e01b5f52603260045260245ffd5b90600182811c92168015612724575b602083101461271057565b634e487b7160e01b5f52602260045260245ffd5b91607f1691612705565b60a081019081106001600160401b0382111761103957604052565b608081019081106001600160401b0382111761103957604052565b606081019081106001600160401b0382111761103957604052565b604081019081106001600160401b0382111761103957604052565b90601f801991011681019081106001600160401b0382111761103957604052565b9060405191825f8254926127ce846126f6565b808452936001811690811561283957506001146127f5575b506127f39250038361279a565b565b90505f9291925260205f20905f915b81831061281d5750509060206127f3928201015f6127e6565b6020919350806001915483858901015201910190918492612804565b9050602092506127f394915060ff191682840152151560051b8201015f6127e6565b805180835260209291819084018484015e5f828201840152601f01601f1916010190565b9181601f8401121561036b578235916001600160401b03831161036b576020838186019501011161036b57565b9080602083519182815201916020808360051b8301019401925f915b8383106128d757505050505090565b9091929394602080600192601f198582030186528851908280612903845160408552604085019061285b565b930151910152970193019301919392906128c8565b9060058210156106945752565b90602080835192838152019201905f5b8181106129425750505090565b82516001600160a01b0316845260209384019390920191600101612935565b6044359060ff8216820361036b57565b6001600160401b0381116110395760051b60200190565b6001600160401b03811161103957601f01601f191660200190565b9291926129af82612988565b916129bd604051938461279a565b82948184528183011161036b578281602093845f960137010152565b9080601f8301121561036b578160206129f4933591016129a3565b90565b81601f8201121561036b57803590612a0e82612971565b92612a1c604051948561279a565b82845260208085019360051b8301019181831161036b5760208101935b838510612a4857505050505090565b84356001600160401b03811161036b5782016040818503601f19011261036b5760405191612a758361277f565b6020820135926001600160401b03841161036b57604083612a9d8860208098819801016129d9565b8352013583820152815201940193612a39565b606060031982011261036b576004356001600160401b038116810361036b57916024356001600160a01b038116810361036b5791604435906001600160401b03821161036b57612b029160040161287f565b9091565b15612b0d57565b60405162461bcd60e51b815260206004820152601060248201526f4f6e6c792054616e676c6520636f726560801b6044820152606490fd5b15612b4c57565b60405162461bcd60e51b8152602060048201526012602482015271105b1c9958591e481c9959da5cdd195c995960721b6044820152606490fd5b60405190612b9382612764565b5f6040838281528260208201520152565b15612bab57565b60405162461bcd60e51b81526020600482015260116024820152702737ba1039b2b93b34b1b29037bbb732b960791b6044820152606490fd5b15612beb57565b60405162461bcd60e51b8152602060048201526014602482015273546f6f206d616e7920646566696e6974696f6e7360601b6044820152606490fd5b8181029291811591840414171561068057565b818110612c45575050565b5f8155600101612c3a565b91908110156126e25760051b81013590607e198136030182121561036b570190565b903590601e198136030182121561036b57018035906001600160401b03821161036b5760200191813603831361036b57565b15612cab57565b60405162461bcd60e51b815260206004820152600d60248201526c4e616d6520746f6f206c6f6e6760981b6044820152606490fd5b15612ce757565b60405162461bcd60e51b815260206004820152600e60248201526d496e76616c696420626f756e647360901b6044820152606490fd5b9190601f8111612d2c57505050565b6127f3925f5260205f20906020601f840160051c83019310612d56575b601f0160051c0190612c3a565b9091508190612d49565b90612d6a82612971565b612d77604051918261279a565b8281528092612d88601f1991612971565b0190602036910137565b80518210156126e25760209160051b010190565b15612dad57565b60405162461bcd60e51b815260206004820152601760248201527f4e6f742072656769737465726564206f70657261746f720000000000000000006044820152606490fd5b5f9291815491612e01836126f6565b8083529260018116908115612e565750600114612e1d57505050565b5f9081526020812093945091925b838310612e3c575060209250010190565b600181602092949394548385870101520191019190612e2b565b915050602093945060ff929192191683830152151560051b010190565b9190820180921161068057565b9190820391821161068057565b6001600160401b03612e9e826136a3565b911691825f52600560205260405f205491602081019060ff825116158015613096575b801561308e575b613070579060ff6001600160401b03612ee693511691511690612c27565b60c883101561306957825b612efa81612d60565b945f925f5b838110612f4a5750505050612f1381612d60565b935f5b828110612f2257505050565b6001906001600160a01b03612f378285612d92565b5116612f438289612d92565b5201612f16565b825f526005602052612f5f8160405f20613b10565b90545f85815260066020908152604080832060039590951b9390931c6001600160a01b0316808352600194909401905220541561306057835f52600360205260405f20815f5260205260405f20604051612fb88161272e565b8154815260ff60018301546001600160401b0381166020840152818160401c16604084015260481c166005811015610694576002869382606085015201546080830152815115908115613055575b5061304a57613016905142612e80565b1015613028575b506001905b01612eff565b613035868a979397612d92565b525f198114610680576001809101949061301d565b505050600190613022565b60039150145f613006565b50600190613022565b60c8612ef1565b505090915060405161308360208261279a565b5f81525f3681379190565b508315612ec8565b508315612ec1565b9192906001600160401b036130b2846136a3565b9316805f52600560205260405f205493602081019060ff8251161580156132d0575b80156132c6575b6132b1579060ff6001600160401b036130f993511691511690612c27565b9460c88111156132ac575060c85b846131128285612e73565b111561329c575083905b61312e6131298484612e80565b612d60565b955f935b83811061317d575050505061314681612d60565b935f5b82811061315557505050565b6001906001600160a01b0361316a8285612d92565b51166131768289612d92565b5201613149565b825f5260056020526131928160405f20613b10565b90545f85815260066020908152604080832060039590951b9390931c6001600160a01b0316808352600194909401905220541561329357835f52600360205260405f20815f5260205260405f206040516131eb8161272e565b8154815260ff60018301546001600160401b0381166020840152818160401c16604084015260481c166005811015610694576002869382606085015201546080830152815115908115613288575b5061327d57613249905142612e80565b101561325b575b506001905b01613132565b613268868a979397612d92565b525f1981146106805760018091019490613250565b505050600190613255565b60039150145f613239565b50600190613255565b6132a69083612e73565b9061311c565b613107565b5050505090915060405161308360208261279a565b50858410156130db565b5085156130d4565b908060209392818452848401375f828201840152601f01601f1916010190565b6001600160401b03165f8181526003602090815260408083203384529091529020600101805460481c60ff169190600583101561069457600383146133d857821580156133ce575b6133c957805469ffff0000000000000000191669010000000000000000001790555f818152600460205260409020613379903390613b25565b506133ad604051809333847fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c5f80a3612918565b600160208301525f80516020613f6883398151915260403393a3565b505050565b5060018314613340565b60405162461bcd60e51b815260206004820152601e60248201527f43616e6e6f7420676f206f6e6c696e65207768696c6520736c617368656400006044820152606490fd5b1561342457565b60405162461bcd60e51b815260206004820152600e60248201526d139bdd08185d5d1a1bdc9a5e995960921b6044820152606490fd5b906001600160401b03821690815f52600360205260405f2060018060a01b0382165f5260205261348d60405f20936136a3565b92600181019384549160ff8360481c166005811015610694576003146134ef575480156134ef576134be9042612e80565b6001600160401b038251169081156135e9570460ff8111156135e1575060ff5b60ff8082169360401c1683116134f7575b505050505050565b855460409190911b60ff60401b1668ffffffffffffffffff199091161785556020015160ff16811015806135c6575b613532575b80806134ef565b835f80516020613f6883398151915292847f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d602060409560ff6135a29a5460481c1695600160491b60ff60481b19825416179055835f5260048252865f209460018060a01b0316998a8096613d86565b508651908152a36135b582518092612918565b60026020820152a35f80808061352b565b5060ff845460481c1660058110156106945760021415613526565b60ff166134de565b634e487b7160e01b5f52601260045260245ffd5b906001600160401b0361360f836136a3565b92165f52600360205260405f209060018060a01b03165f5260205260405f206040519061363b8261272e565b8054825260ff60018201546001600160401b0381166020850152818160401c16604085015260481c169060058210156106945760029160608401520154608082015251801561369d576136966001600160401b039142612e80565b9151161190565b50505f90565b6001600160401b03906136b4612b86565b50165f52600260205260405f20604051906136ce82612764565b546001600160401b03811680835260ff8260401c169060ff602085019383855260481c16151560408501521561370f575b15613708575090565b6003905290565b61012c83526136ff565b5f546001600160a01b0316330361146857565b909293916001600160401b03821695865f52600360205260405f2060018060a01b0383165f5260205260405f2094613763846136a3565b90600187019460ff865460481c16600581101561069457600314613ad5575f8a81526005602052604090206001600160a01b03861699906137a5908b90613b25565b5060ff875460481c169842815560026137bf36888c6129a3565b6020815191012091015560ff60401b1987541687556001600160401b03875416906001600160401b038214610680576001600160401b03600160ff9301166001600160401b0319895416178855169384155f146139c3575f975b6005891015978861069457805460ff60481b191660488b901b60ff60481b1617905560058a1015610694578a968c9560028c148b816139b4575b509260409592866001600160401b0396937f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b99996613974575b015115158061396b575b613959575b5050505082519586524260208701521693a46106945782918491808203613924575b5050600b546001600160a01b03169391508390506138da57505050565b823b1561036b5760645f92836040519586948593636a3c29db60e11b8552600485015260248401526001600160401b03421660448401525af161391a5750565b5f6127f39161279a565b5f80516020613f688339815191529161394f60409261394584518094612918565b6020830190612918565ba380825f806138bd565b61396293613b88565b5f80808061389b565b50821515613896565b8a5f5260046020526139888d835f20613b25565b508c8b7fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c5f80a361388c565b5f9b506002141590508b613853565b60648510156139d457600197613819565b60019760c88610613819576001600160401b0342168c5f52600c60205260405f208c5f526020526001600160401b0360405f2054168015908115613aae575b50613a1f575b50613819565b8c5f52600c60205260405f208c5f526020526001600160401b0360405f2091166001600160401b03198254161790558a8c7f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c791606060405160208152601b60208201527f50726f746f636f6c2076696f6c6174696f6e207265706f7274656400000000006040820152a35f613a19565b905081036001600160401b038111610680576001600160401b03610e10911610155f613a13565b60405162461bcd60e51b815260206004820152601360248201527213dc195c985d1bdc881a5cc81cdb185cda1959606a1b6044820152606490fd5b80548210156126e2575f5260205f2001905f90565b5f82815260018201602052604090205461369d57805490600160401b8210156110395782613b73613b5d846001809601855584613b10565b819391549060031b91821b915f19901b19161790565b90558054925f520160205260405f2055600190565b9190928015613d805761c3508111613d80576040516331e3bd1b60e01b815260206004820152915f9183918291613bc4916024840191906132d8565b0381305afa5f9181613c55575b50613bdb57505050565b80516032811115613c4f57506032915b303b1561036b576040516332d349b760e11b81526001600160401b039190911660048201526001600160a01b039093166024840152608060448401525f918391829190613c3c9060848401906128ac565b906064830152038183305af161391a5750565b91613beb565b9091503d805f833e613c67818361279a565b81019060208183031261036b578051906001600160401b03821161036b57019080601f8301121561036b57815191613c9e83612971565b92613cac604051948561279a565b80845260208085019160051b8301019183831161036b5760208101915b838310613cdc575050505050905f613bd1565b82516001600160401b03811161036b578201906040828703601f19011261036b5760405190613d0a8261277f565b60208301516001600160401b03811161036b576020908401019187601f8401121561036b57825192613d3b84612988565b94613d49604051968761279a565b848652896020868401011161036b576020955f8787819882604097018386015e830101528352015183820152815201920191613cc9565b50505050565b906001820191815f528260205260405f20548015155f14613e43575f1981018181116106805782545f1981019190821161068057818103613e0e575b50505080548015613dfa575f190190613ddb8282613b10565b8154905f199060031b1b19169055555f526020525f6040812055600190565b634e487b7160e01b5f52603160045260245ffd5b613e2e613e1e613b5d9386613b10565b90549060031b1c92839286613b10565b90555f528360205260405f20555f8080613dc2565b505050505f90565b8151919060418303613e7b57613e749250602082015190606060408401519301515f1a90613ee5565b9192909190565b50505f9160029190565b60048110156106945780613e97575050565b60018103613eae5763f645eedf60e01b5f5260045ffd5b60028103613ec9575063fce698f760e01b5f5260045260245ffd5b600314613ed35750565b6335e2f38360e21b5f5260045260245ffd5b91907f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a08411613f5c579160209360809260ff5f9560405194855216868401526040830152606082015282805260015afa156112ff575f516001600160a01b03811615613f5257905f905f90565b505f906001905f90565b5050505f916003919056fe228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a09a164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static DEPLOYED_BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\x80`@R`\x046\x10\x15a\0\x11W_\x80\xFD[_5`\xE0\x1C\x80c\x05w\x85P\x14a%`W\x80c\x07X#o\x14a%\nW\x80c\x0Cviz\x14a$\xB7W\x80c\x19\x1C\xBD\x1A\x14a\"\x1FW\x80c\x1E\x8F^\xE5\x14a!\x10W\x80c \x81)V\x14a \xCDW\x80c\"\xF1\xEC\x93\x14a =W\x80c,\x95v\x88\x14a !W\x80c-\xAE\x18\x85\x14a\x1F\xF9W\x80c1\xE3\xBD\x1B\x14a\x1F\x89W\x80c6D\xE5\x15\x14a\x1FOW\x80c:\xC3\xCB\xE6\x14a\x1F3W\x80c>n4\xA7\x14a\x1E\xA0W\x80c?\xD6,m\x14a\x1EhW\x80c@#Z\x9C\x14a\x1D\xD0W\x80cH\xF4\xDA \x14a\x1D\xB5W\x80cV\x85\xCFh\x14a\x1D\x05W\x80cV\xC4\xE1}\x14a\x1C\xC5W\x80cY\xDC\xEA\x12\x14a\x1C\x88W\x80cZ\x93m\xC6\x14a\x1CDW\x80c\\\xCE\x98\xA6\x14a\x1B\xBCW\x80c`vC\x9C\x14a\x1B\xA1W\x80c`\xCF\t\x91\x14a\x1BHW\x80ca\xD6\xB8l\x14a\x1B-W\x80cb\xC7\xE8\xFC\x14a\x1A\xCAW\x80ce\xA6\x93n\x14a\x16SW\x80ck\xFE\x06\xA6\x14a\x168W\x80cqP\x18\xA6\x14a\x15\xD5W\x80cq\xE78\x8C\x14a\x14\xD7W\x80cv9\xD2'\x14a\x14{W\x80cy\xBAP\x97\x14a\x13\xF6W\x80c{\x9Fd\xB2\x14a\x13\xBEW\x80c\x81\xBE\xAC.\x14a\x13tW\x80c\x84\xEFs\"\x14a\x131W\x80c\x8D\xA5\xCB[\x14a\x13\nW\x80c\x96hl\x1E\x14a\x12qW\x80c\x9C\xBD\xAE\"\x14a\x11\xE6W\x80c\xAD\xFF\x83\x0C\x14a\x10`W\x80c\xAEG\n\x85\x14a\x0E<W\x80c\xB0t\xE9\xDD\x14a\r\xEBW\x80c\xB9\x9FgY\x14a\x0B\xF3W\x80c\xBA\x1F\xB1\x03\x14a\x0B\xC9W\x80c\xC1\xEF\x9D\xDF\x14a\n\x8DW\x80c\xC5\xD9`\xBB\x14a\tsW\x80c\xCF\xE3GI\x14a\tKW\x80c\xD4\x13\xA5\x80\x14a\x07\x90W\x80c\xD5Q\x16,\x14a\x07=W\x80c\xDACZ|\x14a\x06\xE3W\x80c\xE3\x0C9x\x14a\x06\xBBW\x80c\xE6\\\xAF\xCB\x14a\x04\xCBW\x80c\xEE\x1C\x03\x90\x14a\x04\x95W\x80c\xF2\xFD\xE3\x8B\x14a\x04#W\x80c\xF9\x10\x7F;\x14a\x03\xA9W\x80c\xF9\xF1gb\x14a\x03oWc\xFF\xCF\x08\xF0\x14a\x02vW_\x80\xFD[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x02\x8Fa&\x0CV[`\x01`\x01`@\x1B\x03a\x02\x9Fa&8V[\x91a\x02\xD43\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x14a+\x06V[\x16\x80_R`\x06` Ra\x02\xF4`@_ \x92`\x01\x80`\xA0\x1B\x03\x16\x80\x93a=\x86V[\x15a\x035W\x80_R`\x04` Ra\x03\x0E\x82`@_ a=\x86V[P\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E_\x80\xA3\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x0E`$\x82\x01Rm\x13\x9B\xDD\x08\x1C\x99Y\xDA\\\xDD\x19\\\x99Y`\x92\x1B`D\x82\x01R`d\x90\xFD[_\x80\xFD[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q\x7F\xE1g_\x83d\xC0zM`\xA0u\x03\xF0\xD7\0\xA7\xBC\xAC\xD8\"Q\xDF\xF0\xF0p\xE5#]\xE6\xC6\xD2\x8A\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x03\xC2a&\x0CV[`$5\x80\x15\x15\x81\x03a\x03kW`\x01`\x01`@\x1B\x03a\x04!\x92\x16\x80_R`\x07` Ra\x03\xFA`\x01\x80`\xA0\x1B\x03`@_ T\x163\x14a+\xA4V[_R`\x02` R`@_ \x90`\xFF`H\x1B\x82T\x91\x15\x15`H\x1B\x16\x90`\xFF`H\x1B\x19\x16\x17\x90UV[\0[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa\x04<a&NV[a\x04Da7\x19V[`\x01\x80`\xA0\x1B\x03\x16\x80k\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF`\xA0\x1B`\x01T\x16\x17`\x01U`\x01\x80`\xA0\x1B\x03_T\x16\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0_\x80\xA3\0[4a\x03kW`@6`\x03\x19\x01\x12a\x03kW` a\x04\xC1a\x04\xB3a&\x0CV[a\x04\xBBa&8V[\x90a5\xFDV[`@Q\x90\x15\x15\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x04\xE4a&\x0CV[a\x04\xECa&8V[`\x01`\x01`@\x1B\x03\x82\x16\x91\x82_R`\x07` R`\x01\x80`\xA0\x1B\x03`@_ T\x163\x14\x80\x15a\x06\xA8W[a\x05\x1E\x90a4\x1DV[\x82_R`\x03` R`@_ `\x01\x80`\xA0\x1B\x03\x83\x16_R` R`@_ \x90`@Q\x91a\x05J\x83a'.V[\x80T\x83R`\xFF`\x01\x82\x01T`\x01`\x01`@\x1B\x03\x81\x16` \x86\x01R\x81\x81`@\x1C\x16`@\x86\x01R`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x02`\x03\x92\x82``\x87\x01R\x01T`\x80\x85\x01R\x03a\x05\xC9W[a\x04!\x83\x85\x80_R`\x05` Ra\x05\xB8`@_ \x92`\x01\x80`\xA0\x1B\x03\x16\x80\x93a=\x86V[P_R`\x04` R`@_ a=\x86V[a\x05\xD5a\x05\xEE\x91a6\xA3V[`\xFF` `\x01`\x01`@\x1B\x03\x83Q\x16\x92\x01Q\x16\x90a,'V[\x90`\n\x82\x02\x91\x80\x83\x04`\n\x14\x90\x15\x17\x15a\x06\x80WQ\x90\x81\x15\x15\x91\x82a\x06kW[PP\x15a\x06\x1CW\x82\x80a\x05\x94V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`!`$\x82\x01R\x7FOperator not eligible for remova`D\x82\x01R`\x1B`\xFA\x1B`d\x82\x01R`\x84\x90\xFD[a\x06w\x91\x92PBa.\x80V[\x10\x15\x83\x80a\x06\x0EV[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[P_T`\x01`\x01`\xA0\x1B\x03\x163\x14a\x05\x15V[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`\x01T`@Q`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x81R` \x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x07\x04a&\x0CV[\x16_R`\x02` R```@_ T`\xFF`@Q\x91`\x01`\x01`@\x1B\x03\x81\x16\x83R\x81\x81`@\x1C\x16` \x84\x01R`H\x1C\x16\x15\x15`@\x82\x01R\xF3[4a\x03kW` `\x01`\x01`@\x1B\x03\x81a\x07V6a*\xB0V[\x94\x90\x92\x16_R`\t\x83R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R\x82R`@_ \x83`@Q\x94\x85\x93\x847\x82\x01\x90\x81R\x03\x01\x90 T`@Q\x90\x81R\xF3[4a\x03kW`\xA06`\x03\x19\x01\x12a\x03kWa\x07\xA9a&\x0CV[a\x07\xB1a&\"V[\x90a\x07\xBAa)aV[\x90`d5`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x07\xDA\x906\x90`\x04\x01a(\x7FV[\x92\x90\x91`\x845`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x08\xEDa\x08\xE7a\x08\x05a\x08\xF6\x936\x90`\x04\x01a(\x7FV[\x91\x90`\x01`\x01`@\x1B\x03\x86\x16_R`\x06` Ra\x08<a\x087`@_ 3\x90`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[a-\xA6V[`@Q`\xC0\x87\x81\x1B`\x01`\x01`\xC0\x1B\x03\x19\x90\x81\x16` \x84\x01\x90\x81R\x91\x8D\x90\x1B\x16`(\x83\x01R`\xF8\x89\x90\x1B`\x01`\x01`\xF8\x1B\x03\x19\x16`0\x83\x01R\x90\x8A\x8A`1\x83\x017a\x08\x9A`1\x82\x8D\x81\x01_\x83\x82\x01R\x03\x01`\x1F\x19\x81\x01\x83R\x82a'\x9AV[Q\x90 `@Q` \x81\x01\x91\x7F\x19Ethereum Signed Message:\n32\0\0\0\0\x83R`<\x82\x01R`<\x81Ra\x08\xDC`\\\x82a'\x9AV[Q\x90 \x926\x91a)\xA3V[\x90a>KV[\x90\x92\x91\x92a>\x85V[3`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x03a\t\x12Wa\x04!\x943\x91a7,V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x11`$\x82\x01RpInvalid signature`x\x1B`D\x82\x01R`d\x90\xFD[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`\nT`@Q`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x81R` \x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\t\x94a&\x0CV[\x16\x80_R`\x06` Ra\t\xBCa\x087`@_ 3\x90`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[_\x81\x81R`\x03` \x90\x81R`@\x80\x83 3\x84R\x90\x91R\x90 `\x01\x01\x80T`H\x1C`\xFF\x16\x91\x90`\x05\x83\x10\x15a\x06\x94W`\x03\x83\x14a\nHWi\x04\0\0\0\0\0\0\0\0\0`\xFF`H\x1B\x19\x82T\x16\x17\x90U\x80_R`\x04` Ra\n\x1E3`@_ a=\x86V[Pa\n,`@Q\x80\x93a)\x18V[`\x04` \x83\x01R_\x80Q` a?h\x839\x81Q\x91R`@3\x93\xA3\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x1F`$\x82\x01R\x7FCannot go offline while slashed\0`D\x82\x01R`d\x90\xFD[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\n\xAEa&\x0CV[\x16_R`\x08` R`@_ \x80T\x90a\n\xC6\x82a)qV[\x91a\n\xD4`@Q\x93\x84a'\x9AV[\x80\x83R` \x83\x01\x80\x92_R` _ _\x91[\x83\x83\x10a\x0B|W\x84\x86`@Q\x91\x82\x91` \x83\x01\x90` \x84RQ\x80\x91R`@\x83\x01\x90`@\x81`\x05\x1B\x85\x01\x01\x92\x91_\x90[\x82\x82\x10a\x0B$WPPPP\x03\x90\xF3[\x91\x93`\x01\x91\x93\x95P` \x80\x91`?\x19\x89\x82\x03\x01\x85R\x87Q\x90``\x80a\x0BR\x84Q`\x80\x85R`\x80\x85\x01\x90a([V[\x93\x85\x81\x01Q\x86\x85\x01R`@\x81\x01Q`@\x85\x01R\x01Q\x15\x15\x91\x01R\x96\x01\x92\x01\x92\x01\x85\x94\x93\x91\x92a\x0B\x15V[`\x04` `\x01\x92`@Qa\x0B\x8F\x81a'IV[a\x0B\x98\x86a'\xBBV[\x81R\x84\x86\x01T\x83\x82\x01R`\x02\x86\x01T`@\x82\x01R`\xFF`\x03\x87\x01T\x16\x15\x15``\x82\x01R\x81R\x01\x92\x01\x92\x01\x91\x90a\n\xE6V[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x04!a\x0B\xE5a&\x0CV[a\x0B\xEDa&8V[\x90a4ZV[4a\x03kW``6`\x03\x19\x01\x12a\x03kWa\x0C\x0Ca&\x0CV[a\x0C\x14a&\"V[`\x01`\x01`@\x1B\x03a\x0C$a)aV[\x913\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x14\x80\x15a\r\xC9W[a\x0Ca\x90a4\x1DV[\x16\x90`<\x82\x10a\r\x8FW`\xFF\x16\x91`\x01\x83\x10a\rJW\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x91`\x01`\x01`@\x1B\x03`@\x92\x16\x93\x84_R`\x02` Ra\r=`\xFF\x84_ T`H\x1C\x16\x84Q\x90a\x0C\xC7\x82a'dV[\x84\x82Ra\r\"`\xFF` \x84\x01\x86\x81R\x88\x85\x01\x93\x15\x15\x84R\x8A_R`\x02` R`\x01`\x01`@\x1B\x03\x80\x8A_ \x96Q\x16\x16`\x01`\x01`@\x1B\x03\x19\x86T\x16\x17\x85UQ\x16\x83\x90`\xFF`@\x1B\x82T\x91`@\x1B\x16\x90`\xFF`@\x1B\x19\x16\x17\x90UV[Q\x81T`\xFF`H\x1B\x19\x16\x90\x15\x15`H\x1B`\xFF`H\x1B\x16\x17\x90UV[\x82Q\x91\x82R` \x82\x01R\xA2\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x17`$\x82\x01R\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0`D\x82\x01R`d\x90\xFD[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x12`$\x82\x01Rq\x12[\x9D\x19\\\x9D\x98[\x08\x1D\x1B\xDB\xC8\x1C\xDA\x1B\xDC\x9D`r\x1B`D\x82\x01R`d\x90\xFD[P\x81\x84\x16_\x90\x81R`\x07` R`@\x90 T`\x01`\x01`\xA0\x1B\x03\x163\x14a\x0CXV[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa\x04!a\x0E\x07a&\x0CV[`\x01`\x01`@\x1B\x03\x81\x16_R`\x06` Ra\x0E7a\x087`@_ 3\x90`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[a2\xF8V[4a\x03kW`\xA06`\x03\x19\x01\x12a\x03kWa\x0EUa&\x0CV[`$5`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x0Et\x906\x90`\x04\x01a(\x7FV[\x90`D5`d5\x91`\x845\x94\x85\x15\x15\x80\x96\x03a\x03kW`\x01`\x01`@\x1B\x03\x16\x80_R`\x07` Ra\x0E\xB2`\x01\x80`\xA0\x1B\x03`@_ T\x163\x14a+\xA4V[a\x0E\xBF`@\x86\x11\x15a,\xA4V[a\x0E\xCB\x83\x85\x10\x15a,\xE0V[\x80_R`\x08` Ra\x0E\xE3`2`@_ T\x10a+\xE4V[_R`\x08` Ra\x0F\x06`@_ \x91`@Q\x95a\x0E\xFF\x87a'IV[6\x91a)\xA3V[\x84R` \x84\x01\x91\x82R`@\x84\x01\x92\x83R``\x84\x01\x94\x85R\x80T`\x01`@\x1B\x81\x10\x15a\x109Wa\x0F:\x91`\x01\x82\x01\x81Ua&\xC9V[\x93\x90\x93a\x10MWQ\x80Q\x90`\x01`\x01`@\x1B\x03\x82\x11a\x109Wa\x0Fg\x82a\x0Fa\x87Ta&\xF6V[\x87a-\x1DV[` \x90`\x1F\x83\x11`\x01\x14a\x0F\xCFW\x82`\x03\x95\x93a\x04!\x98\x95\x93a\x0F\x9F\x93_\x92a\x0F\xC4W[PP\x81`\x01\x1B\x91_\x19\x90`\x03\x1B\x1C\x19\x16\x17\x90V[\x85U[Q`\x01\x85\x01UQ`\x02\x84\x01UQ\x15\x15\x91\x01\x90`\xFF\x80\x19\x83T\x16\x91\x15\x15\x16\x17\x90UV[\x01Q\x90P\x89\x80a\x0F\x8BV[\x90`\x1F\x19\x83\x16\x91\x86_R\x81_ \x92_[\x81\x81\x10a\x10!WP\x92`\x01\x92\x85\x92`\x03\x98\x96a\x04!\x9B\x98\x96\x10a\x10\nW[PPP\x81\x1B\x01\x85Ua\x0F\xA2V[\x01Q_\x19\x83\x89\x1B`\xF8\x16\x1C\x19\x16\x90U\x88\x80\x80a\x0F\xFDV[\x92\x93` `\x01\x81\x92\x87\x86\x01Q\x81U\x01\x95\x01\x93\x01a\x0F\xDFV[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[4a\x03kWa\x10n6a*\xB0V[\x90\x91\x92`\x01\x80`\xA0\x1B\x03`\nT\x163\x03a\x11\xABW`\x01`\x01`@\x1B\x03\x16\x91\x82_R`\x05` Ra\x10\xB9`@_ \x94`\x01\x80`\xA0\x1B\x03\x16\x80\x95`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[\x15a\x11sW\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x91\x83_R`\x03` R`@_ \x85_R` R`\x01`@_ \x01i\x03\0\0\0\0\0\0\0\0\0`\xFF`H\x1B\x19\x82T\x16\x17\x90U\x83_R`\x04` Ra\x11%\x85`@_ a=\x86V[P\x83_R`\x0C` R`@_ \x85_R` R`@_ `\x01`\x01`@\x1B\x03\x80B\x16\x16`\x01`\x01`@\x1B\x03\x19\x82T\x16\x17\x90Ua\x11n`@Q\x92\x83\x92` \x84R` \x84\x01\x91a2\xD8V[\x03\x90\xA3\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x10`$\x82\x01Ro'\xB82\xB90\xBA7\xB9\x10:\xB75\xB77\xBB\xB7`\x81\x1B`D\x82\x01R`d\x90\xFD[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x13`$\x82\x01RrNot slashing oracle`h\x1B`D\x82\x01R`d\x90\xFD[4a\x03kW``6`\x03\x19\x01\x12a\x03kWa\x11\xFFa&\x0CV[a\x12\x07a&8V[`D5`\x01`\x01`@\x1B\x03\x81\x11a\x03kW` \x92\x83\x92`\x01`\x01`@\x1B\x03a\x124\x85\x946\x90`\x04\x01a)\xD9V[\x92\x16_R`\t\x83R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R\x82R`@_ `@Q\x93\x82\x85\x93Q\x91\x82\x91\x01\x84^\x82\x01\x90\x81R\x03\x01\x90 T`@Q\x90\x81R\xF3[4a\x03kWa\x12\x7F6a&dV[\x90`\x01`\x01`@\x1B\x03_\x93\x16\x92[\x82\x81\x10\x15a\x04!W`\x05\x81\x90\x1B\x82\x015`\x01`\x01`\xA0\x1B\x03\x81\x16\x91\x90\x82\x90\x03a\x03kW0;\x15a\x03kW`@Q\x91c\xBA\x1F\xB1\x03`\xE0\x1B\x83R\x85`\x04\x84\x01R`$\x83\x01R_\x82`D\x81\x830Z\xF1\x91\x82\x15a\x12\xFFW`\x01\x92a\x12\xEFW[P\x01a\x12\x8DV[_a\x12\xF9\x91a'\x9AV[\x85a\x12\xE8V[`@Q=_\x82>=\x90\xFD[4a\x03kW_6`\x03\x19\x01\x12a\x03kW_T`@Q`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x81R` \x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa\x13Ja&NV[a\x13Ra7\x19V[`\n\x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x92\x90\x92\x16\x91\x90\x91\x17\x90U\0[4a\x03kW``6`\x03\x19\x01\x12a\x03kWa\x13\xB4a\x13\xA0a\x13\x93a&\x0CV[`D5\x90`$5\x90a0\x9EV[`@Q\x92\x83\x92`@\x84R`@\x84\x01\x90a)%V[\x90` \x83\x01R\x03\x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x13\xDFa&\x0CV[\x16_R`\x04` R` `@_ T`@Q\x90\x81R\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`\x01T3`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x03a\x14hW`\x01\x80T`\x01`\x01`\xA0\x1B\x03\x19\x90\x81\x16\x90\x91U_\x80T3\x92\x81\x16\x83\x17\x82U`\x01`\x01`\xA0\x1B\x03\x16\x90\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x90\x80\xA3\0[c\x11\x8C\xDA\xA7`\xE0\x1B_R3`\x04R`$_\xFD[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x14\x94a&\x0CV[`\x01`\x01`@\x1B\x03a\x14\xA4a&8V[\x91\x16_R`\x0C` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R` `\x01`\x01`@\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x14\xF0a&\x0CV[`\x01`\x01`@\x1B\x03a\x15\0a&8V[\x91_`\x80`@Qa\x15\x10\x81a'.V[\x82\x81R\x82` \x82\x01R\x82`@\x82\x01R\x82``\x82\x01R\x01R\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ `@Qa\x15Q\x81a'.V[\x81T\x81R`\x01\x82\x01T\x91` \x82\x01\x90`\x01`\x01`@\x1B\x03\x84\x16\x82R`\xFF`@\x84\x01\x94\x81\x81`@\x1C\x16\x86R`H\x1C\x16``\x84\x01\x90`\x05\x81\x10\x15a\x06\x94W`\xA0\x95`\x01`\x01`@\x1B\x03`\x02a\x15\xCD\x95`\xFF\x94\x86R\x01T\x95`\x80\x88\x01\x96\x87R`@Q\x97Q\x88RQ\x16` \x87\x01RQ\x16`@\x85\x01RQ``\x84\x01\x90a)\x18V[Q`\x80\x82\x01R\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kWa\x15\xEDa7\x19V[`\x01\x80T`\x01`\x01`\xA0\x1B\x03\x19\x90\x81\x16\x90\x91U_\x80T\x91\x82\x16\x81U\x90`\x01`\x01`\xA0\x1B\x03\x16\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x82\x80\xA3\0[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q`@\x81R\xF3[4a\x03kW`\x806`\x03\x19\x01\x12a\x03kWa\x16la&\x0CV[a\x16ta&8V[`D5`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x16\x93\x906\x90`\x04\x01a)\xF7V[`d5\x9203\x03a\x1A\x95W`\x01`\x01`@\x1B\x03\x16\x91\x82_R`\x08` R`@_ \x93a\x16\xBE\x81a-`V[\x92_[\x82\x81\x10a\x1AnWP\x85T\x80\x15\x15\x80\x91``\x92a\x1A%W[P_[\x84\x81\x10a\x18\x17WPPPPP_\x92\x84T\x94[\x85\x85\x10a\x16\xF6W\0[`\xFF`\x03a\x17\x04\x87\x84a&\xC9V[P\x01T\x16\x15a\x18\rWa\x17*a\x171a\x17\x1D\x87\x84a&\xC9V[P`@Q\x92\x83\x80\x92a-\xF2V[\x03\x82a'\x9AV[` \x81Q\x91\x01 _\x94_[\x81Q\x81\x10\x15a\x17\xFFW\x82a\x17P\x82\x84a-\x92V[Q\x14a\x17^W`\x01\x01a\x17<V[P\x94PP\x94\x93`\x01\x90\x81[\x15a\x17wW[\x01\x93\x94a\x16\xEDV[a\x17\x81\x81\x88a&\xC9V[P\x83\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15a\x17\xB9`@Q\x93`@\x85R`@\x85\x01\x90a-\xF2V[\x92\x7FRequired metric missing\0\0\0\0\0\0\0\0\0` \x82\x86\x03\x95\x86\x82\x85\x01R`\x17\x81R\x01R`@\x86\x80`\xA0\x1B\x03\x89\x16\x94\x01\x90\xA3a\x17oV[P\x94`\x01\x92\x97\x96\x91Pa\x17iV[\x94\x93`\x01\x90a\x17oV[`\x01_\x83a\x18\xEFW[P\x90`\x01\x91a\x180W[\x01a\x16\xDBV[` a\x18<\x82\x87a-\x92V[Q\x01Q\x89_R`\t` R`@_ \x83\x80`\xA0\x1B\x03\x89\x16_R` R` \x80`@_ a\x18i\x85\x8Aa-\x92V[QQ\x90`@Q\x93\x82\x85\x93Q\x91\x82\x91\x01\x84^\x82\x01\x90\x81R\x03\x01\x90 Ua\x18\x8E\x81\x86a-\x92V[QQ\x89\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD` a\x18\xBE\x85\x8Aa-\x92V[Q\x01Q\x92a\x18\xD7`@Q\x91`@\x83R`@\x83\x01\x90a([V[\x93` \x82\x01R\x80\x86\x80`\xA0\x1B\x03\x8C\x16\x94\x03\x90\xA3a\x18*V[\x8AT_[\x81\x81\x10a\x19\x16W[PP\x90`\x01\x92\x91\x15a\x19\x0FW[\x90\x91a\x18 V[P_a\x19\x08V[a\x19 \x85\x8Ca-\x92V[Qa\x19+\x82\x89a-\x92V[Q\x14a\x199W`\x01\x01a\x18\xF3V[`\x01\x94\x93\x92P\x84\x91P\x8C` a\x19O\x86\x8Ba-\x92V[Q\x01Q\x83a\x19]\x84\x84a&\xC9V[P\x01T\x11\x91\x82\x15a\x19\xFCW[PPa\x19yW[\x90\x91\x92\x8Ca\x18\xFBV[\x90Pa\x19\x85\x82\x87a-\x92V[QQ\x8A\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15a\x19\xBE`@Q\x93`@\x85R`@\x85\x01\x90a([V[\x92rValue out of bounds`h\x1B` \x82\x86\x03\x95\x86\x82\x85\x01R`\x13\x81R\x01R`@\x87\x80`\xA0\x1B\x03\x8D\x16\x94\x01\x90\xA3_\x90a\x19pV[`\x02\x91\x92Pa\x1A\x1A\x90` a\x1A\x11\x88\x8Da-\x92V[Q\x01Q\x93a&\xC9V[P\x01T\x10\x8C\x8Ea\x19iV[\x91Pa\x1A0\x82a-`V[\x91\x88_[\x82\x81\x10a\x1ABWPPa\x16\xD8V[a\x17*a\x1ATa\x17\x1D\x83`\x01\x95a&\xC9V[` \x81Q\x91\x01 a\x1Ae\x82\x87a-\x92V[R\x01\x89\x90a\x1A4V[\x80a\x1A{`\x01\x92\x84a-\x92V[QQ` \x81Q\x91\x01 a\x1A\x8E\x82\x88a-\x92V[R\x01a\x16\xC1V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\r`$\x82\x01RlInternal only`\x98\x1B`D\x82\x01R`d\x90\xFD[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x1A\xE3a&\x0CV[`\x01`\x01`@\x1B\x03a\x1A\xF3a&8V[\x91\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R` `\xFF`\x01`@_ \x01T`H\x1C\x16a\x1B+`@Q\x80\x92a)\x18V[\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q`\x03\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kW` a\x04\xC1a\x1Bfa&\x0CV[`\x01`\x01`@\x1B\x03a\x1Bva&8V[\x91\x16_\x90\x81R`\x06\x84R`@\x80\x82 `\x01`\x01`\xA0\x1B\x03\x90\x93\x16\x82R`\x01\x90\x92\x01` R T\x15\x15\x90V[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q`2\x81R\xF3[4a\x03kW`\x806`\x03\x19\x01\x12a\x03kWa\x1B\xD5a&\x0CV[a\x1B\xDDa&\"V[\x90a\x1B\xE6a)aV[\x91`d5\x92`\x01`\x01`@\x1B\x03\x84\x11a\x03kWa\x1C\na\x04!\x946\x90`\x04\x01a(\x7FV[\x93\x90\x92`\x01`\x01`@\x1B\x03\x82\x16_R`\x06` Ra\x1C=a\x087`@_ 3\x90`\x01\x91_R\x01` R`@_ T\x15\x15\x90V[3\x91a7,V[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`@Q\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x81R` \x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa\x1C\xC1a\x1C\xACa\x1C\xA7a&\x0CV[a.\x8DV[P`@Q\x91\x82\x91` \x83R` \x83\x01\x90a)%V[\x03\x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x1C\xE6a&\x0CV[\x16_R`\x07` R` `\x01\x80`\xA0\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x1D\x1Ea&\x0CV[`\x01`\x01`@\x1B\x03a\x1D.a&8V[\x91\x16\x80_R`\x03` R`@_ `\x01\x80`\xA0\x1B\x03\x83\x16_R` R`\xFF`\x01`@_ \x01T`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W\x15\x90\x81\x15a\x1DwW[` \x82`@Q\x90\x15\x15\x81R\xF3[\x90P_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`\xFF`\x01`@_ \x01T`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x01` \x91\x14\x82a\x1DjV[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q`\xC8\x81R\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x1D\xF1a&\x0CV[\x16\x80_R`\x04` R`@_ Ta\x1E\x08\x81a-`V[\x91_[\x82\x81\x10a\x1E(W`@Q` \x80\x82R\x81\x90a\x1C\xC1\x90\x82\x01\x87a)%V[`\x01\x90\x82_R`\x04` Ra\x1E@\x81`@_ a;\x10V[\x83\x80`\xA0\x1B\x03\x91T\x90`\x03\x1B\x1C\x16a\x1EX\x82\x87a-\x92V[\x90\x83\x80`\xA0\x1B\x03\x16\x90R\x01a\x1E\x0BV[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x01`\x01`@\x1B\x03a\x1E\x89a&\x0CV[\x16_R`\x05` R` `@_ T`@Q\x90\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa\x1E\xB9a&\x0CV[`\x01`\x01`@\x1B\x03a\x1E\xC9a&8V[\x91\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`\xA0`@_ \x80T\x90a\x1F,`\x02`\x01\x83\x01T\x92\x01T\x91`@Q\x93\x84R`\x01`\x01`@\x1B\x03\x81\x16` \x85\x01R`\xFF\x81`@\x1C\x16`@\x85\x01R`\xFF``\x85\x01\x91`H\x1C\x16a)\x18V[`\x80\x82\x01R\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Qa\x0E\x10\x81R\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Q\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x81R\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW`\x045`\x01`\x01`@\x1B\x03\x81\x11a\x03kWa\x1F\xB9\x906\x90`\x04\x01a(\x7FV[\x81\x01\x90` \x81\x83\x03\x12a\x03kW\x805\x91`\x01`\x01`@\x1B\x03\x83\x11a\x03kWa\x1C\xC1\x92a\x1F\xE5\x92\x01a)\xF7V[`@Q\x91\x82\x91` \x83R` \x83\x01\x90a(\xACV[4a\x03kW_6`\x03\x19\x01\x12a\x03kW`\x0BT`@Q`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x81R` \x90\xF3[4a\x03kW_6`\x03\x19\x01\x12a\x03kW` `@Qa\x01,\x81R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa Va&\x0CV[`\x01`\x01`@\x1B\x03`$5\x91\x16_R`\x08` R`@_ \x80T\x82\x10\x15a\x03kWa \xB7\x91a \x84\x91a&\xC9V[Pa \x8E\x81a'\xBBV[\x90`\x01\x81\x01T\x90`\xFF`\x03`\x02\x83\x01T\x92\x01T\x16\x90`@Q\x94\x85\x94`\x80\x86R`\x80\x86\x01\x90a([V[\x92` \x85\x01R`@\x84\x01R\x15\x15``\x83\x01R\x03\x90\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kWa \xE6a&NV[a \xEEa7\x19V[`\x0B\x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x92\x90\x92\x16\x91\x90\x91\x17\x90U\0[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa!)a&\x0CV[a!1a&8V[a!e3\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x14a+\x06V[`\x01`\x01`\xA0\x1B\x03\x16\x90\x81\x15a!\xEBW`\x01`\x01`@\x1B\x03\x16\x80_R`\x06` Ra!\x9Ba!\x96\x83`@_ a;%V[a+EV[\x80_R`\x03` R`@_ \x82_R` R`\x01`@_ \x01`\x01`I\x1B`\xFF`H\x1B\x19\x82T\x16\x17\x90U\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK_\x80\xA3\0[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x0C`$\x82\x01RkZero address`\xA0\x1B`D\x82\x01R`d\x90\xFD[4a\x03kW`\x01`\x01`@\x1B\x03a\"56a&dV[\x91\x92\x90\x92\x16\x90\x81_R`\x07` Ra\"Z`\x01\x80`\xA0\x1B\x03`@_ T\x163\x14a+\xA4V[a\"g`2\x82\x11\x15a+\xE4V[\x81_R`\x08` R`@_ \x80T\x90_\x81U\x81a$!W[PP_[\x81\x81\x10a\"\x8CW\0[a\"\xAE`@a\"\xA5a\"\x9F\x84\x86\x89a,PV[\x80a,rV[\x90P\x11\x15a,\xA4V[a\"\xD6`@a\"\xBE\x83\x85\x88a,PV[\x015` a\"\xCD\x84\x86\x89a,PV[\x015\x11\x15a,\xE0V[\x82_R`\x08` R`@_ \x90a\"\xEE\x81\x84\x87a,PV[\x91\x80T`\x01`@\x1B\x81\x10\x15a\x109Wa#\x0C\x91`\x01\x82\x01\x81Ua&\xC9V[\x92\x90\x92a\x10MWa#\x1D\x81\x80a,rV[\x90`\x01`\x01`@\x1B\x03\x82\x11a\x109Wa#:\x82a\x0Fa\x87Ta&\xF6V[_\x90`\x1F\x83\x11`\x01\x14a#\xBAW\x91\x80a#k\x92``\x95\x94_\x92a#\xAFWPP\x81`\x01\x1B\x91_\x19\x90`\x03\x1B\x1C\x19\x16\x17\x90V[\x84U[` \x81\x015`\x01\x85\x01U`@\x81\x015`\x02\x85\x01U\x015\x91\x82\x15\x15\x83\x03a\x03kW`\x01\x92`\x03a#\xA9\x92\x01\x90`\xFF\x80\x19\x83T\x16\x91\x15\x15\x16\x17\x90UV[\x01a\"\x83V[\x015\x90P\x8A\x80a\x0F\x8BV[`\x1F\x19\x83\x16\x91\x86_R` _ \x92_[\x81\x81\x10a$\tWP\x91`\x01\x93\x91\x85``\x97\x96\x94\x10a#\xF0W[PPP\x81\x1B\x01\x84Ua#nV[\x015_\x19`\x03\x84\x90\x1B`\xF8\x16\x1C\x19\x16\x90U\x89\x80\x80a#\xE3V[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a#\xCAV[`\x01`\x01`\xFE\x1B\x03\x82\x16\x82\x03a\x06\x80W_R` _ \x90`\x02\x1B\x81\x01\x90[\x81\x81\x10\x15a\"\x7FW\x80a$T`\x04\x92Ta&\xF6V[\x80a$sW[P_`\x01\x82\x01U_`\x02\x82\x01U_`\x03\x82\x01U\x01a$?V[`\x1F\x81\x11`\x01\x14a$\x89WP_\x81U[\x86a$ZV[a$\xA6\x90\x82_R`\x01`\x1F` _ \x92\x01`\x05\x1C\x82\x01\x91\x01a,:V[\x80_R_` \x81 \x81\x83UUa$\x83V[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa$\xD0a&\x0CV[`\x01`\x01`@\x1B\x03a$\xE0a&8V[\x91\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R` `@_ T`@Q\x90\x81R\xF3[4a\x03kW` 6`\x03\x19\x01\x12a\x03kW``a%6a%(a&\x0CV[a%0a+\x86V[Pa6\xA3V[`@\x80Q\x91`\x01`\x01`@\x1B\x03\x81Q\x16\x83R`\xFF` \x82\x01Q\x16` \x84\x01R\x01Q\x15\x15`@\x82\x01R\xF3[4a\x03kW`@6`\x03\x19\x01\x12a\x03kWa%ya&\x0CV[`\x01`\x01`@\x1B\x03a%\x89a&8V[\x91a%\xBE3\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x16\x14a+\x06V[\x16_\x81\x81R`\x07` R`@\x90 Ta%\xE0\x90`\x01`\x01`\xA0\x1B\x03\x16\x15a+EV[_\x90\x81R`\x07` R`@\x90 \x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x90\x92\x16\x91\x90\x91\x17\x90U\0[`\x045\x90`\x01`\x01`@\x1B\x03\x82\x16\x82\x03a\x03kWV[`$5\x90`\x01`\x01`@\x1B\x03\x82\x16\x82\x03a\x03kWV[`$5\x90`\x01`\x01`\xA0\x1B\x03\x82\x16\x82\x03a\x03kWV[`\x045\x90`\x01`\x01`\xA0\x1B\x03\x82\x16\x82\x03a\x03kWV[`@`\x03\x19\x82\x01\x12a\x03kW`\x045`\x01`\x01`@\x1B\x03\x81\x16\x81\x03a\x03kW\x91`$5`\x01`\x01`@\x1B\x03\x81\x11a\x03kW`\x04\x01\x82`\x1F\x82\x01\x12\x15a\x03kW\x805\x92`\x01`\x01`@\x1B\x03\x84\x11a\x03kW` \x80\x83\x01\x92\x85`\x05\x1B\x01\x01\x11a\x03kW\x91\x90V[\x80T\x82\x10\x15a&\xE2W_R` _ \x90`\x02\x1B\x01\x90_\x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[\x90`\x01\x82\x81\x1C\x92\x16\x80\x15a'$W[` \x83\x10\x14a'\x10WV[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x91`\x7F\x16\x91a'\x05V[`\xA0\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[`\x80\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[``\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[`@\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[\x90`\x1F\x80\x19\x91\x01\x16\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x109W`@RV[\x90`@Q\x91\x82_\x82T\x92a'\xCE\x84a&\xF6V[\x80\x84R\x93`\x01\x81\x16\x90\x81\x15a(9WP`\x01\x14a'\xF5W[Pa'\xF3\x92P\x03\x83a'\x9AV[V[\x90P_\x92\x91\x92R` _ \x90_\x91[\x81\x83\x10a(\x1DWPP\x90` a'\xF3\x92\x82\x01\x01_a'\xE6V[` \x91\x93P\x80`\x01\x91T\x83\x85\x89\x01\x01R\x01\x91\x01\x90\x91\x84\x92a(\x04V[\x90P` \x92Pa'\xF3\x94\x91P`\xFF\x19\x16\x82\x84\x01R\x15\x15`\x05\x1B\x82\x01\x01_a'\xE6V[\x80Q\x80\x83R` \x92\x91\x81\x90\x84\x01\x84\x84\x01^_\x82\x82\x01\x84\x01R`\x1F\x01`\x1F\x19\x16\x01\x01\x90V[\x91\x81`\x1F\x84\x01\x12\x15a\x03kW\x825\x91`\x01`\x01`@\x1B\x03\x83\x11a\x03kW` \x83\x81\x86\x01\x95\x01\x01\x11a\x03kWV[\x90\x80` \x83Q\x91\x82\x81R\x01\x91` \x80\x83`\x05\x1B\x83\x01\x01\x94\x01\x92_\x91[\x83\x83\x10a(\xD7WPPPPP\x90V[\x90\x91\x92\x93\x94` \x80`\x01\x92`\x1F\x19\x85\x82\x03\x01\x86R\x88Q\x90\x82\x80a)\x03\x84Q`@\x85R`@\x85\x01\x90a([V[\x93\x01Q\x91\x01R\x97\x01\x93\x01\x93\x01\x91\x93\x92\x90a(\xC8V[\x90`\x05\x82\x10\x15a\x06\x94WRV[\x90` \x80\x83Q\x92\x83\x81R\x01\x92\x01\x90_[\x81\x81\x10a)BWPPP\x90V[\x82Q`\x01`\x01`\xA0\x1B\x03\x16\x84R` \x93\x84\x01\x93\x90\x92\x01\x91`\x01\x01a)5V[`D5\x90`\xFF\x82\x16\x82\x03a\x03kWV[`\x01`\x01`@\x1B\x03\x81\x11a\x109W`\x05\x1B` \x01\x90V[`\x01`\x01`@\x1B\x03\x81\x11a\x109W`\x1F\x01`\x1F\x19\x16` \x01\x90V[\x92\x91\x92a)\xAF\x82a)\x88V[\x91a)\xBD`@Q\x93\x84a'\x9AV[\x82\x94\x81\x84R\x81\x83\x01\x11a\x03kW\x82\x81` \x93\x84_\x96\x017\x01\x01RV[\x90\x80`\x1F\x83\x01\x12\x15a\x03kW\x81` a)\xF4\x935\x91\x01a)\xA3V[\x90V[\x81`\x1F\x82\x01\x12\x15a\x03kW\x805\x90a*\x0E\x82a)qV[\x92a*\x1C`@Q\x94\x85a'\x9AV[\x82\x84R` \x80\x85\x01\x93`\x05\x1B\x83\x01\x01\x91\x81\x83\x11a\x03kW` \x81\x01\x93[\x83\x85\x10a*HWPPPPP\x90V[\x845`\x01`\x01`@\x1B\x03\x81\x11a\x03kW\x82\x01`@\x81\x85\x03`\x1F\x19\x01\x12a\x03kW`@Q\x91a*u\x83a'\x7FV[` \x82\x015\x92`\x01`\x01`@\x1B\x03\x84\x11a\x03kW`@\x83a*\x9D\x88` \x80\x98\x81\x98\x01\x01a)\xD9V[\x83R\x015\x83\x82\x01R\x81R\x01\x94\x01\x93a*9V[```\x03\x19\x82\x01\x12a\x03kW`\x045`\x01`\x01`@\x1B\x03\x81\x16\x81\x03a\x03kW\x91`$5`\x01`\x01`\xA0\x1B\x03\x81\x16\x81\x03a\x03kW\x91`D5\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03kWa+\x02\x91`\x04\x01a(\x7FV[\x90\x91V[\x15a+\rWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x10`$\x82\x01RoOnly Tangle core`\x80\x1B`D\x82\x01R`d\x90\xFD[\x15a+LWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x12`$\x82\x01Rq\x10[\x1C\x99XY\x1EH\x1C\x99Y\xDA\\\xDD\x19\\\x99Y`r\x1B`D\x82\x01R`d\x90\xFD[`@Q\x90a+\x93\x82a'dV[_`@\x83\x82\x81R\x82` \x82\x01R\x01RV[\x15a+\xABWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x11`$\x82\x01Rp'7\xBA\x109\xB2\xB9;4\xB1\xB2\x907\xBB\xB72\xB9`y\x1B`D\x82\x01R`d\x90\xFD[\x15a+\xEBWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x14`$\x82\x01RsToo many definitions``\x1B`D\x82\x01R`d\x90\xFD[\x81\x81\x02\x92\x91\x81\x15\x91\x84\x04\x14\x17\x15a\x06\x80WV[\x81\x81\x10a,EWPPV[_\x81U`\x01\x01a,:V[\x91\x90\x81\x10\x15a&\xE2W`\x05\x1B\x81\x015\x90`~\x19\x816\x03\x01\x82\x12\x15a\x03kW\x01\x90V[\x905\x90`\x1E\x19\x816\x03\x01\x82\x12\x15a\x03kW\x01\x805\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03kW` \x01\x91\x816\x03\x83\x13a\x03kWV[\x15a,\xABWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\r`$\x82\x01RlName too long`\x98\x1B`D\x82\x01R`d\x90\xFD[\x15a,\xE7WV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x0E`$\x82\x01RmInvalid bounds`\x90\x1B`D\x82\x01R`d\x90\xFD[\x91\x90`\x1F\x81\x11a-,WPPPV[a'\xF3\x92_R` _ \x90` `\x1F\x84\x01`\x05\x1C\x83\x01\x93\x10a-VW[`\x1F\x01`\x05\x1C\x01\x90a,:V[\x90\x91P\x81\x90a-IV[\x90a-j\x82a)qV[a-w`@Q\x91\x82a'\x9AV[\x82\x81R\x80\x92a-\x88`\x1F\x19\x91a)qV[\x01\x90` 6\x91\x017V[\x80Q\x82\x10\x15a&\xE2W` \x91`\x05\x1B\x01\x01\x90V[\x15a-\xADWV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x17`$\x82\x01R\x7FNot registered operator\0\0\0\0\0\0\0\0\0`D\x82\x01R`d\x90\xFD[_\x92\x91\x81T\x91a.\x01\x83a&\xF6V[\x80\x83R\x92`\x01\x81\x16\x90\x81\x15a.VWP`\x01\x14a.\x1DWPPPV[_\x90\x81R` \x81 \x93\x94P\x91\x92[\x83\x83\x10a.<WP` \x92P\x01\x01\x90V[`\x01\x81` \x92\x94\x93\x94T\x83\x85\x87\x01\x01R\x01\x91\x01\x91\x90a.+V[\x91PP` \x93\x94P`\xFF\x92\x91\x92\x19\x16\x83\x83\x01R\x15\x15`\x05\x1B\x01\x01\x90V[\x91\x90\x82\x01\x80\x92\x11a\x06\x80WV[\x91\x90\x82\x03\x91\x82\x11a\x06\x80WV[`\x01`\x01`@\x1B\x03a.\x9E\x82a6\xA3V[\x91\x16\x91\x82_R`\x05` R`@_ T\x91` \x81\x01\x90`\xFF\x82Q\x16\x15\x80\x15a0\x96W[\x80\x15a0\x8EW[a0pW\x90`\xFF`\x01`\x01`@\x1B\x03a.\xE6\x93Q\x16\x91Q\x16\x90a,'V[`\xC8\x83\x10\x15a0iW\x82[a.\xFA\x81a-`V[\x94_\x92_[\x83\x81\x10a/JWPPPPa/\x13\x81a-`V[\x93_[\x82\x81\x10a/\"WPPPV[`\x01\x90`\x01`\x01`\xA0\x1B\x03a/7\x82\x85a-\x92V[Q\x16a/C\x82\x89a-\x92V[R\x01a/\x16V[\x82_R`\x05` Ra/_\x81`@_ a;\x10V[\x90T_\x85\x81R`\x06` \x90\x81R`@\x80\x83 `\x03\x95\x90\x95\x1B\x93\x90\x93\x1C`\x01`\x01`\xA0\x1B\x03\x16\x80\x83R`\x01\x94\x90\x94\x01\x90R T\x15a0`W\x83_R`\x03` R`@_ \x81_R` R`@_ `@Qa/\xB8\x81a'.V[\x81T\x81R`\xFF`\x01\x83\x01T`\x01`\x01`@\x1B\x03\x81\x16` \x84\x01R\x81\x81`@\x1C\x16`@\x84\x01R`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x02\x86\x93\x82``\x85\x01R\x01T`\x80\x83\x01R\x81Q\x15\x90\x81\x15a0UW[Pa0JWa0\x16\x90QBa.\x80V[\x10\x15a0(W[P`\x01\x90[\x01a.\xFFV[a05\x86\x8A\x97\x93\x97a-\x92V[R_\x19\x81\x14a\x06\x80W`\x01\x80\x91\x01\x94\x90a0\x1DV[PPP`\x01\x90a0\"V[`\x03\x91P\x14_a0\x06V[P`\x01\x90a0\"V[`\xC8a.\xF1V[PP\x90\x91P`@Qa0\x83` \x82a'\x9AV[_\x81R_6\x817\x91\x90V[P\x83\x15a.\xC8V[P\x83\x15a.\xC1V[\x91\x92\x90`\x01`\x01`@\x1B\x03a0\xB2\x84a6\xA3V[\x93\x16\x80_R`\x05` R`@_ T\x93` \x81\x01\x90`\xFF\x82Q\x16\x15\x80\x15a2\xD0W[\x80\x15a2\xC6W[a2\xB1W\x90`\xFF`\x01`\x01`@\x1B\x03a0\xF9\x93Q\x16\x91Q\x16\x90a,'V[\x94`\xC8\x81\x11\x15a2\xACWP`\xC8[\x84a1\x12\x82\x85a.sV[\x11\x15a2\x9CWP\x83\x90[a1.a1)\x84\x84a.\x80V[a-`V[\x95_\x93[\x83\x81\x10a1}WPPPPa1F\x81a-`V[\x93_[\x82\x81\x10a1UWPPPV[`\x01\x90`\x01`\x01`\xA0\x1B\x03a1j\x82\x85a-\x92V[Q\x16a1v\x82\x89a-\x92V[R\x01a1IV[\x82_R`\x05` Ra1\x92\x81`@_ a;\x10V[\x90T_\x85\x81R`\x06` \x90\x81R`@\x80\x83 `\x03\x95\x90\x95\x1B\x93\x90\x93\x1C`\x01`\x01`\xA0\x1B\x03\x16\x80\x83R`\x01\x94\x90\x94\x01\x90R T\x15a2\x93W\x83_R`\x03` R`@_ \x81_R` R`@_ `@Qa1\xEB\x81a'.V[\x81T\x81R`\xFF`\x01\x83\x01T`\x01`\x01`@\x1B\x03\x81\x16` \x84\x01R\x81\x81`@\x1C\x16`@\x84\x01R`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x02\x86\x93\x82``\x85\x01R\x01T`\x80\x83\x01R\x81Q\x15\x90\x81\x15a2\x88W[Pa2}Wa2I\x90QBa.\x80V[\x10\x15a2[W[P`\x01\x90[\x01a12V[a2h\x86\x8A\x97\x93\x97a-\x92V[R_\x19\x81\x14a\x06\x80W`\x01\x80\x91\x01\x94\x90a2PV[PPP`\x01\x90a2UV[`\x03\x91P\x14_a29V[P`\x01\x90a2UV[a2\xA6\x90\x83a.sV[\x90a1\x1CV[a1\x07V[PPPP\x90\x91P`@Qa0\x83` \x82a'\x9AV[P\x85\x84\x10\x15a0\xDBV[P\x85\x15a0\xD4V[\x90\x80` \x93\x92\x81\x84R\x84\x84\x017_\x82\x82\x01\x84\x01R`\x1F\x01`\x1F\x19\x16\x01\x01\x90V[`\x01`\x01`@\x1B\x03\x16_\x81\x81R`\x03` \x90\x81R`@\x80\x83 3\x84R\x90\x91R\x90 `\x01\x01\x80T`H\x1C`\xFF\x16\x91\x90`\x05\x83\x10\x15a\x06\x94W`\x03\x83\x14a3\xD8W\x82\x15\x80\x15a3\xCEW[a3\xC9W\x80Ti\xFF\xFF\0\0\0\0\0\0\0\0\x19\x16i\x01\0\0\0\0\0\0\0\0\0\x17\x90U_\x81\x81R`\x04` R`@\x90 a3y\x903\x90a;%V[Pa3\xAD`@Q\x80\x933\x84\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C_\x80\xA3a)\x18V[`\x01` \x83\x01R_\x80Q` a?h\x839\x81Q\x91R`@3\x93\xA3V[PPPV[P`\x01\x83\x14a3@V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x1E`$\x82\x01R\x7FCannot go online while slashed\0\0`D\x82\x01R`d\x90\xFD[\x15a4$WV[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x0E`$\x82\x01Rm\x13\x9B\xDD\x08\x18]]\x1A\x1B\xDC\x9A^\x99Y`\x92\x1B`D\x82\x01R`d\x90\xFD[\x90`\x01`\x01`@\x1B\x03\x82\x16\x90\x81_R`\x03` R`@_ `\x01\x80`\xA0\x1B\x03\x82\x16_R` Ra4\x8D`@_ \x93a6\xA3V[\x92`\x01\x81\x01\x93\x84T\x91`\xFF\x83`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x03\x14a4\xEFWT\x80\x15a4\xEFWa4\xBE\x90Ba.\x80V[`\x01`\x01`@\x1B\x03\x82Q\x16\x90\x81\x15a5\xE9W\x04`\xFF\x81\x11\x15a5\xE1WP`\xFF[`\xFF\x80\x82\x16\x93`@\x1C\x16\x83\x11a4\xF7W[PPPPPPV[\x85T`@\x91\x90\x91\x1B`\xFF`@\x1B\x16h\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x19\x90\x91\x16\x17\x85U` \x01Q`\xFF\x16\x81\x10\x15\x80a5\xC6W[a52W[\x80\x80a4\xEFV[\x83_\x80Q` a?h\x839\x81Q\x91R\x92\x84\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM` `@\x95`\xFFa5\xA2\x9AT`H\x1C\x16\x95`\x01`I\x1B`\xFF`H\x1B\x19\x82T\x16\x17\x90U\x83_R`\x04\x82R\x86_ \x94`\x01\x80`\xA0\x1B\x03\x16\x99\x8A\x80\x96a=\x86V[P\x86Q\x90\x81R\xA3a5\xB5\x82Q\x80\x92a)\x18V[`\x02` \x82\x01R\xA3_\x80\x80\x80a5+V[P`\xFF\x84T`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x02\x14\x15a5&V[`\xFF\x16a4\xDEV[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[\x90`\x01`\x01`@\x1B\x03a6\x0F\x83a6\xA3V[\x92\x16_R`\x03` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ `@Q\x90a6;\x82a'.V[\x80T\x82R`\xFF`\x01\x82\x01T`\x01`\x01`@\x1B\x03\x81\x16` \x85\x01R\x81\x81`@\x1C\x16`@\x85\x01R`H\x1C\x16\x90`\x05\x82\x10\x15a\x06\x94W`\x02\x91``\x84\x01R\x01T`\x80\x82\x01RQ\x80\x15a6\x9DWa6\x96`\x01`\x01`@\x1B\x03\x91Ba.\x80V[\x91Q\x16\x11\x90V[PP_\x90V[`\x01`\x01`@\x1B\x03\x90a6\xB4a+\x86V[P\x16_R`\x02` R`@_ `@Q\x90a6\xCE\x82a'dV[T`\x01`\x01`@\x1B\x03\x81\x16\x80\x83R`\xFF\x82`@\x1C\x16\x90`\xFF` \x85\x01\x93\x83\x85R`H\x1C\x16\x15\x15`@\x85\x01R\x15a7\x0FW[\x15a7\x08WP\x90V[`\x03\x90R\x90V[a\x01,\x83Ra6\xFFV[_T`\x01`\x01`\xA0\x1B\x03\x163\x03a\x14hWV[\x90\x92\x93\x91`\x01`\x01`@\x1B\x03\x82\x16\x95\x86_R`\x03` R`@_ `\x01\x80`\xA0\x1B\x03\x83\x16_R` R`@_ \x94a7c\x84a6\xA3V[\x90`\x01\x87\x01\x94`\xFF\x86T`H\x1C\x16`\x05\x81\x10\x15a\x06\x94W`\x03\x14a:\xD5W_\x8A\x81R`\x05` R`@\x90 `\x01`\x01`\xA0\x1B\x03\x86\x16\x99\x90a7\xA5\x90\x8B\x90a;%V[P`\xFF\x87T`H\x1C\x16\x98B\x81U`\x02a7\xBF6\x88\x8Ca)\xA3V[` \x81Q\x91\x01 \x91\x01U`\xFF`@\x1B\x19\x87T\x16\x87U`\x01`\x01`@\x1B\x03\x87T\x16\x90`\x01`\x01`@\x1B\x03\x82\x14a\x06\x80W`\x01`\x01`@\x1B\x03`\x01`\xFF\x93\x01\x16`\x01`\x01`@\x1B\x03\x19\x89T\x16\x17\x88U\x16\x93\x84\x15_\x14a9\xC3W_\x97[`\x05\x89\x10\x15\x97\x88a\x06\x94W\x80T`\xFF`H\x1B\x19\x16`H\x8B\x90\x1B`\xFF`H\x1B\x16\x17\x90U`\x05\x8A\x10\x15a\x06\x94W\x8A\x96\x8C\x95`\x02\x8C\x14\x8B\x81a9\xB4W[P\x92`@\x95\x92\x86`\x01`\x01`@\x1B\x03\x96\x93\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x99\x96a9tW[\x01Q\x15\x15\x80a9kW[a9YW[PPPP\x82Q\x95\x86RB` \x87\x01R\x16\x93\xA4a\x06\x94W\x82\x91\x84\x91\x80\x82\x03a9$W[PP`\x0BT`\x01`\x01`\xA0\x1B\x03\x16\x93\x91P\x83\x90Pa8\xDAWPPPV[\x82;\x15a\x03kW`d_\x92\x83`@Q\x95\x86\x94\x85\x93cj<)\xDB`\xE1\x1B\x85R`\x04\x85\x01R`$\x84\x01R`\x01`\x01`@\x1B\x03B\x16`D\x84\x01RZ\xF1a9\x1AWPV[_a'\xF3\x91a'\x9AV[_\x80Q` a?h\x839\x81Q\x91R\x91a9O`@\x92a9E\x84Q\x80\x94a)\x18V[` \x83\x01\x90a)\x18V[\xA3\x80\x82_\x80a8\xBDV[a9b\x93a;\x88V[_\x80\x80\x80a8\x9BV[P\x82\x15\x15a8\x96V[\x8A_R`\x04` Ra9\x88\x8D\x83_ a;%V[P\x8C\x8B\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C_\x80\xA3a8\x8CV[_\x9BP`\x02\x14\x15\x90P\x8Ba8SV[`d\x85\x10\x15a9\xD4W`\x01\x97a8\x19V[`\x01\x97`\xC8\x86\x10a8\x19W`\x01`\x01`@\x1B\x03B\x16\x8C_R`\x0C` R`@_ \x8C_R` R`\x01`\x01`@\x1B\x03`@_ T\x16\x80\x15\x90\x81\x15a:\xAEW[Pa:\x1FW[Pa8\x19V[\x8C_R`\x0C` R`@_ \x8C_R` R`\x01`\x01`@\x1B\x03`@_ \x91\x16`\x01`\x01`@\x1B\x03\x19\x82T\x16\x17\x90U\x8A\x8C\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91```@Q` \x81R`\x1B` \x82\x01R\x7FProtocol violation reported\0\0\0\0\0`@\x82\x01R\xA3_a:\x19V[\x90P\x81\x03`\x01`\x01`@\x1B\x03\x81\x11a\x06\x80W`\x01`\x01`@\x1B\x03a\x0E\x10\x91\x16\x10\x15_a:\x13V[`@QbF\x1B\xCD`\xE5\x1B\x81R` `\x04\x82\x01R`\x13`$\x82\x01Rr\x13\xDC\x19\\\x98]\x1B\xDC\x88\x1A\\\xC8\x1C\xDB\x18\\\xDA\x19Y`j\x1B`D\x82\x01R`d\x90\xFD[\x80T\x82\x10\x15a&\xE2W_R` _ \x01\x90_\x90V[_\x82\x81R`\x01\x82\x01` R`@\x90 Ta6\x9DW\x80T\x90`\x01`@\x1B\x82\x10\x15a\x109W\x82a;sa;]\x84`\x01\x80\x96\x01\x85U\x84a;\x10V[\x81\x93\x91T\x90`\x03\x1B\x91\x82\x1B\x91_\x19\x90\x1B\x19\x16\x17\x90V[\x90U\x80T\x92_R\x01` R`@_ U`\x01\x90V[\x91\x90\x92\x80\x15a=\x80Wa\xC3P\x81\x11a=\x80W`@Qc1\xE3\xBD\x1B`\xE0\x1B\x81R` `\x04\x82\x01R\x91_\x91\x83\x91\x82\x91a;\xC4\x91`$\x84\x01\x91\x90a2\xD8V[\x03\x810Z\xFA_\x91\x81a<UW[Pa;\xDBWPPPV[\x80Q`2\x81\x11\x15a<OWP`2\x91[0;\x15a\x03kW`@Qc2\xD3I\xB7`\xE1\x1B\x81R`\x01`\x01`@\x1B\x03\x91\x90\x91\x16`\x04\x82\x01R`\x01`\x01`\xA0\x1B\x03\x90\x93\x16`$\x84\x01R`\x80`D\x84\x01R_\x91\x83\x91\x82\x91\x90a<<\x90`\x84\x84\x01\x90a(\xACV[\x90`d\x83\x01R\x03\x81\x830Z\xF1a9\x1AWPV[\x91a;\xEBV[\x90\x91P=\x80_\x83>a<g\x81\x83a'\x9AV[\x81\x01\x90` \x81\x83\x03\x12a\x03kW\x80Q\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03kW\x01\x90\x80`\x1F\x83\x01\x12\x15a\x03kW\x81Q\x91a<\x9E\x83a)qV[\x92a<\xAC`@Q\x94\x85a'\x9AV[\x80\x84R` \x80\x85\x01\x91`\x05\x1B\x83\x01\x01\x91\x83\x83\x11a\x03kW` \x81\x01\x91[\x83\x83\x10a<\xDCWPPPPP\x90_a;\xD1V[\x82Q`\x01`\x01`@\x1B\x03\x81\x11a\x03kW\x82\x01\x90`@\x82\x87\x03`\x1F\x19\x01\x12a\x03kW`@Q\x90a=\n\x82a'\x7FV[` \x83\x01Q`\x01`\x01`@\x1B\x03\x81\x11a\x03kW` \x90\x84\x01\x01\x91\x87`\x1F\x84\x01\x12\x15a\x03kW\x82Q\x92a=;\x84a)\x88V[\x94a=I`@Q\x96\x87a'\x9AV[\x84\x86R\x89` \x86\x84\x01\x01\x11a\x03kW` \x95_\x87\x87\x81\x98\x82`@\x97\x01\x83\x86\x01^\x83\x01\x01R\x83R\x01Q\x83\x82\x01R\x81R\x01\x92\x01\x91a<\xC9V[PPPPV[\x90`\x01\x82\x01\x91\x81_R\x82` R`@_ T\x80\x15\x15_\x14a>CW_\x19\x81\x01\x81\x81\x11a\x06\x80W\x82T_\x19\x81\x01\x91\x90\x82\x11a\x06\x80W\x81\x81\x03a>\x0EW[PPP\x80T\x80\x15a=\xFAW_\x19\x01\x90a=\xDB\x82\x82a;\x10V[\x81T\x90_\x19\x90`\x03\x1B\x1B\x19\x16\x90UU_R` R_`@\x81 U`\x01\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[a>.a>\x1Ea;]\x93\x86a;\x10V[\x90T\x90`\x03\x1B\x1C\x92\x83\x92\x86a;\x10V[\x90U_R\x83` R`@_ U_\x80\x80a=\xC2V[PPPP_\x90V[\x81Q\x91\x90`A\x83\x03a>{Wa>t\x92P` \x82\x01Q\x90```@\x84\x01Q\x93\x01Q_\x1A\x90a>\xE5V[\x91\x92\x90\x91\x90V[PP_\x91`\x02\x91\x90V[`\x04\x81\x10\x15a\x06\x94W\x80a>\x97WPPV[`\x01\x81\x03a>\xAEWc\xF6E\xEE\xDF`\xE0\x1B_R`\x04_\xFD[`\x02\x81\x03a>\xC9WPc\xFC\xE6\x98\xF7`\xE0\x1B_R`\x04R`$_\xFD[`\x03\x14a>\xD3WPV[c5\xE2\xF3\x83`\xE2\x1B_R`\x04R`$_\xFD[\x91\x90\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0\x84\x11a?\\W\x91` \x93`\x80\x92`\xFF_\x95`@Q\x94\x85R\x16\x86\x84\x01R`@\x83\x01R``\x82\x01R\x82\x80R`\x01Z\xFA\x15a\x12\xFFW_Q`\x01`\x01`\xA0\x1B\x03\x81\x16\x15a?RW\x90_\x90_\x90V[P_\x90`\x01\x90_\x90V[PPP_\x91`\x03\x91\x90V\xFE\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\xA1dsolcC\0\x08\x1A\0\n",
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
    /**Function with signature `submitHeartbeat(uint64,uint64,uint8,bytes,bytes)` and selector `0xd413a580`.
```solidity
function submitHeartbeat(uint64 serviceId, uint64 blueprintId, uint8 statusCode, bytes memory metrics, bytes memory signature) external;
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
        pub signature: alloy::sol_types::private::Bytes,
    }
    ///Container type for the return parameters of the [`submitHeartbeat(uint64,uint64,uint8,bytes,bytes)`](submitHeartbeatCall) function.
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
                alloy::sol_types::sol_data::Bytes,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                u64,
                u8,
                alloy::sol_types::private::Bytes,
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
                        signature: tuple.4,
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
            const SIGNATURE: &'static str = "submitHeartbeat(uint64,uint64,uint8,bytes,bytes)";
            const SELECTOR: [u8; 4] = [212u8, 19u8, 165u8, 128u8];
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
            [44u8, 149u8, 118u8, 136u8],
            [45u8, 174u8, 24u8, 133u8],
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
            [212u8, 19u8, 165u8, 128u8],
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
            ::core::stringify!(DEFAULT_HEARTBEAT_INTERVAL),
            ::core::stringify!(metricsRecorder),
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
            ::core::stringify!(submitHeartbeat),
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
            <DEFAULT_HEARTBEAT_INTERVALCall as alloy_sol_types::SolCall>::SIGNATURE,
            <metricsRecorderCall as alloy_sol_types::SolCall>::SIGNATURE,
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
            <submitHeartbeatCall as alloy_sol_types::SolCall>::SIGNATURE,
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
        const COUNT: usize = 55usize;
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
            [215u8, 139u8, 206u8, 12u8],
            [246u8, 69u8, 238u8, 223u8],
            [252u8, 230u8, 152u8, 247u8],
        ];
        /// The names of the variants in the same order as `SELECTORS`.
        pub const VARIANT_NAMES: &'static [&'static str] = &[
            ::core::stringify!(OwnableUnauthorizedAccount),
            ::core::stringify!(OwnableInvalidOwner),
            ::core::stringify!(ECDSAInvalidSignatureS),
            ::core::stringify!(ECDSAInvalidSignature),
            ::core::stringify!(ECDSAInvalidSignatureLength),
        ];
        /// The signatures in the same order as `SELECTORS`.
        pub const SIGNATURES: &'static [&'static str] = &[
            <OwnableUnauthorizedAccount as alloy_sol_types::SolError>::SIGNATURE,
            <OwnableInvalidOwner as alloy_sol_types::SolError>::SIGNATURE,
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
        const COUNT: usize = 5usize;
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
            signature: alloy::sol_types::private::Bytes,
        ) -> alloy_contract::SolCallBuilder<&P, submitHeartbeatCall, N> {
            self.call_builder(
                &submitHeartbeatCall {
                    serviceId,
                    blueprintId,
                    statusCode,
                    metrics,
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
