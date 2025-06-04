# rafaelfess/dotfiles

This is my latest dotfiles generation.

It contains **home-manager**, **nixOS** and **nix-darwin** configuration
for several machines and VMs I use.

## Cheatsheet

```sh
sudo nixos-rebuild switch --flake .
sudo nixos-rebuild switch --flake . --impure
```

## First run

```sh
sh <(curl -L https://nixos.org/nix/install)
echo "experimental-features = nix-command flakes">~/.config/nix/nix.conf
```

On macOS, install homebrew too:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Also make sure the terminal being used has full disk access, otherwise you might
get errors like `Could not write domain`.

## Updating

To apply updates, simply run:

```sh
nix develop -c dot-apply

# pull, update flake, clean old, apply
nix develop -c dot-sync
```

## Clean up

```sh
nix develop -c dot-clean
```

## Create release

To create a release, run:

```sh
nix develop -c dot-release
```

## Post first run

## Fish as the default shell

```sh
which fish | sudo tee -a /etc/shells
chsh -s $(which fish)
```

## Keyboard layouts

Add the US layout so input doesn't wait after opening quotes and such.

## Development

To verify the configuration:

```sh
nix flake check --no-write-lock-file --show-trace
```
