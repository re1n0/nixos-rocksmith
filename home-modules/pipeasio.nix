{
  osConfig,
  lib,
  ...
}: let
  cfg = osConfig.programs.steam.rocksmithPatch;
in
  lib.mkIf cfg.enable {
    xdg.configFile."pipeasio/config.ini".text = lib.generators.toINI {} {
      pipeasio = {
        inputs = 1;
        buffer_size = cfg.pipeasio.buffer;
        sample_rate = cfg.pipeasio.rate;
        input_device = cfg.pipeasio.inputDevice;
        output_device = cfg.pipeasio.outputDevice;
      };
    };
  }
