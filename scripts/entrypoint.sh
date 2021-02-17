#!/usr/bin/env bash
#
# Bootstrap entrypoint for the dedicated server.
# This script helps with any pre-bootstrap requirements
# prior to launching the actual start server commands.

set -xe

echo "Starting server..."

# This comes from the Dockerfile/docker ENV.
cd ${SERVER_INSTALL_DIR}

./startserver-1.sh
