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
}:
let
  mingw = pkgsCross.mingw32;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pipeasio";

  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "M0n7y5";
    repo = "pipeasio";
    tag = "v1.2.3";
    hash = "sha256-aBrDXxHhbXfoUUGJ2K8I2tqRd227B/0LoTgcyQ9Ih2g=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wineWow64Packages.stable
    mingw.buildPackages.gcc
    mingw.buildPackages.binutils
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    pipewire
    qt6.qtbase
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_WOW64_32=ON"
    "-DWINE_LIB_ROOT=${wineWow64Packages.stable}/lib/wine"
    "-DWINE_INCLUDE_DIRS=${wineWow64Packages.stable}/include/wine;${wineWow64Packages.stable}/include/wine/windows"
  ];

  meta = {
    homepage = "https://github.com/M0n7y5/pipeasio";
    changelog = "https://github.com/M0n7y5/pipeasio/releases/tag/${finalAttrs.src.tag}";
    description = "ASIO to pipewire driver for wine";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      rein
    ];
  };
})
