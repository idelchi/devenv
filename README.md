# devenv

`devenv` is a repository that provides a collection of common basic settings for linters and formatters, driven by Taskfiles. It also builds and pushes a Docker image to Docker Hub containing all the necessary tools.

To use `devenv` in your project, include it as a submodule. Optionally copy the [.vscode](./.vscode) folder into your main project, make sure to update the paths in [settings.json](./.vscode/settings.json) to point to the configuration folders used.

## Table of Contents

- [Running the code](#running-the-code)
- [Main Tools](#main-tools)
- [Using Docker](#using-docker)

## Running the code

A [Taskfile](./Taskfile.yml) is used to manage and summarize the different build system commands. To display the available commands along with their descriptions, run:

    task --list

## Main Tools

- Go
  - [gofmt](https://pkg.go.dev/cmd/gofmt)
  - [vet](https://pkg.go.dev/cmd/vet)
  - [golangci-lint](https://github.com/golangci/golangci-lint)
- Python
  - [black](tbd)
  - [isort](tbd)
  - [prospector](tbd)
  - [pyright](tbd)
- JSON/YAML
  - [prettier](https://github.com/prettier/prettier)
  - [jsonlint](https://github.com/zaach/jsonlint)
  - [yamllint](https://github.com/adrienverge/yamllint)
- shell/bash
  - [shfmt](https://github.com/mvdan/sh)
  - [shellcheck](https://github.com/koalaman/shellcheck)
- Dockerfile
  - [hadolint](https://github.com/hadolint/hadolint)
  - [dockerfilelint](https://github.com/replicatedhq/dockerfilelint)
- Markdown
  - [prettier](https://github.com/prettier/prettier)
  - [markdownlint](https://github.com/DavidAnson/markdownlint)
- Spelling
  - [misspell](https://github.com/client9/misspell)
  - [cspell](https://github.com/streetsidesoftware/cspell)
  - [codespell](https://github.com/codespell-project/codespell)
- Copy-Paste
  - [jscpd](https://github.com/kucherenko/jscpd)
- Groovy
  - [npm-groovy-lint](https://github.com/nvuillam/npm-groovy-lint)
  - [jflint](https://github.com/miyajan/jflint)

## Using Docker

You can use the accompanying Docker image to run native tasks with full support for all commands listed in the Taskfile. To launch the container and mount the workspace, run:

    docker compose run devenv

For more detailed instructions on how to use these tools, please refer to their respective documentation.
