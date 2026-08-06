#!/usr/bin/env bash
# gen-wg-keys.sh — idempotent WG key management for users.nix v4.
# Two-pass v3→v4 rename (values preserved) + generate 84 missing peers.
# Run from repo root. Requires: sops 3.13.3+, wg, jq, nix.
# Public-safe: stages plaintext keys ONLY in a 0700 tmpfs dir with trap-cleanup.
set -euo pipefail

cd "$(dirname "$0")/.."
export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
SECRETS="secrets/secrets.yaml"
PUBKEYS="wireguard-pubkeys.nix"

echo "=== gen-wg-keys.sh ==="
echo "Secrets file: $SECRETS"
echo "SOPS_AGE_KEY_FILE: $SOPS_AGE_KEY_FILE"

# ── Gate: sops access works ──
if ! sops decrypt --extract '["wireguard_server_private"]' "$SECRETS" >/dev/null 2>&1; then
  echo "FATAL: cannot decrypt secrets/secrets.yaml — check SOPS_AGE_KEY_FILE" >&2
  exit 1
fi

# ── Get 97 peer names from users.nix ──
echo -n "Resolving peer names from users.nix ... "
PEER_NAMES=$(nix eval --impure --raw --expr \
  'builtins.concatStringsSep "\n" (import ./users.nix).wgPeerNames' 2>/dev/null)
PEER_COUNT=$(echo "$PEER_NAMES" | grep -c .)
echo "$PEER_COUNT names"

if [ "$PEER_COUNT" -ne 97 ]; then
  echo "FATAL: expected 97 peer names, got $PEER_COUNT" >&2
  exit 1
fi

# ── Create staging tempdir (0700, cleaned on exit) ──
STAGEDIR=$(mktemp -d)
chmod 0700 "$STAGEDIR"
trap 'rm -rf "$STAGEDIR"' EXIT

# ═══════════════════════════════════════════════════════════
# Pass 1: v3→v4 rename (two-pass, order-independent)
# ═══════════════════════════════════════════════════════════

# Rename table: old_v3 → new_v4 (12 pairs; admin3-vpn unchanged)
declare -A RENAME=(
  ["dumitru1-vpn"]="dumitru-vpn"
  ["adela1-vpn"]="adela-vpn"
  ["adela2-vpn"]="adela1-vpn"
  ["adela3-vpn"]="adela2-vpn"
  ["tiberiu1-vpn"]="tiberiu-vpn"
  ["david1-vpn"]="david-vpn"
  ["david2-vpn"]="david1-vpn"
  ["ramona1-vpn"]="ramona-vpn"
  ["tibisor1-vpn"]="tibisor-vpn"
  ["iza1-vpn"]="iza-vpn"
  ["kerem1-vpn"]="kerem-vpn"
  ["hannah1-vpn"]="hannah-vpn"
)

echo ""
echo "--- Pass 1: v3→v4 rename (12 pairs) ---"

RENAMED=0
for SUFFIX in private psk; do
  for OLD in "${!RENAME[@]}"; do
    NEW="${RENAME[$OLD]}"
    OLD_KEY="wireguard_peer_${OLD}_${SUFFIX}"
    NEW_KEY="wireguard_peer_${NEW}_${SUFFIX}"

    # Check if old key exists
    if ! sops decrypt --extract "[\"${OLD_KEY}\"]" "$SECRETS" >/dev/null 2>&1; then
      continue  # already moved
    fi

    # Check if new key already exists
    if sops decrypt --extract "[\"${NEW_KEY}\"]" "$SECRETS" >/dev/null 2>&1; then
      echo "  [skip] ${NEW_KEY} already exists — removing old ${OLD_KEY}"
      sops unset "$SECRETS" "[\"${OLD_KEY}\"]" >/dev/null 2>&1 || true
      continue
    fi

    # Stage: extract old value to temp file (named by NEW key)
    STAGE_FILE="${STAGEDIR}/${NEW_KEY}"
    OLD_VALUE=$(sops decrypt --extract "[\"${OLD_KEY}\"]" "$SECRETS")
    printf '%s' "$OLD_VALUE" > "$STAGE_FILE"

    echo "  [stage] ${OLD_KEY} → ${NEW_KEY}"
    RENAMED=$((RENAMED + 1))
  done
done

