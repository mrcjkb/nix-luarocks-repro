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
        luaPkgs = pkgs.lua5_1.pkgs;

        luarocks-rock = luaPkgs.callPackage ({ buildLuarocksPackage, fetchFromGitHub, fetchurl }:
          buildLuarocksPackage {
            pname = "luarocks";
            version = "3.11.0-1";
            knownRockspec = (fetchurl {
              url    = "mirror://luarocks/luarocks-3.11.0-1.rockspec";
              sha256 = "0pi55445dskpw6nhrq52589h4v39fsf23c0kp8d4zg2qaf6y2n38";
            }).outPath;
            src = fetchFromGitHub {
              owner = "luarocks";
              repo = "luarocks";
              rev = "v3.11.0";
              hash = "sha256-mSwwBuLWoMT38iYaV/BTdDmmBz4heTRJzxBHC0Vrvc4=";
            };
            meta = {
              homepage = "http://www.luarocks.org";
              description = "A package manager for Lua modules.";
              license.fullName = "MIT";
            };
          }) {};

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
          propagatedBuildInputs = [
            lua 
            # luarocks-rock # comment this out and it will work
            luarocks
          ];
          }) {};
      in {
        packages = {
          default = testpackage;
          inherit testpackage luarocks-rock;
        };
        devShells.default = pkgs.mkShell {
          name = "lua devShell";
          buildInputs = with pkgs; [
            (lua5_1.withPackages (ps: with ps; [ luarocks ]))
          ];
        };
      };
    };
}
