{
  description = "VoidCanvas - a terminal-aesthetic ASCII art editor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        voidcanvas-desktop = pkgs.makeDesktopItem {
          name = "voidcanvas";
          desktopName = "VoidCanvas";
          comment = "Terminal-aesthetic ASCII art editor";
          exec = "void_canvas";
          icon = "voidcanvas";
          categories = [ "Graphics" "2DGraphics" ];
          terminal = false;
          startupWMClass = "void_canvas";
        };

        voidcanvas = pkgs.rustPlatform.buildRustPackage rec {
          pname = "voidcanvas";
          version = "2.1.0";

          src = pkgs.fetchFromGitHub {
            owner = "the-void-fox";
            repo = "VoidCanvas";
            rev = "v${version}";
            hash = "sha256-gyNmCZ9IgLpCXuSETtabnojkI1neGg3wKtZoRgIsccg=";
          };

          cargoHash = "sha256-pbDOwjIttm8o2ZOXoejsPoTDCSMUbOl+9y+kt4RwA5A=";

          nativeBuildInputs = with pkgs; [
            pkg-config
            copyDesktopItems
            autoPatchelfHook
          ];

          runtimeDependencies = with pkgs; [
            wayland
            libxkbcommon
            libGL
            stdenv.cc.cc.lib
          ];

          buildInputs = (with pkgs; [
            libx11
            libxcursor
            libxrandr
            libxi
            libxinerama
          ]) ++ runtimeDependencies;

          desktopItems = [ voidcanvas-desktop ];

          postInstall = ''
            install -Dm644 src/assets/icon.png \
              $out/share/icons/hicolor/256x256/apps/voidcanvas.png
            install -Dm644 src/assets/icon.png \
              $out/share/pixmaps/voidcanvas.png
          '';

          meta = with pkgs.lib; {
            description = "Terminal-aesthetic ASCII art editor built with Rust";
            homepage = "https://github.com/the-void-fox/VoidCanvas";
            license = licenses.mit;
            platforms = platforms.linux;
            mainProgram = "void_canvas";
          };
        };
      in
      {
        packages = {
          default = voidcanvas;
          voidcanvas = voidcanvas;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ voidcanvas ];
          packages = with pkgs; [ cargo rustc ];
        };
      });
}