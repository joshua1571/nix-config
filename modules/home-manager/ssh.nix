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
    settings = {
      "*" = {
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

        StrictHostKeyChecking = "accept-new";
      };

      # Only use the 1Password agent where it exists; elsewhere fall back to
      # SSH_AUTH_SOCK (e.g. an agent forwarded from the laptop).
      "Match exec \"test -S ~/.1password/agent.sock\"".IdentityAgent = "~/.1password/agent.sock";

      # Forward the laptop's 1Password agent so git works on hosts without it.
      "Host desktop server htpc".ForwardAgent = true;
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
      StrictHostKeyChecking accept-new

      # Only use the 1Password agent where it exists; elsewhere fall back to
      # SSH_AUTH_SOCK (e.g. an agent forwarded from the laptop).
      Match exec "test -S ~/.1password/agent.sock"
        IdentityAgent ~/.1password/agent.sock

      # Forward the laptop's 1Password agent so git works on hosts without it.
      Host desktop server htpc
        ForwardAgent yes
    '';
  };
}
