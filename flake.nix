{
  description = "Flake for an easy Rocksmith 2014 setup on NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default-linux";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;

      imports = [
        ./home-modules
        ./modules
        ./pkgs
      ];

      perSystem = {
        pkgs,
        lib,
        ...
      }: {
        formatter = pkgs.treefmt.withConfig {
          runtimeInputs = [pkgs.alejandra pkgs.ruff];
          settings = {
            on-unmatched = "info";
            formatter.alejandra = {
              command = "alejandra";
              includes = ["*.nix"];
            };
            formatter.ruff = {
              command = pkgs.writeShellScript "ruff-format" ''
                ${lib.getExe pkgs.ruff} check "$@"
                ${lib.getExe pkgs.ruff} format "$@"
              '';
              includes = ["*.py"];
            };
          };
        };
      };
    };
}
