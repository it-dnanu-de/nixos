---
name: nixos-flake
description: Use when writing or editing NixOS config — flake.nix, modules, services, or any nixos option. Enforces the pinned-channel rule, the 99%-declarative rule, and the verify-before-write workflow.
---

# NixOS Flake & Module Conventions

The homelab is a single-node NixOS monolith on the pinned stable channel.

## Hard rules (from OpenCode.md)
- nixpkgs follows `nixos-26.05`. No auto-upgrades; the human runs `nix flake update` deliberately 2-4x/year.
- **99% Declarative.** Declare infrastructure in Nix: ZFS, networking, services, users, paths, secrets, TLS. Application *state* is configured once by the human in web UIs. No bootstrap scripts poking APIs.
- **Native modules only.** Zero containers in v1. The single sanctioned exception is Booklore (pinned OCI image + native MariaDB). VPN confinement uses namespaces, not containers.
- **Zero open ports** except 25/tcp (inbound SMTP). Everything else: Tailscale, Cloudflare tunnel, or VPN netns.
- Do not add services, containers, or dependencies not listed in OpenCode.md.

## Repo layout (OpenCode.md §6)
```
flake.nix              # inputs: nixpkgs(26.05), sops-nix, disko, vpn-confinement, simple-nixos-mailserver
settings.nix           # THE user file: domains, IPs, email, vpn.forwardedPort, zfsArcMax, sshPubKey, hostId
secrets/secrets.yaml   # sops-encrypted, safe to commit
hosts/homelab/{configuration.nix,hardware-configuration.nix,disko.nix}
modules/{networking,services,system}/*.nix
modules/mobile-profile.nix
```

## Verify-before-write
- Every option you write must exist in the pinned `nixos-26.05` channel. Use the `verifier` agent, the `nixpkgs` reference (`@nixpkgs`), or `context7`.
- Abstract paths `/fast` and `/slow` only via `settings.nix` so prod migration is a new disko.nix + hardware config.
- ZFS: `networking.hostId = "<8 hex>";` is mandatory; `boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;`.
- Dell test box quirks: `services.logind.lidSwitch = "ignore";` and ARC capped via `boot.kernelParams = [ "zfs.zfs_arc_max=1073741824" ];` (param from settings.nix).

## Build order (frozen, OpenCode.md)
1. flake.nix + settings.nix + sops skeleton
2. disko.nix + ZFS + hostId + Dell quirks
3. Networking: static IP, AdGuard, Tailscale, ddclient, cloudflared, nginx+ACME
4. Mail (SNM + Resend relay + sieve + DNS table) — highest risk, verify earliest
5. Nextcloud (+Office) + Immich + Vaultwarden
6. VPN-Confinement -> downloaders -> *arrs -> players (incl. Booklore)
7. .mobileconfig signer + Hugo site
8. Restic + Beszel + verification suite
