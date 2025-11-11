{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # firewall is not enabled but this can't hurt
  };
}
