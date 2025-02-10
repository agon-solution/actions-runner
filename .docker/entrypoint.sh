#!/bin/sh
# Simple entrypoint script to configure and run a persistent GitHub Actions runner (self-hosted) with DinD support.
#
# Author: Laurent DECLERCQ, AGON PARTNERS INNOVATION AG <l.declercq@agon-innovation.ag
# Version: 20250210

# If RUNNER_NAME isn't set we default to "oci-runner".
RUNNER_NAME=${RUNNER_NAME:-oci-runner}

# We check for the runner the URL.
if [ -z "$RUNNER_URL" ]; then
    echo "The RUNNER_URL environment variable is not set. Exiting..."
    exit 1
fi

# Check for the runner token.
if [ -z "$RUNNER_TOKEN" ]; then
    echo "The RUNNER_TOKEN environment variable is not set. Exiting..."
    exit 1
fi

# Configure the persistent runner.
# -- replace: Replace any existing runner with the same name. This is needed as the container is not persistent and
#             because we don't store the configuration in a volume.
./config.sh --unattended --url "${RUNNER_URL}" --token "${RUNNER_TOKEN}" --replace --disableupdate --name "${RUNNER_NAME}"

# Run the runner.
exec ./run.sh
