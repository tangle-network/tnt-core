# tnt-core Full Protocol Security Audit

**Auditor:** Tangle Redteam (agentic) · **Model:** Claude Opus 4.8 + extended reasoning · **Commit:** `1a3330f` · **Date:** 2026-06-14

**1 critical · 21 high · 41 medium · 35 low · 3 info** (101 unique issues, deduped from 144 raw across 17 module audits).

## How to read this
- **✅ PoC** = a runnable Foundry exploit test was written and passed (highest confidence; see `test/audit/opus-2026-06-14/`).
- **conf** = the auditor's self-rated confidence (0–1). **`Nx`** = independently flagged by N module passes (corroboration).
- These are **machine-generated findings**. The ✅ PoC items are verified; the rest are **leads requiring developer confirmation** before fixing. Expect some false positives.
- Scope: full `src/` (33.5k LOC) except the 5 top-level files (`root` shard hit an API cap mid-run — partial; `Tangle.sol` was separately covered).

## 🔴 Critical (1)

### C1. Permissionless sendMessage in L1 messengers → forged BEACON_SLASH under opStack mode ✅ **PoC**
`src/beacon/bridges/BaseCrossChainMessenger.sol:54` · access-control · conf 0.85 · 2×

SETUP: The slash path is L2SlashingConnector → ICrossChainMessenger.sendMessage → native L1 bridge → L2SlashingReceiver.receiveMessage. For Base/OP-Stack, L2SlashingReceiver runs in opStackMessengerMode: it DISCARDS the calldata `sender` and authenticates by `IOpStackCrossDomainMessenger(messenger).xDomainMessageSender() == opStackL1Sender[srcChain]` (L2SlashingReceiver.sol:304-314). Because the connector reaches the native L1 messenger only THROUGH the adapter, the L1 contract that calls `l1Messenger.sendMessage` is BaseCrossChainMessenger itself, so `xDomainMessageSender()` on L2 always returns the adapter address. Therefore opStackL1Sender MUST be configured to the adapter for the legit flow to authenticate.

ATTACK: BaseCrossChainMessenger.sendMessage (line 54) has NO caller authorization — only a destinationChainId check (line 64). Any EOA/contract calls `BaseCrossChainMessenger.sendMessage(8453, L2SlashingReceiver, forgedPayload, gas)`. Line 72-77 forwards to the native messenger under the ADAPTER's own identity; the attacker's address is placed only in the calldata `sender` arg (line 74), which opStack mode ignores. On L2: msg.sender == native messenger (passes onlyMessenger), xDomainMessageSender() == BaseCrossChainMessenger == opStackL1Sender (passes). forgedPayload = SLASH_MESSAGE_TYPE ‖ abi.encode(operator, slashBps, factor, nonce, pod) — every field is attacker-chosen and on-chain-derivable (see L2SlashingConnector.sol:266-268).

OUTCOME: Attacker forges an arbitrary BEACON_SLASH against ANY operator with any slashBps/nonce, bypassing beacon-chain verification. The adapter is a permissionless open relay / confused deputy: it lends its trusted xDomainMessageSender identity to attacker payloads. Fix: gate sendMessage to an authorized caller (the connector), or have the receiver authenticate the true origin rather than the relaying adapter. ArbitrumCrossChainMessenger.sendMessage (lines 105-151) is identically unauthenticated.

## 🟠 High (21)

### H1. getOrCreateLock access control breaks genesis lockup distribution (DoS)
`src/governance/lockups/TNTLockFactory.sol:52` · access-control · conf 0.95 · 2×

getOrCreateLock requires msg.sender==beneficiary, but its only intended caller, the genesis distributor DistributeTNTWithLockup.s.sol:121, invokes it as the DEPLOYER on behalf of each recipient: factory.getOrCreateLock(token, t.to, unlockTimestamp, t.to) under vm.startBroadcast(deployerKey). Since deployer != t.to, the call reverts NotBeneficiary(deployer, t.to) for EVERY recipient. A forge-script revert aborts the whole run(), so the entire locked distribution (the 90%-locked genesis tranche) cannot execute. Confirmed by Foundry PoC test_distributionFlow_alwaysReverts (PASS). The natural ops fix - removing the beneficiary guard - directly reintroduces the delegation hijack the contract comment (lines 35-42) claims to mitigate (see F-002). The factory cannot simultaneously be batch-distributable and hijack-safe under this design.

### H2. Inverted/truncating decimal scaling in UniswapV3Oracle prices assets at 0x or 1e6x
`src/oracles/UniswapV3Oracle.sol:386` · loss-of-precision · conf 0.95

_getPriceFromSqrtX96 computes the raw token ratio with (sqrtPriceX96*sqrtPriceX96)>>192 BEFORE any decimal adjustment, then applies price*(10**quoteDecimals)/(10**tokenDecimals). Both the early truncation and the decimal factor are wrong. SETUP: configurePool for the canonical WETH(18,token0)/USDC(6,token1,quoteIsUsd) pool. ATTACK/OUTCOME: raw ratio token1/token0 ~3e-9 truncates to 0 -> getPriceData returns price=0 with isValid=true (line 404,324-329). Re-running test/oracles/OraclePoC.t.sol::test_PriceTruncatesToZero_WethAsToken0 yields price=0. In the non-truncated orientation (6-dec token0 / 18-dec quote) the decimal factor is INVERTED, overstating price by 10^tokenDecimals (1e6x) -- test_DecimalScalingInverted_Overvalues returns 1.8e15 vs correct 1.8e9. The correct factor to express quote_raw per whole token is *10^tokenDecimals applied via mulDiv before truncation; the code uses 10^qd/10^td. oracle.toUSD() feeds USD-weighting in Slashing.sol:214, PaymentsEffectiveExposure.sol:94, ServiceFeeDistributor.sol:1365 -- so a $0-priced asset escapes slashing weight / exposure and a 1e6x-overpriced asset dominates reward and exposure weighting. Manifests under STANDARD pool configuration, not attacker-only config.

### H3. RewardVaults top-up does not settle reward debt -> steal prior epoch rewards ✅ **PoC**
`src/rewards/RewardVaults.sol:314` · reward-accounting · conf 0.95

REPRODUCED with a self-contained Foundry PoC. RewardVaults uses MasterChef accounting owed = boostedScore*(accumulatedPerShare - lastAccumulatedPerShare)/PRECISION. recordDelegate (L314-332) only snapshots lastAccumulatedPerShare when isNewDelegator (stakedAmount==0); on a TOP-UP it adds debt.boostedScore += score without settling pending or advancing lastAccumulatedPerShare. recordStake (L510-522) shares the flaw.

SETUP: attacker recordDelegate 1 wei to OPERATOR (lastAcc=0), honest recordDelegate LARGE=1000e18 to same operator (commission=0). ATTACK: distributeRewards(REWARD=100e18) -> accumulatedPerShare grows over totalStaked=LARGE+1. Attacker fair pending = 0 (1/(LARGE+1) share). Attacker then recordDelegate(LARGE) — boostedScore becomes LARGE+1, lastAcc STILL 0. OUTCOME: attacker pendingDelegatorRewards jumps 0 -> 99999999999999999000 (~REWARD); claimDelegatorRewardsFor pays it out. Vault was funded with exactly REWARD, so after the attacker drains it (vault remaining=1000 wei) the honest delegator is still owed ~REWARD but their claim reverts "Insufficient reward balance". The topped-up stake retroactively earned the entire reward accrued before it existed, stealing the honest delegator's funds and rendering the vault insolvent. Live path: RewardsManager._notifyExternalRewardsManager calls recordDelegate with only the incremental amount on every delegation increase.

### H4. Queued withdrawal + delegation double-count restaked ETH -> phantom operator stake
`src/beacon/ValidatorPodManager.sol:510` · business-logic · conf 0.90

SETUP: A staker restakes beacon principal (recordBeaconChainDeposit) minting beacon-pool shares; the pod physically holds the ETH. ATTACK: (1) queueWithdrawal(allShares) is allowed because it only reverts when delegatorTotalDelegated>0, which is 0 pre-delegation. (2) delegateTo(op, amount) computes availableAssets = _convertToAssets(_pools[s],_shares[s]) — the FULL beacon valuation — and NEVER subtracts queuedShares[s] (line 514), so the same shares that are already queued for withdrawal are delegated again. (3) completeWithdrawal (line 734) burns the beacon shares and pays out real ETH via ValidatorPod.withdrawToStaker; it NEVER checks delegatorTotalDelegated. OUTCOME: the staker recovers 100% of principal while a live, fully-backed-looking delegation persists. operatorDelegatedStake(op) and getDelegation(s,op) still report the full amount with ZERO underlying assets. getOperatorStake/getOperatorStakeForAsset (used by TangleL2Slasher.getSlashableStake and by service security commitments) are inflated by unbacked phantom stake; slashing it claws back nothing. An operator can collude with a staker to advertise arbitrary slashable stake at zero real risk, defeating the restaking economic-security guarantee. The view getAvailableToWithdraw correctly subtracts BOTH queuedShares and delegated shares, but neither state-changing path (delegateTo / completeWithdrawal) enforces that mutual exclusion. PoC test/beacon/PoCDoubleCount.t.sol passes: staker withdraws 32 ETH, pod balance 0, beacon shares 0, yet operatorDelegatedStake==32 ETH.

### H5. Pending-slash guard missing on blueprint rebalance lets Fixed-mode delegators evade targeted slashes
`src/staking/DelegationManagerLib.sol:847` · business-logic · conf 0.85 · 2×

