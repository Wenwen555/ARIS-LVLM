#!/usr/bin/env python3
"""Install Anthropic official document-skills into Claude Code."""

from __future__ import annotations

import platform
import shutil
import subprocess
import sys


def find_claude() -> str | None:
    candidates = ["claude.cmd", "claude"] if platform.system() == "Windows" else ["claude", "claude.cmd"]
    for name in candidates:
        path = shutil.which(name)
        if path:
            return path
    return None


def run(cmd: list[str], check: bool = True) -> subprocess.CompletedProcess[str]:
    print("+", " ".join(cmd))
    return subprocess.run(
        cmd,
        text=True,
        encoding="utf-8",
        errors="replace",
        capture_output=True,
        check=check,
    )


def main() -> int:
    claude = find_claude()
    if not claude:
        print("Claude CLI not found in PATH. Install Claude Code first.", file=sys.stderr)
        return 1

    marketplace_cmd = [claude, "plugin", "marketplace", "add", "anthropics/skills"]
    install_cmd = [claude, "plugin", "install", "document-skills@anthropic-agent-skills"]
    list_cmd = [claude, "plugin", "list"]

    marketplace = run(marketplace_cmd, check=False)
    if marketplace.returncode != 0:
        stderr = marketplace.stderr.strip()
        if "already" not in stderr.lower() and "already" not in marketplace.stdout.lower():
            print(marketplace.stdout)
            print(stderr, file=sys.stderr)
            return marketplace.returncode

    install = run(install_cmd, check=False)
    if install.returncode != 0:
        stderr = install.stderr.strip()
        stdout = install.stdout.strip()
        if "already installed" not in stderr.lower() and "already installed" not in stdout.lower():
            print(stdout)
            print(stderr, file=sys.stderr)
            return install.returncode

    listed = run(list_cmd, check=False)
    print(listed.stdout.strip())
    if listed.stderr.strip():
        print(listed.stderr.strip(), file=sys.stderr)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
