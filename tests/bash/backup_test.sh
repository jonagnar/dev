#!/usr/bin/env bash
# tests/bash/backup_test.sh — mirrors tests/backup.Tests.ps1
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SELF_DIR/helpers.sh"
source "$SELF_DIR/../../scripts/backup.sh"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# stub repo discovery + recipients so we never touch the real system
get_dev_repos()        { printf '%s\n%s\n' "$WORK/meta" "$WORK/ops/demo-api"; }
get_backup_recipients(){ printf 'age1fakeRecipient\n'; }
install_run_native_mock

# Case 1: dry-run runs zero native commands
DRY_RUN=1; ASSUME_YES=0
reset_native_calls
invoke_backup --backup-dir "$WORK/backups" >/dev/null 2>&1
assert_eq "0" "${#NATIVE_CALLS[@]}" "dry-run runs zero run_native calls"

# Case 2: --yes bundles each repo and age-encrypts
DRY_RUN=0; ASSUME_YES=1
reset_native_calls
invoke_backup --backup-dir "$WORK/backups" >/dev/null 2>&1
assert_true "$(( $(native_calls_matching 'git') > 0 ? 0 : 1 ))" "calls git"
assert_true "$(( $(native_calls_matching 'bundle') > 0 ? 0 : 1 ))" "calls git bundle"
assert_true "$(( $(native_calls_matching 'age -r') > 0 ? 0 : 1 ))" "calls age -r (encrypt)"

# get_dev_repos: real discovery finds meta-repo + ops/* with .git, not bare dirs
unset -f get_dev_repos
source "$SELF_DIR/../../scripts/backup.sh"   # reload real get_dev_repos
mkdir -p "$WORK/root/.git" "$WORK/root/ops/proj-a/.git" "$WORK/root/ops/not-a-repo"
repos="$(get_dev_repos "$WORK/root")"
assert_contains "$repos" "$WORK/root" "discovers meta-repo"
assert_contains "$repos" "proj-a" "discovers ops/proj-a (has .git)"
assert_not_contains "$repos" "not-a-repo" "skips ops/not-a-repo (no .git)"

# get_backup_recipients: parses age: line from a .sops.yaml
mkdir -p "$WORK/root/.config/sops"
cat > "$WORK/root/.config/sops/.sops.yaml" <<'YAML'
creation_rules:
  - path_regex: \.env\.sops$
    age: "age1aaa,age1bbb"
YAML
recips="$(get_backup_recipients "$WORK/root")"
assert_contains "$recips" "age1aaa" "parses first recipient"
assert_contains "$recips" "age1bbb" "parses second recipient"

echo "backup_test: $((TESTS_RUN - TESTS_FAILED))/$TESTS_RUN passed"
exit "$TESTS_FAILED"
