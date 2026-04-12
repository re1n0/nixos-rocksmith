{
  lib,
  stdenv,
  cmake,
  libjack2,
  pins,
}:
let
  inherit (pins) rs-linux-autoconnect;
in
stdenv.mkDerivation {
  pname = "rs-autoconnect";
  inherit (rs-linux-autoconnect) version;

  src = rs-linux-autoconnect;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libjack2
  ];

  installPhase = ''
    mkdir -p $out/lib
    cp librsshim.so $out/lib
  '';

  meta = {
    description = "A shim library to automatically connect Rocksmith 2014 on Linux to pipewire inputs and outputs";
    license = lib.licenses.mit;
    homepage = "https://github.com/KczBen/rs-linux-autoconnect";
    maintainers = with lib.maintainers; [
      rein
    ];
  };
}
