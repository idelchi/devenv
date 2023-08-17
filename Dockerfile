#[=======================================================================[
# Description : Docker image containing various tooling, such as:
#   - Go
#   - Python
#   - Rust
#   - Linters
#   - Formatters
#]=======================================================================]

FROM debian:bookworm

LABEL maintainer=arash.idelchi

USER root

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
    iputils-ping \
    gettext-base \
    moreutils \
    tree \
    # Editors
    ne \
    nano \
    vim \
    neovim \
    # ssh
    openssh-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Java & Node (version 11 of Java due to npm-groovy-lint)
RUN echo "deb http://deb.debian.org/debian/ bullseye main" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    rm /etc/apt/sources.list
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    dockerfilelint \
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

# Powershell
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    apt-transport-https \
    && curl https://packages.microsoft.com/keys/microsoft.asc | gpg --yes --dearmor --output /usr/share/keyrings/microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list' && \
    apt-get update && apt-get install -y --no-install-recommends \
    powershell \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# .NET
RUN apt-get update && apt-get install -y --no-install-recommends \
    dotnet-runtime-7.0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ansible
RUN pip install --no-cache-dir ansible

# Terraform
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg \
    software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update && apt-get install -y --no-install-recommends \
    terraform \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Various tools
RUN pip install --no-cache-dir \
    # (bind to 0.0.0.0 to allow access from outside)
    grip \
    gitlint \
    sphinx

# Install Task
ARG TASK_VERSION=v3.28.0
RUN wget -qO- https://github.com/go-task/task/releases/download/${TASK_VERSION}/task_linux_amd64.tar.gz | tar -xz -C /usr/local/bin

# Create CI User (Debian/Ubuntu)
ARG USER=user
RUN groupadd -r -g 1001 ${USER} && \
    useradd -r -u 1001 -g 1001 -m -c "${USER} account" -d /home/${USER} -s /bin/bash ${USER}

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
ARG GO_VERSION=go1.21.0.linux-amd64
RUN wget -qO- https://go.dev/dl/${GO_VERSION}.tar.gz | tar -xz -C /usr/local
ENV PATH="/usr/local/go/bin:$PATH"

ENV GOPATH=/opt/go
RUN mkdir ${GOPATH} && chown -R ${USER}:${USER} ${GOPATH}
ENV PATH="${GOPATH}/bin:$PATH"

USER ${USER}
WORKDIR /home/${USER}

# Go tooling
RUN echo \
    # Commands to install
    golang.org/x/tools/cmd/godoc@latest \
    gotest.tools/gotestsum@latest \
    github.com/t-yuki/gocover-cobertura@latest \
    github.com/client9/misspell/cmd/misspell@latest \
    mvdan.cc/gofumpt@latest \
    mvdan.cc/sh/v3/cmd/shfmt@latest \
    github.com/loov/goda@latest \
    github.com/lucasepe/yml2dot@latest \
    github.com/segmentio/golines@latest \
    golang.org/x/tools/cmd/guru@latest \
    honnef.co/go/implements@latest \
    rsc.io/tmp/uncover@latest \
    github.com/rillig/gobco@latest \
    github.com/mikefarah/yq/v4@latest \
    github.com/bronze1man/yaml2json@latest \
    github.com/idelchi/wslint/cmd/wslint@dev \
    # Feed to 'go install'
    | xargs -n 1 go install

# Install golangci-lint
ARG GOLANGCI_LINT_VERSION=v1.54.1
RUN wget -qO- https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin" ${GOLANGCI_LINT_VERSION}
# Pre-download some useful packages and dependencies
RUN go mod download \
    github.com/stretchr/testify@latest \
    github.com/gin-gonic/gin@latest \
    github.com/bmatcuk/doublestar/v4@latest \
    gopkg.in/yaml.v3@latest \
    github.com/fatih/color@latest \
    github.com/jinzhu/configor@latest \
    github.com/davecgh/go-spew@latest \
    github.com/natefinch/atomic@latest \
    github.com/mattn/go-colorable@v0.1.13 \
    github.com/mattn/go-isatty@v0.0.17 \
    github.com/pmezard/go-difflib@v1.0.0 \
    golang.org/x/sys@v0.11.0 \
    golang.org/x/exp@latest \
    golang.org/x/tools@latest \
    gopkg.in/check.v1@v0.0.0-20161208181325-20d25e280405 \
    bou.ke/monkey@latest

# Reroute cache to /tmp
ENV NPM_CONFIG_CACHE=/tmp/.npm
ENV XDG_CONFIG_HOME=/tmp/.config
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
