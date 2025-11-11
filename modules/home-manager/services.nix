{ pkgs, ... }: {
  services = {
    dropbox.enable = true;
    opensnitch-ui.enable = true;
    gpg-agent.enable = true;
  };
}
