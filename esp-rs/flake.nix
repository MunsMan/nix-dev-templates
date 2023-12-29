{
  description = "A development environment for ESP32 with Rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        embuild = import ./embuild.nix {
          inherit (pkgs) lib;
          inherit pkgs;
        };
        espup = import ./espup.nix { inherit pkgs; };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustup
            cmake
            ninja
            dfu-util
            cargo-generate
            cargo-espflash
            embuild
            espup
          ];
        };
      });
}

