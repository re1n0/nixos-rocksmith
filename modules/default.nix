{ inputs
, self
, ...
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
  };
}