The dispute-window protection (_operatorPendingSlashCount>0) is enforced on EVERY stake-exit path: _scheduleDelegatorUnstake (DelegationManagerLib.sol:424-427), _executeDelegatorUnstake (:469), _executeDelegatorUnstakeAndWithdrawInner (StakingDelegationsFacet.sol:147), _scheduleOperatorUnstake (OperatorManager.sol:157), _executeOperatorUnstake (:191), _startLeaving (:237). Intent: while a slash is pending against an operator, no delegator may move stake out of harm. BUT _addBlueprintToDelegation (DelegationManagerLib.sol:847) and _removeBlueprintFromDelegation (:911) -- exposed via StakingDelegationsFacet.addBlueprintToDelegation/removeBlueprintFromDelegation, gated only by whenNotPaused -- move a Fixed-mode delegator's assets BETWEEN blueprint pools with NO pending-slash check. _removeBlueprintFromDelegation pulls the delegator's full value out of blueprint X's pool via _setDelegatorBlueprintPosition(...,X,0,0) at :951 (which decrements _blueprintPools[op][X].totalAssets) and redistributes it into the remaining blueprint pools. ATTACK: (1) delegator is Fixed-mode on blueprint X; (2) SLASHER calls incrementPendingSlash(operator), opening the dispute window for a slash on X; (3) delegator front-runs execution: addBlueprintToDelegation(idx,Y) then removeBlueprintFromDelegation(idx,X), moving all value from pool X into pool Y; (4) slashForBlueprint/slashForService executes and reduces _blueprintPools[op][X].totalAssets, but the attacker is no longer in pool X and escapes entirely while honest pool-X delegators absorb a proportionally larger loss. OUTCOME: dispute-window lock defeated for Fixed-mode delegations; slash evasion with loss socialized onto honest delegators.

### H6. Fixed-mode slash escape: removeBlueprintFromDelegation moves stake out of a pending-slash target
`src/facets/staking/StakingDelegationsFacet.sol:380` · business-logic · conf 0.85

The protocol blocks delegators from dodging a slash via the `_operatorPendingSlashCount` gate in `_scheduleDelegatorUnstake` (DelegationManagerLib.sol:424-427), `_executeDelegatorUnstake` (469-472) and `executeDelegatorUnstakeAndWithdraw` (StakingDelegationsFacet.sol:147-149). But `addBlueprintToDelegation`/`removeBlueprintFromDelegation` (StakingDelegationsFacet.sol:381,386 → DelegationManagerLib.sol:847,911) carry ONLY `whenNotPaused` — no pending-slash gate. Fixed-mode slashing is per-blueprint: `executeSlash` → `_executeSlashOnStaking(proposal, svc.blueprintId)` → `slashForBlueprint` → `_slashBlueprintPool(operator, blueprintId, ...)` (SlashingManager.sol:510-537) reduces ONLY that one blueprint pool's `totalAssets` at execute time. Whoever holds that pool at execute time bears the loss; rebalancing physically moves assets between pools via `_setDelegatorBlueprintPosition` (DelegationManagerLib.sol:311-346, `pool.totalAssets -= applied` on the removed bp, `+= delta` on the others, mirrored in `_operatorDelegatedAggregate`).

SETUP: Attacker holds a Fixed-mode delegation over blueprints [A,B], 1000 each (2000 total). Pools after delegate: A=[1e11 shares,1000 assets], B=[1e11,1000].
ATTACK: A service/blueprint owner calls `proposeSlash(serviceId, operator, 10000, evidence)` for blueprint A (Slashing.sol:30). This increments `_operatorPendingSlashCount` (Slashing.sol:103) and opens a dispute window before `executeSlash` is callable. The proposal is mempool-visible; even without front-running, the entire dispute window (>= MIN_DISPUTE_WINDOW) is available. The attacker calls `removeBlueprintFromDelegation(idx, A)`. `_removeBlueprintFromDelegation` computes totalAmount = s2a(A)+s2a(B)=2000, calls `_setDelegatorBlueprintPosition(A,0,0)` (A pool totalAssets 1000→0) and redistributes 2000 into B (B pool totalAssets 1000→2000). d.shares is recomputed to B's full position.
OUTCOME: When `executeSlash` runs `_slashBlueprintPool(A, 100%)`, pool A holds 0 assets — the slash collects nothing from the attacker. Attacker retains 2000 (verified by integer simulation of the exact a2s/s2a/setpos math) instead of the correct post-slash 1000. The slash is fully evaded; `_operatorPendingSlashCount` (the documented anti-front-run protection) does not cover this path. If other delegators remain in A, the fixed slash amount now falls entirely on them, amplifying their loss. The same gap lets `addBlueprintToDelegation` dilute exposure by pulling value into freshly added safe blueprints.

### H7. startLeaving() active-service guard is globally dead — unrouted selector → any operator exits stake while backing live services
`src/staking/OperatorManager.sol:241` · access-control · conf 0.85

SETUP: When an operator calls startLeaving() to begin exiting the staking layer (and ultimately withdraw their bond), _startLeaving() (OperatorManager.sol:231-255) is meant to block the exit if the operator still backs active services. It does this by staticcalling the Tangle core: `_tangleCore.staticcall(abi.encodeWithSignature("getOperatorTotalActiveServices(address)", msg.sender))` and reverting OperatorHasActiveServices when the returned count > 0.

ROOT CAUSE: `getOperatorTotalActiveServices(address)` is implemented in Operators.sol:303 but is NOT registered as a router selector on ANY facet. TangleOperatorsFacet.selectors() (TangleOperatorsFacet.sol:10-16) registers only preRegister, registerOperator (x2), unregisterOperator, updateOperatorPreferences. The selector 0x0ded8bf9 (= cast sig "getOperatorTotalActiveServices(address)") is absent from every facet's selectors() list. Calling it through the Tangle proxy therefore hits the router fallback and reverts UnknownSelector(0x0ded8bf9).

ATTACK: The guard swallows that failure: `if (success && data.length >= 32)`. Because the staticcall reverts, `success == false`, so the entire active-services check is skipped for EVERY operator. Empirically confirmed during reproduction (finding sub-9-repro): the proxy call reverts UnknownSelector(0x0ded8bf9). The only remaining gate in _startLeaving is `_operatorPendingSlashCount[msg.sender] > 0`.

OUTCOME: Any operator backing any number of live, paid services (standard request/approve path OR RFQ path) can call startLeaving() without reverting and proceed through the staking exit/withdrawal flow, pulling their bonded collateral out from under services that depend on it as slashable security — provided no slash is already pending. This voids the protocol-wide invariant "an operator backing an active service cannot begin exiting stake" for the entire operator population, not just the RFQ subset (cf. sub-5, which exploits the separate in-contract unregisterOperator counter). Fix: register the getOperatorTotalActiveServices selector on TangleOperatorsFacet (or a views facet), AND treat a failed/empty staticcall as fail-closed (revert) rather than skipping the check.

### H8. Buyback swaps with zero slippage protection + permissionless trigger -> MEV sandwich drains revenue
`src/extensions/BuybackBlueprintBase.sol:204` · mev-sandwich · conf 0.85

_executeBuyback sets amountOutMinimum=minOut where minOut=expectedOut*(10000-bps)/10000 and expectedOut comes from _getExpectedOutput which by DEFAULT returns 0 (line 269-273). So minOut=0, sqrtPriceLimitX96=0, deadline=block.timestamp. ATTACK: AUTO mode swaps on every ETH dev payment (delivered via core tryTransferPayment .call -> receive() -> _onPaymentReceived), and executeBuyback/executeBuybackAll (189-201) are permissionless (nonReentrant only). An MEV bot sandwiches the WETH->token swap: buy token before, let the contract swap at an inflated price receiving near-zero tokens, sell after. OUTCOME: protocol buyback ETH is extracted by MEV, stakers/treasury get dust. The 5% maxSlippageBps default is meaningless because it multiplies expectedOut=0.

### H9. UniswapV3Oracle TWAP price math truncates to 0 + inverted decimals → 0/garbage price
`src/oracles/UniswapV3Oracle.sol:400` · precision-loss · conf 0.85

SETUP: `configurePool(token, pool, ...)` for any pool where 1 whole `token` is worth < 1 whole quote-token in raw wei terms — i.e. essentially every asset quoted against WETH or any equal/higher-decimal quote (WETH/USDC, TNT/WETH, etc.).

ATTACK / ROOT CAUSE: `_getPriceFromSqrtX96` computes the raw price as `(sqrtPriceX96 * sqrtPriceX96) >> 192` (line 404) BEFORE any decimal scaling. `sqrtP^2 >> 192` equals the token1/token0 ratio in *wei* (a dimensionless ratio that is <1 for almost all real pairs), so integer truncation floors it to 0. Verified numerically: TNT/WETH(18/18, 1 TNT=0.0005 WETH) → 0; WETH/USDC(18/6, 1 WETH=3000 USDC) → 0. The subsequent decimal adjustment (line 406) is ALSO inverted: it multiplies by `10**quoteDecimals / 10**tokenDecimals`, whereas converting a wei-ratio to "quote-wei per whole token0" requires multiplying by `10**tokenDecimals` (for equal decimals the correct factor is 1e18; the code yields 1). The `isToken0==false` branch (line 410) is worse: `sqrtPriceX96 * sqrtPriceX96` is up to 320 bits and OVERFLOWS uint256 at high ticks → revert/DoS, and `(1<<192)/sqrtSquared` truncates to 0 whenever price>1.

OUTCOME: `getPrice`/`toUSD` return 0 for realistic configurations; `_getPriceData` still sets `data.isValid = true`, so callers get a silent zero rather than a revert. This oracle feeds `Slashing.sol:214` (toUSD weight per asset), `PaymentsEffectiveExposure.sol:94` (USD exposure), and `ServiceFeeDistributor.sol:1365` (fee conversion). A zero price drops the asset from slashing-weight and exposure pools (weight==0 is skipped at Slashing.sol:215-218), letting an operator commit an asset that carries no slashing weight / no exposure while still backing services. `fromUSD` divides by `data.price` and reverts on 0 → DoS of any USD→token path. Value at risk: full mispricing of every Uniswap-quoted asset across slashing and payment accounting.

### H10. Service slashing of delegated stake is non-punitive in ValidatorPodManager (delegator recovers 100%)
`src/beacon/ValidatorPodManager.sol:943` · restaking-accounting · conf 0.85

