{
  description = "A simple latex flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        latex =
          with pkgs;
          [
            texliveSmall
          ]
          ++ (with pkgs.texlivePackages; [ ]);
      in
      {
        devShell = pkgs.mkShellNoCC {
          packages = [
            latex
            self.packages.watch
          ];
        };
        packages = {
          watch = pkgs.writeShellApplication {
            name = "watch";
            runtimeInputs = [ ];
            text = ''
              latexmk -pdf -pvc $0
            '';
          };
        };
      }
    );
}
