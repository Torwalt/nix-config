{
  description = "Main flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
      url = "github:danth/stylix/release-25.05";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, ... }:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        inherit inputs outputs;
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in {
      # 'sudo nixos-rebuild --flake .#asusSys switch'
      nixosConfigurations = {
        asusSys = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            inputs.stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            ./hosts/asus/configuration.nix
          ];
        };
      };

      # 'home-manager switch --flake .#asusHome'
      homeConfigurations = {
        asusHome = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = extraSpecialArgs;
          modules = [ inputs.stylix.homeModules.stylix ./hosts/asus/home.nix ];
        };
      };

      # 'sudo nixos-rebuild --flake .#towerSys switch'
      nixosConfigurations = {
        towerSys = nixpkgs.lib.nixosSystem {
          specialArgs = extraSpecialArgs;
          modules = [
            inputs.stylix.nixosModules.stylix
            ./hosts/tower/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };

      # 'home-manager switch --flake .#towerHome'
      homeConfigurations = {
        towerHome = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = extraSpecialArgs;
          modules = [ inputs.stylix.homeModules.stylix ./hosts/tower/home.nix ];
        };
      };

      # 'sudo nixos-rebuild --flake .#workSys switch'
      nixosConfigurations = {
        workSys = nixpkgs.lib.nixosSystem {
          specialArgs = extraSpecialArgs;
          modules = [
            inputs.stylix.nixosModules.stylix
            ./hosts/work/configuration.nix
          ];
        };
      };

      # 'home-manager switch --flake .#workHome'
      homeConfigurations = {
        workHome = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = extraSpecialArgs;
          modules = [ inputs.stylix.homeModules.stylix ./hosts/work/home.nix ];
        };
      };

      ### Shells ###

      devShells.x86_64-linux.rust =
        (import ./shells/rust/rust.nix { inherit pkgs; });

      devShells.x86_64-linux.nodejs =
        (import ./shells/nodejs.nix { inherit pkgs; });

      devShells.x86_64-linux.azurecli =
        (import ./shells/azurecli.nix { inherit pkgs; });

      devShells.x86_64-linux.ocaml =
        (import ./shells/ocaml.nix { inherit pkgs; });

    };
}
