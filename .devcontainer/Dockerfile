ARG PYTHON_VERSION=3.12.16
ARG PYTHON_DIGEST=sha256:5e2bdb1b0d542d5039cffb8181c65930093949194a65c365dfb1b0fe13a4fa5b

ARG UV_VERSION=0.13.8
ARG UV_DIGEST=sha256:5cc1805e2426484abca4ad46ea783bab281fdb225fd82d8ce6d66a81254bac85

ARG GH_VERSION=2.104.0
ARG GH_SHA256_AMD64=98cb101ad87dbbd3f6b2f2bfcbd43197ccd07643140121d8a9cfaa91eadbc24e
ARG GH_SHA256_ARM64=cb34cefc6f4e77b90731374a2b737516bb8f3033c6ca46aa949e5344f68069e3

FROM ghcr.io/astral-sh/uv:${UV_VERSION}@${UV_DIGEST} AS uv

FROM scratch AS gh-amd64
ARG GH_VERSION
ARG GH_SHA256_AMD64
ADD --checksum=sha256:${GH_SHA256_AMD64} \
    https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz \
    /gh.tar.gz

FROM scratch AS gh-arm64
ARG GH_VERSION
ARG GH_SHA256_ARM64
ADD --checksum=sha256:${GH_SHA256_ARM64} \
    https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_arm64.tar.gz \
    /gh.tar.gz

ARG TARGETARCH
# hadolint ignore=DL3006
FROM gh-${TARGETARCH} AS gh

FROM docker.io/library/python:${PYTHON_VERSION}-slim-trixie@${PYTHON_DIGEST}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV UV_CACHE_DIR=/home/vscode/.cache/uv \
    UV_PROJECT_ENVIRONMENT=/home/vscode/.venv \
    UV_PYTHON_DOWNLOADS=never \
    VIRTUAL_ENV=/home/vscode/.venv \
    PATH="/home/vscode/.venv/bin:${PATH}"

ARG GH_VERSION
ARG TARGETARCH
# hadolint ignore=DL3008
RUN --mount=type=bind,from=uv,target=/tmp/uv \
    --mount=type=bind,from=gh,target=/tmp/gh \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        git \
        openssh-client \
        sudo \
    # CVE-2026-85091: remove once the python base ships zlib1g 1:1.3.dfsg+really1.3.1-1+deb13u1 or later.
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --only-upgrade \
        zlib1g \
    && rm -rf /var/lib/apt/lists/* \
    && cp /tmp/uv/uv /tmp/uv/uvx /usr/local/bin/ \
    && tar -xzf /tmp/gh/gh.tar.gz -C /usr/local/bin --strip-components=2 --no-same-owner \
        "gh_${GH_VERSION}_linux_${TARGETARCH}/bin/gh" \
    && gh --version \
    # https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
    && groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode \
    && visudo --check --file=/etc/sudoers.d/vscode \
    && runuser -u vscode -- mkdir -p "${UV_CACHE_DIR}" \
    && runuser -u vscode -- uv venv "${VIRTUAL_ENV}" --python /usr/local/bin/python3

# hadolint ignore=DL3066
USER vscode
