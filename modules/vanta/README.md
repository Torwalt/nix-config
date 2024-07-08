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
