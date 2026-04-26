_:
{
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  users.users.sonarr.extraGroups = [
    "users"
    "media"
  ];
}
