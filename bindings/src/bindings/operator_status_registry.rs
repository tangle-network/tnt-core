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
    ///0x60c0604052346100655761001a610014610139565b90610216565b61002261006a565b617ab96104d38239608051818181610edf015261388d015260a051818181611460015281816126cd015281816133ad015281816156a501526162620152617ab990f35b610070565b60405190565b5f80fd5b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b9061009c90610074565b810190811060018060401b038211176100b457604052565b61007e565b906100cc6100c561006a565b9283610092565b565b5f80fd5b60018060a01b031690565b6100e6906100d2565b90565b6100f2816100dd565b036100f957565b5f80fd5b9050519061010a826100e9565b565b91906040838203126101345780610128610131925f86016100fd565b936020016100fd565b90565b6100ce565b610157617f8c8038038061014c816100b9565b92833981019061010c565b9091565b90565b61017261016d610177926100d2565b61015b565b6100d2565b90565b6101839061015e565b90565b61018f9061017a565b90565b90565b61019e90610192565b9052565b90565b6101ae906101a2565b9052565b6101bb906100dd565b9052565b9095949261020a946101f9610203926101ef6080966101e560a088019c5f890190610195565b6020870190610195565b6040850190610195565b60608301906101a5565b01906101b2565b565b60200190565b5190565b90610220906102d3565b60a0527f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f6102bb7f36ffc258c865193ae10c3cf640450ab772fdb8da1dfcae7862ad1205a5567f4c916102ac7fc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc64661029730610186565b916102a061006a565b968795602087016101bf565b60208201810382520382610092565b6102cd6102c782610212565b9161020c565b20608052565b6102dc9061031e565b565b90565b6102f56102f06102fa926102de565b61015b565b6100d2565b90565b610306906102e1565b90565b919061031c905f602085019401906101b2565b565b8061033961033361032e5f6102fd565b6100dd565b916100dd565b1461034957610347906103e7565b565b61036c6103555f6102fd565b5f918291631e4fbdf760e01b835260048301610309565b0390fd5b1b90565b9190600861039491029161038e60018060a01b0384610370565b92610370565b9181191691161790565b6103a79061017a565b90565b90565b91906103c36103be6103cb9361039e565b6103aa565b908354610374565b9055565b5f90565b6103e5916103df6103cf565b916103ad565b565b6103fb906103f65f60016103d3565b610473565b565b5f1c90565b60018060a01b031690565b61041961041e916103fd565b610402565b90565b61042b905461040d565b90565b5f1b90565b9061044460018060a01b039161042e565b9181191691161790565b9061046361045e61046a9261039e565b6103aa565b8254610433565b9055565b5f0190565b61047c5f610421565b610486825f61044e565b906104ba6104b47f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09361039e565b9161039e565b916104c361006a565b806104cd8161046e565b0390a356fe60806040526004361015610013575b612523565b61001d5f3561039c565b806305778550146103975780630758236f146103925780630c76697a1461038d578063191cbd1a146103885780631e8f5ee514610383578063208129561461037e57806322f1ec93146103795780632bf4d6a7146103745780632c9576881461036f5780632dae18851461036a5780632f4bd7b81461036557806331e3bd1b146103605780633644e5151461035b5780633ac3cbe6146103565780633e6e34a7146103515780633fd62c6d1461034c57806340235a9c1461034757806348f4da20146103425780635685cf681461033d57806356c4e17d1461033857806359dcea12146103335780635a936dc61461032e5780635cce98a6146103295780636076439c1461032457806360cf09911461031f57806361d6b86c1461031a57806362c7e8fc1461031557806365a6936e146103105780636bfe06a61461030b578063715018a61461030657806371e7388c146103015780637639d227146102fc57806379ba5097146102f75780637b9f64b2146102f257806381beac2e146102ed57806384ef7322146102e85780638da5cb5b146102e357806396686c1e146102de5780639cbdae22146102d9578063adff830c146102d4578063ae470a85146102cf578063b074e9dd146102ca578063b99f6759146102c5578063ba1fb103146102c0578063c1ef9ddf146102bb578063c5d960bb146102b6578063cfe34749146102b1578063d551162c146102ac578063da435a7c146102a7578063e30c3978146102a2578063e65cafcb1461029d578063ee1c039014610298578063f2fde38b14610293578063f9107f3b1461028e578063f9f16762146102895763ffcf08f00361000e576124ef565b6124ba565b612457565b6123f7565b6123c1565b61238d565b612358565b612320565b61224e565b612219565b6121d7565b6121a2565b612078565b612044565b611fd7565b611f9d565b611ed2565b611e0b565b611c82565b611bc8565b611b95565b611b5e565b611ac9565b611a96565b611a60565b611a2a565b61196e565b611939565b6118cb565b611686565b61163c565b6115ba565b611585565b611517565b611482565b611429565b6113f4565b61138f565b611345565b6112d9565b611205565b6111cb565b610f93565b610f26565b610ea7565b610d2c565b610cde565b610c43565b610b9d565b610a6a565b6106c6565b610674565b610640565b610579565b61051f565b610450565b60e01c90565b60405190565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff1690565b6103ca816103b4565b036103d157565b5f80fd5b905035906103e2826103c1565b565b60018060a01b031690565b6103f8906103e4565b90565b610404816103ef565b0361040b57565b5f80fd5b9050359061041c826103fb565b565b9190604083820312610446578061043a610443925f86016103d5565b9360200161040f565b90565b6103ac565b5f0190565b3461047f5761046961046336600461041e565b906126ba565b6104716103a2565b8061047b8161044b565b0390f35b6103a8565b9060208282031261049d5761049a915f016103d5565b90565b6103ac565b6104ab906103b4565b9052565b60ff1690565b6104be906104af565b9052565b151590565b6104d0906104c2565b9052565b90604080610508936104ec5f8201515f8601906104a2565b6104fe602082015160208601906104b5565b01519101906104c7565b565b919061051d905f606085019401906104d4565b565b3461054f5761054b61053a610535366004610484565b612799565b6105426103a2565b9182918261050a565b0390f35b6103a8565b90565b61056090610554565b9052565b9190610577905f60208501940190610557565b565b346105aa576105a661059561058f36600461041e565b906127b2565b61059d6103a2565b91829182610564565b0390f35b6103a8565b5f80fd5b5f80fd5b5f80fd5b909182601f830112156105f55781359167ffffffffffffffff83116105f05760200192602083028401116105eb57565b6105b7565b6105b3565b6105af565b91909160408184031261063b57610613835f83016103d5565b92602082013567ffffffffffffffff81116106365761063292016105bb565b9091565b6103b0565b6103ac565b3461066f576106596106533660046105fa565b9161313b565b6106616103a2565b8061066b8161044b565b0390f35b6103a8565b346106a35761068d61068736600461041e565b906133a1565b6106956103a2565b8061069f8161044b565b0390f35b6103a8565b906020828203126106c1576106be915f0161040f565b90565b6103ac565b346106f4576106de6106d93660046106a8565b6134b7565b6106e66103a2565b806106f08161044b565b0390f35b6103a8565b61070281610554565b0361070957565b5f80fd5b9050359061071a826106f9565b565b91906040838203126107445780610738610741925f86016103d5565b9360200161070d565b90565b6103ac565b90565b61076061075b610765926103b4565b610749565b6103b4565b90565b906107729061074c565b5f5260205260405f2090565b634e487b7160e01b5f52603260045260245ffd5b5490565b5f5260205f2090565b5f5260205f2090565b6107b181610792565b8210156107cb576107c3600491610796565b910201905f90565b61077e565b634e487b7160e01b5f52602260045260245ffd5b9060016002830492168015610804575b60208310146107ff57565b6107d0565b91607f16916107f4565b60209181520190565b5f5260205f2090565b905f929180549061083a610833836107e4565b809461080e565b916001811690815f146108915750600114610855575b505050565b6108629192939450610817565b915f925b81841061087957505001905f8080610850565b60018160209295939554848601520191019290610866565b92949550505060ff19168252151560200201905f8080610850565b906108b691610820565b90565b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b906108e1906108b9565b810190811067ffffffffffffffff8211176108fb57604052565b6108c3565b90610920610919926109106103a2565b938480926108ac565b03836108d7565b565b5f1c90565b90565b61093661093b91610922565b610927565b90565b610948905461092a565b90565b60ff1690565b61095d61096291610922565b61094b565b90565b61096f9054610951565b90565b61097d906008610768565b9061098782610792565b8110156109cd57610997916107a8565b50906109a45f8301610900565b916109b16001820161093e565b916109ca60036109c36002850161093e565b9301610965565b90565b5f80fd5b5190565b60209181520190565b90825f9392825e0152565b610a08610a11602093610a16936109ff816109d1565b938480936109d5565b958691016109de565b6108b9565b0190565b610a23906104c2565b9052565b610a61610a6894610a57610a4c6060959998969960808601908682035f8801526109e9565b986020850190610557565b6040830190610557565b0190610a1a565b565b34610a9f57610a9b610a86610a8036600461071c565b90610972565b90610a929492946103a2565b94859485610a27565b0390f35b6103a8565b610aad816104af565b03610ab457565b5f80fd5b90503590610ac582610aa4565b565b909182601f83011215610b015781359167ffffffffffffffff8311610afc576020019260018302840111610af757565b6105b7565b6105b3565b6105af565b919060c083820312610b9857610b1e815f85016103d5565b92610b2c82602083016103d5565b92610b3a8360408401610ab8565b92606083013567ffffffffffffffff8111610b935781610b5b918501610ac7565b929093610b6b83608083016103d5565b9260a082013567ffffffffffffffff8111610b8e57610b8a9201610ac7565b9091565b6103b0565b6103b0565b6103ac565b34610bd557610bbf610bb0366004610b06565b96959095949194939293613966565b610bc76103a2565b80610bd18161044b565b0390f35b6103a8565b5f910312610be457565b6103ac565b90565b610c00610bfb610c0592610be9565b610749565b6103b4565b90565b610c1361012c610bec565b90565b610c1e610c08565b90565b610c2a906103b4565b9052565b9190610c41905f60208501940190610c21565b565b34610c7357610c53366004610bda565b610c6f610c5e610c16565b610c666103a2565b91829182610c2e565b0390f35b6103a8565b1c90565b60018060a01b031690565b610c97906008610c9c9302610c78565b610c7c565b90565b90610caa9154610c87565b90565b610cb9600b5f90610c9f565b90565b610cc5906103ef565b9052565b9190610cdc905f60208501940190610cbc565b565b34610d0e57610cee366004610bda565b610d0a610cf9610cad565b610d016103a2565b91829182610cc9565b0390f35b6103a8565b610d1e61012c610bec565b90565b610d29610d13565b90565b34610d5c57610d3c366004610bda565b610d58610d47610d21565b610d4f6103a2565b91829182610c2e565b0390f35b6103a8565b90602082820312610d92575f82013567ffffffffffffffff8111610d8d57610d899201610ac7565b9091565b6103b0565b6103ac565b5190565b60209181520190565b60200190565b610dc9610dd2602093610dd793610dc0816109d1565b9384809361080e565b958691016109de565b6108b9565b0190565b610de490610554565b9052565b90610e1290602080610e07604084015f8701518582035f870152610daa565b940151910190610ddb565b90565b90610e1f91610de8565b90565b60200190565b90610e3c610e3583610d97565b8092610d9b565b9081610e4d60208302840194610da4565b925f915b838310610e6057505050505090565b90919293946020610e82610e7c83856001950387528951610e15565b97610e22565b9301930191939290610e51565b610ea49160208201915f818403910152610e28565b90565b34610ed857610ed4610ec3610ebd366004610d61565b906139b2565b610ecb6103a2565b91829182610e8f565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b90565b610f0d90610f01565b9052565b9190610f24905f60208501940190610f04565b565b34610f5657610f36366004610bda565b610f52610f41610edd565b610f496103a2565b91829182610f11565b0390f35b6103a8565b90565b610f72610f6d610f7792610f5b565b610749565b6103b4565b90565b610f85610e10610f5e565b90565b610f90610f7a565b90565b34610fc357610fa3366004610bda565b610fbf610fae610f88565b610fb66103a2565b91829182610c2e565b0390f35b6103a8565b90610fd29061074c565b5f5260205260405f2090565b610ff2610fed610ff7926103e4565b610749565b6103e4565b90565b61100390610fde565b90565b61100f90610ffa565b90565b9061101c90611006565b5f5260205260405f2090565b67ffffffffffffffff1690565b61104161104691610922565b611028565b90565b6110539054611035565b90565b60401c90565b60ff1690565b61106e61107391611056565b61105c565b90565b6110809054611062565b90565b60481c90565b60ff1690565b61109b6110a091611083565b611089565b90565b6110ad905461108f565b90565b90565b6110bf6110c491610922565b6110b0565b90565b6110d190546110b3565b90565b906110e36110e8926003610fc8565b611012565b6110f35f820161093e565b9161110060018301611049565b9161110d60018201611076565b91611126600261111f600185016110a3565b93016110c7565b90565b611132906104af565b9052565b634e487b7160e01b5f52602160045260245ffd5b6005111561115457565b611136565b906111638261114a565b565b61116e90611159565b90565b61117a90611165565b9052565b909594926111c9946111b86111c2926111ae6080966111a460a088019c5f890190610557565b6020870190610c21565b6040850190611129565b6060830190611171565b0190610f04565b565b34611200576111fc6111e76111e136600461041e565b906110d4565b916111f39593956103a2565b9586958661117e565b0390f35b6103a8565b346112355761123161122061121b366004610484565b6139cc565b6112286103a2565b91829182610564565b0390f35b6103a8565b5190565b60209181520190565b60200190565b611256906103ef565b9052565b906112678160209361124d565b0190565b60200190565b9061128e6112886112818461123a565b809361123e565b92611247565b905f5b81811061129e5750505090565b9091926112b76112b1600192865161125a565b9461126b565b9101919091611291565b6112d69160208201915f818403910152611271565b90565b34611309576113056112f46112ef366004610484565b613a86565b6112fc6103a2565b918291826112c1565b0390f35b6103a8565b90565b61132561132061132a9261130e565b610749565b610554565b90565b61133760c8611311565b90565b61134261132d565b90565b3461137557611355366004610bda565b61137161136061133a565b6113686103a2565b91829182610564565b0390f35b6103a8565b919061138d905f60208501940190610a1a565b565b346113c0576113bc6113ab6113a536600461041e565b90613b26565b6113b36103a2565b9182918261137a565b0390f35b6103a8565b906113cf9061074c565b5f5260205260405f2090565b6113f1906113ec6007915f926113c5565b610c9f565b90565b346114245761142061140f61140a366004610484565b6113db565b6114176103a2565b91829182610cc9565b0390f35b6103a8565b346114595761145561144461143f366004610484565b613bad565b61144c6103a2565b918291826112c1565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b346114b257611492366004610bda565b6114ae61149d61145e565b6114a56103a2565b91829182610cc9565b0390f35b6103a8565b90608082820312611512576114ce815f84016103d5565b926114dc82602085016103d5565b926114ea8360408301610ab8565b92606082013567ffffffffffffffff811161150d576115099201610ac7565b9091565b6103b0565b6103ac565b346115495761153361152a3660046114b7565b93929092613c1f565b61153b6103a2565b806115458161044b565b0390f35b6103a8565b90565b61156561156061156a9261154e565b610749565b610554565b90565b6115776032611551565b90565b61158261156d565b90565b346115b557611595366004610bda565b6115b16115a061157a565b6115a86103a2565b91829182610564565b0390f35b6103a8565b346115eb576115e76115d66115d036600461041e565b90613c2e565b6115de6103a2565b9182918261137a565b0390f35b6103a8565b90565b61160761160261160c926115f0565b610749565b6104af565b90565b61161960036115f3565b90565b61162461160f565b90565b919061163a905f60208501940190611129565b565b3461166c5761164c366004610bda565b61166861165761161c565b61165f6103a2565b91829182611627565b0390f35b6103a8565b9190611684905f60208501940190611171565b565b346116b7576116b36116a261169c36600461041e565b90613c5a565b6116aa6103a2565b91829182611671565b0390f35b6103a8565b906116cf6116c86103a2565b92836108d7565b565b67ffffffffffffffff81116116e95760208091020190565b6108c3565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff8111611718576117146020916108b9565b0190565b6108c3565b90825f939282370152565b9092919261173d611738826116fa565b6116bc565b93818552602085019082840111611759576117579261171d565b565b6116f6565b9080601f8301121561177c5781602061177993359101611728565b90565b6105af565b9190916040818403126117d45761179860406116bc565b925f8201359167ffffffffffffffff83116117cf576117bc826117c894830161175e565b5f86015260200161070d565b6020830152565b6116f2565b6116ee565b9291906117ed6117e8826116d1565b6116bc565b93818552602080860192028101918383116118445781905b838210611813575050505050565b813567ffffffffffffffff811161183f576020916118348784938701611781565b815201910190611805565b6105af565b6105b7565b9080601f8301121561186757816020611864933591016117d9565b90565b6105af565b6080818303126118c657611882825f83016103d5565b92611890836020840161040f565b9260408301359067ffffffffffffffff82116118c1576118b5816118be938601611849565b9360600161070d565b90565b6103b0565b6103ac565b346118fd576118e76118de36600461186c565b92919091614040565b6118ef6103a2565b806118f98161044b565b0390f35b6103a8565b90565b61191961191461191e92611902565b610749565b610554565b90565b61192b6040611905565b90565b611936611921565b90565b3461196957611949366004610bda565b61196561195461192e565b61195c6103a2565b91829182610564565b0390f35b6103a8565b3461199c5761197e366004610bda565b61198661466f565b61198e6103a2565b806119988161044b565b0390f35b6103a8565b6119aa90611165565b9052565b6119b790610f01565b9052565b90608080611a13936119d35f8201515f860190610ddb565b6119e5602082015160208601906104a2565b6119f7604082015160408601906104b5565b611a09606082015160608601906119a1565b01519101906119ae565b565b9190611a28905f60a085019401906119bb565b565b34611a5b57611a57611a46611a4036600461041e565b906147ac565b611a4e6103a2565b91829182611a15565b0390f35b6103a8565b34611a9157611a8d611a7c611a7636600461041e565b90614804565b611a846103a2565b91829182610c2e565b0390f35b6103a8565b34611ac457611aa6366004610bda565b611aae61482c565b611ab66103a2565b80611ac08161044b565b0390f35b6103a8565b34611af957611af5611ae4611adf366004610484565b61487d565b611aec6103a2565b91829182610564565b0390f35b6103a8565b9091606082840312611b3357611b30611b19845f85016103d5565b93611b27816020860161070d565b9360400161070d565b90565b6103ac565b92916020611b54611b5c9360408701908782035f890152611271565b940190610557565b565b34611b9057611b77611b71366004611afe565b9161491b565b90611b8c611b836103a2565b92839283611b38565b0390f35b6103a8565b34611bc357611bad611ba83660046106a8565b614aa2565b611bb56103a2565b80611bbf8161044b565b0390f35b6103a8565b34611bf857611bd8366004610bda565b611bf4611be3614ab1565b611beb6103a2565b91829182610cc9565b0390f35b6103a8565b909182601f83011215611c375781359167ffffffffffffffff8311611c32576020019260208302840111611c2d57565b6105b7565b6105b3565b6105af565b919091604081840312611c7d57611c55835f83016103d5565b92602082013567ffffffffffffffff8111611c7857611c749201611bfd565b9091565b6103b0565b6103ac565b34611cb157611c9b611c95366004611c3c565b91614b38565b611ca36103a2565b80611cad8161044b565b0390f35b6103a8565b91606083830312611d0257611ccd825f85016103d5565b92611cdb836020830161040f565b92604082013567ffffffffffffffff8111611cfd57611cfa920161175e565b90565b6103b0565b6103ac565b90611d119061074c565b5f5260205260405f2090565b90611d2790611006565b5f5260205260405f2090565b905090565b611d5d611d5492602092611d4b816109d1565b94858093611d33565b938491016109de565b0190565b90565b611d70611d7591610554565b611d61565b9052565b611d89611d909160209493611d38565b8092611d64565b0190565b611da8611d9f6103a2565b92839283611d79565b03902090565b611db791611d94565b90565b611dca906008611dcf9302610c78565b610927565b90565b90611ddd9154611dba565b90565b90611e0892611dfe611e0392611df96009955f96611d07565b611d1d565b611dae565b611dd2565b90565b34611e3c57611e38611e27611e21366004611cb6565b91611de0565b611e2f6103a2565b91829182610564565b0390f35b6103a8565b909182601f83011215611e7b5781359167ffffffffffffffff8311611e76576020019260018302840111611e7157565b6105b7565b6105b3565b6105af565b91606083830312611ecd57611e97825f85016103d5565b92611ea5836020830161040f565b92604082013567ffffffffffffffff8111611ec857611ec49201611e41565b9091565b6103b0565b6103ac565b34611f0457611eee611ee5366004611e80565b92919091614d9d565b611ef66103a2565b80611f008161044b565b0390f35b6103a8565b611f12816104c2565b03611f1957565b5f80fd5b90503590611f2a82611f09565b565b91909160a081840312611f9857611f45835f83016103d5565b92602082013567ffffffffffffffff8111611f935781611f66918401611e41565b929093611f90611f79846040850161070d565b93611f87816060860161070d565b93608001611f1d565b90565b6103b0565b6103ac565b34611fd257611fbc611fb0366004611f2c565b94939093929192615072565b611fc46103a2565b80611fce8161044b565b0390f35b6103a8565b3461200557611fef611fea366004610484565b615427565b611ff76103a2565b806120018161044b565b0390f35b6103a8565b909160608284031261203f5761203c612025845f85016103d5565b9361203381602086016103d5565b93604001610ab8565b90565b6103ac565b346120735761205d61205736600461200a565b9161569c565b6120656103a2565b8061206f8161044b565b0390f35b6103a8565b346120a75761209161208b36600461041e565b9061585b565b6120996103a2565b806120a38161044b565b0390f35b6103a8565b5190565b60209181520190565b60200190565b9061210d906060806120de608084015f8701518582035f870152610daa565b946120f160208201516020860190610ddb565b61210360408201516040860190610ddb565b01519101906104c7565b90565b9061211a916120bf565b90565b60200190565b90612137612130836120ac565b80926120b0565b9081612148602083028401946120b9565b925f915b83831061215b57505050505090565b9091929394602061217d61217783856001950387528951612110565b9761211d565b930193019193929061214c565b61219f9160208201915f818403910152612123565b90565b346121d2576121ce6121bd6121b8366004610484565b615bd2565b6121c56103a2565b9182918261218a565b0390f35b6103a8565b34612205576121ef6121ea366004610484565b615d62565b6121f76103a2565b806122018161044b565b0390f35b6103a8565b612216600a5f90610c9f565b90565b3461224957612229366004610bda565b61224561223461220a565b61223c6103a2565b91829182610cc9565b0390f35b6103a8565b346122825761227e61226d612264366004611e80565b92919091615dcf565b6122756103a2565b91829182610564565b0390f35b6103a8565b906122919061074c565b5f5260205260405f2090565b6122a96122ae91611083565b61094b565b90565b6122bb905461229d565b90565b6122c9906002612287565b6122d45f8201611049565b916122eb5f6122e4818501611076565b93016122b1565b90565b60409061231761231e949695939661230d60608401985f850190610c21565b6020830190611129565b0190610a1a565b565b346123535761234f61233b612336366004610484565b6122be565b6123469391936103a2565b938493846122ee565b0390f35b6103a8565b3461238857612368366004610bda565b612384612373615e04565b61237b6103a2565b91829182610cc9565b0390f35b6103a8565b346123bc576123a66123a036600461041e565b90615eee565b6123ae6103a2565b806123b88161044b565b0390f35b6103a8565b346123f2576123ee6123dd6123d736600461041e565b90616083565b6123e56103a2565b9182918261137a565b0390f35b6103a8565b346124255761240f61240a3660046106a8565b616182565b6124176103a2565b806124218161044b565b0390f35b6103a8565b9190604083820312612452578061244661244f925f86016103d5565b93602001611f1d565b90565b6103ac565b346124865761247061246a36600461242a565b9061618d565b6124786103a2565b806124828161044b565b0390f35b6103a8565b7f32721f8dc67e953c540da90f663059c23fc47f70d11e317ed6d5a24c8b85637490565b6124b761248b565b90565b346124ea576124ca366004610bda565b6124e66124d56124af565b6124dd6103a2565b91829182610f11565b0390f35b6103a8565b3461251e5761250861250236600461041e565b90616256565b6125106103a2565b8061251a8161044b565b0390f35b6103a8565b5f80fd5b5f7f4f6e6c792054616e676c6520636f726500000000000000000000000000000000910152565b61255b60106020926109d5565b61256481612527565b0190565b61257d9060208101905f81830391015261254e565b90565b1561258757565b61258f6103a2565b62461bcd60e51b8152806125a560048201612568565b0390fd5b6125b56125ba91610922565b610c7c565b90565b6125c790546125a9565b90565b90565b6125e16125dc6125e6926125ca565b610749565b6103e4565b90565b6125f2906125cd565b90565b5f7f416c726561647920726567697374657265640000000000000000000000000000910152565b61262960126020926109d5565b612632816125f5565b0190565b61264b9060208101905f81830391015261261c565b90565b1561265557565b61265d6103a2565b62461bcd60e51b81528061267360048201612636565b0390fd5b5f1b90565b9061268d60018060a01b0391612677565b9181191691161790565b90565b906126af6126aa6126b692611006565b612697565b825461267c565b9055565b61273c612741926126fd336126f76126f17f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b61273461271461270f600786906113c5565b6125bd565b61272e6127286127235f6125e9565b6103ef565b916103ef565b1461264e565b9160076113c5565b61269a565b565b61274d60606116bc565b90565b5f90565b5f90565b5f90565b612764612743565b906020808084612772612750565b81520161277d612754565b815201612788612758565b81525050565b61279661275c565b90565b6127ab906127a561278e565b5061637e565b90565b5f90565b6127d36127d9926127ce5f936127c66127ae565b506003610fc8565b611012565b0161093e565b90565b5f7f4e6f742073657276696365206f776e6572000000000000000000000000000000910152565b61281060116020926109d5565b612819816127dc565b0190565b6128329060208101905f818303910152612803565b90565b1561283c57565b6128446103a2565b62461bcd60e51b81528061285a6004820161281d565b0390fd5b5090565b5f7f546f6f206d616e7920646566696e6974696f6e73000000000000000000000000910152565b61289660146020926109d5565b61289f81612862565b0190565b6128b89060208101905f818303910152612889565b90565b156128c257565b6128ca6103a2565b62461bcd60e51b8152806128e0600482016128a3565b0390fd5b634e487b7160e01b5f52601160045260245ffd5b61290761290d91939293610554565b92610554565b91612919838202610554565b92818404149015171561292857565b6128e4565b6129389060046128f8565b90565b9061294e905f1990602003600802610c78565b8154169055565b1b90565b9190600861297491029161296e5f1984612955565b92612955565b9181191691161790565b61299261298d61299792610554565b610749565b610554565b90565b90565b91906129b36129ae6129bb9361297e565b61299a565b908354612959565b9055565b6129d1916129cb6127ae565b9161299d565b565b5b8181106129df575050565b806129ec5f6001936129bf565b016129d4565b90612a02905f1990600802610c78565b191690565b81612a11916129f2565b906002021790565b905f91612a30612a2882610817565b928354612a07565b905555565b601f602091010490565b919290602082105f14612a9857601f8411600114612a6857612a62929350612a07565b90555b5b565b5090612a8e612a93936001612a85612a7f85610817565b92612a35565b820191016129d3565b612a19565b612a65565b50612acf8293612aa9600194610817565b612ac8612ab585612a35565b820192601f861680612ada575b50612a35565b01906129d3565b600202179055612a66565b612ae69088860361293b565b5f612ac2565b929091680100000000000000008211612b4c576020115f14612b3d57602081105f14612b2157612b1b91612a07565b90555b5b565b60019160ff1916612b3184610817565b55600202019055612b1e565b60019150600202019055612b1f565b6108c3565b908154612b5d816107e4565b90818311612b86575b818310612b74575b50505050565b612b7d93612a3f565b5f808080612b6e565b612b9283838387612aec565b612b66565b5f612ba191612b51565b565b634e487b7160e01b5f525f60045260245ffd5b905f03612bc857612bc690612b97565b565b612ba3565b60035f91612bdd83808301612bb6565b612bea83600183016129bf565b612bf783600283016129bf565b0155565b905f03612c0d57612c0b90612bcd565b565b612ba3565b5b818110612c1e575050565b80612c2b5f600493612bfb565b01612c13565b9091828110612c40575b505050565b612c5e612c58612c52612c699561292d565b9261292d565b92610796565b918201910190612c12565b5f8080612c3b565b90680100000000000000008111612c9a5781612c8f612c9893610792565b90828155612c31565b565b6108c3565b5f612ca991612c71565b565b905f03612cbd57612cbb90612c9f565b565b612ba3565b612cd6612cd1612cdb926125ca565b610749565b610554565b90565b6001612cea9101610554565b90565b5f80fd5b5f80fd5b5f80fd5b903590600160800381360303821215612d10570190565b612ced565b90821015612d2f576020612d2c9202810190612cf9565b90565b61077e565b903590600160200381360303821215612d76570180359067ffffffffffffffff8211612d7157602001916001820236038313612d6c57565b612cf5565b612cf1565b612ced565b91565b5090565b5f7f4e616d6520746f6f206c6f6e6700000000000000000000000000000000000000910152565b612db6600d6020926109d5565b612dbf81612d82565b0190565b612dd89060208101905f818303910152612da9565b90565b15612de257565b612dea6103a2565b62461bcd60e51b815280612e0060048201612dc3565b0390fd5b35612e0e816106f9565b90565b5f7f496e76616c696420626f756e6473000000000000000000000000000000000000910152565b612e45600e6020926109d5565b612e4e81612e11565b0190565b612e679060208101905f818303910152612e38565b90565b15612e7157565b612e796103a2565b62461bcd60e51b815280612e8f60048201612e52565b0390fd5b90565b5f5260205f2090565b5490565b612eac81612e9f565b821015612ec657612ebe600491612e96565b910201905f90565b61077e565b5090565b9190601f8111612edf575b505050565b612eeb612f1093610817565b906020612ef784612a35565b83019310612f18575b612f0990612a35565b01906129d3565b5f8080612eda565b9150612f0981929050612f00565b91612f319082612ecb565b9067ffffffffffffffff8211612ff057612f5582612f4f85546107e4565b85612ecf565b5f90601f8311600114612f8857918091612f77935f92612f7c575b5050612a07565b90555b565b90915001355f80612f70565b601f19831691612f9785610817565b925f5b818110612fd857509160029391856001969410612fbe575b50505002019055612f7a565b612fce910135601f8416906129f2565b90555f8080612fb2565b91936020600181928787013581550195019201612f9a565b6108c3565b906130009291612f26565b565b9061300e5f1991612677565b9181191691161790565b9061302d6130286130349261297e565b61299a565b8254613002565b9055565b3561304281611f09565b90565b9061305160ff91612677565b9181191691161790565b613064906104c2565b90565b90565b9061307f61307a6130869261305b565b613067565b8254613045565b9055565b906130e8606060036130ee946130ae5f82016130a85f880188612d34565b91612ff5565b6130c7600182016130c160208801612e04565b90613018565b6130e0600282016130da60408801612e04565b90613018565b019201613038565b9061306a565b565b9190613101576130ff9161308a565b565b612ba3565b9081549168010000000000000000831015613136578261312e91600161313495018155612ea3565b906130f0565b565b6108c3565b9291909261316e3361316861316261315d613158600787906113c5565b6125bd565b6103ef565b916103ef565b14612835565b61319c61317c85849061285e565b61319561318f61318a61156d565b610554565b91610554565b11156128bb565b6131b15f6131ac60088490610768565b612cab565b6131ba5f612cc2565b5b806131d86131d26131cd88879061285e565b610554565b91610554565b10156132ab576132a69061322f61320f6132096132036131fa8a898791612d15565b5f810190612d34565b90612d7b565b90612d7e565b61322861322261321d611921565b610554565b91610554565b1115612ddb565b613278613249604061324389888691612d15565b01612e04565b61327161326b61326660206132608c8b8991612d15565b01612e04565b610554565b91610554565b1015612e6a565b6132a161328f61328a60088690610768565b612e93565b61329b88878591612d15565b90613106565b612cde565b6131bb565b5050509050565b5f7f5a65726f20616464726573730000000000000000000000000000000000000000910152565b6132e6600c6020926109d5565b6132ef816132b2565b0190565b6133089060208101905f8183039101526132d9565b90565b1561331257565b61331a6103a2565b62461bcd60e51b815280613330600482016132f3565b0390fd5b9061333e9061074c565b5f5260205260405f2090565b90565b60481b90565b9061336869ff0000000000000000009161334d565b9181191691161790565b61337b90611159565b90565b90565b9061339661339161339d92613372565b61337e565b8254613353565b9055565b6133dd336133d76133d17f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b613402826133fb6133f56133f05f6125e9565b6103ef565b916103ef565b141561330b565b61342861342361341c61341760068590613334565b61334a565b849061645c565b61264e565b61344b6002600161344561343e60038690610fc8565b8690611012565b01613381565b9061347f6134797f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b9361074c565b91611006565b916134886103a2565b806134928161044b565b0390a3565b6134a8906134a3616496565b6134aa565b565b6134b590600b61269a565b565b6134c090613497565b565b5f7f4e6f742072656769737465726564206f70657261746f72000000000000000000910152565b6134f660176020926109d5565b6134ff816134c2565b0190565b6135189060208101905f8183039101526134e9565b90565b1561352257565b61352a6103a2565b62461bcd60e51b81528061354060048201613503565b0390fd5b906135799796959493929161357461356f613568613563846006613334565b61334a565b33906164e4565b61351b565b6137ba565b565b61358f61358a613594926103b4565b610749565b610554565b90565b6135ab6135a66135b092610554565b610749565b6103b4565b90565b9160206135d49294936135cd60408201965f830190610c21565b0190610c21565b565b6135e56135eb91939293610554565b92610554565b82039182116135f657565b6128e4565b67ffffffffffffffff8111613619576136156020916108b9565b0190565b6108c3565b9092919261363361362e826135fb565b6116bc565b9381855260208501908284011161364f5761364d9261171d565b565b6116f6565b61365f91369161361e565b90565b60200190565b5190565b949290979695939160e08601985f870161368591610f04565b6020860161369291610cbc565b6040850161369f91610c21565b606084016136ac91610c21565b608083016136b991611129565b60a082016136c691610f04565b60c0016136d291610c21565b565b5f61190160f01b910152565b6136ec60028092611d33565b6136f5816136d4565b0190565b90565b61370861370d91610f01565b6136f9565b9052565b602080939261372c613725613734946136e0565b80926136fc565b0180926136fc565b0190565b5f7f496e76616c6964207369676e6174757265000000000000000000000000000000910152565b61376c60116020926109d5565b61377581613738565b0190565b61378e9060208101905f81830391015261375f565b90565b1561379857565b6137a06103a2565b62461bcd60e51b8152806137b660048201613779565b0390fd5b919293949796909597806137d66137d042610554565b9161357b565b1161393e576137ee426137e88361357b565b906135d6565b6138076138016137fc610d13565b61357b565b91610554565b116139165761391497986138eb61390993856138758a6138668d6138f1988d8d61383d61383261248b565b963399959293613654565b61384f61384982613668565b91613662565b20929361385a6103a2565b9889976020890161366c565b602082018103825203826108d7565b61388761388182613668565b91613662565b206138d27f00000000000000000000000000000000000000000000000000000000000000006138c36138b76103a2565b93849260208401613711565b602082018103825203826108d7565b6138e46138de82613668565b91613662565b2092613654565b9061651e565b6139036138fd336103ef565b916103ef565b14613791565b9333919293946166b5565b565b61391f42613597565b9061393a5f9283926318355b7560e21b8452600484016135b3565b0390fd5b61394742613597565b906139625f9283926357ea02e960e01b8452600484016135b3565b0390fd5b9061397697969594939291613544565b565b606090565b906020828203126139ad575f82013567ffffffffffffffff81116139a8576139a59201611849565b90565b6103b0565b6103ac565b906139c9916139bf613978565b509081019061397d565b90565b6139eb6139e66139f0926139de6127ae565b506005613334565b61334a565b616ac7565b90565b606090565b67ffffffffffffffff8111613a105760208091020190565b6108c3565b90613a27613a22836139f8565b6116bc565b918252565b369037565b90613a56613a3e83613a15565b92602080613a4c86936139f8565b9201910390613a2c565b565b90613a628261123a565b811015613a73576020809102010190565b61077e565b90613a82906103ef565b9052565b90613a8f6139f3565b50613aac613aa7613aa260048590613334565b61334a565b616ac7565b91613ab683613a31565b91613ac05f612cc2565b5b80613ad4613ace87610554565b91610554565b1015613b1b57613b1690613b11613aff613af8613af360048890613334565b61334a565b8390616b16565b613b0c8791849092613a58565b613a78565b612cde565b613ac1565b5092505090565b5f90565b90613b2f613b22565b50613b516001613b4b613b4460038690610fc8565b8490611012565b016110a3565b613b63613b5d5f611159565b91611159565b14918215613b71575b505090565b613b929250600191613b87613b8c926003610fc8565b611012565b016110a3565b613ba5613b9f6001611159565b91611159565b145f80613b6c565b613bd390613bb96139f3565b505f90613bcd613bc761132d565b92612cc2565b9061491b565b5090565b90613c0994939291613c04613bff613bf8613bf3846006613334565b61334a565b33906164e4565b61351b565b613c0b565b565b91613c1d9492939133919293946166b5565b565b90613c2c94939291613bd7565b565b90613c4e613c49613c5393613c41613b22565b506006613334565b61334a565b6164e4565b90565b5f90565b613c7c613c8292613c77600193613c6f613c56565b506003610fc8565b611012565b016110a3565b90565b613c8e90610ffa565b90565b5f7f496e7465726e616c206f6e6c7900000000000000000000000000000000000000910152565b613cc5600d6020926109d5565b613cce81613c91565b0190565b613ce79060208101905f818303910152613cb8565b90565b15613cf157565b613cf96103a2565b62461bcd60e51b815280613d0f60048201613cd2565b0390fd5b67ffffffffffffffff8111613d2b5760208091020190565b6108c3565b90613d42613d3d83613d13565b6116bc565b918252565b369037565b90613d71613d5983613d30565b92602080613d678693613d13565b9201910390613d47565b565b90613d7d82610d97565b811015613d8e576020809102010190565b61077e565b90565b5190565b90613da482613d96565b811015613db5576020809102010190565b61077e565b90613dc490610f01565b9052565b606090565b90565b60209181520190565b905f9291805490613df3613dec836107e4565b8094613dd0565b916001811690815f14613e4a5750600114613e0e575b505050565b613e1b919293945061079f565b915f925b818410613e3257505001905f8080613e09565b60018160209295939554848601520191019290613e1f565b92949550505060ff19168252151560200201905f8080613e09565b90613e6f91613dd9565b90565b90613e92613e8b92613e826103a2565b93848092613e65565b03836108d7565b565b613e9d90613e72565b90565b613eaa9051610f01565b90565b613eb79051610554565b90565b5f7f56616c7565206f7574206f6620626f756e647300000000000000000000000000910152565b613eee60136020926109d5565b613ef781613eba565b0190565b613f13613f219260408301908382035f8501526109e9565b906020818303910152613ee1565b90565b92916020613f40613f489360408701908782035f8901526109e9565b940190610557565b565b905f9291805490613f64613f5d836107e4565b80946109d5565b916001811690815f14613fbb5750600114613f7f575b505050565b613f8c9192939450610817565b915f925b818410613fa357505001905f8080613f7a565b60018160209295939554848601520191019290613f90565b92949550505060ff19168252151560200201905f8080613f7a565b5f7f5265717569726564206d6574726963206d697373696e67000000000000000000910152565b61400a60176020926109d5565b61401381613fd6565b0190565b61402f61403d9260408301908382035f850152613f4a565b906020818303910152613ffd565b90565b929390936140683361406261405c61405730613c85565b6103ef565b916103ef565b14613cea565b61407c61407760088690610768565b612e93565b9461408682613d4c565b946140905f612cc2565b5b806140a461409e86610554565b91610554565b10156140f7576140f2906140ed6140c85f6140c08a8590613d73565b510151613d93565b6140da6140d482613668565b91613662565b206140e88a91849092613d9a565b613dba565b612cde565b614091565b50919490929561410681612e9f565b6141186141125f612cc2565b91610554565b1196614122613dc8565b90886145a2575b6141325f612cc2565b5b806141466141408b610554565b91610554565b10156144055760015f8b614239575b509088878961416b94614170575b505050612cde565b614133565b825f6141ae6141a66141b7946141a161419960206141926141bc9b8d90613d73565b5101613ead565b976009611d07565b611d1d565b928790613d73565b51015190611dae565b613018565b888789906141e660206141df5f6141d4878990613d73565b510151958790613d73565b5101613ead565b6142196142137f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd9361074c565b93611006565b9361422e6142256103a2565b92839283613f24565b0390a3888789614163565b9a90959291996142485f612cc2565b5b8061426461425e6142598a612e9f565b610554565b91610554565b10156143ef5761427c6142778d87613d9a565b613ea0565b6142a061429a6142956142908a8690613d9a565b613ea0565b610f01565b91610f01565b146142b3576142ae90612cde565b614249565b8a919b929c508961416b9495988a926001908a6142dd60206142d6898b90613d73565b5101613ead565b6143056142ff6142fa60016142f3868890612ea3565b500161093e565b610554565b91610554565b1091888884156143a5575b5050505061433a575b614324905b156104c2565b614333575b9394505050614155565b505f614329565b905082825f61434a878990613d73565b5101519161439661438461437e7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361074c565b93611006565b9361438d6103a2565b91829182613efb565b0390a36143245f919050614319565b6143e59394506143d36143df936143cd60206143c66143da96600296613d73565b5101613ead565b96612ea3565b500161093e565b610554565b91610554565b118a5f8888614310565b5099909a878961416b9495986143248d9461431e565b5097505092935093506144175f612cc2565b935b8461443461442e61442986612e9f565b610554565b91610554565b101561459b5761445a614454600361444d868990612ea3565b5001610965565b156104c2565b6145905761447c6144775f614470868990612ea3565b5001613dcd565b613e94565b61448e61448882613668565b91613662565b20905f9661449b5f612cc2565b5b806144b76144b16144ac86613d96565b610554565b91610554565b101561457e576144d06144cb848390613d9a565b613ea0565b6144e26144dc86610f01565b91610f01565b146144f5576144f090612cde565b61449c565b5095909650614516915061450b60015b156104c2565b61451d575b5b612cde565b9394614419565b82855f61452b878590612ea3565b50019161457661456461455e7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361074c565b93611006565b9361456d6103a2565b91829182614017565b0390a3614510565b50959096614516925061450b90614505565b949361451690614511565b5050505050565b969390506145bc6145b7839794999693612e9f565b613d4c565b976145c65f612cc2565b5b806145e26145dc6145d78b612e9f565b610554565b91610554565b101561463c576146379061463261460d6146085f6146018d8690612ea3565b5001613dcd565b613e94565b61461f61461982613668565b91613662565b2061462d8d91849092613d9a565b613dba565b612cde565b6145c7565b509295919497909396614129565b614652616496565b61465a61465c565b565b61466d6146685f6125e9565b616bae565b565b61467761464a565b565b61468360a06116bc565b90565b5f90565b5f90565b5f90565b61469a614679565b90602080808080866146aa614686565b8152016146b5612750565b8152016146c0612754565b8152016146cb61468a565b8152016146d661468e565b81525050565b6146e4614692565b90565b906146f190610554565b9052565b906146ff906103b4565b9052565b9061470d906104af565b9052565b9061471b90611159565b9052565b9061479e6147956002614730614679565b9461474761473f5f830161093e565b5f88016146e7565b61475f61475660018301611049565b602088016146f5565b61477761476e60018301611076565b60408801614703565b61478f614786600183016110a3565b60608801614711565b016110c7565b60808401613dba565b565b6147a99061471f565b90565b6147d1916147c76147cc926147bf6146dc565b506003610fc8565b611012565b6147a0565b90565b5f90565b906147e29061074c565b5f5260205260405f2090565b906147f890611006565b5f5260205260405f2090565b6148299161481f614824926148176147d4565b50600c6147d8565b6147ee565b611049565b90565b614834616bc4565b61483c615e04565b61484e614848836103ef565b916103ef565b0361485e5761485c90616bae565b565b614879905f91829163118cdaa760e01b835260048301610cc9565b0390fd5b61489c6148976148a19261488f6127ae565b506004613334565b61334a565b616ac7565b90565b6148ae90516104af565b90565b6148c56148c06148ca926125ca565b610749565b6104af565b90565b6148d790516103b4565b90565b6148ee6148e96148f3926104af565b610749565b610554565b90565b61490561490b91939293610554565b92610554565b820180921161491657565b6128e4565b909291926149276139f3565b506149306127ae565b5061493a8261637e565b9361495761495261494d60058690613334565b61334a565b616ac7565b92614964602087016148a4565b6149766149705f6148b1565b916104af565b148015614a68575b8015614a4d575b614a33576149bf866149b96149b460206149ad6149a85f614a1c9b9c9d016148cd565b61357b565b93016148a4565b6148da565b906128f8565b91806149da6149d46149cf61132d565b610554565b91610554565b115f14614a2e57506149ea61132d565b5b6149f68482906148f6565b614a08614a0288610554565b91610554565b115f14614a1f5750845b9092909192616bfa565b91565b614a2990846148f6565b614a12565b6149eb565b5050509150614a49614a445f612cc2565b613a31565b9190565b5082614a61614a5b86610554565b91610554565b1015614985565b5083614a7c614a765f612cc2565b91610554565b1461497e565b614a9390614a8e616496565b614a95565b565b614aa090600a61269a565b565b614aab90614a82565b565b5f90565b614ab9614aad565b50614ac35f6125bd565b90565b5090565b9190811015614ada576020020190565b61077e565b35614ae9816103fb565b90565b5f80fd5b60e01b90565b5f910312614b0057565b6103ac565b916020614b26929493614b1f60408201965f830190610c21565b0190610cbc565b565b614b306103a2565b3d5f823e3d90fd5b90929192614b455f612cc2565b5b80614b63614b5d614b58858990614ac6565b610554565b91610554565b1015614c1257614b7230613c85565b9063ba1fb10384614b8d614b88868a8691614aca565b614adf565b93803b15614c0d57614bb25f8094614bbd614ba66103a2565b98899687958694614af0565b845260048401614b05565b03925af1918215614c0857614bd792614bdc575b50612cde565b614b46565b614bfb905f3d8111614c01575b614bf381836108d7565b810190614af6565b5f614bd1565b503d614be9565b614b28565b614aec565b5050509050565b5f7f4e6f7420736c617368696e67206f7261636c6500000000000000000000000000910152565b614c4d60136020926109d5565b614c5681614c19565b0190565b614c6f9060208101905f818303910152614c40565b90565b15614c7957565b614c816103a2565b62461bcd60e51b815280614c9760048201614c5a565b0390fd5b5f7f4f70657261746f7220756e6b6e6f776e00000000000000000000000000000000910152565b614ccf60106020926109d5565b614cd881614c9b565b0190565b614cf19060208101905f818303910152614cc2565b90565b15614cfb57565b614d036103a2565b62461bcd60e51b815280614d1960048201614cdc565b0390fd5b90565b90614d3367ffffffffffffffff91612677565b9181191691161790565b90565b90614d55614d50614d5c9261074c565b614d3d565b8254614d20565b9055565b9190614d7a81614d7381614d7f956109d5565b809561171d565b6108b9565b0190565b9091614d9a9260208301925f818503910152614d60565b90565b614dc233614dbc614db6614db1600a6125bd565b6103ef565b916103ef565b14614c72565b614de8614de3614ddc614dd760058590613334565b61334a565b84906164e4565b614cf4565b614e14614e09614e04614dfd60038590610fc8565b8590611012565b614d1d565b600160039101613381565b614e32614e2b614e2660048490613334565b61334a565b8390616d16565b50614e5a614e3f42613597565b614e55614e4e600c85906147d8565b85906147ee565b614d40565b909192614e90614e8a7f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361074c565b93611006565b93614ea5614e9c6103a2565b92839283614d83565b0390a3565b614eb460806116bc565b90565b614ec2913691611728565b90565b52565b90614ed2906104c2565b9052565b5190565b90614ee4816109d1565b9067ffffffffffffffff8211614fa457614f0882614f0285546107e4565b85612ecf565b602090601f8311600114614f3c57918091614f2b935f92614f30575b5050612a07565b90555b565b90915001515f80614f24565b601f19831691614f4b85610817565b925f5b818110614f8c57509160029391856001969410614f72575b50505002019055614f2e565b614f82910151601f8416906129f2565b90555f8080614f66565b91936020600181928787015181550195019201614f4e565b6108c3565b90614fb391614eda565b565b614fbf90516104c2565b90565b9061501f6060600361502594614fe55f8201614fdf5f8801614ed6565b90614fa9565b614ffe60018201614ff860208801613ead565b90613018565b6150176002820161501160408801613ead565b90613018565b019201614fb5565b9061306a565b565b91906150385761503691614fc2565b565b612ba3565b908154916801000000000000000083101561506d578261506591600161506b95018155612ea3565b90615027565b565b6108c3565b61519095615179849661517061516861515461514f615182976150f56150d56150cf61518b9d8d9f9d6150ca336150c46150be6150b96150b460078c906113c5565b6125bd565b6103ef565b916103ef565b14612835565b612d7b565b90612d7e565b6150ee6150e86150e3611921565b610554565b91610554565b1115612ddb565b6151128661510b6151058d610554565b91610554565b1015612e6a565b61514861512961512460088490610768565b610792565b61514261513c61513761156d565b610554565b91610554565b106128bb565b6008610768565b612e93565b989996929496615162614eaa565b9a614eb7565b5f8a01614ec5565b602088016146e7565b604086016146e7565b60608401614ec8565b61503d565b565b6151c0906151bb6151b66151af6151aa846006613334565b61334a565b33906164e4565b61351b565b6152a1565b565b5f7f43616e6e6f7420676f206f6e6c696e65207768696c6520736c61736865640000910152565b6151f6601e6020926109d5565b6151ff816151c2565b0190565b6152189060208101905f8183039101526151e9565b90565b60401b90565b9061523568ff00000000000000009161521b565b9181191691161790565b61525361524e615258926104af565b610749565b6104af565b90565b90565b9061527361526e61527a9261523f565b61525b565b8254615221565b9055565b91602061529f92949361529860408201965f830190611171565b0190611171565b565b6152bf6152ba6152b360038490610fc8565b3390611012565b614d1d565b906152cc600183016110a3565b91826152e16152db6003611159565b91611159565b1461540557826152f96152f35f611159565b91611159565b1480156153ea575b6153e557615328906153166001808301613381565b60016153215f6148b1565b910161525e565b61534661533f61533a60048490613334565b61334a565b339061645c565b50803361537c6153767fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361074c565b91611006565b916153856103a2565b8061538f8161044b565b0390a39033909160016153cb6153c57f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b936153e06153d76103a2565b9283928361527e565b0390a3565b505050565b50826153ff6153f96001611159565b91611159565b14615301565b61540d6103a2565b62461bcd60e51b81528061542360048201615203565b0390fd5b61543090615192565b565b5f7f4e6f7420617574686f72697a6564000000000000000000000000000000000000910152565b615466600e6020926109d5565b61546f81615432565b0190565b6154889060208101905f818303910152615459565b90565b1561549257565b61549a6103a2565b62461bcd60e51b8152806154b060048201615473565b0390fd5b90565b6154cb6154c66154d0926154b4565b610749565b6103b4565b90565b5f7f496e74657276616c20746f6f2073686f72740000000000000000000000000000910152565b61550760126020926109d5565b615510816154d3565b0190565b6155299060208101905f8183039101526154fa565b90565b1561553357565b61553b6103a2565b62461bcd60e51b81528061555160048201615514565b0390fd5b90565b61556c61556761557192615555565b610749565b6104af565b90565b5f7f4d6178206d6973736564206d757374206265203e3d2031000000000000000000910152565b6155a860176020926109d5565b6155b181615574565b0190565b6155ca9060208101905f81830391015261559b565b90565b156155d457565b6155dc6103a2565b62461bcd60e51b8152806155f2600482016155b5565b0390fd5b61560060606116bc565b90565b9061561861561361561f9261305b565b613067565b8254613353565b9055565b9061566560405f61566b9461564582820161563f8488016148cd565b90614d40565b61565d828201615657602088016148a4565b9061525e565b019201614fb5565b90615603565b565b9061567791615623565b565b91602061569a92949361569360408201965f830190610c21565b0190611129565b565b336156cf6156c97f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b1480156157bb575b6156e09061548b565b6156fe826156f76156f1603c6154b7565b916103b4565b101561552c565b61571c8361571561570f6001615558565b916104af565b10156155cd565b615775826157648561575b61573d5f61573760028990612287565b016122b1565b916157526157496155f6565b955f87016146f5565b60208501614703565b60408301614ec8565b61577060028490612287565b61566d565b90916157a17fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea5649261074c565b926157b66157ad6103a2565b92839283615679565b0390a2565b506156e0336157e56157df6157da6157d5600787906113c5565b6125bd565b6103ef565b916103ef565b1490506156d7565b634e487b7160e01b5f52601260045260245ffd5b61580d61581391610554565b91610554565b90811561581e570490565b6157ed565b61583761583261583c92610554565b610749565b6104af565b90565b61585361584e615858926125ca565b610749565b6103b4565b90565b61587961587461586d60038490610fc8565b8490611012565b614d1d565b906158838161637e565b61588f600184016110a3565b6158a261589c6003611159565b91611159565b14615ab6576158b25f840161093e565b6158c46158be5f612cc2565b91610554565b14615ab0576158fa6158e1426158db5f870161093e565b906135d6565b6158f46158ef5f85016148cd565b61357b565b90615801565b8061590e61590860ff6148da565b91610554565b115f14615aa2575060ff5b908161593861593261592d60018801611076565b6104af565b916104af565b11615945575b5050505050565b615952826001860161525e565b61596761595e5f61583f565b60018601614d40565b61598561597f61597a60208594016148a4565b6104af565b916104af565b101580615a7b575b615998575b8061593e565b6159b36159a7600185016110a3565b93600160029101613381565b6159d16159ca6159c560048590613334565b61334a565b8590616d16565b508190849091615a1f615a0d615a077f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d9361074c565b93611006565b93615a166103a2565b91829182611627565b0390a39190916002615a5a615a547f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93615a6f615a666103a2565b9283928361527e565b0390a35f808080615992565b50615a88600184016110a3565b615a9b615a956002611159565b91611159565b141561598d565b615aab90615823565b615919565b50505050565b50505050565b606090565b67ffffffffffffffff8111615ad95760208091020190565b6108c3565b90615af0615aeb83615ac1565b6116bc565b918252565b615aff60806116bc565b90565b90615b69615b606003615b13615af5565b94615b2a615b225f8301610900565b5f8801614ec5565b615b42615b396001830161093e565b602088016146e7565b615b5a615b516002830161093e565b604088016146e7565b01610965565b60608401614ec8565b565b615b7490615b02565b90565b90615b8182610792565b615b8a81615ade565b92615b986020850191610796565b5f915b838310615ba85750505050565b60046020600192615bb885615b6b565b815201920192019190615b9b565b615bcf90615b77565b90565b615be9615bee91615be1615abc565b506008610768565b615bc6565b90565b615c1f90615c1a615c15615c0e615c09846006613334565b61334a565b33906164e4565b61351b565b615c7a565b565b5f7f43616e6e6f7420676f206f66666c696e65207768696c6520736c617368656400910152565b615c55601f6020926109d5565b615c5e81615c21565b0190565b615c779060208101905f818303910152615c48565b90565b615c98615c93615c8c60038490610fc8565b3390611012565b614d1d565b90615ca5600183016110a3565b9182615cba615cb46003611159565b91611159565b14615d4057615cce90600160049101613381565b615cec615ce5615ce060048490613334565b61334a565b3390616d16565b50903390916004615d26615d207f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93615d3b615d326103a2565b9283928361527e565b0390a3565b615d486103a2565b62461bcd60e51b815280615d5e60048201615c62565b0390fd5b615d6b90615bf1565b565b909182615d7d81615d8493611d33565b809361171d565b0190565b615d999060209493615da093615d6d565b8092611d64565b0190565b9091615dbb90615db26103a2565b93849384615d88565b03902090565b9091615dcc92615da4565b90565b92615df4615dfc9392615def615e0196615de76127ae565b506009611d07565b611d1d565b919091615dc1565b61093e565b90565b615e0c614aad565b50615e1760016125bd565b90565b615e249051611159565b90565b90565b615e3e615e39615e4392615e27565b610749565b610554565b90565b60207f6c00000000000000000000000000000000000000000000000000000000000000917f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76615f8201520152565b615ea060216040926109d5565b615ea981615e46565b0190565b615ec29060208101905f818303910152615e93565b90565b15615ecc57565b615ed46103a2565b62461bcd60e51b815280615eea60048201615ead565b0390fd5b90615f9f615f9a615fa49333615f1f615f19615f14615f0f600786906113c5565b6125bd565b6103ef565b916103ef565b14801561605d575b615f309061548b565b615f4e615f49615f4260038490610fc8565b8690611012565b6147a0565b615f5a60608201615e1a565b615f6d615f676003611159565b91611159565b03615fa7575b50615f92615f8b615f8660058490613334565b61334a565b8590616d16565b506004613334565b61334a565b616d16565b50565b61602390615ff7615fe7615fba8561637e565b615fe1615fdc6020615fd5615fd05f86016148cd565b61357b565b93016148a4565b6148da565b906128f8565b615ff1600a615e2a565b906128f8565b6160025f8301613ead565b61601461600e5f612cc2565b91610554565b119182616029575b5050615ec5565b5f615f73565b61605491925061604861604e916160425f429201613ead565b906135d6565b92610554565b91610554565b10155f8061601c565b50615f303361607b616075616070614ab1565b6103ef565b916103ef565b149050615f27565b906160ad6160b291616093613b22565b506160a86160a08561637e565b946003610fc8565b611012565b6147a0565b6160bd5f8201613ead565b6160cf6160c95f612cc2565b91610554565b1461610a576161006160fb5f6160f4616106946160ee83429201613ead565b906135d6565b94016148cd565b61357b565b91610554565b1090565b50505f90565b6161219061611c616496565b616123565b565b61612e81600161269a565b616136614ab1565b9061616a6161647f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e2270093611006565b91611006565b916161736103a2565b8061617d8161044b565b0390a3565b61618b90616110565b565b5f6161cc6161d2936161c4336161be6161b86161b36161ae60078a906113c5565b6125bd565b6103ef565b916103ef565b14612835565b926002612287565b01615603565b565b5f7f4e6f742072656769737465726564000000000000000000000000000000000000910152565b616208600e6020926109d5565b616211816161d4565b0190565b61622a9060208101905f8183039101526161fb565b90565b1561623457565b61623c6103a2565b62461bcd60e51b81528061625260048201616215565b0390fd5b6162923361628c6162867f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b6162b86162b36162ac6162a760068590613334565b61334a565b8490616d16565b61622d565b6162d66162cf6162ca60048490613334565b61334a565b8390616d16565b509061630b6163057f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e9361074c565b91611006565b916163146103a2565b8061631e8161044b565b0390a3565b906163706163675f616333612743565b9461634a616342838301611049565b8388016146f5565b616361616358838301611076565b60208801614703565b016122b1565b60408401614ec8565b565b61637b90616323565b90565b61639561639a9161638d61278e565b506002612287565b616372565b6163a55f82016148cd565b6163b76163b15f61583f565b916103b4565b146163fd575b6163c9602082016148a4565b6163db6163d55f6148b1565b916104af565b146163e4575b90565b6163f86163ef61160f565b60208301614703565b6163e1565b616410616408610c08565b5f83016146f5565b6163bd565b61641e90610fde565b90565b61643561643061643a926103e4565b610749565b610554565b90565b61645161644c61645692610554565b612677565b610f01565b90565b90565b9061648e61648861648361647e5f61649396616476613b22565b500194616415565b616421565b61643d565b91616459565b616df9565b90565b61649e614ab1565b6164b76164b16164ac616bc4565b6103ef565b916103ef565b036164be57565b6164e06164c9616bc4565b5f91829163118cdaa760e01b835260048301610cc9565b0390fd5b9061651661651061650b6165065f61651b966164fe613b22565b500194616415565b616421565b61643d565b91616459565b616e5c565b90565b61653d916165349161652e614aad565b50616ebc565b90929192616f7c565b90565b5f7f4f70657261746f7220697320736c617368656400000000000000000000000000910152565b61657460136020926109d5565b61657d81616540565b0190565b6165969060208101905f818303910152616567565b90565b156165a057565b6165a86103a2565b62461bcd60e51b8152806165be60048201616581565b0390fd5b6165cb90610f01565b90565b6165d790610922565b90565b906165ef6165ea6165f6926165c2565b6165ce565b8254613002565b9055565b616603906103b4565b67ffffffffffffffff81146166185760010190565b6128e4565b90565b61663461662f6166399261661d565b610749565b6104af565b90565b91602061665d92949361665660408201965f830190611129565b0190610557565b565b61666890610fde565b90565b6166749061665f565b90565b61668090610ffa565b90565b6040906166ac6166b394969593966166a260608401985f850190610cbc565b6020830190610c21565b0190610c21565b565b94929391936166d86166d36166cc60038990610fc8565b8790611012565b614d1d565b936166e28761637e565b9361670c6166f2600188016110a3565b6167056166ff6003611159565b91611159565b1415616599565b61672a61672361671e60058b90613334565b61334a565b889061645c565b506167ff604061673c600189016110a3565b96616749425f8b01613018565b616773616757858790613654565b61676961676382613668565b91613662565b2060028b016165da565b61678861677f5f6148b1565b60018b0161525e565b6167a660018a016167a061679b82611049565b6165fa565b90614d40565b6167ae613c56565b50856167c26167bc5f6148b1565b916104af565b145f14616a83576167d95f995b60018b9101613381565b876167ed6167e76002611159565b91611159565b1480616a67575b6169f9575b01614fb5565b806169d5575b6169bf575b505085918591924261684e6168486168427f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b99461074c565b9461074c565b94611006565b9461686361685a6103a2565b9283928361663c565b0390a48061687961687384611159565b91611159565b03616969575b505061688b600b6125bd565b6168a561689f61689a5f6125e9565b6103ef565b916103ef565b036168af575b5050565b6168c96168c46168bf600b6125bd565b61666b565b616677565b9163d47853b69190926168db42613597565b92813b15616964575f6169019161690c82966168f56103a2565b98899788968795614af0565b855260048501616683565b03925af19081616938575b50155f1461693357600161692e575b5b5f806168ab565b616926565b616927565b616957905f3d811161695d575b61694f81836108d7565b810190614af6565b5f616917565b503d616945565b614aec565b838391926169a061699a7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b936169b56169ac6103a2565b9283928361527e565b0390a35f8061687f565b6169ce91889188909192617439565b5f8061680a565b506169e1818390612d7e565b6169f36169ed5f612cc2565b91610554565b11616805565b616a16616a0f616a0a8d6004613334565b61334a565b8b9061645c565b508a8a616a4c616a467fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361074c565b91611006565b91616a556103a2565b80616a5f8161044b565b0390a36167f9565b5088616a7c616a766002611159565b91611159565b14156167f4565b85616a97616a916064616620565b916104af565b105f14616aaa576167d96001995b6167cf565b6167d9600199616ac28d8d8b908b908a928c946170ed565b616aa5565b616ade5f616ae392616ad76127ae565b5001616459565b6175f7565b90565b616af2616af791610922565b61297e565b90565b616b0e616b09616b1392610554565b610749565b6103e4565b90565b616b41616b3c616b4b93616b375f616b4695616b30614aad565b5001616459565b617665565b616ae6565b616afa565b610ffa565b90565b91906008616b6e910291616b6860018060a01b0384612955565b92612955565b9181191691161790565b9190616b8e616b89616b9693611006565b612697565b908354616b4e565b9055565b616bac91616ba6614aad565b91616b78565b565b616bc290616bbd5f6001616b9a565b617686565b565b616bcc614aad565b503390565b616bda90610554565b5f198114616be85760010190565b6128e4565b616bf790516103ef565b90565b93919293616c066139f3565b50616c1a616c158584906135d6565b613a31565b92616c245f612cc2565b925b80616c39616c3388610554565b91610554565b1015616ca757616c5d616c56616c5160058690613334565b61334a565b8290616b16565b616c6984828a916176e5565b616c7d575b50616c7890612cde565b616c26565b616c789194616c9b616ca092616c968991849092613a58565b613a78565b616bd1565b9390616c6e565b509450509150616cb682613a31565b92616cc05f612cc2565b5b80616cd4616cce86610554565b91610554565b1015616d1057616d0b90616d06616cf4616cef868490613a58565b616bed565b616d018891849092613a58565b613a78565b612cde565b616cc1565b50915050565b90616d48616d42616d3d616d385f616d4d96616d30613b22565b500194616415565b616421565b61643d565b91616459565b617831565b90565b90565b5f5260205f2090565b5490565b616d6981616d5c565b821015616d8357616d7b600191616d53565b910201905f90565b61077e565b9190616d9e616d99616da6936165c2565b6165ce565b908354612959565b9055565b9081549168010000000000000000831015616dda5782616dd2916001616dd895018155616d60565b90616d88565b565b6108c3565b5490565b90616ded906165c2565b5f5260205260405f2090565b616e01613b22565b50616e16616e10828490616e5c565b156104c2565b5f14616e5657616e4c616e5192616e38616e315f8501616d50565b8290616daa565b6001616e455f8501616ddf565b9301616de3565b613018565b600190565b50505f90565b616e7a916001616e7592616e6e613b22565b5001616de3565b61093e565b616e8c616e865f612cc2565b91610554565b141590565b5f90565b5f90565b90565b616eb0616eab616eb592616e99565b610749565b610554565b90565b5f90565b919091616ec7614aad565b50616ed0616e91565b50616ed9616e95565b50616ee383613668565b616ef6616ef06041616e9c565b91610554565b145f14616f3d57616f369192616f0a616e95565b50616f13616e95565b50616f1c616eb8565b506020810151606060408301519201515f1a9091926179b0565b9192909190565b50616f475f6125e9565b90616f5b616f56600294613668565b61643d565b91929190565b60041115616f6b57565b611136565b90616f7a82616f61565b565b80616f8f616f895f616f70565b91616f70565b145f14616f9a575050565b80616fae616fa86001616f70565b91616f70565b145f14616fd1575f63f645eedf60e01b815280616fcd6004820161044b565b0390fd5b80616fe5616fdf6002616f70565b91616f70565b145f146170135761700f616ff883616ae6565b5f91829163fce698f760e01b835260048301610564565b0390fd5b6170266170206003616f70565b91616f70565b1461702e5750565b617049905f9182916335e2f38360e21b835260048301610f11565b0390fd5b61706161705c6170669261130e565b610749565b6104af565b90565b61707561707b916103b4565b916103b4565b90039067ffffffffffffffff821161708f57565b6128e4565b5f7f50726f746f636f6c2076696f6c6174696f6e207265706f727465640000000000910152565b6170c8601b6020926109d5565b6170d181617094565b0190565b6170ea9060208101905f8183039101526170bb565b90565b93505092506171056170ff60c861704d565b916104af565b1015617110575b5050565b61711942613597565b61713761713261712b600c85906147d8565b85906147ee565b611049565b8061714a6171445f61583f565b916103b4565b149081156171d0575b5061715f575b5061710c565b61717e90617179617172600c85906147d8565b85906147ee565b614d40565b906171b26171ac7f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361074c565b91611006565b916171bb6103a2565b806171c5816170d5565b0390a35f8080617159565b6171db915082617069565b6171f46171ee6171e9610f7a565b6103b4565b916103b4565b10155f617153565b90565b61721361720e617218926171fc565b610749565b610554565b90565b9092919261723061722b826116fa565b6116bc565b9381855260208501908284011161724c5761724a926109de565b565b6116f6565b9080601f8301121561726f5781602061726c9351910161721b565b90565b6105af565b90505190617281826106f9565b565b9190916040818403126172d65761729a60406116bc565b925f8201519167ffffffffffffffff83116172d1576172be826172ca948301617251565b5f860152602001617274565b6020830152565b6116f2565b6116ee565b9291906172ef6172ea826116d1565b6116bc565b93818552602080860192028101918383116173465781905b838210617315575050505050565b815167ffffffffffffffff8111617341576020916173368784938701617283565b815201910190617307565b6105af565b6105b7565b9080601f8301121561736957816020617366935191016172db565b90565b6105af565b9060208282031261739e575f82015167ffffffffffffffff811161739957617396920161734b565b90565b6103b0565b6103ac565b60209181520190565b91906173c6816173bf816173cb956173a3565b809561171d565b6108b9565b0190565b90916173e69260208301925f8185039101526173ac565b90565b6173f36032611551565b90565b9493916060916174379461742261742f9361741860808b01945f8c0190610c21565b60208a0190610cbc565b8782036040890152610e28565b940190610557565b565b91617445818590612d7e565b6174576174515f612cc2565b91610554565b146175f157617467818590612d7e565b61747b61747561c3506171ff565b91610554565b116175eb575f617489613978565b9461749330613c85565b6174b56331e3bd1b9492946174c06174a96103a2565b96879586948594614af0565b8452600484016173cf565b03915afa80915f926175c7575b50155f146175be575060016175b9575b6174e683610d97565b6174ff6174f96174f46173e9565b610554565b91610554565b115f146175ab5761750e6173e9565b5b61751830613c85565b906365a6936e93929490823b156175a6575f9461755386926175489461753c6103a2565b998a9889978896614af0565b8652600486016173f6565b03925af1908161757a575b50155f14617575576001617570575b5b565b61756d565b61756e565b617599905f3d811161759f575b61759181836108d7565b810190614af6565b5f61755e565b503d617587565b614aec565b6175b483610d97565b61750f565b505050565b909250916174dd565b6175e49192503d805f833e6175dc81836108d7565b81019061736e565b905f6174cd565b50505050565b50505050565b5f61760b916176046127ae565b5001616ddf565b90565b5f5260205f2090565b61762081616ddf565b82101561763a5761763260019161760e565b910201905f90565b61077e565b61764f9060086176549302610c78565b6110b0565b90565b90617662915461763f565b90565b617683915f61767d92617676616e95565b5001617617565b90617657565b90565b61768f5f6125bd565b617699825f61269a565b906176cd6176c77f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e093611006565b91611006565b916176d66103a2565b806176e08161044b565b0390a3565b6176ed613b22565b5061771561770f61770861770360068590613334565b61334a565b84906164e4565b156104c2565b6177b7576177359161772b617730926003610fc8565b611012565b6147a0565b6177405f8201613ead565b61775261774c5f612cc2565b91610554565b148015617791575b61778b5761778061777a617786926177745f429201613ead565b906135d6565b92610554565b91610554565b101590565b50505f90565b5061779e60608201615e1a565b6177b16177ab6003611159565b91611159565b1461775a565b5050505f90565b6177d26177cd6177d792615555565b610749565b610554565b90565b634e487b7160e01b5f52603160045260245ffd5b617800916177fa616e95565b91616d88565b565b61780b81616d5c565b801561782c5760019003906178296178238383616d60565b906177ee565b55565b6177da565b617839613b22565b5061785061784b600183018490616de3565b61093e565b908161786461785e5f612cc2565b91610554565b14155f14617930576178e29260016178dd928461788b5f96617885856177be565b906135d6565b6178a8617899888501616ddf565b6178a2866177be565b906135d6565b816178bb6178b583610554565b91610554565b036178e7575b5050506178d76178d2868301616d50565b617802565b01616de3565b6129bf565b600190565b6179289261791a617906617900617923948c8901617617565b90617657565b9361791485918c8901617617565b90616d88565b91858501616de3565b613018565b5f80806178c1565b5050505f90565b90565b61794e61794961795392617937565b610749565b610554565b90565b61798b61799294617981606094989795617977608086019a5f870190610f04565b6020850190611129565b6040830190610f04565b0190610f04565b565b6179a86179a36179ad926125ca565b612677565b610f01565b90565b9392936179bb614aad565b506179c4616e91565b506179cd616e95565b506179d785616ae6565b617a09617a037f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a061793a565b91610554565b11617a965790617a2c602094955f94939293617a236103a2565b94859485617956565b838052039060015afa15617a9157617a445f51612677565b80617a5f617a59617a545f6125e9565b6103ef565b916103ef565b14617a75575f91617a6f5f617994565b91929190565b50617a7f5f6125e9565b600191617a8b5f617994565b91929190565b614b28565b505050617aa25f6125e9565b906003929192919056fea164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\xC0`@R4a\0eWa\0\x1Aa\0\x14a\x019V[\x90a\x02\x16V[a\0\"a\0jV[az\xB9a\x04\xD3\x829`\x80Q\x81\x81\x81a\x0E\xDF\x01Ra8\x8D\x01R`\xA0Q\x81\x81\x81a\x14`\x01R\x81\x81a&\xCD\x01R\x81\x81a3\xAD\x01R\x81\x81aV\xA5\x01Rabb\x01Raz\xB9\x90\xF3[a\0pV[`@Q\x90V[_\x80\xFD[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\0\x9C\x90a\0tV[\x81\x01\x90\x81\x10`\x01\x80`@\x1B\x03\x82\x11\x17a\0\xB4W`@RV[a\0~V[\x90a\0\xCCa\0\xC5a\0jV[\x92\x83a\0\x92V[V[_\x80\xFD[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\0\xE6\x90a\0\xD2V[\x90V[a\0\xF2\x81a\0\xDDV[\x03a\0\xF9WV[_\x80\xFD[\x90PQ\x90a\x01\n\x82a\0\xE9V[V[\x91\x90`@\x83\x82\x03\x12a\x014W\x80a\x01(a\x011\x92_\x86\x01a\0\xFDV[\x93` \x01a\0\xFDV[\x90V[a\0\xCEV[a\x01Wa\x7F\x8C\x808\x03\x80a\x01L\x81a\0\xB9V[\x92\x839\x81\x01\x90a\x01\x0CV[\x90\x91V[\x90V[a\x01ra\x01ma\x01w\x92a\0\xD2V[a\x01[V[a\0\xD2V[\x90V[a\x01\x83\x90a\x01^V[\x90V[a\x01\x8F\x90a\x01zV[\x90V[\x90V[a\x01\x9E\x90a\x01\x92V[\x90RV[\x90V[a\x01\xAE\x90a\x01\xA2V[\x90RV[a\x01\xBB\x90a\0\xDDV[\x90RV[\x90\x95\x94\x92a\x02\n\x94a\x01\xF9a\x02\x03\x92a\x01\xEF`\x80\x96a\x01\xE5`\xA0\x88\x01\x9C_\x89\x01\x90a\x01\x95V[` \x87\x01\x90a\x01\x95V[`@\x85\x01\x90a\x01\x95V[``\x83\x01\x90a\x01\xA5V[\x01\x90a\x01\xB2V[V[` \x01\x90V[Q\x90V[\x90a\x02 \x90a\x02\xD3V[`\xA0R\x7F\x8Bs\xC3\xC6\x9B\xB8\xFE=Q.\xCCL\xF7Y\xCCy#\x9F{\x17\x9B\x0F\xFA\xCA\xA9\xA7]R+9@\x0Fa\x02\xBB\x7F6\xFF\xC2X\xC8e\x19:\xE1\x0C<\xF6@E\n\xB7r\xFD\xB8\xDA\x1D\xFC\xAExb\xAD\x12\x05\xA5V\x7FL\x91a\x02\xAC\x7F\xC8\x9E\xFD\xAAT\xC0\xF2\x0Cz\xDFa(\x82\xDF\tP\xF5\xA9Qc~\x03\x07\xCD\xCBLg/)\x8B\x8B\xC6Fa\x02\x970a\x01\x86V[\x91a\x02\xA0a\0jV[\x96\x87\x95` \x87\x01a\x01\xBFV[` \x82\x01\x81\x03\x82R\x03\x82a\0\x92V[a\x02\xCDa\x02\xC7\x82a\x02\x12V[\x91a\x02\x0CV[ `\x80RV[a\x02\xDC\x90a\x03\x1EV[V[\x90V[a\x02\xF5a\x02\xF0a\x02\xFA\x92a\x02\xDEV[a\x01[V[a\0\xD2V[\x90V[a\x03\x06\x90a\x02\xE1V[\x90V[\x91\x90a\x03\x1C\x90_` \x85\x01\x94\x01\x90a\x01\xB2V[V[\x80a\x039a\x033a\x03._a\x02\xFDV[a\0\xDDV[\x91a\0\xDDV[\x14a\x03IWa\x03G\x90a\x03\xE7V[V[a\x03la\x03U_a\x02\xFDV[_\x91\x82\x91c\x1EO\xBD\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x03\tV[\x03\x90\xFD[\x1B\x90V[\x91\x90`\x08a\x03\x94\x91\x02\x91a\x03\x8E`\x01\x80`\xA0\x1B\x03\x84a\x03pV[\x92a\x03pV[\x91\x81\x19\x16\x91\x16\x17\x90V[a\x03\xA7\x90a\x01zV[\x90V[\x90V[\x91\x90a\x03\xC3a\x03\xBEa\x03\xCB\x93a\x03\x9EV[a\x03\xAAV[\x90\x83Ta\x03tV[\x90UV[_\x90V[a\x03\xE5\x91a\x03\xDFa\x03\xCFV[\x91a\x03\xADV[V[a\x03\xFB\x90a\x03\xF6_`\x01a\x03\xD3V[a\x04sV[V[_\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x04\x19a\x04\x1E\x91a\x03\xFDV[a\x04\x02V[\x90V[a\x04+\x90Ta\x04\rV[\x90V[_\x1B\x90V[\x90a\x04D`\x01\x80`\xA0\x1B\x03\x91a\x04.V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a\x04ca\x04^a\x04j\x92a\x03\x9EV[a\x03\xAAV[\x82Ta\x043V[\x90UV[_\x01\x90V[a\x04|_a\x04!V[a\x04\x86\x82_a\x04NV[\x90a\x04\xBAa\x04\xB4\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x03\x9EV[\x91a\x03\x9EV[\x91a\x04\xC3a\0jV[\x80a\x04\xCD\x81a\x04nV[\x03\x90\xA3V\xFE`\x80`@R`\x046\x10\x15a\0\x13W[a%#V[a\0\x1D_5a\x03\x9CV[\x80c\x05w\x85P\x14a\x03\x97W\x80c\x07X#o\x14a\x03\x92W\x80c\x0Cviz\x14a\x03\x8DW\x80c\x19\x1C\xBD\x1A\x14a\x03\x88W\x80c\x1E\x8F^\xE5\x14a\x03\x83W\x80c \x81)V\x14a\x03~W\x80c\"\xF1\xEC\x93\x14a\x03yW\x80c+\xF4\xD6\xA7\x14a\x03tW\x80c,\x95v\x88\x14a\x03oW\x80c-\xAE\x18\x85\x14a\x03jW\x80c/K\xD7\xB8\x14a\x03eW\x80c1\xE3\xBD\x1B\x14a\x03`W\x80c6D\xE5\x15\x14a\x03[W\x80c:\xC3\xCB\xE6\x14a\x03VW\x80c>n4\xA7\x14a\x03QW\x80c?\xD6,m\x14a\x03LW\x80c@#Z\x9C\x14a\x03GW\x80cH\xF4\xDA \x14a\x03BW\x80cV\x85\xCFh\x14a\x03=W\x80cV\xC4\xE1}\x14a\x038W\x80cY\xDC\xEA\x12\x14a\x033W\x80cZ\x93m\xC6\x14a\x03.W\x80c\\\xCE\x98\xA6\x14a\x03)W\x80c`vC\x9C\x14a\x03$W\x80c`\xCF\t\x91\x14a\x03\x1FW\x80ca\xD6\xB8l\x14a\x03\x1AW\x80cb\xC7\xE8\xFC\x14a\x03\x15W\x80ce\xA6\x93n\x14a\x03\x10W\x80ck\xFE\x06\xA6\x14a\x03\x0BW\x80cqP\x18\xA6\x14a\x03\x06W\x80cq\xE78\x8C\x14a\x03\x01W\x80cv9\xD2'\x14a\x02\xFCW\x80cy\xBAP\x97\x14a\x02\xF7W\x80c{\x9Fd\xB2\x14a\x02\xF2W\x80c\x81\xBE\xAC.\x14a\x02\xEDW\x80c\x84\xEFs\"\x14a\x02\xE8W\x80c\x8D\xA5\xCB[\x14a\x02\xE3W\x80c\x96hl\x1E\x14a\x02\xDEW\x80c\x9C\xBD\xAE\"\x14a\x02\xD9W\x80c\xAD\xFF\x83\x0C\x14a\x02\xD4W\x80c\xAEG\n\x85\x14a\x02\xCFW\x80c\xB0t\xE9\xDD\x14a\x02\xCAW\x80c\xB9\x9FgY\x14a\x02\xC5W\x80c\xBA\x1F\xB1\x03\x14a\x02\xC0W\x80c\xC1\xEF\x9D\xDF\x14a\x02\xBBW\x80c\xC5\xD9`\xBB\x14a\x02\xB6W\x80c\xCF\xE3GI\x14a\x02\xB1W\x80c\xD5Q\x16,\x14a\x02\xACW\x80c\xDACZ|\x14a\x02\xA7W\x80c\xE3\x0C9x\x14a\x02\xA2W\x80c\xE6\\\xAF\xCB\x14a\x02\x9DW\x80c\xEE\x1C\x03\x90\x14a\x02\x98W\x80c\xF2\xFD\xE3\x8B\x14a\x02\x93W\x80c\xF9\x10\x7F;\x14a\x02\x8EW\x80c\xF9\xF1gb\x14a\x02\x89Wc\xFF\xCF\x08\xF0\x03a\0\x0EWa$\xEFV[a$\xBAV[a$WV[a#\xF7V[a#\xC1V[a#\x8DV[a#XV[a# V[a\"NV[a\"\x19V[a!\xD7V[a!\xA2V[a xV[a DV[a\x1F\xD7V[a\x1F\x9DV[a\x1E\xD2V[a\x1E\x0BV[a\x1C\x82V[a\x1B\xC8V[a\x1B\x95V[a\x1B^V[a\x1A\xC9V[a\x1A\x96V[a\x1A`V[a\x1A*V[a\x19nV[a\x199V[a\x18\xCBV[a\x16\x86V[a\x16<V[a\x15\xBAV[a\x15\x85V[a\x15\x17V[a\x14\x82V[a\x14)V[a\x13\xF4V[a\x13\x8FV[a\x13EV[a\x12\xD9V[a\x12\x05V[a\x11\xCBV[a\x0F\x93V[a\x0F&V[a\x0E\xA7V[a\r,V[a\x0C\xDEV[a\x0CCV[a\x0B\x9DV[a\njV[a\x06\xC6V[a\x06tV[a\x06@V[a\x05yV[a\x05\x1FV[a\x04PV[`\xE0\x1C\x90V[`@Q\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x03\xCA\x81a\x03\xB4V[\x03a\x03\xD1WV[_\x80\xFD[\x90P5\x90a\x03\xE2\x82a\x03\xC1V[V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x03\xF8\x90a\x03\xE4V[\x90V[a\x04\x04\x81a\x03\xEFV[\x03a\x04\x0BWV[_\x80\xFD[\x90P5\x90a\x04\x1C\x82a\x03\xFBV[V[\x91\x90`@\x83\x82\x03\x12a\x04FW\x80a\x04:a\x04C\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x04\x0FV[\x90V[a\x03\xACV[_\x01\x90V[4a\x04\x7FWa\x04ia\x04c6`\x04a\x04\x1EV[\x90a&\xBAV[a\x04qa\x03\xA2V[\x80a\x04{\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x04\x9DWa\x04\x9A\x91_\x01a\x03\xD5V[\x90V[a\x03\xACV[a\x04\xAB\x90a\x03\xB4V[\x90RV[`\xFF\x16\x90V[a\x04\xBE\x90a\x04\xAFV[\x90RV[\x15\x15\x90V[a\x04\xD0\x90a\x04\xC2V[\x90RV[\x90`@\x80a\x05\x08\x93a\x04\xEC_\x82\x01Q_\x86\x01\x90a\x04\xA2V[a\x04\xFE` \x82\x01Q` \x86\x01\x90a\x04\xB5V[\x01Q\x91\x01\x90a\x04\xC7V[V[\x91\x90a\x05\x1D\x90_``\x85\x01\x94\x01\x90a\x04\xD4V[V[4a\x05OWa\x05Ka\x05:a\x0556`\x04a\x04\x84V[a'\x99V[a\x05Ba\x03\xA2V[\x91\x82\x91\x82a\x05\nV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x05`\x90a\x05TV[\x90RV[\x91\x90a\x05w\x90_` \x85\x01\x94\x01\x90a\x05WV[V[4a\x05\xAAWa\x05\xA6a\x05\x95a\x05\x8F6`\x04a\x04\x1EV[\x90a'\xB2V[a\x05\x9Da\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x05\xF5W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x05\xF0W` \x01\x92` \x83\x02\x84\x01\x11a\x05\xEBWV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x06;Wa\x06\x13\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x066Wa\x062\x92\x01a\x05\xBBV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x06oWa\x06Ya\x06S6`\x04a\x05\xFAV[\x91a1;V[a\x06aa\x03\xA2V[\x80a\x06k\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x06\xA3Wa\x06\x8Da\x06\x876`\x04a\x04\x1EV[\x90a3\xA1V[a\x06\x95a\x03\xA2V[\x80a\x06\x9F\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x06\xC1Wa\x06\xBE\x91_\x01a\x04\x0FV[\x90V[a\x03\xACV[4a\x06\xF4Wa\x06\xDEa\x06\xD96`\x04a\x06\xA8V[a4\xB7V[a\x06\xE6a\x03\xA2V[\x80a\x06\xF0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x07\x02\x81a\x05TV[\x03a\x07\tWV[_\x80\xFD[\x90P5\x90a\x07\x1A\x82a\x06\xF9V[V[\x91\x90`@\x83\x82\x03\x12a\x07DW\x80a\x078a\x07A\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x07\rV[\x90V[a\x03\xACV[\x90V[a\x07`a\x07[a\x07e\x92a\x03\xB4V[a\x07IV[a\x03\xB4V[\x90V[\x90a\x07r\x90a\x07LV[_R` R`@_ \x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[T\x90V[_R` _ \x90V[_R` _ \x90V[a\x07\xB1\x81a\x07\x92V[\x82\x10\x15a\x07\xCBWa\x07\xC3`\x04\x91a\x07\x96V[\x91\x02\x01\x90_\x90V[a\x07~V[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x90`\x01`\x02\x83\x04\x92\x16\x80\x15a\x08\x04W[` \x83\x10\x14a\x07\xFFWV[a\x07\xD0V[\x91`\x7F\x16\x91a\x07\xF4V[` \x91\x81R\x01\x90V[_R` _ \x90V[\x90_\x92\x91\x80T\x90a\x08:a\x083\x83a\x07\xE4V[\x80\x94a\x08\x0EV[\x91`\x01\x81\x16\x90\x81_\x14a\x08\x91WP`\x01\x14a\x08UW[PPPV[a\x08b\x91\x92\x93\x94Pa\x08\x17V[\x91_\x92[\x81\x84\x10a\x08yWPP\x01\x90_\x80\x80a\x08PV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a\x08fV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a\x08PV[\x90a\x08\xB6\x91a\x08 V[\x90V[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\x08\xE1\x90a\x08\xB9V[\x81\x01\x90\x81\x10g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x17a\x08\xFBW`@RV[a\x08\xC3V[\x90a\t a\t\x19\x92a\t\x10a\x03\xA2V[\x93\x84\x80\x92a\x08\xACV[\x03\x83a\x08\xD7V[V[_\x1C\x90V[\x90V[a\t6a\t;\x91a\t\"V[a\t'V[\x90V[a\tH\x90Ta\t*V[\x90V[`\xFF\x16\x90V[a\t]a\tb\x91a\t\"V[a\tKV[\x90V[a\to\x90Ta\tQV[\x90V[a\t}\x90`\x08a\x07hV[\x90a\t\x87\x82a\x07\x92V[\x81\x10\x15a\t\xCDWa\t\x97\x91a\x07\xA8V[P\x90a\t\xA4_\x83\x01a\t\0V[\x91a\t\xB1`\x01\x82\x01a\t>V[\x91a\t\xCA`\x03a\t\xC3`\x02\x85\x01a\t>V[\x93\x01a\teV[\x90V[_\x80\xFD[Q\x90V[` \x91\x81R\x01\x90V[\x90\x82_\x93\x92\x82^\x01RV[a\n\x08a\n\x11` \x93a\n\x16\x93a\t\xFF\x81a\t\xD1V[\x93\x84\x80\x93a\t\xD5V[\x95\x86\x91\x01a\t\xDEV[a\x08\xB9V[\x01\x90V[a\n#\x90a\x04\xC2V[\x90RV[a\naa\nh\x94a\nWa\nL``\x95\x99\x98\x96\x99`\x80\x86\x01\x90\x86\x82\x03_\x88\x01Ra\t\xE9V[\x98` \x85\x01\x90a\x05WV[`@\x83\x01\x90a\x05WV[\x01\x90a\n\x1AV[V[4a\n\x9FWa\n\x9Ba\n\x86a\n\x806`\x04a\x07\x1CV[\x90a\trV[\x90a\n\x92\x94\x92\x94a\x03\xA2V[\x94\x85\x94\x85a\n'V[\x03\x90\xF3[a\x03\xA8V[a\n\xAD\x81a\x04\xAFV[\x03a\n\xB4WV[_\x80\xFD[\x90P5\x90a\n\xC5\x82a\n\xA4V[V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x0B\x01W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\n\xFCW` \x01\x92`\x01\x83\x02\x84\x01\x11a\n\xF7WV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90`\xC0\x83\x82\x03\x12a\x0B\x98Wa\x0B\x1E\x81_\x85\x01a\x03\xD5V[\x92a\x0B,\x82` \x83\x01a\x03\xD5V[\x92a\x0B:\x83`@\x84\x01a\n\xB8V[\x92``\x83\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0B\x93W\x81a\x0B[\x91\x85\x01a\n\xC7V[\x92\x90\x93a\x0Bk\x83`\x80\x83\x01a\x03\xD5V[\x92`\xA0\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0B\x8EWa\x0B\x8A\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xB0V[a\x03\xACV[4a\x0B\xD5Wa\x0B\xBFa\x0B\xB06`\x04a\x0B\x06V[\x96\x95\x90\x95\x94\x91\x94\x93\x92\x93a9fV[a\x0B\xC7a\x03\xA2V[\x80a\x0B\xD1\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[_\x91\x03\x12a\x0B\xE4WV[a\x03\xACV[\x90V[a\x0C\0a\x0B\xFBa\x0C\x05\x92a\x0B\xE9V[a\x07IV[a\x03\xB4V[\x90V[a\x0C\x13a\x01,a\x0B\xECV[\x90V[a\x0C\x1Ea\x0C\x08V[\x90V[a\x0C*\x90a\x03\xB4V[\x90RV[\x91\x90a\x0CA\x90_` \x85\x01\x94\x01\x90a\x0C!V[V[4a\x0CsWa\x0CS6`\x04a\x0B\xDAV[a\x0Coa\x0C^a\x0C\x16V[a\x0Cfa\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x0C\x97\x90`\x08a\x0C\x9C\x93\x02a\x0CxV[a\x0C|V[\x90V[\x90a\x0C\xAA\x91Ta\x0C\x87V[\x90V[a\x0C\xB9`\x0B_\x90a\x0C\x9FV[\x90V[a\x0C\xC5\x90a\x03\xEFV[\x90RV[\x91\x90a\x0C\xDC\x90_` \x85\x01\x94\x01\x90a\x0C\xBCV[V[4a\r\x0EWa\x0C\xEE6`\x04a\x0B\xDAV[a\r\na\x0C\xF9a\x0C\xADV[a\r\x01a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[a\r\x1Ea\x01,a\x0B\xECV[\x90V[a\r)a\r\x13V[\x90V[4a\r\\Wa\r<6`\x04a\x0B\xDAV[a\rXa\rGa\r!V[a\rOa\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\r\x92W_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\r\x8DWa\r\x89\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xACV[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\r\xC9a\r\xD2` \x93a\r\xD7\x93a\r\xC0\x81a\t\xD1V[\x93\x84\x80\x93a\x08\x0EV[\x95\x86\x91\x01a\t\xDEV[a\x08\xB9V[\x01\x90V[a\r\xE4\x90a\x05TV[\x90RV[\x90a\x0E\x12\x90` \x80a\x0E\x07`@\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\xAAV[\x94\x01Q\x91\x01\x90a\r\xDBV[\x90V[\x90a\x0E\x1F\x91a\r\xE8V[\x90V[` \x01\x90V[\x90a\x0E<a\x0E5\x83a\r\x97V[\x80\x92a\r\x9BV[\x90\x81a\x0EM` \x83\x02\x84\x01\x94a\r\xA4V[\x92_\x91[\x83\x83\x10a\x0E`WPPPPP\x90V[\x90\x91\x92\x93\x94` a\x0E\x82a\x0E|\x83\x85`\x01\x95\x03\x87R\x89Qa\x0E\x15V[\x97a\x0E\"V[\x93\x01\x93\x01\x91\x93\x92\x90a\x0EQV[a\x0E\xA4\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x0E(V[\x90V[4a\x0E\xD8Wa\x0E\xD4a\x0E\xC3a\x0E\xBD6`\x04a\raV[\x90a9\xB2V[a\x0E\xCBa\x03\xA2V[\x91\x82\x91\x82a\x0E\x8FV[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[\x90V[a\x0F\r\x90a\x0F\x01V[\x90RV[\x91\x90a\x0F$\x90_` \x85\x01\x94\x01\x90a\x0F\x04V[V[4a\x0FVWa\x0F66`\x04a\x0B\xDAV[a\x0FRa\x0FAa\x0E\xDDV[a\x0FIa\x03\xA2V[\x91\x82\x91\x82a\x0F\x11V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x0Fra\x0Fma\x0Fw\x92a\x0F[V[a\x07IV[a\x03\xB4V[\x90V[a\x0F\x85a\x0E\x10a\x0F^V[\x90V[a\x0F\x90a\x0FzV[\x90V[4a\x0F\xC3Wa\x0F\xA36`\x04a\x0B\xDAV[a\x0F\xBFa\x0F\xAEa\x0F\x88V[a\x0F\xB6a\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x90a\x0F\xD2\x90a\x07LV[_R` R`@_ \x90V[a\x0F\xF2a\x0F\xEDa\x0F\xF7\x92a\x03\xE4V[a\x07IV[a\x03\xE4V[\x90V[a\x10\x03\x90a\x0F\xDEV[\x90V[a\x10\x0F\x90a\x0F\xFAV[\x90V[\x90a\x10\x1C\x90a\x10\x06V[_R` R`@_ \x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x10Aa\x10F\x91a\t\"V[a\x10(V[\x90V[a\x10S\x90Ta\x105V[\x90V[`@\x1C\x90V[`\xFF\x16\x90V[a\x10na\x10s\x91a\x10VV[a\x10\\V[\x90V[a\x10\x80\x90Ta\x10bV[\x90V[`H\x1C\x90V[`\xFF\x16\x90V[a\x10\x9Ba\x10\xA0\x91a\x10\x83V[a\x10\x89V[\x90V[a\x10\xAD\x90Ta\x10\x8FV[\x90V[\x90V[a\x10\xBFa\x10\xC4\x91a\t\"V[a\x10\xB0V[\x90V[a\x10\xD1\x90Ta\x10\xB3V[\x90V[\x90a\x10\xE3a\x10\xE8\x92`\x03a\x0F\xC8V[a\x10\x12V[a\x10\xF3_\x82\x01a\t>V[\x91a\x11\0`\x01\x83\x01a\x10IV[\x91a\x11\r`\x01\x82\x01a\x10vV[\x91a\x11&`\x02a\x11\x1F`\x01\x85\x01a\x10\xA3V[\x93\x01a\x10\xC7V[\x90V[a\x112\x90a\x04\xAFV[\x90RV[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[`\x05\x11\x15a\x11TWV[a\x116V[\x90a\x11c\x82a\x11JV[V[a\x11n\x90a\x11YV[\x90V[a\x11z\x90a\x11eV[\x90RV[\x90\x95\x94\x92a\x11\xC9\x94a\x11\xB8a\x11\xC2\x92a\x11\xAE`\x80\x96a\x11\xA4`\xA0\x88\x01\x9C_\x89\x01\x90a\x05WV[` \x87\x01\x90a\x0C!V[`@\x85\x01\x90a\x11)V[``\x83\x01\x90a\x11qV[\x01\x90a\x0F\x04V[V[4a\x12\0Wa\x11\xFCa\x11\xE7a\x11\xE16`\x04a\x04\x1EV[\x90a\x10\xD4V[\x91a\x11\xF3\x95\x93\x95a\x03\xA2V[\x95\x86\x95\x86a\x11~V[\x03\x90\xF3[a\x03\xA8V[4a\x125Wa\x121a\x12 a\x12\x1B6`\x04a\x04\x84V[a9\xCCV[a\x12(a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x12V\x90a\x03\xEFV[\x90RV[\x90a\x12g\x81` \x93a\x12MV[\x01\x90V[` \x01\x90V[\x90a\x12\x8Ea\x12\x88a\x12\x81\x84a\x12:V[\x80\x93a\x12>V[\x92a\x12GV[\x90_[\x81\x81\x10a\x12\x9EWPPP\x90V[\x90\x91\x92a\x12\xB7a\x12\xB1`\x01\x92\x86Qa\x12ZV[\x94a\x12kV[\x91\x01\x91\x90\x91a\x12\x91V[a\x12\xD6\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x12qV[\x90V[4a\x13\tWa\x13\x05a\x12\xF4a\x12\xEF6`\x04a\x04\x84V[a:\x86V[a\x12\xFCa\x03\xA2V[\x91\x82\x91\x82a\x12\xC1V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x13%a\x13 a\x13*\x92a\x13\x0EV[a\x07IV[a\x05TV[\x90V[a\x137`\xC8a\x13\x11V[\x90V[a\x13Ba\x13-V[\x90V[4a\x13uWa\x13U6`\x04a\x0B\xDAV[a\x13qa\x13`a\x13:V[a\x13ha\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x13\x8D\x90_` \x85\x01\x94\x01\x90a\n\x1AV[V[4a\x13\xC0Wa\x13\xBCa\x13\xABa\x13\xA56`\x04a\x04\x1EV[\x90a;&V[a\x13\xB3a\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[\x90a\x13\xCF\x90a\x07LV[_R` R`@_ \x90V[a\x13\xF1\x90a\x13\xEC`\x07\x91_\x92a\x13\xC5V[a\x0C\x9FV[\x90V[4a\x14$Wa\x14 a\x14\x0Fa\x14\n6`\x04a\x04\x84V[a\x13\xDBV[a\x14\x17a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a\x14YWa\x14Ua\x14Da\x14?6`\x04a\x04\x84V[a;\xADV[a\x14La\x03\xA2V[\x91\x82\x91\x82a\x12\xC1V[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[4a\x14\xB2Wa\x14\x926`\x04a\x0B\xDAV[a\x14\xAEa\x14\x9Da\x14^V[a\x14\xA5a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[\x90`\x80\x82\x82\x03\x12a\x15\x12Wa\x14\xCE\x81_\x84\x01a\x03\xD5V[\x92a\x14\xDC\x82` \x85\x01a\x03\xD5V[\x92a\x14\xEA\x83`@\x83\x01a\n\xB8V[\x92``\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x15\rWa\x15\t\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x15IWa\x153a\x15*6`\x04a\x14\xB7V[\x93\x92\x90\x92a<\x1FV[a\x15;a\x03\xA2V[\x80a\x15E\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x15ea\x15`a\x15j\x92a\x15NV[a\x07IV[a\x05TV[\x90V[a\x15w`2a\x15QV[\x90V[a\x15\x82a\x15mV[\x90V[4a\x15\xB5Wa\x15\x956`\x04a\x0B\xDAV[a\x15\xB1a\x15\xA0a\x15zV[a\x15\xA8a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[4a\x15\xEBWa\x15\xE7a\x15\xD6a\x15\xD06`\x04a\x04\x1EV[\x90a<.V[a\x15\xDEa\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x16\x07a\x16\x02a\x16\x0C\x92a\x15\xF0V[a\x07IV[a\x04\xAFV[\x90V[a\x16\x19`\x03a\x15\xF3V[\x90V[a\x16$a\x16\x0FV[\x90V[\x91\x90a\x16:\x90_` \x85\x01\x94\x01\x90a\x11)V[V[4a\x16lWa\x16L6`\x04a\x0B\xDAV[a\x16ha\x16Wa\x16\x1CV[a\x16_a\x03\xA2V[\x91\x82\x91\x82a\x16'V[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x16\x84\x90_` \x85\x01\x94\x01\x90a\x11qV[V[4a\x16\xB7Wa\x16\xB3a\x16\xA2a\x16\x9C6`\x04a\x04\x1EV[\x90a<ZV[a\x16\xAAa\x03\xA2V[\x91\x82\x91\x82a\x16qV[\x03\x90\xF3[a\x03\xA8V[\x90a\x16\xCFa\x16\xC8a\x03\xA2V[\x92\x83a\x08\xD7V[V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x16\xE9W` \x80\x91\x02\x01\x90V[a\x08\xC3V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x17\x18Wa\x17\x14` \x91a\x08\xB9V[\x01\x90V[a\x08\xC3V[\x90\x82_\x93\x92\x827\x01RV[\x90\x92\x91\x92a\x17=a\x178\x82a\x16\xFAV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a\x17YWa\x17W\x92a\x17\x1DV[V[a\x16\xF6V[\x90\x80`\x1F\x83\x01\x12\x15a\x17|W\x81` a\x17y\x935\x91\x01a\x17(V[\x90V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x17\xD4Wa\x17\x98`@a\x16\xBCV[\x92_\x82\x015\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x17\xCFWa\x17\xBC\x82a\x17\xC8\x94\x83\x01a\x17^V[_\x86\x01R` \x01a\x07\rV[` \x83\x01RV[a\x16\xF2V[a\x16\xEEV[\x92\x91\x90a\x17\xEDa\x17\xE8\x82a\x16\xD1V[a\x16\xBCV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11a\x18DW\x81\x90[\x83\x82\x10a\x18\x13WPPPPPV[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x18?W` \x91a\x184\x87\x84\x93\x87\x01a\x17\x81V[\x81R\x01\x91\x01\x90a\x18\x05V[a\x05\xAFV[a\x05\xB7V[\x90\x80`\x1F\x83\x01\x12\x15a\x18gW\x81` a\x18d\x935\x91\x01a\x17\xD9V[\x90V[a\x05\xAFV[`\x80\x81\x83\x03\x12a\x18\xC6Wa\x18\x82\x82_\x83\x01a\x03\xD5V[\x92a\x18\x90\x83` \x84\x01a\x04\x0FV[\x92`@\x83\x015\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a\x18\xC1Wa\x18\xB5\x81a\x18\xBE\x93\x86\x01a\x18IV[\x93``\x01a\x07\rV[\x90V[a\x03\xB0V[a\x03\xACV[4a\x18\xFDWa\x18\xE7a\x18\xDE6`\x04a\x18lV[\x92\x91\x90\x91a@@V[a\x18\xEFa\x03\xA2V[\x80a\x18\xF9\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x19\x19a\x19\x14a\x19\x1E\x92a\x19\x02V[a\x07IV[a\x05TV[\x90V[a\x19+`@a\x19\x05V[\x90V[a\x196a\x19!V[\x90V[4a\x19iWa\x19I6`\x04a\x0B\xDAV[a\x19ea\x19Ta\x19.V[a\x19\\a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[4a\x19\x9CWa\x19~6`\x04a\x0B\xDAV[a\x19\x86aFoV[a\x19\x8Ea\x03\xA2V[\x80a\x19\x98\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x19\xAA\x90a\x11eV[\x90RV[a\x19\xB7\x90a\x0F\x01V[\x90RV[\x90`\x80\x80a\x1A\x13\x93a\x19\xD3_\x82\x01Q_\x86\x01\x90a\r\xDBV[a\x19\xE5` \x82\x01Q` \x86\x01\x90a\x04\xA2V[a\x19\xF7`@\x82\x01Q`@\x86\x01\x90a\x04\xB5V[a\x1A\t``\x82\x01Q``\x86\x01\x90a\x19\xA1V[\x01Q\x91\x01\x90a\x19\xAEV[V[\x91\x90a\x1A(\x90_`\xA0\x85\x01\x94\x01\x90a\x19\xBBV[V[4a\x1A[Wa\x1AWa\x1AFa\x1A@6`\x04a\x04\x1EV[\x90aG\xACV[a\x1ANa\x03\xA2V[\x91\x82\x91\x82a\x1A\x15V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\x91Wa\x1A\x8Da\x1A|a\x1Av6`\x04a\x04\x1EV[\x90aH\x04V[a\x1A\x84a\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xC4Wa\x1A\xA66`\x04a\x0B\xDAV[a\x1A\xAEaH,V[a\x1A\xB6a\x03\xA2V[\x80a\x1A\xC0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xF9Wa\x1A\xF5a\x1A\xE4a\x1A\xDF6`\x04a\x04\x84V[aH}V[a\x1A\xECa\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a\x1B3Wa\x1B0a\x1B\x19\x84_\x85\x01a\x03\xD5V[\x93a\x1B'\x81` \x86\x01a\x07\rV[\x93`@\x01a\x07\rV[\x90V[a\x03\xACV[\x92\x91` a\x1BTa\x1B\\\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\x12qV[\x94\x01\x90a\x05WV[V[4a\x1B\x90Wa\x1Bwa\x1Bq6`\x04a\x1A\xFEV[\x91aI\x1BV[\x90a\x1B\x8Ca\x1B\x83a\x03\xA2V[\x92\x83\x92\x83a\x1B8V[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xC3Wa\x1B\xADa\x1B\xA86`\x04a\x06\xA8V[aJ\xA2V[a\x1B\xB5a\x03\xA2V[\x80a\x1B\xBF\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xF8Wa\x1B\xD86`\x04a\x0B\xDAV[a\x1B\xF4a\x1B\xE3aJ\xB1V[a\x1B\xEBa\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1C7W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1C2W` \x01\x92` \x83\x02\x84\x01\x11a\x1C-WV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x1C}Wa\x1CU\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1CxWa\x1Ct\x92\x01a\x1B\xFDV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1C\xB1Wa\x1C\x9Ba\x1C\x956`\x04a\x1C<V[\x91aK8V[a\x1C\xA3a\x03\xA2V[\x80a\x1C\xAD\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x91``\x83\x83\x03\x12a\x1D\x02Wa\x1C\xCD\x82_\x85\x01a\x03\xD5V[\x92a\x1C\xDB\x83` \x83\x01a\x04\x0FV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1C\xFDWa\x1C\xFA\x92\x01a\x17^V[\x90V[a\x03\xB0V[a\x03\xACV[\x90a\x1D\x11\x90a\x07LV[_R` R`@_ \x90V[\x90a\x1D'\x90a\x10\x06V[_R` R`@_ \x90V[\x90P\x90V[a\x1D]a\x1DT\x92` \x92a\x1DK\x81a\t\xD1V[\x94\x85\x80\x93a\x1D3V[\x93\x84\x91\x01a\t\xDEV[\x01\x90V[\x90V[a\x1Dpa\x1Du\x91a\x05TV[a\x1DaV[\x90RV[a\x1D\x89a\x1D\x90\x91` \x94\x93a\x1D8V[\x80\x92a\x1DdV[\x01\x90V[a\x1D\xA8a\x1D\x9Fa\x03\xA2V[\x92\x83\x92\x83a\x1DyV[\x03\x90 \x90V[a\x1D\xB7\x91a\x1D\x94V[\x90V[a\x1D\xCA\x90`\x08a\x1D\xCF\x93\x02a\x0CxV[a\t'V[\x90V[\x90a\x1D\xDD\x91Ta\x1D\xBAV[\x90V[\x90a\x1E\x08\x92a\x1D\xFEa\x1E\x03\x92a\x1D\xF9`\t\x95_\x96a\x1D\x07V[a\x1D\x1DV[a\x1D\xAEV[a\x1D\xD2V[\x90V[4a\x1E<Wa\x1E8a\x1E'a\x1E!6`\x04a\x1C\xB6V[\x91a\x1D\xE0V[a\x1E/a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1E{W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1EvW` \x01\x92`\x01\x83\x02\x84\x01\x11a\x1EqWV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91``\x83\x83\x03\x12a\x1E\xCDWa\x1E\x97\x82_\x85\x01a\x03\xD5V[\x92a\x1E\xA5\x83` \x83\x01a\x04\x0FV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1E\xC8Wa\x1E\xC4\x92\x01a\x1EAV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1F\x04Wa\x1E\xEEa\x1E\xE56`\x04a\x1E\x80V[\x92\x91\x90\x91aM\x9DV[a\x1E\xF6a\x03\xA2V[\x80a\x1F\0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x1F\x12\x81a\x04\xC2V[\x03a\x1F\x19WV[_\x80\xFD[\x90P5\x90a\x1F*\x82a\x1F\tV[V[\x91\x90\x91`\xA0\x81\x84\x03\x12a\x1F\x98Wa\x1FE\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1F\x93W\x81a\x1Ff\x91\x84\x01a\x1EAV[\x92\x90\x93a\x1F\x90a\x1Fy\x84`@\x85\x01a\x07\rV[\x93a\x1F\x87\x81``\x86\x01a\x07\rV[\x93`\x80\x01a\x1F\x1DV[\x90V[a\x03\xB0V[a\x03\xACV[4a\x1F\xD2Wa\x1F\xBCa\x1F\xB06`\x04a\x1F,V[\x94\x93\x90\x93\x92\x91\x92aPrV[a\x1F\xC4a\x03\xA2V[\x80a\x1F\xCE\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a \x05Wa\x1F\xEFa\x1F\xEA6`\x04a\x04\x84V[aT'V[a\x1F\xF7a\x03\xA2V[\x80a \x01\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a ?Wa <a %\x84_\x85\x01a\x03\xD5V[\x93a 3\x81` \x86\x01a\x03\xD5V[\x93`@\x01a\n\xB8V[\x90V[a\x03\xACV[4a sWa ]a W6`\x04a \nV[\x91aV\x9CV[a ea\x03\xA2V[\x80a o\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a \xA7Wa \x91a \x8B6`\x04a\x04\x1EV[\x90aX[V[a \x99a\x03\xA2V[\x80a \xA3\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[\x90a!\r\x90``\x80a \xDE`\x80\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\xAAV[\x94a \xF1` \x82\x01Q` \x86\x01\x90a\r\xDBV[a!\x03`@\x82\x01Q`@\x86\x01\x90a\r\xDBV[\x01Q\x91\x01\x90a\x04\xC7V[\x90V[\x90a!\x1A\x91a \xBFV[\x90V[` \x01\x90V[\x90a!7a!0\x83a \xACV[\x80\x92a \xB0V[\x90\x81a!H` \x83\x02\x84\x01\x94a \xB9V[\x92_\x91[\x83\x83\x10a![WPPPPP\x90V[\x90\x91\x92\x93\x94` a!}a!w\x83\x85`\x01\x95\x03\x87R\x89Qa!\x10V[\x97a!\x1DV[\x93\x01\x93\x01\x91\x93\x92\x90a!LV[a!\x9F\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra!#V[\x90V[4a!\xD2Wa!\xCEa!\xBDa!\xB86`\x04a\x04\x84V[a[\xD2V[a!\xC5a\x03\xA2V[\x91\x82\x91\x82a!\x8AV[\x03\x90\xF3[a\x03\xA8V[4a\"\x05Wa!\xEFa!\xEA6`\x04a\x04\x84V[a]bV[a!\xF7a\x03\xA2V[\x80a\"\x01\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\"\x16`\n_\x90a\x0C\x9FV[\x90V[4a\"IWa\")6`\x04a\x0B\xDAV[a\"Ea\"4a\"\nV[a\"<a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a\"\x82Wa\"~a\"ma\"d6`\x04a\x1E\x80V[\x92\x91\x90\x91a]\xCFV[a\"ua\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90a\"\x91\x90a\x07LV[_R` R`@_ \x90V[a\"\xA9a\"\xAE\x91a\x10\x83V[a\tKV[\x90V[a\"\xBB\x90Ta\"\x9DV[\x90V[a\"\xC9\x90`\x02a\"\x87V[a\"\xD4_\x82\x01a\x10IV[\x91a\"\xEB_a\"\xE4\x81\x85\x01a\x10vV[\x93\x01a\"\xB1V[\x90V[`@\x90a#\x17a#\x1E\x94\x96\x95\x93\x96a#\r``\x84\x01\x98_\x85\x01\x90a\x0C!V[` \x83\x01\x90a\x11)V[\x01\x90a\n\x1AV[V[4a#SWa#Oa#;a#66`\x04a\x04\x84V[a\"\xBEV[a#F\x93\x91\x93a\x03\xA2V[\x93\x84\x93\x84a\"\xEEV[\x03\x90\xF3[a\x03\xA8V[4a#\x88Wa#h6`\x04a\x0B\xDAV[a#\x84a#sa^\x04V[a#{a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a#\xBCWa#\xA6a#\xA06`\x04a\x04\x1EV[\x90a^\xEEV[a#\xAEa\x03\xA2V[\x80a#\xB8\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a#\xF2Wa#\xEEa#\xDDa#\xD76`\x04a\x04\x1EV[\x90a`\x83V[a#\xE5a\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[4a$%Wa$\x0Fa$\n6`\x04a\x06\xA8V[aa\x82V[a$\x17a\x03\xA2V[\x80a$!\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x91\x90`@\x83\x82\x03\x12a$RW\x80a$Fa$O\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x1F\x1DV[\x90V[a\x03\xACV[4a$\x86Wa$pa$j6`\x04a$*V[\x90aa\x8DV[a$xa\x03\xA2V[\x80a$\x82\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x7F2r\x1F\x8D\xC6~\x95<T\r\xA9\x0Ff0Y\xC2?\xC4\x7Fp\xD1\x1E1~\xD6\xD5\xA2L\x8B\x85ct\x90V[a$\xB7a$\x8BV[\x90V[4a$\xEAWa$\xCA6`\x04a\x0B\xDAV[a$\xE6a$\xD5a$\xAFV[a$\xDDa\x03\xA2V[\x91\x82\x91\x82a\x0F\x11V[\x03\x90\xF3[a\x03\xA8V[4a%\x1EWa%\x08a%\x026`\x04a\x04\x1EV[\x90abVV[a%\x10a\x03\xA2V[\x80a%\x1A\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x7FOnly Tangle core\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%[`\x10` \x92a\t\xD5V[a%d\x81a%'V[\x01\x90V[a%}\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%NV[\x90V[\x15a%\x87WV[a%\x8Fa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a%\xA5`\x04\x82\x01a%hV[\x03\x90\xFD[a%\xB5a%\xBA\x91a\t\"V[a\x0C|V[\x90V[a%\xC7\x90Ta%\xA9V[\x90V[\x90V[a%\xE1a%\xDCa%\xE6\x92a%\xCAV[a\x07IV[a\x03\xE4V[\x90V[a%\xF2\x90a%\xCDV[\x90V[_\x7FAlready registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a&)`\x12` \x92a\t\xD5V[a&2\x81a%\xF5V[\x01\x90V[a&K\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra&\x1CV[\x90V[\x15a&UWV[a&]a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a&s`\x04\x82\x01a&6V[\x03\x90\xFD[_\x1B\x90V[\x90a&\x8D`\x01\x80`\xA0\x1B\x03\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90a&\xAFa&\xAAa&\xB6\x92a\x10\x06V[a&\x97V[\x82Ta&|V[\x90UV[a'<a'A\x92a&\xFD3a&\xF7a&\xF1\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[a'4a'\x14a'\x0F`\x07\x86\x90a\x13\xC5V[a%\xBDV[a'.a'(a'#_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14a&NV[\x91`\x07a\x13\xC5V[a&\x9AV[V[a'M``a\x16\xBCV[\x90V[_\x90V[_\x90V[_\x90V[a'da'CV[\x90` \x80\x80\x84a'ra'PV[\x81R\x01a'}a'TV[\x81R\x01a'\x88a'XV[\x81RPPV[a'\x96a'\\V[\x90V[a'\xAB\x90a'\xA5a'\x8EV[Pac~V[\x90V[_\x90V[a'\xD3a'\xD9\x92a'\xCE_\x93a'\xC6a'\xAEV[P`\x03a\x0F\xC8V[a\x10\x12V[\x01a\t>V[\x90V[_\x7FNot service owner\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(\x10`\x11` \x92a\t\xD5V[a(\x19\x81a'\xDCV[\x01\x90V[a(2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x03V[\x90V[\x15a(<WV[a(Da\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(Z`\x04\x82\x01a(\x1DV[\x03\x90\xFD[P\x90V[_\x7FToo many definitions\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(\x96`\x14` \x92a\t\xD5V[a(\x9F\x81a(bV[\x01\x90V[a(\xB8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x89V[\x90V[\x15a(\xC2WV[a(\xCAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(\xE0`\x04\x82\x01a(\xA3V[\x03\x90\xFD[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[a)\x07a)\r\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x91a)\x19\x83\x82\x02a\x05TV[\x92\x81\x84\x04\x14\x90\x15\x17\x15a)(WV[a(\xE4V[a)8\x90`\x04a(\xF8V[\x90V[\x90a)N\x90_\x19\x90` \x03`\x08\x02a\x0CxV[\x81T\x16\x90UV[\x1B\x90V[\x91\x90`\x08a)t\x91\x02\x91a)n_\x19\x84a)UV[\x92a)UV[\x91\x81\x19\x16\x91\x16\x17\x90V[a)\x92a)\x8Da)\x97\x92a\x05TV[a\x07IV[a\x05TV[\x90V[\x90V[\x91\x90a)\xB3a)\xAEa)\xBB\x93a)~V[a)\x9AV[\x90\x83Ta)YV[\x90UV[a)\xD1\x91a)\xCBa'\xAEV[\x91a)\x9DV[V[[\x81\x81\x10a)\xDFWPPV[\x80a)\xEC_`\x01\x93a)\xBFV[\x01a)\xD4V[\x90a*\x02\x90_\x19\x90`\x08\x02a\x0CxV[\x19\x16\x90V[\x81a*\x11\x91a)\xF2V[\x90`\x02\x02\x17\x90V[\x90_\x91a*0a*(\x82a\x08\x17V[\x92\x83Ta*\x07V[\x90UUV[`\x1F` \x91\x01\x04\x90V[\x91\x92\x90` \x82\x10_\x14a*\x98W`\x1F\x84\x11`\x01\x14a*hWa*b\x92\x93Pa*\x07V[\x90U[[V[P\x90a*\x8Ea*\x93\x93`\x01a*\x85a*\x7F\x85a\x08\x17V[\x92a*5V[\x82\x01\x91\x01a)\xD3V[a*\x19V[a*eV[Pa*\xCF\x82\x93a*\xA9`\x01\x94a\x08\x17V[a*\xC8a*\xB5\x85a*5V[\x82\x01\x92`\x1F\x86\x16\x80a*\xDAW[Pa*5V[\x01\x90a)\xD3V[`\x02\x02\x17\x90Ua*fV[a*\xE6\x90\x88\x86\x03a);V[_a*\xC2V[\x92\x90\x91h\x01\0\0\0\0\0\0\0\0\x82\x11a+LW` \x11_\x14a+=W` \x81\x10_\x14a+!Wa+\x1B\x91a*\x07V[\x90U[[V[`\x01\x91`\xFF\x19\x16a+1\x84a\x08\x17V[U`\x02\x02\x01\x90Ua+\x1EV[`\x01\x91P`\x02\x02\x01\x90Ua+\x1FV[a\x08\xC3V[\x90\x81Ta+]\x81a\x07\xE4V[\x90\x81\x83\x11a+\x86W[\x81\x83\x10a+tW[PPPPV[a+}\x93a*?V[_\x80\x80\x80a+nV[a+\x92\x83\x83\x83\x87a*\xECV[a+fV[_a+\xA1\x91a+QV[V[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[\x90_\x03a+\xC8Wa+\xC6\x90a+\x97V[V[a+\xA3V[`\x03_\x91a+\xDD\x83\x80\x83\x01a+\xB6V[a+\xEA\x83`\x01\x83\x01a)\xBFV[a+\xF7\x83`\x02\x83\x01a)\xBFV[\x01UV[\x90_\x03a,\rWa,\x0B\x90a+\xCDV[V[a+\xA3V[[\x81\x81\x10a,\x1EWPPV[\x80a,+_`\x04\x93a+\xFBV[\x01a,\x13V[\x90\x91\x82\x81\x10a,@W[PPPV[a,^a,Xa,Ra,i\x95a)-V[\x92a)-V[\x92a\x07\x96V[\x91\x82\x01\x91\x01\x90a,\x12V[_\x80\x80a,;V[\x90h\x01\0\0\0\0\0\0\0\0\x81\x11a,\x9AW\x81a,\x8Fa,\x98\x93a\x07\x92V[\x90\x82\x81Ua,1V[V[a\x08\xC3V[_a,\xA9\x91a,qV[V[\x90_\x03a,\xBDWa,\xBB\x90a,\x9FV[V[a+\xA3V[a,\xD6a,\xD1a,\xDB\x92a%\xCAV[a\x07IV[a\x05TV[\x90V[`\x01a,\xEA\x91\x01a\x05TV[\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x905\x90`\x01`\x80\x03\x816\x03\x03\x82\x12\x15a-\x10W\x01\x90V[a,\xEDV[\x90\x82\x10\x15a-/W` a-,\x92\x02\x81\x01\x90a,\xF9V[\x90V[a\x07~V[\x905\x90`\x01` \x03\x816\x03\x03\x82\x12\x15a-vW\x01\x805\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a-qW` \x01\x91`\x01\x82\x026\x03\x83\x13a-lWV[a,\xF5V[a,\xF1V[a,\xEDV[\x91V[P\x90V[_\x7FName too long\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-\xB6`\r` \x92a\t\xD5V[a-\xBF\x81a-\x82V[\x01\x90V[a-\xD8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-\xA9V[\x90V[\x15a-\xE2WV[a-\xEAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.\0`\x04\x82\x01a-\xC3V[\x03\x90\xFD[5a.\x0E\x81a\x06\xF9V[\x90V[_\x7FInvalid bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a.E`\x0E` \x92a\t\xD5V[a.N\x81a.\x11V[\x01\x90V[a.g\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra.8V[\x90V[\x15a.qWV[a.ya\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.\x8F`\x04\x82\x01a.RV[\x03\x90\xFD[\x90V[_R` _ \x90V[T\x90V[a.\xAC\x81a.\x9FV[\x82\x10\x15a.\xC6Wa.\xBE`\x04\x91a.\x96V[\x91\x02\x01\x90_\x90V[a\x07~V[P\x90V[\x91\x90`\x1F\x81\x11a.\xDFW[PPPV[a.\xEBa/\x10\x93a\x08\x17V[\x90` a.\xF7\x84a*5V[\x83\x01\x93\x10a/\x18W[a/\t\x90a*5V[\x01\x90a)\xD3V[_\x80\x80a.\xDAV[\x91Pa/\t\x81\x92\x90Pa/\0V[\x91a/1\x90\x82a.\xCBV[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a/\xF0Wa/U\x82a/O\x85Ta\x07\xE4V[\x85a.\xCFV[_\x90`\x1F\x83\x11`\x01\x14a/\x88W\x91\x80\x91a/w\x93_\x92a/|W[PPa*\x07V[\x90U[V[\x90\x91P\x015_\x80a/pV[`\x1F\x19\x83\x16\x91a/\x97\x85a\x08\x17V[\x92_[\x81\x81\x10a/\xD8WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10a/\xBEW[PPP\x02\x01\x90Ua/zV[a/\xCE\x91\x015`\x1F\x84\x16\x90a)\xF2V[\x90U_\x80\x80a/\xB2V[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a/\x9AV[a\x08\xC3V[\x90a0\0\x92\x91a/&V[V[\x90a0\x0E_\x19\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a0-a0(a04\x92a)~V[a)\x9AV[\x82Ta0\x02V[\x90UV[5a0B\x81a\x1F\tV[\x90V[\x90a0Q`\xFF\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[a0d\x90a\x04\xC2V[\x90V[\x90V[\x90a0\x7Fa0za0\x86\x92a0[V[a0gV[\x82Ta0EV[\x90UV[\x90a0\xE8```\x03a0\xEE\x94a0\xAE_\x82\x01a0\xA8_\x88\x01\x88a-4V[\x91a/\xF5V[a0\xC7`\x01\x82\x01a0\xC1` \x88\x01a.\x04V[\x90a0\x18V[a0\xE0`\x02\x82\x01a0\xDA`@\x88\x01a.\x04V[\x90a0\x18V[\x01\x92\x01a08V[\x90a0jV[V[\x91\x90a1\x01Wa0\xFF\x91a0\x8AV[V[a+\xA3V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15a16W\x82a1.\x91`\x01a14\x95\x01\x81Ua.\xA3V[\x90a0\xF0V[V[a\x08\xC3V[\x92\x91\x90\x92a1n3a1ha1ba1]a1X`\x07\x87\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[a1\x9Ca1|\x85\x84\x90a(^V[a1\x95a1\x8Fa1\x8Aa\x15mV[a\x05TV[\x91a\x05TV[\x11\x15a(\xBBV[a1\xB1_a1\xAC`\x08\x84\x90a\x07hV[a,\xABV[a1\xBA_a,\xC2V[[\x80a1\xD8a1\xD2a1\xCD\x88\x87\x90a(^V[a\x05TV[\x91a\x05TV[\x10\x15a2\xABWa2\xA6\x90a2/a2\x0Fa2\ta2\x03a1\xFA\x8A\x89\x87\x91a-\x15V[_\x81\x01\x90a-4V[\x90a-{V[\x90a-~V[a2(a2\"a2\x1Da\x19!V[a\x05TV[\x91a\x05TV[\x11\x15a-\xDBV[a2xa2I`@a2C\x89\x88\x86\x91a-\x15V[\x01a.\x04V[a2qa2ka2f` a2`\x8C\x8B\x89\x91a-\x15V[\x01a.\x04V[a\x05TV[\x91a\x05TV[\x10\x15a.jV[a2\xA1a2\x8Fa2\x8A`\x08\x86\x90a\x07hV[a.\x93V[a2\x9B\x88\x87\x85\x91a-\x15V[\x90a1\x06V[a,\xDEV[a1\xBBV[PPP\x90PV[_\x7FZero address\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a2\xE6`\x0C` \x92a\t\xD5V[a2\xEF\x81a2\xB2V[\x01\x90V[a3\x08\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra2\xD9V[\x90V[\x15a3\x12WV[a3\x1Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a30`\x04\x82\x01a2\xF3V[\x03\x90\xFD[\x90a3>\x90a\x07LV[_R` R`@_ \x90V[\x90V[`H\x1B\x90V[\x90a3hi\xFF\0\0\0\0\0\0\0\0\0\x91a3MV[\x91\x81\x19\x16\x91\x16\x17\x90V[a3{\x90a\x11YV[\x90V[\x90V[\x90a3\x96a3\x91a3\x9D\x92a3rV[a3~V[\x82Ta3SV[\x90UV[a3\xDD3a3\xD7a3\xD1\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[a4\x02\x82a3\xFBa3\xF5a3\xF0_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14\x15a3\x0BV[a4(a4#a4\x1Ca4\x17`\x06\x85\x90a34V[a3JV[\x84\x90ad\\V[a&NV[a4K`\x02`\x01a4Ea4>`\x03\x86\x90a\x0F\xC8V[\x86\x90a\x10\x12V[\x01a3\x81V[\x90a4\x7Fa4y\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK\x93a\x07LV[\x91a\x10\x06V[\x91a4\x88a\x03\xA2V[\x80a4\x92\x81a\x04KV[\x03\x90\xA3V[a4\xA8\x90a4\xA3ad\x96V[a4\xAAV[V[a4\xB5\x90`\x0Ba&\x9AV[V[a4\xC0\x90a4\x97V[V[_\x7FNot registered operator\0\0\0\0\0\0\0\0\0\x91\x01RV[a4\xF6`\x17` \x92a\t\xD5V[a4\xFF\x81a4\xC2V[\x01\x90V[a5\x18\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra4\xE9V[\x90V[\x15a5\"WV[a5*a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a5@`\x04\x82\x01a5\x03V[\x03\x90\xFD[\x90a5y\x97\x96\x95\x94\x93\x92\x91a5ta5oa5ha5c\x84`\x06a34V[a3JV[3\x90ad\xE4V[a5\x1BV[a7\xBAV[V[a5\x8Fa5\x8Aa5\x94\x92a\x03\xB4V[a\x07IV[a\x05TV[\x90V[a5\xABa5\xA6a5\xB0\x92a\x05TV[a\x07IV[a\x03\xB4V[\x90V[\x91` a5\xD4\x92\x94\x93a5\xCD`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x0C!V[V[a5\xE5a5\xEB\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x82\x03\x91\x82\x11a5\xF6WV[a(\xE4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a6\x19Wa6\x15` \x91a\x08\xB9V[\x01\x90V[a\x08\xC3V[\x90\x92\x91\x92a63a6.\x82a5\xFBV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a6OWa6M\x92a\x17\x1DV[V[a\x16\xF6V[a6_\x916\x91a6\x1EV[\x90V[` \x01\x90V[Q\x90V[\x94\x92\x90\x97\x96\x95\x93\x91`\xE0\x86\x01\x98_\x87\x01a6\x85\x91a\x0F\x04V[` \x86\x01a6\x92\x91a\x0C\xBCV[`@\x85\x01a6\x9F\x91a\x0C!V[``\x84\x01a6\xAC\x91a\x0C!V[`\x80\x83\x01a6\xB9\x91a\x11)V[`\xA0\x82\x01a6\xC6\x91a\x0F\x04V[`\xC0\x01a6\xD2\x91a\x0C!V[V[_a\x19\x01`\xF0\x1B\x91\x01RV[a6\xEC`\x02\x80\x92a\x1D3V[a6\xF5\x81a6\xD4V[\x01\x90V[\x90V[a7\x08a7\r\x91a\x0F\x01V[a6\xF9V[\x90RV[` \x80\x93\x92a7,a7%a74\x94a6\xE0V[\x80\x92a6\xFCV[\x01\x80\x92a6\xFCV[\x01\x90V[_\x7FInvalid signature\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a7l`\x11` \x92a\t\xD5V[a7u\x81a78V[\x01\x90V[a7\x8E\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra7_V[\x90V[\x15a7\x98WV[a7\xA0a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a7\xB6`\x04\x82\x01a7yV[\x03\x90\xFD[\x91\x92\x93\x94\x97\x96\x90\x95\x97\x80a7\xD6a7\xD0Ba\x05TV[\x91a5{V[\x11a9>Wa7\xEEBa7\xE8\x83a5{V[\x90a5\xD6V[a8\x07a8\x01a7\xFCa\r\x13V[a5{V[\x91a\x05TV[\x11a9\x16Wa9\x14\x97\x98a8\xEBa9\t\x93\x85a8u\x8Aa8f\x8Da8\xF1\x98\x8D\x8Da8=a82a$\x8BV[\x963\x99\x95\x92\x93a6TV[a8Oa8I\x82a6hV[\x91a6bV[ \x92\x93a8Za\x03\xA2V[\x98\x89\x97` \x89\x01a6lV[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD7V[a8\x87a8\x81\x82a6hV[\x91a6bV[ a8\xD2\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a8\xC3a8\xB7a\x03\xA2V[\x93\x84\x92` \x84\x01a7\x11V[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD7V[a8\xE4a8\xDE\x82a6hV[\x91a6bV[ \x92a6TV[\x90ae\x1EV[a9\x03a8\xFD3a\x03\xEFV[\x91a\x03\xEFV[\x14a7\x91V[\x933\x91\x92\x93\x94af\xB5V[V[a9\x1FBa5\x97V[\x90a9:_\x92\x83\x92c\x185[u`\xE2\x1B\x84R`\x04\x84\x01a5\xB3V[\x03\x90\xFD[a9GBa5\x97V[\x90a9b_\x92\x83\x92cW\xEA\x02\xE9`\xE0\x1B\x84R`\x04\x84\x01a5\xB3V[\x03\x90\xFD[\x90a9v\x97\x96\x95\x94\x93\x92\x91a5DV[V[``\x90V[\x90` \x82\x82\x03\x12a9\xADW_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a9\xA8Wa9\xA5\x92\x01a\x18IV[\x90V[a\x03\xB0V[a\x03\xACV[\x90a9\xC9\x91a9\xBFa9xV[P\x90\x81\x01\x90a9}V[\x90V[a9\xEBa9\xE6a9\xF0\x92a9\xDEa'\xAEV[P`\x05a34V[a3JV[aj\xC7V[\x90V[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a:\x10W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a:'a:\"\x83a9\xF8V[a\x16\xBCV[\x91\x82RV[6\x907V[\x90a:Va:>\x83a:\x15V[\x92` \x80a:L\x86\x93a9\xF8V[\x92\x01\x91\x03\x90a:,V[V[\x90a:b\x82a\x12:V[\x81\x10\x15a:sW` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90a:\x82\x90a\x03\xEFV[\x90RV[\x90a:\x8Fa9\xF3V[Pa:\xACa:\xA7a:\xA2`\x04\x85\x90a34V[a3JV[aj\xC7V[\x91a:\xB6\x83a:1V[\x91a:\xC0_a,\xC2V[[\x80a:\xD4a:\xCE\x87a\x05TV[\x91a\x05TV[\x10\x15a;\x1BWa;\x16\x90a;\x11a:\xFFa:\xF8a:\xF3`\x04\x88\x90a34V[a3JV[\x83\x90ak\x16V[a;\x0C\x87\x91\x84\x90\x92a:XV[a:xV[a,\xDEV[a:\xC1V[P\x92PP\x90V[_\x90V[\x90a;/a;\"V[Pa;Q`\x01a;Ka;D`\x03\x86\x90a\x0F\xC8V[\x84\x90a\x10\x12V[\x01a\x10\xA3V[a;ca;]_a\x11YV[\x91a\x11YV[\x14\x91\x82\x15a;qW[PP\x90V[a;\x92\x92P`\x01\x91a;\x87a;\x8C\x92`\x03a\x0F\xC8V[a\x10\x12V[\x01a\x10\xA3V[a;\xA5a;\x9F`\x01a\x11YV[\x91a\x11YV[\x14_\x80a;lV[a;\xD3\x90a;\xB9a9\xF3V[P_\x90a;\xCDa;\xC7a\x13-V[\x92a,\xC2V[\x90aI\x1BV[P\x90V[\x90a<\t\x94\x93\x92\x91a<\x04a;\xFFa;\xF8a;\xF3\x84`\x06a34V[a3JV[3\x90ad\xE4V[a5\x1BV[a<\x0BV[V[\x91a<\x1D\x94\x92\x93\x913\x91\x92\x93\x94af\xB5V[V[\x90a<,\x94\x93\x92\x91a;\xD7V[V[\x90a<Na<Ia<S\x93a<Aa;\"V[P`\x06a34V[a3JV[ad\xE4V[\x90V[_\x90V[a<|a<\x82\x92a<w`\x01\x93a<oa<VV[P`\x03a\x0F\xC8V[a\x10\x12V[\x01a\x10\xA3V[\x90V[a<\x8E\x90a\x0F\xFAV[\x90V[_\x7FInternal only\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a<\xC5`\r` \x92a\t\xD5V[a<\xCE\x81a<\x91V[\x01\x90V[a<\xE7\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra<\xB8V[\x90V[\x15a<\xF1WV[a<\xF9a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a=\x0F`\x04\x82\x01a<\xD2V[\x03\x90\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a=+W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a=Ba==\x83a=\x13V[a\x16\xBCV[\x91\x82RV[6\x907V[\x90a=qa=Y\x83a=0V[\x92` \x80a=g\x86\x93a=\x13V[\x92\x01\x91\x03\x90a=GV[V[\x90a=}\x82a\r\x97V[\x81\x10\x15a=\x8EW` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90V[Q\x90V[\x90a=\xA4\x82a=\x96V[\x81\x10\x15a=\xB5W` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90a=\xC4\x90a\x0F\x01V[\x90RV[``\x90V[\x90V[` \x91\x81R\x01\x90V[\x90_\x92\x91\x80T\x90a=\xF3a=\xEC\x83a\x07\xE4V[\x80\x94a=\xD0V[\x91`\x01\x81\x16\x90\x81_\x14a>JWP`\x01\x14a>\x0EW[PPPV[a>\x1B\x91\x92\x93\x94Pa\x07\x9FV[\x91_\x92[\x81\x84\x10a>2WPP\x01\x90_\x80\x80a>\tV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a>\x1FV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a>\tV[\x90a>o\x91a=\xD9V[\x90V[\x90a>\x92a>\x8B\x92a>\x82a\x03\xA2V[\x93\x84\x80\x92a>eV[\x03\x83a\x08\xD7V[V[a>\x9D\x90a>rV[\x90V[a>\xAA\x90Qa\x0F\x01V[\x90V[a>\xB7\x90Qa\x05TV[\x90V[_\x7FValue out of bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a>\xEE`\x13` \x92a\t\xD5V[a>\xF7\x81a>\xBAV[\x01\x90V[a?\x13a?!\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra\t\xE9V[\x90` \x81\x83\x03\x91\x01Ra>\xE1V[\x90V[\x92\x91` a?@a?H\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\t\xE9V[\x94\x01\x90a\x05WV[V[\x90_\x92\x91\x80T\x90a?da?]\x83a\x07\xE4V[\x80\x94a\t\xD5V[\x91`\x01\x81\x16\x90\x81_\x14a?\xBBWP`\x01\x14a?\x7FW[PPPV[a?\x8C\x91\x92\x93\x94Pa\x08\x17V[\x91_\x92[\x81\x84\x10a?\xA3WPP\x01\x90_\x80\x80a?zV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a?\x90V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a?zV[_\x7FRequired metric missing\0\0\0\0\0\0\0\0\0\x91\x01RV[a@\n`\x17` \x92a\t\xD5V[a@\x13\x81a?\xD6V[\x01\x90V[a@/a@=\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra?JV[\x90` \x81\x83\x03\x91\x01Ra?\xFDV[\x90V[\x92\x93\x90\x93a@h3a@ba@\\a@W0a<\x85V[a\x03\xEFV[\x91a\x03\xEFV[\x14a<\xEAV[a@|a@w`\x08\x86\x90a\x07hV[a.\x93V[\x94a@\x86\x82a=LV[\x94a@\x90_a,\xC2V[[\x80a@\xA4a@\x9E\x86a\x05TV[\x91a\x05TV[\x10\x15a@\xF7Wa@\xF2\x90a@\xEDa@\xC8_a@\xC0\x8A\x85\x90a=sV[Q\x01Qa=\x93V[a@\xDAa@\xD4\x82a6hV[\x91a6bV[ a@\xE8\x8A\x91\x84\x90\x92a=\x9AV[a=\xBAV[a,\xDEV[a@\x91V[P\x91\x94\x90\x92\x95aA\x06\x81a.\x9FV[aA\x18aA\x12_a,\xC2V[\x91a\x05TV[\x11\x96aA\"a=\xC8V[\x90\x88aE\xA2W[aA2_a,\xC2V[[\x80aAFaA@\x8Ba\x05TV[\x91a\x05TV[\x10\x15aD\x05W`\x01_\x8BaB9W[P\x90\x88\x87\x89aAk\x94aApW[PPPa,\xDEV[aA3V[\x82_aA\xAEaA\xA6aA\xB7\x94aA\xA1aA\x99` aA\x92aA\xBC\x9B\x8D\x90a=sV[Q\x01a>\xADV[\x97`\ta\x1D\x07V[a\x1D\x1DV[\x92\x87\x90a=sV[Q\x01Q\x90a\x1D\xAEV[a0\x18V[\x88\x87\x89\x90aA\xE6` aA\xDF_aA\xD4\x87\x89\x90a=sV[Q\x01Q\x95\x87\x90a=sV[Q\x01a>\xADV[aB\x19aB\x13\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD\x93a\x07LV[\x93a\x10\x06V[\x93aB.aB%a\x03\xA2V[\x92\x83\x92\x83a?$V[\x03\x90\xA3\x88\x87\x89aAcV[\x9A\x90\x95\x92\x91\x99aBH_a,\xC2V[[\x80aBdaB^aBY\x8Aa.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aC\xEFWaB|aBw\x8D\x87a=\x9AV[a>\xA0V[aB\xA0aB\x9AaB\x95aB\x90\x8A\x86\x90a=\x9AV[a>\xA0V[a\x0F\x01V[\x91a\x0F\x01V[\x14aB\xB3WaB\xAE\x90a,\xDEV[aBIV[\x8A\x91\x9B\x92\x9CP\x89aAk\x94\x95\x98\x8A\x92`\x01\x90\x8AaB\xDD` aB\xD6\x89\x8B\x90a=sV[Q\x01a>\xADV[aC\x05aB\xFFaB\xFA`\x01aB\xF3\x86\x88\x90a.\xA3V[P\x01a\t>V[a\x05TV[\x91a\x05TV[\x10\x91\x88\x88\x84\x15aC\xA5W[PPPPaC:W[aC$\x90[\x15a\x04\xC2V[aC3W[\x93\x94PPPaAUV[P_aC)V[\x90P\x82\x82_aCJ\x87\x89\x90a=sV[Q\x01Q\x91aC\x96aC\x84aC~\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07LV[\x93a\x10\x06V[\x93aC\x8Da\x03\xA2V[\x91\x82\x91\x82a>\xFBV[\x03\x90\xA3aC$_\x91\x90PaC\x19V[aC\xE5\x93\x94PaC\xD3aC\xDF\x93aC\xCD` aC\xC6aC\xDA\x96`\x02\x96a=sV[Q\x01a>\xADV[\x96a.\xA3V[P\x01a\t>V[a\x05TV[\x91a\x05TV[\x11\x8A_\x88\x88aC\x10V[P\x99\x90\x9A\x87\x89aAk\x94\x95\x98aC$\x8D\x94aC\x1EV[P\x97PP\x92\x93P\x93PaD\x17_a,\xC2V[\x93[\x84aD4aD.aD)\x86a.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aE\x9BWaDZaDT`\x03aDM\x86\x89\x90a.\xA3V[P\x01a\teV[\x15a\x04\xC2V[aE\x90WaD|aDw_aDp\x86\x89\x90a.\xA3V[P\x01a=\xCDV[a>\x94V[aD\x8EaD\x88\x82a6hV[\x91a6bV[ \x90_\x96aD\x9B_a,\xC2V[[\x80aD\xB7aD\xB1aD\xAC\x86a=\x96V[a\x05TV[\x91a\x05TV[\x10\x15aE~WaD\xD0aD\xCB\x84\x83\x90a=\x9AV[a>\xA0V[aD\xE2aD\xDC\x86a\x0F\x01V[\x91a\x0F\x01V[\x14aD\xF5WaD\xF0\x90a,\xDEV[aD\x9CV[P\x95\x90\x96PaE\x16\x91PaE\x0B`\x01[\x15a\x04\xC2V[aE\x1DW[[a,\xDEV[\x93\x94aD\x19V[\x82\x85_aE+\x87\x85\x90a.\xA3V[P\x01\x91aEvaEdaE^\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07LV[\x93a\x10\x06V[\x93aEma\x03\xA2V[\x91\x82\x91\x82a@\x17V[\x03\x90\xA3aE\x10V[P\x95\x90\x96aE\x16\x92PaE\x0B\x90aE\x05V[\x94\x93aE\x16\x90aE\x11V[PPPPPV[\x96\x93\x90PaE\xBCaE\xB7\x83\x97\x94\x99\x96\x93a.\x9FV[a=LV[\x97aE\xC6_a,\xC2V[[\x80aE\xE2aE\xDCaE\xD7\x8Ba.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aF<WaF7\x90aF2aF\raF\x08_aF\x01\x8D\x86\x90a.\xA3V[P\x01a=\xCDV[a>\x94V[aF\x1FaF\x19\x82a6hV[\x91a6bV[ aF-\x8D\x91\x84\x90\x92a=\x9AV[a=\xBAV[a,\xDEV[aE\xC7V[P\x92\x95\x91\x94\x97\x90\x93\x96aA)V[aFRad\x96V[aFZaF\\V[V[aFmaFh_a%\xE9V[ak\xAEV[V[aFwaFJV[V[aF\x83`\xA0a\x16\xBCV[\x90V[_\x90V[_\x90V[_\x90V[aF\x9AaFyV[\x90` \x80\x80\x80\x80\x86aF\xAAaF\x86V[\x81R\x01aF\xB5a'PV[\x81R\x01aF\xC0a'TV[\x81R\x01aF\xCBaF\x8AV[\x81R\x01aF\xD6aF\x8EV[\x81RPPV[aF\xE4aF\x92V[\x90V[\x90aF\xF1\x90a\x05TV[\x90RV[\x90aF\xFF\x90a\x03\xB4V[\x90RV[\x90aG\r\x90a\x04\xAFV[\x90RV[\x90aG\x1B\x90a\x11YV[\x90RV[\x90aG\x9EaG\x95`\x02aG0aFyV[\x94aGGaG?_\x83\x01a\t>V[_\x88\x01aF\xE7V[aG_aGV`\x01\x83\x01a\x10IV[` \x88\x01aF\xF5V[aGwaGn`\x01\x83\x01a\x10vV[`@\x88\x01aG\x03V[aG\x8FaG\x86`\x01\x83\x01a\x10\xA3V[``\x88\x01aG\x11V[\x01a\x10\xC7V[`\x80\x84\x01a=\xBAV[V[aG\xA9\x90aG\x1FV[\x90V[aG\xD1\x91aG\xC7aG\xCC\x92aG\xBFaF\xDCV[P`\x03a\x0F\xC8V[a\x10\x12V[aG\xA0V[\x90V[_\x90V[\x90aG\xE2\x90a\x07LV[_R` R`@_ \x90V[\x90aG\xF8\x90a\x10\x06V[_R` R`@_ \x90V[aH)\x91aH\x1FaH$\x92aH\x17aG\xD4V[P`\x0CaG\xD8V[aG\xEEV[a\x10IV[\x90V[aH4ak\xC4V[aH<a^\x04V[aHNaHH\x83a\x03\xEFV[\x91a\x03\xEFV[\x03aH^WaH\\\x90ak\xAEV[V[aHy\x90_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xC9V[\x03\x90\xFD[aH\x9CaH\x97aH\xA1\x92aH\x8Fa'\xAEV[P`\x04a34V[a3JV[aj\xC7V[\x90V[aH\xAE\x90Qa\x04\xAFV[\x90V[aH\xC5aH\xC0aH\xCA\x92a%\xCAV[a\x07IV[a\x04\xAFV[\x90V[aH\xD7\x90Qa\x03\xB4V[\x90V[aH\xEEaH\xE9aH\xF3\x92a\x04\xAFV[a\x07IV[a\x05TV[\x90V[aI\x05aI\x0B\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x82\x01\x80\x92\x11aI\x16WV[a(\xE4V[\x90\x92\x91\x92aI'a9\xF3V[PaI0a'\xAEV[PaI:\x82ac~V[\x93aIWaIRaIM`\x05\x86\x90a34V[a3JV[aj\xC7V[\x92aId` \x87\x01aH\xA4V[aIvaIp_aH\xB1V[\x91a\x04\xAFV[\x14\x80\x15aJhW[\x80\x15aJMW[aJ3WaI\xBF\x86aI\xB9aI\xB4` aI\xADaI\xA8_aJ\x1C\x9B\x9C\x9D\x01aH\xCDV[a5{V[\x93\x01aH\xA4V[aH\xDAV[\x90a(\xF8V[\x91\x80aI\xDAaI\xD4aI\xCFa\x13-V[a\x05TV[\x91a\x05TV[\x11_\x14aJ.WPaI\xEAa\x13-V[[aI\xF6\x84\x82\x90aH\xF6V[aJ\x08aJ\x02\x88a\x05TV[\x91a\x05TV[\x11_\x14aJ\x1FWP\x84[\x90\x92\x90\x91\x92ak\xFAV[\x91V[aJ)\x90\x84aH\xF6V[aJ\x12V[aI\xEBV[PPP\x91PaJIaJD_a,\xC2V[a:1V[\x91\x90V[P\x82aJaaJ[\x86a\x05TV[\x91a\x05TV[\x10\x15aI\x85V[P\x83aJ|aJv_a,\xC2V[\x91a\x05TV[\x14aI~V[aJ\x93\x90aJ\x8Ead\x96V[aJ\x95V[V[aJ\xA0\x90`\na&\x9AV[V[aJ\xAB\x90aJ\x82V[V[_\x90V[aJ\xB9aJ\xADV[PaJ\xC3_a%\xBDV[\x90V[P\x90V[\x91\x90\x81\x10\x15aJ\xDAW` \x02\x01\x90V[a\x07~V[5aJ\xE9\x81a\x03\xFBV[\x90V[_\x80\xFD[`\xE0\x1B\x90V[_\x91\x03\x12aK\0WV[a\x03\xACV[\x91` aK&\x92\x94\x93aK\x1F`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x0C\xBCV[V[aK0a\x03\xA2V[=_\x82>=\x90\xFD[\x90\x92\x91\x92aKE_a,\xC2V[[\x80aKcaK]aKX\x85\x89\x90aJ\xC6V[a\x05TV[\x91a\x05TV[\x10\x15aL\x12WaKr0a<\x85V[\x90c\xBA\x1F\xB1\x03\x84aK\x8DaK\x88\x86\x8A\x86\x91aJ\xCAV[aJ\xDFV[\x93\x80;\x15aL\rWaK\xB2_\x80\x94aK\xBDaK\xA6a\x03\xA2V[\x98\x89\x96\x87\x95\x86\x94aJ\xF0V[\x84R`\x04\x84\x01aK\x05V[\x03\x92Z\xF1\x91\x82\x15aL\x08WaK\xD7\x92aK\xDCW[Pa,\xDEV[aKFV[aK\xFB\x90_=\x81\x11aL\x01W[aK\xF3\x81\x83a\x08\xD7V[\x81\x01\x90aJ\xF6V[_aK\xD1V[P=aK\xE9V[aK(V[aJ\xECV[PPP\x90PV[_\x7FNot slashing oracle\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aLM`\x13` \x92a\t\xD5V[aLV\x81aL\x19V[\x01\x90V[aLo\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaL@V[\x90V[\x15aLyWV[aL\x81a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aL\x97`\x04\x82\x01aLZV[\x03\x90\xFD[_\x7FOperator unknown\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aL\xCF`\x10` \x92a\t\xD5V[aL\xD8\x81aL\x9BV[\x01\x90V[aL\xF1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaL\xC2V[\x90V[\x15aL\xFBWV[aM\x03a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aM\x19`\x04\x82\x01aL\xDCV[\x03\x90\xFD[\x90V[\x90aM3g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90aMUaMPaM\\\x92a\x07LV[aM=V[\x82TaM V[\x90UV[\x91\x90aMz\x81aMs\x81aM\x7F\x95a\t\xD5V[\x80\x95a\x17\x1DV[a\x08\xB9V[\x01\x90V[\x90\x91aM\x9A\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaM`V[\x90V[aM\xC23aM\xBCaM\xB6aM\xB1`\na%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14aLrV[aM\xE8aM\xE3aM\xDCaM\xD7`\x05\x85\x90a34V[a3JV[\x84\x90ad\xE4V[aL\xF4V[aN\x14aN\taN\x04aM\xFD`\x03\x85\x90a\x0F\xC8V[\x85\x90a\x10\x12V[aM\x1DV[`\x01`\x03\x91\x01a3\x81V[aN2aN+aN&`\x04\x84\x90a34V[a3JV[\x83\x90am\x16V[PaNZaN?Ba5\x97V[aNUaNN`\x0C\x85\x90aG\xD8V[\x85\x90aG\xEEV[aM@V[\x90\x91\x92aN\x90aN\x8A\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07LV[\x93a\x10\x06V[\x93aN\xA5aN\x9Ca\x03\xA2V[\x92\x83\x92\x83aM\x83V[\x03\x90\xA3V[aN\xB4`\x80a\x16\xBCV[\x90V[aN\xC2\x916\x91a\x17(V[\x90V[RV[\x90aN\xD2\x90a\x04\xC2V[\x90RV[Q\x90V[\x90aN\xE4\x81a\t\xD1V[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11aO\xA4WaO\x08\x82aO\x02\x85Ta\x07\xE4V[\x85a.\xCFV[` \x90`\x1F\x83\x11`\x01\x14aO<W\x91\x80\x91aO+\x93_\x92aO0W[PPa*\x07V[\x90U[V[\x90\x91P\x01Q_\x80aO$V[`\x1F\x19\x83\x16\x91aOK\x85a\x08\x17V[\x92_[\x81\x81\x10aO\x8CWP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10aOrW[PPP\x02\x01\x90UaO.V[aO\x82\x91\x01Q`\x1F\x84\x16\x90a)\xF2V[\x90U_\x80\x80aOfV[\x91\x93` `\x01\x81\x92\x87\x87\x01Q\x81U\x01\x95\x01\x92\x01aONV[a\x08\xC3V[\x90aO\xB3\x91aN\xDAV[V[aO\xBF\x90Qa\x04\xC2V[\x90V[\x90aP\x1F```\x03aP%\x94aO\xE5_\x82\x01aO\xDF_\x88\x01aN\xD6V[\x90aO\xA9V[aO\xFE`\x01\x82\x01aO\xF8` \x88\x01a>\xADV[\x90a0\x18V[aP\x17`\x02\x82\x01aP\x11`@\x88\x01a>\xADV[\x90a0\x18V[\x01\x92\x01aO\xB5V[\x90a0jV[V[\x91\x90aP8WaP6\x91aO\xC2V[V[a+\xA3V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15aPmW\x82aPe\x91`\x01aPk\x95\x01\x81Ua.\xA3V[\x90aP'V[V[a\x08\xC3V[aQ\x90\x95aQy\x84\x96aQpaQhaQTaQOaQ\x82\x97aP\xF5aP\xD5aP\xCFaQ\x8B\x9D\x8D\x9F\x9DaP\xCA3aP\xC4aP\xBEaP\xB9aP\xB4`\x07\x8C\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[a-{V[\x90a-~V[aP\xEEaP\xE8aP\xE3a\x19!V[a\x05TV[\x91a\x05TV[\x11\x15a-\xDBV[aQ\x12\x86aQ\x0BaQ\x05\x8Da\x05TV[\x91a\x05TV[\x10\x15a.jV[aQHaQ)aQ$`\x08\x84\x90a\x07hV[a\x07\x92V[aQBaQ<aQ7a\x15mV[a\x05TV[\x91a\x05TV[\x10a(\xBBV[`\x08a\x07hV[a.\x93V[\x98\x99\x96\x92\x94\x96aQbaN\xAAV[\x9AaN\xB7V[_\x8A\x01aN\xC5V[` \x88\x01aF\xE7V[`@\x86\x01aF\xE7V[``\x84\x01aN\xC8V[aP=V[V[aQ\xC0\x90aQ\xBBaQ\xB6aQ\xAFaQ\xAA\x84`\x06a34V[a3JV[3\x90ad\xE4V[a5\x1BV[aR\xA1V[V[_\x7FCannot go online while slashed\0\0\x91\x01RV[aQ\xF6`\x1E` \x92a\t\xD5V[aQ\xFF\x81aQ\xC2V[\x01\x90V[aR\x18\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaQ\xE9V[\x90V[`@\x1B\x90V[\x90aR5h\xFF\0\0\0\0\0\0\0\0\x91aR\x1BV[\x91\x81\x19\x16\x91\x16\x17\x90V[aRSaRNaRX\x92a\x04\xAFV[a\x07IV[a\x04\xAFV[\x90V[\x90V[\x90aRsaRnaRz\x92aR?V[aR[V[\x82TaR!V[\x90UV[\x91` aR\x9F\x92\x94\x93aR\x98`@\x82\x01\x96_\x83\x01\x90a\x11qV[\x01\x90a\x11qV[V[aR\xBFaR\xBAaR\xB3`\x03\x84\x90a\x0F\xC8V[3\x90a\x10\x12V[aM\x1DV[\x90aR\xCC`\x01\x83\x01a\x10\xA3V[\x91\x82aR\xE1aR\xDB`\x03a\x11YV[\x91a\x11YV[\x14aT\x05W\x82aR\xF9aR\xF3_a\x11YV[\x91a\x11YV[\x14\x80\x15aS\xEAW[aS\xE5WaS(\x90aS\x16`\x01\x80\x83\x01a3\x81V[`\x01aS!_aH\xB1V[\x91\x01aR^V[aSFaS?aS:`\x04\x84\x90a34V[a3JV[3\x90ad\\V[P\x803aS|aSv\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07LV[\x91a\x10\x06V[\x91aS\x85a\x03\xA2V[\x80aS\x8F\x81a\x04KV[\x03\x90\xA3\x903\x90\x91`\x01aS\xCBaS\xC5\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93aS\xE0aS\xD7a\x03\xA2V[\x92\x83\x92\x83aR~V[\x03\x90\xA3V[PPPV[P\x82aS\xFFaS\xF9`\x01a\x11YV[\x91a\x11YV[\x14aS\x01V[aT\ra\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aT#`\x04\x82\x01aR\x03V[\x03\x90\xFD[aT0\x90aQ\x92V[V[_\x7FNot authorized\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aTf`\x0E` \x92a\t\xD5V[aTo\x81aT2V[\x01\x90V[aT\x88\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaTYV[\x90V[\x15aT\x92WV[aT\x9Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aT\xB0`\x04\x82\x01aTsV[\x03\x90\xFD[\x90V[aT\xCBaT\xC6aT\xD0\x92aT\xB4V[a\x07IV[a\x03\xB4V[\x90V[_\x7FInterval too short\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\x07`\x12` \x92a\t\xD5V[aU\x10\x81aT\xD3V[\x01\x90V[aU)\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaT\xFAV[\x90V[\x15aU3WV[aU;a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aUQ`\x04\x82\x01aU\x14V[\x03\x90\xFD[\x90V[aUlaUgaUq\x92aUUV[a\x07IV[a\x04\xAFV[\x90V[_\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\xA8`\x17` \x92a\t\xD5V[aU\xB1\x81aUtV[\x01\x90V[aU\xCA\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaU\x9BV[\x90V[\x15aU\xD4WV[aU\xDCa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aU\xF2`\x04\x82\x01aU\xB5V[\x03\x90\xFD[aV\0``a\x16\xBCV[\x90V[\x90aV\x18aV\x13aV\x1F\x92a0[V[a0gV[\x82Ta3SV[\x90UV[\x90aVe`@_aVk\x94aVE\x82\x82\x01aV?\x84\x88\x01aH\xCDV[\x90aM@V[aV]\x82\x82\x01aVW` \x88\x01aH\xA4V[\x90aR^V[\x01\x92\x01aO\xB5V[\x90aV\x03V[V[\x90aVw\x91aV#V[V[\x91` aV\x9A\x92\x94\x93aV\x93`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x11)V[V[3aV\xCFaV\xC9\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14\x80\x15aW\xBBW[aV\xE0\x90aT\x8BV[aV\xFE\x82aV\xF7aV\xF1`<aT\xB7V[\x91a\x03\xB4V[\x10\x15aU,V[aW\x1C\x83aW\x15aW\x0F`\x01aUXV[\x91a\x04\xAFV[\x10\x15aU\xCDV[aWu\x82aWd\x85aW[aW=_aW7`\x02\x89\x90a\"\x87V[\x01a\"\xB1V[\x91aWRaWIaU\xF6V[\x95_\x87\x01aF\xF5V[` \x85\x01aG\x03V[`@\x83\x01aN\xC8V[aWp`\x02\x84\x90a\"\x87V[aVmV[\x90\x91aW\xA1\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x92a\x07LV[\x92aW\xB6aW\xADa\x03\xA2V[\x92\x83\x92\x83aVyV[\x03\x90\xA2V[PaV\xE03aW\xE5aW\xDFaW\xDAaW\xD5`\x07\x87\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x90PaV\xD7V[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[aX\raX\x13\x91a\x05TV[\x91a\x05TV[\x90\x81\x15aX\x1EW\x04\x90V[aW\xEDV[aX7aX2aX<\x92a\x05TV[a\x07IV[a\x04\xAFV[\x90V[aXSaXNaXX\x92a%\xCAV[a\x07IV[a\x03\xB4V[\x90V[aXyaXtaXm`\x03\x84\x90a\x0F\xC8V[\x84\x90a\x10\x12V[aM\x1DV[\x90aX\x83\x81ac~V[aX\x8F`\x01\x84\x01a\x10\xA3V[aX\xA2aX\x9C`\x03a\x11YV[\x91a\x11YV[\x14aZ\xB6WaX\xB2_\x84\x01a\t>V[aX\xC4aX\xBE_a,\xC2V[\x91a\x05TV[\x14aZ\xB0WaX\xFAaX\xE1BaX\xDB_\x87\x01a\t>V[\x90a5\xD6V[aX\xF4aX\xEF_\x85\x01aH\xCDV[a5{V[\x90aX\x01V[\x80aY\x0EaY\x08`\xFFaH\xDAV[\x91a\x05TV[\x11_\x14aZ\xA2WP`\xFF[\x90\x81aY8aY2aY-`\x01\x88\x01a\x10vV[a\x04\xAFV[\x91a\x04\xAFV[\x11aYEW[PPPPPV[aYR\x82`\x01\x86\x01aR^V[aYgaY^_aX?V[`\x01\x86\x01aM@V[aY\x85aY\x7FaYz` \x85\x94\x01aH\xA4V[a\x04\xAFV[\x91a\x04\xAFV[\x10\x15\x80aZ{W[aY\x98W[\x80aY>V[aY\xB3aY\xA7`\x01\x85\x01a\x10\xA3V[\x93`\x01`\x02\x91\x01a3\x81V[aY\xD1aY\xCAaY\xC5`\x04\x85\x90a34V[a3JV[\x85\x90am\x16V[P\x81\x90\x84\x90\x91aZ\x1FaZ\raZ\x07\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM\x93a\x07LV[\x93a\x10\x06V[\x93aZ\x16a\x03\xA2V[\x91\x82\x91\x82a\x16'V[\x03\x90\xA3\x91\x90\x91`\x02aZZaZT\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93aZoaZfa\x03\xA2V[\x92\x83\x92\x83aR~V[\x03\x90\xA3_\x80\x80\x80aY\x92V[PaZ\x88`\x01\x84\x01a\x10\xA3V[aZ\x9BaZ\x95`\x02a\x11YV[\x91a\x11YV[\x14\x15aY\x8DV[aZ\xAB\x90aX#V[aY\x19V[PPPPV[PPPPV[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11aZ\xD9W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90aZ\xF0aZ\xEB\x83aZ\xC1V[a\x16\xBCV[\x91\x82RV[aZ\xFF`\x80a\x16\xBCV[\x90V[\x90a[ia[``\x03a[\x13aZ\xF5V[\x94a[*a[\"_\x83\x01a\t\0V[_\x88\x01aN\xC5V[a[Ba[9`\x01\x83\x01a\t>V[` \x88\x01aF\xE7V[a[Za[Q`\x02\x83\x01a\t>V[`@\x88\x01aF\xE7V[\x01a\teV[``\x84\x01aN\xC8V[V[a[t\x90a[\x02V[\x90V[\x90a[\x81\x82a\x07\x92V[a[\x8A\x81aZ\xDEV[\x92a[\x98` \x85\x01\x91a\x07\x96V[_\x91[\x83\x83\x10a[\xA8WPPPPV[`\x04` `\x01\x92a[\xB8\x85a[kV[\x81R\x01\x92\x01\x92\x01\x91\x90a[\x9BV[a[\xCF\x90a[wV[\x90V[a[\xE9a[\xEE\x91a[\xE1aZ\xBCV[P`\x08a\x07hV[a[\xC6V[\x90V[a\\\x1F\x90a\\\x1Aa\\\x15a\\\x0Ea\\\t\x84`\x06a34V[a3JV[3\x90ad\xE4V[a5\x1BV[a\\zV[V[_\x7FCannot go offline while slashed\0\x91\x01RV[a\\U`\x1F` \x92a\t\xD5V[a\\^\x81a\\!V[\x01\x90V[a\\w\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra\\HV[\x90V[a\\\x98a\\\x93a\\\x8C`\x03\x84\x90a\x0F\xC8V[3\x90a\x10\x12V[aM\x1DV[\x90a\\\xA5`\x01\x83\x01a\x10\xA3V[\x91\x82a\\\xBAa\\\xB4`\x03a\x11YV[\x91a\x11YV[\x14a]@Wa\\\xCE\x90`\x01`\x04\x91\x01a3\x81V[a\\\xECa\\\xE5a\\\xE0`\x04\x84\x90a34V[a3JV[3\x90am\x16V[P\x903\x90\x91`\x04a]&a] \x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93a];a]2a\x03\xA2V[\x92\x83\x92\x83aR~V[\x03\x90\xA3V[a]Ha\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a]^`\x04\x82\x01a\\bV[\x03\x90\xFD[a]k\x90a[\xF1V[V[\x90\x91\x82a]}\x81a]\x84\x93a\x1D3V[\x80\x93a\x17\x1DV[\x01\x90V[a]\x99\x90` \x94\x93a]\xA0\x93a]mV[\x80\x92a\x1DdV[\x01\x90V[\x90\x91a]\xBB\x90a]\xB2a\x03\xA2V[\x93\x84\x93\x84a]\x88V[\x03\x90 \x90V[\x90\x91a]\xCC\x92a]\xA4V[\x90V[\x92a]\xF4a]\xFC\x93\x92a]\xEFa^\x01\x96a]\xE7a'\xAEV[P`\ta\x1D\x07V[a\x1D\x1DV[\x91\x90\x91a]\xC1V[a\t>V[\x90V[a^\x0CaJ\xADV[Pa^\x17`\x01a%\xBDV[\x90V[a^$\x90Qa\x11YV[\x90V[\x90V[a^>a^9a^C\x92a^'V[a\x07IV[a\x05TV[\x90V[` \x7Fl\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x7FOperator not eligible for remova_\x82\x01R\x01RV[a^\xA0`!`@\x92a\t\xD5V[a^\xA9\x81a^FV[\x01\x90V[a^\xC2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra^\x93V[\x90V[\x15a^\xCCWV[a^\xD4a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a^\xEA`\x04\x82\x01a^\xADV[\x03\x90\xFD[\x90a_\x9Fa_\x9Aa_\xA4\x933a_\x1Fa_\x19a_\x14a_\x0F`\x07\x86\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x80\x15a`]W[a_0\x90aT\x8BV[a_Na_Ia_B`\x03\x84\x90a\x0F\xC8V[\x86\x90a\x10\x12V[aG\xA0V[a_Z``\x82\x01a^\x1AV[a_ma_g`\x03a\x11YV[\x91a\x11YV[\x03a_\xA7W[Pa_\x92a_\x8Ba_\x86`\x05\x84\x90a34V[a3JV[\x85\x90am\x16V[P`\x04a34V[a3JV[am\x16V[PV[a`#\x90a_\xF7a_\xE7a_\xBA\x85ac~V[a_\xE1a_\xDC` a_\xD5a_\xD0_\x86\x01aH\xCDV[a5{V[\x93\x01aH\xA4V[aH\xDAV[\x90a(\xF8V[a_\xF1`\na^*V[\x90a(\xF8V[a`\x02_\x83\x01a>\xADV[a`\x14a`\x0E_a,\xC2V[\x91a\x05TV[\x11\x91\x82a`)W[PPa^\xC5V[_a_sV[a`T\x91\x92Pa`Ha`N\x91a`B_B\x92\x01a>\xADV[\x90a5\xD6V[\x92a\x05TV[\x91a\x05TV[\x10\x15_\x80a`\x1CV[Pa_03a`{a`ua`paJ\xB1V[a\x03\xEFV[\x91a\x03\xEFV[\x14\x90Pa_'V[\x90a`\xADa`\xB2\x91a`\x93a;\"V[Pa`\xA8a`\xA0\x85ac~V[\x94`\x03a\x0F\xC8V[a\x10\x12V[aG\xA0V[a`\xBD_\x82\x01a>\xADV[a`\xCFa`\xC9_a,\xC2V[\x91a\x05TV[\x14aa\nWaa\0a`\xFB_a`\xF4aa\x06\x94a`\xEE\x83B\x92\x01a>\xADV[\x90a5\xD6V[\x94\x01aH\xCDV[a5{V[\x91a\x05TV[\x10\x90V[PP_\x90V[aa!\x90aa\x1Cad\x96V[aa#V[V[aa.\x81`\x01a&\x9AV[aa6aJ\xB1V[\x90aajaad\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0\x93a\x10\x06V[\x91a\x10\x06V[\x91aasa\x03\xA2V[\x80aa}\x81a\x04KV[\x03\x90\xA3V[aa\x8B\x90aa\x10V[V[_aa\xCCaa\xD2\x93aa\xC43aa\xBEaa\xB8aa\xB3aa\xAE`\x07\x8A\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[\x92`\x02a\"\x87V[\x01aV\x03V[V[_\x7FNot registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[ab\x08`\x0E` \x92a\t\xD5V[ab\x11\x81aa\xD4V[\x01\x90V[ab*\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Raa\xFBV[\x90V[\x15ab4WV[ab<a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80abR`\x04\x82\x01ab\x15V[\x03\x90\xFD[ab\x923ab\x8Cab\x86\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[ab\xB8ab\xB3ab\xACab\xA7`\x06\x85\x90a34V[a3JV[\x84\x90am\x16V[ab-V[ab\xD6ab\xCFab\xCA`\x04\x84\x90a34V[a3JV[\x83\x90am\x16V[P\x90ac\x0Bac\x05\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E\x93a\x07LV[\x91a\x10\x06V[\x91ac\x14a\x03\xA2V[\x80ac\x1E\x81a\x04KV[\x03\x90\xA3V[\x90acpacg_ac3a'CV[\x94acJacB\x83\x83\x01a\x10IV[\x83\x88\x01aF\xF5V[acaacX\x83\x83\x01a\x10vV[` \x88\x01aG\x03V[\x01a\"\xB1V[`@\x84\x01aN\xC8V[V[ac{\x90ac#V[\x90V[ac\x95ac\x9A\x91ac\x8Da'\x8EV[P`\x02a\"\x87V[acrV[ac\xA5_\x82\x01aH\xCDV[ac\xB7ac\xB1_aX?V[\x91a\x03\xB4V[\x14ac\xFDW[ac\xC9` \x82\x01aH\xA4V[ac\xDBac\xD5_aH\xB1V[\x91a\x04\xAFV[\x14ac\xE4W[\x90V[ac\xF8ac\xEFa\x16\x0FV[` \x83\x01aG\x03V[ac\xE1V[ad\x10ad\x08a\x0C\x08V[_\x83\x01aF\xF5V[ac\xBDV[ad\x1E\x90a\x0F\xDEV[\x90V[ad5ad0ad:\x92a\x03\xE4V[a\x07IV[a\x05TV[\x90V[adQadLadV\x92a\x05TV[a&wV[a\x0F\x01V[\x90V[\x90V[\x90ad\x8Ead\x88ad\x83ad~_ad\x93\x96adva;\"V[P\x01\x94ad\x15V[ad!V[ad=V[\x91adYV[am\xF9V[\x90V[ad\x9EaJ\xB1V[ad\xB7ad\xB1ad\xACak\xC4V[a\x03\xEFV[\x91a\x03\xEFV[\x03ad\xBEWV[ad\xE0ad\xC9ak\xC4V[_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xC9V[\x03\x90\xFD[\x90ae\x16ae\x10ae\x0Bae\x06_ae\x1B\x96ad\xFEa;\"V[P\x01\x94ad\x15V[ad!V[ad=V[\x91adYV[an\\V[\x90V[ae=\x91ae4\x91ae.aJ\xADV[Pan\xBCV[\x90\x92\x91\x92ao|V[\x90V[_\x7FOperator is slashed\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aet`\x13` \x92a\t\xD5V[ae}\x81ae@V[\x01\x90V[ae\x96\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaegV[\x90V[\x15ae\xA0WV[ae\xA8a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80ae\xBE`\x04\x82\x01ae\x81V[\x03\x90\xFD[ae\xCB\x90a\x0F\x01V[\x90V[ae\xD7\x90a\t\"V[\x90V[\x90ae\xEFae\xEAae\xF6\x92ae\xC2V[ae\xCEV[\x82Ta0\x02V[\x90UV[af\x03\x90a\x03\xB4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x14af\x18W`\x01\x01\x90V[a(\xE4V[\x90V[af4af/af9\x92af\x1DV[a\x07IV[a\x04\xAFV[\x90V[\x91` af]\x92\x94\x93afV`@\x82\x01\x96_\x83\x01\x90a\x11)V[\x01\x90a\x05WV[V[afh\x90a\x0F\xDEV[\x90V[aft\x90af_V[\x90V[af\x80\x90a\x0F\xFAV[\x90V[`@\x90af\xACaf\xB3\x94\x96\x95\x93\x96af\xA2``\x84\x01\x98_\x85\x01\x90a\x0C\xBCV[` \x83\x01\x90a\x0C!V[\x01\x90a\x0C!V[V[\x94\x92\x93\x91\x93af\xD8af\xD3af\xCC`\x03\x89\x90a\x0F\xC8V[\x87\x90a\x10\x12V[aM\x1DV[\x93af\xE2\x87ac~V[\x93ag\x0Caf\xF2`\x01\x88\x01a\x10\xA3V[ag\x05af\xFF`\x03a\x11YV[\x91a\x11YV[\x14\x15ae\x99V[ag*ag#ag\x1E`\x05\x8B\x90a34V[a3JV[\x88\x90ad\\V[Pag\xFF`@ag<`\x01\x89\x01a\x10\xA3V[\x96agIB_\x8B\x01a0\x18V[agsagW\x85\x87\x90a6TV[agiagc\x82a6hV[\x91a6bV[ `\x02\x8B\x01ae\xDAV[ag\x88ag\x7F_aH\xB1V[`\x01\x8B\x01aR^V[ag\xA6`\x01\x8A\x01ag\xA0ag\x9B\x82a\x10IV[ae\xFAV[\x90aM@V[ag\xAEa<VV[P\x85ag\xC2ag\xBC_aH\xB1V[\x91a\x04\xAFV[\x14_\x14aj\x83Wag\xD9_\x99[`\x01\x8B\x91\x01a3\x81V[\x87ag\xEDag\xE7`\x02a\x11YV[\x91a\x11YV[\x14\x80ajgW[ai\xF9W[\x01aO\xB5V[\x80ai\xD5W[ai\xBFW[PP\x85\x91\x85\x91\x92BahNahHahB\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x94a\x07LV[\x94a\x07LV[\x94a\x10\x06V[\x94ahcahZa\x03\xA2V[\x92\x83\x92\x83af<V[\x03\x90\xA4\x80ahyahs\x84a\x11YV[\x91a\x11YV[\x03aiiW[PPah\x8B`\x0Ba%\xBDV[ah\xA5ah\x9Fah\x9A_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x03ah\xAFW[PPV[ah\xC9ah\xC4ah\xBF`\x0Ba%\xBDV[afkV[afwV[\x91c\xD4xS\xB6\x91\x90\x92ah\xDBBa5\x97V[\x92\x81;\x15aidW_ai\x01\x91ai\x0C\x82\x96ah\xF5a\x03\xA2V[\x98\x89\x97\x88\x96\x87\x95aJ\xF0V[\x85R`\x04\x85\x01af\x83V[\x03\x92Z\xF1\x90\x81ai8W[P\x15_\x14ai3W`\x01ai.W[[_\x80ah\xABV[ai&V[ai'V[aiW\x90_=\x81\x11ai]W[aiO\x81\x83a\x08\xD7V[\x81\x01\x90aJ\xF6V[_ai\x17V[P=aiEV[aJ\xECV[\x83\x83\x91\x92ai\xA0ai\x9A\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93ai\xB5ai\xACa\x03\xA2V[\x92\x83\x92\x83aR~V[\x03\x90\xA3_\x80ah\x7FV[ai\xCE\x91\x88\x91\x88\x90\x91\x92at9V[_\x80ah\nV[Pai\xE1\x81\x83\x90a-~V[ai\xF3ai\xED_a,\xC2V[\x91a\x05TV[\x11ah\x05V[aj\x16aj\x0Faj\n\x8D`\x04a34V[a3JV[\x8B\x90ad\\V[P\x8A\x8AajLajF\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07LV[\x91a\x10\x06V[\x91ajUa\x03\xA2V[\x80aj_\x81a\x04KV[\x03\x90\xA3ag\xF9V[P\x88aj|ajv`\x02a\x11YV[\x91a\x11YV[\x14\x15ag\xF4V[\x85aj\x97aj\x91`daf V[\x91a\x04\xAFV[\x10_\x14aj\xAAWag\xD9`\x01\x99[ag\xCFV[ag\xD9`\x01\x99aj\xC2\x8D\x8D\x8B\x90\x8B\x90\x8A\x92\x8C\x94ap\xEDV[aj\xA5V[aj\xDE_aj\xE3\x92aj\xD7a'\xAEV[P\x01adYV[au\xF7V[\x90V[aj\xF2aj\xF7\x91a\t\"V[a)~V[\x90V[ak\x0Eak\tak\x13\x92a\x05TV[a\x07IV[a\x03\xE4V[\x90V[akAak<akK\x93ak7_akF\x95ak0aJ\xADV[P\x01adYV[aveV[aj\xE6V[aj\xFAV[a\x0F\xFAV[\x90V[\x91\x90`\x08akn\x91\x02\x91akh`\x01\x80`\xA0\x1B\x03\x84a)UV[\x92a)UV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x91\x90ak\x8Eak\x89ak\x96\x93a\x10\x06V[a&\x97V[\x90\x83TakNV[\x90UV[ak\xAC\x91ak\xA6aJ\xADV[\x91akxV[V[ak\xC2\x90ak\xBD_`\x01ak\x9AV[av\x86V[V[ak\xCCaJ\xADV[P3\x90V[ak\xDA\x90a\x05TV[_\x19\x81\x14ak\xE8W`\x01\x01\x90V[a(\xE4V[ak\xF7\x90Qa\x03\xEFV[\x90V[\x93\x91\x92\x93al\x06a9\xF3V[Pal\x1Aal\x15\x85\x84\x90a5\xD6V[a:1V[\x92al$_a,\xC2V[\x92[\x80al9al3\x88a\x05TV[\x91a\x05TV[\x10\x15al\xA7Wal]alValQ`\x05\x86\x90a34V[a3JV[\x82\x90ak\x16V[ali\x84\x82\x8A\x91av\xE5V[al}W[Palx\x90a,\xDEV[al&V[alx\x91\x94al\x9Bal\xA0\x92al\x96\x89\x91\x84\x90\x92a:XV[a:xV[ak\xD1V[\x93\x90alnV[P\x94PP\x91Pal\xB6\x82a:1V[\x92al\xC0_a,\xC2V[[\x80al\xD4al\xCE\x86a\x05TV[\x91a\x05TV[\x10\x15am\x10Wam\x0B\x90am\x06al\xF4al\xEF\x86\x84\x90a:XV[ak\xEDV[am\x01\x88\x91\x84\x90\x92a:XV[a:xV[a,\xDEV[al\xC1V[P\x91PPV[\x90amHamBam=am8_amM\x96am0a;\"V[P\x01\x94ad\x15V[ad!V[ad=V[\x91adYV[ax1V[\x90V[\x90V[_R` _ \x90V[T\x90V[ami\x81am\\V[\x82\x10\x15am\x83Wam{`\x01\x91amSV[\x91\x02\x01\x90_\x90V[a\x07~V[\x91\x90am\x9Eam\x99am\xA6\x93ae\xC2V[ae\xCEV[\x90\x83Ta)YV[\x90UV[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15am\xDAW\x82am\xD2\x91`\x01am\xD8\x95\x01\x81Uam`V[\x90am\x88V[V[a\x08\xC3V[T\x90V[\x90am\xED\x90ae\xC2V[_R` R`@_ \x90V[an\x01a;\"V[Pan\x16an\x10\x82\x84\x90an\\V[\x15a\x04\xC2V[_\x14anVWanLanQ\x92an8an1_\x85\x01amPV[\x82\x90am\xAAV[`\x01anE_\x85\x01am\xDFV[\x93\x01am\xE3V[a0\x18V[`\x01\x90V[PP_\x90V[anz\x91`\x01anu\x92anna;\"V[P\x01am\xE3V[a\t>V[an\x8Can\x86_a,\xC2V[\x91a\x05TV[\x14\x15\x90V[_\x90V[_\x90V[\x90V[an\xB0an\xABan\xB5\x92an\x99V[a\x07IV[a\x05TV[\x90V[_\x90V[\x91\x90\x91an\xC7aJ\xADV[Pan\xD0an\x91V[Pan\xD9an\x95V[Pan\xE3\x83a6hV[an\xF6an\xF0`Aan\x9CV[\x91a\x05TV[\x14_\x14ao=Wao6\x91\x92ao\nan\x95V[Pao\x13an\x95V[Pao\x1Can\xB8V[P` \x81\x01Q```@\x83\x01Q\x92\x01Q_\x1A\x90\x91\x92ay\xB0V[\x91\x92\x90\x91\x90V[PaoG_a%\xE9V[\x90ao[aoV`\x02\x94a6hV[ad=V[\x91\x92\x91\x90V[`\x04\x11\x15aokWV[a\x116V[\x90aoz\x82aoaV[V[\x80ao\x8Fao\x89_aopV[\x91aopV[\x14_\x14ao\x9AWPPV[\x80ao\xAEao\xA8`\x01aopV[\x91aopV[\x14_\x14ao\xD1W_c\xF6E\xEE\xDF`\xE0\x1B\x81R\x80ao\xCD`\x04\x82\x01a\x04KV[\x03\x90\xFD[\x80ao\xE5ao\xDF`\x02aopV[\x91aopV[\x14_\x14ap\x13Wap\x0Fao\xF8\x83aj\xE6V[_\x91\x82\x91c\xFC\xE6\x98\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x05dV[\x03\x90\xFD[ap&ap `\x03aopV[\x91aopV[\x14ap.WPV[apI\x90_\x91\x82\x91c5\xE2\xF3\x83`\xE2\x1B\x83R`\x04\x83\x01a\x0F\x11V[\x03\x90\xFD[apaap\\apf\x92a\x13\x0EV[a\x07IV[a\x04\xAFV[\x90V[apuap{\x91a\x03\xB4V[\x91a\x03\xB4V[\x90\x03\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11ap\x8FWV[a(\xE4V[_\x7FProtocol violation reported\0\0\0\0\0\x91\x01RV[ap\xC8`\x1B` \x92a\t\xD5V[ap\xD1\x81ap\x94V[\x01\x90V[ap\xEA\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rap\xBBV[\x90V[\x93PP\x92Paq\x05ap\xFF`\xC8apMV[\x91a\x04\xAFV[\x10\x15aq\x10W[PPV[aq\x19Ba5\x97V[aq7aq2aq+`\x0C\x85\x90aG\xD8V[\x85\x90aG\xEEV[a\x10IV[\x80aqJaqD_aX?V[\x91a\x03\xB4V[\x14\x90\x81\x15aq\xD0W[Paq_W[Paq\x0CV[aq~\x90aqyaqr`\x0C\x85\x90aG\xD8V[\x85\x90aG\xEEV[aM@V[\x90aq\xB2aq\xAC\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07LV[\x91a\x10\x06V[\x91aq\xBBa\x03\xA2V[\x80aq\xC5\x81ap\xD5V[\x03\x90\xA3_\x80\x80aqYV[aq\xDB\x91P\x82apiV[aq\xF4aq\xEEaq\xE9a\x0FzV[a\x03\xB4V[\x91a\x03\xB4V[\x10\x15_aqSV[\x90V[ar\x13ar\x0Ear\x18\x92aq\xFCV[a\x07IV[a\x05TV[\x90V[\x90\x92\x91\x92ar0ar+\x82a\x16\xFAV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11arLWarJ\x92a\t\xDEV[V[a\x16\xF6V[\x90\x80`\x1F\x83\x01\x12\x15aroW\x81` arl\x93Q\x91\x01ar\x1BV[\x90V[a\x05\xAFV[\x90PQ\x90ar\x81\x82a\x06\xF9V[V[\x91\x90\x91`@\x81\x84\x03\x12ar\xD6War\x9A`@a\x16\xBCV[\x92_\x82\x01Q\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11ar\xD1War\xBE\x82ar\xCA\x94\x83\x01arQV[_\x86\x01R` \x01artV[` \x83\x01RV[a\x16\xF2V[a\x16\xEEV[\x92\x91\x90ar\xEFar\xEA\x82a\x16\xD1V[a\x16\xBCV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11asFW\x81\x90[\x83\x82\x10as\x15WPPPPPV[\x81Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11asAW` \x91as6\x87\x84\x93\x87\x01ar\x83V[\x81R\x01\x91\x01\x90as\x07V[a\x05\xAFV[a\x05\xB7V[\x90\x80`\x1F\x83\x01\x12\x15asiW\x81` asf\x93Q\x91\x01ar\xDBV[\x90V[a\x05\xAFV[\x90` \x82\x82\x03\x12as\x9EW_\x82\x01Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11as\x99Was\x96\x92\x01asKV[\x90V[a\x03\xB0V[a\x03\xACV[` \x91\x81R\x01\x90V[\x91\x90as\xC6\x81as\xBF\x81as\xCB\x95as\xA3V[\x80\x95a\x17\x1DV[a\x08\xB9V[\x01\x90V[\x90\x91as\xE6\x92` \x83\x01\x92_\x81\x85\x03\x91\x01Ras\xACV[\x90V[as\xF3`2a\x15QV[\x90V[\x94\x93\x91``\x91at7\x94at\"at/\x93at\x18`\x80\x8B\x01\x94_\x8C\x01\x90a\x0C!V[` \x8A\x01\x90a\x0C\xBCV[\x87\x82\x03`@\x89\x01Ra\x0E(V[\x94\x01\x90a\x05WV[V[\x91atE\x81\x85\x90a-~V[atWatQ_a,\xC2V[\x91a\x05TV[\x14au\xF1Watg\x81\x85\x90a-~V[at{atua\xC3Paq\xFFV[\x91a\x05TV[\x11au\xEBW_at\x89a9xV[\x94at\x930a<\x85V[at\xB5c1\xE3\xBD\x1B\x94\x92\x94at\xC0at\xA9a\x03\xA2V[\x96\x87\x95\x86\x94\x85\x94aJ\xF0V[\x84R`\x04\x84\x01as\xCFV[\x03\x91Z\xFA\x80\x91_\x92au\xC7W[P\x15_\x14au\xBEWP`\x01au\xB9W[at\xE6\x83a\r\x97V[at\xFFat\xF9at\xF4as\xE9V[a\x05TV[\x91a\x05TV[\x11_\x14au\xABWau\x0Eas\xE9V[[au\x180a<\x85V[\x90ce\xA6\x93n\x93\x92\x94\x90\x82;\x15au\xA6W_\x94auS\x86\x92auH\x94au<a\x03\xA2V[\x99\x8A\x98\x89\x97\x88\x96aJ\xF0V[\x86R`\x04\x86\x01as\xF6V[\x03\x92Z\xF1\x90\x81auzW[P\x15_\x14auuW`\x01aupW[[V[aumV[aunV[au\x99\x90_=\x81\x11au\x9FW[au\x91\x81\x83a\x08\xD7V[\x81\x01\x90aJ\xF6V[_au^V[P=au\x87V[aJ\xECV[au\xB4\x83a\r\x97V[au\x0FV[PPPV[\x90\x92P\x91at\xDDV[au\xE4\x91\x92P=\x80_\x83>au\xDC\x81\x83a\x08\xD7V[\x81\x01\x90asnV[\x90_at\xCDV[PPPPV[PPPPV[_av\x0B\x91av\x04a'\xAEV[P\x01am\xDFV[\x90V[_R` _ \x90V[av \x81am\xDFV[\x82\x10\x15av:Wav2`\x01\x91av\x0EV[\x91\x02\x01\x90_\x90V[a\x07~V[avO\x90`\x08avT\x93\x02a\x0CxV[a\x10\xB0V[\x90V[\x90avb\x91Tav?V[\x90V[av\x83\x91_av}\x92avvan\x95V[P\x01av\x17V[\x90avWV[\x90V[av\x8F_a%\xBDV[av\x99\x82_a&\x9AV[\x90av\xCDav\xC7\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x10\x06V[\x91a\x10\x06V[\x91av\xD6a\x03\xA2V[\x80av\xE0\x81a\x04KV[\x03\x90\xA3V[av\xEDa;\"V[Paw\x15aw\x0Faw\x08aw\x03`\x06\x85\x90a34V[a3JV[\x84\x90ad\xE4V[\x15a\x04\xC2V[aw\xB7Waw5\x91aw+aw0\x92`\x03a\x0F\xC8V[a\x10\x12V[aG\xA0V[aw@_\x82\x01a>\xADV[awRawL_a,\xC2V[\x91a\x05TV[\x14\x80\x15aw\x91W[aw\x8BWaw\x80awzaw\x86\x92awt_B\x92\x01a>\xADV[\x90a5\xD6V[\x92a\x05TV[\x91a\x05TV[\x10\x15\x90V[PP_\x90V[Paw\x9E``\x82\x01a^\x1AV[aw\xB1aw\xAB`\x03a\x11YV[\x91a\x11YV[\x14awZV[PPP_\x90V[aw\xD2aw\xCDaw\xD7\x92aUUV[a\x07IV[a\x05TV[\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[ax\0\x91aw\xFAan\x95V[\x91am\x88V[V[ax\x0B\x81am\\V[\x80\x15ax,W`\x01\x90\x03\x90ax)ax#\x83\x83am`V[\x90aw\xEEV[UV[aw\xDAV[ax9a;\"V[PaxPaxK`\x01\x83\x01\x84\x90am\xE3V[a\t>V[\x90\x81axdax^_a,\xC2V[\x91a\x05TV[\x14\x15_\x14ay0Wax\xE2\x92`\x01ax\xDD\x92\x84ax\x8B_\x96ax\x85\x85aw\xBEV[\x90a5\xD6V[ax\xA8ax\x99\x88\x85\x01am\xDFV[ax\xA2\x86aw\xBEV[\x90a5\xD6V[\x81ax\xBBax\xB5\x83a\x05TV[\x91a\x05TV[\x03ax\xE7W[PPPax\xD7ax\xD2\x86\x83\x01amPV[ax\x02V[\x01am\xE3V[a)\xBFV[`\x01\x90V[ay(\x92ay\x1Aay\x06ay\0ay#\x94\x8C\x89\x01av\x17V[\x90avWV[\x93ay\x14\x85\x91\x8C\x89\x01av\x17V[\x90am\x88V[\x91\x85\x85\x01am\xE3V[a0\x18V[_\x80\x80ax\xC1V[PPP_\x90V[\x90V[ayNayIayS\x92ay7V[a\x07IV[a\x05TV[\x90V[ay\x8Bay\x92\x94ay\x81``\x94\x98\x97\x95ayw`\x80\x86\x01\x9A_\x87\x01\x90a\x0F\x04V[` \x85\x01\x90a\x11)V[`@\x83\x01\x90a\x0F\x04V[\x01\x90a\x0F\x04V[V[ay\xA8ay\xA3ay\xAD\x92a%\xCAV[a&wV[a\x0F\x01V[\x90V[\x93\x92\x93ay\xBBaJ\xADV[Pay\xC4an\x91V[Pay\xCDan\x95V[Pay\xD7\x85aj\xE6V[az\taz\x03\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0ay:V[\x91a\x05TV[\x11az\x96W\x90az,` \x94\x95_\x94\x93\x92\x93az#a\x03\xA2V[\x94\x85\x94\x85ayVV[\x83\x80R\x03\x90`\x01Z\xFA\x15az\x91WazD_Qa&wV[\x80az_azYazT_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14azuW_\x91azo_ay\x94V[\x91\x92\x91\x90V[Paz\x7F_a%\xE9V[`\x01\x91az\x8B_ay\x94V[\x91\x92\x91\x90V[aK(V[PPPaz\xA2_a%\xE9V[\x90`\x03\x92\x91\x92\x91\x90V\xFE\xA1dsolcC\0\x08\x1A\0\n",
    );
    /// The runtime bytecode of the contract, as deployed on the network.
    ///
    /// ```text
    ///0x60806040526004361015610013575b612523565b61001d5f3561039c565b806305778550146103975780630758236f146103925780630c76697a1461038d578063191cbd1a146103885780631e8f5ee514610383578063208129561461037e57806322f1ec93146103795780632bf4d6a7146103745780632c9576881461036f5780632dae18851461036a5780632f4bd7b81461036557806331e3bd1b146103605780633644e5151461035b5780633ac3cbe6146103565780633e6e34a7146103515780633fd62c6d1461034c57806340235a9c1461034757806348f4da20146103425780635685cf681461033d57806356c4e17d1461033857806359dcea12146103335780635a936dc61461032e5780635cce98a6146103295780636076439c1461032457806360cf09911461031f57806361d6b86c1461031a57806362c7e8fc1461031557806365a6936e146103105780636bfe06a61461030b578063715018a61461030657806371e7388c146103015780637639d227146102fc57806379ba5097146102f75780637b9f64b2146102f257806381beac2e146102ed57806384ef7322146102e85780638da5cb5b146102e357806396686c1e146102de5780639cbdae22146102d9578063adff830c146102d4578063ae470a85146102cf578063b074e9dd146102ca578063b99f6759146102c5578063ba1fb103146102c0578063c1ef9ddf146102bb578063c5d960bb146102b6578063cfe34749146102b1578063d551162c146102ac578063da435a7c146102a7578063e30c3978146102a2578063e65cafcb1461029d578063ee1c039014610298578063f2fde38b14610293578063f9107f3b1461028e578063f9f16762146102895763ffcf08f00361000e576124ef565b6124ba565b612457565b6123f7565b6123c1565b61238d565b612358565b612320565b61224e565b612219565b6121d7565b6121a2565b612078565b612044565b611fd7565b611f9d565b611ed2565b611e0b565b611c82565b611bc8565b611b95565b611b5e565b611ac9565b611a96565b611a60565b611a2a565b61196e565b611939565b6118cb565b611686565b61163c565b6115ba565b611585565b611517565b611482565b611429565b6113f4565b61138f565b611345565b6112d9565b611205565b6111cb565b610f93565b610f26565b610ea7565b610d2c565b610cde565b610c43565b610b9d565b610a6a565b6106c6565b610674565b610640565b610579565b61051f565b610450565b60e01c90565b60405190565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff1690565b6103ca816103b4565b036103d157565b5f80fd5b905035906103e2826103c1565b565b60018060a01b031690565b6103f8906103e4565b90565b610404816103ef565b0361040b57565b5f80fd5b9050359061041c826103fb565b565b9190604083820312610446578061043a610443925f86016103d5565b9360200161040f565b90565b6103ac565b5f0190565b3461047f5761046961046336600461041e565b906126ba565b6104716103a2565b8061047b8161044b565b0390f35b6103a8565b9060208282031261049d5761049a915f016103d5565b90565b6103ac565b6104ab906103b4565b9052565b60ff1690565b6104be906104af565b9052565b151590565b6104d0906104c2565b9052565b90604080610508936104ec5f8201515f8601906104a2565b6104fe602082015160208601906104b5565b01519101906104c7565b565b919061051d905f606085019401906104d4565b565b3461054f5761054b61053a610535366004610484565b612799565b6105426103a2565b9182918261050a565b0390f35b6103a8565b90565b61056090610554565b9052565b9190610577905f60208501940190610557565b565b346105aa576105a661059561058f36600461041e565b906127b2565b61059d6103a2565b91829182610564565b0390f35b6103a8565b5f80fd5b5f80fd5b5f80fd5b909182601f830112156105f55781359167ffffffffffffffff83116105f05760200192602083028401116105eb57565b6105b7565b6105b3565b6105af565b91909160408184031261063b57610613835f83016103d5565b92602082013567ffffffffffffffff81116106365761063292016105bb565b9091565b6103b0565b6103ac565b3461066f576106596106533660046105fa565b9161313b565b6106616103a2565b8061066b8161044b565b0390f35b6103a8565b346106a35761068d61068736600461041e565b906133a1565b6106956103a2565b8061069f8161044b565b0390f35b6103a8565b906020828203126106c1576106be915f0161040f565b90565b6103ac565b346106f4576106de6106d93660046106a8565b6134b7565b6106e66103a2565b806106f08161044b565b0390f35b6103a8565b61070281610554565b0361070957565b5f80fd5b9050359061071a826106f9565b565b91906040838203126107445780610738610741925f86016103d5565b9360200161070d565b90565b6103ac565b90565b61076061075b610765926103b4565b610749565b6103b4565b90565b906107729061074c565b5f5260205260405f2090565b634e487b7160e01b5f52603260045260245ffd5b5490565b5f5260205f2090565b5f5260205f2090565b6107b181610792565b8210156107cb576107c3600491610796565b910201905f90565b61077e565b634e487b7160e01b5f52602260045260245ffd5b9060016002830492168015610804575b60208310146107ff57565b6107d0565b91607f16916107f4565b60209181520190565b5f5260205f2090565b905f929180549061083a610833836107e4565b809461080e565b916001811690815f146108915750600114610855575b505050565b6108629192939450610817565b915f925b81841061087957505001905f8080610850565b60018160209295939554848601520191019290610866565b92949550505060ff19168252151560200201905f8080610850565b906108b691610820565b90565b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b906108e1906108b9565b810190811067ffffffffffffffff8211176108fb57604052565b6108c3565b90610920610919926109106103a2565b938480926108ac565b03836108d7565b565b5f1c90565b90565b61093661093b91610922565b610927565b90565b610948905461092a565b90565b60ff1690565b61095d61096291610922565b61094b565b90565b61096f9054610951565b90565b61097d906008610768565b9061098782610792565b8110156109cd57610997916107a8565b50906109a45f8301610900565b916109b16001820161093e565b916109ca60036109c36002850161093e565b9301610965565b90565b5f80fd5b5190565b60209181520190565b90825f9392825e0152565b610a08610a11602093610a16936109ff816109d1565b938480936109d5565b958691016109de565b6108b9565b0190565b610a23906104c2565b9052565b610a61610a6894610a57610a4c6060959998969960808601908682035f8801526109e9565b986020850190610557565b6040830190610557565b0190610a1a565b565b34610a9f57610a9b610a86610a8036600461071c565b90610972565b90610a929492946103a2565b94859485610a27565b0390f35b6103a8565b610aad816104af565b03610ab457565b5f80fd5b90503590610ac582610aa4565b565b909182601f83011215610b015781359167ffffffffffffffff8311610afc576020019260018302840111610af757565b6105b7565b6105b3565b6105af565b919060c083820312610b9857610b1e815f85016103d5565b92610b2c82602083016103d5565b92610b3a8360408401610ab8565b92606083013567ffffffffffffffff8111610b935781610b5b918501610ac7565b929093610b6b83608083016103d5565b9260a082013567ffffffffffffffff8111610b8e57610b8a9201610ac7565b9091565b6103b0565b6103b0565b6103ac565b34610bd557610bbf610bb0366004610b06565b96959095949194939293613966565b610bc76103a2565b80610bd18161044b565b0390f35b6103a8565b5f910312610be457565b6103ac565b90565b610c00610bfb610c0592610be9565b610749565b6103b4565b90565b610c1361012c610bec565b90565b610c1e610c08565b90565b610c2a906103b4565b9052565b9190610c41905f60208501940190610c21565b565b34610c7357610c53366004610bda565b610c6f610c5e610c16565b610c666103a2565b91829182610c2e565b0390f35b6103a8565b1c90565b60018060a01b031690565b610c97906008610c9c9302610c78565b610c7c565b90565b90610caa9154610c87565b90565b610cb9600b5f90610c9f565b90565b610cc5906103ef565b9052565b9190610cdc905f60208501940190610cbc565b565b34610d0e57610cee366004610bda565b610d0a610cf9610cad565b610d016103a2565b91829182610cc9565b0390f35b6103a8565b610d1e61012c610bec565b90565b610d29610d13565b90565b34610d5c57610d3c366004610bda565b610d58610d47610d21565b610d4f6103a2565b91829182610c2e565b0390f35b6103a8565b90602082820312610d92575f82013567ffffffffffffffff8111610d8d57610d899201610ac7565b9091565b6103b0565b6103ac565b5190565b60209181520190565b60200190565b610dc9610dd2602093610dd793610dc0816109d1565b9384809361080e565b958691016109de565b6108b9565b0190565b610de490610554565b9052565b90610e1290602080610e07604084015f8701518582035f870152610daa565b940151910190610ddb565b90565b90610e1f91610de8565b90565b60200190565b90610e3c610e3583610d97565b8092610d9b565b9081610e4d60208302840194610da4565b925f915b838310610e6057505050505090565b90919293946020610e82610e7c83856001950387528951610e15565b97610e22565b9301930191939290610e51565b610ea49160208201915f818403910152610e28565b90565b34610ed857610ed4610ec3610ebd366004610d61565b906139b2565b610ecb6103a2565b91829182610e8f565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b90565b610f0d90610f01565b9052565b9190610f24905f60208501940190610f04565b565b34610f5657610f36366004610bda565b610f52610f41610edd565b610f496103a2565b91829182610f11565b0390f35b6103a8565b90565b610f72610f6d610f7792610f5b565b610749565b6103b4565b90565b610f85610e10610f5e565b90565b610f90610f7a565b90565b34610fc357610fa3366004610bda565b610fbf610fae610f88565b610fb66103a2565b91829182610c2e565b0390f35b6103a8565b90610fd29061074c565b5f5260205260405f2090565b610ff2610fed610ff7926103e4565b610749565b6103e4565b90565b61100390610fde565b90565b61100f90610ffa565b90565b9061101c90611006565b5f5260205260405f2090565b67ffffffffffffffff1690565b61104161104691610922565b611028565b90565b6110539054611035565b90565b60401c90565b60ff1690565b61106e61107391611056565b61105c565b90565b6110809054611062565b90565b60481c90565b60ff1690565b61109b6110a091611083565b611089565b90565b6110ad905461108f565b90565b90565b6110bf6110c491610922565b6110b0565b90565b6110d190546110b3565b90565b906110e36110e8926003610fc8565b611012565b6110f35f820161093e565b9161110060018301611049565b9161110d60018201611076565b91611126600261111f600185016110a3565b93016110c7565b90565b611132906104af565b9052565b634e487b7160e01b5f52602160045260245ffd5b6005111561115457565b611136565b906111638261114a565b565b61116e90611159565b90565b61117a90611165565b9052565b909594926111c9946111b86111c2926111ae6080966111a460a088019c5f890190610557565b6020870190610c21565b6040850190611129565b6060830190611171565b0190610f04565b565b34611200576111fc6111e76111e136600461041e565b906110d4565b916111f39593956103a2565b9586958661117e565b0390f35b6103a8565b346112355761123161122061121b366004610484565b6139cc565b6112286103a2565b91829182610564565b0390f35b6103a8565b5190565b60209181520190565b60200190565b611256906103ef565b9052565b906112678160209361124d565b0190565b60200190565b9061128e6112886112818461123a565b809361123e565b92611247565b905f5b81811061129e5750505090565b9091926112b76112b1600192865161125a565b9461126b565b9101919091611291565b6112d69160208201915f818403910152611271565b90565b34611309576113056112f46112ef366004610484565b613a86565b6112fc6103a2565b918291826112c1565b0390f35b6103a8565b90565b61132561132061132a9261130e565b610749565b610554565b90565b61133760c8611311565b90565b61134261132d565b90565b3461137557611355366004610bda565b61137161136061133a565b6113686103a2565b91829182610564565b0390f35b6103a8565b919061138d905f60208501940190610a1a565b565b346113c0576113bc6113ab6113a536600461041e565b90613b26565b6113b36103a2565b9182918261137a565b0390f35b6103a8565b906113cf9061074c565b5f5260205260405f2090565b6113f1906113ec6007915f926113c5565b610c9f565b90565b346114245761142061140f61140a366004610484565b6113db565b6114176103a2565b91829182610cc9565b0390f35b6103a8565b346114595761145561144461143f366004610484565b613bad565b61144c6103a2565b918291826112c1565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b346114b257611492366004610bda565b6114ae61149d61145e565b6114a56103a2565b91829182610cc9565b0390f35b6103a8565b90608082820312611512576114ce815f84016103d5565b926114dc82602085016103d5565b926114ea8360408301610ab8565b92606082013567ffffffffffffffff811161150d576115099201610ac7565b9091565b6103b0565b6103ac565b346115495761153361152a3660046114b7565b93929092613c1f565b61153b6103a2565b806115458161044b565b0390f35b6103a8565b90565b61156561156061156a9261154e565b610749565b610554565b90565b6115776032611551565b90565b61158261156d565b90565b346115b557611595366004610bda565b6115b16115a061157a565b6115a86103a2565b91829182610564565b0390f35b6103a8565b346115eb576115e76115d66115d036600461041e565b90613c2e565b6115de6103a2565b9182918261137a565b0390f35b6103a8565b90565b61160761160261160c926115f0565b610749565b6104af565b90565b61161960036115f3565b90565b61162461160f565b90565b919061163a905f60208501940190611129565b565b3461166c5761164c366004610bda565b61166861165761161c565b61165f6103a2565b91829182611627565b0390f35b6103a8565b9190611684905f60208501940190611171565b565b346116b7576116b36116a261169c36600461041e565b90613c5a565b6116aa6103a2565b91829182611671565b0390f35b6103a8565b906116cf6116c86103a2565b92836108d7565b565b67ffffffffffffffff81116116e95760208091020190565b6108c3565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff8111611718576117146020916108b9565b0190565b6108c3565b90825f939282370152565b9092919261173d611738826116fa565b6116bc565b93818552602085019082840111611759576117579261171d565b565b6116f6565b9080601f8301121561177c5781602061177993359101611728565b90565b6105af565b9190916040818403126117d45761179860406116bc565b925f8201359167ffffffffffffffff83116117cf576117bc826117c894830161175e565b5f86015260200161070d565b6020830152565b6116f2565b6116ee565b9291906117ed6117e8826116d1565b6116bc565b93818552602080860192028101918383116118445781905b838210611813575050505050565b813567ffffffffffffffff811161183f576020916118348784938701611781565b815201910190611805565b6105af565b6105b7565b9080601f8301121561186757816020611864933591016117d9565b90565b6105af565b6080818303126118c657611882825f83016103d5565b92611890836020840161040f565b9260408301359067ffffffffffffffff82116118c1576118b5816118be938601611849565b9360600161070d565b90565b6103b0565b6103ac565b346118fd576118e76118de36600461186c565b92919091614040565b6118ef6103a2565b806118f98161044b565b0390f35b6103a8565b90565b61191961191461191e92611902565b610749565b610554565b90565b61192b6040611905565b90565b611936611921565b90565b3461196957611949366004610bda565b61196561195461192e565b61195c6103a2565b91829182610564565b0390f35b6103a8565b3461199c5761197e366004610bda565b61198661466f565b61198e6103a2565b806119988161044b565b0390f35b6103a8565b6119aa90611165565b9052565b6119b790610f01565b9052565b90608080611a13936119d35f8201515f860190610ddb565b6119e5602082015160208601906104a2565b6119f7604082015160408601906104b5565b611a09606082015160608601906119a1565b01519101906119ae565b565b9190611a28905f60a085019401906119bb565b565b34611a5b57611a57611a46611a4036600461041e565b906147ac565b611a4e6103a2565b91829182611a15565b0390f35b6103a8565b34611a9157611a8d611a7c611a7636600461041e565b90614804565b611a846103a2565b91829182610c2e565b0390f35b6103a8565b34611ac457611aa6366004610bda565b611aae61482c565b611ab66103a2565b80611ac08161044b565b0390f35b6103a8565b34611af957611af5611ae4611adf366004610484565b61487d565b611aec6103a2565b91829182610564565b0390f35b6103a8565b9091606082840312611b3357611b30611b19845f85016103d5565b93611b27816020860161070d565b9360400161070d565b90565b6103ac565b92916020611b54611b5c9360408701908782035f890152611271565b940190610557565b565b34611b9057611b77611b71366004611afe565b9161491b565b90611b8c611b836103a2565b92839283611b38565b0390f35b6103a8565b34611bc357611bad611ba83660046106a8565b614aa2565b611bb56103a2565b80611bbf8161044b565b0390f35b6103a8565b34611bf857611bd8366004610bda565b611bf4611be3614ab1565b611beb6103a2565b91829182610cc9565b0390f35b6103a8565b909182601f83011215611c375781359167ffffffffffffffff8311611c32576020019260208302840111611c2d57565b6105b7565b6105b3565b6105af565b919091604081840312611c7d57611c55835f83016103d5565b92602082013567ffffffffffffffff8111611c7857611c749201611bfd565b9091565b6103b0565b6103ac565b34611cb157611c9b611c95366004611c3c565b91614b38565b611ca36103a2565b80611cad8161044b565b0390f35b6103a8565b91606083830312611d0257611ccd825f85016103d5565b92611cdb836020830161040f565b92604082013567ffffffffffffffff8111611cfd57611cfa920161175e565b90565b6103b0565b6103ac565b90611d119061074c565b5f5260205260405f2090565b90611d2790611006565b5f5260205260405f2090565b905090565b611d5d611d5492602092611d4b816109d1565b94858093611d33565b938491016109de565b0190565b90565b611d70611d7591610554565b611d61565b9052565b611d89611d909160209493611d38565b8092611d64565b0190565b611da8611d9f6103a2565b92839283611d79565b03902090565b611db791611d94565b90565b611dca906008611dcf9302610c78565b610927565b90565b90611ddd9154611dba565b90565b90611e0892611dfe611e0392611df96009955f96611d07565b611d1d565b611dae565b611dd2565b90565b34611e3c57611e38611e27611e21366004611cb6565b91611de0565b611e2f6103a2565b91829182610564565b0390f35b6103a8565b909182601f83011215611e7b5781359167ffffffffffffffff8311611e76576020019260018302840111611e7157565b6105b7565b6105b3565b6105af565b91606083830312611ecd57611e97825f85016103d5565b92611ea5836020830161040f565b92604082013567ffffffffffffffff8111611ec857611ec49201611e41565b9091565b6103b0565b6103ac565b34611f0457611eee611ee5366004611e80565b92919091614d9d565b611ef66103a2565b80611f008161044b565b0390f35b6103a8565b611f12816104c2565b03611f1957565b5f80fd5b90503590611f2a82611f09565b565b91909160a081840312611f9857611f45835f83016103d5565b92602082013567ffffffffffffffff8111611f935781611f66918401611e41565b929093611f90611f79846040850161070d565b93611f87816060860161070d565b93608001611f1d565b90565b6103b0565b6103ac565b34611fd257611fbc611fb0366004611f2c565b94939093929192615072565b611fc46103a2565b80611fce8161044b565b0390f35b6103a8565b3461200557611fef611fea366004610484565b615427565b611ff76103a2565b806120018161044b565b0390f35b6103a8565b909160608284031261203f5761203c612025845f85016103d5565b9361203381602086016103d5565b93604001610ab8565b90565b6103ac565b346120735761205d61205736600461200a565b9161569c565b6120656103a2565b8061206f8161044b565b0390f35b6103a8565b346120a75761209161208b36600461041e565b9061585b565b6120996103a2565b806120a38161044b565b0390f35b6103a8565b5190565b60209181520190565b60200190565b9061210d906060806120de608084015f8701518582035f870152610daa565b946120f160208201516020860190610ddb565b61210360408201516040860190610ddb565b01519101906104c7565b90565b9061211a916120bf565b90565b60200190565b90612137612130836120ac565b80926120b0565b9081612148602083028401946120b9565b925f915b83831061215b57505050505090565b9091929394602061217d61217783856001950387528951612110565b9761211d565b930193019193929061214c565b61219f9160208201915f818403910152612123565b90565b346121d2576121ce6121bd6121b8366004610484565b615bd2565b6121c56103a2565b9182918261218a565b0390f35b6103a8565b34612205576121ef6121ea366004610484565b615d62565b6121f76103a2565b806122018161044b565b0390f35b6103a8565b612216600a5f90610c9f565b90565b3461224957612229366004610bda565b61224561223461220a565b61223c6103a2565b91829182610cc9565b0390f35b6103a8565b346122825761227e61226d612264366004611e80565b92919091615dcf565b6122756103a2565b91829182610564565b0390f35b6103a8565b906122919061074c565b5f5260205260405f2090565b6122a96122ae91611083565b61094b565b90565b6122bb905461229d565b90565b6122c9906002612287565b6122d45f8201611049565b916122eb5f6122e4818501611076565b93016122b1565b90565b60409061231761231e949695939661230d60608401985f850190610c21565b6020830190611129565b0190610a1a565b565b346123535761234f61233b612336366004610484565b6122be565b6123469391936103a2565b938493846122ee565b0390f35b6103a8565b3461238857612368366004610bda565b612384612373615e04565b61237b6103a2565b91829182610cc9565b0390f35b6103a8565b346123bc576123a66123a036600461041e565b90615eee565b6123ae6103a2565b806123b88161044b565b0390f35b6103a8565b346123f2576123ee6123dd6123d736600461041e565b90616083565b6123e56103a2565b9182918261137a565b0390f35b6103a8565b346124255761240f61240a3660046106a8565b616182565b6124176103a2565b806124218161044b565b0390f35b6103a8565b9190604083820312612452578061244661244f925f86016103d5565b93602001611f1d565b90565b6103ac565b346124865761247061246a36600461242a565b9061618d565b6124786103a2565b806124828161044b565b0390f35b6103a8565b7f32721f8dc67e953c540da90f663059c23fc47f70d11e317ed6d5a24c8b85637490565b6124b761248b565b90565b346124ea576124ca366004610bda565b6124e66124d56124af565b6124dd6103a2565b91829182610f11565b0390f35b6103a8565b3461251e5761250861250236600461041e565b90616256565b6125106103a2565b8061251a8161044b565b0390f35b6103a8565b5f80fd5b5f7f4f6e6c792054616e676c6520636f726500000000000000000000000000000000910152565b61255b60106020926109d5565b61256481612527565b0190565b61257d9060208101905f81830391015261254e565b90565b1561258757565b61258f6103a2565b62461bcd60e51b8152806125a560048201612568565b0390fd5b6125b56125ba91610922565b610c7c565b90565b6125c790546125a9565b90565b90565b6125e16125dc6125e6926125ca565b610749565b6103e4565b90565b6125f2906125cd565b90565b5f7f416c726561647920726567697374657265640000000000000000000000000000910152565b61262960126020926109d5565b612632816125f5565b0190565b61264b9060208101905f81830391015261261c565b90565b1561265557565b61265d6103a2565b62461bcd60e51b81528061267360048201612636565b0390fd5b5f1b90565b9061268d60018060a01b0391612677565b9181191691161790565b90565b906126af6126aa6126b692611006565b612697565b825461267c565b9055565b61273c612741926126fd336126f76126f17f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b61273461271461270f600786906113c5565b6125bd565b61272e6127286127235f6125e9565b6103ef565b916103ef565b1461264e565b9160076113c5565b61269a565b565b61274d60606116bc565b90565b5f90565b5f90565b5f90565b612764612743565b906020808084612772612750565b81520161277d612754565b815201612788612758565b81525050565b61279661275c565b90565b6127ab906127a561278e565b5061637e565b90565b5f90565b6127d36127d9926127ce5f936127c66127ae565b506003610fc8565b611012565b0161093e565b90565b5f7f4e6f742073657276696365206f776e6572000000000000000000000000000000910152565b61281060116020926109d5565b612819816127dc565b0190565b6128329060208101905f818303910152612803565b90565b1561283c57565b6128446103a2565b62461bcd60e51b81528061285a6004820161281d565b0390fd5b5090565b5f7f546f6f206d616e7920646566696e6974696f6e73000000000000000000000000910152565b61289660146020926109d5565b61289f81612862565b0190565b6128b89060208101905f818303910152612889565b90565b156128c257565b6128ca6103a2565b62461bcd60e51b8152806128e0600482016128a3565b0390fd5b634e487b7160e01b5f52601160045260245ffd5b61290761290d91939293610554565b92610554565b91612919838202610554565b92818404149015171561292857565b6128e4565b6129389060046128f8565b90565b9061294e905f1990602003600802610c78565b8154169055565b1b90565b9190600861297491029161296e5f1984612955565b92612955565b9181191691161790565b61299261298d61299792610554565b610749565b610554565b90565b90565b91906129b36129ae6129bb9361297e565b61299a565b908354612959565b9055565b6129d1916129cb6127ae565b9161299d565b565b5b8181106129df575050565b806129ec5f6001936129bf565b016129d4565b90612a02905f1990600802610c78565b191690565b81612a11916129f2565b906002021790565b905f91612a30612a2882610817565b928354612a07565b905555565b601f602091010490565b919290602082105f14612a9857601f8411600114612a6857612a62929350612a07565b90555b5b565b5090612a8e612a93936001612a85612a7f85610817565b92612a35565b820191016129d3565b612a19565b612a65565b50612acf8293612aa9600194610817565b612ac8612ab585612a35565b820192601f861680612ada575b50612a35565b01906129d3565b600202179055612a66565b612ae69088860361293b565b5f612ac2565b929091680100000000000000008211612b4c576020115f14612b3d57602081105f14612b2157612b1b91612a07565b90555b5b565b60019160ff1916612b3184610817565b55600202019055612b1e565b60019150600202019055612b1f565b6108c3565b908154612b5d816107e4565b90818311612b86575b818310612b74575b50505050565b612b7d93612a3f565b5f808080612b6e565b612b9283838387612aec565b612b66565b5f612ba191612b51565b565b634e487b7160e01b5f525f60045260245ffd5b905f03612bc857612bc690612b97565b565b612ba3565b60035f91612bdd83808301612bb6565b612bea83600183016129bf565b612bf783600283016129bf565b0155565b905f03612c0d57612c0b90612bcd565b565b612ba3565b5b818110612c1e575050565b80612c2b5f600493612bfb565b01612c13565b9091828110612c40575b505050565b612c5e612c58612c52612c699561292d565b9261292d565b92610796565b918201910190612c12565b5f8080612c3b565b90680100000000000000008111612c9a5781612c8f612c9893610792565b90828155612c31565b565b6108c3565b5f612ca991612c71565b565b905f03612cbd57612cbb90612c9f565b565b612ba3565b612cd6612cd1612cdb926125ca565b610749565b610554565b90565b6001612cea9101610554565b90565b5f80fd5b5f80fd5b5f80fd5b903590600160800381360303821215612d10570190565b612ced565b90821015612d2f576020612d2c9202810190612cf9565b90565b61077e565b903590600160200381360303821215612d76570180359067ffffffffffffffff8211612d7157602001916001820236038313612d6c57565b612cf5565b612cf1565b612ced565b91565b5090565b5f7f4e616d6520746f6f206c6f6e6700000000000000000000000000000000000000910152565b612db6600d6020926109d5565b612dbf81612d82565b0190565b612dd89060208101905f818303910152612da9565b90565b15612de257565b612dea6103a2565b62461bcd60e51b815280612e0060048201612dc3565b0390fd5b35612e0e816106f9565b90565b5f7f496e76616c696420626f756e6473000000000000000000000000000000000000910152565b612e45600e6020926109d5565b612e4e81612e11565b0190565b612e679060208101905f818303910152612e38565b90565b15612e7157565b612e796103a2565b62461bcd60e51b815280612e8f60048201612e52565b0390fd5b90565b5f5260205f2090565b5490565b612eac81612e9f565b821015612ec657612ebe600491612e96565b910201905f90565b61077e565b5090565b9190601f8111612edf575b505050565b612eeb612f1093610817565b906020612ef784612a35565b83019310612f18575b612f0990612a35565b01906129d3565b5f8080612eda565b9150612f0981929050612f00565b91612f319082612ecb565b9067ffffffffffffffff8211612ff057612f5582612f4f85546107e4565b85612ecf565b5f90601f8311600114612f8857918091612f77935f92612f7c575b5050612a07565b90555b565b90915001355f80612f70565b601f19831691612f9785610817565b925f5b818110612fd857509160029391856001969410612fbe575b50505002019055612f7a565b612fce910135601f8416906129f2565b90555f8080612fb2565b91936020600181928787013581550195019201612f9a565b6108c3565b906130009291612f26565b565b9061300e5f1991612677565b9181191691161790565b9061302d6130286130349261297e565b61299a565b8254613002565b9055565b3561304281611f09565b90565b9061305160ff91612677565b9181191691161790565b613064906104c2565b90565b90565b9061307f61307a6130869261305b565b613067565b8254613045565b9055565b906130e8606060036130ee946130ae5f82016130a85f880188612d34565b91612ff5565b6130c7600182016130c160208801612e04565b90613018565b6130e0600282016130da60408801612e04565b90613018565b019201613038565b9061306a565b565b9190613101576130ff9161308a565b565b612ba3565b9081549168010000000000000000831015613136578261312e91600161313495018155612ea3565b906130f0565b565b6108c3565b9291909261316e3361316861316261315d613158600787906113c5565b6125bd565b6103ef565b916103ef565b14612835565b61319c61317c85849061285e565b61319561318f61318a61156d565b610554565b91610554565b11156128bb565b6131b15f6131ac60088490610768565b612cab565b6131ba5f612cc2565b5b806131d86131d26131cd88879061285e565b610554565b91610554565b10156132ab576132a69061322f61320f6132096132036131fa8a898791612d15565b5f810190612d34565b90612d7b565b90612d7e565b61322861322261321d611921565b610554565b91610554565b1115612ddb565b613278613249604061324389888691612d15565b01612e04565b61327161326b61326660206132608c8b8991612d15565b01612e04565b610554565b91610554565b1015612e6a565b6132a161328f61328a60088690610768565b612e93565b61329b88878591612d15565b90613106565b612cde565b6131bb565b5050509050565b5f7f5a65726f20616464726573730000000000000000000000000000000000000000910152565b6132e6600c6020926109d5565b6132ef816132b2565b0190565b6133089060208101905f8183039101526132d9565b90565b1561331257565b61331a6103a2565b62461bcd60e51b815280613330600482016132f3565b0390fd5b9061333e9061074c565b5f5260205260405f2090565b90565b60481b90565b9061336869ff0000000000000000009161334d565b9181191691161790565b61337b90611159565b90565b90565b9061339661339161339d92613372565b61337e565b8254613353565b9055565b6133dd336133d76133d17f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b613402826133fb6133f56133f05f6125e9565b6103ef565b916103ef565b141561330b565b61342861342361341c61341760068590613334565b61334a565b849061645c565b61264e565b61344b6002600161344561343e60038690610fc8565b8690611012565b01613381565b9061347f6134797f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b9361074c565b91611006565b916134886103a2565b806134928161044b565b0390a3565b6134a8906134a3616496565b6134aa565b565b6134b590600b61269a565b565b6134c090613497565b565b5f7f4e6f742072656769737465726564206f70657261746f72000000000000000000910152565b6134f660176020926109d5565b6134ff816134c2565b0190565b6135189060208101905f8183039101526134e9565b90565b1561352257565b61352a6103a2565b62461bcd60e51b81528061354060048201613503565b0390fd5b906135799796959493929161357461356f613568613563846006613334565b61334a565b33906164e4565b61351b565b6137ba565b565b61358f61358a613594926103b4565b610749565b610554565b90565b6135ab6135a66135b092610554565b610749565b6103b4565b90565b9160206135d49294936135cd60408201965f830190610c21565b0190610c21565b565b6135e56135eb91939293610554565b92610554565b82039182116135f657565b6128e4565b67ffffffffffffffff8111613619576136156020916108b9565b0190565b6108c3565b9092919261363361362e826135fb565b6116bc565b9381855260208501908284011161364f5761364d9261171d565b565b6116f6565b61365f91369161361e565b90565b60200190565b5190565b949290979695939160e08601985f870161368591610f04565b6020860161369291610cbc565b6040850161369f91610c21565b606084016136ac91610c21565b608083016136b991611129565b60a082016136c691610f04565b60c0016136d291610c21565b565b5f61190160f01b910152565b6136ec60028092611d33565b6136f5816136d4565b0190565b90565b61370861370d91610f01565b6136f9565b9052565b602080939261372c613725613734946136e0565b80926136fc565b0180926136fc565b0190565b5f7f496e76616c6964207369676e6174757265000000000000000000000000000000910152565b61376c60116020926109d5565b61377581613738565b0190565b61378e9060208101905f81830391015261375f565b90565b1561379857565b6137a06103a2565b62461bcd60e51b8152806137b660048201613779565b0390fd5b919293949796909597806137d66137d042610554565b9161357b565b1161393e576137ee426137e88361357b565b906135d6565b6138076138016137fc610d13565b61357b565b91610554565b116139165761391497986138eb61390993856138758a6138668d6138f1988d8d61383d61383261248b565b963399959293613654565b61384f61384982613668565b91613662565b20929361385a6103a2565b9889976020890161366c565b602082018103825203826108d7565b61388761388182613668565b91613662565b206138d27f00000000000000000000000000000000000000000000000000000000000000006138c36138b76103a2565b93849260208401613711565b602082018103825203826108d7565b6138e46138de82613668565b91613662565b2092613654565b9061651e565b6139036138fd336103ef565b916103ef565b14613791565b9333919293946166b5565b565b61391f42613597565b9061393a5f9283926318355b7560e21b8452600484016135b3565b0390fd5b61394742613597565b906139625f9283926357ea02e960e01b8452600484016135b3565b0390fd5b9061397697969594939291613544565b565b606090565b906020828203126139ad575f82013567ffffffffffffffff81116139a8576139a59201611849565b90565b6103b0565b6103ac565b906139c9916139bf613978565b509081019061397d565b90565b6139eb6139e66139f0926139de6127ae565b506005613334565b61334a565b616ac7565b90565b606090565b67ffffffffffffffff8111613a105760208091020190565b6108c3565b90613a27613a22836139f8565b6116bc565b918252565b369037565b90613a56613a3e83613a15565b92602080613a4c86936139f8565b9201910390613a2c565b565b90613a628261123a565b811015613a73576020809102010190565b61077e565b90613a82906103ef565b9052565b90613a8f6139f3565b50613aac613aa7613aa260048590613334565b61334a565b616ac7565b91613ab683613a31565b91613ac05f612cc2565b5b80613ad4613ace87610554565b91610554565b1015613b1b57613b1690613b11613aff613af8613af360048890613334565b61334a565b8390616b16565b613b0c8791849092613a58565b613a78565b612cde565b613ac1565b5092505090565b5f90565b90613b2f613b22565b50613b516001613b4b613b4460038690610fc8565b8490611012565b016110a3565b613b63613b5d5f611159565b91611159565b14918215613b71575b505090565b613b929250600191613b87613b8c926003610fc8565b611012565b016110a3565b613ba5613b9f6001611159565b91611159565b145f80613b6c565b613bd390613bb96139f3565b505f90613bcd613bc761132d565b92612cc2565b9061491b565b5090565b90613c0994939291613c04613bff613bf8613bf3846006613334565b61334a565b33906164e4565b61351b565b613c0b565b565b91613c1d9492939133919293946166b5565b565b90613c2c94939291613bd7565b565b90613c4e613c49613c5393613c41613b22565b506006613334565b61334a565b6164e4565b90565b5f90565b613c7c613c8292613c77600193613c6f613c56565b506003610fc8565b611012565b016110a3565b90565b613c8e90610ffa565b90565b5f7f496e7465726e616c206f6e6c7900000000000000000000000000000000000000910152565b613cc5600d6020926109d5565b613cce81613c91565b0190565b613ce79060208101905f818303910152613cb8565b90565b15613cf157565b613cf96103a2565b62461bcd60e51b815280613d0f60048201613cd2565b0390fd5b67ffffffffffffffff8111613d2b5760208091020190565b6108c3565b90613d42613d3d83613d13565b6116bc565b918252565b369037565b90613d71613d5983613d30565b92602080613d678693613d13565b9201910390613d47565b565b90613d7d82610d97565b811015613d8e576020809102010190565b61077e565b90565b5190565b90613da482613d96565b811015613db5576020809102010190565b61077e565b90613dc490610f01565b9052565b606090565b90565b60209181520190565b905f9291805490613df3613dec836107e4565b8094613dd0565b916001811690815f14613e4a5750600114613e0e575b505050565b613e1b919293945061079f565b915f925b818410613e3257505001905f8080613e09565b60018160209295939554848601520191019290613e1f565b92949550505060ff19168252151560200201905f8080613e09565b90613e6f91613dd9565b90565b90613e92613e8b92613e826103a2565b93848092613e65565b03836108d7565b565b613e9d90613e72565b90565b613eaa9051610f01565b90565b613eb79051610554565b90565b5f7f56616c7565206f7574206f6620626f756e647300000000000000000000000000910152565b613eee60136020926109d5565b613ef781613eba565b0190565b613f13613f219260408301908382035f8501526109e9565b906020818303910152613ee1565b90565b92916020613f40613f489360408701908782035f8901526109e9565b940190610557565b565b905f9291805490613f64613f5d836107e4565b80946109d5565b916001811690815f14613fbb5750600114613f7f575b505050565b613f8c9192939450610817565b915f925b818410613fa357505001905f8080613f7a565b60018160209295939554848601520191019290613f90565b92949550505060ff19168252151560200201905f8080613f7a565b5f7f5265717569726564206d6574726963206d697373696e67000000000000000000910152565b61400a60176020926109d5565b61401381613fd6565b0190565b61402f61403d9260408301908382035f850152613f4a565b906020818303910152613ffd565b90565b929390936140683361406261405c61405730613c85565b6103ef565b916103ef565b14613cea565b61407c61407760088690610768565b612e93565b9461408682613d4c565b946140905f612cc2565b5b806140a461409e86610554565b91610554565b10156140f7576140f2906140ed6140c85f6140c08a8590613d73565b510151613d93565b6140da6140d482613668565b91613662565b206140e88a91849092613d9a565b613dba565b612cde565b614091565b50919490929561410681612e9f565b6141186141125f612cc2565b91610554565b1196614122613dc8565b90886145a2575b6141325f612cc2565b5b806141466141408b610554565b91610554565b10156144055760015f8b614239575b509088878961416b94614170575b505050612cde565b614133565b825f6141ae6141a66141b7946141a161419960206141926141bc9b8d90613d73565b5101613ead565b976009611d07565b611d1d565b928790613d73565b51015190611dae565b613018565b888789906141e660206141df5f6141d4878990613d73565b510151958790613d73565b5101613ead565b6142196142137f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd9361074c565b93611006565b9361422e6142256103a2565b92839283613f24565b0390a3888789614163565b9a90959291996142485f612cc2565b5b8061426461425e6142598a612e9f565b610554565b91610554565b10156143ef5761427c6142778d87613d9a565b613ea0565b6142a061429a6142956142908a8690613d9a565b613ea0565b610f01565b91610f01565b146142b3576142ae90612cde565b614249565b8a919b929c508961416b9495988a926001908a6142dd60206142d6898b90613d73565b5101613ead565b6143056142ff6142fa60016142f3868890612ea3565b500161093e565b610554565b91610554565b1091888884156143a5575b5050505061433a575b614324905b156104c2565b614333575b9394505050614155565b505f614329565b905082825f61434a878990613d73565b5101519161439661438461437e7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361074c565b93611006565b9361438d6103a2565b91829182613efb565b0390a36143245f919050614319565b6143e59394506143d36143df936143cd60206143c66143da96600296613d73565b5101613ead565b96612ea3565b500161093e565b610554565b91610554565b118a5f8888614310565b5099909a878961416b9495986143248d9461431e565b5097505092935093506144175f612cc2565b935b8461443461442e61442986612e9f565b610554565b91610554565b101561459b5761445a614454600361444d868990612ea3565b5001610965565b156104c2565b6145905761447c6144775f614470868990612ea3565b5001613dcd565b613e94565b61448e61448882613668565b91613662565b20905f9661449b5f612cc2565b5b806144b76144b16144ac86613d96565b610554565b91610554565b101561457e576144d06144cb848390613d9a565b613ea0565b6144e26144dc86610f01565b91610f01565b146144f5576144f090612cde565b61449c565b5095909650614516915061450b60015b156104c2565b61451d575b5b612cde565b9394614419565b82855f61452b878590612ea3565b50019161457661456461455e7fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361074c565b93611006565b9361456d6103a2565b91829182614017565b0390a3614510565b50959096614516925061450b90614505565b949361451690614511565b5050505050565b969390506145bc6145b7839794999693612e9f565b613d4c565b976145c65f612cc2565b5b806145e26145dc6145d78b612e9f565b610554565b91610554565b101561463c576146379061463261460d6146085f6146018d8690612ea3565b5001613dcd565b613e94565b61461f61461982613668565b91613662565b2061462d8d91849092613d9a565b613dba565b612cde565b6145c7565b509295919497909396614129565b614652616496565b61465a61465c565b565b61466d6146685f6125e9565b616bae565b565b61467761464a565b565b61468360a06116bc565b90565b5f90565b5f90565b5f90565b61469a614679565b90602080808080866146aa614686565b8152016146b5612750565b8152016146c0612754565b8152016146cb61468a565b8152016146d661468e565b81525050565b6146e4614692565b90565b906146f190610554565b9052565b906146ff906103b4565b9052565b9061470d906104af565b9052565b9061471b90611159565b9052565b9061479e6147956002614730614679565b9461474761473f5f830161093e565b5f88016146e7565b61475f61475660018301611049565b602088016146f5565b61477761476e60018301611076565b60408801614703565b61478f614786600183016110a3565b60608801614711565b016110c7565b60808401613dba565b565b6147a99061471f565b90565b6147d1916147c76147cc926147bf6146dc565b506003610fc8565b611012565b6147a0565b90565b5f90565b906147e29061074c565b5f5260205260405f2090565b906147f890611006565b5f5260205260405f2090565b6148299161481f614824926148176147d4565b50600c6147d8565b6147ee565b611049565b90565b614834616bc4565b61483c615e04565b61484e614848836103ef565b916103ef565b0361485e5761485c90616bae565b565b614879905f91829163118cdaa760e01b835260048301610cc9565b0390fd5b61489c6148976148a19261488f6127ae565b506004613334565b61334a565b616ac7565b90565b6148ae90516104af565b90565b6148c56148c06148ca926125ca565b610749565b6104af565b90565b6148d790516103b4565b90565b6148ee6148e96148f3926104af565b610749565b610554565b90565b61490561490b91939293610554565b92610554565b820180921161491657565b6128e4565b909291926149276139f3565b506149306127ae565b5061493a8261637e565b9361495761495261494d60058690613334565b61334a565b616ac7565b92614964602087016148a4565b6149766149705f6148b1565b916104af565b148015614a68575b8015614a4d575b614a33576149bf866149b96149b460206149ad6149a85f614a1c9b9c9d016148cd565b61357b565b93016148a4565b6148da565b906128f8565b91806149da6149d46149cf61132d565b610554565b91610554565b115f14614a2e57506149ea61132d565b5b6149f68482906148f6565b614a08614a0288610554565b91610554565b115f14614a1f5750845b9092909192616bfa565b91565b614a2990846148f6565b614a12565b6149eb565b5050509150614a49614a445f612cc2565b613a31565b9190565b5082614a61614a5b86610554565b91610554565b1015614985565b5083614a7c614a765f612cc2565b91610554565b1461497e565b614a9390614a8e616496565b614a95565b565b614aa090600a61269a565b565b614aab90614a82565b565b5f90565b614ab9614aad565b50614ac35f6125bd565b90565b5090565b9190811015614ada576020020190565b61077e565b35614ae9816103fb565b90565b5f80fd5b60e01b90565b5f910312614b0057565b6103ac565b916020614b26929493614b1f60408201965f830190610c21565b0190610cbc565b565b614b306103a2565b3d5f823e3d90fd5b90929192614b455f612cc2565b5b80614b63614b5d614b58858990614ac6565b610554565b91610554565b1015614c1257614b7230613c85565b9063ba1fb10384614b8d614b88868a8691614aca565b614adf565b93803b15614c0d57614bb25f8094614bbd614ba66103a2565b98899687958694614af0565b845260048401614b05565b03925af1918215614c0857614bd792614bdc575b50612cde565b614b46565b614bfb905f3d8111614c01575b614bf381836108d7565b810190614af6565b5f614bd1565b503d614be9565b614b28565b614aec565b5050509050565b5f7f4e6f7420736c617368696e67206f7261636c6500000000000000000000000000910152565b614c4d60136020926109d5565b614c5681614c19565b0190565b614c6f9060208101905f818303910152614c40565b90565b15614c7957565b614c816103a2565b62461bcd60e51b815280614c9760048201614c5a565b0390fd5b5f7f4f70657261746f7220756e6b6e6f776e00000000000000000000000000000000910152565b614ccf60106020926109d5565b614cd881614c9b565b0190565b614cf19060208101905f818303910152614cc2565b90565b15614cfb57565b614d036103a2565b62461bcd60e51b815280614d1960048201614cdc565b0390fd5b90565b90614d3367ffffffffffffffff91612677565b9181191691161790565b90565b90614d55614d50614d5c9261074c565b614d3d565b8254614d20565b9055565b9190614d7a81614d7381614d7f956109d5565b809561171d565b6108b9565b0190565b9091614d9a9260208301925f818503910152614d60565b90565b614dc233614dbc614db6614db1600a6125bd565b6103ef565b916103ef565b14614c72565b614de8614de3614ddc614dd760058590613334565b61334a565b84906164e4565b614cf4565b614e14614e09614e04614dfd60038590610fc8565b8590611012565b614d1d565b600160039101613381565b614e32614e2b614e2660048490613334565b61334a565b8390616d16565b50614e5a614e3f42613597565b614e55614e4e600c85906147d8565b85906147ee565b614d40565b909192614e90614e8a7f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361074c565b93611006565b93614ea5614e9c6103a2565b92839283614d83565b0390a3565b614eb460806116bc565b90565b614ec2913691611728565b90565b52565b90614ed2906104c2565b9052565b5190565b90614ee4816109d1565b9067ffffffffffffffff8211614fa457614f0882614f0285546107e4565b85612ecf565b602090601f8311600114614f3c57918091614f2b935f92614f30575b5050612a07565b90555b565b90915001515f80614f24565b601f19831691614f4b85610817565b925f5b818110614f8c57509160029391856001969410614f72575b50505002019055614f2e565b614f82910151601f8416906129f2565b90555f8080614f66565b91936020600181928787015181550195019201614f4e565b6108c3565b90614fb391614eda565b565b614fbf90516104c2565b90565b9061501f6060600361502594614fe55f8201614fdf5f8801614ed6565b90614fa9565b614ffe60018201614ff860208801613ead565b90613018565b6150176002820161501160408801613ead565b90613018565b019201614fb5565b9061306a565b565b91906150385761503691614fc2565b565b612ba3565b908154916801000000000000000083101561506d578261506591600161506b95018155612ea3565b90615027565b565b6108c3565b61519095615179849661517061516861515461514f615182976150f56150d56150cf61518b9d8d9f9d6150ca336150c46150be6150b96150b460078c906113c5565b6125bd565b6103ef565b916103ef565b14612835565b612d7b565b90612d7e565b6150ee6150e86150e3611921565b610554565b91610554565b1115612ddb565b6151128661510b6151058d610554565b91610554565b1015612e6a565b61514861512961512460088490610768565b610792565b61514261513c61513761156d565b610554565b91610554565b106128bb565b6008610768565b612e93565b989996929496615162614eaa565b9a614eb7565b5f8a01614ec5565b602088016146e7565b604086016146e7565b60608401614ec8565b61503d565b565b6151c0906151bb6151b66151af6151aa846006613334565b61334a565b33906164e4565b61351b565b6152a1565b565b5f7f43616e6e6f7420676f206f6e6c696e65207768696c6520736c61736865640000910152565b6151f6601e6020926109d5565b6151ff816151c2565b0190565b6152189060208101905f8183039101526151e9565b90565b60401b90565b9061523568ff00000000000000009161521b565b9181191691161790565b61525361524e615258926104af565b610749565b6104af565b90565b90565b9061527361526e61527a9261523f565b61525b565b8254615221565b9055565b91602061529f92949361529860408201965f830190611171565b0190611171565b565b6152bf6152ba6152b360038490610fc8565b3390611012565b614d1d565b906152cc600183016110a3565b91826152e16152db6003611159565b91611159565b1461540557826152f96152f35f611159565b91611159565b1480156153ea575b6153e557615328906153166001808301613381565b60016153215f6148b1565b910161525e565b61534661533f61533a60048490613334565b61334a565b339061645c565b50803361537c6153767fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361074c565b91611006565b916153856103a2565b8061538f8161044b565b0390a39033909160016153cb6153c57f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b936153e06153d76103a2565b9283928361527e565b0390a3565b505050565b50826153ff6153f96001611159565b91611159565b14615301565b61540d6103a2565b62461bcd60e51b81528061542360048201615203565b0390fd5b61543090615192565b565b5f7f4e6f7420617574686f72697a6564000000000000000000000000000000000000910152565b615466600e6020926109d5565b61546f81615432565b0190565b6154889060208101905f818303910152615459565b90565b1561549257565b61549a6103a2565b62461bcd60e51b8152806154b060048201615473565b0390fd5b90565b6154cb6154c66154d0926154b4565b610749565b6103b4565b90565b5f7f496e74657276616c20746f6f2073686f72740000000000000000000000000000910152565b61550760126020926109d5565b615510816154d3565b0190565b6155299060208101905f8183039101526154fa565b90565b1561553357565b61553b6103a2565b62461bcd60e51b81528061555160048201615514565b0390fd5b90565b61556c61556761557192615555565b610749565b6104af565b90565b5f7f4d6178206d6973736564206d757374206265203e3d2031000000000000000000910152565b6155a860176020926109d5565b6155b181615574565b0190565b6155ca9060208101905f81830391015261559b565b90565b156155d457565b6155dc6103a2565b62461bcd60e51b8152806155f2600482016155b5565b0390fd5b61560060606116bc565b90565b9061561861561361561f9261305b565b613067565b8254613353565b9055565b9061566560405f61566b9461564582820161563f8488016148cd565b90614d40565b61565d828201615657602088016148a4565b9061525e565b019201614fb5565b90615603565b565b9061567791615623565b565b91602061569a92949361569360408201965f830190610c21565b0190611129565b565b336156cf6156c97f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b1480156157bb575b6156e09061548b565b6156fe826156f76156f1603c6154b7565b916103b4565b101561552c565b61571c8361571561570f6001615558565b916104af565b10156155cd565b615775826157648561575b61573d5f61573760028990612287565b016122b1565b916157526157496155f6565b955f87016146f5565b60208501614703565b60408301614ec8565b61577060028490612287565b61566d565b90916157a17fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea5649261074c565b926157b66157ad6103a2565b92839283615679565b0390a2565b506156e0336157e56157df6157da6157d5600787906113c5565b6125bd565b6103ef565b916103ef565b1490506156d7565b634e487b7160e01b5f52601260045260245ffd5b61580d61581391610554565b91610554565b90811561581e570490565b6157ed565b61583761583261583c92610554565b610749565b6104af565b90565b61585361584e615858926125ca565b610749565b6103b4565b90565b61587961587461586d60038490610fc8565b8490611012565b614d1d565b906158838161637e565b61588f600184016110a3565b6158a261589c6003611159565b91611159565b14615ab6576158b25f840161093e565b6158c46158be5f612cc2565b91610554565b14615ab0576158fa6158e1426158db5f870161093e565b906135d6565b6158f46158ef5f85016148cd565b61357b565b90615801565b8061590e61590860ff6148da565b91610554565b115f14615aa2575060ff5b908161593861593261592d60018801611076565b6104af565b916104af565b11615945575b5050505050565b615952826001860161525e565b61596761595e5f61583f565b60018601614d40565b61598561597f61597a60208594016148a4565b6104af565b916104af565b101580615a7b575b615998575b8061593e565b6159b36159a7600185016110a3565b93600160029101613381565b6159d16159ca6159c560048590613334565b61334a565b8590616d16565b508190849091615a1f615a0d615a077f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d9361074c565b93611006565b93615a166103a2565b91829182611627565b0390a39190916002615a5a615a547f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93615a6f615a666103a2565b9283928361527e565b0390a35f808080615992565b50615a88600184016110a3565b615a9b615a956002611159565b91611159565b141561598d565b615aab90615823565b615919565b50505050565b50505050565b606090565b67ffffffffffffffff8111615ad95760208091020190565b6108c3565b90615af0615aeb83615ac1565b6116bc565b918252565b615aff60806116bc565b90565b90615b69615b606003615b13615af5565b94615b2a615b225f8301610900565b5f8801614ec5565b615b42615b396001830161093e565b602088016146e7565b615b5a615b516002830161093e565b604088016146e7565b01610965565b60608401614ec8565b565b615b7490615b02565b90565b90615b8182610792565b615b8a81615ade565b92615b986020850191610796565b5f915b838310615ba85750505050565b60046020600192615bb885615b6b565b815201920192019190615b9b565b615bcf90615b77565b90565b615be9615bee91615be1615abc565b506008610768565b615bc6565b90565b615c1f90615c1a615c15615c0e615c09846006613334565b61334a565b33906164e4565b61351b565b615c7a565b565b5f7f43616e6e6f7420676f206f66666c696e65207768696c6520736c617368656400910152565b615c55601f6020926109d5565b615c5e81615c21565b0190565b615c779060208101905f818303910152615c48565b90565b615c98615c93615c8c60038490610fc8565b3390611012565b614d1d565b90615ca5600183016110a3565b9182615cba615cb46003611159565b91611159565b14615d4057615cce90600160049101613381565b615cec615ce5615ce060048490613334565b61334a565b3390616d16565b50903390916004615d26615d207f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93615d3b615d326103a2565b9283928361527e565b0390a3565b615d486103a2565b62461bcd60e51b815280615d5e60048201615c62565b0390fd5b615d6b90615bf1565b565b909182615d7d81615d8493611d33565b809361171d565b0190565b615d999060209493615da093615d6d565b8092611d64565b0190565b9091615dbb90615db26103a2565b93849384615d88565b03902090565b9091615dcc92615da4565b90565b92615df4615dfc9392615def615e0196615de76127ae565b506009611d07565b611d1d565b919091615dc1565b61093e565b90565b615e0c614aad565b50615e1760016125bd565b90565b615e249051611159565b90565b90565b615e3e615e39615e4392615e27565b610749565b610554565b90565b60207f6c00000000000000000000000000000000000000000000000000000000000000917f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76615f8201520152565b615ea060216040926109d5565b615ea981615e46565b0190565b615ec29060208101905f818303910152615e93565b90565b15615ecc57565b615ed46103a2565b62461bcd60e51b815280615eea60048201615ead565b0390fd5b90615f9f615f9a615fa49333615f1f615f19615f14615f0f600786906113c5565b6125bd565b6103ef565b916103ef565b14801561605d575b615f309061548b565b615f4e615f49615f4260038490610fc8565b8690611012565b6147a0565b615f5a60608201615e1a565b615f6d615f676003611159565b91611159565b03615fa7575b50615f92615f8b615f8660058490613334565b61334a565b8590616d16565b506004613334565b61334a565b616d16565b50565b61602390615ff7615fe7615fba8561637e565b615fe1615fdc6020615fd5615fd05f86016148cd565b61357b565b93016148a4565b6148da565b906128f8565b615ff1600a615e2a565b906128f8565b6160025f8301613ead565b61601461600e5f612cc2565b91610554565b119182616029575b5050615ec5565b5f615f73565b61605491925061604861604e916160425f429201613ead565b906135d6565b92610554565b91610554565b10155f8061601c565b50615f303361607b616075616070614ab1565b6103ef565b916103ef565b149050615f27565b906160ad6160b291616093613b22565b506160a86160a08561637e565b946003610fc8565b611012565b6147a0565b6160bd5f8201613ead565b6160cf6160c95f612cc2565b91610554565b1461610a576161006160fb5f6160f4616106946160ee83429201613ead565b906135d6565b94016148cd565b61357b565b91610554565b1090565b50505f90565b6161219061611c616496565b616123565b565b61612e81600161269a565b616136614ab1565b9061616a6161647f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e2270093611006565b91611006565b916161736103a2565b8061617d8161044b565b0390a3565b61618b90616110565b565b5f6161cc6161d2936161c4336161be6161b86161b36161ae60078a906113c5565b6125bd565b6103ef565b916103ef565b14612835565b926002612287565b01615603565b565b5f7f4e6f742072656769737465726564000000000000000000000000000000000000910152565b616208600e6020926109d5565b616211816161d4565b0190565b61622a9060208101905f8183039101526161fb565b90565b1561623457565b61623c6103a2565b62461bcd60e51b81528061625260048201616215565b0390fd5b6162923361628c6162867f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b6162b86162b36162ac6162a760068590613334565b61334a565b8490616d16565b61622d565b6162d66162cf6162ca60048490613334565b61334a565b8390616d16565b509061630b6163057f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e9361074c565b91611006565b916163146103a2565b8061631e8161044b565b0390a3565b906163706163675f616333612743565b9461634a616342838301611049565b8388016146f5565b616361616358838301611076565b60208801614703565b016122b1565b60408401614ec8565b565b61637b90616323565b90565b61639561639a9161638d61278e565b506002612287565b616372565b6163a55f82016148cd565b6163b76163b15f61583f565b916103b4565b146163fd575b6163c9602082016148a4565b6163db6163d55f6148b1565b916104af565b146163e4575b90565b6163f86163ef61160f565b60208301614703565b6163e1565b616410616408610c08565b5f83016146f5565b6163bd565b61641e90610fde565b90565b61643561643061643a926103e4565b610749565b610554565b90565b61645161644c61645692610554565b612677565b610f01565b90565b90565b9061648e61648861648361647e5f61649396616476613b22565b500194616415565b616421565b61643d565b91616459565b616df9565b90565b61649e614ab1565b6164b76164b16164ac616bc4565b6103ef565b916103ef565b036164be57565b6164e06164c9616bc4565b5f91829163118cdaa760e01b835260048301610cc9565b0390fd5b9061651661651061650b6165065f61651b966164fe613b22565b500194616415565b616421565b61643d565b91616459565b616e5c565b90565b61653d916165349161652e614aad565b50616ebc565b90929192616f7c565b90565b5f7f4f70657261746f7220697320736c617368656400000000000000000000000000910152565b61657460136020926109d5565b61657d81616540565b0190565b6165969060208101905f818303910152616567565b90565b156165a057565b6165a86103a2565b62461bcd60e51b8152806165be60048201616581565b0390fd5b6165cb90610f01565b90565b6165d790610922565b90565b906165ef6165ea6165f6926165c2565b6165ce565b8254613002565b9055565b616603906103b4565b67ffffffffffffffff81146166185760010190565b6128e4565b90565b61663461662f6166399261661d565b610749565b6104af565b90565b91602061665d92949361665660408201965f830190611129565b0190610557565b565b61666890610fde565b90565b6166749061665f565b90565b61668090610ffa565b90565b6040906166ac6166b394969593966166a260608401985f850190610cbc565b6020830190610c21565b0190610c21565b565b94929391936166d86166d36166cc60038990610fc8565b8790611012565b614d1d565b936166e28761637e565b9361670c6166f2600188016110a3565b6167056166ff6003611159565b91611159565b1415616599565b61672a61672361671e60058b90613334565b61334a565b889061645c565b506167ff604061673c600189016110a3565b96616749425f8b01613018565b616773616757858790613654565b61676961676382613668565b91613662565b2060028b016165da565b61678861677f5f6148b1565b60018b0161525e565b6167a660018a016167a061679b82611049565b6165fa565b90614d40565b6167ae613c56565b50856167c26167bc5f6148b1565b916104af565b145f14616a83576167d95f995b60018b9101613381565b876167ed6167e76002611159565b91611159565b1480616a67575b6169f9575b01614fb5565b806169d5575b6169bf575b505085918591924261684e6168486168427f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b99461074c565b9461074c565b94611006565b9461686361685a6103a2565b9283928361663c565b0390a48061687961687384611159565b91611159565b03616969575b505061688b600b6125bd565b6168a561689f61689a5f6125e9565b6103ef565b916103ef565b036168af575b5050565b6168c96168c46168bf600b6125bd565b61666b565b616677565b9163d47853b69190926168db42613597565b92813b15616964575f6169019161690c82966168f56103a2565b98899788968795614af0565b855260048501616683565b03925af19081616938575b50155f1461693357600161692e575b5b5f806168ab565b616926565b616927565b616957905f3d811161695d575b61694f81836108d7565b810190614af6565b5f616917565b503d616945565b614aec565b838391926169a061699a7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b936169b56169ac6103a2565b9283928361527e565b0390a35f8061687f565b6169ce91889188909192617439565b5f8061680a565b506169e1818390612d7e565b6169f36169ed5f612cc2565b91610554565b11616805565b616a16616a0f616a0a8d6004613334565b61334a565b8b9061645c565b508a8a616a4c616a467fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361074c565b91611006565b91616a556103a2565b80616a5f8161044b565b0390a36167f9565b5088616a7c616a766002611159565b91611159565b14156167f4565b85616a97616a916064616620565b916104af565b105f14616aaa576167d96001995b6167cf565b6167d9600199616ac28d8d8b908b908a928c946170ed565b616aa5565b616ade5f616ae392616ad76127ae565b5001616459565b6175f7565b90565b616af2616af791610922565b61297e565b90565b616b0e616b09616b1392610554565b610749565b6103e4565b90565b616b41616b3c616b4b93616b375f616b4695616b30614aad565b5001616459565b617665565b616ae6565b616afa565b610ffa565b90565b91906008616b6e910291616b6860018060a01b0384612955565b92612955565b9181191691161790565b9190616b8e616b89616b9693611006565b612697565b908354616b4e565b9055565b616bac91616ba6614aad565b91616b78565b565b616bc290616bbd5f6001616b9a565b617686565b565b616bcc614aad565b503390565b616bda90610554565b5f198114616be85760010190565b6128e4565b616bf790516103ef565b90565b93919293616c066139f3565b50616c1a616c158584906135d6565b613a31565b92616c245f612cc2565b925b80616c39616c3388610554565b91610554565b1015616ca757616c5d616c56616c5160058690613334565b61334a565b8290616b16565b616c6984828a916176e5565b616c7d575b50616c7890612cde565b616c26565b616c789194616c9b616ca092616c968991849092613a58565b613a78565b616bd1565b9390616c6e565b509450509150616cb682613a31565b92616cc05f612cc2565b5b80616cd4616cce86610554565b91610554565b1015616d1057616d0b90616d06616cf4616cef868490613a58565b616bed565b616d018891849092613a58565b613a78565b612cde565b616cc1565b50915050565b90616d48616d42616d3d616d385f616d4d96616d30613b22565b500194616415565b616421565b61643d565b91616459565b617831565b90565b90565b5f5260205f2090565b5490565b616d6981616d5c565b821015616d8357616d7b600191616d53565b910201905f90565b61077e565b9190616d9e616d99616da6936165c2565b6165ce565b908354612959565b9055565b9081549168010000000000000000831015616dda5782616dd2916001616dd895018155616d60565b90616d88565b565b6108c3565b5490565b90616ded906165c2565b5f5260205260405f2090565b616e01613b22565b50616e16616e10828490616e5c565b156104c2565b5f14616e5657616e4c616e5192616e38616e315f8501616d50565b8290616daa565b6001616e455f8501616ddf565b9301616de3565b613018565b600190565b50505f90565b616e7a916001616e7592616e6e613b22565b5001616de3565b61093e565b616e8c616e865f612cc2565b91610554565b141590565b5f90565b5f90565b90565b616eb0616eab616eb592616e99565b610749565b610554565b90565b5f90565b919091616ec7614aad565b50616ed0616e91565b50616ed9616e95565b50616ee383613668565b616ef6616ef06041616e9c565b91610554565b145f14616f3d57616f369192616f0a616e95565b50616f13616e95565b50616f1c616eb8565b506020810151606060408301519201515f1a9091926179b0565b9192909190565b50616f475f6125e9565b90616f5b616f56600294613668565b61643d565b91929190565b60041115616f6b57565b611136565b90616f7a82616f61565b565b80616f8f616f895f616f70565b91616f70565b145f14616f9a575050565b80616fae616fa86001616f70565b91616f70565b145f14616fd1575f63f645eedf60e01b815280616fcd6004820161044b565b0390fd5b80616fe5616fdf6002616f70565b91616f70565b145f146170135761700f616ff883616ae6565b5f91829163fce698f760e01b835260048301610564565b0390fd5b6170266170206003616f70565b91616f70565b1461702e5750565b617049905f9182916335e2f38360e21b835260048301610f11565b0390fd5b61706161705c6170669261130e565b610749565b6104af565b90565b61707561707b916103b4565b916103b4565b90039067ffffffffffffffff821161708f57565b6128e4565b5f7f50726f746f636f6c2076696f6c6174696f6e207265706f727465640000000000910152565b6170c8601b6020926109d5565b6170d181617094565b0190565b6170ea9060208101905f8183039101526170bb565b90565b93505092506171056170ff60c861704d565b916104af565b1015617110575b5050565b61711942613597565b61713761713261712b600c85906147d8565b85906147ee565b611049565b8061714a6171445f61583f565b916103b4565b149081156171d0575b5061715f575b5061710c565b61717e90617179617172600c85906147d8565b85906147ee565b614d40565b906171b26171ac7f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361074c565b91611006565b916171bb6103a2565b806171c5816170d5565b0390a35f8080617159565b6171db915082617069565b6171f46171ee6171e9610f7a565b6103b4565b916103b4565b10155f617153565b90565b61721361720e617218926171fc565b610749565b610554565b90565b9092919261723061722b826116fa565b6116bc565b9381855260208501908284011161724c5761724a926109de565b565b6116f6565b9080601f8301121561726f5781602061726c9351910161721b565b90565b6105af565b90505190617281826106f9565b565b9190916040818403126172d65761729a60406116bc565b925f8201519167ffffffffffffffff83116172d1576172be826172ca948301617251565b5f860152602001617274565b6020830152565b6116f2565b6116ee565b9291906172ef6172ea826116d1565b6116bc565b93818552602080860192028101918383116173465781905b838210617315575050505050565b815167ffffffffffffffff8111617341576020916173368784938701617283565b815201910190617307565b6105af565b6105b7565b9080601f8301121561736957816020617366935191016172db565b90565b6105af565b9060208282031261739e575f82015167ffffffffffffffff811161739957617396920161734b565b90565b6103b0565b6103ac565b60209181520190565b91906173c6816173bf816173cb956173a3565b809561171d565b6108b9565b0190565b90916173e69260208301925f8185039101526173ac565b90565b6173f36032611551565b90565b9493916060916174379461742261742f9361741860808b01945f8c0190610c21565b60208a0190610cbc565b8782036040890152610e28565b940190610557565b565b91617445818590612d7e565b6174576174515f612cc2565b91610554565b146175f157617467818590612d7e565b61747b61747561c3506171ff565b91610554565b116175eb575f617489613978565b9461749330613c85565b6174b56331e3bd1b9492946174c06174a96103a2565b96879586948594614af0565b8452600484016173cf565b03915afa80915f926175c7575b50155f146175be575060016175b9575b6174e683610d97565b6174ff6174f96174f46173e9565b610554565b91610554565b115f146175ab5761750e6173e9565b5b61751830613c85565b906365a6936e93929490823b156175a6575f9461755386926175489461753c6103a2565b998a9889978896614af0565b8652600486016173f6565b03925af1908161757a575b50155f14617575576001617570575b5b565b61756d565b61756e565b617599905f3d811161759f575b61759181836108d7565b810190614af6565b5f61755e565b503d617587565b614aec565b6175b483610d97565b61750f565b505050565b909250916174dd565b6175e49192503d805f833e6175dc81836108d7565b81019061736e565b905f6174cd565b50505050565b50505050565b5f61760b916176046127ae565b5001616ddf565b90565b5f5260205f2090565b61762081616ddf565b82101561763a5761763260019161760e565b910201905f90565b61077e565b61764f9060086176549302610c78565b6110b0565b90565b90617662915461763f565b90565b617683915f61767d92617676616e95565b5001617617565b90617657565b90565b61768f5f6125bd565b617699825f61269a565b906176cd6176c77f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e093611006565b91611006565b916176d66103a2565b806176e08161044b565b0390a3565b6176ed613b22565b5061771561770f61770861770360068590613334565b61334a565b84906164e4565b156104c2565b6177b7576177359161772b617730926003610fc8565b611012565b6147a0565b6177405f8201613ead565b61775261774c5f612cc2565b91610554565b148015617791575b61778b5761778061777a617786926177745f429201613ead565b906135d6565b92610554565b91610554565b101590565b50505f90565b5061779e60608201615e1a565b6177b16177ab6003611159565b91611159565b1461775a565b5050505f90565b6177d26177cd6177d792615555565b610749565b610554565b90565b634e487b7160e01b5f52603160045260245ffd5b617800916177fa616e95565b91616d88565b565b61780b81616d5c565b801561782c5760019003906178296178238383616d60565b906177ee565b55565b6177da565b617839613b22565b5061785061784b600183018490616de3565b61093e565b908161786461785e5f612cc2565b91610554565b14155f14617930576178e29260016178dd928461788b5f96617885856177be565b906135d6565b6178a8617899888501616ddf565b6178a2866177be565b906135d6565b816178bb6178b583610554565b91610554565b036178e7575b5050506178d76178d2868301616d50565b617802565b01616de3565b6129bf565b600190565b6179289261791a617906617900617923948c8901617617565b90617657565b9361791485918c8901617617565b90616d88565b91858501616de3565b613018565b5f80806178c1565b5050505f90565b90565b61794e61794961795392617937565b610749565b610554565b90565b61798b61799294617981606094989795617977608086019a5f870190610f04565b6020850190611129565b6040830190610f04565b0190610f04565b565b6179a86179a36179ad926125ca565b612677565b610f01565b90565b9392936179bb614aad565b506179c4616e91565b506179cd616e95565b506179d785616ae6565b617a09617a037f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a061793a565b91610554565b11617a965790617a2c602094955f94939293617a236103a2565b94859485617956565b838052039060015afa15617a9157617a445f51612677565b80617a5f617a59617a545f6125e9565b6103ef565b916103ef565b14617a75575f91617a6f5f617994565b91929190565b50617a7f5f6125e9565b600191617a8b5f617994565b91929190565b614b28565b505050617aa25f6125e9565b906003929192919056fea164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static DEPLOYED_BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\x80`@R`\x046\x10\x15a\0\x13W[a%#V[a\0\x1D_5a\x03\x9CV[\x80c\x05w\x85P\x14a\x03\x97W\x80c\x07X#o\x14a\x03\x92W\x80c\x0Cviz\x14a\x03\x8DW\x80c\x19\x1C\xBD\x1A\x14a\x03\x88W\x80c\x1E\x8F^\xE5\x14a\x03\x83W\x80c \x81)V\x14a\x03~W\x80c\"\xF1\xEC\x93\x14a\x03yW\x80c+\xF4\xD6\xA7\x14a\x03tW\x80c,\x95v\x88\x14a\x03oW\x80c-\xAE\x18\x85\x14a\x03jW\x80c/K\xD7\xB8\x14a\x03eW\x80c1\xE3\xBD\x1B\x14a\x03`W\x80c6D\xE5\x15\x14a\x03[W\x80c:\xC3\xCB\xE6\x14a\x03VW\x80c>n4\xA7\x14a\x03QW\x80c?\xD6,m\x14a\x03LW\x80c@#Z\x9C\x14a\x03GW\x80cH\xF4\xDA \x14a\x03BW\x80cV\x85\xCFh\x14a\x03=W\x80cV\xC4\xE1}\x14a\x038W\x80cY\xDC\xEA\x12\x14a\x033W\x80cZ\x93m\xC6\x14a\x03.W\x80c\\\xCE\x98\xA6\x14a\x03)W\x80c`vC\x9C\x14a\x03$W\x80c`\xCF\t\x91\x14a\x03\x1FW\x80ca\xD6\xB8l\x14a\x03\x1AW\x80cb\xC7\xE8\xFC\x14a\x03\x15W\x80ce\xA6\x93n\x14a\x03\x10W\x80ck\xFE\x06\xA6\x14a\x03\x0BW\x80cqP\x18\xA6\x14a\x03\x06W\x80cq\xE78\x8C\x14a\x03\x01W\x80cv9\xD2'\x14a\x02\xFCW\x80cy\xBAP\x97\x14a\x02\xF7W\x80c{\x9Fd\xB2\x14a\x02\xF2W\x80c\x81\xBE\xAC.\x14a\x02\xEDW\x80c\x84\xEFs\"\x14a\x02\xE8W\x80c\x8D\xA5\xCB[\x14a\x02\xE3W\x80c\x96hl\x1E\x14a\x02\xDEW\x80c\x9C\xBD\xAE\"\x14a\x02\xD9W\x80c\xAD\xFF\x83\x0C\x14a\x02\xD4W\x80c\xAEG\n\x85\x14a\x02\xCFW\x80c\xB0t\xE9\xDD\x14a\x02\xCAW\x80c\xB9\x9FgY\x14a\x02\xC5W\x80c\xBA\x1F\xB1\x03\x14a\x02\xC0W\x80c\xC1\xEF\x9D\xDF\x14a\x02\xBBW\x80c\xC5\xD9`\xBB\x14a\x02\xB6W\x80c\xCF\xE3GI\x14a\x02\xB1W\x80c\xD5Q\x16,\x14a\x02\xACW\x80c\xDACZ|\x14a\x02\xA7W\x80c\xE3\x0C9x\x14a\x02\xA2W\x80c\xE6\\\xAF\xCB\x14a\x02\x9DW\x80c\xEE\x1C\x03\x90\x14a\x02\x98W\x80c\xF2\xFD\xE3\x8B\x14a\x02\x93W\x80c\xF9\x10\x7F;\x14a\x02\x8EW\x80c\xF9\xF1gb\x14a\x02\x89Wc\xFF\xCF\x08\xF0\x03a\0\x0EWa$\xEFV[a$\xBAV[a$WV[a#\xF7V[a#\xC1V[a#\x8DV[a#XV[a# V[a\"NV[a\"\x19V[a!\xD7V[a!\xA2V[a xV[a DV[a\x1F\xD7V[a\x1F\x9DV[a\x1E\xD2V[a\x1E\x0BV[a\x1C\x82V[a\x1B\xC8V[a\x1B\x95V[a\x1B^V[a\x1A\xC9V[a\x1A\x96V[a\x1A`V[a\x1A*V[a\x19nV[a\x199V[a\x18\xCBV[a\x16\x86V[a\x16<V[a\x15\xBAV[a\x15\x85V[a\x15\x17V[a\x14\x82V[a\x14)V[a\x13\xF4V[a\x13\x8FV[a\x13EV[a\x12\xD9V[a\x12\x05V[a\x11\xCBV[a\x0F\x93V[a\x0F&V[a\x0E\xA7V[a\r,V[a\x0C\xDEV[a\x0CCV[a\x0B\x9DV[a\njV[a\x06\xC6V[a\x06tV[a\x06@V[a\x05yV[a\x05\x1FV[a\x04PV[`\xE0\x1C\x90V[`@Q\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x03\xCA\x81a\x03\xB4V[\x03a\x03\xD1WV[_\x80\xFD[\x90P5\x90a\x03\xE2\x82a\x03\xC1V[V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x03\xF8\x90a\x03\xE4V[\x90V[a\x04\x04\x81a\x03\xEFV[\x03a\x04\x0BWV[_\x80\xFD[\x90P5\x90a\x04\x1C\x82a\x03\xFBV[V[\x91\x90`@\x83\x82\x03\x12a\x04FW\x80a\x04:a\x04C\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x04\x0FV[\x90V[a\x03\xACV[_\x01\x90V[4a\x04\x7FWa\x04ia\x04c6`\x04a\x04\x1EV[\x90a&\xBAV[a\x04qa\x03\xA2V[\x80a\x04{\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x04\x9DWa\x04\x9A\x91_\x01a\x03\xD5V[\x90V[a\x03\xACV[a\x04\xAB\x90a\x03\xB4V[\x90RV[`\xFF\x16\x90V[a\x04\xBE\x90a\x04\xAFV[\x90RV[\x15\x15\x90V[a\x04\xD0\x90a\x04\xC2V[\x90RV[\x90`@\x80a\x05\x08\x93a\x04\xEC_\x82\x01Q_\x86\x01\x90a\x04\xA2V[a\x04\xFE` \x82\x01Q` \x86\x01\x90a\x04\xB5V[\x01Q\x91\x01\x90a\x04\xC7V[V[\x91\x90a\x05\x1D\x90_``\x85\x01\x94\x01\x90a\x04\xD4V[V[4a\x05OWa\x05Ka\x05:a\x0556`\x04a\x04\x84V[a'\x99V[a\x05Ba\x03\xA2V[\x91\x82\x91\x82a\x05\nV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x05`\x90a\x05TV[\x90RV[\x91\x90a\x05w\x90_` \x85\x01\x94\x01\x90a\x05WV[V[4a\x05\xAAWa\x05\xA6a\x05\x95a\x05\x8F6`\x04a\x04\x1EV[\x90a'\xB2V[a\x05\x9Da\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x05\xF5W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x05\xF0W` \x01\x92` \x83\x02\x84\x01\x11a\x05\xEBWV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x06;Wa\x06\x13\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x066Wa\x062\x92\x01a\x05\xBBV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x06oWa\x06Ya\x06S6`\x04a\x05\xFAV[\x91a1;V[a\x06aa\x03\xA2V[\x80a\x06k\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x06\xA3Wa\x06\x8Da\x06\x876`\x04a\x04\x1EV[\x90a3\xA1V[a\x06\x95a\x03\xA2V[\x80a\x06\x9F\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x06\xC1Wa\x06\xBE\x91_\x01a\x04\x0FV[\x90V[a\x03\xACV[4a\x06\xF4Wa\x06\xDEa\x06\xD96`\x04a\x06\xA8V[a4\xB7V[a\x06\xE6a\x03\xA2V[\x80a\x06\xF0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x07\x02\x81a\x05TV[\x03a\x07\tWV[_\x80\xFD[\x90P5\x90a\x07\x1A\x82a\x06\xF9V[V[\x91\x90`@\x83\x82\x03\x12a\x07DW\x80a\x078a\x07A\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x07\rV[\x90V[a\x03\xACV[\x90V[a\x07`a\x07[a\x07e\x92a\x03\xB4V[a\x07IV[a\x03\xB4V[\x90V[\x90a\x07r\x90a\x07LV[_R` R`@_ \x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[T\x90V[_R` _ \x90V[_R` _ \x90V[a\x07\xB1\x81a\x07\x92V[\x82\x10\x15a\x07\xCBWa\x07\xC3`\x04\x91a\x07\x96V[\x91\x02\x01\x90_\x90V[a\x07~V[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x90`\x01`\x02\x83\x04\x92\x16\x80\x15a\x08\x04W[` \x83\x10\x14a\x07\xFFWV[a\x07\xD0V[\x91`\x7F\x16\x91a\x07\xF4V[` \x91\x81R\x01\x90V[_R` _ \x90V[\x90_\x92\x91\x80T\x90a\x08:a\x083\x83a\x07\xE4V[\x80\x94a\x08\x0EV[\x91`\x01\x81\x16\x90\x81_\x14a\x08\x91WP`\x01\x14a\x08UW[PPPV[a\x08b\x91\x92\x93\x94Pa\x08\x17V[\x91_\x92[\x81\x84\x10a\x08yWPP\x01\x90_\x80\x80a\x08PV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a\x08fV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a\x08PV[\x90a\x08\xB6\x91a\x08 V[\x90V[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\x08\xE1\x90a\x08\xB9V[\x81\x01\x90\x81\x10g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x17a\x08\xFBW`@RV[a\x08\xC3V[\x90a\t a\t\x19\x92a\t\x10a\x03\xA2V[\x93\x84\x80\x92a\x08\xACV[\x03\x83a\x08\xD7V[V[_\x1C\x90V[\x90V[a\t6a\t;\x91a\t\"V[a\t'V[\x90V[a\tH\x90Ta\t*V[\x90V[`\xFF\x16\x90V[a\t]a\tb\x91a\t\"V[a\tKV[\x90V[a\to\x90Ta\tQV[\x90V[a\t}\x90`\x08a\x07hV[\x90a\t\x87\x82a\x07\x92V[\x81\x10\x15a\t\xCDWa\t\x97\x91a\x07\xA8V[P\x90a\t\xA4_\x83\x01a\t\0V[\x91a\t\xB1`\x01\x82\x01a\t>V[\x91a\t\xCA`\x03a\t\xC3`\x02\x85\x01a\t>V[\x93\x01a\teV[\x90V[_\x80\xFD[Q\x90V[` \x91\x81R\x01\x90V[\x90\x82_\x93\x92\x82^\x01RV[a\n\x08a\n\x11` \x93a\n\x16\x93a\t\xFF\x81a\t\xD1V[\x93\x84\x80\x93a\t\xD5V[\x95\x86\x91\x01a\t\xDEV[a\x08\xB9V[\x01\x90V[a\n#\x90a\x04\xC2V[\x90RV[a\naa\nh\x94a\nWa\nL``\x95\x99\x98\x96\x99`\x80\x86\x01\x90\x86\x82\x03_\x88\x01Ra\t\xE9V[\x98` \x85\x01\x90a\x05WV[`@\x83\x01\x90a\x05WV[\x01\x90a\n\x1AV[V[4a\n\x9FWa\n\x9Ba\n\x86a\n\x806`\x04a\x07\x1CV[\x90a\trV[\x90a\n\x92\x94\x92\x94a\x03\xA2V[\x94\x85\x94\x85a\n'V[\x03\x90\xF3[a\x03\xA8V[a\n\xAD\x81a\x04\xAFV[\x03a\n\xB4WV[_\x80\xFD[\x90P5\x90a\n\xC5\x82a\n\xA4V[V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x0B\x01W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\n\xFCW` \x01\x92`\x01\x83\x02\x84\x01\x11a\n\xF7WV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90`\xC0\x83\x82\x03\x12a\x0B\x98Wa\x0B\x1E\x81_\x85\x01a\x03\xD5V[\x92a\x0B,\x82` \x83\x01a\x03\xD5V[\x92a\x0B:\x83`@\x84\x01a\n\xB8V[\x92``\x83\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0B\x93W\x81a\x0B[\x91\x85\x01a\n\xC7V[\x92\x90\x93a\x0Bk\x83`\x80\x83\x01a\x03\xD5V[\x92`\xA0\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0B\x8EWa\x0B\x8A\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xB0V[a\x03\xACV[4a\x0B\xD5Wa\x0B\xBFa\x0B\xB06`\x04a\x0B\x06V[\x96\x95\x90\x95\x94\x91\x94\x93\x92\x93a9fV[a\x0B\xC7a\x03\xA2V[\x80a\x0B\xD1\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[_\x91\x03\x12a\x0B\xE4WV[a\x03\xACV[\x90V[a\x0C\0a\x0B\xFBa\x0C\x05\x92a\x0B\xE9V[a\x07IV[a\x03\xB4V[\x90V[a\x0C\x13a\x01,a\x0B\xECV[\x90V[a\x0C\x1Ea\x0C\x08V[\x90V[a\x0C*\x90a\x03\xB4V[\x90RV[\x91\x90a\x0CA\x90_` \x85\x01\x94\x01\x90a\x0C!V[V[4a\x0CsWa\x0CS6`\x04a\x0B\xDAV[a\x0Coa\x0C^a\x0C\x16V[a\x0Cfa\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x0C\x97\x90`\x08a\x0C\x9C\x93\x02a\x0CxV[a\x0C|V[\x90V[\x90a\x0C\xAA\x91Ta\x0C\x87V[\x90V[a\x0C\xB9`\x0B_\x90a\x0C\x9FV[\x90V[a\x0C\xC5\x90a\x03\xEFV[\x90RV[\x91\x90a\x0C\xDC\x90_` \x85\x01\x94\x01\x90a\x0C\xBCV[V[4a\r\x0EWa\x0C\xEE6`\x04a\x0B\xDAV[a\r\na\x0C\xF9a\x0C\xADV[a\r\x01a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[a\r\x1Ea\x01,a\x0B\xECV[\x90V[a\r)a\r\x13V[\x90V[4a\r\\Wa\r<6`\x04a\x0B\xDAV[a\rXa\rGa\r!V[a\rOa\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\r\x92W_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\r\x8DWa\r\x89\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xACV[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\r\xC9a\r\xD2` \x93a\r\xD7\x93a\r\xC0\x81a\t\xD1V[\x93\x84\x80\x93a\x08\x0EV[\x95\x86\x91\x01a\t\xDEV[a\x08\xB9V[\x01\x90V[a\r\xE4\x90a\x05TV[\x90RV[\x90a\x0E\x12\x90` \x80a\x0E\x07`@\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\xAAV[\x94\x01Q\x91\x01\x90a\r\xDBV[\x90V[\x90a\x0E\x1F\x91a\r\xE8V[\x90V[` \x01\x90V[\x90a\x0E<a\x0E5\x83a\r\x97V[\x80\x92a\r\x9BV[\x90\x81a\x0EM` \x83\x02\x84\x01\x94a\r\xA4V[\x92_\x91[\x83\x83\x10a\x0E`WPPPPP\x90V[\x90\x91\x92\x93\x94` a\x0E\x82a\x0E|\x83\x85`\x01\x95\x03\x87R\x89Qa\x0E\x15V[\x97a\x0E\"V[\x93\x01\x93\x01\x91\x93\x92\x90a\x0EQV[a\x0E\xA4\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x0E(V[\x90V[4a\x0E\xD8Wa\x0E\xD4a\x0E\xC3a\x0E\xBD6`\x04a\raV[\x90a9\xB2V[a\x0E\xCBa\x03\xA2V[\x91\x82\x91\x82a\x0E\x8FV[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[\x90V[a\x0F\r\x90a\x0F\x01V[\x90RV[\x91\x90a\x0F$\x90_` \x85\x01\x94\x01\x90a\x0F\x04V[V[4a\x0FVWa\x0F66`\x04a\x0B\xDAV[a\x0FRa\x0FAa\x0E\xDDV[a\x0FIa\x03\xA2V[\x91\x82\x91\x82a\x0F\x11V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x0Fra\x0Fma\x0Fw\x92a\x0F[V[a\x07IV[a\x03\xB4V[\x90V[a\x0F\x85a\x0E\x10a\x0F^V[\x90V[a\x0F\x90a\x0FzV[\x90V[4a\x0F\xC3Wa\x0F\xA36`\x04a\x0B\xDAV[a\x0F\xBFa\x0F\xAEa\x0F\x88V[a\x0F\xB6a\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x90a\x0F\xD2\x90a\x07LV[_R` R`@_ \x90V[a\x0F\xF2a\x0F\xEDa\x0F\xF7\x92a\x03\xE4V[a\x07IV[a\x03\xE4V[\x90V[a\x10\x03\x90a\x0F\xDEV[\x90V[a\x10\x0F\x90a\x0F\xFAV[\x90V[\x90a\x10\x1C\x90a\x10\x06V[_R` R`@_ \x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x10Aa\x10F\x91a\t\"V[a\x10(V[\x90V[a\x10S\x90Ta\x105V[\x90V[`@\x1C\x90V[`\xFF\x16\x90V[a\x10na\x10s\x91a\x10VV[a\x10\\V[\x90V[a\x10\x80\x90Ta\x10bV[\x90V[`H\x1C\x90V[`\xFF\x16\x90V[a\x10\x9Ba\x10\xA0\x91a\x10\x83V[a\x10\x89V[\x90V[a\x10\xAD\x90Ta\x10\x8FV[\x90V[\x90V[a\x10\xBFa\x10\xC4\x91a\t\"V[a\x10\xB0V[\x90V[a\x10\xD1\x90Ta\x10\xB3V[\x90V[\x90a\x10\xE3a\x10\xE8\x92`\x03a\x0F\xC8V[a\x10\x12V[a\x10\xF3_\x82\x01a\t>V[\x91a\x11\0`\x01\x83\x01a\x10IV[\x91a\x11\r`\x01\x82\x01a\x10vV[\x91a\x11&`\x02a\x11\x1F`\x01\x85\x01a\x10\xA3V[\x93\x01a\x10\xC7V[\x90V[a\x112\x90a\x04\xAFV[\x90RV[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[`\x05\x11\x15a\x11TWV[a\x116V[\x90a\x11c\x82a\x11JV[V[a\x11n\x90a\x11YV[\x90V[a\x11z\x90a\x11eV[\x90RV[\x90\x95\x94\x92a\x11\xC9\x94a\x11\xB8a\x11\xC2\x92a\x11\xAE`\x80\x96a\x11\xA4`\xA0\x88\x01\x9C_\x89\x01\x90a\x05WV[` \x87\x01\x90a\x0C!V[`@\x85\x01\x90a\x11)V[``\x83\x01\x90a\x11qV[\x01\x90a\x0F\x04V[V[4a\x12\0Wa\x11\xFCa\x11\xE7a\x11\xE16`\x04a\x04\x1EV[\x90a\x10\xD4V[\x91a\x11\xF3\x95\x93\x95a\x03\xA2V[\x95\x86\x95\x86a\x11~V[\x03\x90\xF3[a\x03\xA8V[4a\x125Wa\x121a\x12 a\x12\x1B6`\x04a\x04\x84V[a9\xCCV[a\x12(a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x12V\x90a\x03\xEFV[\x90RV[\x90a\x12g\x81` \x93a\x12MV[\x01\x90V[` \x01\x90V[\x90a\x12\x8Ea\x12\x88a\x12\x81\x84a\x12:V[\x80\x93a\x12>V[\x92a\x12GV[\x90_[\x81\x81\x10a\x12\x9EWPPP\x90V[\x90\x91\x92a\x12\xB7a\x12\xB1`\x01\x92\x86Qa\x12ZV[\x94a\x12kV[\x91\x01\x91\x90\x91a\x12\x91V[a\x12\xD6\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x12qV[\x90V[4a\x13\tWa\x13\x05a\x12\xF4a\x12\xEF6`\x04a\x04\x84V[a:\x86V[a\x12\xFCa\x03\xA2V[\x91\x82\x91\x82a\x12\xC1V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x13%a\x13 a\x13*\x92a\x13\x0EV[a\x07IV[a\x05TV[\x90V[a\x137`\xC8a\x13\x11V[\x90V[a\x13Ba\x13-V[\x90V[4a\x13uWa\x13U6`\x04a\x0B\xDAV[a\x13qa\x13`a\x13:V[a\x13ha\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x13\x8D\x90_` \x85\x01\x94\x01\x90a\n\x1AV[V[4a\x13\xC0Wa\x13\xBCa\x13\xABa\x13\xA56`\x04a\x04\x1EV[\x90a;&V[a\x13\xB3a\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[\x90a\x13\xCF\x90a\x07LV[_R` R`@_ \x90V[a\x13\xF1\x90a\x13\xEC`\x07\x91_\x92a\x13\xC5V[a\x0C\x9FV[\x90V[4a\x14$Wa\x14 a\x14\x0Fa\x14\n6`\x04a\x04\x84V[a\x13\xDBV[a\x14\x17a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a\x14YWa\x14Ua\x14Da\x14?6`\x04a\x04\x84V[a;\xADV[a\x14La\x03\xA2V[\x91\x82\x91\x82a\x12\xC1V[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[4a\x14\xB2Wa\x14\x926`\x04a\x0B\xDAV[a\x14\xAEa\x14\x9Da\x14^V[a\x14\xA5a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[\x90`\x80\x82\x82\x03\x12a\x15\x12Wa\x14\xCE\x81_\x84\x01a\x03\xD5V[\x92a\x14\xDC\x82` \x85\x01a\x03\xD5V[\x92a\x14\xEA\x83`@\x83\x01a\n\xB8V[\x92``\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x15\rWa\x15\t\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x15IWa\x153a\x15*6`\x04a\x14\xB7V[\x93\x92\x90\x92a<\x1FV[a\x15;a\x03\xA2V[\x80a\x15E\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x15ea\x15`a\x15j\x92a\x15NV[a\x07IV[a\x05TV[\x90V[a\x15w`2a\x15QV[\x90V[a\x15\x82a\x15mV[\x90V[4a\x15\xB5Wa\x15\x956`\x04a\x0B\xDAV[a\x15\xB1a\x15\xA0a\x15zV[a\x15\xA8a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[4a\x15\xEBWa\x15\xE7a\x15\xD6a\x15\xD06`\x04a\x04\x1EV[\x90a<.V[a\x15\xDEa\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x16\x07a\x16\x02a\x16\x0C\x92a\x15\xF0V[a\x07IV[a\x04\xAFV[\x90V[a\x16\x19`\x03a\x15\xF3V[\x90V[a\x16$a\x16\x0FV[\x90V[\x91\x90a\x16:\x90_` \x85\x01\x94\x01\x90a\x11)V[V[4a\x16lWa\x16L6`\x04a\x0B\xDAV[a\x16ha\x16Wa\x16\x1CV[a\x16_a\x03\xA2V[\x91\x82\x91\x82a\x16'V[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x16\x84\x90_` \x85\x01\x94\x01\x90a\x11qV[V[4a\x16\xB7Wa\x16\xB3a\x16\xA2a\x16\x9C6`\x04a\x04\x1EV[\x90a<ZV[a\x16\xAAa\x03\xA2V[\x91\x82\x91\x82a\x16qV[\x03\x90\xF3[a\x03\xA8V[\x90a\x16\xCFa\x16\xC8a\x03\xA2V[\x92\x83a\x08\xD7V[V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x16\xE9W` \x80\x91\x02\x01\x90V[a\x08\xC3V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x17\x18Wa\x17\x14` \x91a\x08\xB9V[\x01\x90V[a\x08\xC3V[\x90\x82_\x93\x92\x827\x01RV[\x90\x92\x91\x92a\x17=a\x178\x82a\x16\xFAV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a\x17YWa\x17W\x92a\x17\x1DV[V[a\x16\xF6V[\x90\x80`\x1F\x83\x01\x12\x15a\x17|W\x81` a\x17y\x935\x91\x01a\x17(V[\x90V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x17\xD4Wa\x17\x98`@a\x16\xBCV[\x92_\x82\x015\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x17\xCFWa\x17\xBC\x82a\x17\xC8\x94\x83\x01a\x17^V[_\x86\x01R` \x01a\x07\rV[` \x83\x01RV[a\x16\xF2V[a\x16\xEEV[\x92\x91\x90a\x17\xEDa\x17\xE8\x82a\x16\xD1V[a\x16\xBCV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11a\x18DW\x81\x90[\x83\x82\x10a\x18\x13WPPPPPV[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x18?W` \x91a\x184\x87\x84\x93\x87\x01a\x17\x81V[\x81R\x01\x91\x01\x90a\x18\x05V[a\x05\xAFV[a\x05\xB7V[\x90\x80`\x1F\x83\x01\x12\x15a\x18gW\x81` a\x18d\x935\x91\x01a\x17\xD9V[\x90V[a\x05\xAFV[`\x80\x81\x83\x03\x12a\x18\xC6Wa\x18\x82\x82_\x83\x01a\x03\xD5V[\x92a\x18\x90\x83` \x84\x01a\x04\x0FV[\x92`@\x83\x015\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a\x18\xC1Wa\x18\xB5\x81a\x18\xBE\x93\x86\x01a\x18IV[\x93``\x01a\x07\rV[\x90V[a\x03\xB0V[a\x03\xACV[4a\x18\xFDWa\x18\xE7a\x18\xDE6`\x04a\x18lV[\x92\x91\x90\x91a@@V[a\x18\xEFa\x03\xA2V[\x80a\x18\xF9\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x19\x19a\x19\x14a\x19\x1E\x92a\x19\x02V[a\x07IV[a\x05TV[\x90V[a\x19+`@a\x19\x05V[\x90V[a\x196a\x19!V[\x90V[4a\x19iWa\x19I6`\x04a\x0B\xDAV[a\x19ea\x19Ta\x19.V[a\x19\\a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[4a\x19\x9CWa\x19~6`\x04a\x0B\xDAV[a\x19\x86aFoV[a\x19\x8Ea\x03\xA2V[\x80a\x19\x98\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x19\xAA\x90a\x11eV[\x90RV[a\x19\xB7\x90a\x0F\x01V[\x90RV[\x90`\x80\x80a\x1A\x13\x93a\x19\xD3_\x82\x01Q_\x86\x01\x90a\r\xDBV[a\x19\xE5` \x82\x01Q` \x86\x01\x90a\x04\xA2V[a\x19\xF7`@\x82\x01Q`@\x86\x01\x90a\x04\xB5V[a\x1A\t``\x82\x01Q``\x86\x01\x90a\x19\xA1V[\x01Q\x91\x01\x90a\x19\xAEV[V[\x91\x90a\x1A(\x90_`\xA0\x85\x01\x94\x01\x90a\x19\xBBV[V[4a\x1A[Wa\x1AWa\x1AFa\x1A@6`\x04a\x04\x1EV[\x90aG\xACV[a\x1ANa\x03\xA2V[\x91\x82\x91\x82a\x1A\x15V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\x91Wa\x1A\x8Da\x1A|a\x1Av6`\x04a\x04\x1EV[\x90aH\x04V[a\x1A\x84a\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xC4Wa\x1A\xA66`\x04a\x0B\xDAV[a\x1A\xAEaH,V[a\x1A\xB6a\x03\xA2V[\x80a\x1A\xC0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xF9Wa\x1A\xF5a\x1A\xE4a\x1A\xDF6`\x04a\x04\x84V[aH}V[a\x1A\xECa\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a\x1B3Wa\x1B0a\x1B\x19\x84_\x85\x01a\x03\xD5V[\x93a\x1B'\x81` \x86\x01a\x07\rV[\x93`@\x01a\x07\rV[\x90V[a\x03\xACV[\x92\x91` a\x1BTa\x1B\\\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\x12qV[\x94\x01\x90a\x05WV[V[4a\x1B\x90Wa\x1Bwa\x1Bq6`\x04a\x1A\xFEV[\x91aI\x1BV[\x90a\x1B\x8Ca\x1B\x83a\x03\xA2V[\x92\x83\x92\x83a\x1B8V[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xC3Wa\x1B\xADa\x1B\xA86`\x04a\x06\xA8V[aJ\xA2V[a\x1B\xB5a\x03\xA2V[\x80a\x1B\xBF\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xF8Wa\x1B\xD86`\x04a\x0B\xDAV[a\x1B\xF4a\x1B\xE3aJ\xB1V[a\x1B\xEBa\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1C7W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1C2W` \x01\x92` \x83\x02\x84\x01\x11a\x1C-WV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x1C}Wa\x1CU\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1CxWa\x1Ct\x92\x01a\x1B\xFDV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1C\xB1Wa\x1C\x9Ba\x1C\x956`\x04a\x1C<V[\x91aK8V[a\x1C\xA3a\x03\xA2V[\x80a\x1C\xAD\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x91``\x83\x83\x03\x12a\x1D\x02Wa\x1C\xCD\x82_\x85\x01a\x03\xD5V[\x92a\x1C\xDB\x83` \x83\x01a\x04\x0FV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1C\xFDWa\x1C\xFA\x92\x01a\x17^V[\x90V[a\x03\xB0V[a\x03\xACV[\x90a\x1D\x11\x90a\x07LV[_R` R`@_ \x90V[\x90a\x1D'\x90a\x10\x06V[_R` R`@_ \x90V[\x90P\x90V[a\x1D]a\x1DT\x92` \x92a\x1DK\x81a\t\xD1V[\x94\x85\x80\x93a\x1D3V[\x93\x84\x91\x01a\t\xDEV[\x01\x90V[\x90V[a\x1Dpa\x1Du\x91a\x05TV[a\x1DaV[\x90RV[a\x1D\x89a\x1D\x90\x91` \x94\x93a\x1D8V[\x80\x92a\x1DdV[\x01\x90V[a\x1D\xA8a\x1D\x9Fa\x03\xA2V[\x92\x83\x92\x83a\x1DyV[\x03\x90 \x90V[a\x1D\xB7\x91a\x1D\x94V[\x90V[a\x1D\xCA\x90`\x08a\x1D\xCF\x93\x02a\x0CxV[a\t'V[\x90V[\x90a\x1D\xDD\x91Ta\x1D\xBAV[\x90V[\x90a\x1E\x08\x92a\x1D\xFEa\x1E\x03\x92a\x1D\xF9`\t\x95_\x96a\x1D\x07V[a\x1D\x1DV[a\x1D\xAEV[a\x1D\xD2V[\x90V[4a\x1E<Wa\x1E8a\x1E'a\x1E!6`\x04a\x1C\xB6V[\x91a\x1D\xE0V[a\x1E/a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1E{W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1EvW` \x01\x92`\x01\x83\x02\x84\x01\x11a\x1EqWV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91``\x83\x83\x03\x12a\x1E\xCDWa\x1E\x97\x82_\x85\x01a\x03\xD5V[\x92a\x1E\xA5\x83` \x83\x01a\x04\x0FV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1E\xC8Wa\x1E\xC4\x92\x01a\x1EAV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1F\x04Wa\x1E\xEEa\x1E\xE56`\x04a\x1E\x80V[\x92\x91\x90\x91aM\x9DV[a\x1E\xF6a\x03\xA2V[\x80a\x1F\0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x1F\x12\x81a\x04\xC2V[\x03a\x1F\x19WV[_\x80\xFD[\x90P5\x90a\x1F*\x82a\x1F\tV[V[\x91\x90\x91`\xA0\x81\x84\x03\x12a\x1F\x98Wa\x1FE\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1F\x93W\x81a\x1Ff\x91\x84\x01a\x1EAV[\x92\x90\x93a\x1F\x90a\x1Fy\x84`@\x85\x01a\x07\rV[\x93a\x1F\x87\x81``\x86\x01a\x07\rV[\x93`\x80\x01a\x1F\x1DV[\x90V[a\x03\xB0V[a\x03\xACV[4a\x1F\xD2Wa\x1F\xBCa\x1F\xB06`\x04a\x1F,V[\x94\x93\x90\x93\x92\x91\x92aPrV[a\x1F\xC4a\x03\xA2V[\x80a\x1F\xCE\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a \x05Wa\x1F\xEFa\x1F\xEA6`\x04a\x04\x84V[aT'V[a\x1F\xF7a\x03\xA2V[\x80a \x01\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a ?Wa <a %\x84_\x85\x01a\x03\xD5V[\x93a 3\x81` \x86\x01a\x03\xD5V[\x93`@\x01a\n\xB8V[\x90V[a\x03\xACV[4a sWa ]a W6`\x04a \nV[\x91aV\x9CV[a ea\x03\xA2V[\x80a o\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a \xA7Wa \x91a \x8B6`\x04a\x04\x1EV[\x90aX[V[a \x99a\x03\xA2V[\x80a \xA3\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[\x90a!\r\x90``\x80a \xDE`\x80\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\xAAV[\x94a \xF1` \x82\x01Q` \x86\x01\x90a\r\xDBV[a!\x03`@\x82\x01Q`@\x86\x01\x90a\r\xDBV[\x01Q\x91\x01\x90a\x04\xC7V[\x90V[\x90a!\x1A\x91a \xBFV[\x90V[` \x01\x90V[\x90a!7a!0\x83a \xACV[\x80\x92a \xB0V[\x90\x81a!H` \x83\x02\x84\x01\x94a \xB9V[\x92_\x91[\x83\x83\x10a![WPPPPP\x90V[\x90\x91\x92\x93\x94` a!}a!w\x83\x85`\x01\x95\x03\x87R\x89Qa!\x10V[\x97a!\x1DV[\x93\x01\x93\x01\x91\x93\x92\x90a!LV[a!\x9F\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra!#V[\x90V[4a!\xD2Wa!\xCEa!\xBDa!\xB86`\x04a\x04\x84V[a[\xD2V[a!\xC5a\x03\xA2V[\x91\x82\x91\x82a!\x8AV[\x03\x90\xF3[a\x03\xA8V[4a\"\x05Wa!\xEFa!\xEA6`\x04a\x04\x84V[a]bV[a!\xF7a\x03\xA2V[\x80a\"\x01\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\"\x16`\n_\x90a\x0C\x9FV[\x90V[4a\"IWa\")6`\x04a\x0B\xDAV[a\"Ea\"4a\"\nV[a\"<a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a\"\x82Wa\"~a\"ma\"d6`\x04a\x1E\x80V[\x92\x91\x90\x91a]\xCFV[a\"ua\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90a\"\x91\x90a\x07LV[_R` R`@_ \x90V[a\"\xA9a\"\xAE\x91a\x10\x83V[a\tKV[\x90V[a\"\xBB\x90Ta\"\x9DV[\x90V[a\"\xC9\x90`\x02a\"\x87V[a\"\xD4_\x82\x01a\x10IV[\x91a\"\xEB_a\"\xE4\x81\x85\x01a\x10vV[\x93\x01a\"\xB1V[\x90V[`@\x90a#\x17a#\x1E\x94\x96\x95\x93\x96a#\r``\x84\x01\x98_\x85\x01\x90a\x0C!V[` \x83\x01\x90a\x11)V[\x01\x90a\n\x1AV[V[4a#SWa#Oa#;a#66`\x04a\x04\x84V[a\"\xBEV[a#F\x93\x91\x93a\x03\xA2V[\x93\x84\x93\x84a\"\xEEV[\x03\x90\xF3[a\x03\xA8V[4a#\x88Wa#h6`\x04a\x0B\xDAV[a#\x84a#sa^\x04V[a#{a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a#\xBCWa#\xA6a#\xA06`\x04a\x04\x1EV[\x90a^\xEEV[a#\xAEa\x03\xA2V[\x80a#\xB8\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a#\xF2Wa#\xEEa#\xDDa#\xD76`\x04a\x04\x1EV[\x90a`\x83V[a#\xE5a\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[4a$%Wa$\x0Fa$\n6`\x04a\x06\xA8V[aa\x82V[a$\x17a\x03\xA2V[\x80a$!\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x91\x90`@\x83\x82\x03\x12a$RW\x80a$Fa$O\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x1F\x1DV[\x90V[a\x03\xACV[4a$\x86Wa$pa$j6`\x04a$*V[\x90aa\x8DV[a$xa\x03\xA2V[\x80a$\x82\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x7F2r\x1F\x8D\xC6~\x95<T\r\xA9\x0Ff0Y\xC2?\xC4\x7Fp\xD1\x1E1~\xD6\xD5\xA2L\x8B\x85ct\x90V[a$\xB7a$\x8BV[\x90V[4a$\xEAWa$\xCA6`\x04a\x0B\xDAV[a$\xE6a$\xD5a$\xAFV[a$\xDDa\x03\xA2V[\x91\x82\x91\x82a\x0F\x11V[\x03\x90\xF3[a\x03\xA8V[4a%\x1EWa%\x08a%\x026`\x04a\x04\x1EV[\x90abVV[a%\x10a\x03\xA2V[\x80a%\x1A\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x7FOnly Tangle core\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%[`\x10` \x92a\t\xD5V[a%d\x81a%'V[\x01\x90V[a%}\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%NV[\x90V[\x15a%\x87WV[a%\x8Fa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a%\xA5`\x04\x82\x01a%hV[\x03\x90\xFD[a%\xB5a%\xBA\x91a\t\"V[a\x0C|V[\x90V[a%\xC7\x90Ta%\xA9V[\x90V[\x90V[a%\xE1a%\xDCa%\xE6\x92a%\xCAV[a\x07IV[a\x03\xE4V[\x90V[a%\xF2\x90a%\xCDV[\x90V[_\x7FAlready registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a&)`\x12` \x92a\t\xD5V[a&2\x81a%\xF5V[\x01\x90V[a&K\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra&\x1CV[\x90V[\x15a&UWV[a&]a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a&s`\x04\x82\x01a&6V[\x03\x90\xFD[_\x1B\x90V[\x90a&\x8D`\x01\x80`\xA0\x1B\x03\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90a&\xAFa&\xAAa&\xB6\x92a\x10\x06V[a&\x97V[\x82Ta&|V[\x90UV[a'<a'A\x92a&\xFD3a&\xF7a&\xF1\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[a'4a'\x14a'\x0F`\x07\x86\x90a\x13\xC5V[a%\xBDV[a'.a'(a'#_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14a&NV[\x91`\x07a\x13\xC5V[a&\x9AV[V[a'M``a\x16\xBCV[\x90V[_\x90V[_\x90V[_\x90V[a'da'CV[\x90` \x80\x80\x84a'ra'PV[\x81R\x01a'}a'TV[\x81R\x01a'\x88a'XV[\x81RPPV[a'\x96a'\\V[\x90V[a'\xAB\x90a'\xA5a'\x8EV[Pac~V[\x90V[_\x90V[a'\xD3a'\xD9\x92a'\xCE_\x93a'\xC6a'\xAEV[P`\x03a\x0F\xC8V[a\x10\x12V[\x01a\t>V[\x90V[_\x7FNot service owner\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(\x10`\x11` \x92a\t\xD5V[a(\x19\x81a'\xDCV[\x01\x90V[a(2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x03V[\x90V[\x15a(<WV[a(Da\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(Z`\x04\x82\x01a(\x1DV[\x03\x90\xFD[P\x90V[_\x7FToo many definitions\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(\x96`\x14` \x92a\t\xD5V[a(\x9F\x81a(bV[\x01\x90V[a(\xB8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x89V[\x90V[\x15a(\xC2WV[a(\xCAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(\xE0`\x04\x82\x01a(\xA3V[\x03\x90\xFD[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[a)\x07a)\r\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x91a)\x19\x83\x82\x02a\x05TV[\x92\x81\x84\x04\x14\x90\x15\x17\x15a)(WV[a(\xE4V[a)8\x90`\x04a(\xF8V[\x90V[\x90a)N\x90_\x19\x90` \x03`\x08\x02a\x0CxV[\x81T\x16\x90UV[\x1B\x90V[\x91\x90`\x08a)t\x91\x02\x91a)n_\x19\x84a)UV[\x92a)UV[\x91\x81\x19\x16\x91\x16\x17\x90V[a)\x92a)\x8Da)\x97\x92a\x05TV[a\x07IV[a\x05TV[\x90V[\x90V[\x91\x90a)\xB3a)\xAEa)\xBB\x93a)~V[a)\x9AV[\x90\x83Ta)YV[\x90UV[a)\xD1\x91a)\xCBa'\xAEV[\x91a)\x9DV[V[[\x81\x81\x10a)\xDFWPPV[\x80a)\xEC_`\x01\x93a)\xBFV[\x01a)\xD4V[\x90a*\x02\x90_\x19\x90`\x08\x02a\x0CxV[\x19\x16\x90V[\x81a*\x11\x91a)\xF2V[\x90`\x02\x02\x17\x90V[\x90_\x91a*0a*(\x82a\x08\x17V[\x92\x83Ta*\x07V[\x90UUV[`\x1F` \x91\x01\x04\x90V[\x91\x92\x90` \x82\x10_\x14a*\x98W`\x1F\x84\x11`\x01\x14a*hWa*b\x92\x93Pa*\x07V[\x90U[[V[P\x90a*\x8Ea*\x93\x93`\x01a*\x85a*\x7F\x85a\x08\x17V[\x92a*5V[\x82\x01\x91\x01a)\xD3V[a*\x19V[a*eV[Pa*\xCF\x82\x93a*\xA9`\x01\x94a\x08\x17V[a*\xC8a*\xB5\x85a*5V[\x82\x01\x92`\x1F\x86\x16\x80a*\xDAW[Pa*5V[\x01\x90a)\xD3V[`\x02\x02\x17\x90Ua*fV[a*\xE6\x90\x88\x86\x03a);V[_a*\xC2V[\x92\x90\x91h\x01\0\0\0\0\0\0\0\0\x82\x11a+LW` \x11_\x14a+=W` \x81\x10_\x14a+!Wa+\x1B\x91a*\x07V[\x90U[[V[`\x01\x91`\xFF\x19\x16a+1\x84a\x08\x17V[U`\x02\x02\x01\x90Ua+\x1EV[`\x01\x91P`\x02\x02\x01\x90Ua+\x1FV[a\x08\xC3V[\x90\x81Ta+]\x81a\x07\xE4V[\x90\x81\x83\x11a+\x86W[\x81\x83\x10a+tW[PPPPV[a+}\x93a*?V[_\x80\x80\x80a+nV[a+\x92\x83\x83\x83\x87a*\xECV[a+fV[_a+\xA1\x91a+QV[V[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[\x90_\x03a+\xC8Wa+\xC6\x90a+\x97V[V[a+\xA3V[`\x03_\x91a+\xDD\x83\x80\x83\x01a+\xB6V[a+\xEA\x83`\x01\x83\x01a)\xBFV[a+\xF7\x83`\x02\x83\x01a)\xBFV[\x01UV[\x90_\x03a,\rWa,\x0B\x90a+\xCDV[V[a+\xA3V[[\x81\x81\x10a,\x1EWPPV[\x80a,+_`\x04\x93a+\xFBV[\x01a,\x13V[\x90\x91\x82\x81\x10a,@W[PPPV[a,^a,Xa,Ra,i\x95a)-V[\x92a)-V[\x92a\x07\x96V[\x91\x82\x01\x91\x01\x90a,\x12V[_\x80\x80a,;V[\x90h\x01\0\0\0\0\0\0\0\0\x81\x11a,\x9AW\x81a,\x8Fa,\x98\x93a\x07\x92V[\x90\x82\x81Ua,1V[V[a\x08\xC3V[_a,\xA9\x91a,qV[V[\x90_\x03a,\xBDWa,\xBB\x90a,\x9FV[V[a+\xA3V[a,\xD6a,\xD1a,\xDB\x92a%\xCAV[a\x07IV[a\x05TV[\x90V[`\x01a,\xEA\x91\x01a\x05TV[\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x905\x90`\x01`\x80\x03\x816\x03\x03\x82\x12\x15a-\x10W\x01\x90V[a,\xEDV[\x90\x82\x10\x15a-/W` a-,\x92\x02\x81\x01\x90a,\xF9V[\x90V[a\x07~V[\x905\x90`\x01` \x03\x816\x03\x03\x82\x12\x15a-vW\x01\x805\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a-qW` \x01\x91`\x01\x82\x026\x03\x83\x13a-lWV[a,\xF5V[a,\xF1V[a,\xEDV[\x91V[P\x90V[_\x7FName too long\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-\xB6`\r` \x92a\t\xD5V[a-\xBF\x81a-\x82V[\x01\x90V[a-\xD8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-\xA9V[\x90V[\x15a-\xE2WV[a-\xEAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.\0`\x04\x82\x01a-\xC3V[\x03\x90\xFD[5a.\x0E\x81a\x06\xF9V[\x90V[_\x7FInvalid bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a.E`\x0E` \x92a\t\xD5V[a.N\x81a.\x11V[\x01\x90V[a.g\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra.8V[\x90V[\x15a.qWV[a.ya\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.\x8F`\x04\x82\x01a.RV[\x03\x90\xFD[\x90V[_R` _ \x90V[T\x90V[a.\xAC\x81a.\x9FV[\x82\x10\x15a.\xC6Wa.\xBE`\x04\x91a.\x96V[\x91\x02\x01\x90_\x90V[a\x07~V[P\x90V[\x91\x90`\x1F\x81\x11a.\xDFW[PPPV[a.\xEBa/\x10\x93a\x08\x17V[\x90` a.\xF7\x84a*5V[\x83\x01\x93\x10a/\x18W[a/\t\x90a*5V[\x01\x90a)\xD3V[_\x80\x80a.\xDAV[\x91Pa/\t\x81\x92\x90Pa/\0V[\x91a/1\x90\x82a.\xCBV[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a/\xF0Wa/U\x82a/O\x85Ta\x07\xE4V[\x85a.\xCFV[_\x90`\x1F\x83\x11`\x01\x14a/\x88W\x91\x80\x91a/w\x93_\x92a/|W[PPa*\x07V[\x90U[V[\x90\x91P\x015_\x80a/pV[`\x1F\x19\x83\x16\x91a/\x97\x85a\x08\x17V[\x92_[\x81\x81\x10a/\xD8WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10a/\xBEW[PPP\x02\x01\x90Ua/zV[a/\xCE\x91\x015`\x1F\x84\x16\x90a)\xF2V[\x90U_\x80\x80a/\xB2V[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a/\x9AV[a\x08\xC3V[\x90a0\0\x92\x91a/&V[V[\x90a0\x0E_\x19\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a0-a0(a04\x92a)~V[a)\x9AV[\x82Ta0\x02V[\x90UV[5a0B\x81a\x1F\tV[\x90V[\x90a0Q`\xFF\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[a0d\x90a\x04\xC2V[\x90V[\x90V[\x90a0\x7Fa0za0\x86\x92a0[V[a0gV[\x82Ta0EV[\x90UV[\x90a0\xE8```\x03a0\xEE\x94a0\xAE_\x82\x01a0\xA8_\x88\x01\x88a-4V[\x91a/\xF5V[a0\xC7`\x01\x82\x01a0\xC1` \x88\x01a.\x04V[\x90a0\x18V[a0\xE0`\x02\x82\x01a0\xDA`@\x88\x01a.\x04V[\x90a0\x18V[\x01\x92\x01a08V[\x90a0jV[V[\x91\x90a1\x01Wa0\xFF\x91a0\x8AV[V[a+\xA3V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15a16W\x82a1.\x91`\x01a14\x95\x01\x81Ua.\xA3V[\x90a0\xF0V[V[a\x08\xC3V[\x92\x91\x90\x92a1n3a1ha1ba1]a1X`\x07\x87\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[a1\x9Ca1|\x85\x84\x90a(^V[a1\x95a1\x8Fa1\x8Aa\x15mV[a\x05TV[\x91a\x05TV[\x11\x15a(\xBBV[a1\xB1_a1\xAC`\x08\x84\x90a\x07hV[a,\xABV[a1\xBA_a,\xC2V[[\x80a1\xD8a1\xD2a1\xCD\x88\x87\x90a(^V[a\x05TV[\x91a\x05TV[\x10\x15a2\xABWa2\xA6\x90a2/a2\x0Fa2\ta2\x03a1\xFA\x8A\x89\x87\x91a-\x15V[_\x81\x01\x90a-4V[\x90a-{V[\x90a-~V[a2(a2\"a2\x1Da\x19!V[a\x05TV[\x91a\x05TV[\x11\x15a-\xDBV[a2xa2I`@a2C\x89\x88\x86\x91a-\x15V[\x01a.\x04V[a2qa2ka2f` a2`\x8C\x8B\x89\x91a-\x15V[\x01a.\x04V[a\x05TV[\x91a\x05TV[\x10\x15a.jV[a2\xA1a2\x8Fa2\x8A`\x08\x86\x90a\x07hV[a.\x93V[a2\x9B\x88\x87\x85\x91a-\x15V[\x90a1\x06V[a,\xDEV[a1\xBBV[PPP\x90PV[_\x7FZero address\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a2\xE6`\x0C` \x92a\t\xD5V[a2\xEF\x81a2\xB2V[\x01\x90V[a3\x08\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra2\xD9V[\x90V[\x15a3\x12WV[a3\x1Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a30`\x04\x82\x01a2\xF3V[\x03\x90\xFD[\x90a3>\x90a\x07LV[_R` R`@_ \x90V[\x90V[`H\x1B\x90V[\x90a3hi\xFF\0\0\0\0\0\0\0\0\0\x91a3MV[\x91\x81\x19\x16\x91\x16\x17\x90V[a3{\x90a\x11YV[\x90V[\x90V[\x90a3\x96a3\x91a3\x9D\x92a3rV[a3~V[\x82Ta3SV[\x90UV[a3\xDD3a3\xD7a3\xD1\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[a4\x02\x82a3\xFBa3\xF5a3\xF0_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14\x15a3\x0BV[a4(a4#a4\x1Ca4\x17`\x06\x85\x90a34V[a3JV[\x84\x90ad\\V[a&NV[a4K`\x02`\x01a4Ea4>`\x03\x86\x90a\x0F\xC8V[\x86\x90a\x10\x12V[\x01a3\x81V[\x90a4\x7Fa4y\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK\x93a\x07LV[\x91a\x10\x06V[\x91a4\x88a\x03\xA2V[\x80a4\x92\x81a\x04KV[\x03\x90\xA3V[a4\xA8\x90a4\xA3ad\x96V[a4\xAAV[V[a4\xB5\x90`\x0Ba&\x9AV[V[a4\xC0\x90a4\x97V[V[_\x7FNot registered operator\0\0\0\0\0\0\0\0\0\x91\x01RV[a4\xF6`\x17` \x92a\t\xD5V[a4\xFF\x81a4\xC2V[\x01\x90V[a5\x18\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra4\xE9V[\x90V[\x15a5\"WV[a5*a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a5@`\x04\x82\x01a5\x03V[\x03\x90\xFD[\x90a5y\x97\x96\x95\x94\x93\x92\x91a5ta5oa5ha5c\x84`\x06a34V[a3JV[3\x90ad\xE4V[a5\x1BV[a7\xBAV[V[a5\x8Fa5\x8Aa5\x94\x92a\x03\xB4V[a\x07IV[a\x05TV[\x90V[a5\xABa5\xA6a5\xB0\x92a\x05TV[a\x07IV[a\x03\xB4V[\x90V[\x91` a5\xD4\x92\x94\x93a5\xCD`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x0C!V[V[a5\xE5a5\xEB\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x82\x03\x91\x82\x11a5\xF6WV[a(\xE4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a6\x19Wa6\x15` \x91a\x08\xB9V[\x01\x90V[a\x08\xC3V[\x90\x92\x91\x92a63a6.\x82a5\xFBV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a6OWa6M\x92a\x17\x1DV[V[a\x16\xF6V[a6_\x916\x91a6\x1EV[\x90V[` \x01\x90V[Q\x90V[\x94\x92\x90\x97\x96\x95\x93\x91`\xE0\x86\x01\x98_\x87\x01a6\x85\x91a\x0F\x04V[` \x86\x01a6\x92\x91a\x0C\xBCV[`@\x85\x01a6\x9F\x91a\x0C!V[``\x84\x01a6\xAC\x91a\x0C!V[`\x80\x83\x01a6\xB9\x91a\x11)V[`\xA0\x82\x01a6\xC6\x91a\x0F\x04V[`\xC0\x01a6\xD2\x91a\x0C!V[V[_a\x19\x01`\xF0\x1B\x91\x01RV[a6\xEC`\x02\x80\x92a\x1D3V[a6\xF5\x81a6\xD4V[\x01\x90V[\x90V[a7\x08a7\r\x91a\x0F\x01V[a6\xF9V[\x90RV[` \x80\x93\x92a7,a7%a74\x94a6\xE0V[\x80\x92a6\xFCV[\x01\x80\x92a6\xFCV[\x01\x90V[_\x7FInvalid signature\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a7l`\x11` \x92a\t\xD5V[a7u\x81a78V[\x01\x90V[a7\x8E\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra7_V[\x90V[\x15a7\x98WV[a7\xA0a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a7\xB6`\x04\x82\x01a7yV[\x03\x90\xFD[\x91\x92\x93\x94\x97\x96\x90\x95\x97\x80a7\xD6a7\xD0Ba\x05TV[\x91a5{V[\x11a9>Wa7\xEEBa7\xE8\x83a5{V[\x90a5\xD6V[a8\x07a8\x01a7\xFCa\r\x13V[a5{V[\x91a\x05TV[\x11a9\x16Wa9\x14\x97\x98a8\xEBa9\t\x93\x85a8u\x8Aa8f\x8Da8\xF1\x98\x8D\x8Da8=a82a$\x8BV[\x963\x99\x95\x92\x93a6TV[a8Oa8I\x82a6hV[\x91a6bV[ \x92\x93a8Za\x03\xA2V[\x98\x89\x97` \x89\x01a6lV[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD7V[a8\x87a8\x81\x82a6hV[\x91a6bV[ a8\xD2\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a8\xC3a8\xB7a\x03\xA2V[\x93\x84\x92` \x84\x01a7\x11V[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD7V[a8\xE4a8\xDE\x82a6hV[\x91a6bV[ \x92a6TV[\x90ae\x1EV[a9\x03a8\xFD3a\x03\xEFV[\x91a\x03\xEFV[\x14a7\x91V[\x933\x91\x92\x93\x94af\xB5V[V[a9\x1FBa5\x97V[\x90a9:_\x92\x83\x92c\x185[u`\xE2\x1B\x84R`\x04\x84\x01a5\xB3V[\x03\x90\xFD[a9GBa5\x97V[\x90a9b_\x92\x83\x92cW\xEA\x02\xE9`\xE0\x1B\x84R`\x04\x84\x01a5\xB3V[\x03\x90\xFD[\x90a9v\x97\x96\x95\x94\x93\x92\x91a5DV[V[``\x90V[\x90` \x82\x82\x03\x12a9\xADW_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a9\xA8Wa9\xA5\x92\x01a\x18IV[\x90V[a\x03\xB0V[a\x03\xACV[\x90a9\xC9\x91a9\xBFa9xV[P\x90\x81\x01\x90a9}V[\x90V[a9\xEBa9\xE6a9\xF0\x92a9\xDEa'\xAEV[P`\x05a34V[a3JV[aj\xC7V[\x90V[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a:\x10W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a:'a:\"\x83a9\xF8V[a\x16\xBCV[\x91\x82RV[6\x907V[\x90a:Va:>\x83a:\x15V[\x92` \x80a:L\x86\x93a9\xF8V[\x92\x01\x91\x03\x90a:,V[V[\x90a:b\x82a\x12:V[\x81\x10\x15a:sW` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90a:\x82\x90a\x03\xEFV[\x90RV[\x90a:\x8Fa9\xF3V[Pa:\xACa:\xA7a:\xA2`\x04\x85\x90a34V[a3JV[aj\xC7V[\x91a:\xB6\x83a:1V[\x91a:\xC0_a,\xC2V[[\x80a:\xD4a:\xCE\x87a\x05TV[\x91a\x05TV[\x10\x15a;\x1BWa;\x16\x90a;\x11a:\xFFa:\xF8a:\xF3`\x04\x88\x90a34V[a3JV[\x83\x90ak\x16V[a;\x0C\x87\x91\x84\x90\x92a:XV[a:xV[a,\xDEV[a:\xC1V[P\x92PP\x90V[_\x90V[\x90a;/a;\"V[Pa;Q`\x01a;Ka;D`\x03\x86\x90a\x0F\xC8V[\x84\x90a\x10\x12V[\x01a\x10\xA3V[a;ca;]_a\x11YV[\x91a\x11YV[\x14\x91\x82\x15a;qW[PP\x90V[a;\x92\x92P`\x01\x91a;\x87a;\x8C\x92`\x03a\x0F\xC8V[a\x10\x12V[\x01a\x10\xA3V[a;\xA5a;\x9F`\x01a\x11YV[\x91a\x11YV[\x14_\x80a;lV[a;\xD3\x90a;\xB9a9\xF3V[P_\x90a;\xCDa;\xC7a\x13-V[\x92a,\xC2V[\x90aI\x1BV[P\x90V[\x90a<\t\x94\x93\x92\x91a<\x04a;\xFFa;\xF8a;\xF3\x84`\x06a34V[a3JV[3\x90ad\xE4V[a5\x1BV[a<\x0BV[V[\x91a<\x1D\x94\x92\x93\x913\x91\x92\x93\x94af\xB5V[V[\x90a<,\x94\x93\x92\x91a;\xD7V[V[\x90a<Na<Ia<S\x93a<Aa;\"V[P`\x06a34V[a3JV[ad\xE4V[\x90V[_\x90V[a<|a<\x82\x92a<w`\x01\x93a<oa<VV[P`\x03a\x0F\xC8V[a\x10\x12V[\x01a\x10\xA3V[\x90V[a<\x8E\x90a\x0F\xFAV[\x90V[_\x7FInternal only\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a<\xC5`\r` \x92a\t\xD5V[a<\xCE\x81a<\x91V[\x01\x90V[a<\xE7\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra<\xB8V[\x90V[\x15a<\xF1WV[a<\xF9a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a=\x0F`\x04\x82\x01a<\xD2V[\x03\x90\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a=+W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a=Ba==\x83a=\x13V[a\x16\xBCV[\x91\x82RV[6\x907V[\x90a=qa=Y\x83a=0V[\x92` \x80a=g\x86\x93a=\x13V[\x92\x01\x91\x03\x90a=GV[V[\x90a=}\x82a\r\x97V[\x81\x10\x15a=\x8EW` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90V[Q\x90V[\x90a=\xA4\x82a=\x96V[\x81\x10\x15a=\xB5W` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90a=\xC4\x90a\x0F\x01V[\x90RV[``\x90V[\x90V[` \x91\x81R\x01\x90V[\x90_\x92\x91\x80T\x90a=\xF3a=\xEC\x83a\x07\xE4V[\x80\x94a=\xD0V[\x91`\x01\x81\x16\x90\x81_\x14a>JWP`\x01\x14a>\x0EW[PPPV[a>\x1B\x91\x92\x93\x94Pa\x07\x9FV[\x91_\x92[\x81\x84\x10a>2WPP\x01\x90_\x80\x80a>\tV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a>\x1FV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a>\tV[\x90a>o\x91a=\xD9V[\x90V[\x90a>\x92a>\x8B\x92a>\x82a\x03\xA2V[\x93\x84\x80\x92a>eV[\x03\x83a\x08\xD7V[V[a>\x9D\x90a>rV[\x90V[a>\xAA\x90Qa\x0F\x01V[\x90V[a>\xB7\x90Qa\x05TV[\x90V[_\x7FValue out of bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a>\xEE`\x13` \x92a\t\xD5V[a>\xF7\x81a>\xBAV[\x01\x90V[a?\x13a?!\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra\t\xE9V[\x90` \x81\x83\x03\x91\x01Ra>\xE1V[\x90V[\x92\x91` a?@a?H\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\t\xE9V[\x94\x01\x90a\x05WV[V[\x90_\x92\x91\x80T\x90a?da?]\x83a\x07\xE4V[\x80\x94a\t\xD5V[\x91`\x01\x81\x16\x90\x81_\x14a?\xBBWP`\x01\x14a?\x7FW[PPPV[a?\x8C\x91\x92\x93\x94Pa\x08\x17V[\x91_\x92[\x81\x84\x10a?\xA3WPP\x01\x90_\x80\x80a?zV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a?\x90V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a?zV[_\x7FRequired metric missing\0\0\0\0\0\0\0\0\0\x91\x01RV[a@\n`\x17` \x92a\t\xD5V[a@\x13\x81a?\xD6V[\x01\x90V[a@/a@=\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra?JV[\x90` \x81\x83\x03\x91\x01Ra?\xFDV[\x90V[\x92\x93\x90\x93a@h3a@ba@\\a@W0a<\x85V[a\x03\xEFV[\x91a\x03\xEFV[\x14a<\xEAV[a@|a@w`\x08\x86\x90a\x07hV[a.\x93V[\x94a@\x86\x82a=LV[\x94a@\x90_a,\xC2V[[\x80a@\xA4a@\x9E\x86a\x05TV[\x91a\x05TV[\x10\x15a@\xF7Wa@\xF2\x90a@\xEDa@\xC8_a@\xC0\x8A\x85\x90a=sV[Q\x01Qa=\x93V[a@\xDAa@\xD4\x82a6hV[\x91a6bV[ a@\xE8\x8A\x91\x84\x90\x92a=\x9AV[a=\xBAV[a,\xDEV[a@\x91V[P\x91\x94\x90\x92\x95aA\x06\x81a.\x9FV[aA\x18aA\x12_a,\xC2V[\x91a\x05TV[\x11\x96aA\"a=\xC8V[\x90\x88aE\xA2W[aA2_a,\xC2V[[\x80aAFaA@\x8Ba\x05TV[\x91a\x05TV[\x10\x15aD\x05W`\x01_\x8BaB9W[P\x90\x88\x87\x89aAk\x94aApW[PPPa,\xDEV[aA3V[\x82_aA\xAEaA\xA6aA\xB7\x94aA\xA1aA\x99` aA\x92aA\xBC\x9B\x8D\x90a=sV[Q\x01a>\xADV[\x97`\ta\x1D\x07V[a\x1D\x1DV[\x92\x87\x90a=sV[Q\x01Q\x90a\x1D\xAEV[a0\x18V[\x88\x87\x89\x90aA\xE6` aA\xDF_aA\xD4\x87\x89\x90a=sV[Q\x01Q\x95\x87\x90a=sV[Q\x01a>\xADV[aB\x19aB\x13\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD\x93a\x07LV[\x93a\x10\x06V[\x93aB.aB%a\x03\xA2V[\x92\x83\x92\x83a?$V[\x03\x90\xA3\x88\x87\x89aAcV[\x9A\x90\x95\x92\x91\x99aBH_a,\xC2V[[\x80aBdaB^aBY\x8Aa.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aC\xEFWaB|aBw\x8D\x87a=\x9AV[a>\xA0V[aB\xA0aB\x9AaB\x95aB\x90\x8A\x86\x90a=\x9AV[a>\xA0V[a\x0F\x01V[\x91a\x0F\x01V[\x14aB\xB3WaB\xAE\x90a,\xDEV[aBIV[\x8A\x91\x9B\x92\x9CP\x89aAk\x94\x95\x98\x8A\x92`\x01\x90\x8AaB\xDD` aB\xD6\x89\x8B\x90a=sV[Q\x01a>\xADV[aC\x05aB\xFFaB\xFA`\x01aB\xF3\x86\x88\x90a.\xA3V[P\x01a\t>V[a\x05TV[\x91a\x05TV[\x10\x91\x88\x88\x84\x15aC\xA5W[PPPPaC:W[aC$\x90[\x15a\x04\xC2V[aC3W[\x93\x94PPPaAUV[P_aC)V[\x90P\x82\x82_aCJ\x87\x89\x90a=sV[Q\x01Q\x91aC\x96aC\x84aC~\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07LV[\x93a\x10\x06V[\x93aC\x8Da\x03\xA2V[\x91\x82\x91\x82a>\xFBV[\x03\x90\xA3aC$_\x91\x90PaC\x19V[aC\xE5\x93\x94PaC\xD3aC\xDF\x93aC\xCD` aC\xC6aC\xDA\x96`\x02\x96a=sV[Q\x01a>\xADV[\x96a.\xA3V[P\x01a\t>V[a\x05TV[\x91a\x05TV[\x11\x8A_\x88\x88aC\x10V[P\x99\x90\x9A\x87\x89aAk\x94\x95\x98aC$\x8D\x94aC\x1EV[P\x97PP\x92\x93P\x93PaD\x17_a,\xC2V[\x93[\x84aD4aD.aD)\x86a.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aE\x9BWaDZaDT`\x03aDM\x86\x89\x90a.\xA3V[P\x01a\teV[\x15a\x04\xC2V[aE\x90WaD|aDw_aDp\x86\x89\x90a.\xA3V[P\x01a=\xCDV[a>\x94V[aD\x8EaD\x88\x82a6hV[\x91a6bV[ \x90_\x96aD\x9B_a,\xC2V[[\x80aD\xB7aD\xB1aD\xAC\x86a=\x96V[a\x05TV[\x91a\x05TV[\x10\x15aE~WaD\xD0aD\xCB\x84\x83\x90a=\x9AV[a>\xA0V[aD\xE2aD\xDC\x86a\x0F\x01V[\x91a\x0F\x01V[\x14aD\xF5WaD\xF0\x90a,\xDEV[aD\x9CV[P\x95\x90\x96PaE\x16\x91PaE\x0B`\x01[\x15a\x04\xC2V[aE\x1DW[[a,\xDEV[\x93\x94aD\x19V[\x82\x85_aE+\x87\x85\x90a.\xA3V[P\x01\x91aEvaEdaE^\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07LV[\x93a\x10\x06V[\x93aEma\x03\xA2V[\x91\x82\x91\x82a@\x17V[\x03\x90\xA3aE\x10V[P\x95\x90\x96aE\x16\x92PaE\x0B\x90aE\x05V[\x94\x93aE\x16\x90aE\x11V[PPPPPV[\x96\x93\x90PaE\xBCaE\xB7\x83\x97\x94\x99\x96\x93a.\x9FV[a=LV[\x97aE\xC6_a,\xC2V[[\x80aE\xE2aE\xDCaE\xD7\x8Ba.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aF<WaF7\x90aF2aF\raF\x08_aF\x01\x8D\x86\x90a.\xA3V[P\x01a=\xCDV[a>\x94V[aF\x1FaF\x19\x82a6hV[\x91a6bV[ aF-\x8D\x91\x84\x90\x92a=\x9AV[a=\xBAV[a,\xDEV[aE\xC7V[P\x92\x95\x91\x94\x97\x90\x93\x96aA)V[aFRad\x96V[aFZaF\\V[V[aFmaFh_a%\xE9V[ak\xAEV[V[aFwaFJV[V[aF\x83`\xA0a\x16\xBCV[\x90V[_\x90V[_\x90V[_\x90V[aF\x9AaFyV[\x90` \x80\x80\x80\x80\x86aF\xAAaF\x86V[\x81R\x01aF\xB5a'PV[\x81R\x01aF\xC0a'TV[\x81R\x01aF\xCBaF\x8AV[\x81R\x01aF\xD6aF\x8EV[\x81RPPV[aF\xE4aF\x92V[\x90V[\x90aF\xF1\x90a\x05TV[\x90RV[\x90aF\xFF\x90a\x03\xB4V[\x90RV[\x90aG\r\x90a\x04\xAFV[\x90RV[\x90aG\x1B\x90a\x11YV[\x90RV[\x90aG\x9EaG\x95`\x02aG0aFyV[\x94aGGaG?_\x83\x01a\t>V[_\x88\x01aF\xE7V[aG_aGV`\x01\x83\x01a\x10IV[` \x88\x01aF\xF5V[aGwaGn`\x01\x83\x01a\x10vV[`@\x88\x01aG\x03V[aG\x8FaG\x86`\x01\x83\x01a\x10\xA3V[``\x88\x01aG\x11V[\x01a\x10\xC7V[`\x80\x84\x01a=\xBAV[V[aG\xA9\x90aG\x1FV[\x90V[aG\xD1\x91aG\xC7aG\xCC\x92aG\xBFaF\xDCV[P`\x03a\x0F\xC8V[a\x10\x12V[aG\xA0V[\x90V[_\x90V[\x90aG\xE2\x90a\x07LV[_R` R`@_ \x90V[\x90aG\xF8\x90a\x10\x06V[_R` R`@_ \x90V[aH)\x91aH\x1FaH$\x92aH\x17aG\xD4V[P`\x0CaG\xD8V[aG\xEEV[a\x10IV[\x90V[aH4ak\xC4V[aH<a^\x04V[aHNaHH\x83a\x03\xEFV[\x91a\x03\xEFV[\x03aH^WaH\\\x90ak\xAEV[V[aHy\x90_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xC9V[\x03\x90\xFD[aH\x9CaH\x97aH\xA1\x92aH\x8Fa'\xAEV[P`\x04a34V[a3JV[aj\xC7V[\x90V[aH\xAE\x90Qa\x04\xAFV[\x90V[aH\xC5aH\xC0aH\xCA\x92a%\xCAV[a\x07IV[a\x04\xAFV[\x90V[aH\xD7\x90Qa\x03\xB4V[\x90V[aH\xEEaH\xE9aH\xF3\x92a\x04\xAFV[a\x07IV[a\x05TV[\x90V[aI\x05aI\x0B\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x82\x01\x80\x92\x11aI\x16WV[a(\xE4V[\x90\x92\x91\x92aI'a9\xF3V[PaI0a'\xAEV[PaI:\x82ac~V[\x93aIWaIRaIM`\x05\x86\x90a34V[a3JV[aj\xC7V[\x92aId` \x87\x01aH\xA4V[aIvaIp_aH\xB1V[\x91a\x04\xAFV[\x14\x80\x15aJhW[\x80\x15aJMW[aJ3WaI\xBF\x86aI\xB9aI\xB4` aI\xADaI\xA8_aJ\x1C\x9B\x9C\x9D\x01aH\xCDV[a5{V[\x93\x01aH\xA4V[aH\xDAV[\x90a(\xF8V[\x91\x80aI\xDAaI\xD4aI\xCFa\x13-V[a\x05TV[\x91a\x05TV[\x11_\x14aJ.WPaI\xEAa\x13-V[[aI\xF6\x84\x82\x90aH\xF6V[aJ\x08aJ\x02\x88a\x05TV[\x91a\x05TV[\x11_\x14aJ\x1FWP\x84[\x90\x92\x90\x91\x92ak\xFAV[\x91V[aJ)\x90\x84aH\xF6V[aJ\x12V[aI\xEBV[PPP\x91PaJIaJD_a,\xC2V[a:1V[\x91\x90V[P\x82aJaaJ[\x86a\x05TV[\x91a\x05TV[\x10\x15aI\x85V[P\x83aJ|aJv_a,\xC2V[\x91a\x05TV[\x14aI~V[aJ\x93\x90aJ\x8Ead\x96V[aJ\x95V[V[aJ\xA0\x90`\na&\x9AV[V[aJ\xAB\x90aJ\x82V[V[_\x90V[aJ\xB9aJ\xADV[PaJ\xC3_a%\xBDV[\x90V[P\x90V[\x91\x90\x81\x10\x15aJ\xDAW` \x02\x01\x90V[a\x07~V[5aJ\xE9\x81a\x03\xFBV[\x90V[_\x80\xFD[`\xE0\x1B\x90V[_\x91\x03\x12aK\0WV[a\x03\xACV[\x91` aK&\x92\x94\x93aK\x1F`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x0C\xBCV[V[aK0a\x03\xA2V[=_\x82>=\x90\xFD[\x90\x92\x91\x92aKE_a,\xC2V[[\x80aKcaK]aKX\x85\x89\x90aJ\xC6V[a\x05TV[\x91a\x05TV[\x10\x15aL\x12WaKr0a<\x85V[\x90c\xBA\x1F\xB1\x03\x84aK\x8DaK\x88\x86\x8A\x86\x91aJ\xCAV[aJ\xDFV[\x93\x80;\x15aL\rWaK\xB2_\x80\x94aK\xBDaK\xA6a\x03\xA2V[\x98\x89\x96\x87\x95\x86\x94aJ\xF0V[\x84R`\x04\x84\x01aK\x05V[\x03\x92Z\xF1\x91\x82\x15aL\x08WaK\xD7\x92aK\xDCW[Pa,\xDEV[aKFV[aK\xFB\x90_=\x81\x11aL\x01W[aK\xF3\x81\x83a\x08\xD7V[\x81\x01\x90aJ\xF6V[_aK\xD1V[P=aK\xE9V[aK(V[aJ\xECV[PPP\x90PV[_\x7FNot slashing oracle\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aLM`\x13` \x92a\t\xD5V[aLV\x81aL\x19V[\x01\x90V[aLo\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaL@V[\x90V[\x15aLyWV[aL\x81a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aL\x97`\x04\x82\x01aLZV[\x03\x90\xFD[_\x7FOperator unknown\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aL\xCF`\x10` \x92a\t\xD5V[aL\xD8\x81aL\x9BV[\x01\x90V[aL\xF1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaL\xC2V[\x90V[\x15aL\xFBWV[aM\x03a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aM\x19`\x04\x82\x01aL\xDCV[\x03\x90\xFD[\x90V[\x90aM3g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90aMUaMPaM\\\x92a\x07LV[aM=V[\x82TaM V[\x90UV[\x91\x90aMz\x81aMs\x81aM\x7F\x95a\t\xD5V[\x80\x95a\x17\x1DV[a\x08\xB9V[\x01\x90V[\x90\x91aM\x9A\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaM`V[\x90V[aM\xC23aM\xBCaM\xB6aM\xB1`\na%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14aLrV[aM\xE8aM\xE3aM\xDCaM\xD7`\x05\x85\x90a34V[a3JV[\x84\x90ad\xE4V[aL\xF4V[aN\x14aN\taN\x04aM\xFD`\x03\x85\x90a\x0F\xC8V[\x85\x90a\x10\x12V[aM\x1DV[`\x01`\x03\x91\x01a3\x81V[aN2aN+aN&`\x04\x84\x90a34V[a3JV[\x83\x90am\x16V[PaNZaN?Ba5\x97V[aNUaNN`\x0C\x85\x90aG\xD8V[\x85\x90aG\xEEV[aM@V[\x90\x91\x92aN\x90aN\x8A\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07LV[\x93a\x10\x06V[\x93aN\xA5aN\x9Ca\x03\xA2V[\x92\x83\x92\x83aM\x83V[\x03\x90\xA3V[aN\xB4`\x80a\x16\xBCV[\x90V[aN\xC2\x916\x91a\x17(V[\x90V[RV[\x90aN\xD2\x90a\x04\xC2V[\x90RV[Q\x90V[\x90aN\xE4\x81a\t\xD1V[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11aO\xA4WaO\x08\x82aO\x02\x85Ta\x07\xE4V[\x85a.\xCFV[` \x90`\x1F\x83\x11`\x01\x14aO<W\x91\x80\x91aO+\x93_\x92aO0W[PPa*\x07V[\x90U[V[\x90\x91P\x01Q_\x80aO$V[`\x1F\x19\x83\x16\x91aOK\x85a\x08\x17V[\x92_[\x81\x81\x10aO\x8CWP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10aOrW[PPP\x02\x01\x90UaO.V[aO\x82\x91\x01Q`\x1F\x84\x16\x90a)\xF2V[\x90U_\x80\x80aOfV[\x91\x93` `\x01\x81\x92\x87\x87\x01Q\x81U\x01\x95\x01\x92\x01aONV[a\x08\xC3V[\x90aO\xB3\x91aN\xDAV[V[aO\xBF\x90Qa\x04\xC2V[\x90V[\x90aP\x1F```\x03aP%\x94aO\xE5_\x82\x01aO\xDF_\x88\x01aN\xD6V[\x90aO\xA9V[aO\xFE`\x01\x82\x01aO\xF8` \x88\x01a>\xADV[\x90a0\x18V[aP\x17`\x02\x82\x01aP\x11`@\x88\x01a>\xADV[\x90a0\x18V[\x01\x92\x01aO\xB5V[\x90a0jV[V[\x91\x90aP8WaP6\x91aO\xC2V[V[a+\xA3V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15aPmW\x82aPe\x91`\x01aPk\x95\x01\x81Ua.\xA3V[\x90aP'V[V[a\x08\xC3V[aQ\x90\x95aQy\x84\x96aQpaQhaQTaQOaQ\x82\x97aP\xF5aP\xD5aP\xCFaQ\x8B\x9D\x8D\x9F\x9DaP\xCA3aP\xC4aP\xBEaP\xB9aP\xB4`\x07\x8C\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[a-{V[\x90a-~V[aP\xEEaP\xE8aP\xE3a\x19!V[a\x05TV[\x91a\x05TV[\x11\x15a-\xDBV[aQ\x12\x86aQ\x0BaQ\x05\x8Da\x05TV[\x91a\x05TV[\x10\x15a.jV[aQHaQ)aQ$`\x08\x84\x90a\x07hV[a\x07\x92V[aQBaQ<aQ7a\x15mV[a\x05TV[\x91a\x05TV[\x10a(\xBBV[`\x08a\x07hV[a.\x93V[\x98\x99\x96\x92\x94\x96aQbaN\xAAV[\x9AaN\xB7V[_\x8A\x01aN\xC5V[` \x88\x01aF\xE7V[`@\x86\x01aF\xE7V[``\x84\x01aN\xC8V[aP=V[V[aQ\xC0\x90aQ\xBBaQ\xB6aQ\xAFaQ\xAA\x84`\x06a34V[a3JV[3\x90ad\xE4V[a5\x1BV[aR\xA1V[V[_\x7FCannot go online while slashed\0\0\x91\x01RV[aQ\xF6`\x1E` \x92a\t\xD5V[aQ\xFF\x81aQ\xC2V[\x01\x90V[aR\x18\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaQ\xE9V[\x90V[`@\x1B\x90V[\x90aR5h\xFF\0\0\0\0\0\0\0\0\x91aR\x1BV[\x91\x81\x19\x16\x91\x16\x17\x90V[aRSaRNaRX\x92a\x04\xAFV[a\x07IV[a\x04\xAFV[\x90V[\x90V[\x90aRsaRnaRz\x92aR?V[aR[V[\x82TaR!V[\x90UV[\x91` aR\x9F\x92\x94\x93aR\x98`@\x82\x01\x96_\x83\x01\x90a\x11qV[\x01\x90a\x11qV[V[aR\xBFaR\xBAaR\xB3`\x03\x84\x90a\x0F\xC8V[3\x90a\x10\x12V[aM\x1DV[\x90aR\xCC`\x01\x83\x01a\x10\xA3V[\x91\x82aR\xE1aR\xDB`\x03a\x11YV[\x91a\x11YV[\x14aT\x05W\x82aR\xF9aR\xF3_a\x11YV[\x91a\x11YV[\x14\x80\x15aS\xEAW[aS\xE5WaS(\x90aS\x16`\x01\x80\x83\x01a3\x81V[`\x01aS!_aH\xB1V[\x91\x01aR^V[aSFaS?aS:`\x04\x84\x90a34V[a3JV[3\x90ad\\V[P\x803aS|aSv\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07LV[\x91a\x10\x06V[\x91aS\x85a\x03\xA2V[\x80aS\x8F\x81a\x04KV[\x03\x90\xA3\x903\x90\x91`\x01aS\xCBaS\xC5\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93aS\xE0aS\xD7a\x03\xA2V[\x92\x83\x92\x83aR~V[\x03\x90\xA3V[PPPV[P\x82aS\xFFaS\xF9`\x01a\x11YV[\x91a\x11YV[\x14aS\x01V[aT\ra\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aT#`\x04\x82\x01aR\x03V[\x03\x90\xFD[aT0\x90aQ\x92V[V[_\x7FNot authorized\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aTf`\x0E` \x92a\t\xD5V[aTo\x81aT2V[\x01\x90V[aT\x88\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaTYV[\x90V[\x15aT\x92WV[aT\x9Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aT\xB0`\x04\x82\x01aTsV[\x03\x90\xFD[\x90V[aT\xCBaT\xC6aT\xD0\x92aT\xB4V[a\x07IV[a\x03\xB4V[\x90V[_\x7FInterval too short\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\x07`\x12` \x92a\t\xD5V[aU\x10\x81aT\xD3V[\x01\x90V[aU)\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaT\xFAV[\x90V[\x15aU3WV[aU;a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aUQ`\x04\x82\x01aU\x14V[\x03\x90\xFD[\x90V[aUlaUgaUq\x92aUUV[a\x07IV[a\x04\xAFV[\x90V[_\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\xA8`\x17` \x92a\t\xD5V[aU\xB1\x81aUtV[\x01\x90V[aU\xCA\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaU\x9BV[\x90V[\x15aU\xD4WV[aU\xDCa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aU\xF2`\x04\x82\x01aU\xB5V[\x03\x90\xFD[aV\0``a\x16\xBCV[\x90V[\x90aV\x18aV\x13aV\x1F\x92a0[V[a0gV[\x82Ta3SV[\x90UV[\x90aVe`@_aVk\x94aVE\x82\x82\x01aV?\x84\x88\x01aH\xCDV[\x90aM@V[aV]\x82\x82\x01aVW` \x88\x01aH\xA4V[\x90aR^V[\x01\x92\x01aO\xB5V[\x90aV\x03V[V[\x90aVw\x91aV#V[V[\x91` aV\x9A\x92\x94\x93aV\x93`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x11)V[V[3aV\xCFaV\xC9\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14\x80\x15aW\xBBW[aV\xE0\x90aT\x8BV[aV\xFE\x82aV\xF7aV\xF1`<aT\xB7V[\x91a\x03\xB4V[\x10\x15aU,V[aW\x1C\x83aW\x15aW\x0F`\x01aUXV[\x91a\x04\xAFV[\x10\x15aU\xCDV[aWu\x82aWd\x85aW[aW=_aW7`\x02\x89\x90a\"\x87V[\x01a\"\xB1V[\x91aWRaWIaU\xF6V[\x95_\x87\x01aF\xF5V[` \x85\x01aG\x03V[`@\x83\x01aN\xC8V[aWp`\x02\x84\x90a\"\x87V[aVmV[\x90\x91aW\xA1\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x92a\x07LV[\x92aW\xB6aW\xADa\x03\xA2V[\x92\x83\x92\x83aVyV[\x03\x90\xA2V[PaV\xE03aW\xE5aW\xDFaW\xDAaW\xD5`\x07\x87\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x90PaV\xD7V[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[aX\raX\x13\x91a\x05TV[\x91a\x05TV[\x90\x81\x15aX\x1EW\x04\x90V[aW\xEDV[aX7aX2aX<\x92a\x05TV[a\x07IV[a\x04\xAFV[\x90V[aXSaXNaXX\x92a%\xCAV[a\x07IV[a\x03\xB4V[\x90V[aXyaXtaXm`\x03\x84\x90a\x0F\xC8V[\x84\x90a\x10\x12V[aM\x1DV[\x90aX\x83\x81ac~V[aX\x8F`\x01\x84\x01a\x10\xA3V[aX\xA2aX\x9C`\x03a\x11YV[\x91a\x11YV[\x14aZ\xB6WaX\xB2_\x84\x01a\t>V[aX\xC4aX\xBE_a,\xC2V[\x91a\x05TV[\x14aZ\xB0WaX\xFAaX\xE1BaX\xDB_\x87\x01a\t>V[\x90a5\xD6V[aX\xF4aX\xEF_\x85\x01aH\xCDV[a5{V[\x90aX\x01V[\x80aY\x0EaY\x08`\xFFaH\xDAV[\x91a\x05TV[\x11_\x14aZ\xA2WP`\xFF[\x90\x81aY8aY2aY-`\x01\x88\x01a\x10vV[a\x04\xAFV[\x91a\x04\xAFV[\x11aYEW[PPPPPV[aYR\x82`\x01\x86\x01aR^V[aYgaY^_aX?V[`\x01\x86\x01aM@V[aY\x85aY\x7FaYz` \x85\x94\x01aH\xA4V[a\x04\xAFV[\x91a\x04\xAFV[\x10\x15\x80aZ{W[aY\x98W[\x80aY>V[aY\xB3aY\xA7`\x01\x85\x01a\x10\xA3V[\x93`\x01`\x02\x91\x01a3\x81V[aY\xD1aY\xCAaY\xC5`\x04\x85\x90a34V[a3JV[\x85\x90am\x16V[P\x81\x90\x84\x90\x91aZ\x1FaZ\raZ\x07\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM\x93a\x07LV[\x93a\x10\x06V[\x93aZ\x16a\x03\xA2V[\x91\x82\x91\x82a\x16'V[\x03\x90\xA3\x91\x90\x91`\x02aZZaZT\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93aZoaZfa\x03\xA2V[\x92\x83\x92\x83aR~V[\x03\x90\xA3_\x80\x80\x80aY\x92V[PaZ\x88`\x01\x84\x01a\x10\xA3V[aZ\x9BaZ\x95`\x02a\x11YV[\x91a\x11YV[\x14\x15aY\x8DV[aZ\xAB\x90aX#V[aY\x19V[PPPPV[PPPPV[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11aZ\xD9W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90aZ\xF0aZ\xEB\x83aZ\xC1V[a\x16\xBCV[\x91\x82RV[aZ\xFF`\x80a\x16\xBCV[\x90V[\x90a[ia[``\x03a[\x13aZ\xF5V[\x94a[*a[\"_\x83\x01a\t\0V[_\x88\x01aN\xC5V[a[Ba[9`\x01\x83\x01a\t>V[` \x88\x01aF\xE7V[a[Za[Q`\x02\x83\x01a\t>V[`@\x88\x01aF\xE7V[\x01a\teV[``\x84\x01aN\xC8V[V[a[t\x90a[\x02V[\x90V[\x90a[\x81\x82a\x07\x92V[a[\x8A\x81aZ\xDEV[\x92a[\x98` \x85\x01\x91a\x07\x96V[_\x91[\x83\x83\x10a[\xA8WPPPPV[`\x04` `\x01\x92a[\xB8\x85a[kV[\x81R\x01\x92\x01\x92\x01\x91\x90a[\x9BV[a[\xCF\x90a[wV[\x90V[a[\xE9a[\xEE\x91a[\xE1aZ\xBCV[P`\x08a\x07hV[a[\xC6V[\x90V[a\\\x1F\x90a\\\x1Aa\\\x15a\\\x0Ea\\\t\x84`\x06a34V[a3JV[3\x90ad\xE4V[a5\x1BV[a\\zV[V[_\x7FCannot go offline while slashed\0\x91\x01RV[a\\U`\x1F` \x92a\t\xD5V[a\\^\x81a\\!V[\x01\x90V[a\\w\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra\\HV[\x90V[a\\\x98a\\\x93a\\\x8C`\x03\x84\x90a\x0F\xC8V[3\x90a\x10\x12V[aM\x1DV[\x90a\\\xA5`\x01\x83\x01a\x10\xA3V[\x91\x82a\\\xBAa\\\xB4`\x03a\x11YV[\x91a\x11YV[\x14a]@Wa\\\xCE\x90`\x01`\x04\x91\x01a3\x81V[a\\\xECa\\\xE5a\\\xE0`\x04\x84\x90a34V[a3JV[3\x90am\x16V[P\x903\x90\x91`\x04a]&a] \x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93a];a]2a\x03\xA2V[\x92\x83\x92\x83aR~V[\x03\x90\xA3V[a]Ha\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a]^`\x04\x82\x01a\\bV[\x03\x90\xFD[a]k\x90a[\xF1V[V[\x90\x91\x82a]}\x81a]\x84\x93a\x1D3V[\x80\x93a\x17\x1DV[\x01\x90V[a]\x99\x90` \x94\x93a]\xA0\x93a]mV[\x80\x92a\x1DdV[\x01\x90V[\x90\x91a]\xBB\x90a]\xB2a\x03\xA2V[\x93\x84\x93\x84a]\x88V[\x03\x90 \x90V[\x90\x91a]\xCC\x92a]\xA4V[\x90V[\x92a]\xF4a]\xFC\x93\x92a]\xEFa^\x01\x96a]\xE7a'\xAEV[P`\ta\x1D\x07V[a\x1D\x1DV[\x91\x90\x91a]\xC1V[a\t>V[\x90V[a^\x0CaJ\xADV[Pa^\x17`\x01a%\xBDV[\x90V[a^$\x90Qa\x11YV[\x90V[\x90V[a^>a^9a^C\x92a^'V[a\x07IV[a\x05TV[\x90V[` \x7Fl\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x7FOperator not eligible for remova_\x82\x01R\x01RV[a^\xA0`!`@\x92a\t\xD5V[a^\xA9\x81a^FV[\x01\x90V[a^\xC2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra^\x93V[\x90V[\x15a^\xCCWV[a^\xD4a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a^\xEA`\x04\x82\x01a^\xADV[\x03\x90\xFD[\x90a_\x9Fa_\x9Aa_\xA4\x933a_\x1Fa_\x19a_\x14a_\x0F`\x07\x86\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x80\x15a`]W[a_0\x90aT\x8BV[a_Na_Ia_B`\x03\x84\x90a\x0F\xC8V[\x86\x90a\x10\x12V[aG\xA0V[a_Z``\x82\x01a^\x1AV[a_ma_g`\x03a\x11YV[\x91a\x11YV[\x03a_\xA7W[Pa_\x92a_\x8Ba_\x86`\x05\x84\x90a34V[a3JV[\x85\x90am\x16V[P`\x04a34V[a3JV[am\x16V[PV[a`#\x90a_\xF7a_\xE7a_\xBA\x85ac~V[a_\xE1a_\xDC` a_\xD5a_\xD0_\x86\x01aH\xCDV[a5{V[\x93\x01aH\xA4V[aH\xDAV[\x90a(\xF8V[a_\xF1`\na^*V[\x90a(\xF8V[a`\x02_\x83\x01a>\xADV[a`\x14a`\x0E_a,\xC2V[\x91a\x05TV[\x11\x91\x82a`)W[PPa^\xC5V[_a_sV[a`T\x91\x92Pa`Ha`N\x91a`B_B\x92\x01a>\xADV[\x90a5\xD6V[\x92a\x05TV[\x91a\x05TV[\x10\x15_\x80a`\x1CV[Pa_03a`{a`ua`paJ\xB1V[a\x03\xEFV[\x91a\x03\xEFV[\x14\x90Pa_'V[\x90a`\xADa`\xB2\x91a`\x93a;\"V[Pa`\xA8a`\xA0\x85ac~V[\x94`\x03a\x0F\xC8V[a\x10\x12V[aG\xA0V[a`\xBD_\x82\x01a>\xADV[a`\xCFa`\xC9_a,\xC2V[\x91a\x05TV[\x14aa\nWaa\0a`\xFB_a`\xF4aa\x06\x94a`\xEE\x83B\x92\x01a>\xADV[\x90a5\xD6V[\x94\x01aH\xCDV[a5{V[\x91a\x05TV[\x10\x90V[PP_\x90V[aa!\x90aa\x1Cad\x96V[aa#V[V[aa.\x81`\x01a&\x9AV[aa6aJ\xB1V[\x90aajaad\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0\x93a\x10\x06V[\x91a\x10\x06V[\x91aasa\x03\xA2V[\x80aa}\x81a\x04KV[\x03\x90\xA3V[aa\x8B\x90aa\x10V[V[_aa\xCCaa\xD2\x93aa\xC43aa\xBEaa\xB8aa\xB3aa\xAE`\x07\x8A\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[\x92`\x02a\"\x87V[\x01aV\x03V[V[_\x7FNot registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[ab\x08`\x0E` \x92a\t\xD5V[ab\x11\x81aa\xD4V[\x01\x90V[ab*\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Raa\xFBV[\x90V[\x15ab4WV[ab<a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80abR`\x04\x82\x01ab\x15V[\x03\x90\xFD[ab\x923ab\x8Cab\x86\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[ab\xB8ab\xB3ab\xACab\xA7`\x06\x85\x90a34V[a3JV[\x84\x90am\x16V[ab-V[ab\xD6ab\xCFab\xCA`\x04\x84\x90a34V[a3JV[\x83\x90am\x16V[P\x90ac\x0Bac\x05\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E\x93a\x07LV[\x91a\x10\x06V[\x91ac\x14a\x03\xA2V[\x80ac\x1E\x81a\x04KV[\x03\x90\xA3V[\x90acpacg_ac3a'CV[\x94acJacB\x83\x83\x01a\x10IV[\x83\x88\x01aF\xF5V[acaacX\x83\x83\x01a\x10vV[` \x88\x01aG\x03V[\x01a\"\xB1V[`@\x84\x01aN\xC8V[V[ac{\x90ac#V[\x90V[ac\x95ac\x9A\x91ac\x8Da'\x8EV[P`\x02a\"\x87V[acrV[ac\xA5_\x82\x01aH\xCDV[ac\xB7ac\xB1_aX?V[\x91a\x03\xB4V[\x14ac\xFDW[ac\xC9` \x82\x01aH\xA4V[ac\xDBac\xD5_aH\xB1V[\x91a\x04\xAFV[\x14ac\xE4W[\x90V[ac\xF8ac\xEFa\x16\x0FV[` \x83\x01aG\x03V[ac\xE1V[ad\x10ad\x08a\x0C\x08V[_\x83\x01aF\xF5V[ac\xBDV[ad\x1E\x90a\x0F\xDEV[\x90V[ad5ad0ad:\x92a\x03\xE4V[a\x07IV[a\x05TV[\x90V[adQadLadV\x92a\x05TV[a&wV[a\x0F\x01V[\x90V[\x90V[\x90ad\x8Ead\x88ad\x83ad~_ad\x93\x96adva;\"V[P\x01\x94ad\x15V[ad!V[ad=V[\x91adYV[am\xF9V[\x90V[ad\x9EaJ\xB1V[ad\xB7ad\xB1ad\xACak\xC4V[a\x03\xEFV[\x91a\x03\xEFV[\x03ad\xBEWV[ad\xE0ad\xC9ak\xC4V[_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xC9V[\x03\x90\xFD[\x90ae\x16ae\x10ae\x0Bae\x06_ae\x1B\x96ad\xFEa;\"V[P\x01\x94ad\x15V[ad!V[ad=V[\x91adYV[an\\V[\x90V[ae=\x91ae4\x91ae.aJ\xADV[Pan\xBCV[\x90\x92\x91\x92ao|V[\x90V[_\x7FOperator is slashed\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aet`\x13` \x92a\t\xD5V[ae}\x81ae@V[\x01\x90V[ae\x96\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaegV[\x90V[\x15ae\xA0WV[ae\xA8a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80ae\xBE`\x04\x82\x01ae\x81V[\x03\x90\xFD[ae\xCB\x90a\x0F\x01V[\x90V[ae\xD7\x90a\t\"V[\x90V[\x90ae\xEFae\xEAae\xF6\x92ae\xC2V[ae\xCEV[\x82Ta0\x02V[\x90UV[af\x03\x90a\x03\xB4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x14af\x18W`\x01\x01\x90V[a(\xE4V[\x90V[af4af/af9\x92af\x1DV[a\x07IV[a\x04\xAFV[\x90V[\x91` af]\x92\x94\x93afV`@\x82\x01\x96_\x83\x01\x90a\x11)V[\x01\x90a\x05WV[V[afh\x90a\x0F\xDEV[\x90V[aft\x90af_V[\x90V[af\x80\x90a\x0F\xFAV[\x90V[`@\x90af\xACaf\xB3\x94\x96\x95\x93\x96af\xA2``\x84\x01\x98_\x85\x01\x90a\x0C\xBCV[` \x83\x01\x90a\x0C!V[\x01\x90a\x0C!V[V[\x94\x92\x93\x91\x93af\xD8af\xD3af\xCC`\x03\x89\x90a\x0F\xC8V[\x87\x90a\x10\x12V[aM\x1DV[\x93af\xE2\x87ac~V[\x93ag\x0Caf\xF2`\x01\x88\x01a\x10\xA3V[ag\x05af\xFF`\x03a\x11YV[\x91a\x11YV[\x14\x15ae\x99V[ag*ag#ag\x1E`\x05\x8B\x90a34V[a3JV[\x88\x90ad\\V[Pag\xFF`@ag<`\x01\x89\x01a\x10\xA3V[\x96agIB_\x8B\x01a0\x18V[agsagW\x85\x87\x90a6TV[agiagc\x82a6hV[\x91a6bV[ `\x02\x8B\x01ae\xDAV[ag\x88ag\x7F_aH\xB1V[`\x01\x8B\x01aR^V[ag\xA6`\x01\x8A\x01ag\xA0ag\x9B\x82a\x10IV[ae\xFAV[\x90aM@V[ag\xAEa<VV[P\x85ag\xC2ag\xBC_aH\xB1V[\x91a\x04\xAFV[\x14_\x14aj\x83Wag\xD9_\x99[`\x01\x8B\x91\x01a3\x81V[\x87ag\xEDag\xE7`\x02a\x11YV[\x91a\x11YV[\x14\x80ajgW[ai\xF9W[\x01aO\xB5V[\x80ai\xD5W[ai\xBFW[PP\x85\x91\x85\x91\x92BahNahHahB\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x94a\x07LV[\x94a\x07LV[\x94a\x10\x06V[\x94ahcahZa\x03\xA2V[\x92\x83\x92\x83af<V[\x03\x90\xA4\x80ahyahs\x84a\x11YV[\x91a\x11YV[\x03aiiW[PPah\x8B`\x0Ba%\xBDV[ah\xA5ah\x9Fah\x9A_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x03ah\xAFW[PPV[ah\xC9ah\xC4ah\xBF`\x0Ba%\xBDV[afkV[afwV[\x91c\xD4xS\xB6\x91\x90\x92ah\xDBBa5\x97V[\x92\x81;\x15aidW_ai\x01\x91ai\x0C\x82\x96ah\xF5a\x03\xA2V[\x98\x89\x97\x88\x96\x87\x95aJ\xF0V[\x85R`\x04\x85\x01af\x83V[\x03\x92Z\xF1\x90\x81ai8W[P\x15_\x14ai3W`\x01ai.W[[_\x80ah\xABV[ai&V[ai'V[aiW\x90_=\x81\x11ai]W[aiO\x81\x83a\x08\xD7V[\x81\x01\x90aJ\xF6V[_ai\x17V[P=aiEV[aJ\xECV[\x83\x83\x91\x92ai\xA0ai\x9A\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93ai\xB5ai\xACa\x03\xA2V[\x92\x83\x92\x83aR~V[\x03\x90\xA3_\x80ah\x7FV[ai\xCE\x91\x88\x91\x88\x90\x91\x92at9V[_\x80ah\nV[Pai\xE1\x81\x83\x90a-~V[ai\xF3ai\xED_a,\xC2V[\x91a\x05TV[\x11ah\x05V[aj\x16aj\x0Faj\n\x8D`\x04a34V[a3JV[\x8B\x90ad\\V[P\x8A\x8AajLajF\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07LV[\x91a\x10\x06V[\x91ajUa\x03\xA2V[\x80aj_\x81a\x04KV[\x03\x90\xA3ag\xF9V[P\x88aj|ajv`\x02a\x11YV[\x91a\x11YV[\x14\x15ag\xF4V[\x85aj\x97aj\x91`daf V[\x91a\x04\xAFV[\x10_\x14aj\xAAWag\xD9`\x01\x99[ag\xCFV[ag\xD9`\x01\x99aj\xC2\x8D\x8D\x8B\x90\x8B\x90\x8A\x92\x8C\x94ap\xEDV[aj\xA5V[aj\xDE_aj\xE3\x92aj\xD7a'\xAEV[P\x01adYV[au\xF7V[\x90V[aj\xF2aj\xF7\x91a\t\"V[a)~V[\x90V[ak\x0Eak\tak\x13\x92a\x05TV[a\x07IV[a\x03\xE4V[\x90V[akAak<akK\x93ak7_akF\x95ak0aJ\xADV[P\x01adYV[aveV[aj\xE6V[aj\xFAV[a\x0F\xFAV[\x90V[\x91\x90`\x08akn\x91\x02\x91akh`\x01\x80`\xA0\x1B\x03\x84a)UV[\x92a)UV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x91\x90ak\x8Eak\x89ak\x96\x93a\x10\x06V[a&\x97V[\x90\x83TakNV[\x90UV[ak\xAC\x91ak\xA6aJ\xADV[\x91akxV[V[ak\xC2\x90ak\xBD_`\x01ak\x9AV[av\x86V[V[ak\xCCaJ\xADV[P3\x90V[ak\xDA\x90a\x05TV[_\x19\x81\x14ak\xE8W`\x01\x01\x90V[a(\xE4V[ak\xF7\x90Qa\x03\xEFV[\x90V[\x93\x91\x92\x93al\x06a9\xF3V[Pal\x1Aal\x15\x85\x84\x90a5\xD6V[a:1V[\x92al$_a,\xC2V[\x92[\x80al9al3\x88a\x05TV[\x91a\x05TV[\x10\x15al\xA7Wal]alValQ`\x05\x86\x90a34V[a3JV[\x82\x90ak\x16V[ali\x84\x82\x8A\x91av\xE5V[al}W[Palx\x90a,\xDEV[al&V[alx\x91\x94al\x9Bal\xA0\x92al\x96\x89\x91\x84\x90\x92a:XV[a:xV[ak\xD1V[\x93\x90alnV[P\x94PP\x91Pal\xB6\x82a:1V[\x92al\xC0_a,\xC2V[[\x80al\xD4al\xCE\x86a\x05TV[\x91a\x05TV[\x10\x15am\x10Wam\x0B\x90am\x06al\xF4al\xEF\x86\x84\x90a:XV[ak\xEDV[am\x01\x88\x91\x84\x90\x92a:XV[a:xV[a,\xDEV[al\xC1V[P\x91PPV[\x90amHamBam=am8_amM\x96am0a;\"V[P\x01\x94ad\x15V[ad!V[ad=V[\x91adYV[ax1V[\x90V[\x90V[_R` _ \x90V[T\x90V[ami\x81am\\V[\x82\x10\x15am\x83Wam{`\x01\x91amSV[\x91\x02\x01\x90_\x90V[a\x07~V[\x91\x90am\x9Eam\x99am\xA6\x93ae\xC2V[ae\xCEV[\x90\x83Ta)YV[\x90UV[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15am\xDAW\x82am\xD2\x91`\x01am\xD8\x95\x01\x81Uam`V[\x90am\x88V[V[a\x08\xC3V[T\x90V[\x90am\xED\x90ae\xC2V[_R` R`@_ \x90V[an\x01a;\"V[Pan\x16an\x10\x82\x84\x90an\\V[\x15a\x04\xC2V[_\x14anVWanLanQ\x92an8an1_\x85\x01amPV[\x82\x90am\xAAV[`\x01anE_\x85\x01am\xDFV[\x93\x01am\xE3V[a0\x18V[`\x01\x90V[PP_\x90V[anz\x91`\x01anu\x92anna;\"V[P\x01am\xE3V[a\t>V[an\x8Can\x86_a,\xC2V[\x91a\x05TV[\x14\x15\x90V[_\x90V[_\x90V[\x90V[an\xB0an\xABan\xB5\x92an\x99V[a\x07IV[a\x05TV[\x90V[_\x90V[\x91\x90\x91an\xC7aJ\xADV[Pan\xD0an\x91V[Pan\xD9an\x95V[Pan\xE3\x83a6hV[an\xF6an\xF0`Aan\x9CV[\x91a\x05TV[\x14_\x14ao=Wao6\x91\x92ao\nan\x95V[Pao\x13an\x95V[Pao\x1Can\xB8V[P` \x81\x01Q```@\x83\x01Q\x92\x01Q_\x1A\x90\x91\x92ay\xB0V[\x91\x92\x90\x91\x90V[PaoG_a%\xE9V[\x90ao[aoV`\x02\x94a6hV[ad=V[\x91\x92\x91\x90V[`\x04\x11\x15aokWV[a\x116V[\x90aoz\x82aoaV[V[\x80ao\x8Fao\x89_aopV[\x91aopV[\x14_\x14ao\x9AWPPV[\x80ao\xAEao\xA8`\x01aopV[\x91aopV[\x14_\x14ao\xD1W_c\xF6E\xEE\xDF`\xE0\x1B\x81R\x80ao\xCD`\x04\x82\x01a\x04KV[\x03\x90\xFD[\x80ao\xE5ao\xDF`\x02aopV[\x91aopV[\x14_\x14ap\x13Wap\x0Fao\xF8\x83aj\xE6V[_\x91\x82\x91c\xFC\xE6\x98\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x05dV[\x03\x90\xFD[ap&ap `\x03aopV[\x91aopV[\x14ap.WPV[apI\x90_\x91\x82\x91c5\xE2\xF3\x83`\xE2\x1B\x83R`\x04\x83\x01a\x0F\x11V[\x03\x90\xFD[apaap\\apf\x92a\x13\x0EV[a\x07IV[a\x04\xAFV[\x90V[apuap{\x91a\x03\xB4V[\x91a\x03\xB4V[\x90\x03\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11ap\x8FWV[a(\xE4V[_\x7FProtocol violation reported\0\0\0\0\0\x91\x01RV[ap\xC8`\x1B` \x92a\t\xD5V[ap\xD1\x81ap\x94V[\x01\x90V[ap\xEA\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rap\xBBV[\x90V[\x93PP\x92Paq\x05ap\xFF`\xC8apMV[\x91a\x04\xAFV[\x10\x15aq\x10W[PPV[aq\x19Ba5\x97V[aq7aq2aq+`\x0C\x85\x90aG\xD8V[\x85\x90aG\xEEV[a\x10IV[\x80aqJaqD_aX?V[\x91a\x03\xB4V[\x14\x90\x81\x15aq\xD0W[Paq_W[Paq\x0CV[aq~\x90aqyaqr`\x0C\x85\x90aG\xD8V[\x85\x90aG\xEEV[aM@V[\x90aq\xB2aq\xAC\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07LV[\x91a\x10\x06V[\x91aq\xBBa\x03\xA2V[\x80aq\xC5\x81ap\xD5V[\x03\x90\xA3_\x80\x80aqYV[aq\xDB\x91P\x82apiV[aq\xF4aq\xEEaq\xE9a\x0FzV[a\x03\xB4V[\x91a\x03\xB4V[\x10\x15_aqSV[\x90V[ar\x13ar\x0Ear\x18\x92aq\xFCV[a\x07IV[a\x05TV[\x90V[\x90\x92\x91\x92ar0ar+\x82a\x16\xFAV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11arLWarJ\x92a\t\xDEV[V[a\x16\xF6V[\x90\x80`\x1F\x83\x01\x12\x15aroW\x81` arl\x93Q\x91\x01ar\x1BV[\x90V[a\x05\xAFV[\x90PQ\x90ar\x81\x82a\x06\xF9V[V[\x91\x90\x91`@\x81\x84\x03\x12ar\xD6War\x9A`@a\x16\xBCV[\x92_\x82\x01Q\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11ar\xD1War\xBE\x82ar\xCA\x94\x83\x01arQV[_\x86\x01R` \x01artV[` \x83\x01RV[a\x16\xF2V[a\x16\xEEV[\x92\x91\x90ar\xEFar\xEA\x82a\x16\xD1V[a\x16\xBCV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11asFW\x81\x90[\x83\x82\x10as\x15WPPPPPV[\x81Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11asAW` \x91as6\x87\x84\x93\x87\x01ar\x83V[\x81R\x01\x91\x01\x90as\x07V[a\x05\xAFV[a\x05\xB7V[\x90\x80`\x1F\x83\x01\x12\x15asiW\x81` asf\x93Q\x91\x01ar\xDBV[\x90V[a\x05\xAFV[\x90` \x82\x82\x03\x12as\x9EW_\x82\x01Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11as\x99Was\x96\x92\x01asKV[\x90V[a\x03\xB0V[a\x03\xACV[` \x91\x81R\x01\x90V[\x91\x90as\xC6\x81as\xBF\x81as\xCB\x95as\xA3V[\x80\x95a\x17\x1DV[a\x08\xB9V[\x01\x90V[\x90\x91as\xE6\x92` \x83\x01\x92_\x81\x85\x03\x91\x01Ras\xACV[\x90V[as\xF3`2a\x15QV[\x90V[\x94\x93\x91``\x91at7\x94at\"at/\x93at\x18`\x80\x8B\x01\x94_\x8C\x01\x90a\x0C!V[` \x8A\x01\x90a\x0C\xBCV[\x87\x82\x03`@\x89\x01Ra\x0E(V[\x94\x01\x90a\x05WV[V[\x91atE\x81\x85\x90a-~V[atWatQ_a,\xC2V[\x91a\x05TV[\x14au\xF1Watg\x81\x85\x90a-~V[at{atua\xC3Paq\xFFV[\x91a\x05TV[\x11au\xEBW_at\x89a9xV[\x94at\x930a<\x85V[at\xB5c1\xE3\xBD\x1B\x94\x92\x94at\xC0at\xA9a\x03\xA2V[\x96\x87\x95\x86\x94\x85\x94aJ\xF0V[\x84R`\x04\x84\x01as\xCFV[\x03\x91Z\xFA\x80\x91_\x92au\xC7W[P\x15_\x14au\xBEWP`\x01au\xB9W[at\xE6\x83a\r\x97V[at\xFFat\xF9at\xF4as\xE9V[a\x05TV[\x91a\x05TV[\x11_\x14au\xABWau\x0Eas\xE9V[[au\x180a<\x85V[\x90ce\xA6\x93n\x93\x92\x94\x90\x82;\x15au\xA6W_\x94auS\x86\x92auH\x94au<a\x03\xA2V[\x99\x8A\x98\x89\x97\x88\x96aJ\xF0V[\x86R`\x04\x86\x01as\xF6V[\x03\x92Z\xF1\x90\x81auzW[P\x15_\x14auuW`\x01aupW[[V[aumV[aunV[au\x99\x90_=\x81\x11au\x9FW[au\x91\x81\x83a\x08\xD7V[\x81\x01\x90aJ\xF6V[_au^V[P=au\x87V[aJ\xECV[au\xB4\x83a\r\x97V[au\x0FV[PPPV[\x90\x92P\x91at\xDDV[au\xE4\x91\x92P=\x80_\x83>au\xDC\x81\x83a\x08\xD7V[\x81\x01\x90asnV[\x90_at\xCDV[PPPPV[PPPPV[_av\x0B\x91av\x04a'\xAEV[P\x01am\xDFV[\x90V[_R` _ \x90V[av \x81am\xDFV[\x82\x10\x15av:Wav2`\x01\x91av\x0EV[\x91\x02\x01\x90_\x90V[a\x07~V[avO\x90`\x08avT\x93\x02a\x0CxV[a\x10\xB0V[\x90V[\x90avb\x91Tav?V[\x90V[av\x83\x91_av}\x92avvan\x95V[P\x01av\x17V[\x90avWV[\x90V[av\x8F_a%\xBDV[av\x99\x82_a&\x9AV[\x90av\xCDav\xC7\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x10\x06V[\x91a\x10\x06V[\x91av\xD6a\x03\xA2V[\x80av\xE0\x81a\x04KV[\x03\x90\xA3V[av\xEDa;\"V[Paw\x15aw\x0Faw\x08aw\x03`\x06\x85\x90a34V[a3JV[\x84\x90ad\xE4V[\x15a\x04\xC2V[aw\xB7Waw5\x91aw+aw0\x92`\x03a\x0F\xC8V[a\x10\x12V[aG\xA0V[aw@_\x82\x01a>\xADV[awRawL_a,\xC2V[\x91a\x05TV[\x14\x80\x15aw\x91W[aw\x8BWaw\x80awzaw\x86\x92awt_B\x92\x01a>\xADV[\x90a5\xD6V[\x92a\x05TV[\x91a\x05TV[\x10\x15\x90V[PP_\x90V[Paw\x9E``\x82\x01a^\x1AV[aw\xB1aw\xAB`\x03a\x11YV[\x91a\x11YV[\x14awZV[PPP_\x90V[aw\xD2aw\xCDaw\xD7\x92aUUV[a\x07IV[a\x05TV[\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[ax\0\x91aw\xFAan\x95V[\x91am\x88V[V[ax\x0B\x81am\\V[\x80\x15ax,W`\x01\x90\x03\x90ax)ax#\x83\x83am`V[\x90aw\xEEV[UV[aw\xDAV[ax9a;\"V[PaxPaxK`\x01\x83\x01\x84\x90am\xE3V[a\t>V[\x90\x81axdax^_a,\xC2V[\x91a\x05TV[\x14\x15_\x14ay0Wax\xE2\x92`\x01ax\xDD\x92\x84ax\x8B_\x96ax\x85\x85aw\xBEV[\x90a5\xD6V[ax\xA8ax\x99\x88\x85\x01am\xDFV[ax\xA2\x86aw\xBEV[\x90a5\xD6V[\x81ax\xBBax\xB5\x83a\x05TV[\x91a\x05TV[\x03ax\xE7W[PPPax\xD7ax\xD2\x86\x83\x01amPV[ax\x02V[\x01am\xE3V[a)\xBFV[`\x01\x90V[ay(\x92ay\x1Aay\x06ay\0ay#\x94\x8C\x89\x01av\x17V[\x90avWV[\x93ay\x14\x85\x91\x8C\x89\x01av\x17V[\x90am\x88V[\x91\x85\x85\x01am\xE3V[a0\x18V[_\x80\x80ax\xC1V[PPP_\x90V[\x90V[ayNayIayS\x92ay7V[a\x07IV[a\x05TV[\x90V[ay\x8Bay\x92\x94ay\x81``\x94\x98\x97\x95ayw`\x80\x86\x01\x9A_\x87\x01\x90a\x0F\x04V[` \x85\x01\x90a\x11)V[`@\x83\x01\x90a\x0F\x04V[\x01\x90a\x0F\x04V[V[ay\xA8ay\xA3ay\xAD\x92a%\xCAV[a&wV[a\x0F\x01V[\x90V[\x93\x92\x93ay\xBBaJ\xADV[Pay\xC4an\x91V[Pay\xCDan\x95V[Pay\xD7\x85aj\xE6V[az\taz\x03\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0ay:V[\x91a\x05TV[\x11az\x96W\x90az,` \x94\x95_\x94\x93\x92\x93az#a\x03\xA2V[\x94\x85\x94\x85ayVV[\x83\x80R\x03\x90`\x01Z\xFA\x15az\x91WazD_Qa&wV[\x80az_azYazT_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14azuW_\x91azo_ay\x94V[\x91\x92\x91\x90V[Paz\x7F_a%\xE9V[`\x01\x91az\x8B_ay\x94V[\x91\x92\x91\x90V[aK(V[PPPaz\xA2_a%\xE9V[\x90`\x03\x92\x91\x92\x91\x90V\xFE\xA1dsolcC\0\x08\x1A\0\n",
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
