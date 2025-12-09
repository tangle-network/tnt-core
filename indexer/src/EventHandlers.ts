import { registerTangleHandlers } from "./handlers/tangle";
import { registerRestakingHandlers } from "./handlers/restaking";
import { registerRewardVaultHandlers } from "./handlers/rewardVaults";
import { registerBlueprintManagerHandlers } from "./handlers/blueprintManager";
import { registerCreditHandlers } from "./handlers/credits";
import { registerHourlyHandlers } from "./handlers/hourly";

registerTangleHandlers();
registerRestakingHandlers();
registerRewardVaultHandlers();
registerBlueprintManagerHandlers();
registerCreditHandlers();
registerHourlyHandlers();
