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

      packages =
        let
          rs-autoconnect = pkgs.callPackage ./rs-autoconnect { inherit inputs; };
        in
        {
          steamRocksmith = pkgs.steam.override {
            extraPkgs =
              pkgs': with pkgs'; [
                wineasio
                patch-rocksmith
              ];
            extraLibraries =
              pkgs': with pkgs'; [
                pipewire.jack
                rs-autoconnect
              ];
          };

          patch-rocksmith = pkgs.callPackage ./patch-rocksmith { inherit inputs; };
        };
    };
}
