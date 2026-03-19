import { ethers } from "ethers";
import { randomBytes } from "crypto";

// EIP-712 type hashes (must match ShieldedCredits.sol)
const SPEND_TYPEHASH = ethers.keccak256(
  ethers.toUtf8Bytes(
    "SpendAuthorization(bytes32 commitment,uint64 serviceId,uint8 jobIndex,uint256 amount,address operator,uint256 nonce,uint64 expiry)"
  )
);

const WITHDRAW_TYPEHASH = ethers.keccak256(
  ethers.toUtf8Bytes(
    "WithdrawCredits(bytes32 commitment,address recipient,uint256 amount,uint256 nonce)"
  )
);

const CREDITS_ABI = [
  "function fundCredits(address token, uint256 amount, bytes32 commitment, address spendingKey) external",
  "function authorizeSpend(tuple(bytes32 commitment, uint64 serviceId, uint8 jobIndex, uint256 amount, address operator, uint256 nonce, uint64 expiry, bytes signature) auth) external returns (bytes32)",
  "function claimPayment(bytes32 authHash, address recipient) external",
  "function withdrawCredits(bytes32 commitment, address recipient, uint256 amount, uint256 nonce, bytes signature) external",
  "function getAccount(bytes32 commitment) external view returns (tuple(address spendingKey, address token, uint256 balance, uint256 totalFunded, uint256 totalSpent, uint256 nonce))",
  "function getSpendAuth(bytes32 authHash) external view returns (uint256 amount, bool claimed)",
  "function DOMAIN_SEPARATOR() external view returns (bytes32)",
];

/// Ephemeral credit account keys
export interface CreditKeys {
  /// The ephemeral private key (keep secret!)
  spendingPrivateKey: string;
  /// The ephemeral public key (used on-chain)
  spendingPublicKey: string;
  /// Random salt for commitment derivation
  salt: string;
  /// The commitment: keccak256(spendingPubKey, salt)
  commitment: string;
}

/// Credit account state from on-chain
export interface CreditAccountState {
  spendingKey: string;
  token: string;
  balance: bigint;
  totalFunded: bigint;
  totalSpent: bigint;
  nonce: bigint;
}

/// A signed spend authorization ready to submit on-chain
export interface SignedSpendAuth {
  commitment: string;
  serviceId: bigint;
  jobIndex: number;
  amount: bigint;
  operator: string;
  nonce: bigint;
  expiry: bigint;
  signature: string;
}

/// Generate fresh credit account keys.
/// The user keeps the private key; the public key and commitment go on-chain.
export function generateCreditKeys(): CreditKeys {
  const wallet = ethers.Wallet.createRandom();
  const salt =
    "0x" + Buffer.from(randomBytes(32)).toString("hex");
  const commitment = ethers.keccak256(
    ethers.solidityPacked(
      ["address", "bytes32"],
      [wallet.address, salt]
    )
  );

  return {
    spendingPrivateKey: wallet.privateKey,
    spendingPublicKey: wallet.address,
    salt,
    commitment,
  };
}

/// Sign a spend authorization (off-chain, cheap).
/// This is what makes pay-per-job efficient — no ZK proof needed.
export async function signSpendAuthorization(params: {
  spendingPrivateKey: string;
  commitment: string;
  serviceId: bigint;
  jobIndex: number;
  amount: bigint;
  operator: string;
  nonce: bigint;
  expiry: bigint;
  domainSeparator: string;
}): Promise<SignedSpendAuth> {
  const {
    spendingPrivateKey,
    commitment,
    serviceId,
    jobIndex,
    amount,
    operator,
    nonce,
    expiry,
    domainSeparator,
  } = params;

  const structHash = ethers.keccak256(
    ethers.AbiCoder.defaultAbiCoder().encode(
      ["bytes32", "bytes32", "uint64", "uint8", "uint256", "address", "uint256", "uint64"],
      [SPEND_TYPEHASH, commitment, serviceId, jobIndex, amount, operator, nonce, expiry]
    )
  );

  const digest = ethers.keccak256(
    ethers.solidityPacked(
      ["string", "bytes32", "bytes32"],
      ["\x19\x01", domainSeparator, structHash]
    )
  );

  const wallet = new ethers.Wallet(spendingPrivateKey);
  const signature = wallet.signingKey.sign(digest);

  return {
    commitment,
    serviceId,
    jobIndex,
    amount,
    operator,
    nonce,
    expiry,
    signature: ethers.Signature.from(signature).serialized,
  };
}