SETUP: src/core/Slashing.sol routes operator misbehavior to IStaking.slashForService/slashForBlueprint/slash. In ValidatorPodManager these all call _slash(operator,slashBps). ATTACK/OUTCOME: _slash decrements ONLY operatorStake[operator] (self-stake) and _operatorDelegationPools[operator].totalAssets (a pure accounting figure). It never touches the delegator beacon pool (_pools/_shares) nor the ValidatorPod ETH custody. A delegators committed collateral IS their beacon principal, which physically sits in the pod and is withdrawn via the independent beacon withdrawal queue (queueWithdrawal/completeWithdrawal -> ValidatorPod.withdrawToStaker). completeUndelegation only mutates accounting and moves NO ETH. Therefore after even a 100% service slash of the delegation pool, a delegator undelegates (accounting only) and withdraws their FULL beacon principal from the pod. Only operator self-stake is ever really clawed back. Delegated stake — the core of the restaking security promise and the value reported by getOperatorStake/getOperatorDelegatedStake used for service security commitments — provides ZERO real slashable collateral. A service relying on an operators delegated stake for security can be cheated: operator misbehaves, gets slashed on paper, delegators lose nothing. PoC test/beacon/PoCSlashNoop.t.sol: 50% slash applied, delegator still recovers 32/32 ETH.

### H11. RFQ quote services skip _operatorActiveServiceCount → operator withdraws full stake mid-service ✅ **PoC**
`src/core/QuotesCreate.sol:284` · access-control · conf 0.82

SETUP: A service is created via the RFQ quote path `createServiceFromQuotes` → `_activateQuoteService` → `_processOperatorQuotes` (QuotesCreate.sol:275-300). For each quoted operator this writes `_serviceOperators[serviceId][op]` (active=true, exposureBps) and adds them to `_serviceOperatorSet`, making them live, paid security providers for the service.

ROOT CAUSE: `_processOperatorQuotes` NEVER increments `_operatorActiveServiceCount[blueprintId][op]`. The standard (request/approval) activation path does — TangleServicesFacet.sol:140 `_operatorActiveServiceCount[blueprintId][op]++` with the comment "Track active service count per blueprint for operator unregistration checks" — and so does join (ServicesLifecycle.sol:672). The RFQ/quote creation path omits it entirely (confirmed: the only writers of this counter are TangleServicesFacet:140 and ServicesLifecycle:672/758). Service extension (QuotesExtend) likewise never sets it.

This counter is the ONLY active-service guard on two privileged exits:
1. `unregisterOperator` (Operators.sol:204): `if (_operatorActiveServiceCount[blueprintId][msg.sender] > 0) revert OperatorHasActiveServices(...)` — its docstring (L193) promises "Reverts if operator has any active services for this blueprint".
2. `startLeaving()` → `_startLeaving()` (StakingOperatorsFacet.sol:77, OperatorManager.sol:231-252): the operator-leaves-staking guard staticcalls `getOperatorTotalActiveServices(operator)` (Operators.sol:303-309), which simply SUMS `_operatorActiveServiceCount` across all blueprints, and reverts `OperatorHasActiveServices` only if >0.

ATTACK: An operator joins only RFQ/quote-created services (signs quotes consumed by `createServiceFromQuotes`). The customer pays upfront and the service relies on the operator's bonded stake as economic security for its whole TTL. Because the counter stays 0 for this operator, `getOperatorTotalActiveServices` returns 0, so — provided no slash has been proposed yet (`_operatorPendingSlashCount == 0`) — the operator calls `startLeaving()` (passes the guard), waits the leave delay, completes leaving and withdraws their ENTIRE operator bond/stake. They can also `unregisterOperator` for the blueprint, freeing their gossip key slot and calling `removeBlueprintForOperator`, all while `_serviceOperators[serviceId][op].active == true`.

OUTCOME: The core economic-security invariant — an operator backing a live, paid service cannot pull their stake — is silently void for the entire RFQ/quote service class. The operator collects the upfront RFQ payment, exits staking, and withdraws all bonded collateral while the service is still Active and customers depend on that collateral. If the operator subsequently misbehaves or goes offline, there is little or no stake left to slash. Fix: increment `_operatorActiveServiceCount[blueprintId][op]` for each operator in `_processOperatorQuotes` (and decrement on RFQ-service removal/termination), mirroring TangleServicesFacet.sol:140.

### H12. recordDelegate grants lock-multiplier boost but sets no lockExpiry → boosted rewards with no lock
`src/rewards/RewardVaults.sol:308` · business-logic · conf 0.82

SETUP: The LIVE delegation path is recordDelegate(), called by RewardsManager._notifyExternalRewardsManager (src/staking/RewardsManager.sol:209-210), which forwards a caller-chosen lockMultiplierBps. recordDelegate computes score = amount*lockMultiplierBps/BPS_DENOMINATOR (line 308) and credits debt.boostedScore += score and operatorPools.totalStaked += score (lines 320,329) — i.e. the delegator earns a lock-multiplier-boosted share (up to 1.6x) of all accumulatedPerShare rewards. ATTACK: But lines 321-322 unconditionally set debt.lockDuration = None and debt.lockExpiry = 0 — NO lock is ever recorded. The live un-delegate path recordUndelegate() (lines 335-376) contains NO lockExpiry check at all (only the separate recordUnstake at line 542 checks it). So a delegator: (1) delegates with maximum lockMultiplierBps (1.6x), receiving 1.6x boosted reward score; (2) collects epoch rewards at 1.6x weight; (3) immediately undelegates via recordUndelegate with zero wait. OUTCOME: The lock multiplier — whose entire purpose is to reward funds committed for 30-180 days — is obtained for free, diluting honest lockers and unboosted delegators on every epoch distribution. Separately, because lines 321-322 run on every call (including top-ups), a recordDelegate top-up onto a position that recordStake() previously locked wipes its lockExpiry to 0, enabling early unlock through recordUnstake as well.

### H13. Validator exit misread as beacon slash in ValidatorPod → real L2 stake slash
`src/beacon/ValidatorPod.sol:450` · business-logic · conf 0.82

SETUP: `beaconChainSlashingFactor` is meant to track ONLY proportional loss from beacon-chain slashing. `_finalizeCheckpoint` instead derives it from any drop in `totalRestakedBalanceGwei` vs the checkpoint's `priorBeaconBalanceGwei` (line 455: `if (currentBalance < priorBalance)` → newFactor = oldFactor*currentBalance/priorBalance, lines 459-463). `totalRestakedBalanceGwei` is decremented in `_verifyAndProcessCheckpointProof` (lines 419-421) for EVERY beacon-balance decrease, and a full exit sets currentBalance==0 (lines 424-428), subtracting the validator's entire ~32 ETH.

ATTACK / TRIGGER: An operator's validator exits the beacon chain *normally* (no slashing). Its 32 ETH lands in the pod and is correctly re-credited to totalAssets via `newlyWithdrawableGwei` (line 440). But `verifyCheckpointProofs` is permissionless (comment line 337). Anyone starts a checkpoint and submits the post-exit balance proof (balance=0). At finalize, currentBalance = priorBalance − 32e9 < priorBalance, so `beaconChainSlashingFactor` is cut proportionally (e.g. single-validator pod → factor ≈ 0). 

