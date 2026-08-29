{ config, ... }:
{
  age.secrets =
    let
      serverOwned = file: {
        inherit file;
        owner = "root";
        mode = "0400";
      };
    in
    {
      tailscale-domain = serverOwned ../../secrets/tailscale-domain.age;
      homepage-jellyfin-key = serverOwned ../../secrets/homepage-jellyfin-key.age;
      homepage-jellyseerr-key = serverOwned ../../secrets/homepage-jellyseerr-key.age;
      homepage-immich-key = serverOwned ../../secrets/homepage-immich-key.age;
      homepage-radarr-key = serverOwned ../../secrets/homepage-radarr-key.age;
      homepage-sonarr-key = serverOwned ../../secrets/homepage-sonarr-key.age;
      homepage-lidarr-key = serverOwned ../../secrets/homepage-lidarr-key.age;
      homepage-prowlarr-key = serverOwned ../../secrets/homepage-prowlarr-key.age;
      homepage-navidrome-user = serverOwned ../../secrets/homepage-navidrome-user.age;
      homepage-navidrome-salt = serverOwned ../../secrets/homepage-navidrome-salt.age;
      homepage-navidrome-token = serverOwned ../../secrets/homepage-navidrome-token.age;
      homepage-homeassistant-key = serverOwned ../../secrets/homepage-homeassistant-key.age;
      homepage-freshrss-password = serverOwned ../../secrets/homepage-freshrss-password.age;
    };

  # Generate a runtime env file for homepage containing widget credentials.
  # Everything is encrypted at rest via agenix and read at service start.
  systemd.services.homepage-env = {
    description = "Generate homepage-dashboard environment file";
    after = [ "agenix.service" ];
    before = [ "homepage-dashboard.service" ];
    wantedBy = [ "homepage-dashboard.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      domain=$(cat ${config.age.secrets.tailscale-domain.path})
      {
        echo "HOMEPAGE_VAR_TAILSCALE_DOMAIN=$domain"
        echo "HOMEPAGE_VAR_JELLYFIN_KEY=$(cat ${config.age.secrets.homepage-jellyfin-key.path})"
        echo "HOMEPAGE_VAR_JELLYSEERR_KEY=$(cat ${config.age.secrets.homepage-jellyseerr-key.path})"
        echo "HOMEPAGE_VAR_IMMICH_KEY=$(cat ${config.age.secrets.homepage-immich-key.path})"
        echo "HOMEPAGE_VAR_RADARR_KEY=$(cat ${config.age.secrets.homepage-radarr-key.path})"
        echo "HOMEPAGE_VAR_SONARR_KEY=$(cat ${config.age.secrets.homepage-sonarr-key.path})"
        echo "HOMEPAGE_VAR_LIDARR_KEY=$(cat ${config.age.secrets.homepage-lidarr-key.path})"
        echo "HOMEPAGE_VAR_PROWLARR_KEY=$(cat ${config.age.secrets.homepage-prowlarr-key.path})"
        echo "HOMEPAGE_VAR_NEXTCLOUD_PASSWORD=$(cat ${config.age.secrets.nextcloud-adminpass.path})"
        echo "HOMEPAGE_VAR_NAVIDROME_USER=$(cat ${config.age.secrets.homepage-navidrome-user.path})"
        echo "HOMEPAGE_VAR_NAVIDROME_SALT=$(cat ${config.age.secrets.homepage-navidrome-salt.path})"
        echo "HOMEPAGE_VAR_NAVIDROME_TOKEN=$(cat ${config.age.secrets.homepage-navidrome-token.path})"
        echo "HOMEPAGE_VAR_HOMEASSISTANT_KEY=$(cat ${config.age.secrets.homepage-homeassistant-key.path})"
        echo "HOMEPAGE_VAR_FRESHRSS_USER=${config.services.freshrss.defaultUser}"
        echo "HOMEPAGE_VAR_FRESHRSS_PASSWORD=$(cat ${config.age.secrets.homepage-freshrss-password.path})"
      } > /run/homepage-env
      chmod 400 /run/homepage-env
    '';
  };

  services.homepage-dashboard = {
    enable = true;
    environmentFile = "/run/homepage-env";
    # Wildcard: access control is enforced by Tailscale (interface-bound
    # firewall) and nginx (443 on tailscale0 only). The Host header from
    # nginx varies with the tailscale domain, which is a runtime agenix
    # secret — a specific list can't be baked in at build time.
    allowedHosts = "*";
    settings = {
      title = "JRH Home Lab";
      description = "My Home Lab";
      bookmarksStyle = "icons";
      headerStyle = "clean";
      hideVersion = true;
      useEqualHeights = true;
      iconStyle = "theme";
      layout = [
        {
          Bookmarks = {
            tab = "Main";
            style = "row";
            header = false;
            columns = 22;
            iconsOnly = true;
          };
        }
        {
          Main = {
            tab = "Main";
            style = "row";
            header = false;
            columns = 4;
          };
        }
        {
          Downloads = {
            tab = "Downloads";
            style = "row";
            header = false;
            columns = 4;
          };
        }
        {
          Administration = {
            tab = "Administration";
            style = "row";
            header = false;
            columns = 5;
            iconsOnly = true;
          };
        }
        {
          Monitoring = {
            tab = "Administration";
            style = "row";
            header = true;
            columns = 3;
          };
        }
      ];
    };
    listenPort = 8082;
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
        };
      }
      {
        resources = {
          label = "root";
          disk = "/";
        };
      }
      {
        resources = {
          label = "tank";
          disk = "/tank";
        };
      }
      {
        resources = {
          label = "fasttank";
          disk = "/fasttank";
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = {
            weekday = "long";
            month = "long";
            day = "numeric";
            year = "numeric";
            hour = "numeric";
            minute = "numeric";
            hourCycle = "h12";
          };
        };
      }
      {
        openmeteo = {
          latitude = "33.6439";
          longitude = "-117.7481";
          timezone = "America/Los_Angeles";
          units = "imperial";
          cache = 5;
        };
      }
    ];
    bookmarks = [
      {
        Bookmarks = [
          {
            Claude = [
              {
                icon = "sh-claude";
                abbr = "CL";
                href = "https://claude.ai/";
              }
            ];
          }
          {
            ChatGPT = [
              {
                icon = "sh-chatgpt";
                abbr = "GP";
                href = "https://chat.openai.com/";
              }
            ];
          }
          {
            Gemini = [
              {
                icon = "sh-google-gemini";
                abbr = "GE";
                href = "https://gemini.google.com/";
              }
            ];
          }
          {
            Fastmail = [
              {
                icon = "sh-fastmail";
                abbr = "FM";
                href = "https://app.fastmail.com";
              }
            ];
          }
          {
            Gmail = [
              {
                icon = "sh-gmail";
                abbr = "GL";
                href = "https://mail.google.com/";
              }
            ];
          }
          {
            Hotmail = [
              {
                icon = "sh-microsoft-outlook";
                abbr = "HO";
                href = "https://outlook.live.com/mail/";
              }
            ];
          }
          {
            Thundermail = [
              {
                icon = "sh-thundermail";
                abbr = "TM";
                href = "https://mail.thundermail.com/";
              }
            ];
          }
          {
            TickTick = [
              {
                icon = "sh-ticktick";
                abbr = "TT";
                href = "https://ticktick.com/webapp/";
              }
            ];
          }
          {
            Google_Maps = [
              {
                icon = "sh-google-maps";
                abbr = "GM";
                href = "https://www.google.com/maps";
              }
            ];
          }
          {
            Apple_Maps = [
              {
                icon = "sh-apple-maps";
                abbr = "AM";
                href = "https://beta.maps.apple.com/";
              }
            ];
          }
          {
            Reddit = [
              {
                icon = "sh-reddit";
                abbr = "RD";
                href = "https://www.reddit.com/";
              }
            ];
          }
          {
            WhatsApp = [
              {
                icon = "sh-whatsapp";
                abbr = "WA";
                href = "https://web.whatsapp.com/";
              }
            ];
          }
          {
            Amazon = [
              {
                icon = "sh-amazon";
                abbr = "AZ";
                href = "https://www.amazon.com/ref=nav_logo";
              }
            ];
          }
          {
            Github = [
              {
                icon = "sh-github";
                abbr = "GH";
                href = "https://github.com/";
              }
            ];
          }
          {
            YouTube = [
              {
                icon = "sh-youtube";
                abbr = "YT";
                href = "https://youtube.com/";
              }
            ];
          }
          {
            Netflix = [
              {
                icon = "sh-netflix";
                abbr = "NX";
                href = "https://www.netflix.com/browse";
              }
            ];
          }
          {
            Amazon_Prime = [
              {
                icon = "sh-amazon-prime-video";
                abbr = "AP";
                href = "https://www.amazon.com/gp/video/storefront";
              }
            ];
          }
          {
            Hulu = [
              {
                icon = "sh-hulu";
                abbr = "HL";
                href = "https://www.hulu.com/hub/home";
              }
            ];
          }
          {
            Disney_Plus = [
              {
                icon = "sh-disney-plus";
                abbr = "DP";
                href = "https://www.disneyplus.com/home";
              }
            ];
          }
          {
            HBO_Max = [
              {
                icon = "sh-hbo-max";
                abbr = "HM";
                href = "https://play.hbomax.com/";
              }
            ];
          }
          {
            Crunchyroll = [
              {
                icon = "sh-crunchyroll";
                abbr = "CR";
                href = "https://www.crunchyroll.com/discover";
              }
            ];
          }
          {
            RunningMan = [
              {
                abbr = "RM";
                href = "https://www.myrunningman.com/";
              }
            ];
          }
        ];
      }
      {
        Administration = [
          {
            Router = [
              {
                icon = "mdi-router-wireless";
                abbr = "RT";
                href = "http://10.0.0.1:8080/cgi-bin/luci/admin/status/overview";
              }
            ];
          }
          {
            Switch = [
              {
                icon = "mdi-lan";
                abbr = "SW";
                href = "http://10.0.0.2";
              }
            ];
          }
          {
            KVM = [
              {
                icon = "mdi-monitor-dashboard";
                abbr = "KV";
                href = "http://10.0.0.209";
              }
            ];
          }
          {
            Vultr = [
              {
                icon = "sh-vultr";
                abbr = "VU";
                href = "https://my.vultr.com/";
              }
            ];
          }
          {
            Tailscale = [
              {
                icon = "sh-tailscale";
                abbr = "TS";
                href = "https://login.tailscale.com/admin/machines";
              }
            ];
          }
          {
            Authelia = [
              {
                icon = "sh-authelia";
                abbr = "AU";
                href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/authelia/";
              }
            ];
          }
        ];
      }
    ];

    services = [
      {
        "Main" = [
          {
            "Jellyfin" = {
              icon = "sh-jellyfin";
              description = "Movies and TV Shows";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/jellyfin/";
              siteMonitor = "http://127.0.0.1:8096";
              widget = {
                type = "jellyfin";
                url = "http://127.0.0.1:8096";
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                enableBlocks = true;
                enableNowPlaying = true;
              };
            };
          }
          {
            "Navidrome" = {
              icon = "sh-navidrome";
              description = "Music";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/navidrome/";
              siteMonitor = "http://127.0.0.1:4533";
              widget = {
                type = "navidrome";
                # BaseUrl = "/navidrome" is set in navidrome.nix, so it's
                # part of the widget URL too.
                url = "http://127.0.0.1:4533/navidrome";
                user = "{{HOMEPAGE_VAR_NAVIDROME_USER}}";
                salt = "{{HOMEPAGE_VAR_NAVIDROME_SALT}}";
                token = "{{HOMEPAGE_VAR_NAVIDROME_TOKEN}}";
              };
            };
          }
          {
            "Immich" = {
              icon = "sh-immich";
              description = "Photos";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}:2443/photos";
              siteMonitor = "http://127.0.0.1:2283";
              widget = {
                type = "immich";
                url = "http://127.0.0.1:2283";
                key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                version = 2;
              };
            };
          }
          {
            "Jellyseerr" = {
              icon = "sh-jellyseerr";
              description = "Requests";
              href = "http://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}:5055";
              siteMonitor = "http://127.0.0.1:5055";
              widget = {
                type = "jellyseerr";
                url = "http://127.0.0.1:5055";
                key = "{{HOMEPAGE_VAR_JELLYSEERR_KEY}}";
              };
            };
          }
          {
            "FreshRSS" = {
              icon = "sh-freshrss";
              description = "RSS Reader";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/freshrss/";
              # / redirects to /freshrss/i/ (derived from baseUrl), a path that
              # only exists behind the nginx prefix-stripping proxy — hitting
              # 8083 directly 404s. /i/ is the real app root on this port.
              siteMonitor = "http://127.0.0.1:8083/i/";
              widget = {
                type = "freshrss";
                # baseUrl in freshrss.nix is /freshrss, so the widget URL
                # must include it too.
                url = "http://127.0.0.1:8083";
                username = "{{HOMEPAGE_VAR_FRESHRSS_USER}}";
                # Not the login password — the API password set per-user in
                # FreshRSS → Profile → API management (Fever/GReader).
                password = "{{HOMEPAGE_VAR_FRESHRSS_PASSWORD}}";
              };
            };
          }
          {
            "Nextcloud" = {
              icon = "sh-nextcloud";
              description = "Files, calendar, contacts";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/nextcloud/";
              # overwritecondaddr in nextcloud.nix matches homepage's own
              # loopback connection, so / redirects to an https URL — which
              # homepage's http-only redirect follower rejects. status.php
              # answers 200 directly with no redirect.
              siteMonitor = "http://127.0.0.1/status.php";
              widget = {
                type = "nextcloud";
                url = "http://127.0.0.1";
                username = "admin";
                password = "{{HOMEPAGE_VAR_NEXTCLOUD_PASSWORD}}";
              };
            };
          }
          {
            "Home Assistant" = {
              icon = "sh-home-assistant";
              description = "Home Automation";
              href = "http://10.0.0.155:8123/home/overview";
              siteMonitor = "http://10.0.0.155:8123";
              widget = {
                type = "homeassistant";
                url = "http://10.0.0.155:8123";
                key = "{{HOMEPAGE_VAR_HOMEASSISTANT_KEY}}";
              };
            };
          }
        ];
      }
      {
        "Downloads" = [
          {
            "Radarr" = {
              icon = "sh-radarr";
              description = "Movies";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/radarr/";
              siteMonitor = "http://127.0.0.1:7878";
              widget = {
                type = "radarr";
                url = "http://127.0.0.1:7878";
                key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                enableQueue = true;
              };
            };
          }
          {
            "Sonarr" = {
              icon = "sh-sonarr";
              description = "TV Shows";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/sonarr/";
              siteMonitor = "http://127.0.0.1:8989";
              widget = {
                type = "sonarr";
                url = "http://127.0.0.1:8989";
                key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                enableQueue = true;
              };
            };
          }
          {
            "Lidarr" = {
              icon = "sh-lidarr";
              description = "Music";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/lidarr/";
              siteMonitor = "http://127.0.0.1:8686";
              widget = {
                type = "lidarr";
                url = "http://127.0.0.1:8686";
                key = "{{HOMEPAGE_VAR_LIDARR_KEY}}";
              };
            };
          }
          {
            "Prowlarr" = {
              icon = "sh-prowlarr";
              description = "Indexers";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/prowlarr/";
              siteMonitor = "http://127.0.0.1:9696";
              widget = {
                type = "prowlarr";
                url = "http://127.0.0.1:9696";
                key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
              };
            };
          }
          {
            "qBittorrent" = {
              icon = "sh-qbittorrent";
              description = "Downloads";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/qbittorrent/";
              siteMonitor = "http://127.0.0.1:8080";
              widget = {
                type = "qbittorrent";
                url = "http://127.0.0.1:8080";
                # Auth bypassed for loopback in qbittorrent.nix (LocalHostAuth=false).
                username = "";
                password = "";
                fields = [
                  "download"
                  "upload"
                  "leech"
                  "seed"
                ];
              };
            };
          }
        ];
      }
      {
        "Monitoring" = [
          {
            "Gatus" = {
              icon = "sh-gatus";
              description = "Uptime checks";
              href = "http://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}:8084";
              siteMonitor = "http://127.0.0.1:8084/health";
            };
          }
          {
            "Grafana" = {
              icon = "sh-grafana";
              description = "Dashboards";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/grafana/";
              siteMonitor = "http://127.0.0.1:3000/grafana/api/health";
            };
          }
          {
            "Prometheus" = {
              icon = "sh-prometheus";
              description = "Metrics & rules";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/prometheus/";
              siteMonitor = "http://127.0.0.1:9090/prometheus/-/healthy";
            };
          }
          {
            "ntfy" = {
              icon = "sh-ntfy";
              description = "Push notifications";
              href = "http://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}:8085";
              siteMonitor = "http://127.0.0.1:8085/v1/health";
            };
          }
        ];
      }
    ];
  };
}
