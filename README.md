# NixOS Rocksmith 🎸

Simplify the setup of Rocksmith 2014 on NixOS!

## ❄️ Flake

In order to use this, you need to include it in your flake's inputs like this:

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-rocksmith = {
      url = "github:re1n0/nixos-rocksmith";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {self, nixpkgs, ...}@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
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

Tips for running Rocksmith 2014 on Linux are available in [linux_rocksmith](https://github.com/theNizo/linux_rocksmith) repo.
Go check them out for potential troubleshooting or setting Launch Options on Steam. 

## ⚠️ Beware

The flake does not provide a binary cache for its packages, thus you'll need to compile them on your own machine.
This might make rebuilding take quite a bit more time after an update.