# Pass 1b: write staged values to sops
if [ "$RENAMED" -gt 0 ]; then
  echo "  Writing ${RENAMED} staged values ..."
  for STAGE_FILE in "$STAGEDIR"/wireguard_peer_*; do
    [ -f "$STAGE_FILE" ] || continue
    NEW_KEY=$(basename "$STAGE_FILE")
    VAL=$(cat "$STAGE_FILE")
    JSON_VAL=$(printf '%s' "$VAL" | jq -Rs .)
    echo "    set ${NEW_KEY}"
    sops set "$SECRETS" "[\"${NEW_KEY}\"]" "$JSON_VAL" >/dev/null 2>&1
  done

  # Pass 1c: unset old keys
  echo "  Removing old keys ..."
  for OLD in "${!RENAME[@]}"; do
    for SUFFIX in private psk; do
      OLD_KEY="wireguard_peer_${OLD}_${SUFFIX}"
      if sops decrypt --extract "[\"${OLD_KEY}\"]" "$SECRETS" >/dev/null 2>&1; then
        echo "    unset ${OLD_KEY}"
        sops unset "$SECRETS" "[\"${OLD_KEY}\"]" >/dev/null 2>&1 || true
      fi
    done
  done
else
  echo "  No renames needed (all already migrated)"
fi

# ═══════════════════════════════════════════════════════════
# Pass 2: generate missing keys (84 peers × 2 = 168 keys)
# ═══════════════════════════════════════════════════════════
echo ""
echo "--- Pass 2: generate missing keys ---"

GENERATED=0
SKIPPED=0
while IFS= read -r PEER; do
  [ -z "$PEER" ] && continue
  for SUFFIX in private psk; do
    KEY_NAME="wireguard_peer_${PEER}_${SUFFIX}"

    # Check if already exists with real content
    if sops decrypt --extract "[\"${KEY_NAME}\"]" "$SECRETS" >/dev/null 2>&1; then
      VAL=$(sops decrypt --extract "[\"${KEY_NAME}\"]" "$SECRETS")
      if [ -n "$VAL" ] && [ "$VAL" != "PLACEHOLDER" ]; then
        SKIPPED=$((SKIPPED + 1))
        continue
      fi
    fi

    # Generate
    if [ "$SUFFIX" = "private" ]; then
      GEN_VAL=$(wg genkey)
    else
      GEN_VAL=$(wg genpsk)
    fi

    JSON_VAL=$(printf '%s' "$GEN_VAL" | jq -Rs .)
    sops set "$SECRETS" "[\"${KEY_NAME}\"]" "$JSON_VAL" >/dev/null 2>&1
    GENERATED=$((GENERATED + 1))
    echo "    generated ${KEY_NAME}"
  done
done <<< "$PEER_NAMES"

echo "  Generated: $GENERATED  Skipped: $SKIPPED"

# ═══════════════════════════════════════════════════════════
# Pass 3: derive public keys → wireguard-pubkeys.nix
# ═══════════════════════════════════════════════════════════
echo ""
echo "--- Pass 3: derive public keys → ${PUBKEYS} ---"

PUBKEY_COUNT=0
TMPFILE="${STAGEDIR}/pubkeys.tmp"

cat > "$TMPFILE" <<'HEADER'
# GENERATED by scripts/gen-wg-keys.sh — do not hand-edit.
# Public keys are not secret; this file is committed.
# 97 entries, one per WG peer (hostname → public key).
# hostname = peer name minus "-vpn" suffix.
{
HEADER

while IFS= read -r PEER; do
  [ -z "$PEER" ] && continue
  KEY_NAME="wireguard_peer_${PEER}_private"

  # Get private key (sops returns the decrypted value)
  PRIV_VAL=$(sops decrypt --extract "[\"${KEY_NAME}\"]" "$SECRETS" 2>/dev/null || echo "")
  if [ -z "$PRIV_VAL" ] || [ "$PRIV_VAL" = "PLACEHOLDER" ]; then
    echo "  WARNING: no private key for ${PEER} — skipping pubkey derivation" >&2
    continue
  fi

  # Derive public key
  PUBKEY=$(wg pubkey <<< "$PRIV_VAL")
  HOSTNAME="${PEER%-vpn}"   # strip -vpn suffix

  echo "  ${HOSTNAME} = \"${PUBKEY}\";" >> "$TMPFILE"
  PUBKEY_COUNT=$((PUBKEY_COUNT + 1))
done <<< "$PEER_NAMES"

echo "}" >> "$TMPFILE"

# Atomic write
mv "$TMPFILE" "$PUBKEYS"
echo "  Wrote ${PUBKEY_COUNT} public keys to ${PUBKEYS}"

# ═══════════════════════════════════════════════════════════
# Final self-checks
# ═══════════════════════════════════════════════════════════
echo ""
echo "=== Self-checks ==="
WG_KEY_COUNT=$(sops decrypt "$SECRETS" 2>/dev/null | grep -c '^wireguard_peer_' || echo 0)
echo "  WG keys in sops: ${WG_KEY_COUNT} (expected 194)"
echo "  Pubkeys in file: ${PUBKEY_COUNT} (expected 97)"
echo "  Renames: ${RENAMED}"
echo "  Generated: ${GENERATED}"
echo "  Skipped: ${SKIPPED}"
echo "=== Done ==="
