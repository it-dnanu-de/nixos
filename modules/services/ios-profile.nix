# iOS DNS profile — forces all DNS (WiFi + cellular) through AdGuard via Tailscale.
# OpenCode.md §10, §3.4. Install once, works everywhere.
# DNS queries go to 100.75.98.53 (homelab Tailscale IP → AdGuard).
{ pkgs, ... }:
let
  profileDir = pkgs.writeTextDir "dns.mobileconfig" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>PayloadContent</key>
      <array>
        <dict>
          <key>Name</key>
          <string>nanulab AdGuard DNS</string>
          <key>PayloadDescription</key>
          <string>Force all DNS queries through homelab AdGuard via Tailscale</string>
          <key>PayloadDisplayName</key>
          <string>DNS: AdGuard (nanulab)</string>
          <key>PayloadIdentifier</key>
          <string>de.dnanu.dns</string>
          <key>PayloadType</key>
          <string>com.apple.dnsSettings.managed</string>
          <key>PayloadUUID</key>
          <string>00000000-0000-0000-0000-000000000001</string>
          <key>PayloadVersion</key>
          <integer>1</integer>
          <key>DNSSettings</key>
          <dict>
            <key>DNSProtocol</key>
            <string>HTTPS</string>
            <key>ServerAddresses</key>
            <array>
              <string>100.75.98.53</string>
            </array>
            <key>ServerURL</key>
            <string>https://dns.quad9.net/dns-query</string>
          </dict>
        </dict>
      </array>
      <key>PayloadDescription</key>
      <string>AdGuard DNS via homelab Tailscale</string>
      <key>PayloadDisplayName</key>
      <string>nanulab DNS</string>
      <key>PayloadIdentifier</key>
      <string>de.dnanu.dns-profile</string>
      <key>PayloadOrganization</key>
      <string>nanulab</string>
      <key>PayloadType</key>
      <string>Configuration</string>
      <key>PayloadUUID</key>
      <string>00000000-0000-0000-0001-000000000001</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
    </dict>
    </plist>
  '';
in
{
  services.nginx.virtualHosts."profile.nanulab.de" = {
    forceSSL = true;
    useACMEHost = "nanulab.de";
    locations."/dns.mobileconfig" = {
      root = profileDir;
      extraConfig = ''
        add_header Content-Type application/x-apple-aspen-config;
        add_header Content-Disposition 'attachment; filename="nanulab-dns.mobileconfig"';
      '';
    };
  };
}
