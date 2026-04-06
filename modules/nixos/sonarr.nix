{ ... }:
{
  services.sonarr = {
    enable = true;
    dataDir = "/tank/sonarr";
    openFirewall = true;
  };

  users.users.sonarr.extraGroups = [ "users" ];
}
