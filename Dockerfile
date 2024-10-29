#[=======================================================================[
# Description : Docker image containing various tooling, such as:
#   - Go
#   - Python
#   - Rust
#   - Linters
#   - Formatters
#   - and many, many, more...
#]=======================================================================]

# Build stage for Rust tools
FROM --platform=$BUILDPLATFORM rust:bookworm AS rust-builder

# Basic good practices
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /tmp
COPY scripts/rustcc.sh .

