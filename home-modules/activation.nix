{
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = osConfig.programs.steam.rocksmithPatch;

  launchScript = pkgs.writeShellApplication {
    name = "launch-rocksmith";

    text = ''
      export PROTON_USE_WOW64=1
      export WINEDLLPATH=/run/host/usr/lib64/wine

      exec "$@"
    '';
  };
in
  lib.mkIf cfg.enable {
    home.activation.patchRocksmith = lib.hm.dag.entryAfter ["writeBoundary"] ''
      steam-run ${lib.getExe pkgs.patch-rocksmith}
    '';

    home.packages = [launchScript];
  }
