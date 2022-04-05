## Cache evaluation of nix functions

This is an implementation of a nix eval cache for individual function calls. It works by offloading the function evaluation into a nix build and caching the result in the nix store.

On subsequent calls of that function the cached value will be read from the store without the function being re-executed.

This only works if:
  - the function is defined inside a single file containing just the function expression
  - the function expects an attrset argument
  - all function args are json serializable
  - the result is json serializable

The function arguments are allowed to reference store paths, therefore you can pass in nixpkgs and other libraries etc. without a problem.

This can be used to cache expensive function calls like parsing lock files etc.

The cost:
  - refactoring your code might be necessary to use this eval cache
  - the initial function evaluation will be more expensive since libraries or nixpkgs might need to be re-imported inside the function (inside the nix build).
  - import from derivation is used in order to read the function result


### Usage example
Given the expensive function is defined in `./expensive.nix` (see example in `./funcs/expensive1.nix`).

Nix repl:
```shell
  nix-repl> cachedCall = (builtins.getFlake "github:davhau/nix-eval-cache").lib.x86_64-linux.cachedCall

  nix-repl> cachedCall ./expensive.nix { nixpkgs = <nixpkgs>; input = "test";}
```
