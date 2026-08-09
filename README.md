# NixOS Rocksmith 🎸

Simplify the setup of Rocksmith 2014 on NixOS!

## ❄️ Flake

In order to use this, you need to include it in your flake's inputs like this:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # required for activation script and PipeASIO's config.ini
    home-manager.url = "github:nix-community/home-manager";

    # optional for automatic launch options
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  
    nixos-rocksmith.url = "github:re1n0/nixos-rocksmith/release";
  };

  outputs = {self, nixpkgs, ...}@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.steam-config-nix.nixosModules.default
        inputs.nixos-rocksmith.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
```

## ⚙ Example Configuration

```nix
# configuration.nix
{
  # ...

  # Add user to `audio` and `rtkit` groups.
  users.users.<username>.extraGroups = [ "audio" "rtkit" ];

  programs.steam = {
    enable = true;
    rocksmithPatch.enable = true;
  };

  # ...
}
```

## 🔍 Further Instructions

Tips for running Rocksmith 2014 on Linux are available in [linux-rocksmith](https://codeberg.org/nizo/linux-rocksmith) repo.
Go check them out for potential troubleshooting or setting Launch Options on Steam. 
