{
  description = "Hello";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.nix-filter.url = "github:numtide/nix-filter";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.ocaml-overlays.url = "github:RyanGibb/nix-overlays";
  inputs.ocaml-overlays.inputs.flake-utils.follows = "flake-utils";
  # make ocaml-overlays follow system nixpkgs
  # TODO use https://github.com/RyanGibb/nix-overlays#alternative-advanced
  inputs.ocaml-overlays.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, ocaml-overlays, flake-utils, nix-filter, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = ocaml-overlays.legacyPackages."${system}".extend (self: super: {
          ocamlPackages = super.ocaml-ng.ocamlPackages_4_14;
        });
      in
      rec {
        packages = {
          native = pkgs.callPackage ./src {
            nix-filter = nix-filter.lib;
            doCheck = false;
          };
          musl64 =
            let
              pkgs' = pkgs.pkgsCross.musl64;
            in
            pkgs'.lib.callPackageWith pkgs' ./src {
              static = true;
              doCheck = false;
              nix-filter = nix-filter.lib;
            };
          solo5 =
            let
              pkgs' = pkgs.pkgsCross.solo5;
            in
            pkgs'.lib.callPackageWith pkgs' ./src {
              doCheck = false;
              nix-filter = nix-filter.lib;
            };
        };
        defaultPackage = packages.native.hello-spt;
        devShell = pkgs.callPackage ./shell.nix { inherit packages; };
      });
}
