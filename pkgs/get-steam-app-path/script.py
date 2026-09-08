import sys
from protontricks.steam import (
    find_steam_path,
    get_steam_lib_paths,
    get_steam_apps,
    find_appid_proton_prefix,
    find_proton_app,
)


def main() -> int:
    if len(sys.argv) not in (2, 3):
        print("Usage: get-steam-app-path <appid> [game|prefix|proton]", file=sys.stderr)
        return 1

    appid = int(sys.argv[1])
    what = sys.argv[2] if len(sys.argv) == 3 else "game"

    if what not in ("game", "prefix", "proton"):
        print(f"Unknown target: {what} (use 'game', 'prefix', or 'proton')", file=sys.stderr)
        return 1

    steam_path, steam_root = find_steam_path()
    if steam_path is None:
        print("Could not locate a Steam installation", file=sys.stderr)
        return 1

    steam_lib_paths = get_steam_lib_paths(steam_path)

    if what == "prefix":
        prefix = find_appid_proton_prefix(appid, steam_lib_paths)
        if prefix is None:
            print(f"No compatdata prefix found for appid {appid}", file=sys.stderr)
            return 1
        print(prefix)
        return 0

    steam_apps = get_steam_apps(
        steam_root=steam_root, steam_path=steam_path, steam_lib_paths=steam_lib_paths,
    )

    if what == "proton":
        proton_app = find_proton_app(steam_path=steam_path, steam_apps=steam_apps, appid=appid)
        if proton_app is None:
            print(f"Could not resolve the active Proton installation for appid {appid}", file=sys.stderr)
            return 1
        print(proton_app.install_path)
        return 0

    # what == "game"
    try:
        app = next(a for a in steam_apps if a.appid == appid)
    except StopIteration:
        print(f"AppID {appid} not found in any Steam library", file=sys.stderr)
        return 1
    print(app.install_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
