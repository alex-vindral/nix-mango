# Leader-key launcher: a wlr-which-key menu whose entries mmsg-dispatch
# back into the running mango. Takes the mango package so its bin/ can be
# prepended to PATH (that's where the menu's `mmsg` resolves from).
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
    exec ${pkgs.wlr-which-key}/bin/wlr-which-key ${whichKeyConfig}
  ''
