import { Tangle } from "generated";
import type {
  Blueprint,
  EscrowBalance,
  JobCall,
  JobResult,
  Operator,
  OperatorIntent,
  OperatorRegistration,
  ProtocolState,
  QuoteUsage,
  RewardClaim,
  Role,
  RoleAssignment,
  Service,
  ServiceOperator,
  ServiceRequest,
  SlashConfig,
  SlashProposal,
  SubscriptionBilling,
  Upgrade,
} from "generated/src/Types.gen";
import {
  ZERO_ADDRESS,
  ensureAssetPosition,
  ensureDelegator,
  ensureOperator,
  ensureProtocolState,
  ensureSlashConfig,
  getEventId,
  getPointsManager,
  getSlashProposal,
  getSlashProposalId,
  getTimestamp,
  getTxHash,
  mapBlueprintSelection,
  normalizeAddress,
  subtractToZero,
  toBigInt,
  toHexString,
  toNumber,
} from "../lib/handlerUtils";
import { activateParticipation, deactivateParticipation, pointsContext } from "../points/participation";
import { toPointsValue } from "../points/math";
import {
  awardCustomerEscrowFunding,
  awardCustomerServiceActivation,
  awardCustomerServiceRequest,
  awardDeveloperBlueprint,
  awardOperatorServiceJoin,
} from "../points/awards";

