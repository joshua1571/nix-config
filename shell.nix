{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    nixfmt # nixfmt-rfc-style
    statix
    just
    nil
  ];
}
