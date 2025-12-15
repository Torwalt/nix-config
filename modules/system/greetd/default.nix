{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland
        '';
        user = "greeter";
      };
    };
  };

  boot.kernelParams = [ "console=tty1" ];

  environment.systemPackages = with pkgs; [ tuigreet ];
}

