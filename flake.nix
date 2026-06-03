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

      # Define runtime dependencies that need to be visible via LD_LIBRARY_PATH
      runtimeLibs = with pkgs; [
        wayland
        libxkbcommon
        libX11
        libXcursor
        libXrandr
        libXi
        vulkan-loader
      ];
    in
    {
      packages.${system}.default = pkgs.stdenvNoCC.mkDerivation {
        pname = "gmod-wstool";
        inherit version src;

        nativeBuildInputs = with pkgs; [
          zstd
          gnutar
          autoPatchelfHook
          makeWrapper
        ];

        buildInputs = [
          pkgs.stdenv.cc.cc.lib
          pkgs.libgcc.lib
        ]
        ++ runtimeLibs;

        unpackPhase = ''
          tar -I zstd -xvf $src
        '';

        installPhase = ''
          mkdir -p $out/bin $out/lib $out/share

          cp -r usr/lib/gmod-wstool $out/lib/
          cp -r usr/share/* $out/share/

          # Wrap the actual binary to inject the runtime path for dlopen
          makeWrapper $out/lib/gmod-wstool/gmod-wstool $out/bin/gmod-wstool \
            --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath runtimeLibs}"

          # Fix the desktop shortcut file accurately
          if [ -f "$out/share/applications/gmod-wstool.desktop" ]; then
            sed -i "s|^Exec=.*|Exec=$out/bin/gmod-wstool|" "$out/share/applications/gmod-wstool.desktop"
          fi
        '';
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/gmod-wstool";
      };
    };
}
