{
  description = "A simple typst flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.mkShellNoCC {
          packages = with pkgs; [
            typst
          ];
        };
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "typst-build";
          src = ./.;
          buildInputs = [ pkgs.typst ];

          buildPhase = # bash
            ''
              typst compile main.typ output.pdf
            '';
          installPhase = # bash
            ''
                mkdir -p $out
                cp output.pdf $out/
              '';
        };
      }
    );
}
