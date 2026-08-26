_: {
  services.openssh = {
    enable = true;
    ports = [ 2228 ];
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };
}
