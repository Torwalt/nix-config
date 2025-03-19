{
  description = "Main flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plugin-telescope-emoji-nvim.url = "github:xiyaowong/telescope-emoji.nvim";
    plugin-telescope-emoji-nvim.flake = false;

    # v1.3.0
    plugin-neotest-golang-nvim.url =
      "github:fredrikaverpil/neotest-golang/ea1c3a7";
    plugin-neotest-golang-nvim.flake = false;
    nvim-rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      flake = false;
    };

    # Newest mpvpaper
    mpvpaper16.url = "github:GhostNaN/mpvpaper/1.6";
    mpvpaper16.flake = false;

    # nix-colors
    nix-colors.url = "github:misterio77/nix-colors";

    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        inherit inputs outputs;
        pkgs-unstable = import nixpkgs-unstable {
          # Refer to the `system` parameter from
          # the outer scope recursively
          inherit system;
          # To use Chrome, we need to allow the
          # installation of non-free software.
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
          modules =
            [ inputs.stylix.homeManagerModules.stylix ./hosts/asus/home.nix ];
        };
      };

      # 'sudo nixos-rebuild --flake .#towerSys switch'
      nixosConfigurations = {
        towerSys = nixpkgs.lib.nixosSystem {
          specialArgs = extraSpecialArgs;
          modules = [
            inputs.stylix.nixosModules.stylix
            ./hosts/tower/configuration.nix
          ];
        };
      };

      # 'home-manager switch --flake .#towerHome'
      homeConfigurations = {
        towerHome = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = extraSpecialArgs;
          modules =
            [ inputs.stylix.homeManagerModules.stylix ./hosts/tower/home.nix ];
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
          modules =
            [ inputs.stylix.homeManagerModules.stylix ./hosts/work/home.nix ];
        };
      };

      ### Shells ###

      devShells.x86_64-linux.rust =
        (import ./shells/rust/rust.nix { inherit pkgs; });

      devShells.x86_64-linux.nodejs =
        (import ./shells/nodejs.nix { inherit pkgs; });

      devShells.x86_64-linux.azurecli =
        (import ./shells/azurecli.nix { inherit pkgs; });

    };
}
