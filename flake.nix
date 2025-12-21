{
  description = "Flake for an easy Rocksmith 2014 setup on NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    linux-rocksmith = {
      url = "github:re1n0/linux_rocksmith";
      flake = false;
    };

    rs-linux-autoconnect = {
      url = "github:KczBen/rs-linux-autoconnect";
      flake = false;
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./modules
        ./pkgs
      ];
    };
}
