#!/usr/bin/env bash
set -euo pipefail

image=${1:?usage: $0 IMAGE_REF}
tests_dir=$(cd "$(dirname "$0")" && pwd)
devcontainer() { npx --yes @devcontainers/cli@0.90.0 "$@"; }

workspace=$(mktemp -d)
cleanup() {
    docker ps -aq --filter "label=devcontainer.local_folder=$workspace" | xargs -r docker rm -f >/dev/null
    rm -rf "$workspace"
}
trap cleanup EXIT

cp -r "$tests_dir/project/." "$workspace"
cp "$tests_dir/verify_environment.py" "$workspace"
mkdir "$workspace/.devcontainer"
jq --arg image "$image" '.image = $image' "$tests_dir/../examples/.devcontainer/devcontainer.json" \
    > "$workspace/.devcontainer/devcontainer.json"

devcontainer up --workspace-folder "$workspace"
devcontainer exec --workspace-folder "$workspace" python verify_environment.py
