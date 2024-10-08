{
  description = "A Python project with virtual environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            python311
            virtualenv
          ];
          shellHook = ''
            if [ ! -d ".venv" ]; then
              echo "Creating virtual environment..."
              python3.11 -m venv .venv
            fi

            echo "Activating virtual environment..."
            source .venv/bin/activate

            # Automatically install requirements if requirements.txt is present
            if [ -f requirements.txt ]; then
              echo "Installing Python dependencies..."
              pip install -r requirements.txt
            fi
          '';
        };
      });
}
