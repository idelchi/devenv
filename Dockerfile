#[=======================================================================[
# Description : Docker image containing various tooling, such as:
#   - Go
#   - Python
#   - Linters
#   - Formatters
#]=======================================================================]

FROM ubuntu:22.04

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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Update node to version 14
RUN curl -sL https://deb.nodesource.com/setup_19.x | bash -
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-jre \
    nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Various linters & formatters
RUN npm install -g \
    # groovy
    npm-groovy-lint \
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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

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
    wget \
    apt-transport-https \
    software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb" && \
    dpkg -i packages-microsoft-prod.deb && \
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

# Create CI User (Debian/Ubuntu)
RUN groupadd -r -g 1001 user && \
    useradd -r -u 1001 -g 1001 -m -c "user account" -d /home/user -s /bin/bash user

# Python tooling
# hadolint ignore=SC2102
RUN pip install --no-cache-dir \
    prospector[with_everything] \
    pyright \
    black \
    isort

ENV NPM_CONFIG_CACHE=/tmp/.npm
ENV XDG_CONFIG_HOME=/tmp/.config
ENV XDG_CACHE_HOME=/tmp/.cache
ENV MYPY_CACHE_DIR=/tmp/.mypy_cache

# Install Go
ARG GO_VERSION=go1.20.2.linux-amd64
RUN wget -qO- https://go.dev/dl/${GO_VERSION}.tar.gz | tar -xz -C /usr/local
ENV PATH="/usr/local/go/bin:$PATH"

ENV GOPATH=/opt/go
RUN mkdir ${GOPATH} && chown -R user:user ${GOPATH}
ENV PATH="${GOPATH}/bin:$PATH"

USER user
WORKDIR /home/user

# Go tooling
RUN echo \
    # Commands to install
    github.com/go-task/task/v3/cmd/task@latest \
    golang.org/x/tools/cmd/godoc@latest \
    gotest.tools/gotestsum@latest  \
    github.com/t-yuki/gocover-cobertura@latest \
    github.com/client9/misspell/cmd/misspell@latest  \
    mvdan.cc/gofumpt@latest  \
    mvdan.cc/sh/v3/cmd/shfmt@latest  \
    github.com/loov/goda@latest  \
    github.com/lucasepe/yml2dot@latest  \
    github.com/segmentio/golines@latest  \
    golang.org/x/tools/cmd/guru@latest  \
    honnef.co/go/implements@latest  \
    rsc.io/tmp/uncover@latest \
    # Feed to 'go install'
    | xargs -n 1 go install

ARG GOLANGCI_LINT_VERSION=v1.51.2
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)/bin" ${GOLANGCI_LINT_VERSION}

# Pre-download some useful packages and dependencies
RUN go mod download \
    github.com/stretchr/testify@latest \
    github.com/davecgh/go-spew@latest \
    gopkg.in/yaml.v3@latest \
    github.com/gin-gonic/gin@latest \
    github.com/jinzhu/configor@latest \
    github.com/bmatcuk/doublestar/v4@latest \
    golang.org/x/exp@latest \
    golang.org/x/tools@latest \
    golang.org/x/tools@v0.6.0 \
    golang.org/x/exp@v0.0.0-20230224173230-c95f2b4c22f2 \
    gopkg.in/check.v1@v0.0.0-20161208181325-20d25e280405 \
    bou.ke/monkey@v1.0.2


# Install Rust
USER root
ARG RUST_DIR=/opt/rust
RUN mkdir -p ${RUST_DIR} && chown -R user:user ${RUST_DIR}

USER user
ENV RUSTUP_HOME=${RUST_DIR}/.rustup
ENV CARGO_HOME=${RUST_DIR}/.cargo
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="${CARGO_HOME}/bin:${PATH}"

ENV TZ=Europe/Zurich
