{
  lib,
  inputs,
  ...
}: {
  imports = [inputs.flake-parts.flakeModules.easyOverlay];

  perSystem = {
    config,
    system,
    pkgs,
    final,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "steam"
          "steam-unwrapped"
          "xwin-fetch-msvc"
          "win-sdk"
        ];
      config.microsoftVisualStudioLicenseAccepted = true;
    };

    overlayAttrs = config.packages;

    packages = {
      pipeasio = final.callPackage ./pipeasio {};

      rs-asio = final.callPackage ./rs_asio {};

      get-steam-app-path = final.callPackage ./get-steam-app-path {};

      patch-rocksmith = final.callPackage ./patch-rocksmith {};
    };
  };
}
