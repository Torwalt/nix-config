{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/start-hyprland
        '';
        user = "greeter";
      };
    };
  };

  boot.kernelParams = [ "console=tty1" ];

  environment.systemPackages = with pkgs; [ tuigreet ];
}

