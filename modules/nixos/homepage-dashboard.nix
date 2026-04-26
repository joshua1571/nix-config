{ config, ... }:
{
  age.secrets.tailscale-domain = {
    file = ../../secrets/tailscale-domain.age;
    owner = "root";
    mode = "0400";
  };

  # Generate a runtime env file for homepage containing the Tailscale domain.
  # The domain is encrypted at rest via agenix and read at service start.
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
        "Self Hosted (Local)" = [
          {
            "Jellyfin" = {
              description = "Movies and TV Shows";
              href = "http://10.0.0.126:8096/web/#/login?serverid=d11f4daf81904233a08637f4bdb164c6&url=%2Fhome";
            };
          }
          {
            "Navidrome" = {
              description = "Music";
              href = "http://10.0.0.126:4533/app/#/login";
            };
          }
          {
            "Immich" = {
              description = "Photos";
              href = "http://10.0.0.126:2283/photos";
            };
          }
          {
            "Radarr" = {
              description = "Movies";
              href = "http://10.0.0.126:7878";
            };
          }
          {
            "Sonarr" = {
              description = "TV Shows";
              href = "http://10.0.0.126:8989";
            };
          }
        ];
      }
      {
        "Self Hosted (Tailscale)" = [
          {
            "Jellyfin" = {
              description = "Movies and TV Shows";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/jellyfin/";
            };
          }
          {
            "Navidrome" = {
              description = "Music";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/navidrome/";
            };
          }
          {
            "Jellyseerr" = {
              description = "Requests";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/jellyseerr/";
            };
          }
          {
            "Radarr" = {
              description = "Movies";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/radarr/";
            };
          }
          {
            "Sonarr" = {
              description = "TV Shows";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/sonarr/";
            };
          }
          {
            "Lidarr" = {
              description = "Music";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/lidarr/";
            };
          }
          {
            "Prowlarr" = {
              description = "Indexers";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/prowlarr/";
            };
          }
          {
            "qBittorrent" = {
              description = "Downloads";
              href = "https://server.{{HOMEPAGE_VAR_TAILSCALE_DOMAIN}}/qbittorrent/";
            };
          }
        ];
      }
      {
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
