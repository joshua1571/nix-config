{ ... }:
{
  services.lidarr = {
    enable = true;
    dataDir = "/tank/lidarr";
    openFirewall = true;
  };

  users.users.lidarr.extraGroups = [ "users" ];
}
