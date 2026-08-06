# Base networking: static IP, gateway, firewall, DNS.
# OpenCode.md §3.1 — server is static 10.0.0.2/24, gw 10.0.0.1.
# v4 (2026-08-06): ULA fd10::2/64 for Kea DHCPv6 DNS, accept_ra=1
# (keep SLAAC GUA for outbound v6/mail, no v6 forwarding).
# DHCP is now Kea (§3.1), not AdGuard.
# Open ports: 25/tcp (inbound SMTP), 51820/udp (WireGuard — §3.3).
{ settings, ... }:
{
  networking.useDHCP = false;
  networking.interfaces.${settings.network.interface} = {
    ipv4.addresses = [{
      address = settings.network.address;
      prefixLength = settings.network.prefixLength;
    }];
    # ULA for Kea DHCPv6 DNS (fd10::2/64); GUA comes from Speedport SLAAC.
    ipv6.addresses = [{
      address = "fd10::2";
      prefixLength = 64;
    }];
  };
  networking.defaultGateway = settings.network.gateway;

  time.timeZone = settings.timeZone;

  # Host uses AdGuard on loopback for split-horizon DNS correctness.
  networking.nameservers = [ "127.0.0.1" ];
  services.resolved.enable = false;

  # Belt-and-braces: ensure SLAAC GUA stays alive (needed for outbound v6 mail).
  # No v6 forwarding enabled, so accept_ra=1 is honored.
  boot.kernel.sysctl."net.ipv6.conf.${settings.network.interface}.accept_ra" = 1;

  networking.firewall = {
    enable = true;
    # TCP 25: inbound SMTP, 53: AdGuard DNS, 80: HTTP→HTTPS redirect (LAN-only),
    # 443: nginx TLS vhosts (AdGuard UI, profile.dnanu.de — LAN/VPN-only;
    # router forwards only 25/51820 so 80/443 are effectively LAN-only),
    # 465/587: submission, 993: IMAPS (LAN-only)
    allowedTCPPorts = [ 25 53 80 443 465 587 993 ];
    # UDP 53: DNS, 67: DHCPv4 (Kea), 547: DHCPv6 (Kea), 51820: WireGuard
    allowedUDPPorts = [ 53 67 547 51820 ];
    # WireGuard interface — all traffic trusted (how admin UIs are reached).
    trustedInterfaces = [ "wg0" ];
  };
}
