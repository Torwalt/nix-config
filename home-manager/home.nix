{ pkgs, inputs, ... }:

let
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &

    ${pkgs.waybar}/bin/waybar &

    ${pkgs.dunst}/bin/dunst
  '';
in {
  imports = [
    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    overlays = [
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          vim-delve-nvim = prev.vimUtils.buildVimPlugin {
            name = "vim-delve";
            src = inputs.plugin-vim-delve;
          };
        };
      })
    ];

    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  fonts.fontconfig.enable = true;

  home = {
    username = "ada";
    homeDirectory = "/home/ada";

    packages = with pkgs; [
      gcc
      go
      jq
      keepassxc
      python3
      zsh-vi-mode
      ripgrep
      delve
      gnumake
      nixfmt
      firefox
      pavucontrol
      telegram-desktop

      # Fonts
      fira-code
      fira-code-symbols
      font-awesome
      liberation_ttf
      mplus-outline-fonts.githubRelease
      nerdfonts
      noto-fonts
      noto-fonts-emoji
      proggyfonts
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraLuaConfig = ''
      ${builtins.readFile ../nvim/init.lua}
      ${builtins.readFile ../nvim/plugin/color.lua}
      ${builtins.readFile ../nvim/plugin/comment.lua}
      ${builtins.readFile ../nvim/plugin/coq_nvim.lua}
      ${builtins.readFile ../nvim/plugin/null-ls.lua}
      ${builtins.readFile ../nvim/plugin/nvim-treesitter.lua}
      ${builtins.readFile ../nvim/plugin/telescope.lua}
      ${builtins.readFile ../nvim/plugin/nvim-lspconfig.lua}
    '';

    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      plenary-nvim
      telescope-nvim
      nvim-lspconfig
      null-ls-nvim
      lsp-format-nvim
      coq_nvim
      coq-artifacts
      git-blame-nvim
      comment-nvim
      markdown-preview-nvim
      vim-delve-nvim

      nvim-treesitter.withAllGrammars
    ];

    extraPackages = with pkgs; [ nil luajitPackages.lua-lsp python3 gopls ];
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Alexander Dadiani";
    userEmail = "alexdadiani1994@gmail.com";
  };

  # In order for .profile being updated.
  programs.bash = { enable = true; };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    defaultKeymap = "viins";
    autocd = true;

    shellAliases = {
      gs = "git status";
      gg = "git checkout";
      ga = "git add .";
      gc = "git commit";
      gam = "git commit --amend";
      gfp = "git push --force-with-lease";
      v = "nvim";
      nix-switch = "home-manager switch --flake ~/nix-config/#ada@ada-machine";
      nix-upgrade = "sudo nixos-rebuild --flake ~/nix-config/#adasys switch";
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "jeffreytse/zsh-vi-mode"; }
        {
          name = "plugins/git";
          tags = [ "from:oh-my-zsh" ];
        }
      ];
    };

    plugins = [{
      name = "powerlevel10k";
      src = pkgs.zsh-powerlevel10k;
      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    }];

    # Profiling
    # initExtraFirst = "zmodload zsh/zprof";
    initExtra = ''
      source ~/nix-config/.p10k.zsh \n
    '';

    # initExtra = ''
    #   source ~/nix-config/.p10k.zsh \n
    #   zprof
    # '';
  };

  programs.tmux = {
    enable = true;
    escapeTime = 0;
    terminal = "screen-256color";
    historyLimit = 100000;
    keyMode = "vi";

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.resurrect
      tmuxPlugins.yank
    ];
  };

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {

      monitor = ",preferred,auto,auto";

      env = "XCURSOR_SIZE,24";

      input = {
        kb_layout = "de";
        kb_options = "caps:swapescape";
        follow_mouse = 1;
        touchpad = { natural_scroll = "no"; };
        sensitivity = 0;
      };

      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = "yes";
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };

      master = { new_is_master = true; };

      gestures = { workspace_swipe = "off"; };

      misc = { force_default_wallpaper = -1; };

      "$mainMod" = "ALT_L";

      bind = [
        # Program shortcuts
        "$mainMod, RETURN, exec, kitty"
        "$mainMod, Q, killactive, "
        "$mainMod, X, exit, "
        "$mainMod, D, exec, rofi -show drun -show-icons"
        "$mainMod, L, exec, swaylock"

        # Window manipulation"
        "$mainMod, V, togglefloating, "
        "$mainMod, T, togglegroup, "
        "$mainMod, N, changegroupactive, "
        "$mainMod, F, fullscreen,"
        "$mainMod, P, pseudo, # dwindle"
        # Move focus with mainMod + arrow keys
        "$mainMod, l, movefocus, l"
        "$mainMod, r, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      exec-once = "${startupScript}/bin/start";
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "262626";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      line-color = "ffffff";
      show-failed-attempts = true;
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        height = 30;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ ];
        modules-right = [
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "temperature"
          "battery"
          "clock"
          "tray"
        ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = false;
          format = "{name}, {icon}";
          "format-icons" = {
            urgent = "";
            focused = "";
            default = "";
          };
        };
        "hyprland/mode" = { format = "<span style=italic>{}</span>"; };
        tray = { spacing = 10; };
        clock = {
          format = "{:%R %d-%m-%Y}";
          "tooltip-format" = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          "format-alt" = "{:%Y-%m-%d}";
        };
        cpu = {
          format = "{usage}% ";
          tooltip = false;
        };
        memory = { format = "{}% "; };
        temperature = {
          "critical-threshold" = 80;
          "format" = "{temperatureC}°C {icon}";
          "format-icons" = [ "" "" "" ];
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          "format-charging" = "{capacity}% ";
          "format-plugged" = "{capacity}% ";
          "format-alt" = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };
        network = {
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ipaddr}/{cidr} ";
          "tooltip-format" = "{ifname} via {gwaddr} ";
          "format-linked" = "{ifname} (No IP) ";
          "format-disconnected" = "Disconnected ⚠";
          "format-alt" = "{ifname}= {ipaddr}/{cidr}";
        };
        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = " {icon} {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            headphone = "";
            "hands-free" = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
      };
    };
  };
}
