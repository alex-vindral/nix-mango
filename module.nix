inputs: {
  config,
  wlib,
  lib,
  pkgs,
  ...
}: let
  vicinae = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  imports = [wlib.wrapperModules.mangowc];

  # Use the flake version of mango
  config.package = inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango;

  # Mango config
  config.sourcedFiles = [
    ./mango/appearance.conf
    ./mango/animations.conf
    ./mango/behavior.conf
    ./mango/layouts/scroller.conf
    ./mango/input.conf
    ./mango/binds.conf
  ];

  # Startup components, pinned to exact binaries and shipped with the config
  config.autostart_sh = ''
    ${lib.getExe pkgs.waybar} &
    ${lib.getExe vicinae} server &
  '';

  # DE utilities on mango's PATH
  config.runtimePkgs = [
    pkgs.waybar
    vicinae
  ];

  config.settings.bindr = let
    mangoLeader = import ./mango/leader.nix {
      inherit pkgs;
      mango = config.package;
    };
  in [
    # Left-Alt (code:64)
    "ALT,code:64,spawn,${lib.getExe mangoLeader}"
    # "NONE,code:64,spawn,${lib.getExe mangoLeader}"
  ];
}
