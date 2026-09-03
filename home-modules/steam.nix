{
  osConfig,
  options,
  lib,
  ...
}: let
  cfg = osConfig.programs.steam.rocksmithPatch;
in {
  config = lib.optionalAttrs (options ? programs.steam.config
    && cfg.enable) {
    programs.steam.config = {
      enable = lib.mkDefault true;
      onSteamRunning = lib.mkDefault "close";

      apps."221680" = {
        name = "Rocksmith 2014";
        env.PROTON_USE_WOW64 = 1;
        env.WINEDLLPATH = "/run/host/usr/lib64/wine";
      };
    };
  };
}
