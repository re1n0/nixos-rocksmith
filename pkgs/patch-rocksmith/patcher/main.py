#!/usr/bin/env python3
import argparse
import os
import shutil
import subprocess
import sys
from protontricks.steam import (
    find_steam_path,
    get_steam_lib_paths,
    get_steam_apps,
    find_appid_proton_prefix,
    find_proton_app,
)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Patch a Steam game with RS_ASIO/PipeASIO"
    )
    parser.add_argument("--appid", type=int, required=True, help="Steam App ID")
    parser.add_argument("--rs-asio-dll", required=True, help="Path to RS_ASIO.dll")
    parser.add_argument("--avrt-dll", required=True, help="Path to avrt.dll")
    parser.add_argument("--rs-asio-ini", required=True, help="Path to RS_ASIO.ini")
    args = parser.parse_args()

    steam_path, steam_root = find_steam_path()
    if not steam_path:
        print("Could not locate a Steam installation", file=sys.stderr)
        return 1

    steam_lib_paths = get_steam_lib_paths(steam_path)
    steam_apps = get_steam_apps(
        steam_root=steam_root,
        steam_path=steam_path,
        steam_lib_paths=steam_lib_paths,
    )

    try:
        app = next(a for a in steam_apps if a.appid == args.appid)
        game_dir = app.install_path
    except StopIteration:
        print(f"AppID {args.appid} not found in any Steam library", file=sys.stderr)
        return 1

    prefix = find_appid_proton_prefix(args.appid, steam_lib_paths)
    if not prefix:
        print(f"No compatdata prefix found for appid {args.appid}", file=sys.stderr)
        return 1

    proton_app = find_proton_app(
        steam_path=steam_path, steam_apps=steam_apps, appid=args.appid
    )
    if not proton_app:
        print(
            f"Could not resolve active Proton installation for appid {args.appid}",
            file=sys.stderr,
        )
        return 1
    proton_path = proton_app.install_path

    if not (
        os.path.isdir(game_dir) and os.path.isdir(prefix) and os.path.isdir(proton_path)
    ):
        print("One or more required directories are missing.", file=sys.stderr)
        return 1

    dry_run = bool(os.environ.get("DRY_RUN_CMD"))

    def copy_file(src, dst):
        if dry_run:
            print(f"DRY_RUN: cp -f {src} {dst}")
        else:
            if os.path.lexists(dst):
                os.remove(dst)

            shutil.copy2(src, dst)
            os.chmod(dst, 0o644)

            print(f"Copied {src} to {dst}")

    copy_file(args.rs_asio_dll, os.path.join(game_dir, "RS_ASIO.dll"))
    copy_file(args.avrt_dll, os.path.join(game_dir, "avrt.dll"))
    copy_file(args.rs_asio_ini, os.path.join(game_dir, "RS_ASIO.ini"))

    env = os.environ.copy()
    env["WINEPREFIX"] = prefix
    env["PROTONPATH"] = proton_path
    env["WINE"] = "umu-run"
    env["GAMEID"] = str(args.appid)

    if dry_run:
        print("DRY_RUN: pipeasio-register")
    else:
        print("Running pipeasio-register...")
        subprocess.run(["pipeasio-register"], env=env, check=True)

    return 0


if __name__ == "__main__":
    sys.exit(main())
