{
  inputs,
  lib,
  pkgsi686Linux,
}:
pkgsi686Linux.stdenv.mkDerivation (finalAttrs: {
  pname = "rs-autoconnect";
  version = "1.1.1";

  src = inputs.rs-linux-autoconnect;

  nativeBuildInputs = [
    pkgsi686Linux.cmake
  ];

  buildInputs = [
    pkgsi686Linux.jack2
  ];

  installPhase = ''
    mkdir -p $out/lib
    cp librsshim.so $out/lib
  '';

  meta = {
    description = "A shim library to automatically connect Rocksmith 2014 on Linux to pipewire inputs and outputs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      rein
    ];
  };
})
