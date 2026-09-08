{
  writers,
  python3,
  protontricks,
}: let
  protontricksModule = python3.pkgs.toPythonModule protontricks;
in
  writers.writePython3Bin "get-steam-app-path" {
    libraries = [protontricksModule];
    flakeIgnore = ["E501"];
  } (builtins.readFile ./script.py)
