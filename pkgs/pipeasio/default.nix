{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  pipewire,
  wineWow64Packages,
  pkgsCross,
  qt6,
}: let
  mingw64 = pkgsCross.mingwW64;
  mingw32 = pkgsCross.mingw32;
  wine = wineWow64Packages.stable;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "pipeasio";
    version = "1.7.0";

    src = fetchFromGitHub {
      owner = "M0n7y5";
      repo = "pipeasio";
      rev = "v1.7.0";
      hash = "sha256-L7EkqebKAgVtTWFDOH3b0emFE/3Esex8T0xtbOXjNgE=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      pkg-config
      cmake
      wine
      mingw64.stdenv.cc
      mingw32.stdenv.cc
      qt6.wrapQtAppsHook
      qt6.qtbase.dev
    ];

    buildInputs = [
      pipewire
      qt6.qtbase
    ];

    preConfigure = ''
      cp -r ${wine}/lib/wine wine-lib
      chmod -R u+w wine-lib

      if [ -d wine-lib/i386-windows ]; then
        find wine-lib/i386-windows -name '*.a' -print0 \
          | xargs -0 -r i686-w64-mingw32-ranlib
      fi

      if [ -d wine-lib/x86_64-windows ]; then
        find wine-lib/x86_64-windows -name '*.a' -print0 \
          | xargs -0 -r x86_64-w64-mingw32-ranlib
      fi

      cmakeFlags+=("-DWINE_LIB_ROOT=$PWD/wine-lib")
    '';

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DBUILD_WOW64_32=ON"
      "-DWINE_INCLUDE_DIRS=${wine}/include;${wine}/include/wine;${wine}/include/wine/windows"
    ];

    meta = {
      homepage = "https://github.com/M0n7y5/pipeasio";
      changelog = "https://github.com/M0n7y5/pipeasio/releases/tag/v${finalAttrs.version}";
      description = "ASIO to pipewire driver for wine";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [
        rein
      ];
    };
  })
