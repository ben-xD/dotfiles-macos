#!/usr/bin/env python3
"""Claude Code statusline with powerline style, git status, and API usage stats."""

import json
import os
import platform
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

# ANSI escape helpers
RESET = "\033[0m"
BOLD = "\033[1m"
BLINK = "\033[5m"
FG_BLACK = "\033[30m"
FG_WHITE = "\033[97m"
FG_BLUE = "\033[34m"
FG_GREEN = "\033[32m"
FG_YELLOW = "\033[33m"
FG_RED = "\033[31m"
FG_CYAN = "\033[36m"
FG_MAGENTA = "\033[35m"
BG_BLUE = "\033[44m"
BG_GREEN = "\033[42m"
BG_YELLOW = "\033[43m"
BG_CYAN = "\033[46m"
BG_RED = "\033[41m"
BG_MAGENTA = "\033[45m"
FG_LTBLUE = "\033[38;5;75m"
BG_LTBLUE = "\033[48;5;75m"
FG_ORANGE = "\033[38;5;208m"
BG_DARK = "\033[48;5;236m"
FG_DARK = "\033[38;5;236m"
FG_GRAY = "\033[38;5;240m"

SEP = "\ue0b0"  # Powerline separator

USAGE_API_URL = "https://api.anthropic.com/api/oauth/usage"
USAGE_CACHE_PATH = Path.home() / ".claude" / ".statusline_usage_cache.json"
USAGE_CACHE_TTL = 60  # seconds between API calls


def main():
    try:
        raw = sys.stdin.read()
        data = json.loads(raw)
    except Exception:
        print("\u26a0 invalid input")
        return

    cwd = data.get("workspace", {}).get("current_dir", "")
    dir_name = os.path.basename(cwd) if cwd else "?"

    # Extract model name
    model_raw = data.get("model", "claude")
    if isinstance(model_raw, dict):
        model = model_raw.get("id") or model_raw.get("name") or "claude"
    elif isinstance(model_raw, str):
        model = model_raw
    else:
        model = "claude"
    # Clean up: remove claude- prefix and date suffix, truncate
    model = model.replace("claude-", "")
    import re
    model = re.sub(r"-\d+$", "", model)[:10]

    # Git info
    git_segment, model_bg, model_fg, next_fg = get_git_segment(cwd)

    # Context window segment
    context_segment, next_fg = get_context_segment(data, next_fg)

    # Usage API segment (5h / 7d)
    usage_segment = get_usage_segment()

    # Date/time
    from datetime import datetime
    dt = datetime.now().strftime("%Y/%m/%d %H:%M")

    # Build output
    out = []
    out.append(f"{model_bg}{FG_BLACK}{BOLD} {model} {RESET}")
    out.append(f"{model_fg}{BG_BLUE}{SEP}{FG_BLACK}  {dir_name} {RESET}")
    out.append(git_segment)
    out.append(context_segment)
    out.append(usage_segment)
    out.append(f"{next_fg}{RESET}{SEP} {dt}")

    print("".join(out), end="")


def get_git_segment(cwd: str) -> tuple[str, str, str, str]:
    """Return (git_segment, model_bg, model_fg, next_fg)."""
    model_bg = BG_GREEN
    model_fg = FG_GREEN

    try:
        subprocess.run(
            ["git", "-C", cwd, "rev-parse", "--git-dir"],
            capture_output=True, timeout=2, check=True,
        )
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError):
        return ("", model_bg, model_fg, FG_BLUE)

    # Branch
    try:
        r = subprocess.run(
            ["git", "-C", cwd, "branch", "--show-current"],
            capture_output=True, text=True, timeout=2,
        )
        branch = r.stdout.strip()
    except Exception:
        branch = ""
    if not branch:
        try:
            r = subprocess.run(
                ["git", "-C", cwd, "rev-parse", "--short", "HEAD"],
                capture_output=True, text=True, timeout=2,
            )
            branch = r.stdout.strip()
        except Exception:
            branch = "?"

    # Status counts
    try:
        r = subprocess.run(
            ["git", "-C", cwd, "status", "--porcelain"],
            capture_output=True, text=True, timeout=2,
        )
        lines = [l for l in r.stdout.splitlines() if l]
        staged = sum(1 for l in lines if len(l) >= 1 and l[0] in "MADRC")
        modified = sum(1 for l in lines if len(l) >= 2 and l[1] in "MD")
    except Exception:
        staged = modified = 0

    # Ahead/behind
    try:
        r = subprocess.run(
            ["git", "-C", cwd, "rev-list", "--count", "@{u}..HEAD"],
            capture_output=True, text=True, timeout=2,
        )
        ahead = int(r.stdout.strip()) if r.returncode == 0 else 0
    except Exception:
        ahead = 0
    try:
        r = subprocess.run(
            ["git", "-C", cwd, "rev-list", "--count", "HEAD..@{u}"],
            capture_output=True, text=True, timeout=2,
        )
        behind = int(r.stdout.strip()) if r.returncode == 0 else 0
    except Exception:
        behind = 0

    # Build status string
    git_status = ""
    if ahead > 0:
        git_status += f"\u21e1{ahead}"
    if behind > 0:
        git_status += f"\u21e3{behind}"
    if staged > 0:
        git_status += f"+{staged}"
    if modified > 0:
        git_status += f"!{modified}"

    if git_status:
        model_bg = BG_YELLOW
        model_fg = FG_YELLOW
        content = f" {branch} {git_status} "
    else:
        model_bg = BG_GREEN
        model_fg = FG_GREEN
        content = f" {branch} "

    segment = f"{FG_BLUE}{BG_LTBLUE}{SEP}{FG_BLACK}{content}"
    next_fg = FG_LTBLUE
    return (segment, model_bg, model_fg, next_fg)


