#[=======================================================================[
# Description : Docker image containing various tooling, such as:
#   - Go
#   - Python
#   - Rust
#   - Linters
#   - Formatters
#   - and many, many, more...
#]=======================================================================]

FROM python:3.12

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
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-jdk \
    nodejs \
    npm \
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
RUN wget -q https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64 -O /usr/local/bin/hadolint && \
    chmod +x /usr/local/bin/hadolint

# Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Pip override to allow breaking packages
RUN echo -e "[global]\nbreak-system-packages=true" >> /etc/pip.conf

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
ARG TASK_VERSION=v3.37.1
RUN wget -qO- https://github.com/go-task/task/releases/download/${TASK_VERSION}/task_linux_amd64.tar.gz | tar -xz -C /usr/local/bin

# Install Rust
ARG RUST_DIR=/opt/rust
RUN mkdir -p ${RUST_DIR} && chown -R ${USER}:${USER} ${RUST_DIR}

ENV RUSTUP_HOME=${RUST_DIR}/.rustup
ENV CARGO_HOME=${RUST_DIR}/.cargo
RUN wget -qO- https://sh.rustup.rs | bash -s -- -y
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Additional Rust based tools
RUN cargo install \
    typos-cli \
    just

# Python tooling for linting & formatting
# (mistakes brackets for ranges, split up for readability)
# hadolint ignore=SC2102,DL3059
RUN pip install --no-cache-dir \
    prospector[with_everything] \
    pyright \
    black \
    isort \
    ruff \
    # Library stubs for typing
    types-pyyaml

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
ARG GO_VERSION=go1.22.3.linux-amd64
RUN wget -qO- https://go.dev/dl/${GO_VERSION}.tar.gz | tar -xz -C /usr/local
ENV PATH="/usr/local/go/bin:$PATH"

ENV GOPATH=/opt/go
RUN mkdir ${GOPATH} && chown -R ${USER}:${USER} ${GOPATH}
ENV PATH="${GOPATH}/bin:$PATH"

USER ${USER}
WORKDIR /home/${USER}

# Run npm-groovy-lint once to download its preferred version of Java
RUN npm-groovy-lint --version

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
    | xargs -n 1 go install && \
    rm -rf "$(go env GOCACHE)"

# Install golangci-lint
ARG GOLANGCI_LINT_VERSION=v1.58.1
RUN wget -qO- https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin" ${GOLANGCI_LINT_VERSION}

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

# Install wslint
ARG CACHEBUST
# TODO: Implement versioning in wslint instead.
RUN go install -ldflags='-s -w -X "main.version=unofficial & built from dev branch"' github.com/idelchi/wslint@dev

# TODO: Install "Mega-Linter"?

# Clear the base image entrypoint
ENTRYPOINT []
CMD ["/bin/bash"]
