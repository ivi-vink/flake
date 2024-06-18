SSH_OPTIONS := "-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
NIXNAME := "vm-aarch64"

@vm-bootstrap0 diskname ip:
    #!/usr/bin/env bash
    ssh {{SSH_OPTIONS}}  -p22 root@{{ip}} "
        parted /dev/{{diskname}} -- mklabel gpt
        parted /dev/{{diskname}} -- mkpart primary 512MB -8GB
        parted /dev/{{diskname}} -- mkpart primary linux-swap -8GB 100\%
        parted /dev/{{diskname}} -- mkpart ESP fat32 1MB 512MB
        parted /dev/{{diskname}} -- set 3 esp on
        sleep 1
        mkfs.ext4 -L nixos /dev/{{diskname}}p1
        mkswap -L swap /dev/{{diskname}}p2
        mkfs.fat -F 32 -n boot /dev/{{diskname}}p3
        sleep 1
        mount /dev/disk/by-label/nixos /mnt
        mkdir -p /mnt/boot
        mount /dev/disk/by-label/boot /mnt/boot
        nixos-generate-config --root /mnt
        sed --in-place '/system\.stateVersion = .*/a \
    nix.package = pkgs.nixVersions.latest;\n \
    nix.extraOptions = \"experimental-features = nix-command flakes configurable-impure-env\";\n \
    services.openssh.enable = true;\n \
    services.openssh.settings.PasswordAuthentication = true;\n \
    services.openssh.settings.PermitRootLogin = \"yes\";\n \
    users.users.root.initialPassword = \"root\";\n \
        ' /mnt/etc/nixos/configuration.nix
        nixos-install --no-root-passwd && reboot
    "

# copy the Nix configurations into the VM.
@vm-copy ip:
    rsync -av -e 'ssh {{SSH_OPTIONS}} -p22' \
        --exclude='.git/' \
        --rsync-path="sudo rsync" \
        ./ root@{{ip}}:/nix-config

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
@vm-switch ip: (vm-copy ip)
    ssh {{SSH_OPTIONS}} -p22 root@{{ip}} " \
        sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nix-config#{{NIXNAME}}\" \
    "

# after bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
@vm-bootstrap ip: (vm-switch ip)
    ssh {{SSH_OPTIONS}} -p22 root@{{ip}} " \
        sudo reboot; \
    "
