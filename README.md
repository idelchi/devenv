# settings

Common basic settings for linters, formatters, etc.

Builds and pushes a Docker image to Docker Hub.

Include as a submodule and initialize your main project's Taskfile & vscode settings with:

    task -f settings/Taskfile.yml aux:init

or write your own `Taskfile.yml` using the tasks defined in `settings/taskfiles`

## Running the code

A [Taskfile][taskfile-file] is used to summarize and manage the different build system commands.

[taskfile-file]: ./Taskfile.yaml

To display available commands along with their descriptions, run

    task --list

## Tools

- Go
  - [gofmt](https://pkg.go.dev/cmd/gofmt)
  - [vet](https://pkg.go.dev/cmd/vet)
  - [golangci-lint](https://github.com/golangci/golangci-lint)
- Python
  - [black](tbd)
  - [flake8](tbd)
  - [isort](tbd)
  - [prospector](tbd)
  - [pyright](tbd)
- Groovy
  - [npm-groovy-lint](https://github.com/nvuillam/npm-groovy-lint)
  - [jflint](https://github.com/miyajan/jflint)
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

## Using Docker

The accompanying docker image may be used to run native runs with full support of all commands listed in the _taskfile_.

To launch the container and mount the workspace, run

    docker compose run devenv
