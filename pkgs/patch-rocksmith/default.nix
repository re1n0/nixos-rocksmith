{
  lib,
  fetchFromCodeberg,
  writeText,
  python3Packages,
  protontricks,
  pipeasio,
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
  python3Packages.buildPythonApplication (finalAttrs: {
    pname = "patch-rocksmith";
    version = "1.1.0";
    pyproject = true;

    src = fetchFromCodeberg {
      owner = "rein";
      repo = "linux-rocksmith-patch";
      tag = finalAttrs.version;
      hash = "sha256-QgmMAF6aewcEOU3gaAGxfkoybPsyZoUc2yS6K0Eoytk=";
    };

    build-system = [python3Packages.setuptools];

    propagatedBuildInputs = [protontricksModule];

    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [pipeasio]}"

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
      description = "Automatic patcher for Rocksmith 2014 using RS_ASIO/PipeASIO";
      homepage = "https://codeberg.org/rein/linux-rocksmith-patch";
      license = lib.licenses.gpl3Plus;
      maintainers = with lib.maintainers; [
        rein
      ];
      mainProgram = "patch-rocksmith";
    };
  })
