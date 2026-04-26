_: {
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  users.users.prowlarr = {
    isSystemUser = true;
    group = "prowlarr";
    extraGroups = [
      "users"
      "media"
    ];
  };

  users.groups.prowlarr = { };
}
