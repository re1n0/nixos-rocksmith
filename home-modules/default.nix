_: {
  flake.homeManagerModules.default = {
    imports = [
      ./activation.nix
    ];
  };

  flake.homeManagerModules.steam = {
    imports = [
      ./steam.nix
    ];
  };
}
