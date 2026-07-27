{
  description = "Bungos mango desktop";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.wrappers = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # The flake build of mango, so the latest compositor is always available.
  inputs.mangowm = {
    url = "github:mangowm/mango";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # Vicinae, a native launcher bound to super+d.
  inputs.vicinae = {
    url = "github:vicinaehq/vicinae";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    ...
  } @ inputs: let
    # mango is a Wayland compositor, so it is linux only.
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"];
    module = nixpkgs.lib.modules.importApply ./module.nix inputs;
    wrapper = wrappers.lib.evalModule module;
  in {
    wrapperModules = {
      mango = module;
      default = self.wrapperModules.mango;
    };
    wrappers = {
      mango = wrapper.config;
      default = self.wrappers.mango;
    };
    overlays = {
      mango = final: prev: {mango = self.wrappers.mango.wrap {pkgs = final;};};
      default = self.overlays.mango;
    };
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        mango = self.wrappers.mango.wrap {inherit pkgs;};
        default = self.packages.${system}.mango;
      }
    );
    nixosModules = {
      default = self.nixosModules.mango;
      # mango's own module (session, portals, polkit, xwayland), wrapped package as default
      mango = {
        pkgs,
        lib,
        ...
      }: {
        imports = [inputs.mangowm.nixosModules.mango];
        programs.mango.package = lib.mkDefault (self.wrappers.mango.wrap {inherit pkgs;});
      };
    };

    # For development of this package
    devShells = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            just
            nixd
            alejandra
          ];
        };
      }
    );
  };
}
