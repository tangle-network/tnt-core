///Module containing a contract's types and functions.
/**

```solidity
library SlashingManager {
    struct SlashRecord { uint64 round; uint64 serviceId; uint64 blueprintId; uint256 totalSlashed; uint256 exchangeRateBefore; uint256 exchangeRateAfter; bytes32 evidence; }
}
```*/
#[allow(
    non_camel_case_types,
    non_snake_case,
    clippy::pub_underscore_fields,
    clippy::style,
    clippy::empty_structs_with_brackets
)]
pub mod SlashingManager {
    use super::*;
    use alloy::sol_types as alloy_sol_types;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**```solidity
struct SlashRecord { uint64 round; uint64 serviceId; uint64 blueprintId; uint256 totalSlashed; uint256 exchangeRateBefore; uint256 exchangeRateAfter; bytes32 evidence; }
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct SlashRecord {
        #[allow(missing_docs)]
        pub round: u64,
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub blueprintId: u64,
        #[allow(missing_docs)]
        pub totalSlashed: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub exchangeRateBefore: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub exchangeRateAfter: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub evidence: alloy::sol_types::private::FixedBytes<32>,
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
            alloy::sol_types::sol_data::Uint<64>,
            alloy::sol_types::sol_data::Uint<256>,
            alloy::sol_types::sol_data::Uint<256>,
            alloy::sol_types::sol_data::Uint<256>,
            alloy::sol_types::sol_data::FixedBytes<32>,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (
            u64,
            u64,
            u64,
            alloy::sol_types::private::primitives::aliases::U256,
            alloy::sol_types::private::primitives::aliases::U256,
            alloy::sol_types::private::primitives::aliases::U256,
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
        impl ::core::convert::From<SlashRecord> for UnderlyingRustTuple<'_> {
            fn from(value: SlashRecord) -> Self {
                (
                    value.round,
                    value.serviceId,
                    value.blueprintId,
                    value.totalSlashed,
                    value.exchangeRateBefore,
                    value.exchangeRateAfter,
                    value.evidence,
                )
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for SlashRecord {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    round: tuple.0,
                    serviceId: tuple.1,
                    blueprintId: tuple.2,
                    totalSlashed: tuple.3,
                    exchangeRateBefore: tuple.4,
                    exchangeRateAfter: tuple.5,
                    evidence: tuple.6,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolValue for SlashRecord {
            type SolType = Self;
        }
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<Self> for SlashRecord {
            #[inline]
            fn stv_to_tokens(&self) -> <Self as alloy_sol_types::SolType>::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.round),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.blueprintId),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.totalSlashed),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.exchangeRateBefore),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.exchangeRateAfter),
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(&self.evidence),
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
        impl alloy_sol_types::SolType for SlashRecord {
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
        impl alloy_sol_types::SolStruct for SlashRecord {
            const NAME: &'static str = "SlashRecord";
            #[inline]
            fn eip712_root_type() -> alloy_sol_types::private::Cow<'static, str> {
                alloy_sol_types::private::Cow::Borrowed(
                    "SlashRecord(uint64 round,uint64 serviceId,uint64 blueprintId,uint256 totalSlashed,uint256 exchangeRateBefore,uint256 exchangeRateAfter,bytes32 evidence)",
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
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.round)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.serviceId)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.blueprintId)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.totalSlashed)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::eip712_data_word(
                            &self.exchangeRateBefore,
                        )
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::eip712_data_word(
                            &self.exchangeRateAfter,
                        )
                        .0,
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.evidence)
                        .0,
                ]
                    .concat()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::EventTopic for SlashRecord {
            #[inline]
            fn topic_preimage_length(rust: &Self::RustType) -> usize {
                0usize
                    + <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(&rust.round)
                    + <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.serviceId,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.blueprintId,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.totalSlashed,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.exchangeRateBefore,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.exchangeRateAfter,
                    )
                    + <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.evidence,
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
                    &rust.round,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.serviceId,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.blueprintId,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.totalSlashed,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.exchangeRateBefore,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.exchangeRateAfter,
                    out,
                );
                <alloy::sol_types::sol_data::FixedBytes<
                    32,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.evidence,
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
    /**Creates a new wrapper around an on-chain [`SlashingManager`](self) contract instance.

See the [wrapper's documentation](`SlashingManagerInstance`) for more details.*/
    #[inline]
    pub const fn new<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(
        address: alloy_sol_types::private::Address,
        __provider: P,
    ) -> SlashingManagerInstance<P, N> {
        SlashingManagerInstance::<P, N>::new(address, __provider)
    }
    /**A [`SlashingManager`](self) instance.

Contains type-safe methods for interacting with an on-chain instance of the
[`SlashingManager`](self) contract located at a given `address`, using a given
provider `P`.

If the contract bytecode is available (see the [`sol!`](alloy_sol_types::sol!)
documentation on how to provide it), the `deploy` and `deploy_builder` methods can
be used to deploy a new instance of the contract.

See the [module-level documentation](self) for all the available methods.*/
    #[derive(Clone)]
    pub struct SlashingManagerInstance<P, N = alloy_contract::private::Ethereum> {
        address: alloy_sol_types::private::Address,
        provider: P,
        _network: ::core::marker::PhantomData<N>,
    }
    #[automatically_derived]
    impl<P, N> ::core::fmt::Debug for SlashingManagerInstance<P, N> {
        #[inline]
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            f.debug_tuple("SlashingManagerInstance").field(&self.address).finish()
        }
    }
    /// Instantiation and getters/setters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > SlashingManagerInstance<P, N> {
        /**Creates a new wrapper around an on-chain [`SlashingManager`](self) contract instance.

See the [wrapper's documentation](`SlashingManagerInstance`) for more details.*/
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
    impl<P: ::core::clone::Clone, N> SlashingManagerInstance<&P, N> {
        /// Clones the provider and returns a new instance with the cloned provider.
        #[inline]
        pub fn with_cloned_provider(self) -> SlashingManagerInstance<P, N> {
            SlashingManagerInstance {
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
    > SlashingManagerInstance<P, N> {
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
    > SlashingManagerInstance<P, N> {
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
///Module containing a contract's types and functions.
/**

```solidity
library Types {
    type BlueprintSelectionMode is uint8;
    type LockMultiplier is uint8;
    struct OperatorSnapshot { uint256 stake; uint256 totalDelegated; }
}
```*/
#[allow(
    non_camel_case_types,
    non_snake_case,
    clippy::pub_underscore_fields,
    clippy::style,
    clippy::empty_structs_with_brackets
)]
pub mod Types {
    use super::*;
    use alloy::sol_types as alloy_sol_types;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct BlueprintSelectionMode(u8);
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<BlueprintSelectionMode> for u8 {
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
        impl BlueprintSelectionMode {
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
        impl From<u8> for BlueprintSelectionMode {
            fn from(value: u8) -> Self {
                Self::from_underlying(value)
            }
        }
        #[automatically_derived]
        impl From<BlueprintSelectionMode> for u8 {
            fn from(value: BlueprintSelectionMode) -> Self {
                value.into_underlying()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolType for BlueprintSelectionMode {
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
        impl alloy_sol_types::EventTopic for BlueprintSelectionMode {
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
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct LockMultiplier(u8);
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<LockMultiplier> for u8 {
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
        impl LockMultiplier {
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
        impl From<u8> for LockMultiplier {
            fn from(value: u8) -> Self {
                Self::from_underlying(value)
            }
        }
        #[automatically_derived]
        impl From<LockMultiplier> for u8 {
            fn from(value: LockMultiplier) -> Self {
                value.into_underlying()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolType for LockMultiplier {
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
        impl alloy_sol_types::EventTopic for LockMultiplier {
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
struct OperatorSnapshot { uint256 stake; uint256 totalDelegated; }
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct OperatorSnapshot {
        #[allow(missing_docs)]
        pub stake: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub totalDelegated: alloy::sol_types::private::primitives::aliases::U256,
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
            alloy::sol_types::sol_data::Uint<256>,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (
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
        impl ::core::convert::From<OperatorSnapshot> for UnderlyingRustTuple<'_> {
            fn from(value: OperatorSnapshot) -> Self {
                (value.stake, value.totalDelegated)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for OperatorSnapshot {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    stake: tuple.0,
                    totalDelegated: tuple.1,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolValue for OperatorSnapshot {
            type SolType = Self;
        }
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<Self> for OperatorSnapshot {
            #[inline]
            fn stv_to_tokens(&self) -> <Self as alloy_sol_types::SolType>::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.stake),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.totalDelegated),
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
        impl alloy_sol_types::SolType for OperatorSnapshot {
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
        impl alloy_sol_types::SolStruct for OperatorSnapshot {
            const NAME: &'static str = "OperatorSnapshot";
            #[inline]
            fn eip712_root_type() -> alloy_sol_types::private::Cow<'static, str> {
                alloy_sol_types::private::Cow::Borrowed(
                    "OperatorSnapshot(uint256 stake,uint256 totalDelegated)",
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
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.stake)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::eip712_data_word(
                            &self.totalDelegated,
                        )
                        .0,
                ]
                    .concat()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::EventTopic for OperatorSnapshot {
            #[inline]
            fn topic_preimage_length(rust: &Self::RustType) -> usize {
                0usize
                    + <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(&rust.stake)
                    + <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.totalDelegated,
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
                    &rust.stake,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.totalDelegated,
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
    /**Creates a new wrapper around an on-chain [`Types`](self) contract instance.

See the [wrapper's documentation](`TypesInstance`) for more details.*/
    #[inline]
    pub const fn new<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(address: alloy_sol_types::private::Address, __provider: P) -> TypesInstance<P, N> {
        TypesInstance::<P, N>::new(address, __provider)
    }
    /**A [`Types`](self) instance.

Contains type-safe methods for interacting with an on-chain instance of the
[`Types`](self) contract located at a given `address`, using a given
provider `P`.

If the contract bytecode is available (see the [`sol!`](alloy_sol_types::sol!)
documentation on how to provide it), the `deploy` and `deploy_builder` methods can
be used to deploy a new instance of the contract.

See the [module-level documentation](self) for all the available methods.*/
    #[derive(Clone)]
    pub struct TypesInstance<P, N = alloy_contract::private::Ethereum> {
        address: alloy_sol_types::private::Address,
        provider: P,
        _network: ::core::marker::PhantomData<N>,
    }
    #[automatically_derived]
    impl<P, N> ::core::fmt::Debug for TypesInstance<P, N> {
        #[inline]
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            f.debug_tuple("TypesInstance").field(&self.address).finish()
        }
    }
    /// Instantiation and getters/setters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > TypesInstance<P, N> {
        /**Creates a new wrapper around an on-chain [`Types`](self) contract instance.

See the [wrapper's documentation](`TypesInstance`) for more details.*/
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
    impl<P: ::core::clone::Clone, N> TypesInstance<&P, N> {
        /// Clones the provider and returns a new instance with the cloned provider.
        #[inline]
        pub fn with_cloned_provider(self) -> TypesInstance<P, N> {
            TypesInstance {
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
    > TypesInstance<P, N> {
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
    > TypesInstance<P, N> {
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
library SlashingManager {
    struct SlashRecord {
        uint64 round;
        uint64 serviceId;
        uint64 blueprintId;
        uint256 totalSlashed;
        uint256 exchangeRateBefore;
        uint256 exchangeRateAfter;
        bytes32 evidence;
    }
}

library Types {
    type BlueprintSelectionMode is uint8;
    type LockMultiplier is uint8;
    struct OperatorSnapshot {
        uint256 stake;
        uint256 totalDelegated;
    }
}

interface MultiAssetDelegation {
    error AccessControlBadConfirmation();
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    error AddressEmptyCode(address target);
    error ERC1967InvalidImplementation(address implementation);
    error ERC1967NonPayable();
    error EnforcedPause();
    error ExpectedPause();
    error FailedCall();
    error InvalidInitialization();
    error NotAContract(address account);
    error NotInitializing();
    error ReentrancyGuardReentrantCall();
    error SelectorAlreadyRegistered(bytes4 selector, address existingFacet);
    error UUPSUnauthorizedCallContext();
    error UUPSUnsupportedProxiableUUID(bytes32 slot);
    error UnknownSelector(bytes4 selector);
    error ZeroAddress();

    event BlueprintAddedToDelegation(address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId);
    event BlueprintRemovedFromDelegation(address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId);
    event Delegated(address indexed delegator, address indexed operator, address indexed token, uint256 amount, uint256 shares, Types.BlueprintSelectionMode selectionMode);
    event DelegatorUnstakeExecuted(address indexed delegator, address indexed operator, address indexed token, uint256 shares, uint256 amount);
    event DelegatorUnstakeScheduled(address indexed delegator, address indexed operator, address indexed token, uint256 shares, uint256 estimatedAmount, uint64 readyRound);
    event Deposited(address indexed delegator, address indexed token, uint256 amount, Types.LockMultiplier lock);
    event ExpiredLocksHarvested(address indexed delegator, address indexed token, uint256 count, uint256 totalAmount);
    event FacetRegistered(address indexed facet);
    event FacetSelectorCleared(bytes4 indexed selector);
    event FacetSelectorSet(bytes4 indexed selector, address indexed facet);
    event Initialized(uint64 version);
    event OperatorBlueprintAdded(address indexed operator, uint64 indexed blueprintId);
    event OperatorBlueprintRemoved(address indexed operator, uint64 indexed blueprintId);
    event OperatorLeavingScheduled(address indexed operator, uint64 readyRound);
    event OperatorLeft(address indexed operator);
    event OperatorRegistered(address indexed operator, uint256 stake);
    event OperatorStakeIncreased(address indexed operator, uint256 amount);
    event OperatorUnstakeExecuted(address indexed operator, uint256 amount);
    event OperatorUnstakeScheduled(address indexed operator, uint256 amount, uint64 readyRound);
    event Paused(address account);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event SlashRecorded(address indexed operator, uint64 indexed slashId, uint256 totalSlashed, uint256 exchangeRateBefore, uint256 exchangeRateAfter);
    event Slashed(address indexed operator, uint64 indexed serviceId, uint256 operatorSlashed, uint256 delegatorsSlashed, uint256 newExchangeRate);
    event SlashedForService(address indexed operator, uint64 indexed serviceId, uint64 indexed blueprintId, uint256 totalSlashed, uint256 commitmentCount);
    event Unpaused(address account);
    event Upgraded(address indexed implementation);
    event WithdrawScheduled(address indexed delegator, address indexed token, uint256 amount, uint64 readyRound);
    event Withdrawn(address indexed delegator, address indexed token, uint256 amount);

    constructor();

    fallback() external payable;

    receive() external payable;

    function ADMIN_ROLE() external view returns (bytes32);
    function ASSET_MANAGER_ROLE() external view returns (bytes32);
    function BPS_DENOMINATOR() external view returns (uint256);
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function LOCK_ONE_MONTH() external view returns (uint64);
    function LOCK_SIX_MONTHS() external view returns (uint64);
    function LOCK_THREE_MONTHS() external view returns (uint64);
    function LOCK_TWO_MONTHS() external view returns (uint64);
    function MULTIPLIER_NONE() external view returns (uint16);
    function MULTIPLIER_ONE_MONTH() external view returns (uint16);
    function MULTIPLIER_SIX_MONTHS() external view returns (uint16);
    function MULTIPLIER_THREE_MONTHS() external view returns (uint16);
    function MULTIPLIER_TWO_MONTHS() external view returns (uint16);
    function PRECISION() external view returns (uint256);
    function SLASHER_ROLE() external view returns (bytes32);
    function UPGRADE_INTERFACE_VERSION() external view returns (string memory);
    function blueprintSlashCount(uint64, address) external view returns (uint64);
    function clearFacetSelectors(bytes4[] memory selectors) external;
    function currentRound() external view returns (uint64);
    function delegationBondLessDelay() external view returns (uint64);
    function facetForSelector(bytes4 selector) external view returns (address);
    function getAssetAdapter(address token) external view returns (address);
    function getOperatorSlashFactor(address operator) external view returns (uint256);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function getSlashCount(address operator) external view returns (uint64);
    function getSlashCountForBlueprint(uint64 blueprintId, address operator) external view returns (uint64);
    function getSlashCountForService(uint64 serviceId, address operator) external view returns (uint64);
    function getSlashImpact(address operator, uint64 slashId, address delegator) external view returns (uint256 lostAmount);
    function getSlashRecord(address operator, uint64 slashId) external view returns (SlashingManager.SlashRecord memory);
    function getSnapshot(uint64 round, address operator) external view returns (Types.OperatorSnapshot memory);
    function grantRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function initialize(address admin, uint256 nativeMinOperatorStake, uint256 nativeMinDelegation, uint16 _operatorCommissionBps) external;
    function lastRoundAdvance() external view returns (uint64);
    function leaveDelegatorsDelay() external view returns (uint64);
    function leaveOperatorsDelay() external view returns (uint64);
    function nativeEnabled() external view returns (bool);
    function nextSlashId(address) external view returns (uint64);
    function operatorCommissionBps() external view returns (uint16);
    function paused() external view returns (bool);
    function proxiableUUID() external view returns (bytes32);
    function registerFacet(address facet) external;
    function registerFacetSelectors(address facet, bytes4[] memory selectors) external;
    function renounceRole(bytes32 role, address callerConfirmation) external;
    function requireAdapters() external view returns (bool);
    function revokeRole(bytes32 role, address account) external;
    function roundDuration() external view returns (uint64);
    function serviceSlashCount(uint64, address) external view returns (uint64);
    function slashHistory(address, uint64) external view returns (uint64 round, uint64 serviceId, uint64 blueprintId, uint256 totalSlashed, uint256 exchangeRateBefore, uint256 exchangeRateAfter, bytes32 evidence);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}
```

...which was generated by the following JSON ABI:
```json
[
  {
    "type": "constructor",
    "inputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "fallback",
    "stateMutability": "payable"
  },
  {
    "type": "receive",
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "ADMIN_ROLE",
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
    "name": "ASSET_MANAGER_ROLE",
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
    "name": "BPS_DENOMINATOR",
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
    "name": "DEFAULT_ADMIN_ROLE",
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
    "name": "LOCK_ONE_MONTH",
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
    "name": "LOCK_SIX_MONTHS",
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
    "name": "LOCK_THREE_MONTHS",
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
    "name": "LOCK_TWO_MONTHS",
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
    "name": "MULTIPLIER_NONE",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MULTIPLIER_ONE_MONTH",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MULTIPLIER_SIX_MONTHS",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MULTIPLIER_THREE_MONTHS",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "MULTIPLIER_TWO_MONTHS",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "PRECISION",
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
    "name": "SLASHER_ROLE",
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
    "name": "UPGRADE_INTERFACE_VERSION",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "string",
        "internalType": "string"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "blueprintSlashCount",
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
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "clearFacetSelectors",
    "inputs": [
      {
        "name": "selectors",
        "type": "bytes4[]",
        "internalType": "bytes4[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "currentRound",
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
    "name": "delegationBondLessDelay",
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
    "name": "facetForSelector",
    "inputs": [
      {
        "name": "selector",
        "type": "bytes4",
        "internalType": "bytes4"
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
    "name": "getAssetAdapter",
    "inputs": [
      {
        "name": "token",
        "type": "address",
        "internalType": "address"
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
    "name": "getOperatorSlashFactor",
    "inputs": [
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
    "name": "getRoleAdmin",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
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
    "name": "getSlashCount",
    "inputs": [
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
    "name": "getSlashCountForBlueprint",
    "inputs": [
      {
        "name": "blueprintId",
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
    "name": "getSlashCountForService",
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
    "name": "getSlashImpact",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "slashId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "delegator",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [
      {
        "name": "lostAmount",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getSlashRecord",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "slashId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "",
        "type": "tuple",
        "internalType": "struct SlashingManager.SlashRecord",
        "components": [
          {
            "name": "round",
            "type": "uint64",
            "internalType": "uint64"
          },
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
            "name": "totalSlashed",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "exchangeRateBefore",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "exchangeRateAfter",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "evidence",
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
    "name": "getSnapshot",
    "inputs": [
      {
        "name": "round",
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
        "internalType": "struct Types.OperatorSnapshot",
        "components": [
          {
            "name": "stake",
            "type": "uint256",
            "internalType": "uint256"
          },
          {
            "name": "totalDelegated",
            "type": "uint256",
            "internalType": "uint256"
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "grantRole",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "hasRole",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "account",
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
    "name": "initialize",
    "inputs": [
      {
        "name": "admin",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "nativeMinOperatorStake",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "nativeMinDelegation",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "_operatorCommissionBps",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "lastRoundAdvance",
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
    "name": "leaveDelegatorsDelay",
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
    "name": "leaveOperatorsDelay",
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
    "name": "nativeEnabled",
    "inputs": [],
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
    "name": "nextSlashId",
    "inputs": [
      {
        "name": "",
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
    "name": "operatorCommissionBps",
    "inputs": [],
    "outputs": [
      {
        "name": "",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "paused",
    "inputs": [],
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
    "name": "proxiableUUID",
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
    "name": "registerFacet",
    "inputs": [
      {
        "name": "facet",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "registerFacetSelectors",
    "inputs": [
      {
        "name": "facet",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "selectors",
        "type": "bytes4[]",
        "internalType": "bytes4[]"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "renounceRole",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "callerConfirmation",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "requireAdapters",
    "inputs": [],
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
    "name": "revokeRole",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "roundDuration",
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
    "name": "serviceSlashCount",
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
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "slashHistory",
    "inputs": [
      {
        "name": "",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "round",
        "type": "uint64",
        "internalType": "uint64"
      },
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
        "name": "totalSlashed",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "exchangeRateBefore",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "exchangeRateAfter",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "evidence",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "supportsInterface",
    "inputs": [
      {
        "name": "interfaceId",
        "type": "bytes4",
        "internalType": "bytes4"
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
    "name": "upgradeToAndCall",
    "inputs": [
      {
        "name": "newImplementation",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "data",
        "type": "bytes",
        "internalType": "bytes"
      }
    ],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "event",
    "name": "BlueprintAddedToDelegation",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "delegationIndex",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "blueprintId",
        "type": "uint64",
        "indexed": false,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "BlueprintRemovedFromDelegation",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "delegationIndex",
        "type": "uint256",
        "indexed": true,
        "internalType": "uint256"
      },
      {
        "name": "blueprintId",
        "type": "uint64",
        "indexed": false,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Delegated",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "token",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "shares",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "selectionMode",
        "type": "uint8",
        "indexed": false,
        "internalType": "enum Types.BlueprintSelectionMode"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "DelegatorUnstakeExecuted",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "token",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "shares",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "DelegatorUnstakeScheduled",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "token",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "shares",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "estimatedAmount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "readyRound",
        "type": "uint64",
        "indexed": false,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Deposited",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "token",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "lock",
        "type": "uint8",
        "indexed": false,
        "internalType": "enum Types.LockMultiplier"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "ExpiredLocksHarvested",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "token",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "count",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "totalAmount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "FacetRegistered",
    "inputs": [
      {
        "name": "facet",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "FacetSelectorCleared",
    "inputs": [
      {
        "name": "selector",
        "type": "bytes4",
        "indexed": true,
        "internalType": "bytes4"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "FacetSelectorSet",
    "inputs": [
      {
        "name": "selector",
        "type": "bytes4",
        "indexed": true,
        "internalType": "bytes4"
      },
      {
        "name": "facet",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Initialized",
    "inputs": [
      {
        "name": "version",
        "type": "uint64",
        "indexed": false,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorBlueprintAdded",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "blueprintId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorBlueprintRemoved",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "blueprintId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorLeavingScheduled",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "readyRound",
        "type": "uint64",
        "indexed": false,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorLeft",
    "inputs": [
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
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "stake",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorStakeIncreased",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorUnstakeExecuted",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "OperatorUnstakeScheduled",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "readyRound",
        "type": "uint64",
        "indexed": false,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Paused",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleAdminChanged",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "previousAdminRole",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "newAdminRole",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleGranted",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "sender",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "RoleRevoked",
    "inputs": [
      {
        "name": "role",
        "type": "bytes32",
        "indexed": true,
        "internalType": "bytes32"
      },
      {
        "name": "account",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "sender",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "SlashRecorded",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "slashId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "totalSlashed",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "exchangeRateBefore",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "exchangeRateAfter",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Slashed",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "serviceId",
        "type": "uint64",
        "indexed": true,
        "internalType": "uint64"
      },
      {
        "name": "operatorSlashed",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "delegatorsSlashed",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "newExchangeRate",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "SlashedForService",
    "inputs": [
      {
        "name": "operator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
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
        "name": "totalSlashed",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "commitmentCount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Unpaused",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "indexed": false,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Upgraded",
    "inputs": [
      {
        "name": "implementation",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "WithdrawScheduled",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "token",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      },
      {
        "name": "readyRound",
        "type": "uint64",
        "indexed": false,
        "internalType": "uint64"
      }
    ],
    "anonymous": false
  },
  {
    "type": "event",
    "name": "Withdrawn",
    "inputs": [
      {
        "name": "delegator",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "token",
        "type": "address",
        "indexed": true,
        "internalType": "address"
      },
      {
        "name": "amount",
        "type": "uint256",
        "indexed": false,
        "internalType": "uint256"
      }
    ],
    "anonymous": false
  },
  {
    "type": "error",
    "name": "AccessControlBadConfirmation",
    "inputs": []
  },
  {
    "type": "error",
    "name": "AccessControlUnauthorizedAccount",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      },
      {
        "name": "neededRole",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ]
  },
  {
    "type": "error",
    "name": "AddressEmptyCode",
    "inputs": [
      {
        "name": "target",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "ERC1967InvalidImplementation",
    "inputs": [
      {
        "name": "implementation",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "ERC1967NonPayable",
    "inputs": []
  },
  {
    "type": "error",
    "name": "EnforcedPause",
    "inputs": []
  },
  {
    "type": "error",
    "name": "ExpectedPause",
    "inputs": []
  },
  {
    "type": "error",
    "name": "FailedCall",
    "inputs": []
  },
  {
    "type": "error",
    "name": "InvalidInitialization",
    "inputs": []
  },
  {
    "type": "error",
    "name": "NotAContract",
    "inputs": [
      {
        "name": "account",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "NotInitializing",
    "inputs": []
  },
  {
    "type": "error",
    "name": "ReentrancyGuardReentrantCall",
    "inputs": []
  },
  {
    "type": "error",
    "name": "SelectorAlreadyRegistered",
    "inputs": [
      {
        "name": "selector",
        "type": "bytes4",
        "internalType": "bytes4"
      },
      {
        "name": "existingFacet",
        "type": "address",
        "internalType": "address"
      }
    ]
  },
  {
    "type": "error",
    "name": "UUPSUnauthorizedCallContext",
    "inputs": []
  },
  {
    "type": "error",
    "name": "UUPSUnsupportedProxiableUUID",
    "inputs": [
      {
        "name": "slot",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ]
  },
  {
    "type": "error",
    "name": "UnknownSelector",
    "inputs": [
      {
        "name": "selector",
        "type": "bytes4",
        "internalType": "bytes4"
      }
    ]
  },
  {
    "type": "error",
    "name": "ZeroAddress",
    "inputs": []
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
pub mod MultiAssetDelegation {
    use super::*;
    use alloy::sol_types as alloy_sol_types;
    /// The creation / init bytecode of the contract.
    ///
    /// ```text
    ///0x60a080604052346100e857306080527ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a005460ff8160401c166100d9576002600160401b03196001600160401b03821601610073575b60405161216f90816100ed82396080518181816109cd01526113b40152f35b6001600160401b0319166001600160401b039081177ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a005581527fc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d290602090a15f80610054565b63f92ee8a960e01b5f5260045ffd5b5f80fdfe60806040526004361015610015575b3661185257005b5f3560e01c806301ffc9a71461033057806305d64e381461032b5780630aa8b1101461032657806318056dc21461032157806319e82e611461031c578063248a9ca3146103175780632f2ff15d1461031257806332273f611461030d57806336568abe14610308578063453eccea1461030357806346d163aa146102fe5780634962f88f146102545780634de8addc146102f95780634e9c929a146102725780634f1ef286146102f45780635095af64146102ef57806352d1902d146102ea57806354de2320146102e55780635c975abb146102e0578063615d24de146102db57806366c36875146102ae57806372b5032d146102a957806375b238fc146102d657806377ab2cf3146102d15780637df92ada146102cc5780638a19c8bc146102c75780638a7fe60f146102c257806390837ff4146102bd57806391d14854146102b85780639494f426146102b357806396085673146102ae5780639722f4b9146102a95780639e870585146102a4578063a217fddf1461029f578063a457af3d1461029a578063a4b32de814610295578063a7fa6f9814610290578063aaf5eb681461028b578063ad3cb1cc14610286578063b54b2b9e14610281578063ba05bbf51461027c578063c07449e214610277578063c550d93814610272578063cbb6d6bd1461026d578063d27a6f0614610268578063d547741f14610263578063db8a173a1461025e578063e07dec2914610259578063e1a4521814610254578063f3c9b3111461024f5763f7cb789a0361000e5761134b565b61132e565b6107c1565b611261565b61123b565b61120a565b6111ed565b61106c565b610806565b610fd0565b610fb1565b610f8f565b610f31565b610f0f565b610ef3565b610eb9565b610d56565b610d3c565b610d1f565b610b11565b610ad0565b610cde565b610c83565b610c3f565b610bff565b610bda565b610bbd565b610b9b565b610b61565b610a7e565b610a3d565b610a21565b6109bb565b610981565b61090b565b6107dd565b610698565b61067c565b610638565b610614565b6105de565b6105b8565b61051c565b6104d0565b610421565b6103a1565b61034b565b6001600160e01b031981160361034757565b5f80fd5b3461034757602036600319011261034757602060043561036a81610335565b63ffffffff60e01b16637965db0b60e01b8114908115610390575b506040519015158152f35b6301ffc9a760e01b1490505f610385565b34610347575f3660031901126103475760206001600160401b035f5460801c16604051908152f35b600435906001600160a01b038216820361034757565b602435906001600160a01b038216820361034757565b602435906001600160401b038216820361034757565b600435906001600160401b038216820361034757565b346103475760403660031901126103475761046f61043d6103c9565b6104456103f5565b9060018060a01b03165f52604e60205260405f20906001600160401b03165f5260205260405f2090565b8054600182015460028301546003840154600490940154604080516001600160401b03808716825286831c81166020830152608096871c169181019190915260608101939093529282015260a081019290925260c082015260e090f35b0390f35b34610347575f366003190112610347576020604051612af88152f35b9181601f84011215610347578235916001600160401b038311610347576020808501948460051b01011161034757565b34610347576040366003190112610347576105356103c9565b6024356001600160401b038111610347576105549036906004016104ec565b9161055d6118ac565b61056683611373565b9161057460405193846108af565b838352602083019360051b81019036821161034757935b81851061059e5761059c8484611975565b005b6020809186356105ad81610335565b81520194019361058b565b346103475760203660031901126103475760206105d660043561138a565b604051908152f35b346103475760403660031901126103475761059c6004356105fd6103df565b9061060f61060a8261138a565b61191b565b611d00565b34610347575f36600319011261034757602061ffff60015460801c16604051908152f35b34610347576040366003190112610347576004356106546103df565b336001600160a01b0382160361066d5761059c91611d95565b63334bd91960e11b5f5260045ffd5b34610347575f366003190112610347576020604051613e808152f35b34610347576020366003190112610347576106b16103c9565b6106b96118ac565b604051630dc4b72f60e31b8152906001600160a01b038116905f83600481855afa9081156107b6575f91610718575b906106f291611975565b7f4d3c30f5993f1922a779345a0f7ec1a170f1e52e9d230824f9c17e63596c906d5f80a2005b90503d805f853e61072981856108af565b830192602081850312610347578051906001600160401b038211610347570183601f820112156103475780519361075f85611373565b9161076d60405193846108af565b85835260208084019660051b82010191821161034757602001945b81861061079c5750929350839250906106e8565b6020809187516107ab81610335565b815201950194610788565b6040513d5f823e3d90fd5b34610347575f3660031901126103475760206040516127108152f35b34610347575f3660031901126103475760206001600160401b0360015460401c16604051908152f35b346103475760403660031901126103475760206001600160401b0361085661082c61040b565b826108356103df565b91165f526051845260405f209060018060a01b03165f5260205260405f2090565b5416604051908152f35b634e487b7160e01b5f52604160045260245ffd5b60e081019081106001600160401b0382111761088f57604052565b610860565b604081019081106001600160401b0382111761088f57604052565b90601f801991011681019081106001600160401b0382111761088f57604052565b604051906108df6040836108af565b565b604051906108df60c0836108af565b6001600160401b03811161088f57601f01601f191660200190565b60403660031901126103475761091f6103c9565b602435906001600160401b03821161034757366023830112156103475781600401359061094b826108f0565b9161095960405193846108af565b8083523660248286010111610347576020815f92602461059c970183870137840101526113a8565b34610347575f3660031901126103475760206040517f12b42e8a160f6064dc959c6f251e3af0750ad213dbecf573b4710d67d6c28e398152f35b34610347575f366003190112610347577f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03163003610a125760206040515f805160206121038339815191528152f35b63703e46dd60e11b5f5260045ffd5b34610347575f366003190112610347576020604051612ee08152f35b34610347575f36600319011261034757602060ff7fcd5ed15c6e187e77e9aee88184c21f4f2182ab5827cb3b7e07fbedcd63f0330054166040519015158152f35b34610347576020366003190112610347576001600160a01b03610a9f6103c9565b165f52600f60205260405f205480155f14610ac857506020670de0b6b3a7640000604051908152f35b6020906105d6565b34610347576020366003190112610347576001600160a01b03610af16103c9565b165f52604f60205260206001600160401b0360405f205416604051908152f35b346103475760403660031901126103475760206001600160401b03610856610b3761040b565b82610b406103df565b91165f526050845260405f209060018060a01b03165f5260205260405f2090565b34610347575f3660031901126103475760206040517fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c217758152f35b34610347575f36600319011261034757602060ff600554166040519015158152f35b34610347575f366003190112610347576020604051624f1a008152f35b34610347575f3660031901126103475760206001600160401b035f5416604051908152f35b34610347576020366003190112610347576001600160a01b03610c206103c9565b165f526006602052602060018060a01b0360405f205416604051908152f35b3461034757602036600319011261034757600435610c5c81610335565b63ffffffff60e01b165f52601e602052602060018060a01b0360405f205416604051908152f35b3461034757604036600319011261034757602060ff610cd2600435610ca66103df565b905f525f80516020612123833981519152845260405f209060018060a01b03165f5260205260405f2090565b54166040519015158152f35b3461034757606036600319011261034757610cf76103c9565b610cff6103f5565b906044356001600160a01b0381168103610347576020926105d6926114f9565b34610347575f36600319011261034757602060405162278d008152f35b34610347575f3660031901126103475760206040515f8152f35b34610347576040366003190112610347576104cc610dd9610d756103c9565b610d7d6103f5565b905f60c0604051610d8d81610874565b8281528260208201528260408201528260608201528260808201528260a0820152015260018060a01b03165f52604e60205260405f20906001600160401b03165f5260205260405f2090565b600460405191610de883610874565b80546001600160401b038082168552604082901c166020850152610e2a90610e1a905b60801c6001600160401b031690565b6001600160401b03166040850152565b6001810154606084015260028101546080840152600381015460a0840152015460c08201526040519182918291909160c08060e08301946001600160401b0381511684526001600160401b0360208201511660208501526001600160401b036040820151166040850152606081015160608501526080810151608085015260a081015160a08501520151910152565b34610347575f3660031901126103475760206040517fb1fadd3142ab2ad7f1337ea4d97112bcc8337fc11ce5b20cb04ad038adf998198152f35b34610347575f3660031901126103475760206040516132c88152f35b34610347575f366003190112610347576020604051670de0b6b3a76400008152f35b34610347575f366003190112610347576040805190610f5081836108af565b600582526020820191640352e302e360dc1b83528151928391602083525180918160208501528484015e5f828201840152601f01601f19168101030190f35b34610347575f36600319011261034757602060ff600754166040519015158152f35b34610347575f3660031901126103475760205f5460c01c604051908152f35b34610347576040366003190112610347576104cc611035610fef61040b565b6001600160401b03610fff6103df565b915f602060405161100f81610894565b8281520152165f52600e60205260405f209060018060a01b03165f5260205260405f2090565b60016040519161104483610894565b8054835201546020820152604051918291829190916020806040830194805184520151910152565b34610347576080366003190112610347576110856103c9565b6024359060643560443561ffff82168203610347575f8051602061214383398151915254936001600160401b036110cb60ff604088901c1615966001600160401b031690565b16801590816111e5575b60011490816111db575b1590816111d2575b506111c35761112a938561112160016001600160401b03195f805160206121438339815191525416175f8051602061214383398151915255565b61118957611619565b61113057005b61115a60ff60401b195f8051602061214383398151915254165f8051602061214383398151915255565b604051600181527fc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d290602090a1005b6111be6801000000000000000060ff60401b195f805160206121438339815191525416175f8051602061214383398151915255565b611619565b63f92ee8a960e01b5f5260045ffd5b9050155f6110e7565b303b1591506110df565b8691506110d5565b34610347575f3660031901126103475760206040516276a7008152f35b346103475760403660031901126103475761059c6004356112296103df565b9061123661060a8261138a565b611d95565b34610347575f3660031901126103475760206001600160401b0360015416604051908152f35b34610347576020366003190112610347576004356001600160401b038111610347576112919036906004016104ec565b6112996118ac565b5f5b8181106112a457005b806112b26001928486611833565b356112bc81610335565b6001600160e01b0319165f908152601e6020526040902080546001600160a01b03191690556113046112f76112f2838688611833565b611848565b6001600160e01b03191690565b7fbeb27701828f515b03069d44da6519b6c491da13ef1ca7082e619959d1f48ddb5f80a20161129b565b34610347575f36600319011261034757602060405162ed4e008152f35b34610347575f3660031901126103475760206001600160401b035f5460401c16604051908152f35b6001600160401b03811161088f5760051b60200190565b5f525f80516020612123833981519152602052600160405f20015490565b90916001600160a01b037f00000000000000000000000000000000000000000000000000000000000000001630811490811561149e575b50610a12576113ec6118ac565b6040516352d1902d60e01b8152926020846004816001600160a01b0387165afa5f948161146d575b5061143857634c9c8ce360e01b5f526001600160a01b03831660045260245ffd5b5ffd5b90915f805160206121038339815191528403611459576108df929350611f77565b632a87526960e21b5f52600484905260245ffd5b61149091955060203d602011611497575b61148881836108af565b810190611e35565b935f611414565b503d61147e565b5f80516020612103833981519152546001600160a01b0316141590505f6113df565b634e487b7160e01b5f52601160045260245ffd5b919082039182116114e157565b6114c0565b818102929181159184041417156114e157565b9291909261152c5f9460018060a01b0383165f52604e60205260405f20906001600160401b03165f5260205260405f2090565b906040519261153a84610874565b82546001600160401b038082168652604082901c1660208601526115719061156190610e0b565b6001600160401b03166040860152565b600183015460608501526001600160401b036115b660028501549560808101968752600460038701549660a08301978852015460c0820152516001600160401b031690565b161561161057906115c691611e6a565b91821561160857519051908181116115dd57505050565b6116059394506115f792916115f1916114d4565b906114e6565b670de0b6b3a7640000900490565b90565b505f93505050565b505f9450505050565b9061170c61179694936116b261176394611631612019565b611639612019565b611641612019565b611649612019565b60ff197fcd5ed15c6e187e77e9aee88184c21f4f2182ab5827cb3b7e07fbedcd63f0330054167fcd5ed15c6e187e77e9aee88184c21f4f2182ab5827cb3b7e07fbedcd63f0330055611699611eef565b6116a281611ae2565b506116ac81611b7e565b50611c3f565b506116cc6116be6108d0565b5f81525f6020820152611f25565b906116d56108e1565b6001815293602085015260408401525f60608401525f60808401526116fe60a084016127109052565b5f52600260205260405f2090565b90600561ffff60a081938051151560ff801988541691151516178655602081015160018701556040810151600287015560608101516003870155608081015160048701550151169201911661ffff19825416179055565b611775600160ff196005541617600555565b6001805461ffff60801b191660809290921b61ffff60801b16919091179055565b6117ac60016001600160401b03195f5416175f55565b6117cf695460000000000000000067ffffffffffffffff60401b195f5416175f55565b5f80546001600160c01b0316600760c21b1790556117fb601c6001600160401b03196001541617600155565b6108df6838000000000000000067ffffffffffffffff60401b196001541617600155565b634e487b7160e01b5f52603260045260245ffd5b91908110156118435760051b0190565b61181f565b3561160581610335565b5f80356001600160e01b031916808252601e6020526040909120546001600160a01b031690811561189a575f8083368280378136915af43d5f803e15611896573d5ff35b3d5ffd5b63c2a825f560e01b5f5260045260245ffd5b335f9081527fb16e88c42fd4e48df2dd6a2eabd6bc9aec654ec170056b470819f8892cc6431c602052604090205460ff16156118e457565b63e2517d3f60e01b5f52336004527fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c2177560245260445ffd5b5f8181525f805160206121238339815191526020908152604080832033845290915290205460ff161561194b5750565b63e2517d3f60e01b5f523360045260245260445ffd5b80518210156118435760209160051b010190565b9091906001600160a01b038116908115611ad357803b15611ab8575f5b8451811015611ab1576119e06119d36119bc6119ae8489611961565b516001600160e01b03191690565b63ffffffff60e01b165f52601e60205260405f2090565b546001600160a01b031690565b6001600160a01b03811680151590859082611aa6575b5050611a6e575080611a3383611a146119bc6119ae6001968b611961565b80546001600160a01b0319166001600160a01b03909216919091179055565b83611a446112f76119ae848a611961565b7f12557f25e458d9682d7c959b5a960bc9332e8b7af1120b54a333bfc1ff282b395f80a301611992565b611a7e6119ae6114359388611961565b6310ae11a960e31b5f526001600160e01b0319166004526001600160a01b0316602452604490565b14159050845f6119f6565b5050509050565b6322a2d07b60e21b5f526001600160a01b031660045260245ffd5b63d92e233d60e01b5f5260045ffd5b6001600160a01b0381165f9081527fb7db2dd08fcb62d0c9e08c51941cae53c267786a0b75803fb7960902fc8ef97d602052604090205460ff16611b79576001600160a01b03165f8181527fb7db2dd08fcb62d0c9e08c51941cae53c267786a0b75803fb7960902fc8ef97d60205260408120805460ff191660011790553391905f805160206120e38339815191528180a4600190565b505f90565b6001600160a01b0381165f9081527fb16e88c42fd4e48df2dd6a2eabd6bc9aec654ec170056b470819f8892cc6431c602052604090205460ff16611b79576001600160a01b0381165f9081527fb16e88c42fd4e48df2dd6a2eabd6bc9aec654ec170056b470819f8892cc6431c60205260409020805460ff1916600117905533906001600160a01b03167fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c217755f805160206120e38339815191525f80a4600190565b6001600160a01b0381165f9081527f5bc841a6d925a620866922bada36d16da3dcc9d52290519ea1126e5ca2372139602052604090205460ff16611b79576001600160a01b0381165f9081527f5bc841a6d925a620866922bada36d16da3dcc9d52290519ea1126e5ca237213960205260409020805460ff1916600117905533906001600160a01b03167fb1fadd3142ab2ad7f1337ea4d97112bcc8337fc11ce5b20cb04ad038adf998195f805160206120e38339815191525f80a4600190565b5f8181525f80516020612123833981519152602090815260408083206001600160a01b038616845290915290205460ff16611d8f575f8181525f80516020612123833981519152602090815260408083206001600160a01b03861684529091529020805460ff1916600117905533916001600160a01b0316905f805160206120e38339815191525f80a4600190565b50505f90565b5f8181525f80516020612123833981519152602090815260408083206001600160a01b038616845290915290205460ff1615611d8f575f8181525f80516020612123833981519152602090815260408083206001600160a01b03861684529091529020805460ff1916905533916001600160a01b0316907ff6391f5c32d9c69d2a47ea670b442974b53935d1edc7fd64eb21e047a839171b5f80a4600190565b90816020910312610347575190565b8054821015611843575f5260205f209060021b01905f90565b919082018092116114e157565b90915f925f5b6001600160a01b0384165f81815260136020526040902054821015611ab157805f526013602052611ea48260405f20611e44565b50546001600160a01b03848116911614611ec2575b50600101611e70565b60019195611ee8915f52601360205282611edf8860405f20611e44565b50015490611e5d565b9490611eb9565b611ef7612019565b611eff612019565b60017f9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f0055565b8051906002821015611f6357602090810151604080519283019384526001600160a01b03909116828201528152611f5d6060826108af565b51902090565b634e487b7160e01b5f52602160045260245ffd5b90813b15611ff8575f8051602061210383398151915280546001600160a01b0319166001600160a01b0384169081179091557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b5f80a2805115611fe057611fdd91612044565b50565b505034611fe957565b63b398979f60e01b5f5260045ffd5b50634c9c8ce360e01b5f9081526001600160a01b0391909116600452602490fd5b60ff5f805160206121438339815191525460401c161561203557565b631afcd79f60e31b5f5260045ffd5b5f8061160593602081519101845af43d15612080573d91612064836108f0565b9261207260405194856108af565b83523d5f602085013e612084565b6060915b906120a8575080511561209957805190602001fd5b63d6bda27560e01b5f5260045ffd5b815115806120d9575b6120b9575090565b639996b31560e01b5f9081526001600160a01b0391909116600452602490fd5b50803b156120b156fe2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc02dd7bc7dec4dceedda775e58dd541e08a116c6c53815c0bd028192f7b626800f0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00a164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\xA0\x80`@R4a\0\xE8W0`\x80R\x7F\xF0\xC5~\x16\x84\r\xF0@\xF1P\x88\xDC/\x81\xFE9\x1C9#\xBE\xC7>#\xA9f.\xFC\x9C\"\x9Cj\0T`\xFF\x81`@\x1C\x16a\0\xD9W`\x02`\x01`@\x1B\x03\x19`\x01`\x01`@\x1B\x03\x82\x16\x01a\0sW[`@Qa!o\x90\x81a\0\xED\x829`\x80Q\x81\x81\x81a\t\xCD\x01Ra\x13\xB4\x01R\xF3[`\x01`\x01`@\x1B\x03\x19\x16`\x01`\x01`@\x1B\x03\x90\x81\x17\x7F\xF0\xC5~\x16\x84\r\xF0@\xF1P\x88\xDC/\x81\xFE9\x1C9#\xBE\xC7>#\xA9f.\xFC\x9C\"\x9Cj\0U\x81R\x7F\xC7\xF5\x05\xB2\xF3q\xAE!u\xEEI\x13\xF4I\x9E\x1F&3\xA7\xB5\x93c!\xEE\xD1\xCD\xAE\xB6\x11Q\x81\xD2\x90` \x90\xA1_\x80a\0TV[c\xF9.\xE8\xA9`\xE0\x1B_R`\x04_\xFD[_\x80\xFD\xFE`\x80`@R`\x046\x10\x15a\0\x15W[6a\x18RW\0[_5`\xE0\x1C\x80c\x01\xFF\xC9\xA7\x14a\x030W\x80c\x05\xD6N8\x14a\x03+W\x80c\n\xA8\xB1\x10\x14a\x03&W\x80c\x18\x05m\xC2\x14a\x03!W\x80c\x19\xE8.a\x14a\x03\x1CW\x80c$\x8A\x9C\xA3\x14a\x03\x17W\x80c//\xF1]\x14a\x03\x12W\x80c2'?a\x14a\x03\rW\x80c6V\x8A\xBE\x14a\x03\x08W\x80cE>\xCC\xEA\x14a\x03\x03W\x80cF\xD1c\xAA\x14a\x02\xFEW\x80cIb\xF8\x8F\x14a\x02TW\x80cM\xE8\xAD\xDC\x14a\x02\xF9W\x80cN\x9C\x92\x9A\x14a\x02rW\x80cO\x1E\xF2\x86\x14a\x02\xF4W\x80cP\x95\xAFd\x14a\x02\xEFW\x80cR\xD1\x90-\x14a\x02\xEAW\x80cT\xDE# \x14a\x02\xE5W\x80c\\\x97Z\xBB\x14a\x02\xE0W\x80ca]$\xDE\x14a\x02\xDBW\x80cf\xC3hu\x14a\x02\xAEW\x80cr\xB5\x03-\x14a\x02\xA9W\x80cu\xB28\xFC\x14a\x02\xD6W\x80cw\xAB,\xF3\x14a\x02\xD1W\x80c}\xF9*\xDA\x14a\x02\xCCW\x80c\x8A\x19\xC8\xBC\x14a\x02\xC7W\x80c\x8A\x7F\xE6\x0F\x14a\x02\xC2W\x80c\x90\x83\x7F\xF4\x14a\x02\xBDW\x80c\x91\xD1HT\x14a\x02\xB8W\x80c\x94\x94\xF4&\x14a\x02\xB3W\x80c\x96\x08Vs\x14a\x02\xAEW\x80c\x97\"\xF4\xB9\x14a\x02\xA9W\x80c\x9E\x87\x05\x85\x14a\x02\xA4W\x80c\xA2\x17\xFD\xDF\x14a\x02\x9FW\x80c\xA4W\xAF=\x14a\x02\x9AW\x80c\xA4\xB3-\xE8\x14a\x02\x95W\x80c\xA7\xFAo\x98\x14a\x02\x90W\x80c\xAA\xF5\xEBh\x14a\x02\x8BW\x80c\xAD<\xB1\xCC\x14a\x02\x86W\x80c\xB5K+\x9E\x14a\x02\x81W\x80c\xBA\x05\xBB\xF5\x14a\x02|W\x80c\xC0tI\xE2\x14a\x02wW\x80c\xC5P\xD98\x14a\x02rW\x80c\xCB\xB6\xD6\xBD\x14a\x02mW\x80c\xD2zo\x06\x14a\x02hW\x80c\xD5Gt\x1F\x14a\x02cW\x80c\xDB\x8A\x17:\x14a\x02^W\x80c\xE0}\xEC)\x14a\x02YW\x80c\xE1\xA4R\x18\x14a\x02TW\x80c\xF3\xC9\xB3\x11\x14a\x02OWc\xF7\xCBx\x9A\x03a\0\x0EWa\x13KV[a\x13.V[a\x07\xC1V[a\x12aV[a\x12;V[a\x12\nV[a\x11\xEDV[a\x10lV[a\x08\x06V[a\x0F\xD0V[a\x0F\xB1V[a\x0F\x8FV[a\x0F1V[a\x0F\x0FV[a\x0E\xF3V[a\x0E\xB9V[a\rVV[a\r<V[a\r\x1FV[a\x0B\x11V[a\n\xD0V[a\x0C\xDEV[a\x0C\x83V[a\x0C?V[a\x0B\xFFV[a\x0B\xDAV[a\x0B\xBDV[a\x0B\x9BV[a\x0BaV[a\n~V[a\n=V[a\n!V[a\t\xBBV[a\t\x81V[a\t\x0BV[a\x07\xDDV[a\x06\x98V[a\x06|V[a\x068V[a\x06\x14V[a\x05\xDEV[a\x05\xB8V[a\x05\x1CV[a\x04\xD0V[a\x04!V[a\x03\xA1V[a\x03KV[`\x01`\x01`\xE0\x1B\x03\x19\x81\x16\x03a\x03GWV[_\x80\xFD[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW` `\x045a\x03j\x81a\x035V[c\xFF\xFF\xFF\xFF`\xE0\x1B\x16cye\xDB\x0B`\xE0\x1B\x81\x14\x90\x81\x15a\x03\x90W[P`@Q\x90\x15\x15\x81R\xF3[c\x01\xFF\xC9\xA7`\xE0\x1B\x14\x90P_a\x03\x85V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03_T`\x80\x1C\x16`@Q\x90\x81R\xF3[`\x045\x90`\x01`\x01`\xA0\x1B\x03\x82\x16\x82\x03a\x03GWV[`$5\x90`\x01`\x01`\xA0\x1B\x03\x82\x16\x82\x03a\x03GWV[`$5\x90`\x01`\x01`@\x1B\x03\x82\x16\x82\x03a\x03GWV[`\x045\x90`\x01`\x01`@\x1B\x03\x82\x16\x82\x03a\x03GWV[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x04oa\x04=a\x03\xC9V[a\x04Ea\x03\xF5V[\x90`\x01\x80`\xA0\x1B\x03\x16_R`N` R`@_ \x90`\x01`\x01`@\x1B\x03\x16_R` R`@_ \x90V[\x80T`\x01\x82\x01T`\x02\x83\x01T`\x03\x84\x01T`\x04\x90\x94\x01T`@\x80Q`\x01`\x01`@\x1B\x03\x80\x87\x16\x82R\x86\x83\x1C\x81\x16` \x83\x01R`\x80\x96\x87\x1C\x16\x91\x81\x01\x91\x90\x91R``\x81\x01\x93\x90\x93R\x92\x82\x01R`\xA0\x81\x01\x92\x90\x92R`\xC0\x82\x01R`\xE0\x90\xF3[\x03\x90\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa*\xF8\x81R\xF3[\x91\x81`\x1F\x84\x01\x12\x15a\x03GW\x825\x91`\x01`\x01`@\x1B\x03\x83\x11a\x03GW` \x80\x85\x01\x94\x84`\x05\x1B\x01\x01\x11a\x03GWV[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x055a\x03\xC9V[`$5`\x01`\x01`@\x1B\x03\x81\x11a\x03GWa\x05T\x906\x90`\x04\x01a\x04\xECV[\x91a\x05]a\x18\xACV[a\x05f\x83a\x13sV[\x91a\x05t`@Q\x93\x84a\x08\xAFV[\x83\x83R` \x83\x01\x93`\x05\x1B\x81\x01\x906\x82\x11a\x03GW\x93[\x81\x85\x10a\x05\x9EWa\x05\x9C\x84\x84a\x19uV[\0[` \x80\x91\x865a\x05\xAD\x81a\x035V[\x81R\x01\x94\x01\x93a\x05\x8BV[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW` a\x05\xD6`\x045a\x13\x8AV[`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x05\x9C`\x045a\x05\xFDa\x03\xDFV[\x90a\x06\x0Fa\x06\n\x82a\x13\x8AV[a\x19\x1BV[a\x1D\0V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` a\xFF\xFF`\x01T`\x80\x1C\x16`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GW`\x045a\x06Ta\x03\xDFV[3`\x01`\x01`\xA0\x1B\x03\x82\x16\x03a\x06mWa\x05\x9C\x91a\x1D\x95V[c3K\xD9\x19`\xE1\x1B_R`\x04_\xFD[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa>\x80\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GWa\x06\xB1a\x03\xC9V[a\x06\xB9a\x18\xACV[`@Qc\r\xC4\xB7/`\xE3\x1B\x81R\x90`\x01`\x01`\xA0\x1B\x03\x81\x16\x90_\x83`\x04\x81\x85Z\xFA\x90\x81\x15a\x07\xB6W_\x91a\x07\x18W[\x90a\x06\xF2\x91a\x19uV[\x7FM<0\xF5\x99?\x19\"\xA7y4Z\x0F~\xC1\xA1p\xF1\xE5.\x9D#\x08$\xF9\xC1~cYl\x90m_\x80\xA2\0[\x90P=\x80_\x85>a\x07)\x81\x85a\x08\xAFV[\x83\x01\x92` \x81\x85\x03\x12a\x03GW\x80Q\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03GW\x01\x83`\x1F\x82\x01\x12\x15a\x03GW\x80Q\x93a\x07_\x85a\x13sV[\x91a\x07m`@Q\x93\x84a\x08\xAFV[\x85\x83R` \x80\x84\x01\x96`\x05\x1B\x82\x01\x01\x91\x82\x11a\x03GW` \x01\x94[\x81\x86\x10a\x07\x9CWP\x92\x93P\x83\x92P\x90a\x06\xE8V[` \x80\x91\x87Qa\x07\xAB\x81a\x035V[\x81R\x01\x95\x01\x94a\x07\x88V[`@Q=_\x82>=\x90\xFD[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa'\x10\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03`\x01T`@\x1C\x16`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03a\x08Va\x08,a\x04\x0BV[\x82a\x085a\x03\xDFV[\x91\x16_R`Q\x84R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ \x90V[T\x16`@Q\x90\x81R\xF3[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[`\xE0\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x08\x8FW`@RV[a\x08`V[`@\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x08\x8FW`@RV[\x90`\x1F\x80\x19\x91\x01\x16\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x08\x8FW`@RV[`@Q\x90a\x08\xDF`@\x83a\x08\xAFV[V[`@Q\x90a\x08\xDF`\xC0\x83a\x08\xAFV[`\x01`\x01`@\x1B\x03\x81\x11a\x08\x8FW`\x1F\x01`\x1F\x19\x16` \x01\x90V[`@6`\x03\x19\x01\x12a\x03GWa\t\x1Fa\x03\xC9V[`$5\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03GW6`#\x83\x01\x12\x15a\x03GW\x81`\x04\x015\x90a\tK\x82a\x08\xF0V[\x91a\tY`@Q\x93\x84a\x08\xAFV[\x80\x83R6`$\x82\x86\x01\x01\x11a\x03GW` \x81_\x92`$a\x05\x9C\x97\x01\x83\x87\x017\x84\x01\x01Ra\x13\xA8V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Q\x7F\x12\xB4.\x8A\x16\x0F`d\xDC\x95\x9Co%\x1E:\xF0u\n\xD2\x13\xDB\xEC\xF5s\xB4q\rg\xD6\xC2\x8E9\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x160\x03a\n\x12W` `@Q_\x80Q` a!\x03\x839\x81Q\x91R\x81R\xF3[cp>F\xDD`\xE1\x1B_R`\x04_\xFD[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa.\xE0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\xFF\x7F\xCD^\xD1\\n\x18~w\xE9\xAE\xE8\x81\x84\xC2\x1FO!\x82\xABX'\xCB;~\x07\xFB\xED\xCDc\xF03\0T\x16`@Q\x90\x15\x15\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x01`\x01`\xA0\x1B\x03a\n\x9Fa\x03\xC9V[\x16_R`\x0F` R`@_ T\x80\x15_\x14a\n\xC8WP` g\r\xE0\xB6\xB3\xA7d\0\0`@Q\x90\x81R\xF3[` \x90a\x05\xD6V[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x01`\x01`\xA0\x1B\x03a\n\xF1a\x03\xC9V[\x16_R`O` R` `\x01`\x01`@\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03a\x08Va\x0B7a\x04\x0BV[\x82a\x0B@a\x03\xDFV[\x91\x16_R`P\x84R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ \x90V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Q\x7F\xA4\x98\x07 \\\xE4\xD3U\t.\xF5\xA8\xA1\x8FV\xE8\x91<\xF4\xA2\x01\xFB\xE2\x87\x82[\tV\x93\xC2\x17u\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\xFF`\x05T\x16`@Q\x90\x15\x15\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@QbO\x1A\0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03_T\x16`@Q\x90\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x01`\x01`\xA0\x1B\x03a\x0C a\x03\xC9V[\x16_R`\x06` R` `\x01\x80`\xA0\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x045a\x0C\\\x81a\x035V[c\xFF\xFF\xFF\xFF`\xE0\x1B\x16_R`\x1E` R` `\x01\x80`\xA0\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GW` `\xFFa\x0C\xD2`\x045a\x0C\xA6a\x03\xDFV[\x90_R_\x80Q` a!#\x839\x81Q\x91R\x84R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ \x90V[T\x16`@Q\x90\x15\x15\x81R\xF3[4a\x03GW``6`\x03\x19\x01\x12a\x03GWa\x0C\xF7a\x03\xC9V[a\x0C\xFFa\x03\xF5V[\x90`D5`\x01`\x01`\xA0\x1B\x03\x81\x16\x81\x03a\x03GW` \x92a\x05\xD6\x92a\x14\xF9V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qb'\x8D\0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Q_\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x04\xCCa\r\xD9a\rua\x03\xC9V[a\r}a\x03\xF5V[\x90_`\xC0`@Qa\r\x8D\x81a\x08tV[\x82\x81R\x82` \x82\x01R\x82`@\x82\x01R\x82``\x82\x01R\x82`\x80\x82\x01R\x82`\xA0\x82\x01R\x01R`\x01\x80`\xA0\x1B\x03\x16_R`N` R`@_ \x90`\x01`\x01`@\x1B\x03\x16_R` R`@_ \x90V[`\x04`@Q\x91a\r\xE8\x83a\x08tV[\x80T`\x01`\x01`@\x1B\x03\x80\x82\x16\x85R`@\x82\x90\x1C\x16` \x85\x01Ra\x0E*\x90a\x0E\x1A\x90[`\x80\x1C`\x01`\x01`@\x1B\x03\x16\x90V[`\x01`\x01`@\x1B\x03\x16`@\x85\x01RV[`\x01\x81\x01T``\x84\x01R`\x02\x81\x01T`\x80\x84\x01R`\x03\x81\x01T`\xA0\x84\x01R\x01T`\xC0\x82\x01R`@Q\x91\x82\x91\x82\x91\x90\x91`\xC0\x80`\xE0\x83\x01\x94`\x01`\x01`@\x1B\x03\x81Q\x16\x84R`\x01`\x01`@\x1B\x03` \x82\x01Q\x16` \x85\x01R`\x01`\x01`@\x1B\x03`@\x82\x01Q\x16`@\x85\x01R``\x81\x01Q``\x85\x01R`\x80\x81\x01Q`\x80\x85\x01R`\xA0\x81\x01Q`\xA0\x85\x01R\x01Q\x91\x01RV[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Q\x7F\xB1\xFA\xDD1B\xAB*\xD7\xF13~\xA4\xD9q\x12\xBC\xC83\x7F\xC1\x1C\xE5\xB2\x0C\xB0J\xD08\xAD\xF9\x98\x19\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa2\xC8\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qg\r\xE0\xB6\xB3\xA7d\0\0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW`@\x80Q\x90a\x0FP\x81\x83a\x08\xAFV[`\x05\x82R` \x82\x01\x91d\x03R\xE3\x02\xE3`\xDC\x1B\x83R\x81Q\x92\x83\x91` \x83RQ\x80\x91\x81` \x85\x01R\x84\x84\x01^_\x82\x82\x01\x84\x01R`\x1F\x01`\x1F\x19\x16\x81\x01\x03\x01\x90\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\xFF`\x07T\x16`@Q\x90\x15\x15\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` _T`\xC0\x1C`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x04\xCCa\x105a\x0F\xEFa\x04\x0BV[`\x01`\x01`@\x1B\x03a\x0F\xFFa\x03\xDFV[\x91_` `@Qa\x10\x0F\x81a\x08\x94V[\x82\x81R\x01R\x16_R`\x0E` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ \x90V[`\x01`@Q\x91a\x10D\x83a\x08\x94V[\x80T\x83R\x01T` \x82\x01R`@Q\x91\x82\x91\x82\x91\x90\x91` \x80`@\x83\x01\x94\x80Q\x84R\x01Q\x91\x01RV[4a\x03GW`\x806`\x03\x19\x01\x12a\x03GWa\x10\x85a\x03\xC9V[`$5\x90`d5`D5a\xFF\xFF\x82\x16\x82\x03a\x03GW_\x80Q` a!C\x839\x81Q\x91RT\x93`\x01`\x01`@\x1B\x03a\x10\xCB`\xFF`@\x88\x90\x1C\x16\x15\x96`\x01`\x01`@\x1B\x03\x16\x90V[\x16\x80\x15\x90\x81a\x11\xE5W[`\x01\x14\x90\x81a\x11\xDBW[\x15\x90\x81a\x11\xD2W[Pa\x11\xC3Wa\x11*\x93\x85a\x11!`\x01`\x01`\x01`@\x1B\x03\x19_\x80Q` a!C\x839\x81Q\x91RT\x16\x17_\x80Q` a!C\x839\x81Q\x91RUV[a\x11\x89Wa\x16\x19V[a\x110W\0[a\x11Z`\xFF`@\x1B\x19_\x80Q` a!C\x839\x81Q\x91RT\x16_\x80Q` a!C\x839\x81Q\x91RUV[`@Q`\x01\x81R\x7F\xC7\xF5\x05\xB2\xF3q\xAE!u\xEEI\x13\xF4I\x9E\x1F&3\xA7\xB5\x93c!\xEE\xD1\xCD\xAE\xB6\x11Q\x81\xD2\x90` \x90\xA1\0[a\x11\xBEh\x01\0\0\0\0\0\0\0\0`\xFF`@\x1B\x19_\x80Q` a!C\x839\x81Q\x91RT\x16\x17_\x80Q` a!C\x839\x81Q\x91RUV[a\x16\x19V[c\xF9.\xE8\xA9`\xE0\x1B_R`\x04_\xFD[\x90P\x15_a\x10\xE7V[0;\x15\x91Pa\x10\xDFV[\x86\x91Pa\x10\xD5V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qbv\xA7\0\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x05\x9C`\x045a\x12)a\x03\xDFV[\x90a\x126a\x06\n\x82a\x13\x8AV[a\x1D\x95V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03`\x01T\x16`@Q\x90\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x045`\x01`\x01`@\x1B\x03\x81\x11a\x03GWa\x12\x91\x906\x90`\x04\x01a\x04\xECV[a\x12\x99a\x18\xACV[_[\x81\x81\x10a\x12\xA4W\0[\x80a\x12\xB2`\x01\x92\x84\x86a\x183V[5a\x12\xBC\x81a\x035V[`\x01`\x01`\xE0\x1B\x03\x19\x16_\x90\x81R`\x1E` R`@\x90 \x80T`\x01`\x01`\xA0\x1B\x03\x19\x16\x90Ua\x13\x04a\x12\xF7a\x12\xF2\x83\x86\x88a\x183V[a\x18HV[`\x01`\x01`\xE0\x1B\x03\x19\x16\x90V[\x7F\xBE\xB2w\x01\x82\x8FQ[\x03\x06\x9DD\xDAe\x19\xB6\xC4\x91\xDA\x13\xEF\x1C\xA7\x08.a\x99Y\xD1\xF4\x8D\xDB_\x80\xA2\x01a\x12\x9BV[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qb\xEDN\0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03_T`@\x1C\x16`@Q\x90\x81R\xF3[`\x01`\x01`@\x1B\x03\x81\x11a\x08\x8FW`\x05\x1B` \x01\x90V[_R_\x80Q` a!#\x839\x81Q\x91R` R`\x01`@_ \x01T\x90V[\x90\x91`\x01`\x01`\xA0\x1B\x03\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x160\x81\x14\x90\x81\x15a\x14\x9EW[Pa\n\x12Wa\x13\xECa\x18\xACV[`@QcR\xD1\x90-`\xE0\x1B\x81R\x92` \x84`\x04\x81`\x01`\x01`\xA0\x1B\x03\x87\x16Z\xFA_\x94\x81a\x14mW[Pa\x148WcL\x9C\x8C\xE3`\xE0\x1B_R`\x01`\x01`\xA0\x1B\x03\x83\x16`\x04R`$_\xFD[_\xFD[\x90\x91_\x80Q` a!\x03\x839\x81Q\x91R\x84\x03a\x14YWa\x08\xDF\x92\x93Pa\x1FwV[c*\x87Ri`\xE2\x1B_R`\x04\x84\x90R`$_\xFD[a\x14\x90\x91\x95P` =` \x11a\x14\x97W[a\x14\x88\x81\x83a\x08\xAFV[\x81\x01\x90a\x1E5V[\x93_a\x14\x14V[P=a\x14~V[_\x80Q` a!\x03\x839\x81Q\x91RT`\x01`\x01`\xA0\x1B\x03\x16\x14\x15\x90P_a\x13\xDFV[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[\x91\x90\x82\x03\x91\x82\x11a\x14\xE1WV[a\x14\xC0V[\x81\x81\x02\x92\x91\x81\x15\x91\x84\x04\x14\x17\x15a\x14\xE1WV[\x92\x91\x90\x92a\x15,_\x94`\x01\x80`\xA0\x1B\x03\x83\x16_R`N` R`@_ \x90`\x01`\x01`@\x1B\x03\x16_R` R`@_ \x90V[\x90`@Q\x92a\x15:\x84a\x08tV[\x82T`\x01`\x01`@\x1B\x03\x80\x82\x16\x86R`@\x82\x90\x1C\x16` \x86\x01Ra\x15q\x90a\x15a\x90a\x0E\x0BV[`\x01`\x01`@\x1B\x03\x16`@\x86\x01RV[`\x01\x83\x01T``\x85\x01R`\x01`\x01`@\x1B\x03a\x15\xB6`\x02\x85\x01T\x95`\x80\x81\x01\x96\x87R`\x04`\x03\x87\x01T\x96`\xA0\x83\x01\x97\x88R\x01T`\xC0\x82\x01RQ`\x01`\x01`@\x1B\x03\x16\x90V[\x16\x15a\x16\x10W\x90a\x15\xC6\x91a\x1EjV[\x91\x82\x15a\x16\x08WQ\x90Q\x90\x81\x81\x11a\x15\xDDWPPPV[a\x16\x05\x93\x94Pa\x15\xF7\x92\x91a\x15\xF1\x91a\x14\xD4V[\x90a\x14\xE6V[g\r\xE0\xB6\xB3\xA7d\0\0\x90\x04\x90V[\x90V[P_\x93PPPV[P_\x94PPPPV[\x90a\x17\x0Ca\x17\x96\x94\x93a\x16\xB2a\x17c\x94a\x161a \x19V[a\x169a \x19V[a\x16Aa \x19V[a\x16Ia \x19V[`\xFF\x19\x7F\xCD^\xD1\\n\x18~w\xE9\xAE\xE8\x81\x84\xC2\x1FO!\x82\xABX'\xCB;~\x07\xFB\xED\xCDc\xF03\0T\x16\x7F\xCD^\xD1\\n\x18~w\xE9\xAE\xE8\x81\x84\xC2\x1FO!\x82\xABX'\xCB;~\x07\xFB\xED\xCDc\xF03\0Ua\x16\x99a\x1E\xEFV[a\x16\xA2\x81a\x1A\xE2V[Pa\x16\xAC\x81a\x1B~V[Pa\x1C?V[Pa\x16\xCCa\x16\xBEa\x08\xD0V[_\x81R_` \x82\x01Ra\x1F%V[\x90a\x16\xD5a\x08\xE1V[`\x01\x81R\x93` \x85\x01R`@\x84\x01R_``\x84\x01R_`\x80\x84\x01Ra\x16\xFE`\xA0\x84\x01a'\x10\x90RV[_R`\x02` R`@_ \x90V[\x90`\x05a\xFF\xFF`\xA0\x81\x93\x80Q\x15\x15`\xFF\x80\x19\x88T\x16\x91\x15\x15\x16\x17\x86U` \x81\x01Q`\x01\x87\x01U`@\x81\x01Q`\x02\x87\x01U``\x81\x01Q`\x03\x87\x01U`\x80\x81\x01Q`\x04\x87\x01U\x01Q\x16\x92\x01\x91\x16a\xFF\xFF\x19\x82T\x16\x17\x90UV[a\x17u`\x01`\xFF\x19`\x05T\x16\x17`\x05UV[`\x01\x80Ta\xFF\xFF`\x80\x1B\x19\x16`\x80\x92\x90\x92\x1Ba\xFF\xFF`\x80\x1B\x16\x91\x90\x91\x17\x90UV[a\x17\xAC`\x01`\x01`\x01`@\x1B\x03\x19_T\x16\x17_UV[a\x17\xCFiT`\0\0\0\0\0\0\0\0g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF`@\x1B\x19_T\x16\x17_UV[_\x80T`\x01`\x01`\xC0\x1B\x03\x16`\x07`\xC2\x1B\x17\x90Ua\x17\xFB`\x1C`\x01`\x01`@\x1B\x03\x19`\x01T\x16\x17`\x01UV[a\x08\xDFh8\0\0\0\0\0\0\0\0g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF`@\x1B\x19`\x01T\x16\x17`\x01UV[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[\x91\x90\x81\x10\x15a\x18CW`\x05\x1B\x01\x90V[a\x18\x1FV[5a\x16\x05\x81a\x035V[_\x805`\x01`\x01`\xE0\x1B\x03\x19\x16\x80\x82R`\x1E` R`@\x90\x91 T`\x01`\x01`\xA0\x1B\x03\x16\x90\x81\x15a\x18\x9AW_\x80\x836\x82\x807\x816\x91Z\xF4=_\x80>\x15a\x18\x96W=_\xF3[=_\xFD[c\xC2\xA8%\xF5`\xE0\x1B_R`\x04R`$_\xFD[3_\x90\x81R\x7F\xB1n\x88\xC4/\xD4\xE4\x8D\xF2\xDDj.\xAB\xD6\xBC\x9A\xECeN\xC1p\x05kG\x08\x19\xF8\x89,\xC6C\x1C` R`@\x90 T`\xFF\x16\x15a\x18\xE4WV[c\xE2Q}?`\xE0\x1B_R3`\x04R\x7F\xA4\x98\x07 \\\xE4\xD3U\t.\xF5\xA8\xA1\x8FV\xE8\x91<\xF4\xA2\x01\xFB\xE2\x87\x82[\tV\x93\xC2\x17u`$R`D_\xFD[_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 3\x84R\x90\x91R\x90 T`\xFF\x16\x15a\x19KWPV[c\xE2Q}?`\xE0\x1B_R3`\x04R`$R`D_\xFD[\x80Q\x82\x10\x15a\x18CW` \x91`\x05\x1B\x01\x01\x90V[\x90\x91\x90`\x01`\x01`\xA0\x1B\x03\x81\x16\x90\x81\x15a\x1A\xD3W\x80;\x15a\x1A\xB8W_[\x84Q\x81\x10\x15a\x1A\xB1Wa\x19\xE0a\x19\xD3a\x19\xBCa\x19\xAE\x84\x89a\x19aV[Q`\x01`\x01`\xE0\x1B\x03\x19\x16\x90V[c\xFF\xFF\xFF\xFF`\xE0\x1B\x16_R`\x1E` R`@_ \x90V[T`\x01`\x01`\xA0\x1B\x03\x16\x90V[`\x01`\x01`\xA0\x1B\x03\x81\x16\x80\x15\x15\x90\x85\x90\x82a\x1A\xA6W[PPa\x1AnWP\x80a\x1A3\x83a\x1A\x14a\x19\xBCa\x19\xAE`\x01\x96\x8Ba\x19aV[\x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x90\x92\x16\x91\x90\x91\x17\x90UV[\x83a\x1ADa\x12\xF7a\x19\xAE\x84\x8Aa\x19aV[\x7F\x12U\x7F%\xE4X\xD9h-|\x95\x9BZ\x96\x0B\xC93.\x8Bz\xF1\x12\x0BT\xA33\xBF\xC1\xFF(+9_\x80\xA3\x01a\x19\x92V[a\x1A~a\x19\xAEa\x145\x93\x88a\x19aV[c\x10\xAE\x11\xA9`\xE3\x1B_R`\x01`\x01`\xE0\x1B\x03\x19\x16`\x04R`\x01`\x01`\xA0\x1B\x03\x16`$R`D\x90V[\x14\x15\x90P\x84_a\x19\xF6V[PPP\x90PV[c\"\xA2\xD0{`\xE2\x1B_R`\x01`\x01`\xA0\x1B\x03\x16`\x04R`$_\xFD[c\xD9.#=`\xE0\x1B_R`\x04_\xFD[`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F\xB7\xDB-\xD0\x8F\xCBb\xD0\xC9\xE0\x8CQ\x94\x1C\xAES\xC2gxj\x0Bu\x80?\xB7\x96\t\x02\xFC\x8E\xF9}` R`@\x90 T`\xFF\x16a\x1ByW`\x01`\x01`\xA0\x1B\x03\x16_\x81\x81R\x7F\xB7\xDB-\xD0\x8F\xCBb\xD0\xC9\xE0\x8CQ\x94\x1C\xAES\xC2gxj\x0Bu\x80?\xB7\x96\t\x02\xFC\x8E\xF9}` R`@\x81 \x80T`\xFF\x19\x16`\x01\x17\x90U3\x91\x90_\x80Q` a \xE3\x839\x81Q\x91R\x81\x80\xA4`\x01\x90V[P_\x90V[`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F\xB1n\x88\xC4/\xD4\xE4\x8D\xF2\xDDj.\xAB\xD6\xBC\x9A\xECeN\xC1p\x05kG\x08\x19\xF8\x89,\xC6C\x1C` R`@\x90 T`\xFF\x16a\x1ByW`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F\xB1n\x88\xC4/\xD4\xE4\x8D\xF2\xDDj.\xAB\xD6\xBC\x9A\xECeN\xC1p\x05kG\x08\x19\xF8\x89,\xC6C\x1C` R`@\x90 \x80T`\xFF\x19\x16`\x01\x17\x90U3\x90`\x01`\x01`\xA0\x1B\x03\x16\x7F\xA4\x98\x07 \\\xE4\xD3U\t.\xF5\xA8\xA1\x8FV\xE8\x91<\xF4\xA2\x01\xFB\xE2\x87\x82[\tV\x93\xC2\x17u_\x80Q` a \xE3\x839\x81Q\x91R_\x80\xA4`\x01\x90V[`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F[\xC8A\xA6\xD9%\xA6 \x86i\"\xBA\xDA6\xD1m\xA3\xDC\xC9\xD5\"\x90Q\x9E\xA1\x12n\\\xA27!9` R`@\x90 T`\xFF\x16a\x1ByW`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F[\xC8A\xA6\xD9%\xA6 \x86i\"\xBA\xDA6\xD1m\xA3\xDC\xC9\xD5\"\x90Q\x9E\xA1\x12n\\\xA27!9` R`@\x90 \x80T`\xFF\x19\x16`\x01\x17\x90U3\x90`\x01`\x01`\xA0\x1B\x03\x16\x7F\xB1\xFA\xDD1B\xAB*\xD7\xF13~\xA4\xD9q\x12\xBC\xC83\x7F\xC1\x1C\xE5\xB2\x0C\xB0J\xD08\xAD\xF9\x98\x19_\x80Q` a \xE3\x839\x81Q\x91R_\x80\xA4`\x01\x90V[_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 `\x01`\x01`\xA0\x1B\x03\x86\x16\x84R\x90\x91R\x90 T`\xFF\x16a\x1D\x8FW_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 `\x01`\x01`\xA0\x1B\x03\x86\x16\x84R\x90\x91R\x90 \x80T`\xFF\x19\x16`\x01\x17\x90U3\x91`\x01`\x01`\xA0\x1B\x03\x16\x90_\x80Q` a \xE3\x839\x81Q\x91R_\x80\xA4`\x01\x90V[PP_\x90V[_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 `\x01`\x01`\xA0\x1B\x03\x86\x16\x84R\x90\x91R\x90 T`\xFF\x16\x15a\x1D\x8FW_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 `\x01`\x01`\xA0\x1B\x03\x86\x16\x84R\x90\x91R\x90 \x80T`\xFF\x19\x16\x90U3\x91`\x01`\x01`\xA0\x1B\x03\x16\x90\x7F\xF69\x1F\\2\xD9\xC6\x9D*G\xEAg\x0BD)t\xB595\xD1\xED\xC7\xFDd\xEB!\xE0G\xA89\x17\x1B_\x80\xA4`\x01\x90V[\x90\x81` \x91\x03\x12a\x03GWQ\x90V[\x80T\x82\x10\x15a\x18CW_R` _ \x90`\x02\x1B\x01\x90_\x90V[\x91\x90\x82\x01\x80\x92\x11a\x14\xE1WV[\x90\x91_\x92_[`\x01`\x01`\xA0\x1B\x03\x84\x16_\x81\x81R`\x13` R`@\x90 T\x82\x10\x15a\x1A\xB1W\x80_R`\x13` Ra\x1E\xA4\x82`@_ a\x1EDV[PT`\x01`\x01`\xA0\x1B\x03\x84\x81\x16\x91\x16\x14a\x1E\xC2W[P`\x01\x01a\x1EpV[`\x01\x91\x95a\x1E\xE8\x91_R`\x13` R\x82a\x1E\xDF\x88`@_ a\x1EDV[P\x01T\x90a\x1E]V[\x94\x90a\x1E\xB9V[a\x1E\xF7a \x19V[a\x1E\xFFa \x19V[`\x01\x7F\x9Bw\x9B\x17B-\r\xF9\"#\x01\x8B2\xB4\xD1\xFAF\xE0qr=h\x17\xE2Hm\0;\xEC\xC5_\0UV[\x80Q\x90`\x02\x82\x10\x15a\x1FcW` \x90\x81\x01Q`@\x80Q\x92\x83\x01\x93\x84R`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x82\x82\x01R\x81Ra\x1F]``\x82a\x08\xAFV[Q\x90 \x90V[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[\x90\x81;\x15a\x1F\xF8W_\x80Q` a!\x03\x839\x81Q\x91R\x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x84\x16\x90\x81\x17\x90\x91U\x7F\xBC|\xD7Z \xEE'\xFD\x9A\xDE\xBA\xB3 A\xF7U!M\xBCk\xFF\xA9\x0C\xC0\"[9\xDA.\\-;_\x80\xA2\x80Q\x15a\x1F\xE0Wa\x1F\xDD\x91a DV[PV[PP4a\x1F\xE9WV[c\xB3\x98\x97\x9F`\xE0\x1B_R`\x04_\xFD[PcL\x9C\x8C\xE3`\xE0\x1B_\x90\x81R`\x01`\x01`\xA0\x1B\x03\x91\x90\x91\x16`\x04R`$\x90\xFD[`\xFF_\x80Q` a!C\x839\x81Q\x91RT`@\x1C\x16\x15a 5WV[c\x1A\xFC\xD7\x9F`\xE3\x1B_R`\x04_\xFD[_\x80a\x16\x05\x93` \x81Q\x91\x01\x84Z\xF4=\x15a \x80W=\x91a d\x83a\x08\xF0V[\x92a r`@Q\x94\x85a\x08\xAFV[\x83R=_` \x85\x01>a \x84V[``\x91[\x90a \xA8WP\x80Q\x15a \x99W\x80Q\x90` \x01\xFD[c\xD6\xBD\xA2u`\xE0\x1B_R`\x04_\xFD[\x81Q\x15\x80a \xD9W[a \xB9WP\x90V[c\x99\x96\xB3\x15`\xE0\x1B_\x90\x81R`\x01`\x01`\xA0\x1B\x03\x91\x90\x91\x16`\x04R`$\x90\xFD[P\x80;\x15a \xB1V\xFE/\x87\x88\x11~~\xFF\x1D\x82\xE9&\xECyI\x01\xD1|x\x02JP'\t@0E@\xA73eo\r6\x08\x94\xA1;\xA1\xA3!\x06g\xC8(I-\xB9\x8D\xCA> v\xCC75\xA9 \xA3\xCAP]8+\xBC\x02\xDD{\xC7\xDE\xC4\xDC\xEE\xDD\xA7u\xE5\x8D\xD5A\xE0\x8A\x11llS\x81\\\x0B\xD0(\x19/{bh\0\xF0\xC5~\x16\x84\r\xF0@\xF1P\x88\xDC/\x81\xFE9\x1C9#\xBE\xC7>#\xA9f.\xFC\x9C\"\x9Cj\0\xA1dsolcC\0\x08\x1A\0\n",
    );
    /// The runtime bytecode of the contract, as deployed on the network.
    ///
    /// ```text
    ///0x60806040526004361015610015575b3661185257005b5f3560e01c806301ffc9a71461033057806305d64e381461032b5780630aa8b1101461032657806318056dc21461032157806319e82e611461031c578063248a9ca3146103175780632f2ff15d1461031257806332273f611461030d57806336568abe14610308578063453eccea1461030357806346d163aa146102fe5780634962f88f146102545780634de8addc146102f95780634e9c929a146102725780634f1ef286146102f45780635095af64146102ef57806352d1902d146102ea57806354de2320146102e55780635c975abb146102e0578063615d24de146102db57806366c36875146102ae57806372b5032d146102a957806375b238fc146102d657806377ab2cf3146102d15780637df92ada146102cc5780638a19c8bc146102c75780638a7fe60f146102c257806390837ff4146102bd57806391d14854146102b85780639494f426146102b357806396085673146102ae5780639722f4b9146102a95780639e870585146102a4578063a217fddf1461029f578063a457af3d1461029a578063a4b32de814610295578063a7fa6f9814610290578063aaf5eb681461028b578063ad3cb1cc14610286578063b54b2b9e14610281578063ba05bbf51461027c578063c07449e214610277578063c550d93814610272578063cbb6d6bd1461026d578063d27a6f0614610268578063d547741f14610263578063db8a173a1461025e578063e07dec2914610259578063e1a4521814610254578063f3c9b3111461024f5763f7cb789a0361000e5761134b565b61132e565b6107c1565b611261565b61123b565b61120a565b6111ed565b61106c565b610806565b610fd0565b610fb1565b610f8f565b610f31565b610f0f565b610ef3565b610eb9565b610d56565b610d3c565b610d1f565b610b11565b610ad0565b610cde565b610c83565b610c3f565b610bff565b610bda565b610bbd565b610b9b565b610b61565b610a7e565b610a3d565b610a21565b6109bb565b610981565b61090b565b6107dd565b610698565b61067c565b610638565b610614565b6105de565b6105b8565b61051c565b6104d0565b610421565b6103a1565b61034b565b6001600160e01b031981160361034757565b5f80fd5b3461034757602036600319011261034757602060043561036a81610335565b63ffffffff60e01b16637965db0b60e01b8114908115610390575b506040519015158152f35b6301ffc9a760e01b1490505f610385565b34610347575f3660031901126103475760206001600160401b035f5460801c16604051908152f35b600435906001600160a01b038216820361034757565b602435906001600160a01b038216820361034757565b602435906001600160401b038216820361034757565b600435906001600160401b038216820361034757565b346103475760403660031901126103475761046f61043d6103c9565b6104456103f5565b9060018060a01b03165f52604e60205260405f20906001600160401b03165f5260205260405f2090565b8054600182015460028301546003840154600490940154604080516001600160401b03808716825286831c81166020830152608096871c169181019190915260608101939093529282015260a081019290925260c082015260e090f35b0390f35b34610347575f366003190112610347576020604051612af88152f35b9181601f84011215610347578235916001600160401b038311610347576020808501948460051b01011161034757565b34610347576040366003190112610347576105356103c9565b6024356001600160401b038111610347576105549036906004016104ec565b9161055d6118ac565b61056683611373565b9161057460405193846108af565b838352602083019360051b81019036821161034757935b81851061059e5761059c8484611975565b005b6020809186356105ad81610335565b81520194019361058b565b346103475760203660031901126103475760206105d660043561138a565b604051908152f35b346103475760403660031901126103475761059c6004356105fd6103df565b9061060f61060a8261138a565b61191b565b611d00565b34610347575f36600319011261034757602061ffff60015460801c16604051908152f35b34610347576040366003190112610347576004356106546103df565b336001600160a01b0382160361066d5761059c91611d95565b63334bd91960e11b5f5260045ffd5b34610347575f366003190112610347576020604051613e808152f35b34610347576020366003190112610347576106b16103c9565b6106b96118ac565b604051630dc4b72f60e31b8152906001600160a01b038116905f83600481855afa9081156107b6575f91610718575b906106f291611975565b7f4d3c30f5993f1922a779345a0f7ec1a170f1e52e9d230824f9c17e63596c906d5f80a2005b90503d805f853e61072981856108af565b830192602081850312610347578051906001600160401b038211610347570183601f820112156103475780519361075f85611373565b9161076d60405193846108af565b85835260208084019660051b82010191821161034757602001945b81861061079c5750929350839250906106e8565b6020809187516107ab81610335565b815201950194610788565b6040513d5f823e3d90fd5b34610347575f3660031901126103475760206040516127108152f35b34610347575f3660031901126103475760206001600160401b0360015460401c16604051908152f35b346103475760403660031901126103475760206001600160401b0361085661082c61040b565b826108356103df565b91165f526051845260405f209060018060a01b03165f5260205260405f2090565b5416604051908152f35b634e487b7160e01b5f52604160045260245ffd5b60e081019081106001600160401b0382111761088f57604052565b610860565b604081019081106001600160401b0382111761088f57604052565b90601f801991011681019081106001600160401b0382111761088f57604052565b604051906108df6040836108af565b565b604051906108df60c0836108af565b6001600160401b03811161088f57601f01601f191660200190565b60403660031901126103475761091f6103c9565b602435906001600160401b03821161034757366023830112156103475781600401359061094b826108f0565b9161095960405193846108af565b8083523660248286010111610347576020815f92602461059c970183870137840101526113a8565b34610347575f3660031901126103475760206040517f12b42e8a160f6064dc959c6f251e3af0750ad213dbecf573b4710d67d6c28e398152f35b34610347575f366003190112610347577f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03163003610a125760206040515f805160206121038339815191528152f35b63703e46dd60e11b5f5260045ffd5b34610347575f366003190112610347576020604051612ee08152f35b34610347575f36600319011261034757602060ff7fcd5ed15c6e187e77e9aee88184c21f4f2182ab5827cb3b7e07fbedcd63f0330054166040519015158152f35b34610347576020366003190112610347576001600160a01b03610a9f6103c9565b165f52600f60205260405f205480155f14610ac857506020670de0b6b3a7640000604051908152f35b6020906105d6565b34610347576020366003190112610347576001600160a01b03610af16103c9565b165f52604f60205260206001600160401b0360405f205416604051908152f35b346103475760403660031901126103475760206001600160401b03610856610b3761040b565b82610b406103df565b91165f526050845260405f209060018060a01b03165f5260205260405f2090565b34610347575f3660031901126103475760206040517fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c217758152f35b34610347575f36600319011261034757602060ff600554166040519015158152f35b34610347575f366003190112610347576020604051624f1a008152f35b34610347575f3660031901126103475760206001600160401b035f5416604051908152f35b34610347576020366003190112610347576001600160a01b03610c206103c9565b165f526006602052602060018060a01b0360405f205416604051908152f35b3461034757602036600319011261034757600435610c5c81610335565b63ffffffff60e01b165f52601e602052602060018060a01b0360405f205416604051908152f35b3461034757604036600319011261034757602060ff610cd2600435610ca66103df565b905f525f80516020612123833981519152845260405f209060018060a01b03165f5260205260405f2090565b54166040519015158152f35b3461034757606036600319011261034757610cf76103c9565b610cff6103f5565b906044356001600160a01b0381168103610347576020926105d6926114f9565b34610347575f36600319011261034757602060405162278d008152f35b34610347575f3660031901126103475760206040515f8152f35b34610347576040366003190112610347576104cc610dd9610d756103c9565b610d7d6103f5565b905f60c0604051610d8d81610874565b8281528260208201528260408201528260608201528260808201528260a0820152015260018060a01b03165f52604e60205260405f20906001600160401b03165f5260205260405f2090565b600460405191610de883610874565b80546001600160401b038082168552604082901c166020850152610e2a90610e1a905b60801c6001600160401b031690565b6001600160401b03166040850152565b6001810154606084015260028101546080840152600381015460a0840152015460c08201526040519182918291909160c08060e08301946001600160401b0381511684526001600160401b0360208201511660208501526001600160401b036040820151166040850152606081015160608501526080810151608085015260a081015160a08501520151910152565b34610347575f3660031901126103475760206040517fb1fadd3142ab2ad7f1337ea4d97112bcc8337fc11ce5b20cb04ad038adf998198152f35b34610347575f3660031901126103475760206040516132c88152f35b34610347575f366003190112610347576020604051670de0b6b3a76400008152f35b34610347575f366003190112610347576040805190610f5081836108af565b600582526020820191640352e302e360dc1b83528151928391602083525180918160208501528484015e5f828201840152601f01601f19168101030190f35b34610347575f36600319011261034757602060ff600754166040519015158152f35b34610347575f3660031901126103475760205f5460c01c604051908152f35b34610347576040366003190112610347576104cc611035610fef61040b565b6001600160401b03610fff6103df565b915f602060405161100f81610894565b8281520152165f52600e60205260405f209060018060a01b03165f5260205260405f2090565b60016040519161104483610894565b8054835201546020820152604051918291829190916020806040830194805184520151910152565b34610347576080366003190112610347576110856103c9565b6024359060643560443561ffff82168203610347575f8051602061214383398151915254936001600160401b036110cb60ff604088901c1615966001600160401b031690565b16801590816111e5575b60011490816111db575b1590816111d2575b506111c35761112a938561112160016001600160401b03195f805160206121438339815191525416175f8051602061214383398151915255565b61118957611619565b61113057005b61115a60ff60401b195f8051602061214383398151915254165f8051602061214383398151915255565b604051600181527fc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d290602090a1005b6111be6801000000000000000060ff60401b195f805160206121438339815191525416175f8051602061214383398151915255565b611619565b63f92ee8a960e01b5f5260045ffd5b9050155f6110e7565b303b1591506110df565b8691506110d5565b34610347575f3660031901126103475760206040516276a7008152f35b346103475760403660031901126103475761059c6004356112296103df565b9061123661060a8261138a565b611d95565b34610347575f3660031901126103475760206001600160401b0360015416604051908152f35b34610347576020366003190112610347576004356001600160401b038111610347576112919036906004016104ec565b6112996118ac565b5f5b8181106112a457005b806112b26001928486611833565b356112bc81610335565b6001600160e01b0319165f908152601e6020526040902080546001600160a01b03191690556113046112f76112f2838688611833565b611848565b6001600160e01b03191690565b7fbeb27701828f515b03069d44da6519b6c491da13ef1ca7082e619959d1f48ddb5f80a20161129b565b34610347575f36600319011261034757602060405162ed4e008152f35b34610347575f3660031901126103475760206001600160401b035f5460401c16604051908152f35b6001600160401b03811161088f5760051b60200190565b5f525f80516020612123833981519152602052600160405f20015490565b90916001600160a01b037f00000000000000000000000000000000000000000000000000000000000000001630811490811561149e575b50610a12576113ec6118ac565b6040516352d1902d60e01b8152926020846004816001600160a01b0387165afa5f948161146d575b5061143857634c9c8ce360e01b5f526001600160a01b03831660045260245ffd5b5ffd5b90915f805160206121038339815191528403611459576108df929350611f77565b632a87526960e21b5f52600484905260245ffd5b61149091955060203d602011611497575b61148881836108af565b810190611e35565b935f611414565b503d61147e565b5f80516020612103833981519152546001600160a01b0316141590505f6113df565b634e487b7160e01b5f52601160045260245ffd5b919082039182116114e157565b6114c0565b818102929181159184041417156114e157565b9291909261152c5f9460018060a01b0383165f52604e60205260405f20906001600160401b03165f5260205260405f2090565b906040519261153a84610874565b82546001600160401b038082168652604082901c1660208601526115719061156190610e0b565b6001600160401b03166040860152565b600183015460608501526001600160401b036115b660028501549560808101968752600460038701549660a08301978852015460c0820152516001600160401b031690565b161561161057906115c691611e6a565b91821561160857519051908181116115dd57505050565b6116059394506115f792916115f1916114d4565b906114e6565b670de0b6b3a7640000900490565b90565b505f93505050565b505f9450505050565b9061170c61179694936116b261176394611631612019565b611639612019565b611641612019565b611649612019565b60ff197fcd5ed15c6e187e77e9aee88184c21f4f2182ab5827cb3b7e07fbedcd63f0330054167fcd5ed15c6e187e77e9aee88184c21f4f2182ab5827cb3b7e07fbedcd63f0330055611699611eef565b6116a281611ae2565b506116ac81611b7e565b50611c3f565b506116cc6116be6108d0565b5f81525f6020820152611f25565b906116d56108e1565b6001815293602085015260408401525f60608401525f60808401526116fe60a084016127109052565b5f52600260205260405f2090565b90600561ffff60a081938051151560ff801988541691151516178655602081015160018701556040810151600287015560608101516003870155608081015160048701550151169201911661ffff19825416179055565b611775600160ff196005541617600555565b6001805461ffff60801b191660809290921b61ffff60801b16919091179055565b6117ac60016001600160401b03195f5416175f55565b6117cf695460000000000000000067ffffffffffffffff60401b195f5416175f55565b5f80546001600160c01b0316600760c21b1790556117fb601c6001600160401b03196001541617600155565b6108df6838000000000000000067ffffffffffffffff60401b196001541617600155565b634e487b7160e01b5f52603260045260245ffd5b91908110156118435760051b0190565b61181f565b3561160581610335565b5f80356001600160e01b031916808252601e6020526040909120546001600160a01b031690811561189a575f8083368280378136915af43d5f803e15611896573d5ff35b3d5ffd5b63c2a825f560e01b5f5260045260245ffd5b335f9081527fb16e88c42fd4e48df2dd6a2eabd6bc9aec654ec170056b470819f8892cc6431c602052604090205460ff16156118e457565b63e2517d3f60e01b5f52336004527fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c2177560245260445ffd5b5f8181525f805160206121238339815191526020908152604080832033845290915290205460ff161561194b5750565b63e2517d3f60e01b5f523360045260245260445ffd5b80518210156118435760209160051b010190565b9091906001600160a01b038116908115611ad357803b15611ab8575f5b8451811015611ab1576119e06119d36119bc6119ae8489611961565b516001600160e01b03191690565b63ffffffff60e01b165f52601e60205260405f2090565b546001600160a01b031690565b6001600160a01b03811680151590859082611aa6575b5050611a6e575080611a3383611a146119bc6119ae6001968b611961565b80546001600160a01b0319166001600160a01b03909216919091179055565b83611a446112f76119ae848a611961565b7f12557f25e458d9682d7c959b5a960bc9332e8b7af1120b54a333bfc1ff282b395f80a301611992565b611a7e6119ae6114359388611961565b6310ae11a960e31b5f526001600160e01b0319166004526001600160a01b0316602452604490565b14159050845f6119f6565b5050509050565b6322a2d07b60e21b5f526001600160a01b031660045260245ffd5b63d92e233d60e01b5f5260045ffd5b6001600160a01b0381165f9081527fb7db2dd08fcb62d0c9e08c51941cae53c267786a0b75803fb7960902fc8ef97d602052604090205460ff16611b79576001600160a01b03165f8181527fb7db2dd08fcb62d0c9e08c51941cae53c267786a0b75803fb7960902fc8ef97d60205260408120805460ff191660011790553391905f805160206120e38339815191528180a4600190565b505f90565b6001600160a01b0381165f9081527fb16e88c42fd4e48df2dd6a2eabd6bc9aec654ec170056b470819f8892cc6431c602052604090205460ff16611b79576001600160a01b0381165f9081527fb16e88c42fd4e48df2dd6a2eabd6bc9aec654ec170056b470819f8892cc6431c60205260409020805460ff1916600117905533906001600160a01b03167fa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c217755f805160206120e38339815191525f80a4600190565b6001600160a01b0381165f9081527f5bc841a6d925a620866922bada36d16da3dcc9d52290519ea1126e5ca2372139602052604090205460ff16611b79576001600160a01b0381165f9081527f5bc841a6d925a620866922bada36d16da3dcc9d52290519ea1126e5ca237213960205260409020805460ff1916600117905533906001600160a01b03167fb1fadd3142ab2ad7f1337ea4d97112bcc8337fc11ce5b20cb04ad038adf998195f805160206120e38339815191525f80a4600190565b5f8181525f80516020612123833981519152602090815260408083206001600160a01b038616845290915290205460ff16611d8f575f8181525f80516020612123833981519152602090815260408083206001600160a01b03861684529091529020805460ff1916600117905533916001600160a01b0316905f805160206120e38339815191525f80a4600190565b50505f90565b5f8181525f80516020612123833981519152602090815260408083206001600160a01b038616845290915290205460ff1615611d8f575f8181525f80516020612123833981519152602090815260408083206001600160a01b03861684529091529020805460ff1916905533916001600160a01b0316907ff6391f5c32d9c69d2a47ea670b442974b53935d1edc7fd64eb21e047a839171b5f80a4600190565b90816020910312610347575190565b8054821015611843575f5260205f209060021b01905f90565b919082018092116114e157565b90915f925f5b6001600160a01b0384165f81815260136020526040902054821015611ab157805f526013602052611ea48260405f20611e44565b50546001600160a01b03848116911614611ec2575b50600101611e70565b60019195611ee8915f52601360205282611edf8860405f20611e44565b50015490611e5d565b9490611eb9565b611ef7612019565b611eff612019565b60017f9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f0055565b8051906002821015611f6357602090810151604080519283019384526001600160a01b03909116828201528152611f5d6060826108af565b51902090565b634e487b7160e01b5f52602160045260245ffd5b90813b15611ff8575f8051602061210383398151915280546001600160a01b0319166001600160a01b0384169081179091557fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b5f80a2805115611fe057611fdd91612044565b50565b505034611fe957565b63b398979f60e01b5f5260045ffd5b50634c9c8ce360e01b5f9081526001600160a01b0391909116600452602490fd5b60ff5f805160206121438339815191525460401c161561203557565b631afcd79f60e31b5f5260045ffd5b5f8061160593602081519101845af43d15612080573d91612064836108f0565b9261207260405194856108af565b83523d5f602085013e612084565b6060915b906120a8575080511561209957805190602001fd5b63d6bda27560e01b5f5260045ffd5b815115806120d9575b6120b9575090565b639996b31560e01b5f9081526001600160a01b0391909116600452602490fd5b50803b156120b156fe2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc02dd7bc7dec4dceedda775e58dd541e08a116c6c53815c0bd028192f7b626800f0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00a164736f6c634300081a000a
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static DEPLOYED_BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"`\x80`@R`\x046\x10\x15a\0\x15W[6a\x18RW\0[_5`\xE0\x1C\x80c\x01\xFF\xC9\xA7\x14a\x030W\x80c\x05\xD6N8\x14a\x03+W\x80c\n\xA8\xB1\x10\x14a\x03&W\x80c\x18\x05m\xC2\x14a\x03!W\x80c\x19\xE8.a\x14a\x03\x1CW\x80c$\x8A\x9C\xA3\x14a\x03\x17W\x80c//\xF1]\x14a\x03\x12W\x80c2'?a\x14a\x03\rW\x80c6V\x8A\xBE\x14a\x03\x08W\x80cE>\xCC\xEA\x14a\x03\x03W\x80cF\xD1c\xAA\x14a\x02\xFEW\x80cIb\xF8\x8F\x14a\x02TW\x80cM\xE8\xAD\xDC\x14a\x02\xF9W\x80cN\x9C\x92\x9A\x14a\x02rW\x80cO\x1E\xF2\x86\x14a\x02\xF4W\x80cP\x95\xAFd\x14a\x02\xEFW\x80cR\xD1\x90-\x14a\x02\xEAW\x80cT\xDE# \x14a\x02\xE5W\x80c\\\x97Z\xBB\x14a\x02\xE0W\x80ca]$\xDE\x14a\x02\xDBW\x80cf\xC3hu\x14a\x02\xAEW\x80cr\xB5\x03-\x14a\x02\xA9W\x80cu\xB28\xFC\x14a\x02\xD6W\x80cw\xAB,\xF3\x14a\x02\xD1W\x80c}\xF9*\xDA\x14a\x02\xCCW\x80c\x8A\x19\xC8\xBC\x14a\x02\xC7W\x80c\x8A\x7F\xE6\x0F\x14a\x02\xC2W\x80c\x90\x83\x7F\xF4\x14a\x02\xBDW\x80c\x91\xD1HT\x14a\x02\xB8W\x80c\x94\x94\xF4&\x14a\x02\xB3W\x80c\x96\x08Vs\x14a\x02\xAEW\x80c\x97\"\xF4\xB9\x14a\x02\xA9W\x80c\x9E\x87\x05\x85\x14a\x02\xA4W\x80c\xA2\x17\xFD\xDF\x14a\x02\x9FW\x80c\xA4W\xAF=\x14a\x02\x9AW\x80c\xA4\xB3-\xE8\x14a\x02\x95W\x80c\xA7\xFAo\x98\x14a\x02\x90W\x80c\xAA\xF5\xEBh\x14a\x02\x8BW\x80c\xAD<\xB1\xCC\x14a\x02\x86W\x80c\xB5K+\x9E\x14a\x02\x81W\x80c\xBA\x05\xBB\xF5\x14a\x02|W\x80c\xC0tI\xE2\x14a\x02wW\x80c\xC5P\xD98\x14a\x02rW\x80c\xCB\xB6\xD6\xBD\x14a\x02mW\x80c\xD2zo\x06\x14a\x02hW\x80c\xD5Gt\x1F\x14a\x02cW\x80c\xDB\x8A\x17:\x14a\x02^W\x80c\xE0}\xEC)\x14a\x02YW\x80c\xE1\xA4R\x18\x14a\x02TW\x80c\xF3\xC9\xB3\x11\x14a\x02OWc\xF7\xCBx\x9A\x03a\0\x0EWa\x13KV[a\x13.V[a\x07\xC1V[a\x12aV[a\x12;V[a\x12\nV[a\x11\xEDV[a\x10lV[a\x08\x06V[a\x0F\xD0V[a\x0F\xB1V[a\x0F\x8FV[a\x0F1V[a\x0F\x0FV[a\x0E\xF3V[a\x0E\xB9V[a\rVV[a\r<V[a\r\x1FV[a\x0B\x11V[a\n\xD0V[a\x0C\xDEV[a\x0C\x83V[a\x0C?V[a\x0B\xFFV[a\x0B\xDAV[a\x0B\xBDV[a\x0B\x9BV[a\x0BaV[a\n~V[a\n=V[a\n!V[a\t\xBBV[a\t\x81V[a\t\x0BV[a\x07\xDDV[a\x06\x98V[a\x06|V[a\x068V[a\x06\x14V[a\x05\xDEV[a\x05\xB8V[a\x05\x1CV[a\x04\xD0V[a\x04!V[a\x03\xA1V[a\x03KV[`\x01`\x01`\xE0\x1B\x03\x19\x81\x16\x03a\x03GWV[_\x80\xFD[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW` `\x045a\x03j\x81a\x035V[c\xFF\xFF\xFF\xFF`\xE0\x1B\x16cye\xDB\x0B`\xE0\x1B\x81\x14\x90\x81\x15a\x03\x90W[P`@Q\x90\x15\x15\x81R\xF3[c\x01\xFF\xC9\xA7`\xE0\x1B\x14\x90P_a\x03\x85V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03_T`\x80\x1C\x16`@Q\x90\x81R\xF3[`\x045\x90`\x01`\x01`\xA0\x1B\x03\x82\x16\x82\x03a\x03GWV[`$5\x90`\x01`\x01`\xA0\x1B\x03\x82\x16\x82\x03a\x03GWV[`$5\x90`\x01`\x01`@\x1B\x03\x82\x16\x82\x03a\x03GWV[`\x045\x90`\x01`\x01`@\x1B\x03\x82\x16\x82\x03a\x03GWV[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x04oa\x04=a\x03\xC9V[a\x04Ea\x03\xF5V[\x90`\x01\x80`\xA0\x1B\x03\x16_R`N` R`@_ \x90`\x01`\x01`@\x1B\x03\x16_R` R`@_ \x90V[\x80T`\x01\x82\x01T`\x02\x83\x01T`\x03\x84\x01T`\x04\x90\x94\x01T`@\x80Q`\x01`\x01`@\x1B\x03\x80\x87\x16\x82R\x86\x83\x1C\x81\x16` \x83\x01R`\x80\x96\x87\x1C\x16\x91\x81\x01\x91\x90\x91R``\x81\x01\x93\x90\x93R\x92\x82\x01R`\xA0\x81\x01\x92\x90\x92R`\xC0\x82\x01R`\xE0\x90\xF3[\x03\x90\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa*\xF8\x81R\xF3[\x91\x81`\x1F\x84\x01\x12\x15a\x03GW\x825\x91`\x01`\x01`@\x1B\x03\x83\x11a\x03GW` \x80\x85\x01\x94\x84`\x05\x1B\x01\x01\x11a\x03GWV[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x055a\x03\xC9V[`$5`\x01`\x01`@\x1B\x03\x81\x11a\x03GWa\x05T\x906\x90`\x04\x01a\x04\xECV[\x91a\x05]a\x18\xACV[a\x05f\x83a\x13sV[\x91a\x05t`@Q\x93\x84a\x08\xAFV[\x83\x83R` \x83\x01\x93`\x05\x1B\x81\x01\x906\x82\x11a\x03GW\x93[\x81\x85\x10a\x05\x9EWa\x05\x9C\x84\x84a\x19uV[\0[` \x80\x91\x865a\x05\xAD\x81a\x035V[\x81R\x01\x94\x01\x93a\x05\x8BV[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW` a\x05\xD6`\x045a\x13\x8AV[`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x05\x9C`\x045a\x05\xFDa\x03\xDFV[\x90a\x06\x0Fa\x06\n\x82a\x13\x8AV[a\x19\x1BV[a\x1D\0V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` a\xFF\xFF`\x01T`\x80\x1C\x16`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GW`\x045a\x06Ta\x03\xDFV[3`\x01`\x01`\xA0\x1B\x03\x82\x16\x03a\x06mWa\x05\x9C\x91a\x1D\x95V[c3K\xD9\x19`\xE1\x1B_R`\x04_\xFD[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa>\x80\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GWa\x06\xB1a\x03\xC9V[a\x06\xB9a\x18\xACV[`@Qc\r\xC4\xB7/`\xE3\x1B\x81R\x90`\x01`\x01`\xA0\x1B\x03\x81\x16\x90_\x83`\x04\x81\x85Z\xFA\x90\x81\x15a\x07\xB6W_\x91a\x07\x18W[\x90a\x06\xF2\x91a\x19uV[\x7FM<0\xF5\x99?\x19\"\xA7y4Z\x0F~\xC1\xA1p\xF1\xE5.\x9D#\x08$\xF9\xC1~cYl\x90m_\x80\xA2\0[\x90P=\x80_\x85>a\x07)\x81\x85a\x08\xAFV[\x83\x01\x92` \x81\x85\x03\x12a\x03GW\x80Q\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03GW\x01\x83`\x1F\x82\x01\x12\x15a\x03GW\x80Q\x93a\x07_\x85a\x13sV[\x91a\x07m`@Q\x93\x84a\x08\xAFV[\x85\x83R` \x80\x84\x01\x96`\x05\x1B\x82\x01\x01\x91\x82\x11a\x03GW` \x01\x94[\x81\x86\x10a\x07\x9CWP\x92\x93P\x83\x92P\x90a\x06\xE8V[` \x80\x91\x87Qa\x07\xAB\x81a\x035V[\x81R\x01\x95\x01\x94a\x07\x88V[`@Q=_\x82>=\x90\xFD[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa'\x10\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03`\x01T`@\x1C\x16`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03a\x08Va\x08,a\x04\x0BV[\x82a\x085a\x03\xDFV[\x91\x16_R`Q\x84R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ \x90V[T\x16`@Q\x90\x81R\xF3[cNH{q`\xE0\x1B_R`A`\x04R`$_\xFD[`\xE0\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x08\x8FW`@RV[a\x08`V[`@\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x08\x8FW`@RV[\x90`\x1F\x80\x19\x91\x01\x16\x81\x01\x90\x81\x10`\x01`\x01`@\x1B\x03\x82\x11\x17a\x08\x8FW`@RV[`@Q\x90a\x08\xDF`@\x83a\x08\xAFV[V[`@Q\x90a\x08\xDF`\xC0\x83a\x08\xAFV[`\x01`\x01`@\x1B\x03\x81\x11a\x08\x8FW`\x1F\x01`\x1F\x19\x16` \x01\x90V[`@6`\x03\x19\x01\x12a\x03GWa\t\x1Fa\x03\xC9V[`$5\x90`\x01`\x01`@\x1B\x03\x82\x11a\x03GW6`#\x83\x01\x12\x15a\x03GW\x81`\x04\x015\x90a\tK\x82a\x08\xF0V[\x91a\tY`@Q\x93\x84a\x08\xAFV[\x80\x83R6`$\x82\x86\x01\x01\x11a\x03GW` \x81_\x92`$a\x05\x9C\x97\x01\x83\x87\x017\x84\x01\x01Ra\x13\xA8V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Q\x7F\x12\xB4.\x8A\x16\x0F`d\xDC\x95\x9Co%\x1E:\xF0u\n\xD2\x13\xDB\xEC\xF5s\xB4q\rg\xD6\xC2\x8E9\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\x01`\x01`\xA0\x1B\x03\x160\x03a\n\x12W` `@Q_\x80Q` a!\x03\x839\x81Q\x91R\x81R\xF3[cp>F\xDD`\xE1\x1B_R`\x04_\xFD[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa.\xE0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\xFF\x7F\xCD^\xD1\\n\x18~w\xE9\xAE\xE8\x81\x84\xC2\x1FO!\x82\xABX'\xCB;~\x07\xFB\xED\xCDc\xF03\0T\x16`@Q\x90\x15\x15\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x01`\x01`\xA0\x1B\x03a\n\x9Fa\x03\xC9V[\x16_R`\x0F` R`@_ T\x80\x15_\x14a\n\xC8WP` g\r\xE0\xB6\xB3\xA7d\0\0`@Q\x90\x81R\xF3[` \x90a\x05\xD6V[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x01`\x01`\xA0\x1B\x03a\n\xF1a\x03\xC9V[\x16_R`O` R` `\x01`\x01`@\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03a\x08Va\x0B7a\x04\x0BV[\x82a\x0B@a\x03\xDFV[\x91\x16_R`P\x84R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ \x90V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Q\x7F\xA4\x98\x07 \\\xE4\xD3U\t.\xF5\xA8\xA1\x8FV\xE8\x91<\xF4\xA2\x01\xFB\xE2\x87\x82[\tV\x93\xC2\x17u\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\xFF`\x05T\x16`@Q\x90\x15\x15\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@QbO\x1A\0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03_T\x16`@Q\x90\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x01`\x01`\xA0\x1B\x03a\x0C a\x03\xC9V[\x16_R`\x06` R` `\x01\x80`\xA0\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x045a\x0C\\\x81a\x035V[c\xFF\xFF\xFF\xFF`\xE0\x1B\x16_R`\x1E` R` `\x01\x80`\xA0\x1B\x03`@_ T\x16`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GW` `\xFFa\x0C\xD2`\x045a\x0C\xA6a\x03\xDFV[\x90_R_\x80Q` a!#\x839\x81Q\x91R\x84R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ \x90V[T\x16`@Q\x90\x15\x15\x81R\xF3[4a\x03GW``6`\x03\x19\x01\x12a\x03GWa\x0C\xF7a\x03\xC9V[a\x0C\xFFa\x03\xF5V[\x90`D5`\x01`\x01`\xA0\x1B\x03\x81\x16\x81\x03a\x03GW` \x92a\x05\xD6\x92a\x14\xF9V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qb'\x8D\0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Q_\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x04\xCCa\r\xD9a\rua\x03\xC9V[a\r}a\x03\xF5V[\x90_`\xC0`@Qa\r\x8D\x81a\x08tV[\x82\x81R\x82` \x82\x01R\x82`@\x82\x01R\x82``\x82\x01R\x82`\x80\x82\x01R\x82`\xA0\x82\x01R\x01R`\x01\x80`\xA0\x1B\x03\x16_R`N` R`@_ \x90`\x01`\x01`@\x1B\x03\x16_R` R`@_ \x90V[`\x04`@Q\x91a\r\xE8\x83a\x08tV[\x80T`\x01`\x01`@\x1B\x03\x80\x82\x16\x85R`@\x82\x90\x1C\x16` \x85\x01Ra\x0E*\x90a\x0E\x1A\x90[`\x80\x1C`\x01`\x01`@\x1B\x03\x16\x90V[`\x01`\x01`@\x1B\x03\x16`@\x85\x01RV[`\x01\x81\x01T``\x84\x01R`\x02\x81\x01T`\x80\x84\x01R`\x03\x81\x01T`\xA0\x84\x01R\x01T`\xC0\x82\x01R`@Q\x91\x82\x91\x82\x91\x90\x91`\xC0\x80`\xE0\x83\x01\x94`\x01`\x01`@\x1B\x03\x81Q\x16\x84R`\x01`\x01`@\x1B\x03` \x82\x01Q\x16` \x85\x01R`\x01`\x01`@\x1B\x03`@\x82\x01Q\x16`@\x85\x01R``\x81\x01Q``\x85\x01R`\x80\x81\x01Q`\x80\x85\x01R`\xA0\x81\x01Q`\xA0\x85\x01R\x01Q\x91\x01RV[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Q\x7F\xB1\xFA\xDD1B\xAB*\xD7\xF13~\xA4\xD9q\x12\xBC\xC83\x7F\xC1\x1C\xE5\xB2\x0C\xB0J\xD08\xAD\xF9\x98\x19\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qa2\xC8\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qg\r\xE0\xB6\xB3\xA7d\0\0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW`@\x80Q\x90a\x0FP\x81\x83a\x08\xAFV[`\x05\x82R` \x82\x01\x91d\x03R\xE3\x02\xE3`\xDC\x1B\x83R\x81Q\x92\x83\x91` \x83RQ\x80\x91\x81` \x85\x01R\x84\x84\x01^_\x82\x82\x01\x84\x01R`\x1F\x01`\x1F\x19\x16\x81\x01\x03\x01\x90\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\xFF`\x07T\x16`@Q\x90\x15\x15\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` _T`\xC0\x1C`@Q\x90\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x04\xCCa\x105a\x0F\xEFa\x04\x0BV[`\x01`\x01`@\x1B\x03a\x0F\xFFa\x03\xDFV[\x91_` `@Qa\x10\x0F\x81a\x08\x94V[\x82\x81R\x01R\x16_R`\x0E` R`@_ \x90`\x01\x80`\xA0\x1B\x03\x16_R` R`@_ \x90V[`\x01`@Q\x91a\x10D\x83a\x08\x94V[\x80T\x83R\x01T` \x82\x01R`@Q\x91\x82\x91\x82\x91\x90\x91` \x80`@\x83\x01\x94\x80Q\x84R\x01Q\x91\x01RV[4a\x03GW`\x806`\x03\x19\x01\x12a\x03GWa\x10\x85a\x03\xC9V[`$5\x90`d5`D5a\xFF\xFF\x82\x16\x82\x03a\x03GW_\x80Q` a!C\x839\x81Q\x91RT\x93`\x01`\x01`@\x1B\x03a\x10\xCB`\xFF`@\x88\x90\x1C\x16\x15\x96`\x01`\x01`@\x1B\x03\x16\x90V[\x16\x80\x15\x90\x81a\x11\xE5W[`\x01\x14\x90\x81a\x11\xDBW[\x15\x90\x81a\x11\xD2W[Pa\x11\xC3Wa\x11*\x93\x85a\x11!`\x01`\x01`\x01`@\x1B\x03\x19_\x80Q` a!C\x839\x81Q\x91RT\x16\x17_\x80Q` a!C\x839\x81Q\x91RUV[a\x11\x89Wa\x16\x19V[a\x110W\0[a\x11Z`\xFF`@\x1B\x19_\x80Q` a!C\x839\x81Q\x91RT\x16_\x80Q` a!C\x839\x81Q\x91RUV[`@Q`\x01\x81R\x7F\xC7\xF5\x05\xB2\xF3q\xAE!u\xEEI\x13\xF4I\x9E\x1F&3\xA7\xB5\x93c!\xEE\xD1\xCD\xAE\xB6\x11Q\x81\xD2\x90` \x90\xA1\0[a\x11\xBEh\x01\0\0\0\0\0\0\0\0`\xFF`@\x1B\x19_\x80Q` a!C\x839\x81Q\x91RT\x16\x17_\x80Q` a!C\x839\x81Q\x91RUV[a\x16\x19V[c\xF9.\xE8\xA9`\xE0\x1B_R`\x04_\xFD[\x90P\x15_a\x10\xE7V[0;\x15\x91Pa\x10\xDFV[\x86\x91Pa\x10\xD5V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qbv\xA7\0\x81R\xF3[4a\x03GW`@6`\x03\x19\x01\x12a\x03GWa\x05\x9C`\x045a\x12)a\x03\xDFV[\x90a\x126a\x06\n\x82a\x13\x8AV[a\x1D\x95V[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03`\x01T\x16`@Q\x90\x81R\xF3[4a\x03GW` 6`\x03\x19\x01\x12a\x03GW`\x045`\x01`\x01`@\x1B\x03\x81\x11a\x03GWa\x12\x91\x906\x90`\x04\x01a\x04\xECV[a\x12\x99a\x18\xACV[_[\x81\x81\x10a\x12\xA4W\0[\x80a\x12\xB2`\x01\x92\x84\x86a\x183V[5a\x12\xBC\x81a\x035V[`\x01`\x01`\xE0\x1B\x03\x19\x16_\x90\x81R`\x1E` R`@\x90 \x80T`\x01`\x01`\xA0\x1B\x03\x19\x16\x90Ua\x13\x04a\x12\xF7a\x12\xF2\x83\x86\x88a\x183V[a\x18HV[`\x01`\x01`\xE0\x1B\x03\x19\x16\x90V[\x7F\xBE\xB2w\x01\x82\x8FQ[\x03\x06\x9DD\xDAe\x19\xB6\xC4\x91\xDA\x13\xEF\x1C\xA7\x08.a\x99Y\xD1\xF4\x8D\xDB_\x80\xA2\x01a\x12\x9BV[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `@Qb\xEDN\0\x81R\xF3[4a\x03GW_6`\x03\x19\x01\x12a\x03GW` `\x01`\x01`@\x1B\x03_T`@\x1C\x16`@Q\x90\x81R\xF3[`\x01`\x01`@\x1B\x03\x81\x11a\x08\x8FW`\x05\x1B` \x01\x90V[_R_\x80Q` a!#\x839\x81Q\x91R` R`\x01`@_ \x01T\x90V[\x90\x91`\x01`\x01`\xA0\x1B\x03\x7F\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x160\x81\x14\x90\x81\x15a\x14\x9EW[Pa\n\x12Wa\x13\xECa\x18\xACV[`@QcR\xD1\x90-`\xE0\x1B\x81R\x92` \x84`\x04\x81`\x01`\x01`\xA0\x1B\x03\x87\x16Z\xFA_\x94\x81a\x14mW[Pa\x148WcL\x9C\x8C\xE3`\xE0\x1B_R`\x01`\x01`\xA0\x1B\x03\x83\x16`\x04R`$_\xFD[_\xFD[\x90\x91_\x80Q` a!\x03\x839\x81Q\x91R\x84\x03a\x14YWa\x08\xDF\x92\x93Pa\x1FwV[c*\x87Ri`\xE2\x1B_R`\x04\x84\x90R`$_\xFD[a\x14\x90\x91\x95P` =` \x11a\x14\x97W[a\x14\x88\x81\x83a\x08\xAFV[\x81\x01\x90a\x1E5V[\x93_a\x14\x14V[P=a\x14~V[_\x80Q` a!\x03\x839\x81Q\x91RT`\x01`\x01`\xA0\x1B\x03\x16\x14\x15\x90P_a\x13\xDFV[cNH{q`\xE0\x1B_R`\x11`\x04R`$_\xFD[\x91\x90\x82\x03\x91\x82\x11a\x14\xE1WV[a\x14\xC0V[\x81\x81\x02\x92\x91\x81\x15\x91\x84\x04\x14\x17\x15a\x14\xE1WV[\x92\x91\x90\x92a\x15,_\x94`\x01\x80`\xA0\x1B\x03\x83\x16_R`N` R`@_ \x90`\x01`\x01`@\x1B\x03\x16_R` R`@_ \x90V[\x90`@Q\x92a\x15:\x84a\x08tV[\x82T`\x01`\x01`@\x1B\x03\x80\x82\x16\x86R`@\x82\x90\x1C\x16` \x86\x01Ra\x15q\x90a\x15a\x90a\x0E\x0BV[`\x01`\x01`@\x1B\x03\x16`@\x86\x01RV[`\x01\x83\x01T``\x85\x01R`\x01`\x01`@\x1B\x03a\x15\xB6`\x02\x85\x01T\x95`\x80\x81\x01\x96\x87R`\x04`\x03\x87\x01T\x96`\xA0\x83\x01\x97\x88R\x01T`\xC0\x82\x01RQ`\x01`\x01`@\x1B\x03\x16\x90V[\x16\x15a\x16\x10W\x90a\x15\xC6\x91a\x1EjV[\x91\x82\x15a\x16\x08WQ\x90Q\x90\x81\x81\x11a\x15\xDDWPPPV[a\x16\x05\x93\x94Pa\x15\xF7\x92\x91a\x15\xF1\x91a\x14\xD4V[\x90a\x14\xE6V[g\r\xE0\xB6\xB3\xA7d\0\0\x90\x04\x90V[\x90V[P_\x93PPPV[P_\x94PPPPV[\x90a\x17\x0Ca\x17\x96\x94\x93a\x16\xB2a\x17c\x94a\x161a \x19V[a\x169a \x19V[a\x16Aa \x19V[a\x16Ia \x19V[`\xFF\x19\x7F\xCD^\xD1\\n\x18~w\xE9\xAE\xE8\x81\x84\xC2\x1FO!\x82\xABX'\xCB;~\x07\xFB\xED\xCDc\xF03\0T\x16\x7F\xCD^\xD1\\n\x18~w\xE9\xAE\xE8\x81\x84\xC2\x1FO!\x82\xABX'\xCB;~\x07\xFB\xED\xCDc\xF03\0Ua\x16\x99a\x1E\xEFV[a\x16\xA2\x81a\x1A\xE2V[Pa\x16\xAC\x81a\x1B~V[Pa\x1C?V[Pa\x16\xCCa\x16\xBEa\x08\xD0V[_\x81R_` \x82\x01Ra\x1F%V[\x90a\x16\xD5a\x08\xE1V[`\x01\x81R\x93` \x85\x01R`@\x84\x01R_``\x84\x01R_`\x80\x84\x01Ra\x16\xFE`\xA0\x84\x01a'\x10\x90RV[_R`\x02` R`@_ \x90V[\x90`\x05a\xFF\xFF`\xA0\x81\x93\x80Q\x15\x15`\xFF\x80\x19\x88T\x16\x91\x15\x15\x16\x17\x86U` \x81\x01Q`\x01\x87\x01U`@\x81\x01Q`\x02\x87\x01U``\x81\x01Q`\x03\x87\x01U`\x80\x81\x01Q`\x04\x87\x01U\x01Q\x16\x92\x01\x91\x16a\xFF\xFF\x19\x82T\x16\x17\x90UV[a\x17u`\x01`\xFF\x19`\x05T\x16\x17`\x05UV[`\x01\x80Ta\xFF\xFF`\x80\x1B\x19\x16`\x80\x92\x90\x92\x1Ba\xFF\xFF`\x80\x1B\x16\x91\x90\x91\x17\x90UV[a\x17\xAC`\x01`\x01`\x01`@\x1B\x03\x19_T\x16\x17_UV[a\x17\xCFiT`\0\0\0\0\0\0\0\0g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF`@\x1B\x19_T\x16\x17_UV[_\x80T`\x01`\x01`\xC0\x1B\x03\x16`\x07`\xC2\x1B\x17\x90Ua\x17\xFB`\x1C`\x01`\x01`@\x1B\x03\x19`\x01T\x16\x17`\x01UV[a\x08\xDFh8\0\0\0\0\0\0\0\0g\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF`@\x1B\x19`\x01T\x16\x17`\x01UV[cNH{q`\xE0\x1B_R`2`\x04R`$_\xFD[\x91\x90\x81\x10\x15a\x18CW`\x05\x1B\x01\x90V[a\x18\x1FV[5a\x16\x05\x81a\x035V[_\x805`\x01`\x01`\xE0\x1B\x03\x19\x16\x80\x82R`\x1E` R`@\x90\x91 T`\x01`\x01`\xA0\x1B\x03\x16\x90\x81\x15a\x18\x9AW_\x80\x836\x82\x807\x816\x91Z\xF4=_\x80>\x15a\x18\x96W=_\xF3[=_\xFD[c\xC2\xA8%\xF5`\xE0\x1B_R`\x04R`$_\xFD[3_\x90\x81R\x7F\xB1n\x88\xC4/\xD4\xE4\x8D\xF2\xDDj.\xAB\xD6\xBC\x9A\xECeN\xC1p\x05kG\x08\x19\xF8\x89,\xC6C\x1C` R`@\x90 T`\xFF\x16\x15a\x18\xE4WV[c\xE2Q}?`\xE0\x1B_R3`\x04R\x7F\xA4\x98\x07 \\\xE4\xD3U\t.\xF5\xA8\xA1\x8FV\xE8\x91<\xF4\xA2\x01\xFB\xE2\x87\x82[\tV\x93\xC2\x17u`$R`D_\xFD[_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 3\x84R\x90\x91R\x90 T`\xFF\x16\x15a\x19KWPV[c\xE2Q}?`\xE0\x1B_R3`\x04R`$R`D_\xFD[\x80Q\x82\x10\x15a\x18CW` \x91`\x05\x1B\x01\x01\x90V[\x90\x91\x90`\x01`\x01`\xA0\x1B\x03\x81\x16\x90\x81\x15a\x1A\xD3W\x80;\x15a\x1A\xB8W_[\x84Q\x81\x10\x15a\x1A\xB1Wa\x19\xE0a\x19\xD3a\x19\xBCa\x19\xAE\x84\x89a\x19aV[Q`\x01`\x01`\xE0\x1B\x03\x19\x16\x90V[c\xFF\xFF\xFF\xFF`\xE0\x1B\x16_R`\x1E` R`@_ \x90V[T`\x01`\x01`\xA0\x1B\x03\x16\x90V[`\x01`\x01`\xA0\x1B\x03\x81\x16\x80\x15\x15\x90\x85\x90\x82a\x1A\xA6W[PPa\x1AnWP\x80a\x1A3\x83a\x1A\x14a\x19\xBCa\x19\xAE`\x01\x96\x8Ba\x19aV[\x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x90\x92\x16\x91\x90\x91\x17\x90UV[\x83a\x1ADa\x12\xF7a\x19\xAE\x84\x8Aa\x19aV[\x7F\x12U\x7F%\xE4X\xD9h-|\x95\x9BZ\x96\x0B\xC93.\x8Bz\xF1\x12\x0BT\xA33\xBF\xC1\xFF(+9_\x80\xA3\x01a\x19\x92V[a\x1A~a\x19\xAEa\x145\x93\x88a\x19aV[c\x10\xAE\x11\xA9`\xE3\x1B_R`\x01`\x01`\xE0\x1B\x03\x19\x16`\x04R`\x01`\x01`\xA0\x1B\x03\x16`$R`D\x90V[\x14\x15\x90P\x84_a\x19\xF6V[PPP\x90PV[c\"\xA2\xD0{`\xE2\x1B_R`\x01`\x01`\xA0\x1B\x03\x16`\x04R`$_\xFD[c\xD9.#=`\xE0\x1B_R`\x04_\xFD[`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F\xB7\xDB-\xD0\x8F\xCBb\xD0\xC9\xE0\x8CQ\x94\x1C\xAES\xC2gxj\x0Bu\x80?\xB7\x96\t\x02\xFC\x8E\xF9}` R`@\x90 T`\xFF\x16a\x1ByW`\x01`\x01`\xA0\x1B\x03\x16_\x81\x81R\x7F\xB7\xDB-\xD0\x8F\xCBb\xD0\xC9\xE0\x8CQ\x94\x1C\xAES\xC2gxj\x0Bu\x80?\xB7\x96\t\x02\xFC\x8E\xF9}` R`@\x81 \x80T`\xFF\x19\x16`\x01\x17\x90U3\x91\x90_\x80Q` a \xE3\x839\x81Q\x91R\x81\x80\xA4`\x01\x90V[P_\x90V[`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F\xB1n\x88\xC4/\xD4\xE4\x8D\xF2\xDDj.\xAB\xD6\xBC\x9A\xECeN\xC1p\x05kG\x08\x19\xF8\x89,\xC6C\x1C` R`@\x90 T`\xFF\x16a\x1ByW`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F\xB1n\x88\xC4/\xD4\xE4\x8D\xF2\xDDj.\xAB\xD6\xBC\x9A\xECeN\xC1p\x05kG\x08\x19\xF8\x89,\xC6C\x1C` R`@\x90 \x80T`\xFF\x19\x16`\x01\x17\x90U3\x90`\x01`\x01`\xA0\x1B\x03\x16\x7F\xA4\x98\x07 \\\xE4\xD3U\t.\xF5\xA8\xA1\x8FV\xE8\x91<\xF4\xA2\x01\xFB\xE2\x87\x82[\tV\x93\xC2\x17u_\x80Q` a \xE3\x839\x81Q\x91R_\x80\xA4`\x01\x90V[`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F[\xC8A\xA6\xD9%\xA6 \x86i\"\xBA\xDA6\xD1m\xA3\xDC\xC9\xD5\"\x90Q\x9E\xA1\x12n\\\xA27!9` R`@\x90 T`\xFF\x16a\x1ByW`\x01`\x01`\xA0\x1B\x03\x81\x16_\x90\x81R\x7F[\xC8A\xA6\xD9%\xA6 \x86i\"\xBA\xDA6\xD1m\xA3\xDC\xC9\xD5\"\x90Q\x9E\xA1\x12n\\\xA27!9` R`@\x90 \x80T`\xFF\x19\x16`\x01\x17\x90U3\x90`\x01`\x01`\xA0\x1B\x03\x16\x7F\xB1\xFA\xDD1B\xAB*\xD7\xF13~\xA4\xD9q\x12\xBC\xC83\x7F\xC1\x1C\xE5\xB2\x0C\xB0J\xD08\xAD\xF9\x98\x19_\x80Q` a \xE3\x839\x81Q\x91R_\x80\xA4`\x01\x90V[_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 `\x01`\x01`\xA0\x1B\x03\x86\x16\x84R\x90\x91R\x90 T`\xFF\x16a\x1D\x8FW_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 `\x01`\x01`\xA0\x1B\x03\x86\x16\x84R\x90\x91R\x90 \x80T`\xFF\x19\x16`\x01\x17\x90U3\x91`\x01`\x01`\xA0\x1B\x03\x16\x90_\x80Q` a \xE3\x839\x81Q\x91R_\x80\xA4`\x01\x90V[PP_\x90V[_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 `\x01`\x01`\xA0\x1B\x03\x86\x16\x84R\x90\x91R\x90 T`\xFF\x16\x15a\x1D\x8FW_\x81\x81R_\x80Q` a!#\x839\x81Q\x91R` \x90\x81R`@\x80\x83 `\x01`\x01`\xA0\x1B\x03\x86\x16\x84R\x90\x91R\x90 \x80T`\xFF\x19\x16\x90U3\x91`\x01`\x01`\xA0\x1B\x03\x16\x90\x7F\xF69\x1F\\2\xD9\xC6\x9D*G\xEAg\x0BD)t\xB595\xD1\xED\xC7\xFDd\xEB!\xE0G\xA89\x17\x1B_\x80\xA4`\x01\x90V[\x90\x81` \x91\x03\x12a\x03GWQ\x90V[\x80T\x82\x10\x15a\x18CW_R` _ \x90`\x02\x1B\x01\x90_\x90V[\x91\x90\x82\x01\x80\x92\x11a\x14\xE1WV[\x90\x91_\x92_[`\x01`\x01`\xA0\x1B\x03\x84\x16_\x81\x81R`\x13` R`@\x90 T\x82\x10\x15a\x1A\xB1W\x80_R`\x13` Ra\x1E\xA4\x82`@_ a\x1EDV[PT`\x01`\x01`\xA0\x1B\x03\x84\x81\x16\x91\x16\x14a\x1E\xC2W[P`\x01\x01a\x1EpV[`\x01\x91\x95a\x1E\xE8\x91_R`\x13` R\x82a\x1E\xDF\x88`@_ a\x1EDV[P\x01T\x90a\x1E]V[\x94\x90a\x1E\xB9V[a\x1E\xF7a \x19V[a\x1E\xFFa \x19V[`\x01\x7F\x9Bw\x9B\x17B-\r\xF9\"#\x01\x8B2\xB4\xD1\xFAF\xE0qr=h\x17\xE2Hm\0;\xEC\xC5_\0UV[\x80Q\x90`\x02\x82\x10\x15a\x1FcW` \x90\x81\x01Q`@\x80Q\x92\x83\x01\x93\x84R`\x01`\x01`\xA0\x1B\x03\x90\x91\x16\x82\x82\x01R\x81Ra\x1F]``\x82a\x08\xAFV[Q\x90 \x90V[cNH{q`\xE0\x1B_R`!`\x04R`$_\xFD[\x90\x81;\x15a\x1F\xF8W_\x80Q` a!\x03\x839\x81Q\x91R\x80T`\x01`\x01`\xA0\x1B\x03\x19\x16`\x01`\x01`\xA0\x1B\x03\x84\x16\x90\x81\x17\x90\x91U\x7F\xBC|\xD7Z \xEE'\xFD\x9A\xDE\xBA\xB3 A\xF7U!M\xBCk\xFF\xA9\x0C\xC0\"[9\xDA.\\-;_\x80\xA2\x80Q\x15a\x1F\xE0Wa\x1F\xDD\x91a DV[PV[PP4a\x1F\xE9WV[c\xB3\x98\x97\x9F`\xE0\x1B_R`\x04_\xFD[PcL\x9C\x8C\xE3`\xE0\x1B_\x90\x81R`\x01`\x01`\xA0\x1B\x03\x91\x90\x91\x16`\x04R`$\x90\xFD[`\xFF_\x80Q` a!C\x839\x81Q\x91RT`@\x1C\x16\x15a 5WV[c\x1A\xFC\xD7\x9F`\xE3\x1B_R`\x04_\xFD[_\x80a\x16\x05\x93` \x81Q\x91\x01\x84Z\xF4=\x15a \x80W=\x91a d\x83a\x08\xF0V[\x92a r`@Q\x94\x85a\x08\xAFV[\x83R=_` \x85\x01>a \x84V[``\x91[\x90a \xA8WP\x80Q\x15a \x99W\x80Q\x90` \x01\xFD[c\xD6\xBD\xA2u`\xE0\x1B_R`\x04_\xFD[\x81Q\x15\x80a \xD9W[a \xB9WP\x90V[c\x99\x96\xB3\x15`\xE0\x1B_\x90\x81R`\x01`\x01`\xA0\x1B\x03\x91\x90\x91\x16`\x04R`$\x90\xFD[P\x80;\x15a \xB1V\xFE/\x87\x88\x11~~\xFF\x1D\x82\xE9&\xECyI\x01\xD1|x\x02JP'\t@0E@\xA73eo\r6\x08\x94\xA1;\xA1\xA3!\x06g\xC8(I-\xB9\x8D\xCA> v\xCC75\xA9 \xA3\xCAP]8+\xBC\x02\xDD{\xC7\xDE\xC4\xDC\xEE\xDD\xA7u\xE5\x8D\xD5A\xE0\x8A\x11llS\x81\\\x0B\xD0(\x19/{bh\0\xF0\xC5~\x16\x84\r\xF0@\xF1P\x88\xDC/\x81\xFE9\x1C9#\xBE\xC7>#\xA9f.\xFC\x9C\"\x9Cj\0\xA1dsolcC\0\x08\x1A\0\n",
    );
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Custom error with signature `AccessControlBadConfirmation()` and selector `0x6697b232`.
```solidity
error AccessControlBadConfirmation();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct AccessControlBadConfirmation;
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
        impl ::core::convert::From<AccessControlBadConfirmation>
        for UnderlyingRustTuple<'_> {
            fn from(value: AccessControlBadConfirmation) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>>
        for AccessControlBadConfirmation {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for AccessControlBadConfirmation {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "AccessControlBadConfirmation()";
            const SELECTOR: [u8; 4] = [102u8, 151u8, 178u8, 50u8];
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
    /**Custom error with signature `AccessControlUnauthorizedAccount(address,bytes32)` and selector `0xe2517d3f`.
```solidity
error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct AccessControlUnauthorizedAccount {
        #[allow(missing_docs)]
        pub account: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub neededRole: alloy::sol_types::private::FixedBytes<32>,
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
            alloy::sol_types::sol_data::Address,
            alloy::sol_types::sol_data::FixedBytes<32>,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (
            alloy::sol_types::private::Address,
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
        impl ::core::convert::From<AccessControlUnauthorizedAccount>
        for UnderlyingRustTuple<'_> {
            fn from(value: AccessControlUnauthorizedAccount) -> Self {
                (value.account, value.neededRole)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>>
        for AccessControlUnauthorizedAccount {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    account: tuple.0,
                    neededRole: tuple.1,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for AccessControlUnauthorizedAccount {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "AccessControlUnauthorizedAccount(address,bytes32)";
            const SELECTOR: [u8; 4] = [226u8, 81u8, 125u8, 63u8];
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
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(&self.neededRole),
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
    /**Custom error with signature `AddressEmptyCode(address)` and selector `0x9996b315`.
```solidity
error AddressEmptyCode(address target);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct AddressEmptyCode {
        #[allow(missing_docs)]
        pub target: alloy::sol_types::private::Address,
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
        impl ::core::convert::From<AddressEmptyCode> for UnderlyingRustTuple<'_> {
            fn from(value: AddressEmptyCode) -> Self {
                (value.target,)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for AddressEmptyCode {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self { target: tuple.0 }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for AddressEmptyCode {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "AddressEmptyCode(address)";
            const SELECTOR: [u8; 4] = [153u8, 150u8, 179u8, 21u8];
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
                        &self.target,
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
    /**Custom error with signature `ERC1967InvalidImplementation(address)` and selector `0x4c9c8ce3`.
```solidity
error ERC1967InvalidImplementation(address implementation);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ERC1967InvalidImplementation {
        #[allow(missing_docs)]
        pub implementation: alloy::sol_types::private::Address,
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
        impl ::core::convert::From<ERC1967InvalidImplementation>
        for UnderlyingRustTuple<'_> {
            fn from(value: ERC1967InvalidImplementation) -> Self {
                (value.implementation,)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>>
        for ERC1967InvalidImplementation {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self { implementation: tuple.0 }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for ERC1967InvalidImplementation {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ERC1967InvalidImplementation(address)";
            const SELECTOR: [u8; 4] = [76u8, 156u8, 140u8, 227u8];
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
                        &self.implementation,
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
    /**Custom error with signature `ERC1967NonPayable()` and selector `0xb398979f`.
```solidity
error ERC1967NonPayable();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ERC1967NonPayable;
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
        impl ::core::convert::From<ERC1967NonPayable> for UnderlyingRustTuple<'_> {
            fn from(value: ERC1967NonPayable) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for ERC1967NonPayable {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for ERC1967NonPayable {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ERC1967NonPayable()";
            const SELECTOR: [u8; 4] = [179u8, 152u8, 151u8, 159u8];
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
    /**Custom error with signature `EnforcedPause()` and selector `0xd93c0665`.
```solidity
error EnforcedPause();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct EnforcedPause;
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
        impl ::core::convert::From<EnforcedPause> for UnderlyingRustTuple<'_> {
            fn from(value: EnforcedPause) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for EnforcedPause {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for EnforcedPause {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "EnforcedPause()";
            const SELECTOR: [u8; 4] = [217u8, 60u8, 6u8, 101u8];
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
    /**Custom error with signature `ExpectedPause()` and selector `0x8dfc202b`.
```solidity
error ExpectedPause();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ExpectedPause;
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
        impl ::core::convert::From<ExpectedPause> for UnderlyingRustTuple<'_> {
            fn from(value: ExpectedPause) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for ExpectedPause {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for ExpectedPause {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ExpectedPause()";
            const SELECTOR: [u8; 4] = [141u8, 252u8, 32u8, 43u8];
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
    /**Custom error with signature `FailedCall()` and selector `0xd6bda275`.
```solidity
error FailedCall();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct FailedCall;
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
        impl ::core::convert::From<FailedCall> for UnderlyingRustTuple<'_> {
            fn from(value: FailedCall) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for FailedCall {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for FailedCall {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "FailedCall()";
            const SELECTOR: [u8; 4] = [214u8, 189u8, 162u8, 117u8];
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
    /**Custom error with signature `InvalidInitialization()` and selector `0xf92ee8a9`.
```solidity
error InvalidInitialization();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct InvalidInitialization;
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
        impl ::core::convert::From<InvalidInitialization> for UnderlyingRustTuple<'_> {
            fn from(value: InvalidInitialization) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for InvalidInitialization {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for InvalidInitialization {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "InvalidInitialization()";
            const SELECTOR: [u8; 4] = [249u8, 46u8, 232u8, 169u8];
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
    /**Custom error with signature `NotAContract(address)` and selector `0x8a8b41ec`.
```solidity
error NotAContract(address account);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct NotAContract {
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
        impl ::core::convert::From<NotAContract> for UnderlyingRustTuple<'_> {
            fn from(value: NotAContract) -> Self {
                (value.account,)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for NotAContract {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self { account: tuple.0 }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for NotAContract {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "NotAContract(address)";
            const SELECTOR: [u8; 4] = [138u8, 139u8, 65u8, 236u8];
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
    /**Custom error with signature `NotInitializing()` and selector `0xd7e6bcf8`.
```solidity
error NotInitializing();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct NotInitializing;
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
        impl ::core::convert::From<NotInitializing> for UnderlyingRustTuple<'_> {
            fn from(value: NotInitializing) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for NotInitializing {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for NotInitializing {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "NotInitializing()";
            const SELECTOR: [u8; 4] = [215u8, 230u8, 188u8, 248u8];
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
    /**Custom error with signature `ReentrancyGuardReentrantCall()` and selector `0x3ee5aeb5`.
```solidity
error ReentrancyGuardReentrantCall();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ReentrancyGuardReentrantCall;
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
        impl ::core::convert::From<ReentrancyGuardReentrantCall>
        for UnderlyingRustTuple<'_> {
            fn from(value: ReentrancyGuardReentrantCall) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>>
        for ReentrancyGuardReentrantCall {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for ReentrancyGuardReentrantCall {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ReentrancyGuardReentrantCall()";
            const SELECTOR: [u8; 4] = [62u8, 229u8, 174u8, 181u8];
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
    /**Custom error with signature `SelectorAlreadyRegistered(bytes4,address)` and selector `0x85708d48`.
```solidity
error SelectorAlreadyRegistered(bytes4 selector, address existingFacet);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct SelectorAlreadyRegistered {
        #[allow(missing_docs)]
        pub selector: alloy::sol_types::private::FixedBytes<4>,
        #[allow(missing_docs)]
        pub existingFacet: alloy::sol_types::private::Address,
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
            alloy::sol_types::sol_data::FixedBytes<4>,
            alloy::sol_types::sol_data::Address,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (
            alloy::sol_types::private::FixedBytes<4>,
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
        impl ::core::convert::From<SelectorAlreadyRegistered>
        for UnderlyingRustTuple<'_> {
            fn from(value: SelectorAlreadyRegistered) -> Self {
                (value.selector, value.existingFacet)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>>
        for SelectorAlreadyRegistered {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    selector: tuple.0,
                    existingFacet: tuple.1,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for SelectorAlreadyRegistered {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "SelectorAlreadyRegistered(bytes4,address)";
            const SELECTOR: [u8; 4] = [133u8, 112u8, 141u8, 72u8];
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
                        4,
                    > as alloy_sol_types::SolType>::tokenize(&self.selector),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.existingFacet,
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
    /**Custom error with signature `UUPSUnauthorizedCallContext()` and selector `0xe07c8dba`.
```solidity
error UUPSUnauthorizedCallContext();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct UUPSUnauthorizedCallContext;
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
        impl ::core::convert::From<UUPSUnauthorizedCallContext>
        for UnderlyingRustTuple<'_> {
            fn from(value: UUPSUnauthorizedCallContext) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>>
        for UUPSUnauthorizedCallContext {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for UUPSUnauthorizedCallContext {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "UUPSUnauthorizedCallContext()";
            const SELECTOR: [u8; 4] = [224u8, 124u8, 141u8, 186u8];
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
    /**Custom error with signature `UUPSUnsupportedProxiableUUID(bytes32)` and selector `0xaa1d49a4`.
```solidity
error UUPSUnsupportedProxiableUUID(bytes32 slot);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct UUPSUnsupportedProxiableUUID {
        #[allow(missing_docs)]
        pub slot: alloy::sol_types::private::FixedBytes<32>,
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
        impl ::core::convert::From<UUPSUnsupportedProxiableUUID>
        for UnderlyingRustTuple<'_> {
            fn from(value: UUPSUnsupportedProxiableUUID) -> Self {
                (value.slot,)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>>
        for UUPSUnsupportedProxiableUUID {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self { slot: tuple.0 }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for UUPSUnsupportedProxiableUUID {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "UUPSUnsupportedProxiableUUID(bytes32)";
            const SELECTOR: [u8; 4] = [170u8, 29u8, 73u8, 164u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.slot),
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
    /**Custom error with signature `UnknownSelector(bytes4)` and selector `0xc2a825f5`.
```solidity
error UnknownSelector(bytes4 selector);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct UnknownSelector {
        #[allow(missing_docs)]
        pub selector: alloy::sol_types::private::FixedBytes<4>,
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
        type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<4>,);
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (alloy::sol_types::private::FixedBytes<4>,);
        #[cfg(test)]
        #[allow(dead_code, unreachable_patterns)]
        fn _type_assertion(
            _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
        ) {
            match _t {
                alloy_sol_types::private::AssertTypeEq::<
                    <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                >(_) => {}
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnknownSelector> for UnderlyingRustTuple<'_> {
            fn from(value: UnknownSelector) -> Self {
                (value.selector,)
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for UnknownSelector {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self { selector: tuple.0 }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for UnknownSelector {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "UnknownSelector(bytes4)";
            const SELECTOR: [u8; 4] = [194u8, 168u8, 37u8, 245u8];
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
                        4,
                    > as alloy_sol_types::SolType>::tokenize(&self.selector),
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
    /**Custom error with signature `ZeroAddress()` and selector `0xd92e233d`.
```solidity
error ZeroAddress();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ZeroAddress;
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
        impl ::core::convert::From<ZeroAddress> for UnderlyingRustTuple<'_> {
            fn from(value: ZeroAddress) -> Self {
                ()
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for ZeroAddress {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolError for ZeroAddress {
            type Parameters<'a> = UnderlyingSolTuple<'a>;
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ZeroAddress()";
            const SELECTOR: [u8; 4] = [217u8, 46u8, 35u8, 61u8];
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
    /**Event with signature `BlueprintAddedToDelegation(address,uint256,uint64)` and selector `0xa7b81e017abeb50ecf2c121cb0db7087dfc4b3cc85cd8d857f9a5f1e81f64845`.
```solidity
event BlueprintAddedToDelegation(address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct BlueprintAddedToDelegation {
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub delegationIndex: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub blueprintId: u64,
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
        impl alloy_sol_types::SolEvent for BlueprintAddedToDelegation {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<256>,
            );
            const SIGNATURE: &'static str = "BlueprintAddedToDelegation(address,uint256,uint64)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                167u8, 184u8, 30u8, 1u8, 122u8, 190u8, 181u8, 14u8, 207u8, 44u8, 18u8,
                28u8, 176u8, 219u8, 112u8, 135u8, 223u8, 196u8, 179u8, 204u8, 133u8,
                205u8, 141u8, 133u8, 127u8, 154u8, 95u8, 30u8, 129u8, 246u8, 72u8, 69u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    delegator: topics.1,
                    delegationIndex: topics.2,
                    blueprintId: data.0,
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
                    > as alloy_sol_types::SolType>::tokenize(&self.blueprintId),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.delegator.clone(),
                    self.delegationIndex.clone(),
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
                    &self.delegator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.delegationIndex);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for BlueprintAddedToDelegation {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&BlueprintAddedToDelegation> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(
                this: &BlueprintAddedToDelegation,
            ) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `BlueprintRemovedFromDelegation(address,uint256,uint64)` and selector `0xc38cef0d003bc8a9982db0d994b2ea048946028e9255cc061a56abcbb7d548a1`.
```solidity
event BlueprintRemovedFromDelegation(address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct BlueprintRemovedFromDelegation {
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub delegationIndex: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub blueprintId: u64,
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
        impl alloy_sol_types::SolEvent for BlueprintRemovedFromDelegation {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<256>,
            );
            const SIGNATURE: &'static str = "BlueprintRemovedFromDelegation(address,uint256,uint64)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                195u8, 140u8, 239u8, 13u8, 0u8, 59u8, 200u8, 169u8, 152u8, 45u8, 176u8,
                217u8, 148u8, 178u8, 234u8, 4u8, 137u8, 70u8, 2u8, 142u8, 146u8, 85u8,
                204u8, 6u8, 26u8, 86u8, 171u8, 203u8, 183u8, 213u8, 72u8, 161u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    delegator: topics.1,
                    delegationIndex: topics.2,
                    blueprintId: data.0,
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
                    > as alloy_sol_types::SolType>::tokenize(&self.blueprintId),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.delegator.clone(),
                    self.delegationIndex.clone(),
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
                    &self.delegator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Uint<
                    256,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.delegationIndex);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for BlueprintRemovedFromDelegation {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&BlueprintRemovedFromDelegation>
        for alloy_sol_types::private::LogData {
            #[inline]
            fn from(
                this: &BlueprintRemovedFromDelegation,
            ) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `Delegated(address,address,address,uint256,uint256,uint8)` and selector `0x4fe2fde631e986ee26283901b9cc8d6d4a311b750f9fa0d659520deba2995f1f`.
```solidity
event Delegated(address indexed delegator, address indexed operator, address indexed token, uint256 amount, uint256 shares, Types.BlueprintSelectionMode selectionMode);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct Delegated {
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub token: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub amount: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub shares: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub selectionMode: <Types::BlueprintSelectionMode as alloy::sol_types::SolType>::RustType,
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
        impl alloy_sol_types::SolEvent for Delegated {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                Types::BlueprintSelectionMode,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "Delegated(address,address,address,uint256,uint256,uint8)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                79u8, 226u8, 253u8, 230u8, 49u8, 233u8, 134u8, 238u8, 38u8, 40u8, 57u8,
                1u8, 185u8, 204u8, 141u8, 109u8, 74u8, 49u8, 27u8, 117u8, 15u8, 159u8,
                160u8, 214u8, 89u8, 82u8, 13u8, 235u8, 162u8, 153u8, 95u8, 31u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    delegator: topics.1,
                    operator: topics.2,
                    token: topics.3,
                    amount: data.0,
                    shares: data.1,
                    selectionMode: data.2,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.amount),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.shares),
                    <Types::BlueprintSelectionMode as alloy_sol_types::SolType>::tokenize(
                        &self.selectionMode,
                    ),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.delegator.clone(),
                    self.operator.clone(),
                    self.token.clone(),
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
                    &self.delegator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                out[3usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.token,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for Delegated {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&Delegated> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &Delegated) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `DelegatorUnstakeExecuted(address,address,address,uint256,uint256)` and selector `0xe4183514c7483039538cd1f9ca20e489b3c411f3af1211cf6b5ad0a00ca4e228`.
```solidity
event DelegatorUnstakeExecuted(address indexed delegator, address indexed operator, address indexed token, uint256 shares, uint256 amount);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct DelegatorUnstakeExecuted {
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub token: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub shares: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub amount: alloy::sol_types::private::primitives::aliases::U256,
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
        impl alloy_sol_types::SolEvent for DelegatorUnstakeExecuted {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "DelegatorUnstakeExecuted(address,address,address,uint256,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                228u8, 24u8, 53u8, 20u8, 199u8, 72u8, 48u8, 57u8, 83u8, 140u8, 209u8,
                249u8, 202u8, 32u8, 228u8, 137u8, 179u8, 196u8, 17u8, 243u8, 175u8, 18u8,
                17u8, 207u8, 107u8, 90u8, 208u8, 160u8, 12u8, 164u8, 226u8, 40u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    delegator: topics.1,
                    operator: topics.2,
                    token: topics.3,
                    shares: data.0,
                    amount: data.1,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.shares),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.amount),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.delegator.clone(),
                    self.operator.clone(),
                    self.token.clone(),
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
                    &self.delegator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                out[3usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.token,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for DelegatorUnstakeExecuted {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&DelegatorUnstakeExecuted> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(
                this: &DelegatorUnstakeExecuted,
            ) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `DelegatorUnstakeScheduled(address,address,address,uint256,uint256,uint64)` and selector `0x06325d83435da87657b063c6142a5b91a66a7e811827d082d624287a9953c4ba`.
```solidity
event DelegatorUnstakeScheduled(address indexed delegator, address indexed operator, address indexed token, uint256 shares, uint256 estimatedAmount, uint64 readyRound);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct DelegatorUnstakeScheduled {
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub token: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub shares: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub estimatedAmount: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub readyRound: u64,
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
        impl alloy_sol_types::SolEvent for DelegatorUnstakeScheduled {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<64>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "DelegatorUnstakeScheduled(address,address,address,uint256,uint256,uint64)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                6u8, 50u8, 93u8, 131u8, 67u8, 93u8, 168u8, 118u8, 87u8, 176u8, 99u8,
                198u8, 20u8, 42u8, 91u8, 145u8, 166u8, 106u8, 126u8, 129u8, 24u8, 39u8,
                208u8, 130u8, 214u8, 36u8, 40u8, 122u8, 153u8, 83u8, 196u8, 186u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    delegator: topics.1,
                    operator: topics.2,
                    token: topics.3,
                    shares: data.0,
                    estimatedAmount: data.1,
                    readyRound: data.2,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.shares),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.estimatedAmount),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.readyRound),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.delegator.clone(),
                    self.operator.clone(),
                    self.token.clone(),
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
                    &self.delegator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.operator,
                );
                out[3usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.token,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for DelegatorUnstakeScheduled {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&DelegatorUnstakeScheduled> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(
                this: &DelegatorUnstakeScheduled,
            ) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `Deposited(address,address,uint256,uint8)` and selector `0x754fff2205ca9f1a08ae1f38f487839ba7e18895f0238908ea8b8842d7424fbb`.
```solidity
event Deposited(address indexed delegator, address indexed token, uint256 amount, Types.LockMultiplier lock);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct Deposited {
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub token: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub amount: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub lock: <Types::LockMultiplier as alloy::sol_types::SolType>::RustType,
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
        impl alloy_sol_types::SolEvent for Deposited {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                Types::LockMultiplier,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "Deposited(address,address,uint256,uint8)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                117u8, 79u8, 255u8, 34u8, 5u8, 202u8, 159u8, 26u8, 8u8, 174u8, 31u8,
                56u8, 244u8, 135u8, 131u8, 155u8, 167u8, 225u8, 136u8, 149u8, 240u8,
                35u8, 137u8, 8u8, 234u8, 139u8, 136u8, 66u8, 215u8, 66u8, 79u8, 187u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    delegator: topics.1,
                    token: topics.2,
                    amount: data.0,
                    lock: data.1,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.amount),
                    <Types::LockMultiplier as alloy_sol_types::SolType>::tokenize(
                        &self.lock,
                    ),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.delegator.clone(), self.token.clone())
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
                    &self.delegator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.token,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for Deposited {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&Deposited> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &Deposited) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `ExpiredLocksHarvested(address,address,uint256,uint256)` and selector `0x33348a72e308c92b447540f079c5f5895cc70cd83b15c264f330073c841770fc`.
```solidity
event ExpiredLocksHarvested(address indexed delegator, address indexed token, uint256 count, uint256 totalAmount);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct ExpiredLocksHarvested {
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub token: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub count: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub totalAmount: alloy::sol_types::private::primitives::aliases::U256,
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
        impl alloy_sol_types::SolEvent for ExpiredLocksHarvested {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "ExpiredLocksHarvested(address,address,uint256,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                51u8, 52u8, 138u8, 114u8, 227u8, 8u8, 201u8, 43u8, 68u8, 117u8, 64u8,
                240u8, 121u8, 197u8, 245u8, 137u8, 92u8, 199u8, 12u8, 216u8, 59u8, 21u8,
                194u8, 100u8, 243u8, 48u8, 7u8, 60u8, 132u8, 23u8, 112u8, 252u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    delegator: topics.1,
                    token: topics.2,
                    count: data.0,
                    totalAmount: data.1,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.count),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.totalAmount),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.delegator.clone(), self.token.clone())
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
                    &self.delegator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.token,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for ExpiredLocksHarvested {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&ExpiredLocksHarvested> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &ExpiredLocksHarvested) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `FacetRegistered(address)` and selector `0x4d3c30f5993f1922a779345a0f7ec1a170f1e52e9d230824f9c17e63596c906d`.
```solidity
event FacetRegistered(address indexed facet);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct FacetRegistered {
        #[allow(missing_docs)]
        pub facet: alloy::sol_types::private::Address,
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
        impl alloy_sol_types::SolEvent for FacetRegistered {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "FacetRegistered(address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                77u8, 60u8, 48u8, 245u8, 153u8, 63u8, 25u8, 34u8, 167u8, 121u8, 52u8,
                90u8, 15u8, 126u8, 193u8, 161u8, 112u8, 241u8, 229u8, 46u8, 157u8, 35u8,
                8u8, 36u8, 249u8, 193u8, 126u8, 99u8, 89u8, 108u8, 144u8, 109u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self { facet: topics.1 }
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
                (Self::SIGNATURE_HASH.into(), self.facet.clone())
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
                    &self.facet,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for FacetRegistered {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&FacetRegistered> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &FacetRegistered) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `FacetSelectorCleared(bytes4)` and selector `0xbeb27701828f515b03069d44da6519b6c491da13ef1ca7082e619959d1f48ddb`.
```solidity
event FacetSelectorCleared(bytes4 indexed selector);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct FacetSelectorCleared {
        #[allow(missing_docs)]
        pub selector: alloy::sol_types::private::FixedBytes<4>,
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
        impl alloy_sol_types::SolEvent for FacetSelectorCleared {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::FixedBytes<4>,
            );
            const SIGNATURE: &'static str = "FacetSelectorCleared(bytes4)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                190u8, 178u8, 119u8, 1u8, 130u8, 143u8, 81u8, 91u8, 3u8, 6u8, 157u8,
                68u8, 218u8, 101u8, 25u8, 182u8, 196u8, 145u8, 218u8, 19u8, 239u8, 28u8,
                167u8, 8u8, 46u8, 97u8, 153u8, 89u8, 209u8, 244u8, 141u8, 219u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self { selector: topics.1 }
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
                (Self::SIGNATURE_HASH.into(), self.selector.clone())
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
                out[1usize] = <alloy::sol_types::sol_data::FixedBytes<
                    4,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.selector);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for FacetSelectorCleared {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&FacetSelectorCleared> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &FacetSelectorCleared) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `FacetSelectorSet(bytes4,address)` and selector `0x12557f25e458d9682d7c959b5a960bc9332e8b7af1120b54a333bfc1ff282b39`.
```solidity
event FacetSelectorSet(bytes4 indexed selector, address indexed facet);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct FacetSelectorSet {
        #[allow(missing_docs)]
        pub selector: alloy::sol_types::private::FixedBytes<4>,
        #[allow(missing_docs)]
        pub facet: alloy::sol_types::private::Address,
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
        impl alloy_sol_types::SolEvent for FacetSelectorSet {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::FixedBytes<4>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "FacetSelectorSet(bytes4,address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                18u8, 85u8, 127u8, 37u8, 228u8, 88u8, 217u8, 104u8, 45u8, 124u8, 149u8,
                155u8, 90u8, 150u8, 11u8, 201u8, 51u8, 46u8, 139u8, 122u8, 241u8, 18u8,
                11u8, 84u8, 163u8, 51u8, 191u8, 193u8, 255u8, 40u8, 43u8, 57u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    selector: topics.1,
                    facet: topics.2,
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
                (Self::SIGNATURE_HASH.into(), self.selector.clone(), self.facet.clone())
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
                out[1usize] = <alloy::sol_types::sol_data::FixedBytes<
                    4,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.selector);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.facet,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for FacetSelectorSet {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&FacetSelectorSet> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &FacetSelectorSet) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `Initialized(uint64)` and selector `0xc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d2`.
```solidity
event Initialized(uint64 version);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct Initialized {
        #[allow(missing_docs)]
        pub version: u64,
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
        impl alloy_sol_types::SolEvent for Initialized {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (alloy_sol_types::sol_data::FixedBytes<32>,);
            const SIGNATURE: &'static str = "Initialized(uint64)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                199u8, 245u8, 5u8, 178u8, 243u8, 113u8, 174u8, 33u8, 117u8, 238u8, 73u8,
                19u8, 244u8, 73u8, 158u8, 31u8, 38u8, 51u8, 167u8, 181u8, 147u8, 99u8,
                33u8, 238u8, 209u8, 205u8, 174u8, 182u8, 17u8, 81u8, 129u8, 210u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self { version: data.0 }
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
                    > as alloy_sol_types::SolType>::tokenize(&self.version),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(),)
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
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for Initialized {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&Initialized> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &Initialized) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorBlueprintAdded(address,uint64)` and selector `0xb6d5e45d77b8967cff525b375be6e07f99ca5af91d88724ac1237aafe295d50e`.
```solidity
event OperatorBlueprintAdded(address indexed operator, uint64 indexed blueprintId);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorBlueprintAdded {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub blueprintId: u64,
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
        impl alloy_sol_types::SolEvent for OperatorBlueprintAdded {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
            );
            const SIGNATURE: &'static str = "OperatorBlueprintAdded(address,uint64)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                182u8, 213u8, 228u8, 93u8, 119u8, 184u8, 150u8, 124u8, 255u8, 82u8, 91u8,
                55u8, 91u8, 230u8, 224u8, 127u8, 153u8, 202u8, 90u8, 249u8, 29u8, 136u8,
                114u8, 74u8, 193u8, 35u8, 122u8, 175u8, 226u8, 149u8, 213u8, 14u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    blueprintId: topics.2,
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
                    self.operator.clone(),
                    self.blueprintId.clone(),
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
                    &self.operator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.blueprintId);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorBlueprintAdded {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorBlueprintAdded> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &OperatorBlueprintAdded) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorBlueprintRemoved(address,uint64)` and selector `0x4b9bbf2ebc79e9fb39a64920934b3f458a486552d3df95395aa750ece9e97093`.
```solidity
event OperatorBlueprintRemoved(address indexed operator, uint64 indexed blueprintId);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorBlueprintRemoved {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub blueprintId: u64,
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
        impl alloy_sol_types::SolEvent for OperatorBlueprintRemoved {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
            );
            const SIGNATURE: &'static str = "OperatorBlueprintRemoved(address,uint64)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                75u8, 155u8, 191u8, 46u8, 188u8, 121u8, 233u8, 251u8, 57u8, 166u8, 73u8,
                32u8, 147u8, 75u8, 63u8, 69u8, 138u8, 72u8, 101u8, 82u8, 211u8, 223u8,
                149u8, 57u8, 90u8, 167u8, 80u8, 236u8, 233u8, 233u8, 112u8, 147u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    blueprintId: topics.2,
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
                    self.operator.clone(),
                    self.blueprintId.clone(),
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
                    &self.operator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.blueprintId);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorBlueprintRemoved {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorBlueprintRemoved> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(
                this: &OperatorBlueprintRemoved,
            ) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorLeavingScheduled(address,uint64)` and selector `0xfd47ed8e653fba5e6e9fcaa947419ca2334b3972ce196132ec69708574d6d35a`.
```solidity
event OperatorLeavingScheduled(address indexed operator, uint64 readyRound);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorLeavingScheduled {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub readyRound: u64,
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
        impl alloy_sol_types::SolEvent for OperatorLeavingScheduled {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorLeavingScheduled(address,uint64)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                253u8, 71u8, 237u8, 142u8, 101u8, 63u8, 186u8, 94u8, 110u8, 159u8, 202u8,
                169u8, 71u8, 65u8, 156u8, 162u8, 51u8, 75u8, 57u8, 114u8, 206u8, 25u8,
                97u8, 50u8, 236u8, 105u8, 112u8, 133u8, 116u8, 214u8, 211u8, 90u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    readyRound: data.0,
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
                    > as alloy_sol_types::SolType>::tokenize(&self.readyRound),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.operator.clone())
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
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorLeavingScheduled {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorLeavingScheduled> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(
                this: &OperatorLeavingScheduled,
            ) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorLeft(address)` and selector `0x120599f8830115ed973189f8f4947cc793fcd90a15d47c4d6ad8d1a3f15af734`.
```solidity
event OperatorLeft(address indexed operator);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorLeft {
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
        impl alloy_sol_types::SolEvent for OperatorLeft {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorLeft(address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                18u8, 5u8, 153u8, 248u8, 131u8, 1u8, 21u8, 237u8, 151u8, 49u8, 137u8,
                248u8, 244u8, 148u8, 124u8, 199u8, 147u8, 252u8, 217u8, 10u8, 21u8,
                212u8, 124u8, 77u8, 106u8, 216u8, 209u8, 163u8, 241u8, 90u8, 247u8, 52u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self { operator: topics.1 }
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
                (Self::SIGNATURE_HASH.into(), self.operator.clone())
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
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorLeft {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorLeft> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &OperatorLeft) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorRegistered(address,uint256)` and selector `0xbc11617e575d658c74e921c8df22f8e48566072fa78145a6cfe18420bf8d0c4e`.
```solidity
event OperatorRegistered(address indexed operator, uint256 stake);
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
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub stake: alloy::sol_types::private::primitives::aliases::U256,
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
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorRegistered(address,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                188u8, 17u8, 97u8, 126u8, 87u8, 93u8, 101u8, 140u8, 116u8, 233u8, 33u8,
                200u8, 223u8, 34u8, 248u8, 228u8, 133u8, 102u8, 7u8, 47u8, 167u8, 129u8,
                69u8, 166u8, 207u8, 225u8, 132u8, 32u8, 191u8, 141u8, 12u8, 78u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    stake: data.0,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.stake),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.operator.clone())
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
    /**Event with signature `OperatorStakeIncreased(address,uint256)` and selector `0x614a3fa8467eb54cb60af3aab440279837c9fcd75c5a2617fe0af9c6e5e60e83`.
```solidity
event OperatorStakeIncreased(address indexed operator, uint256 amount);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorStakeIncreased {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub amount: alloy::sol_types::private::primitives::aliases::U256,
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
        impl alloy_sol_types::SolEvent for OperatorStakeIncreased {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorStakeIncreased(address,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                97u8, 74u8, 63u8, 168u8, 70u8, 126u8, 181u8, 76u8, 182u8, 10u8, 243u8,
                170u8, 180u8, 64u8, 39u8, 152u8, 55u8, 201u8, 252u8, 215u8, 92u8, 90u8,
                38u8, 23u8, 254u8, 10u8, 249u8, 198u8, 229u8, 230u8, 14u8, 131u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    amount: data.0,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.amount),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.operator.clone())
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
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorStakeIncreased {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorStakeIncreased> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &OperatorStakeIncreased) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorUnstakeExecuted(address,uint256)` and selector `0xda2b51341079f3dd8e6763a50f329bbc3dc6ca6a51b920fe99fbf89a54ec0e27`.
```solidity
event OperatorUnstakeExecuted(address indexed operator, uint256 amount);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorUnstakeExecuted {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub amount: alloy::sol_types::private::primitives::aliases::U256,
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
        impl alloy_sol_types::SolEvent for OperatorUnstakeExecuted {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorUnstakeExecuted(address,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                218u8, 43u8, 81u8, 52u8, 16u8, 121u8, 243u8, 221u8, 142u8, 103u8, 99u8,
                165u8, 15u8, 50u8, 155u8, 188u8, 61u8, 198u8, 202u8, 106u8, 81u8, 185u8,
                32u8, 254u8, 153u8, 251u8, 248u8, 154u8, 84u8, 236u8, 14u8, 39u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    amount: data.0,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.amount),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.operator.clone())
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
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorUnstakeExecuted {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorUnstakeExecuted> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(
                this: &OperatorUnstakeExecuted,
            ) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `OperatorUnstakeScheduled(address,uint256,uint64)` and selector `0xf7e874d9fd42838b0f06a44c7bbe45417b991e6b000e8ca4c5c1f086084a9cd3`.
```solidity
event OperatorUnstakeScheduled(address indexed operator, uint256 amount, uint64 readyRound);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct OperatorUnstakeScheduled {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub amount: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub readyRound: u64,
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
        impl alloy_sol_types::SolEvent for OperatorUnstakeScheduled {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<64>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "OperatorUnstakeScheduled(address,uint256,uint64)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                247u8, 232u8, 116u8, 217u8, 253u8, 66u8, 131u8, 139u8, 15u8, 6u8, 164u8,
                76u8, 123u8, 190u8, 69u8, 65u8, 123u8, 153u8, 30u8, 107u8, 0u8, 14u8,
                140u8, 164u8, 197u8, 193u8, 240u8, 134u8, 8u8, 74u8, 156u8, 211u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    amount: data.0,
                    readyRound: data.1,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.amount),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.readyRound),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.operator.clone())
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
                    &self.operator,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for OperatorUnstakeScheduled {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&OperatorUnstakeScheduled> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(
                this: &OperatorUnstakeScheduled,
            ) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `Paused(address)` and selector `0x62e78cea01bee320cd4e420270b5ea74000d11b0c9f74754ebdbfc544b05a258`.
```solidity
event Paused(address account);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct Paused {
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
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for Paused {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (alloy_sol_types::sol_data::FixedBytes<32>,);
            const SIGNATURE: &'static str = "Paused(address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                98u8, 231u8, 140u8, 234u8, 1u8, 190u8, 227u8, 32u8, 205u8, 78u8, 66u8,
                2u8, 112u8, 181u8, 234u8, 116u8, 0u8, 13u8, 17u8, 176u8, 201u8, 247u8,
                71u8, 84u8, 235u8, 219u8, 252u8, 84u8, 75u8, 5u8, 162u8, 88u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self { account: data.0 }
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
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.account,
                    ),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(),)
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
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for Paused {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&Paused> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &Paused) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `RoleAdminChanged(bytes32,bytes32,bytes32)` and selector `0xbd79b86ffe0ab8e8776151514217cd7cacd52c909f66475c3af44e129f0b00ff`.
```solidity
event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct RoleAdminChanged {
        #[allow(missing_docs)]
        pub role: alloy::sol_types::private::FixedBytes<32>,
        #[allow(missing_docs)]
        pub previousAdminRole: alloy::sol_types::private::FixedBytes<32>,
        #[allow(missing_docs)]
        pub newAdminRole: alloy::sol_types::private::FixedBytes<32>,
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
        impl alloy_sol_types::SolEvent for RoleAdminChanged {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::FixedBytes<32>,
            );
            const SIGNATURE: &'static str = "RoleAdminChanged(bytes32,bytes32,bytes32)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                189u8, 121u8, 184u8, 111u8, 254u8, 10u8, 184u8, 232u8, 119u8, 97u8, 81u8,
                81u8, 66u8, 23u8, 205u8, 124u8, 172u8, 213u8, 44u8, 144u8, 159u8, 102u8,
                71u8, 92u8, 58u8, 244u8, 78u8, 18u8, 159u8, 11u8, 0u8, 255u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    role: topics.1,
                    previousAdminRole: topics.2,
                    newAdminRole: topics.3,
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
                    self.role.clone(),
                    self.previousAdminRole.clone(),
                    self.newAdminRole.clone(),
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
                out[1usize] = <alloy::sol_types::sol_data::FixedBytes<
                    32,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.role);
                out[2usize] = <alloy::sol_types::sol_data::FixedBytes<
                    32,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.previousAdminRole);
                out[3usize] = <alloy::sol_types::sol_data::FixedBytes<
                    32,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.newAdminRole);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for RoleAdminChanged {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&RoleAdminChanged> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &RoleAdminChanged) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `RoleGranted(bytes32,address,address)` and selector `0x2f8788117e7eff1d82e926ec794901d17c78024a50270940304540a733656f0d`.
```solidity
event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct RoleGranted {
        #[allow(missing_docs)]
        pub role: alloy::sol_types::private::FixedBytes<32>,
        #[allow(missing_docs)]
        pub account: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub sender: alloy::sol_types::private::Address,
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
        impl alloy_sol_types::SolEvent for RoleGranted {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "RoleGranted(bytes32,address,address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                47u8, 135u8, 136u8, 17u8, 126u8, 126u8, 255u8, 29u8, 130u8, 233u8, 38u8,
                236u8, 121u8, 73u8, 1u8, 209u8, 124u8, 120u8, 2u8, 74u8, 80u8, 39u8, 9u8,
                64u8, 48u8, 69u8, 64u8, 167u8, 51u8, 101u8, 111u8, 13u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    role: topics.1,
                    account: topics.2,
                    sender: topics.3,
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
                    self.role.clone(),
                    self.account.clone(),
                    self.sender.clone(),
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
                out[1usize] = <alloy::sol_types::sol_data::FixedBytes<
                    32,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.role);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.account,
                );
                out[3usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.sender,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for RoleGranted {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&RoleGranted> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &RoleGranted) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `RoleRevoked(bytes32,address,address)` and selector `0xf6391f5c32d9c69d2a47ea670b442974b53935d1edc7fd64eb21e047a839171b`.
```solidity
event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct RoleRevoked {
        #[allow(missing_docs)]
        pub role: alloy::sol_types::private::FixedBytes<32>,
        #[allow(missing_docs)]
        pub account: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub sender: alloy::sol_types::private::Address,
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
        impl alloy_sol_types::SolEvent for RoleRevoked {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "RoleRevoked(bytes32,address,address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                246u8, 57u8, 31u8, 92u8, 50u8, 217u8, 198u8, 157u8, 42u8, 71u8, 234u8,
                103u8, 11u8, 68u8, 41u8, 116u8, 181u8, 57u8, 53u8, 209u8, 237u8, 199u8,
                253u8, 100u8, 235u8, 33u8, 224u8, 71u8, 168u8, 57u8, 23u8, 27u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    role: topics.1,
                    account: topics.2,
                    sender: topics.3,
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
                    self.role.clone(),
                    self.account.clone(),
                    self.sender.clone(),
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
                out[1usize] = <alloy::sol_types::sol_data::FixedBytes<
                    32,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.role);
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.account,
                );
                out[3usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.sender,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for RoleRevoked {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&RoleRevoked> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &RoleRevoked) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `SlashRecorded(address,uint64,uint256,uint256,uint256)` and selector `0x1508fbe22c9805770740c8f3827567950022729e0096e311dc087990c157fffc`.
```solidity
event SlashRecorded(address indexed operator, uint64 indexed slashId, uint256 totalSlashed, uint256 exchangeRateBefore, uint256 exchangeRateAfter);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct SlashRecorded {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub slashId: u64,
        #[allow(missing_docs)]
        pub totalSlashed: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub exchangeRateBefore: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub exchangeRateAfter: alloy::sol_types::private::primitives::aliases::U256,
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
        impl alloy_sol_types::SolEvent for SlashRecorded {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
            );
            const SIGNATURE: &'static str = "SlashRecorded(address,uint64,uint256,uint256,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                21u8, 8u8, 251u8, 226u8, 44u8, 152u8, 5u8, 119u8, 7u8, 64u8, 200u8,
                243u8, 130u8, 117u8, 103u8, 149u8, 0u8, 34u8, 114u8, 158u8, 0u8, 150u8,
                227u8, 17u8, 220u8, 8u8, 121u8, 144u8, 193u8, 87u8, 255u8, 252u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    slashId: topics.2,
                    totalSlashed: data.0,
                    exchangeRateBefore: data.1,
                    exchangeRateAfter: data.2,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.totalSlashed),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.exchangeRateBefore),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.exchangeRateAfter),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.operator.clone(),
                    self.slashId.clone(),
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
                    &self.operator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.slashId);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for SlashRecorded {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&SlashRecorded> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &SlashRecorded) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `Slashed(address,uint64,uint256,uint256,uint256)` and selector `0x91754b254153861c1e9bc9186484a0bb770823acfa00423044ba1759a01210e7`.
```solidity
event Slashed(address indexed operator, uint64 indexed serviceId, uint256 operatorSlashed, uint256 delegatorsSlashed, uint256 newExchangeRate);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct Slashed {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operatorSlashed: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub delegatorsSlashed: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub newExchangeRate: alloy::sol_types::private::primitives::aliases::U256,
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
        impl alloy_sol_types::SolEvent for Slashed {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
            );
            const SIGNATURE: &'static str = "Slashed(address,uint64,uint256,uint256,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                145u8, 117u8, 75u8, 37u8, 65u8, 83u8, 134u8, 28u8, 30u8, 155u8, 201u8,
                24u8, 100u8, 132u8, 160u8, 187u8, 119u8, 8u8, 35u8, 172u8, 250u8, 0u8,
                66u8, 48u8, 68u8, 186u8, 23u8, 89u8, 160u8, 18u8, 16u8, 231u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    serviceId: topics.2,
                    operatorSlashed: data.0,
                    delegatorsSlashed: data.1,
                    newExchangeRate: data.2,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.operatorSlashed),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.delegatorsSlashed),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.newExchangeRate),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.operator.clone(),
                    self.serviceId.clone(),
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
                    &self.operator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for Slashed {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&Slashed> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &Slashed) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `SlashedForService(address,uint64,uint64,uint256,uint256)` and selector `0xeb0d9b34ef071b87da8591ddd82cc67f90c6806201b5c9ddc91f0624677dc815`.
```solidity
event SlashedForService(address indexed operator, uint64 indexed serviceId, uint64 indexed blueprintId, uint256 totalSlashed, uint256 commitmentCount);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct SlashedForService {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub blueprintId: u64,
        #[allow(missing_docs)]
        pub totalSlashed: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub commitmentCount: alloy::sol_types::private::primitives::aliases::U256,
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
        impl alloy_sol_types::SolEvent for SlashedForService {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
            );
            const SIGNATURE: &'static str = "SlashedForService(address,uint64,uint64,uint256,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                235u8, 13u8, 155u8, 52u8, 239u8, 7u8, 27u8, 135u8, 218u8, 133u8, 145u8,
                221u8, 216u8, 44u8, 198u8, 127u8, 144u8, 198u8, 128u8, 98u8, 1u8, 181u8,
                201u8, 221u8, 201u8, 31u8, 6u8, 36u8, 103u8, 125u8, 200u8, 21u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    operator: topics.1,
                    serviceId: topics.2,
                    blueprintId: topics.3,
                    totalSlashed: data.0,
                    commitmentCount: data.1,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.totalSlashed),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.commitmentCount),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (
                    Self::SIGNATURE_HASH.into(),
                    self.operator.clone(),
                    self.serviceId.clone(),
                    self.blueprintId.clone(),
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
                    &self.operator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.serviceId);
                out[3usize] = <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic(&self.blueprintId);
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for SlashedForService {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&SlashedForService> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &SlashedForService) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `Unpaused(address)` and selector `0x5db9ee0a495bf2e6ff9c91a7834c1ba4fdd244a5e8aa4e537bd38aeae4b073aa`.
```solidity
event Unpaused(address account);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct Unpaused {
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
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for Unpaused {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (alloy_sol_types::sol_data::FixedBytes<32>,);
            const SIGNATURE: &'static str = "Unpaused(address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                93u8, 185u8, 238u8, 10u8, 73u8, 91u8, 242u8, 230u8, 255u8, 156u8, 145u8,
                167u8, 131u8, 76u8, 27u8, 164u8, 253u8, 210u8, 68u8, 165u8, 232u8, 170u8,
                78u8, 83u8, 123u8, 211u8, 138u8, 234u8, 228u8, 176u8, 115u8, 170u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self { account: data.0 }
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
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.account,
                    ),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(),)
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
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for Unpaused {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&Unpaused> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &Unpaused) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `Upgraded(address)` and selector `0xbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b`.
```solidity
event Upgraded(address indexed implementation);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct Upgraded {
        #[allow(missing_docs)]
        pub implementation: alloy::sol_types::private::Address,
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
        impl alloy_sol_types::SolEvent for Upgraded {
            type DataTuple<'a> = ();
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "Upgraded(address)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                188u8, 124u8, 215u8, 90u8, 32u8, 238u8, 39u8, 253u8, 154u8, 222u8, 186u8,
                179u8, 32u8, 65u8, 247u8, 85u8, 33u8, 77u8, 188u8, 107u8, 255u8, 169u8,
                12u8, 192u8, 34u8, 91u8, 57u8, 218u8, 46u8, 92u8, 45u8, 59u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self { implementation: topics.1 }
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
                (Self::SIGNATURE_HASH.into(), self.implementation.clone())
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
                    &self.implementation,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for Upgraded {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&Upgraded> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &Upgraded) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `WithdrawScheduled(address,address,uint256,uint64)` and selector `0x91eff7d39d2499d76ac21a1903a95a88f31589cb07b1ffdfb61db9f7cd8a3978`.
```solidity
event WithdrawScheduled(address indexed delegator, address indexed token, uint256 amount, uint64 readyRound);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct WithdrawScheduled {
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub token: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub amount: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub readyRound: u64,
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
        impl alloy_sol_types::SolEvent for WithdrawScheduled {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<64>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "WithdrawScheduled(address,address,uint256,uint64)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                145u8, 239u8, 247u8, 211u8, 157u8, 36u8, 153u8, 215u8, 106u8, 194u8,
                26u8, 25u8, 3u8, 169u8, 90u8, 136u8, 243u8, 21u8, 137u8, 203u8, 7u8,
                177u8, 255u8, 223u8, 182u8, 29u8, 185u8, 247u8, 205u8, 138u8, 57u8, 120u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    delegator: topics.1,
                    token: topics.2,
                    amount: data.0,
                    readyRound: data.1,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.amount),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.readyRound),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.delegator.clone(), self.token.clone())
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
                    &self.delegator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.token,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for WithdrawScheduled {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&WithdrawScheduled> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &WithdrawScheduled) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `Withdrawn(address,address,uint256)` and selector `0xd1c19fbcd4551a5edfb66d43d2e337c04837afda3482b42bdf569a8fccdae5fb`.
```solidity
event Withdrawn(address indexed delegator, address indexed token, uint256 amount);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct Withdrawn {
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub token: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub amount: alloy::sol_types::private::primitives::aliases::U256,
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
        impl alloy_sol_types::SolEvent for Withdrawn {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "Withdrawn(address,address,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                209u8, 193u8, 159u8, 188u8, 212u8, 85u8, 26u8, 94u8, 223u8, 182u8, 109u8,
                67u8, 210u8, 227u8, 55u8, 192u8, 72u8, 55u8, 175u8, 218u8, 52u8, 130u8,
                180u8, 43u8, 223u8, 86u8, 154u8, 143u8, 204u8, 218u8, 229u8, 251u8,
            ]);
            const ANONYMOUS: bool = false;
            #[allow(unused_variables)]
            #[inline]
            fn new(
                topics: <Self::TopicList as alloy_sol_types::SolType>::RustType,
                data: <Self::DataTuple<'_> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                Self {
                    delegator: topics.1,
                    token: topics.2,
                    amount: data.0,
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
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.amount),
                )
            }
            #[inline]
            fn topics(&self) -> <Self::TopicList as alloy_sol_types::SolType>::RustType {
                (Self::SIGNATURE_HASH.into(), self.delegator.clone(), self.token.clone())
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
                    &self.delegator,
                );
                out[2usize] = <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic(
                    &self.token,
                );
                Ok(())
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::private::IntoLogData for Withdrawn {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&Withdrawn> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &Withdrawn) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    /**Constructor`.
```solidity
constructor();
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct constructorCall {}
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
            impl ::core::convert::From<constructorCall> for UnderlyingRustTuple<'_> {
                fn from(value: constructorCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for constructorCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolConstructor for constructorCall {
            type Parameters<'a> = ();
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
                ()
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `ADMIN_ROLE()` and selector `0x75b238fc`.
```solidity
function ADMIN_ROLE() external view returns (bytes32);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ADMIN_ROLECall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`ADMIN_ROLE()`](ADMIN_ROLECall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ADMIN_ROLEReturn {
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
            impl ::core::convert::From<ADMIN_ROLECall> for UnderlyingRustTuple<'_> {
                fn from(value: ADMIN_ROLECall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for ADMIN_ROLECall {
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
            impl ::core::convert::From<ADMIN_ROLEReturn> for UnderlyingRustTuple<'_> {
                fn from(value: ADMIN_ROLEReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for ADMIN_ROLEReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for ADMIN_ROLECall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::FixedBytes<32>;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ADMIN_ROLE()";
            const SELECTOR: [u8; 4] = [117u8, 178u8, 56u8, 252u8];
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
                        let r: ADMIN_ROLEReturn = r.into();
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
                        let r: ADMIN_ROLEReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `ASSET_MANAGER_ROLE()` and selector `0xa4b32de8`.
```solidity
function ASSET_MANAGER_ROLE() external view returns (bytes32);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ASSET_MANAGER_ROLECall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`ASSET_MANAGER_ROLE()`](ASSET_MANAGER_ROLECall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct ASSET_MANAGER_ROLEReturn {
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
            impl ::core::convert::From<ASSET_MANAGER_ROLECall>
            for UnderlyingRustTuple<'_> {
                fn from(value: ASSET_MANAGER_ROLECall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for ASSET_MANAGER_ROLECall {
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
            impl ::core::convert::From<ASSET_MANAGER_ROLEReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: ASSET_MANAGER_ROLEReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for ASSET_MANAGER_ROLEReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for ASSET_MANAGER_ROLECall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::FixedBytes<32>;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "ASSET_MANAGER_ROLE()";
            const SELECTOR: [u8; 4] = [164u8, 179u8, 45u8, 232u8];
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
                        let r: ASSET_MANAGER_ROLEReturn = r.into();
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
                        let r: ASSET_MANAGER_ROLEReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `BPS_DENOMINATOR()` and selector `0xe1a45218`.
```solidity
function BPS_DENOMINATOR() external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct BPS_DENOMINATORCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`BPS_DENOMINATOR()`](BPS_DENOMINATORCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct BPS_DENOMINATORReturn {
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
            impl ::core::convert::From<BPS_DENOMINATORCall> for UnderlyingRustTuple<'_> {
                fn from(value: BPS_DENOMINATORCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for BPS_DENOMINATORCall {
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
            impl ::core::convert::From<BPS_DENOMINATORReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: BPS_DENOMINATORReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for BPS_DENOMINATORReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for BPS_DENOMINATORCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "BPS_DENOMINATOR()";
            const SELECTOR: [u8; 4] = [225u8, 164u8, 82u8, 24u8];
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
                        let r: BPS_DENOMINATORReturn = r.into();
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
                        let r: BPS_DENOMINATORReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `DEFAULT_ADMIN_ROLE()` and selector `0xa217fddf`.
```solidity
function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct DEFAULT_ADMIN_ROLECall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`DEFAULT_ADMIN_ROLE()`](DEFAULT_ADMIN_ROLECall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct DEFAULT_ADMIN_ROLEReturn {
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
            impl ::core::convert::From<DEFAULT_ADMIN_ROLECall>
            for UnderlyingRustTuple<'_> {
                fn from(value: DEFAULT_ADMIN_ROLECall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for DEFAULT_ADMIN_ROLECall {
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
            impl ::core::convert::From<DEFAULT_ADMIN_ROLEReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: DEFAULT_ADMIN_ROLEReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for DEFAULT_ADMIN_ROLEReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for DEFAULT_ADMIN_ROLECall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::FixedBytes<32>;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "DEFAULT_ADMIN_ROLE()";
            const SELECTOR: [u8; 4] = [162u8, 23u8, 253u8, 223u8];
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
                        let r: DEFAULT_ADMIN_ROLEReturn = r.into();
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
                        let r: DEFAULT_ADMIN_ROLEReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `LOCK_ONE_MONTH()` and selector `0x9e870585`.
```solidity
function LOCK_ONE_MONTH() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct LOCK_ONE_MONTHCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`LOCK_ONE_MONTH()`](LOCK_ONE_MONTHCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct LOCK_ONE_MONTHReturn {
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
            impl ::core::convert::From<LOCK_ONE_MONTHCall> for UnderlyingRustTuple<'_> {
                fn from(value: LOCK_ONE_MONTHCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for LOCK_ONE_MONTHCall {
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
            impl ::core::convert::From<LOCK_ONE_MONTHReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: LOCK_ONE_MONTHReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for LOCK_ONE_MONTHReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for LOCK_ONE_MONTHCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "LOCK_ONE_MONTH()";
            const SELECTOR: [u8; 4] = [158u8, 135u8, 5u8, 133u8];
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
                        let r: LOCK_ONE_MONTHReturn = r.into();
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
                        let r: LOCK_ONE_MONTHReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `LOCK_SIX_MONTHS()` and selector `0xf3c9b311`.
```solidity
function LOCK_SIX_MONTHS() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct LOCK_SIX_MONTHSCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`LOCK_SIX_MONTHS()`](LOCK_SIX_MONTHSCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct LOCK_SIX_MONTHSReturn {
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
            impl ::core::convert::From<LOCK_SIX_MONTHSCall> for UnderlyingRustTuple<'_> {
                fn from(value: LOCK_SIX_MONTHSCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for LOCK_SIX_MONTHSCall {
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
            impl ::core::convert::From<LOCK_SIX_MONTHSReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: LOCK_SIX_MONTHSReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for LOCK_SIX_MONTHSReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for LOCK_SIX_MONTHSCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "LOCK_SIX_MONTHS()";
            const SELECTOR: [u8; 4] = [243u8, 201u8, 179u8, 17u8];
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
                        let r: LOCK_SIX_MONTHSReturn = r.into();
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
                        let r: LOCK_SIX_MONTHSReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `LOCK_THREE_MONTHS()` and selector `0xd27a6f06`.
```solidity
function LOCK_THREE_MONTHS() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct LOCK_THREE_MONTHSCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`LOCK_THREE_MONTHS()`](LOCK_THREE_MONTHSCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct LOCK_THREE_MONTHSReturn {
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
            impl ::core::convert::From<LOCK_THREE_MONTHSCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: LOCK_THREE_MONTHSCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for LOCK_THREE_MONTHSCall {
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
            impl ::core::convert::From<LOCK_THREE_MONTHSReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: LOCK_THREE_MONTHSReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for LOCK_THREE_MONTHSReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for LOCK_THREE_MONTHSCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "LOCK_THREE_MONTHS()";
            const SELECTOR: [u8; 4] = [210u8, 122u8, 111u8, 6u8];
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
                        let r: LOCK_THREE_MONTHSReturn = r.into();
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
                        let r: LOCK_THREE_MONTHSReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `LOCK_TWO_MONTHS()` and selector `0x7df92ada`.
```solidity
function LOCK_TWO_MONTHS() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct LOCK_TWO_MONTHSCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`LOCK_TWO_MONTHS()`](LOCK_TWO_MONTHSCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct LOCK_TWO_MONTHSReturn {
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
            impl ::core::convert::From<LOCK_TWO_MONTHSCall> for UnderlyingRustTuple<'_> {
                fn from(value: LOCK_TWO_MONTHSCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for LOCK_TWO_MONTHSCall {
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
            impl ::core::convert::From<LOCK_TWO_MONTHSReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: LOCK_TWO_MONTHSReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for LOCK_TWO_MONTHSReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for LOCK_TWO_MONTHSCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "LOCK_TWO_MONTHS()";
            const SELECTOR: [u8; 4] = [125u8, 249u8, 42u8, 218u8];
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
                        let r: LOCK_TWO_MONTHSReturn = r.into();
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
                        let r: LOCK_TWO_MONTHSReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `MULTIPLIER_NONE()` and selector `0x4962f88f`.
```solidity
function MULTIPLIER_NONE() external view returns (uint16);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_NONECall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`MULTIPLIER_NONE()`](MULTIPLIER_NONECall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_NONEReturn {
        #[allow(missing_docs)]
        pub _0: u16,
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
            impl ::core::convert::From<MULTIPLIER_NONECall> for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_NONECall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for MULTIPLIER_NONECall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u16,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MULTIPLIER_NONEReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_NONEReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MULTIPLIER_NONEReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for MULTIPLIER_NONECall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u16;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "MULTIPLIER_NONE()";
            const SELECTOR: [u8; 4] = [73u8, 98u8, 248u8, 143u8];
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
                        16,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: MULTIPLIER_NONEReturn = r.into();
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
                        let r: MULTIPLIER_NONEReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `MULTIPLIER_ONE_MONTH()` and selector `0x18056dc2`.
```solidity
function MULTIPLIER_ONE_MONTH() external view returns (uint16);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_ONE_MONTHCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`MULTIPLIER_ONE_MONTH()`](MULTIPLIER_ONE_MONTHCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_ONE_MONTHReturn {
        #[allow(missing_docs)]
        pub _0: u16,
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
            impl ::core::convert::From<MULTIPLIER_ONE_MONTHCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_ONE_MONTHCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MULTIPLIER_ONE_MONTHCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u16,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MULTIPLIER_ONE_MONTHReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_ONE_MONTHReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MULTIPLIER_ONE_MONTHReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for MULTIPLIER_ONE_MONTHCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u16;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "MULTIPLIER_ONE_MONTH()";
            const SELECTOR: [u8; 4] = [24u8, 5u8, 109u8, 194u8];
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
                        16,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: MULTIPLIER_ONE_MONTHReturn = r.into();
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
                        let r: MULTIPLIER_ONE_MONTHReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `MULTIPLIER_SIX_MONTHS()` and selector `0x453eccea`.
```solidity
function MULTIPLIER_SIX_MONTHS() external view returns (uint16);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_SIX_MONTHSCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`MULTIPLIER_SIX_MONTHS()`](MULTIPLIER_SIX_MONTHSCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_SIX_MONTHSReturn {
        #[allow(missing_docs)]
        pub _0: u16,
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
            impl ::core::convert::From<MULTIPLIER_SIX_MONTHSCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_SIX_MONTHSCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MULTIPLIER_SIX_MONTHSCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u16,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MULTIPLIER_SIX_MONTHSReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_SIX_MONTHSReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MULTIPLIER_SIX_MONTHSReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for MULTIPLIER_SIX_MONTHSCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u16;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "MULTIPLIER_SIX_MONTHS()";
            const SELECTOR: [u8; 4] = [69u8, 62u8, 204u8, 234u8];
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
                        16,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: MULTIPLIER_SIX_MONTHSReturn = r.into();
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
                        let r: MULTIPLIER_SIX_MONTHSReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `MULTIPLIER_THREE_MONTHS()` and selector `0xa7fa6f98`.
```solidity
function MULTIPLIER_THREE_MONTHS() external view returns (uint16);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_THREE_MONTHSCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`MULTIPLIER_THREE_MONTHS()`](MULTIPLIER_THREE_MONTHSCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_THREE_MONTHSReturn {
        #[allow(missing_docs)]
        pub _0: u16,
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
            impl ::core::convert::From<MULTIPLIER_THREE_MONTHSCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_THREE_MONTHSCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MULTIPLIER_THREE_MONTHSCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u16,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MULTIPLIER_THREE_MONTHSReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_THREE_MONTHSReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MULTIPLIER_THREE_MONTHSReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for MULTIPLIER_THREE_MONTHSCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u16;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "MULTIPLIER_THREE_MONTHS()";
            const SELECTOR: [u8; 4] = [167u8, 250u8, 111u8, 152u8];
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
                        16,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: MULTIPLIER_THREE_MONTHSReturn = r.into();
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
                        let r: MULTIPLIER_THREE_MONTHSReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `MULTIPLIER_TWO_MONTHS()` and selector `0x54de2320`.
```solidity
function MULTIPLIER_TWO_MONTHS() external view returns (uint16);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_TWO_MONTHSCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`MULTIPLIER_TWO_MONTHS()`](MULTIPLIER_TWO_MONTHSCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct MULTIPLIER_TWO_MONTHSReturn {
        #[allow(missing_docs)]
        pub _0: u16,
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
            impl ::core::convert::From<MULTIPLIER_TWO_MONTHSCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_TWO_MONTHSCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MULTIPLIER_TWO_MONTHSCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u16,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<MULTIPLIER_TWO_MONTHSReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: MULTIPLIER_TWO_MONTHSReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for MULTIPLIER_TWO_MONTHSReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for MULTIPLIER_TWO_MONTHSCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u16;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "MULTIPLIER_TWO_MONTHS()";
            const SELECTOR: [u8; 4] = [84u8, 222u8, 35u8, 32u8];
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
                        16,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: MULTIPLIER_TWO_MONTHSReturn = r.into();
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
                        let r: MULTIPLIER_TWO_MONTHSReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `PRECISION()` and selector `0xaaf5eb68`.
```solidity
function PRECISION() external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct PRECISIONCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`PRECISION()`](PRECISIONCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct PRECISIONReturn {
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
            impl ::core::convert::From<PRECISIONCall> for UnderlyingRustTuple<'_> {
                fn from(value: PRECISIONCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for PRECISIONCall {
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
            impl ::core::convert::From<PRECISIONReturn> for UnderlyingRustTuple<'_> {
                fn from(value: PRECISIONReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for PRECISIONReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for PRECISIONCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "PRECISION()";
            const SELECTOR: [u8; 4] = [170u8, 245u8, 235u8, 104u8];
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
                        let r: PRECISIONReturn = r.into();
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
                        let r: PRECISIONReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `SLASHER_ROLE()` and selector `0x5095af64`.
```solidity
function SLASHER_ROLE() external view returns (bytes32);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct SLASHER_ROLECall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`SLASHER_ROLE()`](SLASHER_ROLECall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct SLASHER_ROLEReturn {
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
            impl ::core::convert::From<SLASHER_ROLECall> for UnderlyingRustTuple<'_> {
                fn from(value: SLASHER_ROLECall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for SLASHER_ROLECall {
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
            impl ::core::convert::From<SLASHER_ROLEReturn> for UnderlyingRustTuple<'_> {
                fn from(value: SLASHER_ROLEReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for SLASHER_ROLEReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for SLASHER_ROLECall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::FixedBytes<32>;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "SLASHER_ROLE()";
            const SELECTOR: [u8; 4] = [80u8, 149u8, 175u8, 100u8];
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
                        let r: SLASHER_ROLEReturn = r.into();
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
                        let r: SLASHER_ROLEReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `UPGRADE_INTERFACE_VERSION()` and selector `0xad3cb1cc`.
```solidity
function UPGRADE_INTERFACE_VERSION() external view returns (string memory);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct UPGRADE_INTERFACE_VERSIONCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`UPGRADE_INTERFACE_VERSION()`](UPGRADE_INTERFACE_VERSIONCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct UPGRADE_INTERFACE_VERSIONReturn {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::String,
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
            impl ::core::convert::From<UPGRADE_INTERFACE_VERSIONCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: UPGRADE_INTERFACE_VERSIONCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for UPGRADE_INTERFACE_VERSIONCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::String,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::String,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UPGRADE_INTERFACE_VERSIONReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: UPGRADE_INTERFACE_VERSIONReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for UPGRADE_INTERFACE_VERSIONReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for UPGRADE_INTERFACE_VERSIONCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::String;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::String,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "UPGRADE_INTERFACE_VERSION()";
            const SELECTOR: [u8; 4] = [173u8, 60u8, 177u8, 204u8];
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
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
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
                        let r: UPGRADE_INTERFACE_VERSIONReturn = r.into();
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
                        let r: UPGRADE_INTERFACE_VERSIONReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `blueprintSlashCount(uint64,address)` and selector `0x4e9c929a`.
```solidity
function blueprintSlashCount(uint64, address) external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct blueprintSlashCountCall {
        #[allow(missing_docs)]
        pub _0: u64,
        #[allow(missing_docs)]
        pub _1: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`blueprintSlashCount(uint64,address)`](blueprintSlashCountCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct blueprintSlashCountReturn {
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
            impl ::core::convert::From<blueprintSlashCountCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: blueprintSlashCountCall) -> Self {
                    (value._0, value._1)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for blueprintSlashCountCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0, _1: tuple.1 }
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
            impl ::core::convert::From<blueprintSlashCountReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: blueprintSlashCountReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for blueprintSlashCountReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for blueprintSlashCountCall {
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
            const SIGNATURE: &'static str = "blueprintSlashCount(uint64,address)";
            const SELECTOR: [u8; 4] = [78u8, 156u8, 146u8, 154u8];
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
                        let r: blueprintSlashCountReturn = r.into();
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
                        let r: blueprintSlashCountReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `clearFacetSelectors(bytes4[])` and selector `0xe07dec29`.
```solidity
function clearFacetSelectors(bytes4[] memory selectors) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct clearFacetSelectorsCall {
        #[allow(missing_docs)]
        pub selectors: alloy::sol_types::private::Vec<
            alloy::sol_types::private::FixedBytes<4>,
        >,
    }
    ///Container type for the return parameters of the [`clearFacetSelectors(bytes4[])`](clearFacetSelectorsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct clearFacetSelectorsReturn {}
    #[allow(
        non_camel_case_types,
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
                alloy::sol_types::sol_data::Array<
                    alloy::sol_types::sol_data::FixedBytes<4>,
                >,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Vec<alloy::sol_types::private::FixedBytes<4>>,
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
            impl ::core::convert::From<clearFacetSelectorsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: clearFacetSelectorsCall) -> Self {
                    (value.selectors,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for clearFacetSelectorsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { selectors: tuple.0 }
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
            impl ::core::convert::From<clearFacetSelectorsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: clearFacetSelectorsReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for clearFacetSelectorsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl clearFacetSelectorsReturn {
            fn _tokenize(
                &self,
            ) -> <clearFacetSelectorsCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for clearFacetSelectorsCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Array<
                    alloy::sol_types::sol_data::FixedBytes<4>,
                >,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = clearFacetSelectorsReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "clearFacetSelectors(bytes4[])";
            const SELECTOR: [u8; 4] = [224u8, 125u8, 236u8, 41u8];
            #[inline]
            fn new<'a>(
                tuple: <Self::Parameters<'a> as alloy_sol_types::SolType>::RustType,
            ) -> Self {
                tuple.into()
            }
            #[inline]
            fn tokenize(&self) -> Self::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Array<
                        alloy::sol_types::sol_data::FixedBytes<4>,
                    > as alloy_sol_types::SolType>::tokenize(&self.selectors),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                clearFacetSelectorsReturn::_tokenize(ret)
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
    /**Function with signature `currentRound()` and selector `0x8a19c8bc`.
```solidity
function currentRound() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct currentRoundCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`currentRound()`](currentRoundCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct currentRoundReturn {
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
            impl ::core::convert::From<currentRoundCall> for UnderlyingRustTuple<'_> {
                fn from(value: currentRoundCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for currentRoundCall {
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
            impl ::core::convert::From<currentRoundReturn> for UnderlyingRustTuple<'_> {
                fn from(value: currentRoundReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for currentRoundReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for currentRoundCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "currentRound()";
            const SELECTOR: [u8; 4] = [138u8, 25u8, 200u8, 188u8];
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
                        let r: currentRoundReturn = r.into();
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
                        let r: currentRoundReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `delegationBondLessDelay()` and selector `0xba05bbf5`.
```solidity
function delegationBondLessDelay() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct delegationBondLessDelayCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`delegationBondLessDelay()`](delegationBondLessDelayCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct delegationBondLessDelayReturn {
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
            impl ::core::convert::From<delegationBondLessDelayCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: delegationBondLessDelayCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for delegationBondLessDelayCall {
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
            impl ::core::convert::From<delegationBondLessDelayReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: delegationBondLessDelayReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for delegationBondLessDelayReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for delegationBondLessDelayCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "delegationBondLessDelay()";
            const SELECTOR: [u8; 4] = [186u8, 5u8, 187u8, 245u8];
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
                        let r: delegationBondLessDelayReturn = r.into();
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
                        let r: delegationBondLessDelayReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `facetForSelector(bytes4)` and selector `0x90837ff4`.
```solidity
function facetForSelector(bytes4 selector) external view returns (address);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct facetForSelectorCall {
        #[allow(missing_docs)]
        pub selector: alloy::sol_types::private::FixedBytes<4>,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`facetForSelector(bytes4)`](facetForSelectorCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct facetForSelectorReturn {
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
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<4>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::FixedBytes<4>,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<facetForSelectorCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: facetForSelectorCall) -> Self {
                    (value.selector,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for facetForSelectorCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { selector: tuple.0 }
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
            impl ::core::convert::From<facetForSelectorReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: facetForSelectorReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for facetForSelectorReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for facetForSelectorCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::FixedBytes<4>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Address;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "facetForSelector(bytes4)";
            const SELECTOR: [u8; 4] = [144u8, 131u8, 127u8, 244u8];
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
                        4,
                    > as alloy_sol_types::SolType>::tokenize(&self.selector),
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
                        let r: facetForSelectorReturn = r.into();
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
                        let r: facetForSelectorReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getAssetAdapter(address)` and selector `0x8a7fe60f`.
```solidity
function getAssetAdapter(address token) external view returns (address);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getAssetAdapterCall {
        #[allow(missing_docs)]
        pub token: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getAssetAdapter(address)`](getAssetAdapterCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getAssetAdapterReturn {
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
            impl ::core::convert::From<getAssetAdapterCall> for UnderlyingRustTuple<'_> {
                fn from(value: getAssetAdapterCall) -> Self {
                    (value.token,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getAssetAdapterCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { token: tuple.0 }
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
            impl ::core::convert::From<getAssetAdapterReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getAssetAdapterReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getAssetAdapterReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getAssetAdapterCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Address,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Address;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Address,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getAssetAdapter(address)";
            const SELECTOR: [u8; 4] = [138u8, 127u8, 230u8, 15u8];
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
                        &self.token,
                    ),
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
                        let r: getAssetAdapterReturn = r.into();
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
                        let r: getAssetAdapterReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getOperatorSlashFactor(address)` and selector `0x615d24de`.
```solidity
function getOperatorSlashFactor(address operator) external view returns (uint256);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOperatorSlashFactorCall {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getOperatorSlashFactor(address)`](getOperatorSlashFactorCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getOperatorSlashFactorReturn {
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
            impl ::core::convert::From<getOperatorSlashFactorCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOperatorSlashFactorCall) -> Self {
                    (value.operator,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOperatorSlashFactorCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { operator: tuple.0 }
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
            impl ::core::convert::From<getOperatorSlashFactorReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getOperatorSlashFactorReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getOperatorSlashFactorReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getOperatorSlashFactorCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Address,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getOperatorSlashFactor(address)";
            const SELECTOR: [u8; 4] = [97u8, 93u8, 36u8, 222u8];
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
                        let r: getOperatorSlashFactorReturn = r.into();
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
                        let r: getOperatorSlashFactorReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getRoleAdmin(bytes32)` and selector `0x248a9ca3`.
```solidity
function getRoleAdmin(bytes32 role) external view returns (bytes32);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getRoleAdminCall {
        #[allow(missing_docs)]
        pub role: alloy::sol_types::private::FixedBytes<32>,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getRoleAdmin(bytes32)`](getRoleAdminCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getRoleAdminReturn {
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
            impl ::core::convert::From<getRoleAdminCall> for UnderlyingRustTuple<'_> {
                fn from(value: getRoleAdminCall) -> Self {
                    (value.role,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getRoleAdminCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { role: tuple.0 }
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
            impl ::core::convert::From<getRoleAdminReturn> for UnderlyingRustTuple<'_> {
                fn from(value: getRoleAdminReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getRoleAdminReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getRoleAdminCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::FixedBytes<32>;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getRoleAdmin(bytes32)";
            const SELECTOR: [u8; 4] = [36u8, 138u8, 156u8, 163u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.role),
                )
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
                        let r: getRoleAdminReturn = r.into();
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
                        let r: getRoleAdminReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getSlashCount(address)` and selector `0x66c36875`.
```solidity
function getSlashCount(address operator) external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashCountCall {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getSlashCount(address)`](getSlashCountCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashCountReturn {
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
            impl ::core::convert::From<getSlashCountCall> for UnderlyingRustTuple<'_> {
                fn from(value: getSlashCountCall) -> Self {
                    (value.operator,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getSlashCountCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { operator: tuple.0 }
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
            impl ::core::convert::From<getSlashCountReturn> for UnderlyingRustTuple<'_> {
                fn from(value: getSlashCountReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getSlashCountReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getSlashCountCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Address,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getSlashCount(address)";
            const SELECTOR: [u8; 4] = [102u8, 195u8, 104u8, 117u8];
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
                        let r: getSlashCountReturn = r.into();
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
                        let r: getSlashCountReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getSlashCountForBlueprint(uint64,address)` and selector `0xc550d938`.
```solidity
function getSlashCountForBlueprint(uint64 blueprintId, address operator) external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashCountForBlueprintCall {
        #[allow(missing_docs)]
        pub blueprintId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getSlashCountForBlueprint(uint64,address)`](getSlashCountForBlueprintCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashCountForBlueprintReturn {
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
            impl ::core::convert::From<getSlashCountForBlueprintCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashCountForBlueprintCall) -> Self {
                    (value.blueprintId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashCountForBlueprintCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        blueprintId: tuple.0,
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
            impl ::core::convert::From<getSlashCountForBlueprintReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashCountForBlueprintReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashCountForBlueprintReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getSlashCountForBlueprintCall {
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
            const SIGNATURE: &'static str = "getSlashCountForBlueprint(uint64,address)";
            const SELECTOR: [u8; 4] = [197u8, 80u8, 217u8, 56u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.blueprintId),
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
                        let r: getSlashCountForBlueprintReturn = r.into();
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
                        let r: getSlashCountForBlueprintReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getSlashCountForService(uint64,address)` and selector `0x72b5032d`.
```solidity
function getSlashCountForService(uint64 serviceId, address operator) external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashCountForServiceCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getSlashCountForService(uint64,address)`](getSlashCountForServiceCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashCountForServiceReturn {
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
            impl ::core::convert::From<getSlashCountForServiceCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashCountForServiceCall) -> Self {
                    (value.serviceId, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashCountForServiceCall {
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
            impl ::core::convert::From<getSlashCountForServiceReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashCountForServiceReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashCountForServiceReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getSlashCountForServiceCall {
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
            const SIGNATURE: &'static str = "getSlashCountForService(uint64,address)";
            const SELECTOR: [u8; 4] = [114u8, 181u8, 3u8, 45u8];
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
                        let r: getSlashCountForServiceReturn = r.into();
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
                        let r: getSlashCountForServiceReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getSlashImpact(address,uint64,address)` and selector `0x9494f426`.
```solidity
function getSlashImpact(address operator, uint64 slashId, address delegator) external view returns (uint256 lostAmount);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashImpactCall {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub slashId: u64,
        #[allow(missing_docs)]
        pub delegator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getSlashImpact(address,uint64,address)`](getSlashImpactCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashImpactReturn {
        #[allow(missing_docs)]
        pub lostAmount: alloy::sol_types::private::primitives::aliases::U256,
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
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Address,
                u64,
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
            impl ::core::convert::From<getSlashImpactCall> for UnderlyingRustTuple<'_> {
                fn from(value: getSlashImpactCall) -> Self {
                    (value.operator, value.slashId, value.delegator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getSlashImpactCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        operator: tuple.0,
                        slashId: tuple.1,
                        delegator: tuple.2,
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
            impl ::core::convert::From<getSlashImpactReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashImpactReturn) -> Self {
                    (value.lostAmount,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashImpactReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { lostAmount: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getSlashImpactCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Address,
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
            const SIGNATURE: &'static str = "getSlashImpact(address,uint64,address)";
            const SELECTOR: [u8; 4] = [148u8, 148u8, 244u8, 38u8];
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
                        &self.operator,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.slashId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.delegator,
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
                        let r: getSlashImpactReturn = r.into();
                        r.lostAmount
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
                        let r: getSlashImpactReturn = r.into();
                        r.lostAmount
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getSlashRecord(address,uint64)` and selector `0xa457af3d`.
```solidity
function getSlashRecord(address operator, uint64 slashId) external view returns (SlashingManager.SlashRecord memory);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashRecordCall {
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub slashId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getSlashRecord(address,uint64)`](getSlashRecordCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashRecordReturn {
        #[allow(missing_docs)]
        pub _0: <SlashingManager::SlashRecord as alloy::sol_types::SolType>::RustType,
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
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address, u64);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getSlashRecordCall> for UnderlyingRustTuple<'_> {
                fn from(value: getSlashRecordCall) -> Self {
                    (value.operator, value.slashId)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getSlashRecordCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        operator: tuple.0,
                        slashId: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (SlashingManager::SlashRecord,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                <SlashingManager::SlashRecord as alloy::sol_types::SolType>::RustType,
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
            impl ::core::convert::From<getSlashRecordReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashRecordReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashRecordReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getSlashRecordCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = <SlashingManager::SlashRecord as alloy::sol_types::SolType>::RustType;
            type ReturnTuple<'a> = (SlashingManager::SlashRecord,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getSlashRecord(address,uint64)";
            const SELECTOR: [u8; 4] = [164u8, 87u8, 175u8, 61u8];
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
                        &self.operator,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.slashId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <SlashingManager::SlashRecord as alloy_sol_types::SolType>::tokenize(
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
                        let r: getSlashRecordReturn = r.into();
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
                        let r: getSlashRecordReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getSnapshot(uint64,address)` and selector `0xc07449e2`.
```solidity
function getSnapshot(uint64 round, address operator) external view returns (Types.OperatorSnapshot memory);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSnapshotCall {
        #[allow(missing_docs)]
        pub round: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getSnapshot(uint64,address)`](getSnapshotCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSnapshotReturn {
        #[allow(missing_docs)]
        pub _0: <Types::OperatorSnapshot as alloy::sol_types::SolType>::RustType,
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
            impl ::core::convert::From<getSnapshotCall> for UnderlyingRustTuple<'_> {
                fn from(value: getSnapshotCall) -> Self {
                    (value.round, value.operator)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getSnapshotCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        round: tuple.0,
                        operator: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (Types::OperatorSnapshot,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                <Types::OperatorSnapshot as alloy::sol_types::SolType>::RustType,
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
            impl ::core::convert::From<getSnapshotReturn> for UnderlyingRustTuple<'_> {
                fn from(value: getSnapshotReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for getSnapshotReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getSnapshotCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = <Types::OperatorSnapshot as alloy::sol_types::SolType>::RustType;
            type ReturnTuple<'a> = (Types::OperatorSnapshot,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getSnapshot(uint64,address)";
            const SELECTOR: [u8; 4] = [192u8, 116u8, 73u8, 226u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.round),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (<Types::OperatorSnapshot as alloy_sol_types::SolType>::tokenize(ret),)
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getSnapshotReturn = r.into();
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
                        let r: getSnapshotReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `grantRole(bytes32,address)` and selector `0x2f2ff15d`.
```solidity
function grantRole(bytes32 role, address account) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct grantRoleCall {
        #[allow(missing_docs)]
        pub role: alloy::sol_types::private::FixedBytes<32>,
        #[allow(missing_docs)]
        pub account: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`grantRole(bytes32,address)`](grantRoleCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct grantRoleReturn {}
    #[allow(
        non_camel_case_types,
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
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::FixedBytes<32>,
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
            impl ::core::convert::From<grantRoleCall> for UnderlyingRustTuple<'_> {
                fn from(value: grantRoleCall) -> Self {
                    (value.role, value.account)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for grantRoleCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        role: tuple.0,
                        account: tuple.1,
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
            impl ::core::convert::From<grantRoleReturn> for UnderlyingRustTuple<'_> {
                fn from(value: grantRoleReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for grantRoleReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl grantRoleReturn {
            fn _tokenize(
                &self,
            ) -> <grantRoleCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for grantRoleCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = grantRoleReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "grantRole(bytes32,address)";
            const SELECTOR: [u8; 4] = [47u8, 47u8, 241u8, 93u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.role),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.account,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                grantRoleReturn::_tokenize(ret)
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
    /**Function with signature `hasRole(bytes32,address)` and selector `0x91d14854`.
```solidity
function hasRole(bytes32 role, address account) external view returns (bool);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct hasRoleCall {
        #[allow(missing_docs)]
        pub role: alloy::sol_types::private::FixedBytes<32>,
        #[allow(missing_docs)]
        pub account: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`hasRole(bytes32,address)`](hasRoleCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct hasRoleReturn {
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
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::FixedBytes<32>,
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
            impl ::core::convert::From<hasRoleCall> for UnderlyingRustTuple<'_> {
                fn from(value: hasRoleCall) -> Self {
                    (value.role, value.account)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for hasRoleCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        role: tuple.0,
                        account: tuple.1,
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
            impl ::core::convert::From<hasRoleReturn> for UnderlyingRustTuple<'_> {
                fn from(value: hasRoleReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for hasRoleReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for hasRoleCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::FixedBytes<32>,
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
            const SIGNATURE: &'static str = "hasRole(bytes32,address)";
            const SELECTOR: [u8; 4] = [145u8, 209u8, 72u8, 84u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.role),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.account,
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
                        let r: hasRoleReturn = r.into();
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
                        let r: hasRoleReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `initialize(address,uint256,uint256,uint16)` and selector `0xcbb6d6bd`.
```solidity
function initialize(address admin, uint256 nativeMinOperatorStake, uint256 nativeMinDelegation, uint16 _operatorCommissionBps) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct initializeCall {
        #[allow(missing_docs)]
        pub admin: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub nativeMinOperatorStake: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub nativeMinDelegation: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub _operatorCommissionBps: u16,
    }
    ///Container type for the return parameters of the [`initialize(address,uint256,uint256,uint16)`](initializeCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct initializeReturn {}
    #[allow(
        non_camel_case_types,
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
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<16>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Address,
                alloy::sol_types::private::primitives::aliases::U256,
                alloy::sol_types::private::primitives::aliases::U256,
                u16,
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
            impl ::core::convert::From<initializeCall> for UnderlyingRustTuple<'_> {
                fn from(value: initializeCall) -> Self {
                    (
                        value.admin,
                        value.nativeMinOperatorStake,
                        value.nativeMinDelegation,
                        value._operatorCommissionBps,
                    )
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for initializeCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        admin: tuple.0,
                        nativeMinOperatorStake: tuple.1,
                        nativeMinDelegation: tuple.2,
                        _operatorCommissionBps: tuple.3,
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
            impl ::core::convert::From<initializeReturn> for UnderlyingRustTuple<'_> {
                fn from(value: initializeReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for initializeReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl initializeReturn {
            fn _tokenize(
                &self,
            ) -> <initializeCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for initializeCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<16>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = initializeReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "initialize(address,uint256,uint256,uint16)";
            const SELECTOR: [u8; 4] = [203u8, 182u8, 214u8, 189u8];
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
                        &self.admin,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(
                        &self.nativeMinOperatorStake,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.nativeMinDelegation),
                    <alloy::sol_types::sol_data::Uint<
                        16,
                    > as alloy_sol_types::SolType>::tokenize(
                        &self._operatorCommissionBps,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                initializeReturn::_tokenize(ret)
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
    /**Function with signature `lastRoundAdvance()` and selector `0x05d64e38`.
```solidity
function lastRoundAdvance() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct lastRoundAdvanceCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`lastRoundAdvance()`](lastRoundAdvanceCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct lastRoundAdvanceReturn {
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
            impl ::core::convert::From<lastRoundAdvanceCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: lastRoundAdvanceCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for lastRoundAdvanceCall {
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
            impl ::core::convert::From<lastRoundAdvanceReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: lastRoundAdvanceReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for lastRoundAdvanceReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for lastRoundAdvanceCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "lastRoundAdvance()";
            const SELECTOR: [u8; 4] = [5u8, 214u8, 78u8, 56u8];
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
                        let r: lastRoundAdvanceReturn = r.into();
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
                        let r: lastRoundAdvanceReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `leaveDelegatorsDelay()` and selector `0xdb8a173a`.
```solidity
function leaveDelegatorsDelay() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct leaveDelegatorsDelayCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`leaveDelegatorsDelay()`](leaveDelegatorsDelayCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct leaveDelegatorsDelayReturn {
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
            impl ::core::convert::From<leaveDelegatorsDelayCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: leaveDelegatorsDelayCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for leaveDelegatorsDelayCall {
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
            impl ::core::convert::From<leaveDelegatorsDelayReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: leaveDelegatorsDelayReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for leaveDelegatorsDelayReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for leaveDelegatorsDelayCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "leaveDelegatorsDelay()";
            const SELECTOR: [u8; 4] = [219u8, 138u8, 23u8, 58u8];
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
                        let r: leaveDelegatorsDelayReturn = r.into();
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
                        let r: leaveDelegatorsDelayReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `leaveOperatorsDelay()` and selector `0x4de8addc`.
```solidity
function leaveOperatorsDelay() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct leaveOperatorsDelayCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`leaveOperatorsDelay()`](leaveOperatorsDelayCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct leaveOperatorsDelayReturn {
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
            impl ::core::convert::From<leaveOperatorsDelayCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: leaveOperatorsDelayCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for leaveOperatorsDelayCall {
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
            impl ::core::convert::From<leaveOperatorsDelayReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: leaveOperatorsDelayReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for leaveOperatorsDelayReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for leaveOperatorsDelayCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "leaveOperatorsDelay()";
            const SELECTOR: [u8; 4] = [77u8, 232u8, 173u8, 220u8];
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
                        let r: leaveOperatorsDelayReturn = r.into();
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
                        let r: leaveOperatorsDelayReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `nativeEnabled()` and selector `0x77ab2cf3`.
```solidity
function nativeEnabled() external view returns (bool);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct nativeEnabledCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`nativeEnabled()`](nativeEnabledCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct nativeEnabledReturn {
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
            impl ::core::convert::From<nativeEnabledCall> for UnderlyingRustTuple<'_> {
                fn from(value: nativeEnabledCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for nativeEnabledCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
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
            impl ::core::convert::From<nativeEnabledReturn> for UnderlyingRustTuple<'_> {
                fn from(value: nativeEnabledReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for nativeEnabledReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for nativeEnabledCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = bool;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "nativeEnabled()";
            const SELECTOR: [u8; 4] = [119u8, 171u8, 44u8, 243u8];
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
                        let r: nativeEnabledReturn = r.into();
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
                        let r: nativeEnabledReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `nextSlashId(address)` and selector `0x96085673`.
```solidity
function nextSlashId(address) external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct nextSlashIdCall(pub alloy::sol_types::private::Address);
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`nextSlashId(address)`](nextSlashIdCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct nextSlashIdReturn {
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
            impl ::core::convert::From<nextSlashIdCall> for UnderlyingRustTuple<'_> {
                fn from(value: nextSlashIdCall) -> Self {
                    (value.0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for nextSlashIdCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self(tuple.0)
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
            impl ::core::convert::From<nextSlashIdReturn> for UnderlyingRustTuple<'_> {
                fn from(value: nextSlashIdReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for nextSlashIdReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for nextSlashIdCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Address,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "nextSlashId(address)";
            const SELECTOR: [u8; 4] = [150u8, 8u8, 86u8, 115u8];
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
                        &self.0,
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
                        let r: nextSlashIdReturn = r.into();
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
                        let r: nextSlashIdReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `operatorCommissionBps()` and selector `0x32273f61`.
```solidity
function operatorCommissionBps() external view returns (uint16);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct operatorCommissionBpsCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`operatorCommissionBps()`](operatorCommissionBpsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct operatorCommissionBpsReturn {
        #[allow(missing_docs)]
        pub _0: u16,
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
            impl ::core::convert::From<operatorCommissionBpsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: operatorCommissionBpsCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for operatorCommissionBpsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u16,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<operatorCommissionBpsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: operatorCommissionBpsReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for operatorCommissionBpsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for operatorCommissionBpsCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u16;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<16>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "operatorCommissionBps()";
            const SELECTOR: [u8; 4] = [50u8, 39u8, 63u8, 97u8];
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
                        16,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: operatorCommissionBpsReturn = r.into();
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
                        let r: operatorCommissionBpsReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `paused()` and selector `0x5c975abb`.
```solidity
function paused() external view returns (bool);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct pausedCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`paused()`](pausedCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct pausedReturn {
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
            impl ::core::convert::From<pausedCall> for UnderlyingRustTuple<'_> {
                fn from(value: pausedCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for pausedCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
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
            impl ::core::convert::From<pausedReturn> for UnderlyingRustTuple<'_> {
                fn from(value: pausedReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for pausedReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for pausedCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = bool;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "paused()";
            const SELECTOR: [u8; 4] = [92u8, 151u8, 90u8, 187u8];
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
                        let r: pausedReturn = r.into();
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
                        let r: pausedReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `proxiableUUID()` and selector `0x52d1902d`.
```solidity
function proxiableUUID() external view returns (bytes32);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct proxiableUUIDCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`proxiableUUID()`](proxiableUUIDCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct proxiableUUIDReturn {
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
            impl ::core::convert::From<proxiableUUIDCall> for UnderlyingRustTuple<'_> {
                fn from(value: proxiableUUIDCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for proxiableUUIDCall {
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
            impl ::core::convert::From<proxiableUUIDReturn> for UnderlyingRustTuple<'_> {
                fn from(value: proxiableUUIDReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for proxiableUUIDReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for proxiableUUIDCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::FixedBytes<32>;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<32>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "proxiableUUID()";
            const SELECTOR: [u8; 4] = [82u8, 209u8, 144u8, 45u8];
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
                        let r: proxiableUUIDReturn = r.into();
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
                        let r: proxiableUUIDReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `registerFacet(address)` and selector `0x46d163aa`.
```solidity
function registerFacet(address facet) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct registerFacetCall {
        #[allow(missing_docs)]
        pub facet: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`registerFacet(address)`](registerFacetCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct registerFacetReturn {}
    #[allow(
        non_camel_case_types,
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
            impl ::core::convert::From<registerFacetCall> for UnderlyingRustTuple<'_> {
                fn from(value: registerFacetCall) -> Self {
                    (value.facet,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for registerFacetCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { facet: tuple.0 }
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
            impl ::core::convert::From<registerFacetReturn> for UnderlyingRustTuple<'_> {
                fn from(value: registerFacetReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for registerFacetReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl registerFacetReturn {
            fn _tokenize(
                &self,
            ) -> <registerFacetCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for registerFacetCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Address,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = registerFacetReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "registerFacet(address)";
            const SELECTOR: [u8; 4] = [70u8, 209u8, 99u8, 170u8];
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
                        &self.facet,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                registerFacetReturn::_tokenize(ret)
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
    /**Function with signature `registerFacetSelectors(address,bytes4[])` and selector `0x19e82e61`.
```solidity
function registerFacetSelectors(address facet, bytes4[] memory selectors) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct registerFacetSelectorsCall {
        #[allow(missing_docs)]
        pub facet: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub selectors: alloy::sol_types::private::Vec<
            alloy::sol_types::private::FixedBytes<4>,
        >,
    }
    ///Container type for the return parameters of the [`registerFacetSelectors(address,bytes4[])`](registerFacetSelectorsCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct registerFacetSelectorsReturn {}
    #[allow(
        non_camel_case_types,
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
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Array<
                    alloy::sol_types::sol_data::FixedBytes<4>,
                >,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Address,
                alloy::sol_types::private::Vec<alloy::sol_types::private::FixedBytes<4>>,
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
            impl ::core::convert::From<registerFacetSelectorsCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: registerFacetSelectorsCall) -> Self {
                    (value.facet, value.selectors)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for registerFacetSelectorsCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        facet: tuple.0,
                        selectors: tuple.1,
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
            impl ::core::convert::From<registerFacetSelectorsReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: registerFacetSelectorsReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for registerFacetSelectorsReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl registerFacetSelectorsReturn {
            fn _tokenize(
                &self,
            ) -> <registerFacetSelectorsCall as alloy_sol_types::SolCall>::ReturnToken<
                '_,
            > {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for registerFacetSelectorsCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Array<
                    alloy::sol_types::sol_data::FixedBytes<4>,
                >,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = registerFacetSelectorsReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "registerFacetSelectors(address,bytes4[])";
            const SELECTOR: [u8; 4] = [25u8, 232u8, 46u8, 97u8];
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
                        &self.facet,
                    ),
                    <alloy::sol_types::sol_data::Array<
                        alloy::sol_types::sol_data::FixedBytes<4>,
                    > as alloy_sol_types::SolType>::tokenize(&self.selectors),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                registerFacetSelectorsReturn::_tokenize(ret)
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
    /**Function with signature `renounceRole(bytes32,address)` and selector `0x36568abe`.
```solidity
function renounceRole(bytes32 role, address callerConfirmation) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct renounceRoleCall {
        #[allow(missing_docs)]
        pub role: alloy::sol_types::private::FixedBytes<32>,
        #[allow(missing_docs)]
        pub callerConfirmation: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`renounceRole(bytes32,address)`](renounceRoleCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct renounceRoleReturn {}
    #[allow(
        non_camel_case_types,
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
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::FixedBytes<32>,
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
            impl ::core::convert::From<renounceRoleCall> for UnderlyingRustTuple<'_> {
                fn from(value: renounceRoleCall) -> Self {
                    (value.role, value.callerConfirmation)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for renounceRoleCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        role: tuple.0,
                        callerConfirmation: tuple.1,
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
            impl ::core::convert::From<renounceRoleReturn> for UnderlyingRustTuple<'_> {
                fn from(value: renounceRoleReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for renounceRoleReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl renounceRoleReturn {
            fn _tokenize(
                &self,
            ) -> <renounceRoleCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for renounceRoleCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = renounceRoleReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "renounceRole(bytes32,address)";
            const SELECTOR: [u8; 4] = [54u8, 86u8, 138u8, 190u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.role),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.callerConfirmation,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                renounceRoleReturn::_tokenize(ret)
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
    /**Function with signature `requireAdapters()` and selector `0xb54b2b9e`.
```solidity
function requireAdapters() external view returns (bool);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct requireAdaptersCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`requireAdapters()`](requireAdaptersCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct requireAdaptersReturn {
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
            impl ::core::convert::From<requireAdaptersCall> for UnderlyingRustTuple<'_> {
                fn from(value: requireAdaptersCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for requireAdaptersCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self
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
            impl ::core::convert::From<requireAdaptersReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: requireAdaptersReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for requireAdaptersReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for requireAdaptersCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = bool;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "requireAdapters()";
            const SELECTOR: [u8; 4] = [181u8, 75u8, 43u8, 158u8];
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
                        let r: requireAdaptersReturn = r.into();
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
                        let r: requireAdaptersReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `revokeRole(bytes32,address)` and selector `0xd547741f`.
```solidity
function revokeRole(bytes32 role, address account) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct revokeRoleCall {
        #[allow(missing_docs)]
        pub role: alloy::sol_types::private::FixedBytes<32>,
        #[allow(missing_docs)]
        pub account: alloy::sol_types::private::Address,
    }
    ///Container type for the return parameters of the [`revokeRole(bytes32,address)`](revokeRoleCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct revokeRoleReturn {}
    #[allow(
        non_camel_case_types,
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
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::FixedBytes<32>,
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
            impl ::core::convert::From<revokeRoleCall> for UnderlyingRustTuple<'_> {
                fn from(value: revokeRoleCall) -> Self {
                    (value.role, value.account)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for revokeRoleCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        role: tuple.0,
                        account: tuple.1,
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
            impl ::core::convert::From<revokeRoleReturn> for UnderlyingRustTuple<'_> {
                fn from(value: revokeRoleReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for revokeRoleReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl revokeRoleReturn {
            fn _tokenize(
                &self,
            ) -> <revokeRoleCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for revokeRoleCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Address,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = revokeRoleReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "revokeRole(bytes32,address)";
            const SELECTOR: [u8; 4] = [213u8, 71u8, 116u8, 31u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.role),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.account,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                revokeRoleReturn::_tokenize(ret)
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
    /**Function with signature `roundDuration()` and selector `0xf7cb789a`.
```solidity
function roundDuration() external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct roundDurationCall;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`roundDuration()`](roundDurationCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct roundDurationReturn {
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
            impl ::core::convert::From<roundDurationCall> for UnderlyingRustTuple<'_> {
                fn from(value: roundDurationCall) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for roundDurationCall {
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
            impl ::core::convert::From<roundDurationReturn> for UnderlyingRustTuple<'_> {
                fn from(value: roundDurationReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for roundDurationReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for roundDurationCall {
            type Parameters<'a> = ();
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "roundDuration()";
            const SELECTOR: [u8; 4] = [247u8, 203u8, 120u8, 154u8];
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
                        let r: roundDurationReturn = r.into();
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
                        let r: roundDurationReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `serviceSlashCount(uint64,address)` and selector `0x9722f4b9`.
```solidity
function serviceSlashCount(uint64, address) external view returns (uint64);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct serviceSlashCountCall {
        #[allow(missing_docs)]
        pub _0: u64,
        #[allow(missing_docs)]
        pub _1: alloy::sol_types::private::Address,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`serviceSlashCount(uint64,address)`](serviceSlashCountCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct serviceSlashCountReturn {
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
            impl ::core::convert::From<serviceSlashCountCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: serviceSlashCountCall) -> Self {
                    (value._0, value._1)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for serviceSlashCountCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0, _1: tuple.1 }
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
            impl ::core::convert::From<serviceSlashCountReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: serviceSlashCountReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for serviceSlashCountReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for serviceSlashCountCall {
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
            const SIGNATURE: &'static str = "serviceSlashCount(uint64,address)";
            const SELECTOR: [u8; 4] = [151u8, 34u8, 244u8, 185u8];
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
                        let r: serviceSlashCountReturn = r.into();
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
                        let r: serviceSlashCountReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `slashHistory(address,uint64)` and selector `0x0aa8b110`.
```solidity
function slashHistory(address, uint64) external view returns (uint64 round, uint64 serviceId, uint64 blueprintId, uint256 totalSlashed, uint256 exchangeRateBefore, uint256 exchangeRateAfter, bytes32 evidence);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct slashHistoryCall {
        #[allow(missing_docs)]
        pub _0: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub _1: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`slashHistory(address,uint64)`](slashHistoryCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct slashHistoryReturn {
        #[allow(missing_docs)]
        pub round: u64,
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub blueprintId: u64,
        #[allow(missing_docs)]
        pub totalSlashed: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub exchangeRateBefore: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub exchangeRateAfter: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub evidence: alloy::sol_types::private::FixedBytes<32>,
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
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Address, u64);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<slashHistoryCall> for UnderlyingRustTuple<'_> {
                fn from(value: slashHistoryCall) -> Self {
                    (value._0, value._1)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for slashHistoryCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0, _1: tuple.1 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::FixedBytes<32>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                u64,
                u64,
                alloy::sol_types::private::primitives::aliases::U256,
                alloy::sol_types::private::primitives::aliases::U256,
                alloy::sol_types::private::primitives::aliases::U256,
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
            impl ::core::convert::From<slashHistoryReturn> for UnderlyingRustTuple<'_> {
                fn from(value: slashHistoryReturn) -> Self {
                    (
                        value.round,
                        value.serviceId,
                        value.blueprintId,
                        value.totalSlashed,
                        value.exchangeRateBefore,
                        value.exchangeRateAfter,
                        value.evidence,
                    )
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for slashHistoryReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        round: tuple.0,
                        serviceId: tuple.1,
                        blueprintId: tuple.2,
                        totalSlashed: tuple.3,
                        exchangeRateBefore: tuple.4,
                        exchangeRateAfter: tuple.5,
                        evidence: tuple.6,
                    }
                }
            }
        }
        impl slashHistoryReturn {
            fn _tokenize(
                &self,
            ) -> <slashHistoryCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.round),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.blueprintId),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.totalSlashed),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.exchangeRateBefore),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.exchangeRateAfter),
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(&self.evidence),
                )
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for slashHistoryCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<64>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = slashHistoryReturn;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::FixedBytes<32>,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "slashHistory(address,uint64)";
            const SELECTOR: [u8; 4] = [10u8, 168u8, 177u8, 16u8];
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
                        &self._0,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self._1),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                slashHistoryReturn::_tokenize(ret)
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
    /**Function with signature `supportsInterface(bytes4)` and selector `0x01ffc9a7`.
```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct supportsInterfaceCall {
        #[allow(missing_docs)]
        pub interfaceId: alloy::sol_types::private::FixedBytes<4>,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`supportsInterface(bytes4)`](supportsInterfaceCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct supportsInterfaceReturn {
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
            type UnderlyingSolTuple<'a> = (alloy::sol_types::sol_data::FixedBytes<4>,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::FixedBytes<4>,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<supportsInterfaceCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: supportsInterfaceCall) -> Self {
                    (value.interfaceId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for supportsInterfaceCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { interfaceId: tuple.0 }
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
            impl ::core::convert::From<supportsInterfaceReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: supportsInterfaceReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for supportsInterfaceReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for supportsInterfaceCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::FixedBytes<4>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = bool;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Bool,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "supportsInterface(bytes4)";
            const SELECTOR: [u8; 4] = [1u8, 255u8, 201u8, 167u8];
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
                        4,
                    > as alloy_sol_types::SolType>::tokenize(&self.interfaceId),
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
                        let r: supportsInterfaceReturn = r.into();
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
                        let r: supportsInterfaceReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `upgradeToAndCall(address,bytes)` and selector `0x4f1ef286`.
```solidity
function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct upgradeToAndCallCall {
        #[allow(missing_docs)]
        pub newImplementation: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub data: alloy::sol_types::private::Bytes,
    }
    ///Container type for the return parameters of the [`upgradeToAndCall(address,bytes)`](upgradeToAndCallCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct upgradeToAndCallReturn {}
    #[allow(
        non_camel_case_types,
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
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Bytes,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                alloy::sol_types::private::Address,
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
            impl ::core::convert::From<upgradeToAndCallCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: upgradeToAndCallCall) -> Self {
                    (value.newImplementation, value.data)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for upgradeToAndCallCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        newImplementation: tuple.0,
                        data: tuple.1,
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
            impl ::core::convert::From<upgradeToAndCallReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: upgradeToAndCallReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for upgradeToAndCallReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl upgradeToAndCallReturn {
            fn _tokenize(
                &self,
            ) -> <upgradeToAndCallCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for upgradeToAndCallCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Bytes,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = upgradeToAndCallReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "upgradeToAndCall(address,bytes)";
            const SELECTOR: [u8; 4] = [79u8, 30u8, 242u8, 134u8];
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
                        &self.newImplementation,
                    ),
                    <alloy::sol_types::sol_data::Bytes as alloy_sol_types::SolType>::tokenize(
                        &self.data,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                upgradeToAndCallReturn::_tokenize(ret)
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
    ///Container for all the [`MultiAssetDelegation`](self) function calls.
    #[derive(Clone)]
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive()]
    pub enum MultiAssetDelegationCalls {
        #[allow(missing_docs)]
        ADMIN_ROLE(ADMIN_ROLECall),
        #[allow(missing_docs)]
        ASSET_MANAGER_ROLE(ASSET_MANAGER_ROLECall),
        #[allow(missing_docs)]
        BPS_DENOMINATOR(BPS_DENOMINATORCall),
        #[allow(missing_docs)]
        DEFAULT_ADMIN_ROLE(DEFAULT_ADMIN_ROLECall),
        #[allow(missing_docs)]
        LOCK_ONE_MONTH(LOCK_ONE_MONTHCall),
        #[allow(missing_docs)]
        LOCK_SIX_MONTHS(LOCK_SIX_MONTHSCall),
        #[allow(missing_docs)]
        LOCK_THREE_MONTHS(LOCK_THREE_MONTHSCall),
        #[allow(missing_docs)]
        LOCK_TWO_MONTHS(LOCK_TWO_MONTHSCall),
        #[allow(missing_docs)]
        MULTIPLIER_NONE(MULTIPLIER_NONECall),
        #[allow(missing_docs)]
        MULTIPLIER_ONE_MONTH(MULTIPLIER_ONE_MONTHCall),
        #[allow(missing_docs)]
        MULTIPLIER_SIX_MONTHS(MULTIPLIER_SIX_MONTHSCall),
        #[allow(missing_docs)]
        MULTIPLIER_THREE_MONTHS(MULTIPLIER_THREE_MONTHSCall),
        #[allow(missing_docs)]
        MULTIPLIER_TWO_MONTHS(MULTIPLIER_TWO_MONTHSCall),
        #[allow(missing_docs)]
        PRECISION(PRECISIONCall),
        #[allow(missing_docs)]
        SLASHER_ROLE(SLASHER_ROLECall),
        #[allow(missing_docs)]
        UPGRADE_INTERFACE_VERSION(UPGRADE_INTERFACE_VERSIONCall),
        #[allow(missing_docs)]
        blueprintSlashCount(blueprintSlashCountCall),
        #[allow(missing_docs)]
        clearFacetSelectors(clearFacetSelectorsCall),
        #[allow(missing_docs)]
        currentRound(currentRoundCall),
        #[allow(missing_docs)]
        delegationBondLessDelay(delegationBondLessDelayCall),
        #[allow(missing_docs)]
        facetForSelector(facetForSelectorCall),
        #[allow(missing_docs)]
        getAssetAdapter(getAssetAdapterCall),
        #[allow(missing_docs)]
        getOperatorSlashFactor(getOperatorSlashFactorCall),
        #[allow(missing_docs)]
        getRoleAdmin(getRoleAdminCall),
        #[allow(missing_docs)]
        getSlashCount(getSlashCountCall),
        #[allow(missing_docs)]
        getSlashCountForBlueprint(getSlashCountForBlueprintCall),
        #[allow(missing_docs)]
        getSlashCountForService(getSlashCountForServiceCall),
        #[allow(missing_docs)]
        getSlashImpact(getSlashImpactCall),
        #[allow(missing_docs)]
        getSlashRecord(getSlashRecordCall),
        #[allow(missing_docs)]
        getSnapshot(getSnapshotCall),
        #[allow(missing_docs)]
        grantRole(grantRoleCall),
        #[allow(missing_docs)]
        hasRole(hasRoleCall),
        #[allow(missing_docs)]
        initialize(initializeCall),
        #[allow(missing_docs)]
        lastRoundAdvance(lastRoundAdvanceCall),
        #[allow(missing_docs)]
        leaveDelegatorsDelay(leaveDelegatorsDelayCall),
        #[allow(missing_docs)]
        leaveOperatorsDelay(leaveOperatorsDelayCall),
        #[allow(missing_docs)]
        nativeEnabled(nativeEnabledCall),
        #[allow(missing_docs)]
        nextSlashId(nextSlashIdCall),
        #[allow(missing_docs)]
        operatorCommissionBps(operatorCommissionBpsCall),
        #[allow(missing_docs)]
        paused(pausedCall),
        #[allow(missing_docs)]
        proxiableUUID(proxiableUUIDCall),
        #[allow(missing_docs)]
        registerFacet(registerFacetCall),
        #[allow(missing_docs)]
        registerFacetSelectors(registerFacetSelectorsCall),
        #[allow(missing_docs)]
        renounceRole(renounceRoleCall),
        #[allow(missing_docs)]
        requireAdapters(requireAdaptersCall),
        #[allow(missing_docs)]
        revokeRole(revokeRoleCall),
        #[allow(missing_docs)]
        roundDuration(roundDurationCall),
        #[allow(missing_docs)]
        serviceSlashCount(serviceSlashCountCall),
        #[allow(missing_docs)]
        slashHistory(slashHistoryCall),
        #[allow(missing_docs)]
        supportsInterface(supportsInterfaceCall),
        #[allow(missing_docs)]
        upgradeToAndCall(upgradeToAndCallCall),
    }
    impl MultiAssetDelegationCalls {
        /// All the selectors of this enum.
        ///
        /// Note that the selectors might not be in the same order as the variants.
        /// No guarantees are made about the order of the selectors.
        ///
        /// Prefer using `SolInterface` methods instead.
        pub const SELECTORS: &'static [[u8; 4usize]] = &[
            [1u8, 255u8, 201u8, 167u8],
            [5u8, 214u8, 78u8, 56u8],
            [10u8, 168u8, 177u8, 16u8],
            [24u8, 5u8, 109u8, 194u8],
            [25u8, 232u8, 46u8, 97u8],
            [36u8, 138u8, 156u8, 163u8],
            [47u8, 47u8, 241u8, 93u8],
            [50u8, 39u8, 63u8, 97u8],
            [54u8, 86u8, 138u8, 190u8],
            [69u8, 62u8, 204u8, 234u8],
            [70u8, 209u8, 99u8, 170u8],
            [73u8, 98u8, 248u8, 143u8],
            [77u8, 232u8, 173u8, 220u8],
            [78u8, 156u8, 146u8, 154u8],
            [79u8, 30u8, 242u8, 134u8],
            [80u8, 149u8, 175u8, 100u8],
            [82u8, 209u8, 144u8, 45u8],
            [84u8, 222u8, 35u8, 32u8],
            [92u8, 151u8, 90u8, 187u8],
            [97u8, 93u8, 36u8, 222u8],
            [102u8, 195u8, 104u8, 117u8],
            [114u8, 181u8, 3u8, 45u8],
            [117u8, 178u8, 56u8, 252u8],
            [119u8, 171u8, 44u8, 243u8],
            [125u8, 249u8, 42u8, 218u8],
            [138u8, 25u8, 200u8, 188u8],
            [138u8, 127u8, 230u8, 15u8],
            [144u8, 131u8, 127u8, 244u8],
            [145u8, 209u8, 72u8, 84u8],
            [148u8, 148u8, 244u8, 38u8],
            [150u8, 8u8, 86u8, 115u8],
            [151u8, 34u8, 244u8, 185u8],
            [158u8, 135u8, 5u8, 133u8],
            [162u8, 23u8, 253u8, 223u8],
            [164u8, 87u8, 175u8, 61u8],
            [164u8, 179u8, 45u8, 232u8],
            [167u8, 250u8, 111u8, 152u8],
            [170u8, 245u8, 235u8, 104u8],
            [173u8, 60u8, 177u8, 204u8],
            [181u8, 75u8, 43u8, 158u8],
            [186u8, 5u8, 187u8, 245u8],
            [192u8, 116u8, 73u8, 226u8],
            [197u8, 80u8, 217u8, 56u8],
            [203u8, 182u8, 214u8, 189u8],
            [210u8, 122u8, 111u8, 6u8],
            [213u8, 71u8, 116u8, 31u8],
            [219u8, 138u8, 23u8, 58u8],
            [224u8, 125u8, 236u8, 41u8],
            [225u8, 164u8, 82u8, 24u8],
            [243u8, 201u8, 179u8, 17u8],
            [247u8, 203u8, 120u8, 154u8],
        ];
        /// The names of the variants in the same order as `SELECTORS`.
        pub const VARIANT_NAMES: &'static [&'static str] = &[
            ::core::stringify!(supportsInterface),
            ::core::stringify!(lastRoundAdvance),
            ::core::stringify!(slashHistory),
            ::core::stringify!(MULTIPLIER_ONE_MONTH),
            ::core::stringify!(registerFacetSelectors),
            ::core::stringify!(getRoleAdmin),
            ::core::stringify!(grantRole),
            ::core::stringify!(operatorCommissionBps),
            ::core::stringify!(renounceRole),
            ::core::stringify!(MULTIPLIER_SIX_MONTHS),
            ::core::stringify!(registerFacet),
            ::core::stringify!(MULTIPLIER_NONE),
            ::core::stringify!(leaveOperatorsDelay),
            ::core::stringify!(blueprintSlashCount),
            ::core::stringify!(upgradeToAndCall),
            ::core::stringify!(SLASHER_ROLE),
            ::core::stringify!(proxiableUUID),
            ::core::stringify!(MULTIPLIER_TWO_MONTHS),
            ::core::stringify!(paused),
            ::core::stringify!(getOperatorSlashFactor),
            ::core::stringify!(getSlashCount),
            ::core::stringify!(getSlashCountForService),
            ::core::stringify!(ADMIN_ROLE),
            ::core::stringify!(nativeEnabled),
            ::core::stringify!(LOCK_TWO_MONTHS),
            ::core::stringify!(currentRound),
            ::core::stringify!(getAssetAdapter),
            ::core::stringify!(facetForSelector),
            ::core::stringify!(hasRole),
            ::core::stringify!(getSlashImpact),
            ::core::stringify!(nextSlashId),
            ::core::stringify!(serviceSlashCount),
            ::core::stringify!(LOCK_ONE_MONTH),
            ::core::stringify!(DEFAULT_ADMIN_ROLE),
            ::core::stringify!(getSlashRecord),
            ::core::stringify!(ASSET_MANAGER_ROLE),
            ::core::stringify!(MULTIPLIER_THREE_MONTHS),
            ::core::stringify!(PRECISION),
            ::core::stringify!(UPGRADE_INTERFACE_VERSION),
            ::core::stringify!(requireAdapters),
            ::core::stringify!(delegationBondLessDelay),
            ::core::stringify!(getSnapshot),
            ::core::stringify!(getSlashCountForBlueprint),
            ::core::stringify!(initialize),
            ::core::stringify!(LOCK_THREE_MONTHS),
            ::core::stringify!(revokeRole),
            ::core::stringify!(leaveDelegatorsDelay),
            ::core::stringify!(clearFacetSelectors),
            ::core::stringify!(BPS_DENOMINATOR),
            ::core::stringify!(LOCK_SIX_MONTHS),
            ::core::stringify!(roundDuration),
        ];
        /// The signatures in the same order as `SELECTORS`.
        pub const SIGNATURES: &'static [&'static str] = &[
            <supportsInterfaceCall as alloy_sol_types::SolCall>::SIGNATURE,
            <lastRoundAdvanceCall as alloy_sol_types::SolCall>::SIGNATURE,
            <slashHistoryCall as alloy_sol_types::SolCall>::SIGNATURE,
            <MULTIPLIER_ONE_MONTHCall as alloy_sol_types::SolCall>::SIGNATURE,
            <registerFacetSelectorsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getRoleAdminCall as alloy_sol_types::SolCall>::SIGNATURE,
            <grantRoleCall as alloy_sol_types::SolCall>::SIGNATURE,
            <operatorCommissionBpsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <renounceRoleCall as alloy_sol_types::SolCall>::SIGNATURE,
            <MULTIPLIER_SIX_MONTHSCall as alloy_sol_types::SolCall>::SIGNATURE,
            <registerFacetCall as alloy_sol_types::SolCall>::SIGNATURE,
            <MULTIPLIER_NONECall as alloy_sol_types::SolCall>::SIGNATURE,
            <leaveOperatorsDelayCall as alloy_sol_types::SolCall>::SIGNATURE,
            <blueprintSlashCountCall as alloy_sol_types::SolCall>::SIGNATURE,
            <upgradeToAndCallCall as alloy_sol_types::SolCall>::SIGNATURE,
            <SLASHER_ROLECall as alloy_sol_types::SolCall>::SIGNATURE,
            <proxiableUUIDCall as alloy_sol_types::SolCall>::SIGNATURE,
            <MULTIPLIER_TWO_MONTHSCall as alloy_sol_types::SolCall>::SIGNATURE,
            <pausedCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getOperatorSlashFactorCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getSlashCountCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getSlashCountForServiceCall as alloy_sol_types::SolCall>::SIGNATURE,
            <ADMIN_ROLECall as alloy_sol_types::SolCall>::SIGNATURE,
            <nativeEnabledCall as alloy_sol_types::SolCall>::SIGNATURE,
            <LOCK_TWO_MONTHSCall as alloy_sol_types::SolCall>::SIGNATURE,
            <currentRoundCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getAssetAdapterCall as alloy_sol_types::SolCall>::SIGNATURE,
            <facetForSelectorCall as alloy_sol_types::SolCall>::SIGNATURE,
            <hasRoleCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getSlashImpactCall as alloy_sol_types::SolCall>::SIGNATURE,
            <nextSlashIdCall as alloy_sol_types::SolCall>::SIGNATURE,
            <serviceSlashCountCall as alloy_sol_types::SolCall>::SIGNATURE,
            <LOCK_ONE_MONTHCall as alloy_sol_types::SolCall>::SIGNATURE,
            <DEFAULT_ADMIN_ROLECall as alloy_sol_types::SolCall>::SIGNATURE,
            <getSlashRecordCall as alloy_sol_types::SolCall>::SIGNATURE,
            <ASSET_MANAGER_ROLECall as alloy_sol_types::SolCall>::SIGNATURE,
            <MULTIPLIER_THREE_MONTHSCall as alloy_sol_types::SolCall>::SIGNATURE,
            <PRECISIONCall as alloy_sol_types::SolCall>::SIGNATURE,
            <UPGRADE_INTERFACE_VERSIONCall as alloy_sol_types::SolCall>::SIGNATURE,
            <requireAdaptersCall as alloy_sol_types::SolCall>::SIGNATURE,
            <delegationBondLessDelayCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getSnapshotCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getSlashCountForBlueprintCall as alloy_sol_types::SolCall>::SIGNATURE,
            <initializeCall as alloy_sol_types::SolCall>::SIGNATURE,
            <LOCK_THREE_MONTHSCall as alloy_sol_types::SolCall>::SIGNATURE,
            <revokeRoleCall as alloy_sol_types::SolCall>::SIGNATURE,
            <leaveDelegatorsDelayCall as alloy_sol_types::SolCall>::SIGNATURE,
            <clearFacetSelectorsCall as alloy_sol_types::SolCall>::SIGNATURE,
            <BPS_DENOMINATORCall as alloy_sol_types::SolCall>::SIGNATURE,
            <LOCK_SIX_MONTHSCall as alloy_sol_types::SolCall>::SIGNATURE,
            <roundDurationCall as alloy_sol_types::SolCall>::SIGNATURE,
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
    impl alloy_sol_types::SolInterface for MultiAssetDelegationCalls {
        const NAME: &'static str = "MultiAssetDelegationCalls";
        const MIN_DATA_LENGTH: usize = 0usize;
        const COUNT: usize = 51usize;
        #[inline]
        fn selector(&self) -> [u8; 4] {
            match self {
                Self::ADMIN_ROLE(_) => {
                    <ADMIN_ROLECall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::ASSET_MANAGER_ROLE(_) => {
                    <ASSET_MANAGER_ROLECall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::BPS_DENOMINATOR(_) => {
                    <BPS_DENOMINATORCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::DEFAULT_ADMIN_ROLE(_) => {
                    <DEFAULT_ADMIN_ROLECall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::LOCK_ONE_MONTH(_) => {
                    <LOCK_ONE_MONTHCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::LOCK_SIX_MONTHS(_) => {
                    <LOCK_SIX_MONTHSCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::LOCK_THREE_MONTHS(_) => {
                    <LOCK_THREE_MONTHSCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::LOCK_TWO_MONTHS(_) => {
                    <LOCK_TWO_MONTHSCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::MULTIPLIER_NONE(_) => {
                    <MULTIPLIER_NONECall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::MULTIPLIER_ONE_MONTH(_) => {
                    <MULTIPLIER_ONE_MONTHCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::MULTIPLIER_SIX_MONTHS(_) => {
                    <MULTIPLIER_SIX_MONTHSCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::MULTIPLIER_THREE_MONTHS(_) => {
                    <MULTIPLIER_THREE_MONTHSCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::MULTIPLIER_TWO_MONTHS(_) => {
                    <MULTIPLIER_TWO_MONTHSCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::PRECISION(_) => {
                    <PRECISIONCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::SLASHER_ROLE(_) => {
                    <SLASHER_ROLECall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::UPGRADE_INTERFACE_VERSION(_) => {
                    <UPGRADE_INTERFACE_VERSIONCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::blueprintSlashCount(_) => {
                    <blueprintSlashCountCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::clearFacetSelectors(_) => {
                    <clearFacetSelectorsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::currentRound(_) => {
                    <currentRoundCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::delegationBondLessDelay(_) => {
                    <delegationBondLessDelayCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::facetForSelector(_) => {
                    <facetForSelectorCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getAssetAdapter(_) => {
                    <getAssetAdapterCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getOperatorSlashFactor(_) => {
                    <getOperatorSlashFactorCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getRoleAdmin(_) => {
                    <getRoleAdminCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getSlashCount(_) => {
                    <getSlashCountCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getSlashCountForBlueprint(_) => {
                    <getSlashCountForBlueprintCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getSlashCountForService(_) => {
                    <getSlashCountForServiceCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getSlashImpact(_) => {
                    <getSlashImpactCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getSlashRecord(_) => {
                    <getSlashRecordCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getSnapshot(_) => {
                    <getSnapshotCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::grantRole(_) => {
                    <grantRoleCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::hasRole(_) => <hasRoleCall as alloy_sol_types::SolCall>::SELECTOR,
                Self::initialize(_) => {
                    <initializeCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::lastRoundAdvance(_) => {
                    <lastRoundAdvanceCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::leaveDelegatorsDelay(_) => {
                    <leaveDelegatorsDelayCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::leaveOperatorsDelay(_) => {
                    <leaveOperatorsDelayCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::nativeEnabled(_) => {
                    <nativeEnabledCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::nextSlashId(_) => {
                    <nextSlashIdCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::operatorCommissionBps(_) => {
                    <operatorCommissionBpsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::paused(_) => <pausedCall as alloy_sol_types::SolCall>::SELECTOR,
                Self::proxiableUUID(_) => {
                    <proxiableUUIDCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::registerFacet(_) => {
                    <registerFacetCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::registerFacetSelectors(_) => {
                    <registerFacetSelectorsCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::renounceRole(_) => {
                    <renounceRoleCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::requireAdapters(_) => {
                    <requireAdaptersCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::revokeRole(_) => {
                    <revokeRoleCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::roundDuration(_) => {
                    <roundDurationCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::serviceSlashCount(_) => {
                    <serviceSlashCountCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::slashHistory(_) => {
                    <slashHistoryCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::supportsInterface(_) => {
                    <supportsInterfaceCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::upgradeToAndCall(_) => {
                    <upgradeToAndCallCall as alloy_sol_types::SolCall>::SELECTOR
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
            ) -> alloy_sol_types::Result<MultiAssetDelegationCalls>] = &[
                {
                    fn supportsInterface(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <supportsInterfaceCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::supportsInterface)
                    }
                    supportsInterface
                },
                {
                    fn lastRoundAdvance(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <lastRoundAdvanceCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::lastRoundAdvance)
                    }
                    lastRoundAdvance
                },
                {
                    fn slashHistory(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <slashHistoryCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::slashHistory)
                    }
                    slashHistory
                },
                {
                    fn MULTIPLIER_ONE_MONTH(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_ONE_MONTHCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_ONE_MONTH)
                    }
                    MULTIPLIER_ONE_MONTH
                },
                {
                    fn registerFacetSelectors(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <registerFacetSelectorsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::registerFacetSelectors)
                    }
                    registerFacetSelectors
                },
                {
                    fn getRoleAdmin(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getRoleAdminCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getRoleAdmin)
                    }
                    getRoleAdmin
                },
                {
                    fn grantRole(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <grantRoleCall as alloy_sol_types::SolCall>::abi_decode_raw(data)
                            .map(MultiAssetDelegationCalls::grantRole)
                    }
                    grantRole
                },
                {
                    fn operatorCommissionBps(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <operatorCommissionBpsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::operatorCommissionBps)
                    }
                    operatorCommissionBps
                },
                {
                    fn renounceRole(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <renounceRoleCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::renounceRole)
                    }
                    renounceRole
                },
                {
                    fn MULTIPLIER_SIX_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_SIX_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_SIX_MONTHS)
                    }
                    MULTIPLIER_SIX_MONTHS
                },
                {
                    fn registerFacet(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <registerFacetCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::registerFacet)
                    }
                    registerFacet
                },
                {
                    fn MULTIPLIER_NONE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_NONECall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_NONE)
                    }
                    MULTIPLIER_NONE
                },
                {
                    fn leaveOperatorsDelay(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <leaveOperatorsDelayCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::leaveOperatorsDelay)
                    }
                    leaveOperatorsDelay
                },
                {
                    fn blueprintSlashCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <blueprintSlashCountCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::blueprintSlashCount)
                    }
                    blueprintSlashCount
                },
                {
                    fn upgradeToAndCall(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <upgradeToAndCallCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::upgradeToAndCall)
                    }
                    upgradeToAndCall
                },
                {
                    fn SLASHER_ROLE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <SLASHER_ROLECall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::SLASHER_ROLE)
                    }
                    SLASHER_ROLE
                },
                {
                    fn proxiableUUID(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <proxiableUUIDCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::proxiableUUID)
                    }
                    proxiableUUID
                },
                {
                    fn MULTIPLIER_TWO_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_TWO_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_TWO_MONTHS)
                    }
                    MULTIPLIER_TWO_MONTHS
                },
                {
                    fn paused(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <pausedCall as alloy_sol_types::SolCall>::abi_decode_raw(data)
                            .map(MultiAssetDelegationCalls::paused)
                    }
                    paused
                },
                {
                    fn getOperatorSlashFactor(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getOperatorSlashFactorCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getOperatorSlashFactor)
                    }
                    getOperatorSlashFactor
                },
                {
                    fn getSlashCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashCountCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashCount)
                    }
                    getSlashCount
                },
                {
                    fn getSlashCountForService(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashCountForServiceCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashCountForService)
                    }
                    getSlashCountForService
                },
                {
                    fn ADMIN_ROLE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <ADMIN_ROLECall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::ADMIN_ROLE)
                    }
                    ADMIN_ROLE
                },
                {
                    fn nativeEnabled(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <nativeEnabledCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::nativeEnabled)
                    }
                    nativeEnabled
                },
                {
                    fn LOCK_TWO_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <LOCK_TWO_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::LOCK_TWO_MONTHS)
                    }
                    LOCK_TWO_MONTHS
                },
                {
                    fn currentRound(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <currentRoundCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::currentRound)
                    }
                    currentRound
                },
                {
                    fn getAssetAdapter(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getAssetAdapterCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getAssetAdapter)
                    }
                    getAssetAdapter
                },
                {
                    fn facetForSelector(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <facetForSelectorCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::facetForSelector)
                    }
                    facetForSelector
                },
                {
                    fn hasRole(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <hasRoleCall as alloy_sol_types::SolCall>::abi_decode_raw(data)
                            .map(MultiAssetDelegationCalls::hasRole)
                    }
                    hasRole
                },
                {
                    fn getSlashImpact(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashImpactCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashImpact)
                    }
                    getSlashImpact
                },
                {
                    fn nextSlashId(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <nextSlashIdCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::nextSlashId)
                    }
                    nextSlashId
                },
                {
                    fn serviceSlashCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <serviceSlashCountCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::serviceSlashCount)
                    }
                    serviceSlashCount
                },
                {
                    fn LOCK_ONE_MONTH(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <LOCK_ONE_MONTHCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::LOCK_ONE_MONTH)
                    }
                    LOCK_ONE_MONTH
                },
                {
                    fn DEFAULT_ADMIN_ROLE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <DEFAULT_ADMIN_ROLECall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::DEFAULT_ADMIN_ROLE)
                    }
                    DEFAULT_ADMIN_ROLE
                },
                {
                    fn getSlashRecord(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashRecordCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashRecord)
                    }
                    getSlashRecord
                },
                {
                    fn ASSET_MANAGER_ROLE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <ASSET_MANAGER_ROLECall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::ASSET_MANAGER_ROLE)
                    }
                    ASSET_MANAGER_ROLE
                },
                {
                    fn MULTIPLIER_THREE_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_THREE_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_THREE_MONTHS)
                    }
                    MULTIPLIER_THREE_MONTHS
                },
                {
                    fn PRECISION(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <PRECISIONCall as alloy_sol_types::SolCall>::abi_decode_raw(data)
                            .map(MultiAssetDelegationCalls::PRECISION)
                    }
                    PRECISION
                },
                {
                    fn UPGRADE_INTERFACE_VERSION(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <UPGRADE_INTERFACE_VERSIONCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::UPGRADE_INTERFACE_VERSION)
                    }
                    UPGRADE_INTERFACE_VERSION
                },
                {
                    fn requireAdapters(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <requireAdaptersCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::requireAdapters)
                    }
                    requireAdapters
                },
                {
                    fn delegationBondLessDelay(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <delegationBondLessDelayCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::delegationBondLessDelay)
                    }
                    delegationBondLessDelay
                },
                {
                    fn getSnapshot(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSnapshotCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSnapshot)
                    }
                    getSnapshot
                },
                {
                    fn getSlashCountForBlueprint(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashCountForBlueprintCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashCountForBlueprint)
                    }
                    getSlashCountForBlueprint
                },
                {
                    fn initialize(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <initializeCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::initialize)
                    }
                    initialize
                },
                {
                    fn LOCK_THREE_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <LOCK_THREE_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::LOCK_THREE_MONTHS)
                    }
                    LOCK_THREE_MONTHS
                },
                {
                    fn revokeRole(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <revokeRoleCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::revokeRole)
                    }
                    revokeRole
                },
                {
                    fn leaveDelegatorsDelay(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <leaveDelegatorsDelayCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::leaveDelegatorsDelay)
                    }
                    leaveDelegatorsDelay
                },
                {
                    fn clearFacetSelectors(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <clearFacetSelectorsCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::clearFacetSelectors)
                    }
                    clearFacetSelectors
                },
                {
                    fn BPS_DENOMINATOR(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <BPS_DENOMINATORCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::BPS_DENOMINATOR)
                    }
                    BPS_DENOMINATOR
                },
                {
                    fn LOCK_SIX_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <LOCK_SIX_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::LOCK_SIX_MONTHS)
                    }
                    LOCK_SIX_MONTHS
                },
                {
                    fn roundDuration(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <roundDurationCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::roundDuration)
                    }
                    roundDuration
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
            ) -> alloy_sol_types::Result<MultiAssetDelegationCalls>] = &[
                {
                    fn supportsInterface(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <supportsInterfaceCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::supportsInterface)
                    }
                    supportsInterface
                },
                {
                    fn lastRoundAdvance(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <lastRoundAdvanceCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::lastRoundAdvance)
                    }
                    lastRoundAdvance
                },
                {
                    fn slashHistory(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <slashHistoryCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::slashHistory)
                    }
                    slashHistory
                },
                {
                    fn MULTIPLIER_ONE_MONTH(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_ONE_MONTHCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_ONE_MONTH)
                    }
                    MULTIPLIER_ONE_MONTH
                },
                {
                    fn registerFacetSelectors(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <registerFacetSelectorsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::registerFacetSelectors)
                    }
                    registerFacetSelectors
                },
                {
                    fn getRoleAdmin(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getRoleAdminCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getRoleAdmin)
                    }
                    getRoleAdmin
                },
                {
                    fn grantRole(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <grantRoleCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::grantRole)
                    }
                    grantRole
                },
                {
                    fn operatorCommissionBps(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <operatorCommissionBpsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::operatorCommissionBps)
                    }
                    operatorCommissionBps
                },
                {
                    fn renounceRole(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <renounceRoleCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::renounceRole)
                    }
                    renounceRole
                },
                {
                    fn MULTIPLIER_SIX_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_SIX_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_SIX_MONTHS)
                    }
                    MULTIPLIER_SIX_MONTHS
                },
                {
                    fn registerFacet(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <registerFacetCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::registerFacet)
                    }
                    registerFacet
                },
                {
                    fn MULTIPLIER_NONE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_NONECall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_NONE)
                    }
                    MULTIPLIER_NONE
                },
                {
                    fn leaveOperatorsDelay(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <leaveOperatorsDelayCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::leaveOperatorsDelay)
                    }
                    leaveOperatorsDelay
                },
                {
                    fn blueprintSlashCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <blueprintSlashCountCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::blueprintSlashCount)
                    }
                    blueprintSlashCount
                },
                {
                    fn upgradeToAndCall(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <upgradeToAndCallCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::upgradeToAndCall)
                    }
                    upgradeToAndCall
                },
                {
                    fn SLASHER_ROLE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <SLASHER_ROLECall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::SLASHER_ROLE)
                    }
                    SLASHER_ROLE
                },
                {
                    fn proxiableUUID(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <proxiableUUIDCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::proxiableUUID)
                    }
                    proxiableUUID
                },
                {
                    fn MULTIPLIER_TWO_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_TWO_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_TWO_MONTHS)
                    }
                    MULTIPLIER_TWO_MONTHS
                },
                {
                    fn paused(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <pausedCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::paused)
                    }
                    paused
                },
                {
                    fn getOperatorSlashFactor(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getOperatorSlashFactorCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getOperatorSlashFactor)
                    }
                    getOperatorSlashFactor
                },
                {
                    fn getSlashCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashCountCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashCount)
                    }
                    getSlashCount
                },
                {
                    fn getSlashCountForService(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashCountForServiceCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashCountForService)
                    }
                    getSlashCountForService
                },
                {
                    fn ADMIN_ROLE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <ADMIN_ROLECall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::ADMIN_ROLE)
                    }
                    ADMIN_ROLE
                },
                {
                    fn nativeEnabled(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <nativeEnabledCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::nativeEnabled)
                    }
                    nativeEnabled
                },
                {
                    fn LOCK_TWO_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <LOCK_TWO_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::LOCK_TWO_MONTHS)
                    }
                    LOCK_TWO_MONTHS
                },
                {
                    fn currentRound(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <currentRoundCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::currentRound)
                    }
                    currentRound
                },
                {
                    fn getAssetAdapter(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getAssetAdapterCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getAssetAdapter)
                    }
                    getAssetAdapter
                },
                {
                    fn facetForSelector(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <facetForSelectorCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::facetForSelector)
                    }
                    facetForSelector
                },
                {
                    fn hasRole(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <hasRoleCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::hasRole)
                    }
                    hasRole
                },
                {
                    fn getSlashImpact(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashImpactCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashImpact)
                    }
                    getSlashImpact
                },
                {
                    fn nextSlashId(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <nextSlashIdCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::nextSlashId)
                    }
                    nextSlashId
                },
                {
                    fn serviceSlashCount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <serviceSlashCountCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::serviceSlashCount)
                    }
                    serviceSlashCount
                },
                {
                    fn LOCK_ONE_MONTH(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <LOCK_ONE_MONTHCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::LOCK_ONE_MONTH)
                    }
                    LOCK_ONE_MONTH
                },
                {
                    fn DEFAULT_ADMIN_ROLE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <DEFAULT_ADMIN_ROLECall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::DEFAULT_ADMIN_ROLE)
                    }
                    DEFAULT_ADMIN_ROLE
                },
                {
                    fn getSlashRecord(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashRecordCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashRecord)
                    }
                    getSlashRecord
                },
                {
                    fn ASSET_MANAGER_ROLE(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <ASSET_MANAGER_ROLECall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::ASSET_MANAGER_ROLE)
                    }
                    ASSET_MANAGER_ROLE
                },
                {
                    fn MULTIPLIER_THREE_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <MULTIPLIER_THREE_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::MULTIPLIER_THREE_MONTHS)
                    }
                    MULTIPLIER_THREE_MONTHS
                },
                {
                    fn PRECISION(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <PRECISIONCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::PRECISION)
                    }
                    PRECISION
                },
                {
                    fn UPGRADE_INTERFACE_VERSION(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <UPGRADE_INTERFACE_VERSIONCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::UPGRADE_INTERFACE_VERSION)
                    }
                    UPGRADE_INTERFACE_VERSION
                },
                {
                    fn requireAdapters(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <requireAdaptersCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::requireAdapters)
                    }
                    requireAdapters
                },
                {
                    fn delegationBondLessDelay(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <delegationBondLessDelayCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::delegationBondLessDelay)
                    }
                    delegationBondLessDelay
                },
                {
                    fn getSnapshot(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSnapshotCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSnapshot)
                    }
                    getSnapshot
                },
                {
                    fn getSlashCountForBlueprint(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <getSlashCountForBlueprintCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::getSlashCountForBlueprint)
                    }
                    getSlashCountForBlueprint
                },
                {
                    fn initialize(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <initializeCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::initialize)
                    }
                    initialize
                },
                {
                    fn LOCK_THREE_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <LOCK_THREE_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::LOCK_THREE_MONTHS)
                    }
                    LOCK_THREE_MONTHS
                },
                {
                    fn revokeRole(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <revokeRoleCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::revokeRole)
                    }
                    revokeRole
                },
                {
                    fn leaveDelegatorsDelay(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <leaveDelegatorsDelayCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::leaveDelegatorsDelay)
                    }
                    leaveDelegatorsDelay
                },
                {
                    fn clearFacetSelectors(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <clearFacetSelectorsCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::clearFacetSelectors)
                    }
                    clearFacetSelectors
                },
                {
                    fn BPS_DENOMINATOR(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <BPS_DENOMINATORCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::BPS_DENOMINATOR)
                    }
                    BPS_DENOMINATOR
                },
                {
                    fn LOCK_SIX_MONTHS(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <LOCK_SIX_MONTHSCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::LOCK_SIX_MONTHS)
                    }
                    LOCK_SIX_MONTHS
                },
                {
                    fn roundDuration(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationCalls> {
                        <roundDurationCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationCalls::roundDuration)
                    }
                    roundDuration
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
                Self::ADMIN_ROLE(inner) => {
                    <ADMIN_ROLECall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::ASSET_MANAGER_ROLE(inner) => {
                    <ASSET_MANAGER_ROLECall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::BPS_DENOMINATOR(inner) => {
                    <BPS_DENOMINATORCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::DEFAULT_ADMIN_ROLE(inner) => {
                    <DEFAULT_ADMIN_ROLECall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::LOCK_ONE_MONTH(inner) => {
                    <LOCK_ONE_MONTHCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::LOCK_SIX_MONTHS(inner) => {
                    <LOCK_SIX_MONTHSCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::LOCK_THREE_MONTHS(inner) => {
                    <LOCK_THREE_MONTHSCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::LOCK_TWO_MONTHS(inner) => {
                    <LOCK_TWO_MONTHSCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::MULTIPLIER_NONE(inner) => {
                    <MULTIPLIER_NONECall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::MULTIPLIER_ONE_MONTH(inner) => {
                    <MULTIPLIER_ONE_MONTHCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::MULTIPLIER_SIX_MONTHS(inner) => {
                    <MULTIPLIER_SIX_MONTHSCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::MULTIPLIER_THREE_MONTHS(inner) => {
                    <MULTIPLIER_THREE_MONTHSCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::MULTIPLIER_TWO_MONTHS(inner) => {
                    <MULTIPLIER_TWO_MONTHSCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::PRECISION(inner) => {
                    <PRECISIONCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::SLASHER_ROLE(inner) => {
                    <SLASHER_ROLECall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::UPGRADE_INTERFACE_VERSION(inner) => {
                    <UPGRADE_INTERFACE_VERSIONCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::blueprintSlashCount(inner) => {
                    <blueprintSlashCountCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::clearFacetSelectors(inner) => {
                    <clearFacetSelectorsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::currentRound(inner) => {
                    <currentRoundCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::delegationBondLessDelay(inner) => {
                    <delegationBondLessDelayCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::facetForSelector(inner) => {
                    <facetForSelectorCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getAssetAdapter(inner) => {
                    <getAssetAdapterCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getOperatorSlashFactor(inner) => {
                    <getOperatorSlashFactorCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getRoleAdmin(inner) => {
                    <getRoleAdminCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getSlashCount(inner) => {
                    <getSlashCountCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getSlashCountForBlueprint(inner) => {
                    <getSlashCountForBlueprintCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getSlashCountForService(inner) => {
                    <getSlashCountForServiceCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getSlashImpact(inner) => {
                    <getSlashImpactCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getSlashRecord(inner) => {
                    <getSlashRecordCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getSnapshot(inner) => {
                    <getSnapshotCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::grantRole(inner) => {
                    <grantRoleCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::hasRole(inner) => {
                    <hasRoleCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::initialize(inner) => {
                    <initializeCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::lastRoundAdvance(inner) => {
                    <lastRoundAdvanceCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::leaveDelegatorsDelay(inner) => {
                    <leaveDelegatorsDelayCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::leaveOperatorsDelay(inner) => {
                    <leaveOperatorsDelayCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::nativeEnabled(inner) => {
                    <nativeEnabledCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::nextSlashId(inner) => {
                    <nextSlashIdCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::operatorCommissionBps(inner) => {
                    <operatorCommissionBpsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::paused(inner) => {
                    <pausedCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::proxiableUUID(inner) => {
                    <proxiableUUIDCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::registerFacet(inner) => {
                    <registerFacetCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::registerFacetSelectors(inner) => {
                    <registerFacetSelectorsCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::renounceRole(inner) => {
                    <renounceRoleCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::requireAdapters(inner) => {
                    <requireAdaptersCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::revokeRole(inner) => {
                    <revokeRoleCall as alloy_sol_types::SolCall>::abi_encoded_size(inner)
                }
                Self::roundDuration(inner) => {
                    <roundDurationCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::serviceSlashCount(inner) => {
                    <serviceSlashCountCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::slashHistory(inner) => {
                    <slashHistoryCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::supportsInterface(inner) => {
                    <supportsInterfaceCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::upgradeToAndCall(inner) => {
                    <upgradeToAndCallCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
            }
        }
        #[inline]
        fn abi_encode_raw(&self, out: &mut alloy_sol_types::private::Vec<u8>) {
            match self {
                Self::ADMIN_ROLE(inner) => {
                    <ADMIN_ROLECall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::ASSET_MANAGER_ROLE(inner) => {
                    <ASSET_MANAGER_ROLECall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::BPS_DENOMINATOR(inner) => {
                    <BPS_DENOMINATORCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::DEFAULT_ADMIN_ROLE(inner) => {
                    <DEFAULT_ADMIN_ROLECall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::LOCK_ONE_MONTH(inner) => {
                    <LOCK_ONE_MONTHCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::LOCK_SIX_MONTHS(inner) => {
                    <LOCK_SIX_MONTHSCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::LOCK_THREE_MONTHS(inner) => {
                    <LOCK_THREE_MONTHSCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::LOCK_TWO_MONTHS(inner) => {
                    <LOCK_TWO_MONTHSCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::MULTIPLIER_NONE(inner) => {
                    <MULTIPLIER_NONECall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::MULTIPLIER_ONE_MONTH(inner) => {
                    <MULTIPLIER_ONE_MONTHCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::MULTIPLIER_SIX_MONTHS(inner) => {
                    <MULTIPLIER_SIX_MONTHSCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::MULTIPLIER_THREE_MONTHS(inner) => {
                    <MULTIPLIER_THREE_MONTHSCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::MULTIPLIER_TWO_MONTHS(inner) => {
                    <MULTIPLIER_TWO_MONTHSCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::PRECISION(inner) => {
                    <PRECISIONCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::SLASHER_ROLE(inner) => {
                    <SLASHER_ROLECall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::UPGRADE_INTERFACE_VERSION(inner) => {
                    <UPGRADE_INTERFACE_VERSIONCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::blueprintSlashCount(inner) => {
                    <blueprintSlashCountCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::clearFacetSelectors(inner) => {
                    <clearFacetSelectorsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::currentRound(inner) => {
                    <currentRoundCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::delegationBondLessDelay(inner) => {
                    <delegationBondLessDelayCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::facetForSelector(inner) => {
                    <facetForSelectorCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getAssetAdapter(inner) => {
                    <getAssetAdapterCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getOperatorSlashFactor(inner) => {
                    <getOperatorSlashFactorCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getRoleAdmin(inner) => {
                    <getRoleAdminCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getSlashCount(inner) => {
                    <getSlashCountCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getSlashCountForBlueprint(inner) => {
                    <getSlashCountForBlueprintCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getSlashCountForService(inner) => {
                    <getSlashCountForServiceCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getSlashImpact(inner) => {
                    <getSlashImpactCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getSlashRecord(inner) => {
                    <getSlashRecordCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getSnapshot(inner) => {
                    <getSnapshotCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::grantRole(inner) => {
                    <grantRoleCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::hasRole(inner) => {
                    <hasRoleCall as alloy_sol_types::SolCall>::abi_encode_raw(inner, out)
                }
                Self::initialize(inner) => {
                    <initializeCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::lastRoundAdvance(inner) => {
                    <lastRoundAdvanceCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::leaveDelegatorsDelay(inner) => {
                    <leaveDelegatorsDelayCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::leaveOperatorsDelay(inner) => {
                    <leaveOperatorsDelayCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::nativeEnabled(inner) => {
                    <nativeEnabledCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::nextSlashId(inner) => {
                    <nextSlashIdCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::operatorCommissionBps(inner) => {
                    <operatorCommissionBpsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::paused(inner) => {
                    <pausedCall as alloy_sol_types::SolCall>::abi_encode_raw(inner, out)
                }
                Self::proxiableUUID(inner) => {
                    <proxiableUUIDCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::registerFacet(inner) => {
                    <registerFacetCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::registerFacetSelectors(inner) => {
                    <registerFacetSelectorsCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::renounceRole(inner) => {
                    <renounceRoleCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::requireAdapters(inner) => {
                    <requireAdaptersCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::revokeRole(inner) => {
                    <revokeRoleCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::roundDuration(inner) => {
                    <roundDurationCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::serviceSlashCount(inner) => {
                    <serviceSlashCountCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::slashHistory(inner) => {
                    <slashHistoryCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::supportsInterface(inner) => {
                    <supportsInterfaceCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::upgradeToAndCall(inner) => {
                    <upgradeToAndCallCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
            }
        }
    }
    ///Container for all the [`MultiAssetDelegation`](self) custom errors.
    #[derive(Clone)]
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Debug, PartialEq, Eq, Hash)]
    pub enum MultiAssetDelegationErrors {
        #[allow(missing_docs)]
        AccessControlBadConfirmation(AccessControlBadConfirmation),
        #[allow(missing_docs)]
        AccessControlUnauthorizedAccount(AccessControlUnauthorizedAccount),
        #[allow(missing_docs)]
        AddressEmptyCode(AddressEmptyCode),
        #[allow(missing_docs)]
        ERC1967InvalidImplementation(ERC1967InvalidImplementation),
        #[allow(missing_docs)]
        ERC1967NonPayable(ERC1967NonPayable),
        #[allow(missing_docs)]
        EnforcedPause(EnforcedPause),
        #[allow(missing_docs)]
        ExpectedPause(ExpectedPause),
        #[allow(missing_docs)]
        FailedCall(FailedCall),
        #[allow(missing_docs)]
        InvalidInitialization(InvalidInitialization),
        #[allow(missing_docs)]
        NotAContract(NotAContract),
        #[allow(missing_docs)]
        NotInitializing(NotInitializing),
        #[allow(missing_docs)]
        ReentrancyGuardReentrantCall(ReentrancyGuardReentrantCall),
        #[allow(missing_docs)]
        SelectorAlreadyRegistered(SelectorAlreadyRegistered),
        #[allow(missing_docs)]
        UUPSUnauthorizedCallContext(UUPSUnauthorizedCallContext),
        #[allow(missing_docs)]
        UUPSUnsupportedProxiableUUID(UUPSUnsupportedProxiableUUID),
        #[allow(missing_docs)]
        UnknownSelector(UnknownSelector),
        #[allow(missing_docs)]
        ZeroAddress(ZeroAddress),
    }
    impl MultiAssetDelegationErrors {
        /// All the selectors of this enum.
        ///
        /// Note that the selectors might not be in the same order as the variants.
        /// No guarantees are made about the order of the selectors.
        ///
        /// Prefer using `SolInterface` methods instead.
        pub const SELECTORS: &'static [[u8; 4usize]] = &[
            [62u8, 229u8, 174u8, 181u8],
            [76u8, 156u8, 140u8, 227u8],
            [102u8, 151u8, 178u8, 50u8],
            [133u8, 112u8, 141u8, 72u8],
            [138u8, 139u8, 65u8, 236u8],
            [141u8, 252u8, 32u8, 43u8],
            [153u8, 150u8, 179u8, 21u8],
            [170u8, 29u8, 73u8, 164u8],
            [179u8, 152u8, 151u8, 159u8],
            [194u8, 168u8, 37u8, 245u8],
            [214u8, 189u8, 162u8, 117u8],
            [215u8, 230u8, 188u8, 248u8],
            [217u8, 46u8, 35u8, 61u8],
            [217u8, 60u8, 6u8, 101u8],
            [224u8, 124u8, 141u8, 186u8],
            [226u8, 81u8, 125u8, 63u8],
            [249u8, 46u8, 232u8, 169u8],
        ];
        /// The names of the variants in the same order as `SELECTORS`.
        pub const VARIANT_NAMES: &'static [&'static str] = &[
            ::core::stringify!(ReentrancyGuardReentrantCall),
            ::core::stringify!(ERC1967InvalidImplementation),
            ::core::stringify!(AccessControlBadConfirmation),
            ::core::stringify!(SelectorAlreadyRegistered),
            ::core::stringify!(NotAContract),
            ::core::stringify!(ExpectedPause),
            ::core::stringify!(AddressEmptyCode),
            ::core::stringify!(UUPSUnsupportedProxiableUUID),
            ::core::stringify!(ERC1967NonPayable),
            ::core::stringify!(UnknownSelector),
            ::core::stringify!(FailedCall),
            ::core::stringify!(NotInitializing),
            ::core::stringify!(ZeroAddress),
            ::core::stringify!(EnforcedPause),
            ::core::stringify!(UUPSUnauthorizedCallContext),
            ::core::stringify!(AccessControlUnauthorizedAccount),
            ::core::stringify!(InvalidInitialization),
        ];
        /// The signatures in the same order as `SELECTORS`.
        pub const SIGNATURES: &'static [&'static str] = &[
            <ReentrancyGuardReentrantCall as alloy_sol_types::SolError>::SIGNATURE,
            <ERC1967InvalidImplementation as alloy_sol_types::SolError>::SIGNATURE,
            <AccessControlBadConfirmation as alloy_sol_types::SolError>::SIGNATURE,
            <SelectorAlreadyRegistered as alloy_sol_types::SolError>::SIGNATURE,
            <NotAContract as alloy_sol_types::SolError>::SIGNATURE,
            <ExpectedPause as alloy_sol_types::SolError>::SIGNATURE,
            <AddressEmptyCode as alloy_sol_types::SolError>::SIGNATURE,
            <UUPSUnsupportedProxiableUUID as alloy_sol_types::SolError>::SIGNATURE,
            <ERC1967NonPayable as alloy_sol_types::SolError>::SIGNATURE,
            <UnknownSelector as alloy_sol_types::SolError>::SIGNATURE,
            <FailedCall as alloy_sol_types::SolError>::SIGNATURE,
            <NotInitializing as alloy_sol_types::SolError>::SIGNATURE,
            <ZeroAddress as alloy_sol_types::SolError>::SIGNATURE,
            <EnforcedPause as alloy_sol_types::SolError>::SIGNATURE,
            <UUPSUnauthorizedCallContext as alloy_sol_types::SolError>::SIGNATURE,
            <AccessControlUnauthorizedAccount as alloy_sol_types::SolError>::SIGNATURE,
            <InvalidInitialization as alloy_sol_types::SolError>::SIGNATURE,
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
    impl alloy_sol_types::SolInterface for MultiAssetDelegationErrors {
        const NAME: &'static str = "MultiAssetDelegationErrors";
        const MIN_DATA_LENGTH: usize = 0usize;
        const COUNT: usize = 17usize;
        #[inline]
        fn selector(&self) -> [u8; 4] {
            match self {
                Self::AccessControlBadConfirmation(_) => {
                    <AccessControlBadConfirmation as alloy_sol_types::SolError>::SELECTOR
                }
                Self::AccessControlUnauthorizedAccount(_) => {
                    <AccessControlUnauthorizedAccount as alloy_sol_types::SolError>::SELECTOR
                }
                Self::AddressEmptyCode(_) => {
                    <AddressEmptyCode as alloy_sol_types::SolError>::SELECTOR
                }
                Self::ERC1967InvalidImplementation(_) => {
                    <ERC1967InvalidImplementation as alloy_sol_types::SolError>::SELECTOR
                }
                Self::ERC1967NonPayable(_) => {
                    <ERC1967NonPayable as alloy_sol_types::SolError>::SELECTOR
                }
                Self::EnforcedPause(_) => {
                    <EnforcedPause as alloy_sol_types::SolError>::SELECTOR
                }
                Self::ExpectedPause(_) => {
                    <ExpectedPause as alloy_sol_types::SolError>::SELECTOR
                }
                Self::FailedCall(_) => {
                    <FailedCall as alloy_sol_types::SolError>::SELECTOR
                }
                Self::InvalidInitialization(_) => {
                    <InvalidInitialization as alloy_sol_types::SolError>::SELECTOR
                }
                Self::NotAContract(_) => {
                    <NotAContract as alloy_sol_types::SolError>::SELECTOR
                }
                Self::NotInitializing(_) => {
                    <NotInitializing as alloy_sol_types::SolError>::SELECTOR
                }
                Self::ReentrancyGuardReentrantCall(_) => {
                    <ReentrancyGuardReentrantCall as alloy_sol_types::SolError>::SELECTOR
                }
                Self::SelectorAlreadyRegistered(_) => {
                    <SelectorAlreadyRegistered as alloy_sol_types::SolError>::SELECTOR
                }
                Self::UUPSUnauthorizedCallContext(_) => {
                    <UUPSUnauthorizedCallContext as alloy_sol_types::SolError>::SELECTOR
                }
                Self::UUPSUnsupportedProxiableUUID(_) => {
                    <UUPSUnsupportedProxiableUUID as alloy_sol_types::SolError>::SELECTOR
                }
                Self::UnknownSelector(_) => {
                    <UnknownSelector as alloy_sol_types::SolError>::SELECTOR
                }
                Self::ZeroAddress(_) => {
                    <ZeroAddress as alloy_sol_types::SolError>::SELECTOR
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
            ) -> alloy_sol_types::Result<MultiAssetDelegationErrors>] = &[
                {
                    fn ReentrancyGuardReentrantCall(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ReentrancyGuardReentrantCall as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::ReentrancyGuardReentrantCall,
                            )
                    }
                    ReentrancyGuardReentrantCall
                },
                {
                    fn ERC1967InvalidImplementation(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ERC1967InvalidImplementation as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::ERC1967InvalidImplementation,
                            )
                    }
                    ERC1967InvalidImplementation
                },
                {
                    fn AccessControlBadConfirmation(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <AccessControlBadConfirmation as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::AccessControlBadConfirmation,
                            )
                    }
                    AccessControlBadConfirmation
                },
                {
                    fn SelectorAlreadyRegistered(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <SelectorAlreadyRegistered as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::SelectorAlreadyRegistered)
                    }
                    SelectorAlreadyRegistered
                },
                {
                    fn NotAContract(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <NotAContract as alloy_sol_types::SolError>::abi_decode_raw(data)
                            .map(MultiAssetDelegationErrors::NotAContract)
                    }
                    NotAContract
                },
                {
                    fn ExpectedPause(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ExpectedPause as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::ExpectedPause)
                    }
                    ExpectedPause
                },
                {
                    fn AddressEmptyCode(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <AddressEmptyCode as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::AddressEmptyCode)
                    }
                    AddressEmptyCode
                },
                {
                    fn UUPSUnsupportedProxiableUUID(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <UUPSUnsupportedProxiableUUID as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::UUPSUnsupportedProxiableUUID,
                            )
                    }
                    UUPSUnsupportedProxiableUUID
                },
                {
                    fn ERC1967NonPayable(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ERC1967NonPayable as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::ERC1967NonPayable)
                    }
                    ERC1967NonPayable
                },
                {
                    fn UnknownSelector(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <UnknownSelector as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::UnknownSelector)
                    }
                    UnknownSelector
                },
                {
                    fn FailedCall(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <FailedCall as alloy_sol_types::SolError>::abi_decode_raw(data)
                            .map(MultiAssetDelegationErrors::FailedCall)
                    }
                    FailedCall
                },
                {
                    fn NotInitializing(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <NotInitializing as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::NotInitializing)
                    }
                    NotInitializing
                },
                {
                    fn ZeroAddress(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ZeroAddress as alloy_sol_types::SolError>::abi_decode_raw(data)
                            .map(MultiAssetDelegationErrors::ZeroAddress)
                    }
                    ZeroAddress
                },
                {
                    fn EnforcedPause(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <EnforcedPause as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::EnforcedPause)
                    }
                    EnforcedPause
                },
                {
                    fn UUPSUnauthorizedCallContext(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <UUPSUnauthorizedCallContext as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::UUPSUnauthorizedCallContext)
                    }
                    UUPSUnauthorizedCallContext
                },
                {
                    fn AccessControlUnauthorizedAccount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <AccessControlUnauthorizedAccount as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::AccessControlUnauthorizedAccount,
                            )
                    }
                    AccessControlUnauthorizedAccount
                },
                {
                    fn InvalidInitialization(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <InvalidInitialization as alloy_sol_types::SolError>::abi_decode_raw(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::InvalidInitialization)
                    }
                    InvalidInitialization
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
            ) -> alloy_sol_types::Result<MultiAssetDelegationErrors>] = &[
                {
                    fn ReentrancyGuardReentrantCall(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ReentrancyGuardReentrantCall as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::ReentrancyGuardReentrantCall,
                            )
                    }
                    ReentrancyGuardReentrantCall
                },
                {
                    fn ERC1967InvalidImplementation(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ERC1967InvalidImplementation as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::ERC1967InvalidImplementation,
                            )
                    }
                    ERC1967InvalidImplementation
                },
                {
                    fn AccessControlBadConfirmation(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <AccessControlBadConfirmation as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::AccessControlBadConfirmation,
                            )
                    }
                    AccessControlBadConfirmation
                },
                {
                    fn SelectorAlreadyRegistered(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <SelectorAlreadyRegistered as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::SelectorAlreadyRegistered)
                    }
                    SelectorAlreadyRegistered
                },
                {
                    fn NotAContract(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <NotAContract as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::NotAContract)
                    }
                    NotAContract
                },
                {
                    fn ExpectedPause(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ExpectedPause as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::ExpectedPause)
                    }
                    ExpectedPause
                },
                {
                    fn AddressEmptyCode(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <AddressEmptyCode as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::AddressEmptyCode)
                    }
                    AddressEmptyCode
                },
                {
                    fn UUPSUnsupportedProxiableUUID(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <UUPSUnsupportedProxiableUUID as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::UUPSUnsupportedProxiableUUID,
                            )
                    }
                    UUPSUnsupportedProxiableUUID
                },
                {
                    fn ERC1967NonPayable(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ERC1967NonPayable as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::ERC1967NonPayable)
                    }
                    ERC1967NonPayable
                },
                {
                    fn UnknownSelector(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <UnknownSelector as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::UnknownSelector)
                    }
                    UnknownSelector
                },
                {
                    fn FailedCall(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <FailedCall as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::FailedCall)
                    }
                    FailedCall
                },
                {
                    fn NotInitializing(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <NotInitializing as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::NotInitializing)
                    }
                    NotInitializing
                },
                {
                    fn ZeroAddress(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <ZeroAddress as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::ZeroAddress)
                    }
                    ZeroAddress
                },
                {
                    fn EnforcedPause(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <EnforcedPause as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::EnforcedPause)
                    }
                    EnforcedPause
                },
                {
                    fn UUPSUnauthorizedCallContext(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <UUPSUnauthorizedCallContext as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::UUPSUnauthorizedCallContext)
                    }
                    UUPSUnauthorizedCallContext
                },
                {
                    fn AccessControlUnauthorizedAccount(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <AccessControlUnauthorizedAccount as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(
                                MultiAssetDelegationErrors::AccessControlUnauthorizedAccount,
                            )
                    }
                    AccessControlUnauthorizedAccount
                },
                {
                    fn InvalidInitialization(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<MultiAssetDelegationErrors> {
                        <InvalidInitialization as alloy_sol_types::SolError>::abi_decode_raw_validate(
                                data,
                            )
                            .map(MultiAssetDelegationErrors::InvalidInitialization)
                    }
                    InvalidInitialization
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
                Self::AccessControlBadConfirmation(inner) => {
                    <AccessControlBadConfirmation as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::AccessControlUnauthorizedAccount(inner) => {
                    <AccessControlUnauthorizedAccount as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::AddressEmptyCode(inner) => {
                    <AddressEmptyCode as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::ERC1967InvalidImplementation(inner) => {
                    <ERC1967InvalidImplementation as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::ERC1967NonPayable(inner) => {
                    <ERC1967NonPayable as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::EnforcedPause(inner) => {
                    <EnforcedPause as alloy_sol_types::SolError>::abi_encoded_size(inner)
                }
                Self::ExpectedPause(inner) => {
                    <ExpectedPause as alloy_sol_types::SolError>::abi_encoded_size(inner)
                }
                Self::FailedCall(inner) => {
                    <FailedCall as alloy_sol_types::SolError>::abi_encoded_size(inner)
                }
                Self::InvalidInitialization(inner) => {
                    <InvalidInitialization as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::NotAContract(inner) => {
                    <NotAContract as alloy_sol_types::SolError>::abi_encoded_size(inner)
                }
                Self::NotInitializing(inner) => {
                    <NotInitializing as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::ReentrancyGuardReentrantCall(inner) => {
                    <ReentrancyGuardReentrantCall as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::SelectorAlreadyRegistered(inner) => {
                    <SelectorAlreadyRegistered as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::UUPSUnauthorizedCallContext(inner) => {
                    <UUPSUnauthorizedCallContext as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::UUPSUnsupportedProxiableUUID(inner) => {
                    <UUPSUnsupportedProxiableUUID as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::UnknownSelector(inner) => {
                    <UnknownSelector as alloy_sol_types::SolError>::abi_encoded_size(
                        inner,
                    )
                }
                Self::ZeroAddress(inner) => {
                    <ZeroAddress as alloy_sol_types::SolError>::abi_encoded_size(inner)
                }
            }
        }
        #[inline]
        fn abi_encode_raw(&self, out: &mut alloy_sol_types::private::Vec<u8>) {
            match self {
                Self::AccessControlBadConfirmation(inner) => {
                    <AccessControlBadConfirmation as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::AccessControlUnauthorizedAccount(inner) => {
                    <AccessControlUnauthorizedAccount as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::AddressEmptyCode(inner) => {
                    <AddressEmptyCode as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::ERC1967InvalidImplementation(inner) => {
                    <ERC1967InvalidImplementation as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::ERC1967NonPayable(inner) => {
                    <ERC1967NonPayable as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::EnforcedPause(inner) => {
                    <EnforcedPause as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::ExpectedPause(inner) => {
                    <ExpectedPause as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::FailedCall(inner) => {
                    <FailedCall as alloy_sol_types::SolError>::abi_encode_raw(inner, out)
                }
                Self::InvalidInitialization(inner) => {
                    <InvalidInitialization as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::NotAContract(inner) => {
                    <NotAContract as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::NotInitializing(inner) => {
                    <NotInitializing as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::ReentrancyGuardReentrantCall(inner) => {
                    <ReentrancyGuardReentrantCall as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::SelectorAlreadyRegistered(inner) => {
                    <SelectorAlreadyRegistered as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::UUPSUnauthorizedCallContext(inner) => {
                    <UUPSUnauthorizedCallContext as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::UUPSUnsupportedProxiableUUID(inner) => {
                    <UUPSUnsupportedProxiableUUID as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::UnknownSelector(inner) => {
                    <UnknownSelector as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::ZeroAddress(inner) => {
                    <ZeroAddress as alloy_sol_types::SolError>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
            }
        }
    }
    ///Container for all the [`MultiAssetDelegation`](self) events.
    #[derive(Clone)]
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Debug, PartialEq, Eq, Hash)]
    pub enum MultiAssetDelegationEvents {
        #[allow(missing_docs)]
        BlueprintAddedToDelegation(BlueprintAddedToDelegation),
        #[allow(missing_docs)]
        BlueprintRemovedFromDelegation(BlueprintRemovedFromDelegation),
        #[allow(missing_docs)]
        Delegated(Delegated),
        #[allow(missing_docs)]
        DelegatorUnstakeExecuted(DelegatorUnstakeExecuted),
        #[allow(missing_docs)]
        DelegatorUnstakeScheduled(DelegatorUnstakeScheduled),
        #[allow(missing_docs)]
        Deposited(Deposited),
        #[allow(missing_docs)]
        ExpiredLocksHarvested(ExpiredLocksHarvested),
        #[allow(missing_docs)]
        FacetRegistered(FacetRegistered),
        #[allow(missing_docs)]
        FacetSelectorCleared(FacetSelectorCleared),
        #[allow(missing_docs)]
        FacetSelectorSet(FacetSelectorSet),
        #[allow(missing_docs)]
        Initialized(Initialized),
        #[allow(missing_docs)]
        OperatorBlueprintAdded(OperatorBlueprintAdded),
        #[allow(missing_docs)]
        OperatorBlueprintRemoved(OperatorBlueprintRemoved),
        #[allow(missing_docs)]
        OperatorLeavingScheduled(OperatorLeavingScheduled),
        #[allow(missing_docs)]
        OperatorLeft(OperatorLeft),
        #[allow(missing_docs)]
        OperatorRegistered(OperatorRegistered),
        #[allow(missing_docs)]
        OperatorStakeIncreased(OperatorStakeIncreased),
        #[allow(missing_docs)]
        OperatorUnstakeExecuted(OperatorUnstakeExecuted),
        #[allow(missing_docs)]
        OperatorUnstakeScheduled(OperatorUnstakeScheduled),
        #[allow(missing_docs)]
        Paused(Paused),
        #[allow(missing_docs)]
        RoleAdminChanged(RoleAdminChanged),
        #[allow(missing_docs)]
        RoleGranted(RoleGranted),
        #[allow(missing_docs)]
        RoleRevoked(RoleRevoked),
        #[allow(missing_docs)]
        SlashRecorded(SlashRecorded),
        #[allow(missing_docs)]
        Slashed(Slashed),
        #[allow(missing_docs)]
        SlashedForService(SlashedForService),
        #[allow(missing_docs)]
        Unpaused(Unpaused),
        #[allow(missing_docs)]
        Upgraded(Upgraded),
        #[allow(missing_docs)]
        WithdrawScheduled(WithdrawScheduled),
        #[allow(missing_docs)]
        Withdrawn(Withdrawn),
    }
    impl MultiAssetDelegationEvents {
        /// All the selectors of this enum.
        ///
        /// Note that the selectors might not be in the same order as the variants.
        /// No guarantees are made about the order of the selectors.
        ///
        /// Prefer using `SolInterface` methods instead.
        pub const SELECTORS: &'static [[u8; 32usize]] = &[
            [
                6u8, 50u8, 93u8, 131u8, 67u8, 93u8, 168u8, 118u8, 87u8, 176u8, 99u8,
                198u8, 20u8, 42u8, 91u8, 145u8, 166u8, 106u8, 126u8, 129u8, 24u8, 39u8,
                208u8, 130u8, 214u8, 36u8, 40u8, 122u8, 153u8, 83u8, 196u8, 186u8,
            ],
            [
                18u8, 5u8, 153u8, 248u8, 131u8, 1u8, 21u8, 237u8, 151u8, 49u8, 137u8,
                248u8, 244u8, 148u8, 124u8, 199u8, 147u8, 252u8, 217u8, 10u8, 21u8,
                212u8, 124u8, 77u8, 106u8, 216u8, 209u8, 163u8, 241u8, 90u8, 247u8, 52u8,
            ],
            [
                18u8, 85u8, 127u8, 37u8, 228u8, 88u8, 217u8, 104u8, 45u8, 124u8, 149u8,
                155u8, 90u8, 150u8, 11u8, 201u8, 51u8, 46u8, 139u8, 122u8, 241u8, 18u8,
                11u8, 84u8, 163u8, 51u8, 191u8, 193u8, 255u8, 40u8, 43u8, 57u8,
            ],
            [
                21u8, 8u8, 251u8, 226u8, 44u8, 152u8, 5u8, 119u8, 7u8, 64u8, 200u8,
                243u8, 130u8, 117u8, 103u8, 149u8, 0u8, 34u8, 114u8, 158u8, 0u8, 150u8,
                227u8, 17u8, 220u8, 8u8, 121u8, 144u8, 193u8, 87u8, 255u8, 252u8,
            ],
            [
                47u8, 135u8, 136u8, 17u8, 126u8, 126u8, 255u8, 29u8, 130u8, 233u8, 38u8,
                236u8, 121u8, 73u8, 1u8, 209u8, 124u8, 120u8, 2u8, 74u8, 80u8, 39u8, 9u8,
                64u8, 48u8, 69u8, 64u8, 167u8, 51u8, 101u8, 111u8, 13u8,
            ],
            [
                51u8, 52u8, 138u8, 114u8, 227u8, 8u8, 201u8, 43u8, 68u8, 117u8, 64u8,
                240u8, 121u8, 197u8, 245u8, 137u8, 92u8, 199u8, 12u8, 216u8, 59u8, 21u8,
                194u8, 100u8, 243u8, 48u8, 7u8, 60u8, 132u8, 23u8, 112u8, 252u8,
            ],
            [
                75u8, 155u8, 191u8, 46u8, 188u8, 121u8, 233u8, 251u8, 57u8, 166u8, 73u8,
                32u8, 147u8, 75u8, 63u8, 69u8, 138u8, 72u8, 101u8, 82u8, 211u8, 223u8,
                149u8, 57u8, 90u8, 167u8, 80u8, 236u8, 233u8, 233u8, 112u8, 147u8,
            ],
            [
                77u8, 60u8, 48u8, 245u8, 153u8, 63u8, 25u8, 34u8, 167u8, 121u8, 52u8,
                90u8, 15u8, 126u8, 193u8, 161u8, 112u8, 241u8, 229u8, 46u8, 157u8, 35u8,
                8u8, 36u8, 249u8, 193u8, 126u8, 99u8, 89u8, 108u8, 144u8, 109u8,
            ],
            [
                79u8, 226u8, 253u8, 230u8, 49u8, 233u8, 134u8, 238u8, 38u8, 40u8, 57u8,
                1u8, 185u8, 204u8, 141u8, 109u8, 74u8, 49u8, 27u8, 117u8, 15u8, 159u8,
                160u8, 214u8, 89u8, 82u8, 13u8, 235u8, 162u8, 153u8, 95u8, 31u8,
            ],
            [
                93u8, 185u8, 238u8, 10u8, 73u8, 91u8, 242u8, 230u8, 255u8, 156u8, 145u8,
                167u8, 131u8, 76u8, 27u8, 164u8, 253u8, 210u8, 68u8, 165u8, 232u8, 170u8,
                78u8, 83u8, 123u8, 211u8, 138u8, 234u8, 228u8, 176u8, 115u8, 170u8,
            ],
            [
                97u8, 74u8, 63u8, 168u8, 70u8, 126u8, 181u8, 76u8, 182u8, 10u8, 243u8,
                170u8, 180u8, 64u8, 39u8, 152u8, 55u8, 201u8, 252u8, 215u8, 92u8, 90u8,
                38u8, 23u8, 254u8, 10u8, 249u8, 198u8, 229u8, 230u8, 14u8, 131u8,
            ],
            [
                98u8, 231u8, 140u8, 234u8, 1u8, 190u8, 227u8, 32u8, 205u8, 78u8, 66u8,
                2u8, 112u8, 181u8, 234u8, 116u8, 0u8, 13u8, 17u8, 176u8, 201u8, 247u8,
                71u8, 84u8, 235u8, 219u8, 252u8, 84u8, 75u8, 5u8, 162u8, 88u8,
            ],
            [
                117u8, 79u8, 255u8, 34u8, 5u8, 202u8, 159u8, 26u8, 8u8, 174u8, 31u8,
                56u8, 244u8, 135u8, 131u8, 155u8, 167u8, 225u8, 136u8, 149u8, 240u8,
                35u8, 137u8, 8u8, 234u8, 139u8, 136u8, 66u8, 215u8, 66u8, 79u8, 187u8,
            ],
            [
                145u8, 117u8, 75u8, 37u8, 65u8, 83u8, 134u8, 28u8, 30u8, 155u8, 201u8,
                24u8, 100u8, 132u8, 160u8, 187u8, 119u8, 8u8, 35u8, 172u8, 250u8, 0u8,
                66u8, 48u8, 68u8, 186u8, 23u8, 89u8, 160u8, 18u8, 16u8, 231u8,
            ],
            [
                145u8, 239u8, 247u8, 211u8, 157u8, 36u8, 153u8, 215u8, 106u8, 194u8,
                26u8, 25u8, 3u8, 169u8, 90u8, 136u8, 243u8, 21u8, 137u8, 203u8, 7u8,
                177u8, 255u8, 223u8, 182u8, 29u8, 185u8, 247u8, 205u8, 138u8, 57u8, 120u8,
            ],
            [
                167u8, 184u8, 30u8, 1u8, 122u8, 190u8, 181u8, 14u8, 207u8, 44u8, 18u8,
                28u8, 176u8, 219u8, 112u8, 135u8, 223u8, 196u8, 179u8, 204u8, 133u8,
                205u8, 141u8, 133u8, 127u8, 154u8, 95u8, 30u8, 129u8, 246u8, 72u8, 69u8,
            ],
            [
                182u8, 213u8, 228u8, 93u8, 119u8, 184u8, 150u8, 124u8, 255u8, 82u8, 91u8,
                55u8, 91u8, 230u8, 224u8, 127u8, 153u8, 202u8, 90u8, 249u8, 29u8, 136u8,
                114u8, 74u8, 193u8, 35u8, 122u8, 175u8, 226u8, 149u8, 213u8, 14u8,
            ],
            [
                188u8, 17u8, 97u8, 126u8, 87u8, 93u8, 101u8, 140u8, 116u8, 233u8, 33u8,
                200u8, 223u8, 34u8, 248u8, 228u8, 133u8, 102u8, 7u8, 47u8, 167u8, 129u8,
                69u8, 166u8, 207u8, 225u8, 132u8, 32u8, 191u8, 141u8, 12u8, 78u8,
            ],
            [
                188u8, 124u8, 215u8, 90u8, 32u8, 238u8, 39u8, 253u8, 154u8, 222u8, 186u8,
                179u8, 32u8, 65u8, 247u8, 85u8, 33u8, 77u8, 188u8, 107u8, 255u8, 169u8,
                12u8, 192u8, 34u8, 91u8, 57u8, 218u8, 46u8, 92u8, 45u8, 59u8,
            ],
            [
                189u8, 121u8, 184u8, 111u8, 254u8, 10u8, 184u8, 232u8, 119u8, 97u8, 81u8,
                81u8, 66u8, 23u8, 205u8, 124u8, 172u8, 213u8, 44u8, 144u8, 159u8, 102u8,
                71u8, 92u8, 58u8, 244u8, 78u8, 18u8, 159u8, 11u8, 0u8, 255u8,
            ],
            [
                190u8, 178u8, 119u8, 1u8, 130u8, 143u8, 81u8, 91u8, 3u8, 6u8, 157u8,
                68u8, 218u8, 101u8, 25u8, 182u8, 196u8, 145u8, 218u8, 19u8, 239u8, 28u8,
                167u8, 8u8, 46u8, 97u8, 153u8, 89u8, 209u8, 244u8, 141u8, 219u8,
            ],
            [
                195u8, 140u8, 239u8, 13u8, 0u8, 59u8, 200u8, 169u8, 152u8, 45u8, 176u8,
                217u8, 148u8, 178u8, 234u8, 4u8, 137u8, 70u8, 2u8, 142u8, 146u8, 85u8,
                204u8, 6u8, 26u8, 86u8, 171u8, 203u8, 183u8, 213u8, 72u8, 161u8,
            ],
            [
                199u8, 245u8, 5u8, 178u8, 243u8, 113u8, 174u8, 33u8, 117u8, 238u8, 73u8,
                19u8, 244u8, 73u8, 158u8, 31u8, 38u8, 51u8, 167u8, 181u8, 147u8, 99u8,
                33u8, 238u8, 209u8, 205u8, 174u8, 182u8, 17u8, 81u8, 129u8, 210u8,
            ],
            [
                209u8, 193u8, 159u8, 188u8, 212u8, 85u8, 26u8, 94u8, 223u8, 182u8, 109u8,
                67u8, 210u8, 227u8, 55u8, 192u8, 72u8, 55u8, 175u8, 218u8, 52u8, 130u8,
                180u8, 43u8, 223u8, 86u8, 154u8, 143u8, 204u8, 218u8, 229u8, 251u8,
            ],
            [
                218u8, 43u8, 81u8, 52u8, 16u8, 121u8, 243u8, 221u8, 142u8, 103u8, 99u8,
                165u8, 15u8, 50u8, 155u8, 188u8, 61u8, 198u8, 202u8, 106u8, 81u8, 185u8,
                32u8, 254u8, 153u8, 251u8, 248u8, 154u8, 84u8, 236u8, 14u8, 39u8,
            ],
            [
                228u8, 24u8, 53u8, 20u8, 199u8, 72u8, 48u8, 57u8, 83u8, 140u8, 209u8,
                249u8, 202u8, 32u8, 228u8, 137u8, 179u8, 196u8, 17u8, 243u8, 175u8, 18u8,
                17u8, 207u8, 107u8, 90u8, 208u8, 160u8, 12u8, 164u8, 226u8, 40u8,
            ],
            [
                235u8, 13u8, 155u8, 52u8, 239u8, 7u8, 27u8, 135u8, 218u8, 133u8, 145u8,
                221u8, 216u8, 44u8, 198u8, 127u8, 144u8, 198u8, 128u8, 98u8, 1u8, 181u8,
                201u8, 221u8, 201u8, 31u8, 6u8, 36u8, 103u8, 125u8, 200u8, 21u8,
            ],
            [
                246u8, 57u8, 31u8, 92u8, 50u8, 217u8, 198u8, 157u8, 42u8, 71u8, 234u8,
                103u8, 11u8, 68u8, 41u8, 116u8, 181u8, 57u8, 53u8, 209u8, 237u8, 199u8,
                253u8, 100u8, 235u8, 33u8, 224u8, 71u8, 168u8, 57u8, 23u8, 27u8,
            ],
            [
                247u8, 232u8, 116u8, 217u8, 253u8, 66u8, 131u8, 139u8, 15u8, 6u8, 164u8,
                76u8, 123u8, 190u8, 69u8, 65u8, 123u8, 153u8, 30u8, 107u8, 0u8, 14u8,
                140u8, 164u8, 197u8, 193u8, 240u8, 134u8, 8u8, 74u8, 156u8, 211u8,
            ],
            [
                253u8, 71u8, 237u8, 142u8, 101u8, 63u8, 186u8, 94u8, 110u8, 159u8, 202u8,
                169u8, 71u8, 65u8, 156u8, 162u8, 51u8, 75u8, 57u8, 114u8, 206u8, 25u8,
                97u8, 50u8, 236u8, 105u8, 112u8, 133u8, 116u8, 214u8, 211u8, 90u8,
            ],
        ];
        /// The names of the variants in the same order as `SELECTORS`.
        pub const VARIANT_NAMES: &'static [&'static str] = &[
            ::core::stringify!(DelegatorUnstakeScheduled),
            ::core::stringify!(OperatorLeft),
            ::core::stringify!(FacetSelectorSet),
            ::core::stringify!(SlashRecorded),
            ::core::stringify!(RoleGranted),
            ::core::stringify!(ExpiredLocksHarvested),
            ::core::stringify!(OperatorBlueprintRemoved),
            ::core::stringify!(FacetRegistered),
            ::core::stringify!(Delegated),
            ::core::stringify!(Unpaused),
            ::core::stringify!(OperatorStakeIncreased),
            ::core::stringify!(Paused),
            ::core::stringify!(Deposited),
            ::core::stringify!(Slashed),
            ::core::stringify!(WithdrawScheduled),
            ::core::stringify!(BlueprintAddedToDelegation),
            ::core::stringify!(OperatorBlueprintAdded),
            ::core::stringify!(OperatorRegistered),
            ::core::stringify!(Upgraded),
            ::core::stringify!(RoleAdminChanged),
            ::core::stringify!(FacetSelectorCleared),
            ::core::stringify!(BlueprintRemovedFromDelegation),
            ::core::stringify!(Initialized),
            ::core::stringify!(Withdrawn),
            ::core::stringify!(OperatorUnstakeExecuted),
            ::core::stringify!(DelegatorUnstakeExecuted),
            ::core::stringify!(SlashedForService),
            ::core::stringify!(RoleRevoked),
            ::core::stringify!(OperatorUnstakeScheduled),
            ::core::stringify!(OperatorLeavingScheduled),
        ];
        /// The signatures in the same order as `SELECTORS`.
        pub const SIGNATURES: &'static [&'static str] = &[
            <DelegatorUnstakeScheduled as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorLeft as alloy_sol_types::SolEvent>::SIGNATURE,
            <FacetSelectorSet as alloy_sol_types::SolEvent>::SIGNATURE,
            <SlashRecorded as alloy_sol_types::SolEvent>::SIGNATURE,
            <RoleGranted as alloy_sol_types::SolEvent>::SIGNATURE,
            <ExpiredLocksHarvested as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorBlueprintRemoved as alloy_sol_types::SolEvent>::SIGNATURE,
            <FacetRegistered as alloy_sol_types::SolEvent>::SIGNATURE,
            <Delegated as alloy_sol_types::SolEvent>::SIGNATURE,
            <Unpaused as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorStakeIncreased as alloy_sol_types::SolEvent>::SIGNATURE,
            <Paused as alloy_sol_types::SolEvent>::SIGNATURE,
            <Deposited as alloy_sol_types::SolEvent>::SIGNATURE,
            <Slashed as alloy_sol_types::SolEvent>::SIGNATURE,
            <WithdrawScheduled as alloy_sol_types::SolEvent>::SIGNATURE,
            <BlueprintAddedToDelegation as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorBlueprintAdded as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorRegistered as alloy_sol_types::SolEvent>::SIGNATURE,
            <Upgraded as alloy_sol_types::SolEvent>::SIGNATURE,
            <RoleAdminChanged as alloy_sol_types::SolEvent>::SIGNATURE,
            <FacetSelectorCleared as alloy_sol_types::SolEvent>::SIGNATURE,
            <BlueprintRemovedFromDelegation as alloy_sol_types::SolEvent>::SIGNATURE,
            <Initialized as alloy_sol_types::SolEvent>::SIGNATURE,
            <Withdrawn as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorUnstakeExecuted as alloy_sol_types::SolEvent>::SIGNATURE,
            <DelegatorUnstakeExecuted as alloy_sol_types::SolEvent>::SIGNATURE,
            <SlashedForService as alloy_sol_types::SolEvent>::SIGNATURE,
            <RoleRevoked as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorUnstakeScheduled as alloy_sol_types::SolEvent>::SIGNATURE,
            <OperatorLeavingScheduled as alloy_sol_types::SolEvent>::SIGNATURE,
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
    impl alloy_sol_types::SolEventInterface for MultiAssetDelegationEvents {
        const NAME: &'static str = "MultiAssetDelegationEvents";
        const COUNT: usize = 30usize;
        fn decode_raw_log(
            topics: &[alloy_sol_types::Word],
            data: &[u8],
        ) -> alloy_sol_types::Result<Self> {
            match topics.first().copied() {
                Some(
                    <BlueprintAddedToDelegation as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <BlueprintAddedToDelegation as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::BlueprintAddedToDelegation)
                }
                Some(
                    <BlueprintRemovedFromDelegation as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <BlueprintRemovedFromDelegation as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::BlueprintRemovedFromDelegation)
                }
                Some(<Delegated as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <Delegated as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::Delegated)
                }
                Some(
                    <DelegatorUnstakeExecuted as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <DelegatorUnstakeExecuted as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::DelegatorUnstakeExecuted)
                }
                Some(
                    <DelegatorUnstakeScheduled as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <DelegatorUnstakeScheduled as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::DelegatorUnstakeScheduled)
                }
                Some(<Deposited as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <Deposited as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::Deposited)
                }
                Some(
                    <ExpiredLocksHarvested as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <ExpiredLocksHarvested as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::ExpiredLocksHarvested)
                }
                Some(<FacetRegistered as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <FacetRegistered as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::FacetRegistered)
                }
                Some(
                    <FacetSelectorCleared as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <FacetSelectorCleared as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::FacetSelectorCleared)
                }
                Some(<FacetSelectorSet as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <FacetSelectorSet as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::FacetSelectorSet)
                }
                Some(<Initialized as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <Initialized as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::Initialized)
                }
                Some(
                    <OperatorBlueprintAdded as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorBlueprintAdded as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorBlueprintAdded)
                }
                Some(
                    <OperatorBlueprintRemoved as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorBlueprintRemoved as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorBlueprintRemoved)
                }
                Some(
                    <OperatorLeavingScheduled as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorLeavingScheduled as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorLeavingScheduled)
                }
                Some(<OperatorLeft as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <OperatorLeft as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorLeft)
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
                    <OperatorStakeIncreased as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorStakeIncreased as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorStakeIncreased)
                }
                Some(
                    <OperatorUnstakeExecuted as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorUnstakeExecuted as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorUnstakeExecuted)
                }
                Some(
                    <OperatorUnstakeScheduled as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <OperatorUnstakeScheduled as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::OperatorUnstakeScheduled)
                }
                Some(<Paused as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <Paused as alloy_sol_types::SolEvent>::decode_raw_log(topics, data)
                        .map(Self::Paused)
                }
                Some(<RoleAdminChanged as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <RoleAdminChanged as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::RoleAdminChanged)
                }
                Some(<RoleGranted as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <RoleGranted as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::RoleGranted)
                }
                Some(<RoleRevoked as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <RoleRevoked as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::RoleRevoked)
                }
                Some(<SlashRecorded as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <SlashRecorded as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::SlashRecorded)
                }
                Some(<Slashed as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <Slashed as alloy_sol_types::SolEvent>::decode_raw_log(topics, data)
                        .map(Self::Slashed)
                }
                Some(
                    <SlashedForService as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <SlashedForService as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::SlashedForService)
                }
                Some(<Unpaused as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <Unpaused as alloy_sol_types::SolEvent>::decode_raw_log(topics, data)
                        .map(Self::Unpaused)
                }
                Some(<Upgraded as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <Upgraded as alloy_sol_types::SolEvent>::decode_raw_log(topics, data)
                        .map(Self::Upgraded)
                }
                Some(
                    <WithdrawScheduled as alloy_sol_types::SolEvent>::SIGNATURE_HASH,
                ) => {
                    <WithdrawScheduled as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::WithdrawScheduled)
                }
                Some(<Withdrawn as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <Withdrawn as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::Withdrawn)
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
    impl alloy_sol_types::private::IntoLogData for MultiAssetDelegationEvents {
        fn to_log_data(&self) -> alloy_sol_types::private::LogData {
            match self {
                Self::BlueprintAddedToDelegation(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::BlueprintRemovedFromDelegation(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::Delegated(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::DelegatorUnstakeExecuted(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::DelegatorUnstakeScheduled(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::Deposited(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::ExpiredLocksHarvested(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::FacetRegistered(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::FacetSelectorCleared(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::FacetSelectorSet(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::Initialized(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorBlueprintAdded(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorBlueprintRemoved(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorLeavingScheduled(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorLeft(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorRegistered(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorStakeIncreased(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorUnstakeExecuted(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::OperatorUnstakeScheduled(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::Paused(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::RoleAdminChanged(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::RoleGranted(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::RoleRevoked(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::SlashRecorded(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::Slashed(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::SlashedForService(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::Unpaused(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::Upgraded(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::WithdrawScheduled(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::Withdrawn(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
            }
        }
        fn into_log_data(self) -> alloy_sol_types::private::LogData {
            match self {
                Self::BlueprintAddedToDelegation(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::BlueprintRemovedFromDelegation(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::Delegated(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::DelegatorUnstakeExecuted(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::DelegatorUnstakeScheduled(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::Deposited(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::ExpiredLocksHarvested(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::FacetRegistered(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::FacetSelectorCleared(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::FacetSelectorSet(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::Initialized(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorBlueprintAdded(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorBlueprintRemoved(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorLeavingScheduled(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorLeft(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorRegistered(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorStakeIncreased(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorUnstakeExecuted(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::OperatorUnstakeScheduled(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::Paused(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::RoleAdminChanged(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::RoleGranted(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::RoleRevoked(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::SlashRecorded(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::Slashed(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::SlashedForService(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::Unpaused(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::Upgraded(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::WithdrawScheduled(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::Withdrawn(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
            }
        }
    }
    use alloy::contract as alloy_contract;
    /**Creates a new wrapper around an on-chain [`MultiAssetDelegation`](self) contract instance.

See the [wrapper's documentation](`MultiAssetDelegationInstance`) for more details.*/
    #[inline]
    pub const fn new<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(
        address: alloy_sol_types::private::Address,
        __provider: P,
    ) -> MultiAssetDelegationInstance<P, N> {
        MultiAssetDelegationInstance::<P, N>::new(address, __provider)
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
    ) -> impl ::core::future::Future<
        Output = alloy_contract::Result<MultiAssetDelegationInstance<P, N>>,
    > {
        MultiAssetDelegationInstance::<P, N>::deploy(__provider)
    }
    /**Creates a `RawCallBuilder` for deploying this contract using the given `provider`
and constructor arguments, if any.

This is a simple wrapper around creating a `RawCallBuilder` with the data set to
the bytecode concatenated with the constructor's ABI-encoded arguments.*/
    #[inline]
    pub fn deploy_builder<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(__provider: P) -> alloy_contract::RawCallBuilder<P, N> {
        MultiAssetDelegationInstance::<P, N>::deploy_builder(__provider)
    }
    /**A [`MultiAssetDelegation`](self) instance.

Contains type-safe methods for interacting with an on-chain instance of the
[`MultiAssetDelegation`](self) contract located at a given `address`, using a given
provider `P`.

If the contract bytecode is available (see the [`sol!`](alloy_sol_types::sol!)
documentation on how to provide it), the `deploy` and `deploy_builder` methods can
be used to deploy a new instance of the contract.

See the [module-level documentation](self) for all the available methods.*/
    #[derive(Clone)]
    pub struct MultiAssetDelegationInstance<P, N = alloy_contract::private::Ethereum> {
        address: alloy_sol_types::private::Address,
        provider: P,
        _network: ::core::marker::PhantomData<N>,
    }
    #[automatically_derived]
    impl<P, N> ::core::fmt::Debug for MultiAssetDelegationInstance<P, N> {
        #[inline]
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            f.debug_tuple("MultiAssetDelegationInstance").field(&self.address).finish()
        }
    }
    /// Instantiation and getters/setters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > MultiAssetDelegationInstance<P, N> {
        /**Creates a new wrapper around an on-chain [`MultiAssetDelegation`](self) contract instance.

See the [wrapper's documentation](`MultiAssetDelegationInstance`) for more details.*/
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
        ) -> alloy_contract::Result<MultiAssetDelegationInstance<P, N>> {
            let call_builder = Self::deploy_builder(__provider);
            let contract_address = call_builder.deploy().await?;
            Ok(Self::new(contract_address, call_builder.provider))
        }
        /**Creates a `RawCallBuilder` for deploying this contract using the given `provider`
and constructor arguments, if any.

This is a simple wrapper around creating a `RawCallBuilder` with the data set to
the bytecode concatenated with the constructor's ABI-encoded arguments.*/
        #[inline]
        pub fn deploy_builder(__provider: P) -> alloy_contract::RawCallBuilder<P, N> {
            alloy_contract::RawCallBuilder::new_raw_deploy(
                __provider,
                ::core::clone::Clone::clone(&BYTECODE),
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
    impl<P: ::core::clone::Clone, N> MultiAssetDelegationInstance<&P, N> {
        /// Clones the provider and returns a new instance with the cloned provider.
        #[inline]
        pub fn with_cloned_provider(self) -> MultiAssetDelegationInstance<P, N> {
            MultiAssetDelegationInstance {
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
    > MultiAssetDelegationInstance<P, N> {
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
        ///Creates a new call builder for the [`ADMIN_ROLE`] function.
        pub fn ADMIN_ROLE(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, ADMIN_ROLECall, N> {
            self.call_builder(&ADMIN_ROLECall)
        }
        ///Creates a new call builder for the [`ASSET_MANAGER_ROLE`] function.
        pub fn ASSET_MANAGER_ROLE(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, ASSET_MANAGER_ROLECall, N> {
            self.call_builder(&ASSET_MANAGER_ROLECall)
        }
        ///Creates a new call builder for the [`BPS_DENOMINATOR`] function.
        pub fn BPS_DENOMINATOR(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, BPS_DENOMINATORCall, N> {
            self.call_builder(&BPS_DENOMINATORCall)
        }
        ///Creates a new call builder for the [`DEFAULT_ADMIN_ROLE`] function.
        pub fn DEFAULT_ADMIN_ROLE(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, DEFAULT_ADMIN_ROLECall, N> {
            self.call_builder(&DEFAULT_ADMIN_ROLECall)
        }
        ///Creates a new call builder for the [`LOCK_ONE_MONTH`] function.
        pub fn LOCK_ONE_MONTH(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, LOCK_ONE_MONTHCall, N> {
            self.call_builder(&LOCK_ONE_MONTHCall)
        }
        ///Creates a new call builder for the [`LOCK_SIX_MONTHS`] function.
        pub fn LOCK_SIX_MONTHS(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, LOCK_SIX_MONTHSCall, N> {
            self.call_builder(&LOCK_SIX_MONTHSCall)
        }
        ///Creates a new call builder for the [`LOCK_THREE_MONTHS`] function.
        pub fn LOCK_THREE_MONTHS(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, LOCK_THREE_MONTHSCall, N> {
            self.call_builder(&LOCK_THREE_MONTHSCall)
        }
        ///Creates a new call builder for the [`LOCK_TWO_MONTHS`] function.
        pub fn LOCK_TWO_MONTHS(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, LOCK_TWO_MONTHSCall, N> {
            self.call_builder(&LOCK_TWO_MONTHSCall)
        }
        ///Creates a new call builder for the [`MULTIPLIER_NONE`] function.
        pub fn MULTIPLIER_NONE(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, MULTIPLIER_NONECall, N> {
            self.call_builder(&MULTIPLIER_NONECall)
        }
        ///Creates a new call builder for the [`MULTIPLIER_ONE_MONTH`] function.
        pub fn MULTIPLIER_ONE_MONTH(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, MULTIPLIER_ONE_MONTHCall, N> {
            self.call_builder(&MULTIPLIER_ONE_MONTHCall)
        }
        ///Creates a new call builder for the [`MULTIPLIER_SIX_MONTHS`] function.
        pub fn MULTIPLIER_SIX_MONTHS(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, MULTIPLIER_SIX_MONTHSCall, N> {
            self.call_builder(&MULTIPLIER_SIX_MONTHSCall)
        }
        ///Creates a new call builder for the [`MULTIPLIER_THREE_MONTHS`] function.
        pub fn MULTIPLIER_THREE_MONTHS(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, MULTIPLIER_THREE_MONTHSCall, N> {
            self.call_builder(&MULTIPLIER_THREE_MONTHSCall)
        }
        ///Creates a new call builder for the [`MULTIPLIER_TWO_MONTHS`] function.
        pub fn MULTIPLIER_TWO_MONTHS(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, MULTIPLIER_TWO_MONTHSCall, N> {
            self.call_builder(&MULTIPLIER_TWO_MONTHSCall)
        }
        ///Creates a new call builder for the [`PRECISION`] function.
        pub fn PRECISION(&self) -> alloy_contract::SolCallBuilder<&P, PRECISIONCall, N> {
            self.call_builder(&PRECISIONCall)
        }
        ///Creates a new call builder for the [`SLASHER_ROLE`] function.
        pub fn SLASHER_ROLE(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, SLASHER_ROLECall, N> {
            self.call_builder(&SLASHER_ROLECall)
        }
        ///Creates a new call builder for the [`UPGRADE_INTERFACE_VERSION`] function.
        pub fn UPGRADE_INTERFACE_VERSION(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, UPGRADE_INTERFACE_VERSIONCall, N> {
            self.call_builder(&UPGRADE_INTERFACE_VERSIONCall)
        }
        ///Creates a new call builder for the [`blueprintSlashCount`] function.
        pub fn blueprintSlashCount(
            &self,
            _0: u64,
            _1: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, blueprintSlashCountCall, N> {
            self.call_builder(&blueprintSlashCountCall { _0, _1 })
        }
        ///Creates a new call builder for the [`clearFacetSelectors`] function.
        pub fn clearFacetSelectors(
            &self,
            selectors: alloy::sol_types::private::Vec<
                alloy::sol_types::private::FixedBytes<4>,
            >,
        ) -> alloy_contract::SolCallBuilder<&P, clearFacetSelectorsCall, N> {
            self.call_builder(
                &clearFacetSelectorsCall {
                    selectors,
                },
            )
        }
        ///Creates a new call builder for the [`currentRound`] function.
        pub fn currentRound(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, currentRoundCall, N> {
            self.call_builder(&currentRoundCall)
        }
        ///Creates a new call builder for the [`delegationBondLessDelay`] function.
        pub fn delegationBondLessDelay(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, delegationBondLessDelayCall, N> {
            self.call_builder(&delegationBondLessDelayCall)
        }
        ///Creates a new call builder for the [`facetForSelector`] function.
        pub fn facetForSelector(
            &self,
            selector: alloy::sol_types::private::FixedBytes<4>,
        ) -> alloy_contract::SolCallBuilder<&P, facetForSelectorCall, N> {
            self.call_builder(&facetForSelectorCall { selector })
        }
        ///Creates a new call builder for the [`getAssetAdapter`] function.
        pub fn getAssetAdapter(
            &self,
            token: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getAssetAdapterCall, N> {
            self.call_builder(&getAssetAdapterCall { token })
        }
        ///Creates a new call builder for the [`getOperatorSlashFactor`] function.
        pub fn getOperatorSlashFactor(
            &self,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getOperatorSlashFactorCall, N> {
            self.call_builder(
                &getOperatorSlashFactorCall {
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`getRoleAdmin`] function.
        pub fn getRoleAdmin(
            &self,
            role: alloy::sol_types::private::FixedBytes<32>,
        ) -> alloy_contract::SolCallBuilder<&P, getRoleAdminCall, N> {
            self.call_builder(&getRoleAdminCall { role })
        }
        ///Creates a new call builder for the [`getSlashCount`] function.
        pub fn getSlashCount(
            &self,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getSlashCountCall, N> {
            self.call_builder(&getSlashCountCall { operator })
        }
        ///Creates a new call builder for the [`getSlashCountForBlueprint`] function.
        pub fn getSlashCountForBlueprint(
            &self,
            blueprintId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getSlashCountForBlueprintCall, N> {
            self.call_builder(
                &getSlashCountForBlueprintCall {
                    blueprintId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`getSlashCountForService`] function.
        pub fn getSlashCountForService(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getSlashCountForServiceCall, N> {
            self.call_builder(
                &getSlashCountForServiceCall {
                    serviceId,
                    operator,
                },
            )
        }
        ///Creates a new call builder for the [`getSlashImpact`] function.
        pub fn getSlashImpact(
            &self,
            operator: alloy::sol_types::private::Address,
            slashId: u64,
            delegator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getSlashImpactCall, N> {
            self.call_builder(
                &getSlashImpactCall {
                    operator,
                    slashId,
                    delegator,
                },
            )
        }
        ///Creates a new call builder for the [`getSlashRecord`] function.
        pub fn getSlashRecord(
            &self,
            operator: alloy::sol_types::private::Address,
            slashId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, getSlashRecordCall, N> {
            self.call_builder(
                &getSlashRecordCall {
                    operator,
                    slashId,
                },
            )
        }
        ///Creates a new call builder for the [`getSnapshot`] function.
        pub fn getSnapshot(
            &self,
            round: u64,
            operator: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, getSnapshotCall, N> {
            self.call_builder(&getSnapshotCall { round, operator })
        }
        ///Creates a new call builder for the [`grantRole`] function.
        pub fn grantRole(
            &self,
            role: alloy::sol_types::private::FixedBytes<32>,
            account: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, grantRoleCall, N> {
            self.call_builder(&grantRoleCall { role, account })
        }
        ///Creates a new call builder for the [`hasRole`] function.
        pub fn hasRole(
            &self,
            role: alloy::sol_types::private::FixedBytes<32>,
            account: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, hasRoleCall, N> {
            self.call_builder(&hasRoleCall { role, account })
        }
        ///Creates a new call builder for the [`initialize`] function.
        pub fn initialize(
            &self,
            admin: alloy::sol_types::private::Address,
            nativeMinOperatorStake: alloy::sol_types::private::primitives::aliases::U256,
            nativeMinDelegation: alloy::sol_types::private::primitives::aliases::U256,
            _operatorCommissionBps: u16,
        ) -> alloy_contract::SolCallBuilder<&P, initializeCall, N> {
            self.call_builder(
                &initializeCall {
                    admin,
                    nativeMinOperatorStake,
                    nativeMinDelegation,
                    _operatorCommissionBps,
                },
            )
        }
        ///Creates a new call builder for the [`lastRoundAdvance`] function.
        pub fn lastRoundAdvance(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, lastRoundAdvanceCall, N> {
            self.call_builder(&lastRoundAdvanceCall)
        }
        ///Creates a new call builder for the [`leaveDelegatorsDelay`] function.
        pub fn leaveDelegatorsDelay(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, leaveDelegatorsDelayCall, N> {
            self.call_builder(&leaveDelegatorsDelayCall)
        }
        ///Creates a new call builder for the [`leaveOperatorsDelay`] function.
        pub fn leaveOperatorsDelay(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, leaveOperatorsDelayCall, N> {
            self.call_builder(&leaveOperatorsDelayCall)
        }
        ///Creates a new call builder for the [`nativeEnabled`] function.
        pub fn nativeEnabled(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, nativeEnabledCall, N> {
            self.call_builder(&nativeEnabledCall)
        }
        ///Creates a new call builder for the [`nextSlashId`] function.
        pub fn nextSlashId(
            &self,
            _0: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, nextSlashIdCall, N> {
            self.call_builder(&nextSlashIdCall(_0))
        }
        ///Creates a new call builder for the [`operatorCommissionBps`] function.
        pub fn operatorCommissionBps(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, operatorCommissionBpsCall, N> {
            self.call_builder(&operatorCommissionBpsCall)
        }
        ///Creates a new call builder for the [`paused`] function.
        pub fn paused(&self) -> alloy_contract::SolCallBuilder<&P, pausedCall, N> {
            self.call_builder(&pausedCall)
        }
        ///Creates a new call builder for the [`proxiableUUID`] function.
        pub fn proxiableUUID(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, proxiableUUIDCall, N> {
            self.call_builder(&proxiableUUIDCall)
        }
        ///Creates a new call builder for the [`registerFacet`] function.
        pub fn registerFacet(
            &self,
            facet: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, registerFacetCall, N> {
            self.call_builder(&registerFacetCall { facet })
        }
        ///Creates a new call builder for the [`registerFacetSelectors`] function.
        pub fn registerFacetSelectors(
            &self,
            facet: alloy::sol_types::private::Address,
            selectors: alloy::sol_types::private::Vec<
                alloy::sol_types::private::FixedBytes<4>,
            >,
        ) -> alloy_contract::SolCallBuilder<&P, registerFacetSelectorsCall, N> {
            self.call_builder(
                &registerFacetSelectorsCall {
                    facet,
                    selectors,
                },
            )
        }
        ///Creates a new call builder for the [`renounceRole`] function.
        pub fn renounceRole(
            &self,
            role: alloy::sol_types::private::FixedBytes<32>,
            callerConfirmation: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, renounceRoleCall, N> {
            self.call_builder(
                &renounceRoleCall {
                    role,
                    callerConfirmation,
                },
            )
        }
        ///Creates a new call builder for the [`requireAdapters`] function.
        pub fn requireAdapters(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, requireAdaptersCall, N> {
            self.call_builder(&requireAdaptersCall)
        }
        ///Creates a new call builder for the [`revokeRole`] function.
        pub fn revokeRole(
            &self,
            role: alloy::sol_types::private::FixedBytes<32>,
            account: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, revokeRoleCall, N> {
            self.call_builder(&revokeRoleCall { role, account })
        }
        ///Creates a new call builder for the [`roundDuration`] function.
        pub fn roundDuration(
            &self,
        ) -> alloy_contract::SolCallBuilder<&P, roundDurationCall, N> {
            self.call_builder(&roundDurationCall)
        }
        ///Creates a new call builder for the [`serviceSlashCount`] function.
        pub fn serviceSlashCount(
            &self,
            _0: u64,
            _1: alloy::sol_types::private::Address,
        ) -> alloy_contract::SolCallBuilder<&P, serviceSlashCountCall, N> {
            self.call_builder(&serviceSlashCountCall { _0, _1 })
        }
        ///Creates a new call builder for the [`slashHistory`] function.
        pub fn slashHistory(
            &self,
            _0: alloy::sol_types::private::Address,
            _1: u64,
        ) -> alloy_contract::SolCallBuilder<&P, slashHistoryCall, N> {
            self.call_builder(&slashHistoryCall { _0, _1 })
        }
        ///Creates a new call builder for the [`supportsInterface`] function.
        pub fn supportsInterface(
            &self,
            interfaceId: alloy::sol_types::private::FixedBytes<4>,
        ) -> alloy_contract::SolCallBuilder<&P, supportsInterfaceCall, N> {
            self.call_builder(
                &supportsInterfaceCall {
                    interfaceId,
                },
            )
        }
        ///Creates a new call builder for the [`upgradeToAndCall`] function.
        pub fn upgradeToAndCall(
            &self,
            newImplementation: alloy::sol_types::private::Address,
            data: alloy::sol_types::private::Bytes,
        ) -> alloy_contract::SolCallBuilder<&P, upgradeToAndCallCall, N> {
            self.call_builder(
                &upgradeToAndCallCall {
                    newImplementation,
                    data,
                },
            )
        }
    }
    /// Event filters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > MultiAssetDelegationInstance<P, N> {
        /// Creates a new event filter using this contract instance's provider and address.
        ///
        /// Note that the type can be any event, not just those defined in this contract.
        /// Prefer using the other methods for building type-safe event filters.
        pub fn event_filter<E: alloy_sol_types::SolEvent>(
            &self,
        ) -> alloy_contract::Event<&P, E, N> {
            alloy_contract::Event::new_sol(&self.provider, &self.address)
        }
        ///Creates a new event filter for the [`BlueprintAddedToDelegation`] event.
        pub fn BlueprintAddedToDelegation_filter(
            &self,
        ) -> alloy_contract::Event<&P, BlueprintAddedToDelegation, N> {
            self.event_filter::<BlueprintAddedToDelegation>()
        }
        ///Creates a new event filter for the [`BlueprintRemovedFromDelegation`] event.
        pub fn BlueprintRemovedFromDelegation_filter(
            &self,
        ) -> alloy_contract::Event<&P, BlueprintRemovedFromDelegation, N> {
            self.event_filter::<BlueprintRemovedFromDelegation>()
        }
        ///Creates a new event filter for the [`Delegated`] event.
        pub fn Delegated_filter(&self) -> alloy_contract::Event<&P, Delegated, N> {
            self.event_filter::<Delegated>()
        }
        ///Creates a new event filter for the [`DelegatorUnstakeExecuted`] event.
        pub fn DelegatorUnstakeExecuted_filter(
            &self,
        ) -> alloy_contract::Event<&P, DelegatorUnstakeExecuted, N> {
            self.event_filter::<DelegatorUnstakeExecuted>()
        }
        ///Creates a new event filter for the [`DelegatorUnstakeScheduled`] event.
        pub fn DelegatorUnstakeScheduled_filter(
            &self,
        ) -> alloy_contract::Event<&P, DelegatorUnstakeScheduled, N> {
            self.event_filter::<DelegatorUnstakeScheduled>()
        }
        ///Creates a new event filter for the [`Deposited`] event.
        pub fn Deposited_filter(&self) -> alloy_contract::Event<&P, Deposited, N> {
            self.event_filter::<Deposited>()
        }
        ///Creates a new event filter for the [`ExpiredLocksHarvested`] event.
        pub fn ExpiredLocksHarvested_filter(
            &self,
        ) -> alloy_contract::Event<&P, ExpiredLocksHarvested, N> {
            self.event_filter::<ExpiredLocksHarvested>()
        }
        ///Creates a new event filter for the [`FacetRegistered`] event.
        pub fn FacetRegistered_filter(
            &self,
        ) -> alloy_contract::Event<&P, FacetRegistered, N> {
            self.event_filter::<FacetRegistered>()
        }
        ///Creates a new event filter for the [`FacetSelectorCleared`] event.
        pub fn FacetSelectorCleared_filter(
            &self,
        ) -> alloy_contract::Event<&P, FacetSelectorCleared, N> {
            self.event_filter::<FacetSelectorCleared>()
        }
        ///Creates a new event filter for the [`FacetSelectorSet`] event.
        pub fn FacetSelectorSet_filter(
            &self,
        ) -> alloy_contract::Event<&P, FacetSelectorSet, N> {
            self.event_filter::<FacetSelectorSet>()
        }
        ///Creates a new event filter for the [`Initialized`] event.
        pub fn Initialized_filter(&self) -> alloy_contract::Event<&P, Initialized, N> {
            self.event_filter::<Initialized>()
        }
        ///Creates a new event filter for the [`OperatorBlueprintAdded`] event.
        pub fn OperatorBlueprintAdded_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorBlueprintAdded, N> {
            self.event_filter::<OperatorBlueprintAdded>()
        }
        ///Creates a new event filter for the [`OperatorBlueprintRemoved`] event.
        pub fn OperatorBlueprintRemoved_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorBlueprintRemoved, N> {
            self.event_filter::<OperatorBlueprintRemoved>()
        }
        ///Creates a new event filter for the [`OperatorLeavingScheduled`] event.
        pub fn OperatorLeavingScheduled_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorLeavingScheduled, N> {
            self.event_filter::<OperatorLeavingScheduled>()
        }
        ///Creates a new event filter for the [`OperatorLeft`] event.
        pub fn OperatorLeft_filter(&self) -> alloy_contract::Event<&P, OperatorLeft, N> {
            self.event_filter::<OperatorLeft>()
        }
        ///Creates a new event filter for the [`OperatorRegistered`] event.
        pub fn OperatorRegistered_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorRegistered, N> {
            self.event_filter::<OperatorRegistered>()
        }
        ///Creates a new event filter for the [`OperatorStakeIncreased`] event.
        pub fn OperatorStakeIncreased_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorStakeIncreased, N> {
            self.event_filter::<OperatorStakeIncreased>()
        }
        ///Creates a new event filter for the [`OperatorUnstakeExecuted`] event.
        pub fn OperatorUnstakeExecuted_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorUnstakeExecuted, N> {
            self.event_filter::<OperatorUnstakeExecuted>()
        }
        ///Creates a new event filter for the [`OperatorUnstakeScheduled`] event.
        pub fn OperatorUnstakeScheduled_filter(
            &self,
        ) -> alloy_contract::Event<&P, OperatorUnstakeScheduled, N> {
            self.event_filter::<OperatorUnstakeScheduled>()
        }
        ///Creates a new event filter for the [`Paused`] event.
        pub fn Paused_filter(&self) -> alloy_contract::Event<&P, Paused, N> {
            self.event_filter::<Paused>()
        }
        ///Creates a new event filter for the [`RoleAdminChanged`] event.
        pub fn RoleAdminChanged_filter(
            &self,
        ) -> alloy_contract::Event<&P, RoleAdminChanged, N> {
            self.event_filter::<RoleAdminChanged>()
        }
        ///Creates a new event filter for the [`RoleGranted`] event.
        pub fn RoleGranted_filter(&self) -> alloy_contract::Event<&P, RoleGranted, N> {
            self.event_filter::<RoleGranted>()
        }
        ///Creates a new event filter for the [`RoleRevoked`] event.
        pub fn RoleRevoked_filter(&self) -> alloy_contract::Event<&P, RoleRevoked, N> {
            self.event_filter::<RoleRevoked>()
        }
        ///Creates a new event filter for the [`SlashRecorded`] event.
        pub fn SlashRecorded_filter(
            &self,
        ) -> alloy_contract::Event<&P, SlashRecorded, N> {
            self.event_filter::<SlashRecorded>()
        }
        ///Creates a new event filter for the [`Slashed`] event.
        pub fn Slashed_filter(&self) -> alloy_contract::Event<&P, Slashed, N> {
            self.event_filter::<Slashed>()
        }
        ///Creates a new event filter for the [`SlashedForService`] event.
        pub fn SlashedForService_filter(
            &self,
        ) -> alloy_contract::Event<&P, SlashedForService, N> {
            self.event_filter::<SlashedForService>()
        }
        ///Creates a new event filter for the [`Unpaused`] event.
        pub fn Unpaused_filter(&self) -> alloy_contract::Event<&P, Unpaused, N> {
            self.event_filter::<Unpaused>()
        }
        ///Creates a new event filter for the [`Upgraded`] event.
        pub fn Upgraded_filter(&self) -> alloy_contract::Event<&P, Upgraded, N> {
            self.event_filter::<Upgraded>()
        }
        ///Creates a new event filter for the [`WithdrawScheduled`] event.
        pub fn WithdrawScheduled_filter(
            &self,
        ) -> alloy_contract::Event<&P, WithdrawScheduled, N> {
            self.event_filter::<WithdrawScheduled>()
        }
        ///Creates a new event filter for the [`Withdrawn`] event.
        pub fn Withdrawn_filter(&self) -> alloy_contract::Event<&P, Withdrawn, N> {
            self.event_filter::<Withdrawn>()
        }
    }
}
