{
  lib,
  writeShellApplication,
  ripgrep,
}:
writeShellApplication {
  name = "get-steam-app-path";

  runtimeInputs = [
    ripgrep
  ];

  text = ''
    set -euo pipefail

    appid="''${1:?Usage: get-steam-app-path <appid> [game|prefix]}"
    what="''${2:-game}"

    steam_root="''${STEAM_ROOT:-$HOME/.local/share/Steam}"
    libraryfolders="$steam_root/steamapps/libraryfolders.vdf"

    mapfile -t libraries < <(
      { echo "$steam_root"; rg -oP '"path"\s*"\K[^"]+' "$libraryfolders"; }
    )

    for lib in "''${libraries[@]}"; do
      manifest="$lib/steamapps/appmanifest_$appid.acf"
      if [[ -f "$manifest" ]]; then
        installdir=$(rg -oP '"installdir"\s*"\K[^"]+' "$manifest")
        case "$what" in
          game)   echo "$lib/steamapps/common/$installdir" ;;
          prefix) echo "$lib/steamapps/compatdata/$appid/pfx" ;;
          *) echo "Unknown target: $what (use 'game' or 'prefix')" >&2; exit 1 ;;
        esac
        exit 0
      fi
    done

    echo "AppID $appid not found in any Steam library" >&2
    exit 1
  '';

  meta = {
    description = "Script to retrieve Steam application paths";
    license = lib.licenses.gpl3Plus;
    pname = "get-steam-app-path";
    version = "0.1.0";
    maintainers = with lib.maintainers; [
      rein
    ];

    mainProgram = "get-steam-app-path";
  };
}
