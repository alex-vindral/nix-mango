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
            key = "c";
            desc = "Center tile";
            cmd = "mmsg dispatch setlayout,center_tile";
          }
          {
            key = "d";
            desc = "Deck";
            cmd = "mmsg dispatch setlayout,deck";
          }
          {
            key = "f";
            desc = "Fair";
            cmd = "mmsg dispatch setlayout,fair";
          }
          {
            key = "g";
            desc = "Grid";
            cmd = "mmsg dispatch setlayout,grid";
          }
          {
            key = "m";
            desc = "Monocle";
            cmd = "mmsg dispatch setlayout,monocle";
          }
          {
            key = "r";
            desc = "Right Tile";
            cmd = "mmsg dispatch setlayout,right_tile";
          }
          {
            key = "s";
            desc = "Scroller";
            cmd = "mmsg dispatch setlayout,scroller";
          }
          {
            key = "t";
            desc = "Tile";
            cmd = "mmsg dispatch setlayout,tile";
          }
          {
            key = "w";
            desc = "Dwindle";
            cmd = "mmsg dispatch setlayout,dwindle";
          }


          {
            key = "D";
            desc = "Vertical Deck";
            cmd = "mmsg dispatch setlayout,vertical_deck";
          }
          {
            key = "F";
            desc = "Vertical fair";
            cmd = "mmsg dispatch setlayout,vertical_fair";
          }
          {
            key = "G";
            desc = "Vertical Grid";
            cmd = "mmsg dispatch setlayout,vertical_grid";
          }
          {
            key = "S";
            desc = "Vertical Scroller";
            cmd = "mmsg dispatch setlayout,vertical_scroller";
          }
          {
            key = "T";
            desc = "Vertical Tile";
            cmd = "mmsg dispatch setlayout,vertical_tile";
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
