# Tangle v2 Progress

## Target
Production-ready EVM protocol for Tempo L1.

## Status: CORE IMPLEMENTATION COMPLETE

---

## Completed

- [x] Architecture design (see DESIGN.md)
- [x] Types library (`Types.sol`)
- [x] Errors library (`Errors.sol`)
- [x] IRestaking interface
- [x] IBlueprintHook interface + base implementation
- [x] ITangle interface
- [x] Tangle.sol core contract
- [x] NativeRestaking.sol (native token staking)
- [x] ERC20Restaking.sol (LST/ERC20 support)
- [x] EigenLayerRestaking.sol (EigenLayer adapter)
- [x] SymbioticRestaking.sol (Symbiotic adapter)
- [x] Core tests (71 passing)

## Pending

- [ ] Deploy scripts
- [ ] Integration tests for adapters
- [ ] Documentation

---

## File Structure

```
src/v2/
├── Tangle.sol                    ✅ Core protocol
├── interfaces/
│   ├── ITangle.sol               ✅ Core interface
│   ├── IRestaking.sol            ✅ Staking abstraction
│   └── IBlueprintHook.sol        ✅ Hook interface + base
├── restaking/
│   ├── NativeRestaking.sol       ✅ Native token staking
│   ├── ERC20Restaking.sol        ✅ LST/ERC20 support
│   ├── EigenLayerRestaking.sol   ✅ EigenLayer adapter
│   └── SymbioticRestaking.sol    ✅ Symbiotic adapter
└── libraries/
    ├── Types.sol                 ✅ Shared types
    └── Errors.sol                ✅ Custom errors
```

## Key Design Decisions

1. **Single core contract** - Tangle.sol handles all protocol logic
2. **Abstract staking** - IRestaking interface for pluggable backends
3. **Optional hooks** - Blueprints can customize via IBlueprintHook
4. **Masterchef rewards** - O(1) claim via accumulated-per-share
5. **Packed structs** - Gas-optimized storage
6. **Multi-protocol support** - Native, ERC20, EigenLayer, Symbiotic

---

## DeFi Integration

### Supported Restaking Protocols

| Protocol | Contract | Status |
|----------|----------|--------|
| Native ETH | NativeRestaking.sol | ✅ Complete |
| Any ERC20/LST | ERC20Restaking.sol | ✅ Complete |
| EigenLayer | EigenLayerRestaking.sol | ✅ Complete |
| Symbiotic | SymbioticRestaking.sol | ✅ Complete |

### LST Support (EtherFi, Lido, Renzo, etc.)

The `ERC20Restaking` contract enables **permissionless** integration:

```solidity
// Any ERC20 can be enabled for staking
restaking.enableToken(
    stETH,                // token address
    1 ether,              // min operator stake
    0.1 ether,            // min delegation
    10000                 // multiplier (10000 = 1x)
);

// Operators stake with their preferred LST
restaking.registerOperator(stETH, 10 ether);

// Delegators use any enabled token
restaking.deposit(eETH, 5 ether);
restaking.delegate(operator, eETH, 5 ether);
```

### Integration Points

1. **TOKEN_MANAGER_ROLE** - Protocols can request token whitelisting
2. **Standard ERC20** - Works with any compliant token
3. **Multipliers** - Support rebasing tokens with value multipliers
4. **No supervision required** - Standard interfaces, self-service

### Protocol-Specific Adapters

**EigenLayer:**
- Wraps DelegationManager, StrategyManager, AVSDirectory
- Operators register through EigenLayer, opt into Tangle AVS
- Stake queries aggregate across configured strategies

**Symbiotic:**
- Wraps OperatorRegistry, Network, Slasher
- Operators opt into Tangle network
- Stake queries aggregate across configured vaults

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Tangle.sol                           │
│   (Blueprints, Services, Jobs, Payments, Rewards)           │
└─────────────────────────┬───────────────────────────────────┘
                          │ IRestaking
          ┌───────────────┼───────────────┬───────────────┐
          │               │               │               │
          ▼               ▼               ▼               ▼
   NativeRestaking  ERC20Restaking  EigenLayer    Symbiotic
      (ETH)           (LSTs)         Adapter       Adapter
```
