{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland
        '';
        user = "greeter";
      };
    };
  };

  boot.kernelParams = [ "console=tty1" ];

  environment.systemPackages = with pkgs; [ greetd.tuigreet ];
}

