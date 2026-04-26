_:
{
  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  users.users.radarr.extraGroups = [
    "users"
    "media"
  ];
}
