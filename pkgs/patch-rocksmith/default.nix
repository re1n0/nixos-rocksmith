{
  lib,
  writeText,
  python3Packages,
  protontricks,
  pipeasio,
  umu-launcher,
  rs-asio,
}: let
  appId = "221680";

  rsAsioIni = writeText "RS_ASIO.ini" (
    lib.generators.toINI {} {
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

  protontricksModule = python3Packages.toPythonModule protontricks;
in
  python3Packages.buildPythonApplication {
    pname = "patch-rocksmith";
    version = "1.0.0";
    pyproject = true;

    src = ./patcher;

    build-system = [python3Packages.setuptools];

    propagatedBuildInputs = [protontricksModule];

    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [pipeasio umu-launcher]}"

      "--add-flags"
      "--appid"
      "--add-flags"
      "${appId}"

      "--add-flags"
      "--rs-asio-dll"
      "--add-flags"
      "${rs-asio}/lib/RS_ASIO.dll"

      "--add-flags"
      "--avrt-dll"
      "--add-flags"
      "${rs-asio}/lib/avrt.dll"

      "--add-flags"
      "--rs-asio-ini"
      "--add-flags"
      "${rsAsioIni}"
    ];

    meta = {
      description = "Script to patch Rocksmith 2014";
      license = lib.licenses.gpl3Plus;
      pname = "patch-rocksmith";
      version = "1.0.0";
      maintainers = with lib.maintainers; [
        rein
      ];
      mainProgram = "patch-rocksmith";
    };
  }
