{
  lib ? pkgs.lib,
  pkgs ? import <nixpkgs> {},
}: let
  l = lib // builtins;
in {
  cachedCall = funcFile: args:
    let
      jsonArgs = l.toJSON args;
      jsonArgsFile = pkgs.writeText "args.json" jsonArgs;

      resultJson = pkgs.runCommand "result.json"
        {
          nativeBuildInputs = with pkgs;[
            nix
          ];
        }
        ''
          export NIX_CONFIG="${''
            experimental-features = nix-command
          ''}"
          mkdir store
          nix --store ./store eval --offline --impure --raw --expr \
            '
              let
                func = import ${funcFile};

                argsBase = rec {
                  pkgs = import ${pkgs.path} {};
                  lib = pkgs.lib;
                };

                args =
                  argsBase
                  // (builtins.fromJSON (builtins.readFile ${jsonArgsFile}));

                result = func args;

              in
                builtins.toJSON result
            ' \
            > $out
        '';

      in
        l.fromJSON (l.readFile resultJson);

}
