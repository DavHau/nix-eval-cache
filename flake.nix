{
  description = "Cache evaluation of nix functions";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    self,
  } @ inp: let
    l = builtins // nixpkgs.lib;
    supportedSystems = ["x86_64-linux"];

    forAllSystems = f: l.genAttrs supportedSystems
      (system: f system nixpkgs.legacyPackages.${system});

  in {

    lib = forAllSystems (system: pkgs: {
      cachedCall =
        (import ./lib.nix {inherit pkgs; lib = nixpkgs.lib;}).cachedCall;
    });

    evalTest = forAllSystems (system: pkgs:
      self.lib.${system}.cachedCall ./funcs/expensive1.nix {
        input = "test";
        nixpkgs = pkgs.path;
      }
    );
  };
}
