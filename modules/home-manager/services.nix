{ pkgs, desktop-environment, ... }: {
  services = {
    dropbox.enable = desktop-environment;
    opensnitch-ui.enable = true;
    gpg-agent.enable = true;
  };
}
