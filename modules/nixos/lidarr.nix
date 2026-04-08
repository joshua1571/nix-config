{ ... }:
{
  services.lidarr = {
    enable = true;
    openFirewall = true;
  };

  users.users.lidarr.extraGroups = [ "users" ];
}
