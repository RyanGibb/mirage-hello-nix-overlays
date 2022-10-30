{ pkgs, stdenv, lib, ocamlPackages, static ? false, doCheck, nix-filter }:

with ocamlPackages;

{
  hello-spt = buildDunePackage {
    pname = "hello-spt";
    version = "0.0.1-dev";

    src = ./.;

    nativeBuildInputs = [ ocaml dune findlib pkgs.solo5 ];
    propagatedBuildInputs = [
      duration 
      lwt 
      mirage 
      mirage-bootvar-solo5 
      mirage-clock-solo5
      mirage-logs 
    #   mirage-runtime 
      mirage-solo5
      mirage-time
      # TODO use nixpkgs solo5?
      # solo5-elftool
    ];
    inherit doCheck;

    # preBuild = ''
    #   export OCAMLFIND_CONF=\"${ocaml-solo5}/lib/findlib.conf
    # '';

    # dune build -p ${args.pname} ''${enableParallelBuilding:+-j $NIX_BUILD_CORES} -x ${crossName}
    buildPhase = ''
      runHook preBuild
      dune build
      runHook postBuild
    '';

    meta = {
      description = "Client library for HTTP/1.X / HTTP/2 written entirely in OCaml.";
      license = lib.licenses.bsd3;
      mainProgram = "hello";
    };
  };
}