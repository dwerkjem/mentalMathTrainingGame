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

### Backup and Restore System

This repo includes a Docker `rclone` service on the same Docker network as `mongo`. The current setup is designed to mount a real `rclone.conf` file into the container instead of performing OAuth inside Docker.

#### Rclone Setup

1. Create or verify your local `rclone` config.

```bash
rclone config file
rclone config show
```

By default, local `rclone` config is stored at `~/.config/rclone/rclone.conf`.

2. Copy your local config into this repo.

```bash
./scripts/use-local-rclone-config.sh
```

This copies your local config to `./rclone/rclone.conf` and updates `.env` so Docker Compose mounts that file into the container.

If your config lives somewhere else, pass the path explicitly:

```bash
./scripts/use-local-rclone-config.sh /path/to/rclone.conf
```

3. Start the services.

```bash
docker compose up -d
```

4. Inspect the `rclone` container logs.

```bash
docker compose logs rclone
docker compose logs -f rclone
```

#### What The Container Does

The `rclone` service mounts the config file at `/config/rclone/rclone.conf` and currently runs:

```bash
rclone config show
```

This is intended as a verification step so you can confirm the container sees the expected remote definitions without opening a web server inside Docker.

#### Files Involved

- `docker-compose.yml`: defines the `mongo`, `mongo-express`, and `rclone` services.
- `.env`: stores the repo-local `RCLONE_CONFIG_PATH` value used by Docker Compose.
- `rclone/rclone.conf`: the config file mounted into the container.
- `scripts/use-local-rclone-config.sh`: helper script that copies your local `rclone.conf` into the repo and updates `.env`.

#### Notes

- Use `docker compose` rather than `docker-compose` if both are available on your machine.
- The `mongo-express` service may log temporary `Connection refused` messages while MongoDB is still starting. That is expected during startup.
- If your local Google Drive remote fails with `401 invalid_client`, the issue is in your local `rclone` OAuth client configuration, not in the Docker container.
