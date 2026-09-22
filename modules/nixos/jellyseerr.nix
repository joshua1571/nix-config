{ pkgs, ... }:
{
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  # Jellyfin is configured with base URL /jellyfin (set in Jellyfin → Dashboard
  # → Networking). Jellyseerr stores the base path separately in settings.json
  # as jellyfin.urlBase and defaults it to empty string. Without the patch,
  # Jellyseerr calls http://127.0.0.1:8096/Users/AuthenticateByName which
  # Jellyfin 302-redirects, causing auth to fail with "Cannot read properties
  # of undefined (reading 'Id')".
  systemd.services.jellyseerr.preStart =
    let
      jq = "${pkgs.jq}/bin/jq";
      settings = "/var/lib/jellyseerr/config/settings.json";
    in
    ''
      set -eu
      if [ -f ${settings} ]; then
        tmp=$(mktemp --tmpdir=/var/lib/jellyseerr/config)
        ${jq} 'if has("jellyfin") then .jellyfin.urlBase = "/jellyfin" else . end' \
          ${settings} > "$tmp"
        mv "$tmp" ${settings}
      fi
    '';
}
