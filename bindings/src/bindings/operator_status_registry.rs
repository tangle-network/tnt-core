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
    ///0x60c06040523461005e5761001a610014610132565b9061020f565b610022610063565b6179866104cc823960805181610d8a015260a05181818161130b0152818161265e0152818161333e01528181615244015261612f015261798690f35b610069565b60405190565b5f80fd5b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b906100959061006d565b810190811060018060401b038211176100ad57604052565b610077565b906100c56100be610063565b928361008b565b565b5f80fd5b60018060a01b031690565b6100df906100cb565b90565b6100eb816100d6565b036100f257565b5f80fd5b90505190610103826100e2565b565b919060408382031261012d578061012161012a925f86016100f6565b936020016100f6565b90565b6100c7565b610150617e5280380380610145816100b2565b928339810190610105565b9091565b90565b61016b610166610170926100cb565b610154565b6100cb565b90565b61017c90610157565b90565b61018890610173565b90565b90565b6101979061018b565b9052565b90565b6101a79061019b565b9052565b6101b4906100d6565b9052565b90959492610203946101f26101fc926101e86080966101de60a088019c5f89019061018e565b602087019061018e565b604085019061018e565b606083019061019e565b01906101ab565b565b60200190565b5190565b90610219906102cc565b60a0527f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f6102b47f36ffc258c865193ae10c3cf640450ab772fdb8da1dfcae7862ad1205a5567f4c916102a57fc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6466102903061017f565b91610299610063565b968795602087016101b8565b6020820181038252038261008b565b6102c66102c08261020b565b91610205565b20608052565b6102d590610317565b565b90565b6102ee6102e96102f3926102d7565b610154565b6100cb565b90565b6102ff906102da565b90565b9190610315905f602085019401906101ab565b565b8061033261032c6103275f6102f6565b6100d6565b916100d6565b1461034257610340906103e0565b565b61036561034e5f6102f6565b5f918291631e4fbdf760e01b835260048301610302565b0390fd5b1b90565b9190600861038d91029161038760018060a01b0384610369565b92610369565b9181191691161790565b6103a090610173565b90565b90565b91906103bc6103b76103c493610397565b6103a3565b90835461036d565b9055565b5f90565b6103de916103d86103c8565b916103a6565b565b6103f4906103ef5f60016103cc565b61046c565b565b5f1c90565b60018060a01b031690565b610412610417916103f6565b6103fb565b90565b6104249054610406565b90565b5f1b90565b9061043d60018060a01b0391610427565b9181191691161790565b9061045c61045761046392610397565b6103a3565b825461042c565b9055565b5f0190565b6104755f61041a565b61047f825f610447565b906104b36104ad7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e093610397565b91610397565b916104bc610063565b806104c681610467565b0390a356fe60806040526004361015610013575b6124b4565b61001d5f3561038c565b806305778550146103875780630758236f146103825780630c76697a1461037d578063191cbd1a146103785780631e8f5ee514610373578063208129561461036e57806322f1ec93146103695780632c957688146103645780632dae18851461035f57806331e3bd1b1461035a5780633644e515146103555780633ac3cbe6146103505780633e6e34a71461034b5780633fd62c6d1461034657806340235a9c1461034157806348f4da201461033c5780635685cf681461033757806356c4e17d1461033257806359dcea121461032d5780635a936dc6146103285780635cce98a6146103235780636076439c1461031e57806360cf09911461031957806361d6b86c1461031457806362c7e8fc1461030f57806365a6936e1461030a5780636bfe06a614610305578063715018a61461030057806371e7388c146102fb5780637639d227146102f657806379ba5097146102f15780637b9f64b2146102ec57806381beac2e146102e757806384ef7322146102e25780638da5cb5b146102dd57806396686c1e146102d85780639cbdae22146102d3578063adff830c146102ce578063ae470a85146102c9578063b074e9dd146102c4578063b99f6759146102bf578063ba1fb103146102ba578063c1ef9ddf146102b5578063c5d960bb146102b0578063cfe34749146102ab578063d413a580146102a6578063d551162c146102a1578063da435a7c1461029c578063e30c397814610297578063e65cafcb14610292578063ee1c03901461028d578063f2fde38b14610288578063f9107f3b14610283578063f9f167621461027e5763ffcf08f00361000e57612480565b61244b565b6123e8565b612388565b612352565b61231e565b6122e9565b6122b1565b6121df565b6121a5565b6120e7565b6120a5565b612070565b611f46565b611f12565b611ea5565b611e6b565b611da0565b611cd9565b611b50565b611a96565b611a63565b611a2c565b611997565b611964565b61192e565b6118f8565b61183c565b611807565b611799565b611554565b61150a565b611488565b611453565b6113e5565b61132d565b6112d4565b61129f565b61123a565b6111f0565b611184565b6110b0565b611076565b610e3e565b610dd1565b610d52565b610b98565b610afd565b610a5a565b6106b6565b610664565b610630565b610569565b61050f565b610440565b60e01c90565b60405190565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff1690565b6103ba816103a4565b036103c157565b5f80fd5b905035906103d2826103b1565b565b60018060a01b031690565b6103e8906103d4565b90565b6103f4816103df565b036103fb57565b5f80fd5b9050359061040c826103eb565b565b9190604083820312610436578061042a610433925f86016103c5565b936020016103ff565b90565b61039c565b5f0190565b3461046f5761045961045336600461040e565b9061264b565b610461610392565b8061046b8161043b565b0390f35b610398565b9060208282031261048d5761048a915f016103c5565b90565b61039c565b61049b906103a4565b9052565b60ff1690565b6104ae9061049f565b9052565b151590565b6104c0906104b2565b9052565b906040806104f8936104dc5f8201515f860190610492565b6104ee602082015160208601906104a5565b01519101906104b7565b565b919061050d905f606085019401906104c4565b565b3461053f5761053b61052a610525366004610474565b61272a565b610532610392565b918291826104fa565b0390f35b610398565b90565b61055090610544565b9052565b9190610567905f60208501940190610547565b565b3461059a5761059661058561057f36600461040e565b90612743565b61058d610392565b91829182610554565b0390f35b610398565b5f80fd5b5f80fd5b5f80fd5b909182601f830112156105e55781359167ffffffffffffffff83116105e05760200192602083028401116105db57565b6105a7565b6105a3565b61059f565b91909160408184031261062b57610603835f83016103c5565b92602082013567ffffffffffffffff81116106265761062292016105ab565b9091565b6103a0565b61039c565b3461065f576106496106433660046105ea565b916130cc565b610651610392565b8061065b8161043b565b0390f35b610398565b346106935761067d61067736600461040e565b90613332565b610685610392565b8061068f8161043b565b0390f35b610398565b906020828203126106b1576106ae915f016103ff565b90565b61039c565b346106e4576106ce6106c9366004610698565b613448565b6106d6610392565b806106e08161043b565b0390f35b610398565b6106f281610544565b036106f957565b5f80fd5b9050359061070a826106e9565b565b91906040838203126107345780610728610731925f86016103c5565b936020016106fd565b90565b61039c565b90565b61075061074b610755926103a4565b610739565b6103a4565b90565b906107629061073c565b5f5260205260405f2090565b634e487b7160e01b5f52603260045260245ffd5b5490565b5f5260205f2090565b5f5260205f2090565b6107a181610782565b8210156107bb576107b3600491610786565b910201905f90565b61076e565b634e487b7160e01b5f52602260045260245ffd5b90600160028304921680156107f4575b60208310146107ef57565b6107c0565b91607f16916107e4565b60209181520190565b5f5260205f2090565b905f929180549061082a610823836107d4565b80946107fe565b916001811690815f146108815750600114610845575b505050565b6108529192939450610807565b915f925b81841061086957505001905f8080610840565b60018160209295939554848601520191019290610856565b92949550505060ff19168252151560200201905f8080610840565b906108a691610810565b90565b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b906108d1906108a9565b810190811067ffffffffffffffff8211176108eb57604052565b6108b3565b9061091061090992610900610392565b9384809261089c565b03836108c7565b565b5f1c90565b90565b61092661092b91610912565b610917565b90565b610938905461091a565b90565b60ff1690565b61094d61095291610912565b61093b565b90565b61095f9054610941565b90565b61096d906008610758565b9061097782610782565b8110156109bd5761098791610798565b50906109945f83016108f0565b916109a16001820161092e565b916109ba60036109b36002850161092e565b9301610955565b90565b5f80fd5b5190565b60209181520190565b90825f9392825e0152565b6109f8610a01602093610a06936109ef816109c1565b938480936109c5565b958691016109ce565b6108a9565b0190565b610a13906104b2565b9052565b610a51610a5894610a47610a3c6060959998969960808601908682035f8801526109d9565b986020850190610547565b6040830190610547565b0190610a0a565b565b34610a8f57610a8b610a76610a7036600461070c565b90610962565b90610a82949294610392565b94859485610a17565b0390f35b610398565b5f910312610a9e57565b61039c565b90565b610aba610ab5610abf92610aa3565b610739565b6103a4565b90565b610acd61012c610aa6565b90565b610ad8610ac2565b90565b610ae4906103a4565b9052565b9190610afb905f60208501940190610adb565b565b34610b2d57610b0d366004610a94565b610b29610b18610ad0565b610b20610392565b91829182610ae8565b0390f35b610398565b1c90565b60018060a01b031690565b610b51906008610b569302610b32565b610b36565b90565b90610b649154610b41565b90565b610b73600b5f90610b59565b90565b610b7f906103df565b9052565b9190610b96905f60208501940190610b76565b565b34610bc857610ba8366004610a94565b610bc4610bb3610b67565b610bbb610392565b91829182610b83565b0390f35b610398565b909182601f83011215610c075781359167ffffffffffffffff8311610c02576020019260018302840111610bfd57565b6105a7565b6105a3565b61059f565b90602082820312610c3d575f82013567ffffffffffffffff8111610c3857610c349201610bcd565b9091565b6103a0565b61039c565b5190565b60209181520190565b60200190565b610c74610c7d602093610c8293610c6b816109c1565b938480936107fe565b958691016109ce565b6108a9565b0190565b610c8f90610544565b9052565b90610cbd90602080610cb2604084015f8701518582035f870152610c55565b940151910190610c86565b90565b90610cca91610c93565b90565b60200190565b90610ce7610ce083610c42565b8092610c46565b9081610cf860208302840194610c4f565b925f915b838310610d0b57505050505090565b90919293946020610d2d610d2783856001950387528951610cc0565b97610ccd565b9301930191939290610cfc565b610d4f9160208201915f818403910152610cd3565b90565b34610d8357610d7f610d6e610d68366004610c0c565b9061348d565b610d76610392565b91829182610d3a565b0390f35b610398565b7f000000000000000000000000000000000000000000000000000000000000000090565b90565b610db890610dac565b9052565b9190610dcf905f60208501940190610daf565b565b34610e0157610de1366004610a94565b610dfd610dec610d88565b610df4610392565b91829182610dbc565b0390f35b610398565b90565b610e1d610e18610e2292610e06565b610739565b6103a4565b90565b610e30610e10610e09565b90565b610e3b610e25565b90565b34610e6e57610e4e366004610a94565b610e6a610e59610e33565b610e61610392565b91829182610ae8565b0390f35b610398565b90610e7d9061073c565b5f5260205260405f2090565b610e9d610e98610ea2926103d4565b610739565b6103d4565b90565b610eae90610e89565b90565b610eba90610ea5565b90565b90610ec790610eb1565b5f5260205260405f2090565b67ffffffffffffffff1690565b610eec610ef191610912565b610ed3565b90565b610efe9054610ee0565b90565b60401c90565b60ff1690565b610f19610f1e91610f01565b610f07565b90565b610f2b9054610f0d565b90565b60481c90565b60ff1690565b610f46610f4b91610f2e565b610f34565b90565b610f589054610f3a565b90565b90565b610f6a610f6f91610912565b610f5b565b90565b610f7c9054610f5e565b90565b90610f8e610f93926003610e73565b610ebd565b610f9e5f820161092e565b91610fab60018301610ef4565b91610fb860018201610f21565b91610fd16002610fca60018501610f4e565b9301610f72565b90565b610fdd9061049f565b9052565b634e487b7160e01b5f52602160045260245ffd5b60051115610fff57565b610fe1565b9061100e82610ff5565b565b61101990611004565b90565b61102590611010565b9052565b909594926110749461106361106d9261105960809661104f60a088019c5f890190610547565b6020870190610adb565b6040850190610fd4565b606083019061101c565b0190610daf565b565b346110ab576110a761109261108c36600461040e565b90610f7f565b9161109e959395610392565b95869586611029565b0390f35b610398565b346110e0576110dc6110cb6110c6366004610474565b6134a7565b6110d3610392565b91829182610554565b0390f35b610398565b5190565b60209181520190565b60200190565b611101906103df565b9052565b90611112816020936110f8565b0190565b60200190565b9061113961113361112c846110e5565b80936110e9565b926110f2565b905f5b8181106111495750505090565b90919261116261115c6001928651611105565b94611116565b910191909161113c565b6111819160208201915f81840391015261111c565b90565b346111b4576111b061119f61119a366004610474565b613561565b6111a7610392565b9182918261116c565b0390f35b610398565b90565b6111d06111cb6111d5926111b9565b610739565b610544565b90565b6111e260c86111bc565b90565b6111ed6111d8565b90565b3461122057611200366004610a94565b61121c61120b6111e5565b611213610392565b91829182610554565b0390f35b610398565b9190611238905f60208501940190610a0a565b565b3461126b5761126761125661125036600461040e565b90613601565b61125e610392565b91829182611225565b0390f35b610398565b9061127a9061073c565b5f5260205260405f2090565b61129c906112976007915f92611270565b610b59565b90565b346112cf576112cb6112ba6112b5366004610474565b611286565b6112c2610392565b91829182610b83565b0390f35b610398565b34611304576113006112ef6112ea366004610474565b613688565b6112f7610392565b9182918261116c565b0390f35b610398565b7f000000000000000000000000000000000000000000000000000000000000000090565b3461135d5761133d366004610a94565b611359611348611309565b611350610392565b91829182610b83565b0390f35b610398565b61136b8161049f565b0361137257565b5f80fd5b9050359061138382611362565b565b906080828203126113e05761139c815f84016103c5565b926113aa82602085016103c5565b926113b88360408301611376565b92606082013567ffffffffffffffff81116113db576113d79201610bcd565b9091565b6103a0565b61039c565b34611417576114016113f8366004611385565b9392909261377c565b611409610392565b806114138161043b565b0390f35b610398565b90565b61143361142e6114389261141c565b610739565b610544565b90565b611445603261141f565b90565b61145061143b565b90565b3461148357611463366004610a94565b61147f61146e611448565b611476610392565b91829182610554565b0390f35b610398565b346114b9576114b56114a461149e36600461040e565b9061378b565b6114ac610392565b91829182611225565b0390f35b610398565b90565b6114d56114d06114da926114be565b610739565b61049f565b90565b6114e760036114c1565b90565b6114f26114dd565b90565b9190611508905f60208501940190610fd4565b565b3461153a5761151a366004610a94565b6115366115256114ea565b61152d610392565b918291826114f5565b0390f35b610398565b9190611552905f6020850194019061101c565b565b346115855761158161157061156a36600461040e565b906137b7565b611578610392565b9182918261153f565b0390f35b610398565b9061159d611596610392565b92836108c7565b565b67ffffffffffffffff81116115b75760208091020190565b6108b3565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff81116115e6576115e26020916108a9565b0190565b6108b3565b90825f939282370152565b9092919261160b611606826115c8565b61158a565b9381855260208501908284011161162757611625926115eb565b565b6115c4565b9080601f8301121561164a57816020611647933591016115f6565b90565b61059f565b9190916040818403126116a257611666604061158a565b925f8201359167ffffffffffffffff831161169d5761168a8261169694830161162c565b5f8601526020016106fd565b6020830152565b6115c0565b6115bc565b9291906116bb6116b68261159f565b61158a565b93818552602080860192028101918383116117125781905b8382106116e1575050505050565b813567ffffffffffffffff811161170d57602091611702878493870161164f565b8152019101906116d3565b61059f565b6105a7565b9080601f8301121561173557816020611732933591016116a7565b90565b61059f565b60808183031261179457611750825f83016103c5565b9261175e83602084016103ff565b9260408301359067ffffffffffffffff821161178f576117838161178c938601611717565b936060016106fd565b90565b6103a0565b61039c565b346117cb576117b56117ac36600461173a565b92919091613ba7565b6117bd610392565b806117c78161043b565b0390f35b610398565b90565b6117e76117e26117ec926117d0565b610739565b610544565b90565b6117f960406117d3565b90565b6118046117ef565b90565b3461183757611817366004610a94565b6118336118226117fc565b61182a610392565b91829182610554565b0390f35b610398565b3461186a5761184c366004610a94565b6118546141d6565b61185c610392565b806118668161043b565b0390f35b610398565b61187890611010565b9052565b61188590610dac565b9052565b906080806118e1936118a15f8201515f860190610c86565b6118b360208201516020860190610492565b6118c5604082015160408601906104a5565b6118d76060820151606086019061186f565b015191019061187c565b565b91906118f6905f60a08501940190611889565b565b346119295761192561191461190e36600461040e565b90614313565b61191c610392565b918291826118e3565b0390f35b610398565b3461195f5761195b61194a61194436600461040e565b9061436b565b611952610392565b91829182610ae8565b0390f35b610398565b3461199257611974366004610a94565b61197c614393565b611984610392565b8061198e8161043b565b0390f35b610398565b346119c7576119c36119b26119ad366004610474565b6143e4565b6119ba610392565b91829182610554565b0390f35b610398565b9091606082840312611a01576119fe6119e7845f85016103c5565b936119f581602086016106fd565b936040016106fd565b90565b61039c565b92916020611a22611a2a9360408701908782035f89015261111c565b940190610547565b565b34611a5e57611a45611a3f3660046119cc565b9161449e565b90611a5a611a51610392565b92839283611a06565b0390f35b610398565b34611a9157611a7b611a76366004610698565b614625565b611a83610392565b80611a8d8161043b565b0390f35b610398565b34611ac657611aa6366004610a94565b611ac2611ab1614634565b611ab9610392565b91829182610b83565b0390f35b610398565b909182601f83011215611b055781359167ffffffffffffffff8311611b00576020019260208302840111611afb57565b6105a7565b6105a3565b61059f565b919091604081840312611b4b57611b23835f83016103c5565b92602082013567ffffffffffffffff8111611b4657611b429201611acb565b9091565b6103a0565b61039c565b34611b7f57611b69611b63366004611b0a565b916146bb565b611b71610392565b80611b7b8161043b565b0390f35b610398565b91606083830312611bd057611b9b825f85016103c5565b92611ba983602083016103ff565b92604082013567ffffffffffffffff8111611bcb57611bc8920161162c565b90565b6103a0565b61039c565b90611bdf9061073c565b5f5260205260405f2090565b90611bf590610eb1565b5f5260205260405f2090565b905090565b611c2b611c2292602092611c19816109c1565b94858093611c01565b938491016109ce565b0190565b90565b611c3e611c4391610544565b611c2f565b9052565b611c57611c5e9160209493611c06565b8092611c32565b0190565b611c76611c6d610392565b92839283611c47565b03902090565b611c8591611c62565b90565b611c98906008611c9d9302610b32565b610917565b90565b90611cab9154611c88565b90565b90611cd692611ccc611cd192611cc76009955f96611bd5565b611beb565b611c7c565b611ca0565b90565b34611d0a57611d06611cf5611cef366004611b84565b91611cae565b611cfd610392565b91829182610554565b0390f35b610398565b909182601f83011215611d495781359167ffffffffffffffff8311611d44576020019260018302840111611d3f57565b6105a7565b6105a3565b61059f565b91606083830312611d9b57611d65825f85016103c5565b92611d7383602083016103ff565b92604082013567ffffffffffffffff8111611d9657611d929201611d0f565b9091565b6103a0565b61039c565b34611dd257611dbc611db3366004611d4e565b9291909161493c565b611dc4610392565b80611dce8161043b565b0390f35b610398565b611de0816104b2565b03611de757565b5f80fd5b90503590611df882611dd7565b565b91909160a081840312611e6657611e13835f83016103c5565b92602082013567ffffffffffffffff8111611e615781611e34918401611d0f565b929093611e5e611e4784604085016106fd565b93611e5581606086016106fd565b93608001611deb565b90565b6103a0565b61039c565b34611ea057611e8a611e7e366004611dfa565b94939093929192614c11565b611e92610392565b80611e9c8161043b565b0390f35b610398565b34611ed357611ebd611eb8366004610474565b614fc6565b611ec5610392565b80611ecf8161043b565b0390f35b610398565b9091606082840312611f0d57611f0a611ef3845f85016103c5565b93611f0181602086016103c5565b93604001611376565b90565b61039c565b34611f4157611f2b611f25366004611ed8565b9161523b565b611f33610392565b80611f3d8161043b565b0390f35b610398565b34611f7557611f5f611f5936600461040e565b9061541f565b611f67610392565b80611f718161043b565b0390f35b610398565b5190565b60209181520190565b60200190565b90611fdb90606080611fac608084015f8701518582035f870152610c55565b94611fbf60208201516020860190610c86565b611fd160408201516040860190610c86565b01519101906104b7565b90565b90611fe891611f8d565b90565b60200190565b90612005611ffe83611f7a565b8092611f7e565b908161201660208302840194611f87565b925f915b83831061202957505050505090565b9091929394602061204b61204583856001950387528951611fde565b97611feb565b930193019193929061201a565b61206d9160208201915f818403910152611ff1565b90565b346120a05761209c61208b612086366004610474565b615796565b612093610392565b91829182612058565b0390f35b610398565b346120d3576120bd6120b8366004610474565b615926565b6120c5610392565b806120cf8161043b565b0390f35b610398565b6120e4600a5f90610b59565b90565b34612117576120f7366004610a94565b6121136121026120d8565b61210a610392565b91829182610b83565b0390f35b610398565b909160a0828403126121a057612134835f84016103c5565b9261214281602085016103c5565b926121508260408301611376565b92606082013567ffffffffffffffff811161219b5783612171918401610bcd565b929093608082013567ffffffffffffffff8111612196576121929201610bcd565b9091565b6103a0565b6103a0565b61039c565b346121da576121c46121b836600461211c565b95949094939193615c29565b6121cc610392565b806121d68161043b565b0390f35b610398565b346122135761220f6121fe6121f5366004611d4e565b92919091615c9c565b612206610392565b91829182610554565b0390f35b610398565b906122229061073c565b5f5260205260405f2090565b61223a61223f91610f2e565b61093b565b90565b61224c905461222e565b90565b61225a906002612218565b6122655f8201610ef4565b9161227c5f612275818501610f21565b9301612242565b90565b6040906122a86122af949695939661229e60608401985f850190610adb565b6020830190610fd4565b0190610a0a565b565b346122e4576122e06122cc6122c7366004610474565b61224f565b6122d7939193610392565b9384938461227f565b0390f35b610398565b34612319576122f9366004610a94565b612315612304615cd1565b61230c610392565b91829182610b83565b0390f35b610398565b3461234d5761233761233136600461040e565b90615dbb565b61233f610392565b806123498161043b565b0390f35b610398565b346123835761237f61236e61236836600461040e565b90615f50565b612376610392565b91829182611225565b0390f35b610398565b346123b6576123a061239b366004610698565b61604f565b6123a8610392565b806123b28161043b565b0390f35b610398565b91906040838203126123e357806123d76123e0925f86016103c5565b93602001611deb565b90565b61039c565b34612417576124016123fb3660046123bb565b9061605a565b612409610392565b806124138161043b565b0390f35b610398565b7fe1675f8364c07a4d60a07503f0d700a7bcacd82251dff0f070e5235de6c6d28a90565b61244861241c565b90565b3461247b5761245b366004610a94565b612477612466612440565b61246e610392565b91829182610dbc565b0390f35b610398565b346124af5761249961249336600461040e565b90616123565b6124a1610392565b806124ab8161043b565b0390f35b610398565b5f80fd5b5f7f4f6e6c792054616e676c6520636f726500000000000000000000000000000000910152565b6124ec60106020926109c5565b6124f5816124b8565b0190565b61250e9060208101905f8183039101526124df565b90565b1561251857565b612520610392565b62461bcd60e51b815280612536600482016124f9565b0390fd5b61254661254b91610912565b610b36565b90565b612558905461253a565b90565b90565b61257261256d6125779261255b565b610739565b6103d4565b90565b6125839061255e565b90565b5f7f416c726561647920726567697374657265640000000000000000000000000000910152565b6125ba60126020926109c5565b6125c381612586565b0190565b6125dc9060208101905f8183039101526125ad565b90565b156125e657565b6125ee610392565b62461bcd60e51b815280612604600482016125c7565b0390fd5b5f1b90565b9061261e60018060a01b0391612608565b9181191691161790565b90565b9061264061263b61264792610eb1565b612628565b825461260d565b9055565b6126cd6126d29261268e336126886126827f00000000000000000000000000000000000000000000000000000000000000006103df565b916103df565b14612511565b6126c56126a56126a060078690611270565b61254e565b6126bf6126b96126b45f61257a565b6103df565b916103df565b146125df565b916007611270565b61262b565b565b6126de606061158a565b90565b5f90565b5f90565b5f90565b6126f56126d4565b9060208080846127036126e1565b81520161270e6126e5565b8152016127196126e9565b81525050565b6127276126ed565b90565b61273c9061273661271f565b5061624b565b90565b5f90565b61276461276a9261275f5f9361275761273f565b506003610e73565b610ebd565b0161092e565b90565b5f7f4e6f742073657276696365206f776e6572000000000000000000000000000000910152565b6127a160116020926109c5565b6127aa8161276d565b0190565b6127c39060208101905f818303910152612794565b90565b156127cd57565b6127d5610392565b62461bcd60e51b8152806127eb600482016127ae565b0390fd5b5090565b5f7f546f6f206d616e7920646566696e6974696f6e73000000000000000000000000910152565b61282760146020926109c5565b612830816127f3565b0190565b6128499060208101905f81830391015261281a565b90565b1561285357565b61285b610392565b62461bcd60e51b81528061287160048201612834565b0390fd5b634e487b7160e01b5f52601160045260245ffd5b61289861289e91939293610544565b92610544565b916128aa838202610544565b9281840414901517156128b957565b612875565b6128c9906004612889565b90565b906128df905f1990602003600802610b32565b8154169055565b1b90565b919060086129059102916128ff5f19846128e6565b926128e6565b9181191691161790565b61292361291e61292892610544565b610739565b610544565b90565b90565b919061294461293f61294c9361290f565b61292b565b9083546128ea565b9055565b6129629161295c61273f565b9161292e565b565b5b818110612970575050565b8061297d5f600193612950565b01612965565b90612993905f1990600802610b32565b191690565b816129a291612983565b906002021790565b905f916129c16129b982610807565b928354612998565b905555565b601f602091010490565b919290602082105f14612a2957601f84116001146129f9576129f3929350612998565b90555b5b565b5090612a1f612a24936001612a16612a1085610807565b926129c6565b82019101612964565b6129aa565b6129f6565b50612a608293612a3a600194610807565b612a59612a46856129c6565b820192601f861680612a6b575b506129c6565b0190612964565b6002021790556129f7565b612a77908886036128cc565b5f612a53565b929091680100000000000000008211612add576020115f14612ace57602081105f14612ab257612aac91612998565b90555b5b565b60019160ff1916612ac284610807565b55600202019055612aaf565b60019150600202019055612ab0565b6108b3565b908154612aee816107d4565b90818311612b17575b818310612b05575b50505050565b612b0e936129d0565b5f808080612aff565b612b2383838387612a7d565b612af7565b5f612b3291612ae2565b565b634e487b7160e01b5f525f60045260245ffd5b905f03612b5957612b5790612b28565b565b612b34565b60035f91612b6e83808301612b47565b612b7b8360018301612950565b612b888360028301612950565b0155565b905f03612b9e57612b9c90612b5e565b565b612b34565b5b818110612baf575050565b80612bbc5f600493612b8c565b01612ba4565b9091828110612bd1575b505050565b612bef612be9612be3612bfa956128be565b926128be565b92610786565b918201910190612ba3565b5f8080612bcc565b90680100000000000000008111612c2b5781612c20612c2993610782565b90828155612bc2565b565b6108b3565b5f612c3a91612c02565b565b905f03612c4e57612c4c90612c30565b565b612b34565b612c67612c62612c6c9261255b565b610739565b610544565b90565b6001612c7b9101610544565b90565b5f80fd5b5f80fd5b5f80fd5b903590600160800381360303821215612ca1570190565b612c7e565b90821015612cc0576020612cbd9202810190612c8a565b90565b61076e565b903590600160200381360303821215612d07570180359067ffffffffffffffff8211612d0257602001916001820236038313612cfd57565b612c86565b612c82565b612c7e565b91565b5090565b5f7f4e616d6520746f6f206c6f6e6700000000000000000000000000000000000000910152565b612d47600d6020926109c5565b612d5081612d13565b0190565b612d699060208101905f818303910152612d3a565b90565b15612d7357565b612d7b610392565b62461bcd60e51b815280612d9160048201612d54565b0390fd5b35612d9f816106e9565b90565b5f7f496e76616c696420626f756e6473000000000000000000000000000000000000910152565b612dd6600e6020926109c5565b612ddf81612da2565b0190565b612df89060208101905f818303910152612dc9565b90565b15612e0257565b612e0a610392565b62461bcd60e51b815280612e2060048201612de3565b0390fd5b90565b5f5260205f2090565b5490565b612e3d81612e30565b821015612e5757612e4f600491612e27565b910201905f90565b61076e565b5090565b9190601f8111612e70575b505050565b612e7c612ea193610807565b906020612e88846129c6565b83019310612ea9575b612e9a906129c6565b0190612964565b5f8080612e6b565b9150612e9a81929050612e91565b91612ec29082612e5c565b9067ffffffffffffffff8211612f8157612ee682612ee085546107d4565b85612e60565b5f90601f8311600114612f1957918091612f08935f92612f0d575b5050612998565b90555b565b90915001355f80612f01565b601f19831691612f2885610807565b925f5b818110612f6957509160029391856001969410612f4f575b50505002019055612f0b565b612f5f910135601f841690612983565b90555f8080612f43565b91936020600181928787013581550195019201612f2b565b6108b3565b90612f919291612eb7565b565b90612f9f5f1991612608565b9181191691161790565b90612fbe612fb9612fc59261290f565b61292b565b8254612f93565b9055565b35612fd381611dd7565b90565b90612fe260ff91612608565b9181191691161790565b612ff5906104b2565b90565b90565b9061301061300b61301792612fec565b612ff8565b8254612fd6565b9055565b906130796060600361307f9461303f5f82016130395f880188612cc5565b91612f86565b6130586001820161305260208801612d95565b90612fa9565b6130716002820161306b60408801612d95565b90612fa9565b019201612fc9565b90612ffb565b565b9190613092576130909161301b565b565b612b34565b90815491680100000000000000008310156130c757826130bf9160016130c595018155612e34565b90613081565b565b6108b3565b929190926130ff336130f96130f36130ee6130e960078790611270565b61254e565b6103df565b916103df565b146127c6565b61312d61310d8584906127ef565b61312661312061311b61143b565b610544565b91610544565b111561284c565b6131425f61313d60088490610758565b612c3c565b61314b5f612c53565b5b8061316961316361315e8887906127ef565b610544565b91610544565b101561323c57613237906131c06131a061319a61319461318b8a898791612ca6565b5f810190612cc5565b90612d0c565b90612d0f565b6131b96131b36131ae6117ef565b610544565b91610544565b1115612d6c565b6132096131da60406131d489888691612ca6565b01612d95565b6132026131fc6131f760206131f18c8b8991612ca6565b01612d95565b610544565b91610544565b1015612dfb565b61323261322061321b60088690610758565b612e24565b61322c88878591612ca6565b90613097565b612c6f565b61314c565b5050509050565b5f7f5a65726f20616464726573730000000000000000000000000000000000000000910152565b613277600c6020926109c5565b61328081613243565b0190565b6132999060208101905f81830391015261326a565b90565b156132a357565b6132ab610392565b62461bcd60e51b8152806132c160048201613284565b0390fd5b906132cf9061073c565b5f5260205260405f2090565b90565b60481b90565b906132f969ff000000000000000000916132de565b9181191691161790565b61330c90611004565b90565b90565b9061332761332261332e92613303565b61330f565b82546132e4565b9055565b61336e336133686133627f00000000000000000000000000000000000000000000000000000000000000006103df565b916103df565b14612511565b6133938261338c6133866133815f61257a565b6103df565b916103df565b141561329c565b6133b96133b46133ad6133a8600685906132c5565b6132db565b8490616329565b6125df565b6133dc600260016133d66133cf60038690610e73565b8690610ebd565b01613312565b9061341061340a7f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b9361073c565b91610eb1565b91613419610392565b806134238161043b565b0390a3565b61343990613434616363565b61343b565b565b61344690600b61262b565b565b61345190613428565b565b606090565b90602082820312613488575f82013567ffffffffffffffff8111613483576134809201611717565b90565b6103a0565b61039c565b906134a49161349a613453565b5090810190613458565b90565b6134c66134c16134cb926134b961273f565b5060056132c5565b6132db565b6163b1565b90565b606090565b67ffffffffffffffff81116134eb5760208091020190565b6108b3565b906135026134fd836134d3565b61158a565b918252565b369037565b90613531613519836134f0565b9260208061352786936134d3565b9201910390613507565b565b9061353d826110e5565b81101561354e576020809102010190565b61076e565b9061355d906103df565b9052565b9061356a6134ce565b5061358761358261357d600485906132c5565b6132db565b6163b1565b916135918361350c565b9161359b5f612c53565b5b806135af6135a987610544565b91610544565b10156135f6576135f1906135ec6135da6135d36135ce600488906132c5565b6132db565b8390616400565b6135e78791849092613533565b613553565b612c6f565b61359c565b5092505090565b5f90565b9061360a6135fd565b5061362c600161362661361f60038690610e73565b8490610ebd565b01610f4e565b61363e6136385f611004565b91611004565b1491821561364c575b505090565b61366d9250600191613662613667926003610e73565b610ebd565b01610f4e565b61368061367a6001611004565b91611004565b145f80613647565b6136ae906136946134ce565b505f906136a86136a26111d8565b92612c53565b9061449e565b5090565b5f7f4e6f742072656769737465726564206f70657261746f72000000000000000000910152565b6136e660176020926109c5565b6136ef816136b2565b0190565b6137089060208101905f8183039101526136d9565b90565b1561371257565b61371a610392565b62461bcd60e51b815280613730600482016136f3565b0390fd5b906137669493929161376161375c6137556137508460066132c5565b6132db565b3390616438565b61370b565b613768565b565b9161377a9492939133919293946165e7565b565b9061378994939291613734565b565b906137ab6137a66137b09361379e6135fd565b5060066132c5565b6132db565b616438565b90565b5f90565b6137d96137df926137d46001936137cc6137b3565b506003610e73565b610ebd565b01610f4e565b90565b6137eb90610ea5565b90565b5f7f496e7465726e616c206f6e6c7900000000000000000000000000000000000000910152565b613822600d6020926109c5565b61382b816137ee565b0190565b6138449060208101905f818303910152613815565b90565b1561384e57565b613856610392565b62461bcd60e51b81528061386c6004820161382f565b0390fd5b67ffffffffffffffff81116138885760208091020190565b6108b3565b9061389f61389a83613870565b61158a565b918252565b369037565b906138ce6138b68361388d565b926020806138c48693613870565b92019103906138a4565b565b906138da82610c42565b8110156138eb576020809102010190565b61076e565b90565b60200190565b5190565b5190565b9061390b826138fd565b81101561391c576020809102010190565b61076e565b9061392b90610dac565b9052565b606090565b90565b60209181520190565b905f929180549061395a613953836107d4565b8094613937565b916001811690815f146139b15750600114613975575b505050565b613982919293945061078f565b915f925b81841061399957505001905f8080613970565b60018160209295939554848601520191019290613986565b92949550505060ff19168252151560200201905f8080613970565b906139d691613940565b90565b906139f96139f2926139e9610392565b938480926139cc565b03836108c7565b565b613a04906139d9565b90565b613a119051610dac565b90565b613a1e9051610544565b90565b5f7f56616c7565206f7574206f6620626f756e647300000000000000000000000000910152565b613a5560136020926109c5565b613a5e81613a21565b0190565b613a7a613a889260408301908382035f8501526109d9565b906020818303910152613a48565b90565b92916020613aa7613aaf9360408701908782035f8901526109d9565b940190610547565b565b905f9291805490613acb613ac4836107d4565b80946109c5565b916001811690815f14613b225750600114613ae6575b505050565b613af39192939450610807565b915f925b818410613b0a57505001905f8080613ae1565b60018160209295939554848601520191019290613af7565b92949550505060ff19168252151560200201905f8080613ae1565b5f7f5265717569726564206d6574726963206d697373696e67000000000000000000910152565b613b7160176020926109c5565b613b7a81613b3d565b0190565b613b96613ba49260408301908382035f850152613ab1565b906020818303910152613b64565b90565b92939093613bcf33613bc9613bc3613bbe306137e2565b6103df565b916103df565b14613847565b613be3613bde60088690610758565b612e24565b94613bed826138a9565b94613bf75f612c53565b5b80613c0b613c0586610544565b91610544565b1015613c5e57613c5990613c54613c2f5f613c278a85906138d0565b5101516138f0565b613c41613c3b826138f9565b916138f3565b20613c4f8a91849092613901565b613921565b612c6f565b613bf8565b509194909295613c6d81612e30565b613c7f613c795f612c53565b91610544565b1196613c8961392f565b9088614109575b613c995f612c53565b5b80613cad613ca78b610544565b91610544565b1015613f6c5760015f8b613da0575b5090888789613cd294613cd7575b505050612c6f565b613c9a565b825f613d15613d0d613d1e94613d08613d006020613cf9613d239b8d906138d0565b5101613a14565b976009611bd5565b611beb565b9287906138d0565b51015190611c7c565b612fa9565b88878990613d4d6020613d465f613d3b8789906138d0565b5101519587906138d0565b5101613a14565b613d80613d7a7f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd9361073c565b93610eb1565b93613d95613d8c610392565b92839283613a8b565b0390a3888789613cca565b9a9095929199613daf5f612c53565b5b80613dcb613dc5613dc08a612e30565b610544565b91610544565b1015613f5657613de3613dde8d87613901565b613a07565b613e07613e01613dfc613df78a8690613901565b613a07565b610dac565b91610dac565b14613e1a57613e1590612c6f565b613db0565b8a919b929c5089613cd29495988a926001908a613e446020613e3d898b906138d0565b5101613a14565b613e6c613e66613e616001613e5a868890612e34565b500161092e565b610544565b91610544565b109188888415613f0c575b50505050613ea1575b613e8b905b156104b2565b613e9a575b9394505050613cbc565b505f613e90565b905082825f613eb18789906138d0565b51015191613efd613eeb613ee57fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361073c565b93610eb1565b93613ef4610392565b91829182613a62565b0390a3613e8b5f919050613e80565b613f4c939450613f3a613f4693613f346020613f2d613f41966002966138d0565b5101613a14565b96612e34565b500161092e565b610544565b91610544565b118a5f8888613e77565b5099909a8789613cd2949598613e8b8d94613e85565b509750509293509350613f7e5f612c53565b935b84613f9b613f95613f9086612e30565b610544565b91610544565b101561410257613fc1613fbb6003613fb4868990612e34565b5001610955565b156104b2565b6140f757613fe3613fde5f613fd7868990612e34565b5001613934565b6139fb565b613ff5613fef826138f9565b916138f3565b20905f966140025f612c53565b5b8061401e614018614013866138fd565b610544565b91610544565b10156140e557614037614032848390613901565b613a07565b61404961404386610dac565b91610dac565b1461405c5761405790612c6f565b614003565b509590965061407d915061407260015b156104b2565b614084575b5b612c6f565b9394613f80565b82855f614092878590612e34565b5001916140dd6140cb6140c57fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361073c565b93610eb1565b936140d4610392565b91829182613b7e565b0390a3614077565b5095909661407d92506140729061406c565b949361407d90614078565b5050505050565b9693905061412361411e839794999693612e30565b6138a9565b9761412d5f612c53565b5b8061414961414361413e8b612e30565b610544565b91610544565b10156141a35761419e9061419961417461416f5f6141688d8690612e34565b5001613934565b6139fb565b614186614180826138f9565b916138f3565b206141948d91849092613901565b613921565b612c6f565b61412e565b509295919497909396613c90565b6141b9616363565b6141c16141c3565b565b6141d46141cf5f61257a565b616a59565b565b6141de6141b1565b565b6141ea60a061158a565b90565b5f90565b5f90565b5f90565b6142016141e0565b90602080808080866142116141ed565b81520161421c6126e1565b8152016142276126e5565b8152016142326141f1565b81520161423d6141f5565b81525050565b61424b6141f9565b90565b9061425890610544565b9052565b90614266906103a4565b9052565b906142749061049f565b9052565b9061428290611004565b9052565b906143056142fc60026142976141e0565b946142ae6142a65f830161092e565b5f880161424e565b6142c66142bd60018301610ef4565b6020880161425c565b6142de6142d560018301610f21565b6040880161426a565b6142f66142ed60018301610f4e565b60608801614278565b01610f72565b60808401613921565b565b61431090614286565b90565b6143389161432e61433392614326614243565b506003610e73565b610ebd565b614307565b90565b5f90565b906143499061073c565b5f5260205260405f2090565b9061435f90610eb1565b5f5260205260405f2090565b6143909161438661438b9261437e61433b565b50600c61433f565b614355565b610ef4565b90565b61439b616a6f565b6143a3615cd1565b6143b56143af836103df565b916103df565b036143c5576143c390616a59565b565b6143e0905f91829163118cdaa760e01b835260048301610b83565b0390fd5b6144036143fe614408926143f661273f565b5060046132c5565b6132db565b6163b1565b90565b614415905161049f565b90565b61442c6144276144319261255b565b610739565b61049f565b90565b61443e90516103a4565b90565b61445561445061445a926103a4565b610739565b610544565b90565b61447161446c6144769261049f565b610739565b610544565b90565b61448861448e91939293610544565b92610544565b820180921161449957565b612875565b909291926144aa6134ce565b506144b361273f565b506144bd8261624b565b936144da6144d56144d0600586906132c5565b6132db565b6163b1565b926144e76020870161440b565b6144f96144f35f614418565b9161049f565b1480156145eb575b80156145d0575b6145b6576145428661453c614537602061453061452b5f61459f9b9c9d01614434565b614441565b930161440b565b61445d565b90612889565b918061455d6145576145526111d8565b610544565b91610544565b115f146145b1575061456d6111d8565b5b614579848290614479565b61458b61458588610544565b91610544565b115f146145a25750845b9092909192616aa5565b91565b6145ac9084614479565b614595565b61456e565b50505091506145cc6145c75f612c53565b61350c565b9190565b50826145e46145de86610544565b91610544565b1015614508565b50836145ff6145f95f612c53565b91610544565b14614501565b61461690614611616363565b614618565b565b61462390600a61262b565b565b61462e90614605565b565b5f90565b61463c614630565b506146465f61254e565b90565b5090565b919081101561465d576020020190565b61076e565b3561466c816103eb565b90565b5f80fd5b60e01b90565b5f91031261468357565b61039c565b9160206146a99294936146a260408201965f830190610adb565b0190610b76565b565b6146b3610392565b3d5f823e3d90fd5b909291926146c85f612c53565b5b806146e66146e06146db858990614649565b610544565b91610544565b1015614795576146f5306137e2565b9063ba1fb1038461471061470b868a869161464d565b614662565b93803b15614790576147355f8094614740614729610392565b98899687958694614673565b845260048401614688565b03925af191821561478b5761475a9261475f575b50612c6f565b6146c9565b61477e905f3d8111614784575b61477681836108c7565b810190614679565b5f614754565b503d61476c565b6146ab565b61466f565b5050509050565b5f7f4e6f7420736c617368696e67206f7261636c6500000000000000000000000000910152565b6147d060136020926109c5565b6147d98161479c565b0190565b6147f29060208101905f8183039101526147c3565b90565b156147fc57565b614804610392565b62461bcd60e51b81528061481a600482016147dd565b0390fd5b5f7f4f70657261746f7220756e6b6e6f776e00000000000000000000000000000000910152565b61485260106020926109c5565b61485b8161481e565b0190565b6148749060208101905f818303910152614845565b90565b1561487e57565b614886610392565b62461bcd60e51b81528061489c6004820161485f565b0390fd5b90565b6148b76148b26148bc92610544565b610739565b6103a4565b90565b906148d267ffffffffffffffff91612608565b9181191691161790565b90565b906148f46148ef6148fb9261073c565b6148dc565b82546148bf565b9055565b9190614919816149128161491e956109c5565b80956115eb565b6108a9565b0190565b90916149399260208301925f8185039101526148ff565b90565b6149613361495b614955614950600a61254e565b6103df565b916103df565b146147f5565b61498761498261497b614976600585906132c5565b6132db565b8490616438565b614877565b6149b36149a86149a361499c60038590610e73565b8590610ebd565b6148a0565b600160039101613312565b6149d16149ca6149c5600484906132c5565b6132db565b8390616bc1565b506149f96149de426148a3565b6149f46149ed600c859061433f565b8590614355565b6148df565b909192614a2f614a297f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361073c565b93610eb1565b93614a44614a3b610392565b92839283614922565b0390a3565b614a53608061158a565b90565b614a619136916115f6565b90565b52565b90614a71906104b2565b9052565b5190565b90614a83816109c1565b9067ffffffffffffffff8211614b4357614aa782614aa185546107d4565b85612e60565b602090601f8311600114614adb57918091614aca935f92614acf575b5050612998565b90555b565b90915001515f80614ac3565b601f19831691614aea85610807565b925f5b818110614b2b57509160029391856001969410614b11575b50505002019055614acd565b614b21910151601f841690612983565b90555f8080614b05565b91936020600181928787015181550195019201614aed565b6108b3565b90614b5291614a79565b565b614b5e90516104b2565b90565b90614bbe60606003614bc494614b845f8201614b7e5f8801614a75565b90614b48565b614b9d60018201614b9760208801613a14565b90612fa9565b614bb660028201614bb060408801613a14565b90612fa9565b019201614b54565b90612ffb565b565b9190614bd757614bd591614b61565b565b612b34565b9081549168010000000000000000831015614c0c5782614c04916001614c0a95018155612e34565b90614bc6565b565b6108b3565b614d2f95614d188496614d0f614d07614cf3614cee614d2197614c94614c74614c6e614d2a9d8d9f9d614c6933614c63614c5d614c58614c5360078c90611270565b61254e565b6103df565b916103df565b146127c6565b612d0c565b90612d0f565b614c8d614c87614c826117ef565b610544565b91610544565b1115612d6c565b614cb186614caa614ca48d610544565b91610544565b1015612dfb565b614ce7614cc8614cc360088490610758565b610782565b614ce1614cdb614cd661143b565b610544565b91610544565b1061284c565b6008610758565b612e24565b989996929496614d01614a49565b9a614a56565b5f8a01614a64565b6020880161424e565b6040860161424e565b60608401614a67565b614bdc565b565b614d5f90614d5a614d55614d4e614d498460066132c5565b6132db565b3390616438565b61370b565b614e40565b565b5f7f43616e6e6f7420676f206f6e6c696e65207768696c6520736c61736865640000910152565b614d95601e6020926109c5565b614d9e81614d61565b0190565b614db79060208101905f818303910152614d88565b90565b60401b90565b90614dd468ff000000000000000091614dba565b9181191691161790565b614df2614ded614df79261049f565b610739565b61049f565b90565b90565b90614e12614e0d614e1992614dde565b614dfa565b8254614dc0565b9055565b916020614e3e929493614e3760408201965f83019061101c565b019061101c565b565b614e5e614e59614e5260038490610e73565b3390610ebd565b6148a0565b90614e6b60018301610f4e565b9182614e80614e7a6003611004565b91611004565b14614fa45782614e98614e925f611004565b91611004565b148015614f89575b614f8457614ec790614eb56001808301613312565b6001614ec05f614418565b9101614dfd565b614ee5614ede614ed9600484906132c5565b6132db565b3390616329565b508033614f1b614f157fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361073c565b91610eb1565b91614f24610392565b80614f2e8161043b565b0390a3903390916001614f6a614f647f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361073c565b93610eb1565b93614f7f614f76610392565b92839283614e1d565b0390a3565b505050565b5082614f9e614f986001611004565b91611004565b14614ea0565b614fac610392565b62461bcd60e51b815280614fc260048201614da2565b0390fd5b614fcf90614d31565b565b5f7f4e6f7420617574686f72697a6564000000000000000000000000000000000000910152565b615005600e6020926109c5565b61500e81614fd1565b0190565b6150279060208101905f818303910152614ff8565b90565b1561503157565b615039610392565b62461bcd60e51b81528061504f60048201615012565b0390fd5b90565b61506a61506561506f92615053565b610739565b6103a4565b90565b5f7f496e74657276616c20746f6f2073686f72740000000000000000000000000000910152565b6150a660126020926109c5565b6150af81615072565b0190565b6150c89060208101905f818303910152615099565b90565b156150d257565b6150da610392565b62461bcd60e51b8152806150f0600482016150b3565b0390fd5b90565b61510b615106615110926150f4565b610739565b61049f565b90565b5f7f4d6178206d6973736564206d757374206265203e3d2031000000000000000000910152565b61514760176020926109c5565b61515081615113565b0190565b6151699060208101905f81830391015261513a565b90565b1561517357565b61517b610392565b62461bcd60e51b81528061519160048201615154565b0390fd5b61519f606061158a565b90565b906151b76151b26151be92612fec565b612ff8565b82546132e4565b9055565b9061520460405f61520a946151e48282016151de848801614434565b906148df565b6151fc8282016151f66020880161440b565b90614dfd565b019201614b54565b906151a2565b565b90615216916151c2565b565b91602061523992949361523260408201965f830190610adb565b0190610fd4565b565b3361526e6152687f00000000000000000000000000000000000000000000000000000000000000006103df565b916103df565b14801561535a575b61527f9061502a565b61529d82615296615290603c615056565b916103a4565b10156150cb565b6152bb836152b46152ae60016150f7565b9161049f565b101561516c565b61531482615303856152fa6152dc5f6152d660028990612218565b01612242565b916152f16152e8615195565b955f870161425c565b6020850161426a565b60408301614a67565b61530f60028490612218565b61520c565b90916153407fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea5649261073c565b9261535561534c610392565b92839283615218565b0390a2565b5061527f3361538461537e61537961537460078790611270565b61254e565b6103df565b916103df565b149050615276565b61539b6153a191939293610544565b92610544565b82039182116153ac57565b612875565b634e487b7160e01b5f52601260045260245ffd5b6153d16153d791610544565b91610544565b9081156153e2570490565b6153b1565b6153fb6153f661540092610544565b610739565b61049f565b90565b61541761541261541c9261255b565b610739565b6103a4565b90565b61543d61543861543160038490610e73565b8490610ebd565b6148a0565b906154478161624b565b61545360018401610f4e565b6154666154606003611004565b91611004565b1461567a576154765f840161092e565b6154886154825f612c53565b91610544565b14615674576154be6154a54261549f5f870161092e565b9061538c565b6154b86154b35f8501614434565b614441565b906153c5565b806154d26154cc60ff61445d565b91610544565b115f14615666575060ff5b90816154fc6154f66154f160018801610f21565b61049f565b9161049f565b11615509575b5050505050565b6155168260018601614dfd565b61552b6155225f615403565b600186016148df565b61554961554361553e602085940161440b565b61049f565b9161049f565b10158061563f575b61555c575b80615502565b61557761556b60018501610f4e565b93600160029101613312565b61559561558e615589600485906132c5565b6132db565b8590616bc1565b5081908490916155e36155d16155cb7f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d9361073c565b93610eb1565b936155da610392565b918291826114f5565b0390a3919091600261561e6156187f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361073c565b93610eb1565b9361563361562a610392565b92839283614e1d565b0390a35f808080615556565b5061564c60018401610f4e565b61565f6156596002611004565b91611004565b1415615551565b61566f906153e7565b6154dd565b50505050565b50505050565b606090565b67ffffffffffffffff811161569d5760208091020190565b6108b3565b906156b46156af83615685565b61158a565b918252565b6156c3608061158a565b90565b9061572d61572460036156d76156b9565b946156ee6156e65f83016108f0565b5f8801614a64565b6157066156fd6001830161092e565b6020880161424e565b61571e6157156002830161092e565b6040880161424e565b01610955565b60608401614a67565b565b615738906156c6565b90565b9061574582610782565b61574e816156a2565b9261575c6020850191610786565b5f915b83831061576c5750505050565b6004602060019261577c8561572f565b81520192019201919061575f565b6157939061573b565b90565b6157ad6157b2916157a5615680565b506008610758565b61578a565b90565b6157e3906157de6157d96157d26157cd8460066132c5565b6132db565b3390616438565b61370b565b61583e565b565b5f7f43616e6e6f7420676f206f66666c696e65207768696c6520736c617368656400910152565b615819601f6020926109c5565b615822816157e5565b0190565b61583b9060208101905f81830391015261580c565b90565b61585c61585761585060038490610e73565b3390610ebd565b6148a0565b9061586960018301610f4e565b918261587e6158786003611004565b91611004565b146159045761589290600160049101613312565b6158b06158a96158a4600484906132c5565b6132db565b3390616bc1565b509033909160046158ea6158e47f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361073c565b93610eb1565b936158ff6158f6610392565b92839283614e1d565b0390a3565b61590c610392565b62461bcd60e51b81528061592260048201615826565b0390fd5b61592f906157b5565b565b9061596596959493929161596061595b61595461594f8460066132c5565b6132db565b3390616438565b61370b565b615b66565b565b60c01b90565b61597690615967565b90565b61598561598a916103a4565b61596d565b9052565b60f81b90565b61599d9061598e565b90565b6159ac6159b19161049f565b615994565b9052565b905090565b9091826159ca816159d1936159b5565b80936115eb565b0190565b60086001936159f982846159f1615a0196615a089c9a98615979565b018092615979565b0180926159a0565b01916159ba565b90565b5f7f19457468657265756d205369676e6564204d6573736167653a0a333200000000910152565b615a3e601c8092611c01565b615a4781615a0b565b0190565b90565b615a5a615a5f91610dac565b615a4b565b9052565b90615a79615a72602093615a32565b8092615a4e565b0190565b67ffffffffffffffff8111615a9b57615a976020916108a9565b0190565b6108b3565b90929192615ab5615ab082615a7d565b61158a565b93818552602085019082840111615ad157615acf926115eb565b565b6115c4565b615ae1913691615aa0565b90565b5f7f496e76616c6964207369676e6174757265000000000000000000000000000000910152565b615b1860116020926109c5565b615b2181615ae4565b0190565b615b3a9060208101905f818303910152615b0b565b90565b15615b4457565b615b4c610392565b62461bcd60e51b815280615b6260048201615b25565b0390fd5b9094615c04615c1c91615bfe615c2799615bd6615be588615baf8d615ba08d8f8d9395919091615b94610392565b968795602087016159d5565b602082018103825203826108c7565b615bc1615bbb826138f9565b916138f3565b20615bca610392565b92839160208301615a63565b602082018103825203826108c7565b615bf7615bf1826138f9565b916138f3565b2092615ad6565b90616bfb565b615c16615c10336103df565b916103df565b14615b3d565b9333919293946165e7565b565b90615c38969594939291615931565b565b909182615c4a81615c5193611c01565b80936115eb565b0190565b615c669060209493615c6d93615c3a565b8092611c32565b0190565b9091615c8890615c7f610392565b93849384615c55565b03902090565b9091615c9992615c71565b90565b92615cc1615cc99392615cbc615cce96615cb461273f565b506009611bd5565b611beb565b919091615c8e565b61092e565b90565b615cd9614630565b50615ce4600161254e565b90565b615cf19051611004565b90565b90565b615d0b615d06615d1092615cf4565b610739565b610544565b90565b60207f6c00000000000000000000000000000000000000000000000000000000000000917f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76615f8201520152565b615d6d60216040926109c5565b615d7681615d13565b0190565b615d8f9060208101905f818303910152615d60565b90565b15615d9957565b615da1610392565b62461bcd60e51b815280615db760048201615d7a565b0390fd5b90615e6c615e67615e719333615dec615de6615de1615ddc60078690611270565b61254e565b6103df565b916103df565b148015615f2a575b615dfd9061502a565b615e1b615e16615e0f60038490610e73565b8690610ebd565b614307565b615e2760608201615ce7565b615e3a615e346003611004565b91611004565b03615e74575b50615e5f615e58615e53600584906132c5565b6132db565b8590616bc1565b5060046132c5565b6132db565b616bc1565b50565b615ef090615ec4615eb4615e878561624b565b615eae615ea96020615ea2615e9d5f8601614434565b614441565b930161440b565b61445d565b90612889565b615ebe600a615cf7565b90612889565b615ecf5f8301613a14565b615ee1615edb5f612c53565b91610544565b119182615ef6575b5050615d92565b5f615e40565b615f21919250615f15615f1b91615f0f5f429201613a14565b9061538c565b92610544565b91610544565b10155f80615ee9565b50615dfd33615f48615f42615f3d614634565b6103df565b916103df565b149050615df4565b90615f7a615f7f91615f606135fd565b50615f75615f6d8561624b565b946003610e73565b610ebd565b614307565b615f8a5f8201613a14565b615f9c615f965f612c53565b91610544565b14615fd757615fcd615fc85f615fc1615fd394615fbb83429201613a14565b9061538c565b9401614434565b614441565b91610544565b1090565b50505f90565b615fee90615fe9616363565b615ff0565b565b615ffb81600161262b565b616003614634565b906160376160317f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e2270093610eb1565b91610eb1565b91616040610392565b8061604a8161043b565b0390a3565b61605890615fdd565b565b5f61609961609f936160913361608b61608561608061607b60078a90611270565b61254e565b6103df565b916103df565b146127c6565b926002612218565b016151a2565b565b5f7f4e6f742072656769737465726564000000000000000000000000000000000000910152565b6160d5600e6020926109c5565b6160de816160a1565b0190565b6160f79060208101905f8183039101526160c8565b90565b1561610157565b616109610392565b62461bcd60e51b81528061611f600482016160e2565b0390fd5b61615f336161596161537f00000000000000000000000000000000000000000000000000000000000000006103df565b916103df565b14612511565b616185616180616179616174600685906132c5565b6132db565b8490616bc1565b6160fa565b6161a361619c616197600484906132c5565b6132db565b8390616bc1565b50906161d86161d27f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e9361073c565b91610eb1565b916161e1610392565b806161eb8161043b565b0390a3565b9061623d6162345f6162006126d4565b9461621761620f838301610ef4565b83880161425c565b61622e616225838301610f21565b6020880161426a565b01612242565b60408401614a67565b565b616248906161f0565b90565b6162626162679161625a61271f565b506002612218565b61623f565b6162725f8201614434565b61628461627e5f615403565b916103a4565b146162ca575b6162966020820161440b565b6162a86162a25f614418565b9161049f565b146162b1575b90565b6162c56162bc6114dd565b6020830161426a565b6162ae565b6162dd6162d5610ac2565b5f830161425c565b61628a565b6162eb90610e89565b90565b6163026162fd616307926103d4565b610739565b610544565b90565b61631e61631961632392610544565b612608565b610dac565b90565b90565b9061635b61635561635061634b5f616360966163436135fd565b5001946162e2565b6162ee565b61630a565b91616326565b616cc6565b90565b61636b614634565b61638461637e616379616a6f565b6103df565b916103df565b0361638b57565b6163ad616396616a6f565b5f91829163118cdaa760e01b835260048301610b83565b0390fd5b6163c85f6163cd926163c161273f565b5001616326565b616d29565b90565b6163dc6163e191610912565b61290f565b90565b6163f86163f36163fd92610544565b610739565b6103d4565b90565b61642b616426616435936164215f6164309561641a614630565b5001616326565b616d9b565b6163d0565b6163e4565b610ea5565b90565b9061646a61646461645f61645a5f61646f966164526135fd565b5001946162e2565b6162ee565b61630a565b91616326565b616dbc565b90565b5f7f4f70657261746f7220697320736c617368656400000000000000000000000000910152565b6164a660136020926109c5565b6164af81616472565b0190565b6164c89060208101905f818303910152616499565b90565b156164d257565b6164da610392565b62461bcd60e51b8152806164f0600482016164b3565b0390fd5b6164fd90610dac565b90565b61650990610912565b90565b9061652161651c616528926164f4565b616500565b8254612f93565b9055565b616535906103a4565b67ffffffffffffffff811461654a5760010190565b612875565b90565b61656661656161656b9261654f565b610739565b61049f565b90565b91602061658f92949361658860408201965f830190610fd4565b0190610547565b565b61659a90610e89565b90565b6165a690616591565b90565b6165b290610ea5565b90565b6040906165de6165e594969593966165d460608401985f850190610b76565b6020830190610adb565b0190610adb565b565b949293919361660a6166056165fe60038990610e73565b8790610ebd565b6148a0565b936166148761624b565b9361663e61662460018801610f4e565b6166376166316003611004565b91611004565b14156164cb565b61665c61665561665060058b906132c5565b6132db565b8890616329565b50616731604061666e60018901610f4e565b9661667b425f8b01612fa9565b6166a5616689858790615ad6565b61669b616695826138f9565b916138f3565b2060028b0161650c565b6166ba6166b15f614418565b60018b01614dfd565b6166d860018a016166d26166cd82610ef4565b61652c565b906148df565b6166e06137b3565b50856166f46166ee5f614418565b9161049f565b145f146169b55761670b5f995b60018b9101613312565b8761671f6167196002611004565b91611004565b1480616999575b61692b575b01614b54565b80616907575b6168f1575b505085918591924261678061677a6167747f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b99461073c565b9461073c565b94610eb1565b9461679561678c610392565b9283928361656e565b0390a4806167ab6167a584611004565b91611004565b0361689b575b50506167bd600b61254e565b6167d76167d16167cc5f61257a565b6103df565b916103df565b036167e1575b5050565b6167fb6167f66167f1600b61254e565b61659d565b6165a9565b9163d47853b691909261680d426148a3565b92813b15616896575f6168339161683e8296616827610392565b98899788968795614673565b8552600485016165b5565b03925af1908161686a575b50155f14616865576001616860575b5b5f806167dd565b616858565b616859565b616889905f3d811161688f575b61688181836108c7565b810190614679565b5f616849565b503d616877565b61466f565b838391926168d26168cc7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361073c565b93610eb1565b936168e76168de610392565b92839283614e1d565b0390a35f806167b1565b616900918891889091926171dd565b5f8061673c565b50616913818390612d0f565b61692561691f5f612c53565b91610544565b11616737565b61694861694161693c8d60046132c5565b6132db565b8b90616329565b508a8a61697e6169787fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361073c565b91610eb1565b91616987610392565b806169918161043b565b0390a361672b565b50886169ae6169a86002611004565b91611004565b1415616726565b856169c96169c36064616552565b9161049f565b105f146169dc5761670b6001995b616701565b61670b6001996169f48d8d8b908b908a928c94616e91565b6169d7565b91906008616a19910291616a1360018060a01b03846128e6565b926128e6565b9181191691161790565b9190616a39616a34616a4193610eb1565b612628565b9083546169f9565b9055565b616a5791616a51614630565b91616a23565b565b616a6d90616a685f6001616a45565b61739b565b565b616a77614630565b503390565b616a8590610544565b5f198114616a935760010190565b612875565b616aa290516103df565b90565b93919293616ab16134ce565b50616ac5616ac085849061538c565b61350c565b92616acf5f612c53565b925b80616ae4616ade88610544565b91610544565b1015616b5257616b08616b01616afc600586906132c5565b6132db565b8290616400565b616b1484828a916173fa565b616b28575b50616b2390612c6f565b616ad1565b616b239194616b46616b4b92616b418991849092613533565b613553565b616a7c565b9390616b19565b509450509150616b618261350c565b92616b6b5f612c53565b5b80616b7f616b7986610544565b91610544565b1015616bbb57616bb690616bb1616b9f616b9a868490613533565b616a98565b616bac8891849092613533565b613553565b612c6f565b616b6c565b50915050565b90616bf3616bed616be8616be35f616bf896616bdb6135fd565b5001946162e2565b6162ee565b61630a565b91616326565b617546565b90565b616c1a91616c1191616c0b614630565b50617673565b90929192617733565b90565b90565b5f5260205f2090565b5490565b616c3681616c29565b821015616c5057616c48600191616c20565b910201905f90565b61076e565b9190616c6b616c66616c73936164f4565b616500565b9083546128ea565b9055565b9081549168010000000000000000831015616ca75782616c9f916001616ca595018155616c2d565b90616c55565b565b6108b3565b5490565b90616cba906164f4565b5f5260205260405f2090565b616cce6135fd565b50616ce3616cdd828490616dbc565b156104b2565b5f14616d2357616d19616d1e92616d05616cfe5f8501616c1d565b8290616c77565b6001616d125f8501616cac565b9301616cb0565b612fa9565b600190565b50505f90565b5f616d3d91616d3661273f565b5001616cac565b90565b5f90565b5f5260205f2090565b616d5681616cac565b821015616d7057616d68600191616d44565b910201905f90565b61076e565b616d85906008616d8a9302610b32565b610f5b565b90565b90616d989154616d75565b90565b616db9915f616db392616dac616d40565b5001616d4d565b90616d8d565b90565b616dda916001616dd592616dce6135fd565b5001616cb0565b61092e565b616dec616de65f612c53565b91610544565b141590565b616e05616e00616e0a926111b9565b610739565b61049f565b90565b616e19616e1f916103a4565b916103a4565b90039067ffffffffffffffff8211616e3357565b612875565b5f7f50726f746f636f6c2076696f6c6174696f6e207265706f727465640000000000910152565b616e6c601b6020926109c5565b616e7581616e38565b0190565b616e8e9060208101905f818303910152616e5f565b90565b9350509250616ea9616ea360c8616df1565b9161049f565b1015616eb4575b5050565b616ebd426148a3565b616edb616ed6616ecf600c859061433f565b8590614355565b610ef4565b80616eee616ee85f615403565b916103a4565b14908115616f74575b50616f03575b50616eb0565b616f2290616f1d616f16600c859061433f565b8590614355565b6148df565b90616f56616f507f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361073c565b91610eb1565b91616f5f610392565b80616f6981616e79565b0390a35f8080616efd565b616f7f915082616e0d565b616f98616f92616f8d610e25565b6103a4565b916103a4565b10155f616ef7565b90565b616fb7616fb2616fbc92616fa0565b610739565b610544565b90565b90929192616fd4616fcf826115c8565b61158a565b93818552602085019082840111616ff057616fee926109ce565b565b6115c4565b9080601f830112156170135781602061701093519101616fbf565b90565b61059f565b90505190617025826106e9565b565b91909160408184031261707a5761703e604061158a565b925f8201519167ffffffffffffffff8311617075576170628261706e948301616ff5565b5f860152602001617018565b6020830152565b6115c0565b6115bc565b92919061709361708e8261159f565b61158a565b93818552602080860192028101918383116170ea5781905b8382106170b9575050505050565b815167ffffffffffffffff81116170e5576020916170da8784938701617027565b8152019101906170ab565b61059f565b6105a7565b9080601f8301121561710d5781602061710a9351910161707f565b90565b61059f565b90602082820312617142575f82015167ffffffffffffffff811161713d5761713a92016170ef565b90565b6103a0565b61039c565b60209181520190565b919061716a816171638161716f95617147565b80956115eb565b6108a9565b0190565b909161718a9260208301925f818503910152617150565b90565b617197603261141f565b90565b9493916060916171db946171c66171d3936171bc60808b01945f8c0190610adb565b60208a0190610b76565b8782036040890152610cd3565b940190610547565b565b916171e9818590612d0f565b6171fb6171f55f612c53565b91610544565b146173955761720b818590612d0f565b61721f61721961c350616fa3565b91610544565b1161738f575f61722d613453565b94617237306137e2565b6172596331e3bd1b94929461726461724d610392565b96879586948594614673565b845260048401617173565b03915afa80915f9261736b575b50155f146173625750600161735d575b61728a83610c42565b6172a361729d61729861718d565b610544565b91610544565b115f1461734f576172b261718d565b5b6172bc306137e2565b906365a6936e93929490823b1561734a575f946172f786926172ec946172e0610392565b998a9889978896614673565b86526004860161719a565b03925af1908161731e575b50155f14617319576001617314575b5b565b617311565b617312565b61733d905f3d8111617343575b61733581836108c7565b810190614679565b5f617302565b503d61732b565b61466f565b61735883610c42565b6172b3565b505050565b90925091617281565b6173889192503d805f833e61738081836108c7565b810190617112565b905f617271565b50505050565b50505050565b6173a45f61254e565b6173ae825f61262b565b906173e26173dc7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e093610eb1565b91610eb1565b916173eb610392565b806173f58161043b565b0390a3565b6174026135fd565b5061742a61742461741d617418600685906132c5565b6132db565b8490616438565b156104b2565b6174cc5761744a91617440617445926003610e73565b610ebd565b614307565b6174555f8201613a14565b6174676174615f612c53565b91610544565b1480156174a6575b6174a05761749561748f61749b926174895f429201613a14565b9061538c565b92610544565b91610544565b101590565b50505f90565b506174b360608201615ce7565b6174c66174c06003611004565b91611004565b1461746f565b5050505f90565b6174e76174e26174ec926150f4565b610739565b610544565b90565b634e487b7160e01b5f52603160045260245ffd5b6175159161750f616d40565b91616c55565b565b61752081616c29565b801561754157600190039061753e6175388383616c2d565b90617503565b55565b6174ef565b61754e6135fd565b50617565617560600183018490616cb0565b61092e565b90816175796175735f612c53565b91610544565b14155f14617645576175f79260016175f292846175a05f9661759a856174d3565b9061538c565b6175bd6175ae888501616cac565b6175b7866174d3565b9061538c565b816175d06175ca83610544565b91610544565b036175fc575b5050506175ec6175e7868301616c1d565b617517565b01616cb0565b612950565b600190565b61763d9261762f61761b617615617638948c8901616d4d565b90616d8d565b9361762985918c8901616d4d565b90616c55565b91858501616cb0565b612fa9565b5f80806175d6565b5050505f90565b5f90565b90565b61766761766261766c92617650565b610739565b610544565b90565b5f90565b91909161767e614630565b5061768761764c565b50617690616d40565b5061769a836138f9565b6176ad6176a76041617653565b91610544565b145f146176f4576176ed91926176c1616d40565b506176ca616d40565b506176d361766f565b506020810151606060408301519201515f1a90919261787d565b9192909190565b506176fe5f61257a565b9061771261770d6002946138f9565b61630a565b91929190565b6004111561772257565b610fe1565b9061773182617718565b565b806177466177405f617727565b91617727565b145f14617751575050565b8061776561775f6001617727565b91617727565b145f14617788575f63f645eedf60e01b8152806177846004820161043b565b0390fd5b8061779c6177966002617727565b91617727565b145f146177ca576177c66177af836163d0565b5f91829163fce698f760e01b835260048301610554565b0390fd5b6177dd6177d76003617727565b91617727565b146177e55750565b617800905f9182916335e2f38360e21b835260048301610dbc565b0390fd5b90565b61781b61781661782092617804565b610739565b610544565b90565b61785861785f9461784e606094989795617844608086019a5f870190610daf565b6020850190610fd4565b6040830190610daf565b0190610daf565b565b61787561787061787a9261255b565b612608565b610dac565b90565b939293617888614630565b5061789161764c565b5061789a616d40565b506178a4856163d0565b6178d66178d07f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0617807565b91610544565b1161796357906178f9602094955f949392936178f0610392565b94859485617823565b838052039060015afa1561795e576179115f51612608565b8061792c6179266179215f61257a565b6103df565b916103df565b14617942575f9161793c5f617861565b91929190565b5061794c5f61257a565b6001916179585f617861565b91929190565b6146ab565b50505061796f5f61257a565b906003929192919056fea164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\xC0`@R4a\0^Wa\0\x1Aa\0\x14a\x012V[\x90a\x02\x0FV[a\0\"a\0cV[ay\x86a\x04\xCC\x829`\x80Q\x81a\r\x8A\x01R`\xA0Q\x81\x81\x81a\x13\x0B\x01R\x81\x81a&^\x01R\x81\x81a3>\x01R\x81\x81aRD\x01Raa/\x01Ray\x86\x90\xF3[a\0iV[`@Q\x90V[_\x80\xFD[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\0\x95\x90a\0mV[\x81\x01\x90\x81\x10`\x01\x80`@\x1B\x03\x82\x11\x17a\0\xADW`@RV[a\0wV[\x90a\0\xC5a\0\xBEa\0cV[\x92\x83a\0\x8BV[V[_\x80\xFD[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\0\xDF\x90a\0\xCBV[\x90V[a\0\xEB\x81a\0\xD6V[\x03a\0\xF2WV[_\x80\xFD[\x90PQ\x90a\x01\x03\x82a\0\xE2V[V[\x91\x90`@\x83\x82\x03\x12a\x01-W\x80a\x01!a\x01*\x92_\x86\x01a\0\xF6V[\x93` \x01a\0\xF6V[\x90V[a\0\xC7V[a\x01Pa~R\x808\x03\x80a\x01E\x81a\0\xB2V[\x92\x839\x81\x01\x90a\x01\x05V[\x90\x91V[\x90V[a\x01ka\x01fa\x01p\x92a\0\xCBV[a\x01TV[a\0\xCBV[\x90V[a\x01|\x90a\x01WV[\x90V[a\x01\x88\x90a\x01sV[\x90V[\x90V[a\x01\x97\x90a\x01\x8BV[\x90RV[\x90V[a\x01\xA7\x90a\x01\x9BV[\x90RV[a\x01\xB4\x90a\0\xD6V[\x90RV[\x90\x95\x94\x92a\x02\x03\x94a\x01\xF2a\x01\xFC\x92a\x01\xE8`\x80\x96a\x01\xDE`\xA0\x88\x01\x9C_\x89\x01\x90a\x01\x8EV[` \x87\x01\x90a\x01\x8EV[`@\x85\x01\x90a\x01\x8EV[``\x83\x01\x90a\x01\x9EV[\x01\x90a\x01\xABV[V[` \x01\x90V[Q\x90V[\x90a\x02\x19\x90a\x02\xCCV[`\xA0R\x7F\x8Bs\xC3\xC6\x9B\xB8\xFE=Q.\xCCL\xF7Y\xCCy#\x9F{\x17\x9B\x0F\xFA\xCA\xA9\xA7]R+9@\x0Fa\x02\xB4\x7F6\xFF\xC2X\xC8e\x19:\xE1\x0C<\xF6@E\n\xB7r\xFD\xB8\xDA\x1D\xFC\xAExb\xAD\x12\x05\xA5V\x7FL\x91a\x02\xA5\x7F\xC8\x9E\xFD\xAAT\xC0\xF2\x0Cz\xDFa(\x82\xDF\tP\xF5\xA9Qc~\x03\x07\xCD\xCBLg/)\x8B\x8B\xC6Fa\x02\x900a\x01\x7FV[\x91a\x02\x99a\0cV[\x96\x87\x95` \x87\x01a\x01\xB8V[` \x82\x01\x81\x03\x82R\x03\x82a\0\x8BV[a\x02\xC6a\x02\xC0\x82a\x02\x0BV[\x91a\x02\x05V[ `\x80RV[a\x02\xD5\x90a\x03\x17V[V[\x90V[a\x02\xEEa\x02\xE9a\x02\xF3\x92a\x02\xD7V[a\x01TV[a\0\xCBV[\x90V[a\x02\xFF\x90a\x02\xDAV[\x90V[\x91\x90a\x03\x15\x90_` \x85\x01\x94\x01\x90a\x01\xABV[V[\x80a\x032a\x03,a\x03'_a\x02\xF6V[a\0\xD6V[\x91a\0\xD6V[\x14a\x03BWa\x03@\x90a\x03\xE0V[V[a\x03ea\x03N_a\x02\xF6V[_\x91\x82\x91c\x1EO\xBD\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x03\x02V[\x03\x90\xFD[\x1B\x90V[\x91\x90`\x08a\x03\x8D\x91\x02\x91a\x03\x87`\x01\x80`\xA0\x1B\x03\x84a\x03iV[\x92a\x03iV[\x91\x81\x19\x16\x91\x16\x17\x90V[a\x03\xA0\x90a\x01sV[\x90V[\x90V[\x91\x90a\x03\xBCa\x03\xB7a\x03\xC4\x93a\x03\x97V[a\x03\xA3V[\x90\x83Ta\x03mV[\x90UV[_\x90V[a\x03\xDE\x91a\x03\xD8a\x03\xC8V[\x91a\x03\xA6V[V[a\x03\xF4\x90a\x03\xEF_`\x01a\x03\xCCV[a\x04lV[V[_\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x04\x12a\x04\x17\x91a\x03\xF6V[a\x03\xFBV[\x90V[a\x04$\x90Ta\x04\x06V[\x90V[_\x1B\x90V[\x90a\x04=`\x01\x80`\xA0\x1B\x03\x91a\x04'V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a\x04\\a\x04Wa\x04c\x92a\x03\x97V[a\x03\xA3V[\x82Ta\x04,V[\x90UV[_\x01\x90V[a\x04u_a\x04\x1AV[a\x04\x7F\x82_a\x04GV[\x90a\x04\xB3a\x04\xAD\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x03\x97V[\x91a\x03\x97V[\x91a\x04\xBCa\0cV[\x80a\x04\xC6\x81a\x04gV[\x03\x90\xA3V\xFE`\x80`@R`\x046\x10\x15a\0\x13W[a$\xB4V[a\0\x1D_5a\x03\x8CV[\x80c\x05w\x85P\x14a\x03\x87W\x80c\x07X#o\x14a\x03\x82W\x80c\x0Cviz\x14a\x03}W\x80c\x19\x1C\xBD\x1A\x14a\x03xW\x80c\x1E\x8F^\xE5\x14a\x03sW\x80c \x81)V\x14a\x03nW\x80c\"\xF1\xEC\x93\x14a\x03iW\x80c,\x95v\x88\x14a\x03dW\x80c-\xAE\x18\x85\x14a\x03_W\x80c1\xE3\xBD\x1B\x14a\x03ZW\x80c6D\xE5\x15\x14a\x03UW\x80c:\xC3\xCB\xE6\x14a\x03PW\x80c>n4\xA7\x14a\x03KW\x80c?\xD6,m\x14a\x03FW\x80c@#Z\x9C\x14a\x03AW\x80cH\xF4\xDA \x14a\x03<W\x80cV\x85\xCFh\x14a\x037W\x80cV\xC4\xE1}\x14a\x032W\x80cY\xDC\xEA\x12\x14a\x03-W\x80cZ\x93m\xC6\x14a\x03(W\x80c\\\xCE\x98\xA6\x14a\x03#W\x80c`vC\x9C\x14a\x03\x1EW\x80c`\xCF\t\x91\x14a\x03\x19W\x80ca\xD6\xB8l\x14a\x03\x14W\x80cb\xC7\xE8\xFC\x14a\x03\x0FW\x80ce\xA6\x93n\x14a\x03\nW\x80ck\xFE\x06\xA6\x14a\x03\x05W\x80cqP\x18\xA6\x14a\x03\0W\x80cq\xE78\x8C\x14a\x02\xFBW\x80cv9\xD2'\x14a\x02\xF6W\x80cy\xBAP\x97\x14a\x02\xF1W\x80c{\x9Fd\xB2\x14a\x02\xECW\x80c\x81\xBE\xAC.\x14a\x02\xE7W\x80c\x84\xEFs\"\x14a\x02\xE2W\x80c\x8D\xA5\xCB[\x14a\x02\xDDW\x80c\x96hl\x1E\x14a\x02\xD8W\x80c\x9C\xBD\xAE\"\x14a\x02\xD3W\x80c\xAD\xFF\x83\x0C\x14a\x02\xCEW\x80c\xAEG\n\x85\x14a\x02\xC9W\x80c\xB0t\xE9\xDD\x14a\x02\xC4W\x80c\xB9\x9FgY\x14a\x02\xBFW\x80c\xBA\x1F\xB1\x03\x14a\x02\xBAW\x80c\xC1\xEF\x9D\xDF\x14a\x02\xB5W\x80c\xC5\xD9`\xBB\x14a\x02\xB0W\x80c\xCF\xE3GI\x14a\x02\xABW\x80c\xD4\x13\xA5\x80\x14a\x02\xA6W\x80c\xD5Q\x16,\x14a\x02\xA1W\x80c\xDACZ|\x14a\x02\x9CW\x80c\xE3\x0C9x\x14a\x02\x97W\x80c\xE6\\\xAF\xCB\x14a\x02\x92W\x80c\xEE\x1C\x03\x90\x14a\x02\x8DW\x80c\xF2\xFD\xE3\x8B\x14a\x02\x88W\x80c\xF9\x10\x7F;\x14a\x02\x83W\x80c\xF9\xF1gb\x14a\x02~Wc\xFF\xCF\x08\xF0\x03a\0\x0EWa$\x80V[a$KV[a#\xE8V[a#\x88V[a#RV[a#\x1EV[a\"\xE9V[a\"\xB1V[a!\xDFV[a!\xA5V[a \xE7V[a \xA5V[a pV[a\x1FFV[a\x1F\x12V[a\x1E\xA5V[a\x1EkV[a\x1D\xA0V[a\x1C\xD9V[a\x1BPV[a\x1A\x96V[a\x1AcV[a\x1A,V[a\x19\x97V[a\x19dV[a\x19.V[a\x18\xF8V[a\x18<V[a\x18\x07V[a\x17\x99V[a\x15TV[a\x15\nV[a\x14\x88V[a\x14SV[a\x13\xE5V[a\x13-V[a\x12\xD4V[a\x12\x9FV[a\x12:V[a\x11\xF0V[a\x11\x84V[a\x10\xB0V[a\x10vV[a\x0E>V[a\r\xD1V[a\rRV[a\x0B\x98V[a\n\xFDV[a\nZV[a\x06\xB6V[a\x06dV[a\x060V[a\x05iV[a\x05\x0FV[a\x04@V[`\xE0\x1C\x90V[`@Q\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x03\xBA\x81a\x03\xA4V[\x03a\x03\xC1WV[_\x80\xFD[\x90P5\x90a\x03\xD2\x82a\x03\xB1V[V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x03\xE8\x90a\x03\xD4V[\x90V[a\x03\xF4\x81a\x03\xDFV[\x03a\x03\xFBWV[_\x80\xFD[\x90P5\x90a\x04\x0C\x82a\x03\xEBV[V[\x91\x90`@\x83\x82\x03\x12a\x046W\x80a\x04*a\x043\x92_\x86\x01a\x03\xC5V[\x93` \x01a\x03\xFFV[\x90V[a\x03\x9CV[_\x01\x90V[4a\x04oWa\x04Ya\x04S6`\x04a\x04\x0EV[\x90a&KV[a\x04aa\x03\x92V[\x80a\x04k\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90` \x82\x82\x03\x12a\x04\x8DWa\x04\x8A\x91_\x01a\x03\xC5V[\x90V[a\x03\x9CV[a\x04\x9B\x90a\x03\xA4V[\x90RV[`\xFF\x16\x90V[a\x04\xAE\x90a\x04\x9FV[\x90RV[\x15\x15\x90V[a\x04\xC0\x90a\x04\xB2V[\x90RV[\x90`@\x80a\x04\xF8\x93a\x04\xDC_\x82\x01Q_\x86\x01\x90a\x04\x92V[a\x04\xEE` \x82\x01Q` \x86\x01\x90a\x04\xA5V[\x01Q\x91\x01\x90a\x04\xB7V[V[\x91\x90a\x05\r\x90_``\x85\x01\x94\x01\x90a\x04\xC4V[V[4a\x05?Wa\x05;a\x05*a\x05%6`\x04a\x04tV[a'*V[a\x052a\x03\x92V[\x91\x82\x91\x82a\x04\xFAV[\x03\x90\xF3[a\x03\x98V[\x90V[a\x05P\x90a\x05DV[\x90RV[\x91\x90a\x05g\x90_` \x85\x01\x94\x01\x90a\x05GV[V[4a\x05\x9AWa\x05\x96a\x05\x85a\x05\x7F6`\x04a\x04\x0EV[\x90a'CV[a\x05\x8Da\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x05\xE5W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x05\xE0W` \x01\x92` \x83\x02\x84\x01\x11a\x05\xDBWV[a\x05\xA7V[a\x05\xA3V[a\x05\x9FV[\x91\x90\x91`@\x81\x84\x03\x12a\x06+Wa\x06\x03\x83_\x83\x01a\x03\xC5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x06&Wa\x06\"\x92\x01a\x05\xABV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[4a\x06_Wa\x06Ia\x06C6`\x04a\x05\xEAV[\x91a0\xCCV[a\x06Qa\x03\x92V[\x80a\x06[\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x06\x93Wa\x06}a\x06w6`\x04a\x04\x0EV[\x90a32V[a\x06\x85a\x03\x92V[\x80a\x06\x8F\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90` \x82\x82\x03\x12a\x06\xB1Wa\x06\xAE\x91_\x01a\x03\xFFV[\x90V[a\x03\x9CV[4a\x06\xE4Wa\x06\xCEa\x06\xC96`\x04a\x06\x98V[a4HV[a\x06\xD6a\x03\x92V[\x80a\x06\xE0\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[a\x06\xF2\x81a\x05DV[\x03a\x06\xF9WV[_\x80\xFD[\x90P5\x90a\x07\n\x82a\x06\xE9V[V[\x91\x90`@\x83\x82\x03\x12a\x074W\x80a\x07(a\x071\x92_\x86\x01a\x03\xC5V[\x93` \x01a\x06\xFDV[\x90V[a\x03\x9CV[\x90V[a\x07Pa\x07Ka\x07U\x92a\x03\xA4V[a\x079V[a\x03\xA4V[\x90V[\x90a\x07b\x90a\x07<V[_R` R`@_ \x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[T\x90V[_R` _ \x90V[_R` _ \x90V[a\x07\xA1\x81a\x07\x82V[\x82\x10\x15a\x07\xBBWa\x07\xB3`\x04\x91a\x07\x86V[\x91\x02\x01\x90_\x90V[a\x07nV[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x90`\x01`\x02\x83\x04\x92\x16\x80\x15a\x07\xF4W[` \x83\x10\x14a\x07\xEFWV[a\x07\xC0V[\x91`\x7F\x16\x91a\x07\xE4V[` \x91\x81R\x01\x90V[_R` _ \x90V[\x90_\x92\x91\x80T\x90a\x08*a\x08#\x83a\x07\xD4V[\x80\x94a\x07\xFEV[\x91`\x01\x81\x16\x90\x81_\x14a\x08\x81WP`\x01\x14a\x08EW[PPPV[a\x08R\x91\x92\x93\x94Pa\x08\x07V[\x91_\x92[\x81\x84\x10a\x08iWPP\x01\x90_\x80\x80a\x08@V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a\x08VV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a\x08@V[\x90a\x08\xA6\x91a\x08\x10V[\x90V[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\x08\xD1\x90a\x08\xA9V[\x81\x01\x90\x81\x10g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x17a\x08\xEBW`@RV[a\x08\xB3V[\x90a\t\x10a\t\t\x92a\t\0a\x03\x92V[\x93\x84\x80\x92a\x08\x9CV[\x03\x83a\x08\xC7V[V[_\x1C\x90V[\x90V[a\t&a\t+\x91a\t\x12V[a\t\x17V[\x90V[a\t8\x90Ta\t\x1AV[\x90V[`\xFF\x16\x90V[a\tMa\tR\x91a\t\x12V[a\t;V[\x90V[a\t_\x90Ta\tAV[\x90V[a\tm\x90`\x08a\x07XV[\x90a\tw\x82a\x07\x82V[\x81\x10\x15a\t\xBDWa\t\x87\x91a\x07\x98V[P\x90a\t\x94_\x83\x01a\x08\xF0V[\x91a\t\xA1`\x01\x82\x01a\t.V[\x91a\t\xBA`\x03a\t\xB3`\x02\x85\x01a\t.V[\x93\x01a\tUV[\x90V[_\x80\xFD[Q\x90V[` \x91\x81R\x01\x90V[\x90\x82_\x93\x92\x82^\x01RV[a\t\xF8a\n\x01` \x93a\n\x06\x93a\t\xEF\x81a\t\xC1V[\x93\x84\x80\x93a\t\xC5V[\x95\x86\x91\x01a\t\xCEV[a\x08\xA9V[\x01\x90V[a\n\x13\x90a\x04\xB2V[\x90RV[a\nQa\nX\x94a\nGa\n<``\x95\x99\x98\x96\x99`\x80\x86\x01\x90\x86\x82\x03_\x88\x01Ra\t\xD9V[\x98` \x85\x01\x90a\x05GV[`@\x83\x01\x90a\x05GV[\x01\x90a\n\nV[V[4a\n\x8FWa\n\x8Ba\nva\np6`\x04a\x07\x0CV[\x90a\tbV[\x90a\n\x82\x94\x92\x94a\x03\x92V[\x94\x85\x94\x85a\n\x17V[\x03\x90\xF3[a\x03\x98V[_\x91\x03\x12a\n\x9EWV[a\x03\x9CV[\x90V[a\n\xBAa\n\xB5a\n\xBF\x92a\n\xA3V[a\x079V[a\x03\xA4V[\x90V[a\n\xCDa\x01,a\n\xA6V[\x90V[a\n\xD8a\n\xC2V[\x90V[a\n\xE4\x90a\x03\xA4V[\x90RV[\x91\x90a\n\xFB\x90_` \x85\x01\x94\x01\x90a\n\xDBV[V[4a\x0B-Wa\x0B\r6`\x04a\n\x94V[a\x0B)a\x0B\x18a\n\xD0V[a\x0B a\x03\x92V[\x91\x82\x91\x82a\n\xE8V[\x03\x90\xF3[a\x03\x98V[\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x0BQ\x90`\x08a\x0BV\x93\x02a\x0B2V[a\x0B6V[\x90V[\x90a\x0Bd\x91Ta\x0BAV[\x90V[a\x0Bs`\x0B_\x90a\x0BYV[\x90V[a\x0B\x7F\x90a\x03\xDFV[\x90RV[\x91\x90a\x0B\x96\x90_` \x85\x01\x94\x01\x90a\x0BvV[V[4a\x0B\xC8Wa\x0B\xA86`\x04a\n\x94V[a\x0B\xC4a\x0B\xB3a\x0BgV[a\x0B\xBBa\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x0C\x07W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x0C\x02W` \x01\x92`\x01\x83\x02\x84\x01\x11a\x0B\xFDWV[a\x05\xA7V[a\x05\xA3V[a\x05\x9FV[\x90` \x82\x82\x03\x12a\x0C=W_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0C8Wa\x0C4\x92\x01a\x0B\xCDV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x0Cta\x0C}` \x93a\x0C\x82\x93a\x0Ck\x81a\t\xC1V[\x93\x84\x80\x93a\x07\xFEV[\x95\x86\x91\x01a\t\xCEV[a\x08\xA9V[\x01\x90V[a\x0C\x8F\x90a\x05DV[\x90RV[\x90a\x0C\xBD\x90` \x80a\x0C\xB2`@\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\x0CUV[\x94\x01Q\x91\x01\x90a\x0C\x86V[\x90V[\x90a\x0C\xCA\x91a\x0C\x93V[\x90V[` \x01\x90V[\x90a\x0C\xE7a\x0C\xE0\x83a\x0CBV[\x80\x92a\x0CFV[\x90\x81a\x0C\xF8` \x83\x02\x84\x01\x94a\x0COV[\x92_\x91[\x83\x83\x10a\r\x0BWPPPPP\x90V[\x90\x91\x92\x93\x94` a\r-a\r'\x83\x85`\x01\x95\x03\x87R\x89Qa\x0C\xC0V[\x97a\x0C\xCDV[\x93\x01\x93\x01\x91\x93\x92\x90a\x0C\xFCV[a\rO\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x0C\xD3V[\x90V[4a\r\x83Wa\r\x7Fa\rna\rh6`\x04a\x0C\x0CV[\x90a4\x8DV[a\rva\x03\x92V[\x91\x82\x91\x82a\r:V[\x03\x90\xF3[a\x03\x98V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[\x90V[a\r\xB8\x90a\r\xACV[\x90RV[\x91\x90a\r\xCF\x90_` \x85\x01\x94\x01\x90a\r\xAFV[V[4a\x0E\x01Wa\r\xE16`\x04a\n\x94V[a\r\xFDa\r\xECa\r\x88V[a\r\xF4a\x03\x92V[\x91\x82\x91\x82a\r\xBCV[\x03\x90\xF3[a\x03\x98V[\x90V[a\x0E\x1Da\x0E\x18a\x0E\"\x92a\x0E\x06V[a\x079V[a\x03\xA4V[\x90V[a\x0E0a\x0E\x10a\x0E\tV[\x90V[a\x0E;a\x0E%V[\x90V[4a\x0EnWa\x0EN6`\x04a\n\x94V[a\x0Eja\x0EYa\x0E3V[a\x0Eaa\x03\x92V[\x91\x82\x91\x82a\n\xE8V[\x03\x90\xF3[a\x03\x98V[\x90a\x0E}\x90a\x07<V[_R` R`@_ \x90V[a\x0E\x9Da\x0E\x98a\x0E\xA2\x92a\x03\xD4V[a\x079V[a\x03\xD4V[\x90V[a\x0E\xAE\x90a\x0E\x89V[\x90V[a\x0E\xBA\x90a\x0E\xA5V[\x90V[\x90a\x0E\xC7\x90a\x0E\xB1V[_R` R`@_ \x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x0E\xECa\x0E\xF1\x91a\t\x12V[a\x0E\xD3V[\x90V[a\x0E\xFE\x90Ta\x0E\xE0V[\x90V[`@\x1C\x90V[`\xFF\x16\x90V[a\x0F\x19a\x0F\x1E\x91a\x0F\x01V[a\x0F\x07V[\x90V[a\x0F+\x90Ta\x0F\rV[\x90V[`H\x1C\x90V[`\xFF\x16\x90V[a\x0FFa\x0FK\x91a\x0F.V[a\x0F4V[\x90V[a\x0FX\x90Ta\x0F:V[\x90V[\x90V[a\x0Fja\x0Fo\x91a\t\x12V[a\x0F[V[\x90V[a\x0F|\x90Ta\x0F^V[\x90V[\x90a\x0F\x8Ea\x0F\x93\x92`\x03a\x0EsV[a\x0E\xBDV[a\x0F\x9E_\x82\x01a\t.V[\x91a\x0F\xAB`\x01\x83\x01a\x0E\xF4V[\x91a\x0F\xB8`\x01\x82\x01a\x0F!V[\x91a\x0F\xD1`\x02a\x0F\xCA`\x01\x85\x01a\x0FNV[\x93\x01a\x0FrV[\x90V[a\x0F\xDD\x90a\x04\x9FV[\x90RV[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[`\x05\x11\x15a\x0F\xFFWV[a\x0F\xE1V[\x90a\x10\x0E\x82a\x0F\xF5V[V[a\x10\x19\x90a\x10\x04V[\x90V[a\x10%\x90a\x10\x10V[\x90RV[\x90\x95\x94\x92a\x10t\x94a\x10ca\x10m\x92a\x10Y`\x80\x96a\x10O`\xA0\x88\x01\x9C_\x89\x01\x90a\x05GV[` \x87\x01\x90a\n\xDBV[`@\x85\x01\x90a\x0F\xD4V[``\x83\x01\x90a\x10\x1CV[\x01\x90a\r\xAFV[V[4a\x10\xABWa\x10\xA7a\x10\x92a\x10\x8C6`\x04a\x04\x0EV[\x90a\x0F\x7FV[\x91a\x10\x9E\x95\x93\x95a\x03\x92V[\x95\x86\x95\x86a\x10)V[\x03\x90\xF3[a\x03\x98V[4a\x10\xE0Wa\x10\xDCa\x10\xCBa\x10\xC66`\x04a\x04tV[a4\xA7V[a\x10\xD3a\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x11\x01\x90a\x03\xDFV[\x90RV[\x90a\x11\x12\x81` \x93a\x10\xF8V[\x01\x90V[` \x01\x90V[\x90a\x119a\x113a\x11,\x84a\x10\xE5V[\x80\x93a\x10\xE9V[\x92a\x10\xF2V[\x90_[\x81\x81\x10a\x11IWPPP\x90V[\x90\x91\x92a\x11ba\x11\\`\x01\x92\x86Qa\x11\x05V[\x94a\x11\x16V[\x91\x01\x91\x90\x91a\x11<V[a\x11\x81\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x11\x1CV[\x90V[4a\x11\xB4Wa\x11\xB0a\x11\x9Fa\x11\x9A6`\x04a\x04tV[a5aV[a\x11\xA7a\x03\x92V[\x91\x82\x91\x82a\x11lV[\x03\x90\xF3[a\x03\x98V[\x90V[a\x11\xD0a\x11\xCBa\x11\xD5\x92a\x11\xB9V[a\x079V[a\x05DV[\x90V[a\x11\xE2`\xC8a\x11\xBCV[\x90V[a\x11\xEDa\x11\xD8V[\x90V[4a\x12 Wa\x12\x006`\x04a\n\x94V[a\x12\x1Ca\x12\x0Ba\x11\xE5V[a\x12\x13a\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[\x91\x90a\x128\x90_` \x85\x01\x94\x01\x90a\n\nV[V[4a\x12kWa\x12ga\x12Va\x12P6`\x04a\x04\x0EV[\x90a6\x01V[a\x12^a\x03\x92V[\x91\x82\x91\x82a\x12%V[\x03\x90\xF3[a\x03\x98V[\x90a\x12z\x90a\x07<V[_R` R`@_ \x90V[a\x12\x9C\x90a\x12\x97`\x07\x91_\x92a\x12pV[a\x0BYV[\x90V[4a\x12\xCFWa\x12\xCBa\x12\xBAa\x12\xB56`\x04a\x04tV[a\x12\x86V[a\x12\xC2a\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[4a\x13\x04Wa\x13\0a\x12\xEFa\x12\xEA6`\x04a\x04tV[a6\x88V[a\x12\xF7a\x03\x92V[\x91\x82\x91\x82a\x11lV[\x03\x90\xF3[a\x03\x98V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[4a\x13]Wa\x13=6`\x04a\n\x94V[a\x13Ya\x13Ha\x13\tV[a\x13Pa\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[a\x13k\x81a\x04\x9FV[\x03a\x13rWV[_\x80\xFD[\x90P5\x90a\x13\x83\x82a\x13bV[V[\x90`\x80\x82\x82\x03\x12a\x13\xE0Wa\x13\x9C\x81_\x84\x01a\x03\xC5V[\x92a\x13\xAA\x82` \x85\x01a\x03\xC5V[\x92a\x13\xB8\x83`@\x83\x01a\x13vV[\x92``\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x13\xDBWa\x13\xD7\x92\x01a\x0B\xCDV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[4a\x14\x17Wa\x14\x01a\x13\xF86`\x04a\x13\x85V[\x93\x92\x90\x92a7|V[a\x14\ta\x03\x92V[\x80a\x14\x13\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90V[a\x143a\x14.a\x148\x92a\x14\x1CV[a\x079V[a\x05DV[\x90V[a\x14E`2a\x14\x1FV[\x90V[a\x14Pa\x14;V[\x90V[4a\x14\x83Wa\x14c6`\x04a\n\x94V[a\x14\x7Fa\x14na\x14HV[a\x14va\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[4a\x14\xB9Wa\x14\xB5a\x14\xA4a\x14\x9E6`\x04a\x04\x0EV[\x90a7\x8BV[a\x14\xACa\x03\x92V[\x91\x82\x91\x82a\x12%V[\x03\x90\xF3[a\x03\x98V[\x90V[a\x14\xD5a\x14\xD0a\x14\xDA\x92a\x14\xBEV[a\x079V[a\x04\x9FV[\x90V[a\x14\xE7`\x03a\x14\xC1V[\x90V[a\x14\xF2a\x14\xDDV[\x90V[\x91\x90a\x15\x08\x90_` \x85\x01\x94\x01\x90a\x0F\xD4V[V[4a\x15:Wa\x15\x1A6`\x04a\n\x94V[a\x156a\x15%a\x14\xEAV[a\x15-a\x03\x92V[\x91\x82\x91\x82a\x14\xF5V[\x03\x90\xF3[a\x03\x98V[\x91\x90a\x15R\x90_` \x85\x01\x94\x01\x90a\x10\x1CV[V[4a\x15\x85Wa\x15\x81a\x15pa\x15j6`\x04a\x04\x0EV[\x90a7\xB7V[a\x15xa\x03\x92V[\x91\x82\x91\x82a\x15?V[\x03\x90\xF3[a\x03\x98V[\x90a\x15\x9Da\x15\x96a\x03\x92V[\x92\x83a\x08\xC7V[V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x15\xB7W` \x80\x91\x02\x01\x90V[a\x08\xB3V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x15\xE6Wa\x15\xE2` \x91a\x08\xA9V[\x01\x90V[a\x08\xB3V[\x90\x82_\x93\x92\x827\x01RV[\x90\x92\x91\x92a\x16\x0Ba\x16\x06\x82a\x15\xC8V[a\x15\x8AV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a\x16'Wa\x16%\x92a\x15\xEBV[V[a\x15\xC4V[\x90\x80`\x1F\x83\x01\x12\x15a\x16JW\x81` a\x16G\x935\x91\x01a\x15\xF6V[\x90V[a\x05\x9FV[\x91\x90\x91`@\x81\x84\x03\x12a\x16\xA2Wa\x16f`@a\x15\x8AV[\x92_\x82\x015\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x16\x9DWa\x16\x8A\x82a\x16\x96\x94\x83\x01a\x16,V[_\x86\x01R` \x01a\x06\xFDV[` \x83\x01RV[a\x15\xC0V[a\x15\xBCV[\x92\x91\x90a\x16\xBBa\x16\xB6\x82a\x15\x9FV[a\x15\x8AV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11a\x17\x12W\x81\x90[\x83\x82\x10a\x16\xE1WPPPPPV[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x17\rW` \x91a\x17\x02\x87\x84\x93\x87\x01a\x16OV[\x81R\x01\x91\x01\x90a\x16\xD3V[a\x05\x9FV[a\x05\xA7V[\x90\x80`\x1F\x83\x01\x12\x15a\x175W\x81` a\x172\x935\x91\x01a\x16\xA7V[\x90V[a\x05\x9FV[`\x80\x81\x83\x03\x12a\x17\x94Wa\x17P\x82_\x83\x01a\x03\xC5V[\x92a\x17^\x83` \x84\x01a\x03\xFFV[\x92`@\x83\x015\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a\x17\x8FWa\x17\x83\x81a\x17\x8C\x93\x86\x01a\x17\x17V[\x93``\x01a\x06\xFDV[\x90V[a\x03\xA0V[a\x03\x9CV[4a\x17\xCBWa\x17\xB5a\x17\xAC6`\x04a\x17:V[\x92\x91\x90\x91a;\xA7V[a\x17\xBDa\x03\x92V[\x80a\x17\xC7\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90V[a\x17\xE7a\x17\xE2a\x17\xEC\x92a\x17\xD0V[a\x079V[a\x05DV[\x90V[a\x17\xF9`@a\x17\xD3V[\x90V[a\x18\x04a\x17\xEFV[\x90V[4a\x187Wa\x18\x176`\x04a\n\x94V[a\x183a\x18\"a\x17\xFCV[a\x18*a\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[4a\x18jWa\x18L6`\x04a\n\x94V[a\x18TaA\xD6V[a\x18\\a\x03\x92V[\x80a\x18f\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[a\x18x\x90a\x10\x10V[\x90RV[a\x18\x85\x90a\r\xACV[\x90RV[\x90`\x80\x80a\x18\xE1\x93a\x18\xA1_\x82\x01Q_\x86\x01\x90a\x0C\x86V[a\x18\xB3` \x82\x01Q` \x86\x01\x90a\x04\x92V[a\x18\xC5`@\x82\x01Q`@\x86\x01\x90a\x04\xA5V[a\x18\xD7``\x82\x01Q``\x86\x01\x90a\x18oV[\x01Q\x91\x01\x90a\x18|V[V[\x91\x90a\x18\xF6\x90_`\xA0\x85\x01\x94\x01\x90a\x18\x89V[V[4a\x19)Wa\x19%a\x19\x14a\x19\x0E6`\x04a\x04\x0EV[\x90aC\x13V[a\x19\x1Ca\x03\x92V[\x91\x82\x91\x82a\x18\xE3V[\x03\x90\xF3[a\x03\x98V[4a\x19_Wa\x19[a\x19Ja\x19D6`\x04a\x04\x0EV[\x90aCkV[a\x19Ra\x03\x92V[\x91\x82\x91\x82a\n\xE8V[\x03\x90\xF3[a\x03\x98V[4a\x19\x92Wa\x19t6`\x04a\n\x94V[a\x19|aC\x93V[a\x19\x84a\x03\x92V[\x80a\x19\x8E\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x19\xC7Wa\x19\xC3a\x19\xB2a\x19\xAD6`\x04a\x04tV[aC\xE4V[a\x19\xBAa\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[\x90\x91``\x82\x84\x03\x12a\x1A\x01Wa\x19\xFEa\x19\xE7\x84_\x85\x01a\x03\xC5V[\x93a\x19\xF5\x81` \x86\x01a\x06\xFDV[\x93`@\x01a\x06\xFDV[\x90V[a\x03\x9CV[\x92\x91` a\x1A\"a\x1A*\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\x11\x1CV[\x94\x01\x90a\x05GV[V[4a\x1A^Wa\x1AEa\x1A?6`\x04a\x19\xCCV[\x91aD\x9EV[\x90a\x1AZa\x1AQa\x03\x92V[\x92\x83\x92\x83a\x1A\x06V[\x03\x90\xF3[a\x03\x98V[4a\x1A\x91Wa\x1A{a\x1Av6`\x04a\x06\x98V[aF%V[a\x1A\x83a\x03\x92V[\x80a\x1A\x8D\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x1A\xC6Wa\x1A\xA66`\x04a\n\x94V[a\x1A\xC2a\x1A\xB1aF4V[a\x1A\xB9a\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1B\x05W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1B\0W` \x01\x92` \x83\x02\x84\x01\x11a\x1A\xFBWV[a\x05\xA7V[a\x05\xA3V[a\x05\x9FV[\x91\x90\x91`@\x81\x84\x03\x12a\x1BKWa\x1B#\x83_\x83\x01a\x03\xC5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1BFWa\x1BB\x92\x01a\x1A\xCBV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[4a\x1B\x7FWa\x1Bia\x1Bc6`\x04a\x1B\nV[\x91aF\xBBV[a\x1Bqa\x03\x92V[\x80a\x1B{\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x91``\x83\x83\x03\x12a\x1B\xD0Wa\x1B\x9B\x82_\x85\x01a\x03\xC5V[\x92a\x1B\xA9\x83` \x83\x01a\x03\xFFV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1B\xCBWa\x1B\xC8\x92\x01a\x16,V[\x90V[a\x03\xA0V[a\x03\x9CV[\x90a\x1B\xDF\x90a\x07<V[_R` R`@_ \x90V[\x90a\x1B\xF5\x90a\x0E\xB1V[_R` R`@_ \x90V[\x90P\x90V[a\x1C+a\x1C\"\x92` \x92a\x1C\x19\x81a\t\xC1V[\x94\x85\x80\x93a\x1C\x01V[\x93\x84\x91\x01a\t\xCEV[\x01\x90V[\x90V[a\x1C>a\x1CC\x91a\x05DV[a\x1C/V[\x90RV[a\x1CWa\x1C^\x91` \x94\x93a\x1C\x06V[\x80\x92a\x1C2V[\x01\x90V[a\x1Cva\x1Cma\x03\x92V[\x92\x83\x92\x83a\x1CGV[\x03\x90 \x90V[a\x1C\x85\x91a\x1CbV[\x90V[a\x1C\x98\x90`\x08a\x1C\x9D\x93\x02a\x0B2V[a\t\x17V[\x90V[\x90a\x1C\xAB\x91Ta\x1C\x88V[\x90V[\x90a\x1C\xD6\x92a\x1C\xCCa\x1C\xD1\x92a\x1C\xC7`\t\x95_\x96a\x1B\xD5V[a\x1B\xEBV[a\x1C|V[a\x1C\xA0V[\x90V[4a\x1D\nWa\x1D\x06a\x1C\xF5a\x1C\xEF6`\x04a\x1B\x84V[\x91a\x1C\xAEV[a\x1C\xFDa\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1DIW\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1DDW` \x01\x92`\x01\x83\x02\x84\x01\x11a\x1D?WV[a\x05\xA7V[a\x05\xA3V[a\x05\x9FV[\x91``\x83\x83\x03\x12a\x1D\x9BWa\x1De\x82_\x85\x01a\x03\xC5V[\x92a\x1Ds\x83` \x83\x01a\x03\xFFV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1D\x96Wa\x1D\x92\x92\x01a\x1D\x0FV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[4a\x1D\xD2Wa\x1D\xBCa\x1D\xB36`\x04a\x1DNV[\x92\x91\x90\x91aI<V[a\x1D\xC4a\x03\x92V[\x80a\x1D\xCE\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[a\x1D\xE0\x81a\x04\xB2V[\x03a\x1D\xE7WV[_\x80\xFD[\x90P5\x90a\x1D\xF8\x82a\x1D\xD7V[V[\x91\x90\x91`\xA0\x81\x84\x03\x12a\x1EfWa\x1E\x13\x83_\x83\x01a\x03\xC5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1EaW\x81a\x1E4\x91\x84\x01a\x1D\x0FV[\x92\x90\x93a\x1E^a\x1EG\x84`@\x85\x01a\x06\xFDV[\x93a\x1EU\x81``\x86\x01a\x06\xFDV[\x93`\x80\x01a\x1D\xEBV[\x90V[a\x03\xA0V[a\x03\x9CV[4a\x1E\xA0Wa\x1E\x8Aa\x1E~6`\x04a\x1D\xFAV[\x94\x93\x90\x93\x92\x91\x92aL\x11V[a\x1E\x92a\x03\x92V[\x80a\x1E\x9C\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x1E\xD3Wa\x1E\xBDa\x1E\xB86`\x04a\x04tV[aO\xC6V[a\x1E\xC5a\x03\x92V[\x80a\x1E\xCF\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90\x91``\x82\x84\x03\x12a\x1F\rWa\x1F\na\x1E\xF3\x84_\x85\x01a\x03\xC5V[\x93a\x1F\x01\x81` \x86\x01a\x03\xC5V[\x93`@\x01a\x13vV[\x90V[a\x03\x9CV[4a\x1FAWa\x1F+a\x1F%6`\x04a\x1E\xD8V[\x91aR;V[a\x1F3a\x03\x92V[\x80a\x1F=\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x1FuWa\x1F_a\x1FY6`\x04a\x04\x0EV[\x90aT\x1FV[a\x1Fga\x03\x92V[\x80a\x1Fq\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[\x90a\x1F\xDB\x90``\x80a\x1F\xAC`\x80\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\x0CUV[\x94a\x1F\xBF` \x82\x01Q` \x86\x01\x90a\x0C\x86V[a\x1F\xD1`@\x82\x01Q`@\x86\x01\x90a\x0C\x86V[\x01Q\x91\x01\x90a\x04\xB7V[\x90V[\x90a\x1F\xE8\x91a\x1F\x8DV[\x90V[` \x01\x90V[\x90a \x05a\x1F\xFE\x83a\x1FzV[\x80\x92a\x1F~V[\x90\x81a \x16` \x83\x02\x84\x01\x94a\x1F\x87V[\x92_\x91[\x83\x83\x10a )WPPPPP\x90V[\x90\x91\x92\x93\x94` a Ka E\x83\x85`\x01\x95\x03\x87R\x89Qa\x1F\xDEV[\x97a\x1F\xEBV[\x93\x01\x93\x01\x91\x93\x92\x90a \x1AV[a m\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x1F\xF1V[\x90V[4a \xA0Wa \x9Ca \x8Ba \x866`\x04a\x04tV[aW\x96V[a \x93a\x03\x92V[\x91\x82\x91\x82a XV[\x03\x90\xF3[a\x03\x98V[4a \xD3Wa \xBDa \xB86`\x04a\x04tV[aY&V[a \xC5a\x03\x92V[\x80a \xCF\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[a \xE4`\n_\x90a\x0BYV[\x90V[4a!\x17Wa \xF76`\x04a\n\x94V[a!\x13a!\x02a \xD8V[a!\na\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[\x90\x91`\xA0\x82\x84\x03\x12a!\xA0Wa!4\x83_\x84\x01a\x03\xC5V[\x92a!B\x81` \x85\x01a\x03\xC5V[\x92a!P\x82`@\x83\x01a\x13vV[\x92``\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a!\x9BW\x83a!q\x91\x84\x01a\x0B\xCDV[\x92\x90\x93`\x80\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a!\x96Wa!\x92\x92\x01a\x0B\xCDV[\x90\x91V[a\x03\xA0V[a\x03\xA0V[a\x03\x9CV[4a!\xDAWa!\xC4a!\xB86`\x04a!\x1CV[\x95\x94\x90\x94\x93\x91\x93a\\)V[a!\xCCa\x03\x92V[\x80a!\xD6\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\"\x13Wa\"\x0Fa!\xFEa!\xF56`\x04a\x1DNV[\x92\x91\x90\x91a\\\x9CV[a\"\x06a\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[\x90a\"\"\x90a\x07<V[_R` R`@_ \x90V[a\":a\"?\x91a\x0F.V[a\t;V[\x90V[a\"L\x90Ta\".V[\x90V[a\"Z\x90`\x02a\"\x18V[a\"e_\x82\x01a\x0E\xF4V[\x91a\"|_a\"u\x81\x85\x01a\x0F!V[\x93\x01a\"BV[\x90V[`@\x90a\"\xA8a\"\xAF\x94\x96\x95\x93\x96a\"\x9E``\x84\x01\x98_\x85\x01\x90a\n\xDBV[` \x83\x01\x90a\x0F\xD4V[\x01\x90a\n\nV[V[4a\"\xE4Wa\"\xE0a\"\xCCa\"\xC76`\x04a\x04tV[a\"OV[a\"\xD7\x93\x91\x93a\x03\x92V[\x93\x84\x93\x84a\"\x7FV[\x03\x90\xF3[a\x03\x98V[4a#\x19Wa\"\xF96`\x04a\n\x94V[a#\x15a#\x04a\\\xD1V[a#\x0Ca\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[4a#MWa#7a#16`\x04a\x04\x0EV[\x90a]\xBBV[a#?a\x03\x92V[\x80a#I\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a#\x83Wa#\x7Fa#na#h6`\x04a\x04\x0EV[\x90a_PV[a#va\x03\x92V[\x91\x82\x91\x82a\x12%V[\x03\x90\xF3[a\x03\x98V[4a#\xB6Wa#\xA0a#\x9B6`\x04a\x06\x98V[a`OV[a#\xA8a\x03\x92V[\x80a#\xB2\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x91\x90`@\x83\x82\x03\x12a#\xE3W\x80a#\xD7a#\xE0\x92_\x86\x01a\x03\xC5V[\x93` \x01a\x1D\xEBV[\x90V[a\x03\x9CV[4a$\x17Wa$\x01a#\xFB6`\x04a#\xBBV[\x90a`ZV[a$\ta\x03\x92V[\x80a$\x13\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x7F\xE1g_\x83d\xC0zM`\xA0u\x03\xF0\xD7\0\xA7\xBC\xAC\xD8\"Q\xDF\xF0\xF0p\xE5#]\xE6\xC6\xD2\x8A\x90V[a$Ha$\x1CV[\x90V[4a${Wa$[6`\x04a\n\x94V[a$wa$fa$@V[a$na\x03\x92V[\x91\x82\x91\x82a\r\xBCV[\x03\x90\xF3[a\x03\x98V[4a$\xAFWa$\x99a$\x936`\x04a\x04\x0EV[\x90aa#V[a$\xA1a\x03\x92V[\x80a$\xAB\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[_\x80\xFD[_\x7FOnly Tangle core\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a$\xEC`\x10` \x92a\t\xC5V[a$\xF5\x81a$\xB8V[\x01\x90V[a%\x0E\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra$\xDFV[\x90V[\x15a%\x18WV[a% a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a%6`\x04\x82\x01a$\xF9V[\x03\x90\xFD[a%Fa%K\x91a\t\x12V[a\x0B6V[\x90V[a%X\x90Ta%:V[\x90V[\x90V[a%ra%ma%w\x92a%[V[a\x079V[a\x03\xD4V[\x90V[a%\x83\x90a%^V[\x90V[_\x7FAlready registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%\xBA`\x12` \x92a\t\xC5V[a%\xC3\x81a%\x86V[\x01\x90V[a%\xDC\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%\xADV[\x90V[\x15a%\xE6WV[a%\xEEa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a&\x04`\x04\x82\x01a%\xC7V[\x03\x90\xFD[_\x1B\x90V[\x90a&\x1E`\x01\x80`\xA0\x1B\x03\x91a&\x08V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90a&@a&;a&G\x92a\x0E\xB1V[a&(V[\x82Ta&\rV[\x90UV[a&\xCDa&\xD2\x92a&\x8E3a&\x88a&\x82\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xDFV[\x91a\x03\xDFV[\x14a%\x11V[a&\xC5a&\xA5a&\xA0`\x07\x86\x90a\x12pV[a%NV[a&\xBFa&\xB9a&\xB4_a%zV[a\x03\xDFV[\x91a\x03\xDFV[\x14a%\xDFV[\x91`\x07a\x12pV[a&+V[V[a&\xDE``a\x15\x8AV[\x90V[_\x90V[_\x90V[_\x90V[a&\xF5a&\xD4V[\x90` \x80\x80\x84a'\x03a&\xE1V[\x81R\x01a'\x0Ea&\xE5V[\x81R\x01a'\x19a&\xE9V[\x81RPPV[a''a&\xEDV[\x90V[a'<\x90a'6a'\x1FV[PabKV[\x90V[_\x90V[a'da'j\x92a'__\x93a'Wa'?V[P`\x03a\x0EsV[a\x0E\xBDV[\x01a\t.V[\x90V[_\x7FNot service owner\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a'\xA1`\x11` \x92a\t\xC5V[a'\xAA\x81a'mV[\x01\x90V[a'\xC3\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra'\x94V[\x90V[\x15a'\xCDWV[a'\xD5a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a'\xEB`\x04\x82\x01a'\xAEV[\x03\x90\xFD[P\x90V[_\x7FToo many definitions\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a('`\x14` \x92a\t\xC5V[a(0\x81a'\xF3V[\x01\x90V[a(I\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x1AV[\x90V[\x15a(SWV[a([a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(q`\x04\x82\x01a(4V[\x03\x90\xFD[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[a(\x98a(\x9E\x91\x93\x92\x93a\x05DV[\x92a\x05DV[\x91a(\xAA\x83\x82\x02a\x05DV[\x92\x81\x84\x04\x14\x90\x15\x17\x15a(\xB9WV[a(uV[a(\xC9\x90`\x04a(\x89V[\x90V[\x90a(\xDF\x90_\x19\x90` \x03`\x08\x02a\x0B2V[\x81T\x16\x90UV[\x1B\x90V[\x91\x90`\x08a)\x05\x91\x02\x91a(\xFF_\x19\x84a(\xE6V[\x92a(\xE6V[\x91\x81\x19\x16\x91\x16\x17\x90V[a)#a)\x1Ea)(\x92a\x05DV[a\x079V[a\x05DV[\x90V[\x90V[\x91\x90a)Da)?a)L\x93a)\x0FV[a)+V[\x90\x83Ta(\xEAV[\x90UV[a)b\x91a)\\a'?V[\x91a).V[V[[\x81\x81\x10a)pWPPV[\x80a)}_`\x01\x93a)PV[\x01a)eV[\x90a)\x93\x90_\x19\x90`\x08\x02a\x0B2V[\x19\x16\x90V[\x81a)\xA2\x91a)\x83V[\x90`\x02\x02\x17\x90V[\x90_\x91a)\xC1a)\xB9\x82a\x08\x07V[\x92\x83Ta)\x98V[\x90UUV[`\x1F` \x91\x01\x04\x90V[\x91\x92\x90` \x82\x10_\x14a*)W`\x1F\x84\x11`\x01\x14a)\xF9Wa)\xF3\x92\x93Pa)\x98V[\x90U[[V[P\x90a*\x1Fa*$\x93`\x01a*\x16a*\x10\x85a\x08\x07V[\x92a)\xC6V[\x82\x01\x91\x01a)dV[a)\xAAV[a)\xF6V[Pa*`\x82\x93a*:`\x01\x94a\x08\x07V[a*Ya*F\x85a)\xC6V[\x82\x01\x92`\x1F\x86\x16\x80a*kW[Pa)\xC6V[\x01\x90a)dV[`\x02\x02\x17\x90Ua)\xF7V[a*w\x90\x88\x86\x03a(\xCCV[_a*SV[\x92\x90\x91h\x01\0\0\0\0\0\0\0\0\x82\x11a*\xDDW` \x11_\x14a*\xCEW` \x81\x10_\x14a*\xB2Wa*\xAC\x91a)\x98V[\x90U[[V[`\x01\x91`\xFF\x19\x16a*\xC2\x84a\x08\x07V[U`\x02\x02\x01\x90Ua*\xAFV[`\x01\x91P`\x02\x02\x01\x90Ua*\xB0V[a\x08\xB3V[\x90\x81Ta*\xEE\x81a\x07\xD4V[\x90\x81\x83\x11a+\x17W[\x81\x83\x10a+\x05W[PPPPV[a+\x0E\x93a)\xD0V[_\x80\x80\x80a*\xFFV[a+#\x83\x83\x83\x87a*}V[a*\xF7V[_a+2\x91a*\xE2V[V[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[\x90_\x03a+YWa+W\x90a+(V[V[a+4V[`\x03_\x91a+n\x83\x80\x83\x01a+GV[a+{\x83`\x01\x83\x01a)PV[a+\x88\x83`\x02\x83\x01a)PV[\x01UV[\x90_\x03a+\x9EWa+\x9C\x90a+^V[V[a+4V[[\x81\x81\x10a+\xAFWPPV[\x80a+\xBC_`\x04\x93a+\x8CV[\x01a+\xA4V[\x90\x91\x82\x81\x10a+\xD1W[PPPV[a+\xEFa+\xE9a+\xE3a+\xFA\x95a(\xBEV[\x92a(\xBEV[\x92a\x07\x86V[\x91\x82\x01\x91\x01\x90a+\xA3V[_\x80\x80a+\xCCV[\x90h\x01\0\0\0\0\0\0\0\0\x81\x11a,+W\x81a, a,)\x93a\x07\x82V[\x90\x82\x81Ua+\xC2V[V[a\x08\xB3V[_a,:\x91a,\x02V[V[\x90_\x03a,NWa,L\x90a,0V[V[a+4V[a,ga,ba,l\x92a%[V[a\x079V[a\x05DV[\x90V[`\x01a,{\x91\x01a\x05DV[\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x905\x90`\x01`\x80\x03\x816\x03\x03\x82\x12\x15a,\xA1W\x01\x90V[a,~V[\x90\x82\x10\x15a,\xC0W` a,\xBD\x92\x02\x81\x01\x90a,\x8AV[\x90V[a\x07nV[\x905\x90`\x01` \x03\x816\x03\x03\x82\x12\x15a-\x07W\x01\x805\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a-\x02W` \x01\x91`\x01\x82\x026\x03\x83\x13a,\xFDWV[a,\x86V[a,\x82V[a,~V[\x91V[P\x90V[_\x7FName too long\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-G`\r` \x92a\t\xC5V[a-P\x81a-\x13V[\x01\x90V[a-i\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-:V[\x90V[\x15a-sWV[a-{a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a-\x91`\x04\x82\x01a-TV[\x03\x90\xFD[5a-\x9F\x81a\x06\xE9V[\x90V[_\x7FInvalid bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-\xD6`\x0E` \x92a\t\xC5V[a-\xDF\x81a-\xA2V[\x01\x90V[a-\xF8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-\xC9V[\x90V[\x15a.\x02WV[a.\na\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a. `\x04\x82\x01a-\xE3V[\x03\x90\xFD[\x90V[_R` _ \x90V[T\x90V[a.=\x81a.0V[\x82\x10\x15a.WWa.O`\x04\x91a.'V[\x91\x02\x01\x90_\x90V[a\x07nV[P\x90V[\x91\x90`\x1F\x81\x11a.pW[PPPV[a.|a.\xA1\x93a\x08\x07V[\x90` a.\x88\x84a)\xC6V[\x83\x01\x93\x10a.\xA9W[a.\x9A\x90a)\xC6V[\x01\x90a)dV[_\x80\x80a.kV[\x91Pa.\x9A\x81\x92\x90Pa.\x91V[\x91a.\xC2\x90\x82a.\\V[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a/\x81Wa.\xE6\x82a.\xE0\x85Ta\x07\xD4V[\x85a.`V[_\x90`\x1F\x83\x11`\x01\x14a/\x19W\x91\x80\x91a/\x08\x93_\x92a/\rW[PPa)\x98V[\x90U[V[\x90\x91P\x015_\x80a/\x01V[`\x1F\x19\x83\x16\x91a/(\x85a\x08\x07V[\x92_[\x81\x81\x10a/iWP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10a/OW[PPP\x02\x01\x90Ua/\x0BV[a/_\x91\x015`\x1F\x84\x16\x90a)\x83V[\x90U_\x80\x80a/CV[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a/+V[a\x08\xB3V[\x90a/\x91\x92\x91a.\xB7V[V[\x90a/\x9F_\x19\x91a&\x08V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a/\xBEa/\xB9a/\xC5\x92a)\x0FV[a)+V[\x82Ta/\x93V[\x90UV[5a/\xD3\x81a\x1D\xD7V[\x90V[\x90a/\xE2`\xFF\x91a&\x08V[\x91\x81\x19\x16\x91\x16\x17\x90V[a/\xF5\x90a\x04\xB2V[\x90V[\x90V[\x90a0\x10a0\x0Ba0\x17\x92a/\xECV[a/\xF8V[\x82Ta/\xD6V[\x90UV[\x90a0y```\x03a0\x7F\x94a0?_\x82\x01a09_\x88\x01\x88a,\xC5V[\x91a/\x86V[a0X`\x01\x82\x01a0R` \x88\x01a-\x95V[\x90a/\xA9V[a0q`\x02\x82\x01a0k`@\x88\x01a-\x95V[\x90a/\xA9V[\x01\x92\x01a/\xC9V[\x90a/\xFBV[V[\x91\x90a0\x92Wa0\x90\x91a0\x1BV[V[a+4V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15a0\xC7W\x82a0\xBF\x91`\x01a0\xC5\x95\x01\x81Ua.4V[\x90a0\x81V[V[a\x08\xB3V[\x92\x91\x90\x92a0\xFF3a0\xF9a0\xF3a0\xEEa0\xE9`\x07\x87\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14a'\xC6V[a1-a1\r\x85\x84\x90a'\xEFV[a1&a1 a1\x1Ba\x14;V[a\x05DV[\x91a\x05DV[\x11\x15a(LV[a1B_a1=`\x08\x84\x90a\x07XV[a,<V[a1K_a,SV[[\x80a1ia1ca1^\x88\x87\x90a'\xEFV[a\x05DV[\x91a\x05DV[\x10\x15a2<Wa27\x90a1\xC0a1\xA0a1\x9Aa1\x94a1\x8B\x8A\x89\x87\x91a,\xA6V[_\x81\x01\x90a,\xC5V[\x90a-\x0CV[\x90a-\x0FV[a1\xB9a1\xB3a1\xAEa\x17\xEFV[a\x05DV[\x91a\x05DV[\x11\x15a-lV[a2\ta1\xDA`@a1\xD4\x89\x88\x86\x91a,\xA6V[\x01a-\x95V[a2\x02a1\xFCa1\xF7` a1\xF1\x8C\x8B\x89\x91a,\xA6V[\x01a-\x95V[a\x05DV[\x91a\x05DV[\x10\x15a-\xFBV[a22a2 a2\x1B`\x08\x86\x90a\x07XV[a.$V[a2,\x88\x87\x85\x91a,\xA6V[\x90a0\x97V[a,oV[a1LV[PPP\x90PV[_\x7FZero address\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a2w`\x0C` \x92a\t\xC5V[a2\x80\x81a2CV[\x01\x90V[a2\x99\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra2jV[\x90V[\x15a2\xA3WV[a2\xABa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a2\xC1`\x04\x82\x01a2\x84V[\x03\x90\xFD[\x90a2\xCF\x90a\x07<V[_R` R`@_ \x90V[\x90V[`H\x1B\x90V[\x90a2\xF9i\xFF\0\0\0\0\0\0\0\0\0\x91a2\xDEV[\x91\x81\x19\x16\x91\x16\x17\x90V[a3\x0C\x90a\x10\x04V[\x90V[\x90V[\x90a3'a3\"a3.\x92a3\x03V[a3\x0FV[\x82Ta2\xE4V[\x90UV[a3n3a3ha3b\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xDFV[\x91a\x03\xDFV[\x14a%\x11V[a3\x93\x82a3\x8Ca3\x86a3\x81_a%zV[a\x03\xDFV[\x91a\x03\xDFV[\x14\x15a2\x9CV[a3\xB9a3\xB4a3\xADa3\xA8`\x06\x85\x90a2\xC5V[a2\xDBV[\x84\x90ac)V[a%\xDFV[a3\xDC`\x02`\x01a3\xD6a3\xCF`\x03\x86\x90a\x0EsV[\x86\x90a\x0E\xBDV[\x01a3\x12V[\x90a4\x10a4\n\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK\x93a\x07<V[\x91a\x0E\xB1V[\x91a4\x19a\x03\x92V[\x80a4#\x81a\x04;V[\x03\x90\xA3V[a49\x90a44accV[a4;V[V[a4F\x90`\x0Ba&+V[V[a4Q\x90a4(V[V[``\x90V[\x90` \x82\x82\x03\x12a4\x88W_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a4\x83Wa4\x80\x92\x01a\x17\x17V[\x90V[a\x03\xA0V[a\x03\x9CV[\x90a4\xA4\x91a4\x9Aa4SV[P\x90\x81\x01\x90a4XV[\x90V[a4\xC6a4\xC1a4\xCB\x92a4\xB9a'?V[P`\x05a2\xC5V[a2\xDBV[ac\xB1V[\x90V[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a4\xEBW` \x80\x91\x02\x01\x90V[a\x08\xB3V[\x90a5\x02a4\xFD\x83a4\xD3V[a\x15\x8AV[\x91\x82RV[6\x907V[\x90a51a5\x19\x83a4\xF0V[\x92` \x80a5'\x86\x93a4\xD3V[\x92\x01\x91\x03\x90a5\x07V[V[\x90a5=\x82a\x10\xE5V[\x81\x10\x15a5NW` \x80\x91\x02\x01\x01\x90V[a\x07nV[\x90a5]\x90a\x03\xDFV[\x90RV[\x90a5ja4\xCEV[Pa5\x87a5\x82a5}`\x04\x85\x90a2\xC5V[a2\xDBV[ac\xB1V[\x91a5\x91\x83a5\x0CV[\x91a5\x9B_a,SV[[\x80a5\xAFa5\xA9\x87a\x05DV[\x91a\x05DV[\x10\x15a5\xF6Wa5\xF1\x90a5\xECa5\xDAa5\xD3a5\xCE`\x04\x88\x90a2\xC5V[a2\xDBV[\x83\x90ad\0V[a5\xE7\x87\x91\x84\x90\x92a53V[a5SV[a,oV[a5\x9CV[P\x92PP\x90V[_\x90V[\x90a6\na5\xFDV[Pa6,`\x01a6&a6\x1F`\x03\x86\x90a\x0EsV[\x84\x90a\x0E\xBDV[\x01a\x0FNV[a6>a68_a\x10\x04V[\x91a\x10\x04V[\x14\x91\x82\x15a6LW[PP\x90V[a6m\x92P`\x01\x91a6ba6g\x92`\x03a\x0EsV[a\x0E\xBDV[\x01a\x0FNV[a6\x80a6z`\x01a\x10\x04V[\x91a\x10\x04V[\x14_\x80a6GV[a6\xAE\x90a6\x94a4\xCEV[P_\x90a6\xA8a6\xA2a\x11\xD8V[\x92a,SV[\x90aD\x9EV[P\x90V[_\x7FNot registered operator\0\0\0\0\0\0\0\0\0\x91\x01RV[a6\xE6`\x17` \x92a\t\xC5V[a6\xEF\x81a6\xB2V[\x01\x90V[a7\x08\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra6\xD9V[\x90V[\x15a7\x12WV[a7\x1Aa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a70`\x04\x82\x01a6\xF3V[\x03\x90\xFD[\x90a7f\x94\x93\x92\x91a7aa7\\a7Ua7P\x84`\x06a2\xC5V[a2\xDBV[3\x90ad8V[a7\x0BV[a7hV[V[\x91a7z\x94\x92\x93\x913\x91\x92\x93\x94ae\xE7V[V[\x90a7\x89\x94\x93\x92\x91a74V[V[\x90a7\xABa7\xA6a7\xB0\x93a7\x9Ea5\xFDV[P`\x06a2\xC5V[a2\xDBV[ad8V[\x90V[_\x90V[a7\xD9a7\xDF\x92a7\xD4`\x01\x93a7\xCCa7\xB3V[P`\x03a\x0EsV[a\x0E\xBDV[\x01a\x0FNV[\x90V[a7\xEB\x90a\x0E\xA5V[\x90V[_\x7FInternal only\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a8\"`\r` \x92a\t\xC5V[a8+\x81a7\xEEV[\x01\x90V[a8D\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra8\x15V[\x90V[\x15a8NWV[a8Va\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a8l`\x04\x82\x01a8/V[\x03\x90\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a8\x88W` \x80\x91\x02\x01\x90V[a\x08\xB3V[\x90a8\x9Fa8\x9A\x83a8pV[a\x15\x8AV[\x91\x82RV[6\x907V[\x90a8\xCEa8\xB6\x83a8\x8DV[\x92` \x80a8\xC4\x86\x93a8pV[\x92\x01\x91\x03\x90a8\xA4V[V[\x90a8\xDA\x82a\x0CBV[\x81\x10\x15a8\xEBW` \x80\x91\x02\x01\x01\x90V[a\x07nV[\x90V[` \x01\x90V[Q\x90V[Q\x90V[\x90a9\x0B\x82a8\xFDV[\x81\x10\x15a9\x1CW` \x80\x91\x02\x01\x01\x90V[a\x07nV[\x90a9+\x90a\r\xACV[\x90RV[``\x90V[\x90V[` \x91\x81R\x01\x90V[\x90_\x92\x91\x80T\x90a9Za9S\x83a\x07\xD4V[\x80\x94a97V[\x91`\x01\x81\x16\x90\x81_\x14a9\xB1WP`\x01\x14a9uW[PPPV[a9\x82\x91\x92\x93\x94Pa\x07\x8FV[\x91_\x92[\x81\x84\x10a9\x99WPP\x01\x90_\x80\x80a9pV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a9\x86V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a9pV[\x90a9\xD6\x91a9@V[\x90V[\x90a9\xF9a9\xF2\x92a9\xE9a\x03\x92V[\x93\x84\x80\x92a9\xCCV[\x03\x83a\x08\xC7V[V[a:\x04\x90a9\xD9V[\x90V[a:\x11\x90Qa\r\xACV[\x90V[a:\x1E\x90Qa\x05DV[\x90V[_\x7FValue out of bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a:U`\x13` \x92a\t\xC5V[a:^\x81a:!V[\x01\x90V[a:za:\x88\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra\t\xD9V[\x90` \x81\x83\x03\x91\x01Ra:HV[\x90V[\x92\x91` a:\xA7a:\xAF\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\t\xD9V[\x94\x01\x90a\x05GV[V[\x90_\x92\x91\x80T\x90a:\xCBa:\xC4\x83a\x07\xD4V[\x80\x94a\t\xC5V[\x91`\x01\x81\x16\x90\x81_\x14a;\"WP`\x01\x14a:\xE6W[PPPV[a:\xF3\x91\x92\x93\x94Pa\x08\x07V[\x91_\x92[\x81\x84\x10a;\nWPP\x01\x90_\x80\x80a:\xE1V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a:\xF7V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a:\xE1V[_\x7FRequired metric missing\0\0\0\0\0\0\0\0\0\x91\x01RV[a;q`\x17` \x92a\t\xC5V[a;z\x81a;=V[\x01\x90V[a;\x96a;\xA4\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra:\xB1V[\x90` \x81\x83\x03\x91\x01Ra;dV[\x90V[\x92\x93\x90\x93a;\xCF3a;\xC9a;\xC3a;\xBE0a7\xE2V[a\x03\xDFV[\x91a\x03\xDFV[\x14a8GV[a;\xE3a;\xDE`\x08\x86\x90a\x07XV[a.$V[\x94a;\xED\x82a8\xA9V[\x94a;\xF7_a,SV[[\x80a<\x0Ba<\x05\x86a\x05DV[\x91a\x05DV[\x10\x15a<^Wa<Y\x90a<Ta</_a<'\x8A\x85\x90a8\xD0V[Q\x01Qa8\xF0V[a<Aa<;\x82a8\xF9V[\x91a8\xF3V[ a<O\x8A\x91\x84\x90\x92a9\x01V[a9!V[a,oV[a;\xF8V[P\x91\x94\x90\x92\x95a<m\x81a.0V[a<\x7Fa<y_a,SV[\x91a\x05DV[\x11\x96a<\x89a9/V[\x90\x88aA\tW[a<\x99_a,SV[[\x80a<\xADa<\xA7\x8Ba\x05DV[\x91a\x05DV[\x10\x15a?lW`\x01_\x8Ba=\xA0W[P\x90\x88\x87\x89a<\xD2\x94a<\xD7W[PPPa,oV[a<\x9AV[\x82_a=\x15a=\ra=\x1E\x94a=\x08a=\0` a<\xF9a=#\x9B\x8D\x90a8\xD0V[Q\x01a:\x14V[\x97`\ta\x1B\xD5V[a\x1B\xEBV[\x92\x87\x90a8\xD0V[Q\x01Q\x90a\x1C|V[a/\xA9V[\x88\x87\x89\x90a=M` a=F_a=;\x87\x89\x90a8\xD0V[Q\x01Q\x95\x87\x90a8\xD0V[Q\x01a:\x14V[a=\x80a=z\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD\x93a\x07<V[\x93a\x0E\xB1V[\x93a=\x95a=\x8Ca\x03\x92V[\x92\x83\x92\x83a:\x8BV[\x03\x90\xA3\x88\x87\x89a<\xCAV[\x9A\x90\x95\x92\x91\x99a=\xAF_a,SV[[\x80a=\xCBa=\xC5a=\xC0\x8Aa.0V[a\x05DV[\x91a\x05DV[\x10\x15a?VWa=\xE3a=\xDE\x8D\x87a9\x01V[a:\x07V[a>\x07a>\x01a=\xFCa=\xF7\x8A\x86\x90a9\x01V[a:\x07V[a\r\xACV[\x91a\r\xACV[\x14a>\x1AWa>\x15\x90a,oV[a=\xB0V[\x8A\x91\x9B\x92\x9CP\x89a<\xD2\x94\x95\x98\x8A\x92`\x01\x90\x8Aa>D` a>=\x89\x8B\x90a8\xD0V[Q\x01a:\x14V[a>la>fa>a`\x01a>Z\x86\x88\x90a.4V[P\x01a\t.V[a\x05DV[\x91a\x05DV[\x10\x91\x88\x88\x84\x15a?\x0CW[PPPPa>\xA1W[a>\x8B\x90[\x15a\x04\xB2V[a>\x9AW[\x93\x94PPPa<\xBCV[P_a>\x90V[\x90P\x82\x82_a>\xB1\x87\x89\x90a8\xD0V[Q\x01Q\x91a>\xFDa>\xEBa>\xE5\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07<V[\x93a\x0E\xB1V[\x93a>\xF4a\x03\x92V[\x91\x82\x91\x82a:bV[\x03\x90\xA3a>\x8B_\x91\x90Pa>\x80V[a?L\x93\x94Pa?:a?F\x93a?4` a?-a?A\x96`\x02\x96a8\xD0V[Q\x01a:\x14V[\x96a.4V[P\x01a\t.V[a\x05DV[\x91a\x05DV[\x11\x8A_\x88\x88a>wV[P\x99\x90\x9A\x87\x89a<\xD2\x94\x95\x98a>\x8B\x8D\x94a>\x85V[P\x97PP\x92\x93P\x93Pa?~_a,SV[\x93[\x84a?\x9Ba?\x95a?\x90\x86a.0V[a\x05DV[\x91a\x05DV[\x10\x15aA\x02Wa?\xC1a?\xBB`\x03a?\xB4\x86\x89\x90a.4V[P\x01a\tUV[\x15a\x04\xB2V[a@\xF7Wa?\xE3a?\xDE_a?\xD7\x86\x89\x90a.4V[P\x01a94V[a9\xFBV[a?\xF5a?\xEF\x82a8\xF9V[\x91a8\xF3V[ \x90_\x96a@\x02_a,SV[[\x80a@\x1Ea@\x18a@\x13\x86a8\xFDV[a\x05DV[\x91a\x05DV[\x10\x15a@\xE5Wa@7a@2\x84\x83\x90a9\x01V[a:\x07V[a@Ia@C\x86a\r\xACV[\x91a\r\xACV[\x14a@\\Wa@W\x90a,oV[a@\x03V[P\x95\x90\x96Pa@}\x91Pa@r`\x01[\x15a\x04\xB2V[a@\x84W[[a,oV[\x93\x94a?\x80V[\x82\x85_a@\x92\x87\x85\x90a.4V[P\x01\x91a@\xDDa@\xCBa@\xC5\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07<V[\x93a\x0E\xB1V[\x93a@\xD4a\x03\x92V[\x91\x82\x91\x82a;~V[\x03\x90\xA3a@wV[P\x95\x90\x96a@}\x92Pa@r\x90a@lV[\x94\x93a@}\x90a@xV[PPPPPV[\x96\x93\x90PaA#aA\x1E\x83\x97\x94\x99\x96\x93a.0V[a8\xA9V[\x97aA-_a,SV[[\x80aAIaACaA>\x8Ba.0V[a\x05DV[\x91a\x05DV[\x10\x15aA\xA3WaA\x9E\x90aA\x99aAtaAo_aAh\x8D\x86\x90a.4V[P\x01a94V[a9\xFBV[aA\x86aA\x80\x82a8\xF9V[\x91a8\xF3V[ aA\x94\x8D\x91\x84\x90\x92a9\x01V[a9!V[a,oV[aA.V[P\x92\x95\x91\x94\x97\x90\x93\x96a<\x90V[aA\xB9accV[aA\xC1aA\xC3V[V[aA\xD4aA\xCF_a%zV[ajYV[V[aA\xDEaA\xB1V[V[aA\xEA`\xA0a\x15\x8AV[\x90V[_\x90V[_\x90V[_\x90V[aB\x01aA\xE0V[\x90` \x80\x80\x80\x80\x86aB\x11aA\xEDV[\x81R\x01aB\x1Ca&\xE1V[\x81R\x01aB'a&\xE5V[\x81R\x01aB2aA\xF1V[\x81R\x01aB=aA\xF5V[\x81RPPV[aBKaA\xF9V[\x90V[\x90aBX\x90a\x05DV[\x90RV[\x90aBf\x90a\x03\xA4V[\x90RV[\x90aBt\x90a\x04\x9FV[\x90RV[\x90aB\x82\x90a\x10\x04V[\x90RV[\x90aC\x05aB\xFC`\x02aB\x97aA\xE0V[\x94aB\xAEaB\xA6_\x83\x01a\t.V[_\x88\x01aBNV[aB\xC6aB\xBD`\x01\x83\x01a\x0E\xF4V[` \x88\x01aB\\V[aB\xDEaB\xD5`\x01\x83\x01a\x0F!V[`@\x88\x01aBjV[aB\xF6aB\xED`\x01\x83\x01a\x0FNV[``\x88\x01aBxV[\x01a\x0FrV[`\x80\x84\x01a9!V[V[aC\x10\x90aB\x86V[\x90V[aC8\x91aC.aC3\x92aC&aBCV[P`\x03a\x0EsV[a\x0E\xBDV[aC\x07V[\x90V[_\x90V[\x90aCI\x90a\x07<V[_R` R`@_ \x90V[\x90aC_\x90a\x0E\xB1V[_R` R`@_ \x90V[aC\x90\x91aC\x86aC\x8B\x92aC~aC;V[P`\x0CaC?V[aCUV[a\x0E\xF4V[\x90V[aC\x9BajoV[aC\xA3a\\\xD1V[aC\xB5aC\xAF\x83a\x03\xDFV[\x91a\x03\xDFV[\x03aC\xC5WaC\xC3\x90ajYV[V[aC\xE0\x90_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0B\x83V[\x03\x90\xFD[aD\x03aC\xFEaD\x08\x92aC\xF6a'?V[P`\x04a2\xC5V[a2\xDBV[ac\xB1V[\x90V[aD\x15\x90Qa\x04\x9FV[\x90V[aD,aD'aD1\x92a%[V[a\x079V[a\x04\x9FV[\x90V[aD>\x90Qa\x03\xA4V[\x90V[aDUaDPaDZ\x92a\x03\xA4V[a\x079V[a\x05DV[\x90V[aDqaDlaDv\x92a\x04\x9FV[a\x079V[a\x05DV[\x90V[aD\x88aD\x8E\x91\x93\x92\x93a\x05DV[\x92a\x05DV[\x82\x01\x80\x92\x11aD\x99WV[a(uV[\x90\x92\x91\x92aD\xAAa4\xCEV[PaD\xB3a'?V[PaD\xBD\x82abKV[\x93aD\xDAaD\xD5aD\xD0`\x05\x86\x90a2\xC5V[a2\xDBV[ac\xB1V[\x92aD\xE7` \x87\x01aD\x0BV[aD\xF9aD\xF3_aD\x18V[\x91a\x04\x9FV[\x14\x80\x15aE\xEBW[\x80\x15aE\xD0W[aE\xB6WaEB\x86aE<aE7` aE0aE+_aE\x9F\x9B\x9C\x9D\x01aD4V[aDAV[\x93\x01aD\x0BV[aD]V[\x90a(\x89V[\x91\x80aE]aEWaERa\x11\xD8V[a\x05DV[\x91a\x05DV[\x11_\x14aE\xB1WPaEma\x11\xD8V[[aEy\x84\x82\x90aDyV[aE\x8BaE\x85\x88a\x05DV[\x91a\x05DV[\x11_\x14aE\xA2WP\x84[\x90\x92\x90\x91\x92aj\xA5V[\x91V[aE\xAC\x90\x84aDyV[aE\x95V[aEnV[PPP\x91PaE\xCCaE\xC7_a,SV[a5\x0CV[\x91\x90V[P\x82aE\xE4aE\xDE\x86a\x05DV[\x91a\x05DV[\x10\x15aE\x08V[P\x83aE\xFFaE\xF9_a,SV[\x91a\x05DV[\x14aE\x01V[aF\x16\x90aF\x11accV[aF\x18V[V[aF#\x90`\na&+V[V[aF.\x90aF\x05V[V[_\x90V[aF<aF0V[PaFF_a%NV[\x90V[P\x90V[\x91\x90\x81\x10\x15aF]W` \x02\x01\x90V[a\x07nV[5aFl\x81a\x03\xEBV[\x90V[_\x80\xFD[`\xE0\x1B\x90V[_\x91\x03\x12aF\x83WV[a\x03\x9CV[\x91` aF\xA9\x92\x94\x93aF\xA2`@\x82\x01\x96_\x83\x01\x90a\n\xDBV[\x01\x90a\x0BvV[V[aF\xB3a\x03\x92V[=_\x82>=\x90\xFD[\x90\x92\x91\x92aF\xC8_a,SV[[\x80aF\xE6aF\xE0aF\xDB\x85\x89\x90aFIV[a\x05DV[\x91a\x05DV[\x10\x15aG\x95WaF\xF50a7\xE2V[\x90c\xBA\x1F\xB1\x03\x84aG\x10aG\x0B\x86\x8A\x86\x91aFMV[aFbV[\x93\x80;\x15aG\x90WaG5_\x80\x94aG@aG)a\x03\x92V[\x98\x89\x96\x87\x95\x86\x94aFsV[\x84R`\x04\x84\x01aF\x88V[\x03\x92Z\xF1\x91\x82\x15aG\x8BWaGZ\x92aG_W[Pa,oV[aF\xC9V[aG~\x90_=\x81\x11aG\x84W[aGv\x81\x83a\x08\xC7V[\x81\x01\x90aFyV[_aGTV[P=aGlV[aF\xABV[aFoV[PPP\x90PV[_\x7FNot slashing oracle\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aG\xD0`\x13` \x92a\t\xC5V[aG\xD9\x81aG\x9CV[\x01\x90V[aG\xF2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaG\xC3V[\x90V[\x15aG\xFCWV[aH\x04a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aH\x1A`\x04\x82\x01aG\xDDV[\x03\x90\xFD[_\x7FOperator unknown\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aHR`\x10` \x92a\t\xC5V[aH[\x81aH\x1EV[\x01\x90V[aHt\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaHEV[\x90V[\x15aH~WV[aH\x86a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aH\x9C`\x04\x82\x01aH_V[\x03\x90\xFD[\x90V[aH\xB7aH\xB2aH\xBC\x92a\x05DV[a\x079V[a\x03\xA4V[\x90V[\x90aH\xD2g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x91a&\x08V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90aH\xF4aH\xEFaH\xFB\x92a\x07<V[aH\xDCV[\x82TaH\xBFV[\x90UV[\x91\x90aI\x19\x81aI\x12\x81aI\x1E\x95a\t\xC5V[\x80\x95a\x15\xEBV[a\x08\xA9V[\x01\x90V[\x90\x91aI9\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaH\xFFV[\x90V[aIa3aI[aIUaIP`\na%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14aG\xF5V[aI\x87aI\x82aI{aIv`\x05\x85\x90a2\xC5V[a2\xDBV[\x84\x90ad8V[aHwV[aI\xB3aI\xA8aI\xA3aI\x9C`\x03\x85\x90a\x0EsV[\x85\x90a\x0E\xBDV[aH\xA0V[`\x01`\x03\x91\x01a3\x12V[aI\xD1aI\xCAaI\xC5`\x04\x84\x90a2\xC5V[a2\xDBV[\x83\x90ak\xC1V[PaI\xF9aI\xDEBaH\xA3V[aI\xF4aI\xED`\x0C\x85\x90aC?V[\x85\x90aCUV[aH\xDFV[\x90\x91\x92aJ/aJ)\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07<V[\x93a\x0E\xB1V[\x93aJDaJ;a\x03\x92V[\x92\x83\x92\x83aI\"V[\x03\x90\xA3V[aJS`\x80a\x15\x8AV[\x90V[aJa\x916\x91a\x15\xF6V[\x90V[RV[\x90aJq\x90a\x04\xB2V[\x90RV[Q\x90V[\x90aJ\x83\x81a\t\xC1V[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11aKCWaJ\xA7\x82aJ\xA1\x85Ta\x07\xD4V[\x85a.`V[` \x90`\x1F\x83\x11`\x01\x14aJ\xDBW\x91\x80\x91aJ\xCA\x93_\x92aJ\xCFW[PPa)\x98V[\x90U[V[\x90\x91P\x01Q_\x80aJ\xC3V[`\x1F\x19\x83\x16\x91aJ\xEA\x85a\x08\x07V[\x92_[\x81\x81\x10aK+WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10aK\x11W[PPP\x02\x01\x90UaJ\xCDV[aK!\x91\x01Q`\x1F\x84\x16\x90a)\x83V[\x90U_\x80\x80aK\x05V[\x91\x93` `\x01\x81\x92\x87\x87\x01Q\x81U\x01\x95\x01\x92\x01aJ\xEDV[a\x08\xB3V[\x90aKR\x91aJyV[V[aK^\x90Qa\x04\xB2V[\x90V[\x90aK\xBE```\x03aK\xC4\x94aK\x84_\x82\x01aK~_\x88\x01aJuV[\x90aKHV[aK\x9D`\x01\x82\x01aK\x97` \x88\x01a:\x14V[\x90a/\xA9V[aK\xB6`\x02\x82\x01aK\xB0`@\x88\x01a:\x14V[\x90a/\xA9V[\x01\x92\x01aKTV[\x90a/\xFBV[V[\x91\x90aK\xD7WaK\xD5\x91aKaV[V[a+4V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15aL\x0CW\x82aL\x04\x91`\x01aL\n\x95\x01\x81Ua.4V[\x90aK\xC6V[V[a\x08\xB3V[aM/\x95aM\x18\x84\x96aM\x0FaM\x07aL\xF3aL\xEEaM!\x97aL\x94aLtaLnaM*\x9D\x8D\x9F\x9DaLi3aLcaL]aLXaLS`\x07\x8C\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14a'\xC6V[a-\x0CV[\x90a-\x0FV[aL\x8DaL\x87aL\x82a\x17\xEFV[a\x05DV[\x91a\x05DV[\x11\x15a-lV[aL\xB1\x86aL\xAAaL\xA4\x8Da\x05DV[\x91a\x05DV[\x10\x15a-\xFBV[aL\xE7aL\xC8aL\xC3`\x08\x84\x90a\x07XV[a\x07\x82V[aL\xE1aL\xDBaL\xD6a\x14;V[a\x05DV[\x91a\x05DV[\x10a(LV[`\x08a\x07XV[a.$V[\x98\x99\x96\x92\x94\x96aM\x01aJIV[\x9AaJVV[_\x8A\x01aJdV[` \x88\x01aBNV[`@\x86\x01aBNV[``\x84\x01aJgV[aK\xDCV[V[aM_\x90aMZaMUaMNaMI\x84`\x06a2\xC5V[a2\xDBV[3\x90ad8V[a7\x0BV[aN@V[V[_\x7FCannot go online while slashed\0\0\x91\x01RV[aM\x95`\x1E` \x92a\t\xC5V[aM\x9E\x81aMaV[\x01\x90V[aM\xB7\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaM\x88V[\x90V[`@\x1B\x90V[\x90aM\xD4h\xFF\0\0\0\0\0\0\0\0\x91aM\xBAV[\x91\x81\x19\x16\x91\x16\x17\x90V[aM\xF2aM\xEDaM\xF7\x92a\x04\x9FV[a\x079V[a\x04\x9FV[\x90V[\x90V[\x90aN\x12aN\raN\x19\x92aM\xDEV[aM\xFAV[\x82TaM\xC0V[\x90UV[\x91` aN>\x92\x94\x93aN7`@\x82\x01\x96_\x83\x01\x90a\x10\x1CV[\x01\x90a\x10\x1CV[V[aN^aNYaNR`\x03\x84\x90a\x0EsV[3\x90a\x0E\xBDV[aH\xA0V[\x90aNk`\x01\x83\x01a\x0FNV[\x91\x82aN\x80aNz`\x03a\x10\x04V[\x91a\x10\x04V[\x14aO\xA4W\x82aN\x98aN\x92_a\x10\x04V[\x91a\x10\x04V[\x14\x80\x15aO\x89W[aO\x84WaN\xC7\x90aN\xB5`\x01\x80\x83\x01a3\x12V[`\x01aN\xC0_aD\x18V[\x91\x01aM\xFDV[aN\xE5aN\xDEaN\xD9`\x04\x84\x90a2\xC5V[a2\xDBV[3\x90ac)V[P\x803aO\x1BaO\x15\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07<V[\x91a\x0E\xB1V[\x91aO$a\x03\x92V[\x80aO.\x81a\x04;V[\x03\x90\xA3\x903\x90\x91`\x01aOjaOd\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07<V[\x93a\x0E\xB1V[\x93aO\x7FaOva\x03\x92V[\x92\x83\x92\x83aN\x1DV[\x03\x90\xA3V[PPPV[P\x82aO\x9EaO\x98`\x01a\x10\x04V[\x91a\x10\x04V[\x14aN\xA0V[aO\xACa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aO\xC2`\x04\x82\x01aM\xA2V[\x03\x90\xFD[aO\xCF\x90aM1V[V[_\x7FNot authorized\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aP\x05`\x0E` \x92a\t\xC5V[aP\x0E\x81aO\xD1V[\x01\x90V[aP'\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaO\xF8V[\x90V[\x15aP1WV[aP9a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aPO`\x04\x82\x01aP\x12V[\x03\x90\xFD[\x90V[aPjaPeaPo\x92aPSV[a\x079V[a\x03\xA4V[\x90V[_\x7FInterval too short\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aP\xA6`\x12` \x92a\t\xC5V[aP\xAF\x81aPrV[\x01\x90V[aP\xC8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaP\x99V[\x90V[\x15aP\xD2WV[aP\xDAa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aP\xF0`\x04\x82\x01aP\xB3V[\x03\x90\xFD[\x90V[aQ\x0BaQ\x06aQ\x10\x92aP\xF4V[a\x079V[a\x04\x9FV[\x90V[_\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0\x91\x01RV[aQG`\x17` \x92a\t\xC5V[aQP\x81aQ\x13V[\x01\x90V[aQi\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaQ:V[\x90V[\x15aQsWV[aQ{a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aQ\x91`\x04\x82\x01aQTV[\x03\x90\xFD[aQ\x9F``a\x15\x8AV[\x90V[\x90aQ\xB7aQ\xB2aQ\xBE\x92a/\xECV[a/\xF8V[\x82Ta2\xE4V[\x90UV[\x90aR\x04`@_aR\n\x94aQ\xE4\x82\x82\x01aQ\xDE\x84\x88\x01aD4V[\x90aH\xDFV[aQ\xFC\x82\x82\x01aQ\xF6` \x88\x01aD\x0BV[\x90aM\xFDV[\x01\x92\x01aKTV[\x90aQ\xA2V[V[\x90aR\x16\x91aQ\xC2V[V[\x91` aR9\x92\x94\x93aR2`@\x82\x01\x96_\x83\x01\x90a\n\xDBV[\x01\x90a\x0F\xD4V[V[3aRnaRh\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xDFV[\x91a\x03\xDFV[\x14\x80\x15aSZW[aR\x7F\x90aP*V[aR\x9D\x82aR\x96aR\x90`<aPVV[\x91a\x03\xA4V[\x10\x15aP\xCBV[aR\xBB\x83aR\xB4aR\xAE`\x01aP\xF7V[\x91a\x04\x9FV[\x10\x15aQlV[aS\x14\x82aS\x03\x85aR\xFAaR\xDC_aR\xD6`\x02\x89\x90a\"\x18V[\x01a\"BV[\x91aR\xF1aR\xE8aQ\x95V[\x95_\x87\x01aB\\V[` \x85\x01aBjV[`@\x83\x01aJgV[aS\x0F`\x02\x84\x90a\"\x18V[aR\x0CV[\x90\x91aS@\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x92a\x07<V[\x92aSUaSLa\x03\x92V[\x92\x83\x92\x83aR\x18V[\x03\x90\xA2V[PaR\x7F3aS\x84aS~aSyaSt`\x07\x87\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14\x90PaRvV[aS\x9BaS\xA1\x91\x93\x92\x93a\x05DV[\x92a\x05DV[\x82\x03\x91\x82\x11aS\xACWV[a(uV[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[aS\xD1aS\xD7\x91a\x05DV[\x91a\x05DV[\x90\x81\x15aS\xE2W\x04\x90V[aS\xB1V[aS\xFBaS\xF6aT\0\x92a\x05DV[a\x079V[a\x04\x9FV[\x90V[aT\x17aT\x12aT\x1C\x92a%[V[a\x079V[a\x03\xA4V[\x90V[aT=aT8aT1`\x03\x84\x90a\x0EsV[\x84\x90a\x0E\xBDV[aH\xA0V[\x90aTG\x81abKV[aTS`\x01\x84\x01a\x0FNV[aTfaT``\x03a\x10\x04V[\x91a\x10\x04V[\x14aVzWaTv_\x84\x01a\t.V[aT\x88aT\x82_a,SV[\x91a\x05DV[\x14aVtWaT\xBEaT\xA5BaT\x9F_\x87\x01a\t.V[\x90aS\x8CV[aT\xB8aT\xB3_\x85\x01aD4V[aDAV[\x90aS\xC5V[\x80aT\xD2aT\xCC`\xFFaD]V[\x91a\x05DV[\x11_\x14aVfWP`\xFF[\x90\x81aT\xFCaT\xF6aT\xF1`\x01\x88\x01a\x0F!V[a\x04\x9FV[\x91a\x04\x9FV[\x11aU\tW[PPPPPV[aU\x16\x82`\x01\x86\x01aM\xFDV[aU+aU\"_aT\x03V[`\x01\x86\x01aH\xDFV[aUIaUCaU>` \x85\x94\x01aD\x0BV[a\x04\x9FV[\x91a\x04\x9FV[\x10\x15\x80aV?W[aU\\W[\x80aU\x02V[aUwaUk`\x01\x85\x01a\x0FNV[\x93`\x01`\x02\x91\x01a3\x12V[aU\x95aU\x8EaU\x89`\x04\x85\x90a2\xC5V[a2\xDBV[\x85\x90ak\xC1V[P\x81\x90\x84\x90\x91aU\xE3aU\xD1aU\xCB\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM\x93a\x07<V[\x93a\x0E\xB1V[\x93aU\xDAa\x03\x92V[\x91\x82\x91\x82a\x14\xF5V[\x03\x90\xA3\x91\x90\x91`\x02aV\x1EaV\x18\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07<V[\x93a\x0E\xB1V[\x93aV3aV*a\x03\x92V[\x92\x83\x92\x83aN\x1DV[\x03\x90\xA3_\x80\x80\x80aUVV[PaVL`\x01\x84\x01a\x0FNV[aV_aVY`\x02a\x10\x04V[\x91a\x10\x04V[\x14\x15aUQV[aVo\x90aS\xE7V[aT\xDDV[PPPPV[PPPPV[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11aV\x9DW` \x80\x91\x02\x01\x90V[a\x08\xB3V[\x90aV\xB4aV\xAF\x83aV\x85V[a\x15\x8AV[\x91\x82RV[aV\xC3`\x80a\x15\x8AV[\x90V[\x90aW-aW$`\x03aV\xD7aV\xB9V[\x94aV\xEEaV\xE6_\x83\x01a\x08\xF0V[_\x88\x01aJdV[aW\x06aV\xFD`\x01\x83\x01a\t.V[` \x88\x01aBNV[aW\x1EaW\x15`\x02\x83\x01a\t.V[`@\x88\x01aBNV[\x01a\tUV[``\x84\x01aJgV[V[aW8\x90aV\xC6V[\x90V[\x90aWE\x82a\x07\x82V[aWN\x81aV\xA2V[\x92aW\\` \x85\x01\x91a\x07\x86V[_\x91[\x83\x83\x10aWlWPPPPV[`\x04` `\x01\x92aW|\x85aW/V[\x81R\x01\x92\x01\x92\x01\x91\x90aW_V[aW\x93\x90aW;V[\x90V[aW\xADaW\xB2\x91aW\xA5aV\x80V[P`\x08a\x07XV[aW\x8AV[\x90V[aW\xE3\x90aW\xDEaW\xD9aW\xD2aW\xCD\x84`\x06a2\xC5V[a2\xDBV[3\x90ad8V[a7\x0BV[aX>V[V[_\x7FCannot go offline while slashed\0\x91\x01RV[aX\x19`\x1F` \x92a\t\xC5V[aX\"\x81aW\xE5V[\x01\x90V[aX;\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaX\x0CV[\x90V[aX\\aXWaXP`\x03\x84\x90a\x0EsV[3\x90a\x0E\xBDV[aH\xA0V[\x90aXi`\x01\x83\x01a\x0FNV[\x91\x82aX~aXx`\x03a\x10\x04V[\x91a\x10\x04V[\x14aY\x04WaX\x92\x90`\x01`\x04\x91\x01a3\x12V[aX\xB0aX\xA9aX\xA4`\x04\x84\x90a2\xC5V[a2\xDBV[3\x90ak\xC1V[P\x903\x90\x91`\x04aX\xEAaX\xE4\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07<V[\x93a\x0E\xB1V[\x93aX\xFFaX\xF6a\x03\x92V[\x92\x83\x92\x83aN\x1DV[\x03\x90\xA3V[aY\x0Ca\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aY\"`\x04\x82\x01aX&V[\x03\x90\xFD[aY/\x90aW\xB5V[V[\x90aYe\x96\x95\x94\x93\x92\x91aY`aY[aYTaYO\x84`\x06a2\xC5V[a2\xDBV[3\x90ad8V[a7\x0BV[a[fV[V[`\xC0\x1B\x90V[aYv\x90aYgV[\x90V[aY\x85aY\x8A\x91a\x03\xA4V[aYmV[\x90RV[`\xF8\x1B\x90V[aY\x9D\x90aY\x8EV[\x90V[aY\xACaY\xB1\x91a\x04\x9FV[aY\x94V[\x90RV[\x90P\x90V[\x90\x91\x82aY\xCA\x81aY\xD1\x93aY\xB5V[\x80\x93a\x15\xEBV[\x01\x90V[`\x08`\x01\x93aY\xF9\x82\x84aY\xF1aZ\x01\x96aZ\x08\x9C\x9A\x98aYyV[\x01\x80\x92aYyV[\x01\x80\x92aY\xA0V[\x01\x91aY\xBAV[\x90V[_\x7F\x19Ethereum Signed Message:\n32\0\0\0\0\x91\x01RV[aZ>`\x1C\x80\x92a\x1C\x01V[aZG\x81aZ\x0BV[\x01\x90V[\x90V[aZZaZ_\x91a\r\xACV[aZKV[\x90RV[\x90aZyaZr` \x93aZ2V[\x80\x92aZNV[\x01\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11aZ\x9BWaZ\x97` \x91a\x08\xA9V[\x01\x90V[a\x08\xB3V[\x90\x92\x91\x92aZ\xB5aZ\xB0\x82aZ}V[a\x15\x8AV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11aZ\xD1WaZ\xCF\x92a\x15\xEBV[V[a\x15\xC4V[aZ\xE1\x916\x91aZ\xA0V[\x90V[_\x7FInvalid signature\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a[\x18`\x11` \x92a\t\xC5V[a[!\x81aZ\xE4V[\x01\x90V[a[:\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra[\x0BV[\x90V[\x15a[DWV[a[La\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a[b`\x04\x82\x01a[%V[\x03\x90\xFD[\x90\x94a\\\x04a\\\x1C\x91a[\xFEa\\'\x99a[\xD6a[\xE5\x88a[\xAF\x8Da[\xA0\x8D\x8F\x8D\x93\x95\x91\x90\x91a[\x94a\x03\x92V[\x96\x87\x95` \x87\x01aY\xD5V[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xC7V[a[\xC1a[\xBB\x82a8\xF9V[\x91a8\xF3V[ a[\xCAa\x03\x92V[\x92\x83\x91` \x83\x01aZcV[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xC7V[a[\xF7a[\xF1\x82a8\xF9V[\x91a8\xF3V[ \x92aZ\xD6V[\x90ak\xFBV[a\\\x16a\\\x103a\x03\xDFV[\x91a\x03\xDFV[\x14a[=V[\x933\x91\x92\x93\x94ae\xE7V[V[\x90a\\8\x96\x95\x94\x93\x92\x91aY1V[V[\x90\x91\x82a\\J\x81a\\Q\x93a\x1C\x01V[\x80\x93a\x15\xEBV[\x01\x90V[a\\f\x90` \x94\x93a\\m\x93a\\:V[\x80\x92a\x1C2V[\x01\x90V[\x90\x91a\\\x88\x90a\\\x7Fa\x03\x92V[\x93\x84\x93\x84a\\UV[\x03\x90 \x90V[\x90\x91a\\\x99\x92a\\qV[\x90V[\x92a\\\xC1a\\\xC9\x93\x92a\\\xBCa\\\xCE\x96a\\\xB4a'?V[P`\ta\x1B\xD5V[a\x1B\xEBV[\x91\x90\x91a\\\x8EV[a\t.V[\x90V[a\\\xD9aF0V[Pa\\\xE4`\x01a%NV[\x90V[a\\\xF1\x90Qa\x10\x04V[\x90V[\x90V[a]\x0Ba]\x06a]\x10\x92a\\\xF4V[a\x079V[a\x05DV[\x90V[` \x7Fl\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x7FOperator not eligible for remova_\x82\x01R\x01RV[a]m`!`@\x92a\t\xC5V[a]v\x81a]\x13V[\x01\x90V[a]\x8F\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra]`V[\x90V[\x15a]\x99WV[a]\xA1a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a]\xB7`\x04\x82\x01a]zV[\x03\x90\xFD[\x90a^la^ga^q\x933a]\xECa]\xE6a]\xE1a]\xDC`\x07\x86\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14\x80\x15a_*W[a]\xFD\x90aP*V[a^\x1Ba^\x16a^\x0F`\x03\x84\x90a\x0EsV[\x86\x90a\x0E\xBDV[aC\x07V[a^'``\x82\x01a\\\xE7V[a^:a^4`\x03a\x10\x04V[\x91a\x10\x04V[\x03a^tW[Pa^_a^Xa^S`\x05\x84\x90a2\xC5V[a2\xDBV[\x85\x90ak\xC1V[P`\x04a2\xC5V[a2\xDBV[ak\xC1V[PV[a^\xF0\x90a^\xC4a^\xB4a^\x87\x85abKV[a^\xAEa^\xA9` a^\xA2a^\x9D_\x86\x01aD4V[aDAV[\x93\x01aD\x0BV[aD]V[\x90a(\x89V[a^\xBE`\na\\\xF7V[\x90a(\x89V[a^\xCF_\x83\x01a:\x14V[a^\xE1a^\xDB_a,SV[\x91a\x05DV[\x11\x91\x82a^\xF6W[PPa]\x92V[_a^@V[a_!\x91\x92Pa_\x15a_\x1B\x91a_\x0F_B\x92\x01a:\x14V[\x90aS\x8CV[\x92a\x05DV[\x91a\x05DV[\x10\x15_\x80a^\xE9V[Pa]\xFD3a_Ha_Ba_=aF4V[a\x03\xDFV[\x91a\x03\xDFV[\x14\x90Pa]\xF4V[\x90a_za_\x7F\x91a_`a5\xFDV[Pa_ua_m\x85abKV[\x94`\x03a\x0EsV[a\x0E\xBDV[aC\x07V[a_\x8A_\x82\x01a:\x14V[a_\x9Ca_\x96_a,SV[\x91a\x05DV[\x14a_\xD7Wa_\xCDa_\xC8_a_\xC1a_\xD3\x94a_\xBB\x83B\x92\x01a:\x14V[\x90aS\x8CV[\x94\x01aD4V[aDAV[\x91a\x05DV[\x10\x90V[PP_\x90V[a_\xEE\x90a_\xE9accV[a_\xF0V[V[a_\xFB\x81`\x01a&+V[a`\x03aF4V[\x90a`7a`1\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0\x93a\x0E\xB1V[\x91a\x0E\xB1V[\x91a`@a\x03\x92V[\x80a`J\x81a\x04;V[\x03\x90\xA3V[a`X\x90a_\xDDV[V[_a`\x99a`\x9F\x93a`\x913a`\x8Ba`\x85a`\x80a`{`\x07\x8A\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14a'\xC6V[\x92`\x02a\"\x18V[\x01aQ\xA2V[V[_\x7FNot registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a`\xD5`\x0E` \x92a\t\xC5V[a`\xDE\x81a`\xA1V[\x01\x90V[a`\xF7\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra`\xC8V[\x90V[\x15aa\x01WV[aa\ta\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aa\x1F`\x04\x82\x01a`\xE2V[\x03\x90\xFD[aa_3aaYaaS\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xDFV[\x91a\x03\xDFV[\x14a%\x11V[aa\x85aa\x80aayaat`\x06\x85\x90a2\xC5V[a2\xDBV[\x84\x90ak\xC1V[a`\xFAV[aa\xA3aa\x9Caa\x97`\x04\x84\x90a2\xC5V[a2\xDBV[\x83\x90ak\xC1V[P\x90aa\xD8aa\xD2\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E\x93a\x07<V[\x91a\x0E\xB1V[\x91aa\xE1a\x03\x92V[\x80aa\xEB\x81a\x04;V[\x03\x90\xA3V[\x90ab=ab4_ab\0a&\xD4V[\x94ab\x17ab\x0F\x83\x83\x01a\x0E\xF4V[\x83\x88\x01aB\\V[ab.ab%\x83\x83\x01a\x0F!V[` \x88\x01aBjV[\x01a\"BV[`@\x84\x01aJgV[V[abH\x90aa\xF0V[\x90V[abbabg\x91abZa'\x1FV[P`\x02a\"\x18V[ab?V[abr_\x82\x01aD4V[ab\x84ab~_aT\x03V[\x91a\x03\xA4V[\x14ab\xCAW[ab\x96` \x82\x01aD\x0BV[ab\xA8ab\xA2_aD\x18V[\x91a\x04\x9FV[\x14ab\xB1W[\x90V[ab\xC5ab\xBCa\x14\xDDV[` \x83\x01aBjV[ab\xAEV[ab\xDDab\xD5a\n\xC2V[_\x83\x01aB\\V[ab\x8AV[ab\xEB\x90a\x0E\x89V[\x90V[ac\x02ab\xFDac\x07\x92a\x03\xD4V[a\x079V[a\x05DV[\x90V[ac\x1Eac\x19ac#\x92a\x05DV[a&\x08V[a\r\xACV[\x90V[\x90V[\x90ac[acUacPacK_ac`\x96acCa5\xFDV[P\x01\x94ab\xE2V[ab\xEEV[ac\nV[\x91ac&V[al\xC6V[\x90V[ackaF4V[ac\x84ac~acyajoV[a\x03\xDFV[\x91a\x03\xDFV[\x03ac\x8BWV[ac\xADac\x96ajoV[_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0B\x83V[\x03\x90\xFD[ac\xC8_ac\xCD\x92ac\xC1a'?V[P\x01ac&V[am)V[\x90V[ac\xDCac\xE1\x91a\t\x12V[a)\x0FV[\x90V[ac\xF8ac\xF3ac\xFD\x92a\x05DV[a\x079V[a\x03\xD4V[\x90V[ad+ad&ad5\x93ad!_ad0\x95ad\x1AaF0V[P\x01ac&V[am\x9BV[ac\xD0V[ac\xE4V[a\x0E\xA5V[\x90V[\x90adjaddad_adZ_ado\x96adRa5\xFDV[P\x01\x94ab\xE2V[ab\xEEV[ac\nV[\x91ac&V[am\xBCV[\x90V[_\x7FOperator is slashed\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[ad\xA6`\x13` \x92a\t\xC5V[ad\xAF\x81adrV[\x01\x90V[ad\xC8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rad\x99V[\x90V[\x15ad\xD2WV[ad\xDAa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80ad\xF0`\x04\x82\x01ad\xB3V[\x03\x90\xFD[ad\xFD\x90a\r\xACV[\x90V[ae\t\x90a\t\x12V[\x90V[\x90ae!ae\x1Cae(\x92ad\xF4V[ae\0V[\x82Ta/\x93V[\x90UV[ae5\x90a\x03\xA4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x14aeJW`\x01\x01\x90V[a(uV[\x90V[aefaeaaek\x92aeOV[a\x079V[a\x04\x9FV[\x90V[\x91` ae\x8F\x92\x94\x93ae\x88`@\x82\x01\x96_\x83\x01\x90a\x0F\xD4V[\x01\x90a\x05GV[V[ae\x9A\x90a\x0E\x89V[\x90V[ae\xA6\x90ae\x91V[\x90V[ae\xB2\x90a\x0E\xA5V[\x90V[`@\x90ae\xDEae\xE5\x94\x96\x95\x93\x96ae\xD4``\x84\x01\x98_\x85\x01\x90a\x0BvV[` \x83\x01\x90a\n\xDBV[\x01\x90a\n\xDBV[V[\x94\x92\x93\x91\x93af\naf\x05ae\xFE`\x03\x89\x90a\x0EsV[\x87\x90a\x0E\xBDV[aH\xA0V[\x93af\x14\x87abKV[\x93af>af$`\x01\x88\x01a\x0FNV[af7af1`\x03a\x10\x04V[\x91a\x10\x04V[\x14\x15ad\xCBV[af\\afUafP`\x05\x8B\x90a2\xC5V[a2\xDBV[\x88\x90ac)V[Pag1`@afn`\x01\x89\x01a\x0FNV[\x96af{B_\x8B\x01a/\xA9V[af\xA5af\x89\x85\x87\x90aZ\xD6V[af\x9Baf\x95\x82a8\xF9V[\x91a8\xF3V[ `\x02\x8B\x01ae\x0CV[af\xBAaf\xB1_aD\x18V[`\x01\x8B\x01aM\xFDV[af\xD8`\x01\x8A\x01af\xD2af\xCD\x82a\x0E\xF4V[ae,V[\x90aH\xDFV[af\xE0a7\xB3V[P\x85af\xF4af\xEE_aD\x18V[\x91a\x04\x9FV[\x14_\x14ai\xB5Wag\x0B_\x99[`\x01\x8B\x91\x01a3\x12V[\x87ag\x1Fag\x19`\x02a\x10\x04V[\x91a\x10\x04V[\x14\x80ai\x99W[ai+W[\x01aKTV[\x80ai\x07W[ah\xF1W[PP\x85\x91\x85\x91\x92Bag\x80agzagt\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x94a\x07<V[\x94a\x07<V[\x94a\x0E\xB1V[\x94ag\x95ag\x8Ca\x03\x92V[\x92\x83\x92\x83aenV[\x03\x90\xA4\x80ag\xABag\xA5\x84a\x10\x04V[\x91a\x10\x04V[\x03ah\x9BW[PPag\xBD`\x0Ba%NV[ag\xD7ag\xD1ag\xCC_a%zV[a\x03\xDFV[\x91a\x03\xDFV[\x03ag\xE1W[PPV[ag\xFBag\xF6ag\xF1`\x0Ba%NV[ae\x9DV[ae\xA9V[\x91c\xD4xS\xB6\x91\x90\x92ah\rBaH\xA3V[\x92\x81;\x15ah\x96W_ah3\x91ah>\x82\x96ah'a\x03\x92V[\x98\x89\x97\x88\x96\x87\x95aFsV[\x85R`\x04\x85\x01ae\xB5V[\x03\x92Z\xF1\x90\x81ahjW[P\x15_\x14aheW`\x01ah`W[[_\x80ag\xDDV[ahXV[ahYV[ah\x89\x90_=\x81\x11ah\x8FW[ah\x81\x81\x83a\x08\xC7V[\x81\x01\x90aFyV[_ahIV[P=ahwV[aFoV[\x83\x83\x91\x92ah\xD2ah\xCC\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07<V[\x93a\x0E\xB1V[\x93ah\xE7ah\xDEa\x03\x92V[\x92\x83\x92\x83aN\x1DV[\x03\x90\xA3_\x80ag\xB1V[ai\0\x91\x88\x91\x88\x90\x91\x92aq\xDDV[_\x80ag<V[Pai\x13\x81\x83\x90a-\x0FV[ai%ai\x1F_a,SV[\x91a\x05DV[\x11ag7V[aiHaiAai<\x8D`\x04a2\xC5V[a2\xDBV[\x8B\x90ac)V[P\x8A\x8Aai~aix\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07<V[\x91a\x0E\xB1V[\x91ai\x87a\x03\x92V[\x80ai\x91\x81a\x04;V[\x03\x90\xA3ag+V[P\x88ai\xAEai\xA8`\x02a\x10\x04V[\x91a\x10\x04V[\x14\x15ag&V[\x85ai\xC9ai\xC3`daeRV[\x91a\x04\x9FV[\x10_\x14ai\xDCWag\x0B`\x01\x99[ag\x01V[ag\x0B`\x01\x99ai\xF4\x8D\x8D\x8B\x90\x8B\x90\x8A\x92\x8C\x94an\x91V[ai\xD7V[\x91\x90`\x08aj\x19\x91\x02\x91aj\x13`\x01\x80`\xA0\x1B\x03\x84a(\xE6V[\x92a(\xE6V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x91\x90aj9aj4ajA\x93a\x0E\xB1V[a&(V[\x90\x83Tai\xF9V[\x90UV[ajW\x91ajQaF0V[\x91aj#V[V[ajm\x90ajh_`\x01ajEV[as\x9BV[V[ajwaF0V[P3\x90V[aj\x85\x90a\x05DV[_\x19\x81\x14aj\x93W`\x01\x01\x90V[a(uV[aj\xA2\x90Qa\x03\xDFV[\x90V[\x93\x91\x92\x93aj\xB1a4\xCEV[Paj\xC5aj\xC0\x85\x84\x90aS\x8CV[a5\x0CV[\x92aj\xCF_a,SV[\x92[\x80aj\xE4aj\xDE\x88a\x05DV[\x91a\x05DV[\x10\x15akRWak\x08ak\x01aj\xFC`\x05\x86\x90a2\xC5V[a2\xDBV[\x82\x90ad\0V[ak\x14\x84\x82\x8A\x91as\xFAV[ak(W[Pak#\x90a,oV[aj\xD1V[ak#\x91\x94akFakK\x92akA\x89\x91\x84\x90\x92a53V[a5SV[aj|V[\x93\x90ak\x19V[P\x94PP\x91Paka\x82a5\x0CV[\x92akk_a,SV[[\x80ak\x7Faky\x86a\x05DV[\x91a\x05DV[\x10\x15ak\xBBWak\xB6\x90ak\xB1ak\x9Fak\x9A\x86\x84\x90a53V[aj\x98V[ak\xAC\x88\x91\x84\x90\x92a53V[a5SV[a,oV[aklV[P\x91PPV[\x90ak\xF3ak\xEDak\xE8ak\xE3_ak\xF8\x96ak\xDBa5\xFDV[P\x01\x94ab\xE2V[ab\xEEV[ac\nV[\x91ac&V[auFV[\x90V[al\x1A\x91al\x11\x91al\x0BaF0V[PavsV[\x90\x92\x91\x92aw3V[\x90V[\x90V[_R` _ \x90V[T\x90V[al6\x81al)V[\x82\x10\x15alPWalH`\x01\x91al V[\x91\x02\x01\x90_\x90V[a\x07nV[\x91\x90alkalfals\x93ad\xF4V[ae\0V[\x90\x83Ta(\xEAV[\x90UV[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15al\xA7W\x82al\x9F\x91`\x01al\xA5\x95\x01\x81Ual-V[\x90alUV[V[a\x08\xB3V[T\x90V[\x90al\xBA\x90ad\xF4V[_R` R`@_ \x90V[al\xCEa5\xFDV[Pal\xE3al\xDD\x82\x84\x90am\xBCV[\x15a\x04\xB2V[_\x14am#Wam\x19am\x1E\x92am\x05al\xFE_\x85\x01al\x1DV[\x82\x90alwV[`\x01am\x12_\x85\x01al\xACV[\x93\x01al\xB0V[a/\xA9V[`\x01\x90V[PP_\x90V[_am=\x91am6a'?V[P\x01al\xACV[\x90V[_\x90V[_R` _ \x90V[amV\x81al\xACV[\x82\x10\x15ampWamh`\x01\x91amDV[\x91\x02\x01\x90_\x90V[a\x07nV[am\x85\x90`\x08am\x8A\x93\x02a\x0B2V[a\x0F[V[\x90V[\x90am\x98\x91TamuV[\x90V[am\xB9\x91_am\xB3\x92am\xACam@V[P\x01amMV[\x90am\x8DV[\x90V[am\xDA\x91`\x01am\xD5\x92am\xCEa5\xFDV[P\x01al\xB0V[a\t.V[am\xECam\xE6_a,SV[\x91a\x05DV[\x14\x15\x90V[an\x05an\0an\n\x92a\x11\xB9V[a\x079V[a\x04\x9FV[\x90V[an\x19an\x1F\x91a\x03\xA4V[\x91a\x03\xA4V[\x90\x03\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11an3WV[a(uV[_\x7FProtocol violation reported\0\0\0\0\0\x91\x01RV[anl`\x1B` \x92a\t\xC5V[anu\x81an8V[\x01\x90V[an\x8E\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ran_V[\x90V[\x93PP\x92Pan\xA9an\xA3`\xC8am\xF1V[\x91a\x04\x9FV[\x10\x15an\xB4W[PPV[an\xBDBaH\xA3V[an\xDBan\xD6an\xCF`\x0C\x85\x90aC?V[\x85\x90aCUV[a\x0E\xF4V[\x80an\xEEan\xE8_aT\x03V[\x91a\x03\xA4V[\x14\x90\x81\x15aotW[Pao\x03W[Pan\xB0V[ao\"\x90ao\x1Dao\x16`\x0C\x85\x90aC?V[\x85\x90aCUV[aH\xDFV[\x90aoVaoP\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07<V[\x91a\x0E\xB1V[\x91ao_a\x03\x92V[\x80aoi\x81anyV[\x03\x90\xA3_\x80\x80an\xFDV[ao\x7F\x91P\x82an\rV[ao\x98ao\x92ao\x8Da\x0E%V[a\x03\xA4V[\x91a\x03\xA4V[\x10\x15_an\xF7V[\x90V[ao\xB7ao\xB2ao\xBC\x92ao\xA0V[a\x079V[a\x05DV[\x90V[\x90\x92\x91\x92ao\xD4ao\xCF\x82a\x15\xC8V[a\x15\x8AV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11ao\xF0Wao\xEE\x92a\t\xCEV[V[a\x15\xC4V[\x90\x80`\x1F\x83\x01\x12\x15ap\x13W\x81` ap\x10\x93Q\x91\x01ao\xBFV[\x90V[a\x05\x9FV[\x90PQ\x90ap%\x82a\x06\xE9V[V[\x91\x90\x91`@\x81\x84\x03\x12apzWap>`@a\x15\x8AV[\x92_\x82\x01Q\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11apuWapb\x82apn\x94\x83\x01ao\xF5V[_\x86\x01R` \x01ap\x18V[` \x83\x01RV[a\x15\xC0V[a\x15\xBCV[\x92\x91\x90ap\x93ap\x8E\x82a\x15\x9FV[a\x15\x8AV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11ap\xEAW\x81\x90[\x83\x82\x10ap\xB9WPPPPPV[\x81Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11ap\xE5W` \x91ap\xDA\x87\x84\x93\x87\x01ap'V[\x81R\x01\x91\x01\x90ap\xABV[a\x05\x9FV[a\x05\xA7V[\x90\x80`\x1F\x83\x01\x12\x15aq\rW\x81` aq\n\x93Q\x91\x01ap\x7FV[\x90V[a\x05\x9FV[\x90` \x82\x82\x03\x12aqBW_\x82\x01Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11aq=Waq:\x92\x01ap\xEFV[\x90V[a\x03\xA0V[a\x03\x9CV[` \x91\x81R\x01\x90V[\x91\x90aqj\x81aqc\x81aqo\x95aqGV[\x80\x95a\x15\xEBV[a\x08\xA9V[\x01\x90V[\x90\x91aq\x8A\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaqPV[\x90V[aq\x97`2a\x14\x1FV[\x90V[\x94\x93\x91``\x91aq\xDB\x94aq\xC6aq\xD3\x93aq\xBC`\x80\x8B\x01\x94_\x8C\x01\x90a\n\xDBV[` \x8A\x01\x90a\x0BvV[\x87\x82\x03`@\x89\x01Ra\x0C\xD3V[\x94\x01\x90a\x05GV[V[\x91aq\xE9\x81\x85\x90a-\x0FV[aq\xFBaq\xF5_a,SV[\x91a\x05DV[\x14as\x95War\x0B\x81\x85\x90a-\x0FV[ar\x1Far\x19a\xC3Pao\xA3V[\x91a\x05DV[\x11as\x8FW_ar-a4SV[\x94ar70a7\xE2V[arYc1\xE3\xBD\x1B\x94\x92\x94ardarMa\x03\x92V[\x96\x87\x95\x86\x94\x85\x94aFsV[\x84R`\x04\x84\x01aqsV[\x03\x91Z\xFA\x80\x91_\x92askW[P\x15_\x14asbWP`\x01as]W[ar\x8A\x83a\x0CBV[ar\xA3ar\x9Dar\x98aq\x8DV[a\x05DV[\x91a\x05DV[\x11_\x14asOWar\xB2aq\x8DV[[ar\xBC0a7\xE2V[\x90ce\xA6\x93n\x93\x92\x94\x90\x82;\x15asJW_\x94ar\xF7\x86\x92ar\xEC\x94ar\xE0a\x03\x92V[\x99\x8A\x98\x89\x97\x88\x96aFsV[\x86R`\x04\x86\x01aq\x9AV[\x03\x92Z\xF1\x90\x81as\x1EW[P\x15_\x14as\x19W`\x01as\x14W[[V[as\x11V[as\x12V[as=\x90_=\x81\x11asCW[as5\x81\x83a\x08\xC7V[\x81\x01\x90aFyV[_as\x02V[P=as+V[aFoV[asX\x83a\x0CBV[ar\xB3V[PPPV[\x90\x92P\x91ar\x81V[as\x88\x91\x92P=\x80_\x83>as\x80\x81\x83a\x08\xC7V[\x81\x01\x90aq\x12V[\x90_arqV[PPPPV[PPPPV[as\xA4_a%NV[as\xAE\x82_a&+V[\x90as\xE2as\xDC\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x0E\xB1V[\x91a\x0E\xB1V[\x91as\xEBa\x03\x92V[\x80as\xF5\x81a\x04;V[\x03\x90\xA3V[at\x02a5\xFDV[Pat*at$at\x1Dat\x18`\x06\x85\x90a2\xC5V[a2\xDBV[\x84\x90ad8V[\x15a\x04\xB2V[at\xCCWatJ\x91at@atE\x92`\x03a\x0EsV[a\x0E\xBDV[aC\x07V[atU_\x82\x01a:\x14V[atgata_a,SV[\x91a\x05DV[\x14\x80\x15at\xA6W[at\xA0Wat\x95at\x8Fat\x9B\x92at\x89_B\x92\x01a:\x14V[\x90aS\x8CV[\x92a\x05DV[\x91a\x05DV[\x10\x15\x90V[PP_\x90V[Pat\xB3``\x82\x01a\\\xE7V[at\xC6at\xC0`\x03a\x10\x04V[\x91a\x10\x04V[\x14atoV[PPP_\x90V[at\xE7at\xE2at\xEC\x92aP\xF4V[a\x079V[a\x05DV[\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[au\x15\x91au\x0Fam@V[\x91alUV[V[au \x81al)V[\x80\x15auAW`\x01\x90\x03\x90au>au8\x83\x83al-V[\x90au\x03V[UV[at\xEFV[auNa5\xFDV[Paueau``\x01\x83\x01\x84\x90al\xB0V[a\t.V[\x90\x81auyaus_a,SV[\x91a\x05DV[\x14\x15_\x14avEWau\xF7\x92`\x01au\xF2\x92\x84au\xA0_\x96au\x9A\x85at\xD3V[\x90aS\x8CV[au\xBDau\xAE\x88\x85\x01al\xACV[au\xB7\x86at\xD3V[\x90aS\x8CV[\x81au\xD0au\xCA\x83a\x05DV[\x91a\x05DV[\x03au\xFCW[PPPau\xECau\xE7\x86\x83\x01al\x1DV[au\x17V[\x01al\xB0V[a)PV[`\x01\x90V[av=\x92av/av\x1Bav\x15av8\x94\x8C\x89\x01amMV[\x90am\x8DV[\x93av)\x85\x91\x8C\x89\x01amMV[\x90alUV[\x91\x85\x85\x01al\xB0V[a/\xA9V[_\x80\x80au\xD6V[PPP_\x90V[_\x90V[\x90V[avgavbavl\x92avPV[a\x079V[a\x05DV[\x90V[_\x90V[\x91\x90\x91av~aF0V[Pav\x87avLV[Pav\x90am@V[Pav\x9A\x83a8\xF9V[av\xADav\xA7`AavSV[\x91a\x05DV[\x14_\x14av\xF4Wav\xED\x91\x92av\xC1am@V[Pav\xCAam@V[Pav\xD3avoV[P` \x81\x01Q```@\x83\x01Q\x92\x01Q_\x1A\x90\x91\x92ax}V[\x91\x92\x90\x91\x90V[Pav\xFE_a%zV[\x90aw\x12aw\r`\x02\x94a8\xF9V[ac\nV[\x91\x92\x91\x90V[`\x04\x11\x15aw\"WV[a\x0F\xE1V[\x90aw1\x82aw\x18V[V[\x80awFaw@_aw'V[\x91aw'V[\x14_\x14awQWPPV[\x80aweaw_`\x01aw'V[\x91aw'V[\x14_\x14aw\x88W_c\xF6E\xEE\xDF`\xE0\x1B\x81R\x80aw\x84`\x04\x82\x01a\x04;V[\x03\x90\xFD[\x80aw\x9Caw\x96`\x02aw'V[\x91aw'V[\x14_\x14aw\xCAWaw\xC6aw\xAF\x83ac\xD0V[_\x91\x82\x91c\xFC\xE6\x98\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x05TV[\x03\x90\xFD[aw\xDDaw\xD7`\x03aw'V[\x91aw'V[\x14aw\xE5WPV[ax\0\x90_\x91\x82\x91c5\xE2\xF3\x83`\xE2\x1B\x83R`\x04\x83\x01a\r\xBCV[\x03\x90\xFD[\x90V[ax\x1Bax\x16ax \x92ax\x04V[a\x079V[a\x05DV[\x90V[axXax_\x94axN``\x94\x98\x97\x95axD`\x80\x86\x01\x9A_\x87\x01\x90a\r\xAFV[` \x85\x01\x90a\x0F\xD4V[`@\x83\x01\x90a\r\xAFV[\x01\x90a\r\xAFV[V[axuaxpaxz\x92a%[V[a&\x08V[a\r\xACV[\x90V[\x93\x92\x93ax\x88aF0V[Pax\x91avLV[Pax\x9Aam@V[Pax\xA4\x85ac\xD0V[ax\xD6ax\xD0\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0ax\x07V[\x91a\x05DV[\x11aycW\x90ax\xF9` \x94\x95_\x94\x93\x92\x93ax\xF0a\x03\x92V[\x94\x85\x94\x85ax#V[\x83\x80R\x03\x90`\x01Z\xFA\x15ay^Way\x11_Qa&\x08V[\x80ay,ay&ay!_a%zV[a\x03\xDFV[\x91a\x03\xDFV[\x14ayBW_\x91ay<_axaV[\x91\x92\x91\x90V[PayL_a%zV[`\x01\x91ayX_axaV[\x91\x92\x91\x90V[aF\xABV[PPPayo_a%zV[\x90`\x03\x92\x91\x92\x91\x90V\xFE\xA1dsolcC\0\x08\x1A\0\n",
    );
    /// The runtime bytecode of the contract, as deployed on the network.
    ///
    /// ```text
    ///0x60806040526004361015610013575b6124b4565b61001d5f3561038c565b806305778550146103875780630758236f146103825780630c76697a1461037d578063191cbd1a146103785780631e8f5ee514610373578063208129561461036e57806322f1ec93146103695780632c957688146103645780632dae18851461035f57806331e3bd1b1461035a5780633644e515146103555780633ac3cbe6146103505780633e6e34a71461034b5780633fd62c6d1461034657806340235a9c1461034157806348f4da201461033c5780635685cf681461033757806356c4e17d1461033257806359dcea121461032d5780635a936dc6146103285780635cce98a6146103235780636076439c1461031e57806360cf09911461031957806361d6b86c1461031457806362c7e8fc1461030f57806365a6936e1461030a5780636bfe06a614610305578063715018a61461030057806371e7388c146102fb5780637639d227146102f657806379ba5097146102f15780637b9f64b2146102ec57806381beac2e146102e757806384ef7322146102e25780638da5cb5b146102dd57806396686c1e146102d85780639cbdae22146102d3578063adff830c146102ce578063ae470a85146102c9578063b074e9dd146102c4578063b99f6759146102bf578063ba1fb103146102ba578063c1ef9ddf146102b5578063c5d960bb146102b0578063cfe34749146102ab578063d413a580146102a6578063d551162c146102a1578063da435a7c1461029c578063e30c397814610297578063e65cafcb14610292578063ee1c03901461028d578063f2fde38b14610288578063f9107f3b14610283578063f9f167621461027e5763ffcf08f00361000e57612480565b61244b565b6123e8565b612388565b612352565b61231e565b6122e9565b6122b1565b6121df565b6121a5565b6120e7565b6120a5565b612070565b611f46565b611f12565b611ea5565b611e6b565b611da0565b611cd9565b611b50565b611a96565b611a63565b611a2c565b611997565b611964565b61192e565b6118f8565b61183c565b611807565b611799565b611554565b61150a565b611488565b611453565b6113e5565b61132d565b6112d4565b61129f565b61123a565b6111f0565b611184565b6110b0565b611076565b610e3e565b610dd1565b610d52565b610b98565b610afd565b610a5a565b6106b6565b610664565b610630565b610569565b61050f565b610440565b60e01c90565b60405190565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff1690565b6103ba816103a4565b036103c157565b5f80fd5b905035906103d2826103b1565b565b60018060a01b031690565b6103e8906103d4565b90565b6103f4816103df565b036103fb57565b5f80fd5b9050359061040c826103eb565b565b9190604083820312610436578061042a610433925f86016103c5565b936020016103ff565b90565b61039c565b5f0190565b3461046f5761045961045336600461040e565b9061264b565b610461610392565b8061046b8161043b565b0390f35b610398565b9060208282031261048d5761048a915f016103c5565b90565b61039c565b61049b906103a4565b9052565b60ff1690565b6104ae9061049f565b9052565b151590565b6104c0906104b2565b9052565b906040806104f8936104dc5f8201515f860190610492565b6104ee602082015160208601906104a5565b01519101906104b7565b565b919061050d905f606085019401906104c4565b565b3461053f5761053b61052a610525366004610474565b61272a565b610532610392565b918291826104fa565b0390f35b610398565b90565b61055090610544565b9052565b9190610567905f60208501940190610547565b565b3461059a5761059661058561057f36600461040e565b90612743565b61058d610392565b91829182610554565b0390f35b610398565b5f80fd5b5f80fd5b5f80fd5b909182601f830112156105e55781359167ffffffffffffffff83116105e05760200192602083028401116105db57565b6105a7565b6105a3565b61059f565b91909160408184031261062b57610603835f83016103c5565b92602082013567ffffffffffffffff81116106265761062292016105ab565b9091565b6103a0565b61039c565b3461065f576106496106433660046105ea565b916130cc565b610651610392565b8061065b8161043b565b0390f35b610398565b346106935761067d61067736600461040e565b90613332565b610685610392565b8061068f8161043b565b0390f35b610398565b906020828203126106b1576106ae915f016103ff565b90565b61039c565b346106e4576106ce6106c9366004610698565b613448565b6106d6610392565b806106e08161043b565b0390f35b610398565b6106f281610544565b036106f957565b5f80fd5b9050359061070a826106e9565b565b91906040838203126107345780610728610731925f86016103c5565b936020016106fd565b90565b61039c565b90565b61075061074b610755926103a4565b610739565b6103a4565b90565b906107629061073c565b5f5260205260405f2090565b634e487b7160e01b5f52603260045260245ffd5b5490565b5f5260205f2090565b5f5260205f2090565b6107a181610782565b8210156107bb576107b3600491610786565b910201905f90565b61076e565b634e487b7160e01b5f52602260045260245ffd5b90600160028304921680156107f4575b60208310146107ef57565b6107c0565b91607f16916107e4565b60209181520190565b5f5260205f2090565b905f929180549061082a610823836107d4565b80946107fe565b916001811690815f146108815750600114610845575b505050565b6108529192939450610807565b915f925b81841061086957505001905f8080610840565b60018160209295939554848601520191019290610856565b92949550505060ff19168252151560200201905f8080610840565b906108a691610810565b90565b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b906108d1906108a9565b810190811067ffffffffffffffff8211176108eb57604052565b6108b3565b9061091061090992610900610392565b9384809261089c565b03836108c7565b565b5f1c90565b90565b61092661092b91610912565b610917565b90565b610938905461091a565b90565b60ff1690565b61094d61095291610912565b61093b565b90565b61095f9054610941565b90565b61096d906008610758565b9061097782610782565b8110156109bd5761098791610798565b50906109945f83016108f0565b916109a16001820161092e565b916109ba60036109b36002850161092e565b9301610955565b90565b5f80fd5b5190565b60209181520190565b90825f9392825e0152565b6109f8610a01602093610a06936109ef816109c1565b938480936109c5565b958691016109ce565b6108a9565b0190565b610a13906104b2565b9052565b610a51610a5894610a47610a3c6060959998969960808601908682035f8801526109d9565b986020850190610547565b6040830190610547565b0190610a0a565b565b34610a8f57610a8b610a76610a7036600461070c565b90610962565b90610a82949294610392565b94859485610a17565b0390f35b610398565b5f910312610a9e57565b61039c565b90565b610aba610ab5610abf92610aa3565b610739565b6103a4565b90565b610acd61012c610aa6565b90565b610ad8610ac2565b90565b610ae4906103a4565b9052565b9190610afb905f60208501940190610adb565b565b34610b2d57610b0d366004610a94565b610b29610b18610ad0565b610b20610392565b91829182610ae8565b0390f35b610398565b1c90565b60018060a01b031690565b610b51906008610b569302610b32565b610b36565b90565b90610b649154610b41565b90565b610b73600b5f90610b59565b90565b610b7f906103df565b9052565b9190610b96905f60208501940190610b76565b565b34610bc857610ba8366004610a94565b610bc4610bb3610b67565b610bbb610392565b91829182610b83565b0390f35b610398565b909182601f83011215610c075781359167ffffffffffffffff8311610c02576020019260018302840111610bfd57565b6105a7565b6105a3565b61059f565b90602082820312610c3d575f82013567ffffffffffffffff8111610c3857610c349201610bcd565b9091565b6103a0565b61039c565b5190565b60209181520190565b60200190565b610c74610c7d602093610c8293610c6b816109c1565b938480936107fe565b958691016109ce565b6108a9565b0190565b610c8f90610544565b9052565b90610cbd90602080610cb2604084015f8701518582035f870152610c55565b940151910190610c86565b90565b90610cca91610c93565b90565b60200190565b90610ce7610ce083610c42565b8092610c46565b9081610cf860208302840194610c4f565b925f915b838310610d0b57505050505090565b90919293946020610d2d610d2783856001950387528951610cc0565b97610ccd565b9301930191939290610cfc565b610d4f9160208201915f818403910152610cd3565b90565b34610d8357610d7f610d6e610d68366004610c0c565b9061348d565b610d76610392565b91829182610d3a565b0390f35b610398565b7f000000000000000000000000000000000000000000000000000000000000000090565b90565b610db890610dac565b9052565b9190610dcf905f60208501940190610daf565b565b34610e0157610de1366004610a94565b610dfd610dec610d88565b610df4610392565b91829182610dbc565b0390f35b610398565b90565b610e1d610e18610e2292610e06565b610739565b6103a4565b90565b610e30610e10610e09565b90565b610e3b610e25565b90565b34610e6e57610e4e366004610a94565b610e6a610e59610e33565b610e61610392565b91829182610ae8565b0390f35b610398565b90610e7d9061073c565b5f5260205260405f2090565b610e9d610e98610ea2926103d4565b610739565b6103d4565b90565b610eae90610e89565b90565b610eba90610ea5565b90565b90610ec790610eb1565b5f5260205260405f2090565b67ffffffffffffffff1690565b610eec610ef191610912565b610ed3565b90565b610efe9054610ee0565b90565b60401c90565b60ff1690565b610f19610f1e91610f01565b610f07565b90565b610f2b9054610f0d565b90565b60481c90565b60ff1690565b610f46610f4b91610f2e565b610f34565b90565b610f589054610f3a565b90565b90565b610f6a610f6f91610912565b610f5b565b90565b610f7c9054610f5e565b90565b90610f8e610f93926003610e73565b610ebd565b610f9e5f820161092e565b91610fab60018301610ef4565b91610fb860018201610f21565b91610fd16002610fca60018501610f4e565b9301610f72565b90565b610fdd9061049f565b9052565b634e487b7160e01b5f52602160045260245ffd5b60051115610fff57565b610fe1565b9061100e82610ff5565b565b61101990611004565b90565b61102590611010565b9052565b909594926110749461106361106d9261105960809661104f60a088019c5f890190610547565b6020870190610adb565b6040850190610fd4565b606083019061101c565b0190610daf565b565b346110ab576110a761109261108c36600461040e565b90610f7f565b9161109e959395610392565b95869586611029565b0390f35b610398565b346110e0576110dc6110cb6110c6366004610474565b6134a7565b6110d3610392565b91829182610554565b0390f35b610398565b5190565b60209181520190565b60200190565b611101906103df565b9052565b90611112816020936110f8565b0190565b60200190565b9061113961113361112c846110e5565b80936110e9565b926110f2565b905f5b8181106111495750505090565b90919261116261115c6001928651611105565b94611116565b910191909161113c565b6111819160208201915f81840391015261111c565b90565b346111b4576111b061119f61119a366004610474565b613561565b6111a7610392565b9182918261116c565b0390f35b610398565b90565b6111d06111cb6111d5926111b9565b610739565b610544565b90565b6111e260c86111bc565b90565b6111ed6111d8565b90565b3461122057611200366004610a94565b61121c61120b6111e5565b611213610392565b91829182610554565b0390f35b610398565b9190611238905f60208501940190610a0a565b565b3461126b5761126761125661125036600461040e565b90613601565b61125e610392565b91829182611225565b0390f35b610398565b9061127a9061073c565b5f5260205260405f2090565b61129c906112976007915f92611270565b610b59565b90565b346112cf576112cb6112ba6112b5366004610474565b611286565b6112c2610392565b91829182610b83565b0390f35b610398565b34611304576113006112ef6112ea366004610474565b613688565b6112f7610392565b9182918261116c565b0390f35b610398565b7f000000000000000000000000000000000000000000000000000000000000000090565b3461135d5761133d366004610a94565b611359611348611309565b611350610392565b91829182610b83565b0390f35b610398565b61136b8161049f565b0361137257565b5f80fd5b9050359061138382611362565b565b906080828203126113e05761139c815f84016103c5565b926113aa82602085016103c5565b926113b88360408301611376565b92606082013567ffffffffffffffff81116113db576113d79201610bcd565b9091565b6103a0565b61039c565b34611417576114016113f8366004611385565b9392909261377c565b611409610392565b806114138161043b565b0390f35b610398565b90565b61143361142e6114389261141c565b610739565b610544565b90565b611445603261141f565b90565b61145061143b565b90565b3461148357611463366004610a94565b61147f61146e611448565b611476610392565b91829182610554565b0390f35b610398565b346114b9576114b56114a461149e36600461040e565b9061378b565b6114ac610392565b91829182611225565b0390f35b610398565b90565b6114d56114d06114da926114be565b610739565b61049f565b90565b6114e760036114c1565b90565b6114f26114dd565b90565b9190611508905f60208501940190610fd4565b565b3461153a5761151a366004610a94565b6115366115256114ea565b61152d610392565b918291826114f5565b0390f35b610398565b9190611552905f6020850194019061101c565b565b346115855761158161157061156a36600461040e565b906137b7565b611578610392565b9182918261153f565b0390f35b610398565b9061159d611596610392565b92836108c7565b565b67ffffffffffffffff81116115b75760208091020190565b6108b3565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff81116115e6576115e26020916108a9565b0190565b6108b3565b90825f939282370152565b9092919261160b611606826115c8565b61158a565b9381855260208501908284011161162757611625926115eb565b565b6115c4565b9080601f8301121561164a57816020611647933591016115f6565b90565b61059f565b9190916040818403126116a257611666604061158a565b925f8201359167ffffffffffffffff831161169d5761168a8261169694830161162c565b5f8601526020016106fd565b6020830152565b6115c0565b6115bc565b9291906116bb6116b68261159f565b61158a565b93818552602080860192028101918383116117125781905b8382106116e1575050505050565b813567ffffffffffffffff811161170d57602091611702878493870161164f565b8152019101906116d3565b61059f565b6105a7565b9080601f8301121561173557816020611732933591016116a7565b90565b61059f565b60808183031261179457611750825f83016103c5565b9261175e83602084016103ff565b9260408301359067ffffffffffffffff821161178f576117838161178c938601611717565b936060016106fd565b90565b6103a0565b61039c565b346117cb576117b56117ac36600461173a565b92919091613ba7565b6117bd610392565b806117c78161043b565b0390f35b610398565b90565b6117e76117e26117ec926117d0565b610739565b610544565b90565b6117f960406117d3565b90565b6118046117ef565b90565b3461183757611817366004610a94565b6118336118226117fc565b61182a610392565b91829182610554565b0390f35b610398565b3461186a5761184c366004610a94565b6118546141d6565b61185c610392565b806118668161043b565b0390f35b610398565b61187890611010565b9052565b61188590610dac565b9052565b906080806118e1936118a15f8201515f860190610c86565b6118b360208201516020860190610492565b6118c5604082015160408601906104a5565b6118d76060820151606086019061186f565b015191019061187c565b565b91906118f6905f60a08501940190611889565b565b346119295761192561191461190e36600461040e565b90614313565b61191c610392565b918291826118e3565b0390f35b610398565b3461195f5761195b61194a61194436600461040e565b9061436b565b611952610392565b91829182610ae8565b0390f35b610398565b3461199257611974366004610a94565b61197c614393565b611984610392565b8061198e8161043b565b0390f35b610398565b346119c7576119c36119b26119ad366004610474565b6143e4565b6119ba610392565b91829182610554565b0390f35b610398565b9091606082840312611a01576119fe6119e7845f85016103c5565b936119f581602086016106fd565b936040016106fd565b90565b61039c565b92916020611a22611a2a9360408701908782035f89015261111c565b940190610547565b565b34611a5e57611a45611a3f3660046119cc565b9161449e565b90611a5a611a51610392565b92839283611a06565b0390f35b610398565b34611a9157611a7b611a76366004610698565b614625565b611a83610392565b80611a8d8161043b565b0390f35b610398565b34611ac657611aa6366004610a94565b611ac2611ab1614634565b611ab9610392565b91829182610b83565b0390f35b610398565b909182601f83011215611b055781359167ffffffffffffffff8311611b00576020019260208302840111611afb57565b6105a7565b6105a3565b61059f565b919091604081840312611b4b57611b23835f83016103c5565b92602082013567ffffffffffffffff8111611b4657611b429201611acb565b9091565b6103a0565b61039c565b34611b7f57611b69611b63366004611b0a565b916146bb565b611b71610392565b80611b7b8161043b565b0390f35b610398565b91606083830312611bd057611b9b825f85016103c5565b92611ba983602083016103ff565b92604082013567ffffffffffffffff8111611bcb57611bc8920161162c565b90565b6103a0565b61039c565b90611bdf9061073c565b5f5260205260405f2090565b90611bf590610eb1565b5f5260205260405f2090565b905090565b611c2b611c2292602092611c19816109c1565b94858093611c01565b938491016109ce565b0190565b90565b611c3e611c4391610544565b611c2f565b9052565b611c57611c5e9160209493611c06565b8092611c32565b0190565b611c76611c6d610392565b92839283611c47565b03902090565b611c8591611c62565b90565b611c98906008611c9d9302610b32565b610917565b90565b90611cab9154611c88565b90565b90611cd692611ccc611cd192611cc76009955f96611bd5565b611beb565b611c7c565b611ca0565b90565b34611d0a57611d06611cf5611cef366004611b84565b91611cae565b611cfd610392565b91829182610554565b0390f35b610398565b909182601f83011215611d495781359167ffffffffffffffff8311611d44576020019260018302840111611d3f57565b6105a7565b6105a3565b61059f565b91606083830312611d9b57611d65825f85016103c5565b92611d7383602083016103ff565b92604082013567ffffffffffffffff8111611d9657611d929201611d0f565b9091565b6103a0565b61039c565b34611dd257611dbc611db3366004611d4e565b9291909161493c565b611dc4610392565b80611dce8161043b565b0390f35b610398565b611de0816104b2565b03611de757565b5f80fd5b90503590611df882611dd7565b565b91909160a081840312611e6657611e13835f83016103c5565b92602082013567ffffffffffffffff8111611e615781611e34918401611d0f565b929093611e5e611e4784604085016106fd565b93611e5581606086016106fd565b93608001611deb565b90565b6103a0565b61039c565b34611ea057611e8a611e7e366004611dfa565b94939093929192614c11565b611e92610392565b80611e9c8161043b565b0390f35b610398565b34611ed357611ebd611eb8366004610474565b614fc6565b611ec5610392565b80611ecf8161043b565b0390f35b610398565b9091606082840312611f0d57611f0a611ef3845f85016103c5565b93611f0181602086016103c5565b93604001611376565b90565b61039c565b34611f4157611f2b611f25366004611ed8565b9161523b565b611f33610392565b80611f3d8161043b565b0390f35b610398565b34611f7557611f5f611f5936600461040e565b9061541f565b611f67610392565b80611f718161043b565b0390f35b610398565b5190565b60209181520190565b60200190565b90611fdb90606080611fac608084015f8701518582035f870152610c55565b94611fbf60208201516020860190610c86565b611fd160408201516040860190610c86565b01519101906104b7565b90565b90611fe891611f8d565b90565b60200190565b90612005611ffe83611f7a565b8092611f7e565b908161201660208302840194611f87565b925f915b83831061202957505050505090565b9091929394602061204b61204583856001950387528951611fde565b97611feb565b930193019193929061201a565b61206d9160208201915f818403910152611ff1565b90565b346120a05761209c61208b612086366004610474565b615796565b612093610392565b91829182612058565b0390f35b610398565b346120d3576120bd6120b8366004610474565b615926565b6120c5610392565b806120cf8161043b565b0390f35b610398565b6120e4600a5f90610b59565b90565b34612117576120f7366004610a94565b6121136121026120d8565b61210a610392565b91829182610b83565b0390f35b610398565b909160a0828403126121a057612134835f84016103c5565b9261214281602085016103c5565b926121508260408301611376565b92606082013567ffffffffffffffff811161219b5783612171918401610bcd565b929093608082013567ffffffffffffffff8111612196576121929201610bcd565b9091565b6103a0565b6103a0565b61039c565b346121da576121c46121b836600461211c565b95949094939193615c29565b6121cc610392565b806121d68161043b565b0390f35b610398565b346122135761220f6121fe6121f5366004611d4e565b92919091615c9c565b612206610392565b91829182610554565b0390f35b610398565b906122229061073c565b5f5260205260405f2090565b61223a61223f91610f2e565b61093b565b90565b61224c905461222e565b90565b61225a906002612218565b6122655f8201610ef4565b9161227c5f612275818501610f21565b9301612242565b90565b6040906122a86122af949695939661229e60608401985f850190610adb565b6020830190610fd4565b0190610a0a565b565b346122e4576122e06122cc6122c7366004610474565b61224f565b6122d7939193610392565b9384938461227f565b0390f35b610398565b34612319576122f9366004610a94565b612315612304615cd1565b61230c610392565b91829182610b83565b0390f35b610398565b3461234d5761233761233136600461040e565b90615dbb565b61233f610392565b806123498161043b565b0390f35b610398565b346123835761237f61236e61236836600461040e565b90615f50565b612376610392565b91829182611225565b0390f35b610398565b346123b6576123a061239b366004610698565b61604f565b6123a8610392565b806123b28161043b565b0390f35b610398565b91906040838203126123e357806123d76123e0925f86016103c5565b93602001611deb565b90565b61039c565b34612417576124016123fb3660046123bb565b9061605a565b612409610392565b806124138161043b565b0390f35b610398565b7fe1675f8364c07a4d60a07503f0d700a7bcacd82251dff0f070e5235de6c6d28a90565b61244861241c565b90565b3461247b5761245b366004610a94565b612477612466612440565b61246e610392565b91829182610dbc565b0390f35b610398565b346124af5761249961249336600461040e565b90616123565b6124a1610392565b806124ab8161043b565b0390f35b610398565b5f80fd5b5f7f4f6e6c792054616e676c6520636f726500000000000000000000000000000000910152565b6124ec60106020926109c5565b6124f5816124b8565b0190565b61250e9060208101905f8183039101526124df565b90565b1561251857565b612520610392565b62461bcd60e51b815280612536600482016124f9565b0390fd5b61254661254b91610912565b610b36565b90565b612558905461253a565b90565b90565b61257261256d6125779261255b565b610739565b6103d4565b90565b6125839061255e565b90565b5f7f416c726561647920726567697374657265640000000000000000000000000000910152565b6125ba60126020926109c5565b6125c381612586565b0190565b6125dc9060208101905f8183039101526125ad565b90565b156125e657565b6125ee610392565b62461bcd60e51b815280612604600482016125c7565b0390fd5b5f1b90565b9061261e60018060a01b0391612608565b9181191691161790565b90565b9061264061263b61264792610eb1565b612628565b825461260d565b9055565b6126cd6126d29261268e336126886126827f00000000000000000000000000000000000000000000000000000000000000006103df565b916103df565b14612511565b6126c56126a56126a060078690611270565b61254e565b6126bf6126b96126b45f61257a565b6103df565b916103df565b146125df565b916007611270565b61262b565b565b6126de606061158a565b90565b5f90565b5f90565b5f90565b6126f56126d4565b9060208080846127036126e1565b81520161270e6126e5565b8152016127196126e9565b81525050565b6127276126ed565b90565b61273c9061273661271f565b5061624b565b90565b5f90565b61276461276a9261275f5f9361275761273f565b506003610e73565b610ebd565b0161092e565b90565b5f7f4e6f742073657276696365206f776e6572000000000000000000000000000000910152565b6127a160116020926109c5565b6127aa8161276d565b0190565b6127c39060208101905f818303910152612794565b90565b156127cd57565b6127d5610392565b62461bcd60e51b8152806127eb600482016127ae565b0390fd5b5090565b5f7f546f6f206d616e7920646566696e6974696f6e73000000000000000000000000910152565b61282760146020926109c5565b612830816127f3565b0190565b6128499060208101905f81830391015261281a565b90565b1561285357565b61285b610392565b62461bcd60e51b81528061287160048201612834565b0390fd5b634e487b7160e01b5f52601160045260245ffd5b61289861289e91939293610544565b92610544565b916128aa838202610544565b9281840414901517156128b957565b612875565b6128c9906004612889565b90565b906128df905f1990602003600802610b32565b8154169055565b1b90565b919060086129059102916128ff5f19846128e6565b926128e6565b9181191691161790565b61292361291e61292892610544565b610739565b610544565b90565b90565b919061294461293f61294c9361290f565b61292b565b9083546128ea565b9055565b6129629161295c61273f565b9161292e565b565b5b818110612970575050565b8061297d5f600193612950565b01612965565b90612993905f1990600802610b32565b191690565b816129a291612983565b906002021790565b905f916129c16129b982610807565b928354612998565b905555565b601f602091010490565b919290602082105f14612a2957601f84116001146129f9576129f3929350612998565b90555b5b565b5090612a1f612a24936001612a16612a1085610807565b926129c6565b82019101612964565b6129aa565b6129f6565b50612a608293612a3a600194610807565b612a59612a46856129c6565b820192601f861680612a6b575b506129c6565b0190612964565b6002021790556129f7565b612a77908886036128cc565b5f612a53565b929091680100000000000000008211612add576020115f14612ace57602081105f14612ab257612aac91612998565b90555b5b565b60019160ff1916612ac284610807565b55600202019055612aaf565b60019150600202019055612ab0565b6108b3565b908154612aee816107d4565b90818311612b17575b818310612b05575b50505050565b612b0e936129d0565b5f808080612aff565b612b2383838387612a7d565b612af7565b5f612b3291612ae2565b565b634e487b7160e01b5f525f60045260245ffd5b905f03612b5957612b5790612b28565b565b612b34565b60035f91612b6e83808301612b47565b612b7b8360018301612950565b612b888360028301612950565b0155565b905f03612b9e57612b9c90612b5e565b565b612b34565b5b818110612baf575050565b80612bbc5f600493612b8c565b01612ba4565b9091828110612bd1575b505050565b612bef612be9612be3612bfa956128be565b926128be565b92610786565b918201910190612ba3565b5f8080612bcc565b90680100000000000000008111612c2b5781612c20612c2993610782565b90828155612bc2565b565b6108b3565b5f612c3a91612c02565b565b905f03612c4e57612c4c90612c30565b565b612b34565b612c67612c62612c6c9261255b565b610739565b610544565b90565b6001612c7b9101610544565b90565b5f80fd5b5f80fd5b5f80fd5b903590600160800381360303821215612ca1570190565b612c7e565b90821015612cc0576020612cbd9202810190612c8a565b90565b61076e565b903590600160200381360303821215612d07570180359067ffffffffffffffff8211612d0257602001916001820236038313612cfd57565b612c86565b612c82565b612c7e565b91565b5090565b5f7f4e616d6520746f6f206c6f6e6700000000000000000000000000000000000000910152565b612d47600d6020926109c5565b612d5081612d13565b0190565b612d699060208101905f818303910152612d3a565b90565b15612d7357565b612d7b610392565b62461bcd60e51b815280612d9160048201612d54565b0390fd5b35612d9f816106e9565b90565b5f7f496e76616c696420626f756e6473000000000000000000000000000000000000910152565b612dd6600e6020926109c5565b612ddf81612da2565b0190565b612df89060208101905f818303910152612dc9565b90565b15612e0257565b612e0a610392565b62461bcd60e51b815280612e2060048201612de3565b0390fd5b90565b5f5260205f2090565b5490565b612e3d81612e30565b821015612e5757612e4f600491612e27565b910201905f90565b61076e565b5090565b9190601f8111612e70575b505050565b612e7c612ea193610807565b906020612e88846129c6565b83019310612ea9575b612e9a906129c6565b0190612964565b5f8080612e6b565b9150612e9a81929050612e91565b91612ec29082612e5c565b9067ffffffffffffffff8211612f8157612ee682612ee085546107d4565b85612e60565b5f90601f8311600114612f1957918091612f08935f92612f0d575b5050612998565b90555b565b90915001355f80612f01565b601f19831691612f2885610807565b925f5b818110612f6957509160029391856001969410612f4f575b50505002019055612f0b565b612f5f910135601f841690612983565b90555f8080612f43565b91936020600181928787013581550195019201612f2b565b6108b3565b90612f919291612eb7565b565b90612f9f5f1991612608565b9181191691161790565b90612fbe612fb9612fc59261290f565b61292b565b8254612f93565b9055565b35612fd381611dd7565b90565b90612fe260ff91612608565b9181191691161790565b612ff5906104b2565b90565b90565b9061301061300b61301792612fec565b612ff8565b8254612fd6565b9055565b906130796060600361307f9461303f5f82016130395f880188612cc5565b91612f86565b6130586001820161305260208801612d95565b90612fa9565b6130716002820161306b60408801612d95565b90612fa9565b019201612fc9565b90612ffb565b565b9190613092576130909161301b565b565b612b34565b90815491680100000000000000008310156130c757826130bf9160016130c595018155612e34565b90613081565b565b6108b3565b929190926130ff336130f96130f36130ee6130e960078790611270565b61254e565b6103df565b916103df565b146127c6565b61312d61310d8584906127ef565b61312661312061311b61143b565b610544565b91610544565b111561284c565b6131425f61313d60088490610758565b612c3c565b61314b5f612c53565b5b8061316961316361315e8887906127ef565b610544565b91610544565b101561323c57613237906131c06131a061319a61319461318b8a898791612ca6565b5f810190612cc5565b90612d0c565b90612d0f565b6131b96131b36131ae6117ef565b610544565b91610544565b1115612d6c565b6132096131da60406131d489888691612ca6565b01612d95565b6132026131fc6131f760206131f18c8b8991612ca6565b01612d95565b610544565b91610544565b1015612dfb565b61323261322061321b60088690610758565b612e24565b61322c88878591612ca6565b90613097565b612c6f565b61314c565b5050509050565b5f7f5a65726f20616464726573730000000000000000000000000000000000000000910152565b613277600c6020926109c5565b61328081613243565b0190565b6132999060208101905f81830391015261326a565b90565b156132a357565b6132ab610392565b62461bcd60e51b8152806132c160048201613284565b0390fd5b906132cf9061073c565b5f5260205260405f2090565b90565b60481b90565b906132f969ff000000000000000000916132de565b9181191691161790565b61330c90611004565b90565b90565b9061332761332261332e92613303565b61330f565b82546132e4565b9055565b61336e336133686133627f00000000000000000000000000000000000000000000000000000000000000006103df565b916103df565b14612511565b6133938261338c6133866133815f61257a565b6103df565b916103df565b141561329c565b6133b96133b46133ad6133a8600685906132c5565b6132db565b8490616329565b6125df565b6133dc600260016133d66133cf60038690610e73565b8690610ebd565b01613312565b9061341061340a7f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b9361073c565b91610eb1565b91613419610392565b806134238161043b565b0390a3565b61343990613434616363565b61343b565b565b61344690600b61262b565b565b61345190613428565b565b606090565b90602082820312613488575f82013567ffffffffffffffff8111613483576134809201611717565b90565b6103a0565b61039c565b906134a49161349a613453565b5090810190613458565b90565b6134c66134c16134cb926134b961273f565b5060056132c5565b6132db565b6163b1565b90565b606090565b67ffffffffffffffff81116134eb5760208091020190565b6108b3565b906135026134fd836134d3565b61158a565b918252565b369037565b90613531613519836134f0565b9260208061352786936134d3565b9201910390613507565b565b9061353d826110e5565b81101561354e576020809102010190565b61076e565b9061355d906103df565b9052565b9061356a6134ce565b5061358761358261357d600485906132c5565b6132db565b6163b1565b916135918361350c565b9161359b5f612c53565b5b806135af6135a987610544565b91610544565b10156135f6576135f1906135ec6135da6135d36135ce600488906132c5565b6132db565b8390616400565b6135e78791849092613533565b613553565b612c6f565b61359c565b5092505090565b5f90565b9061360a6135fd565b5061362c600161362661361f60038690610e73565b8490610ebd565b01610f4e565b61363e6136385f611004565b91611004565b1491821561364c575b505090565b61366d9250600191613662613667926003610e73565b610ebd565b01610f4e565b61368061367a6001611004565b91611004565b145f80613647565b6136ae906136946134ce565b505f906136a86136a26111d8565b92612c53565b9061449e565b5090565b5f7f4e6f742072656769737465726564206f70657261746f72000000000000000000910152565b6136e660176020926109c5565b6136ef816136b2565b0190565b6137089060208101905f8183039101526136d9565b90565b1561371257565b61371a610392565b62461bcd60e51b815280613730600482016136f3565b0390fd5b906137669493929161376161375c6137556137508460066132c5565b6132db565b3390616438565b61370b565b613768565b565b9161377a9492939133919293946165e7565b565b9061378994939291613734565b565b906137ab6137a66137b09361379e6135fd565b5060066132c5565b6132db565b616438565b90565b5f90565b6137d96137df926137d46001936137cc6137b3565b506003610e73565b610ebd565b01610f4e565b90565b6137eb90610ea5565b90565b5f7f496e7465726e616c206f6e6c7900000000000000000000000000000000000000910152565b613822600d6020926109c5565b61382b816137ee565b0190565b6138449060208101905f818303910152613815565b90565b1561384e57565b613856610392565b62461bcd60e51b81528061386c6004820161382f565b0390fd5b67ffffffffffffffff81116138885760208091020190565b6108b3565b9061389f61389a83613870565b61158a565b918252565b369037565b906138ce6138b68361388d565b926020806138c48693613870565b92019103906138a4565b565b906138da82610c42565b8110156138eb576020809102010190565b61076e565b90565b60200190565b5190565b5190565b9061390b826138fd565b81101561391c576020809102010190565b61076e565b9061392b90610dac565b9052565b606090565b90565b60209181520190565b905f929180549061395a613953836107d4565b8094613937565b916001811690815f146139b15750600114613975575b505050565b613982919293945061078f565b915f925b81841061399957505001905f8080613970565b60018160209295939554848601520191019290613986565b92949550505060ff19168252151560200201905f8080613970565b906139d691613940565b90565b906139f96139f2926139e9610392565b938480926139cc565b03836108c7565b565b613a04906139d9565b90565b613a119051610dac565b90565b613a1e9051610544565b90565b5f7f56616c7565206f7574206f6620626f756e647300000000000000000000000000910152565b613a5560136020926109c5565b613a5e81613a21565b0190565b613a7a613a889260408301908382035f8501526109d9565b906020818303910152613a48565b90565b92916020613aa7613aaf9360408701908782035f8901526109d9565b940190610547565b565b905f9291805490613acb613ac4836107d4565b80946109c5565b916001811690815f14613b225750600114613ae6575b505050565b613af39192939450610807565b915f925b818410613b0a57505001905f8080613ae1565b60018160209295939554848601520191019290613af7565b92949550505060ff19168252151560200201905f8080613ae1565b5f7f5265717569726564206d6574726963206d697373696e67000000000000000000910152565b613b7160176020926109c5565b613b7a81613b3d565b0190565b613b96613ba49260408301908382035f850152613ab1565b906020818303910152613b64565b90565b92939093613bcf33613bc9613bc3613bbe306137e2565b6103df565b916103df565b14613847565b613be3613bde60088690610758565b612e24565b94613bed826138a9565b94613bf75f612c53565b5b80613c0b613c0586610544565b91610544565b1015613c5e57613c5990613c54613c2f5f613c278a85906138d0565b5101516138f0565b613c41613c3b826138f9565b916138f3565b20613c4f8a91849092613901565b613921565b612c6f565b613bf8565b509194909295613c6d81612e30565b613c7f613c795f612c53565b91610544565b1196613c8961392f565b9088614109575b613c995f612c53565b5b80613cad613ca78b610544565b91610544565b1015613f6c5760015f8b613da0575b5090888789613cd294613cd7575b505050612c6f565b613c9a565b825f613d15613d0d613d1e94613d08613d006020613cf9613d239b8d906138d0565b5101613a14565b976009611bd5565b611beb565b9287906138d0565b51015190611c7c565b612fa9565b88878990613d4d6020613d465f613d3b8789906138d0565b5101519587906138d0565b5101613a14565b613d80613d7a7f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd9361073c565b93610eb1565b93613d95613d8c610392565b92839283613a8b565b0390a3888789613cca565b9a9095929199613daf5f612c53565b5b80613dcb613dc5613dc08a612e30565b610544565b91610544565b1015613f5657613de3613dde8d87613901565b613a07565b613e07613e01613dfc613df78a8690613901565b613a07565b610dac565b91610dac565b14613e1a57613e1590612c6f565b613db0565b8a919b929c5089613cd29495988a926001908a613e446020613e3d898b906138d0565b5101613a14565b613e6c613e66613e616001613e5a868890612e34565b500161092e565b610544565b91610544565b109188888415613f0c575b50505050613ea1575b613e8b905b156104b2565b613e9a575b9394505050613cbc565b505f613e90565b905082825f613eb18789906138d0565b51015191613efd613eeb613ee57fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361073c565b93610eb1565b93613ef4610392565b91829182613a62565b0390a3613e8b5f919050613e80565b613f4c939450613f3a613f4693613f346020613f2d613f41966002966138d0565b5101613a14565b96612e34565b500161092e565b610544565b91610544565b118a5f8888613e77565b5099909a8789613cd2949598613e8b8d94613e85565b509750509293509350613f7e5f612c53565b935b84613f9b613f95613f9086612e30565b610544565b91610544565b101561410257613fc1613fbb6003613fb4868990612e34565b5001610955565b156104b2565b6140f757613fe3613fde5f613fd7868990612e34565b5001613934565b6139fb565b613ff5613fef826138f9565b916138f3565b20905f966140025f612c53565b5b8061401e614018614013866138fd565b610544565b91610544565b10156140e557614037614032848390613901565b613a07565b61404961404386610dac565b91610dac565b1461405c5761405790612c6f565b614003565b509590965061407d915061407260015b156104b2565b614084575b5b612c6f565b9394613f80565b82855f614092878590612e34565b5001916140dd6140cb6140c57fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361073c565b93610eb1565b936140d4610392565b91829182613b7e565b0390a3614077565b5095909661407d92506140729061406c565b949361407d90614078565b5050505050565b9693905061412361411e839794999693612e30565b6138a9565b9761412d5f612c53565b5b8061414961414361413e8b612e30565b610544565b91610544565b10156141a35761419e9061419961417461416f5f6141688d8690612e34565b5001613934565b6139fb565b614186614180826138f9565b916138f3565b206141948d91849092613901565b613921565b612c6f565b61412e565b509295919497909396613c90565b6141b9616363565b6141c16141c3565b565b6141d46141cf5f61257a565b616a59565b565b6141de6141b1565b565b6141ea60a061158a565b90565b5f90565b5f90565b5f90565b6142016141e0565b90602080808080866142116141ed565b81520161421c6126e1565b8152016142276126e5565b8152016142326141f1565b81520161423d6141f5565b81525050565b61424b6141f9565b90565b9061425890610544565b9052565b90614266906103a4565b9052565b906142749061049f565b9052565b9061428290611004565b9052565b906143056142fc60026142976141e0565b946142ae6142a65f830161092e565b5f880161424e565b6142c66142bd60018301610ef4565b6020880161425c565b6142de6142d560018301610f21565b6040880161426a565b6142f66142ed60018301610f4e565b60608801614278565b01610f72565b60808401613921565b565b61431090614286565b90565b6143389161432e61433392614326614243565b506003610e73565b610ebd565b614307565b90565b5f90565b906143499061073c565b5f5260205260405f2090565b9061435f90610eb1565b5f5260205260405f2090565b6143909161438661438b9261437e61433b565b50600c61433f565b614355565b610ef4565b90565b61439b616a6f565b6143a3615cd1565b6143b56143af836103df565b916103df565b036143c5576143c390616a59565b565b6143e0905f91829163118cdaa760e01b835260048301610b83565b0390fd5b6144036143fe614408926143f661273f565b5060046132c5565b6132db565b6163b1565b90565b614415905161049f565b90565b61442c6144276144319261255b565b610739565b61049f565b90565b61443e90516103a4565b90565b61445561445061445a926103a4565b610739565b610544565b90565b61447161446c6144769261049f565b610739565b610544565b90565b61448861448e91939293610544565b92610544565b820180921161449957565b612875565b909291926144aa6134ce565b506144b361273f565b506144bd8261624b565b936144da6144d56144d0600586906132c5565b6132db565b6163b1565b926144e76020870161440b565b6144f96144f35f614418565b9161049f565b1480156145eb575b80156145d0575b6145b6576145428661453c614537602061453061452b5f61459f9b9c9d01614434565b614441565b930161440b565b61445d565b90612889565b918061455d6145576145526111d8565b610544565b91610544565b115f146145b1575061456d6111d8565b5b614579848290614479565b61458b61458588610544565b91610544565b115f146145a25750845b9092909192616aa5565b91565b6145ac9084614479565b614595565b61456e565b50505091506145cc6145c75f612c53565b61350c565b9190565b50826145e46145de86610544565b91610544565b1015614508565b50836145ff6145f95f612c53565b91610544565b14614501565b61461690614611616363565b614618565b565b61462390600a61262b565b565b61462e90614605565b565b5f90565b61463c614630565b506146465f61254e565b90565b5090565b919081101561465d576020020190565b61076e565b3561466c816103eb565b90565b5f80fd5b60e01b90565b5f91031261468357565b61039c565b9160206146a99294936146a260408201965f830190610adb565b0190610b76565b565b6146b3610392565b3d5f823e3d90fd5b909291926146c85f612c53565b5b806146e66146e06146db858990614649565b610544565b91610544565b1015614795576146f5306137e2565b9063ba1fb1038461471061470b868a869161464d565b614662565b93803b15614790576147355f8094614740614729610392565b98899687958694614673565b845260048401614688565b03925af191821561478b5761475a9261475f575b50612c6f565b6146c9565b61477e905f3d8111614784575b61477681836108c7565b810190614679565b5f614754565b503d61476c565b6146ab565b61466f565b5050509050565b5f7f4e6f7420736c617368696e67206f7261636c6500000000000000000000000000910152565b6147d060136020926109c5565b6147d98161479c565b0190565b6147f29060208101905f8183039101526147c3565b90565b156147fc57565b614804610392565b62461bcd60e51b81528061481a600482016147dd565b0390fd5b5f7f4f70657261746f7220756e6b6e6f776e00000000000000000000000000000000910152565b61485260106020926109c5565b61485b8161481e565b0190565b6148749060208101905f818303910152614845565b90565b1561487e57565b614886610392565b62461bcd60e51b81528061489c6004820161485f565b0390fd5b90565b6148b76148b26148bc92610544565b610739565b6103a4565b90565b906148d267ffffffffffffffff91612608565b9181191691161790565b90565b906148f46148ef6148fb9261073c565b6148dc565b82546148bf565b9055565b9190614919816149128161491e956109c5565b80956115eb565b6108a9565b0190565b90916149399260208301925f8185039101526148ff565b90565b6149613361495b614955614950600a61254e565b6103df565b916103df565b146147f5565b61498761498261497b614976600585906132c5565b6132db565b8490616438565b614877565b6149b36149a86149a361499c60038590610e73565b8590610ebd565b6148a0565b600160039101613312565b6149d16149ca6149c5600484906132c5565b6132db565b8390616bc1565b506149f96149de426148a3565b6149f46149ed600c859061433f565b8590614355565b6148df565b909192614a2f614a297f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361073c565b93610eb1565b93614a44614a3b610392565b92839283614922565b0390a3565b614a53608061158a565b90565b614a619136916115f6565b90565b52565b90614a71906104b2565b9052565b5190565b90614a83816109c1565b9067ffffffffffffffff8211614b4357614aa782614aa185546107d4565b85612e60565b602090601f8311600114614adb57918091614aca935f92614acf575b5050612998565b90555b565b90915001515f80614ac3565b601f19831691614aea85610807565b925f5b818110614b2b57509160029391856001969410614b11575b50505002019055614acd565b614b21910151601f841690612983565b90555f8080614b05565b91936020600181928787015181550195019201614aed565b6108b3565b90614b5291614a79565b565b614b5e90516104b2565b90565b90614bbe60606003614bc494614b845f8201614b7e5f8801614a75565b90614b48565b614b9d60018201614b9760208801613a14565b90612fa9565b614bb660028201614bb060408801613a14565b90612fa9565b019201614b54565b90612ffb565b565b9190614bd757614bd591614b61565b565b612b34565b9081549168010000000000000000831015614c0c5782614c04916001614c0a95018155612e34565b90614bc6565b565b6108b3565b614d2f95614d188496614d0f614d07614cf3614cee614d2197614c94614c74614c6e614d2a9d8d9f9d614c6933614c63614c5d614c58614c5360078c90611270565b61254e565b6103df565b916103df565b146127c6565b612d0c565b90612d0f565b614c8d614c87614c826117ef565b610544565b91610544565b1115612d6c565b614cb186614caa614ca48d610544565b91610544565b1015612dfb565b614ce7614cc8614cc360088490610758565b610782565b614ce1614cdb614cd661143b565b610544565b91610544565b1061284c565b6008610758565b612e24565b989996929496614d01614a49565b9a614a56565b5f8a01614a64565b6020880161424e565b6040860161424e565b60608401614a67565b614bdc565b565b614d5f90614d5a614d55614d4e614d498460066132c5565b6132db565b3390616438565b61370b565b614e40565b565b5f7f43616e6e6f7420676f206f6e6c696e65207768696c6520736c61736865640000910152565b614d95601e6020926109c5565b614d9e81614d61565b0190565b614db79060208101905f818303910152614d88565b90565b60401b90565b90614dd468ff000000000000000091614dba565b9181191691161790565b614df2614ded614df79261049f565b610739565b61049f565b90565b90565b90614e12614e0d614e1992614dde565b614dfa565b8254614dc0565b9055565b916020614e3e929493614e3760408201965f83019061101c565b019061101c565b565b614e5e614e59614e5260038490610e73565b3390610ebd565b6148a0565b90614e6b60018301610f4e565b9182614e80614e7a6003611004565b91611004565b14614fa45782614e98614e925f611004565b91611004565b148015614f89575b614f8457614ec790614eb56001808301613312565b6001614ec05f614418565b9101614dfd565b614ee5614ede614ed9600484906132c5565b6132db565b3390616329565b508033614f1b614f157fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361073c565b91610eb1565b91614f24610392565b80614f2e8161043b565b0390a3903390916001614f6a614f647f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361073c565b93610eb1565b93614f7f614f76610392565b92839283614e1d565b0390a3565b505050565b5082614f9e614f986001611004565b91611004565b14614ea0565b614fac610392565b62461bcd60e51b815280614fc260048201614da2565b0390fd5b614fcf90614d31565b565b5f7f4e6f7420617574686f72697a6564000000000000000000000000000000000000910152565b615005600e6020926109c5565b61500e81614fd1565b0190565b6150279060208101905f818303910152614ff8565b90565b1561503157565b615039610392565b62461bcd60e51b81528061504f60048201615012565b0390fd5b90565b61506a61506561506f92615053565b610739565b6103a4565b90565b5f7f496e74657276616c20746f6f2073686f72740000000000000000000000000000910152565b6150a660126020926109c5565b6150af81615072565b0190565b6150c89060208101905f818303910152615099565b90565b156150d257565b6150da610392565b62461bcd60e51b8152806150f0600482016150b3565b0390fd5b90565b61510b615106615110926150f4565b610739565b61049f565b90565b5f7f4d6178206d6973736564206d757374206265203e3d2031000000000000000000910152565b61514760176020926109c5565b61515081615113565b0190565b6151699060208101905f81830391015261513a565b90565b1561517357565b61517b610392565b62461bcd60e51b81528061519160048201615154565b0390fd5b61519f606061158a565b90565b906151b76151b26151be92612fec565b612ff8565b82546132e4565b9055565b9061520460405f61520a946151e48282016151de848801614434565b906148df565b6151fc8282016151f66020880161440b565b90614dfd565b019201614b54565b906151a2565b565b90615216916151c2565b565b91602061523992949361523260408201965f830190610adb565b0190610fd4565b565b3361526e6152687f00000000000000000000000000000000000000000000000000000000000000006103df565b916103df565b14801561535a575b61527f9061502a565b61529d82615296615290603c615056565b916103a4565b10156150cb565b6152bb836152b46152ae60016150f7565b9161049f565b101561516c565b61531482615303856152fa6152dc5f6152d660028990612218565b01612242565b916152f16152e8615195565b955f870161425c565b6020850161426a565b60408301614a67565b61530f60028490612218565b61520c565b90916153407fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea5649261073c565b9261535561534c610392565b92839283615218565b0390a2565b5061527f3361538461537e61537961537460078790611270565b61254e565b6103df565b916103df565b149050615276565b61539b6153a191939293610544565b92610544565b82039182116153ac57565b612875565b634e487b7160e01b5f52601260045260245ffd5b6153d16153d791610544565b91610544565b9081156153e2570490565b6153b1565b6153fb6153f661540092610544565b610739565b61049f565b90565b61541761541261541c9261255b565b610739565b6103a4565b90565b61543d61543861543160038490610e73565b8490610ebd565b6148a0565b906154478161624b565b61545360018401610f4e565b6154666154606003611004565b91611004565b1461567a576154765f840161092e565b6154886154825f612c53565b91610544565b14615674576154be6154a54261549f5f870161092e565b9061538c565b6154b86154b35f8501614434565b614441565b906153c5565b806154d26154cc60ff61445d565b91610544565b115f14615666575060ff5b90816154fc6154f66154f160018801610f21565b61049f565b9161049f565b11615509575b5050505050565b6155168260018601614dfd565b61552b6155225f615403565b600186016148df565b61554961554361553e602085940161440b565b61049f565b9161049f565b10158061563f575b61555c575b80615502565b61557761556b60018501610f4e565b93600160029101613312565b61559561558e615589600485906132c5565b6132db565b8590616bc1565b5081908490916155e36155d16155cb7f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d9361073c565b93610eb1565b936155da610392565b918291826114f5565b0390a3919091600261561e6156187f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361073c565b93610eb1565b9361563361562a610392565b92839283614e1d565b0390a35f808080615556565b5061564c60018401610f4e565b61565f6156596002611004565b91611004565b1415615551565b61566f906153e7565b6154dd565b50505050565b50505050565b606090565b67ffffffffffffffff811161569d5760208091020190565b6108b3565b906156b46156af83615685565b61158a565b918252565b6156c3608061158a565b90565b9061572d61572460036156d76156b9565b946156ee6156e65f83016108f0565b5f8801614a64565b6157066156fd6001830161092e565b6020880161424e565b61571e6157156002830161092e565b6040880161424e565b01610955565b60608401614a67565b565b615738906156c6565b90565b9061574582610782565b61574e816156a2565b9261575c6020850191610786565b5f915b83831061576c5750505050565b6004602060019261577c8561572f565b81520192019201919061575f565b6157939061573b565b90565b6157ad6157b2916157a5615680565b506008610758565b61578a565b90565b6157e3906157de6157d96157d26157cd8460066132c5565b6132db565b3390616438565b61370b565b61583e565b565b5f7f43616e6e6f7420676f206f66666c696e65207768696c6520736c617368656400910152565b615819601f6020926109c5565b615822816157e5565b0190565b61583b9060208101905f81830391015261580c565b90565b61585c61585761585060038490610e73565b3390610ebd565b6148a0565b9061586960018301610f4e565b918261587e6158786003611004565b91611004565b146159045761589290600160049101613312565b6158b06158a96158a4600484906132c5565b6132db565b3390616bc1565b509033909160046158ea6158e47f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361073c565b93610eb1565b936158ff6158f6610392565b92839283614e1d565b0390a3565b61590c610392565b62461bcd60e51b81528061592260048201615826565b0390fd5b61592f906157b5565b565b9061596596959493929161596061595b61595461594f8460066132c5565b6132db565b3390616438565b61370b565b615b66565b565b60c01b90565b61597690615967565b90565b61598561598a916103a4565b61596d565b9052565b60f81b90565b61599d9061598e565b90565b6159ac6159b19161049f565b615994565b9052565b905090565b9091826159ca816159d1936159b5565b80936115eb565b0190565b60086001936159f982846159f1615a0196615a089c9a98615979565b018092615979565b0180926159a0565b01916159ba565b90565b5f7f19457468657265756d205369676e6564204d6573736167653a0a333200000000910152565b615a3e601c8092611c01565b615a4781615a0b565b0190565b90565b615a5a615a5f91610dac565b615a4b565b9052565b90615a79615a72602093615a32565b8092615a4e565b0190565b67ffffffffffffffff8111615a9b57615a976020916108a9565b0190565b6108b3565b90929192615ab5615ab082615a7d565b61158a565b93818552602085019082840111615ad157615acf926115eb565b565b6115c4565b615ae1913691615aa0565b90565b5f7f496e76616c6964207369676e6174757265000000000000000000000000000000910152565b615b1860116020926109c5565b615b2181615ae4565b0190565b615b3a9060208101905f818303910152615b0b565b90565b15615b4457565b615b4c610392565b62461bcd60e51b815280615b6260048201615b25565b0390fd5b9094615c04615c1c91615bfe615c2799615bd6615be588615baf8d615ba08d8f8d9395919091615b94610392565b968795602087016159d5565b602082018103825203826108c7565b615bc1615bbb826138f9565b916138f3565b20615bca610392565b92839160208301615a63565b602082018103825203826108c7565b615bf7615bf1826138f9565b916138f3565b2092615ad6565b90616bfb565b615c16615c10336103df565b916103df565b14615b3d565b9333919293946165e7565b565b90615c38969594939291615931565b565b909182615c4a81615c5193611c01565b80936115eb565b0190565b615c669060209493615c6d93615c3a565b8092611c32565b0190565b9091615c8890615c7f610392565b93849384615c55565b03902090565b9091615c9992615c71565b90565b92615cc1615cc99392615cbc615cce96615cb461273f565b506009611bd5565b611beb565b919091615c8e565b61092e565b90565b615cd9614630565b50615ce4600161254e565b90565b615cf19051611004565b90565b90565b615d0b615d06615d1092615cf4565b610739565b610544565b90565b60207f6c00000000000000000000000000000000000000000000000000000000000000917f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76615f8201520152565b615d6d60216040926109c5565b615d7681615d13565b0190565b615d8f9060208101905f818303910152615d60565b90565b15615d9957565b615da1610392565b62461bcd60e51b815280615db760048201615d7a565b0390fd5b90615e6c615e67615e719333615dec615de6615de1615ddc60078690611270565b61254e565b6103df565b916103df565b148015615f2a575b615dfd9061502a565b615e1b615e16615e0f60038490610e73565b8690610ebd565b614307565b615e2760608201615ce7565b615e3a615e346003611004565b91611004565b03615e74575b50615e5f615e58615e53600584906132c5565b6132db565b8590616bc1565b5060046132c5565b6132db565b616bc1565b50565b615ef090615ec4615eb4615e878561624b565b615eae615ea96020615ea2615e9d5f8601614434565b614441565b930161440b565b61445d565b90612889565b615ebe600a615cf7565b90612889565b615ecf5f8301613a14565b615ee1615edb5f612c53565b91610544565b119182615ef6575b5050615d92565b5f615e40565b615f21919250615f15615f1b91615f0f5f429201613a14565b9061538c565b92610544565b91610544565b10155f80615ee9565b50615dfd33615f48615f42615f3d614634565b6103df565b916103df565b149050615df4565b90615f7a615f7f91615f606135fd565b50615f75615f6d8561624b565b946003610e73565b610ebd565b614307565b615f8a5f8201613a14565b615f9c615f965f612c53565b91610544565b14615fd757615fcd615fc85f615fc1615fd394615fbb83429201613a14565b9061538c565b9401614434565b614441565b91610544565b1090565b50505f90565b615fee90615fe9616363565b615ff0565b565b615ffb81600161262b565b616003614634565b906160376160317f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e2270093610eb1565b91610eb1565b91616040610392565b8061604a8161043b565b0390a3565b61605890615fdd565b565b5f61609961609f936160913361608b61608561608061607b60078a90611270565b61254e565b6103df565b916103df565b146127c6565b926002612218565b016151a2565b565b5f7f4e6f742072656769737465726564000000000000000000000000000000000000910152565b6160d5600e6020926109c5565b6160de816160a1565b0190565b6160f79060208101905f8183039101526160c8565b90565b1561610157565b616109610392565b62461bcd60e51b81528061611f600482016160e2565b0390fd5b61615f336161596161537f00000000000000000000000000000000000000000000000000000000000000006103df565b916103df565b14612511565b616185616180616179616174600685906132c5565b6132db565b8490616bc1565b6160fa565b6161a361619c616197600484906132c5565b6132db565b8390616bc1565b50906161d86161d27f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e9361073c565b91610eb1565b916161e1610392565b806161eb8161043b565b0390a3565b9061623d6162345f6162006126d4565b9461621761620f838301610ef4565b83880161425c565b61622e616225838301610f21565b6020880161426a565b01612242565b60408401614a67565b565b616248906161f0565b90565b6162626162679161625a61271f565b506002612218565b61623f565b6162725f8201614434565b61628461627e5f615403565b916103a4565b146162ca575b6162966020820161440b565b6162a86162a25f614418565b9161049f565b146162b1575b90565b6162c56162bc6114dd565b6020830161426a565b6162ae565b6162dd6162d5610ac2565b5f830161425c565b61628a565b6162eb90610e89565b90565b6163026162fd616307926103d4565b610739565b610544565b90565b61631e61631961632392610544565b612608565b610dac565b90565b90565b9061635b61635561635061634b5f616360966163436135fd565b5001946162e2565b6162ee565b61630a565b91616326565b616cc6565b90565b61636b614634565b61638461637e616379616a6f565b6103df565b916103df565b0361638b57565b6163ad616396616a6f565b5f91829163118cdaa760e01b835260048301610b83565b0390fd5b6163c85f6163cd926163c161273f565b5001616326565b616d29565b90565b6163dc6163e191610912565b61290f565b90565b6163f86163f36163fd92610544565b610739565b6103d4565b90565b61642b616426616435936164215f6164309561641a614630565b5001616326565b616d9b565b6163d0565b6163e4565b610ea5565b90565b9061646a61646461645f61645a5f61646f966164526135fd565b5001946162e2565b6162ee565b61630a565b91616326565b616dbc565b90565b5f7f4f70657261746f7220697320736c617368656400000000000000000000000000910152565b6164a660136020926109c5565b6164af81616472565b0190565b6164c89060208101905f818303910152616499565b90565b156164d257565b6164da610392565b62461bcd60e51b8152806164f0600482016164b3565b0390fd5b6164fd90610dac565b90565b61650990610912565b90565b9061652161651c616528926164f4565b616500565b8254612f93565b9055565b616535906103a4565b67ffffffffffffffff811461654a5760010190565b612875565b90565b61656661656161656b9261654f565b610739565b61049f565b90565b91602061658f92949361658860408201965f830190610fd4565b0190610547565b565b61659a90610e89565b90565b6165a690616591565b90565b6165b290610ea5565b90565b6040906165de6165e594969593966165d460608401985f850190610b76565b6020830190610adb565b0190610adb565b565b949293919361660a6166056165fe60038990610e73565b8790610ebd565b6148a0565b936166148761624b565b9361663e61662460018801610f4e565b6166376166316003611004565b91611004565b14156164cb565b61665c61665561665060058b906132c5565b6132db565b8890616329565b50616731604061666e60018901610f4e565b9661667b425f8b01612fa9565b6166a5616689858790615ad6565b61669b616695826138f9565b916138f3565b2060028b0161650c565b6166ba6166b15f614418565b60018b01614dfd565b6166d860018a016166d26166cd82610ef4565b61652c565b906148df565b6166e06137b3565b50856166f46166ee5f614418565b9161049f565b145f146169b55761670b5f995b60018b9101613312565b8761671f6167196002611004565b91611004565b1480616999575b61692b575b01614b54565b80616907575b6168f1575b505085918591924261678061677a6167747f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b99461073c565b9461073c565b94610eb1565b9461679561678c610392565b9283928361656e565b0390a4806167ab6167a584611004565b91611004565b0361689b575b50506167bd600b61254e565b6167d76167d16167cc5f61257a565b6103df565b916103df565b036167e1575b5050565b6167fb6167f66167f1600b61254e565b61659d565b6165a9565b9163d47853b691909261680d426148a3565b92813b15616896575f6168339161683e8296616827610392565b98899788968795614673565b8552600485016165b5565b03925af1908161686a575b50155f14616865576001616860575b5b5f806167dd565b616858565b616859565b616889905f3d811161688f575b61688181836108c7565b810190614679565b5f616849565b503d616877565b61466f565b838391926168d26168cc7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361073c565b93610eb1565b936168e76168de610392565b92839283614e1d565b0390a35f806167b1565b616900918891889091926171dd565b5f8061673c565b50616913818390612d0f565b61692561691f5f612c53565b91610544565b11616737565b61694861694161693c8d60046132c5565b6132db565b8b90616329565b508a8a61697e6169787fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361073c565b91610eb1565b91616987610392565b806169918161043b565b0390a361672b565b50886169ae6169a86002611004565b91611004565b1415616726565b856169c96169c36064616552565b9161049f565b105f146169dc5761670b6001995b616701565b61670b6001996169f48d8d8b908b908a928c94616e91565b6169d7565b91906008616a19910291616a1360018060a01b03846128e6565b926128e6565b9181191691161790565b9190616a39616a34616a4193610eb1565b612628565b9083546169f9565b9055565b616a5791616a51614630565b91616a23565b565b616a6d90616a685f6001616a45565b61739b565b565b616a77614630565b503390565b616a8590610544565b5f198114616a935760010190565b612875565b616aa290516103df565b90565b93919293616ab16134ce565b50616ac5616ac085849061538c565b61350c565b92616acf5f612c53565b925b80616ae4616ade88610544565b91610544565b1015616b5257616b08616b01616afc600586906132c5565b6132db565b8290616400565b616b1484828a916173fa565b616b28575b50616b2390612c6f565b616ad1565b616b239194616b46616b4b92616b418991849092613533565b613553565b616a7c565b9390616b19565b509450509150616b618261350c565b92616b6b5f612c53565b5b80616b7f616b7986610544565b91610544565b1015616bbb57616bb690616bb1616b9f616b9a868490613533565b616a98565b616bac8891849092613533565b613553565b612c6f565b616b6c565b50915050565b90616bf3616bed616be8616be35f616bf896616bdb6135fd565b5001946162e2565b6162ee565b61630a565b91616326565b617546565b90565b616c1a91616c1191616c0b614630565b50617673565b90929192617733565b90565b90565b5f5260205f2090565b5490565b616c3681616c29565b821015616c5057616c48600191616c20565b910201905f90565b61076e565b9190616c6b616c66616c73936164f4565b616500565b9083546128ea565b9055565b9081549168010000000000000000831015616ca75782616c9f916001616ca595018155616c2d565b90616c55565b565b6108b3565b5490565b90616cba906164f4565b5f5260205260405f2090565b616cce6135fd565b50616ce3616cdd828490616dbc565b156104b2565b5f14616d2357616d19616d1e92616d05616cfe5f8501616c1d565b8290616c77565b6001616d125f8501616cac565b9301616cb0565b612fa9565b600190565b50505f90565b5f616d3d91616d3661273f565b5001616cac565b90565b5f90565b5f5260205f2090565b616d5681616cac565b821015616d7057616d68600191616d44565b910201905f90565b61076e565b616d85906008616d8a9302610b32565b610f5b565b90565b90616d989154616d75565b90565b616db9915f616db392616dac616d40565b5001616d4d565b90616d8d565b90565b616dda916001616dd592616dce6135fd565b5001616cb0565b61092e565b616dec616de65f612c53565b91610544565b141590565b616e05616e00616e0a926111b9565b610739565b61049f565b90565b616e19616e1f916103a4565b916103a4565b90039067ffffffffffffffff8211616e3357565b612875565b5f7f50726f746f636f6c2076696f6c6174696f6e207265706f727465640000000000910152565b616e6c601b6020926109c5565b616e7581616e38565b0190565b616e8e9060208101905f818303910152616e5f565b90565b9350509250616ea9616ea360c8616df1565b9161049f565b1015616eb4575b5050565b616ebd426148a3565b616edb616ed6616ecf600c859061433f565b8590614355565b610ef4565b80616eee616ee85f615403565b916103a4565b14908115616f74575b50616f03575b50616eb0565b616f2290616f1d616f16600c859061433f565b8590614355565b6148df565b90616f56616f507f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361073c565b91610eb1565b91616f5f610392565b80616f6981616e79565b0390a35f8080616efd565b616f7f915082616e0d565b616f98616f92616f8d610e25565b6103a4565b916103a4565b10155f616ef7565b90565b616fb7616fb2616fbc92616fa0565b610739565b610544565b90565b90929192616fd4616fcf826115c8565b61158a565b93818552602085019082840111616ff057616fee926109ce565b565b6115c4565b9080601f830112156170135781602061701093519101616fbf565b90565b61059f565b90505190617025826106e9565b565b91909160408184031261707a5761703e604061158a565b925f8201519167ffffffffffffffff8311617075576170628261706e948301616ff5565b5f860152602001617018565b6020830152565b6115c0565b6115bc565b92919061709361708e8261159f565b61158a565b93818552602080860192028101918383116170ea5781905b8382106170b9575050505050565b815167ffffffffffffffff81116170e5576020916170da8784938701617027565b8152019101906170ab565b61059f565b6105a7565b9080601f8301121561710d5781602061710a9351910161707f565b90565b61059f565b90602082820312617142575f82015167ffffffffffffffff811161713d5761713a92016170ef565b90565b6103a0565b61039c565b60209181520190565b919061716a816171638161716f95617147565b80956115eb565b6108a9565b0190565b909161718a9260208301925f818503910152617150565b90565b617197603261141f565b90565b9493916060916171db946171c66171d3936171bc60808b01945f8c0190610adb565b60208a0190610b76565b8782036040890152610cd3565b940190610547565b565b916171e9818590612d0f565b6171fb6171f55f612c53565b91610544565b146173955761720b818590612d0f565b61721f61721961c350616fa3565b91610544565b1161738f575f61722d613453565b94617237306137e2565b6172596331e3bd1b94929461726461724d610392565b96879586948594614673565b845260048401617173565b03915afa80915f9261736b575b50155f146173625750600161735d575b61728a83610c42565b6172a361729d61729861718d565b610544565b91610544565b115f1461734f576172b261718d565b5b6172bc306137e2565b906365a6936e93929490823b1561734a575f946172f786926172ec946172e0610392565b998a9889978896614673565b86526004860161719a565b03925af1908161731e575b50155f14617319576001617314575b5b565b617311565b617312565b61733d905f3d8111617343575b61733581836108c7565b810190614679565b5f617302565b503d61732b565b61466f565b61735883610c42565b6172b3565b505050565b90925091617281565b6173889192503d805f833e61738081836108c7565b810190617112565b905f617271565b50505050565b50505050565b6173a45f61254e565b6173ae825f61262b565b906173e26173dc7f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e093610eb1565b91610eb1565b916173eb610392565b806173f58161043b565b0390a3565b6174026135fd565b5061742a61742461741d617418600685906132c5565b6132db565b8490616438565b156104b2565b6174cc5761744a91617440617445926003610e73565b610ebd565b614307565b6174555f8201613a14565b6174676174615f612c53565b91610544565b1480156174a6575b6174a05761749561748f61749b926174895f429201613a14565b9061538c565b92610544565b91610544565b101590565b50505f90565b506174b360608201615ce7565b6174c66174c06003611004565b91611004565b1461746f565b5050505f90565b6174e76174e26174ec926150f4565b610739565b610544565b90565b634e487b7160e01b5f52603160045260245ffd5b6175159161750f616d40565b91616c55565b565b61752081616c29565b801561754157600190039061753e6175388383616c2d565b90617503565b55565b6174ef565b61754e6135fd565b50617565617560600183018490616cb0565b61092e565b90816175796175735f612c53565b91610544565b14155f14617645576175f79260016175f292846175a05f9661759a856174d3565b9061538c565b6175bd6175ae888501616cac565b6175b7866174d3565b9061538c565b816175d06175ca83610544565b91610544565b036175fc575b5050506175ec6175e7868301616c1d565b617517565b01616cb0565b612950565b600190565b61763d9261762f61761b617615617638948c8901616d4d565b90616d8d565b9361762985918c8901616d4d565b90616c55565b91858501616cb0565b612fa9565b5f80806175d6565b5050505f90565b5f90565b90565b61766761766261766c92617650565b610739565b610544565b90565b5f90565b91909161767e614630565b5061768761764c565b50617690616d40565b5061769a836138f9565b6176ad6176a76041617653565b91610544565b145f146176f4576176ed91926176c1616d40565b506176ca616d40565b506176d361766f565b506020810151606060408301519201515f1a90919261787d565b9192909190565b506176fe5f61257a565b9061771261770d6002946138f9565b61630a565b91929190565b6004111561772257565b610fe1565b9061773182617718565b565b806177466177405f617727565b91617727565b145f14617751575050565b8061776561775f6001617727565b91617727565b145f14617788575f63f645eedf60e01b8152806177846004820161043b565b0390fd5b8061779c6177966002617727565b91617727565b145f146177ca576177c66177af836163d0565b5f91829163fce698f760e01b835260048301610554565b0390fd5b6177dd6177d76003617727565b91617727565b146177e55750565b617800905f9182916335e2f38360e21b835260048301610dbc565b0390fd5b90565b61781b61781661782092617804565b610739565b610544565b90565b61785861785f9461784e606094989795617844608086019a5f870190610daf565b6020850190610fd4565b6040830190610daf565b0190610daf565b565b61787561787061787a9261255b565b612608565b610dac565b90565b939293617888614630565b5061789161764c565b5061789a616d40565b506178a4856163d0565b6178d66178d07f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0617807565b91610544565b1161796357906178f9602094955f949392936178f0610392565b94859485617823565b838052039060015afa1561795e576179115f51612608565b8061792c6179266179215f61257a565b6103df565b916103df565b14617942575f9161793c5f617861565b91929190565b5061794c5f61257a565b6001916179585f617861565b91929190565b6146ab565b50505061796f5f61257a565b906003929192919056fea164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static DEPLOYED_BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\x80`@R`\x046\x10\x15a\0\x13W[a$\xB4V[a\0\x1D_5a\x03\x8CV[\x80c\x05w\x85P\x14a\x03\x87W\x80c\x07X#o\x14a\x03\x82W\x80c\x0Cviz\x14a\x03}W\x80c\x19\x1C\xBD\x1A\x14a\x03xW\x80c\x1E\x8F^\xE5\x14a\x03sW\x80c \x81)V\x14a\x03nW\x80c\"\xF1\xEC\x93\x14a\x03iW\x80c,\x95v\x88\x14a\x03dW\x80c-\xAE\x18\x85\x14a\x03_W\x80c1\xE3\xBD\x1B\x14a\x03ZW\x80c6D\xE5\x15\x14a\x03UW\x80c:\xC3\xCB\xE6\x14a\x03PW\x80c>n4\xA7\x14a\x03KW\x80c?\xD6,m\x14a\x03FW\x80c@#Z\x9C\x14a\x03AW\x80cH\xF4\xDA \x14a\x03<W\x80cV\x85\xCFh\x14a\x037W\x80cV\xC4\xE1}\x14a\x032W\x80cY\xDC\xEA\x12\x14a\x03-W\x80cZ\x93m\xC6\x14a\x03(W\x80c\\\xCE\x98\xA6\x14a\x03#W\x80c`vC\x9C\x14a\x03\x1EW\x80c`\xCF\t\x91\x14a\x03\x19W\x80ca\xD6\xB8l\x14a\x03\x14W\x80cb\xC7\xE8\xFC\x14a\x03\x0FW\x80ce\xA6\x93n\x14a\x03\nW\x80ck\xFE\x06\xA6\x14a\x03\x05W\x80cqP\x18\xA6\x14a\x03\0W\x80cq\xE78\x8C\x14a\x02\xFBW\x80cv9\xD2'\x14a\x02\xF6W\x80cy\xBAP\x97\x14a\x02\xF1W\x80c{\x9Fd\xB2\x14a\x02\xECW\x80c\x81\xBE\xAC.\x14a\x02\xE7W\x80c\x84\xEFs\"\x14a\x02\xE2W\x80c\x8D\xA5\xCB[\x14a\x02\xDDW\x80c\x96hl\x1E\x14a\x02\xD8W\x80c\x9C\xBD\xAE\"\x14a\x02\xD3W\x80c\xAD\xFF\x83\x0C\x14a\x02\xCEW\x80c\xAEG\n\x85\x14a\x02\xC9W\x80c\xB0t\xE9\xDD\x14a\x02\xC4W\x80c\xB9\x9FgY\x14a\x02\xBFW\x80c\xBA\x1F\xB1\x03\x14a\x02\xBAW\x80c\xC1\xEF\x9D\xDF\x14a\x02\xB5W\x80c\xC5\xD9`\xBB\x14a\x02\xB0W\x80c\xCF\xE3GI\x14a\x02\xABW\x80c\xD4\x13\xA5\x80\x14a\x02\xA6W\x80c\xD5Q\x16,\x14a\x02\xA1W\x80c\xDACZ|\x14a\x02\x9CW\x80c\xE3\x0C9x\x14a\x02\x97W\x80c\xE6\\\xAF\xCB\x14a\x02\x92W\x80c\xEE\x1C\x03\x90\x14a\x02\x8DW\x80c\xF2\xFD\xE3\x8B\x14a\x02\x88W\x80c\xF9\x10\x7F;\x14a\x02\x83W\x80c\xF9\xF1gb\x14a\x02~Wc\xFF\xCF\x08\xF0\x03a\0\x0EWa$\x80V[a$KV[a#\xE8V[a#\x88V[a#RV[a#\x1EV[a\"\xE9V[a\"\xB1V[a!\xDFV[a!\xA5V[a \xE7V[a \xA5V[a pV[a\x1FFV[a\x1F\x12V[a\x1E\xA5V[a\x1EkV[a\x1D\xA0V[a\x1C\xD9V[a\x1BPV[a\x1A\x96V[a\x1AcV[a\x1A,V[a\x19\x97V[a\x19dV[a\x19.V[a\x18\xF8V[a\x18<V[a\x18\x07V[a\x17\x99V[a\x15TV[a\x15\nV[a\x14\x88V[a\x14SV[a\x13\xE5V[a\x13-V[a\x12\xD4V[a\x12\x9FV[a\x12:V[a\x11\xF0V[a\x11\x84V[a\x10\xB0V[a\x10vV[a\x0E>V[a\r\xD1V[a\rRV[a\x0B\x98V[a\n\xFDV[a\nZV[a\x06\xB6V[a\x06dV[a\x060V[a\x05iV[a\x05\x0FV[a\x04@V[`\xE0\x1C\x90V[`@Q\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x03\xBA\x81a\x03\xA4V[\x03a\x03\xC1WV[_\x80\xFD[\x90P5\x90a\x03\xD2\x82a\x03\xB1V[V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x03\xE8\x90a\x03\xD4V[\x90V[a\x03\xF4\x81a\x03\xDFV[\x03a\x03\xFBWV[_\x80\xFD[\x90P5\x90a\x04\x0C\x82a\x03\xEBV[V[\x91\x90`@\x83\x82\x03\x12a\x046W\x80a\x04*a\x043\x92_\x86\x01a\x03\xC5V[\x93` \x01a\x03\xFFV[\x90V[a\x03\x9CV[_\x01\x90V[4a\x04oWa\x04Ya\x04S6`\x04a\x04\x0EV[\x90a&KV[a\x04aa\x03\x92V[\x80a\x04k\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90` \x82\x82\x03\x12a\x04\x8DWa\x04\x8A\x91_\x01a\x03\xC5V[\x90V[a\x03\x9CV[a\x04\x9B\x90a\x03\xA4V[\x90RV[`\xFF\x16\x90V[a\x04\xAE\x90a\x04\x9FV[\x90RV[\x15\x15\x90V[a\x04\xC0\x90a\x04\xB2V[\x90RV[\x90`@\x80a\x04\xF8\x93a\x04\xDC_\x82\x01Q_\x86\x01\x90a\x04\x92V[a\x04\xEE` \x82\x01Q` \x86\x01\x90a\x04\xA5V[\x01Q\x91\x01\x90a\x04\xB7V[V[\x91\x90a\x05\r\x90_``\x85\x01\x94\x01\x90a\x04\xC4V[V[4a\x05?Wa\x05;a\x05*a\x05%6`\x04a\x04tV[a'*V[a\x052a\x03\x92V[\x91\x82\x91\x82a\x04\xFAV[\x03\x90\xF3[a\x03\x98V[\x90V[a\x05P\x90a\x05DV[\x90RV[\x91\x90a\x05g\x90_` \x85\x01\x94\x01\x90a\x05GV[V[4a\x05\x9AWa\x05\x96a\x05\x85a\x05\x7F6`\x04a\x04\x0EV[\x90a'CV[a\x05\x8Da\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x05\xE5W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x05\xE0W` \x01\x92` \x83\x02\x84\x01\x11a\x05\xDBWV[a\x05\xA7V[a\x05\xA3V[a\x05\x9FV[\x91\x90\x91`@\x81\x84\x03\x12a\x06+Wa\x06\x03\x83_\x83\x01a\x03\xC5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x06&Wa\x06\"\x92\x01a\x05\xABV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[4a\x06_Wa\x06Ia\x06C6`\x04a\x05\xEAV[\x91a0\xCCV[a\x06Qa\x03\x92V[\x80a\x06[\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x06\x93Wa\x06}a\x06w6`\x04a\x04\x0EV[\x90a32V[a\x06\x85a\x03\x92V[\x80a\x06\x8F\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90` \x82\x82\x03\x12a\x06\xB1Wa\x06\xAE\x91_\x01a\x03\xFFV[\x90V[a\x03\x9CV[4a\x06\xE4Wa\x06\xCEa\x06\xC96`\x04a\x06\x98V[a4HV[a\x06\xD6a\x03\x92V[\x80a\x06\xE0\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[a\x06\xF2\x81a\x05DV[\x03a\x06\xF9WV[_\x80\xFD[\x90P5\x90a\x07\n\x82a\x06\xE9V[V[\x91\x90`@\x83\x82\x03\x12a\x074W\x80a\x07(a\x071\x92_\x86\x01a\x03\xC5V[\x93` \x01a\x06\xFDV[\x90V[a\x03\x9CV[\x90V[a\x07Pa\x07Ka\x07U\x92a\x03\xA4V[a\x079V[a\x03\xA4V[\x90V[\x90a\x07b\x90a\x07<V[_R` R`@_ \x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[T\x90V[_R` _ \x90V[_R` _ \x90V[a\x07\xA1\x81a\x07\x82V[\x82\x10\x15a\x07\xBBWa\x07\xB3`\x04\x91a\x07\x86V[\x91\x02\x01\x90_\x90V[a\x07nV[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x90`\x01`\x02\x83\x04\x92\x16\x80\x15a\x07\xF4W[` \x83\x10\x14a\x07\xEFWV[a\x07\xC0V[\x91`\x7F\x16\x91a\x07\xE4V[` \x91\x81R\x01\x90V[_R` _ \x90V[\x90_\x92\x91\x80T\x90a\x08*a\x08#\x83a\x07\xD4V[\x80\x94a\x07\xFEV[\x91`\x01\x81\x16\x90\x81_\x14a\x08\x81WP`\x01\x14a\x08EW[PPPV[a\x08R\x91\x92\x93\x94Pa\x08\x07V[\x91_\x92[\x81\x84\x10a\x08iWPP\x01\x90_\x80\x80a\x08@V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a\x08VV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a\x08@V[\x90a\x08\xA6\x91a\x08\x10V[\x90V[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\x08\xD1\x90a\x08\xA9V[\x81\x01\x90\x81\x10g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x17a\x08\xEBW`@RV[a\x08\xB3V[\x90a\t\x10a\t\t\x92a\t\0a\x03\x92V[\x93\x84\x80\x92a\x08\x9CV[\x03\x83a\x08\xC7V[V[_\x1C\x90V[\x90V[a\t&a\t+\x91a\t\x12V[a\t\x17V[\x90V[a\t8\x90Ta\t\x1AV[\x90V[`\xFF\x16\x90V[a\tMa\tR\x91a\t\x12V[a\t;V[\x90V[a\t_\x90Ta\tAV[\x90V[a\tm\x90`\x08a\x07XV[\x90a\tw\x82a\x07\x82V[\x81\x10\x15a\t\xBDWa\t\x87\x91a\x07\x98V[P\x90a\t\x94_\x83\x01a\x08\xF0V[\x91a\t\xA1`\x01\x82\x01a\t.V[\x91a\t\xBA`\x03a\t\xB3`\x02\x85\x01a\t.V[\x93\x01a\tUV[\x90V[_\x80\xFD[Q\x90V[` \x91\x81R\x01\x90V[\x90\x82_\x93\x92\x82^\x01RV[a\t\xF8a\n\x01` \x93a\n\x06\x93a\t\xEF\x81a\t\xC1V[\x93\x84\x80\x93a\t\xC5V[\x95\x86\x91\x01a\t\xCEV[a\x08\xA9V[\x01\x90V[a\n\x13\x90a\x04\xB2V[\x90RV[a\nQa\nX\x94a\nGa\n<``\x95\x99\x98\x96\x99`\x80\x86\x01\x90\x86\x82\x03_\x88\x01Ra\t\xD9V[\x98` \x85\x01\x90a\x05GV[`@\x83\x01\x90a\x05GV[\x01\x90a\n\nV[V[4a\n\x8FWa\n\x8Ba\nva\np6`\x04a\x07\x0CV[\x90a\tbV[\x90a\n\x82\x94\x92\x94a\x03\x92V[\x94\x85\x94\x85a\n\x17V[\x03\x90\xF3[a\x03\x98V[_\x91\x03\x12a\n\x9EWV[a\x03\x9CV[\x90V[a\n\xBAa\n\xB5a\n\xBF\x92a\n\xA3V[a\x079V[a\x03\xA4V[\x90V[a\n\xCDa\x01,a\n\xA6V[\x90V[a\n\xD8a\n\xC2V[\x90V[a\n\xE4\x90a\x03\xA4V[\x90RV[\x91\x90a\n\xFB\x90_` \x85\x01\x94\x01\x90a\n\xDBV[V[4a\x0B-Wa\x0B\r6`\x04a\n\x94V[a\x0B)a\x0B\x18a\n\xD0V[a\x0B a\x03\x92V[\x91\x82\x91\x82a\n\xE8V[\x03\x90\xF3[a\x03\x98V[\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x0BQ\x90`\x08a\x0BV\x93\x02a\x0B2V[a\x0B6V[\x90V[\x90a\x0Bd\x91Ta\x0BAV[\x90V[a\x0Bs`\x0B_\x90a\x0BYV[\x90V[a\x0B\x7F\x90a\x03\xDFV[\x90RV[\x91\x90a\x0B\x96\x90_` \x85\x01\x94\x01\x90a\x0BvV[V[4a\x0B\xC8Wa\x0B\xA86`\x04a\n\x94V[a\x0B\xC4a\x0B\xB3a\x0BgV[a\x0B\xBBa\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x0C\x07W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x0C\x02W` \x01\x92`\x01\x83\x02\x84\x01\x11a\x0B\xFDWV[a\x05\xA7V[a\x05\xA3V[a\x05\x9FV[\x90` \x82\x82\x03\x12a\x0C=W_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0C8Wa\x0C4\x92\x01a\x0B\xCDV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x0Cta\x0C}` \x93a\x0C\x82\x93a\x0Ck\x81a\t\xC1V[\x93\x84\x80\x93a\x07\xFEV[\x95\x86\x91\x01a\t\xCEV[a\x08\xA9V[\x01\x90V[a\x0C\x8F\x90a\x05DV[\x90RV[\x90a\x0C\xBD\x90` \x80a\x0C\xB2`@\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\x0CUV[\x94\x01Q\x91\x01\x90a\x0C\x86V[\x90V[\x90a\x0C\xCA\x91a\x0C\x93V[\x90V[` \x01\x90V[\x90a\x0C\xE7a\x0C\xE0\x83a\x0CBV[\x80\x92a\x0CFV[\x90\x81a\x0C\xF8` \x83\x02\x84\x01\x94a\x0COV[\x92_\x91[\x83\x83\x10a\r\x0BWPPPPP\x90V[\x90\x91\x92\x93\x94` a\r-a\r'\x83\x85`\x01\x95\x03\x87R\x89Qa\x0C\xC0V[\x97a\x0C\xCDV[\x93\x01\x93\x01\x91\x93\x92\x90a\x0C\xFCV[a\rO\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x0C\xD3V[\x90V[4a\r\x83Wa\r\x7Fa\rna\rh6`\x04a\x0C\x0CV[\x90a4\x8DV[a\rva\x03\x92V[\x91\x82\x91\x82a\r:V[\x03\x90\xF3[a\x03\x98V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[\x90V[a\r\xB8\x90a\r\xACV[\x90RV[\x91\x90a\r\xCF\x90_` \x85\x01\x94\x01\x90a\r\xAFV[V[4a\x0E\x01Wa\r\xE16`\x04a\n\x94V[a\r\xFDa\r\xECa\r\x88V[a\r\xF4a\x03\x92V[\x91\x82\x91\x82a\r\xBCV[\x03\x90\xF3[a\x03\x98V[\x90V[a\x0E\x1Da\x0E\x18a\x0E\"\x92a\x0E\x06V[a\x079V[a\x03\xA4V[\x90V[a\x0E0a\x0E\x10a\x0E\tV[\x90V[a\x0E;a\x0E%V[\x90V[4a\x0EnWa\x0EN6`\x04a\n\x94V[a\x0Eja\x0EYa\x0E3V[a\x0Eaa\x03\x92V[\x91\x82\x91\x82a\n\xE8V[\x03\x90\xF3[a\x03\x98V[\x90a\x0E}\x90a\x07<V[_R` R`@_ \x90V[a\x0E\x9Da\x0E\x98a\x0E\xA2\x92a\x03\xD4V[a\x079V[a\x03\xD4V[\x90V[a\x0E\xAE\x90a\x0E\x89V[\x90V[a\x0E\xBA\x90a\x0E\xA5V[\x90V[\x90a\x0E\xC7\x90a\x0E\xB1V[_R` R`@_ \x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x0E\xECa\x0E\xF1\x91a\t\x12V[a\x0E\xD3V[\x90V[a\x0E\xFE\x90Ta\x0E\xE0V[\x90V[`@\x1C\x90V[`\xFF\x16\x90V[a\x0F\x19a\x0F\x1E\x91a\x0F\x01V[a\x0F\x07V[\x90V[a\x0F+\x90Ta\x0F\rV[\x90V[`H\x1C\x90V[`\xFF\x16\x90V[a\x0FFa\x0FK\x91a\x0F.V[a\x0F4V[\x90V[a\x0FX\x90Ta\x0F:V[\x90V[\x90V[a\x0Fja\x0Fo\x91a\t\x12V[a\x0F[V[\x90V[a\x0F|\x90Ta\x0F^V[\x90V[\x90a\x0F\x8Ea\x0F\x93\x92`\x03a\x0EsV[a\x0E\xBDV[a\x0F\x9E_\x82\x01a\t.V[\x91a\x0F\xAB`\x01\x83\x01a\x0E\xF4V[\x91a\x0F\xB8`\x01\x82\x01a\x0F!V[\x91a\x0F\xD1`\x02a\x0F\xCA`\x01\x85\x01a\x0FNV[\x93\x01a\x0FrV[\x90V[a\x0F\xDD\x90a\x04\x9FV[\x90RV[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[`\x05\x11\x15a\x0F\xFFWV[a\x0F\xE1V[\x90a\x10\x0E\x82a\x0F\xF5V[V[a\x10\x19\x90a\x10\x04V[\x90V[a\x10%\x90a\x10\x10V[\x90RV[\x90\x95\x94\x92a\x10t\x94a\x10ca\x10m\x92a\x10Y`\x80\x96a\x10O`\xA0\x88\x01\x9C_\x89\x01\x90a\x05GV[` \x87\x01\x90a\n\xDBV[`@\x85\x01\x90a\x0F\xD4V[``\x83\x01\x90a\x10\x1CV[\x01\x90a\r\xAFV[V[4a\x10\xABWa\x10\xA7a\x10\x92a\x10\x8C6`\x04a\x04\x0EV[\x90a\x0F\x7FV[\x91a\x10\x9E\x95\x93\x95a\x03\x92V[\x95\x86\x95\x86a\x10)V[\x03\x90\xF3[a\x03\x98V[4a\x10\xE0Wa\x10\xDCa\x10\xCBa\x10\xC66`\x04a\x04tV[a4\xA7V[a\x10\xD3a\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x11\x01\x90a\x03\xDFV[\x90RV[\x90a\x11\x12\x81` \x93a\x10\xF8V[\x01\x90V[` \x01\x90V[\x90a\x119a\x113a\x11,\x84a\x10\xE5V[\x80\x93a\x10\xE9V[\x92a\x10\xF2V[\x90_[\x81\x81\x10a\x11IWPPP\x90V[\x90\x91\x92a\x11ba\x11\\`\x01\x92\x86Qa\x11\x05V[\x94a\x11\x16V[\x91\x01\x91\x90\x91a\x11<V[a\x11\x81\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x11\x1CV[\x90V[4a\x11\xB4Wa\x11\xB0a\x11\x9Fa\x11\x9A6`\x04a\x04tV[a5aV[a\x11\xA7a\x03\x92V[\x91\x82\x91\x82a\x11lV[\x03\x90\xF3[a\x03\x98V[\x90V[a\x11\xD0a\x11\xCBa\x11\xD5\x92a\x11\xB9V[a\x079V[a\x05DV[\x90V[a\x11\xE2`\xC8a\x11\xBCV[\x90V[a\x11\xEDa\x11\xD8V[\x90V[4a\x12 Wa\x12\x006`\x04a\n\x94V[a\x12\x1Ca\x12\x0Ba\x11\xE5V[a\x12\x13a\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[\x91\x90a\x128\x90_` \x85\x01\x94\x01\x90a\n\nV[V[4a\x12kWa\x12ga\x12Va\x12P6`\x04a\x04\x0EV[\x90a6\x01V[a\x12^a\x03\x92V[\x91\x82\x91\x82a\x12%V[\x03\x90\xF3[a\x03\x98V[\x90a\x12z\x90a\x07<V[_R` R`@_ \x90V[a\x12\x9C\x90a\x12\x97`\x07\x91_\x92a\x12pV[a\x0BYV[\x90V[4a\x12\xCFWa\x12\xCBa\x12\xBAa\x12\xB56`\x04a\x04tV[a\x12\x86V[a\x12\xC2a\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[4a\x13\x04Wa\x13\0a\x12\xEFa\x12\xEA6`\x04a\x04tV[a6\x88V[a\x12\xF7a\x03\x92V[\x91\x82\x91\x82a\x11lV[\x03\x90\xF3[a\x03\x98V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[4a\x13]Wa\x13=6`\x04a\n\x94V[a\x13Ya\x13Ha\x13\tV[a\x13Pa\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[a\x13k\x81a\x04\x9FV[\x03a\x13rWV[_\x80\xFD[\x90P5\x90a\x13\x83\x82a\x13bV[V[\x90`\x80\x82\x82\x03\x12a\x13\xE0Wa\x13\x9C\x81_\x84\x01a\x03\xC5V[\x92a\x13\xAA\x82` \x85\x01a\x03\xC5V[\x92a\x13\xB8\x83`@\x83\x01a\x13vV[\x92``\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x13\xDBWa\x13\xD7\x92\x01a\x0B\xCDV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[4a\x14\x17Wa\x14\x01a\x13\xF86`\x04a\x13\x85V[\x93\x92\x90\x92a7|V[a\x14\ta\x03\x92V[\x80a\x14\x13\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90V[a\x143a\x14.a\x148\x92a\x14\x1CV[a\x079V[a\x05DV[\x90V[a\x14E`2a\x14\x1FV[\x90V[a\x14Pa\x14;V[\x90V[4a\x14\x83Wa\x14c6`\x04a\n\x94V[a\x14\x7Fa\x14na\x14HV[a\x14va\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[4a\x14\xB9Wa\x14\xB5a\x14\xA4a\x14\x9E6`\x04a\x04\x0EV[\x90a7\x8BV[a\x14\xACa\x03\x92V[\x91\x82\x91\x82a\x12%V[\x03\x90\xF3[a\x03\x98V[\x90V[a\x14\xD5a\x14\xD0a\x14\xDA\x92a\x14\xBEV[a\x079V[a\x04\x9FV[\x90V[a\x14\xE7`\x03a\x14\xC1V[\x90V[a\x14\xF2a\x14\xDDV[\x90V[\x91\x90a\x15\x08\x90_` \x85\x01\x94\x01\x90a\x0F\xD4V[V[4a\x15:Wa\x15\x1A6`\x04a\n\x94V[a\x156a\x15%a\x14\xEAV[a\x15-a\x03\x92V[\x91\x82\x91\x82a\x14\xF5V[\x03\x90\xF3[a\x03\x98V[\x91\x90a\x15R\x90_` \x85\x01\x94\x01\x90a\x10\x1CV[V[4a\x15\x85Wa\x15\x81a\x15pa\x15j6`\x04a\x04\x0EV[\x90a7\xB7V[a\x15xa\x03\x92V[\x91\x82\x91\x82a\x15?V[\x03\x90\xF3[a\x03\x98V[\x90a\x15\x9Da\x15\x96a\x03\x92V[\x92\x83a\x08\xC7V[V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x15\xB7W` \x80\x91\x02\x01\x90V[a\x08\xB3V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x15\xE6Wa\x15\xE2` \x91a\x08\xA9V[\x01\x90V[a\x08\xB3V[\x90\x82_\x93\x92\x827\x01RV[\x90\x92\x91\x92a\x16\x0Ba\x16\x06\x82a\x15\xC8V[a\x15\x8AV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a\x16'Wa\x16%\x92a\x15\xEBV[V[a\x15\xC4V[\x90\x80`\x1F\x83\x01\x12\x15a\x16JW\x81` a\x16G\x935\x91\x01a\x15\xF6V[\x90V[a\x05\x9FV[\x91\x90\x91`@\x81\x84\x03\x12a\x16\xA2Wa\x16f`@a\x15\x8AV[\x92_\x82\x015\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x16\x9DWa\x16\x8A\x82a\x16\x96\x94\x83\x01a\x16,V[_\x86\x01R` \x01a\x06\xFDV[` \x83\x01RV[a\x15\xC0V[a\x15\xBCV[\x92\x91\x90a\x16\xBBa\x16\xB6\x82a\x15\x9FV[a\x15\x8AV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11a\x17\x12W\x81\x90[\x83\x82\x10a\x16\xE1WPPPPPV[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x17\rW` \x91a\x17\x02\x87\x84\x93\x87\x01a\x16OV[\x81R\x01\x91\x01\x90a\x16\xD3V[a\x05\x9FV[a\x05\xA7V[\x90\x80`\x1F\x83\x01\x12\x15a\x175W\x81` a\x172\x935\x91\x01a\x16\xA7V[\x90V[a\x05\x9FV[`\x80\x81\x83\x03\x12a\x17\x94Wa\x17P\x82_\x83\x01a\x03\xC5V[\x92a\x17^\x83` \x84\x01a\x03\xFFV[\x92`@\x83\x015\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a\x17\x8FWa\x17\x83\x81a\x17\x8C\x93\x86\x01a\x17\x17V[\x93``\x01a\x06\xFDV[\x90V[a\x03\xA0V[a\x03\x9CV[4a\x17\xCBWa\x17\xB5a\x17\xAC6`\x04a\x17:V[\x92\x91\x90\x91a;\xA7V[a\x17\xBDa\x03\x92V[\x80a\x17\xC7\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90V[a\x17\xE7a\x17\xE2a\x17\xEC\x92a\x17\xD0V[a\x079V[a\x05DV[\x90V[a\x17\xF9`@a\x17\xD3V[\x90V[a\x18\x04a\x17\xEFV[\x90V[4a\x187Wa\x18\x176`\x04a\n\x94V[a\x183a\x18\"a\x17\xFCV[a\x18*a\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[4a\x18jWa\x18L6`\x04a\n\x94V[a\x18TaA\xD6V[a\x18\\a\x03\x92V[\x80a\x18f\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[a\x18x\x90a\x10\x10V[\x90RV[a\x18\x85\x90a\r\xACV[\x90RV[\x90`\x80\x80a\x18\xE1\x93a\x18\xA1_\x82\x01Q_\x86\x01\x90a\x0C\x86V[a\x18\xB3` \x82\x01Q` \x86\x01\x90a\x04\x92V[a\x18\xC5`@\x82\x01Q`@\x86\x01\x90a\x04\xA5V[a\x18\xD7``\x82\x01Q``\x86\x01\x90a\x18oV[\x01Q\x91\x01\x90a\x18|V[V[\x91\x90a\x18\xF6\x90_`\xA0\x85\x01\x94\x01\x90a\x18\x89V[V[4a\x19)Wa\x19%a\x19\x14a\x19\x0E6`\x04a\x04\x0EV[\x90aC\x13V[a\x19\x1Ca\x03\x92V[\x91\x82\x91\x82a\x18\xE3V[\x03\x90\xF3[a\x03\x98V[4a\x19_Wa\x19[a\x19Ja\x19D6`\x04a\x04\x0EV[\x90aCkV[a\x19Ra\x03\x92V[\x91\x82\x91\x82a\n\xE8V[\x03\x90\xF3[a\x03\x98V[4a\x19\x92Wa\x19t6`\x04a\n\x94V[a\x19|aC\x93V[a\x19\x84a\x03\x92V[\x80a\x19\x8E\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x19\xC7Wa\x19\xC3a\x19\xB2a\x19\xAD6`\x04a\x04tV[aC\xE4V[a\x19\xBAa\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[\x90\x91``\x82\x84\x03\x12a\x1A\x01Wa\x19\xFEa\x19\xE7\x84_\x85\x01a\x03\xC5V[\x93a\x19\xF5\x81` \x86\x01a\x06\xFDV[\x93`@\x01a\x06\xFDV[\x90V[a\x03\x9CV[\x92\x91` a\x1A\"a\x1A*\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\x11\x1CV[\x94\x01\x90a\x05GV[V[4a\x1A^Wa\x1AEa\x1A?6`\x04a\x19\xCCV[\x91aD\x9EV[\x90a\x1AZa\x1AQa\x03\x92V[\x92\x83\x92\x83a\x1A\x06V[\x03\x90\xF3[a\x03\x98V[4a\x1A\x91Wa\x1A{a\x1Av6`\x04a\x06\x98V[aF%V[a\x1A\x83a\x03\x92V[\x80a\x1A\x8D\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x1A\xC6Wa\x1A\xA66`\x04a\n\x94V[a\x1A\xC2a\x1A\xB1aF4V[a\x1A\xB9a\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1B\x05W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1B\0W` \x01\x92` \x83\x02\x84\x01\x11a\x1A\xFBWV[a\x05\xA7V[a\x05\xA3V[a\x05\x9FV[\x91\x90\x91`@\x81\x84\x03\x12a\x1BKWa\x1B#\x83_\x83\x01a\x03\xC5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1BFWa\x1BB\x92\x01a\x1A\xCBV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[4a\x1B\x7FWa\x1Bia\x1Bc6`\x04a\x1B\nV[\x91aF\xBBV[a\x1Bqa\x03\x92V[\x80a\x1B{\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x91``\x83\x83\x03\x12a\x1B\xD0Wa\x1B\x9B\x82_\x85\x01a\x03\xC5V[\x92a\x1B\xA9\x83` \x83\x01a\x03\xFFV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1B\xCBWa\x1B\xC8\x92\x01a\x16,V[\x90V[a\x03\xA0V[a\x03\x9CV[\x90a\x1B\xDF\x90a\x07<V[_R` R`@_ \x90V[\x90a\x1B\xF5\x90a\x0E\xB1V[_R` R`@_ \x90V[\x90P\x90V[a\x1C+a\x1C\"\x92` \x92a\x1C\x19\x81a\t\xC1V[\x94\x85\x80\x93a\x1C\x01V[\x93\x84\x91\x01a\t\xCEV[\x01\x90V[\x90V[a\x1C>a\x1CC\x91a\x05DV[a\x1C/V[\x90RV[a\x1CWa\x1C^\x91` \x94\x93a\x1C\x06V[\x80\x92a\x1C2V[\x01\x90V[a\x1Cva\x1Cma\x03\x92V[\x92\x83\x92\x83a\x1CGV[\x03\x90 \x90V[a\x1C\x85\x91a\x1CbV[\x90V[a\x1C\x98\x90`\x08a\x1C\x9D\x93\x02a\x0B2V[a\t\x17V[\x90V[\x90a\x1C\xAB\x91Ta\x1C\x88V[\x90V[\x90a\x1C\xD6\x92a\x1C\xCCa\x1C\xD1\x92a\x1C\xC7`\t\x95_\x96a\x1B\xD5V[a\x1B\xEBV[a\x1C|V[a\x1C\xA0V[\x90V[4a\x1D\nWa\x1D\x06a\x1C\xF5a\x1C\xEF6`\x04a\x1B\x84V[\x91a\x1C\xAEV[a\x1C\xFDa\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1DIW\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1DDW` \x01\x92`\x01\x83\x02\x84\x01\x11a\x1D?WV[a\x05\xA7V[a\x05\xA3V[a\x05\x9FV[\x91``\x83\x83\x03\x12a\x1D\x9BWa\x1De\x82_\x85\x01a\x03\xC5V[\x92a\x1Ds\x83` \x83\x01a\x03\xFFV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1D\x96Wa\x1D\x92\x92\x01a\x1D\x0FV[\x90\x91V[a\x03\xA0V[a\x03\x9CV[4a\x1D\xD2Wa\x1D\xBCa\x1D\xB36`\x04a\x1DNV[\x92\x91\x90\x91aI<V[a\x1D\xC4a\x03\x92V[\x80a\x1D\xCE\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[a\x1D\xE0\x81a\x04\xB2V[\x03a\x1D\xE7WV[_\x80\xFD[\x90P5\x90a\x1D\xF8\x82a\x1D\xD7V[V[\x91\x90\x91`\xA0\x81\x84\x03\x12a\x1EfWa\x1E\x13\x83_\x83\x01a\x03\xC5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1EaW\x81a\x1E4\x91\x84\x01a\x1D\x0FV[\x92\x90\x93a\x1E^a\x1EG\x84`@\x85\x01a\x06\xFDV[\x93a\x1EU\x81``\x86\x01a\x06\xFDV[\x93`\x80\x01a\x1D\xEBV[\x90V[a\x03\xA0V[a\x03\x9CV[4a\x1E\xA0Wa\x1E\x8Aa\x1E~6`\x04a\x1D\xFAV[\x94\x93\x90\x93\x92\x91\x92aL\x11V[a\x1E\x92a\x03\x92V[\x80a\x1E\x9C\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x1E\xD3Wa\x1E\xBDa\x1E\xB86`\x04a\x04tV[aO\xC6V[a\x1E\xC5a\x03\x92V[\x80a\x1E\xCF\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x90\x91``\x82\x84\x03\x12a\x1F\rWa\x1F\na\x1E\xF3\x84_\x85\x01a\x03\xC5V[\x93a\x1F\x01\x81` \x86\x01a\x03\xC5V[\x93`@\x01a\x13vV[\x90V[a\x03\x9CV[4a\x1FAWa\x1F+a\x1F%6`\x04a\x1E\xD8V[\x91aR;V[a\x1F3a\x03\x92V[\x80a\x1F=\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\x1FuWa\x1F_a\x1FY6`\x04a\x04\x0EV[\x90aT\x1FV[a\x1Fga\x03\x92V[\x80a\x1Fq\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[\x90a\x1F\xDB\x90``\x80a\x1F\xAC`\x80\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\x0CUV[\x94a\x1F\xBF` \x82\x01Q` \x86\x01\x90a\x0C\x86V[a\x1F\xD1`@\x82\x01Q`@\x86\x01\x90a\x0C\x86V[\x01Q\x91\x01\x90a\x04\xB7V[\x90V[\x90a\x1F\xE8\x91a\x1F\x8DV[\x90V[` \x01\x90V[\x90a \x05a\x1F\xFE\x83a\x1FzV[\x80\x92a\x1F~V[\x90\x81a \x16` \x83\x02\x84\x01\x94a\x1F\x87V[\x92_\x91[\x83\x83\x10a )WPPPPP\x90V[\x90\x91\x92\x93\x94` a Ka E\x83\x85`\x01\x95\x03\x87R\x89Qa\x1F\xDEV[\x97a\x1F\xEBV[\x93\x01\x93\x01\x91\x93\x92\x90a \x1AV[a m\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x1F\xF1V[\x90V[4a \xA0Wa \x9Ca \x8Ba \x866`\x04a\x04tV[aW\x96V[a \x93a\x03\x92V[\x91\x82\x91\x82a XV[\x03\x90\xF3[a\x03\x98V[4a \xD3Wa \xBDa \xB86`\x04a\x04tV[aY&V[a \xC5a\x03\x92V[\x80a \xCF\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[a \xE4`\n_\x90a\x0BYV[\x90V[4a!\x17Wa \xF76`\x04a\n\x94V[a!\x13a!\x02a \xD8V[a!\na\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[\x90\x91`\xA0\x82\x84\x03\x12a!\xA0Wa!4\x83_\x84\x01a\x03\xC5V[\x92a!B\x81` \x85\x01a\x03\xC5V[\x92a!P\x82`@\x83\x01a\x13vV[\x92``\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a!\x9BW\x83a!q\x91\x84\x01a\x0B\xCDV[\x92\x90\x93`\x80\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a!\x96Wa!\x92\x92\x01a\x0B\xCDV[\x90\x91V[a\x03\xA0V[a\x03\xA0V[a\x03\x9CV[4a!\xDAWa!\xC4a!\xB86`\x04a!\x1CV[\x95\x94\x90\x94\x93\x91\x93a\\)V[a!\xCCa\x03\x92V[\x80a!\xD6\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a\"\x13Wa\"\x0Fa!\xFEa!\xF56`\x04a\x1DNV[\x92\x91\x90\x91a\\\x9CV[a\"\x06a\x03\x92V[\x91\x82\x91\x82a\x05TV[\x03\x90\xF3[a\x03\x98V[\x90a\"\"\x90a\x07<V[_R` R`@_ \x90V[a\":a\"?\x91a\x0F.V[a\t;V[\x90V[a\"L\x90Ta\".V[\x90V[a\"Z\x90`\x02a\"\x18V[a\"e_\x82\x01a\x0E\xF4V[\x91a\"|_a\"u\x81\x85\x01a\x0F!V[\x93\x01a\"BV[\x90V[`@\x90a\"\xA8a\"\xAF\x94\x96\x95\x93\x96a\"\x9E``\x84\x01\x98_\x85\x01\x90a\n\xDBV[` \x83\x01\x90a\x0F\xD4V[\x01\x90a\n\nV[V[4a\"\xE4Wa\"\xE0a\"\xCCa\"\xC76`\x04a\x04tV[a\"OV[a\"\xD7\x93\x91\x93a\x03\x92V[\x93\x84\x93\x84a\"\x7FV[\x03\x90\xF3[a\x03\x98V[4a#\x19Wa\"\xF96`\x04a\n\x94V[a#\x15a#\x04a\\\xD1V[a#\x0Ca\x03\x92V[\x91\x82\x91\x82a\x0B\x83V[\x03\x90\xF3[a\x03\x98V[4a#MWa#7a#16`\x04a\x04\x0EV[\x90a]\xBBV[a#?a\x03\x92V[\x80a#I\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[4a#\x83Wa#\x7Fa#na#h6`\x04a\x04\x0EV[\x90a_PV[a#va\x03\x92V[\x91\x82\x91\x82a\x12%V[\x03\x90\xF3[a\x03\x98V[4a#\xB6Wa#\xA0a#\x9B6`\x04a\x06\x98V[a`OV[a#\xA8a\x03\x92V[\x80a#\xB2\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x91\x90`@\x83\x82\x03\x12a#\xE3W\x80a#\xD7a#\xE0\x92_\x86\x01a\x03\xC5V[\x93` \x01a\x1D\xEBV[\x90V[a\x03\x9CV[4a$\x17Wa$\x01a#\xFB6`\x04a#\xBBV[\x90a`ZV[a$\ta\x03\x92V[\x80a$\x13\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[\x7F\xE1g_\x83d\xC0zM`\xA0u\x03\xF0\xD7\0\xA7\xBC\xAC\xD8\"Q\xDF\xF0\xF0p\xE5#]\xE6\xC6\xD2\x8A\x90V[a$Ha$\x1CV[\x90V[4a${Wa$[6`\x04a\n\x94V[a$wa$fa$@V[a$na\x03\x92V[\x91\x82\x91\x82a\r\xBCV[\x03\x90\xF3[a\x03\x98V[4a$\xAFWa$\x99a$\x936`\x04a\x04\x0EV[\x90aa#V[a$\xA1a\x03\x92V[\x80a$\xAB\x81a\x04;V[\x03\x90\xF3[a\x03\x98V[_\x80\xFD[_\x7FOnly Tangle core\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a$\xEC`\x10` \x92a\t\xC5V[a$\xF5\x81a$\xB8V[\x01\x90V[a%\x0E\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra$\xDFV[\x90V[\x15a%\x18WV[a% a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a%6`\x04\x82\x01a$\xF9V[\x03\x90\xFD[a%Fa%K\x91a\t\x12V[a\x0B6V[\x90V[a%X\x90Ta%:V[\x90V[\x90V[a%ra%ma%w\x92a%[V[a\x079V[a\x03\xD4V[\x90V[a%\x83\x90a%^V[\x90V[_\x7FAlready registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%\xBA`\x12` \x92a\t\xC5V[a%\xC3\x81a%\x86V[\x01\x90V[a%\xDC\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%\xADV[\x90V[\x15a%\xE6WV[a%\xEEa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a&\x04`\x04\x82\x01a%\xC7V[\x03\x90\xFD[_\x1B\x90V[\x90a&\x1E`\x01\x80`\xA0\x1B\x03\x91a&\x08V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90a&@a&;a&G\x92a\x0E\xB1V[a&(V[\x82Ta&\rV[\x90UV[a&\xCDa&\xD2\x92a&\x8E3a&\x88a&\x82\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xDFV[\x91a\x03\xDFV[\x14a%\x11V[a&\xC5a&\xA5a&\xA0`\x07\x86\x90a\x12pV[a%NV[a&\xBFa&\xB9a&\xB4_a%zV[a\x03\xDFV[\x91a\x03\xDFV[\x14a%\xDFV[\x91`\x07a\x12pV[a&+V[V[a&\xDE``a\x15\x8AV[\x90V[_\x90V[_\x90V[_\x90V[a&\xF5a&\xD4V[\x90` \x80\x80\x84a'\x03a&\xE1V[\x81R\x01a'\x0Ea&\xE5V[\x81R\x01a'\x19a&\xE9V[\x81RPPV[a''a&\xEDV[\x90V[a'<\x90a'6a'\x1FV[PabKV[\x90V[_\x90V[a'da'j\x92a'__\x93a'Wa'?V[P`\x03a\x0EsV[a\x0E\xBDV[\x01a\t.V[\x90V[_\x7FNot service owner\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a'\xA1`\x11` \x92a\t\xC5V[a'\xAA\x81a'mV[\x01\x90V[a'\xC3\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra'\x94V[\x90V[\x15a'\xCDWV[a'\xD5a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a'\xEB`\x04\x82\x01a'\xAEV[\x03\x90\xFD[P\x90V[_\x7FToo many definitions\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a('`\x14` \x92a\t\xC5V[a(0\x81a'\xF3V[\x01\x90V[a(I\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x1AV[\x90V[\x15a(SWV[a([a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(q`\x04\x82\x01a(4V[\x03\x90\xFD[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[a(\x98a(\x9E\x91\x93\x92\x93a\x05DV[\x92a\x05DV[\x91a(\xAA\x83\x82\x02a\x05DV[\x92\x81\x84\x04\x14\x90\x15\x17\x15a(\xB9WV[a(uV[a(\xC9\x90`\x04a(\x89V[\x90V[\x90a(\xDF\x90_\x19\x90` \x03`\x08\x02a\x0B2V[\x81T\x16\x90UV[\x1B\x90V[\x91\x90`\x08a)\x05\x91\x02\x91a(\xFF_\x19\x84a(\xE6V[\x92a(\xE6V[\x91\x81\x19\x16\x91\x16\x17\x90V[a)#a)\x1Ea)(\x92a\x05DV[a\x079V[a\x05DV[\x90V[\x90V[\x91\x90a)Da)?a)L\x93a)\x0FV[a)+V[\x90\x83Ta(\xEAV[\x90UV[a)b\x91a)\\a'?V[\x91a).V[V[[\x81\x81\x10a)pWPPV[\x80a)}_`\x01\x93a)PV[\x01a)eV[\x90a)\x93\x90_\x19\x90`\x08\x02a\x0B2V[\x19\x16\x90V[\x81a)\xA2\x91a)\x83V[\x90`\x02\x02\x17\x90V[\x90_\x91a)\xC1a)\xB9\x82a\x08\x07V[\x92\x83Ta)\x98V[\x90UUV[`\x1F` \x91\x01\x04\x90V[\x91\x92\x90` \x82\x10_\x14a*)W`\x1F\x84\x11`\x01\x14a)\xF9Wa)\xF3\x92\x93Pa)\x98V[\x90U[[V[P\x90a*\x1Fa*$\x93`\x01a*\x16a*\x10\x85a\x08\x07V[\x92a)\xC6V[\x82\x01\x91\x01a)dV[a)\xAAV[a)\xF6V[Pa*`\x82\x93a*:`\x01\x94a\x08\x07V[a*Ya*F\x85a)\xC6V[\x82\x01\x92`\x1F\x86\x16\x80a*kW[Pa)\xC6V[\x01\x90a)dV[`\x02\x02\x17\x90Ua)\xF7V[a*w\x90\x88\x86\x03a(\xCCV[_a*SV[\x92\x90\x91h\x01\0\0\0\0\0\0\0\0\x82\x11a*\xDDW` \x11_\x14a*\xCEW` \x81\x10_\x14a*\xB2Wa*\xAC\x91a)\x98V[\x90U[[V[`\x01\x91`\xFF\x19\x16a*\xC2\x84a\x08\x07V[U`\x02\x02\x01\x90Ua*\xAFV[`\x01\x91P`\x02\x02\x01\x90Ua*\xB0V[a\x08\xB3V[\x90\x81Ta*\xEE\x81a\x07\xD4V[\x90\x81\x83\x11a+\x17W[\x81\x83\x10a+\x05W[PPPPV[a+\x0E\x93a)\xD0V[_\x80\x80\x80a*\xFFV[a+#\x83\x83\x83\x87a*}V[a*\xF7V[_a+2\x91a*\xE2V[V[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[\x90_\x03a+YWa+W\x90a+(V[V[a+4V[`\x03_\x91a+n\x83\x80\x83\x01a+GV[a+{\x83`\x01\x83\x01a)PV[a+\x88\x83`\x02\x83\x01a)PV[\x01UV[\x90_\x03a+\x9EWa+\x9C\x90a+^V[V[a+4V[[\x81\x81\x10a+\xAFWPPV[\x80a+\xBC_`\x04\x93a+\x8CV[\x01a+\xA4V[\x90\x91\x82\x81\x10a+\xD1W[PPPV[a+\xEFa+\xE9a+\xE3a+\xFA\x95a(\xBEV[\x92a(\xBEV[\x92a\x07\x86V[\x91\x82\x01\x91\x01\x90a+\xA3V[_\x80\x80a+\xCCV[\x90h\x01\0\0\0\0\0\0\0\0\x81\x11a,+W\x81a, a,)\x93a\x07\x82V[\x90\x82\x81Ua+\xC2V[V[a\x08\xB3V[_a,:\x91a,\x02V[V[\x90_\x03a,NWa,L\x90a,0V[V[a+4V[a,ga,ba,l\x92a%[V[a\x079V[a\x05DV[\x90V[`\x01a,{\x91\x01a\x05DV[\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x905\x90`\x01`\x80\x03\x816\x03\x03\x82\x12\x15a,\xA1W\x01\x90V[a,~V[\x90\x82\x10\x15a,\xC0W` a,\xBD\x92\x02\x81\x01\x90a,\x8AV[\x90V[a\x07nV[\x905\x90`\x01` \x03\x816\x03\x03\x82\x12\x15a-\x07W\x01\x805\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a-\x02W` \x01\x91`\x01\x82\x026\x03\x83\x13a,\xFDWV[a,\x86V[a,\x82V[a,~V[\x91V[P\x90V[_\x7FName too long\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-G`\r` \x92a\t\xC5V[a-P\x81a-\x13V[\x01\x90V[a-i\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-:V[\x90V[\x15a-sWV[a-{a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a-\x91`\x04\x82\x01a-TV[\x03\x90\xFD[5a-\x9F\x81a\x06\xE9V[\x90V[_\x7FInvalid bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-\xD6`\x0E` \x92a\t\xC5V[a-\xDF\x81a-\xA2V[\x01\x90V[a-\xF8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-\xC9V[\x90V[\x15a.\x02WV[a.\na\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a. `\x04\x82\x01a-\xE3V[\x03\x90\xFD[\x90V[_R` _ \x90V[T\x90V[a.=\x81a.0V[\x82\x10\x15a.WWa.O`\x04\x91a.'V[\x91\x02\x01\x90_\x90V[a\x07nV[P\x90V[\x91\x90`\x1F\x81\x11a.pW[PPPV[a.|a.\xA1\x93a\x08\x07V[\x90` a.\x88\x84a)\xC6V[\x83\x01\x93\x10a.\xA9W[a.\x9A\x90a)\xC6V[\x01\x90a)dV[_\x80\x80a.kV[\x91Pa.\x9A\x81\x92\x90Pa.\x91V[\x91a.\xC2\x90\x82a.\\V[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a/\x81Wa.\xE6\x82a.\xE0\x85Ta\x07\xD4V[\x85a.`V[_\x90`\x1F\x83\x11`\x01\x14a/\x19W\x91\x80\x91a/\x08\x93_\x92a/\rW[PPa)\x98V[\x90U[V[\x90\x91P\x015_\x80a/\x01V[`\x1F\x19\x83\x16\x91a/(\x85a\x08\x07V[\x92_[\x81\x81\x10a/iWP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10a/OW[PPP\x02\x01\x90Ua/\x0BV[a/_\x91\x015`\x1F\x84\x16\x90a)\x83V[\x90U_\x80\x80a/CV[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a/+V[a\x08\xB3V[\x90a/\x91\x92\x91a.\xB7V[V[\x90a/\x9F_\x19\x91a&\x08V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a/\xBEa/\xB9a/\xC5\x92a)\x0FV[a)+V[\x82Ta/\x93V[\x90UV[5a/\xD3\x81a\x1D\xD7V[\x90V[\x90a/\xE2`\xFF\x91a&\x08V[\x91\x81\x19\x16\x91\x16\x17\x90V[a/\xF5\x90a\x04\xB2V[\x90V[\x90V[\x90a0\x10a0\x0Ba0\x17\x92a/\xECV[a/\xF8V[\x82Ta/\xD6V[\x90UV[\x90a0y```\x03a0\x7F\x94a0?_\x82\x01a09_\x88\x01\x88a,\xC5V[\x91a/\x86V[a0X`\x01\x82\x01a0R` \x88\x01a-\x95V[\x90a/\xA9V[a0q`\x02\x82\x01a0k`@\x88\x01a-\x95V[\x90a/\xA9V[\x01\x92\x01a/\xC9V[\x90a/\xFBV[V[\x91\x90a0\x92Wa0\x90\x91a0\x1BV[V[a+4V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15a0\xC7W\x82a0\xBF\x91`\x01a0\xC5\x95\x01\x81Ua.4V[\x90a0\x81V[V[a\x08\xB3V[\x92\x91\x90\x92a0\xFF3a0\xF9a0\xF3a0\xEEa0\xE9`\x07\x87\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14a'\xC6V[a1-a1\r\x85\x84\x90a'\xEFV[a1&a1 a1\x1Ba\x14;V[a\x05DV[\x91a\x05DV[\x11\x15a(LV[a1B_a1=`\x08\x84\x90a\x07XV[a,<V[a1K_a,SV[[\x80a1ia1ca1^\x88\x87\x90a'\xEFV[a\x05DV[\x91a\x05DV[\x10\x15a2<Wa27\x90a1\xC0a1\xA0a1\x9Aa1\x94a1\x8B\x8A\x89\x87\x91a,\xA6V[_\x81\x01\x90a,\xC5V[\x90a-\x0CV[\x90a-\x0FV[a1\xB9a1\xB3a1\xAEa\x17\xEFV[a\x05DV[\x91a\x05DV[\x11\x15a-lV[a2\ta1\xDA`@a1\xD4\x89\x88\x86\x91a,\xA6V[\x01a-\x95V[a2\x02a1\xFCa1\xF7` a1\xF1\x8C\x8B\x89\x91a,\xA6V[\x01a-\x95V[a\x05DV[\x91a\x05DV[\x10\x15a-\xFBV[a22a2 a2\x1B`\x08\x86\x90a\x07XV[a.$V[a2,\x88\x87\x85\x91a,\xA6V[\x90a0\x97V[a,oV[a1LV[PPP\x90PV[_\x7FZero address\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a2w`\x0C` \x92a\t\xC5V[a2\x80\x81a2CV[\x01\x90V[a2\x99\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra2jV[\x90V[\x15a2\xA3WV[a2\xABa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a2\xC1`\x04\x82\x01a2\x84V[\x03\x90\xFD[\x90a2\xCF\x90a\x07<V[_R` R`@_ \x90V[\x90V[`H\x1B\x90V[\x90a2\xF9i\xFF\0\0\0\0\0\0\0\0\0\x91a2\xDEV[\x91\x81\x19\x16\x91\x16\x17\x90V[a3\x0C\x90a\x10\x04V[\x90V[\x90V[\x90a3'a3\"a3.\x92a3\x03V[a3\x0FV[\x82Ta2\xE4V[\x90UV[a3n3a3ha3b\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xDFV[\x91a\x03\xDFV[\x14a%\x11V[a3\x93\x82a3\x8Ca3\x86a3\x81_a%zV[a\x03\xDFV[\x91a\x03\xDFV[\x14\x15a2\x9CV[a3\xB9a3\xB4a3\xADa3\xA8`\x06\x85\x90a2\xC5V[a2\xDBV[\x84\x90ac)V[a%\xDFV[a3\xDC`\x02`\x01a3\xD6a3\xCF`\x03\x86\x90a\x0EsV[\x86\x90a\x0E\xBDV[\x01a3\x12V[\x90a4\x10a4\n\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK\x93a\x07<V[\x91a\x0E\xB1V[\x91a4\x19a\x03\x92V[\x80a4#\x81a\x04;V[\x03\x90\xA3V[a49\x90a44accV[a4;V[V[a4F\x90`\x0Ba&+V[V[a4Q\x90a4(V[V[``\x90V[\x90` \x82\x82\x03\x12a4\x88W_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a4\x83Wa4\x80\x92\x01a\x17\x17V[\x90V[a\x03\xA0V[a\x03\x9CV[\x90a4\xA4\x91a4\x9Aa4SV[P\x90\x81\x01\x90a4XV[\x90V[a4\xC6a4\xC1a4\xCB\x92a4\xB9a'?V[P`\x05a2\xC5V[a2\xDBV[ac\xB1V[\x90V[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a4\xEBW` \x80\x91\x02\x01\x90V[a\x08\xB3V[\x90a5\x02a4\xFD\x83a4\xD3V[a\x15\x8AV[\x91\x82RV[6\x907V[\x90a51a5\x19\x83a4\xF0V[\x92` \x80a5'\x86\x93a4\xD3V[\x92\x01\x91\x03\x90a5\x07V[V[\x90a5=\x82a\x10\xE5V[\x81\x10\x15a5NW` \x80\x91\x02\x01\x01\x90V[a\x07nV[\x90a5]\x90a\x03\xDFV[\x90RV[\x90a5ja4\xCEV[Pa5\x87a5\x82a5}`\x04\x85\x90a2\xC5V[a2\xDBV[ac\xB1V[\x91a5\x91\x83a5\x0CV[\x91a5\x9B_a,SV[[\x80a5\xAFa5\xA9\x87a\x05DV[\x91a\x05DV[\x10\x15a5\xF6Wa5\xF1\x90a5\xECa5\xDAa5\xD3a5\xCE`\x04\x88\x90a2\xC5V[a2\xDBV[\x83\x90ad\0V[a5\xE7\x87\x91\x84\x90\x92a53V[a5SV[a,oV[a5\x9CV[P\x92PP\x90V[_\x90V[\x90a6\na5\xFDV[Pa6,`\x01a6&a6\x1F`\x03\x86\x90a\x0EsV[\x84\x90a\x0E\xBDV[\x01a\x0FNV[a6>a68_a\x10\x04V[\x91a\x10\x04V[\x14\x91\x82\x15a6LW[PP\x90V[a6m\x92P`\x01\x91a6ba6g\x92`\x03a\x0EsV[a\x0E\xBDV[\x01a\x0FNV[a6\x80a6z`\x01a\x10\x04V[\x91a\x10\x04V[\x14_\x80a6GV[a6\xAE\x90a6\x94a4\xCEV[P_\x90a6\xA8a6\xA2a\x11\xD8V[\x92a,SV[\x90aD\x9EV[P\x90V[_\x7FNot registered operator\0\0\0\0\0\0\0\0\0\x91\x01RV[a6\xE6`\x17` \x92a\t\xC5V[a6\xEF\x81a6\xB2V[\x01\x90V[a7\x08\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra6\xD9V[\x90V[\x15a7\x12WV[a7\x1Aa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a70`\x04\x82\x01a6\xF3V[\x03\x90\xFD[\x90a7f\x94\x93\x92\x91a7aa7\\a7Ua7P\x84`\x06a2\xC5V[a2\xDBV[3\x90ad8V[a7\x0BV[a7hV[V[\x91a7z\x94\x92\x93\x913\x91\x92\x93\x94ae\xE7V[V[\x90a7\x89\x94\x93\x92\x91a74V[V[\x90a7\xABa7\xA6a7\xB0\x93a7\x9Ea5\xFDV[P`\x06a2\xC5V[a2\xDBV[ad8V[\x90V[_\x90V[a7\xD9a7\xDF\x92a7\xD4`\x01\x93a7\xCCa7\xB3V[P`\x03a\x0EsV[a\x0E\xBDV[\x01a\x0FNV[\x90V[a7\xEB\x90a\x0E\xA5V[\x90V[_\x7FInternal only\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a8\"`\r` \x92a\t\xC5V[a8+\x81a7\xEEV[\x01\x90V[a8D\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra8\x15V[\x90V[\x15a8NWV[a8Va\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a8l`\x04\x82\x01a8/V[\x03\x90\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a8\x88W` \x80\x91\x02\x01\x90V[a\x08\xB3V[\x90a8\x9Fa8\x9A\x83a8pV[a\x15\x8AV[\x91\x82RV[6\x907V[\x90a8\xCEa8\xB6\x83a8\x8DV[\x92` \x80a8\xC4\x86\x93a8pV[\x92\x01\x91\x03\x90a8\xA4V[V[\x90a8\xDA\x82a\x0CBV[\x81\x10\x15a8\xEBW` \x80\x91\x02\x01\x01\x90V[a\x07nV[\x90V[` \x01\x90V[Q\x90V[Q\x90V[\x90a9\x0B\x82a8\xFDV[\x81\x10\x15a9\x1CW` \x80\x91\x02\x01\x01\x90V[a\x07nV[\x90a9+\x90a\r\xACV[\x90RV[``\x90V[\x90V[` \x91\x81R\x01\x90V[\x90_\x92\x91\x80T\x90a9Za9S\x83a\x07\xD4V[\x80\x94a97V[\x91`\x01\x81\x16\x90\x81_\x14a9\xB1WP`\x01\x14a9uW[PPPV[a9\x82\x91\x92\x93\x94Pa\x07\x8FV[\x91_\x92[\x81\x84\x10a9\x99WPP\x01\x90_\x80\x80a9pV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a9\x86V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a9pV[\x90a9\xD6\x91a9@V[\x90V[\x90a9\xF9a9\xF2\x92a9\xE9a\x03\x92V[\x93\x84\x80\x92a9\xCCV[\x03\x83a\x08\xC7V[V[a:\x04\x90a9\xD9V[\x90V[a:\x11\x90Qa\r\xACV[\x90V[a:\x1E\x90Qa\x05DV[\x90V[_\x7FValue out of bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a:U`\x13` \x92a\t\xC5V[a:^\x81a:!V[\x01\x90V[a:za:\x88\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra\t\xD9V[\x90` \x81\x83\x03\x91\x01Ra:HV[\x90V[\x92\x91` a:\xA7a:\xAF\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\t\xD9V[\x94\x01\x90a\x05GV[V[\x90_\x92\x91\x80T\x90a:\xCBa:\xC4\x83a\x07\xD4V[\x80\x94a\t\xC5V[\x91`\x01\x81\x16\x90\x81_\x14a;\"WP`\x01\x14a:\xE6W[PPPV[a:\xF3\x91\x92\x93\x94Pa\x08\x07V[\x91_\x92[\x81\x84\x10a;\nWPP\x01\x90_\x80\x80a:\xE1V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a:\xF7V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a:\xE1V[_\x7FRequired metric missing\0\0\0\0\0\0\0\0\0\x91\x01RV[a;q`\x17` \x92a\t\xC5V[a;z\x81a;=V[\x01\x90V[a;\x96a;\xA4\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra:\xB1V[\x90` \x81\x83\x03\x91\x01Ra;dV[\x90V[\x92\x93\x90\x93a;\xCF3a;\xC9a;\xC3a;\xBE0a7\xE2V[a\x03\xDFV[\x91a\x03\xDFV[\x14a8GV[a;\xE3a;\xDE`\x08\x86\x90a\x07XV[a.$V[\x94a;\xED\x82a8\xA9V[\x94a;\xF7_a,SV[[\x80a<\x0Ba<\x05\x86a\x05DV[\x91a\x05DV[\x10\x15a<^Wa<Y\x90a<Ta</_a<'\x8A\x85\x90a8\xD0V[Q\x01Qa8\xF0V[a<Aa<;\x82a8\xF9V[\x91a8\xF3V[ a<O\x8A\x91\x84\x90\x92a9\x01V[a9!V[a,oV[a;\xF8V[P\x91\x94\x90\x92\x95a<m\x81a.0V[a<\x7Fa<y_a,SV[\x91a\x05DV[\x11\x96a<\x89a9/V[\x90\x88aA\tW[a<\x99_a,SV[[\x80a<\xADa<\xA7\x8Ba\x05DV[\x91a\x05DV[\x10\x15a?lW`\x01_\x8Ba=\xA0W[P\x90\x88\x87\x89a<\xD2\x94a<\xD7W[PPPa,oV[a<\x9AV[\x82_a=\x15a=\ra=\x1E\x94a=\x08a=\0` a<\xF9a=#\x9B\x8D\x90a8\xD0V[Q\x01a:\x14V[\x97`\ta\x1B\xD5V[a\x1B\xEBV[\x92\x87\x90a8\xD0V[Q\x01Q\x90a\x1C|V[a/\xA9V[\x88\x87\x89\x90a=M` a=F_a=;\x87\x89\x90a8\xD0V[Q\x01Q\x95\x87\x90a8\xD0V[Q\x01a:\x14V[a=\x80a=z\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD\x93a\x07<V[\x93a\x0E\xB1V[\x93a=\x95a=\x8Ca\x03\x92V[\x92\x83\x92\x83a:\x8BV[\x03\x90\xA3\x88\x87\x89a<\xCAV[\x9A\x90\x95\x92\x91\x99a=\xAF_a,SV[[\x80a=\xCBa=\xC5a=\xC0\x8Aa.0V[a\x05DV[\x91a\x05DV[\x10\x15a?VWa=\xE3a=\xDE\x8D\x87a9\x01V[a:\x07V[a>\x07a>\x01a=\xFCa=\xF7\x8A\x86\x90a9\x01V[a:\x07V[a\r\xACV[\x91a\r\xACV[\x14a>\x1AWa>\x15\x90a,oV[a=\xB0V[\x8A\x91\x9B\x92\x9CP\x89a<\xD2\x94\x95\x98\x8A\x92`\x01\x90\x8Aa>D` a>=\x89\x8B\x90a8\xD0V[Q\x01a:\x14V[a>la>fa>a`\x01a>Z\x86\x88\x90a.4V[P\x01a\t.V[a\x05DV[\x91a\x05DV[\x10\x91\x88\x88\x84\x15a?\x0CW[PPPPa>\xA1W[a>\x8B\x90[\x15a\x04\xB2V[a>\x9AW[\x93\x94PPPa<\xBCV[P_a>\x90V[\x90P\x82\x82_a>\xB1\x87\x89\x90a8\xD0V[Q\x01Q\x91a>\xFDa>\xEBa>\xE5\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07<V[\x93a\x0E\xB1V[\x93a>\xF4a\x03\x92V[\x91\x82\x91\x82a:bV[\x03\x90\xA3a>\x8B_\x91\x90Pa>\x80V[a?L\x93\x94Pa?:a?F\x93a?4` a?-a?A\x96`\x02\x96a8\xD0V[Q\x01a:\x14V[\x96a.4V[P\x01a\t.V[a\x05DV[\x91a\x05DV[\x11\x8A_\x88\x88a>wV[P\x99\x90\x9A\x87\x89a<\xD2\x94\x95\x98a>\x8B\x8D\x94a>\x85V[P\x97PP\x92\x93P\x93Pa?~_a,SV[\x93[\x84a?\x9Ba?\x95a?\x90\x86a.0V[a\x05DV[\x91a\x05DV[\x10\x15aA\x02Wa?\xC1a?\xBB`\x03a?\xB4\x86\x89\x90a.4V[P\x01a\tUV[\x15a\x04\xB2V[a@\xF7Wa?\xE3a?\xDE_a?\xD7\x86\x89\x90a.4V[P\x01a94V[a9\xFBV[a?\xF5a?\xEF\x82a8\xF9V[\x91a8\xF3V[ \x90_\x96a@\x02_a,SV[[\x80a@\x1Ea@\x18a@\x13\x86a8\xFDV[a\x05DV[\x91a\x05DV[\x10\x15a@\xE5Wa@7a@2\x84\x83\x90a9\x01V[a:\x07V[a@Ia@C\x86a\r\xACV[\x91a\r\xACV[\x14a@\\Wa@W\x90a,oV[a@\x03V[P\x95\x90\x96Pa@}\x91Pa@r`\x01[\x15a\x04\xB2V[a@\x84W[[a,oV[\x93\x94a?\x80V[\x82\x85_a@\x92\x87\x85\x90a.4V[P\x01\x91a@\xDDa@\xCBa@\xC5\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07<V[\x93a\x0E\xB1V[\x93a@\xD4a\x03\x92V[\x91\x82\x91\x82a;~V[\x03\x90\xA3a@wV[P\x95\x90\x96a@}\x92Pa@r\x90a@lV[\x94\x93a@}\x90a@xV[PPPPPV[\x96\x93\x90PaA#aA\x1E\x83\x97\x94\x99\x96\x93a.0V[a8\xA9V[\x97aA-_a,SV[[\x80aAIaACaA>\x8Ba.0V[a\x05DV[\x91a\x05DV[\x10\x15aA\xA3WaA\x9E\x90aA\x99aAtaAo_aAh\x8D\x86\x90a.4V[P\x01a94V[a9\xFBV[aA\x86aA\x80\x82a8\xF9V[\x91a8\xF3V[ aA\x94\x8D\x91\x84\x90\x92a9\x01V[a9!V[a,oV[aA.V[P\x92\x95\x91\x94\x97\x90\x93\x96a<\x90V[aA\xB9accV[aA\xC1aA\xC3V[V[aA\xD4aA\xCF_a%zV[ajYV[V[aA\xDEaA\xB1V[V[aA\xEA`\xA0a\x15\x8AV[\x90V[_\x90V[_\x90V[_\x90V[aB\x01aA\xE0V[\x90` \x80\x80\x80\x80\x86aB\x11aA\xEDV[\x81R\x01aB\x1Ca&\xE1V[\x81R\x01aB'a&\xE5V[\x81R\x01aB2aA\xF1V[\x81R\x01aB=aA\xF5V[\x81RPPV[aBKaA\xF9V[\x90V[\x90aBX\x90a\x05DV[\x90RV[\x90aBf\x90a\x03\xA4V[\x90RV[\x90aBt\x90a\x04\x9FV[\x90RV[\x90aB\x82\x90a\x10\x04V[\x90RV[\x90aC\x05aB\xFC`\x02aB\x97aA\xE0V[\x94aB\xAEaB\xA6_\x83\x01a\t.V[_\x88\x01aBNV[aB\xC6aB\xBD`\x01\x83\x01a\x0E\xF4V[` \x88\x01aB\\V[aB\xDEaB\xD5`\x01\x83\x01a\x0F!V[`@\x88\x01aBjV[aB\xF6aB\xED`\x01\x83\x01a\x0FNV[``\x88\x01aBxV[\x01a\x0FrV[`\x80\x84\x01a9!V[V[aC\x10\x90aB\x86V[\x90V[aC8\x91aC.aC3\x92aC&aBCV[P`\x03a\x0EsV[a\x0E\xBDV[aC\x07V[\x90V[_\x90V[\x90aCI\x90a\x07<V[_R` R`@_ \x90V[\x90aC_\x90a\x0E\xB1V[_R` R`@_ \x90V[aC\x90\x91aC\x86aC\x8B\x92aC~aC;V[P`\x0CaC?V[aCUV[a\x0E\xF4V[\x90V[aC\x9BajoV[aC\xA3a\\\xD1V[aC\xB5aC\xAF\x83a\x03\xDFV[\x91a\x03\xDFV[\x03aC\xC5WaC\xC3\x90ajYV[V[aC\xE0\x90_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0B\x83V[\x03\x90\xFD[aD\x03aC\xFEaD\x08\x92aC\xF6a'?V[P`\x04a2\xC5V[a2\xDBV[ac\xB1V[\x90V[aD\x15\x90Qa\x04\x9FV[\x90V[aD,aD'aD1\x92a%[V[a\x079V[a\x04\x9FV[\x90V[aD>\x90Qa\x03\xA4V[\x90V[aDUaDPaDZ\x92a\x03\xA4V[a\x079V[a\x05DV[\x90V[aDqaDlaDv\x92a\x04\x9FV[a\x079V[a\x05DV[\x90V[aD\x88aD\x8E\x91\x93\x92\x93a\x05DV[\x92a\x05DV[\x82\x01\x80\x92\x11aD\x99WV[a(uV[\x90\x92\x91\x92aD\xAAa4\xCEV[PaD\xB3a'?V[PaD\xBD\x82abKV[\x93aD\xDAaD\xD5aD\xD0`\x05\x86\x90a2\xC5V[a2\xDBV[ac\xB1V[\x92aD\xE7` \x87\x01aD\x0BV[aD\xF9aD\xF3_aD\x18V[\x91a\x04\x9FV[\x14\x80\x15aE\xEBW[\x80\x15aE\xD0W[aE\xB6WaEB\x86aE<aE7` aE0aE+_aE\x9F\x9B\x9C\x9D\x01aD4V[aDAV[\x93\x01aD\x0BV[aD]V[\x90a(\x89V[\x91\x80aE]aEWaERa\x11\xD8V[a\x05DV[\x91a\x05DV[\x11_\x14aE\xB1WPaEma\x11\xD8V[[aEy\x84\x82\x90aDyV[aE\x8BaE\x85\x88a\x05DV[\x91a\x05DV[\x11_\x14aE\xA2WP\x84[\x90\x92\x90\x91\x92aj\xA5V[\x91V[aE\xAC\x90\x84aDyV[aE\x95V[aEnV[PPP\x91PaE\xCCaE\xC7_a,SV[a5\x0CV[\x91\x90V[P\x82aE\xE4aE\xDE\x86a\x05DV[\x91a\x05DV[\x10\x15aE\x08V[P\x83aE\xFFaE\xF9_a,SV[\x91a\x05DV[\x14aE\x01V[aF\x16\x90aF\x11accV[aF\x18V[V[aF#\x90`\na&+V[V[aF.\x90aF\x05V[V[_\x90V[aF<aF0V[PaFF_a%NV[\x90V[P\x90V[\x91\x90\x81\x10\x15aF]W` \x02\x01\x90V[a\x07nV[5aFl\x81a\x03\xEBV[\x90V[_\x80\xFD[`\xE0\x1B\x90V[_\x91\x03\x12aF\x83WV[a\x03\x9CV[\x91` aF\xA9\x92\x94\x93aF\xA2`@\x82\x01\x96_\x83\x01\x90a\n\xDBV[\x01\x90a\x0BvV[V[aF\xB3a\x03\x92V[=_\x82>=\x90\xFD[\x90\x92\x91\x92aF\xC8_a,SV[[\x80aF\xE6aF\xE0aF\xDB\x85\x89\x90aFIV[a\x05DV[\x91a\x05DV[\x10\x15aG\x95WaF\xF50a7\xE2V[\x90c\xBA\x1F\xB1\x03\x84aG\x10aG\x0B\x86\x8A\x86\x91aFMV[aFbV[\x93\x80;\x15aG\x90WaG5_\x80\x94aG@aG)a\x03\x92V[\x98\x89\x96\x87\x95\x86\x94aFsV[\x84R`\x04\x84\x01aF\x88V[\x03\x92Z\xF1\x91\x82\x15aG\x8BWaGZ\x92aG_W[Pa,oV[aF\xC9V[aG~\x90_=\x81\x11aG\x84W[aGv\x81\x83a\x08\xC7V[\x81\x01\x90aFyV[_aGTV[P=aGlV[aF\xABV[aFoV[PPP\x90PV[_\x7FNot slashing oracle\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aG\xD0`\x13` \x92a\t\xC5V[aG\xD9\x81aG\x9CV[\x01\x90V[aG\xF2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaG\xC3V[\x90V[\x15aG\xFCWV[aH\x04a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aH\x1A`\x04\x82\x01aG\xDDV[\x03\x90\xFD[_\x7FOperator unknown\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aHR`\x10` \x92a\t\xC5V[aH[\x81aH\x1EV[\x01\x90V[aHt\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaHEV[\x90V[\x15aH~WV[aH\x86a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aH\x9C`\x04\x82\x01aH_V[\x03\x90\xFD[\x90V[aH\xB7aH\xB2aH\xBC\x92a\x05DV[a\x079V[a\x03\xA4V[\x90V[\x90aH\xD2g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x91a&\x08V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90aH\xF4aH\xEFaH\xFB\x92a\x07<V[aH\xDCV[\x82TaH\xBFV[\x90UV[\x91\x90aI\x19\x81aI\x12\x81aI\x1E\x95a\t\xC5V[\x80\x95a\x15\xEBV[a\x08\xA9V[\x01\x90V[\x90\x91aI9\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaH\xFFV[\x90V[aIa3aI[aIUaIP`\na%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14aG\xF5V[aI\x87aI\x82aI{aIv`\x05\x85\x90a2\xC5V[a2\xDBV[\x84\x90ad8V[aHwV[aI\xB3aI\xA8aI\xA3aI\x9C`\x03\x85\x90a\x0EsV[\x85\x90a\x0E\xBDV[aH\xA0V[`\x01`\x03\x91\x01a3\x12V[aI\xD1aI\xCAaI\xC5`\x04\x84\x90a2\xC5V[a2\xDBV[\x83\x90ak\xC1V[PaI\xF9aI\xDEBaH\xA3V[aI\xF4aI\xED`\x0C\x85\x90aC?V[\x85\x90aCUV[aH\xDFV[\x90\x91\x92aJ/aJ)\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07<V[\x93a\x0E\xB1V[\x93aJDaJ;a\x03\x92V[\x92\x83\x92\x83aI\"V[\x03\x90\xA3V[aJS`\x80a\x15\x8AV[\x90V[aJa\x916\x91a\x15\xF6V[\x90V[RV[\x90aJq\x90a\x04\xB2V[\x90RV[Q\x90V[\x90aJ\x83\x81a\t\xC1V[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11aKCWaJ\xA7\x82aJ\xA1\x85Ta\x07\xD4V[\x85a.`V[` \x90`\x1F\x83\x11`\x01\x14aJ\xDBW\x91\x80\x91aJ\xCA\x93_\x92aJ\xCFW[PPa)\x98V[\x90U[V[\x90\x91P\x01Q_\x80aJ\xC3V[`\x1F\x19\x83\x16\x91aJ\xEA\x85a\x08\x07V[\x92_[\x81\x81\x10aK+WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10aK\x11W[PPP\x02\x01\x90UaJ\xCDV[aK!\x91\x01Q`\x1F\x84\x16\x90a)\x83V[\x90U_\x80\x80aK\x05V[\x91\x93` `\x01\x81\x92\x87\x87\x01Q\x81U\x01\x95\x01\x92\x01aJ\xEDV[a\x08\xB3V[\x90aKR\x91aJyV[V[aK^\x90Qa\x04\xB2V[\x90V[\x90aK\xBE```\x03aK\xC4\x94aK\x84_\x82\x01aK~_\x88\x01aJuV[\x90aKHV[aK\x9D`\x01\x82\x01aK\x97` \x88\x01a:\x14V[\x90a/\xA9V[aK\xB6`\x02\x82\x01aK\xB0`@\x88\x01a:\x14V[\x90a/\xA9V[\x01\x92\x01aKTV[\x90a/\xFBV[V[\x91\x90aK\xD7WaK\xD5\x91aKaV[V[a+4V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15aL\x0CW\x82aL\x04\x91`\x01aL\n\x95\x01\x81Ua.4V[\x90aK\xC6V[V[a\x08\xB3V[aM/\x95aM\x18\x84\x96aM\x0FaM\x07aL\xF3aL\xEEaM!\x97aL\x94aLtaLnaM*\x9D\x8D\x9F\x9DaLi3aLcaL]aLXaLS`\x07\x8C\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14a'\xC6V[a-\x0CV[\x90a-\x0FV[aL\x8DaL\x87aL\x82a\x17\xEFV[a\x05DV[\x91a\x05DV[\x11\x15a-lV[aL\xB1\x86aL\xAAaL\xA4\x8Da\x05DV[\x91a\x05DV[\x10\x15a-\xFBV[aL\xE7aL\xC8aL\xC3`\x08\x84\x90a\x07XV[a\x07\x82V[aL\xE1aL\xDBaL\xD6a\x14;V[a\x05DV[\x91a\x05DV[\x10a(LV[`\x08a\x07XV[a.$V[\x98\x99\x96\x92\x94\x96aM\x01aJIV[\x9AaJVV[_\x8A\x01aJdV[` \x88\x01aBNV[`@\x86\x01aBNV[``\x84\x01aJgV[aK\xDCV[V[aM_\x90aMZaMUaMNaMI\x84`\x06a2\xC5V[a2\xDBV[3\x90ad8V[a7\x0BV[aN@V[V[_\x7FCannot go online while slashed\0\0\x91\x01RV[aM\x95`\x1E` \x92a\t\xC5V[aM\x9E\x81aMaV[\x01\x90V[aM\xB7\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaM\x88V[\x90V[`@\x1B\x90V[\x90aM\xD4h\xFF\0\0\0\0\0\0\0\0\x91aM\xBAV[\x91\x81\x19\x16\x91\x16\x17\x90V[aM\xF2aM\xEDaM\xF7\x92a\x04\x9FV[a\x079V[a\x04\x9FV[\x90V[\x90V[\x90aN\x12aN\raN\x19\x92aM\xDEV[aM\xFAV[\x82TaM\xC0V[\x90UV[\x91` aN>\x92\x94\x93aN7`@\x82\x01\x96_\x83\x01\x90a\x10\x1CV[\x01\x90a\x10\x1CV[V[aN^aNYaNR`\x03\x84\x90a\x0EsV[3\x90a\x0E\xBDV[aH\xA0V[\x90aNk`\x01\x83\x01a\x0FNV[\x91\x82aN\x80aNz`\x03a\x10\x04V[\x91a\x10\x04V[\x14aO\xA4W\x82aN\x98aN\x92_a\x10\x04V[\x91a\x10\x04V[\x14\x80\x15aO\x89W[aO\x84WaN\xC7\x90aN\xB5`\x01\x80\x83\x01a3\x12V[`\x01aN\xC0_aD\x18V[\x91\x01aM\xFDV[aN\xE5aN\xDEaN\xD9`\x04\x84\x90a2\xC5V[a2\xDBV[3\x90ac)V[P\x803aO\x1BaO\x15\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07<V[\x91a\x0E\xB1V[\x91aO$a\x03\x92V[\x80aO.\x81a\x04;V[\x03\x90\xA3\x903\x90\x91`\x01aOjaOd\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07<V[\x93a\x0E\xB1V[\x93aO\x7FaOva\x03\x92V[\x92\x83\x92\x83aN\x1DV[\x03\x90\xA3V[PPPV[P\x82aO\x9EaO\x98`\x01a\x10\x04V[\x91a\x10\x04V[\x14aN\xA0V[aO\xACa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aO\xC2`\x04\x82\x01aM\xA2V[\x03\x90\xFD[aO\xCF\x90aM1V[V[_\x7FNot authorized\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aP\x05`\x0E` \x92a\t\xC5V[aP\x0E\x81aO\xD1V[\x01\x90V[aP'\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaO\xF8V[\x90V[\x15aP1WV[aP9a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aPO`\x04\x82\x01aP\x12V[\x03\x90\xFD[\x90V[aPjaPeaPo\x92aPSV[a\x079V[a\x03\xA4V[\x90V[_\x7FInterval too short\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aP\xA6`\x12` \x92a\t\xC5V[aP\xAF\x81aPrV[\x01\x90V[aP\xC8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaP\x99V[\x90V[\x15aP\xD2WV[aP\xDAa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aP\xF0`\x04\x82\x01aP\xB3V[\x03\x90\xFD[\x90V[aQ\x0BaQ\x06aQ\x10\x92aP\xF4V[a\x079V[a\x04\x9FV[\x90V[_\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0\x91\x01RV[aQG`\x17` \x92a\t\xC5V[aQP\x81aQ\x13V[\x01\x90V[aQi\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaQ:V[\x90V[\x15aQsWV[aQ{a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aQ\x91`\x04\x82\x01aQTV[\x03\x90\xFD[aQ\x9F``a\x15\x8AV[\x90V[\x90aQ\xB7aQ\xB2aQ\xBE\x92a/\xECV[a/\xF8V[\x82Ta2\xE4V[\x90UV[\x90aR\x04`@_aR\n\x94aQ\xE4\x82\x82\x01aQ\xDE\x84\x88\x01aD4V[\x90aH\xDFV[aQ\xFC\x82\x82\x01aQ\xF6` \x88\x01aD\x0BV[\x90aM\xFDV[\x01\x92\x01aKTV[\x90aQ\xA2V[V[\x90aR\x16\x91aQ\xC2V[V[\x91` aR9\x92\x94\x93aR2`@\x82\x01\x96_\x83\x01\x90a\n\xDBV[\x01\x90a\x0F\xD4V[V[3aRnaRh\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xDFV[\x91a\x03\xDFV[\x14\x80\x15aSZW[aR\x7F\x90aP*V[aR\x9D\x82aR\x96aR\x90`<aPVV[\x91a\x03\xA4V[\x10\x15aP\xCBV[aR\xBB\x83aR\xB4aR\xAE`\x01aP\xF7V[\x91a\x04\x9FV[\x10\x15aQlV[aS\x14\x82aS\x03\x85aR\xFAaR\xDC_aR\xD6`\x02\x89\x90a\"\x18V[\x01a\"BV[\x91aR\xF1aR\xE8aQ\x95V[\x95_\x87\x01aB\\V[` \x85\x01aBjV[`@\x83\x01aJgV[aS\x0F`\x02\x84\x90a\"\x18V[aR\x0CV[\x90\x91aS@\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x92a\x07<V[\x92aSUaSLa\x03\x92V[\x92\x83\x92\x83aR\x18V[\x03\x90\xA2V[PaR\x7F3aS\x84aS~aSyaSt`\x07\x87\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14\x90PaRvV[aS\x9BaS\xA1\x91\x93\x92\x93a\x05DV[\x92a\x05DV[\x82\x03\x91\x82\x11aS\xACWV[a(uV[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[aS\xD1aS\xD7\x91a\x05DV[\x91a\x05DV[\x90\x81\x15aS\xE2W\x04\x90V[aS\xB1V[aS\xFBaS\xF6aT\0\x92a\x05DV[a\x079V[a\x04\x9FV[\x90V[aT\x17aT\x12aT\x1C\x92a%[V[a\x079V[a\x03\xA4V[\x90V[aT=aT8aT1`\x03\x84\x90a\x0EsV[\x84\x90a\x0E\xBDV[aH\xA0V[\x90aTG\x81abKV[aTS`\x01\x84\x01a\x0FNV[aTfaT``\x03a\x10\x04V[\x91a\x10\x04V[\x14aVzWaTv_\x84\x01a\t.V[aT\x88aT\x82_a,SV[\x91a\x05DV[\x14aVtWaT\xBEaT\xA5BaT\x9F_\x87\x01a\t.V[\x90aS\x8CV[aT\xB8aT\xB3_\x85\x01aD4V[aDAV[\x90aS\xC5V[\x80aT\xD2aT\xCC`\xFFaD]V[\x91a\x05DV[\x11_\x14aVfWP`\xFF[\x90\x81aT\xFCaT\xF6aT\xF1`\x01\x88\x01a\x0F!V[a\x04\x9FV[\x91a\x04\x9FV[\x11aU\tW[PPPPPV[aU\x16\x82`\x01\x86\x01aM\xFDV[aU+aU\"_aT\x03V[`\x01\x86\x01aH\xDFV[aUIaUCaU>` \x85\x94\x01aD\x0BV[a\x04\x9FV[\x91a\x04\x9FV[\x10\x15\x80aV?W[aU\\W[\x80aU\x02V[aUwaUk`\x01\x85\x01a\x0FNV[\x93`\x01`\x02\x91\x01a3\x12V[aU\x95aU\x8EaU\x89`\x04\x85\x90a2\xC5V[a2\xDBV[\x85\x90ak\xC1V[P\x81\x90\x84\x90\x91aU\xE3aU\xD1aU\xCB\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM\x93a\x07<V[\x93a\x0E\xB1V[\x93aU\xDAa\x03\x92V[\x91\x82\x91\x82a\x14\xF5V[\x03\x90\xA3\x91\x90\x91`\x02aV\x1EaV\x18\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07<V[\x93a\x0E\xB1V[\x93aV3aV*a\x03\x92V[\x92\x83\x92\x83aN\x1DV[\x03\x90\xA3_\x80\x80\x80aUVV[PaVL`\x01\x84\x01a\x0FNV[aV_aVY`\x02a\x10\x04V[\x91a\x10\x04V[\x14\x15aUQV[aVo\x90aS\xE7V[aT\xDDV[PPPPV[PPPPV[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11aV\x9DW` \x80\x91\x02\x01\x90V[a\x08\xB3V[\x90aV\xB4aV\xAF\x83aV\x85V[a\x15\x8AV[\x91\x82RV[aV\xC3`\x80a\x15\x8AV[\x90V[\x90aW-aW$`\x03aV\xD7aV\xB9V[\x94aV\xEEaV\xE6_\x83\x01a\x08\xF0V[_\x88\x01aJdV[aW\x06aV\xFD`\x01\x83\x01a\t.V[` \x88\x01aBNV[aW\x1EaW\x15`\x02\x83\x01a\t.V[`@\x88\x01aBNV[\x01a\tUV[``\x84\x01aJgV[V[aW8\x90aV\xC6V[\x90V[\x90aWE\x82a\x07\x82V[aWN\x81aV\xA2V[\x92aW\\` \x85\x01\x91a\x07\x86V[_\x91[\x83\x83\x10aWlWPPPPV[`\x04` `\x01\x92aW|\x85aW/V[\x81R\x01\x92\x01\x92\x01\x91\x90aW_V[aW\x93\x90aW;V[\x90V[aW\xADaW\xB2\x91aW\xA5aV\x80V[P`\x08a\x07XV[aW\x8AV[\x90V[aW\xE3\x90aW\xDEaW\xD9aW\xD2aW\xCD\x84`\x06a2\xC5V[a2\xDBV[3\x90ad8V[a7\x0BV[aX>V[V[_\x7FCannot go offline while slashed\0\x91\x01RV[aX\x19`\x1F` \x92a\t\xC5V[aX\"\x81aW\xE5V[\x01\x90V[aX;\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaX\x0CV[\x90V[aX\\aXWaXP`\x03\x84\x90a\x0EsV[3\x90a\x0E\xBDV[aH\xA0V[\x90aXi`\x01\x83\x01a\x0FNV[\x91\x82aX~aXx`\x03a\x10\x04V[\x91a\x10\x04V[\x14aY\x04WaX\x92\x90`\x01`\x04\x91\x01a3\x12V[aX\xB0aX\xA9aX\xA4`\x04\x84\x90a2\xC5V[a2\xDBV[3\x90ak\xC1V[P\x903\x90\x91`\x04aX\xEAaX\xE4\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07<V[\x93a\x0E\xB1V[\x93aX\xFFaX\xF6a\x03\x92V[\x92\x83\x92\x83aN\x1DV[\x03\x90\xA3V[aY\x0Ca\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aY\"`\x04\x82\x01aX&V[\x03\x90\xFD[aY/\x90aW\xB5V[V[\x90aYe\x96\x95\x94\x93\x92\x91aY`aY[aYTaYO\x84`\x06a2\xC5V[a2\xDBV[3\x90ad8V[a7\x0BV[a[fV[V[`\xC0\x1B\x90V[aYv\x90aYgV[\x90V[aY\x85aY\x8A\x91a\x03\xA4V[aYmV[\x90RV[`\xF8\x1B\x90V[aY\x9D\x90aY\x8EV[\x90V[aY\xACaY\xB1\x91a\x04\x9FV[aY\x94V[\x90RV[\x90P\x90V[\x90\x91\x82aY\xCA\x81aY\xD1\x93aY\xB5V[\x80\x93a\x15\xEBV[\x01\x90V[`\x08`\x01\x93aY\xF9\x82\x84aY\xF1aZ\x01\x96aZ\x08\x9C\x9A\x98aYyV[\x01\x80\x92aYyV[\x01\x80\x92aY\xA0V[\x01\x91aY\xBAV[\x90V[_\x7F\x19Ethereum Signed Message:\n32\0\0\0\0\x91\x01RV[aZ>`\x1C\x80\x92a\x1C\x01V[aZG\x81aZ\x0BV[\x01\x90V[\x90V[aZZaZ_\x91a\r\xACV[aZKV[\x90RV[\x90aZyaZr` \x93aZ2V[\x80\x92aZNV[\x01\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11aZ\x9BWaZ\x97` \x91a\x08\xA9V[\x01\x90V[a\x08\xB3V[\x90\x92\x91\x92aZ\xB5aZ\xB0\x82aZ}V[a\x15\x8AV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11aZ\xD1WaZ\xCF\x92a\x15\xEBV[V[a\x15\xC4V[aZ\xE1\x916\x91aZ\xA0V[\x90V[_\x7FInvalid signature\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a[\x18`\x11` \x92a\t\xC5V[a[!\x81aZ\xE4V[\x01\x90V[a[:\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra[\x0BV[\x90V[\x15a[DWV[a[La\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a[b`\x04\x82\x01a[%V[\x03\x90\xFD[\x90\x94a\\\x04a\\\x1C\x91a[\xFEa\\'\x99a[\xD6a[\xE5\x88a[\xAF\x8Da[\xA0\x8D\x8F\x8D\x93\x95\x91\x90\x91a[\x94a\x03\x92V[\x96\x87\x95` \x87\x01aY\xD5V[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xC7V[a[\xC1a[\xBB\x82a8\xF9V[\x91a8\xF3V[ a[\xCAa\x03\x92V[\x92\x83\x91` \x83\x01aZcV[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xC7V[a[\xF7a[\xF1\x82a8\xF9V[\x91a8\xF3V[ \x92aZ\xD6V[\x90ak\xFBV[a\\\x16a\\\x103a\x03\xDFV[\x91a\x03\xDFV[\x14a[=V[\x933\x91\x92\x93\x94ae\xE7V[V[\x90a\\8\x96\x95\x94\x93\x92\x91aY1V[V[\x90\x91\x82a\\J\x81a\\Q\x93a\x1C\x01V[\x80\x93a\x15\xEBV[\x01\x90V[a\\f\x90` \x94\x93a\\m\x93a\\:V[\x80\x92a\x1C2V[\x01\x90V[\x90\x91a\\\x88\x90a\\\x7Fa\x03\x92V[\x93\x84\x93\x84a\\UV[\x03\x90 \x90V[\x90\x91a\\\x99\x92a\\qV[\x90V[\x92a\\\xC1a\\\xC9\x93\x92a\\\xBCa\\\xCE\x96a\\\xB4a'?V[P`\ta\x1B\xD5V[a\x1B\xEBV[\x91\x90\x91a\\\x8EV[a\t.V[\x90V[a\\\xD9aF0V[Pa\\\xE4`\x01a%NV[\x90V[a\\\xF1\x90Qa\x10\x04V[\x90V[\x90V[a]\x0Ba]\x06a]\x10\x92a\\\xF4V[a\x079V[a\x05DV[\x90V[` \x7Fl\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x7FOperator not eligible for remova_\x82\x01R\x01RV[a]m`!`@\x92a\t\xC5V[a]v\x81a]\x13V[\x01\x90V[a]\x8F\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra]`V[\x90V[\x15a]\x99WV[a]\xA1a\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80a]\xB7`\x04\x82\x01a]zV[\x03\x90\xFD[\x90a^la^ga^q\x933a]\xECa]\xE6a]\xE1a]\xDC`\x07\x86\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14\x80\x15a_*W[a]\xFD\x90aP*V[a^\x1Ba^\x16a^\x0F`\x03\x84\x90a\x0EsV[\x86\x90a\x0E\xBDV[aC\x07V[a^'``\x82\x01a\\\xE7V[a^:a^4`\x03a\x10\x04V[\x91a\x10\x04V[\x03a^tW[Pa^_a^Xa^S`\x05\x84\x90a2\xC5V[a2\xDBV[\x85\x90ak\xC1V[P`\x04a2\xC5V[a2\xDBV[ak\xC1V[PV[a^\xF0\x90a^\xC4a^\xB4a^\x87\x85abKV[a^\xAEa^\xA9` a^\xA2a^\x9D_\x86\x01aD4V[aDAV[\x93\x01aD\x0BV[aD]V[\x90a(\x89V[a^\xBE`\na\\\xF7V[\x90a(\x89V[a^\xCF_\x83\x01a:\x14V[a^\xE1a^\xDB_a,SV[\x91a\x05DV[\x11\x91\x82a^\xF6W[PPa]\x92V[_a^@V[a_!\x91\x92Pa_\x15a_\x1B\x91a_\x0F_B\x92\x01a:\x14V[\x90aS\x8CV[\x92a\x05DV[\x91a\x05DV[\x10\x15_\x80a^\xE9V[Pa]\xFD3a_Ha_Ba_=aF4V[a\x03\xDFV[\x91a\x03\xDFV[\x14\x90Pa]\xF4V[\x90a_za_\x7F\x91a_`a5\xFDV[Pa_ua_m\x85abKV[\x94`\x03a\x0EsV[a\x0E\xBDV[aC\x07V[a_\x8A_\x82\x01a:\x14V[a_\x9Ca_\x96_a,SV[\x91a\x05DV[\x14a_\xD7Wa_\xCDa_\xC8_a_\xC1a_\xD3\x94a_\xBB\x83B\x92\x01a:\x14V[\x90aS\x8CV[\x94\x01aD4V[aDAV[\x91a\x05DV[\x10\x90V[PP_\x90V[a_\xEE\x90a_\xE9accV[a_\xF0V[V[a_\xFB\x81`\x01a&+V[a`\x03aF4V[\x90a`7a`1\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0\x93a\x0E\xB1V[\x91a\x0E\xB1V[\x91a`@a\x03\x92V[\x80a`J\x81a\x04;V[\x03\x90\xA3V[a`X\x90a_\xDDV[V[_a`\x99a`\x9F\x93a`\x913a`\x8Ba`\x85a`\x80a`{`\x07\x8A\x90a\x12pV[a%NV[a\x03\xDFV[\x91a\x03\xDFV[\x14a'\xC6V[\x92`\x02a\"\x18V[\x01aQ\xA2V[V[_\x7FNot registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a`\xD5`\x0E` \x92a\t\xC5V[a`\xDE\x81a`\xA1V[\x01\x90V[a`\xF7\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra`\xC8V[\x90V[\x15aa\x01WV[aa\ta\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80aa\x1F`\x04\x82\x01a`\xE2V[\x03\x90\xFD[aa_3aaYaaS\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xDFV[\x91a\x03\xDFV[\x14a%\x11V[aa\x85aa\x80aayaat`\x06\x85\x90a2\xC5V[a2\xDBV[\x84\x90ak\xC1V[a`\xFAV[aa\xA3aa\x9Caa\x97`\x04\x84\x90a2\xC5V[a2\xDBV[\x83\x90ak\xC1V[P\x90aa\xD8aa\xD2\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E\x93a\x07<V[\x91a\x0E\xB1V[\x91aa\xE1a\x03\x92V[\x80aa\xEB\x81a\x04;V[\x03\x90\xA3V[\x90ab=ab4_ab\0a&\xD4V[\x94ab\x17ab\x0F\x83\x83\x01a\x0E\xF4V[\x83\x88\x01aB\\V[ab.ab%\x83\x83\x01a\x0F!V[` \x88\x01aBjV[\x01a\"BV[`@\x84\x01aJgV[V[abH\x90aa\xF0V[\x90V[abbabg\x91abZa'\x1FV[P`\x02a\"\x18V[ab?V[abr_\x82\x01aD4V[ab\x84ab~_aT\x03V[\x91a\x03\xA4V[\x14ab\xCAW[ab\x96` \x82\x01aD\x0BV[ab\xA8ab\xA2_aD\x18V[\x91a\x04\x9FV[\x14ab\xB1W[\x90V[ab\xC5ab\xBCa\x14\xDDV[` \x83\x01aBjV[ab\xAEV[ab\xDDab\xD5a\n\xC2V[_\x83\x01aB\\V[ab\x8AV[ab\xEB\x90a\x0E\x89V[\x90V[ac\x02ab\xFDac\x07\x92a\x03\xD4V[a\x079V[a\x05DV[\x90V[ac\x1Eac\x19ac#\x92a\x05DV[a&\x08V[a\r\xACV[\x90V[\x90V[\x90ac[acUacPacK_ac`\x96acCa5\xFDV[P\x01\x94ab\xE2V[ab\xEEV[ac\nV[\x91ac&V[al\xC6V[\x90V[ackaF4V[ac\x84ac~acyajoV[a\x03\xDFV[\x91a\x03\xDFV[\x03ac\x8BWV[ac\xADac\x96ajoV[_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0B\x83V[\x03\x90\xFD[ac\xC8_ac\xCD\x92ac\xC1a'?V[P\x01ac&V[am)V[\x90V[ac\xDCac\xE1\x91a\t\x12V[a)\x0FV[\x90V[ac\xF8ac\xF3ac\xFD\x92a\x05DV[a\x079V[a\x03\xD4V[\x90V[ad+ad&ad5\x93ad!_ad0\x95ad\x1AaF0V[P\x01ac&V[am\x9BV[ac\xD0V[ac\xE4V[a\x0E\xA5V[\x90V[\x90adjaddad_adZ_ado\x96adRa5\xFDV[P\x01\x94ab\xE2V[ab\xEEV[ac\nV[\x91ac&V[am\xBCV[\x90V[_\x7FOperator is slashed\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[ad\xA6`\x13` \x92a\t\xC5V[ad\xAF\x81adrV[\x01\x90V[ad\xC8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rad\x99V[\x90V[\x15ad\xD2WV[ad\xDAa\x03\x92V[bF\x1B\xCD`\xE5\x1B\x81R\x80ad\xF0`\x04\x82\x01ad\xB3V[\x03\x90\xFD[ad\xFD\x90a\r\xACV[\x90V[ae\t\x90a\t\x12V[\x90V[\x90ae!ae\x1Cae(\x92ad\xF4V[ae\0V[\x82Ta/\x93V[\x90UV[ae5\x90a\x03\xA4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x14aeJW`\x01\x01\x90V[a(uV[\x90V[aefaeaaek\x92aeOV[a\x079V[a\x04\x9FV[\x90V[\x91` ae\x8F\x92\x94\x93ae\x88`@\x82\x01\x96_\x83\x01\x90a\x0F\xD4V[\x01\x90a\x05GV[V[ae\x9A\x90a\x0E\x89V[\x90V[ae\xA6\x90ae\x91V[\x90V[ae\xB2\x90a\x0E\xA5V[\x90V[`@\x90ae\xDEae\xE5\x94\x96\x95\x93\x96ae\xD4``\x84\x01\x98_\x85\x01\x90a\x0BvV[` \x83\x01\x90a\n\xDBV[\x01\x90a\n\xDBV[V[\x94\x92\x93\x91\x93af\naf\x05ae\xFE`\x03\x89\x90a\x0EsV[\x87\x90a\x0E\xBDV[aH\xA0V[\x93af\x14\x87abKV[\x93af>af$`\x01\x88\x01a\x0FNV[af7af1`\x03a\x10\x04V[\x91a\x10\x04V[\x14\x15ad\xCBV[af\\afUafP`\x05\x8B\x90a2\xC5V[a2\xDBV[\x88\x90ac)V[Pag1`@afn`\x01\x89\x01a\x0FNV[\x96af{B_\x8B\x01a/\xA9V[af\xA5af\x89\x85\x87\x90aZ\xD6V[af\x9Baf\x95\x82a8\xF9V[\x91a8\xF3V[ `\x02\x8B\x01ae\x0CV[af\xBAaf\xB1_aD\x18V[`\x01\x8B\x01aM\xFDV[af\xD8`\x01\x8A\x01af\xD2af\xCD\x82a\x0E\xF4V[ae,V[\x90aH\xDFV[af\xE0a7\xB3V[P\x85af\xF4af\xEE_aD\x18V[\x91a\x04\x9FV[\x14_\x14ai\xB5Wag\x0B_\x99[`\x01\x8B\x91\x01a3\x12V[\x87ag\x1Fag\x19`\x02a\x10\x04V[\x91a\x10\x04V[\x14\x80ai\x99W[ai+W[\x01aKTV[\x80ai\x07W[ah\xF1W[PP\x85\x91\x85\x91\x92Bag\x80agzagt\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x94a\x07<V[\x94a\x07<V[\x94a\x0E\xB1V[\x94ag\x95ag\x8Ca\x03\x92V[\x92\x83\x92\x83aenV[\x03\x90\xA4\x80ag\xABag\xA5\x84a\x10\x04V[\x91a\x10\x04V[\x03ah\x9BW[PPag\xBD`\x0Ba%NV[ag\xD7ag\xD1ag\xCC_a%zV[a\x03\xDFV[\x91a\x03\xDFV[\x03ag\xE1W[PPV[ag\xFBag\xF6ag\xF1`\x0Ba%NV[ae\x9DV[ae\xA9V[\x91c\xD4xS\xB6\x91\x90\x92ah\rBaH\xA3V[\x92\x81;\x15ah\x96W_ah3\x91ah>\x82\x96ah'a\x03\x92V[\x98\x89\x97\x88\x96\x87\x95aFsV[\x85R`\x04\x85\x01ae\xB5V[\x03\x92Z\xF1\x90\x81ahjW[P\x15_\x14aheW`\x01ah`W[[_\x80ag\xDDV[ahXV[ahYV[ah\x89\x90_=\x81\x11ah\x8FW[ah\x81\x81\x83a\x08\xC7V[\x81\x01\x90aFyV[_ahIV[P=ahwV[aFoV[\x83\x83\x91\x92ah\xD2ah\xCC\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07<V[\x93a\x0E\xB1V[\x93ah\xE7ah\xDEa\x03\x92V[\x92\x83\x92\x83aN\x1DV[\x03\x90\xA3_\x80ag\xB1V[ai\0\x91\x88\x91\x88\x90\x91\x92aq\xDDV[_\x80ag<V[Pai\x13\x81\x83\x90a-\x0FV[ai%ai\x1F_a,SV[\x91a\x05DV[\x11ag7V[aiHaiAai<\x8D`\x04a2\xC5V[a2\xDBV[\x8B\x90ac)V[P\x8A\x8Aai~aix\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07<V[\x91a\x0E\xB1V[\x91ai\x87a\x03\x92V[\x80ai\x91\x81a\x04;V[\x03\x90\xA3ag+V[P\x88ai\xAEai\xA8`\x02a\x10\x04V[\x91a\x10\x04V[\x14\x15ag&V[\x85ai\xC9ai\xC3`daeRV[\x91a\x04\x9FV[\x10_\x14ai\xDCWag\x0B`\x01\x99[ag\x01V[ag\x0B`\x01\x99ai\xF4\x8D\x8D\x8B\x90\x8B\x90\x8A\x92\x8C\x94an\x91V[ai\xD7V[\x91\x90`\x08aj\x19\x91\x02\x91aj\x13`\x01\x80`\xA0\x1B\x03\x84a(\xE6V[\x92a(\xE6V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x91\x90aj9aj4ajA\x93a\x0E\xB1V[a&(V[\x90\x83Tai\xF9V[\x90UV[ajW\x91ajQaF0V[\x91aj#V[V[ajm\x90ajh_`\x01ajEV[as\x9BV[V[ajwaF0V[P3\x90V[aj\x85\x90a\x05DV[_\x19\x81\x14aj\x93W`\x01\x01\x90V[a(uV[aj\xA2\x90Qa\x03\xDFV[\x90V[\x93\x91\x92\x93aj\xB1a4\xCEV[Paj\xC5aj\xC0\x85\x84\x90aS\x8CV[a5\x0CV[\x92aj\xCF_a,SV[\x92[\x80aj\xE4aj\xDE\x88a\x05DV[\x91a\x05DV[\x10\x15akRWak\x08ak\x01aj\xFC`\x05\x86\x90a2\xC5V[a2\xDBV[\x82\x90ad\0V[ak\x14\x84\x82\x8A\x91as\xFAV[ak(W[Pak#\x90a,oV[aj\xD1V[ak#\x91\x94akFakK\x92akA\x89\x91\x84\x90\x92a53V[a5SV[aj|V[\x93\x90ak\x19V[P\x94PP\x91Paka\x82a5\x0CV[\x92akk_a,SV[[\x80ak\x7Faky\x86a\x05DV[\x91a\x05DV[\x10\x15ak\xBBWak\xB6\x90ak\xB1ak\x9Fak\x9A\x86\x84\x90a53V[aj\x98V[ak\xAC\x88\x91\x84\x90\x92a53V[a5SV[a,oV[aklV[P\x91PPV[\x90ak\xF3ak\xEDak\xE8ak\xE3_ak\xF8\x96ak\xDBa5\xFDV[P\x01\x94ab\xE2V[ab\xEEV[ac\nV[\x91ac&V[auFV[\x90V[al\x1A\x91al\x11\x91al\x0BaF0V[PavsV[\x90\x92\x91\x92aw3V[\x90V[\x90V[_R` _ \x90V[T\x90V[al6\x81al)V[\x82\x10\x15alPWalH`\x01\x91al V[\x91\x02\x01\x90_\x90V[a\x07nV[\x91\x90alkalfals\x93ad\xF4V[ae\0V[\x90\x83Ta(\xEAV[\x90UV[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15al\xA7W\x82al\x9F\x91`\x01al\xA5\x95\x01\x81Ual-V[\x90alUV[V[a\x08\xB3V[T\x90V[\x90al\xBA\x90ad\xF4V[_R` R`@_ \x90V[al\xCEa5\xFDV[Pal\xE3al\xDD\x82\x84\x90am\xBCV[\x15a\x04\xB2V[_\x14am#Wam\x19am\x1E\x92am\x05al\xFE_\x85\x01al\x1DV[\x82\x90alwV[`\x01am\x12_\x85\x01al\xACV[\x93\x01al\xB0V[a/\xA9V[`\x01\x90V[PP_\x90V[_am=\x91am6a'?V[P\x01al\xACV[\x90V[_\x90V[_R` _ \x90V[amV\x81al\xACV[\x82\x10\x15ampWamh`\x01\x91amDV[\x91\x02\x01\x90_\x90V[a\x07nV[am\x85\x90`\x08am\x8A\x93\x02a\x0B2V[a\x0F[V[\x90V[\x90am\x98\x91TamuV[\x90V[am\xB9\x91_am\xB3\x92am\xACam@V[P\x01amMV[\x90am\x8DV[\x90V[am\xDA\x91`\x01am\xD5\x92am\xCEa5\xFDV[P\x01al\xB0V[a\t.V[am\xECam\xE6_a,SV[\x91a\x05DV[\x14\x15\x90V[an\x05an\0an\n\x92a\x11\xB9V[a\x079V[a\x04\x9FV[\x90V[an\x19an\x1F\x91a\x03\xA4V[\x91a\x03\xA4V[\x90\x03\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11an3WV[a(uV[_\x7FProtocol violation reported\0\0\0\0\0\x91\x01RV[anl`\x1B` \x92a\t\xC5V[anu\x81an8V[\x01\x90V[an\x8E\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ran_V[\x90V[\x93PP\x92Pan\xA9an\xA3`\xC8am\xF1V[\x91a\x04\x9FV[\x10\x15an\xB4W[PPV[an\xBDBaH\xA3V[an\xDBan\xD6an\xCF`\x0C\x85\x90aC?V[\x85\x90aCUV[a\x0E\xF4V[\x80an\xEEan\xE8_aT\x03V[\x91a\x03\xA4V[\x14\x90\x81\x15aotW[Pao\x03W[Pan\xB0V[ao\"\x90ao\x1Dao\x16`\x0C\x85\x90aC?V[\x85\x90aCUV[aH\xDFV[\x90aoVaoP\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07<V[\x91a\x0E\xB1V[\x91ao_a\x03\x92V[\x80aoi\x81anyV[\x03\x90\xA3_\x80\x80an\xFDV[ao\x7F\x91P\x82an\rV[ao\x98ao\x92ao\x8Da\x0E%V[a\x03\xA4V[\x91a\x03\xA4V[\x10\x15_an\xF7V[\x90V[ao\xB7ao\xB2ao\xBC\x92ao\xA0V[a\x079V[a\x05DV[\x90V[\x90\x92\x91\x92ao\xD4ao\xCF\x82a\x15\xC8V[a\x15\x8AV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11ao\xF0Wao\xEE\x92a\t\xCEV[V[a\x15\xC4V[\x90\x80`\x1F\x83\x01\x12\x15ap\x13W\x81` ap\x10\x93Q\x91\x01ao\xBFV[\x90V[a\x05\x9FV[\x90PQ\x90ap%\x82a\x06\xE9V[V[\x91\x90\x91`@\x81\x84\x03\x12apzWap>`@a\x15\x8AV[\x92_\x82\x01Q\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11apuWapb\x82apn\x94\x83\x01ao\xF5V[_\x86\x01R` \x01ap\x18V[` \x83\x01RV[a\x15\xC0V[a\x15\xBCV[\x92\x91\x90ap\x93ap\x8E\x82a\x15\x9FV[a\x15\x8AV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11ap\xEAW\x81\x90[\x83\x82\x10ap\xB9WPPPPPV[\x81Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11ap\xE5W` \x91ap\xDA\x87\x84\x93\x87\x01ap'V[\x81R\x01\x91\x01\x90ap\xABV[a\x05\x9FV[a\x05\xA7V[\x90\x80`\x1F\x83\x01\x12\x15aq\rW\x81` aq\n\x93Q\x91\x01ap\x7FV[\x90V[a\x05\x9FV[\x90` \x82\x82\x03\x12aqBW_\x82\x01Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11aq=Waq:\x92\x01ap\xEFV[\x90V[a\x03\xA0V[a\x03\x9CV[` \x91\x81R\x01\x90V[\x91\x90aqj\x81aqc\x81aqo\x95aqGV[\x80\x95a\x15\xEBV[a\x08\xA9V[\x01\x90V[\x90\x91aq\x8A\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaqPV[\x90V[aq\x97`2a\x14\x1FV[\x90V[\x94\x93\x91``\x91aq\xDB\x94aq\xC6aq\xD3\x93aq\xBC`\x80\x8B\x01\x94_\x8C\x01\x90a\n\xDBV[` \x8A\x01\x90a\x0BvV[\x87\x82\x03`@\x89\x01Ra\x0C\xD3V[\x94\x01\x90a\x05GV[V[\x91aq\xE9\x81\x85\x90a-\x0FV[aq\xFBaq\xF5_a,SV[\x91a\x05DV[\x14as\x95War\x0B\x81\x85\x90a-\x0FV[ar\x1Far\x19a\xC3Pao\xA3V[\x91a\x05DV[\x11as\x8FW_ar-a4SV[\x94ar70a7\xE2V[arYc1\xE3\xBD\x1B\x94\x92\x94ardarMa\x03\x92V[\x96\x87\x95\x86\x94\x85\x94aFsV[\x84R`\x04\x84\x01aqsV[\x03\x91Z\xFA\x80\x91_\x92askW[P\x15_\x14asbWP`\x01as]W[ar\x8A\x83a\x0CBV[ar\xA3ar\x9Dar\x98aq\x8DV[a\x05DV[\x91a\x05DV[\x11_\x14asOWar\xB2aq\x8DV[[ar\xBC0a7\xE2V[\x90ce\xA6\x93n\x93\x92\x94\x90\x82;\x15asJW_\x94ar\xF7\x86\x92ar\xEC\x94ar\xE0a\x03\x92V[\x99\x8A\x98\x89\x97\x88\x96aFsV[\x86R`\x04\x86\x01aq\x9AV[\x03\x92Z\xF1\x90\x81as\x1EW[P\x15_\x14as\x19W`\x01as\x14W[[V[as\x11V[as\x12V[as=\x90_=\x81\x11asCW[as5\x81\x83a\x08\xC7V[\x81\x01\x90aFyV[_as\x02V[P=as+V[aFoV[asX\x83a\x0CBV[ar\xB3V[PPPV[\x90\x92P\x91ar\x81V[as\x88\x91\x92P=\x80_\x83>as\x80\x81\x83a\x08\xC7V[\x81\x01\x90aq\x12V[\x90_arqV[PPPPV[PPPPV[as\xA4_a%NV[as\xAE\x82_a&+V[\x90as\xE2as\xDC\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x0E\xB1V[\x91a\x0E\xB1V[\x91as\xEBa\x03\x92V[\x80as\xF5\x81a\x04;V[\x03\x90\xA3V[at\x02a5\xFDV[Pat*at$at\x1Dat\x18`\x06\x85\x90a2\xC5V[a2\xDBV[\x84\x90ad8V[\x15a\x04\xB2V[at\xCCWatJ\x91at@atE\x92`\x03a\x0EsV[a\x0E\xBDV[aC\x07V[atU_\x82\x01a:\x14V[atgata_a,SV[\x91a\x05DV[\x14\x80\x15at\xA6W[at\xA0Wat\x95at\x8Fat\x9B\x92at\x89_B\x92\x01a:\x14V[\x90aS\x8CV[\x92a\x05DV[\x91a\x05DV[\x10\x15\x90V[PP_\x90V[Pat\xB3``\x82\x01a\\\xE7V[at\xC6at\xC0`\x03a\x10\x04V[\x91a\x10\x04V[\x14atoV[PPP_\x90V[at\xE7at\xE2at\xEC\x92aP\xF4V[a\x079V[a\x05DV[\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[au\x15\x91au\x0Fam@V[\x91alUV[V[au \x81al)V[\x80\x15auAW`\x01\x90\x03\x90au>au8\x83\x83al-V[\x90au\x03V[UV[at\xEFV[auNa5\xFDV[Paueau``\x01\x83\x01\x84\x90al\xB0V[a\t.V[\x90\x81auyaus_a,SV[\x91a\x05DV[\x14\x15_\x14avEWau\xF7\x92`\x01au\xF2\x92\x84au\xA0_\x96au\x9A\x85at\xD3V[\x90aS\x8CV[au\xBDau\xAE\x88\x85\x01al\xACV[au\xB7\x86at\xD3V[\x90aS\x8CV[\x81au\xD0au\xCA\x83a\x05DV[\x91a\x05DV[\x03au\xFCW[PPPau\xECau\xE7\x86\x83\x01al\x1DV[au\x17V[\x01al\xB0V[a)PV[`\x01\x90V[av=\x92av/av\x1Bav\x15av8\x94\x8C\x89\x01amMV[\x90am\x8DV[\x93av)\x85\x91\x8C\x89\x01amMV[\x90alUV[\x91\x85\x85\x01al\xB0V[a/\xA9V[_\x80\x80au\xD6V[PPP_\x90V[_\x90V[\x90V[avgavbavl\x92avPV[a\x079V[a\x05DV[\x90V[_\x90V[\x91\x90\x91av~aF0V[Pav\x87avLV[Pav\x90am@V[Pav\x9A\x83a8\xF9V[av\xADav\xA7`AavSV[\x91a\x05DV[\x14_\x14av\xF4Wav\xED\x91\x92av\xC1am@V[Pav\xCAam@V[Pav\xD3avoV[P` \x81\x01Q```@\x83\x01Q\x92\x01Q_\x1A\x90\x91\x92ax}V[\x91\x92\x90\x91\x90V[Pav\xFE_a%zV[\x90aw\x12aw\r`\x02\x94a8\xF9V[ac\nV[\x91\x92\x91\x90V[`\x04\x11\x15aw\"WV[a\x0F\xE1V[\x90aw1\x82aw\x18V[V[\x80awFaw@_aw'V[\x91aw'V[\x14_\x14awQWPPV[\x80aweaw_`\x01aw'V[\x91aw'V[\x14_\x14aw\x88W_c\xF6E\xEE\xDF`\xE0\x1B\x81R\x80aw\x84`\x04\x82\x01a\x04;V[\x03\x90\xFD[\x80aw\x9Caw\x96`\x02aw'V[\x91aw'V[\x14_\x14aw\xCAWaw\xC6aw\xAF\x83ac\xD0V[_\x91\x82\x91c\xFC\xE6\x98\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x05TV[\x03\x90\xFD[aw\xDDaw\xD7`\x03aw'V[\x91aw'V[\x14aw\xE5WPV[ax\0\x90_\x91\x82\x91c5\xE2\xF3\x83`\xE2\x1B\x83R`\x04\x83\x01a\r\xBCV[\x03\x90\xFD[\x90V[ax\x1Bax\x16ax \x92ax\x04V[a\x079V[a\x05DV[\x90V[axXax_\x94axN``\x94\x98\x97\x95axD`\x80\x86\x01\x9A_\x87\x01\x90a\r\xAFV[` \x85\x01\x90a\x0F\xD4V[`@\x83\x01\x90a\r\xAFV[\x01\x90a\r\xAFV[V[axuaxpaxz\x92a%[V[a&\x08V[a\r\xACV[\x90V[\x93\x92\x93ax\x88aF0V[Pax\x91avLV[Pax\x9Aam@V[Pax\xA4\x85ac\xD0V[ax\xD6ax\xD0\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0ax\x07V[\x91a\x05DV[\x11aycW\x90ax\xF9` \x94\x95_\x94\x93\x92\x93ax\xF0a\x03\x92V[\x94\x85\x94\x85ax#V[\x83\x80R\x03\x90`\x01Z\xFA\x15ay^Way\x11_Qa&\x08V[\x80ay,ay&ay!_a%zV[a\x03\xDFV[\x91a\x03\xDFV[\x14ayBW_\x91ay<_axaV[\x91\x92\x91\x90V[PayL_a%zV[`\x01\x91ayX_axaV[\x91\x92\x91\x90V[aF\xABV[PPPayo_a%zV[\x90`\x03\x92\x91\x92\x91\x90V\xFE\xA1dsolcC\0\x08\x1A\0\n",
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
