# Vanta agent

## build

run from root

    nix-build modules/vanta -o ~/vanta-agent/agent

## Env VARS

VANTA_KEY=
VANTA_OWNER_EMAIL=
VANTA_REGION=

get from https://app.vanta.com/employee/onboarding

adjust config in ~/vanta-agent/etc/vanta.conf

## use

    sudo ./agent/var/vanta/vanta-cli doctor

## full notes

- main dep is osquery which needs to be patched by autoPatchelfHook
- use the derivation from `modules/vanta/derivation.nix`
- build using `sudo nix-build modules/vanta -o /var/vanta`
- enable osquery sys pkg see `hosts/work/configuration.nix`
  - make sure to autoload the osquery-vanta.ext
- also, the osquery log must exist
- now you have to "manually" register, you could write a script tho aswell
  - cd into vanta agent install dir
  - run sudo ./vanta-cli doctor
    - make sure everything works but the node part
  - start the vanta launcher => sudo ./launcher
  - run sudo ./vanta-cli check-registration
    - should work now
  - run sudo ./vanta-cli register (with secret etc)
  - run sudo ./vanta-cli doctor again, now everything should be green and your
    machine should be enrolled

apparently here someone made a derivation aswell https://www.reddit.com/r/NixOS/comments/1da1dan/comment/l7lhour/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button

