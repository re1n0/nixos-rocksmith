{ self, ... }: {
  flake.homeManagerModules.default = {
    imports = [
      ./activation.nix
      ./pipeasio.nix
    ];

    nixpkgs.overlays = [
      self.overlays.default
    ];
  };
}
