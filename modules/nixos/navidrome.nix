{ _ }:
{
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/tank/music";
      #Address = "0.0.0.0";
      Address = "10.0.0.126";
      Port = 4533;
    };
    openFirewall = true;
  };
}
