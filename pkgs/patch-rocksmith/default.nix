{
  lib,
  pkgs,
  writeShellApplication,
  coreutils,
  findutils,
  steam-run,
  get-steam-app-path,
  pipeasio,
  rs-asio,
}:
let
  appId = "221680";

  rsAsioIni = pkgs.writeText "RS_ASIO.ini" (
    lib.generators.toINI { } {
      Config = {
        EnableWasapiOutputs = 0;
        EnableWasapiInputs = 0;
        EnableAsio = 1;
      };

      Asio.BufferSizeMode = "driver";

      "Asio.Output" = {
        Driver = "PipeASIO";
        BaseChannel = 0;
        EnableSoftwareEndpointVolumeControl = 1;
        EnableSoftwareMasterVolumeControl = 1;
        SoftwareMasterVolumePercent = 100;
      };

      "Asio.Input.0" = {
        Driver = "PipeASIO";
        Channel = 0;
        EnableSoftwareEndpointVolumeControl = 1;
        EnableSoftwareMasterVolumeControl = 1;
        SoftwareMasterVolumePercent = 100;
      };

      "Asio.Input.1" = {
        Driver = "PipeASIO";
        Channel = 1;
        EnableSoftwareEndpointVolumeControl = 1;
        EnableSoftwareMasterVolumeControl = 1;
        SoftwareMasterVolumePercent = 100;
      };

      "Asio.Input.Mic" = {
        Driver = "PipeASIO";
        Channel = 2;
        EnableSoftwareEndpointVolumeControl = 1;
        EnableSoftwareMasterVolumeControl = 1;
        SoftwareMasterVolumePercent = 100;
      };
    }
  );
in
writeShellApplication {
  name = "patch-rocksmith";

  runtimeInputs = [
    coreutils
    findutils
    steam-run
    get-steam-app-path
    pipeasio
  ];

  text = ''
    GAME_DIR=$(get-steam-app-path ${appId})
    WINEPREFIX=$(get-steam-app-path ${appId} prefix)

    if [ -d "$GAME_DIR" ]; then
      cp -f ${rs-asio}/lib/RS_ASIO.dll "$GAME_DIR/RS_ASIO.dll"
      cp -f ${rs-asio}/lib/avrt.dll "$GAME_DIR/avrt.dll"

      cp -f ${rsAsioIni} "$GAME_DIR/RS_ASIO.ini"

      export WINEPREFIX
      export PIPEASIO_REGISTER_WITHOUT_LOADING=1
      steam-run pipeasio-register
    fi
  '';

  meta = {
    description = "Script to patch Rocksmith 2014";
    license = lib.licenses.gpl3Plus;
    pname = "patch-rocksmith";
    version = "0.1.0";
    maintainers = with lib.maintainers; [
      rein
    ];

    mainProgram = "patch-rocksmith";
  };
}
