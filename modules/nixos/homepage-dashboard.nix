{ _ }:
{
  services.homepage-dashboard = {
    enable = true;
    settings = {
      title = "JRH Home Lab";
      description = "My Home Lab";
      bookmarksStyle = "icons";
    };
    allowedHosts = "localhost, 10.0.0.125:8082,10.0.0.126:8082,10.0.0.100:8082";
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
                href = "https://app.fastmail.com";
              }
            ];
            Maps = [
              {
                href = "https://www.google.com/maps";
              }
            ];
            Reddit = [
              {
                href = "https://www.reddit.com/";
              }
            ];
            Feedly = [
              {
                href = "https://feedly.com/i/collection/content/user/436e25c7-bb60-4a7b-a350-b248ef3c9957/category/global.all";
              }
            ];
            Amazon = [
              {
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
                href = "https://github.com/";
              }
            ];
            Linode = [
              {
                href = "https://cloud.linode.com/linodes";
              }
            ];
            Tailscale = [
              {
                href = "https://login.tailscale.com/admin/machines";
              }
            ];
            HuggingFace = [
              {
                href = "https://huggingface.co/";
              }
            ];
            Kaggle = [
              {
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
                href = "https://youtube.com/";
              }
            ];
            Netflix = [
              {
                href = "https://www.netflix.com/browse";
              }
            ];
            Amazon_Prime = [
              {
                href = "https://www.amazon.com/gp/video/storefront";
              }
            ];
            Hulu = [
              {
                href = "https://www.hulu.com/hub/home";
              }
            ];
            Disney_Plus = [
              {
                href = "https://www.disneyplus.com/home";
              }
            ];
            HBO_Max = [
              {
                href = "https://play.hbomax.com/";
              }
            ];
            Crunchyroll = [
              {
                href = "https://www.crunchyroll.com/discover";
              }
            ];
            RunningMan = [
              {
                href = "https://www.myrunningman.com/";
              }
            ];
            TV_Pass = [
              {
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
              href = "http://10.0.0.126:4533/app/#/song";
            };
          }
          {
            "Immich" = {
              description = "Photos";
              href = "http://10.0.0.126:2283/photos";
            };
          }
        ];
      }
      {
        "Self Hosted (Remote)" = [
          {
            "My Second Service" = {
              description = "Homepage is the best";
              href = "http://localhost/";
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
