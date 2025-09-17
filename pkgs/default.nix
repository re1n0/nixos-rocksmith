{ inputs
, self
, ...
}:
{
  systems = [ "x86_64-linux" ];

  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];

  perSystem =
    { config
    , system
    , pkgs
    , ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
      };

      overlayAttrs = config.packages;

      packages = {
        rs-autoconnect = pkgs.callPackage ./rs-autoconnect { inherit inputs; };

        patch-rocksmith = pkgs.callPackage ./patch-rocksmith { inherit inputs; };
      };
    };
}
