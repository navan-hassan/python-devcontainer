#!/usr/bin/env bash
set -euo pipefail

image=${1:?usage: $0 IMAGE_REF}
tests_dir=$(cd "$(dirname "$0")" && pwd)

docker run --rm \
    --volume "$tests_dir:/tests:ro" \
    "$image" \
    bash -c "cp -r /tests/project /tmp/project && cd /tmp/project && uv sync --locked && python /tests/verify_environment.py"
