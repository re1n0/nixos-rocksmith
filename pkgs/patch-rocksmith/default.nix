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
    version = builtins.substring 0 10 inputs.linux-rocksmith.locked.time;
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