/// Sign a withdrawal authorization (off-chain).
export async function signWithdrawal(params: {
  spendingPrivateKey: string;
  commitment: string;
  recipient: string;
  amount: bigint;
  nonce: bigint;
  domainSeparator: string;
}): Promise<string> {
  const { spendingPrivateKey, commitment, recipient, amount, nonce, domainSeparator } = params;

  const structHash = ethers.keccak256(
    ethers.AbiCoder.defaultAbiCoder().encode(
      ["bytes32", "bytes32", "address", "uint256", "uint256"],
      [WITHDRAW_TYPEHASH, commitment, recipient, amount, nonce]
    )
  );

  const digest = ethers.keccak256(
    ethers.solidityPacked(
      ["string", "bytes32", "bytes32"],
      ["\x19\x01", domainSeparator, structHash]
    )
  );

  const wallet = new ethers.Wallet(spendingPrivateKey);
  return ethers.Signature.from(wallet.signingKey.sign(digest)).serialized;
}

/// High-level client for interacting with ShieldedCredits.
export class ShieldedCreditsClient {
  private readonly contract: ethers.Contract;
  private _domainSeparator: string | null = null;

  constructor(
    creditsAddress: string,
    providerOrSigner: ethers.Provider | ethers.Signer
  ) {
    this.contract = new ethers.Contract(
      creditsAddress,
      CREDITS_ABI,
      providerOrSigner
    );
  }

  /// Get the EIP-712 domain separator (cached after first call)
  async getDomainSeparator(): Promise<string> {
    if (!this._domainSeparator) {
      this._domainSeparator = await this.contract.DOMAIN_SEPARATOR();
    }
    return this._domainSeparator!;
  }

  /// Get credit account state
  async getAccount(commitment: string): Promise<CreditAccountState> {
    const acct = await this.contract.getAccount(commitment);
    return {
      spendingKey: acct.spendingKey,
      token: acct.token,
      balance: acct.balance,
      totalFunded: acct.totalFunded,
      totalSpent: acct.totalSpent,
      nonce: acct.nonce,
    };
  }

  /// Sign and submit a spend authorization in one call
  async authorizeSpend(params: {
    spendingPrivateKey: string;
    commitment: string;
    serviceId: bigint;
    jobIndex: number;
    amount: bigint;
    operator: string;
    expirySeconds?: number;
  }): Promise<{ authHash: string; spendAuth: SignedSpendAuth }> {
    const domainSeparator = await this.getDomainSeparator();
    const acct = await this.getAccount(params.commitment);

    const expiry = BigInt(Math.floor(Date.now() / 1000) + (params.expirySeconds ?? 3600));

    const spendAuth = await signSpendAuthorization({
      spendingPrivateKey: params.spendingPrivateKey,
      commitment: params.commitment,
      serviceId: params.serviceId,
      jobIndex: params.jobIndex,
      amount: params.amount,
      operator: params.operator,
      nonce: acct.nonce,
      expiry,
      domainSeparator,
    });

    const tx = await this.contract.authorizeSpend(spendAuth);
    const receipt = await tx.wait();

    // Extract authHash from event
    const event = receipt.logs.find(
      (l: ethers.Log) => l.topics[0] === ethers.id("CreditsSpent(bytes32,bytes32,uint256,uint256)")
    );
    if (!event) throw new Error("CreditsSpent event not found in receipt");
    const authHash = event.topics[2];

    return { authHash, spendAuth };
  }

  /// Claim payment for a completed job
  async claimPayment(authHash: string, recipient: string): Promise<ethers.TransactionReceipt> {
    const tx = await this.contract.claimPayment(authHash, recipient);
    return tx.wait();
  }

  /// Withdraw remaining credits
  async withdraw(params: {
    spendingPrivateKey: string;
    commitment: string;
    recipient: string;
    amount: bigint;
  }): Promise<ethers.TransactionReceipt> {
    const domainSeparator = await this.getDomainSeparator();
    const acct = await this.getAccount(params.commitment);

    const signature = await signWithdrawal({
      spendingPrivateKey: params.spendingPrivateKey,
      commitment: params.commitment,
      recipient: params.recipient,
      amount: params.amount,
      nonce: acct.nonce,
      domainSeparator,
    });

    const tx = await this.contract.withdrawCredits(
      params.commitment,
      params.recipient,
      params.amount,
      acct.nonce,
      signature
    );
    return tx.wait();
  }
}
