{
  description = "Main flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    # Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    xdg-desktop-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plugin-vim-delve.url = "github:sebdah/vim-delve";
    plugin-vim-delve.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let inherit (self) outputs;
    in {
      # 'sudo nixos-rebuild --flake .#asusSys switch'
      nixosConfigurations = {
        asusSys = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/asus/configuration.nix ];
        };
      };

      # 'home-manager switch --flake .#asusHome'
      homeConfigurations = {
        asusHome = home-manager.lib.homeManagerConfiguration {
          pkgs =
            nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/asus/home.nix ];
        };
      };

      # 'sudo nixos-rebuild --flake .#towerSys switch'
      nixosConfigurations = {
        towerSys = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          # > Our main nixos configuration file <
          modules = [ ./hosts/tower/configuration.nix ];
        };
      };

      # 'home-manager switch --flake .#towerHome'
      homeConfigurations = {
        towerHome = home-manager.lib.homeManagerConfiguration {
          pkgs =
            nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/tower/home.nix ];
        };
      };
    };
}
