_: {
  programs.ssh = {
    enable = true;
    extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
      StrictHostKeyChecking accept-new
    '';
  };
}
