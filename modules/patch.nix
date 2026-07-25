{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.steam.rocksmithPatch;

  qr = "${toString cfg.pipewireLowLatency.quantum}/${toString cfg.pipewireLowLatency.rate}";
in
{
  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = lib.mkForce false;

    services.pipewire = {
      enable = true;
      wireplumber.enable = true;

      extraConfig = {
        pipewire."99-low-latency" = {
          "context.properties"."default.clock.min-quantum" = cfg.pipewireLowLatency.quantum;

          "context.modules" = [
            {
              name = "libpipewire-module-rt";
              flags = [
                "ifexists"
                "nofail"
              ];
              args = {
                "nice.level" = -15;
                "rt.prio" = 99;
                "rt.time.soft" = 200000;
                "rt.time.hard" = 200000;
              };
            }
          ];
        };
        client."99-lowlatency"."stream.properties" = {
          "node.latency" = qr;
          "resample.quality" = 1;
        };
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

    environment.systemPackages = [ pkgs.patch-rocksmith ];
  };
}
