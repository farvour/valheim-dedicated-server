Valheim Dedicated Server in Docker
==================================

A Valheim dedicated server containerized into a Docker container for
portable deployment.

# Preface
The purpose of this repository is to build and run a container for a
Valheim dedicated server.

# Building the container
In order to build the container, the easiest way to get started is to use the
docker compose tool. Lever the docker compose command to build the dedicated
server container so it is ready to be used. Sometimes you may have to bust the
cache if a new version of the server is released but the Dockerfile is not
changed. This can be accomplished by adding the `--no-cache` flag.

```bash
# Use docker compose and build the container.
> docker compose build

# Create initial container but don't start it.
> docker compose up --no-start
Creating valheim_server_1 ... done

# Check that the image exists.
> docker compose images

   Container         Repository      Tag       Image Id      Size
------------------------------------------------------------------
valheim_server_1   valheim_server   latest   00164016873a   1.7 GB
```

# Creating and configuring the data volume(s)
In order for any worlds or save game data to persist, we need a volume. There
are many ways to go about adding a persistent volume to your server but this
document will only go over the docker volume method.

If you are using the [docker-compose.yml](./docker-compose.yml) file included
with this repository, then all you have to do to prepare the data volume (if it
doesn't already exist) is to bring up a container with a simple run. The
[entrypoint.sh](./scripts/entrypoint.sh) script will take care of ensuring
proper ownership of the data files.

# Running the dedicated server
The first thing you should do is ensure the environment is customized to your
needs to do things like set the world name, world seed, password and other
options.

## Configuring environment and settings

```bash
export VALHEIM_SERVER_NAME="Valheim"
export VALHEIM_SERVER_WORLD="watermelons"
export VALHEIM_SERVER_PASSWORD="fruity"
```

Now that you've configured your environment, bring the dedicated server
container up. Simply use the `docker compose up` command and it will bootstrap.

If you have specified a world name and seed that does not exist in the data
files yet, it will be generated by the game. Optionally, you may also copy an
existing world into the docker data volume (both `.fwl` and `.db`). Just be sure
to stop the server and then update the `$VALHEIM_SERVER_WORLD` above to reflect
the name of the world files in the data directory `worlds_local/` of the
dedicated server data volume. **You MUST copy both the `.fwl` and `.db` files
and the filenames are case-sensitive!**

```bash
# Attached console mode.
docker compose up server

# Detatched console mode.
docker compose up -d server
```

You can then shut down the server gracefully by sending a SIGINT/SIGTERM. If
running in foreground or console mode a *Ctrl+C* should invoke this. If you
run `docker compose stop server`, then that will stop it gracefully for you.

## Test server
The compose file also contains a server definition for a test instance of
Valheim dedicated server. This is useful for testing or canary changes to the
game server, configuration, mods, etc. By default it is commented out in the
compose file. This means if you end up utilizing it or creating a test instance
of the server that docker compose may complain about orphaned images or
containers. These can be ignored.
