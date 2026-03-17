export { ShieldedGatewayClient } from "./gateway-client.js";
export type { GatewayClientConfig } from "./gateway-client.js";
export { syncLeaves, discoverNotes } from "./leaf-sync.js";
export type { LeafSyncResult, DiscoveredNote } from "./leaf-sync.js";
export {
  ShieldedCreditsClient,
  generateCreditKeys,
  signSpendAuthorization,
  signWithdrawal,
} from "./credits-client.js";
export type {
  CreditKeys,
  CreditAccountState,
  SignedSpendAuth,
} from "./credits-client.js";
