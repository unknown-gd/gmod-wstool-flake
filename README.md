## Installation

#### flake.nix
```flake

inputs.gmod-wstool.url = "github:unknown-gd/gmod-wstool-flake/main";

environment.systemPackages = with pkgs; [
  gmod-wstool.packages.${pkgs.stdenv.hostPlatform.system}.default
];

```
