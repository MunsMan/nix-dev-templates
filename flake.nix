{
  description = "A collection of project templates";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            nixfmt-rfc-style
            nixd
          ];
        };
        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // {
      templates = rec {
        latex = {
          path = ./latex;
          description = "A basic latex starter template";
        };
        rust = {
          path = ./rust;
          description = "A basic rust flake using the stable toolchain.";
        };
        pnpm = {
          path = ./pnpm;
          description = "A basic pnpm flake using node";
        };
        basic = {
          path = ./basic;
          description = "A basic flake template";
        };
        default = basic;
      };
    };
}
