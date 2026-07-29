{
  description = "Main flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

    plugin-neotest-golang-nvim = {
      url = "github:fredrikaverpil/neotest-golang/v2.6.0";
      flake = false;
    };

    plugin-nvim-treesitter-textobjects = {
      url = "github:nvim-treesitter/nvim-treesitter-textobjects?ref=main";
      flake = false;
    };

    plugin-meow-review-nvim = {
      url = "github:retran/meow.review.nvim";
      flake = false;
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv-nix = {
      url = "github:cachix/devenv/v1.10";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      pre-commit-hooks,
      sops-nix,
      ...
    }:
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
      nixfmt-tree = pkgs.writeShellApplication {
        name = "nixfmt-tree";
        runtimeInputs = with pkgs; [
          findutils
          nixfmt
          ripgrep
        ];
        text = ''
          if [ "$#" -eq 0 ]; then
            rg --files -g '*.nix' -0 | xargs -0 nixfmt
          else
            nixfmt "$@"
          fi
        '';
      };
      hooks = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks.nixfmt.enable = true;
      };
    in
    {
      checks.${system}.pre-commit-check = hooks;

      formatter.${system} = nixfmt-tree;

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
          modules = [
            inputs.stylix.homeModules.stylix
            ./hosts/asus/home.nix
          ];
        };

        # 'home-manager switch --flake .#towerHome'
        towerHome = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = extraSpecialArgs;
          modules = [
            inputs.stylix.homeModules.stylix
            ./hosts/tower/home.nix
          ];
        };

        # 'home-manager switch --flake .#workHome'
        workHome = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = extraSpecialArgs;
          modules = [
            inputs.stylix.homeModules.stylix
            ./hosts/work/home.nix
          ];
        };
      };

      devShells = {
        x86_64-linux = {
          default = pkgs.mkShell {
            inherit (hooks) shellHook;
            buildInputs = hooks.enabledPackages;
          };
          rust = (import ./shells/rust/rust.nix { inherit pkgs; });
          nodejs = (import ./shells/nodejs.nix { inherit pkgs; });
          azurecli = (import ./shells/azurecli.nix { inherit pkgs; });
          ocaml = (import ./shells/ocaml.nix { inherit pkgs; });
        };
      };

    };
}
