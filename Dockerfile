#[=======================================================================[
# Description : Docker image containing various tooling, such as:
#   - Go
#   - Python
#   - Rust
#   - Linters
#   - Formatters
#   - and many, many, more...
#]=======================================================================]

# TODO(Idelchi): Use godyl to download the latest version of each tool

FROM idelchi/godyl:dev AS downloader

ARG TARGETOS
ARG TARGETARCH

USER root

COPY --from=golang:1.24.4 /usr/local/go /usr/local/go

ENV PATH="/usr/local/go/bin:$PATH"

COPY tools /tmp/tools

ENV GODYL_INSTALL_OUTPUT=/tmp/binaries

RUN --mount=type=secret,id=secrets.env \
    # --mount=type=secret,id=github-token,env=GITHUB_TOKEN \
    # [ -f /run/secrets/secrets.env ] && . /run/secrets/secrets.env && \
    godyl update --pre --force && \
    godyl -v i /tmp/tools/go.yml --source=go  && \
    godyl -v i /tmp/tools/tools.yml

# FROM python:3.13

# ARG TARGETOS
# ARG TARGETARCH

# LABEL maintainer=arash.idelchi

# USER root

# # Create User (Debian/Ubuntu)
# ARG USER=user
# RUN groupadd -r -g 1001 ${USER} && \
#     useradd -r -u 1001 -g 1001 -m -c "${USER} account" -d /home/${USER} -s /bin/bash ${USER}

# ARG DEBIAN_FRONTEND=noninteractive

# # Basic good practices
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# # Basic tooling
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     # Build tools
#     build-essential \
#     clang \
#     # Auxiliaries
#     curl \
#     wget \
#     git \
#     ca-certificates \
#     # Tools
#     graphviz \
#     gettext-base \
#     moreutils \
#     iputils-ping \
#     procps \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# # Install Java & Node
# RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
#     apt-get install -y --no-install-recommends \
#     default-jdk \
#     nodejs \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# # Various linters & formatters
# RUN npm install -g \
#     # groovy
#     npm-groovy-lint \
#     # Jenkinsfile
#     jflint \
#     # spellcheck
#     spellchecker-cli \
#     cspell \
#     # markdown
#     markdownlint-cli \
#     # copy-paste
#     jscpd \
#     # docker
#     dockerfile-utils \
#     # json
#     @prantlf/jsonlint \
#     # compound
#     prettier

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     # yaml
#     yamllint \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# # Update pip & allow breaking packages
# RUN pip install --no-cache-dir --upgrade pip && \
#     echo -e "[global]\nbreak-system-packages=true" >> /etc/pip.conf

# RUN \
#     if [ "${TARGETARCH}${TARGETVARIANT}" = "armv7" ]; then \
#     printf "extra-index-url=https://www.piwheels.org/simple\n" >> /etc/pip.conf ; \
#     fi

# # Spellcheckers
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     enchant-2 \
#     hunspell \
#     nuspell \
#     aspell \
#     hunspell-en-gb \
#     && apt-get remove -y hunspell-en-us \
#     && apt-get clean && rm -rf /var/lib/apt/lists/* \
#     && pip install --no-cache-dir \
#     codespell \
#     scspell3k

# # Python tooling for linting & formatting
# # (mistakes brackets for ranges, split up for readability)
# # hadolint ignore=SC2102,DL3059
# RUN pip install --no-cache-dir \
#     pyright \
#     # Library stubs for typing
#     types-pyyaml

# # Python tooling for packaging
# # (split up for readability)
# # hadolint ignore=DL3059
# RUN pip install --no-cache-dir \
#     build \
#     twine \
#     poetry

# # Useful packages
# # (split up for readability)
# # hadolint ignore=DL3059
# RUN pip install --no-cache-dir \
#     pytest \
#     pydantic \
#     requests \
#     flask \
#     fastapi

# # Install Go
# COPY --from=golang:1.24.4 /usr/local/go /usr/local/go
# ENV PATH="/usr/local/go/bin:$PATH"

# ENV GOPATH=/opt/go
# RUN mkdir ${GOPATH} && chown -R ${USER}:${USER} ${GOPATH}
# ENV PATH="${GOPATH}/bin:$PATH"

# USER ${USER}
# WORKDIR /home/${USER}

# # Run npm-groovy-lint once to download its preferred version of Java
# RUN npm-groovy-lint --version

# # Create a local bin directory
# RUN mkdir -p ~/.local/bin
# ENV PATH="/home/${USER}/.local/bin:$PATH"


# # Copy the tools from the build stages
# COPY --from=downloader /tmp/binaries  /usr/local/bin/

# # Reroute cache to /tmp
# ENV NPM_CONFIG_CACHE=/tmp/.npm
# ENV XDG_CACHE_HOME=/tmp/.cache
# ENV MYPY_CACHE_DIR=/tmp/.mypy_cache
# ENV RUFF_CACHE_DIR=/tmp/.ruff_cache
# ENV TASK_TEMP_DIR=/tmp/.task

# # Timezone
# ENV TZ=Europe/Zurich

# # Embed the project
# ENV DEVENV=/home/${USER}
# COPY --chown=${USER}:${USER} . ${DEVENV}
# RUN sed -i 's#^DEVENV=.*#DEVENV='"${DEVENV}"'#' ${DEVENV}/.env

# # Clear the base image entrypoint
# ENTRYPOINT []
# CMD ["/bin/bash"]
