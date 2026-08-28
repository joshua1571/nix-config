{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    brave # Alternative chromium browser
    spotify # Music subscription service
    discord # Game chat
    ticktick # Reminders
    obsidian # Notes
    libreoffice-qt6 # Office suite
    deskflow # Remote KVM
    localsend # Airdrop alternative
    ktailctl # Tailscale GUI applet
    openhue-cli # Philips Hue lighting CLI
    easyeffects # Audio effects
    activitywatch # Not sure if I really need this
    opensnitch # Requires opensnitch service
    jellyfin-desktop
    strawberry
    nextcloud-client
    calibre
    teams-for-linux
    zoom-us
    qownnotes
    #github-desktop				# Error whenever you open this on nix
    #bitwarden-desktop		# I mostly just use this via the browser plugin instead of the native app
    #zapzap								# Use web app instead
    #fastmail-desktop			# Use web app instead
  ];
}
