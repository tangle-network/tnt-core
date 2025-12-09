import { registerTangleHandlers } from "./handlers/tangle";
import { registerRestakingHandlers } from "./handlers/restaking";
import { registerRewardVaultHandlers } from "./handlers/rewardVaults";
import { registerBlueprintManagerHandlers } from "./handlers/blueprintManager";
import { registerCreditHandlers } from "./handlers/credits";
import { registerHourlyHandlers } from "./handlers/hourly";
import { registerLiquidDelegationHandlers } from "./handlers/liquidDelegation";
import { registerValidatorPodHandlers } from "./handlers/validatorPods";

registerTangleHandlers();
registerRestakingHandlers();
registerRewardVaultHandlers();
registerBlueprintManagerHandlers();
registerCreditHandlers();
registerLiquidDelegationHandlers();
registerValidatorPodHandlers();
registerHourlyHandlers();
