#!/usr/bin/env bash
#
# Bootstrap entrypoint for the dedicated server.
# This script helps with any pre-bootstrap requirements
# prior to launching the actual start server commands.

set -xe

echo
echo "Starting server..."
echo

# This comes from the Dockerfile/docker ENV.
cd ${SERVER_INSTALL_DIR}

if [ "$(id -u)" = "0" ]; then
	# Ensure ownership of data files.
	chown -R ${PROC_USER}:${PROC_GROUP} ${SERVER_DATA_DIR}

	echo "Dropping root privileges before invoking server..."
	exec gosu ${PROC_USER} "$@"
fi

exec "$@"
