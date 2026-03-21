{
  stdenv,
  winePackages,
  pkg-config,
  wineasio,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wineasio-32";

  inherit (wineasio)
    version
    src
    buildInputs
    dontConfigure
    ;

  nativeBuildInputs = [
    pkg-config
    winePackages.stable
  ];

  makeFlags = [ "PREFIX=${winePackages.stable}" ];

  buildPhase = ''
    runHook preBuild
    make "''${makeFlags[@]}" 32
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D build32/wineasio32.dll    $out/lib/wine/i386-windows/wineasio32.dll
    install -D build32/wineasio32.dll.so $out/lib/wine/i386-unix/wineasio32.dll.so

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/wineasio/wineasio";
    changelog = "https://github.com/wineasio/wineasio/releases/tag/${finalAttrs.src.tag}";
    description = "32-bit ASIO to JACK driver for WINE";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [
      rein
    ];
  };
})
