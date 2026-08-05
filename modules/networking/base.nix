# Base networking: static IP, gateway, firewall, DNS.
# OpenCode.md §3.1 — server is static 10.0.0.2/24, gw 10.0.0.1.
# Open ports: 25/tcp (inbound SMTP), 51820/udp (WireGuard — §3.3).
{ settings, ... }:
{
  networking.useDHCP = false;
  networking.interfaces.${settings.network.interface} = {
    ipv4.addresses = [{
      address = settings.network.address;
      prefixLength = settings.network.prefixLength;
    }];
  };
  networking.defaultGateway = settings.network.gateway;

  time.timeZone = settings.timeZone;

  # Host uses AdGuard on loopback for split-horizon DNS correctness.
  networking.nameservers = [ "127.0.0.1" ];
  services.resolved.enable = false;

  networking.firewall = {
    enable = true;
    # TCP 25: inbound SMTP, 53: AdGuard DNS, 465/587: submission, 993: IMAPS (LAN-only)
    allowedTCPPorts = [ 25 53 465 587 993 ];
    # UDP 53: DNS, 67: AdGuard DHCP server, 51820: WireGuard (remote-access VPN — §3.3)
    allowedUDPPorts = [ 53 67 51820 ];
    # WireGuard interface — all traffic trusted (how admin UIs are reached, §3.3 superseded Tailscale).
    trustedInterfaces = [ "wg0" ];
  };
}
