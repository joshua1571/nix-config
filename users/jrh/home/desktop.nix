{
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
    ./desktop-environment.nix
  ];

  home.packages = [ pkgs.ryubing ];
}
