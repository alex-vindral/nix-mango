inputs: {
  config,
  wlib,
  lib,
  pkgs,
  ...
}: {
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
  '';

  # DE utilities on mango's PATH
  config.runtimePkgs = [
    pkgs.waybar
  ];
}
