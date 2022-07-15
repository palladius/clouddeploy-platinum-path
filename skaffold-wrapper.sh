#!/bin/bash
function _fatal() {
    echo "$*" >&1
    exit 42
}
source .env.sh ||
    _fatal "env file not found. Cant magically configure Skaffold. existing."

echo "Setting SK DFLT REPO to: $SKAFFOLD_DEFAULT_REPO"

# RIP echo_do
echo skaffold --default-repo "$SKAFFOLD_DEFAULT_REPO" "$@"
     skaffold --default-repo "$SKAFFOLD_DEFAULT_REPO" "$@"
