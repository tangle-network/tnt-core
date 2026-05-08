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
    ///0x60c0604052346100655761001a610014610139565b90610216565b61002261006a565b617b106104d38239608051818181610edf0152613936015260a051818181611460015281816126cd015281816134370152818161574e015261630b0152617b1090f35b610070565b60405190565b5f80fd5b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b9061009c90610074565b810190811060018060401b038211176100b457604052565b61007e565b906100cc6100c561006a565b9283610092565b565b5f80fd5b60018060a01b031690565b6100e6906100d2565b90565b6100f2816100dd565b036100f957565b5f80fd5b9050519061010a826100e9565b565b91906040838203126101345780610128610131925f86016100fd565b936020016100fd565b90565b6100ce565b610157617fe38038038061014c816100b9565b92833981019061010c565b9091565b90565b61017261016d610177926100d2565b61015b565b6100d2565b90565b6101839061015e565b90565b61018f9061017a565b90565b90565b61019e90610192565b9052565b90565b6101ae906101a2565b9052565b6101bb906100dd565b9052565b9095949261020a946101f9610203926101ef6080966101e560a088019c5f890190610195565b6020870190610195565b6040850190610195565b60608301906101a5565b01906101b2565b565b60200190565b5190565b90610220906102d3565b60a0527f8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f6102bb7f36ffc258c865193ae10c3cf640450ab772fdb8da1dfcae7862ad1205a5567f4c916102ac7fc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc64661029730610186565b916102a061006a565b968795602087016101bf565b60208201810382520382610092565b6102cd6102c782610212565b9161020c565b20608052565b6102dc9061031e565b565b90565b6102f56102f06102fa926102de565b61015b565b6100d2565b90565b610306906102e1565b90565b919061031c905f602085019401906101b2565b565b8061033961033361032e5f6102fd565b6100dd565b916100dd565b1461034957610347906103e7565b565b61036c6103555f6102fd565b5f918291631e4fbdf760e01b835260048301610309565b0390fd5b1b90565b9190600861039491029161038e60018060a01b0384610370565b92610370565b9181191691161790565b6103a79061017a565b90565b90565b91906103c36103be6103cb9361039e565b6103aa565b908354610374565b9055565b5f90565b6103e5916103df6103cf565b916103ad565b565b6103fb906103f65f60016103d3565b610473565b565b5f1c90565b60018060a01b031690565b61041961041e916103fd565b610402565b90565b61042b905461040d565b90565b5f1b90565b9061044460018060a01b039161042e565b9181191691161790565b9061046361045e61046a9261039e565b6103aa565b8254610433565b9055565b5f0190565b61047c5f610421565b610486825f61044e565b906104ba6104b47f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e09361039e565b9161039e565b916104c361006a565b806104cd8161046e565b0390a356fe60806040526004361015610013575b612523565b61001d5f3561039c565b806305778550146103975780630758236f146103925780630c76697a1461038d578063191cbd1a146103885780631e8f5ee514610383578063208129561461037e57806322f1ec93146103795780632bf4d6a7146103745780632c9576881461036f5780632dae18851461036a5780632f4bd7b81461036557806331e3bd1b146103605780633644e5151461035b5780633ac3cbe6146103565780633e6e34a7146103515780633fd62c6d1461034c57806340235a9c1461034757806348f4da20146103425780635685cf681461033d57806356c4e17d1461033857806359dcea12146103335780635a936dc61461032e5780635cce98a6146103295780636076439c1461032457806360cf09911461031f57806361d6b86c1461031a57806362c7e8fc1461031557806365a6936e146103105780636bfe06a61461030b578063715018a61461030657806371e7388c146103015780637639d227146102fc57806379ba5097146102f75780637b9f64b2146102f257806381beac2e146102ed57806384ef7322146102e85780638da5cb5b146102e357806396686c1e146102de5780639cbdae22146102d9578063adff830c146102d4578063ae470a85146102cf578063b074e9dd146102ca578063b99f6759146102c5578063ba1fb103146102c0578063c1ef9ddf146102bb578063c5d960bb146102b6578063cfe34749146102b1578063d551162c146102ac578063da435a7c146102a7578063e30c3978146102a2578063e65cafcb1461029d578063ee1c039014610298578063f2fde38b14610293578063f9107f3b1461028e578063f9f16762146102895763ffcf08f00361000e576124ef565b6124ba565b612457565b6123f7565b6123c1565b61238d565b612358565b612320565b61224e565b612219565b6121d7565b6121a2565b612078565b612044565b611fd7565b611f9d565b611ed2565b611e0b565b611c82565b611bc8565b611b95565b611b5e565b611ac9565b611a96565b611a60565b611a2a565b61196e565b611939565b6118cb565b611686565b61163c565b6115ba565b611585565b611517565b611482565b611429565b6113f4565b61138f565b611345565b6112d9565b611205565b6111cb565b610f93565b610f26565b610ea7565b610d2c565b610cde565b610c43565b610b9d565b610a6a565b6106c6565b610674565b610640565b610579565b61051f565b610450565b60e01c90565b60405190565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff1690565b6103ca816103b4565b036103d157565b5f80fd5b905035906103e2826103c1565b565b60018060a01b031690565b6103f8906103e4565b90565b610404816103ef565b0361040b57565b5f80fd5b9050359061041c826103fb565b565b9190604083820312610446578061043a610443925f86016103d5565b9360200161040f565b90565b6103ac565b5f0190565b3461047f5761046961046336600461041e565b906126ba565b6104716103a2565b8061047b8161044b565b0390f35b6103a8565b9060208282031261049d5761049a915f016103d5565b90565b6103ac565b6104ab906103b4565b9052565b60ff1690565b6104be906104af565b9052565b151590565b6104d0906104c2565b9052565b90604080610508936104ec5f8201515f8601906104a2565b6104fe602082015160208601906104b5565b01519101906104c7565b565b919061051d905f606085019401906104d4565b565b3461054f5761054b61053a610535366004610484565b612799565b6105426103a2565b9182918261050a565b0390f35b6103a8565b90565b61056090610554565b9052565b9190610577905f60208501940190610557565b565b346105aa576105a661059561058f36600461041e565b906127b2565b61059d6103a2565b91829182610564565b0390f35b6103a8565b5f80fd5b5f80fd5b5f80fd5b909182601f830112156105f55781359167ffffffffffffffff83116105f05760200192602083028401116105eb57565b6105b7565b6105b3565b6105af565b91909160408184031261063b57610613835f83016103d5565b92602082013567ffffffffffffffff81116106365761063292016105bb565b9091565b6103b0565b6103ac565b3461066f576106596106533660046105fa565b9161313b565b6106616103a2565b8061066b8161044b565b0390f35b6103a8565b346106a35761068d61068736600461041e565b9061342b565b6106956103a2565b8061069f8161044b565b0390f35b6103a8565b906020828203126106c1576106be915f0161040f565b90565b6103ac565b346106f4576106de6106d93660046106a8565b613560565b6106e66103a2565b806106f08161044b565b0390f35b6103a8565b61070281610554565b0361070957565b5f80fd5b9050359061071a826106f9565b565b91906040838203126107445780610738610741925f86016103d5565b9360200161070d565b90565b6103ac565b90565b61076061075b610765926103b4565b610749565b6103b4565b90565b906107729061074c565b5f5260205260405f2090565b634e487b7160e01b5f52603260045260245ffd5b5490565b5f5260205f2090565b5f5260205f2090565b6107b181610792565b8210156107cb576107c3600491610796565b910201905f90565b61077e565b634e487b7160e01b5f52602260045260245ffd5b9060016002830492168015610804575b60208310146107ff57565b6107d0565b91607f16916107f4565b60209181520190565b5f5260205f2090565b905f929180549061083a610833836107e4565b809461080e565b916001811690815f146108915750600114610855575b505050565b6108629192939450610817565b915f925b81841061087957505001905f8080610850565b60018160209295939554848601520191019290610866565b92949550505060ff19168252151560200201905f8080610850565b906108b691610820565b90565b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b906108e1906108b9565b810190811067ffffffffffffffff8211176108fb57604052565b6108c3565b90610920610919926109106103a2565b938480926108ac565b03836108d7565b565b5f1c90565b90565b61093661093b91610922565b610927565b90565b610948905461092a565b90565b60ff1690565b61095d61096291610922565b61094b565b90565b61096f9054610951565b90565b61097d906008610768565b9061098782610792565b8110156109cd57610997916107a8565b50906109a45f8301610900565b916109b16001820161093e565b916109ca60036109c36002850161093e565b9301610965565b90565b5f80fd5b5190565b60209181520190565b90825f9392825e0152565b610a08610a11602093610a16936109ff816109d1565b938480936109d5565b958691016109de565b6108b9565b0190565b610a23906104c2565b9052565b610a61610a6894610a57610a4c6060959998969960808601908682035f8801526109e9565b986020850190610557565b6040830190610557565b0190610a1a565b565b34610a9f57610a9b610a86610a8036600461071c565b90610972565b90610a929492946103a2565b94859485610a27565b0390f35b6103a8565b610aad816104af565b03610ab457565b5f80fd5b90503590610ac582610aa4565b565b909182601f83011215610b015781359167ffffffffffffffff8311610afc576020019260018302840111610af757565b6105b7565b6105b3565b6105af565b919060c083820312610b9857610b1e815f85016103d5565b92610b2c82602083016103d5565b92610b3a8360408401610ab8565b92606083013567ffffffffffffffff8111610b935781610b5b918501610ac7565b929093610b6b83608083016103d5565b9260a082013567ffffffffffffffff8111610b8e57610b8a9201610ac7565b9091565b6103b0565b6103b0565b6103ac565b34610bd557610bbf610bb0366004610b06565b96959095949194939293613a0f565b610bc76103a2565b80610bd18161044b565b0390f35b6103a8565b5f910312610be457565b6103ac565b90565b610c00610bfb610c0592610be9565b610749565b6103b4565b90565b610c1361012c610bec565b90565b610c1e610c08565b90565b610c2a906103b4565b9052565b9190610c41905f60208501940190610c21565b565b34610c7357610c53366004610bda565b610c6f610c5e610c16565b610c666103a2565b91829182610c2e565b0390f35b6103a8565b1c90565b60018060a01b031690565b610c97906008610c9c9302610c78565b610c7c565b90565b90610caa9154610c87565b90565b610cb9600b5f90610c9f565b90565b610cc5906103ef565b9052565b9190610cdc905f60208501940190610cbc565b565b34610d0e57610cee366004610bda565b610d0a610cf9610cad565b610d016103a2565b91829182610cc9565b0390f35b6103a8565b610d1e61012c610bec565b90565b610d29610d13565b90565b34610d5c57610d3c366004610bda565b610d58610d47610d21565b610d4f6103a2565b91829182610c2e565b0390f35b6103a8565b90602082820312610d92575f82013567ffffffffffffffff8111610d8d57610d899201610ac7565b9091565b6103b0565b6103ac565b5190565b60209181520190565b60200190565b610dc9610dd2602093610dd793610dc0816109d1565b9384809361080e565b958691016109de565b6108b9565b0190565b610de490610554565b9052565b90610e1290602080610e07604084015f8701518582035f870152610daa565b940151910190610ddb565b90565b90610e1f91610de8565b90565b60200190565b90610e3c610e3583610d97565b8092610d9b565b9081610e4d60208302840194610da4565b925f915b838310610e6057505050505090565b90919293946020610e82610e7c83856001950387528951610e15565b97610e22565b9301930191939290610e51565b610ea49160208201915f818403910152610e28565b90565b34610ed857610ed4610ec3610ebd366004610d61565b90613a5b565b610ecb6103a2565b91829182610e8f565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b90565b610f0d90610f01565b9052565b9190610f24905f60208501940190610f04565b565b34610f5657610f36366004610bda565b610f52610f41610edd565b610f496103a2565b91829182610f11565b0390f35b6103a8565b90565b610f72610f6d610f7792610f5b565b610749565b6103b4565b90565b610f85610e10610f5e565b90565b610f90610f7a565b90565b34610fc357610fa3366004610bda565b610fbf610fae610f88565b610fb66103a2565b91829182610c2e565b0390f35b6103a8565b90610fd29061074c565b5f5260205260405f2090565b610ff2610fed610ff7926103e4565b610749565b6103e4565b90565b61100390610fde565b90565b61100f90610ffa565b90565b9061101c90611006565b5f5260205260405f2090565b67ffffffffffffffff1690565b61104161104691610922565b611028565b90565b6110539054611035565b90565b60401c90565b60ff1690565b61106e61107391611056565b61105c565b90565b6110809054611062565b90565b60481c90565b60ff1690565b61109b6110a091611083565b611089565b90565b6110ad905461108f565b90565b90565b6110bf6110c491610922565b6110b0565b90565b6110d190546110b3565b90565b906110e36110e8926003610fc8565b611012565b6110f35f820161093e565b9161110060018301611049565b9161110d60018201611076565b91611126600261111f600185016110a3565b93016110c7565b90565b611132906104af565b9052565b634e487b7160e01b5f52602160045260245ffd5b6005111561115457565b611136565b906111638261114a565b565b61116e90611159565b90565b61117a90611165565b9052565b909594926111c9946111b86111c2926111ae6080966111a460a088019c5f890190610557565b6020870190610c21565b6040850190611129565b6060830190611171565b0190610f04565b565b34611200576111fc6111e76111e136600461041e565b906110d4565b916111f39593956103a2565b9586958661117e565b0390f35b6103a8565b346112355761123161122061121b366004610484565b613a75565b6112286103a2565b91829182610564565b0390f35b6103a8565b5190565b60209181520190565b60200190565b611256906103ef565b9052565b906112678160209361124d565b0190565b60200190565b9061128e6112886112818461123a565b809361123e565b92611247565b905f5b81811061129e5750505090565b9091926112b76112b1600192865161125a565b9461126b565b9101919091611291565b6112d69160208201915f818403910152611271565b90565b34611309576113056112f46112ef366004610484565b613b2f565b6112fc6103a2565b918291826112c1565b0390f35b6103a8565b90565b61132561132061132a9261130e565b610749565b610554565b90565b61133760c8611311565b90565b61134261132d565b90565b3461137557611355366004610bda565b61137161136061133a565b6113686103a2565b91829182610564565b0390f35b6103a8565b919061138d905f60208501940190610a1a565b565b346113c0576113bc6113ab6113a536600461041e565b90613bcf565b6113b36103a2565b9182918261137a565b0390f35b6103a8565b906113cf9061074c565b5f5260205260405f2090565b6113f1906113ec6007915f926113c5565b610c9f565b90565b346114245761142061140f61140a366004610484565b6113db565b6114176103a2565b91829182610cc9565b0390f35b6103a8565b346114595761145561144461143f366004610484565b613c56565b61144c6103a2565b918291826112c1565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b346114b257611492366004610bda565b6114ae61149d61145e565b6114a56103a2565b91829182610cc9565b0390f35b6103a8565b90608082820312611512576114ce815f84016103d5565b926114dc82602085016103d5565b926114ea8360408301610ab8565b92606082013567ffffffffffffffff811161150d576115099201610ac7565b9091565b6103b0565b6103ac565b346115495761153361152a3660046114b7565b93929092613cc8565b61153b6103a2565b806115458161044b565b0390f35b6103a8565b90565b61156561156061156a9261154e565b610749565b610554565b90565b6115776032611551565b90565b61158261156d565b90565b346115b557611595366004610bda565b6115b16115a061157a565b6115a86103a2565b91829182610564565b0390f35b6103a8565b346115eb576115e76115d66115d036600461041e565b90613cd7565b6115de6103a2565b9182918261137a565b0390f35b6103a8565b90565b61160761160261160c926115f0565b610749565b6104af565b90565b61161960036115f3565b90565b61162461160f565b90565b919061163a905f60208501940190611129565b565b3461166c5761164c366004610bda565b61166861165761161c565b61165f6103a2565b91829182611627565b0390f35b6103a8565b9190611684905f60208501940190611171565b565b346116b7576116b36116a261169c36600461041e565b90613d03565b6116aa6103a2565b91829182611671565b0390f35b6103a8565b906116cf6116c86103a2565b92836108d7565b565b67ffffffffffffffff81116116e95760208091020190565b6108c3565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff8111611718576117146020916108b9565b0190565b6108c3565b90825f939282370152565b9092919261173d611738826116fa565b6116bc565b93818552602085019082840111611759576117579261171d565b565b6116f6565b9080601f8301121561177c5781602061177993359101611728565b90565b6105af565b9190916040818403126117d45761179860406116bc565b925f8201359167ffffffffffffffff83116117cf576117bc826117c894830161175e565b5f86015260200161070d565b6020830152565b6116f2565b6116ee565b9291906117ed6117e8826116d1565b6116bc565b93818552602080860192028101918383116118445781905b838210611813575050505050565b813567ffffffffffffffff811161183f576020916118348784938701611781565b815201910190611805565b6105af565b6105b7565b9080601f8301121561186757816020611864933591016117d9565b90565b6105af565b6080818303126118c657611882825f83016103d5565b92611890836020840161040f565b9260408301359067ffffffffffffffff82116118c1576118b5816118be938601611849565b9360600161070d565b90565b6103b0565b6103ac565b346118fd576118e76118de36600461186c565b929190916140e9565b6118ef6103a2565b806118f98161044b565b0390f35b6103a8565b90565b61191961191461191e92611902565b610749565b610554565b90565b61192b6040611905565b90565b611936611921565b90565b3461196957611949366004610bda565b61196561195461192e565b61195c6103a2565b91829182610564565b0390f35b6103a8565b3461199c5761197e366004610bda565b611986614718565b61198e6103a2565b806119988161044b565b0390f35b6103a8565b6119aa90611165565b9052565b6119b790610f01565b9052565b90608080611a13936119d35f8201515f860190610ddb565b6119e5602082015160208601906104a2565b6119f7604082015160408601906104b5565b611a09606082015160608601906119a1565b01519101906119ae565b565b9190611a28905f60a085019401906119bb565b565b34611a5b57611a57611a46611a4036600461041e565b90614855565b611a4e6103a2565b91829182611a15565b0390f35b6103a8565b34611a9157611a8d611a7c611a7636600461041e565b906148ad565b611a846103a2565b91829182610c2e565b0390f35b6103a8565b34611ac457611aa6366004610bda565b611aae6148d5565b611ab66103a2565b80611ac08161044b565b0390f35b6103a8565b34611af957611af5611ae4611adf366004610484565b614926565b611aec6103a2565b91829182610564565b0390f35b6103a8565b9091606082840312611b3357611b30611b19845f85016103d5565b93611b27816020860161070d565b9360400161070d565b90565b6103ac565b92916020611b54611b5c9360408701908782035f890152611271565b940190610557565b565b34611b9057611b77611b71366004611afe565b916149c4565b90611b8c611b836103a2565b92839283611b38565b0390f35b6103a8565b34611bc357611bad611ba83660046106a8565b614b4b565b611bb56103a2565b80611bbf8161044b565b0390f35b6103a8565b34611bf857611bd8366004610bda565b611bf4611be3614b5a565b611beb6103a2565b91829182610cc9565b0390f35b6103a8565b909182601f83011215611c375781359167ffffffffffffffff8311611c32576020019260208302840111611c2d57565b6105b7565b6105b3565b6105af565b919091604081840312611c7d57611c55835f83016103d5565b92602082013567ffffffffffffffff8111611c7857611c749201611bfd565b9091565b6103b0565b6103ac565b34611cb157611c9b611c95366004611c3c565b91614be1565b611ca36103a2565b80611cad8161044b565b0390f35b6103a8565b91606083830312611d0257611ccd825f85016103d5565b92611cdb836020830161040f565b92604082013567ffffffffffffffff8111611cfd57611cfa920161175e565b90565b6103b0565b6103ac565b90611d119061074c565b5f5260205260405f2090565b90611d2790611006565b5f5260205260405f2090565b905090565b611d5d611d5492602092611d4b816109d1565b94858093611d33565b938491016109de565b0190565b90565b611d70611d7591610554565b611d61565b9052565b611d89611d909160209493611d38565b8092611d64565b0190565b611da8611d9f6103a2565b92839283611d79565b03902090565b611db791611d94565b90565b611dca906008611dcf9302610c78565b610927565b90565b90611ddd9154611dba565b90565b90611e0892611dfe611e0392611df96009955f96611d07565b611d1d565b611dae565b611dd2565b90565b34611e3c57611e38611e27611e21366004611cb6565b91611de0565b611e2f6103a2565b91829182610564565b0390f35b6103a8565b909182601f83011215611e7b5781359167ffffffffffffffff8311611e76576020019260018302840111611e7157565b6105b7565b6105b3565b6105af565b91606083830312611ecd57611e97825f85016103d5565b92611ea5836020830161040f565b92604082013567ffffffffffffffff8111611ec857611ec49201611e41565b9091565b6103b0565b6103ac565b34611f0457611eee611ee5366004611e80565b92919091614e46565b611ef66103a2565b80611f008161044b565b0390f35b6103a8565b611f12816104c2565b03611f1957565b5f80fd5b90503590611f2a82611f09565b565b91909160a081840312611f9857611f45835f83016103d5565b92602082013567ffffffffffffffff8111611f935781611f66918401611e41565b929093611f90611f79846040850161070d565b93611f87816060860161070d565b93608001611f1d565b90565b6103b0565b6103ac565b34611fd257611fbc611fb0366004611f2c565b9493909392919261511b565b611fc46103a2565b80611fce8161044b565b0390f35b6103a8565b3461200557611fef611fea366004610484565b6154d0565b611ff76103a2565b806120018161044b565b0390f35b6103a8565b909160608284031261203f5761203c612025845f85016103d5565b9361203381602086016103d5565b93604001610ab8565b90565b6103ac565b346120735761205d61205736600461200a565b91615745565b6120656103a2565b8061206f8161044b565b0390f35b6103a8565b346120a75761209161208b36600461041e565b90615904565b6120996103a2565b806120a38161044b565b0390f35b6103a8565b5190565b60209181520190565b60200190565b9061210d906060806120de608084015f8701518582035f870152610daa565b946120f160208201516020860190610ddb565b61210360408201516040860190610ddb565b01519101906104c7565b90565b9061211a916120bf565b90565b60200190565b90612137612130836120ac565b80926120b0565b9081612148602083028401946120b9565b925f915b83831061215b57505050505090565b9091929394602061217d61217783856001950387528951612110565b9761211d565b930193019193929061214c565b61219f9160208201915f818403910152612123565b90565b346121d2576121ce6121bd6121b8366004610484565b615c7b565b6121c56103a2565b9182918261218a565b0390f35b6103a8565b34612205576121ef6121ea366004610484565b615e0b565b6121f76103a2565b806122018161044b565b0390f35b6103a8565b612216600a5f90610c9f565b90565b3461224957612229366004610bda565b61224561223461220a565b61223c6103a2565b91829182610cc9565b0390f35b6103a8565b346122825761227e61226d612264366004611e80565b92919091615e78565b6122756103a2565b91829182610564565b0390f35b6103a8565b906122919061074c565b5f5260205260405f2090565b6122a96122ae91611083565b61094b565b90565b6122bb905461229d565b90565b6122c9906002612287565b6122d45f8201611049565b916122eb5f6122e4818501611076565b93016122b1565b90565b60409061231761231e949695939661230d60608401985f850190610c21565b6020830190611129565b0190610a1a565b565b346123535761234f61233b612336366004610484565b6122be565b6123469391936103a2565b938493846122ee565b0390f35b6103a8565b3461238857612368366004610bda565b612384612373615ead565b61237b6103a2565b91829182610cc9565b0390f35b6103a8565b346123bc576123a66123a036600461041e565b90615f97565b6123ae6103a2565b806123b88161044b565b0390f35b6103a8565b346123f2576123ee6123dd6123d736600461041e565b9061612c565b6123e56103a2565b9182918261137a565b0390f35b6103a8565b346124255761240f61240a3660046106a8565b61622b565b6124176103a2565b806124218161044b565b0390f35b6103a8565b9190604083820312612452578061244661244f925f86016103d5565b93602001611f1d565b90565b6103ac565b346124865761247061246a36600461242a565b90616236565b6124786103a2565b806124828161044b565b0390f35b6103a8565b7f32721f8dc67e953c540da90f663059c23fc47f70d11e317ed6d5a24c8b85637490565b6124b761248b565b90565b346124ea576124ca366004610bda565b6124e66124d56124af565b6124dd6103a2565b91829182610f11565b0390f35b6103a8565b3461251e5761250861250236600461041e565b906162ff565b6125106103a2565b8061251a8161044b565b0390f35b6103a8565b5f80fd5b5f7f4f6e6c792054616e676c6520636f726500000000000000000000000000000000910152565b61255b60106020926109d5565b61256481612527565b0190565b61257d9060208101905f81830391015261254e565b90565b1561258757565b61258f6103a2565b62461bcd60e51b8152806125a560048201612568565b0390fd5b6125b56125ba91610922565b610c7c565b90565b6125c790546125a9565b90565b90565b6125e16125dc6125e6926125ca565b610749565b6103e4565b90565b6125f2906125cd565b90565b5f7f416c726561647920726567697374657265640000000000000000000000000000910152565b61262960126020926109d5565b612632816125f5565b0190565b61264b9060208101905f81830391015261261c565b90565b1561265557565b61265d6103a2565b62461bcd60e51b81528061267360048201612636565b0390fd5b5f1b90565b9061268d60018060a01b0391612677565b9181191691161790565b90565b906126af6126aa6126b692611006565b612697565b825461267c565b9055565b61273c612741926126fd336126f76126f17f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b61273461271461270f600786906113c5565b6125bd565b61272e6127286127235f6125e9565b6103ef565b916103ef565b1461264e565b9160076113c5565b61269a565b565b61274d60606116bc565b90565b5f90565b5f90565b5f90565b612764612743565b906020808084612772612750565b81520161277d612754565b815201612788612758565b81525050565b61279661275c565b90565b6127ab906127a561278e565b50616427565b90565b5f90565b6127d36127d9926127ce5f936127c66127ae565b506003610fc8565b611012565b0161093e565b90565b5f7f4e6f742073657276696365206f776e6572000000000000000000000000000000910152565b61281060116020926109d5565b612819816127dc565b0190565b6128329060208101905f818303910152612803565b90565b1561283c57565b6128446103a2565b62461bcd60e51b81528061285a6004820161281d565b0390fd5b5090565b5f7f546f6f206d616e7920646566696e6974696f6e73000000000000000000000000910152565b61289660146020926109d5565b61289f81612862565b0190565b6128b89060208101905f818303910152612889565b90565b156128c257565b6128ca6103a2565b62461bcd60e51b8152806128e0600482016128a3565b0390fd5b634e487b7160e01b5f52601160045260245ffd5b61290761290d91939293610554565b92610554565b91612919838202610554565b92818404149015171561292857565b6128e4565b6129389060046128f8565b90565b9061294e905f1990602003600802610c78565b8154169055565b1b90565b9190600861297491029161296e5f1984612955565b92612955565b9181191691161790565b61299261298d61299792610554565b610749565b610554565b90565b90565b91906129b36129ae6129bb9361297e565b61299a565b908354612959565b9055565b6129d1916129cb6127ae565b9161299d565b565b5b8181106129df575050565b806129ec5f6001936129bf565b016129d4565b90612a02905f1990600802610c78565b191690565b81612a11916129f2565b906002021790565b905f91612a30612a2882610817565b928354612a07565b905555565b601f602091010490565b919290602082105f14612a9857601f8411600114612a6857612a62929350612a07565b90555b5b565b5090612a8e612a93936001612a85612a7f85610817565b92612a35565b820191016129d3565b612a19565b612a65565b50612acf8293612aa9600194610817565b612ac8612ab585612a35565b820192601f861680612ada575b50612a35565b01906129d3565b600202179055612a66565b612ae69088860361293b565b5f612ac2565b929091680100000000000000008211612b4c576020115f14612b3d57602081105f14612b2157612b1b91612a07565b90555b5b565b60019160ff1916612b3184610817565b55600202019055612b1e565b60019150600202019055612b1f565b6108c3565b908154612b5d816107e4565b90818311612b86575b818310612b74575b50505050565b612b7d93612a3f565b5f808080612b6e565b612b9283838387612aec565b612b66565b5f612ba191612b51565b565b634e487b7160e01b5f525f60045260245ffd5b905f03612bc857612bc690612b97565b565b612ba3565b60035f91612bdd83808301612bb6565b612bea83600183016129bf565b612bf783600283016129bf565b0155565b905f03612c0d57612c0b90612bcd565b565b612ba3565b5b818110612c1e575050565b80612c2b5f600493612bfb565b01612c13565b9091828110612c40575b505050565b612c5e612c58612c52612c699561292d565b9261292d565b92610796565b918201910190612c12565b5f8080612c3b565b90680100000000000000008111612c9a5781612c8f612c9893610792565b90828155612c31565b565b6108c3565b5f612ca991612c71565b565b905f03612cbd57612cbb90612c9f565b565b612ba3565b612cd6612cd1612cdb926125ca565b610749565b610554565b90565b6001612cea9101610554565b90565b5f80fd5b5f80fd5b5f80fd5b903590600160800381360303821215612d10570190565b612ced565b90821015612d2f576020612d2c9202810190612cf9565b90565b61077e565b903590600160200381360303821215612d76570180359067ffffffffffffffff8211612d7157602001916001820236038313612d6c57565b612cf5565b612cf1565b612ced565b91565b5090565b5f7f4e616d6520746f6f206c6f6e6700000000000000000000000000000000000000910152565b612db6600d6020926109d5565b612dbf81612d82565b0190565b612dd89060208101905f818303910152612da9565b90565b15612de257565b612dea6103a2565b62461bcd60e51b815280612e0060048201612dc3565b0390fd5b35612e0e816106f9565b90565b5f7f496e76616c696420626f756e6473000000000000000000000000000000000000910152565b612e45600e6020926109d5565b612e4e81612e11565b0190565b612e679060208101905f818303910152612e38565b90565b15612e7157565b612e796103a2565b62461bcd60e51b815280612e8f60048201612e52565b0390fd5b90565b5f5260205f2090565b5490565b612eac81612e9f565b821015612ec657612ebe600491612e96565b910201905f90565b61077e565b5090565b9190601f8111612edf575b505050565b612eeb612f1093610817565b906020612ef784612a35565b83019310612f18575b612f0990612a35565b01906129d3565b5f8080612eda565b9150612f0981929050612f00565b91612f319082612ecb565b9067ffffffffffffffff8211612ff057612f5582612f4f85546107e4565b85612ecf565b5f90601f8311600114612f8857918091612f77935f92612f7c575b5050612a07565b90555b565b90915001355f80612f70565b601f19831691612f9785610817565b925f5b818110612fd857509160029391856001969410612fbe575b50505002019055612f7a565b612fce910135601f8416906129f2565b90555f8080612fb2565b91936020600181928787013581550195019201612f9a565b6108c3565b906130009291612f26565b565b9061300e5f1991612677565b9181191691161790565b9061302d6130286130349261297e565b61299a565b8254613002565b9055565b3561304281611f09565b90565b9061305160ff91612677565b9181191691161790565b613064906104c2565b90565b90565b9061307f61307a6130869261305b565b613067565b8254613045565b9055565b906130e8606060036130ee946130ae5f82016130a85f880188612d34565b91612ff5565b6130c7600182016130c160208801612e04565b90613018565b6130e0600282016130da60408801612e04565b90613018565b019201613038565b9061306a565b565b9190613101576130ff9161308a565b565b612ba3565b9081549168010000000000000000831015613136578261312e91600161313495018155612ea3565b906130f0565b565b6108c3565b9291909261316e3361316861316261315d613158600787906113c5565b6125bd565b6103ef565b916103ef565b14612835565b61319c61317c85849061285e565b61319561318f61318a61156d565b610554565b91610554565b11156128bb565b6131b15f6131ac60088490610768565b612cab565b6131ba5f612cc2565b5b806131d86131d26131cd88879061285e565b610554565b91610554565b10156132ab576132a69061322f61320f6132096132036131fa8a898791612d15565b5f810190612d34565b90612d7b565b90612d7e565b61322861322261321d611921565b610554565b91610554565b1115612ddb565b613278613249604061324389888691612d15565b01612e04565b61327161326b61326660206132608c8b8991612d15565b01612e04565b610554565b91610554565b1015612e6a565b6132a161328f61328a60088690610768565b612e93565b61329b88878591612d15565b90613106565b612cde565b6131bb565b5050509050565b5f7f5a65726f20616464726573730000000000000000000000000000000000000000910152565b6132e6600c6020926109d5565b6132ef816132b2565b0190565b6133089060208101905f8183039101526132d9565b90565b1561331257565b61331a6103a2565b62461bcd60e51b815280613330600482016132f3565b0390fd5b9061333e9061074c565b5f5260205260405f2090565b90565b61335690610f01565b90565b61336290610922565b90565b919061337b6133766133839361334d565b613359565b908354612959565b9055565b5f90565b61339d91613397613387565b91613365565b565b5f60026133be926133b2838083016129bf565b8260018201550161338b565b565b905f036133d2576133d09061339f565b565b612ba3565b60481b90565b906133f269ff000000000000000000916133d7565b9181191691161790565b61340590611159565b90565b90565b9061342061341b613427926133fc565b613408565b82546133dd565b9055565b6134673361346161345b7f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b61348c8261348561347f61347a5f6125e9565b6103ef565b916103ef565b141561330b565b6134b26134ad6134a66134a160068590613334565b61334a565b8490616505565b61264e565b6134d15f6134cc6134c560038590610fc8565b8590611012565b6133c0565b6134f4600260016134ee6134e760038690610fc8565b8690611012565b0161340b565b906135286135227f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b9361074c565b91611006565b916135316103a2565b8061353b8161044b565b0390a3565b6135519061354c61653f565b613553565b565b61355e90600b61269a565b565b61356990613540565b565b5f7f4e6f742072656769737465726564206f70657261746f72000000000000000000910152565b61359f60176020926109d5565b6135a88161356b565b0190565b6135c19060208101905f818303910152613592565b90565b156135cb57565b6135d36103a2565b62461bcd60e51b8152806135e9600482016135ac565b0390fd5b906136229796959493929161361d61361861361161360c846006613334565b61334a565b339061658d565b6135c4565b613863565b565b61363861363361363d926103b4565b610749565b610554565b90565b61365461364f61365992610554565b610749565b6103b4565b90565b91602061367d92949361367660408201965f830190610c21565b0190610c21565b565b61368e61369491939293610554565b92610554565b820391821161369f57565b6128e4565b67ffffffffffffffff81116136c2576136be6020916108b9565b0190565b6108c3565b909291926136dc6136d7826136a4565b6116bc565b938185526020850190828401116136f8576136f69261171d565b565b6116f6565b6137089136916136c7565b90565b60200190565b5190565b949290979695939160e08601985f870161372e91610f04565b6020860161373b91610cbc565b6040850161374891610c21565b6060840161375591610c21565b6080830161376291611129565b60a0820161376f91610f04565b60c00161377b91610c21565b565b5f61190160f01b910152565b61379560028092611d33565b61379e8161377d565b0190565b90565b6137b16137b691610f01565b6137a2565b9052565b60208093926137d56137ce6137dd94613789565b80926137a5565b0180926137a5565b0190565b5f7f496e76616c6964207369676e6174757265000000000000000000000000000000910152565b61381560116020926109d5565b61381e816137e1565b0190565b6138379060208101905f818303910152613808565b90565b1561384157565b6138496103a2565b62461bcd60e51b81528061385f60048201613822565b0390fd5b9192939497969095978061387f61387942610554565b91613624565b116139e7576138974261389183613624565b9061367f565b6138b06138aa6138a5610d13565b613624565b91610554565b116139bf576139bd97986139946139b2938561391e8a61390f8d61399a988d8d6138e66138db61248b565b9633999592936136fd565b6138f86138f282613711565b9161370b565b2092936139036103a2565b98899760208901613715565b602082018103825203826108d7565b61393061392a82613711565b9161370b565b2061397b7f000000000000000000000000000000000000000000000000000000000000000061396c6139606103a2565b938492602084016137ba565b602082018103825203826108d7565b61398d61398782613711565b9161370b565b20926136fd565b906165c7565b6139ac6139a6336103ef565b916103ef565b1461383a565b933391929394616746565b565b6139c842613640565b906139e35f9283926318355b7560e21b84526004840161365c565b0390fd5b6139f042613640565b90613a0b5f9283926357ea02e960e01b84526004840161365c565b0390fd5b90613a1f979695949392916135ed565b565b606090565b90602082820312613a56575f82013567ffffffffffffffff8111613a5157613a4e9201611849565b90565b6103b0565b6103ac565b90613a7291613a68613a21565b5090810190613a26565b90565b613a94613a8f613a9992613a876127ae565b506005613334565b61334a565b616b58565b90565b606090565b67ffffffffffffffff8111613ab95760208091020190565b6108c3565b90613ad0613acb83613aa1565b6116bc565b918252565b369037565b90613aff613ae783613abe565b92602080613af58693613aa1565b9201910390613ad5565b565b90613b0b8261123a565b811015613b1c576020809102010190565b61077e565b90613b2b906103ef565b9052565b90613b38613a9c565b50613b55613b50613b4b60048590613334565b61334a565b616b58565b91613b5f83613ada565b91613b695f612cc2565b5b80613b7d613b7787610554565b91610554565b1015613bc457613bbf90613bba613ba8613ba1613b9c60048890613334565b61334a565b8390616ba7565b613bb58791849092613b01565b613b21565b612cde565b613b6a565b5092505090565b5f90565b90613bd8613bcb565b50613bfa6001613bf4613bed60038690610fc8565b8490611012565b016110a3565b613c0c613c065f611159565b91611159565b14918215613c1a575b505090565b613c3b9250600191613c30613c35926003610fc8565b611012565b016110a3565b613c4e613c486001611159565b91611159565b145f80613c15565b613c7c90613c62613a9c565b505f90613c76613c7061132d565b92612cc2565b906149c4565b5090565b90613cb294939291613cad613ca8613ca1613c9c846006613334565b61334a565b339061658d565b6135c4565b613cb4565b565b91613cc6949293913391929394616746565b565b90613cd594939291613c80565b565b90613cf7613cf2613cfc93613cea613bcb565b506006613334565b61334a565b61658d565b90565b5f90565b613d25613d2b92613d20600193613d18613cff565b506003610fc8565b611012565b016110a3565b90565b613d3790610ffa565b90565b5f7f496e7465726e616c206f6e6c7900000000000000000000000000000000000000910152565b613d6e600d6020926109d5565b613d7781613d3a565b0190565b613d909060208101905f818303910152613d61565b90565b15613d9a57565b613da26103a2565b62461bcd60e51b815280613db860048201613d7b565b0390fd5b67ffffffffffffffff8111613dd45760208091020190565b6108c3565b90613deb613de683613dbc565b6116bc565b918252565b369037565b90613e1a613e0283613dd9565b92602080613e108693613dbc565b9201910390613df0565b565b90613e2682610d97565b811015613e37576020809102010190565b61077e565b90565b5190565b90613e4d82613e3f565b811015613e5e576020809102010190565b61077e565b90613e6d90610f01565b9052565b606090565b90565b60209181520190565b905f9291805490613e9c613e95836107e4565b8094613e79565b916001811690815f14613ef35750600114613eb7575b505050565b613ec4919293945061079f565b915f925b818410613edb57505001905f8080613eb2565b60018160209295939554848601520191019290613ec8565b92949550505060ff19168252151560200201905f8080613eb2565b90613f1891613e82565b90565b90613f3b613f3492613f2b6103a2565b93848092613f0e565b03836108d7565b565b613f4690613f1b565b90565b613f539051610f01565b90565b613f609051610554565b90565b5f7f56616c7565206f7574206f6620626f756e647300000000000000000000000000910152565b613f9760136020926109d5565b613fa081613f63565b0190565b613fbc613fca9260408301908382035f8501526109e9565b906020818303910152613f8a565b90565b92916020613fe9613ff19360408701908782035f8901526109e9565b940190610557565b565b905f929180549061400d614006836107e4565b80946109d5565b916001811690815f146140645750600114614028575b505050565b6140359192939450610817565b915f925b81841061404c57505001905f8080614023565b60018160209295939554848601520191019290614039565b92949550505060ff19168252151560200201905f8080614023565b5f7f5265717569726564206d6574726963206d697373696e67000000000000000000910152565b6140b360176020926109d5565b6140bc8161407f565b0190565b6140d86140e69260408301908382035f850152613ff3565b9060208183039101526140a6565b90565b929390936141113361410b61410561410030613d2e565b6103ef565b916103ef565b14613d93565b61412561412060088690610768565b612e93565b9461412f82613df5565b946141395f612cc2565b5b8061414d61414786610554565b91610554565b10156141a05761419b906141966141715f6141698a8590613e1c565b510151613e3c565b61418361417d82613711565b9161370b565b206141918a91849092613e43565b613e63565b612cde565b61413a565b5091949092956141af81612e9f565b6141c16141bb5f612cc2565b91610554565b11966141cb613e71565b908861464b575b6141db5f612cc2565b5b806141ef6141e98b610554565b91610554565b10156144ae5760015f8b6142e2575b509088878961421494614219575b505050612cde565b6141dc565b825f61425761424f6142609461424a614242602061423b6142659b8d90613e1c565b5101613f56565b976009611d07565b611d1d565b928790613e1c565b51015190611dae565b613018565b8887899061428f60206142885f61427d878990613e1c565b510151958790613e1c565b5101613f56565b6142c26142bc7f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd9361074c565b93611006565b936142d76142ce6103a2565b92839283613fcd565b0390a388878961420c565b9a90959291996142f15f612cc2565b5b8061430d6143076143028a612e9f565b610554565b91610554565b1015614498576143256143208d87613e43565b613f49565b61434961434361433e6143398a8690613e43565b613f49565b610f01565b91610f01565b1461435c5761435790612cde565b6142f2565b8a919b929c50896142149495988a926001908a614386602061437f898b90613e1c565b5101613f56565b6143ae6143a86143a3600161439c868890612ea3565b500161093e565b610554565b91610554565b10918888841561444e575b505050506143e3575b6143cd905b156104c2565b6143dc575b93945050506141fe565b505f6143d2565b905082825f6143f3878990613e1c565b5101519161443f61442d6144277fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361074c565b93611006565b936144366103a2565b91829182613fa4565b0390a36143cd5f9190506143c2565b61448e93945061447c61448893614476602061446f61448396600296613e1c565b5101613f56565b96612ea3565b500161093e565b610554565b91610554565b118a5f88886143b9565b5099909a87896142149495986143cd8d946143c7565b5097505092935093506144c05f612cc2565b935b846144dd6144d76144d286612e9f565b610554565b91610554565b1015614644576145036144fd60036144f6868990612ea3565b5001610965565b156104c2565b614639576145256145205f614519868990612ea3565b5001613e76565b613f3d565b61453761453182613711565b9161370b565b20905f966145445f612cc2565b5b8061456061455a61455586613e3f565b610554565b91610554565b101561462757614579614574848390613e43565b613f49565b61458b61458586610f01565b91610f01565b1461459e5761459990612cde565b614545565b50959096506145bf91506145b460015b156104c2565b6145c6575b5b612cde565b93946144c2565b82855f6145d4878590612ea3565b50019161461f61460d6146077fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361074c565b93611006565b936146166103a2565b918291826140c0565b0390a36145b9565b509590966145bf92506145b4906145ae565b94936145bf906145ba565b5050505050565b96939050614665614660839794999693612e9f565b613df5565b9761466f5f612cc2565b5b8061468b6146856146808b612e9f565b610554565b91610554565b10156146e5576146e0906146db6146b66146b15f6146aa8d8690612ea3565b5001613e76565b613f3d565b6146c86146c282613711565b9161370b565b206146d68d91849092613e43565b613e63565b612cde565b614670565b5092959194979093966141d2565b6146fb61653f565b614703614705565b565b6147166147115f6125e9565b616c3f565b565b6147206146f3565b565b61472c60a06116bc565b90565b5f90565b5f90565b5f90565b614743614722565b906020808080808661475361472f565b81520161475e612750565b815201614769612754565b815201614774614733565b81520161477f614737565b81525050565b61478d61473b565b90565b9061479a90610554565b9052565b906147a8906103b4565b9052565b906147b6906104af565b9052565b906147c490611159565b9052565b9061484761483e60026147d9614722565b946147f06147e85f830161093e565b5f8801614790565b6148086147ff60018301611049565b6020880161479e565b61482061481760018301611076565b604088016147ac565b61483861482f600183016110a3565b606088016147ba565b016110c7565b60808401613e63565b565b614852906147c8565b90565b61487a9161487061487592614868614785565b506003610fc8565b611012565b614849565b90565b5f90565b9061488b9061074c565b5f5260205260405f2090565b906148a190611006565b5f5260205260405f2090565b6148d2916148c86148cd926148c061487d565b50600c614881565b614897565b611049565b90565b6148dd616c55565b6148e5615ead565b6148f76148f1836103ef565b916103ef565b036149075761490590616c3f565b565b614922905f91829163118cdaa760e01b835260048301610cc9565b0390fd5b61494561494061494a926149386127ae565b506004613334565b61334a565b616b58565b90565b61495790516104af565b90565b61496e614969614973926125ca565b610749565b6104af565b90565b61498090516103b4565b90565b61499761499261499c926104af565b610749565b610554565b90565b6149ae6149b491939293610554565b92610554565b82018092116149bf57565b6128e4565b909291926149d0613a9c565b506149d96127ae565b506149e382616427565b93614a006149fb6149f660058690613334565b61334a565b616b58565b92614a0d6020870161494d565b614a1f614a195f61495a565b916104af565b148015614b11575b8015614af6575b614adc57614a6886614a62614a5d6020614a56614a515f614ac59b9c9d01614976565b613624565b930161494d565b614983565b906128f8565b9180614a83614a7d614a7861132d565b610554565b91610554565b115f14614ad75750614a9361132d565b5b614a9f84829061499f565b614ab1614aab88610554565b91610554565b115f14614ac85750845b9092909192616c8b565b91565b614ad2908461499f565b614abb565b614a94565b5050509150614af2614aed5f612cc2565b613ada565b9190565b5082614b0a614b0486610554565b91610554565b1015614a2e565b5083614b25614b1f5f612cc2565b91610554565b14614a27565b614b3c90614b3761653f565b614b3e565b565b614b4990600a61269a565b565b614b5490614b2b565b565b5f90565b614b62614b56565b50614b6c5f6125bd565b90565b5090565b9190811015614b83576020020190565b61077e565b35614b92816103fb565b90565b5f80fd5b60e01b90565b5f910312614ba957565b6103ac565b916020614bcf929493614bc860408201965f830190610c21565b0190610cbc565b565b614bd96103a2565b3d5f823e3d90fd5b90929192614bee5f612cc2565b5b80614c0c614c06614c01858990614b6f565b610554565b91610554565b1015614cbb57614c1b30613d2e565b9063ba1fb10384614c36614c31868a8691614b73565b614b88565b93803b15614cb657614c5b5f8094614c66614c4f6103a2565b98899687958694614b99565b845260048401614bae565b03925af1918215614cb157614c8092614c85575b50612cde565b614bef565b614ca4905f3d8111614caa575b614c9c81836108d7565b810190614b9f565b5f614c7a565b503d614c92565b614bd1565b614b95565b5050509050565b5f7f4e6f7420736c617368696e67206f7261636c6500000000000000000000000000910152565b614cf660136020926109d5565b614cff81614cc2565b0190565b614d189060208101905f818303910152614ce9565b90565b15614d2257565b614d2a6103a2565b62461bcd60e51b815280614d4060048201614d03565b0390fd5b5f7f4f70657261746f7220756e6b6e6f776e00000000000000000000000000000000910152565b614d7860106020926109d5565b614d8181614d44565b0190565b614d9a9060208101905f818303910152614d6b565b90565b15614da457565b614dac6103a2565b62461bcd60e51b815280614dc260048201614d85565b0390fd5b90565b90614ddc67ffffffffffffffff91612677565b9181191691161790565b90565b90614dfe614df9614e059261074c565b614de6565b8254614dc9565b9055565b9190614e2381614e1c81614e28956109d5565b809561171d565b6108b9565b0190565b9091614e439260208301925f818503910152614e09565b90565b614e6b33614e65614e5f614e5a600a6125bd565b6103ef565b916103ef565b14614d1b565b614e91614e8c614e85614e8060058590613334565b61334a565b849061658d565b614d9d565b614ebd614eb2614ead614ea660038590610fc8565b8590611012565b614dc6565b60016003910161340b565b614edb614ed4614ecf60048490613334565b61334a565b8390616da7565b50614f03614ee842613640565b614efe614ef7600c8590614881565b8590614897565b614de9565b909192614f39614f337f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361074c565b93611006565b93614f4e614f456103a2565b92839283614e2c565b0390a3565b614f5d60806116bc565b90565b614f6b913691611728565b90565b52565b90614f7b906104c2565b9052565b5190565b90614f8d816109d1565b9067ffffffffffffffff821161504d57614fb182614fab85546107e4565b85612ecf565b602090601f8311600114614fe557918091614fd4935f92614fd9575b5050612a07565b90555b565b90915001515f80614fcd565b601f19831691614ff485610817565b925f5b8181106150355750916002939185600196941061501b575b50505002019055614fd7565b61502b910151601f8416906129f2565b90555f808061500f565b91936020600181928787015181550195019201614ff7565b6108c3565b9061505c91614f83565b565b61506890516104c2565b90565b906150c8606060036150ce9461508e5f82016150885f8801614f7f565b90615052565b6150a7600182016150a160208801613f56565b90613018565b6150c0600282016150ba60408801613f56565b90613018565b01920161505e565b9061306a565b565b91906150e1576150df9161506b565b565b612ba3565b9081549168010000000000000000831015615116578261510e91600161511495018155612ea3565b906150d0565b565b6108c3565b6152399561522284966152196152116151fd6151f861522b9761519e61517e6151786152349d8d9f9d6151733361516d61516761516261515d60078c906113c5565b6125bd565b6103ef565b916103ef565b14612835565b612d7b565b90612d7e565b61519761519161518c611921565b610554565b91610554565b1115612ddb565b6151bb866151b46151ae8d610554565b91610554565b1015612e6a565b6151f16151d26151cd60088490610768565b610792565b6151eb6151e56151e061156d565b610554565b91610554565b106128bb565b6008610768565b612e93565b98999692949661520b614f53565b9a614f60565b5f8a01614f6e565b60208801614790565b60408601614790565b60608401614f71565b6150e6565b565b6152699061526461525f615258615253846006613334565b61334a565b339061658d565b6135c4565b61534a565b565b5f7f43616e6e6f7420676f206f6e6c696e65207768696c6520736c61736865640000910152565b61529f601e6020926109d5565b6152a88161526b565b0190565b6152c19060208101905f818303910152615292565b90565b60401b90565b906152de68ff0000000000000000916152c4565b9181191691161790565b6152fc6152f7615301926104af565b610749565b6104af565b90565b90565b9061531c615317615323926152e8565b615304565b82546152ca565b9055565b91602061534892949361534160408201965f830190611171565b0190611171565b565b61536861536361535c60038490610fc8565b3390611012565b614dc6565b90615375600183016110a3565b918261538a6153846003611159565b91611159565b146154ae57826153a261539c5f611159565b91611159565b148015615493575b61548e576153d1906153bf600180830161340b565b60016153ca5f61495a565b9101615307565b6153ef6153e86153e360048490613334565b61334a565b3390616505565b50803361542561541f7fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361074c565b91611006565b9161542e6103a2565b806154388161044b565b0390a390339091600161547461546e7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b936154896154806103a2565b92839283615327565b0390a3565b505050565b50826154a86154a26001611159565b91611159565b146153aa565b6154b66103a2565b62461bcd60e51b8152806154cc600482016152ac565b0390fd5b6154d99061523b565b565b5f7f4e6f7420617574686f72697a6564000000000000000000000000000000000000910152565b61550f600e6020926109d5565b615518816154db565b0190565b6155319060208101905f818303910152615502565b90565b1561553b57565b6155436103a2565b62461bcd60e51b8152806155596004820161551c565b0390fd5b90565b61557461556f6155799261555d565b610749565b6103b4565b90565b5f7f496e74657276616c20746f6f2073686f72740000000000000000000000000000910152565b6155b060126020926109d5565b6155b98161557c565b0190565b6155d29060208101905f8183039101526155a3565b90565b156155dc57565b6155e46103a2565b62461bcd60e51b8152806155fa600482016155bd565b0390fd5b90565b61561561561061561a926155fe565b610749565b6104af565b90565b5f7f4d6178206d6973736564206d757374206265203e3d2031000000000000000000910152565b61565160176020926109d5565b61565a8161561d565b0190565b6156739060208101905f818303910152615644565b90565b1561567d57565b6156856103a2565b62461bcd60e51b81528061569b6004820161565e565b0390fd5b6156a960606116bc565b90565b906156c16156bc6156c89261305b565b613067565b82546133dd565b9055565b9061570e60405f615714946156ee8282016156e8848801614976565b90614de9565b6157068282016157006020880161494d565b90615307565b01920161505e565b906156ac565b565b90615720916156cc565b565b91602061574392949361573c60408201965f830190610c21565b0190611129565b565b336157786157727f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b148015615864575b61578990615534565b6157a7826157a061579a603c615560565b916103b4565b10156155d5565b6157c5836157be6157b86001615601565b916104af565b1015615676565b61581e8261580d856158046157e65f6157e060028990612287565b016122b1565b916157fb6157f261569f565b955f870161479e565b602085016147ac565b60408301614f71565b61581960028490612287565b615716565b909161584a7fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea5649261074c565b9261585f6158566103a2565b92839283615722565b0390a2565b506157893361588e61588861588361587e600787906113c5565b6125bd565b6103ef565b916103ef565b149050615780565b634e487b7160e01b5f52601260045260245ffd5b6158b66158bc91610554565b91610554565b9081156158c7570490565b615896565b6158e06158db6158e592610554565b610749565b6104af565b90565b6158fc6158f7615901926125ca565b610749565b6103b4565b90565b61592261591d61591660038490610fc8565b8490611012565b614dc6565b9061592c81616427565b615938600184016110a3565b61594b6159456003611159565b91611159565b14615b5f5761595b5f840161093e565b61596d6159675f612cc2565b91610554565b14615b59576159a361598a426159845f870161093e565b9061367f565b61599d6159985f8501614976565b613624565b906158aa565b806159b76159b160ff614983565b91610554565b115f14615b4b575060ff5b90816159e16159db6159d660018801611076565b6104af565b916104af565b116159ee575b5050505050565b6159fb8260018601615307565b615a10615a075f6158e8565b60018601614de9565b615a2e615a28615a23602085940161494d565b6104af565b916104af565b101580615b24575b615a41575b806159e7565b615a5c615a50600185016110a3565b9360016002910161340b565b615a7a615a73615a6e60048590613334565b61334a565b8590616da7565b508190849091615ac8615ab6615ab07f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d9361074c565b93611006565b93615abf6103a2565b91829182611627565b0390a39190916002615b03615afd7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93615b18615b0f6103a2565b92839283615327565b0390a35f808080615a3b565b50615b31600184016110a3565b615b44615b3e6002611159565b91611159565b1415615a36565b615b54906158cc565b6159c2565b50505050565b50505050565b606090565b67ffffffffffffffff8111615b825760208091020190565b6108c3565b90615b99615b9483615b6a565b6116bc565b918252565b615ba860806116bc565b90565b90615c12615c096003615bbc615b9e565b94615bd3615bcb5f8301610900565b5f8801614f6e565b615beb615be26001830161093e565b60208801614790565b615c03615bfa6002830161093e565b60408801614790565b01610965565b60608401614f71565b565b615c1d90615bab565b90565b90615c2a82610792565b615c3381615b87565b92615c416020850191610796565b5f915b838310615c515750505050565b60046020600192615c6185615c14565b815201920192019190615c44565b615c7890615c20565b90565b615c92615c9791615c8a615b65565b506008610768565b615c6f565b90565b615cc890615cc3615cbe615cb7615cb2846006613334565b61334a565b339061658d565b6135c4565b615d23565b565b5f7f43616e6e6f7420676f206f66666c696e65207768696c6520736c617368656400910152565b615cfe601f6020926109d5565b615d0781615cca565b0190565b615d209060208101905f818303910152615cf1565b90565b615d41615d3c615d3560038490610fc8565b3390611012565b614dc6565b90615d4e600183016110a3565b9182615d63615d5d6003611159565b91611159565b14615de957615d779060016004910161340b565b615d95615d8e615d8960048490613334565b61334a565b3390616da7565b50903390916004615dcf615dc97f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93615de4615ddb6103a2565b92839283615327565b0390a3565b615df16103a2565b62461bcd60e51b815280615e0760048201615d0b565b0390fd5b615e1490615c9a565b565b909182615e2681615e2d93611d33565b809361171d565b0190565b615e429060209493615e4993615e16565b8092611d64565b0190565b9091615e6490615e5b6103a2565b93849384615e31565b03902090565b9091615e7592615e4d565b90565b92615e9d615ea59392615e98615eaa96615e906127ae565b506009611d07565b611d1d565b919091615e6a565b61093e565b90565b615eb5614b56565b50615ec060016125bd565b90565b615ecd9051611159565b90565b90565b615ee7615ee2615eec92615ed0565b610749565b610554565b90565b60207f6c00000000000000000000000000000000000000000000000000000000000000917f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76615f8201520152565b615f4960216040926109d5565b615f5281615eef565b0190565b615f6b9060208101905f818303910152615f3c565b90565b15615f7557565b615f7d6103a2565b62461bcd60e51b815280615f9360048201615f56565b0390fd5b9061604861604361604d9333615fc8615fc2615fbd615fb8600786906113c5565b6125bd565b6103ef565b916103ef565b148015616106575b615fd990615534565b615ff7615ff2615feb60038490610fc8565b8690611012565b614849565b61600360608201615ec3565b6160166160106003611159565b91611159565b03616050575b5061603b61603461602f60058490613334565b61334a565b8590616da7565b506004613334565b61334a565b616da7565b50565b6160cc906160a061609061606385616427565b61608a616085602061607e6160795f8601614976565b613624565b930161494d565b614983565b906128f8565b61609a600a615ed3565b906128f8565b6160ab5f8301613f56565b6160bd6160b75f612cc2565b91610554565b1191826160d2575b5050615f6e565b5f61601c565b6160fd9192506160f16160f7916160eb5f429201613f56565b9061367f565b92610554565b91610554565b10155f806160c5565b50615fd93361612461611e616119614b5a565b6103ef565b916103ef565b149050615fd0565b9061615661615b9161613c613bcb565b5061615161614985616427565b946003610fc8565b611012565b614849565b6161665f8201613f56565b6161786161725f612cc2565b91610554565b146161b3576161a96161a45f61619d6161af9461619783429201613f56565b9061367f565b9401614976565b613624565b91610554565b1090565b50505f90565b6161ca906161c561653f565b6161cc565b565b6161d781600161269a565b6161df614b5a565b9061621361620d7f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e2270093611006565b91611006565b9161621c6103a2565b806162268161044b565b0390a3565b616234906161b9565b565b5f61627561627b9361626d3361626761626161625c61625760078a906113c5565b6125bd565b6103ef565b916103ef565b14612835565b926002612287565b016156ac565b565b5f7f4e6f742072656769737465726564000000000000000000000000000000000000910152565b6162b1600e6020926109d5565b6162ba8161627d565b0190565b6162d39060208101905f8183039101526162a4565b90565b156162dd57565b6162e56103a2565b62461bcd60e51b8152806162fb600482016162be565b0390fd5b61633b3361633561632f7f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b61636161635c61635561635060068590613334565b61334a565b8490616da7565b6162d6565b61637f61637861637360048490613334565b61334a565b8390616da7565b50906163b46163ae7f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e9361074c565b91611006565b916163bd6103a2565b806163c78161044b565b0390a3565b906164196164105f6163dc612743565b946163f36163eb838301611049565b83880161479e565b61640a616401838301611076565b602088016147ac565b016122b1565b60408401614f71565b565b616424906163cc565b90565b61643e6164439161643661278e565b506002612287565b61641b565b61644e5f8201614976565b61646061645a5f6158e8565b916103b4565b146164a6575b6164726020820161494d565b61648461647e5f61495a565b916104af565b1461648d575b90565b6164a161649861160f565b602083016147ac565b61648a565b6164b96164b1610c08565b5f830161479e565b616466565b6164c790610fde565b90565b6164de6164d96164e3926103e4565b610749565b610554565b90565b6164fa6164f56164ff92610554565b612677565b610f01565b90565b90565b9061653761653161652c6165275f61653c9661651f613bcb565b5001946164be565b6164ca565b6164e6565b91616502565b616e68565b90565b616547614b5a565b61656061655a616555616c55565b6103ef565b916103ef565b0361656757565b616589616572616c55565b5f91829163118cdaa760e01b835260048301610cc9565b0390fd5b906165bf6165b96165b46165af5f6165c4966165a7613bcb565b5001946164be565b6164ca565b6164e6565b91616502565b616ecb565b90565b6165e6916165dd916165d7614b56565b50616f27565b90929192616fe7565b90565b5f7f4f70657261746f7220697320736c617368656400000000000000000000000000910152565b61661d60136020926109d5565b616626816165e9565b0190565b61663f9060208101905f818303910152616610565b90565b1561664957565b6166516103a2565b62461bcd60e51b8152806166676004820161662a565b0390fd5b9061668061667b6166879261334d565b613359565b8254613002565b9055565b616694906103b4565b67ffffffffffffffff81146166a95760010190565b6128e4565b90565b6166c56166c06166ca926166ae565b610749565b6104af565b90565b9160206166ee9294936166e760408201965f830190611129565b0190610557565b565b6166f990610fde565b90565b616705906166f0565b90565b61671190610ffa565b90565b60409061673d616744949695939661673360608401985f850190610cbc565b6020830190610c21565b0190610c21565b565b949293919361676961676461675d60038990610fc8565b8790611012565b614dc6565b9361677387616427565b9361679d616783600188016110a3565b6167966167906003611159565b91611159565b1415616642565b6167bb6167b46167af60058b90613334565b61334a565b8890616505565b5061689060406167cd600189016110a3565b966167da425f8b01613018565b6168046167e88587906136fd565b6167fa6167f482613711565b9161370b565b2060028b0161666b565b6168196168105f61495a565b60018b01615307565b61683760018a0161683161682c82611049565b61668b565b90614de9565b61683f613cff565b508561685361684d5f61495a565b916104af565b145f14616b145761686a5f995b60018b910161340b565b8761687e6168786002611159565b91611159565b1480616af8575b616a8a575b0161505e565b80616a66575b616a50575b50508591859192426168df6168d96168d37f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b99461074c565b9461074c565b94611006565b946168f46168eb6103a2565b928392836166cd565b0390a48061690a61690484611159565b91611159565b036169fa575b505061691c600b6125bd565b61693661693061692b5f6125e9565b6103ef565b916103ef565b03616940575b5050565b61695a616955616950600b6125bd565b6166fc565b616708565b9163d47853b691909261696c42613640565b92813b156169f5575f6169929161699d82966169866103a2565b98899788968795614b99565b855260048501616714565b03925af190816169c9575b50155f146169c45760016169bf575b5b5f8061693c565b6169b7565b6169b8565b6169e8905f3d81116169ee575b6169e081836108d7565b810190614b9f565b5f6169a8565b503d6169d6565b614b95565b83839192616a31616a2b7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93616a46616a3d6103a2565b92839283615327565b0390a35f80616910565b616a5f918891889091926174a4565b5f8061689b565b50616a72818390612d7e565b616a84616a7e5f612cc2565b91610554565b11616896565b616aa7616aa0616a9b8d6004613334565b61334a565b8b90616505565b508a8a616add616ad77fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361074c565b91611006565b91616ae66103a2565b80616af08161044b565b0390a361688a565b5088616b0d616b076002611159565b91611159565b1415616885565b85616b28616b2260646166b1565b916104af565b105f14616b3b5761686a6001995b616860565b61686a600199616b538d8d8b908b908a928c94617158565b616b36565b616b6f5f616b7492616b686127ae565b5001616502565b617662565b90565b616b83616b8891610922565b61297e565b90565b616b9f616b9a616ba492610554565b610749565b6103e4565b90565b616bd2616bcd616bdc93616bc85f616bd795616bc1614b56565b5001616502565b6176d0565b616b77565b616b8b565b610ffa565b90565b91906008616bff910291616bf960018060a01b0384612955565b92612955565b9181191691161790565b9190616c1f616c1a616c2793611006565b612697565b908354616bdf565b9055565b616c3d91616c37614b56565b91616c09565b565b616c5390616c4e5f6001616c2b565b6176f1565b565b616c5d614b56565b503390565b616c6b90610554565b5f198114616c795760010190565b6128e4565b616c8890516103ef565b90565b93919293616c97613a9c565b50616cab616ca685849061367f565b613ada565b92616cb55f612cc2565b925b80616cca616cc488610554565b91610554565b1015616d3857616cee616ce7616ce260058690613334565b61334a565b8290616ba7565b616cfa84828a91617750565b616d0e575b50616d0990612cde565b616cb7565b616d099194616d2c616d3192616d278991849092613b01565b613b21565b616c62565b9390616cff565b509450509150616d4782613ada565b92616d515f612cc2565b5b80616d65616d5f86610554565b91610554565b1015616da157616d9c90616d97616d85616d80868490613b01565b616c7e565b616d928891849092613b01565b613b21565b612cde565b616d52565b50915050565b90616dd9616dd3616dce616dc95f616dde96616dc1613bcb565b5001946164be565b6164ca565b6164e6565b91616502565b617888565b90565b90565b5f5260205f2090565b5490565b616dfa81616ded565b821015616e1457616e0c600191616de4565b910201905f90565b61077e565b9081549168010000000000000000831015616e495782616e41916001616e4795018155616df1565b90613365565b565b6108c3565b5490565b90616e5c9061334d565b5f5260205260405f2090565b616e70613bcb565b50616e85616e7f828490616ecb565b156104c2565b5f14616ec557616ebb616ec092616ea7616ea05f8501616de1565b8290616e19565b6001616eb45f8501616e4e565b9301616e52565b613018565b600190565b50505f90565b616ee9916001616ee492616edd613bcb565b5001616e52565b61093e565b616efb616ef55f612cc2565b91610554565b141590565b5f90565b90565b616f1b616f16616f2092616f04565b610749565b610554565b90565b5f90565b919091616f32614b56565b50616f3b616f00565b50616f44613387565b50616f4e83613711565b616f61616f5b6041616f07565b91610554565b145f14616fa857616fa19192616f75613387565b50616f7e613387565b50616f87616f23565b506020810151606060408301519201515f1a909192617a07565b9192909190565b50616fb25f6125e9565b90616fc6616fc1600294613711565b6164e6565b91929190565b60041115616fd657565b611136565b90616fe582616fcc565b565b80616ffa616ff45f616fdb565b91616fdb565b145f14617005575050565b806170196170136001616fdb565b91616fdb565b145f1461703c575f63f645eedf60e01b8152806170386004820161044b565b0390fd5b8061705061704a6002616fdb565b91616fdb565b145f1461707e5761707a61706383616b77565b5f91829163fce698f760e01b835260048301610564565b0390fd5b61709161708b6003616fdb565b91616fdb565b146170995750565b6170b4905f9182916335e2f38360e21b835260048301610f11565b0390fd5b6170cc6170c76170d19261130e565b610749565b6104af565b90565b6170e06170e6916103b4565b916103b4565b90039067ffffffffffffffff82116170fa57565b6128e4565b5f7f50726f746f636f6c2076696f6c6174696f6e207265706f727465640000000000910152565b617133601b6020926109d5565b61713c816170ff565b0190565b6171559060208101905f818303910152617126565b90565b935050925061717061716a60c86170b8565b916104af565b101561717b575b5050565b61718442613640565b6171a261719d617196600c8590614881565b8590614897565b611049565b806171b56171af5f6158e8565b916103b4565b1490811561723b575b506171ca575b50617177565b6171e9906171e46171dd600c8590614881565b8590614897565b614de9565b9061721d6172177f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361074c565b91611006565b916172266103a2565b8061723081617140565b0390a35f80806171c4565b6172469150826170d4565b61725f617259617254610f7a565b6103b4565b916103b4565b10155f6171be565b90565b61727e61727961728392617267565b610749565b610554565b90565b9092919261729b617296826116fa565b6116bc565b938185526020850190828401116172b7576172b5926109de565b565b6116f6565b9080601f830112156172da578160206172d793519101617286565b90565b6105af565b905051906172ec826106f9565b565b9190916040818403126173415761730560406116bc565b925f8201519167ffffffffffffffff831161733c57617329826173359483016172bc565b5f8601526020016172df565b6020830152565b6116f2565b6116ee565b92919061735a617355826116d1565b6116bc565b93818552602080860192028101918383116173b15781905b838210617380575050505050565b815167ffffffffffffffff81116173ac576020916173a187849387016172ee565b815201910190617372565b6105af565b6105b7565b9080601f830112156173d4578160206173d193519101617346565b90565b6105af565b90602082820312617409575f82015167ffffffffffffffff81116174045761740192016173b6565b90565b6103b0565b6103ac565b60209181520190565b91906174318161742a816174369561740e565b809561171d565b6108b9565b0190565b90916174519260208301925f818503910152617417565b90565b61745e6032611551565b90565b9493916060916174a29461748d61749a9361748360808b01945f8c0190610c21565b60208a0190610cbc565b8782036040890152610e28565b940190610557565b565b916174b0818590612d7e565b6174c26174bc5f612cc2565b91610554565b1461765c576174d2818590612d7e565b6174e66174e061c35061726a565b91610554565b11617656575f6174f4613a21565b946174fe30613d2e565b6175206331e3bd1b94929461752b6175146103a2565b96879586948594614b99565b84526004840161743a565b03915afa80915f92617632575b50155f1461762957506001617624575b61755183610d97565b61756a61756461755f617454565b610554565b91610554565b115f1461761657617579617454565b5b61758330613d2e565b906365a6936e93929490823b15617611575f946175be86926175b3946175a76103a2565b998a9889978896614b99565b865260048601617461565b03925af190816175e5575b50155f146175e05760016175db575b5b565b6175d8565b6175d9565b617604905f3d811161760a575b6175fc81836108d7565b810190614b9f565b5f6175c9565b503d6175f2565b614b95565b61761f83610d97565b61757a565b505050565b90925091617548565b61764f9192503d805f833e61764781836108d7565b8101906173d9565b905f617538565b50505050565b50505050565b5f6176769161766f6127ae565b5001616e4e565b90565b5f5260205f2090565b61768b81616e4e565b8210156176a55761769d600191617679565b910201905f90565b61077e565b6176ba9060086176bf9302610c78565b6110b0565b90565b906176cd91546176aa565b90565b6176ee915f6176e8926176e1613387565b5001617682565b906176c2565b90565b6176fa5f6125bd565b617704825f61269a565b906177386177327f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e093611006565b91611006565b916177416103a2565b8061774b8161044b565b0390a3565b617758613bcb565b5061778061777a61777361776e60068590613334565b61334a565b849061658d565b156104c2565b617822576177a09161779661779b926003610fc8565b611012565b614849565b6177ab5f8201613f56565b6177bd6177b75f612cc2565b91610554565b1480156177fc575b6177f6576177eb6177e56177f1926177df5f429201613f56565b9061367f565b92610554565b91610554565b101590565b50505f90565b5061780960608201615ec3565b61781c6178166003611159565b91611159565b146177c5565b5050505f90565b61783d617838617842926155fe565b610749565b610554565b90565b634e487b7160e01b5f52603160045260245ffd5b61786281616ded565b801561788357600190039061788061787a8383616df1565b9061338b565b55565b617845565b617890613bcb565b506178a76178a2600183018490616e52565b61093e565b90816178bb6178b55f612cc2565b91610554565b14155f146179875761793992600161793492846178e25f966178dc85617829565b9061367f565b6178ff6178f0888501616e4e565b6178f986617829565b9061367f565b8161791261790c83610554565b91610554565b0361793e575b50505061792e617929868301616de1565b617859565b01616e52565b6129bf565b600190565b61797f9261797161795d61795761797a948c8901617682565b906176c2565b9361796b85918c8901617682565b90613365565b91858501616e52565b613018565b5f8080617918565b5050505f90565b90565b6179a56179a06179aa9261798e565b610749565b610554565b90565b6179e26179e9946179d86060949897956179ce608086019a5f870190610f04565b6020850190611129565b6040830190610f04565b0190610f04565b565b6179ff6179fa617a04926125ca565b612677565b610f01565b90565b939293617a12614b56565b50617a1b616f00565b50617a24613387565b50617a2e85616b77565b617a60617a5a7f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0617991565b91610554565b11617aed5790617a83602094955f94939293617a7a6103a2565b948594856179ad565b838052039060015afa15617ae857617a9b5f51612677565b80617ab6617ab0617aab5f6125e9565b6103ef565b916103ef565b14617acc575f91617ac65f6179eb565b91929190565b50617ad65f6125e9565b600191617ae25f6179eb565b91929190565b614bd1565b505050617af95f6125e9565b906003929192919056fea164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\xC0`@R4a\0eWa\0\x1Aa\0\x14a\x019V[\x90a\x02\x16V[a\0\"a\0jV[a{\x10a\x04\xD3\x829`\x80Q\x81\x81\x81a\x0E\xDF\x01Ra96\x01R`\xA0Q\x81\x81\x81a\x14`\x01R\x81\x81a&\xCD\x01R\x81\x81a47\x01R\x81\x81aWN\x01Rac\x0B\x01Ra{\x10\x90\xF3[a\0pV[`@Q\x90V[_\x80\xFD[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\0\x9C\x90a\0tV[\x81\x01\x90\x81\x10`\x01\x80`@\x1B\x03\x82\x11\x17a\0\xB4W`@RV[a\0~V[\x90a\0\xCCa\0\xC5a\0jV[\x92\x83a\0\x92V[V[_\x80\xFD[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\0\xE6\x90a\0\xD2V[\x90V[a\0\xF2\x81a\0\xDDV[\x03a\0\xF9WV[_\x80\xFD[\x90PQ\x90a\x01\n\x82a\0\xE9V[V[\x91\x90`@\x83\x82\x03\x12a\x014W\x80a\x01(a\x011\x92_\x86\x01a\0\xFDV[\x93` \x01a\0\xFDV[\x90V[a\0\xCEV[a\x01Wa\x7F\xE3\x808\x03\x80a\x01L\x81a\0\xB9V[\x92\x839\x81\x01\x90a\x01\x0CV[\x90\x91V[\x90V[a\x01ra\x01ma\x01w\x92a\0\xD2V[a\x01[V[a\0\xD2V[\x90V[a\x01\x83\x90a\x01^V[\x90V[a\x01\x8F\x90a\x01zV[\x90V[\x90V[a\x01\x9E\x90a\x01\x92V[\x90RV[\x90V[a\x01\xAE\x90a\x01\xA2V[\x90RV[a\x01\xBB\x90a\0\xDDV[\x90RV[\x90\x95\x94\x92a\x02\n\x94a\x01\xF9a\x02\x03\x92a\x01\xEF`\x80\x96a\x01\xE5`\xA0\x88\x01\x9C_\x89\x01\x90a\x01\x95V[` \x87\x01\x90a\x01\x95V[`@\x85\x01\x90a\x01\x95V[``\x83\x01\x90a\x01\xA5V[\x01\x90a\x01\xB2V[V[` \x01\x90V[Q\x90V[\x90a\x02 \x90a\x02\xD3V[`\xA0R\x7F\x8Bs\xC3\xC6\x9B\xB8\xFE=Q.\xCCL\xF7Y\xCCy#\x9F{\x17\x9B\x0F\xFA\xCA\xA9\xA7]R+9@\x0Fa\x02\xBB\x7F6\xFF\xC2X\xC8e\x19:\xE1\x0C<\xF6@E\n\xB7r\xFD\xB8\xDA\x1D\xFC\xAExb\xAD\x12\x05\xA5V\x7FL\x91a\x02\xAC\x7F\xC8\x9E\xFD\xAAT\xC0\xF2\x0Cz\xDFa(\x82\xDF\tP\xF5\xA9Qc~\x03\x07\xCD\xCBLg/)\x8B\x8B\xC6Fa\x02\x970a\x01\x86V[\x91a\x02\xA0a\0jV[\x96\x87\x95` \x87\x01a\x01\xBFV[` \x82\x01\x81\x03\x82R\x03\x82a\0\x92V[a\x02\xCDa\x02\xC7\x82a\x02\x12V[\x91a\x02\x0CV[ `\x80RV[a\x02\xDC\x90a\x03\x1EV[V[\x90V[a\x02\xF5a\x02\xF0a\x02\xFA\x92a\x02\xDEV[a\x01[V[a\0\xD2V[\x90V[a\x03\x06\x90a\x02\xE1V[\x90V[\x91\x90a\x03\x1C\x90_` \x85\x01\x94\x01\x90a\x01\xB2V[V[\x80a\x039a\x033a\x03._a\x02\xFDV[a\0\xDDV[\x91a\0\xDDV[\x14a\x03IWa\x03G\x90a\x03\xE7V[V[a\x03la\x03U_a\x02\xFDV[_\x91\x82\x91c\x1EO\xBD\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x03\tV[\x03\x90\xFD[\x1B\x90V[\x91\x90`\x08a\x03\x94\x91\x02\x91a\x03\x8E`\x01\x80`\xA0\x1B\x03\x84a\x03pV[\x92a\x03pV[\x91\x81\x19\x16\x91\x16\x17\x90V[a\x03\xA7\x90a\x01zV[\x90V[\x90V[\x91\x90a\x03\xC3a\x03\xBEa\x03\xCB\x93a\x03\x9EV[a\x03\xAAV[\x90\x83Ta\x03tV[\x90UV[_\x90V[a\x03\xE5\x91a\x03\xDFa\x03\xCFV[\x91a\x03\xADV[V[a\x03\xFB\x90a\x03\xF6_`\x01a\x03\xD3V[a\x04sV[V[_\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x04\x19a\x04\x1E\x91a\x03\xFDV[a\x04\x02V[\x90V[a\x04+\x90Ta\x04\rV[\x90V[_\x1B\x90V[\x90a\x04D`\x01\x80`\xA0\x1B\x03\x91a\x04.V[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a\x04ca\x04^a\x04j\x92a\x03\x9EV[a\x03\xAAV[\x82Ta\x043V[\x90UV[_\x01\x90V[a\x04|_a\x04!V[a\x04\x86\x82_a\x04NV[\x90a\x04\xBAa\x04\xB4\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x03\x9EV[\x91a\x03\x9EV[\x91a\x04\xC3a\0jV[\x80a\x04\xCD\x81a\x04nV[\x03\x90\xA3V\xFE`\x80`@R`\x046\x10\x15a\0\x13W[a%#V[a\0\x1D_5a\x03\x9CV[\x80c\x05w\x85P\x14a\x03\x97W\x80c\x07X#o\x14a\x03\x92W\x80c\x0Cviz\x14a\x03\x8DW\x80c\x19\x1C\xBD\x1A\x14a\x03\x88W\x80c\x1E\x8F^\xE5\x14a\x03\x83W\x80c \x81)V\x14a\x03~W\x80c\"\xF1\xEC\x93\x14a\x03yW\x80c+\xF4\xD6\xA7\x14a\x03tW\x80c,\x95v\x88\x14a\x03oW\x80c-\xAE\x18\x85\x14a\x03jW\x80c/K\xD7\xB8\x14a\x03eW\x80c1\xE3\xBD\x1B\x14a\x03`W\x80c6D\xE5\x15\x14a\x03[W\x80c:\xC3\xCB\xE6\x14a\x03VW\x80c>n4\xA7\x14a\x03QW\x80c?\xD6,m\x14a\x03LW\x80c@#Z\x9C\x14a\x03GW\x80cH\xF4\xDA \x14a\x03BW\x80cV\x85\xCFh\x14a\x03=W\x80cV\xC4\xE1}\x14a\x038W\x80cY\xDC\xEA\x12\x14a\x033W\x80cZ\x93m\xC6\x14a\x03.W\x80c\\\xCE\x98\xA6\x14a\x03)W\x80c`vC\x9C\x14a\x03$W\x80c`\xCF\t\x91\x14a\x03\x1FW\x80ca\xD6\xB8l\x14a\x03\x1AW\x80cb\xC7\xE8\xFC\x14a\x03\x15W\x80ce\xA6\x93n\x14a\x03\x10W\x80ck\xFE\x06\xA6\x14a\x03\x0BW\x80cqP\x18\xA6\x14a\x03\x06W\x80cq\xE78\x8C\x14a\x03\x01W\x80cv9\xD2'\x14a\x02\xFCW\x80cy\xBAP\x97\x14a\x02\xF7W\x80c{\x9Fd\xB2\x14a\x02\xF2W\x80c\x81\xBE\xAC.\x14a\x02\xEDW\x80c\x84\xEFs\"\x14a\x02\xE8W\x80c\x8D\xA5\xCB[\x14a\x02\xE3W\x80c\x96hl\x1E\x14a\x02\xDEW\x80c\x9C\xBD\xAE\"\x14a\x02\xD9W\x80c\xAD\xFF\x83\x0C\x14a\x02\xD4W\x80c\xAEG\n\x85\x14a\x02\xCFW\x80c\xB0t\xE9\xDD\x14a\x02\xCAW\x80c\xB9\x9FgY\x14a\x02\xC5W\x80c\xBA\x1F\xB1\x03\x14a\x02\xC0W\x80c\xC1\xEF\x9D\xDF\x14a\x02\xBBW\x80c\xC5\xD9`\xBB\x14a\x02\xB6W\x80c\xCF\xE3GI\x14a\x02\xB1W\x80c\xD5Q\x16,\x14a\x02\xACW\x80c\xDACZ|\x14a\x02\xA7W\x80c\xE3\x0C9x\x14a\x02\xA2W\x80c\xE6\\\xAF\xCB\x14a\x02\x9DW\x80c\xEE\x1C\x03\x90\x14a\x02\x98W\x80c\xF2\xFD\xE3\x8B\x14a\x02\x93W\x80c\xF9\x10\x7F;\x14a\x02\x8EW\x80c\xF9\xF1gb\x14a\x02\x89Wc\xFF\xCF\x08\xF0\x03a\0\x0EWa$\xEFV[a$\xBAV[a$WV[a#\xF7V[a#\xC1V[a#\x8DV[a#XV[a# V[a\"NV[a\"\x19V[a!\xD7V[a!\xA2V[a xV[a DV[a\x1F\xD7V[a\x1F\x9DV[a\x1E\xD2V[a\x1E\x0BV[a\x1C\x82V[a\x1B\xC8V[a\x1B\x95V[a\x1B^V[a\x1A\xC9V[a\x1A\x96V[a\x1A`V[a\x1A*V[a\x19nV[a\x199V[a\x18\xCBV[a\x16\x86V[a\x16<V[a\x15\xBAV[a\x15\x85V[a\x15\x17V[a\x14\x82V[a\x14)V[a\x13\xF4V[a\x13\x8FV[a\x13EV[a\x12\xD9V[a\x12\x05V[a\x11\xCBV[a\x0F\x93V[a\x0F&V[a\x0E\xA7V[a\r,V[a\x0C\xDEV[a\x0CCV[a\x0B\x9DV[a\njV[a\x06\xC6V[a\x06tV[a\x06@V[a\x05yV[a\x05\x1FV[a\x04PV[`\xE0\x1C\x90V[`@Q\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x03\xCA\x81a\x03\xB4V[\x03a\x03\xD1WV[_\x80\xFD[\x90P5\x90a\x03\xE2\x82a\x03\xC1V[V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x03\xF8\x90a\x03\xE4V[\x90V[a\x04\x04\x81a\x03\xEFV[\x03a\x04\x0BWV[_\x80\xFD[\x90P5\x90a\x04\x1C\x82a\x03\xFBV[V[\x91\x90`@\x83\x82\x03\x12a\x04FW\x80a\x04:a\x04C\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x04\x0FV[\x90V[a\x03\xACV[_\x01\x90V[4a\x04\x7FWa\x04ia\x04c6`\x04a\x04\x1EV[\x90a&\xBAV[a\x04qa\x03\xA2V[\x80a\x04{\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x04\x9DWa\x04\x9A\x91_\x01a\x03\xD5V[\x90V[a\x03\xACV[a\x04\xAB\x90a\x03\xB4V[\x90RV[`\xFF\x16\x90V[a\x04\xBE\x90a\x04\xAFV[\x90RV[\x15\x15\x90V[a\x04\xD0\x90a\x04\xC2V[\x90RV[\x90`@\x80a\x05\x08\x93a\x04\xEC_\x82\x01Q_\x86\x01\x90a\x04\xA2V[a\x04\xFE` \x82\x01Q` \x86\x01\x90a\x04\xB5V[\x01Q\x91\x01\x90a\x04\xC7V[V[\x91\x90a\x05\x1D\x90_``\x85\x01\x94\x01\x90a\x04\xD4V[V[4a\x05OWa\x05Ka\x05:a\x0556`\x04a\x04\x84V[a'\x99V[a\x05Ba\x03\xA2V[\x91\x82\x91\x82a\x05\nV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x05`\x90a\x05TV[\x90RV[\x91\x90a\x05w\x90_` \x85\x01\x94\x01\x90a\x05WV[V[4a\x05\xAAWa\x05\xA6a\x05\x95a\x05\x8F6`\x04a\x04\x1EV[\x90a'\xB2V[a\x05\x9Da\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x05\xF5W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x05\xF0W` \x01\x92` \x83\x02\x84\x01\x11a\x05\xEBWV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x06;Wa\x06\x13\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x066Wa\x062\x92\x01a\x05\xBBV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x06oWa\x06Ya\x06S6`\x04a\x05\xFAV[\x91a1;V[a\x06aa\x03\xA2V[\x80a\x06k\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x06\xA3Wa\x06\x8Da\x06\x876`\x04a\x04\x1EV[\x90a4+V[a\x06\x95a\x03\xA2V[\x80a\x06\x9F\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x06\xC1Wa\x06\xBE\x91_\x01a\x04\x0FV[\x90V[a\x03\xACV[4a\x06\xF4Wa\x06\xDEa\x06\xD96`\x04a\x06\xA8V[a5`V[a\x06\xE6a\x03\xA2V[\x80a\x06\xF0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x07\x02\x81a\x05TV[\x03a\x07\tWV[_\x80\xFD[\x90P5\x90a\x07\x1A\x82a\x06\xF9V[V[\x91\x90`@\x83\x82\x03\x12a\x07DW\x80a\x078a\x07A\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x07\rV[\x90V[a\x03\xACV[\x90V[a\x07`a\x07[a\x07e\x92a\x03\xB4V[a\x07IV[a\x03\xB4V[\x90V[\x90a\x07r\x90a\x07LV[_R` R`@_ \x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[T\x90V[_R` _ \x90V[_R` _ \x90V[a\x07\xB1\x81a\x07\x92V[\x82\x10\x15a\x07\xCBWa\x07\xC3`\x04\x91a\x07\x96V[\x91\x02\x01\x90_\x90V[a\x07~V[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x90`\x01`\x02\x83\x04\x92\x16\x80\x15a\x08\x04W[` \x83\x10\x14a\x07\xFFWV[a\x07\xD0V[\x91`\x7F\x16\x91a\x07\xF4V[` \x91\x81R\x01\x90V[_R` _ \x90V[\x90_\x92\x91\x80T\x90a\x08:a\x083\x83a\x07\xE4V[\x80\x94a\x08\x0EV[\x91`\x01\x81\x16\x90\x81_\x14a\x08\x91WP`\x01\x14a\x08UW[PPPV[a\x08b\x91\x92\x93\x94Pa\x08\x17V[\x91_\x92[\x81\x84\x10a\x08yWPP\x01\x90_\x80\x80a\x08PV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a\x08fV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a\x08PV[\x90a\x08\xB6\x91a\x08 V[\x90V[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\x08\xE1\x90a\x08\xB9V[\x81\x01\x90\x81\x10g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x17a\x08\xFBW`@RV[a\x08\xC3V[\x90a\t a\t\x19\x92a\t\x10a\x03\xA2V[\x93\x84\x80\x92a\x08\xACV[\x03\x83a\x08\xD7V[V[_\x1C\x90V[\x90V[a\t6a\t;\x91a\t\"V[a\t'V[\x90V[a\tH\x90Ta\t*V[\x90V[`\xFF\x16\x90V[a\t]a\tb\x91a\t\"V[a\tKV[\x90V[a\to\x90Ta\tQV[\x90V[a\t}\x90`\x08a\x07hV[\x90a\t\x87\x82a\x07\x92V[\x81\x10\x15a\t\xCDWa\t\x97\x91a\x07\xA8V[P\x90a\t\xA4_\x83\x01a\t\0V[\x91a\t\xB1`\x01\x82\x01a\t>V[\x91a\t\xCA`\x03a\t\xC3`\x02\x85\x01a\t>V[\x93\x01a\teV[\x90V[_\x80\xFD[Q\x90V[` \x91\x81R\x01\x90V[\x90\x82_\x93\x92\x82^\x01RV[a\n\x08a\n\x11` \x93a\n\x16\x93a\t\xFF\x81a\t\xD1V[\x93\x84\x80\x93a\t\xD5V[\x95\x86\x91\x01a\t\xDEV[a\x08\xB9V[\x01\x90V[a\n#\x90a\x04\xC2V[\x90RV[a\naa\nh\x94a\nWa\nL``\x95\x99\x98\x96\x99`\x80\x86\x01\x90\x86\x82\x03_\x88\x01Ra\t\xE9V[\x98` \x85\x01\x90a\x05WV[`@\x83\x01\x90a\x05WV[\x01\x90a\n\x1AV[V[4a\n\x9FWa\n\x9Ba\n\x86a\n\x806`\x04a\x07\x1CV[\x90a\trV[\x90a\n\x92\x94\x92\x94a\x03\xA2V[\x94\x85\x94\x85a\n'V[\x03\x90\xF3[a\x03\xA8V[a\n\xAD\x81a\x04\xAFV[\x03a\n\xB4WV[_\x80\xFD[\x90P5\x90a\n\xC5\x82a\n\xA4V[V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x0B\x01W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\n\xFCW` \x01\x92`\x01\x83\x02\x84\x01\x11a\n\xF7WV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90`\xC0\x83\x82\x03\x12a\x0B\x98Wa\x0B\x1E\x81_\x85\x01a\x03\xD5V[\x92a\x0B,\x82` \x83\x01a\x03\xD5V[\x92a\x0B:\x83`@\x84\x01a\n\xB8V[\x92``\x83\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0B\x93W\x81a\x0B[\x91\x85\x01a\n\xC7V[\x92\x90\x93a\x0Bk\x83`\x80\x83\x01a\x03\xD5V[\x92`\xA0\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0B\x8EWa\x0B\x8A\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xB0V[a\x03\xACV[4a\x0B\xD5Wa\x0B\xBFa\x0B\xB06`\x04a\x0B\x06V[\x96\x95\x90\x95\x94\x91\x94\x93\x92\x93a:\x0FV[a\x0B\xC7a\x03\xA2V[\x80a\x0B\xD1\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[_\x91\x03\x12a\x0B\xE4WV[a\x03\xACV[\x90V[a\x0C\0a\x0B\xFBa\x0C\x05\x92a\x0B\xE9V[a\x07IV[a\x03\xB4V[\x90V[a\x0C\x13a\x01,a\x0B\xECV[\x90V[a\x0C\x1Ea\x0C\x08V[\x90V[a\x0C*\x90a\x03\xB4V[\x90RV[\x91\x90a\x0CA\x90_` \x85\x01\x94\x01\x90a\x0C!V[V[4a\x0CsWa\x0CS6`\x04a\x0B\xDAV[a\x0Coa\x0C^a\x0C\x16V[a\x0Cfa\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x0C\x97\x90`\x08a\x0C\x9C\x93\x02a\x0CxV[a\x0C|V[\x90V[\x90a\x0C\xAA\x91Ta\x0C\x87V[\x90V[a\x0C\xB9`\x0B_\x90a\x0C\x9FV[\x90V[a\x0C\xC5\x90a\x03\xEFV[\x90RV[\x91\x90a\x0C\xDC\x90_` \x85\x01\x94\x01\x90a\x0C\xBCV[V[4a\r\x0EWa\x0C\xEE6`\x04a\x0B\xDAV[a\r\na\x0C\xF9a\x0C\xADV[a\r\x01a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[a\r\x1Ea\x01,a\x0B\xECV[\x90V[a\r)a\r\x13V[\x90V[4a\r\\Wa\r<6`\x04a\x0B\xDAV[a\rXa\rGa\r!V[a\rOa\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\r\x92W_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\r\x8DWa\r\x89\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xACV[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\r\xC9a\r\xD2` \x93a\r\xD7\x93a\r\xC0\x81a\t\xD1V[\x93\x84\x80\x93a\x08\x0EV[\x95\x86\x91\x01a\t\xDEV[a\x08\xB9V[\x01\x90V[a\r\xE4\x90a\x05TV[\x90RV[\x90a\x0E\x12\x90` \x80a\x0E\x07`@\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\xAAV[\x94\x01Q\x91\x01\x90a\r\xDBV[\x90V[\x90a\x0E\x1F\x91a\r\xE8V[\x90V[` \x01\x90V[\x90a\x0E<a\x0E5\x83a\r\x97V[\x80\x92a\r\x9BV[\x90\x81a\x0EM` \x83\x02\x84\x01\x94a\r\xA4V[\x92_\x91[\x83\x83\x10a\x0E`WPPPPP\x90V[\x90\x91\x92\x93\x94` a\x0E\x82a\x0E|\x83\x85`\x01\x95\x03\x87R\x89Qa\x0E\x15V[\x97a\x0E\"V[\x93\x01\x93\x01\x91\x93\x92\x90a\x0EQV[a\x0E\xA4\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x0E(V[\x90V[4a\x0E\xD8Wa\x0E\xD4a\x0E\xC3a\x0E\xBD6`\x04a\raV[\x90a:[V[a\x0E\xCBa\x03\xA2V[\x91\x82\x91\x82a\x0E\x8FV[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[\x90V[a\x0F\r\x90a\x0F\x01V[\x90RV[\x91\x90a\x0F$\x90_` \x85\x01\x94\x01\x90a\x0F\x04V[V[4a\x0FVWa\x0F66`\x04a\x0B\xDAV[a\x0FRa\x0FAa\x0E\xDDV[a\x0FIa\x03\xA2V[\x91\x82\x91\x82a\x0F\x11V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x0Fra\x0Fma\x0Fw\x92a\x0F[V[a\x07IV[a\x03\xB4V[\x90V[a\x0F\x85a\x0E\x10a\x0F^V[\x90V[a\x0F\x90a\x0FzV[\x90V[4a\x0F\xC3Wa\x0F\xA36`\x04a\x0B\xDAV[a\x0F\xBFa\x0F\xAEa\x0F\x88V[a\x0F\xB6a\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x90a\x0F\xD2\x90a\x07LV[_R` R`@_ \x90V[a\x0F\xF2a\x0F\xEDa\x0F\xF7\x92a\x03\xE4V[a\x07IV[a\x03\xE4V[\x90V[a\x10\x03\x90a\x0F\xDEV[\x90V[a\x10\x0F\x90a\x0F\xFAV[\x90V[\x90a\x10\x1C\x90a\x10\x06V[_R` R`@_ \x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x10Aa\x10F\x91a\t\"V[a\x10(V[\x90V[a\x10S\x90Ta\x105V[\x90V[`@\x1C\x90V[`\xFF\x16\x90V[a\x10na\x10s\x91a\x10VV[a\x10\\V[\x90V[a\x10\x80\x90Ta\x10bV[\x90V[`H\x1C\x90V[`\xFF\x16\x90V[a\x10\x9Ba\x10\xA0\x91a\x10\x83V[a\x10\x89V[\x90V[a\x10\xAD\x90Ta\x10\x8FV[\x90V[\x90V[a\x10\xBFa\x10\xC4\x91a\t\"V[a\x10\xB0V[\x90V[a\x10\xD1\x90Ta\x10\xB3V[\x90V[\x90a\x10\xE3a\x10\xE8\x92`\x03a\x0F\xC8V[a\x10\x12V[a\x10\xF3_\x82\x01a\t>V[\x91a\x11\0`\x01\x83\x01a\x10IV[\x91a\x11\r`\x01\x82\x01a\x10vV[\x91a\x11&`\x02a\x11\x1F`\x01\x85\x01a\x10\xA3V[\x93\x01a\x10\xC7V[\x90V[a\x112\x90a\x04\xAFV[\x90RV[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[`\x05\x11\x15a\x11TWV[a\x116V[\x90a\x11c\x82a\x11JV[V[a\x11n\x90a\x11YV[\x90V[a\x11z\x90a\x11eV[\x90RV[\x90\x95\x94\x92a\x11\xC9\x94a\x11\xB8a\x11\xC2\x92a\x11\xAE`\x80\x96a\x11\xA4`\xA0\x88\x01\x9C_\x89\x01\x90a\x05WV[` \x87\x01\x90a\x0C!V[`@\x85\x01\x90a\x11)V[``\x83\x01\x90a\x11qV[\x01\x90a\x0F\x04V[V[4a\x12\0Wa\x11\xFCa\x11\xE7a\x11\xE16`\x04a\x04\x1EV[\x90a\x10\xD4V[\x91a\x11\xF3\x95\x93\x95a\x03\xA2V[\x95\x86\x95\x86a\x11~V[\x03\x90\xF3[a\x03\xA8V[4a\x125Wa\x121a\x12 a\x12\x1B6`\x04a\x04\x84V[a:uV[a\x12(a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x12V\x90a\x03\xEFV[\x90RV[\x90a\x12g\x81` \x93a\x12MV[\x01\x90V[` \x01\x90V[\x90a\x12\x8Ea\x12\x88a\x12\x81\x84a\x12:V[\x80\x93a\x12>V[\x92a\x12GV[\x90_[\x81\x81\x10a\x12\x9EWPPP\x90V[\x90\x91\x92a\x12\xB7a\x12\xB1`\x01\x92\x86Qa\x12ZV[\x94a\x12kV[\x91\x01\x91\x90\x91a\x12\x91V[a\x12\xD6\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x12qV[\x90V[4a\x13\tWa\x13\x05a\x12\xF4a\x12\xEF6`\x04a\x04\x84V[a;/V[a\x12\xFCa\x03\xA2V[\x91\x82\x91\x82a\x12\xC1V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x13%a\x13 a\x13*\x92a\x13\x0EV[a\x07IV[a\x05TV[\x90V[a\x137`\xC8a\x13\x11V[\x90V[a\x13Ba\x13-V[\x90V[4a\x13uWa\x13U6`\x04a\x0B\xDAV[a\x13qa\x13`a\x13:V[a\x13ha\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x13\x8D\x90_` \x85\x01\x94\x01\x90a\n\x1AV[V[4a\x13\xC0Wa\x13\xBCa\x13\xABa\x13\xA56`\x04a\x04\x1EV[\x90a;\xCFV[a\x13\xB3a\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[\x90a\x13\xCF\x90a\x07LV[_R` R`@_ \x90V[a\x13\xF1\x90a\x13\xEC`\x07\x91_\x92a\x13\xC5V[a\x0C\x9FV[\x90V[4a\x14$Wa\x14 a\x14\x0Fa\x14\n6`\x04a\x04\x84V[a\x13\xDBV[a\x14\x17a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a\x14YWa\x14Ua\x14Da\x14?6`\x04a\x04\x84V[a<VV[a\x14La\x03\xA2V[\x91\x82\x91\x82a\x12\xC1V[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[4a\x14\xB2Wa\x14\x926`\x04a\x0B\xDAV[a\x14\xAEa\x14\x9Da\x14^V[a\x14\xA5a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[\x90`\x80\x82\x82\x03\x12a\x15\x12Wa\x14\xCE\x81_\x84\x01a\x03\xD5V[\x92a\x14\xDC\x82` \x85\x01a\x03\xD5V[\x92a\x14\xEA\x83`@\x83\x01a\n\xB8V[\x92``\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x15\rWa\x15\t\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x15IWa\x153a\x15*6`\x04a\x14\xB7V[\x93\x92\x90\x92a<\xC8V[a\x15;a\x03\xA2V[\x80a\x15E\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x15ea\x15`a\x15j\x92a\x15NV[a\x07IV[a\x05TV[\x90V[a\x15w`2a\x15QV[\x90V[a\x15\x82a\x15mV[\x90V[4a\x15\xB5Wa\x15\x956`\x04a\x0B\xDAV[a\x15\xB1a\x15\xA0a\x15zV[a\x15\xA8a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[4a\x15\xEBWa\x15\xE7a\x15\xD6a\x15\xD06`\x04a\x04\x1EV[\x90a<\xD7V[a\x15\xDEa\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x16\x07a\x16\x02a\x16\x0C\x92a\x15\xF0V[a\x07IV[a\x04\xAFV[\x90V[a\x16\x19`\x03a\x15\xF3V[\x90V[a\x16$a\x16\x0FV[\x90V[\x91\x90a\x16:\x90_` \x85\x01\x94\x01\x90a\x11)V[V[4a\x16lWa\x16L6`\x04a\x0B\xDAV[a\x16ha\x16Wa\x16\x1CV[a\x16_a\x03\xA2V[\x91\x82\x91\x82a\x16'V[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x16\x84\x90_` \x85\x01\x94\x01\x90a\x11qV[V[4a\x16\xB7Wa\x16\xB3a\x16\xA2a\x16\x9C6`\x04a\x04\x1EV[\x90a=\x03V[a\x16\xAAa\x03\xA2V[\x91\x82\x91\x82a\x16qV[\x03\x90\xF3[a\x03\xA8V[\x90a\x16\xCFa\x16\xC8a\x03\xA2V[\x92\x83a\x08\xD7V[V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x16\xE9W` \x80\x91\x02\x01\x90V[a\x08\xC3V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x17\x18Wa\x17\x14` \x91a\x08\xB9V[\x01\x90V[a\x08\xC3V[\x90\x82_\x93\x92\x827\x01RV[\x90\x92\x91\x92a\x17=a\x178\x82a\x16\xFAV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a\x17YWa\x17W\x92a\x17\x1DV[V[a\x16\xF6V[\x90\x80`\x1F\x83\x01\x12\x15a\x17|W\x81` a\x17y\x935\x91\x01a\x17(V[\x90V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x17\xD4Wa\x17\x98`@a\x16\xBCV[\x92_\x82\x015\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x17\xCFWa\x17\xBC\x82a\x17\xC8\x94\x83\x01a\x17^V[_\x86\x01R` \x01a\x07\rV[` \x83\x01RV[a\x16\xF2V[a\x16\xEEV[\x92\x91\x90a\x17\xEDa\x17\xE8\x82a\x16\xD1V[a\x16\xBCV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11a\x18DW\x81\x90[\x83\x82\x10a\x18\x13WPPPPPV[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x18?W` \x91a\x184\x87\x84\x93\x87\x01a\x17\x81V[\x81R\x01\x91\x01\x90a\x18\x05V[a\x05\xAFV[a\x05\xB7V[\x90\x80`\x1F\x83\x01\x12\x15a\x18gW\x81` a\x18d\x935\x91\x01a\x17\xD9V[\x90V[a\x05\xAFV[`\x80\x81\x83\x03\x12a\x18\xC6Wa\x18\x82\x82_\x83\x01a\x03\xD5V[\x92a\x18\x90\x83` \x84\x01a\x04\x0FV[\x92`@\x83\x015\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a\x18\xC1Wa\x18\xB5\x81a\x18\xBE\x93\x86\x01a\x18IV[\x93``\x01a\x07\rV[\x90V[a\x03\xB0V[a\x03\xACV[4a\x18\xFDWa\x18\xE7a\x18\xDE6`\x04a\x18lV[\x92\x91\x90\x91a@\xE9V[a\x18\xEFa\x03\xA2V[\x80a\x18\xF9\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x19\x19a\x19\x14a\x19\x1E\x92a\x19\x02V[a\x07IV[a\x05TV[\x90V[a\x19+`@a\x19\x05V[\x90V[a\x196a\x19!V[\x90V[4a\x19iWa\x19I6`\x04a\x0B\xDAV[a\x19ea\x19Ta\x19.V[a\x19\\a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[4a\x19\x9CWa\x19~6`\x04a\x0B\xDAV[a\x19\x86aG\x18V[a\x19\x8Ea\x03\xA2V[\x80a\x19\x98\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x19\xAA\x90a\x11eV[\x90RV[a\x19\xB7\x90a\x0F\x01V[\x90RV[\x90`\x80\x80a\x1A\x13\x93a\x19\xD3_\x82\x01Q_\x86\x01\x90a\r\xDBV[a\x19\xE5` \x82\x01Q` \x86\x01\x90a\x04\xA2V[a\x19\xF7`@\x82\x01Q`@\x86\x01\x90a\x04\xB5V[a\x1A\t``\x82\x01Q``\x86\x01\x90a\x19\xA1V[\x01Q\x91\x01\x90a\x19\xAEV[V[\x91\x90a\x1A(\x90_`\xA0\x85\x01\x94\x01\x90a\x19\xBBV[V[4a\x1A[Wa\x1AWa\x1AFa\x1A@6`\x04a\x04\x1EV[\x90aHUV[a\x1ANa\x03\xA2V[\x91\x82\x91\x82a\x1A\x15V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\x91Wa\x1A\x8Da\x1A|a\x1Av6`\x04a\x04\x1EV[\x90aH\xADV[a\x1A\x84a\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xC4Wa\x1A\xA66`\x04a\x0B\xDAV[a\x1A\xAEaH\xD5V[a\x1A\xB6a\x03\xA2V[\x80a\x1A\xC0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xF9Wa\x1A\xF5a\x1A\xE4a\x1A\xDF6`\x04a\x04\x84V[aI&V[a\x1A\xECa\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a\x1B3Wa\x1B0a\x1B\x19\x84_\x85\x01a\x03\xD5V[\x93a\x1B'\x81` \x86\x01a\x07\rV[\x93`@\x01a\x07\rV[\x90V[a\x03\xACV[\x92\x91` a\x1BTa\x1B\\\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\x12qV[\x94\x01\x90a\x05WV[V[4a\x1B\x90Wa\x1Bwa\x1Bq6`\x04a\x1A\xFEV[\x91aI\xC4V[\x90a\x1B\x8Ca\x1B\x83a\x03\xA2V[\x92\x83\x92\x83a\x1B8V[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xC3Wa\x1B\xADa\x1B\xA86`\x04a\x06\xA8V[aKKV[a\x1B\xB5a\x03\xA2V[\x80a\x1B\xBF\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xF8Wa\x1B\xD86`\x04a\x0B\xDAV[a\x1B\xF4a\x1B\xE3aKZV[a\x1B\xEBa\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1C7W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1C2W` \x01\x92` \x83\x02\x84\x01\x11a\x1C-WV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x1C}Wa\x1CU\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1CxWa\x1Ct\x92\x01a\x1B\xFDV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1C\xB1Wa\x1C\x9Ba\x1C\x956`\x04a\x1C<V[\x91aK\xE1V[a\x1C\xA3a\x03\xA2V[\x80a\x1C\xAD\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x91``\x83\x83\x03\x12a\x1D\x02Wa\x1C\xCD\x82_\x85\x01a\x03\xD5V[\x92a\x1C\xDB\x83` \x83\x01a\x04\x0FV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1C\xFDWa\x1C\xFA\x92\x01a\x17^V[\x90V[a\x03\xB0V[a\x03\xACV[\x90a\x1D\x11\x90a\x07LV[_R` R`@_ \x90V[\x90a\x1D'\x90a\x10\x06V[_R` R`@_ \x90V[\x90P\x90V[a\x1D]a\x1DT\x92` \x92a\x1DK\x81a\t\xD1V[\x94\x85\x80\x93a\x1D3V[\x93\x84\x91\x01a\t\xDEV[\x01\x90V[\x90V[a\x1Dpa\x1Du\x91a\x05TV[a\x1DaV[\x90RV[a\x1D\x89a\x1D\x90\x91` \x94\x93a\x1D8V[\x80\x92a\x1DdV[\x01\x90V[a\x1D\xA8a\x1D\x9Fa\x03\xA2V[\x92\x83\x92\x83a\x1DyV[\x03\x90 \x90V[a\x1D\xB7\x91a\x1D\x94V[\x90V[a\x1D\xCA\x90`\x08a\x1D\xCF\x93\x02a\x0CxV[a\t'V[\x90V[\x90a\x1D\xDD\x91Ta\x1D\xBAV[\x90V[\x90a\x1E\x08\x92a\x1D\xFEa\x1E\x03\x92a\x1D\xF9`\t\x95_\x96a\x1D\x07V[a\x1D\x1DV[a\x1D\xAEV[a\x1D\xD2V[\x90V[4a\x1E<Wa\x1E8a\x1E'a\x1E!6`\x04a\x1C\xB6V[\x91a\x1D\xE0V[a\x1E/a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1E{W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1EvW` \x01\x92`\x01\x83\x02\x84\x01\x11a\x1EqWV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91``\x83\x83\x03\x12a\x1E\xCDWa\x1E\x97\x82_\x85\x01a\x03\xD5V[\x92a\x1E\xA5\x83` \x83\x01a\x04\x0FV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1E\xC8Wa\x1E\xC4\x92\x01a\x1EAV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1F\x04Wa\x1E\xEEa\x1E\xE56`\x04a\x1E\x80V[\x92\x91\x90\x91aNFV[a\x1E\xF6a\x03\xA2V[\x80a\x1F\0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x1F\x12\x81a\x04\xC2V[\x03a\x1F\x19WV[_\x80\xFD[\x90P5\x90a\x1F*\x82a\x1F\tV[V[\x91\x90\x91`\xA0\x81\x84\x03\x12a\x1F\x98Wa\x1FE\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1F\x93W\x81a\x1Ff\x91\x84\x01a\x1EAV[\x92\x90\x93a\x1F\x90a\x1Fy\x84`@\x85\x01a\x07\rV[\x93a\x1F\x87\x81``\x86\x01a\x07\rV[\x93`\x80\x01a\x1F\x1DV[\x90V[a\x03\xB0V[a\x03\xACV[4a\x1F\xD2Wa\x1F\xBCa\x1F\xB06`\x04a\x1F,V[\x94\x93\x90\x93\x92\x91\x92aQ\x1BV[a\x1F\xC4a\x03\xA2V[\x80a\x1F\xCE\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a \x05Wa\x1F\xEFa\x1F\xEA6`\x04a\x04\x84V[aT\xD0V[a\x1F\xF7a\x03\xA2V[\x80a \x01\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a ?Wa <a %\x84_\x85\x01a\x03\xD5V[\x93a 3\x81` \x86\x01a\x03\xD5V[\x93`@\x01a\n\xB8V[\x90V[a\x03\xACV[4a sWa ]a W6`\x04a \nV[\x91aWEV[a ea\x03\xA2V[\x80a o\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a \xA7Wa \x91a \x8B6`\x04a\x04\x1EV[\x90aY\x04V[a \x99a\x03\xA2V[\x80a \xA3\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[\x90a!\r\x90``\x80a \xDE`\x80\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\xAAV[\x94a \xF1` \x82\x01Q` \x86\x01\x90a\r\xDBV[a!\x03`@\x82\x01Q`@\x86\x01\x90a\r\xDBV[\x01Q\x91\x01\x90a\x04\xC7V[\x90V[\x90a!\x1A\x91a \xBFV[\x90V[` \x01\x90V[\x90a!7a!0\x83a \xACV[\x80\x92a \xB0V[\x90\x81a!H` \x83\x02\x84\x01\x94a \xB9V[\x92_\x91[\x83\x83\x10a![WPPPPP\x90V[\x90\x91\x92\x93\x94` a!}a!w\x83\x85`\x01\x95\x03\x87R\x89Qa!\x10V[\x97a!\x1DV[\x93\x01\x93\x01\x91\x93\x92\x90a!LV[a!\x9F\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra!#V[\x90V[4a!\xD2Wa!\xCEa!\xBDa!\xB86`\x04a\x04\x84V[a\\{V[a!\xC5a\x03\xA2V[\x91\x82\x91\x82a!\x8AV[\x03\x90\xF3[a\x03\xA8V[4a\"\x05Wa!\xEFa!\xEA6`\x04a\x04\x84V[a^\x0BV[a!\xF7a\x03\xA2V[\x80a\"\x01\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\"\x16`\n_\x90a\x0C\x9FV[\x90V[4a\"IWa\")6`\x04a\x0B\xDAV[a\"Ea\"4a\"\nV[a\"<a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a\"\x82Wa\"~a\"ma\"d6`\x04a\x1E\x80V[\x92\x91\x90\x91a^xV[a\"ua\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90a\"\x91\x90a\x07LV[_R` R`@_ \x90V[a\"\xA9a\"\xAE\x91a\x10\x83V[a\tKV[\x90V[a\"\xBB\x90Ta\"\x9DV[\x90V[a\"\xC9\x90`\x02a\"\x87V[a\"\xD4_\x82\x01a\x10IV[\x91a\"\xEB_a\"\xE4\x81\x85\x01a\x10vV[\x93\x01a\"\xB1V[\x90V[`@\x90a#\x17a#\x1E\x94\x96\x95\x93\x96a#\r``\x84\x01\x98_\x85\x01\x90a\x0C!V[` \x83\x01\x90a\x11)V[\x01\x90a\n\x1AV[V[4a#SWa#Oa#;a#66`\x04a\x04\x84V[a\"\xBEV[a#F\x93\x91\x93a\x03\xA2V[\x93\x84\x93\x84a\"\xEEV[\x03\x90\xF3[a\x03\xA8V[4a#\x88Wa#h6`\x04a\x0B\xDAV[a#\x84a#sa^\xADV[a#{a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a#\xBCWa#\xA6a#\xA06`\x04a\x04\x1EV[\x90a_\x97V[a#\xAEa\x03\xA2V[\x80a#\xB8\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a#\xF2Wa#\xEEa#\xDDa#\xD76`\x04a\x04\x1EV[\x90aa,V[a#\xE5a\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[4a$%Wa$\x0Fa$\n6`\x04a\x06\xA8V[ab+V[a$\x17a\x03\xA2V[\x80a$!\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x91\x90`@\x83\x82\x03\x12a$RW\x80a$Fa$O\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x1F\x1DV[\x90V[a\x03\xACV[4a$\x86Wa$pa$j6`\x04a$*V[\x90ab6V[a$xa\x03\xA2V[\x80a$\x82\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x7F2r\x1F\x8D\xC6~\x95<T\r\xA9\x0Ff0Y\xC2?\xC4\x7Fp\xD1\x1E1~\xD6\xD5\xA2L\x8B\x85ct\x90V[a$\xB7a$\x8BV[\x90V[4a$\xEAWa$\xCA6`\x04a\x0B\xDAV[a$\xE6a$\xD5a$\xAFV[a$\xDDa\x03\xA2V[\x91\x82\x91\x82a\x0F\x11V[\x03\x90\xF3[a\x03\xA8V[4a%\x1EWa%\x08a%\x026`\x04a\x04\x1EV[\x90ab\xFFV[a%\x10a\x03\xA2V[\x80a%\x1A\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x7FOnly Tangle core\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%[`\x10` \x92a\t\xD5V[a%d\x81a%'V[\x01\x90V[a%}\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%NV[\x90V[\x15a%\x87WV[a%\x8Fa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a%\xA5`\x04\x82\x01a%hV[\x03\x90\xFD[a%\xB5a%\xBA\x91a\t\"V[a\x0C|V[\x90V[a%\xC7\x90Ta%\xA9V[\x90V[\x90V[a%\xE1a%\xDCa%\xE6\x92a%\xCAV[a\x07IV[a\x03\xE4V[\x90V[a%\xF2\x90a%\xCDV[\x90V[_\x7FAlready registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a&)`\x12` \x92a\t\xD5V[a&2\x81a%\xF5V[\x01\x90V[a&K\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra&\x1CV[\x90V[\x15a&UWV[a&]a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a&s`\x04\x82\x01a&6V[\x03\x90\xFD[_\x1B\x90V[\x90a&\x8D`\x01\x80`\xA0\x1B\x03\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90a&\xAFa&\xAAa&\xB6\x92a\x10\x06V[a&\x97V[\x82Ta&|V[\x90UV[a'<a'A\x92a&\xFD3a&\xF7a&\xF1\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[a'4a'\x14a'\x0F`\x07\x86\x90a\x13\xC5V[a%\xBDV[a'.a'(a'#_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14a&NV[\x91`\x07a\x13\xC5V[a&\x9AV[V[a'M``a\x16\xBCV[\x90V[_\x90V[_\x90V[_\x90V[a'da'CV[\x90` \x80\x80\x84a'ra'PV[\x81R\x01a'}a'TV[\x81R\x01a'\x88a'XV[\x81RPPV[a'\x96a'\\V[\x90V[a'\xAB\x90a'\xA5a'\x8EV[Pad'V[\x90V[_\x90V[a'\xD3a'\xD9\x92a'\xCE_\x93a'\xC6a'\xAEV[P`\x03a\x0F\xC8V[a\x10\x12V[\x01a\t>V[\x90V[_\x7FNot service owner\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(\x10`\x11` \x92a\t\xD5V[a(\x19\x81a'\xDCV[\x01\x90V[a(2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x03V[\x90V[\x15a(<WV[a(Da\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(Z`\x04\x82\x01a(\x1DV[\x03\x90\xFD[P\x90V[_\x7FToo many definitions\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(\x96`\x14` \x92a\t\xD5V[a(\x9F\x81a(bV[\x01\x90V[a(\xB8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x89V[\x90V[\x15a(\xC2WV[a(\xCAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(\xE0`\x04\x82\x01a(\xA3V[\x03\x90\xFD[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[a)\x07a)\r\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x91a)\x19\x83\x82\x02a\x05TV[\x92\x81\x84\x04\x14\x90\x15\x17\x15a)(WV[a(\xE4V[a)8\x90`\x04a(\xF8V[\x90V[\x90a)N\x90_\x19\x90` \x03`\x08\x02a\x0CxV[\x81T\x16\x90UV[\x1B\x90V[\x91\x90`\x08a)t\x91\x02\x91a)n_\x19\x84a)UV[\x92a)UV[\x91\x81\x19\x16\x91\x16\x17\x90V[a)\x92a)\x8Da)\x97\x92a\x05TV[a\x07IV[a\x05TV[\x90V[\x90V[\x91\x90a)\xB3a)\xAEa)\xBB\x93a)~V[a)\x9AV[\x90\x83Ta)YV[\x90UV[a)\xD1\x91a)\xCBa'\xAEV[\x91a)\x9DV[V[[\x81\x81\x10a)\xDFWPPV[\x80a)\xEC_`\x01\x93a)\xBFV[\x01a)\xD4V[\x90a*\x02\x90_\x19\x90`\x08\x02a\x0CxV[\x19\x16\x90V[\x81a*\x11\x91a)\xF2V[\x90`\x02\x02\x17\x90V[\x90_\x91a*0a*(\x82a\x08\x17V[\x92\x83Ta*\x07V[\x90UUV[`\x1F` \x91\x01\x04\x90V[\x91\x92\x90` \x82\x10_\x14a*\x98W`\x1F\x84\x11`\x01\x14a*hWa*b\x92\x93Pa*\x07V[\x90U[[V[P\x90a*\x8Ea*\x93\x93`\x01a*\x85a*\x7F\x85a\x08\x17V[\x92a*5V[\x82\x01\x91\x01a)\xD3V[a*\x19V[a*eV[Pa*\xCF\x82\x93a*\xA9`\x01\x94a\x08\x17V[a*\xC8a*\xB5\x85a*5V[\x82\x01\x92`\x1F\x86\x16\x80a*\xDAW[Pa*5V[\x01\x90a)\xD3V[`\x02\x02\x17\x90Ua*fV[a*\xE6\x90\x88\x86\x03a);V[_a*\xC2V[\x92\x90\x91h\x01\0\0\0\0\0\0\0\0\x82\x11a+LW` \x11_\x14a+=W` \x81\x10_\x14a+!Wa+\x1B\x91a*\x07V[\x90U[[V[`\x01\x91`\xFF\x19\x16a+1\x84a\x08\x17V[U`\x02\x02\x01\x90Ua+\x1EV[`\x01\x91P`\x02\x02\x01\x90Ua+\x1FV[a\x08\xC3V[\x90\x81Ta+]\x81a\x07\xE4V[\x90\x81\x83\x11a+\x86W[\x81\x83\x10a+tW[PPPPV[a+}\x93a*?V[_\x80\x80\x80a+nV[a+\x92\x83\x83\x83\x87a*\xECV[a+fV[_a+\xA1\x91a+QV[V[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[\x90_\x03a+\xC8Wa+\xC6\x90a+\x97V[V[a+\xA3V[`\x03_\x91a+\xDD\x83\x80\x83\x01a+\xB6V[a+\xEA\x83`\x01\x83\x01a)\xBFV[a+\xF7\x83`\x02\x83\x01a)\xBFV[\x01UV[\x90_\x03a,\rWa,\x0B\x90a+\xCDV[V[a+\xA3V[[\x81\x81\x10a,\x1EWPPV[\x80a,+_`\x04\x93a+\xFBV[\x01a,\x13V[\x90\x91\x82\x81\x10a,@W[PPPV[a,^a,Xa,Ra,i\x95a)-V[\x92a)-V[\x92a\x07\x96V[\x91\x82\x01\x91\x01\x90a,\x12V[_\x80\x80a,;V[\x90h\x01\0\0\0\0\0\0\0\0\x81\x11a,\x9AW\x81a,\x8Fa,\x98\x93a\x07\x92V[\x90\x82\x81Ua,1V[V[a\x08\xC3V[_a,\xA9\x91a,qV[V[\x90_\x03a,\xBDWa,\xBB\x90a,\x9FV[V[a+\xA3V[a,\xD6a,\xD1a,\xDB\x92a%\xCAV[a\x07IV[a\x05TV[\x90V[`\x01a,\xEA\x91\x01a\x05TV[\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x905\x90`\x01`\x80\x03\x816\x03\x03\x82\x12\x15a-\x10W\x01\x90V[a,\xEDV[\x90\x82\x10\x15a-/W` a-,\x92\x02\x81\x01\x90a,\xF9V[\x90V[a\x07~V[\x905\x90`\x01` \x03\x816\x03\x03\x82\x12\x15a-vW\x01\x805\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a-qW` \x01\x91`\x01\x82\x026\x03\x83\x13a-lWV[a,\xF5V[a,\xF1V[a,\xEDV[\x91V[P\x90V[_\x7FName too long\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-\xB6`\r` \x92a\t\xD5V[a-\xBF\x81a-\x82V[\x01\x90V[a-\xD8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-\xA9V[\x90V[\x15a-\xE2WV[a-\xEAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.\0`\x04\x82\x01a-\xC3V[\x03\x90\xFD[5a.\x0E\x81a\x06\xF9V[\x90V[_\x7FInvalid bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a.E`\x0E` \x92a\t\xD5V[a.N\x81a.\x11V[\x01\x90V[a.g\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra.8V[\x90V[\x15a.qWV[a.ya\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.\x8F`\x04\x82\x01a.RV[\x03\x90\xFD[\x90V[_R` _ \x90V[T\x90V[a.\xAC\x81a.\x9FV[\x82\x10\x15a.\xC6Wa.\xBE`\x04\x91a.\x96V[\x91\x02\x01\x90_\x90V[a\x07~V[P\x90V[\x91\x90`\x1F\x81\x11a.\xDFW[PPPV[a.\xEBa/\x10\x93a\x08\x17V[\x90` a.\xF7\x84a*5V[\x83\x01\x93\x10a/\x18W[a/\t\x90a*5V[\x01\x90a)\xD3V[_\x80\x80a.\xDAV[\x91Pa/\t\x81\x92\x90Pa/\0V[\x91a/1\x90\x82a.\xCBV[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a/\xF0Wa/U\x82a/O\x85Ta\x07\xE4V[\x85a.\xCFV[_\x90`\x1F\x83\x11`\x01\x14a/\x88W\x91\x80\x91a/w\x93_\x92a/|W[PPa*\x07V[\x90U[V[\x90\x91P\x015_\x80a/pV[`\x1F\x19\x83\x16\x91a/\x97\x85a\x08\x17V[\x92_[\x81\x81\x10a/\xD8WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10a/\xBEW[PPP\x02\x01\x90Ua/zV[a/\xCE\x91\x015`\x1F\x84\x16\x90a)\xF2V[\x90U_\x80\x80a/\xB2V[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a/\x9AV[a\x08\xC3V[\x90a0\0\x92\x91a/&V[V[\x90a0\x0E_\x19\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a0-a0(a04\x92a)~V[a)\x9AV[\x82Ta0\x02V[\x90UV[5a0B\x81a\x1F\tV[\x90V[\x90a0Q`\xFF\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[a0d\x90a\x04\xC2V[\x90V[\x90V[\x90a0\x7Fa0za0\x86\x92a0[V[a0gV[\x82Ta0EV[\x90UV[\x90a0\xE8```\x03a0\xEE\x94a0\xAE_\x82\x01a0\xA8_\x88\x01\x88a-4V[\x91a/\xF5V[a0\xC7`\x01\x82\x01a0\xC1` \x88\x01a.\x04V[\x90a0\x18V[a0\xE0`\x02\x82\x01a0\xDA`@\x88\x01a.\x04V[\x90a0\x18V[\x01\x92\x01a08V[\x90a0jV[V[\x91\x90a1\x01Wa0\xFF\x91a0\x8AV[V[a+\xA3V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15a16W\x82a1.\x91`\x01a14\x95\x01\x81Ua.\xA3V[\x90a0\xF0V[V[a\x08\xC3V[\x92\x91\x90\x92a1n3a1ha1ba1]a1X`\x07\x87\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[a1\x9Ca1|\x85\x84\x90a(^V[a1\x95a1\x8Fa1\x8Aa\x15mV[a\x05TV[\x91a\x05TV[\x11\x15a(\xBBV[a1\xB1_a1\xAC`\x08\x84\x90a\x07hV[a,\xABV[a1\xBA_a,\xC2V[[\x80a1\xD8a1\xD2a1\xCD\x88\x87\x90a(^V[a\x05TV[\x91a\x05TV[\x10\x15a2\xABWa2\xA6\x90a2/a2\x0Fa2\ta2\x03a1\xFA\x8A\x89\x87\x91a-\x15V[_\x81\x01\x90a-4V[\x90a-{V[\x90a-~V[a2(a2\"a2\x1Da\x19!V[a\x05TV[\x91a\x05TV[\x11\x15a-\xDBV[a2xa2I`@a2C\x89\x88\x86\x91a-\x15V[\x01a.\x04V[a2qa2ka2f` a2`\x8C\x8B\x89\x91a-\x15V[\x01a.\x04V[a\x05TV[\x91a\x05TV[\x10\x15a.jV[a2\xA1a2\x8Fa2\x8A`\x08\x86\x90a\x07hV[a.\x93V[a2\x9B\x88\x87\x85\x91a-\x15V[\x90a1\x06V[a,\xDEV[a1\xBBV[PPP\x90PV[_\x7FZero address\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a2\xE6`\x0C` \x92a\t\xD5V[a2\xEF\x81a2\xB2V[\x01\x90V[a3\x08\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra2\xD9V[\x90V[\x15a3\x12WV[a3\x1Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a30`\x04\x82\x01a2\xF3V[\x03\x90\xFD[\x90a3>\x90a\x07LV[_R` R`@_ \x90V[\x90V[a3V\x90a\x0F\x01V[\x90V[a3b\x90a\t\"V[\x90V[\x91\x90a3{a3va3\x83\x93a3MV[a3YV[\x90\x83Ta)YV[\x90UV[_\x90V[a3\x9D\x91a3\x97a3\x87V[\x91a3eV[V[_`\x02a3\xBE\x92a3\xB2\x83\x80\x83\x01a)\xBFV[\x82`\x01\x82\x01U\x01a3\x8BV[V[\x90_\x03a3\xD2Wa3\xD0\x90a3\x9FV[V[a+\xA3V[`H\x1B\x90V[\x90a3\xF2i\xFF\0\0\0\0\0\0\0\0\0\x91a3\xD7V[\x91\x81\x19\x16\x91\x16\x17\x90V[a4\x05\x90a\x11YV[\x90V[\x90V[\x90a4 a4\x1Ba4'\x92a3\xFCV[a4\x08V[\x82Ta3\xDDV[\x90UV[a4g3a4aa4[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[a4\x8C\x82a4\x85a4\x7Fa4z_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14\x15a3\x0BV[a4\xB2a4\xADa4\xA6a4\xA1`\x06\x85\x90a34V[a3JV[\x84\x90ae\x05V[a&NV[a4\xD1_a4\xCCa4\xC5`\x03\x85\x90a\x0F\xC8V[\x85\x90a\x10\x12V[a3\xC0V[a4\xF4`\x02`\x01a4\xEEa4\xE7`\x03\x86\x90a\x0F\xC8V[\x86\x90a\x10\x12V[\x01a4\x0BV[\x90a5(a5\"\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK\x93a\x07LV[\x91a\x10\x06V[\x91a51a\x03\xA2V[\x80a5;\x81a\x04KV[\x03\x90\xA3V[a5Q\x90a5Lae?V[a5SV[V[a5^\x90`\x0Ba&\x9AV[V[a5i\x90a5@V[V[_\x7FNot registered operator\0\0\0\0\0\0\0\0\0\x91\x01RV[a5\x9F`\x17` \x92a\t\xD5V[a5\xA8\x81a5kV[\x01\x90V[a5\xC1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra5\x92V[\x90V[\x15a5\xCBWV[a5\xD3a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a5\xE9`\x04\x82\x01a5\xACV[\x03\x90\xFD[\x90a6\"\x97\x96\x95\x94\x93\x92\x91a6\x1Da6\x18a6\x11a6\x0C\x84`\x06a34V[a3JV[3\x90ae\x8DV[a5\xC4V[a8cV[V[a68a63a6=\x92a\x03\xB4V[a\x07IV[a\x05TV[\x90V[a6Ta6Oa6Y\x92a\x05TV[a\x07IV[a\x03\xB4V[\x90V[\x91` a6}\x92\x94\x93a6v`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x0C!V[V[a6\x8Ea6\x94\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x82\x03\x91\x82\x11a6\x9FWV[a(\xE4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a6\xC2Wa6\xBE` \x91a\x08\xB9V[\x01\x90V[a\x08\xC3V[\x90\x92\x91\x92a6\xDCa6\xD7\x82a6\xA4V[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a6\xF8Wa6\xF6\x92a\x17\x1DV[V[a\x16\xF6V[a7\x08\x916\x91a6\xC7V[\x90V[` \x01\x90V[Q\x90V[\x94\x92\x90\x97\x96\x95\x93\x91`\xE0\x86\x01\x98_\x87\x01a7.\x91a\x0F\x04V[` \x86\x01a7;\x91a\x0C\xBCV[`@\x85\x01a7H\x91a\x0C!V[``\x84\x01a7U\x91a\x0C!V[`\x80\x83\x01a7b\x91a\x11)V[`\xA0\x82\x01a7o\x91a\x0F\x04V[`\xC0\x01a7{\x91a\x0C!V[V[_a\x19\x01`\xF0\x1B\x91\x01RV[a7\x95`\x02\x80\x92a\x1D3V[a7\x9E\x81a7}V[\x01\x90V[\x90V[a7\xB1a7\xB6\x91a\x0F\x01V[a7\xA2V[\x90RV[` \x80\x93\x92a7\xD5a7\xCEa7\xDD\x94a7\x89V[\x80\x92a7\xA5V[\x01\x80\x92a7\xA5V[\x01\x90V[_\x7FInvalid signature\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a8\x15`\x11` \x92a\t\xD5V[a8\x1E\x81a7\xE1V[\x01\x90V[a87\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra8\x08V[\x90V[\x15a8AWV[a8Ia\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a8_`\x04\x82\x01a8\"V[\x03\x90\xFD[\x91\x92\x93\x94\x97\x96\x90\x95\x97\x80a8\x7Fa8yBa\x05TV[\x91a6$V[\x11a9\xE7Wa8\x97Ba8\x91\x83a6$V[\x90a6\x7FV[a8\xB0a8\xAAa8\xA5a\r\x13V[a6$V[\x91a\x05TV[\x11a9\xBFWa9\xBD\x97\x98a9\x94a9\xB2\x93\x85a9\x1E\x8Aa9\x0F\x8Da9\x9A\x98\x8D\x8Da8\xE6a8\xDBa$\x8BV[\x963\x99\x95\x92\x93a6\xFDV[a8\xF8a8\xF2\x82a7\x11V[\x91a7\x0BV[ \x92\x93a9\x03a\x03\xA2V[\x98\x89\x97` \x89\x01a7\x15V[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD7V[a90a9*\x82a7\x11V[\x91a7\x0BV[ a9{\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a9la9`a\x03\xA2V[\x93\x84\x92` \x84\x01a7\xBAV[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD7V[a9\x8Da9\x87\x82a7\x11V[\x91a7\x0BV[ \x92a6\xFDV[\x90ae\xC7V[a9\xACa9\xA63a\x03\xEFV[\x91a\x03\xEFV[\x14a8:V[\x933\x91\x92\x93\x94agFV[V[a9\xC8Ba6@V[\x90a9\xE3_\x92\x83\x92c\x185[u`\xE2\x1B\x84R`\x04\x84\x01a6\\V[\x03\x90\xFD[a9\xF0Ba6@V[\x90a:\x0B_\x92\x83\x92cW\xEA\x02\xE9`\xE0\x1B\x84R`\x04\x84\x01a6\\V[\x03\x90\xFD[\x90a:\x1F\x97\x96\x95\x94\x93\x92\x91a5\xEDV[V[``\x90V[\x90` \x82\x82\x03\x12a:VW_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a:QWa:N\x92\x01a\x18IV[\x90V[a\x03\xB0V[a\x03\xACV[\x90a:r\x91a:ha:!V[P\x90\x81\x01\x90a:&V[\x90V[a:\x94a:\x8Fa:\x99\x92a:\x87a'\xAEV[P`\x05a34V[a3JV[akXV[\x90V[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a:\xB9W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a:\xD0a:\xCB\x83a:\xA1V[a\x16\xBCV[\x91\x82RV[6\x907V[\x90a:\xFFa:\xE7\x83a:\xBEV[\x92` \x80a:\xF5\x86\x93a:\xA1V[\x92\x01\x91\x03\x90a:\xD5V[V[\x90a;\x0B\x82a\x12:V[\x81\x10\x15a;\x1CW` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90a;+\x90a\x03\xEFV[\x90RV[\x90a;8a:\x9CV[Pa;Ua;Pa;K`\x04\x85\x90a34V[a3JV[akXV[\x91a;_\x83a:\xDAV[\x91a;i_a,\xC2V[[\x80a;}a;w\x87a\x05TV[\x91a\x05TV[\x10\x15a;\xC4Wa;\xBF\x90a;\xBAa;\xA8a;\xA1a;\x9C`\x04\x88\x90a34V[a3JV[\x83\x90ak\xA7V[a;\xB5\x87\x91\x84\x90\x92a;\x01V[a;!V[a,\xDEV[a;jV[P\x92PP\x90V[_\x90V[\x90a;\xD8a;\xCBV[Pa;\xFA`\x01a;\xF4a;\xED`\x03\x86\x90a\x0F\xC8V[\x84\x90a\x10\x12V[\x01a\x10\xA3V[a<\x0Ca<\x06_a\x11YV[\x91a\x11YV[\x14\x91\x82\x15a<\x1AW[PP\x90V[a<;\x92P`\x01\x91a<0a<5\x92`\x03a\x0F\xC8V[a\x10\x12V[\x01a\x10\xA3V[a<Na<H`\x01a\x11YV[\x91a\x11YV[\x14_\x80a<\x15V[a<|\x90a<ba:\x9CV[P_\x90a<va<pa\x13-V[\x92a,\xC2V[\x90aI\xC4V[P\x90V[\x90a<\xB2\x94\x93\x92\x91a<\xADa<\xA8a<\xA1a<\x9C\x84`\x06a34V[a3JV[3\x90ae\x8DV[a5\xC4V[a<\xB4V[V[\x91a<\xC6\x94\x92\x93\x913\x91\x92\x93\x94agFV[V[\x90a<\xD5\x94\x93\x92\x91a<\x80V[V[\x90a<\xF7a<\xF2a<\xFC\x93a<\xEAa;\xCBV[P`\x06a34V[a3JV[ae\x8DV[\x90V[_\x90V[a=%a=+\x92a= `\x01\x93a=\x18a<\xFFV[P`\x03a\x0F\xC8V[a\x10\x12V[\x01a\x10\xA3V[\x90V[a=7\x90a\x0F\xFAV[\x90V[_\x7FInternal only\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a=n`\r` \x92a\t\xD5V[a=w\x81a=:V[\x01\x90V[a=\x90\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra=aV[\x90V[\x15a=\x9AWV[a=\xA2a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a=\xB8`\x04\x82\x01a={V[\x03\x90\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a=\xD4W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a=\xEBa=\xE6\x83a=\xBCV[a\x16\xBCV[\x91\x82RV[6\x907V[\x90a>\x1Aa>\x02\x83a=\xD9V[\x92` \x80a>\x10\x86\x93a=\xBCV[\x92\x01\x91\x03\x90a=\xF0V[V[\x90a>&\x82a\r\x97V[\x81\x10\x15a>7W` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90V[Q\x90V[\x90a>M\x82a>?V[\x81\x10\x15a>^W` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90a>m\x90a\x0F\x01V[\x90RV[``\x90V[\x90V[` \x91\x81R\x01\x90V[\x90_\x92\x91\x80T\x90a>\x9Ca>\x95\x83a\x07\xE4V[\x80\x94a>yV[\x91`\x01\x81\x16\x90\x81_\x14a>\xF3WP`\x01\x14a>\xB7W[PPPV[a>\xC4\x91\x92\x93\x94Pa\x07\x9FV[\x91_\x92[\x81\x84\x10a>\xDBWPP\x01\x90_\x80\x80a>\xB2V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a>\xC8V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a>\xB2V[\x90a?\x18\x91a>\x82V[\x90V[\x90a?;a?4\x92a?+a\x03\xA2V[\x93\x84\x80\x92a?\x0EV[\x03\x83a\x08\xD7V[V[a?F\x90a?\x1BV[\x90V[a?S\x90Qa\x0F\x01V[\x90V[a?`\x90Qa\x05TV[\x90V[_\x7FValue out of bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a?\x97`\x13` \x92a\t\xD5V[a?\xA0\x81a?cV[\x01\x90V[a?\xBCa?\xCA\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra\t\xE9V[\x90` \x81\x83\x03\x91\x01Ra?\x8AV[\x90V[\x92\x91` a?\xE9a?\xF1\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\t\xE9V[\x94\x01\x90a\x05WV[V[\x90_\x92\x91\x80T\x90a@\ra@\x06\x83a\x07\xE4V[\x80\x94a\t\xD5V[\x91`\x01\x81\x16\x90\x81_\x14a@dWP`\x01\x14a@(W[PPPV[a@5\x91\x92\x93\x94Pa\x08\x17V[\x91_\x92[\x81\x84\x10a@LWPP\x01\x90_\x80\x80a@#V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a@9V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a@#V[_\x7FRequired metric missing\0\0\0\0\0\0\0\0\0\x91\x01RV[a@\xB3`\x17` \x92a\t\xD5V[a@\xBC\x81a@\x7FV[\x01\x90V[a@\xD8a@\xE6\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra?\xF3V[\x90` \x81\x83\x03\x91\x01Ra@\xA6V[\x90V[\x92\x93\x90\x93aA\x113aA\x0BaA\x05aA\x000a=.V[a\x03\xEFV[\x91a\x03\xEFV[\x14a=\x93V[aA%aA `\x08\x86\x90a\x07hV[a.\x93V[\x94aA/\x82a=\xF5V[\x94aA9_a,\xC2V[[\x80aAMaAG\x86a\x05TV[\x91a\x05TV[\x10\x15aA\xA0WaA\x9B\x90aA\x96aAq_aAi\x8A\x85\x90a>\x1CV[Q\x01Qa><V[aA\x83aA}\x82a7\x11V[\x91a7\x0BV[ aA\x91\x8A\x91\x84\x90\x92a>CV[a>cV[a,\xDEV[aA:V[P\x91\x94\x90\x92\x95aA\xAF\x81a.\x9FV[aA\xC1aA\xBB_a,\xC2V[\x91a\x05TV[\x11\x96aA\xCBa>qV[\x90\x88aFKW[aA\xDB_a,\xC2V[[\x80aA\xEFaA\xE9\x8Ba\x05TV[\x91a\x05TV[\x10\x15aD\xAEW`\x01_\x8BaB\xE2W[P\x90\x88\x87\x89aB\x14\x94aB\x19W[PPPa,\xDEV[aA\xDCV[\x82_aBWaBOaB`\x94aBJaBB` aB;aBe\x9B\x8D\x90a>\x1CV[Q\x01a?VV[\x97`\ta\x1D\x07V[a\x1D\x1DV[\x92\x87\x90a>\x1CV[Q\x01Q\x90a\x1D\xAEV[a0\x18V[\x88\x87\x89\x90aB\x8F` aB\x88_aB}\x87\x89\x90a>\x1CV[Q\x01Q\x95\x87\x90a>\x1CV[Q\x01a?VV[aB\xC2aB\xBC\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD\x93a\x07LV[\x93a\x10\x06V[\x93aB\xD7aB\xCEa\x03\xA2V[\x92\x83\x92\x83a?\xCDV[\x03\x90\xA3\x88\x87\x89aB\x0CV[\x9A\x90\x95\x92\x91\x99aB\xF1_a,\xC2V[[\x80aC\raC\x07aC\x02\x8Aa.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aD\x98WaC%aC \x8D\x87a>CV[a?IV[aCIaCCaC>aC9\x8A\x86\x90a>CV[a?IV[a\x0F\x01V[\x91a\x0F\x01V[\x14aC\\WaCW\x90a,\xDEV[aB\xF2V[\x8A\x91\x9B\x92\x9CP\x89aB\x14\x94\x95\x98\x8A\x92`\x01\x90\x8AaC\x86` aC\x7F\x89\x8B\x90a>\x1CV[Q\x01a?VV[aC\xAEaC\xA8aC\xA3`\x01aC\x9C\x86\x88\x90a.\xA3V[P\x01a\t>V[a\x05TV[\x91a\x05TV[\x10\x91\x88\x88\x84\x15aDNW[PPPPaC\xE3W[aC\xCD\x90[\x15a\x04\xC2V[aC\xDCW[\x93\x94PPPaA\xFEV[P_aC\xD2V[\x90P\x82\x82_aC\xF3\x87\x89\x90a>\x1CV[Q\x01Q\x91aD?aD-aD'\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07LV[\x93a\x10\x06V[\x93aD6a\x03\xA2V[\x91\x82\x91\x82a?\xA4V[\x03\x90\xA3aC\xCD_\x91\x90PaC\xC2V[aD\x8E\x93\x94PaD|aD\x88\x93aDv` aDoaD\x83\x96`\x02\x96a>\x1CV[Q\x01a?VV[\x96a.\xA3V[P\x01a\t>V[a\x05TV[\x91a\x05TV[\x11\x8A_\x88\x88aC\xB9V[P\x99\x90\x9A\x87\x89aB\x14\x94\x95\x98aC\xCD\x8D\x94aC\xC7V[P\x97PP\x92\x93P\x93PaD\xC0_a,\xC2V[\x93[\x84aD\xDDaD\xD7aD\xD2\x86a.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aFDWaE\x03aD\xFD`\x03aD\xF6\x86\x89\x90a.\xA3V[P\x01a\teV[\x15a\x04\xC2V[aF9WaE%aE _aE\x19\x86\x89\x90a.\xA3V[P\x01a>vV[a?=V[aE7aE1\x82a7\x11V[\x91a7\x0BV[ \x90_\x96aED_a,\xC2V[[\x80aE`aEZaEU\x86a>?V[a\x05TV[\x91a\x05TV[\x10\x15aF'WaEyaEt\x84\x83\x90a>CV[a?IV[aE\x8BaE\x85\x86a\x0F\x01V[\x91a\x0F\x01V[\x14aE\x9EWaE\x99\x90a,\xDEV[aEEV[P\x95\x90\x96PaE\xBF\x91PaE\xB4`\x01[\x15a\x04\xC2V[aE\xC6W[[a,\xDEV[\x93\x94aD\xC2V[\x82\x85_aE\xD4\x87\x85\x90a.\xA3V[P\x01\x91aF\x1FaF\raF\x07\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07LV[\x93a\x10\x06V[\x93aF\x16a\x03\xA2V[\x91\x82\x91\x82a@\xC0V[\x03\x90\xA3aE\xB9V[P\x95\x90\x96aE\xBF\x92PaE\xB4\x90aE\xAEV[\x94\x93aE\xBF\x90aE\xBAV[PPPPPV[\x96\x93\x90PaFeaF`\x83\x97\x94\x99\x96\x93a.\x9FV[a=\xF5V[\x97aFo_a,\xC2V[[\x80aF\x8BaF\x85aF\x80\x8Ba.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aF\xE5WaF\xE0\x90aF\xDBaF\xB6aF\xB1_aF\xAA\x8D\x86\x90a.\xA3V[P\x01a>vV[a?=V[aF\xC8aF\xC2\x82a7\x11V[\x91a7\x0BV[ aF\xD6\x8D\x91\x84\x90\x92a>CV[a>cV[a,\xDEV[aFpV[P\x92\x95\x91\x94\x97\x90\x93\x96aA\xD2V[aF\xFBae?V[aG\x03aG\x05V[V[aG\x16aG\x11_a%\xE9V[al?V[V[aG aF\xF3V[V[aG,`\xA0a\x16\xBCV[\x90V[_\x90V[_\x90V[_\x90V[aGCaG\"V[\x90` \x80\x80\x80\x80\x86aGSaG/V[\x81R\x01aG^a'PV[\x81R\x01aGia'TV[\x81R\x01aGtaG3V[\x81R\x01aG\x7FaG7V[\x81RPPV[aG\x8DaG;V[\x90V[\x90aG\x9A\x90a\x05TV[\x90RV[\x90aG\xA8\x90a\x03\xB4V[\x90RV[\x90aG\xB6\x90a\x04\xAFV[\x90RV[\x90aG\xC4\x90a\x11YV[\x90RV[\x90aHGaH>`\x02aG\xD9aG\"V[\x94aG\xF0aG\xE8_\x83\x01a\t>V[_\x88\x01aG\x90V[aH\x08aG\xFF`\x01\x83\x01a\x10IV[` \x88\x01aG\x9EV[aH aH\x17`\x01\x83\x01a\x10vV[`@\x88\x01aG\xACV[aH8aH/`\x01\x83\x01a\x10\xA3V[``\x88\x01aG\xBAV[\x01a\x10\xC7V[`\x80\x84\x01a>cV[V[aHR\x90aG\xC8V[\x90V[aHz\x91aHpaHu\x92aHhaG\x85V[P`\x03a\x0F\xC8V[a\x10\x12V[aHIV[\x90V[_\x90V[\x90aH\x8B\x90a\x07LV[_R` R`@_ \x90V[\x90aH\xA1\x90a\x10\x06V[_R` R`@_ \x90V[aH\xD2\x91aH\xC8aH\xCD\x92aH\xC0aH}V[P`\x0CaH\x81V[aH\x97V[a\x10IV[\x90V[aH\xDDalUV[aH\xE5a^\xADV[aH\xF7aH\xF1\x83a\x03\xEFV[\x91a\x03\xEFV[\x03aI\x07WaI\x05\x90al?V[V[aI\"\x90_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xC9V[\x03\x90\xFD[aIEaI@aIJ\x92aI8a'\xAEV[P`\x04a34V[a3JV[akXV[\x90V[aIW\x90Qa\x04\xAFV[\x90V[aInaIiaIs\x92a%\xCAV[a\x07IV[a\x04\xAFV[\x90V[aI\x80\x90Qa\x03\xB4V[\x90V[aI\x97aI\x92aI\x9C\x92a\x04\xAFV[a\x07IV[a\x05TV[\x90V[aI\xAEaI\xB4\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x82\x01\x80\x92\x11aI\xBFWV[a(\xE4V[\x90\x92\x91\x92aI\xD0a:\x9CV[PaI\xD9a'\xAEV[PaI\xE3\x82ad'V[\x93aJ\0aI\xFBaI\xF6`\x05\x86\x90a34V[a3JV[akXV[\x92aJ\r` \x87\x01aIMV[aJ\x1FaJ\x19_aIZV[\x91a\x04\xAFV[\x14\x80\x15aK\x11W[\x80\x15aJ\xF6W[aJ\xDCWaJh\x86aJbaJ]` aJVaJQ_aJ\xC5\x9B\x9C\x9D\x01aIvV[a6$V[\x93\x01aIMV[aI\x83V[\x90a(\xF8V[\x91\x80aJ\x83aJ}aJxa\x13-V[a\x05TV[\x91a\x05TV[\x11_\x14aJ\xD7WPaJ\x93a\x13-V[[aJ\x9F\x84\x82\x90aI\x9FV[aJ\xB1aJ\xAB\x88a\x05TV[\x91a\x05TV[\x11_\x14aJ\xC8WP\x84[\x90\x92\x90\x91\x92al\x8BV[\x91V[aJ\xD2\x90\x84aI\x9FV[aJ\xBBV[aJ\x94V[PPP\x91PaJ\xF2aJ\xED_a,\xC2V[a:\xDAV[\x91\x90V[P\x82aK\naK\x04\x86a\x05TV[\x91a\x05TV[\x10\x15aJ.V[P\x83aK%aK\x1F_a,\xC2V[\x91a\x05TV[\x14aJ'V[aK<\x90aK7ae?V[aK>V[V[aKI\x90`\na&\x9AV[V[aKT\x90aK+V[V[_\x90V[aKbaKVV[PaKl_a%\xBDV[\x90V[P\x90V[\x91\x90\x81\x10\x15aK\x83W` \x02\x01\x90V[a\x07~V[5aK\x92\x81a\x03\xFBV[\x90V[_\x80\xFD[`\xE0\x1B\x90V[_\x91\x03\x12aK\xA9WV[a\x03\xACV[\x91` aK\xCF\x92\x94\x93aK\xC8`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x0C\xBCV[V[aK\xD9a\x03\xA2V[=_\x82>=\x90\xFD[\x90\x92\x91\x92aK\xEE_a,\xC2V[[\x80aL\x0CaL\x06aL\x01\x85\x89\x90aKoV[a\x05TV[\x91a\x05TV[\x10\x15aL\xBBWaL\x1B0a=.V[\x90c\xBA\x1F\xB1\x03\x84aL6aL1\x86\x8A\x86\x91aKsV[aK\x88V[\x93\x80;\x15aL\xB6WaL[_\x80\x94aLfaLOa\x03\xA2V[\x98\x89\x96\x87\x95\x86\x94aK\x99V[\x84R`\x04\x84\x01aK\xAEV[\x03\x92Z\xF1\x91\x82\x15aL\xB1WaL\x80\x92aL\x85W[Pa,\xDEV[aK\xEFV[aL\xA4\x90_=\x81\x11aL\xAAW[aL\x9C\x81\x83a\x08\xD7V[\x81\x01\x90aK\x9FV[_aLzV[P=aL\x92V[aK\xD1V[aK\x95V[PPP\x90PV[_\x7FNot slashing oracle\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aL\xF6`\x13` \x92a\t\xD5V[aL\xFF\x81aL\xC2V[\x01\x90V[aM\x18\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaL\xE9V[\x90V[\x15aM\"WV[aM*a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aM@`\x04\x82\x01aM\x03V[\x03\x90\xFD[_\x7FOperator unknown\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aMx`\x10` \x92a\t\xD5V[aM\x81\x81aMDV[\x01\x90V[aM\x9A\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaMkV[\x90V[\x15aM\xA4WV[aM\xACa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aM\xC2`\x04\x82\x01aM\x85V[\x03\x90\xFD[\x90V[\x90aM\xDCg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90aM\xFEaM\xF9aN\x05\x92a\x07LV[aM\xE6V[\x82TaM\xC9V[\x90UV[\x91\x90aN#\x81aN\x1C\x81aN(\x95a\t\xD5V[\x80\x95a\x17\x1DV[a\x08\xB9V[\x01\x90V[\x90\x91aNC\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaN\tV[\x90V[aNk3aNeaN_aNZ`\na%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14aM\x1BV[aN\x91aN\x8CaN\x85aN\x80`\x05\x85\x90a34V[a3JV[\x84\x90ae\x8DV[aM\x9DV[aN\xBDaN\xB2aN\xADaN\xA6`\x03\x85\x90a\x0F\xC8V[\x85\x90a\x10\x12V[aM\xC6V[`\x01`\x03\x91\x01a4\x0BV[aN\xDBaN\xD4aN\xCF`\x04\x84\x90a34V[a3JV[\x83\x90am\xA7V[PaO\x03aN\xE8Ba6@V[aN\xFEaN\xF7`\x0C\x85\x90aH\x81V[\x85\x90aH\x97V[aM\xE9V[\x90\x91\x92aO9aO3\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07LV[\x93a\x10\x06V[\x93aONaOEa\x03\xA2V[\x92\x83\x92\x83aN,V[\x03\x90\xA3V[aO]`\x80a\x16\xBCV[\x90V[aOk\x916\x91a\x17(V[\x90V[RV[\x90aO{\x90a\x04\xC2V[\x90RV[Q\x90V[\x90aO\x8D\x81a\t\xD1V[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11aPMWaO\xB1\x82aO\xAB\x85Ta\x07\xE4V[\x85a.\xCFV[` \x90`\x1F\x83\x11`\x01\x14aO\xE5W\x91\x80\x91aO\xD4\x93_\x92aO\xD9W[PPa*\x07V[\x90U[V[\x90\x91P\x01Q_\x80aO\xCDV[`\x1F\x19\x83\x16\x91aO\xF4\x85a\x08\x17V[\x92_[\x81\x81\x10aP5WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10aP\x1BW[PPP\x02\x01\x90UaO\xD7V[aP+\x91\x01Q`\x1F\x84\x16\x90a)\xF2V[\x90U_\x80\x80aP\x0FV[\x91\x93` `\x01\x81\x92\x87\x87\x01Q\x81U\x01\x95\x01\x92\x01aO\xF7V[a\x08\xC3V[\x90aP\\\x91aO\x83V[V[aPh\x90Qa\x04\xC2V[\x90V[\x90aP\xC8```\x03aP\xCE\x94aP\x8E_\x82\x01aP\x88_\x88\x01aO\x7FV[\x90aPRV[aP\xA7`\x01\x82\x01aP\xA1` \x88\x01a?VV[\x90a0\x18V[aP\xC0`\x02\x82\x01aP\xBA`@\x88\x01a?VV[\x90a0\x18V[\x01\x92\x01aP^V[\x90a0jV[V[\x91\x90aP\xE1WaP\xDF\x91aPkV[V[a+\xA3V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15aQ\x16W\x82aQ\x0E\x91`\x01aQ\x14\x95\x01\x81Ua.\xA3V[\x90aP\xD0V[V[a\x08\xC3V[aR9\x95aR\"\x84\x96aR\x19aR\x11aQ\xFDaQ\xF8aR+\x97aQ\x9EaQ~aQxaR4\x9D\x8D\x9F\x9DaQs3aQmaQgaQbaQ]`\x07\x8C\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[a-{V[\x90a-~V[aQ\x97aQ\x91aQ\x8Ca\x19!V[a\x05TV[\x91a\x05TV[\x11\x15a-\xDBV[aQ\xBB\x86aQ\xB4aQ\xAE\x8Da\x05TV[\x91a\x05TV[\x10\x15a.jV[aQ\xF1aQ\xD2aQ\xCD`\x08\x84\x90a\x07hV[a\x07\x92V[aQ\xEBaQ\xE5aQ\xE0a\x15mV[a\x05TV[\x91a\x05TV[\x10a(\xBBV[`\x08a\x07hV[a.\x93V[\x98\x99\x96\x92\x94\x96aR\x0BaOSV[\x9AaO`V[_\x8A\x01aOnV[` \x88\x01aG\x90V[`@\x86\x01aG\x90V[``\x84\x01aOqV[aP\xE6V[V[aRi\x90aRdaR_aRXaRS\x84`\x06a34V[a3JV[3\x90ae\x8DV[a5\xC4V[aSJV[V[_\x7FCannot go online while slashed\0\0\x91\x01RV[aR\x9F`\x1E` \x92a\t\xD5V[aR\xA8\x81aRkV[\x01\x90V[aR\xC1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaR\x92V[\x90V[`@\x1B\x90V[\x90aR\xDEh\xFF\0\0\0\0\0\0\0\0\x91aR\xC4V[\x91\x81\x19\x16\x91\x16\x17\x90V[aR\xFCaR\xF7aS\x01\x92a\x04\xAFV[a\x07IV[a\x04\xAFV[\x90V[\x90V[\x90aS\x1CaS\x17aS#\x92aR\xE8V[aS\x04V[\x82TaR\xCAV[\x90UV[\x91` aSH\x92\x94\x93aSA`@\x82\x01\x96_\x83\x01\x90a\x11qV[\x01\x90a\x11qV[V[aShaScaS\\`\x03\x84\x90a\x0F\xC8V[3\x90a\x10\x12V[aM\xC6V[\x90aSu`\x01\x83\x01a\x10\xA3V[\x91\x82aS\x8AaS\x84`\x03a\x11YV[\x91a\x11YV[\x14aT\xAEW\x82aS\xA2aS\x9C_a\x11YV[\x91a\x11YV[\x14\x80\x15aT\x93W[aT\x8EWaS\xD1\x90aS\xBF`\x01\x80\x83\x01a4\x0BV[`\x01aS\xCA_aIZV[\x91\x01aS\x07V[aS\xEFaS\xE8aS\xE3`\x04\x84\x90a34V[a3JV[3\x90ae\x05V[P\x803aT%aT\x1F\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07LV[\x91a\x10\x06V[\x91aT.a\x03\xA2V[\x80aT8\x81a\x04KV[\x03\x90\xA3\x903\x90\x91`\x01aTtaTn\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93aT\x89aT\x80a\x03\xA2V[\x92\x83\x92\x83aS'V[\x03\x90\xA3V[PPPV[P\x82aT\xA8aT\xA2`\x01a\x11YV[\x91a\x11YV[\x14aS\xAAV[aT\xB6a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aT\xCC`\x04\x82\x01aR\xACV[\x03\x90\xFD[aT\xD9\x90aR;V[V[_\x7FNot authorized\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\x0F`\x0E` \x92a\t\xD5V[aU\x18\x81aT\xDBV[\x01\x90V[aU1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaU\x02V[\x90V[\x15aU;WV[aUCa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aUY`\x04\x82\x01aU\x1CV[\x03\x90\xFD[\x90V[aUtaUoaUy\x92aU]V[a\x07IV[a\x03\xB4V[\x90V[_\x7FInterval too short\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\xB0`\x12` \x92a\t\xD5V[aU\xB9\x81aU|V[\x01\x90V[aU\xD2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaU\xA3V[\x90V[\x15aU\xDCWV[aU\xE4a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aU\xFA`\x04\x82\x01aU\xBDV[\x03\x90\xFD[\x90V[aV\x15aV\x10aV\x1A\x92aU\xFEV[a\x07IV[a\x04\xAFV[\x90V[_\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0\x91\x01RV[aVQ`\x17` \x92a\t\xD5V[aVZ\x81aV\x1DV[\x01\x90V[aVs\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaVDV[\x90V[\x15aV}WV[aV\x85a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aV\x9B`\x04\x82\x01aV^V[\x03\x90\xFD[aV\xA9``a\x16\xBCV[\x90V[\x90aV\xC1aV\xBCaV\xC8\x92a0[V[a0gV[\x82Ta3\xDDV[\x90UV[\x90aW\x0E`@_aW\x14\x94aV\xEE\x82\x82\x01aV\xE8\x84\x88\x01aIvV[\x90aM\xE9V[aW\x06\x82\x82\x01aW\0` \x88\x01aIMV[\x90aS\x07V[\x01\x92\x01aP^V[\x90aV\xACV[V[\x90aW \x91aV\xCCV[V[\x91` aWC\x92\x94\x93aW<`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x11)V[V[3aWxaWr\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14\x80\x15aXdW[aW\x89\x90aU4V[aW\xA7\x82aW\xA0aW\x9A`<aU`V[\x91a\x03\xB4V[\x10\x15aU\xD5V[aW\xC5\x83aW\xBEaW\xB8`\x01aV\x01V[\x91a\x04\xAFV[\x10\x15aVvV[aX\x1E\x82aX\r\x85aX\x04aW\xE6_aW\xE0`\x02\x89\x90a\"\x87V[\x01a\"\xB1V[\x91aW\xFBaW\xF2aV\x9FV[\x95_\x87\x01aG\x9EV[` \x85\x01aG\xACV[`@\x83\x01aOqV[aX\x19`\x02\x84\x90a\"\x87V[aW\x16V[\x90\x91aXJ\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x92a\x07LV[\x92aX_aXVa\x03\xA2V[\x92\x83\x92\x83aW\"V[\x03\x90\xA2V[PaW\x893aX\x8EaX\x88aX\x83aX~`\x07\x87\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x90PaW\x80V[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[aX\xB6aX\xBC\x91a\x05TV[\x91a\x05TV[\x90\x81\x15aX\xC7W\x04\x90V[aX\x96V[aX\xE0aX\xDBaX\xE5\x92a\x05TV[a\x07IV[a\x04\xAFV[\x90V[aX\xFCaX\xF7aY\x01\x92a%\xCAV[a\x07IV[a\x03\xB4V[\x90V[aY\"aY\x1DaY\x16`\x03\x84\x90a\x0F\xC8V[\x84\x90a\x10\x12V[aM\xC6V[\x90aY,\x81ad'V[aY8`\x01\x84\x01a\x10\xA3V[aYKaYE`\x03a\x11YV[\x91a\x11YV[\x14a[_WaY[_\x84\x01a\t>V[aYmaYg_a,\xC2V[\x91a\x05TV[\x14a[YWaY\xA3aY\x8ABaY\x84_\x87\x01a\t>V[\x90a6\x7FV[aY\x9DaY\x98_\x85\x01aIvV[a6$V[\x90aX\xAAV[\x80aY\xB7aY\xB1`\xFFaI\x83V[\x91a\x05TV[\x11_\x14a[KWP`\xFF[\x90\x81aY\xE1aY\xDBaY\xD6`\x01\x88\x01a\x10vV[a\x04\xAFV[\x91a\x04\xAFV[\x11aY\xEEW[PPPPPV[aY\xFB\x82`\x01\x86\x01aS\x07V[aZ\x10aZ\x07_aX\xE8V[`\x01\x86\x01aM\xE9V[aZ.aZ(aZ#` \x85\x94\x01aIMV[a\x04\xAFV[\x91a\x04\xAFV[\x10\x15\x80a[$W[aZAW[\x80aY\xE7V[aZ\\aZP`\x01\x85\x01a\x10\xA3V[\x93`\x01`\x02\x91\x01a4\x0BV[aZzaZsaZn`\x04\x85\x90a34V[a3JV[\x85\x90am\xA7V[P\x81\x90\x84\x90\x91aZ\xC8aZ\xB6aZ\xB0\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM\x93a\x07LV[\x93a\x10\x06V[\x93aZ\xBFa\x03\xA2V[\x91\x82\x91\x82a\x16'V[\x03\x90\xA3\x91\x90\x91`\x02a[\x03aZ\xFD\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93a[\x18a[\x0Fa\x03\xA2V[\x92\x83\x92\x83aS'V[\x03\x90\xA3_\x80\x80\x80aZ;V[Pa[1`\x01\x84\x01a\x10\xA3V[a[Da[>`\x02a\x11YV[\x91a\x11YV[\x14\x15aZ6V[a[T\x90aX\xCCV[aY\xC2V[PPPPV[PPPPV[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a[\x82W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a[\x99a[\x94\x83a[jV[a\x16\xBCV[\x91\x82RV[a[\xA8`\x80a\x16\xBCV[\x90V[\x90a\\\x12a\\\t`\x03a[\xBCa[\x9EV[\x94a[\xD3a[\xCB_\x83\x01a\t\0V[_\x88\x01aOnV[a[\xEBa[\xE2`\x01\x83\x01a\t>V[` \x88\x01aG\x90V[a\\\x03a[\xFA`\x02\x83\x01a\t>V[`@\x88\x01aG\x90V[\x01a\teV[``\x84\x01aOqV[V[a\\\x1D\x90a[\xABV[\x90V[\x90a\\*\x82a\x07\x92V[a\\3\x81a[\x87V[\x92a\\A` \x85\x01\x91a\x07\x96V[_\x91[\x83\x83\x10a\\QWPPPPV[`\x04` `\x01\x92a\\a\x85a\\\x14V[\x81R\x01\x92\x01\x92\x01\x91\x90a\\DV[a\\x\x90a\\ V[\x90V[a\\\x92a\\\x97\x91a\\\x8Aa[eV[P`\x08a\x07hV[a\\oV[\x90V[a\\\xC8\x90a\\\xC3a\\\xBEa\\\xB7a\\\xB2\x84`\x06a34V[a3JV[3\x90ae\x8DV[a5\xC4V[a]#V[V[_\x7FCannot go offline while slashed\0\x91\x01RV[a\\\xFE`\x1F` \x92a\t\xD5V[a]\x07\x81a\\\xCAV[\x01\x90V[a] \x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra\\\xF1V[\x90V[a]Aa]<a]5`\x03\x84\x90a\x0F\xC8V[3\x90a\x10\x12V[aM\xC6V[\x90a]N`\x01\x83\x01a\x10\xA3V[\x91\x82a]ca]]`\x03a\x11YV[\x91a\x11YV[\x14a]\xE9Wa]w\x90`\x01`\x04\x91\x01a4\x0BV[a]\x95a]\x8Ea]\x89`\x04\x84\x90a34V[a3JV[3\x90am\xA7V[P\x903\x90\x91`\x04a]\xCFa]\xC9\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93a]\xE4a]\xDBa\x03\xA2V[\x92\x83\x92\x83aS'V[\x03\x90\xA3V[a]\xF1a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a^\x07`\x04\x82\x01a]\x0BV[\x03\x90\xFD[a^\x14\x90a\\\x9AV[V[\x90\x91\x82a^&\x81a^-\x93a\x1D3V[\x80\x93a\x17\x1DV[\x01\x90V[a^B\x90` \x94\x93a^I\x93a^\x16V[\x80\x92a\x1DdV[\x01\x90V[\x90\x91a^d\x90a^[a\x03\xA2V[\x93\x84\x93\x84a^1V[\x03\x90 \x90V[\x90\x91a^u\x92a^MV[\x90V[\x92a^\x9Da^\xA5\x93\x92a^\x98a^\xAA\x96a^\x90a'\xAEV[P`\ta\x1D\x07V[a\x1D\x1DV[\x91\x90\x91a^jV[a\t>V[\x90V[a^\xB5aKVV[Pa^\xC0`\x01a%\xBDV[\x90V[a^\xCD\x90Qa\x11YV[\x90V[\x90V[a^\xE7a^\xE2a^\xEC\x92a^\xD0V[a\x07IV[a\x05TV[\x90V[` \x7Fl\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x7FOperator not eligible for remova_\x82\x01R\x01RV[a_I`!`@\x92a\t\xD5V[a_R\x81a^\xEFV[\x01\x90V[a_k\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra_<V[\x90V[\x15a_uWV[a_}a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a_\x93`\x04\x82\x01a_VV[\x03\x90\xFD[\x90a`Ha`Ca`M\x933a_\xC8a_\xC2a_\xBDa_\xB8`\x07\x86\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x80\x15aa\x06W[a_\xD9\x90aU4V[a_\xF7a_\xF2a_\xEB`\x03\x84\x90a\x0F\xC8V[\x86\x90a\x10\x12V[aHIV[a`\x03``\x82\x01a^\xC3V[a`\x16a`\x10`\x03a\x11YV[\x91a\x11YV[\x03a`PW[Pa`;a`4a`/`\x05\x84\x90a34V[a3JV[\x85\x90am\xA7V[P`\x04a34V[a3JV[am\xA7V[PV[a`\xCC\x90a`\xA0a`\x90a`c\x85ad'V[a`\x8Aa`\x85` a`~a`y_\x86\x01aIvV[a6$V[\x93\x01aIMV[aI\x83V[\x90a(\xF8V[a`\x9A`\na^\xD3V[\x90a(\xF8V[a`\xAB_\x83\x01a?VV[a`\xBDa`\xB7_a,\xC2V[\x91a\x05TV[\x11\x91\x82a`\xD2W[PPa_nV[_a`\x1CV[a`\xFD\x91\x92Pa`\xF1a`\xF7\x91a`\xEB_B\x92\x01a?VV[\x90a6\x7FV[\x92a\x05TV[\x91a\x05TV[\x10\x15_\x80a`\xC5V[Pa_\xD93aa$aa\x1Eaa\x19aKZV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x90Pa_\xD0V[\x90aaVaa[\x91aa<a;\xCBV[PaaQaaI\x85ad'V[\x94`\x03a\x0F\xC8V[a\x10\x12V[aHIV[aaf_\x82\x01a?VV[aaxaar_a,\xC2V[\x91a\x05TV[\x14aa\xB3Waa\xA9aa\xA4_aa\x9Daa\xAF\x94aa\x97\x83B\x92\x01a?VV[\x90a6\x7FV[\x94\x01aIvV[a6$V[\x91a\x05TV[\x10\x90V[PP_\x90V[aa\xCA\x90aa\xC5ae?V[aa\xCCV[V[aa\xD7\x81`\x01a&\x9AV[aa\xDFaKZV[\x90ab\x13ab\r\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0\x93a\x10\x06V[\x91a\x10\x06V[\x91ab\x1Ca\x03\xA2V[\x80ab&\x81a\x04KV[\x03\x90\xA3V[ab4\x90aa\xB9V[V[_abuab{\x93abm3abgabaab\\abW`\x07\x8A\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[\x92`\x02a\"\x87V[\x01aV\xACV[V[_\x7FNot registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[ab\xB1`\x0E` \x92a\t\xD5V[ab\xBA\x81ab}V[\x01\x90V[ab\xD3\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rab\xA4V[\x90V[\x15ab\xDDWV[ab\xE5a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80ab\xFB`\x04\x82\x01ab\xBEV[\x03\x90\xFD[ac;3ac5ac/\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[acaac\\acUacP`\x06\x85\x90a34V[a3JV[\x84\x90am\xA7V[ab\xD6V[ac\x7Facxacs`\x04\x84\x90a34V[a3JV[\x83\x90am\xA7V[P\x90ac\xB4ac\xAE\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E\x93a\x07LV[\x91a\x10\x06V[\x91ac\xBDa\x03\xA2V[\x80ac\xC7\x81a\x04KV[\x03\x90\xA3V[\x90ad\x19ad\x10_ac\xDCa'CV[\x94ac\xF3ac\xEB\x83\x83\x01a\x10IV[\x83\x88\x01aG\x9EV[ad\nad\x01\x83\x83\x01a\x10vV[` \x88\x01aG\xACV[\x01a\"\xB1V[`@\x84\x01aOqV[V[ad$\x90ac\xCCV[\x90V[ad>adC\x91ad6a'\x8EV[P`\x02a\"\x87V[ad\x1BV[adN_\x82\x01aIvV[ad`adZ_aX\xE8V[\x91a\x03\xB4V[\x14ad\xA6W[adr` \x82\x01aIMV[ad\x84ad~_aIZV[\x91a\x04\xAFV[\x14ad\x8DW[\x90V[ad\xA1ad\x98a\x16\x0FV[` \x83\x01aG\xACV[ad\x8AV[ad\xB9ad\xB1a\x0C\x08V[_\x83\x01aG\x9EV[adfV[ad\xC7\x90a\x0F\xDEV[\x90V[ad\xDEad\xD9ad\xE3\x92a\x03\xE4V[a\x07IV[a\x05TV[\x90V[ad\xFAad\xF5ad\xFF\x92a\x05TV[a&wV[a\x0F\x01V[\x90V[\x90V[\x90ae7ae1ae,ae'_ae<\x96ae\x1Fa;\xCBV[P\x01\x94ad\xBEV[ad\xCAV[ad\xE6V[\x91ae\x02V[anhV[\x90V[aeGaKZV[ae`aeZaeUalUV[a\x03\xEFV[\x91a\x03\xEFV[\x03aegWV[ae\x89aeralUV[_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xC9V[\x03\x90\xFD[\x90ae\xBFae\xB9ae\xB4ae\xAF_ae\xC4\x96ae\xA7a;\xCBV[P\x01\x94ad\xBEV[ad\xCAV[ad\xE6V[\x91ae\x02V[an\xCBV[\x90V[ae\xE6\x91ae\xDD\x91ae\xD7aKVV[Pao'V[\x90\x92\x91\x92ao\xE7V[\x90V[_\x7FOperator is slashed\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[af\x1D`\x13` \x92a\t\xD5V[af&\x81ae\xE9V[\x01\x90V[af?\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Raf\x10V[\x90V[\x15afIWV[afQa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80afg`\x04\x82\x01af*V[\x03\x90\xFD[\x90af\x80af{af\x87\x92a3MV[a3YV[\x82Ta0\x02V[\x90UV[af\x94\x90a\x03\xB4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x14af\xA9W`\x01\x01\x90V[a(\xE4V[\x90V[af\xC5af\xC0af\xCA\x92af\xAEV[a\x07IV[a\x04\xAFV[\x90V[\x91` af\xEE\x92\x94\x93af\xE7`@\x82\x01\x96_\x83\x01\x90a\x11)V[\x01\x90a\x05WV[V[af\xF9\x90a\x0F\xDEV[\x90V[ag\x05\x90af\xF0V[\x90V[ag\x11\x90a\x0F\xFAV[\x90V[`@\x90ag=agD\x94\x96\x95\x93\x96ag3``\x84\x01\x98_\x85\x01\x90a\x0C\xBCV[` \x83\x01\x90a\x0C!V[\x01\x90a\x0C!V[V[\x94\x92\x93\x91\x93agiagdag]`\x03\x89\x90a\x0F\xC8V[\x87\x90a\x10\x12V[aM\xC6V[\x93ags\x87ad'V[\x93ag\x9Dag\x83`\x01\x88\x01a\x10\xA3V[ag\x96ag\x90`\x03a\x11YV[\x91a\x11YV[\x14\x15afBV[ag\xBBag\xB4ag\xAF`\x05\x8B\x90a34V[a3JV[\x88\x90ae\x05V[Pah\x90`@ag\xCD`\x01\x89\x01a\x10\xA3V[\x96ag\xDAB_\x8B\x01a0\x18V[ah\x04ag\xE8\x85\x87\x90a6\xFDV[ag\xFAag\xF4\x82a7\x11V[\x91a7\x0BV[ `\x02\x8B\x01afkV[ah\x19ah\x10_aIZV[`\x01\x8B\x01aS\x07V[ah7`\x01\x8A\x01ah1ah,\x82a\x10IV[af\x8BV[\x90aM\xE9V[ah?a<\xFFV[P\x85ahSahM_aIZV[\x91a\x04\xAFV[\x14_\x14ak\x14Wahj_\x99[`\x01\x8B\x91\x01a4\x0BV[\x87ah~ahx`\x02a\x11YV[\x91a\x11YV[\x14\x80aj\xF8W[aj\x8AW[\x01aP^V[\x80ajfW[ajPW[PP\x85\x91\x85\x91\x92Bah\xDFah\xD9ah\xD3\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x94a\x07LV[\x94a\x07LV[\x94a\x10\x06V[\x94ah\xF4ah\xEBa\x03\xA2V[\x92\x83\x92\x83af\xCDV[\x03\x90\xA4\x80ai\nai\x04\x84a\x11YV[\x91a\x11YV[\x03ai\xFAW[PPai\x1C`\x0Ba%\xBDV[ai6ai0ai+_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x03ai@W[PPV[aiZaiUaiP`\x0Ba%\xBDV[af\xFCV[ag\x08V[\x91c\xD4xS\xB6\x91\x90\x92ailBa6@V[\x92\x81;\x15ai\xF5W_ai\x92\x91ai\x9D\x82\x96ai\x86a\x03\xA2V[\x98\x89\x97\x88\x96\x87\x95aK\x99V[\x85R`\x04\x85\x01ag\x14V[\x03\x92Z\xF1\x90\x81ai\xC9W[P\x15_\x14ai\xC4W`\x01ai\xBFW[[_\x80ai<V[ai\xB7V[ai\xB8V[ai\xE8\x90_=\x81\x11ai\xEEW[ai\xE0\x81\x83a\x08\xD7V[\x81\x01\x90aK\x9FV[_ai\xA8V[P=ai\xD6V[aK\x95V[\x83\x83\x91\x92aj1aj+\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93ajFaj=a\x03\xA2V[\x92\x83\x92\x83aS'V[\x03\x90\xA3_\x80ai\x10V[aj_\x91\x88\x91\x88\x90\x91\x92at\xA4V[_\x80ah\x9BV[Pajr\x81\x83\x90a-~V[aj\x84aj~_a,\xC2V[\x91a\x05TV[\x11ah\x96V[aj\xA7aj\xA0aj\x9B\x8D`\x04a34V[a3JV[\x8B\x90ae\x05V[P\x8A\x8Aaj\xDDaj\xD7\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07LV[\x91a\x10\x06V[\x91aj\xE6a\x03\xA2V[\x80aj\xF0\x81a\x04KV[\x03\x90\xA3ah\x8AV[P\x88ak\rak\x07`\x02a\x11YV[\x91a\x11YV[\x14\x15ah\x85V[\x85ak(ak\"`daf\xB1V[\x91a\x04\xAFV[\x10_\x14ak;Wahj`\x01\x99[ah`V[ahj`\x01\x99akS\x8D\x8D\x8B\x90\x8B\x90\x8A\x92\x8C\x94aqXV[ak6V[ako_akt\x92akha'\xAEV[P\x01ae\x02V[avbV[\x90V[ak\x83ak\x88\x91a\t\"V[a)~V[\x90V[ak\x9Fak\x9Aak\xA4\x92a\x05TV[a\x07IV[a\x03\xE4V[\x90V[ak\xD2ak\xCDak\xDC\x93ak\xC8_ak\xD7\x95ak\xC1aKVV[P\x01ae\x02V[av\xD0V[akwV[ak\x8BV[a\x0F\xFAV[\x90V[\x91\x90`\x08ak\xFF\x91\x02\x91ak\xF9`\x01\x80`\xA0\x1B\x03\x84a)UV[\x92a)UV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x91\x90al\x1Fal\x1Aal'\x93a\x10\x06V[a&\x97V[\x90\x83Tak\xDFV[\x90UV[al=\x91al7aKVV[\x91al\tV[V[alS\x90alN_`\x01al+V[av\xF1V[V[al]aKVV[P3\x90V[alk\x90a\x05TV[_\x19\x81\x14alyW`\x01\x01\x90V[a(\xE4V[al\x88\x90Qa\x03\xEFV[\x90V[\x93\x91\x92\x93al\x97a:\x9CV[Pal\xABal\xA6\x85\x84\x90a6\x7FV[a:\xDAV[\x92al\xB5_a,\xC2V[\x92[\x80al\xCAal\xC4\x88a\x05TV[\x91a\x05TV[\x10\x15am8Wal\xEEal\xE7al\xE2`\x05\x86\x90a34V[a3JV[\x82\x90ak\xA7V[al\xFA\x84\x82\x8A\x91awPV[am\x0EW[Pam\t\x90a,\xDEV[al\xB7V[am\t\x91\x94am,am1\x92am'\x89\x91\x84\x90\x92a;\x01V[a;!V[albV[\x93\x90al\xFFV[P\x94PP\x91PamG\x82a:\xDAV[\x92amQ_a,\xC2V[[\x80ameam_\x86a\x05TV[\x91a\x05TV[\x10\x15am\xA1Wam\x9C\x90am\x97am\x85am\x80\x86\x84\x90a;\x01V[al~V[am\x92\x88\x91\x84\x90\x92a;\x01V[a;!V[a,\xDEV[amRV[P\x91PPV[\x90am\xD9am\xD3am\xCEam\xC9_am\xDE\x96am\xC1a;\xCBV[P\x01\x94ad\xBEV[ad\xCAV[ad\xE6V[\x91ae\x02V[ax\x88V[\x90V[\x90V[_R` _ \x90V[T\x90V[am\xFA\x81am\xEDV[\x82\x10\x15an\x14Wan\x0C`\x01\x91am\xE4V[\x91\x02\x01\x90_\x90V[a\x07~V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15anIW\x82anA\x91`\x01anG\x95\x01\x81Uam\xF1V[\x90a3eV[V[a\x08\xC3V[T\x90V[\x90an\\\x90a3MV[_R` R`@_ \x90V[anpa;\xCBV[Pan\x85an\x7F\x82\x84\x90an\xCBV[\x15a\x04\xC2V[_\x14an\xC5Wan\xBBan\xC0\x92an\xA7an\xA0_\x85\x01am\xE1V[\x82\x90an\x19V[`\x01an\xB4_\x85\x01anNV[\x93\x01anRV[a0\x18V[`\x01\x90V[PP_\x90V[an\xE9\x91`\x01an\xE4\x92an\xDDa;\xCBV[P\x01anRV[a\t>V[an\xFBan\xF5_a,\xC2V[\x91a\x05TV[\x14\x15\x90V[_\x90V[\x90V[ao\x1Bao\x16ao \x92ao\x04V[a\x07IV[a\x05TV[\x90V[_\x90V[\x91\x90\x91ao2aKVV[Pao;ao\0V[PaoDa3\x87V[PaoN\x83a7\x11V[aoaao[`Aao\x07V[\x91a\x05TV[\x14_\x14ao\xA8Wao\xA1\x91\x92aoua3\x87V[Pao~a3\x87V[Pao\x87ao#V[P` \x81\x01Q```@\x83\x01Q\x92\x01Q_\x1A\x90\x91\x92az\x07V[\x91\x92\x90\x91\x90V[Pao\xB2_a%\xE9V[\x90ao\xC6ao\xC1`\x02\x94a7\x11V[ad\xE6V[\x91\x92\x91\x90V[`\x04\x11\x15ao\xD6WV[a\x116V[\x90ao\xE5\x82ao\xCCV[V[\x80ao\xFAao\xF4_ao\xDBV[\x91ao\xDBV[\x14_\x14ap\x05WPPV[\x80ap\x19ap\x13`\x01ao\xDBV[\x91ao\xDBV[\x14_\x14ap<W_c\xF6E\xEE\xDF`\xE0\x1B\x81R\x80ap8`\x04\x82\x01a\x04KV[\x03\x90\xFD[\x80apPapJ`\x02ao\xDBV[\x91ao\xDBV[\x14_\x14ap~Wapzapc\x83akwV[_\x91\x82\x91c\xFC\xE6\x98\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x05dV[\x03\x90\xFD[ap\x91ap\x8B`\x03ao\xDBV[\x91ao\xDBV[\x14ap\x99WPV[ap\xB4\x90_\x91\x82\x91c5\xE2\xF3\x83`\xE2\x1B\x83R`\x04\x83\x01a\x0F\x11V[\x03\x90\xFD[ap\xCCap\xC7ap\xD1\x92a\x13\x0EV[a\x07IV[a\x04\xAFV[\x90V[ap\xE0ap\xE6\x91a\x03\xB4V[\x91a\x03\xB4V[\x90\x03\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11ap\xFAWV[a(\xE4V[_\x7FProtocol violation reported\0\0\0\0\0\x91\x01RV[aq3`\x1B` \x92a\t\xD5V[aq<\x81ap\xFFV[\x01\x90V[aqU\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Raq&V[\x90V[\x93PP\x92Paqpaqj`\xC8ap\xB8V[\x91a\x04\xAFV[\x10\x15aq{W[PPV[aq\x84Ba6@V[aq\xA2aq\x9Daq\x96`\x0C\x85\x90aH\x81V[\x85\x90aH\x97V[a\x10IV[\x80aq\xB5aq\xAF_aX\xE8V[\x91a\x03\xB4V[\x14\x90\x81\x15ar;W[Paq\xCAW[PaqwV[aq\xE9\x90aq\xE4aq\xDD`\x0C\x85\x90aH\x81V[\x85\x90aH\x97V[aM\xE9V[\x90ar\x1Dar\x17\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07LV[\x91a\x10\x06V[\x91ar&a\x03\xA2V[\x80ar0\x81aq@V[\x03\x90\xA3_\x80\x80aq\xC4V[arF\x91P\x82ap\xD4V[ar_arYarTa\x0FzV[a\x03\xB4V[\x91a\x03\xB4V[\x10\x15_aq\xBEV[\x90V[ar~aryar\x83\x92argV[a\x07IV[a\x05TV[\x90V[\x90\x92\x91\x92ar\x9Bar\x96\x82a\x16\xFAV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11ar\xB7War\xB5\x92a\t\xDEV[V[a\x16\xF6V[\x90\x80`\x1F\x83\x01\x12\x15ar\xDAW\x81` ar\xD7\x93Q\x91\x01ar\x86V[\x90V[a\x05\xAFV[\x90PQ\x90ar\xEC\x82a\x06\xF9V[V[\x91\x90\x91`@\x81\x84\x03\x12asAWas\x05`@a\x16\xBCV[\x92_\x82\x01Q\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11as<Was)\x82as5\x94\x83\x01ar\xBCV[_\x86\x01R` \x01ar\xDFV[` \x83\x01RV[a\x16\xF2V[a\x16\xEEV[\x92\x91\x90asZasU\x82a\x16\xD1V[a\x16\xBCV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11as\xB1W\x81\x90[\x83\x82\x10as\x80WPPPPPV[\x81Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11as\xACW` \x91as\xA1\x87\x84\x93\x87\x01ar\xEEV[\x81R\x01\x91\x01\x90asrV[a\x05\xAFV[a\x05\xB7V[\x90\x80`\x1F\x83\x01\x12\x15as\xD4W\x81` as\xD1\x93Q\x91\x01asFV[\x90V[a\x05\xAFV[\x90` \x82\x82\x03\x12at\tW_\x82\x01Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11at\x04Wat\x01\x92\x01as\xB6V[\x90V[a\x03\xB0V[a\x03\xACV[` \x91\x81R\x01\x90V[\x91\x90at1\x81at*\x81at6\x95at\x0EV[\x80\x95a\x17\x1DV[a\x08\xB9V[\x01\x90V[\x90\x91atQ\x92` \x83\x01\x92_\x81\x85\x03\x91\x01Rat\x17V[\x90V[at^`2a\x15QV[\x90V[\x94\x93\x91``\x91at\xA2\x94at\x8Dat\x9A\x93at\x83`\x80\x8B\x01\x94_\x8C\x01\x90a\x0C!V[` \x8A\x01\x90a\x0C\xBCV[\x87\x82\x03`@\x89\x01Ra\x0E(V[\x94\x01\x90a\x05WV[V[\x91at\xB0\x81\x85\x90a-~V[at\xC2at\xBC_a,\xC2V[\x91a\x05TV[\x14av\\Wat\xD2\x81\x85\x90a-~V[at\xE6at\xE0a\xC3ParjV[\x91a\x05TV[\x11avVW_at\xF4a:!V[\x94at\xFE0a=.V[au c1\xE3\xBD\x1B\x94\x92\x94au+au\x14a\x03\xA2V[\x96\x87\x95\x86\x94\x85\x94aK\x99V[\x84R`\x04\x84\x01at:V[\x03\x91Z\xFA\x80\x91_\x92av2W[P\x15_\x14av)WP`\x01av$W[auQ\x83a\r\x97V[aujaudau_atTV[a\x05TV[\x91a\x05TV[\x11_\x14av\x16WauyatTV[[au\x830a=.V[\x90ce\xA6\x93n\x93\x92\x94\x90\x82;\x15av\x11W_\x94au\xBE\x86\x92au\xB3\x94au\xA7a\x03\xA2V[\x99\x8A\x98\x89\x97\x88\x96aK\x99V[\x86R`\x04\x86\x01ataV[\x03\x92Z\xF1\x90\x81au\xE5W[P\x15_\x14au\xE0W`\x01au\xDBW[[V[au\xD8V[au\xD9V[av\x04\x90_=\x81\x11av\nW[au\xFC\x81\x83a\x08\xD7V[\x81\x01\x90aK\x9FV[_au\xC9V[P=au\xF2V[aK\x95V[av\x1F\x83a\r\x97V[auzV[PPPV[\x90\x92P\x91auHV[avO\x91\x92P=\x80_\x83>avG\x81\x83a\x08\xD7V[\x81\x01\x90as\xD9V[\x90_au8V[PPPPV[PPPPV[_avv\x91avoa'\xAEV[P\x01anNV[\x90V[_R` _ \x90V[av\x8B\x81anNV[\x82\x10\x15av\xA5Wav\x9D`\x01\x91avyV[\x91\x02\x01\x90_\x90V[a\x07~V[av\xBA\x90`\x08av\xBF\x93\x02a\x0CxV[a\x10\xB0V[\x90V[\x90av\xCD\x91Tav\xAAV[\x90V[av\xEE\x91_av\xE8\x92av\xE1a3\x87V[P\x01av\x82V[\x90av\xC2V[\x90V[av\xFA_a%\xBDV[aw\x04\x82_a&\x9AV[\x90aw8aw2\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x10\x06V[\x91a\x10\x06V[\x91awAa\x03\xA2V[\x80awK\x81a\x04KV[\x03\x90\xA3V[awXa;\xCBV[Paw\x80awzawsawn`\x06\x85\x90a34V[a3JV[\x84\x90ae\x8DV[\x15a\x04\xC2V[ax\"Waw\xA0\x91aw\x96aw\x9B\x92`\x03a\x0F\xC8V[a\x10\x12V[aHIV[aw\xAB_\x82\x01a?VV[aw\xBDaw\xB7_a,\xC2V[\x91a\x05TV[\x14\x80\x15aw\xFCW[aw\xF6Waw\xEBaw\xE5aw\xF1\x92aw\xDF_B\x92\x01a?VV[\x90a6\x7FV[\x92a\x05TV[\x91a\x05TV[\x10\x15\x90V[PP_\x90V[Pax\t``\x82\x01a^\xC3V[ax\x1Cax\x16`\x03a\x11YV[\x91a\x11YV[\x14aw\xC5V[PPP_\x90V[ax=ax8axB\x92aU\xFEV[a\x07IV[a\x05TV[\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[axb\x81am\xEDV[\x80\x15ax\x83W`\x01\x90\x03\x90ax\x80axz\x83\x83am\xF1V[\x90a3\x8BV[UV[axEV[ax\x90a;\xCBV[Pax\xA7ax\xA2`\x01\x83\x01\x84\x90anRV[a\t>V[\x90\x81ax\xBBax\xB5_a,\xC2V[\x91a\x05TV[\x14\x15_\x14ay\x87Way9\x92`\x01ay4\x92\x84ax\xE2_\x96ax\xDC\x85ax)V[\x90a6\x7FV[ax\xFFax\xF0\x88\x85\x01anNV[ax\xF9\x86ax)V[\x90a6\x7FV[\x81ay\x12ay\x0C\x83a\x05TV[\x91a\x05TV[\x03ay>W[PPPay.ay)\x86\x83\x01am\xE1V[axYV[\x01anRV[a)\xBFV[`\x01\x90V[ay\x7F\x92ayqay]ayWayz\x94\x8C\x89\x01av\x82V[\x90av\xC2V[\x93ayk\x85\x91\x8C\x89\x01av\x82V[\x90a3eV[\x91\x85\x85\x01anRV[a0\x18V[_\x80\x80ay\x18V[PPP_\x90V[\x90V[ay\xA5ay\xA0ay\xAA\x92ay\x8EV[a\x07IV[a\x05TV[\x90V[ay\xE2ay\xE9\x94ay\xD8``\x94\x98\x97\x95ay\xCE`\x80\x86\x01\x9A_\x87\x01\x90a\x0F\x04V[` \x85\x01\x90a\x11)V[`@\x83\x01\x90a\x0F\x04V[\x01\x90a\x0F\x04V[V[ay\xFFay\xFAaz\x04\x92a%\xCAV[a&wV[a\x0F\x01V[\x90V[\x93\x92\x93az\x12aKVV[Paz\x1Bao\0V[Paz$a3\x87V[Paz.\x85akwV[az`azZ\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0ay\x91V[\x91a\x05TV[\x11az\xEDW\x90az\x83` \x94\x95_\x94\x93\x92\x93azza\x03\xA2V[\x94\x85\x94\x85ay\xADV[\x83\x80R\x03\x90`\x01Z\xFA\x15az\xE8Waz\x9B_Qa&wV[\x80az\xB6az\xB0az\xAB_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14az\xCCW_\x91az\xC6_ay\xEBV[\x91\x92\x91\x90V[Paz\xD6_a%\xE9V[`\x01\x91az\xE2_ay\xEBV[\x91\x92\x91\x90V[aK\xD1V[PPPaz\xF9_a%\xE9V[\x90`\x03\x92\x91\x92\x91\x90V\xFE\xA1dsolcC\0\x08\x1A\0\n",
    );
    /// The runtime bytecode of the contract, as deployed on the network.
    ///
    /// ```text
    ///0x60806040526004361015610013575b612523565b61001d5f3561039c565b806305778550146103975780630758236f146103925780630c76697a1461038d578063191cbd1a146103885780631e8f5ee514610383578063208129561461037e57806322f1ec93146103795780632bf4d6a7146103745780632c9576881461036f5780632dae18851461036a5780632f4bd7b81461036557806331e3bd1b146103605780633644e5151461035b5780633ac3cbe6146103565780633e6e34a7146103515780633fd62c6d1461034c57806340235a9c1461034757806348f4da20146103425780635685cf681461033d57806356c4e17d1461033857806359dcea12146103335780635a936dc61461032e5780635cce98a6146103295780636076439c1461032457806360cf09911461031f57806361d6b86c1461031a57806362c7e8fc1461031557806365a6936e146103105780636bfe06a61461030b578063715018a61461030657806371e7388c146103015780637639d227146102fc57806379ba5097146102f75780637b9f64b2146102f257806381beac2e146102ed57806384ef7322146102e85780638da5cb5b146102e357806396686c1e146102de5780639cbdae22146102d9578063adff830c146102d4578063ae470a85146102cf578063b074e9dd146102ca578063b99f6759146102c5578063ba1fb103146102c0578063c1ef9ddf146102bb578063c5d960bb146102b6578063cfe34749146102b1578063d551162c146102ac578063da435a7c146102a7578063e30c3978146102a2578063e65cafcb1461029d578063ee1c039014610298578063f2fde38b14610293578063f9107f3b1461028e578063f9f16762146102895763ffcf08f00361000e576124ef565b6124ba565b612457565b6123f7565b6123c1565b61238d565b612358565b612320565b61224e565b612219565b6121d7565b6121a2565b612078565b612044565b611fd7565b611f9d565b611ed2565b611e0b565b611c82565b611bc8565b611b95565b611b5e565b611ac9565b611a96565b611a60565b611a2a565b61196e565b611939565b6118cb565b611686565b61163c565b6115ba565b611585565b611517565b611482565b611429565b6113f4565b61138f565b611345565b6112d9565b611205565b6111cb565b610f93565b610f26565b610ea7565b610d2c565b610cde565b610c43565b610b9d565b610a6a565b6106c6565b610674565b610640565b610579565b61051f565b610450565b60e01c90565b60405190565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff1690565b6103ca816103b4565b036103d157565b5f80fd5b905035906103e2826103c1565b565b60018060a01b031690565b6103f8906103e4565b90565b610404816103ef565b0361040b57565b5f80fd5b9050359061041c826103fb565b565b9190604083820312610446578061043a610443925f86016103d5565b9360200161040f565b90565b6103ac565b5f0190565b3461047f5761046961046336600461041e565b906126ba565b6104716103a2565b8061047b8161044b565b0390f35b6103a8565b9060208282031261049d5761049a915f016103d5565b90565b6103ac565b6104ab906103b4565b9052565b60ff1690565b6104be906104af565b9052565b151590565b6104d0906104c2565b9052565b90604080610508936104ec5f8201515f8601906104a2565b6104fe602082015160208601906104b5565b01519101906104c7565b565b919061051d905f606085019401906104d4565b565b3461054f5761054b61053a610535366004610484565b612799565b6105426103a2565b9182918261050a565b0390f35b6103a8565b90565b61056090610554565b9052565b9190610577905f60208501940190610557565b565b346105aa576105a661059561058f36600461041e565b906127b2565b61059d6103a2565b91829182610564565b0390f35b6103a8565b5f80fd5b5f80fd5b5f80fd5b909182601f830112156105f55781359167ffffffffffffffff83116105f05760200192602083028401116105eb57565b6105b7565b6105b3565b6105af565b91909160408184031261063b57610613835f83016103d5565b92602082013567ffffffffffffffff81116106365761063292016105bb565b9091565b6103b0565b6103ac565b3461066f576106596106533660046105fa565b9161313b565b6106616103a2565b8061066b8161044b565b0390f35b6103a8565b346106a35761068d61068736600461041e565b9061342b565b6106956103a2565b8061069f8161044b565b0390f35b6103a8565b906020828203126106c1576106be915f0161040f565b90565b6103ac565b346106f4576106de6106d93660046106a8565b613560565b6106e66103a2565b806106f08161044b565b0390f35b6103a8565b61070281610554565b0361070957565b5f80fd5b9050359061071a826106f9565b565b91906040838203126107445780610738610741925f86016103d5565b9360200161070d565b90565b6103ac565b90565b61076061075b610765926103b4565b610749565b6103b4565b90565b906107729061074c565b5f5260205260405f2090565b634e487b7160e01b5f52603260045260245ffd5b5490565b5f5260205f2090565b5f5260205f2090565b6107b181610792565b8210156107cb576107c3600491610796565b910201905f90565b61077e565b634e487b7160e01b5f52602260045260245ffd5b9060016002830492168015610804575b60208310146107ff57565b6107d0565b91607f16916107f4565b60209181520190565b5f5260205f2090565b905f929180549061083a610833836107e4565b809461080e565b916001811690815f146108915750600114610855575b505050565b6108629192939450610817565b915f925b81841061087957505001905f8080610850565b60018160209295939554848601520191019290610866565b92949550505060ff19168252151560200201905f8080610850565b906108b691610820565b90565b601f801991011690565b634e487b7160e01b5f52604160045260245ffd5b906108e1906108b9565b810190811067ffffffffffffffff8211176108fb57604052565b6108c3565b90610920610919926109106103a2565b938480926108ac565b03836108d7565b565b5f1c90565b90565b61093661093b91610922565b610927565b90565b610948905461092a565b90565b60ff1690565b61095d61096291610922565b61094b565b90565b61096f9054610951565b90565b61097d906008610768565b9061098782610792565b8110156109cd57610997916107a8565b50906109a45f8301610900565b916109b16001820161093e565b916109ca60036109c36002850161093e565b9301610965565b90565b5f80fd5b5190565b60209181520190565b90825f9392825e0152565b610a08610a11602093610a16936109ff816109d1565b938480936109d5565b958691016109de565b6108b9565b0190565b610a23906104c2565b9052565b610a61610a6894610a57610a4c6060959998969960808601908682035f8801526109e9565b986020850190610557565b6040830190610557565b0190610a1a565b565b34610a9f57610a9b610a86610a8036600461071c565b90610972565b90610a929492946103a2565b94859485610a27565b0390f35b6103a8565b610aad816104af565b03610ab457565b5f80fd5b90503590610ac582610aa4565b565b909182601f83011215610b015781359167ffffffffffffffff8311610afc576020019260018302840111610af757565b6105b7565b6105b3565b6105af565b919060c083820312610b9857610b1e815f85016103d5565b92610b2c82602083016103d5565b92610b3a8360408401610ab8565b92606083013567ffffffffffffffff8111610b935781610b5b918501610ac7565b929093610b6b83608083016103d5565b9260a082013567ffffffffffffffff8111610b8e57610b8a9201610ac7565b9091565b6103b0565b6103b0565b6103ac565b34610bd557610bbf610bb0366004610b06565b96959095949194939293613a0f565b610bc76103a2565b80610bd18161044b565b0390f35b6103a8565b5f910312610be457565b6103ac565b90565b610c00610bfb610c0592610be9565b610749565b6103b4565b90565b610c1361012c610bec565b90565b610c1e610c08565b90565b610c2a906103b4565b9052565b9190610c41905f60208501940190610c21565b565b34610c7357610c53366004610bda565b610c6f610c5e610c16565b610c666103a2565b91829182610c2e565b0390f35b6103a8565b1c90565b60018060a01b031690565b610c97906008610c9c9302610c78565b610c7c565b90565b90610caa9154610c87565b90565b610cb9600b5f90610c9f565b90565b610cc5906103ef565b9052565b9190610cdc905f60208501940190610cbc565b565b34610d0e57610cee366004610bda565b610d0a610cf9610cad565b610d016103a2565b91829182610cc9565b0390f35b6103a8565b610d1e61012c610bec565b90565b610d29610d13565b90565b34610d5c57610d3c366004610bda565b610d58610d47610d21565b610d4f6103a2565b91829182610c2e565b0390f35b6103a8565b90602082820312610d92575f82013567ffffffffffffffff8111610d8d57610d899201610ac7565b9091565b6103b0565b6103ac565b5190565b60209181520190565b60200190565b610dc9610dd2602093610dd793610dc0816109d1565b9384809361080e565b958691016109de565b6108b9565b0190565b610de490610554565b9052565b90610e1290602080610e07604084015f8701518582035f870152610daa565b940151910190610ddb565b90565b90610e1f91610de8565b90565b60200190565b90610e3c610e3583610d97565b8092610d9b565b9081610e4d60208302840194610da4565b925f915b838310610e6057505050505090565b90919293946020610e82610e7c83856001950387528951610e15565b97610e22565b9301930191939290610e51565b610ea49160208201915f818403910152610e28565b90565b34610ed857610ed4610ec3610ebd366004610d61565b90613a5b565b610ecb6103a2565b91829182610e8f565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b90565b610f0d90610f01565b9052565b9190610f24905f60208501940190610f04565b565b34610f5657610f36366004610bda565b610f52610f41610edd565b610f496103a2565b91829182610f11565b0390f35b6103a8565b90565b610f72610f6d610f7792610f5b565b610749565b6103b4565b90565b610f85610e10610f5e565b90565b610f90610f7a565b90565b34610fc357610fa3366004610bda565b610fbf610fae610f88565b610fb66103a2565b91829182610c2e565b0390f35b6103a8565b90610fd29061074c565b5f5260205260405f2090565b610ff2610fed610ff7926103e4565b610749565b6103e4565b90565b61100390610fde565b90565b61100f90610ffa565b90565b9061101c90611006565b5f5260205260405f2090565b67ffffffffffffffff1690565b61104161104691610922565b611028565b90565b6110539054611035565b90565b60401c90565b60ff1690565b61106e61107391611056565b61105c565b90565b6110809054611062565b90565b60481c90565b60ff1690565b61109b6110a091611083565b611089565b90565b6110ad905461108f565b90565b90565b6110bf6110c491610922565b6110b0565b90565b6110d190546110b3565b90565b906110e36110e8926003610fc8565b611012565b6110f35f820161093e565b9161110060018301611049565b9161110d60018201611076565b91611126600261111f600185016110a3565b93016110c7565b90565b611132906104af565b9052565b634e487b7160e01b5f52602160045260245ffd5b6005111561115457565b611136565b906111638261114a565b565b61116e90611159565b90565b61117a90611165565b9052565b909594926111c9946111b86111c2926111ae6080966111a460a088019c5f890190610557565b6020870190610c21565b6040850190611129565b6060830190611171565b0190610f04565b565b34611200576111fc6111e76111e136600461041e565b906110d4565b916111f39593956103a2565b9586958661117e565b0390f35b6103a8565b346112355761123161122061121b366004610484565b613a75565b6112286103a2565b91829182610564565b0390f35b6103a8565b5190565b60209181520190565b60200190565b611256906103ef565b9052565b906112678160209361124d565b0190565b60200190565b9061128e6112886112818461123a565b809361123e565b92611247565b905f5b81811061129e5750505090565b9091926112b76112b1600192865161125a565b9461126b565b9101919091611291565b6112d69160208201915f818403910152611271565b90565b34611309576113056112f46112ef366004610484565b613b2f565b6112fc6103a2565b918291826112c1565b0390f35b6103a8565b90565b61132561132061132a9261130e565b610749565b610554565b90565b61133760c8611311565b90565b61134261132d565b90565b3461137557611355366004610bda565b61137161136061133a565b6113686103a2565b91829182610564565b0390f35b6103a8565b919061138d905f60208501940190610a1a565b565b346113c0576113bc6113ab6113a536600461041e565b90613bcf565b6113b36103a2565b9182918261137a565b0390f35b6103a8565b906113cf9061074c565b5f5260205260405f2090565b6113f1906113ec6007915f926113c5565b610c9f565b90565b346114245761142061140f61140a366004610484565b6113db565b6114176103a2565b91829182610cc9565b0390f35b6103a8565b346114595761145561144461143f366004610484565b613c56565b61144c6103a2565b918291826112c1565b0390f35b6103a8565b7f000000000000000000000000000000000000000000000000000000000000000090565b346114b257611492366004610bda565b6114ae61149d61145e565b6114a56103a2565b91829182610cc9565b0390f35b6103a8565b90608082820312611512576114ce815f84016103d5565b926114dc82602085016103d5565b926114ea8360408301610ab8565b92606082013567ffffffffffffffff811161150d576115099201610ac7565b9091565b6103b0565b6103ac565b346115495761153361152a3660046114b7565b93929092613cc8565b61153b6103a2565b806115458161044b565b0390f35b6103a8565b90565b61156561156061156a9261154e565b610749565b610554565b90565b6115776032611551565b90565b61158261156d565b90565b346115b557611595366004610bda565b6115b16115a061157a565b6115a86103a2565b91829182610564565b0390f35b6103a8565b346115eb576115e76115d66115d036600461041e565b90613cd7565b6115de6103a2565b9182918261137a565b0390f35b6103a8565b90565b61160761160261160c926115f0565b610749565b6104af565b90565b61161960036115f3565b90565b61162461160f565b90565b919061163a905f60208501940190611129565b565b3461166c5761164c366004610bda565b61166861165761161c565b61165f6103a2565b91829182611627565b0390f35b6103a8565b9190611684905f60208501940190611171565b565b346116b7576116b36116a261169c36600461041e565b90613d03565b6116aa6103a2565b91829182611671565b0390f35b6103a8565b906116cf6116c86103a2565b92836108d7565b565b67ffffffffffffffff81116116e95760208091020190565b6108c3565b5f80fd5b5f80fd5b5f80fd5b67ffffffffffffffff8111611718576117146020916108b9565b0190565b6108c3565b90825f939282370152565b9092919261173d611738826116fa565b6116bc565b93818552602085019082840111611759576117579261171d565b565b6116f6565b9080601f8301121561177c5781602061177993359101611728565b90565b6105af565b9190916040818403126117d45761179860406116bc565b925f8201359167ffffffffffffffff83116117cf576117bc826117c894830161175e565b5f86015260200161070d565b6020830152565b6116f2565b6116ee565b9291906117ed6117e8826116d1565b6116bc565b93818552602080860192028101918383116118445781905b838210611813575050505050565b813567ffffffffffffffff811161183f576020916118348784938701611781565b815201910190611805565b6105af565b6105b7565b9080601f8301121561186757816020611864933591016117d9565b90565b6105af565b6080818303126118c657611882825f83016103d5565b92611890836020840161040f565b9260408301359067ffffffffffffffff82116118c1576118b5816118be938601611849565b9360600161070d565b90565b6103b0565b6103ac565b346118fd576118e76118de36600461186c565b929190916140e9565b6118ef6103a2565b806118f98161044b565b0390f35b6103a8565b90565b61191961191461191e92611902565b610749565b610554565b90565b61192b6040611905565b90565b611936611921565b90565b3461196957611949366004610bda565b61196561195461192e565b61195c6103a2565b91829182610564565b0390f35b6103a8565b3461199c5761197e366004610bda565b611986614718565b61198e6103a2565b806119988161044b565b0390f35b6103a8565b6119aa90611165565b9052565b6119b790610f01565b9052565b90608080611a13936119d35f8201515f860190610ddb565b6119e5602082015160208601906104a2565b6119f7604082015160408601906104b5565b611a09606082015160608601906119a1565b01519101906119ae565b565b9190611a28905f60a085019401906119bb565b565b34611a5b57611a57611a46611a4036600461041e565b90614855565b611a4e6103a2565b91829182611a15565b0390f35b6103a8565b34611a9157611a8d611a7c611a7636600461041e565b906148ad565b611a846103a2565b91829182610c2e565b0390f35b6103a8565b34611ac457611aa6366004610bda565b611aae6148d5565b611ab66103a2565b80611ac08161044b565b0390f35b6103a8565b34611af957611af5611ae4611adf366004610484565b614926565b611aec6103a2565b91829182610564565b0390f35b6103a8565b9091606082840312611b3357611b30611b19845f85016103d5565b93611b27816020860161070d565b9360400161070d565b90565b6103ac565b92916020611b54611b5c9360408701908782035f890152611271565b940190610557565b565b34611b9057611b77611b71366004611afe565b916149c4565b90611b8c611b836103a2565b92839283611b38565b0390f35b6103a8565b34611bc357611bad611ba83660046106a8565b614b4b565b611bb56103a2565b80611bbf8161044b565b0390f35b6103a8565b34611bf857611bd8366004610bda565b611bf4611be3614b5a565b611beb6103a2565b91829182610cc9565b0390f35b6103a8565b909182601f83011215611c375781359167ffffffffffffffff8311611c32576020019260208302840111611c2d57565b6105b7565b6105b3565b6105af565b919091604081840312611c7d57611c55835f83016103d5565b92602082013567ffffffffffffffff8111611c7857611c749201611bfd565b9091565b6103b0565b6103ac565b34611cb157611c9b611c95366004611c3c565b91614be1565b611ca36103a2565b80611cad8161044b565b0390f35b6103a8565b91606083830312611d0257611ccd825f85016103d5565b92611cdb836020830161040f565b92604082013567ffffffffffffffff8111611cfd57611cfa920161175e565b90565b6103b0565b6103ac565b90611d119061074c565b5f5260205260405f2090565b90611d2790611006565b5f5260205260405f2090565b905090565b611d5d611d5492602092611d4b816109d1565b94858093611d33565b938491016109de565b0190565b90565b611d70611d7591610554565b611d61565b9052565b611d89611d909160209493611d38565b8092611d64565b0190565b611da8611d9f6103a2565b92839283611d79565b03902090565b611db791611d94565b90565b611dca906008611dcf9302610c78565b610927565b90565b90611ddd9154611dba565b90565b90611e0892611dfe611e0392611df96009955f96611d07565b611d1d565b611dae565b611dd2565b90565b34611e3c57611e38611e27611e21366004611cb6565b91611de0565b611e2f6103a2565b91829182610564565b0390f35b6103a8565b909182601f83011215611e7b5781359167ffffffffffffffff8311611e76576020019260018302840111611e7157565b6105b7565b6105b3565b6105af565b91606083830312611ecd57611e97825f85016103d5565b92611ea5836020830161040f565b92604082013567ffffffffffffffff8111611ec857611ec49201611e41565b9091565b6103b0565b6103ac565b34611f0457611eee611ee5366004611e80565b92919091614e46565b611ef66103a2565b80611f008161044b565b0390f35b6103a8565b611f12816104c2565b03611f1957565b5f80fd5b90503590611f2a82611f09565b565b91909160a081840312611f9857611f45835f83016103d5565b92602082013567ffffffffffffffff8111611f935781611f66918401611e41565b929093611f90611f79846040850161070d565b93611f87816060860161070d565b93608001611f1d565b90565b6103b0565b6103ac565b34611fd257611fbc611fb0366004611f2c565b9493909392919261511b565b611fc46103a2565b80611fce8161044b565b0390f35b6103a8565b3461200557611fef611fea366004610484565b6154d0565b611ff76103a2565b806120018161044b565b0390f35b6103a8565b909160608284031261203f5761203c612025845f85016103d5565b9361203381602086016103d5565b93604001610ab8565b90565b6103ac565b346120735761205d61205736600461200a565b91615745565b6120656103a2565b8061206f8161044b565b0390f35b6103a8565b346120a75761209161208b36600461041e565b90615904565b6120996103a2565b806120a38161044b565b0390f35b6103a8565b5190565b60209181520190565b60200190565b9061210d906060806120de608084015f8701518582035f870152610daa565b946120f160208201516020860190610ddb565b61210360408201516040860190610ddb565b01519101906104c7565b90565b9061211a916120bf565b90565b60200190565b90612137612130836120ac565b80926120b0565b9081612148602083028401946120b9565b925f915b83831061215b57505050505090565b9091929394602061217d61217783856001950387528951612110565b9761211d565b930193019193929061214c565b61219f9160208201915f818403910152612123565b90565b346121d2576121ce6121bd6121b8366004610484565b615c7b565b6121c56103a2565b9182918261218a565b0390f35b6103a8565b34612205576121ef6121ea366004610484565b615e0b565b6121f76103a2565b806122018161044b565b0390f35b6103a8565b612216600a5f90610c9f565b90565b3461224957612229366004610bda565b61224561223461220a565b61223c6103a2565b91829182610cc9565b0390f35b6103a8565b346122825761227e61226d612264366004611e80565b92919091615e78565b6122756103a2565b91829182610564565b0390f35b6103a8565b906122919061074c565b5f5260205260405f2090565b6122a96122ae91611083565b61094b565b90565b6122bb905461229d565b90565b6122c9906002612287565b6122d45f8201611049565b916122eb5f6122e4818501611076565b93016122b1565b90565b60409061231761231e949695939661230d60608401985f850190610c21565b6020830190611129565b0190610a1a565b565b346123535761234f61233b612336366004610484565b6122be565b6123469391936103a2565b938493846122ee565b0390f35b6103a8565b3461238857612368366004610bda565b612384612373615ead565b61237b6103a2565b91829182610cc9565b0390f35b6103a8565b346123bc576123a66123a036600461041e565b90615f97565b6123ae6103a2565b806123b88161044b565b0390f35b6103a8565b346123f2576123ee6123dd6123d736600461041e565b9061612c565b6123e56103a2565b9182918261137a565b0390f35b6103a8565b346124255761240f61240a3660046106a8565b61622b565b6124176103a2565b806124218161044b565b0390f35b6103a8565b9190604083820312612452578061244661244f925f86016103d5565b93602001611f1d565b90565b6103ac565b346124865761247061246a36600461242a565b90616236565b6124786103a2565b806124828161044b565b0390f35b6103a8565b7f32721f8dc67e953c540da90f663059c23fc47f70d11e317ed6d5a24c8b85637490565b6124b761248b565b90565b346124ea576124ca366004610bda565b6124e66124d56124af565b6124dd6103a2565b91829182610f11565b0390f35b6103a8565b3461251e5761250861250236600461041e565b906162ff565b6125106103a2565b8061251a8161044b565b0390f35b6103a8565b5f80fd5b5f7f4f6e6c792054616e676c6520636f726500000000000000000000000000000000910152565b61255b60106020926109d5565b61256481612527565b0190565b61257d9060208101905f81830391015261254e565b90565b1561258757565b61258f6103a2565b62461bcd60e51b8152806125a560048201612568565b0390fd5b6125b56125ba91610922565b610c7c565b90565b6125c790546125a9565b90565b90565b6125e16125dc6125e6926125ca565b610749565b6103e4565b90565b6125f2906125cd565b90565b5f7f416c726561647920726567697374657265640000000000000000000000000000910152565b61262960126020926109d5565b612632816125f5565b0190565b61264b9060208101905f81830391015261261c565b90565b1561265557565b61265d6103a2565b62461bcd60e51b81528061267360048201612636565b0390fd5b5f1b90565b9061268d60018060a01b0391612677565b9181191691161790565b90565b906126af6126aa6126b692611006565b612697565b825461267c565b9055565b61273c612741926126fd336126f76126f17f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b61273461271461270f600786906113c5565b6125bd565b61272e6127286127235f6125e9565b6103ef565b916103ef565b1461264e565b9160076113c5565b61269a565b565b61274d60606116bc565b90565b5f90565b5f90565b5f90565b612764612743565b906020808084612772612750565b81520161277d612754565b815201612788612758565b81525050565b61279661275c565b90565b6127ab906127a561278e565b50616427565b90565b5f90565b6127d36127d9926127ce5f936127c66127ae565b506003610fc8565b611012565b0161093e565b90565b5f7f4e6f742073657276696365206f776e6572000000000000000000000000000000910152565b61281060116020926109d5565b612819816127dc565b0190565b6128329060208101905f818303910152612803565b90565b1561283c57565b6128446103a2565b62461bcd60e51b81528061285a6004820161281d565b0390fd5b5090565b5f7f546f6f206d616e7920646566696e6974696f6e73000000000000000000000000910152565b61289660146020926109d5565b61289f81612862565b0190565b6128b89060208101905f818303910152612889565b90565b156128c257565b6128ca6103a2565b62461bcd60e51b8152806128e0600482016128a3565b0390fd5b634e487b7160e01b5f52601160045260245ffd5b61290761290d91939293610554565b92610554565b91612919838202610554565b92818404149015171561292857565b6128e4565b6129389060046128f8565b90565b9061294e905f1990602003600802610c78565b8154169055565b1b90565b9190600861297491029161296e5f1984612955565b92612955565b9181191691161790565b61299261298d61299792610554565b610749565b610554565b90565b90565b91906129b36129ae6129bb9361297e565b61299a565b908354612959565b9055565b6129d1916129cb6127ae565b9161299d565b565b5b8181106129df575050565b806129ec5f6001936129bf565b016129d4565b90612a02905f1990600802610c78565b191690565b81612a11916129f2565b906002021790565b905f91612a30612a2882610817565b928354612a07565b905555565b601f602091010490565b919290602082105f14612a9857601f8411600114612a6857612a62929350612a07565b90555b5b565b5090612a8e612a93936001612a85612a7f85610817565b92612a35565b820191016129d3565b612a19565b612a65565b50612acf8293612aa9600194610817565b612ac8612ab585612a35565b820192601f861680612ada575b50612a35565b01906129d3565b600202179055612a66565b612ae69088860361293b565b5f612ac2565b929091680100000000000000008211612b4c576020115f14612b3d57602081105f14612b2157612b1b91612a07565b90555b5b565b60019160ff1916612b3184610817565b55600202019055612b1e565b60019150600202019055612b1f565b6108c3565b908154612b5d816107e4565b90818311612b86575b818310612b74575b50505050565b612b7d93612a3f565b5f808080612b6e565b612b9283838387612aec565b612b66565b5f612ba191612b51565b565b634e487b7160e01b5f525f60045260245ffd5b905f03612bc857612bc690612b97565b565b612ba3565b60035f91612bdd83808301612bb6565b612bea83600183016129bf565b612bf783600283016129bf565b0155565b905f03612c0d57612c0b90612bcd565b565b612ba3565b5b818110612c1e575050565b80612c2b5f600493612bfb565b01612c13565b9091828110612c40575b505050565b612c5e612c58612c52612c699561292d565b9261292d565b92610796565b918201910190612c12565b5f8080612c3b565b90680100000000000000008111612c9a5781612c8f612c9893610792565b90828155612c31565b565b6108c3565b5f612ca991612c71565b565b905f03612cbd57612cbb90612c9f565b565b612ba3565b612cd6612cd1612cdb926125ca565b610749565b610554565b90565b6001612cea9101610554565b90565b5f80fd5b5f80fd5b5f80fd5b903590600160800381360303821215612d10570190565b612ced565b90821015612d2f576020612d2c9202810190612cf9565b90565b61077e565b903590600160200381360303821215612d76570180359067ffffffffffffffff8211612d7157602001916001820236038313612d6c57565b612cf5565b612cf1565b612ced565b91565b5090565b5f7f4e616d6520746f6f206c6f6e6700000000000000000000000000000000000000910152565b612db6600d6020926109d5565b612dbf81612d82565b0190565b612dd89060208101905f818303910152612da9565b90565b15612de257565b612dea6103a2565b62461bcd60e51b815280612e0060048201612dc3565b0390fd5b35612e0e816106f9565b90565b5f7f496e76616c696420626f756e6473000000000000000000000000000000000000910152565b612e45600e6020926109d5565b612e4e81612e11565b0190565b612e679060208101905f818303910152612e38565b90565b15612e7157565b612e796103a2565b62461bcd60e51b815280612e8f60048201612e52565b0390fd5b90565b5f5260205f2090565b5490565b612eac81612e9f565b821015612ec657612ebe600491612e96565b910201905f90565b61077e565b5090565b9190601f8111612edf575b505050565b612eeb612f1093610817565b906020612ef784612a35565b83019310612f18575b612f0990612a35565b01906129d3565b5f8080612eda565b9150612f0981929050612f00565b91612f319082612ecb565b9067ffffffffffffffff8211612ff057612f5582612f4f85546107e4565b85612ecf565b5f90601f8311600114612f8857918091612f77935f92612f7c575b5050612a07565b90555b565b90915001355f80612f70565b601f19831691612f9785610817565b925f5b818110612fd857509160029391856001969410612fbe575b50505002019055612f7a565b612fce910135601f8416906129f2565b90555f8080612fb2565b91936020600181928787013581550195019201612f9a565b6108c3565b906130009291612f26565b565b9061300e5f1991612677565b9181191691161790565b9061302d6130286130349261297e565b61299a565b8254613002565b9055565b3561304281611f09565b90565b9061305160ff91612677565b9181191691161790565b613064906104c2565b90565b90565b9061307f61307a6130869261305b565b613067565b8254613045565b9055565b906130e8606060036130ee946130ae5f82016130a85f880188612d34565b91612ff5565b6130c7600182016130c160208801612e04565b90613018565b6130e0600282016130da60408801612e04565b90613018565b019201613038565b9061306a565b565b9190613101576130ff9161308a565b565b612ba3565b9081549168010000000000000000831015613136578261312e91600161313495018155612ea3565b906130f0565b565b6108c3565b9291909261316e3361316861316261315d613158600787906113c5565b6125bd565b6103ef565b916103ef565b14612835565b61319c61317c85849061285e565b61319561318f61318a61156d565b610554565b91610554565b11156128bb565b6131b15f6131ac60088490610768565b612cab565b6131ba5f612cc2565b5b806131d86131d26131cd88879061285e565b610554565b91610554565b10156132ab576132a69061322f61320f6132096132036131fa8a898791612d15565b5f810190612d34565b90612d7b565b90612d7e565b61322861322261321d611921565b610554565b91610554565b1115612ddb565b613278613249604061324389888691612d15565b01612e04565b61327161326b61326660206132608c8b8991612d15565b01612e04565b610554565b91610554565b1015612e6a565b6132a161328f61328a60088690610768565b612e93565b61329b88878591612d15565b90613106565b612cde565b6131bb565b5050509050565b5f7f5a65726f20616464726573730000000000000000000000000000000000000000910152565b6132e6600c6020926109d5565b6132ef816132b2565b0190565b6133089060208101905f8183039101526132d9565b90565b1561331257565b61331a6103a2565b62461bcd60e51b815280613330600482016132f3565b0390fd5b9061333e9061074c565b5f5260205260405f2090565b90565b61335690610f01565b90565b61336290610922565b90565b919061337b6133766133839361334d565b613359565b908354612959565b9055565b5f90565b61339d91613397613387565b91613365565b565b5f60026133be926133b2838083016129bf565b8260018201550161338b565b565b905f036133d2576133d09061339f565b565b612ba3565b60481b90565b906133f269ff000000000000000000916133d7565b9181191691161790565b61340590611159565b90565b90565b9061342061341b613427926133fc565b613408565b82546133dd565b9055565b6134673361346161345b7f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b61348c8261348561347f61347a5f6125e9565b6103ef565b916103ef565b141561330b565b6134b26134ad6134a66134a160068590613334565b61334a565b8490616505565b61264e565b6134d15f6134cc6134c560038590610fc8565b8590611012565b6133c0565b6134f4600260016134ee6134e760038690610fc8565b8690611012565b0161340b565b906135286135227f8e2d88795a3c66719a287658cbf68b3eb2b8e183cb18f46f4813913fc8aafc4b9361074c565b91611006565b916135316103a2565b8061353b8161044b565b0390a3565b6135519061354c61653f565b613553565b565b61355e90600b61269a565b565b61356990613540565b565b5f7f4e6f742072656769737465726564206f70657261746f72000000000000000000910152565b61359f60176020926109d5565b6135a88161356b565b0190565b6135c19060208101905f818303910152613592565b90565b156135cb57565b6135d36103a2565b62461bcd60e51b8152806135e9600482016135ac565b0390fd5b906136229796959493929161361d61361861361161360c846006613334565b61334a565b339061658d565b6135c4565b613863565b565b61363861363361363d926103b4565b610749565b610554565b90565b61365461364f61365992610554565b610749565b6103b4565b90565b91602061367d92949361367660408201965f830190610c21565b0190610c21565b565b61368e61369491939293610554565b92610554565b820391821161369f57565b6128e4565b67ffffffffffffffff81116136c2576136be6020916108b9565b0190565b6108c3565b909291926136dc6136d7826136a4565b6116bc565b938185526020850190828401116136f8576136f69261171d565b565b6116f6565b6137089136916136c7565b90565b60200190565b5190565b949290979695939160e08601985f870161372e91610f04565b6020860161373b91610cbc565b6040850161374891610c21565b6060840161375591610c21565b6080830161376291611129565b60a0820161376f91610f04565b60c00161377b91610c21565b565b5f61190160f01b910152565b61379560028092611d33565b61379e8161377d565b0190565b90565b6137b16137b691610f01565b6137a2565b9052565b60208093926137d56137ce6137dd94613789565b80926137a5565b0180926137a5565b0190565b5f7f496e76616c6964207369676e6174757265000000000000000000000000000000910152565b61381560116020926109d5565b61381e816137e1565b0190565b6138379060208101905f818303910152613808565b90565b1561384157565b6138496103a2565b62461bcd60e51b81528061385f60048201613822565b0390fd5b9192939497969095978061387f61387942610554565b91613624565b116139e7576138974261389183613624565b9061367f565b6138b06138aa6138a5610d13565b613624565b91610554565b116139bf576139bd97986139946139b2938561391e8a61390f8d61399a988d8d6138e66138db61248b565b9633999592936136fd565b6138f86138f282613711565b9161370b565b2092936139036103a2565b98899760208901613715565b602082018103825203826108d7565b61393061392a82613711565b9161370b565b2061397b7f000000000000000000000000000000000000000000000000000000000000000061396c6139606103a2565b938492602084016137ba565b602082018103825203826108d7565b61398d61398782613711565b9161370b565b20926136fd565b906165c7565b6139ac6139a6336103ef565b916103ef565b1461383a565b933391929394616746565b565b6139c842613640565b906139e35f9283926318355b7560e21b84526004840161365c565b0390fd5b6139f042613640565b90613a0b5f9283926357ea02e960e01b84526004840161365c565b0390fd5b90613a1f979695949392916135ed565b565b606090565b90602082820312613a56575f82013567ffffffffffffffff8111613a5157613a4e9201611849565b90565b6103b0565b6103ac565b90613a7291613a68613a21565b5090810190613a26565b90565b613a94613a8f613a9992613a876127ae565b506005613334565b61334a565b616b58565b90565b606090565b67ffffffffffffffff8111613ab95760208091020190565b6108c3565b90613ad0613acb83613aa1565b6116bc565b918252565b369037565b90613aff613ae783613abe565b92602080613af58693613aa1565b9201910390613ad5565b565b90613b0b8261123a565b811015613b1c576020809102010190565b61077e565b90613b2b906103ef565b9052565b90613b38613a9c565b50613b55613b50613b4b60048590613334565b61334a565b616b58565b91613b5f83613ada565b91613b695f612cc2565b5b80613b7d613b7787610554565b91610554565b1015613bc457613bbf90613bba613ba8613ba1613b9c60048890613334565b61334a565b8390616ba7565b613bb58791849092613b01565b613b21565b612cde565b613b6a565b5092505090565b5f90565b90613bd8613bcb565b50613bfa6001613bf4613bed60038690610fc8565b8490611012565b016110a3565b613c0c613c065f611159565b91611159565b14918215613c1a575b505090565b613c3b9250600191613c30613c35926003610fc8565b611012565b016110a3565b613c4e613c486001611159565b91611159565b145f80613c15565b613c7c90613c62613a9c565b505f90613c76613c7061132d565b92612cc2565b906149c4565b5090565b90613cb294939291613cad613ca8613ca1613c9c846006613334565b61334a565b339061658d565b6135c4565b613cb4565b565b91613cc6949293913391929394616746565b565b90613cd594939291613c80565b565b90613cf7613cf2613cfc93613cea613bcb565b506006613334565b61334a565b61658d565b90565b5f90565b613d25613d2b92613d20600193613d18613cff565b506003610fc8565b611012565b016110a3565b90565b613d3790610ffa565b90565b5f7f496e7465726e616c206f6e6c7900000000000000000000000000000000000000910152565b613d6e600d6020926109d5565b613d7781613d3a565b0190565b613d909060208101905f818303910152613d61565b90565b15613d9a57565b613da26103a2565b62461bcd60e51b815280613db860048201613d7b565b0390fd5b67ffffffffffffffff8111613dd45760208091020190565b6108c3565b90613deb613de683613dbc565b6116bc565b918252565b369037565b90613e1a613e0283613dd9565b92602080613e108693613dbc565b9201910390613df0565b565b90613e2682610d97565b811015613e37576020809102010190565b61077e565b90565b5190565b90613e4d82613e3f565b811015613e5e576020809102010190565b61077e565b90613e6d90610f01565b9052565b606090565b90565b60209181520190565b905f9291805490613e9c613e95836107e4565b8094613e79565b916001811690815f14613ef35750600114613eb7575b505050565b613ec4919293945061079f565b915f925b818410613edb57505001905f8080613eb2565b60018160209295939554848601520191019290613ec8565b92949550505060ff19168252151560200201905f8080613eb2565b90613f1891613e82565b90565b90613f3b613f3492613f2b6103a2565b93848092613f0e565b03836108d7565b565b613f4690613f1b565b90565b613f539051610f01565b90565b613f609051610554565b90565b5f7f56616c7565206f7574206f6620626f756e647300000000000000000000000000910152565b613f9760136020926109d5565b613fa081613f63565b0190565b613fbc613fca9260408301908382035f8501526109e9565b906020818303910152613f8a565b90565b92916020613fe9613ff19360408701908782035f8901526109e9565b940190610557565b565b905f929180549061400d614006836107e4565b80946109d5565b916001811690815f146140645750600114614028575b505050565b6140359192939450610817565b915f925b81841061404c57505001905f8080614023565b60018160209295939554848601520191019290614039565b92949550505060ff19168252151560200201905f8080614023565b5f7f5265717569726564206d6574726963206d697373696e67000000000000000000910152565b6140b360176020926109d5565b6140bc8161407f565b0190565b6140d86140e69260408301908382035f850152613ff3565b9060208183039101526140a6565b90565b929390936141113361410b61410561410030613d2e565b6103ef565b916103ef565b14613d93565b61412561412060088690610768565b612e93565b9461412f82613df5565b946141395f612cc2565b5b8061414d61414786610554565b91610554565b10156141a05761419b906141966141715f6141698a8590613e1c565b510151613e3c565b61418361417d82613711565b9161370b565b206141918a91849092613e43565b613e63565b612cde565b61413a565b5091949092956141af81612e9f565b6141c16141bb5f612cc2565b91610554565b11966141cb613e71565b908861464b575b6141db5f612cc2565b5b806141ef6141e98b610554565b91610554565b10156144ae5760015f8b6142e2575b509088878961421494614219575b505050612cde565b6141dc565b825f61425761424f6142609461424a614242602061423b6142659b8d90613e1c565b5101613f56565b976009611d07565b611d1d565b928790613e1c565b51015190611dae565b613018565b8887899061428f60206142885f61427d878990613e1c565b510151958790613e1c565b5101613f56565b6142c26142bc7f23ed02bd3605bdea6a8afa76c46f00d274860ba6cea980f2585b696df9e182bd9361074c565b93611006565b936142d76142ce6103a2565b92839283613fcd565b0390a388878961420c565b9a90959291996142f15f612cc2565b5b8061430d6143076143028a612e9f565b610554565b91610554565b1015614498576143256143208d87613e43565b613f49565b61434961434361433e6143398a8690613e43565b613f49565b610f01565b91610f01565b1461435c5761435790612cde565b6142f2565b8a919b929c50896142149495988a926001908a614386602061437f898b90613e1c565b5101613f56565b6143ae6143a86143a3600161439c868890612ea3565b500161093e565b610554565b91610554565b10918888841561444e575b505050506143e3575b6143cd905b156104c2565b6143dc575b93945050506141fe565b505f6143d2565b905082825f6143f3878990613e1c565b5101519161443f61442d6144277fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361074c565b93611006565b936144366103a2565b91829182613fa4565b0390a36143cd5f9190506143c2565b61448e93945061447c61448893614476602061446f61448396600296613e1c565b5101613f56565b96612ea3565b500161093e565b610554565b91610554565b118a5f88886143b9565b5099909a87896142149495986143cd8d946143c7565b5097505092935093506144c05f612cc2565b935b846144dd6144d76144d286612e9f565b610554565b91610554565b1015614644576145036144fd60036144f6868990612ea3565b5001610965565b156104c2565b614639576145256145205f614519868990612ea3565b5001613e76565b613f3d565b61453761453182613711565b9161370b565b20905f966145445f612cc2565b5b8061456061455a61455586613e3f565b610554565b91610554565b101561462757614579614574848390613e43565b613f49565b61458b61458586610f01565b91610f01565b1461459e5761459990612cde565b614545565b50959096506145bf91506145b460015b156104c2565b6145c6575b5b612cde565b93946144c2565b82855f6145d4878590612ea3565b50019161461f61460d6146077fe08f42896ce3aec2ff7da95a00372f33cf677e75ad602590832a8dffcdad63159361074c565b93611006565b936146166103a2565b918291826140c0565b0390a36145b9565b509590966145bf92506145b4906145ae565b94936145bf906145ba565b5050505050565b96939050614665614660839794999693612e9f565b613df5565b9761466f5f612cc2565b5b8061468b6146856146808b612e9f565b610554565b91610554565b10156146e5576146e0906146db6146b66146b15f6146aa8d8690612ea3565b5001613e76565b613f3d565b6146c86146c282613711565b9161370b565b206146d68d91849092613e43565b613e63565b612cde565b614670565b5092959194979093966141d2565b6146fb61653f565b614703614705565b565b6147166147115f6125e9565b616c3f565b565b6147206146f3565b565b61472c60a06116bc565b90565b5f90565b5f90565b5f90565b614743614722565b906020808080808661475361472f565b81520161475e612750565b815201614769612754565b815201614774614733565b81520161477f614737565b81525050565b61478d61473b565b90565b9061479a90610554565b9052565b906147a8906103b4565b9052565b906147b6906104af565b9052565b906147c490611159565b9052565b9061484761483e60026147d9614722565b946147f06147e85f830161093e565b5f8801614790565b6148086147ff60018301611049565b6020880161479e565b61482061481760018301611076565b604088016147ac565b61483861482f600183016110a3565b606088016147ba565b016110c7565b60808401613e63565b565b614852906147c8565b90565b61487a9161487061487592614868614785565b506003610fc8565b611012565b614849565b90565b5f90565b9061488b9061074c565b5f5260205260405f2090565b906148a190611006565b5f5260205260405f2090565b6148d2916148c86148cd926148c061487d565b50600c614881565b614897565b611049565b90565b6148dd616c55565b6148e5615ead565b6148f76148f1836103ef565b916103ef565b036149075761490590616c3f565b565b614922905f91829163118cdaa760e01b835260048301610cc9565b0390fd5b61494561494061494a926149386127ae565b506004613334565b61334a565b616b58565b90565b61495790516104af565b90565b61496e614969614973926125ca565b610749565b6104af565b90565b61498090516103b4565b90565b61499761499261499c926104af565b610749565b610554565b90565b6149ae6149b491939293610554565b92610554565b82018092116149bf57565b6128e4565b909291926149d0613a9c565b506149d96127ae565b506149e382616427565b93614a006149fb6149f660058690613334565b61334a565b616b58565b92614a0d6020870161494d565b614a1f614a195f61495a565b916104af565b148015614b11575b8015614af6575b614adc57614a6886614a62614a5d6020614a56614a515f614ac59b9c9d01614976565b613624565b930161494d565b614983565b906128f8565b9180614a83614a7d614a7861132d565b610554565b91610554565b115f14614ad75750614a9361132d565b5b614a9f84829061499f565b614ab1614aab88610554565b91610554565b115f14614ac85750845b9092909192616c8b565b91565b614ad2908461499f565b614abb565b614a94565b5050509150614af2614aed5f612cc2565b613ada565b9190565b5082614b0a614b0486610554565b91610554565b1015614a2e565b5083614b25614b1f5f612cc2565b91610554565b14614a27565b614b3c90614b3761653f565b614b3e565b565b614b4990600a61269a565b565b614b5490614b2b565b565b5f90565b614b62614b56565b50614b6c5f6125bd565b90565b5090565b9190811015614b83576020020190565b61077e565b35614b92816103fb565b90565b5f80fd5b60e01b90565b5f910312614ba957565b6103ac565b916020614bcf929493614bc860408201965f830190610c21565b0190610cbc565b565b614bd96103a2565b3d5f823e3d90fd5b90929192614bee5f612cc2565b5b80614c0c614c06614c01858990614b6f565b610554565b91610554565b1015614cbb57614c1b30613d2e565b9063ba1fb10384614c36614c31868a8691614b73565b614b88565b93803b15614cb657614c5b5f8094614c66614c4f6103a2565b98899687958694614b99565b845260048401614bae565b03925af1918215614cb157614c8092614c85575b50612cde565b614bef565b614ca4905f3d8111614caa575b614c9c81836108d7565b810190614b9f565b5f614c7a565b503d614c92565b614bd1565b614b95565b5050509050565b5f7f4e6f7420736c617368696e67206f7261636c6500000000000000000000000000910152565b614cf660136020926109d5565b614cff81614cc2565b0190565b614d189060208101905f818303910152614ce9565b90565b15614d2257565b614d2a6103a2565b62461bcd60e51b815280614d4060048201614d03565b0390fd5b5f7f4f70657261746f7220756e6b6e6f776e00000000000000000000000000000000910152565b614d7860106020926109d5565b614d8181614d44565b0190565b614d9a9060208101905f818303910152614d6b565b90565b15614da457565b614dac6103a2565b62461bcd60e51b815280614dc260048201614d85565b0390fd5b90565b90614ddc67ffffffffffffffff91612677565b9181191691161790565b90565b90614dfe614df9614e059261074c565b614de6565b8254614dc9565b9055565b9190614e2381614e1c81614e28956109d5565b809561171d565b6108b9565b0190565b9091614e439260208301925f818503910152614e09565b90565b614e6b33614e65614e5f614e5a600a6125bd565b6103ef565b916103ef565b14614d1b565b614e91614e8c614e85614e8060058590613334565b61334a565b849061658d565b614d9d565b614ebd614eb2614ead614ea660038590610fc8565b8590611012565b614dc6565b60016003910161340b565b614edb614ed4614ecf60048490613334565b61334a565b8390616da7565b50614f03614ee842613640565b614efe614ef7600c8590614881565b8590614897565b614de9565b909192614f39614f337f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361074c565b93611006565b93614f4e614f456103a2565b92839283614e2c565b0390a3565b614f5d60806116bc565b90565b614f6b913691611728565b90565b52565b90614f7b906104c2565b9052565b5190565b90614f8d816109d1565b9067ffffffffffffffff821161504d57614fb182614fab85546107e4565b85612ecf565b602090601f8311600114614fe557918091614fd4935f92614fd9575b5050612a07565b90555b565b90915001515f80614fcd565b601f19831691614ff485610817565b925f5b8181106150355750916002939185600196941061501b575b50505002019055614fd7565b61502b910151601f8416906129f2565b90555f808061500f565b91936020600181928787015181550195019201614ff7565b6108c3565b9061505c91614f83565b565b61506890516104c2565b90565b906150c8606060036150ce9461508e5f82016150885f8801614f7f565b90615052565b6150a7600182016150a160208801613f56565b90613018565b6150c0600282016150ba60408801613f56565b90613018565b01920161505e565b9061306a565b565b91906150e1576150df9161506b565b565b612ba3565b9081549168010000000000000000831015615116578261510e91600161511495018155612ea3565b906150d0565b565b6108c3565b6152399561522284966152196152116151fd6151f861522b9761519e61517e6151786152349d8d9f9d6151733361516d61516761516261515d60078c906113c5565b6125bd565b6103ef565b916103ef565b14612835565b612d7b565b90612d7e565b61519761519161518c611921565b610554565b91610554565b1115612ddb565b6151bb866151b46151ae8d610554565b91610554565b1015612e6a565b6151f16151d26151cd60088490610768565b610792565b6151eb6151e56151e061156d565b610554565b91610554565b106128bb565b6008610768565b612e93565b98999692949661520b614f53565b9a614f60565b5f8a01614f6e565b60208801614790565b60408601614790565b60608401614f71565b6150e6565b565b6152699061526461525f615258615253846006613334565b61334a565b339061658d565b6135c4565b61534a565b565b5f7f43616e6e6f7420676f206f6e6c696e65207768696c6520736c61736865640000910152565b61529f601e6020926109d5565b6152a88161526b565b0190565b6152c19060208101905f818303910152615292565b90565b60401b90565b906152de68ff0000000000000000916152c4565b9181191691161790565b6152fc6152f7615301926104af565b610749565b6104af565b90565b90565b9061531c615317615323926152e8565b615304565b82546152ca565b9055565b91602061534892949361534160408201965f830190611171565b0190611171565b565b61536861536361535c60038490610fc8565b3390611012565b614dc6565b90615375600183016110a3565b918261538a6153846003611159565b91611159565b146154ae57826153a261539c5f611159565b91611159565b148015615493575b61548e576153d1906153bf600180830161340b565b60016153ca5f61495a565b9101615307565b6153ef6153e86153e360048490613334565b61334a565b3390616505565b50803361542561541f7fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361074c565b91611006565b9161542e6103a2565b806154388161044b565b0390a390339091600161547461546e7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b936154896154806103a2565b92839283615327565b0390a3565b505050565b50826154a86154a26001611159565b91611159565b146153aa565b6154b66103a2565b62461bcd60e51b8152806154cc600482016152ac565b0390fd5b6154d99061523b565b565b5f7f4e6f7420617574686f72697a6564000000000000000000000000000000000000910152565b61550f600e6020926109d5565b615518816154db565b0190565b6155319060208101905f818303910152615502565b90565b1561553b57565b6155436103a2565b62461bcd60e51b8152806155596004820161551c565b0390fd5b90565b61557461556f6155799261555d565b610749565b6103b4565b90565b5f7f496e74657276616c20746f6f2073686f72740000000000000000000000000000910152565b6155b060126020926109d5565b6155b98161557c565b0190565b6155d29060208101905f8183039101526155a3565b90565b156155dc57565b6155e46103a2565b62461bcd60e51b8152806155fa600482016155bd565b0390fd5b90565b61561561561061561a926155fe565b610749565b6104af565b90565b5f7f4d6178206d6973736564206d757374206265203e3d2031000000000000000000910152565b61565160176020926109d5565b61565a8161561d565b0190565b6156739060208101905f818303910152615644565b90565b1561567d57565b6156856103a2565b62461bcd60e51b81528061569b6004820161565e565b0390fd5b6156a960606116bc565b90565b906156c16156bc6156c89261305b565b613067565b82546133dd565b9055565b9061570e60405f615714946156ee8282016156e8848801614976565b90614de9565b6157068282016157006020880161494d565b90615307565b01920161505e565b906156ac565b565b90615720916156cc565b565b91602061574392949361573c60408201965f830190610c21565b0190611129565b565b336157786157727f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b148015615864575b61578990615534565b6157a7826157a061579a603c615560565b916103b4565b10156155d5565b6157c5836157be6157b86001615601565b916104af565b1015615676565b61581e8261580d856158046157e65f6157e060028990612287565b016122b1565b916157fb6157f261569f565b955f870161479e565b602085016147ac565b60408301614f71565b61581960028490612287565b615716565b909161584a7fc9599ed962624a858ec59bae0ed86c75f4db65fe04570021277edbedd04ea5649261074c565b9261585f6158566103a2565b92839283615722565b0390a2565b506157893361588e61588861588361587e600787906113c5565b6125bd565b6103ef565b916103ef565b149050615780565b634e487b7160e01b5f52601260045260245ffd5b6158b66158bc91610554565b91610554565b9081156158c7570490565b615896565b6158e06158db6158e592610554565b610749565b6104af565b90565b6158fc6158f7615901926125ca565b610749565b6103b4565b90565b61592261591d61591660038490610fc8565b8490611012565b614dc6565b9061592c81616427565b615938600184016110a3565b61594b6159456003611159565b91611159565b14615b5f5761595b5f840161093e565b61596d6159675f612cc2565b91610554565b14615b59576159a361598a426159845f870161093e565b9061367f565b61599d6159985f8501614976565b613624565b906158aa565b806159b76159b160ff614983565b91610554565b115f14615b4b575060ff5b90816159e16159db6159d660018801611076565b6104af565b916104af565b116159ee575b5050505050565b6159fb8260018601615307565b615a10615a075f6158e8565b60018601614de9565b615a2e615a28615a23602085940161494d565b6104af565b916104af565b101580615b24575b615a41575b806159e7565b615a5c615a50600185016110a3565b9360016002910161340b565b615a7a615a73615a6e60048590613334565b61334a565b8590616da7565b508190849091615ac8615ab6615ab07f44fd32b677704ce68e7763897c49733b8f5289018ac60a5c926802d63759db4d9361074c565b93611006565b93615abf6103a2565b91829182611627565b0390a39190916002615b03615afd7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93615b18615b0f6103a2565b92839283615327565b0390a35f808080615a3b565b50615b31600184016110a3565b615b44615b3e6002611159565b91611159565b1415615a36565b615b54906158cc565b6159c2565b50505050565b50505050565b606090565b67ffffffffffffffff8111615b825760208091020190565b6108c3565b90615b99615b9483615b6a565b6116bc565b918252565b615ba860806116bc565b90565b90615c12615c096003615bbc615b9e565b94615bd3615bcb5f8301610900565b5f8801614f6e565b615beb615be26001830161093e565b60208801614790565b615c03615bfa6002830161093e565b60408801614790565b01610965565b60608401614f71565b565b615c1d90615bab565b90565b90615c2a82610792565b615c3381615b87565b92615c416020850191610796565b5f915b838310615c515750505050565b60046020600192615c6185615c14565b815201920192019190615c44565b615c7890615c20565b90565b615c92615c9791615c8a615b65565b506008610768565b615c6f565b90565b615cc890615cc3615cbe615cb7615cb2846006613334565b61334a565b339061658d565b6135c4565b615d23565b565b5f7f43616e6e6f7420676f206f66666c696e65207768696c6520736c617368656400910152565b615cfe601f6020926109d5565b615d0781615cca565b0190565b615d209060208101905f818303910152615cf1565b90565b615d41615d3c615d3560038490610fc8565b3390611012565b614dc6565b90615d4e600183016110a3565b9182615d63615d5d6003611159565b91611159565b14615de957615d779060016004910161340b565b615d95615d8e615d8960048490613334565b61334a565b3390616da7565b50903390916004615dcf615dc97f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93615de4615ddb6103a2565b92839283615327565b0390a3565b615df16103a2565b62461bcd60e51b815280615e0760048201615d0b565b0390fd5b615e1490615c9a565b565b909182615e2681615e2d93611d33565b809361171d565b0190565b615e429060209493615e4993615e16565b8092611d64565b0190565b9091615e6490615e5b6103a2565b93849384615e31565b03902090565b9091615e7592615e4d565b90565b92615e9d615ea59392615e98615eaa96615e906127ae565b506009611d07565b611d1d565b919091615e6a565b61093e565b90565b615eb5614b56565b50615ec060016125bd565b90565b615ecd9051611159565b90565b90565b615ee7615ee2615eec92615ed0565b610749565b610554565b90565b60207f6c00000000000000000000000000000000000000000000000000000000000000917f4f70657261746f72206e6f7420656c696769626c6520666f722072656d6f76615f8201520152565b615f4960216040926109d5565b615f5281615eef565b0190565b615f6b9060208101905f818303910152615f3c565b90565b15615f7557565b615f7d6103a2565b62461bcd60e51b815280615f9360048201615f56565b0390fd5b9061604861604361604d9333615fc8615fc2615fbd615fb8600786906113c5565b6125bd565b6103ef565b916103ef565b148015616106575b615fd990615534565b615ff7615ff2615feb60038490610fc8565b8690611012565b614849565b61600360608201615ec3565b6160166160106003611159565b91611159565b03616050575b5061603b61603461602f60058490613334565b61334a565b8590616da7565b506004613334565b61334a565b616da7565b50565b6160cc906160a061609061606385616427565b61608a616085602061607e6160795f8601614976565b613624565b930161494d565b614983565b906128f8565b61609a600a615ed3565b906128f8565b6160ab5f8301613f56565b6160bd6160b75f612cc2565b91610554565b1191826160d2575b5050615f6e565b5f61601c565b6160fd9192506160f16160f7916160eb5f429201613f56565b9061367f565b92610554565b91610554565b10155f806160c5565b50615fd93361612461611e616119614b5a565b6103ef565b916103ef565b149050615fd0565b9061615661615b9161613c613bcb565b5061615161614985616427565b946003610fc8565b611012565b614849565b6161665f8201613f56565b6161786161725f612cc2565b91610554565b146161b3576161a96161a45f61619d6161af9461619783429201613f56565b9061367f565b9401614976565b613624565b91610554565b1090565b50505f90565b6161ca906161c561653f565b6161cc565b565b6161d781600161269a565b6161df614b5a565b9061621361620d7f38d16b8cac22d99fc7c124b9cd0de2d3fa1faef420bfe791d8c362d765e2270093611006565b91611006565b9161621c6103a2565b806162268161044b565b0390a3565b616234906161b9565b565b5f61627561627b9361626d3361626761626161625c61625760078a906113c5565b6125bd565b6103ef565b916103ef565b14612835565b926002612287565b016156ac565b565b5f7f4e6f742072656769737465726564000000000000000000000000000000000000910152565b6162b1600e6020926109d5565b6162ba8161627d565b0190565b6162d39060208101905f8183039101526162a4565b90565b156162dd57565b6162e56103a2565b62461bcd60e51b8152806162fb600482016162be565b0390fd5b61633b3361633561632f7f00000000000000000000000000000000000000000000000000000000000000006103ef565b916103ef565b14612580565b61636161635c61635561635060068590613334565b61334a565b8490616da7565b6162d6565b61637f61637861637360048490613334565b61334a565b8390616da7565b50906163b46163ae7f08bb93e5444209b15155078a13f6e341299d748d0c299f722c9cbc0723f0fe9e9361074c565b91611006565b916163bd6103a2565b806163c78161044b565b0390a3565b906164196164105f6163dc612743565b946163f36163eb838301611049565b83880161479e565b61640a616401838301611076565b602088016147ac565b016122b1565b60408401614f71565b565b616424906163cc565b90565b61643e6164439161643661278e565b506002612287565b61641b565b61644e5f8201614976565b61646061645a5f6158e8565b916103b4565b146164a6575b6164726020820161494d565b61648461647e5f61495a565b916104af565b1461648d575b90565b6164a161649861160f565b602083016147ac565b61648a565b6164b96164b1610c08565b5f830161479e565b616466565b6164c790610fde565b90565b6164de6164d96164e3926103e4565b610749565b610554565b90565b6164fa6164f56164ff92610554565b612677565b610f01565b90565b90565b9061653761653161652c6165275f61653c9661651f613bcb565b5001946164be565b6164ca565b6164e6565b91616502565b616e68565b90565b616547614b5a565b61656061655a616555616c55565b6103ef565b916103ef565b0361656757565b616589616572616c55565b5f91829163118cdaa760e01b835260048301610cc9565b0390fd5b906165bf6165b96165b46165af5f6165c4966165a7613bcb565b5001946164be565b6164ca565b6164e6565b91616502565b616ecb565b90565b6165e6916165dd916165d7614b56565b50616f27565b90929192616fe7565b90565b5f7f4f70657261746f7220697320736c617368656400000000000000000000000000910152565b61661d60136020926109d5565b616626816165e9565b0190565b61663f9060208101905f818303910152616610565b90565b1561664957565b6166516103a2565b62461bcd60e51b8152806166676004820161662a565b0390fd5b9061668061667b6166879261334d565b613359565b8254613002565b9055565b616694906103b4565b67ffffffffffffffff81146166a95760010190565b6128e4565b90565b6166c56166c06166ca926166ae565b610749565b6104af565b90565b9160206166ee9294936166e760408201965f830190611129565b0190610557565b565b6166f990610fde565b90565b616705906166f0565b90565b61671190610ffa565b90565b60409061673d616744949695939661673360608401985f850190610cbc565b6020830190610c21565b0190610c21565b565b949293919361676961676461675d60038990610fc8565b8790611012565b614dc6565b9361677387616427565b9361679d616783600188016110a3565b6167966167906003611159565b91611159565b1415616642565b6167bb6167b46167af60058b90613334565b61334a565b8890616505565b5061689060406167cd600189016110a3565b966167da425f8b01613018565b6168046167e88587906136fd565b6167fa6167f482613711565b9161370b565b2060028b0161666b565b6168196168105f61495a565b60018b01615307565b61683760018a0161683161682c82611049565b61668b565b90614de9565b61683f613cff565b508561685361684d5f61495a565b916104af565b145f14616b145761686a5f995b60018b910161340b565b8761687e6168786002611159565b91611159565b1480616af8575b616a8a575b0161505e565b80616a66575b616a50575b50508591859192426168df6168d96168d37f658918e3147f13dd068ec21437b4c25c21682a8dc2129348671ead000db3e7b99461074c565b9461074c565b94611006565b946168f46168eb6103a2565b928392836166cd565b0390a48061690a61690484611159565b91611159565b036169fa575b505061691c600b6125bd565b61693661693061692b5f6125e9565b6103ef565b916103ef565b03616940575b5050565b61695a616955616950600b6125bd565b6166fc565b616708565b9163d47853b691909261696c42613640565b92813b156169f5575f6169929161699d82966169866103a2565b98899788968795614b99565b855260048501616714565b03925af190816169c9575b50155f146169c45760016169bf575b5b5f8061693c565b6169b7565b6169b8565b6169e8905f3d81116169ee575b6169e081836108d7565b810190614b9f565b5f6169a8565b503d6169d6565b614b95565b83839192616a31616a2b7f228824b86c256469125f525ce18c6c2d0a9e133d13b8ec7a2c96a193b0c28a099361074c565b93611006565b93616a46616a3d6103a2565b92839283615327565b0390a35f80616910565b616a5f918891889091926174a4565b5f8061689b565b50616a72818390612d7e565b616a84616a7e5f612cc2565b91610554565b11616896565b616aa7616aa0616a9b8d6004613334565b61334a565b8b90616505565b508a8a616add616ad77fc9862c5f02eefbdcea01c207ae538e1d304dc93026870f48951e48a0f4c8470c9361074c565b91611006565b91616ae66103a2565b80616af08161044b565b0390a361688a565b5088616b0d616b076002611159565b91611159565b1415616885565b85616b28616b2260646166b1565b916104af565b105f14616b3b5761686a6001995b616860565b61686a600199616b538d8d8b908b908a928c94617158565b616b36565b616b6f5f616b7492616b686127ae565b5001616502565b617662565b90565b616b83616b8891610922565b61297e565b90565b616b9f616b9a616ba492610554565b610749565b6103e4565b90565b616bd2616bcd616bdc93616bc85f616bd795616bc1614b56565b5001616502565b6176d0565b616b77565b616b8b565b610ffa565b90565b91906008616bff910291616bf960018060a01b0384612955565b92612955565b9181191691161790565b9190616c1f616c1a616c2793611006565b612697565b908354616bdf565b9055565b616c3d91616c37614b56565b91616c09565b565b616c5390616c4e5f6001616c2b565b6176f1565b565b616c5d614b56565b503390565b616c6b90610554565b5f198114616c795760010190565b6128e4565b616c8890516103ef565b90565b93919293616c97613a9c565b50616cab616ca685849061367f565b613ada565b92616cb55f612cc2565b925b80616cca616cc488610554565b91610554565b1015616d3857616cee616ce7616ce260058690613334565b61334a565b8290616ba7565b616cfa84828a91617750565b616d0e575b50616d0990612cde565b616cb7565b616d099194616d2c616d3192616d278991849092613b01565b613b21565b616c62565b9390616cff565b509450509150616d4782613ada565b92616d515f612cc2565b5b80616d65616d5f86610554565b91610554565b1015616da157616d9c90616d97616d85616d80868490613b01565b616c7e565b616d928891849092613b01565b613b21565b612cde565b616d52565b50915050565b90616dd9616dd3616dce616dc95f616dde96616dc1613bcb565b5001946164be565b6164ca565b6164e6565b91616502565b617888565b90565b90565b5f5260205f2090565b5490565b616dfa81616ded565b821015616e1457616e0c600191616de4565b910201905f90565b61077e565b9081549168010000000000000000831015616e495782616e41916001616e4795018155616df1565b90613365565b565b6108c3565b5490565b90616e5c9061334d565b5f5260205260405f2090565b616e70613bcb565b50616e85616e7f828490616ecb565b156104c2565b5f14616ec557616ebb616ec092616ea7616ea05f8501616de1565b8290616e19565b6001616eb45f8501616e4e565b9301616e52565b613018565b600190565b50505f90565b616ee9916001616ee492616edd613bcb565b5001616e52565b61093e565b616efb616ef55f612cc2565b91610554565b141590565b5f90565b90565b616f1b616f16616f2092616f04565b610749565b610554565b90565b5f90565b919091616f32614b56565b50616f3b616f00565b50616f44613387565b50616f4e83613711565b616f61616f5b6041616f07565b91610554565b145f14616fa857616fa19192616f75613387565b50616f7e613387565b50616f87616f23565b506020810151606060408301519201515f1a909192617a07565b9192909190565b50616fb25f6125e9565b90616fc6616fc1600294613711565b6164e6565b91929190565b60041115616fd657565b611136565b90616fe582616fcc565b565b80616ffa616ff45f616fdb565b91616fdb565b145f14617005575050565b806170196170136001616fdb565b91616fdb565b145f1461703c575f63f645eedf60e01b8152806170386004820161044b565b0390fd5b8061705061704a6002616fdb565b91616fdb565b145f1461707e5761707a61706383616b77565b5f91829163fce698f760e01b835260048301610564565b0390fd5b61709161708b6003616fdb565b91616fdb565b146170995750565b6170b4905f9182916335e2f38360e21b835260048301610f11565b0390fd5b6170cc6170c76170d19261130e565b610749565b6104af565b90565b6170e06170e6916103b4565b916103b4565b90039067ffffffffffffffff82116170fa57565b6128e4565b5f7f50726f746f636f6c2076696f6c6174696f6e207265706f727465640000000000910152565b617133601b6020926109d5565b61713c816170ff565b0190565b6171559060208101905f818303910152617126565b90565b935050925061717061716a60c86170b8565b916104af565b101561717b575b5050565b61718442613640565b6171a261719d617196600c8590614881565b8590614897565b611049565b806171b56171af5f6158e8565b916103b4565b1490811561723b575b506171ca575b50617177565b6171e9906171e46171dd600c8590614881565b8590614897565b614de9565b9061721d6172177f1e2909cf45d70cf003f334b73c93330ce7e572782dfc82fab79deb8855a7c7919361074c565b91611006565b916172266103a2565b8061723081617140565b0390a35f80806171c4565b6172469150826170d4565b61725f617259617254610f7a565b6103b4565b916103b4565b10155f6171be565b90565b61727e61727961728392617267565b610749565b610554565b90565b9092919261729b617296826116fa565b6116bc565b938185526020850190828401116172b7576172b5926109de565b565b6116f6565b9080601f830112156172da578160206172d793519101617286565b90565b6105af565b905051906172ec826106f9565b565b9190916040818403126173415761730560406116bc565b925f8201519167ffffffffffffffff831161733c57617329826173359483016172bc565b5f8601526020016172df565b6020830152565b6116f2565b6116ee565b92919061735a617355826116d1565b6116bc565b93818552602080860192028101918383116173b15781905b838210617380575050505050565b815167ffffffffffffffff81116173ac576020916173a187849387016172ee565b815201910190617372565b6105af565b6105b7565b9080601f830112156173d4578160206173d193519101617346565b90565b6105af565b90602082820312617409575f82015167ffffffffffffffff81116174045761740192016173b6565b90565b6103b0565b6103ac565b60209181520190565b91906174318161742a816174369561740e565b809561171d565b6108b9565b0190565b90916174519260208301925f818503910152617417565b90565b61745e6032611551565b90565b9493916060916174a29461748d61749a9361748360808b01945f8c0190610c21565b60208a0190610cbc565b8782036040890152610e28565b940190610557565b565b916174b0818590612d7e565b6174c26174bc5f612cc2565b91610554565b1461765c576174d2818590612d7e565b6174e66174e061c35061726a565b91610554565b11617656575f6174f4613a21565b946174fe30613d2e565b6175206331e3bd1b94929461752b6175146103a2565b96879586948594614b99565b84526004840161743a565b03915afa80915f92617632575b50155f1461762957506001617624575b61755183610d97565b61756a61756461755f617454565b610554565b91610554565b115f1461761657617579617454565b5b61758330613d2e565b906365a6936e93929490823b15617611575f946175be86926175b3946175a76103a2565b998a9889978896614b99565b865260048601617461565b03925af190816175e5575b50155f146175e05760016175db575b5b565b6175d8565b6175d9565b617604905f3d811161760a575b6175fc81836108d7565b810190614b9f565b5f6175c9565b503d6175f2565b614b95565b61761f83610d97565b61757a565b505050565b90925091617548565b61764f9192503d805f833e61764781836108d7565b8101906173d9565b905f617538565b50505050565b50505050565b5f6176769161766f6127ae565b5001616e4e565b90565b5f5260205f2090565b61768b81616e4e565b8210156176a55761769d600191617679565b910201905f90565b61077e565b6176ba9060086176bf9302610c78565b6110b0565b90565b906176cd91546176aa565b90565b6176ee915f6176e8926176e1613387565b5001617682565b906176c2565b90565b6176fa5f6125bd565b617704825f61269a565b906177386177327f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e093611006565b91611006565b916177416103a2565b8061774b8161044b565b0390a3565b617758613bcb565b5061778061777a61777361776e60068590613334565b61334a565b849061658d565b156104c2565b617822576177a09161779661779b926003610fc8565b611012565b614849565b6177ab5f8201613f56565b6177bd6177b75f612cc2565b91610554565b1480156177fc575b6177f6576177eb6177e56177f1926177df5f429201613f56565b9061367f565b92610554565b91610554565b101590565b50505f90565b5061780960608201615ec3565b61781c6178166003611159565b91611159565b146177c5565b5050505f90565b61783d617838617842926155fe565b610749565b610554565b90565b634e487b7160e01b5f52603160045260245ffd5b61786281616ded565b801561788357600190039061788061787a8383616df1565b9061338b565b55565b617845565b617890613bcb565b506178a76178a2600183018490616e52565b61093e565b90816178bb6178b55f612cc2565b91610554565b14155f146179875761793992600161793492846178e25f966178dc85617829565b9061367f565b6178ff6178f0888501616e4e565b6178f986617829565b9061367f565b8161791261790c83610554565b91610554565b0361793e575b50505061792e617929868301616de1565b617859565b01616e52565b6129bf565b600190565b61797f9261797161795d61795761797a948c8901617682565b906176c2565b9361796b85918c8901617682565b90613365565b91858501616e52565b613018565b5f8080617918565b5050505f90565b90565b6179a56179a06179aa9261798e565b610749565b610554565b90565b6179e26179e9946179d86060949897956179ce608086019a5f870190610f04565b6020850190611129565b6040830190610f04565b0190610f04565b565b6179ff6179fa617a04926125ca565b612677565b610f01565b90565b939293617a12614b56565b50617a1b616f00565b50617a24613387565b50617a2e85616b77565b617a60617a5a7f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0617991565b91610554565b11617aed5790617a83602094955f94939293617a7a6103a2565b948594856179ad565b838052039060015afa15617ae857617a9b5f51612677565b80617ab6617ab0617aab5f6125e9565b6103ef565b916103ef565b14617acc575f91617ac65f6179eb565b91929190565b50617ad65f6125e9565b600191617ae25f6179eb565b91929190565b614bd1565b505050617af95f6125e9565b906003929192919056fea164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static DEPLOYED_BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\x80`@R`\x046\x10\x15a\0\x13W[a%#V[a\0\x1D_5a\x03\x9CV[\x80c\x05w\x85P\x14a\x03\x97W\x80c\x07X#o\x14a\x03\x92W\x80c\x0Cviz\x14a\x03\x8DW\x80c\x19\x1C\xBD\x1A\x14a\x03\x88W\x80c\x1E\x8F^\xE5\x14a\x03\x83W\x80c \x81)V\x14a\x03~W\x80c\"\xF1\xEC\x93\x14a\x03yW\x80c+\xF4\xD6\xA7\x14a\x03tW\x80c,\x95v\x88\x14a\x03oW\x80c-\xAE\x18\x85\x14a\x03jW\x80c/K\xD7\xB8\x14a\x03eW\x80c1\xE3\xBD\x1B\x14a\x03`W\x80c6D\xE5\x15\x14a\x03[W\x80c:\xC3\xCB\xE6\x14a\x03VW\x80c>n4\xA7\x14a\x03QW\x80c?\xD6,m\x14a\x03LW\x80c@#Z\x9C\x14a\x03GW\x80cH\xF4\xDA \x14a\x03BW\x80cV\x85\xCFh\x14a\x03=W\x80cV\xC4\xE1}\x14a\x038W\x80cY\xDC\xEA\x12\x14a\x033W\x80cZ\x93m\xC6\x14a\x03.W\x80c\\\xCE\x98\xA6\x14a\x03)W\x80c`vC\x9C\x14a\x03$W\x80c`\xCF\t\x91\x14a\x03\x1FW\x80ca\xD6\xB8l\x14a\x03\x1AW\x80cb\xC7\xE8\xFC\x14a\x03\x15W\x80ce\xA6\x93n\x14a\x03\x10W\x80ck\xFE\x06\xA6\x14a\x03\x0BW\x80cqP\x18\xA6\x14a\x03\x06W\x80cq\xE78\x8C\x14a\x03\x01W\x80cv9\xD2'\x14a\x02\xFCW\x80cy\xBAP\x97\x14a\x02\xF7W\x80c{\x9Fd\xB2\x14a\x02\xF2W\x80c\x81\xBE\xAC.\x14a\x02\xEDW\x80c\x84\xEFs\"\x14a\x02\xE8W\x80c\x8D\xA5\xCB[\x14a\x02\xE3W\x80c\x96hl\x1E\x14a\x02\xDEW\x80c\x9C\xBD\xAE\"\x14a\x02\xD9W\x80c\xAD\xFF\x83\x0C\x14a\x02\xD4W\x80c\xAEG\n\x85\x14a\x02\xCFW\x80c\xB0t\xE9\xDD\x14a\x02\xCAW\x80c\xB9\x9FgY\x14a\x02\xC5W\x80c\xBA\x1F\xB1\x03\x14a\x02\xC0W\x80c\xC1\xEF\x9D\xDF\x14a\x02\xBBW\x80c\xC5\xD9`\xBB\x14a\x02\xB6W\x80c\xCF\xE3GI\x14a\x02\xB1W\x80c\xD5Q\x16,\x14a\x02\xACW\x80c\xDACZ|\x14a\x02\xA7W\x80c\xE3\x0C9x\x14a\x02\xA2W\x80c\xE6\\\xAF\xCB\x14a\x02\x9DW\x80c\xEE\x1C\x03\x90\x14a\x02\x98W\x80c\xF2\xFD\xE3\x8B\x14a\x02\x93W\x80c\xF9\x10\x7F;\x14a\x02\x8EW\x80c\xF9\xF1gb\x14a\x02\x89Wc\xFF\xCF\x08\xF0\x03a\0\x0EWa$\xEFV[a$\xBAV[a$WV[a#\xF7V[a#\xC1V[a#\x8DV[a#XV[a# V[a\"NV[a\"\x19V[a!\xD7V[a!\xA2V[a xV[a DV[a\x1F\xD7V[a\x1F\x9DV[a\x1E\xD2V[a\x1E\x0BV[a\x1C\x82V[a\x1B\xC8V[a\x1B\x95V[a\x1B^V[a\x1A\xC9V[a\x1A\x96V[a\x1A`V[a\x1A*V[a\x19nV[a\x199V[a\x18\xCBV[a\x16\x86V[a\x16<V[a\x15\xBAV[a\x15\x85V[a\x15\x17V[a\x14\x82V[a\x14)V[a\x13\xF4V[a\x13\x8FV[a\x13EV[a\x12\xD9V[a\x12\x05V[a\x11\xCBV[a\x0F\x93V[a\x0F&V[a\x0E\xA7V[a\r,V[a\x0C\xDEV[a\x0CCV[a\x0B\x9DV[a\njV[a\x06\xC6V[a\x06tV[a\x06@V[a\x05yV[a\x05\x1FV[a\x04PV[`\xE0\x1C\x90V[`@Q\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x03\xCA\x81a\x03\xB4V[\x03a\x03\xD1WV[_\x80\xFD[\x90P5\x90a\x03\xE2\x82a\x03\xC1V[V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x03\xF8\x90a\x03\xE4V[\x90V[a\x04\x04\x81a\x03\xEFV[\x03a\x04\x0BWV[_\x80\xFD[\x90P5\x90a\x04\x1C\x82a\x03\xFBV[V[\x91\x90`@\x83\x82\x03\x12a\x04FW\x80a\x04:a\x04C\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x04\x0FV[\x90V[a\x03\xACV[_\x01\x90V[4a\x04\x7FWa\x04ia\x04c6`\x04a\x04\x1EV[\x90a&\xBAV[a\x04qa\x03\xA2V[\x80a\x04{\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x04\x9DWa\x04\x9A\x91_\x01a\x03\xD5V[\x90V[a\x03\xACV[a\x04\xAB\x90a\x03\xB4V[\x90RV[`\xFF\x16\x90V[a\x04\xBE\x90a\x04\xAFV[\x90RV[\x15\x15\x90V[a\x04\xD0\x90a\x04\xC2V[\x90RV[\x90`@\x80a\x05\x08\x93a\x04\xEC_\x82\x01Q_\x86\x01\x90a\x04\xA2V[a\x04\xFE` \x82\x01Q` \x86\x01\x90a\x04\xB5V[\x01Q\x91\x01\x90a\x04\xC7V[V[\x91\x90a\x05\x1D\x90_``\x85\x01\x94\x01\x90a\x04\xD4V[V[4a\x05OWa\x05Ka\x05:a\x0556`\x04a\x04\x84V[a'\x99V[a\x05Ba\x03\xA2V[\x91\x82\x91\x82a\x05\nV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x05`\x90a\x05TV[\x90RV[\x91\x90a\x05w\x90_` \x85\x01\x94\x01\x90a\x05WV[V[4a\x05\xAAWa\x05\xA6a\x05\x95a\x05\x8F6`\x04a\x04\x1EV[\x90a'\xB2V[a\x05\x9Da\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x05\xF5W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x05\xF0W` \x01\x92` \x83\x02\x84\x01\x11a\x05\xEBWV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x06;Wa\x06\x13\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x066Wa\x062\x92\x01a\x05\xBBV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x06oWa\x06Ya\x06S6`\x04a\x05\xFAV[\x91a1;V[a\x06aa\x03\xA2V[\x80a\x06k\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x06\xA3Wa\x06\x8Da\x06\x876`\x04a\x04\x1EV[\x90a4+V[a\x06\x95a\x03\xA2V[\x80a\x06\x9F\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\x06\xC1Wa\x06\xBE\x91_\x01a\x04\x0FV[\x90V[a\x03\xACV[4a\x06\xF4Wa\x06\xDEa\x06\xD96`\x04a\x06\xA8V[a5`V[a\x06\xE6a\x03\xA2V[\x80a\x06\xF0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x07\x02\x81a\x05TV[\x03a\x07\tWV[_\x80\xFD[\x90P5\x90a\x07\x1A\x82a\x06\xF9V[V[\x91\x90`@\x83\x82\x03\x12a\x07DW\x80a\x078a\x07A\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x07\rV[\x90V[a\x03\xACV[\x90V[a\x07`a\x07[a\x07e\x92a\x03\xB4V[a\x07IV[a\x03\xB4V[\x90V[\x90a\x07r\x90a\x07LV[_R` R`@_ \x90V[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[T\x90V[_R` _ \x90V[_R` _ \x90V[a\x07\xB1\x81a\x07\x92V[\x82\x10\x15a\x07\xCBWa\x07\xC3`\x04\x91a\x07\x96V[\x91\x02\x01\x90_\x90V[a\x07~V[cNH{q`\xE0\x1B_R`\"`\x04R`$_\xFD[\x90`\x01`\x02\x83\x04\x92\x16\x80\x15a\x08\x04W[` \x83\x10\x14a\x07\xFFWV[a\x07\xD0V[\x91`\x7F\x16\x91a\x07\xF4V[` \x91\x81R\x01\x90V[_R` _ \x90V[\x90_\x92\x91\x80T\x90a\x08:a\x083\x83a\x07\xE4V[\x80\x94a\x08\x0EV[\x91`\x01\x81\x16\x90\x81_\x14a\x08\x91WP`\x01\x14a\x08UW[PPPV[a\x08b\x91\x92\x93\x94Pa\x08\x17V[\x91_\x92[\x81\x84\x10a\x08yWPP\x01\x90_\x80\x80a\x08PV[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a\x08fV[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a\x08PV[\x90a\x08\xB6\x91a\x08 V[\x90V[`\x1F\x80\x19\x91\x01\x16\x90V[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[\x90a\x08\xE1\x90a\x08\xB9V[\x81\x01\x90\x81\x10g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11\x17a\x08\xFBW`@RV[a\x08\xC3V[\x90a\t a\t\x19\x92a\t\x10a\x03\xA2V[\x93\x84\x80\x92a\x08\xACV[\x03\x83a\x08\xD7V[V[_\x1C\x90V[\x90V[a\t6a\t;\x91a\t\"V[a\t'V[\x90V[a\tH\x90Ta\t*V[\x90V[`\xFF\x16\x90V[a\t]a\tb\x91a\t\"V[a\tKV[\x90V[a\to\x90Ta\tQV[\x90V[a\t}\x90`\x08a\x07hV[\x90a\t\x87\x82a\x07\x92V[\x81\x10\x15a\t\xCDWa\t\x97\x91a\x07\xA8V[P\x90a\t\xA4_\x83\x01a\t\0V[\x91a\t\xB1`\x01\x82\x01a\t>V[\x91a\t\xCA`\x03a\t\xC3`\x02\x85\x01a\t>V[\x93\x01a\teV[\x90V[_\x80\xFD[Q\x90V[` \x91\x81R\x01\x90V[\x90\x82_\x93\x92\x82^\x01RV[a\n\x08a\n\x11` \x93a\n\x16\x93a\t\xFF\x81a\t\xD1V[\x93\x84\x80\x93a\t\xD5V[\x95\x86\x91\x01a\t\xDEV[a\x08\xB9V[\x01\x90V[a\n#\x90a\x04\xC2V[\x90RV[a\naa\nh\x94a\nWa\nL``\x95\x99\x98\x96\x99`\x80\x86\x01\x90\x86\x82\x03_\x88\x01Ra\t\xE9V[\x98` \x85\x01\x90a\x05WV[`@\x83\x01\x90a\x05WV[\x01\x90a\n\x1AV[V[4a\n\x9FWa\n\x9Ba\n\x86a\n\x806`\x04a\x07\x1CV[\x90a\trV[\x90a\n\x92\x94\x92\x94a\x03\xA2V[\x94\x85\x94\x85a\n'V[\x03\x90\xF3[a\x03\xA8V[a\n\xAD\x81a\x04\xAFV[\x03a\n\xB4WV[_\x80\xFD[\x90P5\x90a\n\xC5\x82a\n\xA4V[V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x0B\x01W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\n\xFCW` \x01\x92`\x01\x83\x02\x84\x01\x11a\n\xF7WV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90`\xC0\x83\x82\x03\x12a\x0B\x98Wa\x0B\x1E\x81_\x85\x01a\x03\xD5V[\x92a\x0B,\x82` \x83\x01a\x03\xD5V[\x92a\x0B:\x83`@\x84\x01a\n\xB8V[\x92``\x83\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0B\x93W\x81a\x0B[\x91\x85\x01a\n\xC7V[\x92\x90\x93a\x0Bk\x83`\x80\x83\x01a\x03\xD5V[\x92`\xA0\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x0B\x8EWa\x0B\x8A\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xB0V[a\x03\xACV[4a\x0B\xD5Wa\x0B\xBFa\x0B\xB06`\x04a\x0B\x06V[\x96\x95\x90\x95\x94\x91\x94\x93\x92\x93a:\x0FV[a\x0B\xC7a\x03\xA2V[\x80a\x0B\xD1\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[_\x91\x03\x12a\x0B\xE4WV[a\x03\xACV[\x90V[a\x0C\0a\x0B\xFBa\x0C\x05\x92a\x0B\xE9V[a\x07IV[a\x03\xB4V[\x90V[a\x0C\x13a\x01,a\x0B\xECV[\x90V[a\x0C\x1Ea\x0C\x08V[\x90V[a\x0C*\x90a\x03\xB4V[\x90RV[\x91\x90a\x0CA\x90_` \x85\x01\x94\x01\x90a\x0C!V[V[4a\x0CsWa\x0CS6`\x04a\x0B\xDAV[a\x0Coa\x0C^a\x0C\x16V[a\x0Cfa\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x1C\x90V[`\x01\x80`\xA0\x1B\x03\x16\x90V[a\x0C\x97\x90`\x08a\x0C\x9C\x93\x02a\x0CxV[a\x0C|V[\x90V[\x90a\x0C\xAA\x91Ta\x0C\x87V[\x90V[a\x0C\xB9`\x0B_\x90a\x0C\x9FV[\x90V[a\x0C\xC5\x90a\x03\xEFV[\x90RV[\x91\x90a\x0C\xDC\x90_` \x85\x01\x94\x01\x90a\x0C\xBCV[V[4a\r\x0EWa\x0C\xEE6`\x04a\x0B\xDAV[a\r\na\x0C\xF9a\x0C\xADV[a\r\x01a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[a\r\x1Ea\x01,a\x0B\xECV[\x90V[a\r)a\r\x13V[\x90V[4a\r\\Wa\r<6`\x04a\x0B\xDAV[a\rXa\rGa\r!V[a\rOa\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x90` \x82\x82\x03\x12a\r\x92W_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\r\x8DWa\r\x89\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xACV[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\r\xC9a\r\xD2` \x93a\r\xD7\x93a\r\xC0\x81a\t\xD1V[\x93\x84\x80\x93a\x08\x0EV[\x95\x86\x91\x01a\t\xDEV[a\x08\xB9V[\x01\x90V[a\r\xE4\x90a\x05TV[\x90RV[\x90a\x0E\x12\x90` \x80a\x0E\x07`@\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\xAAV[\x94\x01Q\x91\x01\x90a\r\xDBV[\x90V[\x90a\x0E\x1F\x91a\r\xE8V[\x90V[` \x01\x90V[\x90a\x0E<a\x0E5\x83a\r\x97V[\x80\x92a\r\x9BV[\x90\x81a\x0EM` \x83\x02\x84\x01\x94a\r\xA4V[\x92_\x91[\x83\x83\x10a\x0E`WPPPPP\x90V[\x90\x91\x92\x93\x94` a\x0E\x82a\x0E|\x83\x85`\x01\x95\x03\x87R\x89Qa\x0E\x15V[\x97a\x0E\"V[\x93\x01\x93\x01\x91\x93\x92\x90a\x0EQV[a\x0E\xA4\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x0E(V[\x90V[4a\x0E\xD8Wa\x0E\xD4a\x0E\xC3a\x0E\xBD6`\x04a\raV[\x90a:[V[a\x0E\xCBa\x03\xA2V[\x91\x82\x91\x82a\x0E\x8FV[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[\x90V[a\x0F\r\x90a\x0F\x01V[\x90RV[\x91\x90a\x0F$\x90_` \x85\x01\x94\x01\x90a\x0F\x04V[V[4a\x0FVWa\x0F66`\x04a\x0B\xDAV[a\x0FRa\x0FAa\x0E\xDDV[a\x0FIa\x03\xA2V[\x91\x82\x91\x82a\x0F\x11V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x0Fra\x0Fma\x0Fw\x92a\x0F[V[a\x07IV[a\x03\xB4V[\x90V[a\x0F\x85a\x0E\x10a\x0F^V[\x90V[a\x0F\x90a\x0FzV[\x90V[4a\x0F\xC3Wa\x0F\xA36`\x04a\x0B\xDAV[a\x0F\xBFa\x0F\xAEa\x0F\x88V[a\x0F\xB6a\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[\x90a\x0F\xD2\x90a\x07LV[_R` R`@_ \x90V[a\x0F\xF2a\x0F\xEDa\x0F\xF7\x92a\x03\xE4V[a\x07IV[a\x03\xE4V[\x90V[a\x10\x03\x90a\x0F\xDEV[\x90V[a\x10\x0F\x90a\x0F\xFAV[\x90V[\x90a\x10\x1C\x90a\x10\x06V[_R` R`@_ \x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x16\x90V[a\x10Aa\x10F\x91a\t\"V[a\x10(V[\x90V[a\x10S\x90Ta\x105V[\x90V[`@\x1C\x90V[`\xFF\x16\x90V[a\x10na\x10s\x91a\x10VV[a\x10\\V[\x90V[a\x10\x80\x90Ta\x10bV[\x90V[`H\x1C\x90V[`\xFF\x16\x90V[a\x10\x9Ba\x10\xA0\x91a\x10\x83V[a\x10\x89V[\x90V[a\x10\xAD\x90Ta\x10\x8FV[\x90V[\x90V[a\x10\xBFa\x10\xC4\x91a\t\"V[a\x10\xB0V[\x90V[a\x10\xD1\x90Ta\x10\xB3V[\x90V[\x90a\x10\xE3a\x10\xE8\x92`\x03a\x0F\xC8V[a\x10\x12V[a\x10\xF3_\x82\x01a\t>V[\x91a\x11\0`\x01\x83\x01a\x10IV[\x91a\x11\r`\x01\x82\x01a\x10vV[\x91a\x11&`\x02a\x11\x1F`\x01\x85\x01a\x10\xA3V[\x93\x01a\x10\xC7V[\x90V[a\x112\x90a\x04\xAFV[\x90RV[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[`\x05\x11\x15a\x11TWV[a\x116V[\x90a\x11c\x82a\x11JV[V[a\x11n\x90a\x11YV[\x90V[a\x11z\x90a\x11eV[\x90RV[\x90\x95\x94\x92a\x11\xC9\x94a\x11\xB8a\x11\xC2\x92a\x11\xAE`\x80\x96a\x11\xA4`\xA0\x88\x01\x9C_\x89\x01\x90a\x05WV[` \x87\x01\x90a\x0C!V[`@\x85\x01\x90a\x11)V[``\x83\x01\x90a\x11qV[\x01\x90a\x0F\x04V[V[4a\x12\0Wa\x11\xFCa\x11\xE7a\x11\xE16`\x04a\x04\x1EV[\x90a\x10\xD4V[\x91a\x11\xF3\x95\x93\x95a\x03\xA2V[\x95\x86\x95\x86a\x11~V[\x03\x90\xF3[a\x03\xA8V[4a\x125Wa\x121a\x12 a\x12\x1B6`\x04a\x04\x84V[a:uV[a\x12(a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[a\x12V\x90a\x03\xEFV[\x90RV[\x90a\x12g\x81` \x93a\x12MV[\x01\x90V[` \x01\x90V[\x90a\x12\x8Ea\x12\x88a\x12\x81\x84a\x12:V[\x80\x93a\x12>V[\x92a\x12GV[\x90_[\x81\x81\x10a\x12\x9EWPPP\x90V[\x90\x91\x92a\x12\xB7a\x12\xB1`\x01\x92\x86Qa\x12ZV[\x94a\x12kV[\x91\x01\x91\x90\x91a\x12\x91V[a\x12\xD6\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra\x12qV[\x90V[4a\x13\tWa\x13\x05a\x12\xF4a\x12\xEF6`\x04a\x04\x84V[a;/V[a\x12\xFCa\x03\xA2V[\x91\x82\x91\x82a\x12\xC1V[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x13%a\x13 a\x13*\x92a\x13\x0EV[a\x07IV[a\x05TV[\x90V[a\x137`\xC8a\x13\x11V[\x90V[a\x13Ba\x13-V[\x90V[4a\x13uWa\x13U6`\x04a\x0B\xDAV[a\x13qa\x13`a\x13:V[a\x13ha\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x13\x8D\x90_` \x85\x01\x94\x01\x90a\n\x1AV[V[4a\x13\xC0Wa\x13\xBCa\x13\xABa\x13\xA56`\x04a\x04\x1EV[\x90a;\xCFV[a\x13\xB3a\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[\x90a\x13\xCF\x90a\x07LV[_R` R`@_ \x90V[a\x13\xF1\x90a\x13\xEC`\x07\x91_\x92a\x13\xC5V[a\x0C\x9FV[\x90V[4a\x14$Wa\x14 a\x14\x0Fa\x14\n6`\x04a\x04\x84V[a\x13\xDBV[a\x14\x17a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a\x14YWa\x14Ua\x14Da\x14?6`\x04a\x04\x84V[a<VV[a\x14La\x03\xA2V[\x91\x82\x91\x82a\x12\xC1V[\x03\x90\xF3[a\x03\xA8V[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x90V[4a\x14\xB2Wa\x14\x926`\x04a\x0B\xDAV[a\x14\xAEa\x14\x9Da\x14^V[a\x14\xA5a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[\x90`\x80\x82\x82\x03\x12a\x15\x12Wa\x14\xCE\x81_\x84\x01a\x03\xD5V[\x92a\x14\xDC\x82` \x85\x01a\x03\xD5V[\x92a\x14\xEA\x83`@\x83\x01a\n\xB8V[\x92``\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x15\rWa\x15\t\x92\x01a\n\xC7V[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x15IWa\x153a\x15*6`\x04a\x14\xB7V[\x93\x92\x90\x92a<\xC8V[a\x15;a\x03\xA2V[\x80a\x15E\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x15ea\x15`a\x15j\x92a\x15NV[a\x07IV[a\x05TV[\x90V[a\x15w`2a\x15QV[\x90V[a\x15\x82a\x15mV[\x90V[4a\x15\xB5Wa\x15\x956`\x04a\x0B\xDAV[a\x15\xB1a\x15\xA0a\x15zV[a\x15\xA8a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[4a\x15\xEBWa\x15\xE7a\x15\xD6a\x15\xD06`\x04a\x04\x1EV[\x90a<\xD7V[a\x15\xDEa\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x16\x07a\x16\x02a\x16\x0C\x92a\x15\xF0V[a\x07IV[a\x04\xAFV[\x90V[a\x16\x19`\x03a\x15\xF3V[\x90V[a\x16$a\x16\x0FV[\x90V[\x91\x90a\x16:\x90_` \x85\x01\x94\x01\x90a\x11)V[V[4a\x16lWa\x16L6`\x04a\x0B\xDAV[a\x16ha\x16Wa\x16\x1CV[a\x16_a\x03\xA2V[\x91\x82\x91\x82a\x16'V[\x03\x90\xF3[a\x03\xA8V[\x91\x90a\x16\x84\x90_` \x85\x01\x94\x01\x90a\x11qV[V[4a\x16\xB7Wa\x16\xB3a\x16\xA2a\x16\x9C6`\x04a\x04\x1EV[\x90a=\x03V[a\x16\xAAa\x03\xA2V[\x91\x82\x91\x82a\x16qV[\x03\x90\xF3[a\x03\xA8V[\x90a\x16\xCFa\x16\xC8a\x03\xA2V[\x92\x83a\x08\xD7V[V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x16\xE9W` \x80\x91\x02\x01\x90V[a\x08\xC3V[_\x80\xFD[_\x80\xFD[_\x80\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x17\x18Wa\x17\x14` \x91a\x08\xB9V[\x01\x90V[a\x08\xC3V[\x90\x82_\x93\x92\x827\x01RV[\x90\x92\x91\x92a\x17=a\x178\x82a\x16\xFAV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a\x17YWa\x17W\x92a\x17\x1DV[V[a\x16\xF6V[\x90\x80`\x1F\x83\x01\x12\x15a\x17|W\x81` a\x17y\x935\x91\x01a\x17(V[\x90V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x17\xD4Wa\x17\x98`@a\x16\xBCV[\x92_\x82\x015\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x17\xCFWa\x17\xBC\x82a\x17\xC8\x94\x83\x01a\x17^V[_\x86\x01R` \x01a\x07\rV[` \x83\x01RV[a\x16\xF2V[a\x16\xEEV[\x92\x91\x90a\x17\xEDa\x17\xE8\x82a\x16\xD1V[a\x16\xBCV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11a\x18DW\x81\x90[\x83\x82\x10a\x18\x13WPPPPPV[\x815g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x18?W` \x91a\x184\x87\x84\x93\x87\x01a\x17\x81V[\x81R\x01\x91\x01\x90a\x18\x05V[a\x05\xAFV[a\x05\xB7V[\x90\x80`\x1F\x83\x01\x12\x15a\x18gW\x81` a\x18d\x935\x91\x01a\x17\xD9V[\x90V[a\x05\xAFV[`\x80\x81\x83\x03\x12a\x18\xC6Wa\x18\x82\x82_\x83\x01a\x03\xD5V[\x92a\x18\x90\x83` \x84\x01a\x04\x0FV[\x92`@\x83\x015\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a\x18\xC1Wa\x18\xB5\x81a\x18\xBE\x93\x86\x01a\x18IV[\x93``\x01a\x07\rV[\x90V[a\x03\xB0V[a\x03\xACV[4a\x18\xFDWa\x18\xE7a\x18\xDE6`\x04a\x18lV[\x92\x91\x90\x91a@\xE9V[a\x18\xEFa\x03\xA2V[\x80a\x18\xF9\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90V[a\x19\x19a\x19\x14a\x19\x1E\x92a\x19\x02V[a\x07IV[a\x05TV[\x90V[a\x19+`@a\x19\x05V[\x90V[a\x196a\x19!V[\x90V[4a\x19iWa\x19I6`\x04a\x0B\xDAV[a\x19ea\x19Ta\x19.V[a\x19\\a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[4a\x19\x9CWa\x19~6`\x04a\x0B\xDAV[a\x19\x86aG\x18V[a\x19\x8Ea\x03\xA2V[\x80a\x19\x98\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x19\xAA\x90a\x11eV[\x90RV[a\x19\xB7\x90a\x0F\x01V[\x90RV[\x90`\x80\x80a\x1A\x13\x93a\x19\xD3_\x82\x01Q_\x86\x01\x90a\r\xDBV[a\x19\xE5` \x82\x01Q` \x86\x01\x90a\x04\xA2V[a\x19\xF7`@\x82\x01Q`@\x86\x01\x90a\x04\xB5V[a\x1A\t``\x82\x01Q``\x86\x01\x90a\x19\xA1V[\x01Q\x91\x01\x90a\x19\xAEV[V[\x91\x90a\x1A(\x90_`\xA0\x85\x01\x94\x01\x90a\x19\xBBV[V[4a\x1A[Wa\x1AWa\x1AFa\x1A@6`\x04a\x04\x1EV[\x90aHUV[a\x1ANa\x03\xA2V[\x91\x82\x91\x82a\x1A\x15V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\x91Wa\x1A\x8Da\x1A|a\x1Av6`\x04a\x04\x1EV[\x90aH\xADV[a\x1A\x84a\x03\xA2V[\x91\x82\x91\x82a\x0C.V[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xC4Wa\x1A\xA66`\x04a\x0B\xDAV[a\x1A\xAEaH\xD5V[a\x1A\xB6a\x03\xA2V[\x80a\x1A\xC0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x1A\xF9Wa\x1A\xF5a\x1A\xE4a\x1A\xDF6`\x04a\x04\x84V[aI&V[a\x1A\xECa\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a\x1B3Wa\x1B0a\x1B\x19\x84_\x85\x01a\x03\xD5V[\x93a\x1B'\x81` \x86\x01a\x07\rV[\x93`@\x01a\x07\rV[\x90V[a\x03\xACV[\x92\x91` a\x1BTa\x1B\\\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\x12qV[\x94\x01\x90a\x05WV[V[4a\x1B\x90Wa\x1Bwa\x1Bq6`\x04a\x1A\xFEV[\x91aI\xC4V[\x90a\x1B\x8Ca\x1B\x83a\x03\xA2V[\x92\x83\x92\x83a\x1B8V[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xC3Wa\x1B\xADa\x1B\xA86`\x04a\x06\xA8V[aKKV[a\x1B\xB5a\x03\xA2V[\x80a\x1B\xBF\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a\x1B\xF8Wa\x1B\xD86`\x04a\x0B\xDAV[a\x1B\xF4a\x1B\xE3aKZV[a\x1B\xEBa\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1C7W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1C2W` \x01\x92` \x83\x02\x84\x01\x11a\x1C-WV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91\x90\x91`@\x81\x84\x03\x12a\x1C}Wa\x1CU\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1CxWa\x1Ct\x92\x01a\x1B\xFDV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1C\xB1Wa\x1C\x9Ba\x1C\x956`\x04a\x1C<V[\x91aK\xE1V[a\x1C\xA3a\x03\xA2V[\x80a\x1C\xAD\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x91``\x83\x83\x03\x12a\x1D\x02Wa\x1C\xCD\x82_\x85\x01a\x03\xD5V[\x92a\x1C\xDB\x83` \x83\x01a\x04\x0FV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1C\xFDWa\x1C\xFA\x92\x01a\x17^V[\x90V[a\x03\xB0V[a\x03\xACV[\x90a\x1D\x11\x90a\x07LV[_R` R`@_ \x90V[\x90a\x1D'\x90a\x10\x06V[_R` R`@_ \x90V[\x90P\x90V[a\x1D]a\x1DT\x92` \x92a\x1DK\x81a\t\xD1V[\x94\x85\x80\x93a\x1D3V[\x93\x84\x91\x01a\t\xDEV[\x01\x90V[\x90V[a\x1Dpa\x1Du\x91a\x05TV[a\x1DaV[\x90RV[a\x1D\x89a\x1D\x90\x91` \x94\x93a\x1D8V[\x80\x92a\x1DdV[\x01\x90V[a\x1D\xA8a\x1D\x9Fa\x03\xA2V[\x92\x83\x92\x83a\x1DyV[\x03\x90 \x90V[a\x1D\xB7\x91a\x1D\x94V[\x90V[a\x1D\xCA\x90`\x08a\x1D\xCF\x93\x02a\x0CxV[a\t'V[\x90V[\x90a\x1D\xDD\x91Ta\x1D\xBAV[\x90V[\x90a\x1E\x08\x92a\x1D\xFEa\x1E\x03\x92a\x1D\xF9`\t\x95_\x96a\x1D\x07V[a\x1D\x1DV[a\x1D\xAEV[a\x1D\xD2V[\x90V[4a\x1E<Wa\x1E8a\x1E'a\x1E!6`\x04a\x1C\xB6V[\x91a\x1D\xE0V[a\x1E/a\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90\x91\x82`\x1F\x83\x01\x12\x15a\x1E{W\x815\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11a\x1EvW` \x01\x92`\x01\x83\x02\x84\x01\x11a\x1EqWV[a\x05\xB7V[a\x05\xB3V[a\x05\xAFV[\x91``\x83\x83\x03\x12a\x1E\xCDWa\x1E\x97\x82_\x85\x01a\x03\xD5V[\x92a\x1E\xA5\x83` \x83\x01a\x04\x0FV[\x92`@\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1E\xC8Wa\x1E\xC4\x92\x01a\x1EAV[\x90\x91V[a\x03\xB0V[a\x03\xACV[4a\x1F\x04Wa\x1E\xEEa\x1E\xE56`\x04a\x1E\x80V[\x92\x91\x90\x91aNFV[a\x1E\xF6a\x03\xA2V[\x80a\x1F\0\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\x1F\x12\x81a\x04\xC2V[\x03a\x1F\x19WV[_\x80\xFD[\x90P5\x90a\x1F*\x82a\x1F\tV[V[\x91\x90\x91`\xA0\x81\x84\x03\x12a\x1F\x98Wa\x1FE\x83_\x83\x01a\x03\xD5V[\x92` \x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a\x1F\x93W\x81a\x1Ff\x91\x84\x01a\x1EAV[\x92\x90\x93a\x1F\x90a\x1Fy\x84`@\x85\x01a\x07\rV[\x93a\x1F\x87\x81``\x86\x01a\x07\rV[\x93`\x80\x01a\x1F\x1DV[\x90V[a\x03\xB0V[a\x03\xACV[4a\x1F\xD2Wa\x1F\xBCa\x1F\xB06`\x04a\x1F,V[\x94\x93\x90\x93\x92\x91\x92aQ\x1BV[a\x1F\xC4a\x03\xA2V[\x80a\x1F\xCE\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a \x05Wa\x1F\xEFa\x1F\xEA6`\x04a\x04\x84V[aT\xD0V[a\x1F\xF7a\x03\xA2V[\x80a \x01\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x90\x91``\x82\x84\x03\x12a ?Wa <a %\x84_\x85\x01a\x03\xD5V[\x93a 3\x81` \x86\x01a\x03\xD5V[\x93`@\x01a\n\xB8V[\x90V[a\x03\xACV[4a sWa ]a W6`\x04a \nV[\x91aWEV[a ea\x03\xA2V[\x80a o\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a \xA7Wa \x91a \x8B6`\x04a\x04\x1EV[\x90aY\x04V[a \x99a\x03\xA2V[\x80a \xA3\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[Q\x90V[` \x91\x81R\x01\x90V[` \x01\x90V[\x90a!\r\x90``\x80a \xDE`\x80\x84\x01_\x87\x01Q\x85\x82\x03_\x87\x01Ra\r\xAAV[\x94a \xF1` \x82\x01Q` \x86\x01\x90a\r\xDBV[a!\x03`@\x82\x01Q`@\x86\x01\x90a\r\xDBV[\x01Q\x91\x01\x90a\x04\xC7V[\x90V[\x90a!\x1A\x91a \xBFV[\x90V[` \x01\x90V[\x90a!7a!0\x83a \xACV[\x80\x92a \xB0V[\x90\x81a!H` \x83\x02\x84\x01\x94a \xB9V[\x92_\x91[\x83\x83\x10a![WPPPPP\x90V[\x90\x91\x92\x93\x94` a!}a!w\x83\x85`\x01\x95\x03\x87R\x89Qa!\x10V[\x97a!\x1DV[\x93\x01\x93\x01\x91\x93\x92\x90a!LV[a!\x9F\x91` \x82\x01\x91_\x81\x84\x03\x91\x01Ra!#V[\x90V[4a!\xD2Wa!\xCEa!\xBDa!\xB86`\x04a\x04\x84V[a\\{V[a!\xC5a\x03\xA2V[\x91\x82\x91\x82a!\x8AV[\x03\x90\xF3[a\x03\xA8V[4a\"\x05Wa!\xEFa!\xEA6`\x04a\x04\x84V[a^\x0BV[a!\xF7a\x03\xA2V[\x80a\"\x01\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[a\"\x16`\n_\x90a\x0C\x9FV[\x90V[4a\"IWa\")6`\x04a\x0B\xDAV[a\"Ea\"4a\"\nV[a\"<a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a\"\x82Wa\"~a\"ma\"d6`\x04a\x1E\x80V[\x92\x91\x90\x91a^xV[a\"ua\x03\xA2V[\x91\x82\x91\x82a\x05dV[\x03\x90\xF3[a\x03\xA8V[\x90a\"\x91\x90a\x07LV[_R` R`@_ \x90V[a\"\xA9a\"\xAE\x91a\x10\x83V[a\tKV[\x90V[a\"\xBB\x90Ta\"\x9DV[\x90V[a\"\xC9\x90`\x02a\"\x87V[a\"\xD4_\x82\x01a\x10IV[\x91a\"\xEB_a\"\xE4\x81\x85\x01a\x10vV[\x93\x01a\"\xB1V[\x90V[`@\x90a#\x17a#\x1E\x94\x96\x95\x93\x96a#\r``\x84\x01\x98_\x85\x01\x90a\x0C!V[` \x83\x01\x90a\x11)V[\x01\x90a\n\x1AV[V[4a#SWa#Oa#;a#66`\x04a\x04\x84V[a\"\xBEV[a#F\x93\x91\x93a\x03\xA2V[\x93\x84\x93\x84a\"\xEEV[\x03\x90\xF3[a\x03\xA8V[4a#\x88Wa#h6`\x04a\x0B\xDAV[a#\x84a#sa^\xADV[a#{a\x03\xA2V[\x91\x82\x91\x82a\x0C\xC9V[\x03\x90\xF3[a\x03\xA8V[4a#\xBCWa#\xA6a#\xA06`\x04a\x04\x1EV[\x90a_\x97V[a#\xAEa\x03\xA2V[\x80a#\xB8\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[4a#\xF2Wa#\xEEa#\xDDa#\xD76`\x04a\x04\x1EV[\x90aa,V[a#\xE5a\x03\xA2V[\x91\x82\x91\x82a\x13zV[\x03\x90\xF3[a\x03\xA8V[4a$%Wa$\x0Fa$\n6`\x04a\x06\xA8V[ab+V[a$\x17a\x03\xA2V[\x80a$!\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x91\x90`@\x83\x82\x03\x12a$RW\x80a$Fa$O\x92_\x86\x01a\x03\xD5V[\x93` \x01a\x1F\x1DV[\x90V[a\x03\xACV[4a$\x86Wa$pa$j6`\x04a$*V[\x90ab6V[a$xa\x03\xA2V[\x80a$\x82\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[\x7F2r\x1F\x8D\xC6~\x95<T\r\xA9\x0Ff0Y\xC2?\xC4\x7Fp\xD1\x1E1~\xD6\xD5\xA2L\x8B\x85ct\x90V[a$\xB7a$\x8BV[\x90V[4a$\xEAWa$\xCA6`\x04a\x0B\xDAV[a$\xE6a$\xD5a$\xAFV[a$\xDDa\x03\xA2V[\x91\x82\x91\x82a\x0F\x11V[\x03\x90\xF3[a\x03\xA8V[4a%\x1EWa%\x08a%\x026`\x04a\x04\x1EV[\x90ab\xFFV[a%\x10a\x03\xA2V[\x80a%\x1A\x81a\x04KV[\x03\x90\xF3[a\x03\xA8V[_\x80\xFD[_\x7FOnly Tangle core\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a%[`\x10` \x92a\t\xD5V[a%d\x81a%'V[\x01\x90V[a%}\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra%NV[\x90V[\x15a%\x87WV[a%\x8Fa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a%\xA5`\x04\x82\x01a%hV[\x03\x90\xFD[a%\xB5a%\xBA\x91a\t\"V[a\x0C|V[\x90V[a%\xC7\x90Ta%\xA9V[\x90V[\x90V[a%\xE1a%\xDCa%\xE6\x92a%\xCAV[a\x07IV[a\x03\xE4V[\x90V[a%\xF2\x90a%\xCDV[\x90V[_\x7FAlready registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a&)`\x12` \x92a\t\xD5V[a&2\x81a%\xF5V[\x01\x90V[a&K\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra&\x1CV[\x90V[\x15a&UWV[a&]a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a&s`\x04\x82\x01a&6V[\x03\x90\xFD[_\x1B\x90V[\x90a&\x8D`\x01\x80`\xA0\x1B\x03\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90a&\xAFa&\xAAa&\xB6\x92a\x10\x06V[a&\x97V[\x82Ta&|V[\x90UV[a'<a'A\x92a&\xFD3a&\xF7a&\xF1\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[a'4a'\x14a'\x0F`\x07\x86\x90a\x13\xC5V[a%\xBDV[a'.a'(a'#_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14a&NV[\x91`\x07a\x13\xC5V[a&\x9AV[V[a'M``a\x16\xBCV[\x90V[_\x90V[_\x90V[_\x90V[a'da'CV[\x90` \x80\x80\x84a'ra'PV[\x81R\x01a'}a'TV[\x81R\x01a'\x88a'XV[\x81RPPV[a'\x96a'\\V[\x90V[a'\xAB\x90a'\xA5a'\x8EV[Pad'V[\x90V[_\x90V[a'\xD3a'\xD9\x92a'\xCE_\x93a'\xC6a'\xAEV[P`\x03a\x0F\xC8V[a\x10\x12V[\x01a\t>V[\x90V[_\x7FNot service owner\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(\x10`\x11` \x92a\t\xD5V[a(\x19\x81a'\xDCV[\x01\x90V[a(2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x03V[\x90V[\x15a(<WV[a(Da\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(Z`\x04\x82\x01a(\x1DV[\x03\x90\xFD[P\x90V[_\x7FToo many definitions\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a(\x96`\x14` \x92a\t\xD5V[a(\x9F\x81a(bV[\x01\x90V[a(\xB8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra(\x89V[\x90V[\x15a(\xC2WV[a(\xCAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a(\xE0`\x04\x82\x01a(\xA3V[\x03\x90\xFD[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[a)\x07a)\r\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x91a)\x19\x83\x82\x02a\x05TV[\x92\x81\x84\x04\x14\x90\x15\x17\x15a)(WV[a(\xE4V[a)8\x90`\x04a(\xF8V[\x90V[\x90a)N\x90_\x19\x90` \x03`\x08\x02a\x0CxV[\x81T\x16\x90UV[\x1B\x90V[\x91\x90`\x08a)t\x91\x02\x91a)n_\x19\x84a)UV[\x92a)UV[\x91\x81\x19\x16\x91\x16\x17\x90V[a)\x92a)\x8Da)\x97\x92a\x05TV[a\x07IV[a\x05TV[\x90V[\x90V[\x91\x90a)\xB3a)\xAEa)\xBB\x93a)~V[a)\x9AV[\x90\x83Ta)YV[\x90UV[a)\xD1\x91a)\xCBa'\xAEV[\x91a)\x9DV[V[[\x81\x81\x10a)\xDFWPPV[\x80a)\xEC_`\x01\x93a)\xBFV[\x01a)\xD4V[\x90a*\x02\x90_\x19\x90`\x08\x02a\x0CxV[\x19\x16\x90V[\x81a*\x11\x91a)\xF2V[\x90`\x02\x02\x17\x90V[\x90_\x91a*0a*(\x82a\x08\x17V[\x92\x83Ta*\x07V[\x90UUV[`\x1F` \x91\x01\x04\x90V[\x91\x92\x90` \x82\x10_\x14a*\x98W`\x1F\x84\x11`\x01\x14a*hWa*b\x92\x93Pa*\x07V[\x90U[[V[P\x90a*\x8Ea*\x93\x93`\x01a*\x85a*\x7F\x85a\x08\x17V[\x92a*5V[\x82\x01\x91\x01a)\xD3V[a*\x19V[a*eV[Pa*\xCF\x82\x93a*\xA9`\x01\x94a\x08\x17V[a*\xC8a*\xB5\x85a*5V[\x82\x01\x92`\x1F\x86\x16\x80a*\xDAW[Pa*5V[\x01\x90a)\xD3V[`\x02\x02\x17\x90Ua*fV[a*\xE6\x90\x88\x86\x03a);V[_a*\xC2V[\x92\x90\x91h\x01\0\0\0\0\0\0\0\0\x82\x11a+LW` \x11_\x14a+=W` \x81\x10_\x14a+!Wa+\x1B\x91a*\x07V[\x90U[[V[`\x01\x91`\xFF\x19\x16a+1\x84a\x08\x17V[U`\x02\x02\x01\x90Ua+\x1EV[`\x01\x91P`\x02\x02\x01\x90Ua+\x1FV[a\x08\xC3V[\x90\x81Ta+]\x81a\x07\xE4V[\x90\x81\x83\x11a+\x86W[\x81\x83\x10a+tW[PPPPV[a+}\x93a*?V[_\x80\x80\x80a+nV[a+\x92\x83\x83\x83\x87a*\xECV[a+fV[_a+\xA1\x91a+QV[V[cNH{q`\xE0\x1B_R_`\x04R`$_\xFD[\x90_\x03a+\xC8Wa+\xC6\x90a+\x97V[V[a+\xA3V[`\x03_\x91a+\xDD\x83\x80\x83\x01a+\xB6V[a+\xEA\x83`\x01\x83\x01a)\xBFV[a+\xF7\x83`\x02\x83\x01a)\xBFV[\x01UV[\x90_\x03a,\rWa,\x0B\x90a+\xCDV[V[a+\xA3V[[\x81\x81\x10a,\x1EWPPV[\x80a,+_`\x04\x93a+\xFBV[\x01a,\x13V[\x90\x91\x82\x81\x10a,@W[PPPV[a,^a,Xa,Ra,i\x95a)-V[\x92a)-V[\x92a\x07\x96V[\x91\x82\x01\x91\x01\x90a,\x12V[_\x80\x80a,;V[\x90h\x01\0\0\0\0\0\0\0\0\x81\x11a,\x9AW\x81a,\x8Fa,\x98\x93a\x07\x92V[\x90\x82\x81Ua,1V[V[a\x08\xC3V[_a,\xA9\x91a,qV[V[\x90_\x03a,\xBDWa,\xBB\x90a,\x9FV[V[a+\xA3V[a,\xD6a,\xD1a,\xDB\x92a%\xCAV[a\x07IV[a\x05TV[\x90V[`\x01a,\xEA\x91\x01a\x05TV[\x90V[_\x80\xFD[_\x80\xFD[_\x80\xFD[\x905\x90`\x01`\x80\x03\x816\x03\x03\x82\x12\x15a-\x10W\x01\x90V[a,\xEDV[\x90\x82\x10\x15a-/W` a-,\x92\x02\x81\x01\x90a,\xF9V[\x90V[a\x07~V[\x905\x90`\x01` \x03\x816\x03\x03\x82\x12\x15a-vW\x01\x805\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a-qW` \x01\x91`\x01\x82\x026\x03\x83\x13a-lWV[a,\xF5V[a,\xF1V[a,\xEDV[\x91V[P\x90V[_\x7FName too long\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a-\xB6`\r` \x92a\t\xD5V[a-\xBF\x81a-\x82V[\x01\x90V[a-\xD8\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra-\xA9V[\x90V[\x15a-\xE2WV[a-\xEAa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.\0`\x04\x82\x01a-\xC3V[\x03\x90\xFD[5a.\x0E\x81a\x06\xF9V[\x90V[_\x7FInvalid bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a.E`\x0E` \x92a\t\xD5V[a.N\x81a.\x11V[\x01\x90V[a.g\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra.8V[\x90V[\x15a.qWV[a.ya\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a.\x8F`\x04\x82\x01a.RV[\x03\x90\xFD[\x90V[_R` _ \x90V[T\x90V[a.\xAC\x81a.\x9FV[\x82\x10\x15a.\xC6Wa.\xBE`\x04\x91a.\x96V[\x91\x02\x01\x90_\x90V[a\x07~V[P\x90V[\x91\x90`\x1F\x81\x11a.\xDFW[PPPV[a.\xEBa/\x10\x93a\x08\x17V[\x90` a.\xF7\x84a*5V[\x83\x01\x93\x10a/\x18W[a/\t\x90a*5V[\x01\x90a)\xD3V[_\x80\x80a.\xDAV[\x91Pa/\t\x81\x92\x90Pa/\0V[\x91a/1\x90\x82a.\xCBV[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11a/\xF0Wa/U\x82a/O\x85Ta\x07\xE4V[\x85a.\xCFV[_\x90`\x1F\x83\x11`\x01\x14a/\x88W\x91\x80\x91a/w\x93_\x92a/|W[PPa*\x07V[\x90U[V[\x90\x91P\x015_\x80a/pV[`\x1F\x19\x83\x16\x91a/\x97\x85a\x08\x17V[\x92_[\x81\x81\x10a/\xD8WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10a/\xBEW[PPP\x02\x01\x90Ua/zV[a/\xCE\x91\x015`\x1F\x84\x16\x90a)\xF2V[\x90U_\x80\x80a/\xB2V[\x91\x93` `\x01\x81\x92\x87\x87\x015\x81U\x01\x95\x01\x92\x01a/\x9AV[a\x08\xC3V[\x90a0\0\x92\x91a/&V[V[\x90a0\x0E_\x19\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90a0-a0(a04\x92a)~V[a)\x9AV[\x82Ta0\x02V[\x90UV[5a0B\x81a\x1F\tV[\x90V[\x90a0Q`\xFF\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[a0d\x90a\x04\xC2V[\x90V[\x90V[\x90a0\x7Fa0za0\x86\x92a0[V[a0gV[\x82Ta0EV[\x90UV[\x90a0\xE8```\x03a0\xEE\x94a0\xAE_\x82\x01a0\xA8_\x88\x01\x88a-4V[\x91a/\xF5V[a0\xC7`\x01\x82\x01a0\xC1` \x88\x01a.\x04V[\x90a0\x18V[a0\xE0`\x02\x82\x01a0\xDA`@\x88\x01a.\x04V[\x90a0\x18V[\x01\x92\x01a08V[\x90a0jV[V[\x91\x90a1\x01Wa0\xFF\x91a0\x8AV[V[a+\xA3V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15a16W\x82a1.\x91`\x01a14\x95\x01\x81Ua.\xA3V[\x90a0\xF0V[V[a\x08\xC3V[\x92\x91\x90\x92a1n3a1ha1ba1]a1X`\x07\x87\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[a1\x9Ca1|\x85\x84\x90a(^V[a1\x95a1\x8Fa1\x8Aa\x15mV[a\x05TV[\x91a\x05TV[\x11\x15a(\xBBV[a1\xB1_a1\xAC`\x08\x84\x90a\x07hV[a,\xABV[a1\xBA_a,\xC2V[[\x80a1\xD8a1\xD2a1\xCD\x88\x87\x90a(^V[a\x05TV[\x91a\x05TV[\x10\x15a2\xABWa2\xA6\x90a2/a2\x0Fa2\ta2\x03a1\xFA\x8A\x89\x87\x91a-\x15V[_\x81\x01\x90a-4V[\x90a-{V[\x90a-~V[a2(a2\"a2\x1Da\x19!V[a\x05TV[\x91a\x05TV[\x11\x15a-\xDBV[a2xa2I`@a2C\x89\x88\x86\x91a-\x15V[\x01a.\x04V[a2qa2ka2f` a2`\x8C\x8B\x89\x91a-\x15V[\x01a.\x04V[a\x05TV[\x91a\x05TV[\x10\x15a.jV[a2\xA1a2\x8Fa2\x8A`\x08\x86\x90a\x07hV[a.\x93V[a2\x9B\x88\x87\x85\x91a-\x15V[\x90a1\x06V[a,\xDEV[a1\xBBV[PPP\x90PV[_\x7FZero address\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a2\xE6`\x0C` \x92a\t\xD5V[a2\xEF\x81a2\xB2V[\x01\x90V[a3\x08\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra2\xD9V[\x90V[\x15a3\x12WV[a3\x1Aa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a30`\x04\x82\x01a2\xF3V[\x03\x90\xFD[\x90a3>\x90a\x07LV[_R` R`@_ \x90V[\x90V[a3V\x90a\x0F\x01V[\x90V[a3b\x90a\t\"V[\x90V[\x91\x90a3{a3va3\x83\x93a3MV[a3YV[\x90\x83Ta)YV[\x90UV[_\x90V[a3\x9D\x91a3\x97a3\x87V[\x91a3eV[V[_`\x02a3\xBE\x92a3\xB2\x83\x80\x83\x01a)\xBFV[\x82`\x01\x82\x01U\x01a3\x8BV[V[\x90_\x03a3\xD2Wa3\xD0\x90a3\x9FV[V[a+\xA3V[`H\x1B\x90V[\x90a3\xF2i\xFF\0\0\0\0\0\0\0\0\0\x91a3\xD7V[\x91\x81\x19\x16\x91\x16\x17\x90V[a4\x05\x90a\x11YV[\x90V[\x90V[\x90a4 a4\x1Ba4'\x92a3\xFCV[a4\x08V[\x82Ta3\xDDV[\x90UV[a4g3a4aa4[\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[a4\x8C\x82a4\x85a4\x7Fa4z_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14\x15a3\x0BV[a4\xB2a4\xADa4\xA6a4\xA1`\x06\x85\x90a34V[a3JV[\x84\x90ae\x05V[a&NV[a4\xD1_a4\xCCa4\xC5`\x03\x85\x90a\x0F\xC8V[\x85\x90a\x10\x12V[a3\xC0V[a4\xF4`\x02`\x01a4\xEEa4\xE7`\x03\x86\x90a\x0F\xC8V[\x86\x90a\x10\x12V[\x01a4\x0BV[\x90a5(a5\"\x7F\x8E-\x88yZ<fq\x9A(vX\xCB\xF6\x8B>\xB2\xB8\xE1\x83\xCB\x18\xF4oH\x13\x91?\xC8\xAA\xFCK\x93a\x07LV[\x91a\x10\x06V[\x91a51a\x03\xA2V[\x80a5;\x81a\x04KV[\x03\x90\xA3V[a5Q\x90a5Lae?V[a5SV[V[a5^\x90`\x0Ba&\x9AV[V[a5i\x90a5@V[V[_\x7FNot registered operator\0\0\0\0\0\0\0\0\0\x91\x01RV[a5\x9F`\x17` \x92a\t\xD5V[a5\xA8\x81a5kV[\x01\x90V[a5\xC1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra5\x92V[\x90V[\x15a5\xCBWV[a5\xD3a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a5\xE9`\x04\x82\x01a5\xACV[\x03\x90\xFD[\x90a6\"\x97\x96\x95\x94\x93\x92\x91a6\x1Da6\x18a6\x11a6\x0C\x84`\x06a34V[a3JV[3\x90ae\x8DV[a5\xC4V[a8cV[V[a68a63a6=\x92a\x03\xB4V[a\x07IV[a\x05TV[\x90V[a6Ta6Oa6Y\x92a\x05TV[a\x07IV[a\x03\xB4V[\x90V[\x91` a6}\x92\x94\x93a6v`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x0C!V[V[a6\x8Ea6\x94\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x82\x03\x91\x82\x11a6\x9FWV[a(\xE4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a6\xC2Wa6\xBE` \x91a\x08\xB9V[\x01\x90V[a\x08\xC3V[\x90\x92\x91\x92a6\xDCa6\xD7\x82a6\xA4V[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11a6\xF8Wa6\xF6\x92a\x17\x1DV[V[a\x16\xF6V[a7\x08\x916\x91a6\xC7V[\x90V[` \x01\x90V[Q\x90V[\x94\x92\x90\x97\x96\x95\x93\x91`\xE0\x86\x01\x98_\x87\x01a7.\x91a\x0F\x04V[` \x86\x01a7;\x91a\x0C\xBCV[`@\x85\x01a7H\x91a\x0C!V[``\x84\x01a7U\x91a\x0C!V[`\x80\x83\x01a7b\x91a\x11)V[`\xA0\x82\x01a7o\x91a\x0F\x04V[`\xC0\x01a7{\x91a\x0C!V[V[_a\x19\x01`\xF0\x1B\x91\x01RV[a7\x95`\x02\x80\x92a\x1D3V[a7\x9E\x81a7}V[\x01\x90V[\x90V[a7\xB1a7\xB6\x91a\x0F\x01V[a7\xA2V[\x90RV[` \x80\x93\x92a7\xD5a7\xCEa7\xDD\x94a7\x89V[\x80\x92a7\xA5V[\x01\x80\x92a7\xA5V[\x01\x90V[_\x7FInvalid signature\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a8\x15`\x11` \x92a\t\xD5V[a8\x1E\x81a7\xE1V[\x01\x90V[a87\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra8\x08V[\x90V[\x15a8AWV[a8Ia\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a8_`\x04\x82\x01a8\"V[\x03\x90\xFD[\x91\x92\x93\x94\x97\x96\x90\x95\x97\x80a8\x7Fa8yBa\x05TV[\x91a6$V[\x11a9\xE7Wa8\x97Ba8\x91\x83a6$V[\x90a6\x7FV[a8\xB0a8\xAAa8\xA5a\r\x13V[a6$V[\x91a\x05TV[\x11a9\xBFWa9\xBD\x97\x98a9\x94a9\xB2\x93\x85a9\x1E\x8Aa9\x0F\x8Da9\x9A\x98\x8D\x8Da8\xE6a8\xDBa$\x8BV[\x963\x99\x95\x92\x93a6\xFDV[a8\xF8a8\xF2\x82a7\x11V[\x91a7\x0BV[ \x92\x93a9\x03a\x03\xA2V[\x98\x89\x97` \x89\x01a7\x15V[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD7V[a90a9*\x82a7\x11V[\x91a7\x0BV[ a9{\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a9la9`a\x03\xA2V[\x93\x84\x92` \x84\x01a7\xBAV[` \x82\x01\x81\x03\x82R\x03\x82a\x08\xD7V[a9\x8Da9\x87\x82a7\x11V[\x91a7\x0BV[ \x92a6\xFDV[\x90ae\xC7V[a9\xACa9\xA63a\x03\xEFV[\x91a\x03\xEFV[\x14a8:V[\x933\x91\x92\x93\x94agFV[V[a9\xC8Ba6@V[\x90a9\xE3_\x92\x83\x92c\x185[u`\xE2\x1B\x84R`\x04\x84\x01a6\\V[\x03\x90\xFD[a9\xF0Ba6@V[\x90a:\x0B_\x92\x83\x92cW\xEA\x02\xE9`\xE0\x1B\x84R`\x04\x84\x01a6\\V[\x03\x90\xFD[\x90a:\x1F\x97\x96\x95\x94\x93\x92\x91a5\xEDV[V[``\x90V[\x90` \x82\x82\x03\x12a:VW_\x82\x015g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a:QWa:N\x92\x01a\x18IV[\x90V[a\x03\xB0V[a\x03\xACV[\x90a:r\x91a:ha:!V[P\x90\x81\x01\x90a:&V[\x90V[a:\x94a:\x8Fa:\x99\x92a:\x87a'\xAEV[P`\x05a34V[a3JV[akXV[\x90V[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a:\xB9W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a:\xD0a:\xCB\x83a:\xA1V[a\x16\xBCV[\x91\x82RV[6\x907V[\x90a:\xFFa:\xE7\x83a:\xBEV[\x92` \x80a:\xF5\x86\x93a:\xA1V[\x92\x01\x91\x03\x90a:\xD5V[V[\x90a;\x0B\x82a\x12:V[\x81\x10\x15a;\x1CW` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90a;+\x90a\x03\xEFV[\x90RV[\x90a;8a:\x9CV[Pa;Ua;Pa;K`\x04\x85\x90a34V[a3JV[akXV[\x91a;_\x83a:\xDAV[\x91a;i_a,\xC2V[[\x80a;}a;w\x87a\x05TV[\x91a\x05TV[\x10\x15a;\xC4Wa;\xBF\x90a;\xBAa;\xA8a;\xA1a;\x9C`\x04\x88\x90a34V[a3JV[\x83\x90ak\xA7V[a;\xB5\x87\x91\x84\x90\x92a;\x01V[a;!V[a,\xDEV[a;jV[P\x92PP\x90V[_\x90V[\x90a;\xD8a;\xCBV[Pa;\xFA`\x01a;\xF4a;\xED`\x03\x86\x90a\x0F\xC8V[\x84\x90a\x10\x12V[\x01a\x10\xA3V[a<\x0Ca<\x06_a\x11YV[\x91a\x11YV[\x14\x91\x82\x15a<\x1AW[PP\x90V[a<;\x92P`\x01\x91a<0a<5\x92`\x03a\x0F\xC8V[a\x10\x12V[\x01a\x10\xA3V[a<Na<H`\x01a\x11YV[\x91a\x11YV[\x14_\x80a<\x15V[a<|\x90a<ba:\x9CV[P_\x90a<va<pa\x13-V[\x92a,\xC2V[\x90aI\xC4V[P\x90V[\x90a<\xB2\x94\x93\x92\x91a<\xADa<\xA8a<\xA1a<\x9C\x84`\x06a34V[a3JV[3\x90ae\x8DV[a5\xC4V[a<\xB4V[V[\x91a<\xC6\x94\x92\x93\x913\x91\x92\x93\x94agFV[V[\x90a<\xD5\x94\x93\x92\x91a<\x80V[V[\x90a<\xF7a<\xF2a<\xFC\x93a<\xEAa;\xCBV[P`\x06a34V[a3JV[ae\x8DV[\x90V[_\x90V[a=%a=+\x92a= `\x01\x93a=\x18a<\xFFV[P`\x03a\x0F\xC8V[a\x10\x12V[\x01a\x10\xA3V[\x90V[a=7\x90a\x0F\xFAV[\x90V[_\x7FInternal only\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a=n`\r` \x92a\t\xD5V[a=w\x81a=:V[\x01\x90V[a=\x90\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra=aV[\x90V[\x15a=\x9AWV[a=\xA2a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a=\xB8`\x04\x82\x01a={V[\x03\x90\xFD[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a=\xD4W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a=\xEBa=\xE6\x83a=\xBCV[a\x16\xBCV[\x91\x82RV[6\x907V[\x90a>\x1Aa>\x02\x83a=\xD9V[\x92` \x80a>\x10\x86\x93a=\xBCV[\x92\x01\x91\x03\x90a=\xF0V[V[\x90a>&\x82a\r\x97V[\x81\x10\x15a>7W` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90V[Q\x90V[\x90a>M\x82a>?V[\x81\x10\x15a>^W` \x80\x91\x02\x01\x01\x90V[a\x07~V[\x90a>m\x90a\x0F\x01V[\x90RV[``\x90V[\x90V[` \x91\x81R\x01\x90V[\x90_\x92\x91\x80T\x90a>\x9Ca>\x95\x83a\x07\xE4V[\x80\x94a>yV[\x91`\x01\x81\x16\x90\x81_\x14a>\xF3WP`\x01\x14a>\xB7W[PPPV[a>\xC4\x91\x92\x93\x94Pa\x07\x9FV[\x91_\x92[\x81\x84\x10a>\xDBWPP\x01\x90_\x80\x80a>\xB2V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a>\xC8V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a>\xB2V[\x90a?\x18\x91a>\x82V[\x90V[\x90a?;a?4\x92a?+a\x03\xA2V[\x93\x84\x80\x92a?\x0EV[\x03\x83a\x08\xD7V[V[a?F\x90a?\x1BV[\x90V[a?S\x90Qa\x0F\x01V[\x90V[a?`\x90Qa\x05TV[\x90V[_\x7FValue out of bounds\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[a?\x97`\x13` \x92a\t\xD5V[a?\xA0\x81a?cV[\x01\x90V[a?\xBCa?\xCA\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra\t\xE9V[\x90` \x81\x83\x03\x91\x01Ra?\x8AV[\x90V[\x92\x91` a?\xE9a?\xF1\x93`@\x87\x01\x90\x87\x82\x03_\x89\x01Ra\t\xE9V[\x94\x01\x90a\x05WV[V[\x90_\x92\x91\x80T\x90a@\ra@\x06\x83a\x07\xE4V[\x80\x94a\t\xD5V[\x91`\x01\x81\x16\x90\x81_\x14a@dWP`\x01\x14a@(W[PPPV[a@5\x91\x92\x93\x94Pa\x08\x17V[\x91_\x92[\x81\x84\x10a@LWPP\x01\x90_\x80\x80a@#V[`\x01\x81` \x92\x95\x93\x95T\x84\x86\x01R\x01\x91\x01\x92\x90a@9V[\x92\x94\x95PPP`\xFF\x19\x16\x82R\x15\x15` \x02\x01\x90_\x80\x80a@#V[_\x7FRequired metric missing\0\0\0\0\0\0\0\0\0\x91\x01RV[a@\xB3`\x17` \x92a\t\xD5V[a@\xBC\x81a@\x7FV[\x01\x90V[a@\xD8a@\xE6\x92`@\x83\x01\x90\x83\x82\x03_\x85\x01Ra?\xF3V[\x90` \x81\x83\x03\x91\x01Ra@\xA6V[\x90V[\x92\x93\x90\x93aA\x113aA\x0BaA\x05aA\x000a=.V[a\x03\xEFV[\x91a\x03\xEFV[\x14a=\x93V[aA%aA `\x08\x86\x90a\x07hV[a.\x93V[\x94aA/\x82a=\xF5V[\x94aA9_a,\xC2V[[\x80aAMaAG\x86a\x05TV[\x91a\x05TV[\x10\x15aA\xA0WaA\x9B\x90aA\x96aAq_aAi\x8A\x85\x90a>\x1CV[Q\x01Qa><V[aA\x83aA}\x82a7\x11V[\x91a7\x0BV[ aA\x91\x8A\x91\x84\x90\x92a>CV[a>cV[a,\xDEV[aA:V[P\x91\x94\x90\x92\x95aA\xAF\x81a.\x9FV[aA\xC1aA\xBB_a,\xC2V[\x91a\x05TV[\x11\x96aA\xCBa>qV[\x90\x88aFKW[aA\xDB_a,\xC2V[[\x80aA\xEFaA\xE9\x8Ba\x05TV[\x91a\x05TV[\x10\x15aD\xAEW`\x01_\x8BaB\xE2W[P\x90\x88\x87\x89aB\x14\x94aB\x19W[PPPa,\xDEV[aA\xDCV[\x82_aBWaBOaB`\x94aBJaBB` aB;aBe\x9B\x8D\x90a>\x1CV[Q\x01a?VV[\x97`\ta\x1D\x07V[a\x1D\x1DV[\x92\x87\x90a>\x1CV[Q\x01Q\x90a\x1D\xAEV[a0\x18V[\x88\x87\x89\x90aB\x8F` aB\x88_aB}\x87\x89\x90a>\x1CV[Q\x01Q\x95\x87\x90a>\x1CV[Q\x01a?VV[aB\xC2aB\xBC\x7F#\xED\x02\xBD6\x05\xBD\xEAj\x8A\xFAv\xC4o\0\xD2t\x86\x0B\xA6\xCE\xA9\x80\xF2X[im\xF9\xE1\x82\xBD\x93a\x07LV[\x93a\x10\x06V[\x93aB\xD7aB\xCEa\x03\xA2V[\x92\x83\x92\x83a?\xCDV[\x03\x90\xA3\x88\x87\x89aB\x0CV[\x9A\x90\x95\x92\x91\x99aB\xF1_a,\xC2V[[\x80aC\raC\x07aC\x02\x8Aa.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aD\x98WaC%aC \x8D\x87a>CV[a?IV[aCIaCCaC>aC9\x8A\x86\x90a>CV[a?IV[a\x0F\x01V[\x91a\x0F\x01V[\x14aC\\WaCW\x90a,\xDEV[aB\xF2V[\x8A\x91\x9B\x92\x9CP\x89aB\x14\x94\x95\x98\x8A\x92`\x01\x90\x8AaC\x86` aC\x7F\x89\x8B\x90a>\x1CV[Q\x01a?VV[aC\xAEaC\xA8aC\xA3`\x01aC\x9C\x86\x88\x90a.\xA3V[P\x01a\t>V[a\x05TV[\x91a\x05TV[\x10\x91\x88\x88\x84\x15aDNW[PPPPaC\xE3W[aC\xCD\x90[\x15a\x04\xC2V[aC\xDCW[\x93\x94PPPaA\xFEV[P_aC\xD2V[\x90P\x82\x82_aC\xF3\x87\x89\x90a>\x1CV[Q\x01Q\x91aD?aD-aD'\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07LV[\x93a\x10\x06V[\x93aD6a\x03\xA2V[\x91\x82\x91\x82a?\xA4V[\x03\x90\xA3aC\xCD_\x91\x90PaC\xC2V[aD\x8E\x93\x94PaD|aD\x88\x93aDv` aDoaD\x83\x96`\x02\x96a>\x1CV[Q\x01a?VV[\x96a.\xA3V[P\x01a\t>V[a\x05TV[\x91a\x05TV[\x11\x8A_\x88\x88aC\xB9V[P\x99\x90\x9A\x87\x89aB\x14\x94\x95\x98aC\xCD\x8D\x94aC\xC7V[P\x97PP\x92\x93P\x93PaD\xC0_a,\xC2V[\x93[\x84aD\xDDaD\xD7aD\xD2\x86a.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aFDWaE\x03aD\xFD`\x03aD\xF6\x86\x89\x90a.\xA3V[P\x01a\teV[\x15a\x04\xC2V[aF9WaE%aE _aE\x19\x86\x89\x90a.\xA3V[P\x01a>vV[a?=V[aE7aE1\x82a7\x11V[\x91a7\x0BV[ \x90_\x96aED_a,\xC2V[[\x80aE`aEZaEU\x86a>?V[a\x05TV[\x91a\x05TV[\x10\x15aF'WaEyaEt\x84\x83\x90a>CV[a?IV[aE\x8BaE\x85\x86a\x0F\x01V[\x91a\x0F\x01V[\x14aE\x9EWaE\x99\x90a,\xDEV[aEEV[P\x95\x90\x96PaE\xBF\x91PaE\xB4`\x01[\x15a\x04\xC2V[aE\xC6W[[a,\xDEV[\x93\x94aD\xC2V[\x82\x85_aE\xD4\x87\x85\x90a.\xA3V[P\x01\x91aF\x1FaF\raF\x07\x7F\xE0\x8FB\x89l\xE3\xAE\xC2\xFF}\xA9Z\x007/3\xCFg~u\xAD`%\x90\x83*\x8D\xFF\xCD\xADc\x15\x93a\x07LV[\x93a\x10\x06V[\x93aF\x16a\x03\xA2V[\x91\x82\x91\x82a@\xC0V[\x03\x90\xA3aE\xB9V[P\x95\x90\x96aE\xBF\x92PaE\xB4\x90aE\xAEV[\x94\x93aE\xBF\x90aE\xBAV[PPPPPV[\x96\x93\x90PaFeaF`\x83\x97\x94\x99\x96\x93a.\x9FV[a=\xF5V[\x97aFo_a,\xC2V[[\x80aF\x8BaF\x85aF\x80\x8Ba.\x9FV[a\x05TV[\x91a\x05TV[\x10\x15aF\xE5WaF\xE0\x90aF\xDBaF\xB6aF\xB1_aF\xAA\x8D\x86\x90a.\xA3V[P\x01a>vV[a?=V[aF\xC8aF\xC2\x82a7\x11V[\x91a7\x0BV[ aF\xD6\x8D\x91\x84\x90\x92a>CV[a>cV[a,\xDEV[aFpV[P\x92\x95\x91\x94\x97\x90\x93\x96aA\xD2V[aF\xFBae?V[aG\x03aG\x05V[V[aG\x16aG\x11_a%\xE9V[al?V[V[aG aF\xF3V[V[aG,`\xA0a\x16\xBCV[\x90V[_\x90V[_\x90V[_\x90V[aGCaG\"V[\x90` \x80\x80\x80\x80\x86aGSaG/V[\x81R\x01aG^a'PV[\x81R\x01aGia'TV[\x81R\x01aGtaG3V[\x81R\x01aG\x7FaG7V[\x81RPPV[aG\x8DaG;V[\x90V[\x90aG\x9A\x90a\x05TV[\x90RV[\x90aG\xA8\x90a\x03\xB4V[\x90RV[\x90aG\xB6\x90a\x04\xAFV[\x90RV[\x90aG\xC4\x90a\x11YV[\x90RV[\x90aHGaH>`\x02aG\xD9aG\"V[\x94aG\xF0aG\xE8_\x83\x01a\t>V[_\x88\x01aG\x90V[aH\x08aG\xFF`\x01\x83\x01a\x10IV[` \x88\x01aG\x9EV[aH aH\x17`\x01\x83\x01a\x10vV[`@\x88\x01aG\xACV[aH8aH/`\x01\x83\x01a\x10\xA3V[``\x88\x01aG\xBAV[\x01a\x10\xC7V[`\x80\x84\x01a>cV[V[aHR\x90aG\xC8V[\x90V[aHz\x91aHpaHu\x92aHhaG\x85V[P`\x03a\x0F\xC8V[a\x10\x12V[aHIV[\x90V[_\x90V[\x90aH\x8B\x90a\x07LV[_R` R`@_ \x90V[\x90aH\xA1\x90a\x10\x06V[_R` R`@_ \x90V[aH\xD2\x91aH\xC8aH\xCD\x92aH\xC0aH}V[P`\x0CaH\x81V[aH\x97V[a\x10IV[\x90V[aH\xDDalUV[aH\xE5a^\xADV[aH\xF7aH\xF1\x83a\x03\xEFV[\x91a\x03\xEFV[\x03aI\x07WaI\x05\x90al?V[V[aI\"\x90_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xC9V[\x03\x90\xFD[aIEaI@aIJ\x92aI8a'\xAEV[P`\x04a34V[a3JV[akXV[\x90V[aIW\x90Qa\x04\xAFV[\x90V[aInaIiaIs\x92a%\xCAV[a\x07IV[a\x04\xAFV[\x90V[aI\x80\x90Qa\x03\xB4V[\x90V[aI\x97aI\x92aI\x9C\x92a\x04\xAFV[a\x07IV[a\x05TV[\x90V[aI\xAEaI\xB4\x91\x93\x92\x93a\x05TV[\x92a\x05TV[\x82\x01\x80\x92\x11aI\xBFWV[a(\xE4V[\x90\x92\x91\x92aI\xD0a:\x9CV[PaI\xD9a'\xAEV[PaI\xE3\x82ad'V[\x93aJ\0aI\xFBaI\xF6`\x05\x86\x90a34V[a3JV[akXV[\x92aJ\r` \x87\x01aIMV[aJ\x1FaJ\x19_aIZV[\x91a\x04\xAFV[\x14\x80\x15aK\x11W[\x80\x15aJ\xF6W[aJ\xDCWaJh\x86aJbaJ]` aJVaJQ_aJ\xC5\x9B\x9C\x9D\x01aIvV[a6$V[\x93\x01aIMV[aI\x83V[\x90a(\xF8V[\x91\x80aJ\x83aJ}aJxa\x13-V[a\x05TV[\x91a\x05TV[\x11_\x14aJ\xD7WPaJ\x93a\x13-V[[aJ\x9F\x84\x82\x90aI\x9FV[aJ\xB1aJ\xAB\x88a\x05TV[\x91a\x05TV[\x11_\x14aJ\xC8WP\x84[\x90\x92\x90\x91\x92al\x8BV[\x91V[aJ\xD2\x90\x84aI\x9FV[aJ\xBBV[aJ\x94V[PPP\x91PaJ\xF2aJ\xED_a,\xC2V[a:\xDAV[\x91\x90V[P\x82aK\naK\x04\x86a\x05TV[\x91a\x05TV[\x10\x15aJ.V[P\x83aK%aK\x1F_a,\xC2V[\x91a\x05TV[\x14aJ'V[aK<\x90aK7ae?V[aK>V[V[aKI\x90`\na&\x9AV[V[aKT\x90aK+V[V[_\x90V[aKbaKVV[PaKl_a%\xBDV[\x90V[P\x90V[\x91\x90\x81\x10\x15aK\x83W` \x02\x01\x90V[a\x07~V[5aK\x92\x81a\x03\xFBV[\x90V[_\x80\xFD[`\xE0\x1B\x90V[_\x91\x03\x12aK\xA9WV[a\x03\xACV[\x91` aK\xCF\x92\x94\x93aK\xC8`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x0C\xBCV[V[aK\xD9a\x03\xA2V[=_\x82>=\x90\xFD[\x90\x92\x91\x92aK\xEE_a,\xC2V[[\x80aL\x0CaL\x06aL\x01\x85\x89\x90aKoV[a\x05TV[\x91a\x05TV[\x10\x15aL\xBBWaL\x1B0a=.V[\x90c\xBA\x1F\xB1\x03\x84aL6aL1\x86\x8A\x86\x91aKsV[aK\x88V[\x93\x80;\x15aL\xB6WaL[_\x80\x94aLfaLOa\x03\xA2V[\x98\x89\x96\x87\x95\x86\x94aK\x99V[\x84R`\x04\x84\x01aK\xAEV[\x03\x92Z\xF1\x91\x82\x15aL\xB1WaL\x80\x92aL\x85W[Pa,\xDEV[aK\xEFV[aL\xA4\x90_=\x81\x11aL\xAAW[aL\x9C\x81\x83a\x08\xD7V[\x81\x01\x90aK\x9FV[_aLzV[P=aL\x92V[aK\xD1V[aK\x95V[PPP\x90PV[_\x7FNot slashing oracle\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aL\xF6`\x13` \x92a\t\xD5V[aL\xFF\x81aL\xC2V[\x01\x90V[aM\x18\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaL\xE9V[\x90V[\x15aM\"WV[aM*a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aM@`\x04\x82\x01aM\x03V[\x03\x90\xFD[_\x7FOperator unknown\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aMx`\x10` \x92a\t\xD5V[aM\x81\x81aMDV[\x01\x90V[aM\x9A\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaMkV[\x90V[\x15aM\xA4WV[aM\xACa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aM\xC2`\x04\x82\x01aM\x85V[\x03\x90\xFD[\x90V[\x90aM\xDCg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x91a&wV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x90V[\x90aM\xFEaM\xF9aN\x05\x92a\x07LV[aM\xE6V[\x82TaM\xC9V[\x90UV[\x91\x90aN#\x81aN\x1C\x81aN(\x95a\t\xD5V[\x80\x95a\x17\x1DV[a\x08\xB9V[\x01\x90V[\x90\x91aNC\x92` \x83\x01\x92_\x81\x85\x03\x91\x01RaN\tV[\x90V[aNk3aNeaN_aNZ`\na%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14aM\x1BV[aN\x91aN\x8CaN\x85aN\x80`\x05\x85\x90a34V[a3JV[\x84\x90ae\x8DV[aM\x9DV[aN\xBDaN\xB2aN\xADaN\xA6`\x03\x85\x90a\x0F\xC8V[\x85\x90a\x10\x12V[aM\xC6V[`\x01`\x03\x91\x01a4\x0BV[aN\xDBaN\xD4aN\xCF`\x04\x84\x90a34V[a3JV[\x83\x90am\xA7V[PaO\x03aN\xE8Ba6@V[aN\xFEaN\xF7`\x0C\x85\x90aH\x81V[\x85\x90aH\x97V[aM\xE9V[\x90\x91\x92aO9aO3\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07LV[\x93a\x10\x06V[\x93aONaOEa\x03\xA2V[\x92\x83\x92\x83aN,V[\x03\x90\xA3V[aO]`\x80a\x16\xBCV[\x90V[aOk\x916\x91a\x17(V[\x90V[RV[\x90aO{\x90a\x04\xC2V[\x90RV[Q\x90V[\x90aO\x8D\x81a\t\xD1V[\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11aPMWaO\xB1\x82aO\xAB\x85Ta\x07\xE4V[\x85a.\xCFV[` \x90`\x1F\x83\x11`\x01\x14aO\xE5W\x91\x80\x91aO\xD4\x93_\x92aO\xD9W[PPa*\x07V[\x90U[V[\x90\x91P\x01Q_\x80aO\xCDV[`\x1F\x19\x83\x16\x91aO\xF4\x85a\x08\x17V[\x92_[\x81\x81\x10aP5WP\x91`\x02\x93\x91\x85`\x01\x96\x94\x10aP\x1BW[PPP\x02\x01\x90UaO\xD7V[aP+\x91\x01Q`\x1F\x84\x16\x90a)\xF2V[\x90U_\x80\x80aP\x0FV[\x91\x93` `\x01\x81\x92\x87\x87\x01Q\x81U\x01\x95\x01\x92\x01aO\xF7V[a\x08\xC3V[\x90aP\\\x91aO\x83V[V[aPh\x90Qa\x04\xC2V[\x90V[\x90aP\xC8```\x03aP\xCE\x94aP\x8E_\x82\x01aP\x88_\x88\x01aO\x7FV[\x90aPRV[aP\xA7`\x01\x82\x01aP\xA1` \x88\x01a?VV[\x90a0\x18V[aP\xC0`\x02\x82\x01aP\xBA`@\x88\x01a?VV[\x90a0\x18V[\x01\x92\x01aP^V[\x90a0jV[V[\x91\x90aP\xE1WaP\xDF\x91aPkV[V[a+\xA3V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15aQ\x16W\x82aQ\x0E\x91`\x01aQ\x14\x95\x01\x81Ua.\xA3V[\x90aP\xD0V[V[a\x08\xC3V[aR9\x95aR\"\x84\x96aR\x19aR\x11aQ\xFDaQ\xF8aR+\x97aQ\x9EaQ~aQxaR4\x9D\x8D\x9F\x9DaQs3aQmaQgaQbaQ]`\x07\x8C\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[a-{V[\x90a-~V[aQ\x97aQ\x91aQ\x8Ca\x19!V[a\x05TV[\x91a\x05TV[\x11\x15a-\xDBV[aQ\xBB\x86aQ\xB4aQ\xAE\x8Da\x05TV[\x91a\x05TV[\x10\x15a.jV[aQ\xF1aQ\xD2aQ\xCD`\x08\x84\x90a\x07hV[a\x07\x92V[aQ\xEBaQ\xE5aQ\xE0a\x15mV[a\x05TV[\x91a\x05TV[\x10a(\xBBV[`\x08a\x07hV[a.\x93V[\x98\x99\x96\x92\x94\x96aR\x0BaOSV[\x9AaO`V[_\x8A\x01aOnV[` \x88\x01aG\x90V[`@\x86\x01aG\x90V[``\x84\x01aOqV[aP\xE6V[V[aRi\x90aRdaR_aRXaRS\x84`\x06a34V[a3JV[3\x90ae\x8DV[a5\xC4V[aSJV[V[_\x7FCannot go online while slashed\0\0\x91\x01RV[aR\x9F`\x1E` \x92a\t\xD5V[aR\xA8\x81aRkV[\x01\x90V[aR\xC1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaR\x92V[\x90V[`@\x1B\x90V[\x90aR\xDEh\xFF\0\0\0\0\0\0\0\0\x91aR\xC4V[\x91\x81\x19\x16\x91\x16\x17\x90V[aR\xFCaR\xF7aS\x01\x92a\x04\xAFV[a\x07IV[a\x04\xAFV[\x90V[\x90V[\x90aS\x1CaS\x17aS#\x92aR\xE8V[aS\x04V[\x82TaR\xCAV[\x90UV[\x91` aSH\x92\x94\x93aSA`@\x82\x01\x96_\x83\x01\x90a\x11qV[\x01\x90a\x11qV[V[aShaScaS\\`\x03\x84\x90a\x0F\xC8V[3\x90a\x10\x12V[aM\xC6V[\x90aSu`\x01\x83\x01a\x10\xA3V[\x91\x82aS\x8AaS\x84`\x03a\x11YV[\x91a\x11YV[\x14aT\xAEW\x82aS\xA2aS\x9C_a\x11YV[\x91a\x11YV[\x14\x80\x15aT\x93W[aT\x8EWaS\xD1\x90aS\xBF`\x01\x80\x83\x01a4\x0BV[`\x01aS\xCA_aIZV[\x91\x01aS\x07V[aS\xEFaS\xE8aS\xE3`\x04\x84\x90a34V[a3JV[3\x90ae\x05V[P\x803aT%aT\x1F\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07LV[\x91a\x10\x06V[\x91aT.a\x03\xA2V[\x80aT8\x81a\x04KV[\x03\x90\xA3\x903\x90\x91`\x01aTtaTn\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93aT\x89aT\x80a\x03\xA2V[\x92\x83\x92\x83aS'V[\x03\x90\xA3V[PPPV[P\x82aT\xA8aT\xA2`\x01a\x11YV[\x91a\x11YV[\x14aS\xAAV[aT\xB6a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aT\xCC`\x04\x82\x01aR\xACV[\x03\x90\xFD[aT\xD9\x90aR;V[V[_\x7FNot authorized\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\x0F`\x0E` \x92a\t\xD5V[aU\x18\x81aT\xDBV[\x01\x90V[aU1\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaU\x02V[\x90V[\x15aU;WV[aUCa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aUY`\x04\x82\x01aU\x1CV[\x03\x90\xFD[\x90V[aUtaUoaUy\x92aU]V[a\x07IV[a\x03\xB4V[\x90V[_\x7FInterval too short\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[aU\xB0`\x12` \x92a\t\xD5V[aU\xB9\x81aU|V[\x01\x90V[aU\xD2\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaU\xA3V[\x90V[\x15aU\xDCWV[aU\xE4a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aU\xFA`\x04\x82\x01aU\xBDV[\x03\x90\xFD[\x90V[aV\x15aV\x10aV\x1A\x92aU\xFEV[a\x07IV[a\x04\xAFV[\x90V[_\x7FMax missed must be >= 1\0\0\0\0\0\0\0\0\0\x91\x01RV[aVQ`\x17` \x92a\t\xD5V[aVZ\x81aV\x1DV[\x01\x90V[aVs\x90` \x81\x01\x90_\x81\x83\x03\x91\x01RaVDV[\x90V[\x15aV}WV[aV\x85a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80aV\x9B`\x04\x82\x01aV^V[\x03\x90\xFD[aV\xA9``a\x16\xBCV[\x90V[\x90aV\xC1aV\xBCaV\xC8\x92a0[V[a0gV[\x82Ta3\xDDV[\x90UV[\x90aW\x0E`@_aW\x14\x94aV\xEE\x82\x82\x01aV\xE8\x84\x88\x01aIvV[\x90aM\xE9V[aW\x06\x82\x82\x01aW\0` \x88\x01aIMV[\x90aS\x07V[\x01\x92\x01aP^V[\x90aV\xACV[V[\x90aW \x91aV\xCCV[V[\x91` aWC\x92\x94\x93aW<`@\x82\x01\x96_\x83\x01\x90a\x0C!V[\x01\x90a\x11)V[V[3aWxaWr\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14\x80\x15aXdW[aW\x89\x90aU4V[aW\xA7\x82aW\xA0aW\x9A`<aU`V[\x91a\x03\xB4V[\x10\x15aU\xD5V[aW\xC5\x83aW\xBEaW\xB8`\x01aV\x01V[\x91a\x04\xAFV[\x10\x15aVvV[aX\x1E\x82aX\r\x85aX\x04aW\xE6_aW\xE0`\x02\x89\x90a\"\x87V[\x01a\"\xB1V[\x91aW\xFBaW\xF2aV\x9FV[\x95_\x87\x01aG\x9EV[` \x85\x01aG\xACV[`@\x83\x01aOqV[aX\x19`\x02\x84\x90a\"\x87V[aW\x16V[\x90\x91aXJ\x7F\xC9Y\x9E\xD9bbJ\x85\x8E\xC5\x9B\xAE\x0E\xD8lu\xF4\xDBe\xFE\x04W\0!'~\xDB\xED\xD0N\xA5d\x92a\x07LV[\x92aX_aXVa\x03\xA2V[\x92\x83\x92\x83aW\"V[\x03\x90\xA2V[PaW\x893aX\x8EaX\x88aX\x83aX~`\x07\x87\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x90PaW\x80V[cNH{q`\xE0\x1B_R`\x12`\x04R`$_\xFD[aX\xB6aX\xBC\x91a\x05TV[\x91a\x05TV[\x90\x81\x15aX\xC7W\x04\x90V[aX\x96V[aX\xE0aX\xDBaX\xE5\x92a\x05TV[a\x07IV[a\x04\xAFV[\x90V[aX\xFCaX\xF7aY\x01\x92a%\xCAV[a\x07IV[a\x03\xB4V[\x90V[aY\"aY\x1DaY\x16`\x03\x84\x90a\x0F\xC8V[\x84\x90a\x10\x12V[aM\xC6V[\x90aY,\x81ad'V[aY8`\x01\x84\x01a\x10\xA3V[aYKaYE`\x03a\x11YV[\x91a\x11YV[\x14a[_WaY[_\x84\x01a\t>V[aYmaYg_a,\xC2V[\x91a\x05TV[\x14a[YWaY\xA3aY\x8ABaY\x84_\x87\x01a\t>V[\x90a6\x7FV[aY\x9DaY\x98_\x85\x01aIvV[a6$V[\x90aX\xAAV[\x80aY\xB7aY\xB1`\xFFaI\x83V[\x91a\x05TV[\x11_\x14a[KWP`\xFF[\x90\x81aY\xE1aY\xDBaY\xD6`\x01\x88\x01a\x10vV[a\x04\xAFV[\x91a\x04\xAFV[\x11aY\xEEW[PPPPPV[aY\xFB\x82`\x01\x86\x01aS\x07V[aZ\x10aZ\x07_aX\xE8V[`\x01\x86\x01aM\xE9V[aZ.aZ(aZ#` \x85\x94\x01aIMV[a\x04\xAFV[\x91a\x04\xAFV[\x10\x15\x80a[$W[aZAW[\x80aY\xE7V[aZ\\aZP`\x01\x85\x01a\x10\xA3V[\x93`\x01`\x02\x91\x01a4\x0BV[aZzaZsaZn`\x04\x85\x90a34V[a3JV[\x85\x90am\xA7V[P\x81\x90\x84\x90\x91aZ\xC8aZ\xB6aZ\xB0\x7FD\xFD2\xB6wpL\xE6\x8Ewc\x89|Is;\x8FR\x89\x01\x8A\xC6\n\\\x92h\x02\xD67Y\xDBM\x93a\x07LV[\x93a\x10\x06V[\x93aZ\xBFa\x03\xA2V[\x91\x82\x91\x82a\x16'V[\x03\x90\xA3\x91\x90\x91`\x02a[\x03aZ\xFD\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93a[\x18a[\x0Fa\x03\xA2V[\x92\x83\x92\x83aS'V[\x03\x90\xA3_\x80\x80\x80aZ;V[Pa[1`\x01\x84\x01a\x10\xA3V[a[Da[>`\x02a\x11YV[\x91a\x11YV[\x14\x15aZ6V[a[T\x90aX\xCCV[aY\xC2V[PPPPV[PPPPV[``\x90V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11a[\x82W` \x80\x91\x02\x01\x90V[a\x08\xC3V[\x90a[\x99a[\x94\x83a[jV[a\x16\xBCV[\x91\x82RV[a[\xA8`\x80a\x16\xBCV[\x90V[\x90a\\\x12a\\\t`\x03a[\xBCa[\x9EV[\x94a[\xD3a[\xCB_\x83\x01a\t\0V[_\x88\x01aOnV[a[\xEBa[\xE2`\x01\x83\x01a\t>V[` \x88\x01aG\x90V[a\\\x03a[\xFA`\x02\x83\x01a\t>V[`@\x88\x01aG\x90V[\x01a\teV[``\x84\x01aOqV[V[a\\\x1D\x90a[\xABV[\x90V[\x90a\\*\x82a\x07\x92V[a\\3\x81a[\x87V[\x92a\\A` \x85\x01\x91a\x07\x96V[_\x91[\x83\x83\x10a\\QWPPPPV[`\x04` `\x01\x92a\\a\x85a\\\x14V[\x81R\x01\x92\x01\x92\x01\x91\x90a\\DV[a\\x\x90a\\ V[\x90V[a\\\x92a\\\x97\x91a\\\x8Aa[eV[P`\x08a\x07hV[a\\oV[\x90V[a\\\xC8\x90a\\\xC3a\\\xBEa\\\xB7a\\\xB2\x84`\x06a34V[a3JV[3\x90ae\x8DV[a5\xC4V[a]#V[V[_\x7FCannot go offline while slashed\0\x91\x01RV[a\\\xFE`\x1F` \x92a\t\xD5V[a]\x07\x81a\\\xCAV[\x01\x90V[a] \x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra\\\xF1V[\x90V[a]Aa]<a]5`\x03\x84\x90a\x0F\xC8V[3\x90a\x10\x12V[aM\xC6V[\x90a]N`\x01\x83\x01a\x10\xA3V[\x91\x82a]ca]]`\x03a\x11YV[\x91a\x11YV[\x14a]\xE9Wa]w\x90`\x01`\x04\x91\x01a4\x0BV[a]\x95a]\x8Ea]\x89`\x04\x84\x90a34V[a3JV[3\x90am\xA7V[P\x903\x90\x91`\x04a]\xCFa]\xC9\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93a]\xE4a]\xDBa\x03\xA2V[\x92\x83\x92\x83aS'V[\x03\x90\xA3V[a]\xF1a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a^\x07`\x04\x82\x01a]\x0BV[\x03\x90\xFD[a^\x14\x90a\\\x9AV[V[\x90\x91\x82a^&\x81a^-\x93a\x1D3V[\x80\x93a\x17\x1DV[\x01\x90V[a^B\x90` \x94\x93a^I\x93a^\x16V[\x80\x92a\x1DdV[\x01\x90V[\x90\x91a^d\x90a^[a\x03\xA2V[\x93\x84\x93\x84a^1V[\x03\x90 \x90V[\x90\x91a^u\x92a^MV[\x90V[\x92a^\x9Da^\xA5\x93\x92a^\x98a^\xAA\x96a^\x90a'\xAEV[P`\ta\x1D\x07V[a\x1D\x1DV[\x91\x90\x91a^jV[a\t>V[\x90V[a^\xB5aKVV[Pa^\xC0`\x01a%\xBDV[\x90V[a^\xCD\x90Qa\x11YV[\x90V[\x90V[a^\xE7a^\xE2a^\xEC\x92a^\xD0V[a\x07IV[a\x05TV[\x90V[` \x7Fl\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x7FOperator not eligible for remova_\x82\x01R\x01RV[a_I`!`@\x92a\t\xD5V[a_R\x81a^\xEFV[\x01\x90V[a_k\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Ra_<V[\x90V[\x15a_uWV[a_}a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80a_\x93`\x04\x82\x01a_VV[\x03\x90\xFD[\x90a`Ha`Ca`M\x933a_\xC8a_\xC2a_\xBDa_\xB8`\x07\x86\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x80\x15aa\x06W[a_\xD9\x90aU4V[a_\xF7a_\xF2a_\xEB`\x03\x84\x90a\x0F\xC8V[\x86\x90a\x10\x12V[aHIV[a`\x03``\x82\x01a^\xC3V[a`\x16a`\x10`\x03a\x11YV[\x91a\x11YV[\x03a`PW[Pa`;a`4a`/`\x05\x84\x90a34V[a3JV[\x85\x90am\xA7V[P`\x04a34V[a3JV[am\xA7V[PV[a`\xCC\x90a`\xA0a`\x90a`c\x85ad'V[a`\x8Aa`\x85` a`~a`y_\x86\x01aIvV[a6$V[\x93\x01aIMV[aI\x83V[\x90a(\xF8V[a`\x9A`\na^\xD3V[\x90a(\xF8V[a`\xAB_\x83\x01a?VV[a`\xBDa`\xB7_a,\xC2V[\x91a\x05TV[\x11\x91\x82a`\xD2W[PPa_nV[_a`\x1CV[a`\xFD\x91\x92Pa`\xF1a`\xF7\x91a`\xEB_B\x92\x01a?VV[\x90a6\x7FV[\x92a\x05TV[\x91a\x05TV[\x10\x15_\x80a`\xC5V[Pa_\xD93aa$aa\x1Eaa\x19aKZV[a\x03\xEFV[\x91a\x03\xEFV[\x14\x90Pa_\xD0V[\x90aaVaa[\x91aa<a;\xCBV[PaaQaaI\x85ad'V[\x94`\x03a\x0F\xC8V[a\x10\x12V[aHIV[aaf_\x82\x01a?VV[aaxaar_a,\xC2V[\x91a\x05TV[\x14aa\xB3Waa\xA9aa\xA4_aa\x9Daa\xAF\x94aa\x97\x83B\x92\x01a?VV[\x90a6\x7FV[\x94\x01aIvV[a6$V[\x91a\x05TV[\x10\x90V[PP_\x90V[aa\xCA\x90aa\xC5ae?V[aa\xCCV[V[aa\xD7\x81`\x01a&\x9AV[aa\xDFaKZV[\x90ab\x13ab\r\x7F8\xD1k\x8C\xAC\"\xD9\x9F\xC7\xC1$\xB9\xCD\r\xE2\xD3\xFA\x1F\xAE\xF4 \xBF\xE7\x91\xD8\xC3b\xD7e\xE2'\0\x93a\x10\x06V[\x91a\x10\x06V[\x91ab\x1Ca\x03\xA2V[\x80ab&\x81a\x04KV[\x03\x90\xA3V[ab4\x90aa\xB9V[V[_abuab{\x93abm3abgabaab\\abW`\x07\x8A\x90a\x13\xC5V[a%\xBDV[a\x03\xEFV[\x91a\x03\xEFV[\x14a(5V[\x92`\x02a\"\x87V[\x01aV\xACV[V[_\x7FNot registered\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[ab\xB1`\x0E` \x92a\t\xD5V[ab\xBA\x81ab}V[\x01\x90V[ab\xD3\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Rab\xA4V[\x90V[\x15ab\xDDWV[ab\xE5a\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80ab\xFB`\x04\x82\x01ab\xBEV[\x03\x90\xFD[ac;3ac5ac/\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0a\x03\xEFV[\x91a\x03\xEFV[\x14a%\x80V[acaac\\acUacP`\x06\x85\x90a34V[a3JV[\x84\x90am\xA7V[ab\xD6V[ac\x7Facxacs`\x04\x84\x90a34V[a3JV[\x83\x90am\xA7V[P\x90ac\xB4ac\xAE\x7F\x08\xBB\x93\xE5DB\t\xB1QU\x07\x8A\x13\xF6\xE3A)\x9Dt\x8D\x0C)\x9Fr,\x9C\xBC\x07#\xF0\xFE\x9E\x93a\x07LV[\x91a\x10\x06V[\x91ac\xBDa\x03\xA2V[\x80ac\xC7\x81a\x04KV[\x03\x90\xA3V[\x90ad\x19ad\x10_ac\xDCa'CV[\x94ac\xF3ac\xEB\x83\x83\x01a\x10IV[\x83\x88\x01aG\x9EV[ad\nad\x01\x83\x83\x01a\x10vV[` \x88\x01aG\xACV[\x01a\"\xB1V[`@\x84\x01aOqV[V[ad$\x90ac\xCCV[\x90V[ad>adC\x91ad6a'\x8EV[P`\x02a\"\x87V[ad\x1BV[adN_\x82\x01aIvV[ad`adZ_aX\xE8V[\x91a\x03\xB4V[\x14ad\xA6W[adr` \x82\x01aIMV[ad\x84ad~_aIZV[\x91a\x04\xAFV[\x14ad\x8DW[\x90V[ad\xA1ad\x98a\x16\x0FV[` \x83\x01aG\xACV[ad\x8AV[ad\xB9ad\xB1a\x0C\x08V[_\x83\x01aG\x9EV[adfV[ad\xC7\x90a\x0F\xDEV[\x90V[ad\xDEad\xD9ad\xE3\x92a\x03\xE4V[a\x07IV[a\x05TV[\x90V[ad\xFAad\xF5ad\xFF\x92a\x05TV[a&wV[a\x0F\x01V[\x90V[\x90V[\x90ae7ae1ae,ae'_ae<\x96ae\x1Fa;\xCBV[P\x01\x94ad\xBEV[ad\xCAV[ad\xE6V[\x91ae\x02V[anhV[\x90V[aeGaKZV[ae`aeZaeUalUV[a\x03\xEFV[\x91a\x03\xEFV[\x03aegWV[ae\x89aeralUV[_\x91\x82\x91c\x11\x8C\xDA\xA7`\xE0\x1B\x83R`\x04\x83\x01a\x0C\xC9V[\x03\x90\xFD[\x90ae\xBFae\xB9ae\xB4ae\xAF_ae\xC4\x96ae\xA7a;\xCBV[P\x01\x94ad\xBEV[ad\xCAV[ad\xE6V[\x91ae\x02V[an\xCBV[\x90V[ae\xE6\x91ae\xDD\x91ae\xD7aKVV[Pao'V[\x90\x92\x91\x92ao\xE7V[\x90V[_\x7FOperator is slashed\0\0\0\0\0\0\0\0\0\0\0\0\0\x91\x01RV[af\x1D`\x13` \x92a\t\xD5V[af&\x81ae\xE9V[\x01\x90V[af?\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Raf\x10V[\x90V[\x15afIWV[afQa\x03\xA2V[bF\x1B\xCD`\xE5\x1B\x81R\x80afg`\x04\x82\x01af*V[\x03\x90\xFD[\x90af\x80af{af\x87\x92a3MV[a3YV[\x82Ta0\x02V[\x90UV[af\x94\x90a\x03\xB4V[g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x14af\xA9W`\x01\x01\x90V[a(\xE4V[\x90V[af\xC5af\xC0af\xCA\x92af\xAEV[a\x07IV[a\x04\xAFV[\x90V[\x91` af\xEE\x92\x94\x93af\xE7`@\x82\x01\x96_\x83\x01\x90a\x11)V[\x01\x90a\x05WV[V[af\xF9\x90a\x0F\xDEV[\x90V[ag\x05\x90af\xF0V[\x90V[ag\x11\x90a\x0F\xFAV[\x90V[`@\x90ag=agD\x94\x96\x95\x93\x96ag3``\x84\x01\x98_\x85\x01\x90a\x0C\xBCV[` \x83\x01\x90a\x0C!V[\x01\x90a\x0C!V[V[\x94\x92\x93\x91\x93agiagdag]`\x03\x89\x90a\x0F\xC8V[\x87\x90a\x10\x12V[aM\xC6V[\x93ags\x87ad'V[\x93ag\x9Dag\x83`\x01\x88\x01a\x10\xA3V[ag\x96ag\x90`\x03a\x11YV[\x91a\x11YV[\x14\x15afBV[ag\xBBag\xB4ag\xAF`\x05\x8B\x90a34V[a3JV[\x88\x90ae\x05V[Pah\x90`@ag\xCD`\x01\x89\x01a\x10\xA3V[\x96ag\xDAB_\x8B\x01a0\x18V[ah\x04ag\xE8\x85\x87\x90a6\xFDV[ag\xFAag\xF4\x82a7\x11V[\x91a7\x0BV[ `\x02\x8B\x01afkV[ah\x19ah\x10_aIZV[`\x01\x8B\x01aS\x07V[ah7`\x01\x8A\x01ah1ah,\x82a\x10IV[af\x8BV[\x90aM\xE9V[ah?a<\xFFV[P\x85ahSahM_aIZV[\x91a\x04\xAFV[\x14_\x14ak\x14Wahj_\x99[`\x01\x8B\x91\x01a4\x0BV[\x87ah~ahx`\x02a\x11YV[\x91a\x11YV[\x14\x80aj\xF8W[aj\x8AW[\x01aP^V[\x80ajfW[ajPW[PP\x85\x91\x85\x91\x92Bah\xDFah\xD9ah\xD3\x7Fe\x89\x18\xE3\x14\x7F\x13\xDD\x06\x8E\xC2\x147\xB4\xC2\\!h*\x8D\xC2\x12\x93Hg\x1E\xAD\0\r\xB3\xE7\xB9\x94a\x07LV[\x94a\x07LV[\x94a\x10\x06V[\x94ah\xF4ah\xEBa\x03\xA2V[\x92\x83\x92\x83af\xCDV[\x03\x90\xA4\x80ai\nai\x04\x84a\x11YV[\x91a\x11YV[\x03ai\xFAW[PPai\x1C`\x0Ba%\xBDV[ai6ai0ai+_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x03ai@W[PPV[aiZaiUaiP`\x0Ba%\xBDV[af\xFCV[ag\x08V[\x91c\xD4xS\xB6\x91\x90\x92ailBa6@V[\x92\x81;\x15ai\xF5W_ai\x92\x91ai\x9D\x82\x96ai\x86a\x03\xA2V[\x98\x89\x97\x88\x96\x87\x95aK\x99V[\x85R`\x04\x85\x01ag\x14V[\x03\x92Z\xF1\x90\x81ai\xC9W[P\x15_\x14ai\xC4W`\x01ai\xBFW[[_\x80ai<V[ai\xB7V[ai\xB8V[ai\xE8\x90_=\x81\x11ai\xEEW[ai\xE0\x81\x83a\x08\xD7V[\x81\x01\x90aK\x9FV[_ai\xA8V[P=ai\xD6V[aK\x95V[\x83\x83\x91\x92aj1aj+\x7F\"\x88$\xB8l%di\x12_R\\\xE1\x8Cl-\n\x9E\x13=\x13\xB8\xECz,\x96\xA1\x93\xB0\xC2\x8A\t\x93a\x07LV[\x93a\x10\x06V[\x93ajFaj=a\x03\xA2V[\x92\x83\x92\x83aS'V[\x03\x90\xA3_\x80ai\x10V[aj_\x91\x88\x91\x88\x90\x91\x92at\xA4V[_\x80ah\x9BV[Pajr\x81\x83\x90a-~V[aj\x84aj~_a,\xC2V[\x91a\x05TV[\x11ah\x96V[aj\xA7aj\xA0aj\x9B\x8D`\x04a34V[a3JV[\x8B\x90ae\x05V[P\x8A\x8Aaj\xDDaj\xD7\x7F\xC9\x86,_\x02\xEE\xFB\xDC\xEA\x01\xC2\x07\xAES\x8E\x1D0M\xC90&\x87\x0FH\x95\x1EH\xA0\xF4\xC8G\x0C\x93a\x07LV[\x91a\x10\x06V[\x91aj\xE6a\x03\xA2V[\x80aj\xF0\x81a\x04KV[\x03\x90\xA3ah\x8AV[P\x88ak\rak\x07`\x02a\x11YV[\x91a\x11YV[\x14\x15ah\x85V[\x85ak(ak\"`daf\xB1V[\x91a\x04\xAFV[\x10_\x14ak;Wahj`\x01\x99[ah`V[ahj`\x01\x99akS\x8D\x8D\x8B\x90\x8B\x90\x8A\x92\x8C\x94aqXV[ak6V[ako_akt\x92akha'\xAEV[P\x01ae\x02V[avbV[\x90V[ak\x83ak\x88\x91a\t\"V[a)~V[\x90V[ak\x9Fak\x9Aak\xA4\x92a\x05TV[a\x07IV[a\x03\xE4V[\x90V[ak\xD2ak\xCDak\xDC\x93ak\xC8_ak\xD7\x95ak\xC1aKVV[P\x01ae\x02V[av\xD0V[akwV[ak\x8BV[a\x0F\xFAV[\x90V[\x91\x90`\x08ak\xFF\x91\x02\x91ak\xF9`\x01\x80`\xA0\x1B\x03\x84a)UV[\x92a)UV[\x91\x81\x19\x16\x91\x16\x17\x90V[\x91\x90al\x1Fal\x1Aal'\x93a\x10\x06V[a&\x97V[\x90\x83Tak\xDFV[\x90UV[al=\x91al7aKVV[\x91al\tV[V[alS\x90alN_`\x01al+V[av\xF1V[V[al]aKVV[P3\x90V[alk\x90a\x05TV[_\x19\x81\x14alyW`\x01\x01\x90V[a(\xE4V[al\x88\x90Qa\x03\xEFV[\x90V[\x93\x91\x92\x93al\x97a:\x9CV[Pal\xABal\xA6\x85\x84\x90a6\x7FV[a:\xDAV[\x92al\xB5_a,\xC2V[\x92[\x80al\xCAal\xC4\x88a\x05TV[\x91a\x05TV[\x10\x15am8Wal\xEEal\xE7al\xE2`\x05\x86\x90a34V[a3JV[\x82\x90ak\xA7V[al\xFA\x84\x82\x8A\x91awPV[am\x0EW[Pam\t\x90a,\xDEV[al\xB7V[am\t\x91\x94am,am1\x92am'\x89\x91\x84\x90\x92a;\x01V[a;!V[albV[\x93\x90al\xFFV[P\x94PP\x91PamG\x82a:\xDAV[\x92amQ_a,\xC2V[[\x80ameam_\x86a\x05TV[\x91a\x05TV[\x10\x15am\xA1Wam\x9C\x90am\x97am\x85am\x80\x86\x84\x90a;\x01V[al~V[am\x92\x88\x91\x84\x90\x92a;\x01V[a;!V[a,\xDEV[amRV[P\x91PPV[\x90am\xD9am\xD3am\xCEam\xC9_am\xDE\x96am\xC1a;\xCBV[P\x01\x94ad\xBEV[ad\xCAV[ad\xE6V[\x91ae\x02V[ax\x88V[\x90V[\x90V[_R` _ \x90V[T\x90V[am\xFA\x81am\xEDV[\x82\x10\x15an\x14Wan\x0C`\x01\x91am\xE4V[\x91\x02\x01\x90_\x90V[a\x07~V[\x90\x81T\x91h\x01\0\0\0\0\0\0\0\0\x83\x10\x15anIW\x82anA\x91`\x01anG\x95\x01\x81Uam\xF1V[\x90a3eV[V[a\x08\xC3V[T\x90V[\x90an\\\x90a3MV[_R` R`@_ \x90V[anpa;\xCBV[Pan\x85an\x7F\x82\x84\x90an\xCBV[\x15a\x04\xC2V[_\x14an\xC5Wan\xBBan\xC0\x92an\xA7an\xA0_\x85\x01am\xE1V[\x82\x90an\x19V[`\x01an\xB4_\x85\x01anNV[\x93\x01anRV[a0\x18V[`\x01\x90V[PP_\x90V[an\xE9\x91`\x01an\xE4\x92an\xDDa;\xCBV[P\x01anRV[a\t>V[an\xFBan\xF5_a,\xC2V[\x91a\x05TV[\x14\x15\x90V[_\x90V[\x90V[ao\x1Bao\x16ao \x92ao\x04V[a\x07IV[a\x05TV[\x90V[_\x90V[\x91\x90\x91ao2aKVV[Pao;ao\0V[PaoDa3\x87V[PaoN\x83a7\x11V[aoaao[`Aao\x07V[\x91a\x05TV[\x14_\x14ao\xA8Wao\xA1\x91\x92aoua3\x87V[Pao~a3\x87V[Pao\x87ao#V[P` \x81\x01Q```@\x83\x01Q\x92\x01Q_\x1A\x90\x91\x92az\x07V[\x91\x92\x90\x91\x90V[Pao\xB2_a%\xE9V[\x90ao\xC6ao\xC1`\x02\x94a7\x11V[ad\xE6V[\x91\x92\x91\x90V[`\x04\x11\x15ao\xD6WV[a\x116V[\x90ao\xE5\x82ao\xCCV[V[\x80ao\xFAao\xF4_ao\xDBV[\x91ao\xDBV[\x14_\x14ap\x05WPPV[\x80ap\x19ap\x13`\x01ao\xDBV[\x91ao\xDBV[\x14_\x14ap<W_c\xF6E\xEE\xDF`\xE0\x1B\x81R\x80ap8`\x04\x82\x01a\x04KV[\x03\x90\xFD[\x80apPapJ`\x02ao\xDBV[\x91ao\xDBV[\x14_\x14ap~Wapzapc\x83akwV[_\x91\x82\x91c\xFC\xE6\x98\xF7`\xE0\x1B\x83R`\x04\x83\x01a\x05dV[\x03\x90\xFD[ap\x91ap\x8B`\x03ao\xDBV[\x91ao\xDBV[\x14ap\x99WPV[ap\xB4\x90_\x91\x82\x91c5\xE2\xF3\x83`\xE2\x1B\x83R`\x04\x83\x01a\x0F\x11V[\x03\x90\xFD[ap\xCCap\xC7ap\xD1\x92a\x13\x0EV[a\x07IV[a\x04\xAFV[\x90V[ap\xE0ap\xE6\x91a\x03\xB4V[\x91a\x03\xB4V[\x90\x03\x90g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x82\x11ap\xFAWV[a(\xE4V[_\x7FProtocol violation reported\0\0\0\0\0\x91\x01RV[aq3`\x1B` \x92a\t\xD5V[aq<\x81ap\xFFV[\x01\x90V[aqU\x90` \x81\x01\x90_\x81\x83\x03\x91\x01Raq&V[\x90V[\x93PP\x92Paqpaqj`\xC8ap\xB8V[\x91a\x04\xAFV[\x10\x15aq{W[PPV[aq\x84Ba6@V[aq\xA2aq\x9Daq\x96`\x0C\x85\x90aH\x81V[\x85\x90aH\x97V[a\x10IV[\x80aq\xB5aq\xAF_aX\xE8V[\x91a\x03\xB4V[\x14\x90\x81\x15ar;W[Paq\xCAW[PaqwV[aq\xE9\x90aq\xE4aq\xDD`\x0C\x85\x90aH\x81V[\x85\x90aH\x97V[aM\xE9V[\x90ar\x1Dar\x17\x7F\x1E)\t\xCFE\xD7\x0C\xF0\x03\xF34\xB7<\x933\x0C\xE7\xE5rx-\xFC\x82\xFA\xB7\x9D\xEB\x88U\xA7\xC7\x91\x93a\x07LV[\x91a\x10\x06V[\x91ar&a\x03\xA2V[\x80ar0\x81aq@V[\x03\x90\xA3_\x80\x80aq\xC4V[arF\x91P\x82ap\xD4V[ar_arYarTa\x0FzV[a\x03\xB4V[\x91a\x03\xB4V[\x10\x15_aq\xBEV[\x90V[ar~aryar\x83\x92argV[a\x07IV[a\x05TV[\x90V[\x90\x92\x91\x92ar\x9Bar\x96\x82a\x16\xFAV[a\x16\xBCV[\x93\x81\x85R` \x85\x01\x90\x82\x84\x01\x11ar\xB7War\xB5\x92a\t\xDEV[V[a\x16\xF6V[\x90\x80`\x1F\x83\x01\x12\x15ar\xDAW\x81` ar\xD7\x93Q\x91\x01ar\x86V[\x90V[a\x05\xAFV[\x90PQ\x90ar\xEC\x82a\x06\xF9V[V[\x91\x90\x91`@\x81\x84\x03\x12asAWas\x05`@a\x16\xBCV[\x92_\x82\x01Q\x91g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x83\x11as<Was)\x82as5\x94\x83\x01ar\xBCV[_\x86\x01R` \x01ar\xDFV[` \x83\x01RV[a\x16\xF2V[a\x16\xEEV[\x92\x91\x90asZasU\x82a\x16\xD1V[a\x16\xBCV[\x93\x81\x85R` \x80\x86\x01\x92\x02\x81\x01\x91\x83\x83\x11as\xB1W\x81\x90[\x83\x82\x10as\x80WPPPPPV[\x81Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11as\xACW` \x91as\xA1\x87\x84\x93\x87\x01ar\xEEV[\x81R\x01\x91\x01\x90asrV[a\x05\xAFV[a\x05\xB7V[\x90\x80`\x1F\x83\x01\x12\x15as\xD4W\x81` as\xD1\x93Q\x91\x01asFV[\x90V[a\x05\xAFV[\x90` \x82\x82\x03\x12at\tW_\x82\x01Qg\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x81\x11at\x04Wat\x01\x92\x01as\xB6V[\x90V[a\x03\xB0V[a\x03\xACV[` \x91\x81R\x01\x90V[\x91\x90at1\x81at*\x81at6\x95at\x0EV[\x80\x95a\x17\x1DV[a\x08\xB9V[\x01\x90V[\x90\x91atQ\x92` \x83\x01\x92_\x81\x85\x03\x91\x01Rat\x17V[\x90V[at^`2a\x15QV[\x90V[\x94\x93\x91``\x91at\xA2\x94at\x8Dat\x9A\x93at\x83`\x80\x8B\x01\x94_\x8C\x01\x90a\x0C!V[` \x8A\x01\x90a\x0C\xBCV[\x87\x82\x03`@\x89\x01Ra\x0E(V[\x94\x01\x90a\x05WV[V[\x91at\xB0\x81\x85\x90a-~V[at\xC2at\xBC_a,\xC2V[\x91a\x05TV[\x14av\\Wat\xD2\x81\x85\x90a-~V[at\xE6at\xE0a\xC3ParjV[\x91a\x05TV[\x11avVW_at\xF4a:!V[\x94at\xFE0a=.V[au c1\xE3\xBD\x1B\x94\x92\x94au+au\x14a\x03\xA2V[\x96\x87\x95\x86\x94\x85\x94aK\x99V[\x84R`\x04\x84\x01at:V[\x03\x91Z\xFA\x80\x91_\x92av2W[P\x15_\x14av)WP`\x01av$W[auQ\x83a\r\x97V[aujaudau_atTV[a\x05TV[\x91a\x05TV[\x11_\x14av\x16WauyatTV[[au\x830a=.V[\x90ce\xA6\x93n\x93\x92\x94\x90\x82;\x15av\x11W_\x94au\xBE\x86\x92au\xB3\x94au\xA7a\x03\xA2V[\x99\x8A\x98\x89\x97\x88\x96aK\x99V[\x86R`\x04\x86\x01ataV[\x03\x92Z\xF1\x90\x81au\xE5W[P\x15_\x14au\xE0W`\x01au\xDBW[[V[au\xD8V[au\xD9V[av\x04\x90_=\x81\x11av\nW[au\xFC\x81\x83a\x08\xD7V[\x81\x01\x90aK\x9FV[_au\xC9V[P=au\xF2V[aK\x95V[av\x1F\x83a\r\x97V[auzV[PPPV[\x90\x92P\x91auHV[avO\x91\x92P=\x80_\x83>avG\x81\x83a\x08\xD7V[\x81\x01\x90as\xD9V[\x90_au8V[PPPPV[PPPPV[_avv\x91avoa'\xAEV[P\x01anNV[\x90V[_R` _ \x90V[av\x8B\x81anNV[\x82\x10\x15av\xA5Wav\x9D`\x01\x91avyV[\x91\x02\x01\x90_\x90V[a\x07~V[av\xBA\x90`\x08av\xBF\x93\x02a\x0CxV[a\x10\xB0V[\x90V[\x90av\xCD\x91Tav\xAAV[\x90V[av\xEE\x91_av\xE8\x92av\xE1a3\x87V[P\x01av\x82V[\x90av\xC2V[\x90V[av\xFA_a%\xBDV[aw\x04\x82_a&\x9AV[\x90aw8aw2\x7F\x8B\xE0\x07\x9CS\x16Y\x14\x13D\xCD\x1F\xD0\xA4\xF2\x84\x19I\x7F\x97\"\xA3\xDA\xAF\xE3\xB4\x18okdW\xE0\x93a\x10\x06V[\x91a\x10\x06V[\x91awAa\x03\xA2V[\x80awK\x81a\x04KV[\x03\x90\xA3V[awXa;\xCBV[Paw\x80awzawsawn`\x06\x85\x90a34V[a3JV[\x84\x90ae\x8DV[\x15a\x04\xC2V[ax\"Waw\xA0\x91aw\x96aw\x9B\x92`\x03a\x0F\xC8V[a\x10\x12V[aHIV[aw\xAB_\x82\x01a?VV[aw\xBDaw\xB7_a,\xC2V[\x91a\x05TV[\x14\x80\x15aw\xFCW[aw\xF6Waw\xEBaw\xE5aw\xF1\x92aw\xDF_B\x92\x01a?VV[\x90a6\x7FV[\x92a\x05TV[\x91a\x05TV[\x10\x15\x90V[PP_\x90V[Pax\t``\x82\x01a^\xC3V[ax\x1Cax\x16`\x03a\x11YV[\x91a\x11YV[\x14aw\xC5V[PPP_\x90V[ax=ax8axB\x92aU\xFEV[a\x07IV[a\x05TV[\x90V[cNH{q`\xE0\x1B_R`1`\x04R`$_\xFD[axb\x81am\xEDV[\x80\x15ax\x83W`\x01\x90\x03\x90ax\x80axz\x83\x83am\xF1V[\x90a3\x8BV[UV[axEV[ax\x90a;\xCBV[Pax\xA7ax\xA2`\x01\x83\x01\x84\x90anRV[a\t>V[\x90\x81ax\xBBax\xB5_a,\xC2V[\x91a\x05TV[\x14\x15_\x14ay\x87Way9\x92`\x01ay4\x92\x84ax\xE2_\x96ax\xDC\x85ax)V[\x90a6\x7FV[ax\xFFax\xF0\x88\x85\x01anNV[ax\xF9\x86ax)V[\x90a6\x7FV[\x81ay\x12ay\x0C\x83a\x05TV[\x91a\x05TV[\x03ay>W[PPPay.ay)\x86\x83\x01am\xE1V[axYV[\x01anRV[a)\xBFV[`\x01\x90V[ay\x7F\x92ayqay]ayWayz\x94\x8C\x89\x01av\x82V[\x90av\xC2V[\x93ayk\x85\x91\x8C\x89\x01av\x82V[\x90a3eV[\x91\x85\x85\x01anRV[a0\x18V[_\x80\x80ay\x18V[PPP_\x90V[\x90V[ay\xA5ay\xA0ay\xAA\x92ay\x8EV[a\x07IV[a\x05TV[\x90V[ay\xE2ay\xE9\x94ay\xD8``\x94\x98\x97\x95ay\xCE`\x80\x86\x01\x9A_\x87\x01\x90a\x0F\x04V[` \x85\x01\x90a\x11)V[`@\x83\x01\x90a\x0F\x04V[\x01\x90a\x0F\x04V[V[ay\xFFay\xFAaz\x04\x92a%\xCAV[a&wV[a\x0F\x01V[\x90V[\x93\x92\x93az\x12aKVV[Paz\x1Bao\0V[Paz$a3\x87V[Paz.\x85akwV[az`azZ\x7F\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF]WnsW\xA4P\x1D\xDF\xE9/Fh\x1B \xA0ay\x91V[\x91a\x05TV[\x11az\xEDW\x90az\x83` \x94\x95_\x94\x93\x92\x93azza\x03\xA2V[\x94\x85\x94\x85ay\xADV[\x83\x80R\x03\x90`\x01Z\xFA\x15az\xE8Waz\x9B_Qa&wV[\x80az\xB6az\xB0az\xAB_a%\xE9V[a\x03\xEFV[\x91a\x03\xEFV[\x14az\xCCW_\x91az\xC6_ay\xEBV[\x91\x92\x91\x90V[Paz\xD6_a%\xE9V[`\x01\x91az\xE2_ay\xEBV[\x91\x92\x91\x90V[aK\xD1V[PPPaz\xF9_a%\xE9V[\x90`\x03\x92\x91\x92\x91\x90V\xFE\xA1dsolcC\0\x08\x1A\0\n",
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