def get_context_segment(data: dict, next_fg: str) -> tuple[str, str]:
    """Return (context_segment, next_fg)."""
    ctx = data.get("context_window", {})
    used_pct = ctx.get("used_percentage")

    if used_pct is None:
        segment = f"{next_fg}{BG_DARK}{SEP}{FG_WHITE} --% {RESET}"
        return (segment, FG_DARK)

    pct = int(round(used_pct))
    bar_width = 8
    filled = min(pct * bar_width // 100, bar_width)
    empty = bar_width - filled

    if pct > 95:
        fill_color = "\033[38;5;196m"
        blink = BLINK
    elif pct > 85:
        fill_color = "\033[38;5;208m"
        blink = ""
    elif pct > 70:
        fill_color = "\033[38;5;220m"
        blink = ""
    else:
        fill_color = "\033[38;5;29m"
        blink = ""

    bar = f"{blink}{fill_color}{'█' * filled}{RESET}{BG_DARK}{FG_GRAY}{'░' * empty}"

    # Session token totals
    total_in = ctx.get("total_input_tokens", 0) or 0
    total_out = ctx.get("total_output_tokens", 0) or 0
    tok_label = f"↑{fmt_tokens(total_in)} ↓{fmt_tokens(total_out)}"

    segment = f"{next_fg}{BG_DARK}{SEP}{bar}{FG_WHITE} {pct}% {FG_CYAN}{tok_label} {RESET}"
    return (segment, FG_DARK)


def fmt_tokens(n: int) -> str:
    if n >= 1_000_000:
        return f"{n // 1_000_000}M"
    elif n >= 1_000:
        return f"{n // 1_000}k"
    return str(n)


def get_usage_segment() -> str:
    """Fetch and format the 5h/7d API usage with caching."""
    usage = get_cached_usage()
    if usage is None:
        return ""

    five_h = usage.get("five_hour", {})
    seven_d = usage.get("seven_day", {})

    five_pct = five_h.get("utilization") or 0
    seven_pct = seven_d.get("utilization") or 0

    five_str = f"{usage_color(five_pct)}{five_pct:.0f}%{RESET}"
    seven_str = f"{usage_color(seven_pct)}{seven_pct:.0f}%{RESET}"

    return f" 5h:{five_str} 7d:{seven_str} "


def usage_color(pct: float) -> str:
    if pct >= 80:
        return FG_RED
    elif pct >= 50:
        return FG_YELLOW
    return FG_GREEN


def get_cached_usage() -> dict | None:
    """Return usage data, using cache if fresh enough."""
    # Check cache
    try:
        if USAGE_CACHE_PATH.exists():
            cache = json.loads(USAGE_CACHE_PATH.read_text())
            if time.time() - cache.get("ts", 0) < USAGE_CACHE_TTL:
                return cache.get("data")
    except Exception:
        pass

    # Fetch fresh
    token = get_access_token()
    if not token:
        return None

    usage = fetch_usage(token)
    if usage is None:
        return None

    # Write cache
    try:
        USAGE_CACHE_PATH.write_text(json.dumps({"ts": time.time(), "data": usage}))
    except Exception:
        pass

    return usage


def get_access_token() -> str | None:
    system = platform.system()
    if system == "Darwin":
        return get_access_token_macos()
    elif system == "Linux":
        return get_access_token_linux()
    return None


def get_access_token_macos() -> str | None:
    try:
        result = subprocess.run(
            ["security", "find-generic-password", "-s", "Claude Code-credentials", "-w"],
            capture_output=True, text=True, timeout=2, check=True,
        )
        creds = json.loads(result.stdout.strip())
        return creds.get("claudeAiOauth", {}).get("accessToken")
    except Exception:
        return None


def get_access_token_linux() -> str | None:
    try:
        creds_path = Path.home() / ".claude" / ".credentials.json"
        creds = json.loads(creds_path.read_text())
        return creds.get("claudeAiOauth", {}).get("accessToken")
    except Exception:
        return None


def fetch_usage(access_token: str) -> dict | None:
    try:
        req = urllib.request.Request(
            USAGE_API_URL,
            headers={
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json",
                "anthropic-beta": "oauth-2025-04-20",
            },
        )
        with urllib.request.urlopen(req, timeout=5) as resp:
            return json.loads(resp.read().decode())
    except Exception:
        return None


if __name__ == "__main__":
    main()
