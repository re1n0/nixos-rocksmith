{
  lib,
  self,
  ...
}: {
  flake.nixosModules.default = {options, ...}: {
    imports = [
      ./patch.nix
    ];

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
