{
  inputs,
  lib,
  writeShellApplication,
  bash,
  coreutils,
  findutils,
  gawk,
  gnutar,
  unzip,
  wget,
}:
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

  text = inputs.linux-rocksmith + "/scripts/patch-nixos.sh";

  meta = {
    description = "Script to patch Rocksmith 2014";
    homepage = "https://github.com/theNizo/linux_rocksmith";
    license = lib.licenses.gpl3Plus;
    version = inputs.linux-rocksmith.locked.rev or "";
    maintainers = with lib.maintainers; [
      rein
    ];
    mainProgram = "patch-rocksmith";
  };
}
