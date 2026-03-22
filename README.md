# Mental Math Training Game

## Goal

The primary goal is to make way for users to quantify their mental math skills and track their growth as well as provide a platform for growing those skills.

### Problem Statement

The main problem is the way mental math is taught is very boring, and I want a way to make it more fun and engaging as well as track progress and compete with others in with in similar ELO.

## Contributing

See [contributing](docs/developmentDocs/contributing.md).

## Installation

Built for and on Linux tested on Debian 13. Ensure you meet the requirements and follow the directions

### Requirements

- Debian 13 or similar Linux distribution
- Nix package manager

### Nix configuration

This repo contains a Nix flake that sets up a development environment with the tools I use for this project. It is not required to use this repo, but it is recommended for ease of development and consistency across machines.

#### Nix Flake Setup

To use the Nix flake, clone this repository to your home directory:

```bash
git clone https://github.com/dwerkjem/nix-config.git
```

Then add the following line to your `~/.config/nix/nix.conf` file:

```nix
experimental-features = nix-command flakes
```

Then set the `# -- USER CONFIGURATION -- #` section of the `flake.nix` to reflect your username and the path to your home directory. For example:

```nix
{
    { home-manager, nixpkgs, ... }:
    let
      # -- USER CONFIGURATION -- #
      # CHANGE THESE TO YOUR OWN VALUES BEFORE USING THIS FLAKE
      fullName = "Derek R. Neilson";
      gitName = "dwerkjem";
      email = "derekrneilson@gmail.com";
      username = "derek";
      # -- END OF USER CONFIGURATION -- #
}
```

Run the following command to apply the configuration:

```bash
update-system
```

**Note:** The `update-system` command is an alias for the following:

```bash
nix run github:nix-community/home-manager -- switch --flake $HOME/nix-config#$USER
```

##### PostgreSQL Password Setup

The PostgreSQL configuration in this flake uses a password for authentication. To set the password, create a file at `~/.config/postgresql/role-password` with the desired password and set the permissions to 600:

```bash
PASSWORD='your-strong-password-here'
mkdir -p ~/.config/postgresql
chmod 700 ~/.config/postgresql
printf '%s\n' "$PASSWORD" > ~/.config/postgresql/role-password
chmod 600 ~/.config/postgresql/role-password
```
