#!/usr/bin/env python3
"""Reconcile the live genesis distribution to exactly 100,000,000 TNT.

Fails (exit 1) unless:
  - normalized-100m.json buckets sum to exactly MAX_SUPPLY (100M * 1e18), and
  - treasury == MAX_SUPPLY - (substrate + evm + foundation) (treasury is the balancer), and
  - the active claimant buckets match the source files in packages/migration-claim/
    (substrate == merkle-tree.json .totalValue, evm == evm-claims.json .totalAmount,
     foundation == foundation-carveout.json .amount).

The expired set (unclaimed-accounts.json) is intentionally NOT allocated and is not
included in any bucket. Run after any snapshot regen; wire into CI so the numbers
cannot drift from 100M.
"""
import json
import os
import sys

MAX_SUPPLY = 100_000_000 * 10**18

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
MC = os.path.join(REPO, "packages", "migration-claim")


def load(path):
    with open(path) as f:
        return json.load(f)


def amount(d, *keys):
    for k in keys:
        if k in d and d[k] not in (None, ""):
            return int(d[k])
    raise KeyError(f"none of {keys} in {list(d)}")


def main():
    errors = []
    dist = load(os.path.join(HERE, "normalized-100m.json"))
    b = dist["buckets"]
    substrate = int(b["substrate"]["wei"])
    evm = int(b["evm"]["wei"])
    foundation = int(b["foundation"]["wei"])
    treasury = int(b["treasury"]["wei"])

    total = substrate + evm + foundation + treasury
    if total != MAX_SUPPLY:
        errors.append(f"buckets sum {total} != MAX_SUPPLY {MAX_SUPPLY} (off by {total - MAX_SUPPLY})")

    expected_treasury = MAX_SUPPLY - (substrate + evm + foundation)
    if treasury != expected_treasury:
        errors.append(f"treasury {treasury} != 100M - claims {expected_treasury} (treasury must be the balancer)")

    # Cross-check active claimant buckets against the source outputs, when present.
    merkle = os.path.join(MC, "merkle-tree.json")
    if os.path.exists(merkle):
        src = amount(load(merkle), "totalValue")
        if src != substrate:
            errors.append(f"substrate {substrate} != merkle-tree.json totalValue {src}")
    evm_file = os.path.join(MC, "evm-claims.json")
    if os.path.exists(evm_file):
        src = amount(load(evm_file), "totalAmount", "total")
        if src != evm:
            errors.append(f"evm {evm} != evm-claims.json totalAmount {src}")
    fnd_file = os.path.join(MC, "foundation-carveout.json")
    if os.path.exists(fnd_file):
        src = amount(load(fnd_file), "amount", "total")
        if src != foundation:
            errors.append(f"foundation {foundation} != foundation-carveout.json amount {src}")

    if errors:
        print("RECONCILE FAILED:")
        for e in errors:
            print("  -", e)
        return 1

    print("RECONCILE OK: substrate + evm + foundation + treasury == 100,000,000 TNT")
    print(f"  substrate  {substrate/10**18:>18,.6f}")
    print(f"  evm        {evm/10**18:>18,.6f}")
    print(f"  foundation {foundation/10**18:>18,.6f}")
    print(f"  treasury   {treasury/10**18:>18,.6f}  (= 100M - claims)")
    print(f"  total      {total/10**18:>18,.6f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
