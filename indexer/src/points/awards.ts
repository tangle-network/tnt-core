import { PointsManager } from "../points";
import { toPointsValue } from "./math";

const BLUEPRINT_BONUS = 100n;
const SERVICE_REQUEST_BONUS = 25n;
const SERVICE_ACTIVATION_BONUS = 50n;
const OPERATOR_UPTIME_BONUS = 1n;
const OPERATOR_SERVICE_JOIN_BONUS = 20n;

export const awardDeveloperBlueprint = async (points: PointsManager, owner: string | undefined, blueprintId: string) => {
  if (!owner) return;
  await points.award(owner, "developer-blueprint", BLUEPRINT_BONUS, `blueprint ${blueprintId}`);
};

export const awardCustomerServiceRequest = async (points: PointsManager, requester: string | undefined, requestId: string) => {
  if (!requester) return;
  await points.award(requester, "customer-service", SERVICE_REQUEST_BONUS, `service request ${requestId}`);
};

export const awardCustomerServiceActivation = async (points: PointsManager, owner: string | undefined, serviceId: string) => {
  if (!owner) return;
  await points.award(owner, "customer-service", SERVICE_ACTIVATION_BONUS, `service activated ${serviceId}`);
};

export const awardCustomerEscrowFunding = async (
  points: PointsManager,
  owner: string | undefined,
  serviceId: string,
  amount: bigint
) => {
  if (!owner) return;
  const scaled = toPointsValue(amount);
  await points.award(owner, "customer-escrow", scaled, `escrow funded ${serviceId}`);
};

export const awardOperatorUptime = async (points: PointsManager, operatorId: string, serviceId: string) => {
  await points.award(operatorId, "operator-uptime", OPERATOR_UPTIME_BONUS, `heartbeat ${serviceId}`);
};

export const awardOperatorServiceJoin = async (points: PointsManager, operatorId: string, serviceId: string) => {
  await points.award(operatorId, "operator-service", OPERATOR_SERVICE_JOIN_BONUS, `joined service ${serviceId}`);
};

export const awardRestakerVaultStake = async (
  points: PointsManager,
  delegator: string | undefined,
  asset: string | undefined,
  amount: bigint
) => {
  if (!delegator) return;
  await points.award(delegator, "restaker-vault", toPointsValue(amount), `vault stake ${asset ?? ""}`);
};

export const awardNativePodCreated = async (points: PointsManager, owner: string | undefined, podId: string) => {
  if (!owner) return;
  await points.award(owner, "native-pod", 25n, `pod ${podId}`);
};
