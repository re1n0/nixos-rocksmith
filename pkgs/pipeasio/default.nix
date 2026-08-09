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
  wine = wineWow64Packages.stable;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "pipeasio";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "M0n7y5";
    repo = "pipeasio";
    rev = "v1.5.0";
    hash = "sha256-5CrcE27vMlRhc+Xu8TSfn1lnF4odAwaZoeh5OvcGi44=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wine
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
    "-DWINE_LIB_ROOT=${wine}/lib/wine"
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
