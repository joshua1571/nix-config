{ ... }:
{
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  users.users.prowlarr.extraGroups = [ "users" "media" ];
}
