#!/usr/bin/env bash
#
# Customized version of the original Valheim start_server.sh. This script
# prevents any overwrites from the app updating (as indicated in the original
# script's instructions), and also uses appropriate variable replacements
# for dedicated world values from the environment of the running container.

set -e

# Set sane defaults if needed.
: ${VALHEIM_SERVER_NAME:="My Valheim Server"}
: ${VALHEIM_SERVER_WORLD:="dedicated_world"}
: ${VALHEIM_SERVER_PASSWORD:=""}
: ${VALHEIM_SERVER_PUBLIC:="0"} # Private, unlisted by default.

# Dedicated server requires a password.
if [ -z "${VALHEIM_SERVER_PASSWORD}" ]; then
    echo "Password is not set!"
    exit 1
fi

export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

echo "Starting server PRESS CTRL-C to exit"

echo "Name: ${VALHEIM_SERVER_NAME}"
echo "World: ${VALHEIM_SERVER_WORLD}"

SERVER_ARGS=(
    "-savedir \"${SERVER_DATA_DIR}\"" # This comes from Dockerfile/ENV.
    "-name \"${VALHEIM_SERVER_NAME}\""
    "-port 2456"
    "-world \"${VALHEIM_SERVER_WORLD}\""
    "-password \"${VALHEIM_SERVER_PASSWORD}\""
    "-public ${VALHEIM_SERVER_PUBLIC}"
)

set -x

./valheim_server.x86_64 ${SERVER_ARGS[@]}

set +x

export LD_LIBRARY_PATH=$templdpath
