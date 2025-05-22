{ pkgs, ... }:

{
  # 1) Turn on the LXD daemon
  virtualisation.lxd = {
    enable = true;
    # optional but recommended sysctl tweaks for production
    recommendedSysctlSettings = true;

    preseed = {
      networks = [{
        name = "lxdbr0";
        type = "bridge";
        config = {
          "ipv4.address" = "10.0.100.1/24";
          "ipv4.nat" = "true";
        };
      }];
      profiles = [{
        name = "default";
        devices = {
          eth0 = {
            name = "eth0";
            network = "lxdbr0";
            type = "nic";
          };
          root = {
            path = "/";
            pool = "default";
            size = "35GiB";
            type = "disk";
          };
        };
      }];
      storage_pools = [{
        name = "default";
        driver = "dir";
        config = { source = "/var/lib/lxd/storage-pools/default"; };
      }];
    };

  };

  # 2) Make sure your user can talk to LXD
  users.users.ada = { extraGroups = [ "lxd" ]; };

  # (If you’d also like the CLI tools available,
  #  but the module will already pull in the lxd package.)
  environment.systemPackages = with pkgs; [ lxd-lts ];
}

