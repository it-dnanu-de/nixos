# WireGuard — declarative remote-access VPN (OpenCode.md §3.3, 2026-08-05).
# Replaces Tailscale SaaS. Kernel WireGuard, fully declarative peers,
# split-tunnel only (no exit node/NAT). One silent UDP port 51820.
#
# Peer data lives in settings.nix (public keys + IPs).
# Private keys and PSKs are in sops (secrets.yaml). The activation oneshot
# renders per-peer .conf + QR PNGs + index.html → profile.nanulab.de/wg/
# behind basic auth.
{
  config,
  lib,
  pkgs,
  settings,
  ...
}:
let
  inherit (lib) concatMap;
  peers = settings.network.wireguard.peers;

  # Build sops secret entries for every peer
  peerSecretAttrs = concatMap (p: [
    { name = "wireguard_peer_${p.name}_private"; value = { }; }
    { name = "wireguard_peer_${p.name}_psk"; value = { }; }
  ]) peers;

  # Bash fragment that renders one peer. Called inside the oneshot script.
  renderPeerBlock = p: ''
    echo "  -> peer ${p.name} (${p.ip})" >&2
    priv="/run/secrets/wireguard_peer_${p.name}_private"
    psk="/run/secrets/wireguard_peer_${p.name}_psk"

    peer_missing=""
    [ ! -f "$priv" ] && peer_missing="$peer_missing wireguard_peer_${p.name}_private"
    [ ! -f "$psk" ]  && peer_missing="$peer_missing wireguard_peer_${p.name}_psk"

    if [ -n "$peer_missing" ]; then
      echo "    WARNING: skipping — missing secrets:$peer_missing" >&2
      MISSING="$MISSING ${p.name}"
      continue
    fi

    conf="$OUT/${p.name}.conf"
    cat > "$conf" <<PEERCONF
[Interface]
PrivateKey = $(cat "$priv")
Address    = ${p.ip}/32
DNS        = 10.0.0.2

[Peer]
PublicKey           = $SERVER_PUB
PresharedKey        = $(cat "$psk")
AllowedIPs          = 10.0.0.0/24
Endpoint            = $ENDPOINT
PersistentKeepalive = 25
PEERCONF

    ${pkgs.qrencode}/bin/qrencode -t PNG -o "$OUT/${p.name}.png" < "$conf"

    cat >> "$INDEX" <<PEERROW
    <tr><td>${p.name}</td><td><a href="${p.name}.conf">${p.name}.conf</a></td><td><img src="${p.name}.png" alt="QR for ${p.name}" width="200"></td></tr>
PEERROW
  '';
in
{
  # ── sops secrets for server key + every peer ──────────────────────────
  sops.secrets = builtins.listToAttrs peerSecretAttrs // {
    wireguard_server_private = {
      restartUnits = [ "wireguard-wg0.service" ];
    };
  };

  # ── IP forwarding so peers can reach other LAN hosts ──────────────────
  # Same trust level that tailscale0 had; no NAT/exit-node.
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # ── WireGuard interface ───────────────────────────────────────────────
  networking.wireguard.interfaces.wg0 = {
    ips = [ "${settings.network.wireguard.address}/24" ];
    listenPort = settings.network.wireguard.port;
    privateKeyFile = config.sops.secrets.wireguard_server_private.path;
    peers = map (p: {
      publicKey = p.publicKey;
      presharedKeyFile = config.sops.secrets."wireguard_peer_${p.name}_psk".path;
      allowedIPs = [ "${p.ip}/32" ];
      persistentKeepalive = 25;
    }) peers;
  };

  # ── Profile renderer: per-peer .conf + QR PNG + index.html ───────────
  systemd.services.wireguard-profile-render = {
    description = "Render WireGuard peer configs and QR codes";
    after = [ "sops-nix.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.wireguard-tools pkgs.qrencode pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      #!/usr/bin/env bash
      set -euo pipefail

      OUT=/var/lib/mobileprofile/wg
      mkdir -p "$OUT"
      INDEX="$OUT/index.html"

      echo "wireguard-profile-render: starting" >&2

      # Derive server public key from the sops-decrypted private key
      SERVER_PRIV=/run/secrets/wireguard_server_private
      if [ ! -f "$SERVER_PRIV" ]; then
        echo "FATAL: wireguard_server_private not found — is sops-nix.service running?" >&2
        exit 1
      fi
      SERVER_PUB=$(wg pubkey < "$SERVER_PRIV")
      ENDPOINT="${settings.network.wireguard.endpoint}:${toString settings.network.wireguard.port}"

      MISSING=""

      # Start index.html
      cat > "$INDEX" <<'HTMLHEAD'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>WireGuard Profiles</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 2rem; color: #222; }
  table { border-collapse: collapse; width: 100%; max-width: 800px; }
  th, td { padding: 0.75rem; border: 1px solid #ddd; text-align: left; }
  th { background: #f5f5f5; }
  img { max-width: 200px; height: auto; }
  a { color: #0366d6; }
  .warn { color: #cb2431; }
</style>
</head>
<body>
<h1>WireGuard Profiles — nanulab</h1>
<table>
<tr><th>Device</th><th>Config</th><th>QR Code</th></tr>
HTMLHEAD

      # Render each peer
    '' + lib.concatMapStrings renderPeerBlock peers + ''

      # Close HTML
      cat >> "$INDEX" <<'HTMLEND'
</table>
HTMLEND

      if [ -n "$MISSING" ]; then
        cat >> "$INDEX" <<MISSINGWARN
<p class="warn"><strong>WARNING:</strong> Some peers skipped — secret keys not yet populated (placeholders in sops). Missing:$MISSING</p>
MISSINGWARN
      fi

      cat >> "$INDEX" <<'HTMLFOOT'
<p><em>Scan QR in the WireGuard app → tap "Allow" → enable On-Demand (Wi‑Fi + Cellular).</em></p>
</body>
</html>
HTMLFOOT

      # Secure output: root:nginx, 0640 for files, 0750 for the directory
      chown -R root:${config.users.groups.nginx.name} "$OUT"
      chmod 750 "$OUT"
      find "$OUT" -type f -exec chmod 640 {} \;

      echo "wireguard-profile-render: done ($(find "$OUT" -name '*.conf' | wc -l) peers rendered)" >&2
    '';
  };

  # ── Serve profiles on the existing profile.nanulab.de vhost ───────────
  # The vhost skeleton (forceSSL, useACMEHost, basicAuthFile) lives in
  # ios-profile.nix — we add only the /wg/ location here. NixOS merges both
  # contributions into a single vhost block.
  services.nginx.virtualHosts."profile.${settings.domains.internal}" = {
    locations."/wg/" = {
      root = "/var/lib/mobileprofile";
      extraConfig = ''
        autoindex off;
        add_header Cache-Control "no-store";
      '';
    };
  };
}
