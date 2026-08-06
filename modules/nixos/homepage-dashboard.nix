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
        echo "HOMEPAGE_ALLOWED_HOSTS=localhost:8082,10.0.0.125:8082,10.0.0.126:8082,10.0.0.100:8082,desktop.$domain:8082,htpc.$domain:8082,iphone.$domain:8082,laptop.$domain:8082,server.$domain:8082"
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
      } > /run/homepage-env
      chmod 400 /run/homepage-env
    '';
  };

  services.homepage-dashboard = {
    enable = true;
    environmentFile = "/run/homepage-env";
    settings = {
      title = "JRH Home Lab";
      description = "My Home Lab";
      bookmarksStyle = "icons";
    };
    listenPort = 8082;
    widgets = [
      {
        resources = {
          cpu = true;
          disk = "/";
          memory = true;
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
            timeStyle = "short";
            dateStyle = "long";
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
        Main = [
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
            Maps = [
              {
                icon = "sh-google-maps";
                abbr = "GM";
                href = "https://www.google.com/maps";
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
            Feedly = [
              {
                icon = "sh-feedly";
                abbr = "FY";
                href = "https://feedly.com/i/collection/content/user/436e25c7-bb60-4a7b-a350-b248ef3c9957/category/global.all";
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
        ];
      }

      {
        Development = [
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
            Linode = [
              {
                icon = "si-akamai";
                abbr = "LN";
                href = "https://cloud.linode.com/linodes";
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
            HuggingFace = [
              {
                icon = "si-huggingface";
                abbr = "HF";
                href = "https://huggingface.co/";
              }
            ];
          }
          {
            Kaggle = [
              {
                icon = "si-kaggle";
                abbr = "KG";
                href = "https://www.kaggle.com/";
              }
            ];
          }
        ];
      }

      {
        Video = [
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
          {
            TV_Pass = [
              {
                icon = "mdi-television-box";
                abbr = "TV";
                href = "https://tvpass.org/";
              }
            ];
          }
        ];

      }
    ];

    services = [
      {
        "Media" = [
          {
            "Jellyfin" = {
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
              description = "Photos";
              href = "http://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}:2283/photos";
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
        ];
      }
      {
        "Downloads" = [
          {
            "Radarr" = {
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
              description = "Downloads";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/qbittorrent/";
              siteMonitor = "http://127.0.0.1:8080";
              widget = {
                type = "qbittorrent";
                url = "http://127.0.0.1:8080";
                # Auth bypassed for loopback in qbittorrent.nix (LocalHostAuth=false).
                username = "";
                password = "";
              };
            };
          }
        ];
      }
      {
        "Files/Cloud" = [
          {
            "Nextcloud" = {
              description = "Files, calendar, contacts";
              # Not behind nginx (:443 catch-all owns /), so plain HTTP on :80.
              href = "http://server/";
              siteMonitor = "http://127.0.0.1";
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
        # Admin devices redirect http → https and often use self-signed certs,
        # which homepage's siteMonitor can't follow, so no reachability pill.
        "Administration" = [
          {
            "Router" = {
              description = "Router Web UI";
              href = "http://10.0.0.1/#/internet";
            };
          }
          {
            "Router(LuCI)" = {
              description = "Router Web UI";
              href = "http://10.0.0.1:8080/cgi-bin/luci/admin/status/overview";
            };
          }
          {
            "Switch" = {
              description = "Switch Web UI";
              href = "http://10.0.0.2";
            };
          }
          {
            "KVM (Local)" = {
              description = "KVM Web UI";
              href = "http://10.0.0.209";
            };
          }
        ];
      }
    ];
  };
}
