// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { stdJson } from "forge-std/StdJson.sol";

import { ChainlinkOracle } from "../src/oracles/ChainlinkOracle.sol";
import { UniswapV3Oracle } from "../src/oracles/UniswapV3Oracle.sol";

/// @notice Minimal view of the two consumers that hold a price-oracle pointer. Both `Tangle`
///         (`Base.setPriceOracle`, ADMIN_ROLE) and `ServiceFeeDistributor` (`setPriceOracle`,
///         ADMIN_ROLE) expose this exact selector.
interface ISetPriceOracle {
    function setPriceOracle(address oracle) external;
}

/// @notice Ownable surface for the post-config ownership handoff.
interface IOwnableTransfer {
    function transferOwnership(address newOwner) external;
}

/// @title ConfigureOracle
/// @notice Config-driven bring-up for the price oracle: deploys a `ChainlinkOracle` or
///         `UniswapV3Oracle`, configures every feed/pool + staleness + L2 sequencer gate, optionally
///         wires it into `Tangle` and `ServiceFeeDistributor`, and hands the oracle's `Ownable`
///         ownership to the timelock/multisig.
///
/// @dev WHY THIS EXISTS. `FullDeploy` only *wires* a pre-existing oracle address
///      (`incentives.priceOracle`); it never deploys one and never configures feeds. With no oracle
///      set, every consumer (`PaymentsDistribution`, `PaymentsBilling`, `PaymentsEffectiveExposure`,
///      `ServiceFeeDistributor`) falls back to RAW token amounts — fine for a single homogeneous
///      asset, but mis-weights heterogeneous assets. This script is the missing post-deploy step
///      that turns USD normalization on.
///
///      ORDERING. Run AFTER `FullDeploy` (needs the `tangle`/`serviceFeeDistributor` addresses to
///      wire). On mainnet the wiring calls (`setPriceOracle`) require ADMIN_ROLE, so either run with
///      `oracle.wire=true` DURING the bootstrap window (before role handoff, deployer still holds
///      ADMIN_ROLE) or leave `wire=false` and execute the two printed `setPriceOracle` calls through
///      governance. The oracle's own ownership is always handed to `oracle.owner` (timelock/multisig)
///      as the final step.
///
///      CONFIG (`<FULL_DEPLOY_CONFIG>.oracle`):
///        {
///          "deploy": true,
///          "kind": "chainlink",                 // or "uniswap"
///          "weth": "0x...",                      // uniswap only (constructor arg / native quote)
///          "nativeFeed": "0x...",                // chainlink: ETH/USD feed (constructor); uniswap: native USD feed
///          "maxAgeSeconds": 3600,
///          "sequencerUptimeFeed": "0x...",       // Base: 0xBCF85224fc0756B9Fa45aA7892530B47e10b6433; 0x0 on L1
///          "sequencerGracePeriodSeconds": 3600,
///          "twapPeriodSeconds": 1800,            // uniswap only
///          "owner": "0x...",                     // timelock/multisig to receive Ownable ownership
///          "wire": false,                        // also call Tangle/SFD setPriceOracle (bootstrap only)
///          "tangle": "0x...",                    // required if wire
///          "serviceFeeDistributor": "0x...",     // optional if wire
///          "feeds": [ { "token": "0x..", "feed": "0x.." } ],                 // chainlink
///          "pools": [ { "token": "0x..", "pool": "0x..", "quoteFeed": "0x..", "quoteIsUsd": false } ] // uniswap
///        }
///
///      Usage:
///        PRIVATE_KEY=<pk> FULL_DEPLOY_CONFIG=deploy/config/base-mainnet.json \
///        forge script script/ConfigureOracle.s.sol:ConfigureOracle --rpc-url <rpc> --broadcast --slow
///
///      Local/anvil bypass of the production guards: TANGLE_DEPLOY_LOCAL=1.
contract ConfigureOracle is Script {
    using stdJson for string;

    struct OracleConfig {
        bool deploy;
        string kind; // "chainlink" | "uniswap"
        address weth;
        address nativeFeed;
        uint256 maxAgeSeconds;
        address sequencerUptimeFeed;
        uint256 sequencerGracePeriodSeconds;
        uint32 twapPeriodSeconds;
        address owner;
        bool wire;
        address tangle;
        address serviceFeeDistributor;
    }

    function run() external {
        uint256 deployerKey = _requireUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);

        string memory blob = _readConfig();
        OracleConfig memory c = _loadOracleConfig(blob);

        require(c.deploy, "oracle.deploy=false - nothing to do");
        bool isChainlink = _isChainlink(c.kind);
        require(isChainlink || _isUniswap(c.kind), "oracle.kind must be 'chainlink' or 'uniswap'");

        _requireProductionConfig(c, isChainlink, blob);

        console2.log("=== Configure Price Oracle ===");
        console2.log("ChainId:", block.chainid);
        console2.log("Deployer:", deployer);
        console2.log("Kind:", c.kind);

        vm.startBroadcast(deployerKey);

        address oracle = isChainlink ? _deployChainlink(c, blob) : _deployUniswap(c, blob);

        // Shared config (both oracles expose these selectors).
        if (c.maxAgeSeconds != 0) {
            ChainlinkOracle(oracle).setMaxPriceAge(c.maxAgeSeconds); // same selector on both
        }
        if (c.sequencerUptimeFeed != address(0)) {
            // setSequencerUptimeFeed requires a non-zero grace period.
            uint256 grace = c.sequencerGracePeriodSeconds == 0 ? 1 hours : c.sequencerGracePeriodSeconds;
            ChainlinkOracle(oracle).setSequencerUptimeFeed(c.sequencerUptimeFeed, grace);
            console2.log("Sequencer uptime feed set:", c.sequencerUptimeFeed);
        }

        // Optional wiring into the consumers (bootstrap window only; needs ADMIN_ROLE).
        if (c.wire) {
            require(c.tangle != address(0), "oracle.wire=true requires oracle.tangle");
            ISetPriceOracle(c.tangle).setPriceOracle(oracle);
            console2.log("Wired Tangle.setPriceOracle ->", oracle);
            if (c.serviceFeeDistributor != address(0)) {
                ISetPriceOracle(c.serviceFeeDistributor).setPriceOracle(oracle);
                console2.log("Wired ServiceFeeDistributor.setPriceOracle ->", oracle);
            }
        }

        // Final step: hand the oracle's Ownable ownership to the timelock/multisig.
        if (c.owner != address(0) && c.owner != deployer) {
            IOwnableTransfer(oracle).transferOwnership(c.owner);
            console2.log("Oracle ownership transferred to:", c.owner);
        }

        vm.stopBroadcast();

        console2.log("Oracle deployed:", oracle);
        _writeManifest(oracle, c.kind);

        if (!c.wire) {
            console2.log("--- WIRE VIA GOVERNANCE (oracle.wire was false) ---");
            console2.log("  Tangle.setPriceOracle(", oracle, ")");
            console2.log("  ServiceFeeDistributor.setPriceOracle(", oracle, ")");
        }
    }

    // ── deployers
    // ──────────────────────────────────────────────────────────────

    function _deployChainlink(OracleConfig memory c, string memory blob) internal returns (address) {
        ChainlinkOracle oracle = new ChainlinkOracle(c.nativeFeed); // native feed set in constructor

        uint256 n = _arrayLen(blob, ".oracle.feeds", ".token");
        for (uint256 i = 0; i < n; i++) {
            string memory base = string.concat(".oracle.feeds[", vm.toString(i), "]");
            address token = blob.readAddress(string.concat(base, ".token"));
            address feed = blob.readAddress(string.concat(base, ".feed"));
            oracle.configurePriceFeed(token, feed);
            console2.log("  feed configured token/feed:", token, feed);
        }
        return address(oracle);
    }

    function _deployUniswap(OracleConfig memory c, string memory blob) internal returns (address) {
        require(c.weth != address(0), "uniswap: oracle.weth required");
        UniswapV3Oracle oracle = new UniswapV3Oracle(c.weth);

        if (c.twapPeriodSeconds != 0) {
            oracle.setTwapPeriod(c.twapPeriodSeconds);
        }
        if (c.nativeFeed != address(0)) {
            oracle.setNativeTokenFeed(c.nativeFeed); // quoteTokenFeeds[address(0)]
        }

        uint256 n = _arrayLen(blob, ".oracle.pools", ".token");
        for (uint256 i = 0; i < n; i++) {
            string memory base = string.concat(".oracle.pools[", vm.toString(i), "]");
            address token = blob.readAddress(string.concat(base, ".token"));
            address pool = blob.readAddress(string.concat(base, ".pool"));
            address quoteFeed = blob.keyExists(string.concat(base, ".quoteFeed"))
                ? blob.readAddress(string.concat(base, ".quoteFeed"))
                : address(0);
            bool quoteIsUsd =
                blob.keyExists(string.concat(base, ".quoteIsUsd")) && blob.readBool(string.concat(base, ".quoteIsUsd"));
            oracle.configurePool(token, pool, quoteFeed, quoteIsUsd);
            console2.log("  pool configured token/pool:", token, pool);
        }
        return address(oracle);
    }

    // ── config loading
    // ──────────────────────────────────────────────────────────

    function _readConfig() internal view returns (string memory blob) {
        string memory path = vm.envString("FULL_DEPLOY_CONFIG");
        blob = vm.readFile(path);
        require(bytes(blob).length != 0, "empty FULL_DEPLOY_CONFIG");
        require(blob.keyExists(".oracle"), "config has no `oracle` block");
    }

    function _loadOracleConfig(string memory blob) internal view returns (OracleConfig memory c) {
        c.deploy = blob.keyExists(".oracle.deploy") && blob.readBool(".oracle.deploy");
        c.kind = blob.keyExists(".oracle.kind") ? blob.readString(".oracle.kind") : "";
        if (blob.keyExists(".oracle.weth")) c.weth = blob.readAddress(".oracle.weth");
        if (blob.keyExists(".oracle.nativeFeed")) c.nativeFeed = blob.readAddress(".oracle.nativeFeed");
        if (blob.keyExists(".oracle.maxAgeSeconds")) c.maxAgeSeconds = blob.readUint(".oracle.maxAgeSeconds");
        if (blob.keyExists(".oracle.sequencerUptimeFeed")) {
            c.sequencerUptimeFeed = blob.readAddress(".oracle.sequencerUptimeFeed");
        }
        if (blob.keyExists(".oracle.sequencerGracePeriodSeconds")) {
            c.sequencerGracePeriodSeconds = blob.readUint(".oracle.sequencerGracePeriodSeconds");
        }
        if (blob.keyExists(".oracle.twapPeriodSeconds")) {
            c.twapPeriodSeconds = uint32(blob.readUint(".oracle.twapPeriodSeconds"));
        }
        if (blob.keyExists(".oracle.owner")) c.owner = blob.readAddress(".oracle.owner");
        c.wire = blob.keyExists(".oracle.wire") && blob.readBool(".oracle.wire");
        if (blob.keyExists(".oracle.tangle")) c.tangle = blob.readAddress(".oracle.tangle");
        if (blob.keyExists(".oracle.serviceFeeDistributor")) {
            c.serviceFeeDistributor = blob.readAddress(".oracle.serviceFeeDistributor");
        }
    }

    /// @dev Count a JSON array by probing `<path>[i]<probeKey>` until it stops existing — the same
    ///      pattern `FullDeploy._loadVaults` uses (avoids fragile parseRaw/abi.decode struct layout).
    function _arrayLen(
        string memory blob,
        string memory path,
        string memory probeKey
    )
        internal
        view
        returns (uint256 n)
    {
        while (blob.keyExists(string.concat(path, "[", vm.toString(n), "]", probeKey))) {
            n++;
        }
    }

    // ── production guards
    // ─────────────────────────────────────────────────────────

    /// @dev Refuse footguns on a production chain: an oracle whose ownership stays with the EOA
    ///      deployer, a missing native/quote source, or a sequencer gate omitted on a known L2.
    ///      Bypass on anvil/local with TANGLE_DEPLOY_LOCAL=1.
    function _requireProductionConfig(OracleConfig memory c, bool isChainlink, string memory blob) internal view {
        if (!_isProductionChain()) return;

        require(c.owner != address(0), "prod: oracle.owner (timelock/multisig) must be set");
        require(c.maxAgeSeconds != 0, "prod: oracle.maxAgeSeconds must be set");

        if (isChainlink) {
            require(
                c.nativeFeed != address(0) || _arrayLen(blob, ".oracle.feeds", ".token") > 0, "prod: no chainlink feeds"
            );
        } else {
            require(_arrayLen(blob, ".oracle.pools", ".token") > 0, "prod: no uniswap pools");
        }

        // Base / Optimism / Arbitrum are L2s with a canonical sequencer-uptime feed; require it so the
        // oracle cannot serve frozen prices during a sequencer outage.
        uint256 id = block.chainid;
        if (id == 8453 || id == 10 || id == 42_161) {
            require(c.sequencerUptimeFeed != address(0), "prod L2: oracle.sequencerUptimeFeed must be set");
        }
        if (c.wire) {
            require(c.tangle != address(0), "prod: oracle.wire=true requires oracle.tangle");
        }
    }

    function _isProductionChain() internal view returns (bool) {
        if (vm.envOr("TANGLE_DEPLOY_LOCAL", uint256(0)) != 0) return false;
        uint256 id = block.chainid;
        return id == 1 || id == 8453 || id == 5845 || id == 42_161 || id == 10;
    }

    // ── manifest
    // ──────────────────────────────────────────────────────────────────

    function _writeManifest(address oracle, string memory kind) internal {
        string memory outPath = vm.envOr("ORACLE_MANIFEST", string("deployments/oracle.json"));
        string memory manifest = "oracle";
        manifest.serialize("kind", kind);
        manifest.serialize("chainId", block.chainid);
        manifest = manifest.serialize("oracle", oracle);
        manifest.write(outPath);
        console2.log("Manifest written:", outPath);
    }

    // ── env
    // ───────────────────────────────────────────────────────────────────────

    function _requireUint(string memory key) internal view returns (uint256) {
        try vm.envUint(key) returns (uint256 v) {
            return v;
        } catch {
            revert(string.concat("Missing env ", key));
        }
    }

    function _isChainlink(string memory k) internal pure returns (bool) {
        return keccak256(bytes(k)) == keccak256("chainlink");
    }

    function _isUniswap(string memory k) internal pure returns (bool) {
        return keccak256(bytes(k)) == keccak256("uniswap");
    }
}