OUTCOME: `L2SlashingConnector.propagateBeaconSlashing` (it re-reads the pod's real factor at line 252, so the drop is genuine) converts the factor delta into `slashBps` and bridges a slash to `L2SlashingReceiver`, which slashes `operatorDelegatedStake * slashPercentage`. A lawful validator exit (or any balance dip) thus burns the operator's L2 delegated stake. The factor is monotonic (never restored on the principal reappearing in the EL), so the loss is permanent. This is both an honest-loss correctness bug and a griefing vector (third party finalizes the checkpoint to weaponize any exit). EigenLayer avoids this by attributing the slashing factor only to the validator `slashed` flag / loss not explained by exited principal, not to raw balance deltas.

### H14. Rejoin re-pushes security commitments without clearing → duplicated array inflates billing weight, steals reward share, over-bills customer
`src/core/ServicesLifecycle.sol:203` · business-logic · conf 0.78

SETUP: A Dynamic-membership service has security requirements (`_serviceSecurityRequirements[serviceId].length > 0`). An operator joins via `joinServiceWithCommitments`, which PUSHES each commitment into the array `_serviceSecurityCommitments[serviceId][op]` (line 204) and writes the per-asset `_serviceSecurityCommitmentBps` mapping.

ATTACK / ROOT CAUSE: The commitments ARRAY is never cleared anywhere in the repo. `_removeOperatorFromService` (lines 742-771) sets `opData.active=false` on leave but leaves the array intact (no `delete`/`pop` — confirmed by grep). `_loadJoinContext` (line 631) permits rejoin whenever the caller is `!active`. So an operator can:
1. join (commitments stored once),
2. leave (scheduleExit→executeExit, or leaveService/forceExit) — array untouched,
3. rejoin via `joinServiceWithCommitments` — the loop at lines 203-215 PUSHES the same commitments AGAIN. `_validateSecurityCommitments` only rejects duplicates WITHIN the new calldata, never against what is already stored, so identical valid commitments pass.
Each rejoin appends another full copy → after N cycles the array holds the same asset (N+1) times. The `_serviceSecurityCommitmentBps` mapping is keyed by assetHash so it just overwrites — but every consumer that iterates the ARRAY now double-counts. The inflation is permanent for the service's lifetime.

OUTCOME:
1. Reward-share theft: `_accrueOperatorWeights` (PaymentsBilling.sol:274-356) iterates the array and does `opWeight += contribution` per entry (line 345). Duplicate entries share assetHash/cursor/projectedCum/exposureBps, so an identical `contribution` is summed (N+1)× → the rejoiner's `weights[i]` is multiplied. `_distributeBill` splits each interval's payout proportionally by `weights[i]/totalWeight`, so the attacker siphons reward share from honest operators every billing period, indefinitely.
2. Customer over-billing: the same loop accumulates `result.cumDeltaPeriod += opWeight` (line 357); inflated cumDelta raises `PaymentLib.twapBillAmount` (up to the rate cap), draining more of the customer's escrow each interval than the contracted stake warrants.
3. Slashing corruption: `_executeSlashOnStaking` (Slashing.sol:501-502) loads the duplicated array via `_loadServiceCommitments` and forwards it to `_staking.slashForService`, applying the per-asset slash multiple times.

Friction (protocol defaults: minCommitment 1d, exitQueue 7d) only paces stacking; a blueprint manager's `getExitConfig` hook can set both to 0 for instant unlimited stacking, and even one cycle yields a permanent 2× weight. Fix: on leave, `delete _serviceSecurityCommitments[serviceId][op]` (and the cursor/snapshot state), or overwrite-not-append on (re)join, or merge-dedup new commitments against stored ones.

### H15. Double exposure scaling in commitment slash path under-slashes operators by exposure factor ✅ **PoC**
`src/core/Slashing.sol:494` · business-logic · conf 0.74

executeSlash (reachable from in-scope TangleSlashingFacet.executeSlash) under-slashes operators that made per-asset security commitments. In Slashing.proposeSlash (Slashing.sol:73-92) effectiveExposureBps = opData.exposureBps * commitmentBps / 1e4, where commitmentBps = _computeServiceCommitmentExposureBps() = the average of the operator per-asset commitment.exposureBps values. SlashingLib.proposeSlash then stores proposal.effectiveSlashBps = slashBps * effectiveExposureBps / 1e4 (SlashingLib.sol:197,247). At execution _executeSlashOnStaking (Slashing.sol:494-517) routes commitment-bearing operators to SlashingManager._slashForService, passing proposal.effectiveSlashBps as slashBps. _slashForService (SlashingManager.sol:268-284) then re-applies per-asset exposure: effectiveBps = slashBps * commitment.exposureBps / 1e4. Since commitmentBps IS the average of those same commitment.exposureBps values, exposure is applied TWICE. Net slash = slashBps * opData.exposureBps/1e4 * commitmentBps/1e4 * commitment.exposureBps/1e4. The no-commitment fallback _slashForBlueprint (Slashing.sol:504-507) applies effectiveSlashBps once with NO further scaling, which is the correct single application — confirming the commitment branch double-counts. SETUP: operator commits exposureBps E to a service (single asset, opData.exposureBps=100%). ATTACK: governance proposes a 50% slash for misbehavior. OUTCOME: intended slash of committed pool = 50% * E; actual = 50% * E * E/1e4. For E=10% the operator loses ~10% of the intended penalty; for E=50%, half. Operators with per-asset commitments systematically escape the bulk of any slash, breaking the protocols core economic-security guarantee. The commitment branch should pass the RAW cappedSlashBps (un-exposure-scaled) to _slashForService, OR _slashForService should not re-scale by commitment.exposureBps.

### H16. Staker-share refund credits non-subscription escrow → service owner steals delegators' pool via withdrawRemainingEscrow
`src/core/PaymentsDistribution.sol:400` · business-logic · conf 0.72

SETUP: EventDriven and native-token PayOnce services route their job payments through the SAME `_distributeBill` core as subscriptions. `TangleJobsFacet._distributeJobPayment` (TangleJobsFacet.sol:29-30) and the PayOnce path (TangleServicesFacet.sol:192-193) call `distributePayment(serviceId, blueprintId, address(0), payment, operators)` — token is always native `address(0)`. These pricing models NEVER set `_serviceEscrows[serviceId].token` (only the Subscription branch at TangleServicesFacet.sol:167-170 does), so the escrow struct stays all-zero, including `escrow.token == address(0)`.

When operators have real delegated stake, `_distributeBill` computes `hasSecurityCommitments == true` so a non-zero `stakerPool` is split out (PaymentsDistribution.sol:292-294) and each operator's slice is sent to `_forwardStakerShare`. If `_serviceFeeDistributor == address(0)` (an explicitly-handled normal mode — line 367; realistic in early deployment) OR the distributor reverts for that (op, token), control reaches `_refundStakerShareToEscrow` (lines 400-421).

ATTACK: `_refundStakerShareToEscrow` tests `if (escrow.token != token)` (line 410). For a native job payment, `escrow.token(0) == token(0)`, so it falls through and executes `escrow.balance += amount` (line 414). For an EventDriven/PayOnce service there was no deposit and no `releaseFromEscrow`, so `totalDeposited == 0` and `totalReleased == 0`; the `totalReleased -= amount` guard (415-419) just clamps to 0. Net: `escrow.balance` is credited stakerShare with NOTHING deposited — the invariant `balance == totalDeposited - totalReleased` is broken (balance = s, deposited = 0). Every job over the service's life accrues the entire staker allocation (stakerBps of each job fee, paid by arbitrary job submitters) into this phantom escrow balance. After the service is terminated, the SERVICE OWNER calls `withdrawRemainingEscrow(serviceId)` (PaymentsRefund.sol:35-53 — guarded only by `status==Terminated` + `owner==msg.sender`, NO subscription/pricing check) and pockets the full accumulated balance.

OUTCOME: funds earmarked for delegators (the staker pool) are silently diverted to the service owner — cross-account theft from stakers, plus an escrow accounting invariant break that lets an owner withdraw value never deposited. FIX: gate `_refundStakerShareToEscrow`'s escrow credit on the service actually being a Subscription with an initialized escrow (e.g. require `escrow.totalDeposited > 0` or `svc.pricing == Subscription`); otherwise route the un-routable staker share to the treasury (the `escrow.token != token` branch already does this).

### H17. Per-pod beacon slashBps applied to operator's ENTIRE L2 stake → unbounded over-slash
`src/beacon/L2SlashingConnector.sol:242` · business-logic · conf 0.72

SETUP: `beaconChainSlashingFactor()` is a PER-POD fraction (1e18 = 100%) of that one pod's beacon-validator balance remaining. The connector derives `slashPercentage = (lastFactor - newFactor)*1e18/lastFactor` and `slashBps` from a SINGLE pod (L2SlashingConnector.sol:242-243), then ships `slashBps` to L2. On L2, TangleL2Slasher.slashOperator → staking.slash(operator, ...) → MultiAssetDelegation._slash slashes `(operatorSelfStake + operatorDelegationPool.totalAssets) * slashBps / 10000` — the operator's ENTIRE native stake including all third-party delegators (ValidatorPodManager.sol:943-971 shows identical semantics).

ATTACK / OUTCOME (base mismatch): slashBps expresses "fraction of THIS POD's beacon balance lost", but it is applied to the operator's total L2 delegated stake, an unrelated and generally far larger base. Pod loses 1 ETH of 32 ETH beacon balance → factor 1e18→~0.969e18 → slashBps≈312 (3.1%). If the operator carries 1000 ETH of L2 delegations, 3.1% = ~31 ETH is slashed for a 1 ETH beacon loss — a ~31x over-slash borne by delegators who never backed that validator. Over-slash multiplier = (L2 total stake)/(pod beacon principal), unbounded.

ATTACK / OUTCOME (multi-pod amplification): `podOperator` (L2SlashingConnector.sol:118,396) maps MANY pods → one operator, and `lastProcessedSlashingFactorByChain` is keyed per-pod (line 107). Pod A factor 1e18→0.5e18 slashes 50% of the operator's whole stake; pod B independently 1e18→0.5e18 then slashes 50% of the REMAINING whole stake → 75% total, though each pod lost only 50% of its own balance. The shared L2 stake base is slashed once per pod.

The connector even computes `l2SlashAmount = operatorStake * slashPercentage / 1e18` (line 258-259) confirming the percentage is taken against total operator stake, not the slashed pod's principal.

### H18. Unauthenticated GovernanceDeployer functions allow Timelock admin takeover during deploy
`src/governance/GovernanceDeployer.sol:158` · access-control · conf 0.70

GovernanceDeployer.transferTimelockAdmin / renounceTimelockAdmin / configureProtocolRoles / transferFullControl are all external with NO access control. SETUP: deployGovernance() initializes TangleTimelock with admin=address(this) (GovernanceDeployer.sol:98), so the deployer contract (gd) holds DEFAULT_ADMIN_ROLE on the timelock. DeployGovernance.s.sol:80-82 calls deployGovernance() then renounceTimelockAdmin() as TWO SEPARATE transactions. ATTACK: in the window between them any address calls gd.transferTimelockAdmin(timelock, attacker) (lines 165-168) which grants DEFAULT_ADMIN_ROLE to an attacker-chosen address and renounces gd. Because OZ renounceRole() does not revert when the role is absent (AccessControlUpgradeable.sol:178-184), the scripts later renounceTimelockAdmin() and its post-check require(!hasRole(DEFAULT_ADMIN,gd)) still PASS, so the takeover is silent. OUTCOME: attacker holds DEFAULT_ADMIN on the Timelock, self-grants PROPOSER/EXECUTOR, and immediately executes arbitrary operations. The Timelock is intended to hold UPGRADER_ROLE/ADMIN_ROLE on Tangle core and MultiAssetDelegation, so this is full protocol takeover bypassing every governance vote and delay. The same missing-auth defect lets anyone redirect grantRole targets via configureProtocolRoles/transferFullControl (grantee is a caller-controlled param) whenever gd transiently holds admin on a protocol contract.

### H19. totalAssets() floor-to-zero after slash during pending redeem → share-inflation mint drains vault
`src/staking/LiquidDelegationVault.sol:152` · business-logic · conf 0.65

SETUP: `totalAssets()` (152-159) returns `getDelegation(vault,operator) - _pendingRedeemAssets`, floored to 0 when reserved >= underlying. `convertToShares` (165-168) = `assets * (totalSupply()+1e3) / (totalAssets()+1e3)`. When `totalAssets()==0` while `totalSupply()>0`, the denominator collapses to the 1e3 virtual offset, so a tiny deposit mints astronomically many shares.

Reachability: `requestRedeem` adds `_pendingRedeemAssets += convertToAssets(shares)` and burns the liquid shares, but does NOT reduce the underlying delegation. Pure requests cannot push reserved above underlying (virtual offset keeps a margin). A SLASH does: SlashingManager reduces `pool.totalAssets` (SlashingManager.sol:490), shrinking `_sharesToAmount(vaultShares)=getDelegation(vault)`. With a redeem pending, `_pendingRedeemAssets` was priced pre-slash, so post-slash `getDelegation(vault) < _pendingRedeemAssets` → `totalAssets()` floors to 0.

ATTACK: (1) Holders file requestRedeem, reserving ~all underlying (totalSupply drops to S', reserved=P). (2) Operator is slashed (natural, or attacker delegates to / operates a misbehaving operator). getDelegation drops below P → totalAssets()=0. (3) Attacker calls `deposit(assets)` for a tiny `assets`; mints `assets*(S'+1e3)/1e3` shares — dominant majority of supply. (4) When pending redeems are claimed, reservation P releases and totalAssets recovers; attacker's inflated share fraction now owns nearly the entire vault.

OUTCOME: Attacker steals the non-redeeming holders' stake (and all future deposits/rewards) for the cost of a dust deposit. The floor-to-0 comment (150-151) handles underflow but ignores the share-price collapse it creates.

### H20. Commitment exposure double-applied in slash path → operators massively under-slashed
`src/core/Slashing.sol:73` · business-logic · conf 0.62 · 2×

SETUP: A service has security requirements (`_serviceSecurityRequirements[serviceId].length > 0`) and the offending operator joined with explicit per-asset commitments (`_serviceSecurityCommitments[serviceId][operator]` non-empty) — the normal configuration for any service that enforces security.

ATTACK / ROOT CAUSE: Exposure is folded into the slash fraction TWICE (effectively three times) along the propose→execute path.
1. In `proposeSlash` (Slashing.sol:73-77) the proposal's effective rate is scaled by both the operator's service exposure and a weighted average of the per-asset commitments:
   `effectiveExposureBps = opData.exposureBps * commitmentBps / 10000`
   where `commitmentBps = _computeServiceCommitmentExposureBps(...)` is the weighted average of `_serviceSecurityCommitmentBps[serviceId][operator][assetHash]` (line 169/193) — i.e. the same per-asset `commitment.exposureBps` values.
   Then `SlashingLib.proposeSlash` computes `proposal.effectiveSlashBps = slashBps * effectiveExposureBps / 10000` (SlashingLib.sol:198,247).
2. In `executeSlash` → `_executeSlashOnStaking` (Slashing.sol:509-516) the proposal's already-exposure-scaled `effectiveSlashBps` is passed into `_staking.slashForService(..., proposal.effectiveSlashBps, ...)`.
3. `_slashForService` (SlashingManager.sol:270) re-applies the per-asset commitment exposure AGAIN: `effectiveBps = effectiveSlashBps * commitment.exposureBps / 10000`.

Net per-asset slash fraction = `slashBps * opData.exposureBps * avg(commitment.exposureBps) * commitment.exposureBps / 10000^3`. The commitment-exposure dimension is counted twice and the service exposure once more, all factors ≤ 1.0. For three exposures of 50% the operator is slashed at 0.5^3 = 12.5% of the intended amount.

OUTCOME: A misbehaving operator (and their delegators) escape the overwhelming majority of every slash that routes through the commitment path. The protocol's core economic-security guarantee — that a slash of `slashBps` removes ~that fraction of committed stake — is silently broken; `actualSlashed` is a fraction of the intended penalty. The blueprint owner / service owner who proposed a correct `slashBps` cannot achieve the punishment they specified. Fix: either store the raw `cappedSlashBps` in the proposal and let `slashForService` apply per-asset exposure once, or call `slashForBlueprint` with the pre-scaled rate — not both.

### H21. RebasingAssetAdapter mints ~1e8x-scaled shares -> rebasing-asset exposure inflated 1e8x in USD payout weighting
`src/staking/adapters/RebasingAssetAdapter.sol:111` · loss-of-precision · conf 0.60

On a fresh pool (totalShares==0) RebasingAssetAdapter.deposit computes shares = actualReceived * (0 + VIRTUAL_SHARES) / (0 + VIRTUAL_ASSETS) = actualReceived * 1e8 (VIRTUAL_SHARES=1e8, VIRTUAL_ASSETS=1; lines 45-46,130-131). So a rebasing-asset position is recorded ~1e8x the underlying TOKEN wei, whereas StandardAssetAdapter and direct/native deposits are 1:1 (token wei). These adapter-shares become dep.amount and flow unchanged into the operator stake aggregate (_operatorDelegatedAggregate, DelegationStorage.sol:322-329) returned by getOperatorStakeForAsset. PaymentsEffectiveExposure._calculateEffectiveExposures (src/core/PaymentsEffectiveExposure.sol:82-94) then does exposedAmount = delegation*exposureBps/BPS and feeds it to oracle.toUSD(token, exposedAmount) -- but toUSD expects raw TOKEN wei, so a rebasing-adapter asset is valued at ~1e8x its true USD exposure. OUTCOME: an operator who commits a rebasing-adapter asset captures a grossly disproportionate (~1e8x) slice of service-fee distribution and skews the global payout-weight pool against honest co-operators; the same scale error mis-prices slashing exposure and admin-set depositCap/minDelegation (which are token-denominated but compared against share-denominated currentDeposits). The exact 1e8 multiple holds while the pool is near its bootstrap ratio. Root cause: the adapter emits shares in a unit (1e8x) the cross-asset USD/exposure layer assumes is token-denominated. Preconditions: rebasing adapter deployed for a committable asset and price-oracle USD normalization enabled.

## 🟡 Medium (41)

### M1. createServiceFromQuotes bypasses min/max operator quorum bounds
`src/core/QuotesCreate.sol:188` · business-logic · conf 0.85

SETUP: the standard service-request path validates operator count via _validateOperatorBounds (ServicesRequests.sol:295-297), reverting InsufficientOperators when operatorCount<minOperators and clamping/checking maxOperators against the protocol ceiling.
ATTACK: createServiceFromQuotes -> _activateQuoteService (QuotesCreate.sol:188) writes the Service struct (lines 203-216) storing minOperators (line 211) and maxOperators (line 212) but NEVER checks operators.length against either bound — no _va…

### M2. UniswapV3Oracle marks price valid even when computed price is 0
`src/oracles/UniswapV3Oracle.sol:322` · business-logic · conf 0.85

_getPriceData unconditionally sets data.isValid=true (line 329) with no price>0 guard. SETUP: any pool/decimal combination where the truncated math (F-001) or a degenerate tick yields price==0. ATTACK: getPrice() returns 0 instead of reverting PriceNotAvailable; toUSD(token,amount) returns 0. OUTCOME: in Slashing.sol:214 the zero weight makes the asset contribute nothing to weightedCommitted, so the operator dodges slashing weight for that asset; in PaymentsEffectiveExposure.sol:94 the operator …

### M3. StandardAssetAdapter.deposit ignores actual-received → fee/deflationary token bricks pool
`src/staking/adapters/StandardAssetAdapter.sol:80` · accounting-insolvency · conf 0.85

StandardAssetAdapter.deposit sets shares=assets (1:1) and does safeTransferFrom(from,this,assets) WITHOUT measuring the balance delta. For any fee-on-transfer / deflationary token (USDT fee-switch, PAXG 0.02%, STA, etc.) the adapter receives <assets but credits `assets` shares and returns `assets` to DepositManager. DepositManager._handleErc20Deposit (src/staking/DepositManager.sol:74-76) trusts this return verbatim and credits config.currentDeposits + dep.amount by the full `assets` — UNLIKE bo…

### M4. LiquidDelegationVault.deposit assumes adapter shares==assets → DoS / stranded funds for rebasing assets
`src/staking/LiquidDelegationVault.sol:211` · business-logic · conf 0.82

SETUP: An asset (e.g. stETH) is configured in MultiAssetDelegation with a RebasingAssetAdapter (AssetAdapterFactory.deployRebasingAdapter), and a LiquidDelegationVault is created for it (LiquidDelegationFactory.createVault accepts ANY asset, no adapter-type check). The vault's deposit()/mint() treat the underlying staking "amount" unit as identical to the token amount.

ATTACK / BUG: In deposit() the vault does:
  staking.depositERC20(asset, assets);                       // line 211
  staking.d…

### M5. Uncapped exposureBps in RFQ quote path lets operator inflate payment share, stealing from co-operators
`?:?` · business-logic · conf 0.80 · 2×

SETUP: createServiceFromQuotes activates an RFQ service. _processOperatorQuotes (QuotesCreate.sol:285-288) stores operator-signed exposure via _quoteExposure()=commitments[0].exposureBps (line 313) into _serviceOperators[serviceId][op].exposureBps. Unlike the request path which rejects exposures[i]>BPS_DENOMINATOR (ServicesRequests.sol:275), the quote path applies NO upper bound (exposureBps is uint16, up to 65535). The quote path also never persists AssetSecurityCommitment[] into _serviceSecuri…

### M6. Adapter owner can repoint delegationManager and drain entire shared pool
`src/staking/adapters/RebasingAssetAdapter.sol:89` · access-control · conf 0.80

Both StandardAssetAdapter.setDelegationManager (StandardAssetAdapter.sol:69-73) and RebasingAssetAdapter.setDelegationManager (RebasingAssetAdapter.sol:89-93) are plain onlyOwner setters with NO timelock, NO two-step, and NO guard against live balances, and are re-callable at any time. withdraw(to,shares) is gated only by onlyDelegationManager and sends assets to an arbitrary `to`. SETUP: adapters custody 100% of every delegator restaked balance for their token (the diamond holds only share book…

### M7. enableAsset overwrites AssetConfig and resets currentDeposits to 0, bricking all withdrawals of a live asset
`src/facets/staking/StakingAssetsFacet.sol:40` · business-logic · conf 0.80

enableAsset (StakingAssetsFacet.sol:40) and enableAssetWithAdapter (:142) assign a brand-new Types.AssetConfig struct to _assetConfigs[assetHash] with currentDeposits hard-coded to 0. There is NO updateAssetConfig / setMinDelegation / setDepositCap / setRewardMultiplier function (see selectors() at :24-37) -- enableAsset is the ONLY way to change an existing asset's parameters (minDelegation, depositCap, rewardMultiplierBps) after launch. Re-calling it on an asset that already has live deposits …

### M8. Lock-multiplier reward boost is permanent — never expires with the lock
`src/staking/DelegationManagerLib.sol:776` · business-logic · conf 0.80

The lock multiplier (up to 1.6x at 6 months, MULTIPLIER_SIX_MONTHS=16000) is meant to reward genuinely-locked stake, but the boost is baked into the rewards layer permanently and is NEVER re-evaluated when the lock expires.

CODE PATH: `_depositAsset` (DepositManager.sol:114-126) records a `LockInfo{amount, multiplier, expiryTimestamp}`. At delegate time, `_calculateLockMultiplierBps` (DelegationManagerLib.sol:776-807) reads `_getActiveLockTotals` (757-774), which correctly counts only unexpired…

### M9. Instant-mode reward distribution has no stake lock -> just-in-time staking steals rewards
`src/extensions/TokenizedBlueprintBase.sol:242` · business-logic · conf 0.80

In instant mode _notifyReward immediately bumps rewardPerTokenStored += amount*1e18/totalStaked. Revenue payments are public (core push to receive()) and stake()/withdraw() have NO lock or cooldown. ATTACK: observe a pending revenue payment in mempool, stake a large amount just before it lands, capturing a proportional share of the instant distribution, then withdraw+claim immediately (same/next block). OUTCOME: honest long-term stakers are diluted; the attacker extracts most of each revenue dis…

### M10. ERC20 developer revenue is permanently stranded in the BSM (no hook, no rescue)
`src/extensions/TokenizedBlueprintBase.sol:118` · frozen-funds · conf 0.80

_onPaymentReceived is ONLY ever invoked by BlueprintServiceManagerBase.receive() with token=address(0) (confirmed: receive() -> _onPaymentReceived(address(0), msg.value) is the sole caller in src/). Core delivers ERC20 developer revenue via PaymentLib.tryTransferPayment, which does a raw IERC20.transfer to the BSM (PaymentsDistribution.sol:252) and triggers NO hook. Therefore Buyback._onPaymentReceived token!=0 branch (super._onPaymentReceived -> _notifyReward) is dead for real payments: ERC20 r…

### M11. InflationPool epoch budget recounts unclaimed operator/customer/developer pending -> over-accrual / insolvency
`src/rewards/InflationPool.sol:1164` · reward-accounting · conf 0.80

_distributeOperatorRewards/_distributeCustomerRewards/_distributeDeveloperRewards only EARMARK rewards into pendingOperatorRewards/pendingCustomerRewards/pendingDeveloperRewards (lines 610,687,727) and DO NOT transfer tokens out of the pool. Those tokens therefore remain inside poolBalance(). calculateEpochBudget() (line 1165) returns poolBalance()/epochsRemaining using the RAW token balance, never subtracting outstanding pending liabilities. Consequently the same tokens that already back unclai…

### M12. StreamingPaymentManager strands freshly-dripped chunk on operator-leave and service-termination
`src/rewards/StreamingPaymentManager.sol:305` · payment-accounting · conf 0.80

_drip() (lines 189-224) is a PURE-ACCOUNTING helper: it advances p.distributed += chunk and p.lastDripTime but transfers NOTHING. Delivery of the chunk is the caller's responsibility — dripAndGetChunk (246-252) and dripOperatorStreams (290-296) call _drip and THEN _transferPayment the chunk to the distributor, which credits delegators. However onOperatorLeaving (333-336) calls bare _drip(serviceId, operator) and discards the return value: the chunk earned since lastDripTime is marked distributed…

### M13. Facet registry is a 2nd upgrade path gated below UUPS upgrader → ADMIN_ROLE priv-esc
`src/staking/MultiAssetDelegation.sol:81` · access-control · conf 0.80

SETUP: The router dispatches any registered selector by `delegatecall` into the facet address stored in `_facetForSelector` (FacetRouterBase.sol:66-75, executed for every unknown selector via the `fallback`). Whoever can write that mapping can install arbitrary code that runs in the proxy's storage/`msg.sender` context — functionally identical to a UUPS implementation swap (it can grant roles, move all staked funds, rewrite any slot). Registry writes go through `registerFacet`/`registerFacetSele…

### M14. L1/L2 adapter selector mismatch — receiver-side replay/sender protection is dead code on the slash path
`src/beacon/bridges/BaseCrossChainMessenger.sol:72` · business-logic · conf 0.80

SETUP: Each bridge ships two halves — an L1 messenger (BaseCrossChainMessenger / ArbitrumCrossChainMessenger) and an L2 receiver adapter (BaseL2Receiver / ArbitrumL2Receiver) that implements the hardened path: explicit L1-origin check (BaseL2Receiver.sol:230-231 xDomainMessageSender==l1Sender; ArbitrumL2Receiver.sol:339 msg.sender==applyL1ToL2Alias(l1Sender)) plus per-payload replay dedup (BaseL2Receiver.sol:234-242, ArbitrumL2Receiver.sol:342-350).

ATTACK/OBSERVATION: The L1 messengers encode …

### M15. Sub-bps factor decrease consumed on L1 but permanently rejected on L2 (slashBps==0) → lost slash + corrupted baseline
`src/beacon/L2SlashingConnector.sol:237` · business-logic · conf 0.80

SETUP: `_propagateBeaconSlashing` only gates on `newSlashingFactor < lastFactor` (L2SlashingConnector.sol:237) and never checks that the resulting `slashBps != 0`. `slashBps = uint16((slashPercentage * 10000) / 1e18)` (line 243) truncates to 0 whenever the factor decrease is below 0.01% (slashPercentage < 1e14, i.e. a beacon-balance loss delta under 1e14 relative to a 1e18 factor — realistic for inactivity-leak / correlated-penalty drips that accrue in tiny increments).

ATTACK / OUTCOME: For su…

### M16. ValidatorPod.withdrawNonBeaconChainEth drains credited/delegated beacon principal, bypassing delay, share-burn and delegation lock
`src/beacon/ValidatorPod.sol:489` · business-logic · conf 0.80

SETUP: After a validator exits (or partial withdrawals), its principal lands in the ValidatorPod as ETH and is credited to the owner as beacon-pool shares via a checkpoint rebase; the owner may also have delegated that principal as slashable collateral. ATTACK: withdrawNonBeaconChainEth(recipient, amount) is gated only by onlyPodOwner and amount <= address(this).balance (lines 490-491). It does NOT distinguish beacon principal from stray tips, does NOT decrement the beacon pool totalAssets / own…

### M17. AUTO-mode buyback swap revert forfeits entire developer revenue share to operators
`src/extensions/BuybackBlueprintBase.sol:233` · business-logic · conf 0.75

In AUTO mode an ETH dev payment hits receive() -> _onPaymentReceived -> _executeBuyback. If the Uniswap swap reverts, the catch block (233-240) calls weth.withdraw then `revert BuybackFailed()` -- the revert undoes the catch state changes too, so the try/catch is ineffective and the whole receive() reverts. Core treats the ETH push as best-effort: tryTransferPayment returns false and PaymentsDistribution.sol:251-255 zeroes developerAmount and folds it into operatorAmount. OUTCOME: every time the…

### M18. Exposure applied twice in service-commitment slash path → under-slash
`src/core/Slashing.sol:509` · business-logic · conf 0.72

SETUP: A slash is proposed via proposeSlash(). At propose time the slash fraction is exposure-scaled: effectiveExposureBps = opData.exposureBps, optionally further scaled by the commitment-weighted average from _computeServiceCommitmentExposureBps (Slashing.sol:73-77). SlashingLib.proposeSlash then stores proposal.effectiveSlashBps = cappedSlashBps * effectiveExposureBps / 10000 (SlashingLib.sol:247, calculateEffectiveSlashBps). So effectiveSlashBps is ALREADY the final exposure-scaled fraction.…

### M19. Quote-path exposureBps never clamped to BPS_DENOMINATOR → operator inflates subscription payout share
`src/core/QuotesCreate.sol:285` · business-logic · conf 0.70 · 2×

SETUP: In the RFQ create path, the per-operator exposure stored on the service is taken verbatim from the operator's own signed quote. `_quoteExposure` (QuotesCreate.sol:307-314) returns `commitments[0].exposureBps` with no upper bound, and `_processOperatorQuotes` (QuotesCreate.sol:285-287) writes it straight into `_serviceOperators[serviceId][op].exposureBps` (a uint16, max 65535). The request path enforces a cap: ServicesRequests.sol:275-277 reverts with InvalidState when `exposures[i] > BPS_…

### M20. joinService accepts exposureBps > 10000 → reward-weight inflation & slash-scaling distortion
`src/core/ServicesLifecycle.sol:176` · business-logic · conf 0.70

SETUP: `joinService(serviceId, exposureBps)` and `joinServiceWithCommitments(serviceId, exposureBps, commitments)` let an operator self-select the `exposureBps` stored on their `ServiceOperator` record (`_finalizeJoin`, ServicesLifecycle.sol:667-669). Unlike the request path — `ServicesRequests._validateRequestOperators` rejects `exposures[i] > BPS_DENOMINATOR` (ServicesRequests.sol:275) — NEITHER join entry point bounds `exposureBps`. A `uint16` admits values up to 65535 (6.55×).

ATTACK / IMPA…

### M21. RFQ job quote omits job inputs from signed digest → operator bound to arbitrary work at a fixed price
`src/libraries/SignatureLib.sol:42` · signature-malleability · conf 0.70 · 2×

SETUP: `JOB_QUOTE_TYPEHASH` (SignatureLib.sol:42-44) and `hashJobQuote` (185-200) sign only `(requester, serviceId, jobIndex, price, timestamp, expiry, confidentiality)`. The job `inputs` are NOT part of the signed digest. In `JobsRFQ.submitJobFromQuote`, inputs are validated against the blueprint job schema (JobsRFQ.sol:81) and stored, but quote verification (`_verifyQuotesAndRecordOperators` → `SignatureLib.verifyAndMarkJobQuoteUsed`, JobsRFQ.sol:177-184) never binds them. Job schemas permit v…

### M22. BN254.verifyBls accepts point-at-infinity (and non-subgroup) inputs as a universally-valid BLS signature
`src/libraries/BN254.sol:420` · signature-verification · conf 0.70

verifyBls/verifyAggregatedBls perform NO point validation. With signature = G1 infinity (0,0) and pubkey = G2 infinity (0,0,0,0), pairingCheck computes e(O,gen)*e(-H(m),O)=1*1=1 -> returns TRUE for ANY message. PROVEN by test/audit/BN254Infinity.t.sol (verifyBls(msgA,O,O)=1, verifyBls(msgB,O,O)=1). Root cause: the alt_bn128 pairing precompile (0x08) checks on-curve but NOT prime-order-subgroup membership, and the library never calls isValidG1/isValidG2 (and isValidG2 itself only bounds-checks co…

### M23. ArbitrumCrossChainMessenger.sendMessage is likewise an unrestricted open relay (latent forged-slash)
`src/beacon/bridges/ArbitrumCrossChainMessenger.sol:105` · access-control · conf 0.70

SETUP/ATTACK: Same anti-pattern as F-001. sendMessage (L105-151) has no caller restriction and creates a retryable ticket to an attacker-chosen target with attacker-chosen payload, originating from the messenger own L1 address (its L2 alias becomes msg.sender on L2). OUTCOME: any deployment whose L2 authentication keys on the messenger identity (alias of ArbitrumCrossChainMessenger, or an ArbitrumL2Receiver whose l1Sender is set to this messenger) inherits the F-001 forged-slash. The current shi…

### M24. Exiting redeemer over-claims rewards accrued during unbonding; reservedAssets vs actual-returned mismatch dilutes remaining holders
`src/staking/LiquidDelegationVault.sol:387` · business-logic · conf 0.70

SETUP: At `requestRedeem` the vault prices the exit once: `assets = convertToAssets(shares)` (287), burns the liquid shares (295), stores `reservedAssets = assets` and `unstakeShares = previewDelegatorUnstakeShares(assets)` (308-314), and reserves `_pendingRedeemAssets += assets` (304). Crucially `scheduleDelegatorUnstake` only QUEUES — it does NOT reduce the vault's delegation shares `d.shares`. So during the bond-less delay those `unstakeShares` keep earning pool rewards and keep counting in `…

### M25. Vault approves staking (not the adapter) → deposits revert / mis-account for adapter-backed assets; permissionless factory does no asset validation
`src/staking/LiquidDelegationVault.sol:200` · business-logic · conf 0.70

SETUP: `deposit()` does `asset.forceApprove(address(staking), assets)` then `staking.depositERC20(asset, assets)` (200-211). Inside the staking layer, `_handleErc20Deposit` routes through a registered adapter when one exists: `IAssetAdapter(adapter).deposit(msg.sender=vault, amount)` (DepositManager.sol:76), and the adapter does `safeTransferFrom(vault, adapter, assets)` (e.g. StandardAssetAdapter.sol:88, RebasingAssetAdapter.sol:119) — pulling from the ADAPTER's allowance, which the vault never…

### M26. Fixed-mode delegation accepts arbitrary/unregistered blueprintIds → permanently slash-immune stake
`src/staking/DelegationManagerLib.sol:199` · business-logic · conf 0.70

The Fixed-mode delegation path validates that `operator` is registered/active and that `blueprintIds` are non-empty and duplicate-free (DelegationManagerLib.sol:163-210), but NEVER validates that each `blueprintId` corresponds to a real, registered blueprint that the operator actually serves. The same is true of `addBlueprintToDelegation` (no existence check on the added id). Any `uint64` is accepted and lazily creates a fresh pool at `_blueprintPools[operator][blueprintId][assetHash]`.

SETUP /…

### M27. Oracle enable/disable mid-subscription corrupts TWAP bill scale → indefinite under-billing
`src/core/PaymentsBilling.sol:294` · business-logic · conf 0.70

SETUP: A Subscription service is activated while a price oracle is configured (`_priceOracle != 0`). `_initSubscriptionBaseline` pins `escrow.subscriptionBaselineStake` as a USD-scaled sum: for each (op,asset) it adds `_safeToUSD(oracle, token, exposedAmount)` (PaymentsDistribution.sol:139 and :154). So the denominator the bill formula divides by is in oracle-USD units (e.g. tokenAmount * price). Per-(op,asset) price snapshots are also stored.

ATTACK / ROOT CAUSE: The bill path decides USD-norm…

### M28. _distributeToOperatorPool burns delegator share when totalStaked==0
`src/rewards/RewardVaults.sol:704` · reward-accounting · conf 0.70

_distributeToOperatorPool splits an incoming reward into commission (line 709) and poolReward = amount - commission (line 710). The delegator portion is only credited if the pool has stake: line 714 `if (pool.totalStaked > 0 && poolReward > 0) pool.accumulatedPerShare += ...`. When pool.totalStaked == 0 the ELSE branch is missing: poolReward is neither added to accumulatedPerShare, nor refunded, nor parked as pending — yet line 718 still does `vaultStates[asset].rewardsDistributed += amount`, ac…

### M29. UniswapV3Oracle has no L2 sequencer-uptime check (ChainlinkOracle does)
`src/oracles/UniswapV3Oracle.sol:274` · oracle-manipulation · conf 0.70

SETUP: Deployment target is Base (an OP-stack L2 — see deploy/config/base-sepolia and CLAUDE.md). `ChainlinkOracle` was hardened with `_requireSequencerUp()` (ChainlinkOracle.sol:303-311) that rejects prices while the sequencer is down or within a grace window after restart. `UniswapV3Oracle._getPriceData` has NO equivalent gate.

ATTACK: When the Base sequencer goes down and restarts, users were unable to arbitrage/transact for the outage duration. In the grace window right after restart, Unisw…

### M30. Job quote price not bound to job inputs → caller redeems quoted price for arbitrary, costlier work
`src/libraries/SignatureLib.sol:181` · business-logic · conf 0.66

SETUP: JobQuoteDetails commits the operator only to {requester, serviceId, jobIndex, price, timestamp, expiry, confidentiality} (hashJobQuote, SignatureLib.sol:181-196). It does NOT include the job `inputs`. In JobsRFQ.submitJobFromQuote the caller-supplied `inputs` (JobsRFQ.sol:49,117) are merely schema-validated (SchemaLib.validateJobParams, line 81) and stored — never hashed into the verified digest (confirmed: no keccak of inputs anywhere in JobsRFQ).

ATTACK: An operator gossips a signed qu…

### M31. effectiveStakingPercent to BSM onApprove uses only securityCommitments[0] → operator under-reports stake
`src/core/ServicesApprovals.sol:115` · business-logic · conf 0.65

SETUP: A request carries multiple security requirements, e.g. requirements = [USDC (min=max=100%), TNT (min=10%)]. The inline comment at L112-115 states the per-operator exposure handed to the blueprint manager "must mirror what was actually committed." The manager receives it via onApprove (L146) and a custom BSM commonly gates approval/eligibility on this percent (e.g. "reject operators committing <50%").

ATTACK: The approving operator passes p.securityCommitments ordered so index 0 is the as…

### M32. Slash front-run: matured unstake races proposeSlash to exit at pre-slash rate
`src/staking/DelegationManagerLib.sol:458` · business-logic · conf 0.62

The only on-chain protection against delegators dodging a slash is the `_operatorPendingSlashCount` gate in `_scheduleDelegatorUnstake` (DelegationManagerLib.sol:424-427), `_executeDelegatorUnstake` (467-472) and `executeDelegatorUnstakeAndWithdraw` (StakingDelegationsFacet.sol:147-149). The code comments claim this "prevents delegators from front-running slash execution." It does not — the gate only becomes active AFTER the proposal transaction mines, because the count is incremented inside `pr…

### M33. Delegation front-running hijack via predictable lock address (latent / design-fragile)
`src/governance/lockups/TNTLockFactory.sol:30` · access-control · conf 0.60

The lock address is deterministic in (token,beneficiary,unlockTimestamp) and exposed via public predictLockAddress, explicitly supporting a fund-before-create (lazy) airdrop model. TNTCliffLock.initialize calls IVotes(token).delegate(delegatee) from the lock address; OZ Votes._delegate sets _delegatee[lock]=delegatee with no auth. In the lazy model a third party who creates the lock first picks the delegatee, so once the airdrop funds the predictable address ERC20Votes credits the attacker with …

### M34. QuoteDetails digest lacks create-vs-extend discriminator → cross-flow quote reuse
`src/libraries/SignatureLib.sol:35` · business-logic · conf 0.60

SETUP: `QuoteDetails` (Types.sol:656) and its typehash (SignatureLib.sol:35-36) commit to {requester, blueprintId, ttlBlocks, totalCost, timestamp, expiry, confidentiality, commitments}. There is NO field identifying which operation the quote authorizes. Both `createServiceFromQuotes` (QuotesCreate.sol:56→172) and `extendServiceFromQuotes` (QuotesExtend.sol:75→158) call the SAME `SignatureLib.verifyQuoteBatch` with the SAME `QUOTE_TYPEHASH`, the SAME `_usedQuotes` map, identical (blueprintId, tt…

### M35. Aggregated result accepted with empty signer set + zero-sig when no operator is staking-active → result spoofing
`src/core/JobsAggregation.sol:184` · business-logic · conf 0.60

SETUP: A service is Active with a pending paid (EventDriven) aggregation job (callId not completed). All of the service's operators remain members of `_serviceOperatorSet` (svc.status stays Active — leaveService is gated by minOperators, but **staking** status is independent) yet every one of them currently returns `_staking.isOperatorActive(op) == false` (unbonding/started-leaving/slashed-to-zero — see sibling finding sub-5-deep-audit-a0505ef9 showing RFQ operators can even startLeaving while i…

### M36. Any single service operator overwrites service-wide acked version/policy → forces whole service onto attacker-chosen binary
`src/core/BlueprintsBinaryVersions.sol:160` · access-control · conf 0.60

SETUP: A service has 2+ active operators. The "supply-chain hardening" block (TangleStorage.sol:509-516) added per-operator policy/ack mappings specifically to close a documented single-operator griefing ("any single operator could overwrite for everyone"). The per-operator resolver `effectiveBinaryVersionForOperator` (L308-328) reads only `_serviceOperatorUpgradePolicy`/`_serviceOperatorAckedVersionId`.

ROOT CAUSE: `setServiceUpgradePolicy` and `ackBinaryVersion` STILL write the legacy service…

### M37. recordDelegate wipes lockExpiry on existing locked position → early unstake
`src/rewards/RewardVaults.sol:319` · business-logic · conf 0.60

recordDelegate() and recordStake() write the SAME struct delegatorDebts[asset][delegator][operator]. recordStake (line 516-521) sets debt.lockDuration=lock and debt.lockExpiry = block.timestamp + _lockDurationSeconds(lock) to commit a delegator to a lock in exchange for a boosted score multiplier (up to 1.6x). recordUnstake enforces it: line 542 `if (debt.lockExpiry > block.timestamp) revert StillLocked`.

SETUP: delegator locks via recordStake(asset, d, op, amt, SixMonths) -> boostedScore = 1.6…

### M38. UniswapV3Oracle quote-feed path has no L2 sequencer-uptime check
`src/oracles/UniswapV3Oracle.sol:302` · oracle-manipulation · conf 0.60

SETUP: The protocol explicitly targets Base (an L2 — see BeaconChainProofs/L2 bridges). For non-USD quote tokens, UniswapV3Oracle reads a Chainlink feed (`quoteTokenFeeds`, L303-320) to convert the TWAP into USD, using the same latestRoundData staleness pattern as ChainlinkOracle.

ATTACK: ChainlinkOracle.sol deliberately implements `_requireSequencerUp()` (L303-311) — gating every price on the L2 sequencer uptime feed plus a grace period — precisely because Chainlink L2 feeds can serve a stale …

### M39. UniswapV3Oracle never enforces observation cardinality → TWAP collapses toward manipulable spot
`src/oracles/UniswapV3Oracle.sol:332` · oracle-manipulation · conf 0.60

SETUP: `configurePool` (lines 208-235) reads `token0/token1` from the pool but never inspects `observationCardinality`/`observationCardinalityNext` (the `slot0` fields are declared in the interface but unused), and the oracle never calls `increaseObservationCardinalityNext`. `_getArithmeticMeanTick` blindly calls `observe([twapPeriod, 0])`.

ATTACK: For a pool whose observation buffer does not span the full `twapPeriod` (default 30 min; freshly created or thin pools commonly have cardinality 1),…

### M40. Operator evades beacon slash permanently by zeroing L2 slashable stake (canSlash→false hard-reverts forever)
`src/beacon/L2SlashingReceiver.sol:372` · business-logic · conf 0.60

SETUP: The receiver's "retry-safe" CEI design (L2SlashingReceiver.sol:340-382) reverts the whole tx — leaving the nonce open for bridge redelivery — whenever `!slasher.canSlash(operator)` (line 372). TangleL2Slasher.canSlash returns false when `getSlashableStake(operator) == 0`, i.e. the operator's L2 native stake is zero (TangleL2Slasher.sol:143-152), or when slashing is paused.

ATTACK / OUTCOME: This converts a transient guard into a permanent evasion path. An operator observing a pending/lik…

### M41. Bondless dispute-origin bypasses anti-griefing bond → free 60-day delegator freeze
`src/core/Slashing.sol:256` · business-logic · conf 0.55

SETUP: The dispute bond (`SlashConfig.disputeBond`) exists specifically to make disputes costly, so that disputing-to-freeze-stake is not a free DoS (see comments at SlashingLib.sol:80-82 and Slashing.sol:243-248). A blueprint owner controls `bp.manager` and (separately) can propose slashes via `querySlashingOrigin`.

ATTACK: While a slash against `operator` is `Pending`, the operator's delegators are withdrawal-locked because `_operatorPendingSlashCount[operator] > 0` (checked in StakingDelegat…

## Low (35)

| # | Issue | Location |
|---|---|---|
| 1 | DISPUTE_WINDOW_ROUNDS dead constant contradicts enforced 7-day slash window | `src/config/ProtocolConfig.sol:24` |
| 2 | EIP4788Oracle.latestBeaconTimestamp() returns a non-existent slot key; getBeaconBlockRoot( | `src/beacon/l1/EIP4788Oracle.sol:30` |
| 3 | StakingAdminFacet.setTangle grants TANGLE_ROLE without revoking prior holder | `src/facets/staking/StakingAdminFacet.sol:60` |
| 4 | TNTCliffLock clone master left initializable → stray delegate/withdraw on impl | `src/governance/lockups/TNTCliffLock.sol:35` |
| 5 | QUOTE_TYPEHASH references nested structs in non-canonical EIP-712 order | `src/libraries/SignatureLib.sol:36` |
| 6 | Unbounded gasLimit silently truncated by uint32 cast in BaseCrossChainMessenger.sendMessag | `src/beacon/bridges/BaseCrossChainMessenger.sol:67` |
| 7 | advanceRound() and snapshotOperator() are permissionless | `src/facets/staking/StakingSlashingFacet.sol:74` |
| 8 | snapshotOperator() permissionless and re-writable within a round | `src/facets/staking/StakingSlashingFacet.sol:80` |
| 9 | Permissionless snapshotOperator overwrites per-round operator snapshot | `src/facets/staking/StakingSlashingFacet.sol:79` |
| 10 | Arbitrum retryable excess-fee/call-value refunds locked at L2 alias under default config | `src/beacon/bridges/ArbitrumCrossChainMessenger.sol:135` |
| 11 | setAuditorActive(false) leaves weight>0, breaking advertised "inactive ⇒ weight 0" invaria | `src/governance/BlueprintAuditors.sol:178` |
| 12 | RebasingAssetAdapter previewDeposit/assetsToShares bootstrap factor (1e18) disagrees with  | `src/staking/adapters/RebasingAssetAdapter.sol:183` |
| 13 | mint() rounds required assets DOWN (floor) instead of UP → minter underpays, dilutes exist | `src/staking/LiquidDelegationVault.sol:226` |
| 14 | Slash strands deposit principal: residual delegatedAmount + currentDeposits permanently in | `src/staking/DelegationManagerLib.sol:514` |
| 15 | hasBeaconBlockRoot/hasBeaconRoot check only staticcall success (not returndata length); fa | `src/beacon/l1/EIP4788Oracle.sol:23` |
| 16 | Permissionless distributeEpoch() advances epoch with empty serviceIds, denying staker infl | `src/rewards/InflationPool.sol:375` |
| 17 | QuoteDetails digest lacks operation/serviceId binding → create-quote redeemable as extend | `src/libraries/SignatureLib.sol:85` |
| 18 | ChainlinkOracle lacks min/maxAnswer circuit-breaker bounds | `src/oracles/ChainlinkOracle.sol:254` |
| 19 | DEFAULT_MAX_OPERATORS_PER_SERVICE=256 sets high default for nested per-operator distributi | `src/config/ProtocolConfig.sol:43` |
| 20 | LiquidDelegationFactory.createVault never validates asset is enabled/adapter-compatible; o | `src/staking/LiquidDelegationFactory.sol:76` |
| 21 | RebasingAssetAdapter preview/view math diverges from executable deposit/withdraw share mat | `src/staking/adapters/RebasingAssetAdapter.sol:175` |
| 22 | Dispute bond permanently stranded when treasury push reverts on executeSlash | `src/core/Slashing.sol:546` |
| 23 | Unbounded permittedCallers list copied at activation → last approver bears O(N) gas, reque | `src/core/ServicesRequests.sol:316` |
| 24 | Streaming-mode rewards accrued while totalStaked==0 are permanently lost | `src/extensions/TokenizedBlueprintBase.sol:255` |
| 25 | Instant-mode reward rounding truncates small payments to zero against 100M-supply stake | `src/extensions/TokenizedBlueprintBase.sol:245` |
| 26 | _distributeStakingRewards splits cross-vault by raw deposits (ignores score) and can stran | `src/rewards/InflationPool.sol:530` |
| 27 | QuoteDetails lacks flow/serviceId discriminator: create-quote steerable into extend | `src/libraries/SignatureLib.sol:30` |
| 28 | QuoteDetails digest omits serviceId/intent → create-quote redeemable as extend-quote and a | `src/libraries/SignatureLib.sol:82` |
| 29 | Cold-start source repoint (setBlueprintSources) is not whenNotPaused while in-place upgrad | `src/core/BlueprintsManage.sol:124` |
| 30 | claimDelegatorRewardsFor lets anyone force-realize another account's rewards | `src/rewards/RewardVaults.sol:612` |
| 31 | InflationPool._distributeStakingRewards splits cross-vault by deposits not score | `src/rewards/InflationPool.sol:540` |
| 32 | Termination refunds full escrow to owner without settling the in-progress subscription per | `src/core/ServicesLifecycle.sol:115` |
| 33 | Swallowed distributeEpochReward revert strands pre-transferred TNT in vault | `src/rewards/InflationPool.sol:555` |
| 34 | executeDelegatorUnstakeAndWithdraw halves effective unbonding period vs standard two-step  | `src/facets/staking/StakingDelegationsFacet.sol:175` |
| 35 | Operator gossip key registered with no proof-of-possession → identity squat/DoS | `src/core/Operators.sol:126` |

## Info (3)

| # | Issue | Location |
|---|---|---|
| 1 | REWARD_GRACE_PERIOD_ROUNDS documents an anti-JIT reward delay that is never enforced | `src/config/ProtocolConfig.sol:27` |
| 2 | ROUNDS_PER_EPOCH dead constant (no enforced epoch boundary) | `src/config/ProtocolConfig.sol:15` |
| 3 | Adapter deposit/withdraw expose no slippage/min-out; declared SlippageTooHigh error is dea | `src/staking/adapters/RebasingAssetAdapter.sol:54` |
