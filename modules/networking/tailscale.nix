# Tailscale — zero-trust mesh VPN (SaaS).
# OpenCode.md §3.3. Server advertises LAN subnet route; auth via OAuth client secret.
# 1% manual: approve subnet route in admin console; set tailnet DNS to 10.0.0.2 + 1.1.1.1 with override.
{ config, settings, ... }:
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    authKeyFile = config.sops.secrets.tailscale_oauth.path;
    authKeyParameters.preauthorized = true;
    extraUpFlags = [
      "--advertise-routes=${settings.network.tailscaleRoutes}"
    ];
    openFirewall = true;
  };
}
