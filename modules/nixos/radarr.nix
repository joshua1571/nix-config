{ ... }:
{
  services.radarr = {
    enable = true;
    dataDir = "/tank/radarr";
    openFirewall = true;
  };

  users.users.radarr.extraGroups = [ "users" ];
}
