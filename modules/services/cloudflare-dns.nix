# Cloudflare DNS — declarative zone management.
# Runs on activation: ensures every §4.4 DNS record exists via CF API.
# Static records (MX, SPF, DMARC, nanulab.de) are idempotent.
# DKIM is post-install (key changes per install).
{ config, pkgs, settings, ... }:
let
  cfToken = config.sops.secrets.cloudflare_api_token.path;

  dnsScript = pkgs.writeShellScriptBin "cloudflare-dns-sync" ''
    set -euo pipefail
    TOKEN="$(${pkgs.coreutils}/bin/cat $CREDENTIALS_DIRECTORY/cloudflare_api_token)"
    API="https://api.cloudflare.com/client/v4/zones"
    CURL() { ${pkgs.curl}/bin/curl -s -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" "$@"; }

    Z_DNANU=$(CURL "$API?name=${settings.domains.public}" | ${pkgs.jq}/bin/jq -r '.result[0].id')
    Z_NANULAB=$(CURL "$API?name=${settings.domains.internal}" | ${pkgs.jq}/bin/jq -r '.result[0].id')

    upsert() {
      local zone=$1 type=$2 name=$3 content=$4 proxied=$5 ttl=$6
      local existing=$(CURL "$API/$zone/dns_records?type=$type&name=$name" | ${pkgs.jq}/bin/jq -r '.result | length')
      if [ "$existing" -gt 0 ]; then
        # Update in-place — don't delete (prevents gaps during API failures)
        CURL "$API/$zone/dns_records?type=$type&name=$name" \
          | ${pkgs.jq}/bin/jq -r '.result[].id' \
          | while read -r id; do
              CURL -X PATCH "$API/$zone/dns_records/$id" \
                -d "{\"type\":\"$type\",\"name\":\"$name\",\"content\":\"$content\",\"proxied\":$proxied,\"ttl\":$ttl}" \
                > /dev/null 2>&1
            done
      else
        CURL -X POST "$API/$zone/dns_records" \
          -d "{\"type\":\"$type\",\"name\":\"$name\",\"content\":\"$content\",\"proxied\":$proxied,\"ttl\":$ttl}" \
          > /dev/null
      fi
    }

    # Remove a record if present (idempotent) — used for records that must NOT exist publicly.
    deleteRecord() {
      local zone=$1 type=$2 name=$3
      CURL "$API/$zone/dns_records?type=$type&name=$name" \
        | ${pkgs.jq}/bin/jq -r '.result[].id' \
        | while read -r id; do
            CURL -X DELETE "$API/$zone/dns_records/$id" > /dev/null 2>&1
          done
    }

    PUBLIC_IP4=$(${pkgs.curl}/bin/curl -s --interface ${settings.network.interface} https://api.ipify.org 2>/dev/null || echo "0.0.0.0")
    if [ "$PUBLIC_IP4" != "0.0.0.0" ]; then
      upsert "$Z_DNANU" A "${settings.domains.public}" "$PUBLIC_IP4" true 1
      upsert "$Z_DNANU" A "www.${settings.domains.public}" "$PUBLIC_IP4" true 1
      upsert "$Z_DNANU" A "${settings.domains.vpn}" "$PUBLIC_IP4" false 120
    fi

    upsert "$Z_DNANU" MX "${settings.domains.public}" "${settings.domains.mail}" false 120
    upsert "$Z_DNANU" TXT "${settings.domains.public}" "v=spf1 -all" false 120
    upsert "$Z_DNANU" TXT "_dmarc.${settings.domains.public}" \
      "v=DMARC1; p=quarantine; pct=100; adkim=r; aspf=r; rua=mailto:${settings.email.admin}" false 120

    # nanulab.de services are VPN-only (nginx source allowlist 10.0.1.0/24); AdGuard
    # rewrites them locally to 10.0.0.2. Public records must NOT exist (leaks
    # internal naming, resolves to nothing reachable). Delete A + AAAA if present.
    deleteRecord "$Z_NANULAB" A "*.${settings.domains.internal}"
    deleteRecord "$Z_NANULAB" A "${settings.domains.internal}"
    deleteRecord "$Z_NANULAB" AAAA "${settings.domains.internal}"
    upsert "$Z_NANULAB" MX "${settings.domains.internal}" "${settings.domains.mail}" false 120
  '';
in
{
  systemd.services.cloudflare-dkim-sync = {
    description = "Cloudflare DKIM TXT record";
    after = [ "dkim-setup.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ curl jq coreutils ];
    serviceConfig.Type = "oneshot";
    script = ''
      DKIM_FILE="/var/dkim/dnanu.de.mail.txt"
      [ ! -f "$DKIM_FILE" ] && exit 0
      TOKEN="$(cat $CREDENTIALS_DIRECTORY/cloudflare_api_token)"
      API="https://api.cloudflare.com/client/v4/zones"
      ZONE=$(curl -s -H "Authorization: Bearer $TOKEN" "$API?name=dnanu.de" | jq -r '.result[0].id')
      curl -s -H "Authorization: Bearer $TOKEN" \
        "$API/$ZONE/dns_records?type=TXT&name=mail._domainkey.dnanu.de" \
        | jq -r '.result[].id' | while read -r id; do
          curl -s -X DELETE -H "Authorization: Bearer $TOKEN" "$API/$ZONE/dns_records/$id" > /dev/null
        done
      VALUE=$(cat "$DKIM_FILE" | tr -d '\n\r' | sed 's/.*( \(.*\) ).*/\1/' | tr -d '"' | tr -d '\t' | sed 's/  */ /g')
      curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
        "$API/$ZONE/dns_records" \
        -d "{\"type\":\"TXT\",\"name\":\"mail._domainkey\",\"content\":\"$VALUE\",\"ttl\":120}" > /dev/null
    '';
    serviceConfig.LoadCredential = "cloudflare_api_token:${cfToken}";
  };


  systemd.services.cloudflare-dns-sync = {
    description = "Declarative Cloudflare DNS";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [ ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${dnsScript}/bin/cloudflare-dns-sync";
      LoadCredential = "cloudflare_api_token:${cfToken}";
      RemainAfterExit = true;
    };
  };


  environment.systemPackages = [ pkgs.jq ];
}
