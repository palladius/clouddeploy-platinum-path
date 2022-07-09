
source ../../.env.sh ||
    fatal "env file not found. Cant magically configure Skaffold. existing."

echo "Setting SK DFLT REPO to: $SKAFFOLD_DEFAULT_REPO"

# RIP echo_do
echo skaffold --default-repo $SKAFFOLD_DEFAULT_REPO "$@"
     skaffold --default-repo $SKAFFOLD_DEFAULT_REPO "$@"
