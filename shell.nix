{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    just
    nil
    jq
    nixfmt
    deadnix
    statix
  ];
  shellHook = "git config core.hooksPath .githooks";
}
