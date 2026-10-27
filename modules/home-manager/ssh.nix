{ lib, options, ... }:
let
  # Stable home-manager (server) predates `programs.ssh.settings`.
  hasSettings = options.programs.ssh ? settings;
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  }
  // lib.optionalAttrs hasSettings {
    settings."*" = {
      # Previous home-manager defaults, kept explicitly.
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";

      IdentityAgent = "~/.1password/agent.sock";
      StrictHostKeyChecking = "accept-new";
    };
  }
  // lib.optionalAttrs (!hasSettings) {
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
    extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
      StrictHostKeyChecking accept-new
    '';
  };
}
