#[=======================================================================[
# Description : Docker image containing various tooling, such as:
#   - Go
#   - Python
#   - Rust
#   - Linters
#   - Formatters
#   - and many, many, more...
#]=======================================================================]

ARG GO_VERSION=1.24.4
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION} AS go-builder

# Basic good practices
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETOS
ARG TARGETARCH
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}
ENV CGO_ENABLED=0

# Go based tooling
RUN echo \
    # Commands to install
    # Go tools
    github.com/amit-davidson/Chronos/cmd/chronos@latest \
    github.com/loov/goda@latest \
    github.com/rillig/gobco@latest \
    github.com/segmentio/golines@latest \
    github.com/t-yuki/gocover-cobertura@latest \
    golang.org/x/tools/cmd/godoc@latest \
    golang.org/x/tools/cmd/guru@latest \
    gotest.tools/gotestsum@latest \
    honnef.co/go/implements@latest \
    mvdan.cc/gofumpt@latest \
    rsc.io/uncover@latest \
    # Spelling
    github.com/client9/misspell/cmd/misspell@latest \
    # Shell
    mvdan.cc/sh/v3/cmd/shfmt@latest \
    # YAML
    github.com/google/yamlfmt/cmd/yamlfmt@latest \
    # Pipe to 'go install'
    | xargs -n 1 go install

