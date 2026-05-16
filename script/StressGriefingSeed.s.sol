// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice ERC20 whose `transfer` reverts. `transferFrom`/balance/approve still work so a
///         service could in principle collect payment; the revert only fires when the
///         diamond tries to flush operator rewards via the `_claimRewardsToken` path.
contract RevertingTransferERC20 is ERC20 {
    error TransferGriefed();

    constructor() ERC20("Griefer", "GRF") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert TransferGriefed();
    }
}

/// @title StressGriefingSeed
/// @notice Deploys a `RevertingTransferERC20` whose address the bash harness uses for
///         the per-token griefing storage seed (issued via `anvil_setStorageAt`).
///         `vm.store` in a broadcast script only mutates simulation state — it is NOT
///         propagated to anvil — so the seeding lives entirely in the harness's RPC
///         calls. This script's only on-chain side effect is the ERC20 deployment.
contract StressGriefingSeed is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("DEPLOYER_KEY");
        vm.startBroadcast(deployerKey);
        RevertingTransferERC20 grief = new RevertingTransferERC20();
        vm.stopBroadcast();
        // Print only this final line, parsed by the harness via `grep -oE`.
        console2.log("GRIEF_TOKEN=", address(grief));
    }
}
