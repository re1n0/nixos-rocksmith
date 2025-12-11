{
  inputs,
  self,
  ...
}:
{
  flake.nixosModules.default = {
    imports = [
      inputs.nix-gaming.nixosModules.pipewireLowLatency
      ./steamRocksmithPatch.nix
    ];

    nixpkgs.overlays = [
      self.overlays.default
    ];

    nix.settings.trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nixos-rocksmith.cachix.org-1:gg6dJg9svbP30JVrtFwkCpGVBkHbEwYswGS2VoXJ2qo="
    ];

    nix.settings.substituters = [
      "https://nix-gaming.cachix.org"
      "https://nixos-rocksmith.cachix.org"
    ];
  };
}
