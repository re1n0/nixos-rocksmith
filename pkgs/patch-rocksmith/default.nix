{
  lib,
  writeShellApplication,
  bash,
  coreutils,
  findutils,
  gawk,
  gnutar,
  unzip,
  wget,
  pins,
}:
let
  inherit (pins) linux-rocksmith;
in
writeShellApplication {
  name = "patch-rocksmith";

  runtimeInputs = [
    bash
    coreutils
    findutils
    gawk
    gnutar
    unzip
    wget
  ];

  text = linux-rocksmith + "/scripts/patch-nixos.sh";

  meta = {
    description = "Script to patch Rocksmith 2014";
    homepage = "https://codeberg.org/nizo/linux-rocksmith";
    license = lib.licenses.gpl3Plus;
    pname = "patch-rocksmith";
    version = "0-git+${linux-rocksmith.revision}";
    maintainers = with lib.maintainers; [
      rein
    ];

    postInstall = ''
      mkdir -p $out/share/man/man1
      install -m644 docs/patch-rocksmith.1 $out/share/man/patch-rocksmith.1
    '';

    mainProgram = "patch-rocksmith";
  };
}
