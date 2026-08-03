# Base networking: static IP, gateway, firewall, DNS.
# OpenCode.md §3.1 — server is static 10.0.0.2/24, gw 10.0.0.1.
# Zero open ports except what each service explicitly opens.
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

  # Host uses AdGuard on loopback for split-horizon DNS correctness.
  networking.nameservers = [ "127.0.0.1" ];
  services.resolved.enable = false;

  networking.firewall = {
    enable = true;
    # TCP 53: AdGuard DNS for LAN clients. TCP 25: inbound SMTP.
    allowedTCPPorts = [ 25 53 ];
    # UDP 53: DNS, 67: AdGuard DHCP server.
    allowedUDPPorts = [ 53 67 ];
    # Tailscale interface — all traffic trusted (how admin UIs are reached).
    trustedInterfaces = [ "tailscale0" ];
  };
}
