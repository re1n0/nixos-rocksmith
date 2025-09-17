{ config
, pkgs
, lib
, ...
}:
let
  cfg = config.programs.steam.rocksmithPatch;
in
{
  meta.maintainers = with lib.maintainers; [ rein ];

  options = {
    programs.steam.rocksmithPatch.enable = lib.mkEnableOption ''
      A set of patches and options to make Rocksmith 2014 compatible with NixOS.

      This will disable services.pulseaudio and enable `services.pipewire` alongside `services.pipewire.wireplumber`,
      `services.pipewire.jack`, `services.pipewire.lowLatency` (from nix-gaming) and `security.rtkit`.

      This will also change the `programs.steam.package` to `pkgs.steamRocksmith`.
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.steam.package = lib.mkDefault pkgs.steamRocksmith;

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
