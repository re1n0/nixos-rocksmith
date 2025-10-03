{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.steam.rocksmithPatch;
  package = pkgs.steam.override {
    extraPkgs =
      pkgs': with pkgs'; [
        patch-rocksmith
        wineasio
      ];
    extraLibraries =
      pkgs': with pkgs'; [
        pipewire.jack
        pkgsi686Linux.rs-autoconnect
      ];
  };
in
{
  meta.maintainers = with lib.maintainers; [ rein ];

  options = {
    programs.steam.rocksmithPatch.enable = lib.mkEnableOption ''
      A set of patches and options to make Rocksmith 2014 compatible with NixOS.

      This will disable services.pulseaudio and enable `services.pipewire` alongside `services.pipewire.wireplumber`,
      `services.pipewire.jack`, `services.pipewire.lowLatency` (from nix-gaming) and `security.rtkit`.

      This will also override `pkgs.steam` to include `pipewire.jack`, `wineasio`, `rs-autoconnect` and `patch-rocksmith`.
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.steam.package = lib.mkDefault package;

    services.pulseaudio.enable = lib.mkForce false;

    services.pipewire = {
      enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      lowLatency = {
        enable = true;
        quantum = 256;
        rate = 48000;
      };
    };

    security.rtkit.enable = true;

    security.pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "-";
        value = "unlimited";
      }
      {
        domain = "@audio";
        item = "rtprio";
        type = "-";
        value = "99";
      }
    ];
  };
}
