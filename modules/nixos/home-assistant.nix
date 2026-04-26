_:
{
  services.home-assistant = {
    enable = true;
    openFirewall = true; # port 8123
    extraComponents = [
      "default_config"
      "met"
    ];
  };
}
