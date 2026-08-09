_: {
  flake.homeManagerModules.default = {
    imports = [
      ./activation.nix
      ./pipeasio.nix
    ];
  };
}
