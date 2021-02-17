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

export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

echo "Starting server PRESS CTRL-C to exit"

./valheim_server.x86_64 \
    -name "${VALHEIM_SERVER_NAME}" \
    -port 2456 \
    -world "${VALHEIM_SERVER_WORLD}" \
    -password "${VALHEIM_SERVER_PASSWORD}"

export LD_LIBRARY_PATH=$templdpath
