{
  steam,
  pipeasio,
  wineWow64Packages,
  extraPkgs ? (_: []),
  extraLibraries ? (_: []),
  ...
} @ args: let
  rocksmithLibs = [pipeasio];

  rocksmithPkgs = [
    pipeasio
    wineWow64Packages.stable
  ];

  upstreamArgs = removeAttrs args [
    "steam"
    "pipeasio"
    "wineWow64Packages"
  ];
in
  steam.override (
    upstreamArgs
    // {
      extraPkgs = pkgs: rocksmithPkgs ++ extraPkgs pkgs;
      extraLibraries = pkgs: rocksmithLibs ++ extraLibraries pkgs;
    }
  )
