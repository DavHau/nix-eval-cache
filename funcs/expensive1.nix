{
  input,
  nixpkgs,
  pkgs ? import nixpkgs {},
  lib ? pkgs.lib,
}:
let
  makeList = size: list:
    if size > 0
    then makeList (size - 1) (list ++ [input])
    else list;

  initList = makeList 300 [];

  burn = x:
    lib.unique
      (lib.foldl'
        (all: next: all ++ initList)
        []
        initList);

  burnMore = intensity:
    if intensity > 0
    then lib.unique ((burn intensity) ++ burnMore (intensity - 1))
    else burn 0;
in
  builtins.toJSON (burnMore 300)

