export const toPointsValue = (amount: bigint): bigint => {
  if (amount <= 0n) {
    return 0n;
  }
  const scaled = amount / 10_000_000_000_000_000n; // 1e16
  return scaled > 0n ? scaled : 1n;
};
