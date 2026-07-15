# PostgreSQL Development Template

A self-contained, isolated PostgreSQL developer environment featuring out-of-the-box PostGIS spatial database support.
It is originally designed to be used for my `innmaps` project.
This environment runs completely in user space (no root or global system services required) by initializing the database cluster directly inside your project's local state.

## Quick Start

To bootstrap a brand new workspace with just this PostgresSQL shell, run:

```bash
nix flake init -t github:MunsMan/nix-dev-templates#postgres
nix develop
```

On your very first run, Nix will download PostgreSQL, initialize the database cluster in .direnv/postgres/, register the PostGIS extension, and drop you into the development shell.


## Import as Reusable Library

You can inject this exact database environment into any other existing Nix project (such as a Rust, Go, or Node workspace) without copy-pasting the setup logic.

1. Add to your project's `flake.nix` inputs

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  
  # Fetch the postgres subdirectory from the templates repo
  postgres-dev = {
    url = "github:MunsMan/nix-dev-templates?dir=postgres";
    inputs.nixpkgs.follows = "nixpkgs"; # Reuses your project's nixpkgs version
  };
};
```

2. Instantiate and merge it in your `devShell`:

```nix
outputs = { self, nixpkgs, postgres-dev, ... }: {
  # Inside your per-system loops:
  let
    pgEnv = postgres-dev.lib.mkPostgresGis { inherit pkgs; };
  in {
    devShells.default = pkgs.mkShell {
      packages = [ ... ] ++ pgEnv.packages;
      
      shellHook = ''
        ${pgEnv.shellHook}
        echo "⚡ Project shell and local Postgres ready!"
      '';
    };
  };
};
```

## Database Controls

Once the development shell is active, these preconfigured commands are available:

|Command|Action|
|:------|:-----|
|`pg-start`| Spins up the PostgreSQL database server in the background.|
|`pg-status`| Checks if the local database server is running. |
|`pg-console`|Opens an interactive `psql` console connected to the default database. |
|`pg-stop`| Gracefully shuts down the background database server.|

### Configuration Details

- Data Directory: `.direnv/postgres/`
- Default Port: `5432`
- Log File: `/direnv/postgres/postgres.log`
