#!/usr/bin/env bash
# Check upstream components against the pinned versions in this repo.
# Emits a GitHub Actions step summary and, when updates exist, a markdown
# report the workflow can post as an issue.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

get_var() { # $1=file $2=varname  (handles VAR="x", VAR=x and VAR:=x)
    grep -oP "^[[:space:]]*(export[[:space:]]+)?$2[+:]?=\"?\K[^\"]+" "$1" | head -1
}

OPENWRT_SHA="$(get_var "$ROOT/build.sh" OPENWRT_SHA)"
PR_SHA="$(get_var "$ROOT/build.sh" PR_21495_SHA)"
BDF_COMMIT="$(get_var "$ROOT/build.sh" BDF_COMMIT)"
DAE_VERSION="$(get_var "$ROOT/packages/dae/Makefile" PKG_VERSION)"

api() { curl -sL --retry 3 "https://api.github.com$1"; }

MAIN_HEAD="$(api /repos/openwrt/openwrt/commits/main | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])')"
PR_HEAD="$(api /repos/openwrt/openwrt/pulls/21495 | python3 -c 'import json,sys; print(json.load(sys.stdin)["head"]["sha"])')"
BDF_HEAD="$(api /repos/openwrt/firmware_qca-wireless/commits/main | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"])')"
DAE_LATEST="$(api /repos/daeuniverse/dae/releases/latest | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')"
DAE_LATEST="${DAE_LATEST#v}"

summary=""
add() { # $1=title $2=current $3=latest $4=detail
    if [ "$2" != "$3" ]; then
        summary+="| $1 | \`$2\` | \`$3\` | $4 |\n"
    fi
}

add "OpenWrt pin" "${OPENWRT_SHA:0:12}" "${MAIN_HEAD:0:12}" "[main HEAD](https://github.com/openwrt/openwrt/commit/$MAIN_HEAD)"
add "PR #21495 (ath11k-smallbuffers)" "${PR_SHA:0:12}" "${PR_HEAD:0:12}" "[PR head](https://github.com/openwrt/openwrt/pull/21495)"
add "PZ-L8 BDF (firmware_qca-wireless)" "${BDF_COMMIT:0:12}" "${BDF_HEAD:0:12}" "[repo HEAD](https://github.com/openwrt/firmware_qca-wireless)"
add "dae" "$DAE_VERSION" "$DAE_LATEST" "[releases](https://github.com/daeuniverse/dae/releases)"

body="## Upstream update check — $(date -u +%Y-%m-%d)"
if [ -n "$summary" ]; then
    body+="
| Component | Pinned | Available | Link |
|---|---|---|---|
$(printf "$summary")"
else
    body+="
Everything is up to date."
fi

echo "$body"
[ -n "${GITHUB_STEP_SUMMARY:-}" ] && echo "$body" >> "$GITHUB_STEP_SUMMARY"

if [ -n "$summary" ]; then
    printf "$summary" > "${1:-/tmp/upstream-updates.md}"
    exit 10   # updates available
fi
exit 0
