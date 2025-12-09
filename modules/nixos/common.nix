{
#config,
pkgs, lib, username, ... }: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "networkmanager" "wheel" "input" ];
  };

  # customise /etc/nix/nix.conf declaratively via `nix.settings`
  nix.settings = {
    # enable flakes globally
    experimental-features = [ "nix-command" "flakes" ];
  };

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 30d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.printing.enable = true;

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    tailscale.enable = true;
		#opensnitch.enable = true;
    fwupd.enable = true;
  };

  fonts = {
    enableDefaultPackages = true;
    fontconfig.useEmbeddedBitmaps = true;
    packages = with pkgs; [
      #icon fonts
      material-design-icons
      # normal fonts
      noto-fonts
      noto-fonts-color-emoji
      # nerd fonts https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/shas.nix
      nerd-fonts.sauce-code-pro
      nerd-fonts.fira-code
    ];
  };

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    zip
    xz
    unzip
    xdg-utils
    sysstat
    lm_sensors # for `sensors` command
    cifs-utils
    file
    pciutils
    usbutils
  ];

}
