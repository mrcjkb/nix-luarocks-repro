{
  description = "devShell for Lua projects";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }: flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        pkgs = nixpkgs.legacyPackages.${system};
        testpackage = pkgs.lua5_1.pkgs.callPackage ({
          buildLuarocksPackage,
          fetchzip,
          fetchurl,
          lua,
          luaOlder,
          luarocks
        }:
        buildLuarocksPackage {
          pname = "testpackage";
          version = "scm-1";
          knownRockspec = ./testpackage-scm-1.rockspec;
          src = self;
          disabled = luaOlder "5.1";
          propagatedBuildInputs = [lua luarocks];
          }) {};
      in {
        packages.default = testpackage;
        devShells.default = pkgs.mkShell {
          name = "lua devShell";
          buildInputs = with pkgs; [
            (lua5_1.withPackages (ps: with ps; [ luarocks ]))
          ];
        };
      };
    };
}
