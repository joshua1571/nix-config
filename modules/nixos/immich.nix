{ username, ... }:
{
  services.immich = {
    enable = true;
    #host = "localhost";
    host = "0.0.0.0";
    port = 2283;
    openFirewall = true;
    accelerationDevices = null;
    mediaLocation = "/tank/personal/photos/immich_data";
  };

  users.users.immich.extraGroups = [
    "video"
    "render"
    "users"
    "media"
  ];
}
