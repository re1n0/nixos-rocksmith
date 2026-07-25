{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rs-asio";
  version = "0.7.4";

  src = fetchzip {
    url = "https://github.com/mdias/rs_asio/releases/download/v${finalAttrs.version}/release-${finalAttrs.version}.zip";
    hash = "sha256-RkaGJsxfeF6vKUqpzk05XNj+08svRZNIruu2i1iqWpc=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    cp $src/avrt.dll $out/lib/
    cp $src/RS_ASIO.dll $out/lib/
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/mdias/rs_asio";
    changelog = "https://github.com/mdias/rs_asio/releases/tag/v${finalAttrs.version}";
    description = "ASIO for Rocksmith 2014";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      rein
    ];
  };
})
