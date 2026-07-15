{
  description = "Isolated PostgreSQL + PostGIS Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      # Define the library helper locally within this flake's scope
      mkPostgresGis =
        {
          pkgs,
          pgDataDir ? "$PWD/.direnv/postgres",
          pgPort ? 5432,
        }:
        let
          postgresDb = pkgs.postgresql_18.withPackages (ps: [ ps.postgis ]);

          # Define real executable scripts instead of aliases
          pg-start = pkgs.writeShellScriptBin "pg-start" ''
            ${postgresDb}/bin/pg_ctl -l "$PGLOG" -o "-p $PGPORT" -w start
          '';
          pg-stop = pkgs.writeShellScriptBin "pg-stop" ''
            ${postgresDb}/bin/pg_ctl -m fast -w stop
          '';
          pg-status = pkgs.writeShellScriptBin "pg-status" ''
            ${postgresDb}/bin/pg_ctl status
          '';
          pg-console = pkgs.writeShellScriptBin "pg-console" ''
            ${postgresDb}/bin/psql -p "$PGPORT" "$@"
          '';
        in
        {
          packages = [
            postgresDb
            pg-start
            pg-stop
            pg-status
            pg-console

          ];

          shellHook = ''
                  export PGDATA="${pgDataDir}"
            export PGPORT=${toString pgPort}
            export PGLOG="$PGDATA/postgres.log"

            if [ ! -d "$PGDATA" ]; then
              echo "Initializing local PostgreSQL with PostGIS in $PGDATA..."
              ${postgresDb}/bin/initdb --locale=C --encoding=UTF8
              
              echo "host all all all trust" >> "$PGDATA/pg_hba.conf"
              echo "local all all trust" >> "$PGDATA/pg_hba.conf"
              
              ${postgresDb}/bin/pg_ctl -o "-p $PGPORT" -w start
              ${postgresDb}/bin/createdb -p $PGPORT $USER
              ${postgresDb}/bin/psql -p $PGPORT -d $USER -c "CREATE EXTENSION IF NOT EXISTS postgis;"
              ${postgresDb}/bin/pg_ctl -m fast -w stop
              echo "PostGIS setup complete."
            fi
          '';
        };
    in
    # Merge our system-dependent outputs (like devShells) with our system-agnostic 'lib'
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Use our own local library helper to construct this flake's default shell
        pgEnv = mkPostgresGis { inherit pkgs; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ ] ++ pgEnv.packages;
          shellHook = ''
            ${pgEnv.shellHook}
            echo "⚡ PostgreSQL + PostGIS Shell Active ⚡"
          '';
        };
      }
    ))
    // {
      # Export the 'lib' helper globally at the top level of this sub-flake
      lib = {
        inherit mkPostgresGis;
      };
    };
}
