#[=======================================================================[
# Description : Docker image containing various tooling, such as:
#   - Go
#   - Python
#   - Rust
#   - Linters
#   - Formatters
#   - and many, many, more...
#]=======================================================================]

ARG GO_VERSION=1.26.2
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
    github.com/lucasepe/yml2dot@latest \
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

FROM ubuntu:26.04

ARG TARGETOS
ARG TARGETARCH

LABEL maintainer=arash.idelchi

USER root

# (removed fixed UID/GID user creation to make image UID-agnostic)

ARG DEBIAN_FRONTEND=noninteractive

# Basic good practices
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Basic tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools
    build-essential \
    clang \
    python3 \
    python3-pip \
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
    bsdextrautils \
    vim-common \
    coreutils \
    tree \
    default-jdk \
    nodejs \
    npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Various linters & formatters
RUN npm install -g \
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
    @prantlf/jsonlint@16.1.0 \
    # compound
    prettier

RUN apt-get update && apt-get install -y --no-install-recommends \
    # yaml
    yamllint \
    # shell/bash
    shellcheck \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Allow breaking packages
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

# Python tooling for linting & formatting
RUN pip install --no-cache-dir \
    uv \
    pyright \
    ruff

# Install Go
COPY --from=golang:1.26.2 /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:$PATH"

# Install Rust
COPY --from=rust:1.95 /usr/local/cargo /usr/local/cargo
COPY --from=rust:1.95 /usr/local/rustup /usr/local/rustup
ENV PATH="/usr/local/cargo/bin:$PATH"

# Global bin path (instead of ~/.local/bin)
ENV PATH="/usr/local/bin:$PATH"

# Tool versions
ARG JQ_VERSION=1.8.1
ARG YQ_VERSION=v4.53.2
ARG TYPOS_VERSION=v1.46.0
ARG GOLANGCI_LINT_VERSION=v2.12.1
ARG TASK_VERSION=v3.50.0
ARG HADOLINT_VERSION=v2.14.0
ARG RIPGREP_VERSION=15.1.0
ARG WSLINT_VERSION=v0.0.1

# Install jq
ARG JQ_ARCH=${TARGETARCH}
ARG JQ_ARCH=${JQ_ARCH/arm/armhf}
ARG JQ_ARCH=${JQ_ARCH/armhf64/arm64}
RUN wget -q https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${JQ_ARCH} -O /usr/local/bin/jq && \
    chmod +x /usr/local/bin/jq

# Install yq
RUN wget -qO- https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz | tar -xz -C /tmp && \
    mv /tmp/yq_linux_amd64 /usr/local/bin/yq

# Install typos-cli
ARG TYPOS_ARCH=${TARGETARCH/amd64/x86_64}
ARG TYPOS_ARCH=${TYPOS_ARCH/arm64/aarch64}
RUN wget -qO- https://github.com/crate-ci/typos/releases/download/${TYPOS_VERSION}/typos-${TYPOS_VERSION}-${TYPOS_ARCH}-unknown-linux-musl.tar.gz | tar -xz -C /usr/local/bin

# Install golangci-lint
RUN curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b /usr/local/bin ${GOLANGCI_LINT_VERSION}

# Install Task
ARG TASK_ARCH=${TARGETARCH}
RUN wget -qO- https://github.com/go-task/task/releases/download/${TASK_VERSION}/task_linux_${TASK_ARCH}.tar.gz | tar -xz -C /usr/local/bin

# Install hadolint
ARG HADOLINT_ARCH=${TARGETARCH/amd64/x86_64}
ARG HADOLINT_ARCH=${HADOLINT_ARCH/arm/arm64}
ARG HADOLINT_ARCH=${HADOLINT_ARCH/arm6464/arm64}
RUN wget -q https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-${HADOLINT_ARCH} -O /usr/local/bin/hadolint && \
    chmod +x /usr/local/bin/hadolint

# Install ripgrep
ARG RIPGREP_ARCH=${TARGETARCH/amd64/x86_64}
ARG RIPGREP_ARCH=${RIPGREP_ARCH/arm64/aarch64}
ARG RIPGREP_LIBC=musl
RUN if [ "$RIPGREP_ARCH" = "aarch64" ]; then \
    RIPGREP_LIBC=gnu; \
    fi && \
    wget -qO- https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION}-${RIPGREP_ARCH}-unknown-linux-${RIPGREP_LIBC}.tar.gz \
    | tar -xz --strip-components=1 -C /usr/local/bin

# Install wslint
RUN curl -sSL https://raw.githubusercontent.com/idelchi/wslint/refs/heads/main/install.sh | sh -s -- -d /usr/local/bin -v ${WSLINT_VERSION}

# Copy the tools from the build stages
COPY --from=go-builder /go/bin/* /usr/local/bin/

ENV TZ=Europe/Zurich

RUN mkdir -p /workspace && chmod 1777 /workspace

WORKDIR /workspace

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint

ENTRYPOINT ["entrypoint"]
CMD ["/bin/bash"]

# (user is expected to be overridden from root)
# hadolint global ignore=DL3002
