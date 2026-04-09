///Module containing a contract's types and functions.
/**

```solidity
library SlashingLib {
    type SlashStatus is uint8;
    struct SlashProposal { uint64 serviceId; address operator; address proposer; uint16 slashBps; uint16 effectiveSlashBps; bytes32 evidence; uint64 proposedAt; uint64 executeAfter; SlashStatus status; string disputeReason; }
}
```*/
#[allow(
    non_camel_case_types,
    non_snake_case,
    clippy::pub_underscore_fields,
    clippy::style,
    clippy::empty_structs_with_brackets
)]
pub mod SlashingLib {
    use super::*;
    use alloy::sol_types as alloy_sol_types;
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct SlashStatus(u8);
    const _: () = {
        use alloy::sol_types as alloy_sol_types;
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<SlashStatus> for u8 {
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
        impl SlashStatus {
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
        impl From<u8> for SlashStatus {
            fn from(value: u8) -> Self {
                Self::from_underlying(value)
            }
        }
        #[automatically_derived]
        impl From<SlashStatus> for u8 {
            fn from(value: SlashStatus) -> Self {
                value.into_underlying()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolType for SlashStatus {
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
        impl alloy_sol_types::EventTopic for SlashStatus {
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
struct SlashProposal { uint64 serviceId; address operator; address proposer; uint16 slashBps; uint16 effectiveSlashBps; bytes32 evidence; uint64 proposedAt; uint64 executeAfter; SlashStatus status; string disputeReason; }
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct SlashProposal {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub proposer: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub slashBps: u16,
        #[allow(missing_docs)]
        pub effectiveSlashBps: u16,
        #[allow(missing_docs)]
        pub evidence: alloy::sol_types::private::FixedBytes<32>,
        #[allow(missing_docs)]
        pub proposedAt: u64,
        #[allow(missing_docs)]
        pub executeAfter: u64,
        #[allow(missing_docs)]
        pub status: <SlashStatus as alloy::sol_types::SolType>::RustType,
        #[allow(missing_docs)]
        pub disputeReason: alloy::sol_types::private::String,
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
            alloy::sol_types::sol_data::Address,
            alloy::sol_types::sol_data::Address,
            alloy::sol_types::sol_data::Uint<16>,
            alloy::sol_types::sol_data::Uint<16>,
            alloy::sol_types::sol_data::FixedBytes<32>,
            alloy::sol_types::sol_data::Uint<64>,
            alloy::sol_types::sol_data::Uint<64>,
            SlashStatus,
            alloy::sol_types::sol_data::String,
        );
        #[doc(hidden)]
        type UnderlyingRustTuple<'a> = (
            u64,
            alloy::sol_types::private::Address,
            alloy::sol_types::private::Address,
            u16,
            u16,
            alloy::sol_types::private::FixedBytes<32>,
            u64,
            u64,
            <SlashStatus as alloy::sol_types::SolType>::RustType,
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
        impl ::core::convert::From<SlashProposal> for UnderlyingRustTuple<'_> {
            fn from(value: SlashProposal) -> Self {
                (
                    value.serviceId,
                    value.operator,
                    value.proposer,
                    value.slashBps,
                    value.effectiveSlashBps,
                    value.evidence,
                    value.proposedAt,
                    value.executeAfter,
                    value.status,
                    value.disputeReason,
                )
            }
        }
        #[automatically_derived]
        #[doc(hidden)]
        impl ::core::convert::From<UnderlyingRustTuple<'_>> for SlashProposal {
            fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                Self {
                    serviceId: tuple.0,
                    operator: tuple.1,
                    proposer: tuple.2,
                    slashBps: tuple.3,
                    effectiveSlashBps: tuple.4,
                    evidence: tuple.5,
                    proposedAt: tuple.6,
                    executeAfter: tuple.7,
                    status: tuple.8,
                    disputeReason: tuple.9,
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolValue for SlashProposal {
            type SolType = Self;
        }
        #[automatically_derived]
        impl alloy_sol_types::private::SolTypeValue<Self> for SlashProposal {
            #[inline]
            fn stv_to_tokens(&self) -> <Self as alloy_sol_types::SolType>::Token<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.serviceId),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.operator,
                    ),
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::tokenize(
                        &self.proposer,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        16,
                    > as alloy_sol_types::SolType>::tokenize(&self.slashBps),
                    <alloy::sol_types::sol_data::Uint<
                        16,
                    > as alloy_sol_types::SolType>::tokenize(&self.effectiveSlashBps),
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(&self.evidence),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.proposedAt),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.executeAfter),
                    <SlashStatus as alloy_sol_types::SolType>::tokenize(&self.status),
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.disputeReason,
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
        impl alloy_sol_types::SolType for SlashProposal {
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
        impl alloy_sol_types::SolStruct for SlashProposal {
            const NAME: &'static str = "SlashProposal";
            #[inline]
            fn eip712_root_type() -> alloy_sol_types::private::Cow<'static, str> {
                alloy_sol_types::private::Cow::Borrowed(
                    "SlashProposal(uint64 serviceId,address operator,address proposer,uint16 slashBps,uint16 effectiveSlashBps,bytes32 evidence,uint64 proposedAt,uint64 executeAfter,uint8 status,string disputeReason)",
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
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.serviceId)
                        .0,
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::eip712_data_word(
                            &self.operator,
                        )
                        .0,
                    <alloy::sol_types::sol_data::Address as alloy_sol_types::SolType>::eip712_data_word(
                            &self.proposer,
                        )
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        16,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.slashBps)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        16,
                    > as alloy_sol_types::SolType>::eip712_data_word(
                            &self.effectiveSlashBps,
                        )
                        .0,
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.evidence)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.proposedAt)
                        .0,
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::eip712_data_word(&self.executeAfter)
                        .0,
                    <SlashStatus as alloy_sol_types::SolType>::eip712_data_word(
                            &self.status,
                        )
                        .0,
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::eip712_data_word(
                            &self.disputeReason,
                        )
                        .0,
                ]
                    .concat()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::EventTopic for SlashProposal {
            #[inline]
            fn topic_preimage_length(rust: &Self::RustType) -> usize {
                0usize
                    + <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.serviceId,
                    )
                    + <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.operator,
                    )
                    + <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.proposer,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        16,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.slashBps,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        16,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.effectiveSlashBps,
                    )
                    + <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.evidence,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.proposedAt,
                    )
                    + <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.executeAfter,
                    )
                    + <SlashStatus as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.status,
                    )
                    + <alloy::sol_types::sol_data::String as alloy_sol_types::EventTopic>::topic_preimage_length(
                        &rust.disputeReason,
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
                    &rust.serviceId,
                    out,
                );
                <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.operator,
                    out,
                );
                <alloy::sol_types::sol_data::Address as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.proposer,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    16,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.slashBps,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    16,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.effectiveSlashBps,
                    out,
                );
                <alloy::sol_types::sol_data::FixedBytes<
                    32,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.evidence,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.proposedAt,
                    out,
                );
                <alloy::sol_types::sol_data::Uint<
                    64,
                > as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.executeAfter,
                    out,
                );
                <SlashStatus as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.status,
                    out,
                );
                <alloy::sol_types::sol_data::String as alloy_sol_types::EventTopic>::encode_topic_preimage(
                    &rust.disputeReason,
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
    /**Creates a new wrapper around an on-chain [`SlashingLib`](self) contract instance.

See the [wrapper's documentation](`SlashingLibInstance`) for more details.*/
    #[inline]
    pub const fn new<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(
        address: alloy_sol_types::private::Address,
        __provider: P,
    ) -> SlashingLibInstance<P, N> {
        SlashingLibInstance::<P, N>::new(address, __provider)
    }
    /**A [`SlashingLib`](self) instance.

Contains type-safe methods for interacting with an on-chain instance of the
[`SlashingLib`](self) contract located at a given `address`, using a given
provider `P`.

If the contract bytecode is available (see the [`sol!`](alloy_sol_types::sol!)
documentation on how to provide it), the `deploy` and `deploy_builder` methods can
be used to deploy a new instance of the contract.

See the [module-level documentation](self) for all the available methods.*/
    #[derive(Clone)]
    pub struct SlashingLibInstance<P, N = alloy_contract::private::Ethereum> {
        address: alloy_sol_types::private::Address,
        provider: P,
        _network: ::core::marker::PhantomData<N>,
    }
    #[automatically_derived]
    impl<P, N> ::core::fmt::Debug for SlashingLibInstance<P, N> {
        #[inline]
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            f.debug_tuple("SlashingLibInstance").field(&self.address).finish()
        }
    }
    /// Instantiation and getters/setters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > SlashingLibInstance<P, N> {
        /**Creates a new wrapper around an on-chain [`SlashingLib`](self) contract instance.

See the [wrapper's documentation](`SlashingLibInstance`) for more details.*/
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
    impl<P: ::core::clone::Clone, N> SlashingLibInstance<&P, N> {
        /// Clones the provider and returns a new instance with the cloned provider.
        #[inline]
        pub fn with_cloned_provider(self) -> SlashingLibInstance<P, N> {
            SlashingLibInstance {
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
    > SlashingLibInstance<P, N> {
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
    > SlashingLibInstance<P, N> {
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
library SlashingLib {
    type SlashStatus is uint8;
    struct SlashProposal {
        uint64 serviceId;
        address operator;
        address proposer;
        uint16 slashBps;
        uint16 effectiveSlashBps;
        bytes32 evidence;
        uint64 proposedAt;
        uint64 executeAfter;
        SlashStatus status;
        string disputeReason;
    }
}

interface ITangleSlashing {
    event SlashExecuted(uint64 indexed serviceId, address indexed operator, uint256 amount);
    event SlashProposed(uint64 indexed serviceId, address indexed operator, uint16 slashBps, bytes32 evidence);

    function cancelSlash(uint64 slashId, string memory reason) external;
    function disputeSlash(uint64 slashId, string memory reason) external;
    function executeSlash(uint64 slashId) external returns (uint256 actualSlashed);
    function executeSlashBatch(uint64[] memory slashIds) external returns (uint256 totalSlashed, uint256 executedCount);
    function getExecutableSlashes(uint64 fromId, uint64 toId) external view returns (uint64[] memory ids);
    function getSlashProposal(uint64 slashId) external view returns (SlashingLib.SlashProposal memory);
    function proposeSlash(uint64 serviceId, address operator, uint16 slashBps, bytes32 evidence) external returns (uint64 slashId);
    function setSlashConfig(uint64 disputeWindow, bool instantSlashEnabled, uint16 maxSlashBps) external;
}
```

...which was generated by the following JSON ABI:
```json
[
  {
    "type": "function",
    "name": "cancelSlash",
    "inputs": [
      {
        "name": "slashId",
        "type": "uint64",
        "internalType": "uint64"
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
    "name": "disputeSlash",
    "inputs": [
      {
        "name": "slashId",
        "type": "uint64",
        "internalType": "uint64"
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
    "name": "executeSlash",
    "inputs": [
      {
        "name": "slashId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "actualSlashed",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "executeSlashBatch",
    "inputs": [
      {
        "name": "slashIds",
        "type": "uint64[]",
        "internalType": "uint64[]"
      }
    ],
    "outputs": [
      {
        "name": "totalSlashed",
        "type": "uint256",
        "internalType": "uint256"
      },
      {
        "name": "executedCount",
        "type": "uint256",
        "internalType": "uint256"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getExecutableSlashes",
    "inputs": [
      {
        "name": "fromId",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "toId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "outputs": [
      {
        "name": "ids",
        "type": "uint64[]",
        "internalType": "uint64[]"
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getSlashProposal",
    "inputs": [
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
        "internalType": "struct SlashingLib.SlashProposal",
        "components": [
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
            "name": "proposer",
            "type": "address",
            "internalType": "address"
          },
          {
            "name": "slashBps",
            "type": "uint16",
            "internalType": "uint16"
          },
          {
            "name": "effectiveSlashBps",
            "type": "uint16",
            "internalType": "uint16"
          },
          {
            "name": "evidence",
            "type": "bytes32",
            "internalType": "bytes32"
          },
          {
            "name": "proposedAt",
            "type": "uint64",
            "internalType": "uint64"
          },
          {
            "name": "executeAfter",
            "type": "uint64",
            "internalType": "uint64"
          },
          {
            "name": "status",
            "type": "uint8",
            "internalType": "enum SlashingLib.SlashStatus"
          },
          {
            "name": "disputeReason",
            "type": "string",
            "internalType": "string"
          }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "proposeSlash",
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
        "name": "slashBps",
        "type": "uint16",
        "internalType": "uint16"
      },
      {
        "name": "evidence",
        "type": "bytes32",
        "internalType": "bytes32"
      }
    ],
    "outputs": [
      {
        "name": "slashId",
        "type": "uint64",
        "internalType": "uint64"
      }
    ],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "setSlashConfig",
    "inputs": [
      {
        "name": "disputeWindow",
        "type": "uint64",
        "internalType": "uint64"
      },
      {
        "name": "instantSlashEnabled",
        "type": "bool",
        "internalType": "bool"
      },
      {
        "name": "maxSlashBps",
        "type": "uint16",
        "internalType": "uint16"
      }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "SlashExecuted",
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
    "name": "SlashProposed",
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
        "name": "slashBps",
        "type": "uint16",
        "indexed": false,
        "internalType": "uint16"
      },
      {
        "name": "evidence",
        "type": "bytes32",
        "indexed": false,
        "internalType": "bytes32"
      }
    ],
    "anonymous": false
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
pub mod ITangleSlashing {
    use super::*;
    use alloy::sol_types as alloy_sol_types;
    /// The creation / init bytecode of the contract.
    ///
    /// ```text
    ///0x
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"",
    );
    /// The runtime bytecode of the contract, as deployed on the network.
    ///
    /// ```text
    ///0x
    /// ```
    #[rustfmt::skip]
    #[allow(clippy::all)]
    pub static DEPLOYED_BYTECODE: alloy_sol_types::private::Bytes = alloy_sol_types::private::Bytes::from_static(
        b"",
    );
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `SlashExecuted(uint64,address,uint256)` and selector `0x26c5c426df452d68e3b3d27c7b069a62cd268ad9e1cd55c9c9f239320890de23`.
```solidity
event SlashExecuted(uint64 indexed serviceId, address indexed operator, uint256 amount);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct SlashExecuted {
        #[allow(missing_docs)]
        pub serviceId: u64,
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
        impl alloy_sol_types::SolEvent for SlashExecuted {
            type DataTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "SlashExecuted(uint64,address,uint256)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                38u8, 197u8, 196u8, 38u8, 223u8, 69u8, 45u8, 104u8, 227u8, 179u8, 210u8,
                124u8, 123u8, 6u8, 154u8, 98u8, 205u8, 38u8, 138u8, 217u8, 225u8, 205u8,
                85u8, 201u8, 201u8, 242u8, 57u8, 50u8, 8u8, 144u8, 222u8, 35u8,
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
        impl alloy_sol_types::private::IntoLogData for SlashExecuted {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&SlashExecuted> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &SlashExecuted) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Event with signature `SlashProposed(uint64,address,uint16,bytes32)` and selector `0x0f9eb929e655f6ca1293bbddbade0ebf2c4b209d4454d5399825561892404962`.
```solidity
event SlashProposed(uint64 indexed serviceId, address indexed operator, uint16 slashBps, bytes32 evidence);
```*/
    #[allow(
        non_camel_case_types,
        non_snake_case,
        clippy::pub_underscore_fields,
        clippy::style
    )]
    #[derive(Clone)]
    pub struct SlashProposed {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub slashBps: u16,
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
        #[automatically_derived]
        impl alloy_sol_types::SolEvent for SlashProposed {
            type DataTuple<'a> = (
                alloy::sol_types::sol_data::Uint<16>,
                alloy::sol_types::sol_data::FixedBytes<32>,
            );
            type DataToken<'a> = <Self::DataTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type TopicList = (
                alloy_sol_types::sol_data::FixedBytes<32>,
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
            );
            const SIGNATURE: &'static str = "SlashProposed(uint64,address,uint16,bytes32)";
            const SIGNATURE_HASH: alloy_sol_types::private::B256 = alloy_sol_types::private::B256::new([
                15u8, 158u8, 185u8, 41u8, 230u8, 85u8, 246u8, 202u8, 18u8, 147u8, 187u8,
                221u8, 186u8, 222u8, 14u8, 191u8, 44u8, 75u8, 32u8, 157u8, 68u8, 84u8,
                213u8, 57u8, 152u8, 37u8, 86u8, 24u8, 146u8, 64u8, 73u8, 98u8,
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
                    slashBps: data.0,
                    evidence: data.1,
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
                        16,
                    > as alloy_sol_types::SolType>::tokenize(&self.slashBps),
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(&self.evidence),
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
        impl alloy_sol_types::private::IntoLogData for SlashProposed {
            fn to_log_data(&self) -> alloy_sol_types::private::LogData {
                From::from(self)
            }
            fn into_log_data(self) -> alloy_sol_types::private::LogData {
                From::from(&self)
            }
        }
        #[automatically_derived]
        impl From<&SlashProposed> for alloy_sol_types::private::LogData {
            #[inline]
            fn from(this: &SlashProposed) -> alloy_sol_types::private::LogData {
                alloy_sol_types::SolEvent::encode_log_data(this)
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `cancelSlash(uint64,string)` and selector `0x06079dc5`.
```solidity
function cancelSlash(uint64 slashId, string memory reason) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct cancelSlashCall {
        #[allow(missing_docs)]
        pub slashId: u64,
        #[allow(missing_docs)]
        pub reason: alloy::sol_types::private::String,
    }
    ///Container type for the return parameters of the [`cancelSlash(uint64,string)`](cancelSlashCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct cancelSlashReturn {}
    #[allow(
        non_camel_case_types,
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
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::String);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<cancelSlashCall> for UnderlyingRustTuple<'_> {
                fn from(value: cancelSlashCall) -> Self {
                    (value.slashId, value.reason)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for cancelSlashCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        slashId: tuple.0,
                        reason: tuple.1,
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
            impl ::core::convert::From<cancelSlashReturn> for UnderlyingRustTuple<'_> {
                fn from(value: cancelSlashReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for cancelSlashReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl cancelSlashReturn {
            fn _tokenize(
                &self,
            ) -> <cancelSlashCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for cancelSlashCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::String,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = cancelSlashReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "cancelSlash(uint64,string)";
            const SELECTOR: [u8; 4] = [6u8, 7u8, 157u8, 197u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.slashId),
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.reason,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                cancelSlashReturn::_tokenize(ret)
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
    /**Function with signature `disputeSlash(uint64,string)` and selector `0x77380c74`.
```solidity
function disputeSlash(uint64 slashId, string memory reason) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct disputeSlashCall {
        #[allow(missing_docs)]
        pub slashId: u64,
        #[allow(missing_docs)]
        pub reason: alloy::sol_types::private::String,
    }
    ///Container type for the return parameters of the [`disputeSlash(uint64,string)`](disputeSlashCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct disputeSlashReturn {}
    #[allow(
        non_camel_case_types,
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
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, alloy::sol_types::private::String);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<disputeSlashCall> for UnderlyingRustTuple<'_> {
                fn from(value: disputeSlashCall) -> Self {
                    (value.slashId, value.reason)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for disputeSlashCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        slashId: tuple.0,
                        reason: tuple.1,
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
            impl ::core::convert::From<disputeSlashReturn> for UnderlyingRustTuple<'_> {
                fn from(value: disputeSlashReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for disputeSlashReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl disputeSlashReturn {
            fn _tokenize(
                &self,
            ) -> <disputeSlashCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for disputeSlashCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::String,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = disputeSlashReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "disputeSlash(uint64,string)";
            const SELECTOR: [u8; 4] = [119u8, 56u8, 12u8, 116u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.slashId),
                    <alloy::sol_types::sol_data::String as alloy_sol_types::SolType>::tokenize(
                        &self.reason,
                    ),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                disputeSlashReturn::_tokenize(ret)
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
    /**Function with signature `executeSlash(uint64)` and selector `0xa5bfbae4`.
```solidity
function executeSlash(uint64 slashId) external returns (uint256 actualSlashed);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct executeSlashCall {
        #[allow(missing_docs)]
        pub slashId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`executeSlash(uint64)`](executeSlashCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct executeSlashReturn {
        #[allow(missing_docs)]
        pub actualSlashed: alloy::sol_types::private::primitives::aliases::U256,
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
            impl ::core::convert::From<executeSlashCall> for UnderlyingRustTuple<'_> {
                fn from(value: executeSlashCall) -> Self {
                    (value.slashId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for executeSlashCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { slashId: tuple.0 }
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
            impl ::core::convert::From<executeSlashReturn> for UnderlyingRustTuple<'_> {
                fn from(value: executeSlashReturn) -> Self {
                    (value.actualSlashed,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for executeSlashReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { actualSlashed: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for executeSlashCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::primitives::aliases::U256;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<256>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "executeSlash(uint64)";
            const SELECTOR: [u8; 4] = [165u8, 191u8, 186u8, 228u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.slashId),
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
                        let r: executeSlashReturn = r.into();
                        r.actualSlashed
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
                        let r: executeSlashReturn = r.into();
                        r.actualSlashed
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `executeSlashBatch(uint64[])` and selector `0xb055449b`.
```solidity
function executeSlashBatch(uint64[] memory slashIds) external returns (uint256 totalSlashed, uint256 executedCount);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct executeSlashBatchCall {
        #[allow(missing_docs)]
        pub slashIds: alloy::sol_types::private::Vec<u64>,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`executeSlashBatch(uint64[])`](executeSlashBatchCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct executeSlashBatchReturn {
        #[allow(missing_docs)]
        pub totalSlashed: alloy::sol_types::private::primitives::aliases::U256,
        #[allow(missing_docs)]
        pub executedCount: alloy::sol_types::private::primitives::aliases::U256,
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
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Uint<64>>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Vec<u64>,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<executeSlashBatchCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: executeSlashBatchCall) -> Self {
                    (value.slashIds,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for executeSlashBatchCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { slashIds: tuple.0 }
                }
            }
        }
        {
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
            impl ::core::convert::From<executeSlashBatchReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: executeSlashBatchReturn) -> Self {
                    (value.totalSlashed, value.executedCount)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for executeSlashBatchReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        totalSlashed: tuple.0,
                        executedCount: tuple.1,
                    }
                }
            }
        }
        impl executeSlashBatchReturn {
            fn _tokenize(
                &self,
            ) -> <executeSlashBatchCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.totalSlashed),
                    <alloy::sol_types::sol_data::Uint<
                        256,
                    > as alloy_sol_types::SolType>::tokenize(&self.executedCount),
                )
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for executeSlashBatchCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Uint<64>>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = executeSlashBatchReturn;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Uint<256>,
                alloy::sol_types::sol_data::Uint<256>,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "executeSlashBatch(uint64[])";
            const SELECTOR: [u8; 4] = [176u8, 85u8, 68u8, 155u8];
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
                        alloy::sol_types::sol_data::Uint<64>,
                    > as alloy_sol_types::SolType>::tokenize(&self.slashIds),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                executeSlashBatchReturn::_tokenize(ret)
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
    /**Function with signature `getExecutableSlashes(uint64,uint64)` and selector `0x110f829b`.
```solidity
function getExecutableSlashes(uint64 fromId, uint64 toId) external view returns (uint64[] memory ids);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getExecutableSlashesCall {
        #[allow(missing_docs)]
        pub fromId: u64,
        #[allow(missing_docs)]
        pub toId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`getExecutableSlashes(uint64,uint64)`](getExecutableSlashesCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getExecutableSlashesReturn {
        #[allow(missing_docs)]
        pub ids: alloy::sol_types::private::Vec<u64>,
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
            impl ::core::convert::From<getExecutableSlashesCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getExecutableSlashesCall) -> Self {
                    (value.fromId, value.toId)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getExecutableSlashesCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        fromId: tuple.0,
                        toId: tuple.1,
                    }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Uint<64>>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (alloy::sol_types::private::Vec<u64>,);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<getExecutableSlashesReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getExecutableSlashesReturn) -> Self {
                    (value.ids,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getExecutableSlashesReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { ids: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getExecutableSlashesCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Uint<64>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = alloy::sol_types::private::Vec<u64>;
            type ReturnTuple<'a> = (
                alloy::sol_types::sol_data::Array<alloy::sol_types::sol_data::Uint<64>>,
            );
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getExecutableSlashes(uint64,uint64)";
            const SELECTOR: [u8; 4] = [17u8, 15u8, 130u8, 155u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.fromId),
                    <alloy::sol_types::sol_data::Uint<
                        64,
                    > as alloy_sol_types::SolType>::tokenize(&self.toId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <alloy::sol_types::sol_data::Array<
                        alloy::sol_types::sol_data::Uint<64>,
                    > as alloy_sol_types::SolType>::tokenize(ret),
                )
            }
            #[inline]
            fn abi_decode_returns(data: &[u8]) -> alloy_sol_types::Result<Self::Return> {
                <Self::ReturnTuple<
                    '_,
                > as alloy_sol_types::SolType>::abi_decode_sequence(data)
                    .map(|r| {
                        let r: getExecutableSlashesReturn = r.into();
                        r.ids
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
                        let r: getExecutableSlashesReturn = r.into();
                        r.ids
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `getSlashProposal(uint64)` and selector `0xef1b42a2`.
```solidity
function getSlashProposal(uint64 slashId) external view returns (SlashingLib.SlashProposal memory);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashProposalCall {
        #[allow(missing_docs)]
        pub slashId: u64,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive()]
    ///Container type for the return parameters of the [`getSlashProposal(uint64)`](getSlashProposalCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct getSlashProposalReturn {
        #[allow(missing_docs)]
        pub _0: <SlashingLib::SlashProposal as alloy::sol_types::SolType>::RustType,
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
            impl ::core::convert::From<getSlashProposalCall>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashProposalCall) -> Self {
                    (value.slashId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashProposalCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { slashId: tuple.0 }
                }
            }
        }
        {
            #[doc(hidden)]
            #[allow(dead_code)]
            type UnderlyingSolTuple<'a> = (SlashingLib::SlashProposal,);
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                <SlashingLib::SlashProposal as alloy::sol_types::SolType>::RustType,
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
            impl ::core::convert::From<getSlashProposalReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: getSlashProposalReturn) -> Self {
                    (value._0,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for getSlashProposalReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { _0: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for getSlashProposalCall {
            type Parameters<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = <SlashingLib::SlashProposal as alloy::sol_types::SolType>::RustType;
            type ReturnTuple<'a> = (SlashingLib::SlashProposal,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "getSlashProposal(uint64)";
            const SELECTOR: [u8; 4] = [239u8, 27u8, 66u8, 162u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.slashId),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                (
                    <SlashingLib::SlashProposal as alloy_sol_types::SolType>::tokenize(
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
                        let r: getSlashProposalReturn = r.into();
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
                        let r: getSlashProposalReturn = r.into();
                        r._0
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `proposeSlash(uint64,address,uint16,bytes32)` and selector `0x0472d2ff`.
```solidity
function proposeSlash(uint64 serviceId, address operator, uint16 slashBps, bytes32 evidence) external returns (uint64 slashId);
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct proposeSlashCall {
        #[allow(missing_docs)]
        pub serviceId: u64,
        #[allow(missing_docs)]
        pub operator: alloy::sol_types::private::Address,
        #[allow(missing_docs)]
        pub slashBps: u16,
        #[allow(missing_docs)]
        pub evidence: alloy::sol_types::private::FixedBytes<32>,
    }
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    ///Container type for the return parameters of the [`proposeSlash(uint64,address,uint16,bytes32)`](proposeSlashCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct proposeSlashReturn {
        #[allow(missing_docs)]
        pub slashId: u64,
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
                alloy::sol_types::sol_data::Uint<16>,
                alloy::sol_types::sol_data::FixedBytes<32>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (
                u64,
                alloy::sol_types::private::Address,
                u16,
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
            impl ::core::convert::From<proposeSlashCall> for UnderlyingRustTuple<'_> {
                fn from(value: proposeSlashCall) -> Self {
                    (value.serviceId, value.operator, value.slashBps, value.evidence)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for proposeSlashCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        serviceId: tuple.0,
                        operator: tuple.1,
                        slashBps: tuple.2,
                        evidence: tuple.3,
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
            impl ::core::convert::From<proposeSlashReturn> for UnderlyingRustTuple<'_> {
                fn from(value: proposeSlashReturn) -> Self {
                    (value.slashId,)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for proposeSlashReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self { slashId: tuple.0 }
                }
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for proposeSlashCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Address,
                alloy::sol_types::sol_data::Uint<16>,
                alloy::sol_types::sol_data::FixedBytes<32>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = u64;
            type ReturnTuple<'a> = (alloy::sol_types::sol_data::Uint<64>,);
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "proposeSlash(uint64,address,uint16,bytes32)";
            const SELECTOR: [u8; 4] = [4u8, 114u8, 210u8, 255u8];
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
                    <alloy::sol_types::sol_data::Uint<
                        16,
                    > as alloy_sol_types::SolType>::tokenize(&self.slashBps),
                    <alloy::sol_types::sol_data::FixedBytes<
                        32,
                    > as alloy_sol_types::SolType>::tokenize(&self.evidence),
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
                        let r: proposeSlashReturn = r.into();
                        r.slashId
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
                        let r: proposeSlashReturn = r.into();
                        r.slashId
                    })
            }
        }
    };
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Default, Debug, PartialEq, Eq, Hash)]
    /**Function with signature `setSlashConfig(uint64,bool,uint16)` and selector `0x78867a16`.
```solidity
function setSlashConfig(uint64 disputeWindow, bool instantSlashEnabled, uint16 maxSlashBps) external;
```*/
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct setSlashConfigCall {
        #[allow(missing_docs)]
        pub disputeWindow: u64,
        #[allow(missing_docs)]
        pub instantSlashEnabled: bool,
        #[allow(missing_docs)]
        pub maxSlashBps: u16,
    }
    ///Container type for the return parameters of the [`setSlashConfig(uint64,bool,uint16)`](setSlashConfigCall) function.
    #[allow(non_camel_case_types, non_snake_case, clippy::pub_underscore_fields)]
    #[derive(Clone)]
    pub struct setSlashConfigReturn {}
    #[allow(
        non_camel_case_types,
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
                alloy::sol_types::sol_data::Uint<16>,
            );
            #[doc(hidden)]
            type UnderlyingRustTuple<'a> = (u64, bool, u16);
            #[cfg(test)]
            #[allow(dead_code, unreachable_patterns)]
            fn _type_assertion(
                _t: alloy_sol_types::private::AssertTypeEq<UnderlyingRustTuple>,
            ) {
                match _t {
                    alloy_sol_types::private::AssertTypeEq::<
                        <UnderlyingSolTuple as alloy_sol_types::SolType>::RustType,
                    >(_) => {}
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<setSlashConfigCall> for UnderlyingRustTuple<'_> {
                fn from(value: setSlashConfigCall) -> Self {
                    (value.disputeWindow, value.instantSlashEnabled, value.maxSlashBps)
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>> for setSlashConfigCall {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {
                        disputeWindow: tuple.0,
                        instantSlashEnabled: tuple.1,
                        maxSlashBps: tuple.2,
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
            impl ::core::convert::From<setSlashConfigReturn>
            for UnderlyingRustTuple<'_> {
                fn from(value: setSlashConfigReturn) -> Self {
                    ()
                }
            }
            #[automatically_derived]
            #[doc(hidden)]
            impl ::core::convert::From<UnderlyingRustTuple<'_>>
            for setSlashConfigReturn {
                fn from(tuple: UnderlyingRustTuple<'_>) -> Self {
                    Self {}
                }
            }
        }
        impl setSlashConfigReturn {
            fn _tokenize(
                &self,
            ) -> <setSlashConfigCall as alloy_sol_types::SolCall>::ReturnToken<'_> {
                ()
            }
        }
        #[automatically_derived]
        impl alloy_sol_types::SolCall for setSlashConfigCall {
            type Parameters<'a> = (
                alloy::sol_types::sol_data::Uint<64>,
                alloy::sol_types::sol_data::Bool,
                alloy::sol_types::sol_data::Uint<16>,
            );
            type Token<'a> = <Self::Parameters<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            type Return = setSlashConfigReturn;
            type ReturnTuple<'a> = ();
            type ReturnToken<'a> = <Self::ReturnTuple<
                'a,
            > as alloy_sol_types::SolType>::Token<'a>;
            const SIGNATURE: &'static str = "setSlashConfig(uint64,bool,uint16)";
            const SELECTOR: [u8; 4] = [120u8, 134u8, 122u8, 22u8];
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
                    > as alloy_sol_types::SolType>::tokenize(&self.disputeWindow),
                    <alloy::sol_types::sol_data::Bool as alloy_sol_types::SolType>::tokenize(
                        &self.instantSlashEnabled,
                    ),
                    <alloy::sol_types::sol_data::Uint<
                        16,
                    > as alloy_sol_types::SolType>::tokenize(&self.maxSlashBps),
                )
            }
            #[inline]
            fn tokenize_returns(ret: &Self::Return) -> Self::ReturnToken<'_> {
                setSlashConfigReturn::_tokenize(ret)
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
    ///Container for all the [`ITangleSlashing`](self) function calls.
    #[derive(Clone)]
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive()]
    pub enum ITangleSlashingCalls {
        #[allow(missing_docs)]
        cancelSlash(cancelSlashCall),
        #[allow(missing_docs)]
        disputeSlash(disputeSlashCall),
        #[allow(missing_docs)]
        executeSlash(executeSlashCall),
        #[allow(missing_docs)]
        executeSlashBatch(executeSlashBatchCall),
        #[allow(missing_docs)]
        getExecutableSlashes(getExecutableSlashesCall),
        #[allow(missing_docs)]
        getSlashProposal(getSlashProposalCall),
        #[allow(missing_docs)]
        proposeSlash(proposeSlashCall),
        #[allow(missing_docs)]
        setSlashConfig(setSlashConfigCall),
    }
    impl ITangleSlashingCalls {
        /// All the selectors of this enum.
        ///
        /// Note that the selectors might not be in the same order as the variants.
        /// No guarantees are made about the order of the selectors.
        ///
        /// Prefer using `SolInterface` methods instead.
        pub const SELECTORS: &'static [[u8; 4usize]] = &[
            [4u8, 114u8, 210u8, 255u8],
            [6u8, 7u8, 157u8, 197u8],
            [17u8, 15u8, 130u8, 155u8],
            [119u8, 56u8, 12u8, 116u8],
            [120u8, 134u8, 122u8, 22u8],
            [165u8, 191u8, 186u8, 228u8],
            [176u8, 85u8, 68u8, 155u8],
            [239u8, 27u8, 66u8, 162u8],
        ];
        /// The names of the variants in the same order as `SELECTORS`.
        pub const VARIANT_NAMES: &'static [&'static str] = &[
            ::core::stringify!(proposeSlash),
            ::core::stringify!(cancelSlash),
            ::core::stringify!(getExecutableSlashes),
            ::core::stringify!(disputeSlash),
            ::core::stringify!(setSlashConfig),
            ::core::stringify!(executeSlash),
            ::core::stringify!(executeSlashBatch),
            ::core::stringify!(getSlashProposal),
        ];
        /// The signatures in the same order as `SELECTORS`.
        pub const SIGNATURES: &'static [&'static str] = &[
            <proposeSlashCall as alloy_sol_types::SolCall>::SIGNATURE,
            <cancelSlashCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getExecutableSlashesCall as alloy_sol_types::SolCall>::SIGNATURE,
            <disputeSlashCall as alloy_sol_types::SolCall>::SIGNATURE,
            <setSlashConfigCall as alloy_sol_types::SolCall>::SIGNATURE,
            <executeSlashCall as alloy_sol_types::SolCall>::SIGNATURE,
            <executeSlashBatchCall as alloy_sol_types::SolCall>::SIGNATURE,
            <getSlashProposalCall as alloy_sol_types::SolCall>::SIGNATURE,
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
    impl alloy_sol_types::SolInterface for ITangleSlashingCalls {
        const NAME: &'static str = "ITangleSlashingCalls";
        const MIN_DATA_LENGTH: usize = 32usize;
        const COUNT: usize = 8usize;
        #[inline]
        fn selector(&self) -> [u8; 4] {
            match self {
                Self::cancelSlash(_) => {
                    <cancelSlashCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::disputeSlash(_) => {
                    <disputeSlashCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::executeSlash(_) => {
                    <executeSlashCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::executeSlashBatch(_) => {
                    <executeSlashBatchCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getExecutableSlashes(_) => {
                    <getExecutableSlashesCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::getSlashProposal(_) => {
                    <getSlashProposalCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::proposeSlash(_) => {
                    <proposeSlashCall as alloy_sol_types::SolCall>::SELECTOR
                }
                Self::setSlashConfig(_) => {
                    <setSlashConfigCall as alloy_sol_types::SolCall>::SELECTOR
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
            ) -> alloy_sol_types::Result<ITangleSlashingCalls>] = &[
                {
                    fn proposeSlash(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <proposeSlashCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(ITangleSlashingCalls::proposeSlash)
                    }
                    proposeSlash
                },
                {
                    fn cancelSlash(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <cancelSlashCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(ITangleSlashingCalls::cancelSlash)
                    }
                    cancelSlash
                },
                {
                    fn getExecutableSlashes(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <getExecutableSlashesCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(ITangleSlashingCalls::getExecutableSlashes)
                    }
                    getExecutableSlashes
                },
                {
                    fn disputeSlash(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <disputeSlashCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(ITangleSlashingCalls::disputeSlash)
                    }
                    disputeSlash
                },
                {
                    fn setSlashConfig(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <setSlashConfigCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(ITangleSlashingCalls::setSlashConfig)
                    }
                    setSlashConfig
                },
                {
                    fn executeSlash(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <executeSlashCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(ITangleSlashingCalls::executeSlash)
                    }
                    executeSlash
                },
                {
                    fn executeSlashBatch(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <executeSlashBatchCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(ITangleSlashingCalls::executeSlashBatch)
                    }
                    executeSlashBatch
                },
                {
                    fn getSlashProposal(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <getSlashProposalCall as alloy_sol_types::SolCall>::abi_decode_raw(
                                data,
                            )
                            .map(ITangleSlashingCalls::getSlashProposal)
                    }
                    getSlashProposal
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
            ) -> alloy_sol_types::Result<ITangleSlashingCalls>] = &[
                {
                    fn proposeSlash(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <proposeSlashCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(ITangleSlashingCalls::proposeSlash)
                    }
                    proposeSlash
                },
                {
                    fn cancelSlash(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <cancelSlashCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(ITangleSlashingCalls::cancelSlash)
                    }
                    cancelSlash
                },
                {
                    fn getExecutableSlashes(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <getExecutableSlashesCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(ITangleSlashingCalls::getExecutableSlashes)
                    }
                    getExecutableSlashes
                },
                {
                    fn disputeSlash(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <disputeSlashCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(ITangleSlashingCalls::disputeSlash)
                    }
                    disputeSlash
                },
                {
                    fn setSlashConfig(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <setSlashConfigCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(ITangleSlashingCalls::setSlashConfig)
                    }
                    setSlashConfig
                },
                {
                    fn executeSlash(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <executeSlashCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(ITangleSlashingCalls::executeSlash)
                    }
                    executeSlash
                },
                {
                    fn executeSlashBatch(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <executeSlashBatchCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(ITangleSlashingCalls::executeSlashBatch)
                    }
                    executeSlashBatch
                },
                {
                    fn getSlashProposal(
                        data: &[u8],
                    ) -> alloy_sol_types::Result<ITangleSlashingCalls> {
                        <getSlashProposalCall as alloy_sol_types::SolCall>::abi_decode_raw_validate(
                                data,
                            )
                            .map(ITangleSlashingCalls::getSlashProposal)
                    }
                    getSlashProposal
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
                Self::cancelSlash(inner) => {
                    <cancelSlashCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::disputeSlash(inner) => {
                    <disputeSlashCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::executeSlash(inner) => {
                    <executeSlashCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::executeSlashBatch(inner) => {
                    <executeSlashBatchCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getExecutableSlashes(inner) => {
                    <getExecutableSlashesCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::getSlashProposal(inner) => {
                    <getSlashProposalCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::proposeSlash(inner) => {
                    <proposeSlashCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
                Self::setSlashConfig(inner) => {
                    <setSlashConfigCall as alloy_sol_types::SolCall>::abi_encoded_size(
                        inner,
                    )
                }
            }
        }
        #[inline]
        fn abi_encode_raw(&self, out: &mut alloy_sol_types::private::Vec<u8>) {
            match self {
                Self::cancelSlash(inner) => {
                    <cancelSlashCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::disputeSlash(inner) => {
                    <disputeSlashCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::executeSlash(inner) => {
                    <executeSlashCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::executeSlashBatch(inner) => {
                    <executeSlashBatchCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getExecutableSlashes(inner) => {
                    <getExecutableSlashesCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::getSlashProposal(inner) => {
                    <getSlashProposalCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::proposeSlash(inner) => {
                    <proposeSlashCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
                Self::setSlashConfig(inner) => {
                    <setSlashConfigCall as alloy_sol_types::SolCall>::abi_encode_raw(
                        inner,
                        out,
                    )
                }
            }
        }
    }
    ///Container for all the [`ITangleSlashing`](self) events.
    #[derive(Clone)]
    #[derive(serde::Serialize, serde::Deserialize)]
    #[derive(Debug, PartialEq, Eq, Hash)]
    pub enum ITangleSlashingEvents {
        #[allow(missing_docs)]
        SlashExecuted(SlashExecuted),
        #[allow(missing_docs)]
        SlashProposed(SlashProposed),
    }
    impl ITangleSlashingEvents {
        /// All the selectors of this enum.
        ///
        /// Note that the selectors might not be in the same order as the variants.
        /// No guarantees are made about the order of the selectors.
        ///
        /// Prefer using `SolInterface` methods instead.
        pub const SELECTORS: &'static [[u8; 32usize]] = &[
            [
                15u8, 158u8, 185u8, 41u8, 230u8, 85u8, 246u8, 202u8, 18u8, 147u8, 187u8,
                221u8, 186u8, 222u8, 14u8, 191u8, 44u8, 75u8, 32u8, 157u8, 68u8, 84u8,
                213u8, 57u8, 152u8, 37u8, 86u8, 24u8, 146u8, 64u8, 73u8, 98u8,
            ],
            [
                38u8, 197u8, 196u8, 38u8, 223u8, 69u8, 45u8, 104u8, 227u8, 179u8, 210u8,
                124u8, 123u8, 6u8, 154u8, 98u8, 205u8, 38u8, 138u8, 217u8, 225u8, 205u8,
                85u8, 201u8, 201u8, 242u8, 57u8, 50u8, 8u8, 144u8, 222u8, 35u8,
            ],
        ];
        /// The names of the variants in the same order as `SELECTORS`.
        pub const VARIANT_NAMES: &'static [&'static str] = &[
            ::core::stringify!(SlashProposed),
            ::core::stringify!(SlashExecuted),
        ];
        /// The signatures in the same order as `SELECTORS`.
        pub const SIGNATURES: &'static [&'static str] = &[
            <SlashProposed as alloy_sol_types::SolEvent>::SIGNATURE,
            <SlashExecuted as alloy_sol_types::SolEvent>::SIGNATURE,
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
    impl alloy_sol_types::SolEventInterface for ITangleSlashingEvents {
        const NAME: &'static str = "ITangleSlashingEvents";
        const COUNT: usize = 2usize;
        fn decode_raw_log(
            topics: &[alloy_sol_types::Word],
            data: &[u8],
        ) -> alloy_sol_types::Result<Self> {
            match topics.first().copied() {
                Some(<SlashExecuted as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <SlashExecuted as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::SlashExecuted)
                }
                Some(<SlashProposed as alloy_sol_types::SolEvent>::SIGNATURE_HASH) => {
                    <SlashProposed as alloy_sol_types::SolEvent>::decode_raw_log(
                            topics,
                            data,
                        )
                        .map(Self::SlashProposed)
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
    impl alloy_sol_types::private::IntoLogData for ITangleSlashingEvents {
        fn to_log_data(&self) -> alloy_sol_types::private::LogData {
            match self {
                Self::SlashExecuted(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
                Self::SlashProposed(inner) => {
                    alloy_sol_types::private::IntoLogData::to_log_data(inner)
                }
            }
        }
        fn into_log_data(self) -> alloy_sol_types::private::LogData {
            match self {
                Self::SlashExecuted(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
                Self::SlashProposed(inner) => {
                    alloy_sol_types::private::IntoLogData::into_log_data(inner)
                }
            }
        }
    }
    use alloy::contract as alloy_contract;
    /**Creates a new wrapper around an on-chain [`ITangleSlashing`](self) contract instance.

See the [wrapper's documentation](`ITangleSlashingInstance`) for more details.*/
    #[inline]
    pub const fn new<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    >(
        address: alloy_sol_types::private::Address,
        __provider: P,
    ) -> ITangleSlashingInstance<P, N> {
        ITangleSlashingInstance::<P, N>::new(address, __provider)
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
        Output = alloy_contract::Result<ITangleSlashingInstance<P, N>>,
    > {
        ITangleSlashingInstance::<P, N>::deploy(__provider)
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
        ITangleSlashingInstance::<P, N>::deploy_builder(__provider)
    }
    /**A [`ITangleSlashing`](self) instance.

Contains type-safe methods for interacting with an on-chain instance of the
[`ITangleSlashing`](self) contract located at a given `address`, using a given
provider `P`.

If the contract bytecode is available (see the [`sol!`](alloy_sol_types::sol!)
documentation on how to provide it), the `deploy` and `deploy_builder` methods can
be used to deploy a new instance of the contract.

See the [module-level documentation](self) for all the available methods.*/
    #[derive(Clone)]
    pub struct ITangleSlashingInstance<P, N = alloy_contract::private::Ethereum> {
        address: alloy_sol_types::private::Address,
        provider: P,
        _network: ::core::marker::PhantomData<N>,
    }
    #[automatically_derived]
    impl<P, N> ::core::fmt::Debug for ITangleSlashingInstance<P, N> {
        #[inline]
        fn fmt(&self, f: &mut ::core::fmt::Formatter<'_>) -> ::core::fmt::Result {
            f.debug_tuple("ITangleSlashingInstance").field(&self.address).finish()
        }
    }
    /// Instantiation and getters/setters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > ITangleSlashingInstance<P, N> {
        /**Creates a new wrapper around an on-chain [`ITangleSlashing`](self) contract instance.

See the [wrapper's documentation](`ITangleSlashingInstance`) for more details.*/
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
        ) -> alloy_contract::Result<ITangleSlashingInstance<P, N>> {
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
    impl<P: ::core::clone::Clone, N> ITangleSlashingInstance<&P, N> {
        /// Clones the provider and returns a new instance with the cloned provider.
        #[inline]
        pub fn with_cloned_provider(self) -> ITangleSlashingInstance<P, N> {
            ITangleSlashingInstance {
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
    > ITangleSlashingInstance<P, N> {
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
        ///Creates a new call builder for the [`cancelSlash`] function.
        pub fn cancelSlash(
            &self,
            slashId: u64,
            reason: alloy::sol_types::private::String,
        ) -> alloy_contract::SolCallBuilder<&P, cancelSlashCall, N> {
            self.call_builder(&cancelSlashCall { slashId, reason })
        }
        ///Creates a new call builder for the [`disputeSlash`] function.
        pub fn disputeSlash(
            &self,
            slashId: u64,
            reason: alloy::sol_types::private::String,
        ) -> alloy_contract::SolCallBuilder<&P, disputeSlashCall, N> {
            self.call_builder(
                &disputeSlashCall {
                    slashId,
                    reason,
                },
            )
        }
        ///Creates a new call builder for the [`executeSlash`] function.
        pub fn executeSlash(
            &self,
            slashId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, executeSlashCall, N> {
            self.call_builder(&executeSlashCall { slashId })
        }
        ///Creates a new call builder for the [`executeSlashBatch`] function.
        pub fn executeSlashBatch(
            &self,
            slashIds: alloy::sol_types::private::Vec<u64>,
        ) -> alloy_contract::SolCallBuilder<&P, executeSlashBatchCall, N> {
            self.call_builder(&executeSlashBatchCall { slashIds })
        }
        ///Creates a new call builder for the [`getExecutableSlashes`] function.
        pub fn getExecutableSlashes(
            &self,
            fromId: u64,
            toId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, getExecutableSlashesCall, N> {
            self.call_builder(
                &getExecutableSlashesCall {
                    fromId,
                    toId,
                },
            )
        }
        ///Creates a new call builder for the [`getSlashProposal`] function.
        pub fn getSlashProposal(
            &self,
            slashId: u64,
        ) -> alloy_contract::SolCallBuilder<&P, getSlashProposalCall, N> {
            self.call_builder(&getSlashProposalCall { slashId })
        }
        ///Creates a new call builder for the [`proposeSlash`] function.
        pub fn proposeSlash(
            &self,
            serviceId: u64,
            operator: alloy::sol_types::private::Address,
            slashBps: u16,
            evidence: alloy::sol_types::private::FixedBytes<32>,
        ) -> alloy_contract::SolCallBuilder<&P, proposeSlashCall, N> {
            self.call_builder(
                &proposeSlashCall {
                    serviceId,
                    operator,
                    slashBps,
                    evidence,
                },
            )
        }
        ///Creates a new call builder for the [`setSlashConfig`] function.
        pub fn setSlashConfig(
            &self,
            disputeWindow: u64,
            instantSlashEnabled: bool,
            maxSlashBps: u16,
        ) -> alloy_contract::SolCallBuilder<&P, setSlashConfigCall, N> {
            self.call_builder(
                &setSlashConfigCall {
                    disputeWindow,
                    instantSlashEnabled,
                    maxSlashBps,
                },
            )
        }
    }
    /// Event filters.
    impl<
        P: alloy_contract::private::Provider<N>,
        N: alloy_contract::private::Network,
    > ITangleSlashingInstance<P, N> {
        /// Creates a new event filter using this contract instance's provider and address.
        ///
        /// Note that the type can be any event, not just those defined in this contract.
        /// Prefer using the other methods for building type-safe event filters.
        pub fn event_filter<E: alloy_sol_types::SolEvent>(
            &self,
        ) -> alloy_contract::Event<&P, E, N> {
            alloy_contract::Event::new_sol(&self.provider, &self.address)
        }
        ///Creates a new event filter for the [`SlashExecuted`] event.
        pub fn SlashExecuted_filter(
            &self,
        ) -> alloy_contract::Event<&P, SlashExecuted, N> {
            self.event_filter::<SlashExecuted>()
        }
        ///Creates a new event filter for the [`SlashProposed`] event.
        pub fn SlashProposed_filter(
            &self,
        ) -> alloy_contract::Event<&P, SlashProposed, N> {
            self.event_filter::<SlashProposed>()
        }
    }
}
