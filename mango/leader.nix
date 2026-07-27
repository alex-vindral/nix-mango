{
  pkgs,
  mango,
}: let
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
in
  pkgs.writeShellScriptBin "mango-leader" ''
    export PATH=${mango}/bin:$PATH
    # Only one leader menu at a time. Flock holds the lock for the lifetime of
    # wlr-which-key, so extra key presses while it is open become no-ops.
    exec ${pkgs.util-linux}/bin/flock -n ''${XDG_RUNTIME_DIR:-/tmp}/mango-leader.lock \
      ${pkgs.wlr-which-key}/bin/wlr-which-key ${whichKeyConfig}
  ''
