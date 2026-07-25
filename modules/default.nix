{
  lib,
  self,
  ...
}:
{
  flake.nixosModules.default =
    { config, options, ... }:
    {
      imports = [
        ./patch.nix
      ];

      options = {
        programs.steam.rocksmithPatch = {
          enable = lib.mkEnableOption "A set of patches and options to make Rocksmith 2014 compatible with NixOS";

          pipewireLowLatency = {
            quantum = lib.mkOption {
              description = "Minimum quantum to set";
              type = lib.types.ints.positive;
              default = 256;
              example = 128;
            };

            rate = lib.mkOption {
              description = "Nominal graph sample rate";
              type = lib.types.ints.positive;
              default = 48000;
              example = 96000;
            };
          };
        };
      };

      config = lib.mkMerge [
        (lib.optionalAttrs (options ? home-manager) {
          home-manager.sharedModules = [
            self.homeManagerModules.default
          ];
        })
        {
          nixpkgs.overlays = [
            self.overlays.default
          ];
          nix.settings.trusted-public-keys = [
            "nixos-rocksmith.cachix.org-1:gg6dJg9svbP30JVrtFwkCpGVBkHbEwYswGS2VoXJ2qo="
          ];
          nix.settings.substituters = [
            "https://nixos-rocksmith.cachix.org"
          ];
        }
      ];
    };
}
