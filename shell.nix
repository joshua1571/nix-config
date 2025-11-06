{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    nixfmt-classic # nixfmt-rfc-style
    statix
    just
    nil
  ];
}
