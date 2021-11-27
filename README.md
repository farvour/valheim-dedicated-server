Valheim Dedicated Server in Docker
==================================

A Valheim dedicated server containerized into a Docker container for
portable deployment.

# Preface
The purpose of this repository is to build and run a container for a
Valheim dedicated server.

# Building the Container
In order to build the container, the easiest way to get started is to use the
docker-compose tool. Lever the docker-compose command to build the dedicated
server container so it is ready to be used. Sometimes you may have to bust the
cache if a new version of the server is released but the Dockerfile is not
changed. This can be accomplished by adding the `--no-cache` flag.

```bash
# Use docker-compose and build the container.
> docker-compose build

# Create initial container but don't start it.
> docker-compose up --no-start
Creating valheim_server_1 ... done

# Check that the image exists.
> docker-compose images

   Container         Repository      Tag       Image Id      Size
------------------------------------------------------------------
valheim_server_1   valheim_server   latest   00164016873a   1.7 GB
```

# Creating and Configuring the Data Volume(s)
In order for any worlds or save game data to persist, we need a volume. There
are many ways to go about adding a persistent volume to your server but this
document will only go over the docker volume method.

If you are using the `docker-compose.yml` file included with this repository,
then all you have to do to prepare the data volume (if it doesn't already
exist) is to bring up a container with a simple run to ensure the unprivleged
user in the container owns the volume's data files. Otherwise the server can't
write to it.

It is generally sufficient to simply change ownership to the unprivileged
user on the mount targets inside the container.

```bash
# Ensure proper data volume file ownership.
docker-compose run \
    -u 0 \
    --rm \
    --entrypoint /bin/bash \
    server \
    -c "chown -R valheim:nogroup /var/opt/valheim/data"
```

# Running the Dedicated Server
Once you've ensured proper ownership of the data volume files, you can then
bring the dedicated server container up. Simply use the docker-compose up
command and it will bootstrap.

```bash
# Attached console mode.
docker-compose up server

# Detatched console mode.
docker-compose up -d server
```

## Test Server
The compose file also contains a server definition for a test instance of
Valheim dedicated server. This is useful for testing or canary changes to the
game server, configuration, mods, etc. By default it is commented out in the
compose file. This means if you end up utilizing it or creating a test instance
of the server that docker-compose may complain about orphaned images or
containers. These can be ignored.
