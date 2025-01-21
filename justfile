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

@vm-secrets ip:
    # GPG keyring
    rsync -av -e 'ssh {{SSH_OPTIONS}}' \
        --exclude='.#*' \
        --exclude='S.*' \
        $HOME/.gnupg/ root@{{ip}}:~/.gnupg
    # SSH keys
    rsync -av -e 'ssh {{SSH_OPTIONS}}' \
        --exclude='environment' \
        --exclude='ssh_auth_sock' \
        $HOME/.ssh/ root@{{ip}}:~/.ssh
    # Sops keys
    rsync -avr -e 'ssh {{SSH_OPTIONS}}' --relative ~/./.config/sops root@{{ip}}:~

# copy the Nix configurations into the VM.
@vm-copy ip:
    rsync -av -e 'ssh {{SSH_OPTIONS}} -p22' \
        --exclude='.git/' \
        --rsync-path="sudo rsync" \
        ./ root@{{ip}}:/nix-config

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
@vm-switch ip: (vm-copy ip) (vm-secrets ip)
    ssh {{SSH_OPTIONS}} -p22 root@{{ip}} " \
        sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --impure --flake \"/nix-config#{{NIXNAME}}\" \
    "

# after bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
@vm-bootstrap ip: (vm-switch ip)
    ssh {{SSH_OPTIONS}} -p22 root@{{ip}} " \
        sudo reboot; \
    "

@symlinks:
  #!/usr/bin/env bash
  set -x
  ln -sf /nix-config/mut/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
  ! [ -d ~/.config/aerospace ] && ln -sf /nix-config/mut/aerospace ~/.config/aerospace
  ! [ -d ~/.config/ghostty ] && ln -sf /nix-config/mut/ghostty ~/.config/ghostty
  ! [ -d ~/.config/nushell ] && ln -sf /nix-config/mut/nushell ~/.config/nushell
  ! [ -d ~/.config/nvim ] && ln -sf /nix-config/mut/neovim ~/.config/nvim
  ! [ -d ~/.config/k9s ] && ln -sf /nix-config/mut/k9s ~/.config/k9s
  ! [ -d ~/.config/carapace ] && ln -sf /nix-config/mut/carapace ~/.config/carapace
  true
