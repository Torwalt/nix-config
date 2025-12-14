{
  description = "Main flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plugin-telescope-emoji-nvim = {
      url = "github:xiyaowong/telescope-emoji.nvim";
      flake = false;
    };

    plugin-telescope-luasnip-nvim = {
      url = "github:benfowler/telescope-luasnip.nvim";
      flake = false;
    };

    nvim-rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      flake = false;
    };

    nix-colors = { url = "github:misterio77/nix-colors"; };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv-nix = { url = "github:cachix/devenv/v1.10"; };
  };

  outputs =
    inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, ... }:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      extraSpecialArgs = {
        inherit inputs outputs;
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      pkgs = import nixpkgs {
        inherit system;
        overlays = import ./overlays.nix { inherit inputs; };
      };
    in {
      nixosConfigurations = {
        # 'sudo nixos-rebuild --flake .#asusSys switch'
        asusSys = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            inputs.stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            ./hosts/asus/configuration.nix
          ];
        };

        # 'sudo nixos-rebuild --flake .#towerSys switch'
        towerSys = nixpkgs.lib.nixosSystem {
          specialArgs = extraSpecialArgs;
          modules = [
            inputs.stylix.nixosModules.stylix
            ./hosts/tower/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };

        # 'sudo nixos-rebuild --flake .#workSys switch'
        workSys = nixpkgs.lib.nixosSystem {
          specialArgs = extraSpecialArgs;
          modules = [
            inputs.stylix.nixosModules.stylix
            ./hosts/work/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        # 'home-manager switch --flake .#asusHome'
        asusHome = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = extraSpecialArgs;
          modules = [ inputs.stylix.homeModules.stylix ./hosts/asus/home.nix ];
        };

        # 'home-manager switch --flake .#towerHome'
        towerHome = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = extraSpecialArgs;
          modules = [ inputs.stylix.homeModules.stylix ./hosts/tower/home.nix ];
        };

        # 'home-manager switch --flake .#workHome'
        workHome = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = extraSpecialArgs;
          modules = [ inputs.stylix.homeModules.stylix ./hosts/work/home.nix ];
        };
      };

      devShells = {
        x86_64-linux = {
          rust = (import ./shells/rust/rust.nix { inherit pkgs; });
          nodejs = (import ./shells/nodejs.nix { inherit pkgs; });
          azurecli = (import ./shells/azurecli.nix { inherit pkgs; });
          ocaml = (import ./shells/ocaml.nix { inherit pkgs; });
          mise = (import ./shells/mise.nix { inherit pkgs; });
        };
      };

    };
}
