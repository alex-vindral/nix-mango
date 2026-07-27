inputs: {
  config,
  wlib,
  lib,
  pkgs,
  ...
}: let
  mango = inputs.mangowm.packages.${pkgs.stdenv.hostPlatform.system}.mango;

  # leader menu; entries mmsg-dispatch back into the running mango
  whichKeyConfig = (pkgs.formats.yaml {}).generate "mango-which-key.yaml" {
    menu = [
      {
        key = "l";
        desc = "Layout";
        submenu = [
          {
            key = "s";
            desc = "Scroller";
            cmd = "mmsg dispatch setlayout,scroller";
          }
          {
            key = "c";
            desc = "Center tile";
            cmd = "mmsg dispatch setlayout,center_tile";
          }
        ];
      }
    ];
  };

  # launcher on PATH; prepends mango/bin so the menu's mmsg resolves
  mangoLeader = pkgs.writeShellScriptBin "mango-leader" ''
    export PATH=${mango}/bin:$PATH
    exec ${pkgs.wlr-which-key}/bin/wlr-which-key ${whichKeyConfig}
  '';
in {
  imports = [wlib.wrapperModules.mangowc];

  # Use the flake version of mango
  config.package = mango;

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

  config.settings.bindr = [
    # Left-Alt (code:64)
    "ALT,code:64,spawn,${lib.getExe mangoLeader}"
    "NONE,code:64,spawn,${lib.getExe mangoLeader}"
  ];
}