export function registerTangleHandlers() {
  /* ────────────────────────────────────────────────────────────────────────────
     TANGLE EVENTS
     ────────────────────────────────────────────────────────────────────────── */

  Tangle.Initialized.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const state = await ensureProtocolState(context, timestamp);
    context.ProtocolState.set({
      ...state,
      version: toBigInt(event.params.version),
      lastUpdatedAt: timestamp,
    } as ProtocolState);
  });

  Tangle.Paused.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const state = await ensureProtocolState(context, timestamp);
    context.ProtocolState.set({
      ...state,
      paused: true,
      pausedAt: timestamp,
      pausedBy: normalizeAddress(event.params.account),
      lastUpdatedAt: timestamp,
    } as ProtocolState);
  });

  Tangle.Unpaused.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const state = await ensureProtocolState(context, timestamp);
    context.ProtocolState.set({
      ...state,
      paused: false,
      pausedAt: undefined,
      pausedBy: undefined,
      lastUpdatedAt: timestamp,
    } as ProtocolState);
  });

  Tangle.Upgraded.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const implementation = normalizeAddress(event.params.implementation);
    const state = await ensureProtocolState(context, timestamp);
    context.ProtocolState.set({
      ...state,
      currentImplementation: implementation,
      lastUpdatedAt: timestamp,
    } as ProtocolState);
    const upgrade: Upgrade = {
      id: getEventId(event),
      implementation,
      upgradedAt: timestamp,
      txHash: getTxHash(event),
    } as Upgrade;
    context.Upgrade.set(upgrade);
  });

  Tangle.QuoteUsed.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const usage: QuoteUsage = {
      id: getEventId(event),
      operator_id: operator.id,
      quoteHash: toHexString(event.params.quoteHash),
      usedAt: timestamp,
      txHash: getTxHash(event),
    } as QuoteUsage;
    context.QuoteUsage.set(usage);
  });

  Tangle.SlashConfigUpdated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const config = await ensureSlashConfig(context, timestamp);
    context.SlashConfig.set({
      ...config,
      disputeWindow: toBigInt(event.params.disputeWindow),
      instantSlashEnabled: Boolean(event.params.instantSlashEnabled),
      maxSlashBps: toBigInt(event.params.maxSlashBps),
      updatedAt: timestamp,
    } as SlashConfig);
  });

  Tangle.SlashProposed.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const slashId = getSlashProposalId(event.params.slashId);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const serviceValue = toBigInt(event.params.serviceId);
    const serviceId = serviceValue.toString();
    const proposal: SlashProposal = {
      id: slashId,
      slashId: toBigInt(event.params.slashId),
      serviceId: serviceValue,
      service_id: serviceId,
      operator_id: operator.id,
      proposer: normalizeAddress(event.params.proposer),
      amount: toBigInt(event.params.amount),
      effectiveAmount: toBigInt(event.params.effectiveAmount),
      evidence: toHexString(event.params.evidence),
      executeAfter: toBigInt(event.params.executeAfter),
      status: "PENDING",
      createdAt: timestamp,
    } as SlashProposal;
    context.SlashProposal.set(proposal);
  });

  Tangle.SlashDisputed.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const proposal = await getSlashProposal(context, event.params.slashId);
    if (!proposal) return;
    context.SlashProposal.set({
      ...proposal,
      status: "DISPUTED",
      disputedAt: timestamp,
      disputeReason: event.params.reason,
      disputer: normalizeAddress(event.params.disputer),
    } as SlashProposal);
  });

  Tangle.SlashCancelled.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const proposal = await getSlashProposal(context, event.params.slashId);
    if (!proposal) return;
    context.SlashProposal.set({
      ...proposal,
      status: "CANCELLED",
      cancelledAt: timestamp,
      canceller: normalizeAddress(event.params.canceller),
      cancelReason: event.params.reason,
      disputeReason: proposal.disputeReason ?? event.params.reason,
    } as SlashProposal);
  });

  Tangle.SlashExecuted.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const serviceValue = toBigInt(event.params.serviceId);
    const serviceId = serviceValue.toString();
    const proposal = await getSlashProposal(context, event.params.slashId);
    if (!proposal) return;
    context.SlashProposal.set({
      ...proposal,
      status: "EXECUTED",
      executedAt: timestamp,
      actualSlashed: toBigInt(event.params.actualSlashed),
      operator_id: operator.id,
      service_id: serviceId,
      serviceId: serviceValue,
    } as SlashProposal);
  });

  Tangle.BlueprintCreated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const blueprint: Blueprint = {
      id: toBigInt(event.params.blueprintId).toString(),
      blueprintId: toBigInt(event.params.blueprintId),
      owner: normalizeAddress(event.params.owner),
      manager: normalizeAddress(event.params.manager),
      metadataUri: undefined,
      active: true,
      createdAt: timestamp,
      updatedAt: timestamp,
      operatorCount: 0n,
    } as Blueprint;
    context.Blueprint.set(blueprint);
    const points = getPointsManager(pointsContext(context), event);
    await awardDeveloperBlueprint(points, blueprint.owner, blueprint.id);
  });

  Tangle.BlueprintUpdated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const id = toBigInt(event.params.blueprintId).toString();
    const existing = await context.Blueprint.get(id);
    if (!existing) return;
    context.Blueprint.set({ ...existing, metadataUri: event.params.metadataUri, updatedAt: timestamp });
  });

  Tangle.BlueprintTransferred.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const id = toBigInt(event.params.blueprintId).toString();
    const existing = await context.Blueprint.get(id);
    if (!existing) return;
    context.Blueprint.set({ ...existing, owner: normalizeAddress(event.params.to), updatedAt: timestamp });
  });

  Tangle.BlueprintDeactivated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const id = toBigInt(event.params.blueprintId).toString();
    const existing = await context.Blueprint.get(id);
    if (!existing) return;
    context.Blueprint.set({ ...existing, active: false, updatedAt: timestamp });
  });

  Tangle.OperatorPreRegistered.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const intent: OperatorIntent = {
      id: getEventId(event),
      blueprint_id: toBigInt(event.params.blueprintId).toString(),
      operator_id: operator.id,
      createdAt: timestamp,
      txHash: getTxHash(event),
    } as OperatorIntent;
    context.OperatorIntent.set(intent);
  });

  Tangle.OperatorRegistered.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const blueprintId = toBigInt(event.params.blueprintId).toString();
    const blueprint = await context.Blueprint.get(blueprintId);
    const operator = await ensureOperator(context, event.params.operator, timestamp, {
      ecdsaPublicKey: toHexString(event.params.ecdsaPublicKey),
      rpcAddress: event.params.rpcAddress,
    });
    const regId = `${blueprintId}-${operator.id}`;
    const registration: OperatorRegistration = {
      id: regId,
      blueprint_id: blueprintId,
      operator_id: operator.id,
      status: "ACTIVE",
      registeredAt: timestamp,
      updatedAt: timestamp,
      unregisteredAt: undefined,
      ecdsaPublicKey: operator.ecdsaPublicKey,
      rpcAddress: operator.rpcAddress,
    } as OperatorRegistration;
    context.OperatorRegistration.set(registration);
    if (blueprint) {
      context.Blueprint.set({ ...blueprint, operatorCount: (blueprint.operatorCount ?? 0n) + 1n } as Blueprint);
    }
  });

  Tangle.OperatorUnregistered.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const blueprintId = toBigInt(event.params.blueprintId).toString();
    const operatorId = normalizeAddress(event.params.operator);
    const blueprint = await context.Blueprint.get(blueprintId);
    const regId = `${blueprintId}-${operatorId}`;
    const registration = await context.OperatorRegistration.get(regId);
    if (!registration) return;
    context.OperatorRegistration.set({ ...registration, status: "UNREGISTERED", unregisteredAt: timestamp, updatedAt: timestamp });
    if (blueprint) {
      context.Blueprint.set({ ...blueprint, operatorCount: subtractToZero(blueprint.operatorCount, 1n) } as Blueprint);
    }
  });

  Tangle.OperatorPreferencesUpdated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureOperator(context, event.params.operator, timestamp, {
      ecdsaPublicKey: toHexString(event.params.ecdsaPublicKey) || undefined,
      rpcAddress: event.params.rpcAddress || undefined,
    });
    const blueprintId = toBigInt(event.params.blueprintId).toString();
    const regId = `${blueprintId}-${operator.id}`;
    const registration = await context.OperatorRegistration.get(regId);
    if (registration) {
      context.OperatorRegistration.set({
        ...registration,
        ecdsaPublicKey: operator.ecdsaPublicKey,
        rpcAddress: operator.rpcAddress,
        updatedAt: timestamp,
      });
    }
  });

  Tangle.ServiceRequested.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const id = toBigInt(event.params.requestId).toString();
    const request: ServiceRequest = {
      id,
      requestId: toBigInt(event.params.requestId),
      blueprint_id: toBigInt(event.params.blueprintId).toString(),
      requester: normalizeAddress(event.params.requester),
      createdAt: timestamp,
      updatedAt: timestamp,
      status: "PENDING",
      approvalCount: 0n,
      approvedOperators: [],
      rejectedOperators: [],
      operatorCandidates: [],
      securityRequirements: undefined,
    } as ServiceRequest;
    context.ServiceRequest.set(request);
    const points = getPointsManager(pointsContext(context), event);
    await awardCustomerServiceRequest(points, request.requester, id);
  });

  Tangle.ServiceRequestedWithSecurity.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const id = toBigInt(event.params.requestId).toString();
    const blueprintId = toBigInt(event.params.blueprintId).toString();
    const requester = normalizeAddress(event.params.requester);
    let request = await context.ServiceRequest.get(id);
    const created = !request;
    if (!request) {
      request = {
        id,
        requestId: toBigInt(event.params.requestId),
        blueprint_id: blueprintId,
        requester,
        createdAt: timestamp,
        updatedAt: timestamp,
        status: "PENDING",
        approvalCount: 0n,
        approvedOperators: [],
        rejectedOperators: [],
        operatorCandidates: [],
        securityRequirements: undefined,
      } as ServiceRequest;
    }
    const updated: ServiceRequest = {
      ...request,
      blueprint_id: blueprintId,
      requester: request.requester ?? requester,
      operatorCandidates: (event.params.operators || []).map((op) => normalizeAddress(op)),
      securityRequirements: JSON.stringify(event.params.securityRequirements ?? []),
      updatedAt: timestamp,
    } as ServiceRequest;
    context.ServiceRequest.set(updated);
    if (created) {
      const points = getPointsManager(pointsContext(context), event);
      await awardCustomerServiceRequest(points, updated.requester, id);
    }
  });

  Tangle.ServiceApproved.handler(async ({ event, context }) => {
    const id = toBigInt(event.params.requestId).toString();
    const request = await context.ServiceRequest.get(id);
    if (!request) return;
    const operator = normalizeAddress(event.params.operator);
    if (request.approvedOperators?.includes(operator)) return;
    context.ServiceRequest.set({
      ...request,
      approvedOperators: [...(request.approvedOperators ?? []), operator],
      approvalCount: (request.approvalCount ?? 0n) + 1n,
    });
  });

  Tangle.ServiceRejected.handler(async ({ event, context }) => {
    const id = toBigInt(event.params.requestId).toString();
    const request = await context.ServiceRequest.get(id);
    if (!request) return;
    const operator = normalizeAddress(event.params.operator);
    if (request.rejectedOperators?.includes(operator)) return;
    context.ServiceRequest.set({
      ...request,
      rejectedOperators: [...(request.rejectedOperators ?? []), operator],
    });
  });

  Tangle.ServiceActivated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const serviceId = toBigInt(event.params.serviceId).toString();
    const blueprintId = toBigInt(event.params.blueprintId).toString();
    const requestId = toBigInt(event.params.requestId).toString();
    const request = await context.ServiceRequest.get(requestId);
    const service: Service = {
      id: serviceId,
      serviceId: toBigInt(event.params.serviceId),
      blueprint_id: blueprintId,
      request_id: request?.id,
      owner: request?.requester ?? ZERO_ADDRESS,
      status: "ACTIVE",
      createdAt: timestamp,
      terminatedAt: undefined,
    } as Service;
    context.Service.set(service);
    if (request) {
      context.ServiceRequest.set({ ...request, status: "ACTIVATED", updatedAt: timestamp });
    }
    await activateParticipation(context, "service-hourly", service.id, "SERVICE", timestamp);
    const points = getPointsManager(pointsContext(context), event);
    await awardCustomerServiceActivation(points, service.owner, service.id);
  });

  Tangle.ServiceTerminated.handler(async ({ event, context }) => {
    const serviceId = toBigInt(event.params.serviceId).toString();
    const service = await context.Service.get(serviceId);
    if (!service) return;
    const timestamp = getTimestamp(event);
    context.Service.set({ ...service, status: "TERMINATED", terminatedAt: timestamp });
    await deactivateParticipation(context, "service-hourly", service.id, timestamp);
  });

  Tangle.OperatorJoinedService.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
    if (!service) return;
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const id = `${service.id}-${operator.id}`;
    const membership: ServiceOperator = {
      id,
      service_id: service.id,
      operator_id: operator.id,
      exposureBps: BigInt(event.params.exposureBps ?? 0),
      joinedAt: timestamp,
      active: true,
    } as ServiceOperator;
    context.ServiceOperator.set(membership);
    const points = getPointsManager(pointsContext(context), event);
    await awardOperatorServiceJoin(points, operator.id, service.id);
    await activateParticipation(context, "operator-service-hourly", operator.id, "OPERATOR", timestamp);
  });

  Tangle.OperatorLeftService.handler(async ({ event, context }) => {
    const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
    if (!service) return;
    const id = `${service.id}-${normalizeAddress(event.params.operator)}`;
    const membership = await context.ServiceOperator.get(id);
    if (!membership) return;
    const timestamp = getTimestamp(event);
    context.ServiceOperator.set({ ...membership, active: false, leftAt: timestamp });
    await deactivateParticipation(context, "operator-service-hourly", normalizeAddress(event.params.operator), timestamp);
  });

  Tangle.ExitScheduled.handler(async ({ event, context }) => {
    const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
    if (!service) return;
    const id = `${service.id}-${normalizeAddress(event.params.operator)}`;
    const membership = await context.ServiceOperator.get(id);
    if (!membership) return;
    context.ServiceOperator.set({
      ...membership,
      exitScheduledAt: getTimestamp(event),
      exitExecuteAfter: toBigInt(event.params.executeAfter),
    });
  });

  Tangle.ExitCanceled.handler(async ({ event, context }) => {
    const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
    if (!service) return;
    const id = `${service.id}-${normalizeAddress(event.params.operator)}`;
    const membership = await context.ServiceOperator.get(id);
    if (!membership) return;
    context.ServiceOperator.set({
      ...membership,
      exitScheduledAt: undefined,
      exitExecuteAfter: undefined,
      exitCancelledAt: getTimestamp(event),
    });
  });

  Tangle.ExitForced.handler(async ({ event, context }) => {
    const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
    if (!service) return;
    const id = `${service.id}-${normalizeAddress(event.params.operator)}`;
    const membership = await context.ServiceOperator.get(id);
    if (!membership) return;
    context.ServiceOperator.set({
      ...membership,
      active: false,
      leftAt: getTimestamp(event),
      exitScheduledAt: undefined,
      exitExecuteAfter: undefined,
      exitForcedBy: normalizeAddress(event.params.forcer),
    });
    await deactivateParticipation(context, "operator-service-hourly", normalizeAddress(event.params.operator), getTimestamp(event));
  });

  Tangle.JobSubmitted.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
    if (!service) return;
    const callId = toBigInt(event.params.callId).toString();
    const job: JobCall = {
      id: `${service.id}-${callId}`,
      service_id: service.id,
      callId: toBigInt(event.params.callId),
      jobIndex: toNumber(event.params.jobIndex),
      caller: normalizeAddress(event.params.caller),
      inputs: toHexString(event.params.inputs),
      createdAt: timestamp,
      completed: false,
    } as JobCall;
    context.JobCall.set(job);
    const points = getPointsManager(pointsContext(context), event);
    await points.award(job.caller, "service-activity", 1n, "job submitted");
  });

  Tangle.JobResultSubmitted.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const serviceId = toBigInt(event.params.serviceId).toString();
    const callId = toBigInt(event.params.callId).toString();
    const job = await context.JobCall.get(`${serviceId}-${callId}`);
    if (!job) return;
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const result: JobResult = {
      id: `${serviceId}-${callId}-${operator.id}`,
      jobCall_id: job.id,
      operator_id: operator.id,
      output: toHexString(event.params.output),
      aggregated: false,
      submittedAt: timestamp,
      txHash: getTxHash(event),
    } as JobResult;
    context.JobResult.set(result);
    const points = getPointsManager(pointsContext(context), event);
    await points.award(operator.id, "service-activity", 1n, "job result");
  });

  Tangle.JobCompleted.handler(async ({ event, context }) => {
    const serviceId = toBigInt(event.params.serviceId).toString();
    const job = await context.JobCall.get(`${serviceId}-${toBigInt(event.params.callId).toString()}`);
    if (!job) return;
    context.JobCall.set({ ...job, completed: true, completedAt: getTimestamp(event) });
  });

  Tangle.AggregatedResultSubmitted.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const serviceId = toBigInt(event.params.serviceId).toString();
    const callId = toBigInt(event.params.callId).toString();
    const job = await context.JobCall.get(`${serviceId}-${callId}`);
    if (!job) return;
    const result: JobResult = {
      id: `${serviceId}-${callId}-aggregate`,
      jobCall_id: job.id,
      operator_id: undefined,
      output: toHexString(event.params.output),
      signerBitmap: toBigInt(event.params.signerBitmap),
      aggregated: true,
      submittedAt: timestamp,
      txHash: getTxHash(event),
    } as JobResult;
    context.JobResult.set(result);
    const service = await context.Service.get(job.service_id ?? "");
    const owner = service?.owner ?? ZERO_ADDRESS;
    const points = getPointsManager(pointsContext(context), event);
    await points.award(owner, "service-activity", 1n, "aggregated result");
  });

  Tangle.EscrowFunded.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
    if (!service) return;
    const id = service.id;
    const existing = await context.EscrowBalance.get(id);
    const balance: EscrowBalance = {
      id,
      service_id: service.id,
      token: normalizeAddress(event.params.token ?? existing?.token ?? ZERO_ADDRESS),
      totalFunded: (existing?.totalFunded ?? 0n) + toBigInt(event.params.amount),
      totalBilled: existing?.totalBilled ?? 0n,
      lastFundedAt: timestamp,
      lastBilledAt: existing?.lastBilledAt,
    } as EscrowBalance;
    context.EscrowBalance.set(balance);
    const points = getPointsManager(pointsContext(context), event);
    await awardCustomerEscrowFunding(points, service.owner, service.id, toBigInt(event.params.amount));
  });

  Tangle.SubscriptionBilled.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
    if (!service) return;
    const id = service.id;
    const existing = await context.EscrowBalance.get(id);
    const balance: EscrowBalance = {
      id,
      service_id: service.id,
      token: existing?.token ?? ZERO_ADDRESS,
      totalFunded: existing?.totalFunded ?? 0n,
      totalBilled: (existing?.totalBilled ?? 0n) + toBigInt(event.params.amount),
      lastFundedAt: existing?.lastFundedAt,
      lastBilledAt: timestamp,
    } as EscrowBalance;
    context.EscrowBalance.set(balance);
    const billing: SubscriptionBilling = {
      id: getEventId(event),
      service_id: service.id,
      amount: toBigInt(event.params.amount),
      period: toBigInt(event.params.period),
      billedAt: timestamp,
      txHash: getTxHash(event),
    } as SubscriptionBilling;
    context.SubscriptionBilling.set(billing);
  });

  Tangle.RewardsClaimed.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const claim: RewardClaim = {
      id: getEventId(event),
      account: normalizeAddress(event.params.account),
      token: normalizeAddress(event.params.token),
      amount: toBigInt(event.params.amount),
      claimedAt: timestamp,
      txHash: getTxHash(event),
    } as RewardClaim;
    context.RewardClaim.set(claim);
  });

  Tangle.RoleAdminChanged.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const role: Role = {
      id: toHexString(event.params.role),
      role: toHexString(event.params.role),
      adminRole: toHexString(event.params.newAdminRole),
      updatedAt: timestamp,
    } as Role;
    context.Role.set(role);
  });

  Tangle.RoleGranted.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const roleId = toHexString(event.params.role);
    const assignment: RoleAssignment = {
      id: `${roleId}-${normalizeAddress(event.params.account)}`,
      roleRef_id: roleId,
      account: normalizeAddress(event.params.account),
      active: true,
      grantedAt: timestamp,
      sender: normalizeAddress(event.params.sender),
    } as RoleAssignment;
    context.RoleAssignment.set(assignment);
  });

  Tangle.RoleRevoked.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const roleId = toHexString(event.params.role);
    const id = `${roleId}-${normalizeAddress(event.params.account)}`;
    const assignment = await context.RoleAssignment.get(id);
    if (!assignment) return;
    context.RoleAssignment.set({
      ...assignment,
      active: false,
      revokedAt: timestamp,
      sender: normalizeAddress(event.params.sender),
    });
  });
}
