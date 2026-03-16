{ pkgs, ... }:
{
  virtualisation.docker = {
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    daemon.settings = {
      data-root = "/fasttank/containers/";
    };
    daemon.settings = {
      userland-proxy = false;
      experimental = true;
      metrics-addr = "0.0.0.0:9323";
      ipv6 = true;
      fixed-cidr-v6 = "fd00::/80";
    };
  };
  virtualisation.oci-containers = {
    # Start containers as systemd units
    backend = "docker";
    containers = {
      #foo = {
      #  # ...
      #};
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
