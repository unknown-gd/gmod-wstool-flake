{
  description = "gmod-wstool";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      version = "0.2.6";

      src = pkgs.fetchurl {
        url = "https://github.com/Srlion/gmod-wstool/releases/download/v${version}/gmod-wstool-${version}-1-x86_64.pkg.tar.zst";
        hash = "sha256-KwGsALcw24lZ1wVSAr5u+nuVKFTT8UHGwisKxX6YB90=";
      };
    in
    {
      packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {
        pname = "gmod-wstool";
        inherit version src; # Added src here so Nix knows what to unpack

        nativeBuildInputs = with pkgs; [
          zstd
          gnutar
          autoPatchelfHook
        ];

        buildInputs = with pkgs; [
          stdenv.cc.cc.lib
          libgcc.lib
        ];

        # Removed dontUnpack = true; instead we write a pristine unpackPhase
        unpackPhase = ''
          tar -I zstd -xvf $src
        '';

        installPhase = ''
          mkdir -p $out/bin $out/lib $out/share

          # Copying the directories extracted from the Arch package
          cp -r usr/lib/gmod-wstool $out/lib/
          cp -r usr/share/* $out/share/

          # Symlink the binary to bin so it's in the user's $PATH
          ln -s $out/lib/gmod-wstool/gmod-wstool $out/bin/gmod-wstool
        '';
      };
    };
}
