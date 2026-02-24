#!/usr/bin/env python3
"""Sync TNT release/version references across sibling repos.

Default mode is dry-run (prints unified diffs). Use --write to apply changes.
"""

from __future__ import annotations

import argparse
import difflib
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Pattern


SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$")


@dataclass
class RegexReplace:
    pattern: Pattern[str]
    repl: str


def _require_semver(label: str, value: str) -> None:
    if not SEMVER_RE.match(value):
        raise ValueError(f"{label} must be semver-like, got: {value!r}")


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _render_diff(path: Path, before: str, after: str) -> str:
    return "".join(
        difflib.unified_diff(
            before.splitlines(keepends=True),
            after.splitlines(keepends=True),
            fromfile=str(path),
            tofile=str(path),
        )
    )


def _apply_replacements(content: str, replacements: Iterable[RegexReplace]) -> tuple[str, int]:
    updated = content
    total = 0
    for item in replacements:
        updated, count = item.pattern.subn(item.repl, updated)
        total += count
    return updated, total


def main() -> int:
    parser = argparse.ArgumentParser(description="Sync TNT release references across repos.")
    parser.add_argument("--core-version", required=True, help="tnt-core Soldeer version (e.g. 0.10.4)")
    parser.add_argument(
        "--bindings-version",
        default=None,
        help="tnt-core-bindings crate version (defaults to --core-version)",
    )
    parser.add_argument(
        "--workspace-root",
        default=None,
        help="Workspace root containing tnt-core/docs/blueprint/blueprint-template (default: parent of current repo)",
    )
    parser.add_argument("--write", action="store_true", help="Apply changes (default is dry-run)")
    args = parser.parse_args()

    core_version = args.core_version
    bindings_version = args.bindings_version or core_version
    _require_semver("core version", core_version)
    _require_semver("bindings version", bindings_version)

    this_script = Path(__file__).resolve()
    tnt_core = this_script.parents[1]
    workspace_root = Path(args.workspace_root).resolve() if args.workspace_root else tnt_core.parent
    docs = workspace_root / "docs"
    blueprint = workspace_root / "blueprint"
    blueprint_template = workspace_root / "blueprint-template"

    required = [tnt_core, docs, blueprint, blueprint_template]
    missing = [str(p) for p in required if not p.exists()]
    if missing:
        print("Missing required paths:")
        for item in missing:
            print(f"  - {item}")
        return 2

    plan: dict[Path, list[RegexReplace]] = {}

    # tnt-core README install snippets
    plan[tnt_core / "README.md"] = [
        RegexReplace(
            re.compile(r"forge soldeer install tnt-core~\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?"),
            f"forge soldeer install tnt-core~{core_version}",
        ),
        RegexReplace(
            re.compile(r'(?m)^tnt-core = "\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?"$'),
            f'tnt-core = "{core_version}"',
        ),
    ]

    # blueprint workspace dependency
    plan[blueprint / "Cargo.toml"] = [
        RegexReplace(
            re.compile(r'(?m)^tnt-core-bindings = "\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?"$'),
            f'tnt-core-bindings = "{bindings_version}"',
        )
    ]

    # any foundry.toml in blueprint + blueprint-template that references tnt-core
    foundry_files = [blueprint_template / "foundry.toml", *blueprint.rglob("foundry.toml")]
    for file_path in foundry_files:
        if not file_path.exists():
            continue
        plan[file_path] = [
            RegexReplace(
                re.compile(r'(?m)^(tnt-core\s*=\s*")\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?(")$'),
                rf'\g<1>{core_version}\2',
            ),
            RegexReplace(
                re.compile(r"dependencies/tnt-core-\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?/src/"),
                f"dependencies/tnt-core-{core_version}/src/",
            ),
        ]

    changed = 0
    touched_files: list[Path] = []
    total_replacements = 0

    for file_path, replacements in sorted(plan.items(), key=lambda x: str(x[0])):
        if not file_path.exists():
            continue
        before = _read_text(file_path)
        after, replacement_count = _apply_replacements(before, replacements)
        if replacement_count == 0 or before == after:
            continue

        changed += 1
        total_replacements += replacement_count
        touched_files.append(file_path)
        diff = _render_diff(file_path, before, after)
        if diff:
            print(diff)

        if args.write:
            file_path.write_text(after, encoding="utf-8")

    mode = "APPLIED" if args.write else "DRY-RUN"
    print(f"[{mode}] files_changed={changed} replacements={total_replacements}")
    for path in touched_files:
        print(f"  - {path}")

    if changed == 0:
        print("No version references needed updates.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except ValueError as err:
        print(f"error: {err}")
        sys.exit(2)
