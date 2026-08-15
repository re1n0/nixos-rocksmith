{
  self,
  lib,
  ...
}:
{
  flake.homeManagerModules.default = { osConfig, ... }: {
    imports = [
      ./activation.nix
      ./pipeasio.nix
    ];

    nixpkgs.overlays = lib.mkIf (!(osConfig.home-manager.useGlobalPkgs or false)) [
      self.overlays.default
    ];
  };
}