RUN <<EOF
# 1) If $(go env GOHOSTARCH) is equal to $(go env GOARCH), then the binaries will be placed in $(go env GOPATH)/bin
# 2) Else they will wind up in $(go env GOPATH)/bin/$(go env GOOS)_$(go env GOARCH). As such, let's move them out to /go/bin
if [ "$(go env GOHOSTARCH)" != "$(go env GOARCH)" ]; then
    mv "$(go env GOPATH)/bin/$(go env GOOS)_$(go env GOARCH)"/* /go/bin/
    rmdir "$(go env GOPATH)/bin/$(go env GOOS)_$(go env GOARCH)"
fi
EOF

FROM python:3.13 AS cryptography-builder

LABEL maintainer=arash.idelchi

# (root through the build stage, it is anyway multi-stage)
# hadolint ignore=DL3002
USER root

# Basic good practices
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Rust
ARG RUST_DIR=/opt/rust
RUN mkdir -p ${RUST_DIR}
ENV RUSTUP_HOME=${RUST_DIR}/.rustup
ENV CARGO_HOME=${RUST_DIR}/.cargo
RUN wget -qO- https://sh.rustup.rs | bash -s -- -y --profile minimal
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Update pip & allow breaking packages
RUN pip install --no-cache-dir --upgrade pip && \
    echo -e "[global]\nbreak-system-packages=true" >> /etc/pip.conf

RUN \
    if [ "${TARGETARCH}${TARGETVARIANT}" = "armv7" ]; then \
    printf "extra-index-url=https://www.piwheels.org/simple\n" >> /etc/pip.conf ; \
    fi

# Cryptography
# (split up for readability)
# hadolint ignore=DL3059
RUN pip install --no-cache-dir \
    cryptography --no-binary cryptography

FROM python:3.13

ARG TARGETOS
ARG TARGETARCH

LABEL maintainer=arash.idelchi

USER root

# Create User (Debian/Ubuntu)
ARG USER=user
RUN groupadd -r -g 1001 ${USER} && \
    useradd -r -u 1001 -g 1001 -m -c "${USER} account" -d /home/${USER} -s /bin/bash ${USER}

ARG DEBIAN_FRONTEND=noninteractive

# Basic good practices
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Basic tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    build-essential \
    clang \
    # Auxiliaries
    curl \
    wget \
    git \
    ca-certificates \
    # Tools
    graphviz \
    gettext-base \
    moreutils \
    iputils-ping \
    procps \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Java & Node
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends \
    default-jdk \
    nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Various linters & formatters
RUN npm install -g \
    # groovy
    npm-groovy-lint \
    # Jenkinsfile
    jflint \
    # spellcheck
    spellchecker-cli \
    cspell \
    # markdown
    markdownlint-cli \
    # copy-paste
    jscpd \
    # docker
    dockerfile-utils \
    # json
    @prantlf/jsonlint \
    # compound
    prettier

RUN apt-get update && apt-get install -y --no-install-recommends \
    # yaml
    yamllint \
    # shell/bash
    shellcheck \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG HADOLINT_VERSION=v2.12.0
ARG HADOLINT_ARCH=${TARGETARCH/amd64/x86_64}
ARG HADOLINT_ARCH=${HADOLINT_ARCH/arm/arm64}
ARG HADOLINT_ARCH=${HADOLINT_ARCH/arm6464/arm64}
RUN wget -q https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-${HADOLINT_ARCH} -O /usr/local/bin/hadolint && \
    chmod +x /usr/local/bin/hadolint

# Update pip & allow breaking packages
RUN pip install --no-cache-dir --upgrade pip && \
    echo -e "[global]\nbreak-system-packages=true" >> /etc/pip.conf

RUN \
    if [ "${TARGETARCH}${TARGETVARIANT}" = "armv7" ]; then \
    printf "extra-index-url=https://www.piwheels.org/simple\n" >> /etc/pip.conf ; \
    fi

# Spellcheckers
RUN apt-get update && apt-get install -y --no-install-recommends \
    enchant-2 \
    hunspell \
    nuspell \
    aspell \
    hunspell-en-gb \
    && apt-get remove -y hunspell-en-us \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir \
    codespell \
    scspell3k

# Install Task
ARG TASK_VERSION=v3.43.3
ARG TASK_ARCH=${TARGETARCH}
RUN wget -qO- https://github.com/go-task/task/releases/download/${TASK_VERSION}/task_linux_${TASK_ARCH}.tar.gz | tar -xz -C /usr/local/bin

# Python tooling for linting & formatting
# (mistakes brackets for ranges, split up for readability)
# hadolint ignore=SC2102,DL3059
RUN pip install --no-cache-dir \
    pyright \
    ruff \
    # Library stubs for typing
    types-pyyaml

# Copy the cryptography package
COPY --from=cryptography-builder /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/

# Python tooling for packaging
# (split up for readability)
# hadolint ignore=DL3059
RUN pip install --no-cache-dir \
    build \
    twine \
    poetry

# Useful packages
# (split up for readability)
# hadolint ignore=DL3059
RUN pip install --no-cache-dir \
    pytest \
    pydantic \
    requests \
    flask \
    fastapi

# Install Go
COPY --from=golang:1.24.4 /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:$PATH"

ENV GOPATH=/opt/go
RUN mkdir ${GOPATH} && chown -R ${USER}:${USER} ${GOPATH}
ENV PATH="${GOPATH}/bin:$PATH"

USER ${USER}
WORKDIR /home/${USER}

# Run npm-groovy-lint once to download its preferred version of Java
RUN npm-groovy-lint --version

# Install golangci-lint
ARG GOLANGCI_LINT_VERSION=v2.1.6
RUN wget -qO- https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin" ${GOLANGCI_LINT_VERSION}

# Create a local bin directory
RUN mkdir -p ~/.local/bin
ENV PATH="/home/${USER}/.local/bin:$PATH"

# Install jq
ARG JQ_VERSION=1.8.0
ARG JQ_ARCH=${TARGETARCH}
ARG JQ_ARCH=${JQ_ARCH/arm/armhf}
ARG JQ_ARCH=${JQ_ARCH/armhf64/arm64}
RUN wget -q https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${JQ_ARCH} -O ~/.local/bin/jq && \
    chmod +x ~/.local/bin/jq

# Install yq
ARG YQ_VERSION=v4.45.4
RUN wget -qO- https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz | tar -xz -C /tmp && \
    mv /tmp/yq_linux_amd64 ~/.local/bin/yq

# Install typos-cli
ARG TYPOS_VERSION=v1.33.1
ARG TYPOS_ARCH=${TARGETARCH/amd64/x86_64}
ARG TYPOS_ARCH=${TYPOS_ARCH/arm64/aarch64}
RUN wget -qO- https://github.com/crate-ci/typos/releases/download/${TYPOS_VERSION}/typos-${TYPOS_VERSION}-${TYPOS_ARCH}-unknown-linux-musl.tar.gz | tar -xz -C ~/.local/bin

# Copy the tools from the build stages
COPY --from=go-builder /go/bin/* /usr/local/bin/

# Install wslint
RUN curl -sSL https://raw.githubusercontent.com/idelchi/wslint/refs/heads/dev/install.sh | sh -s -- -d ~/.local/bin

# Reroute cache to /tmp
ENV NPM_CONFIG_CACHE=/tmp/.npm
ENV XDG_CACHE_HOME=/tmp/.cache
ENV MYPY_CACHE_DIR=/tmp/.mypy_cache
ENV RUFF_CACHE_DIR=/tmp/.ruff_cache
ENV TASK_TEMP_DIR=/tmp/.task

# Timezone
ENV TZ=Europe/Zurich

# Embed the project
ENV DEVENV=/home/${USER}
COPY --chown=${USER}:${USER} . ${DEVENV}
RUN sed -i 's#^DEVENV=.*#DEVENV='"${DEVENV}"'#' ${DEVENV}/.env

# TODO: Install "Mega-Linter"?

# Clear the base image entrypoint
ENTRYPOINT []
CMD ["/bin/bash"]
