{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.steam.rocksmithPatch;
in
{
  options = {
    programs.steam.rocksmithPatch = {
      enable = lib.mkEnableOption "A set of patches and options to make Rocksmith 2014 compatible with NixOS";

      pipeasio = {
        buffer = lib.mkOption {
          description = "Buffer size";
          type = lib.types.ints.positive;
          default = 256;
          example = 128;
        };

        rate = lib.mkOption {
          description = "Nominal graph sample rate";
          type = lib.types.ints.positive;
          default = 48000;
          example = 96000;
        };

        inputDevice = lib.mkOption {
          description = "ALSA input device";
          type = lib.types.str;
          default = "";
          example = "alsa_input.usb-BEHRINGER_UMC404HD_192k-00.HiFi__Mic1__source";
        };

        outputDevice = lib.mkOption {
          description = "ALSA output device";
          type = lib.types.str;
          default = "";
          example = "alsa_output.usb-BEHRINGER_UMC404HD_192k-00.HiFi__Line1__sink";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.pulseaudio.enable = lib.mkForce false;

        services.pipewire = {
          enable = true;
          wireplumber.enable = true;
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

        environment.systemPackages = with pkgs; [
          rtaudio
          patch-rocksmith
        ];
      }

      (lib.optionalAttrs (options ? programs.steam.config) {
        programs.steam.config = {
          enable = true;
          onSteamRunning = "close";

          apps."Rocksmith 2014" = {
            id = 221680;
            env.PROTON_USE_WOW64 = 1;
            env.WINEDLLPATH = "/run/host/usr/lib64/wine";
          };
        };
      })
    ]
  );
}
