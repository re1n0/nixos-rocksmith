{
  inputs,
  ...
}:
let
  pins = import ../npins;
in
{
  systems = [ "x86_64-linux" ];

  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem =
    {
      config,
      system,
      pkgs,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
      };

      overlayAttrs = config.packages;

      packages = {
        rs-autoconnect = pkgs.pkgsi686Linux.callPackage ./rs-autoconnect { inherit pins; };

        wineasio-32 = pkgs.pkgsi686Linux.callPackage ./wineasio-32 { };

        patch-rocksmith = pkgs.callPackage ./patch-rocksmith { inherit pins; };
      };
    };
}
