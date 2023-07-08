# devenv

`devenv` is a repository offering a collection of common settings for linters and formatters, managed by Taskfiles.
Additionally, it builds and pushes a Docker image loaded with all the required tools to Docker Hub.

To use `devenv` in your project, include it as a submodule.

    git submodule add https://github.com/idelchi/devenv .devenv

To track the dev branch instead of the default master branch, the following commands can be used:

    git submodule set-branch -b dev .devenv
    git submodule update --init --recursive --remote

If using VS Code, copy the [.vscode](./.vscode) folder into the main project, and adjust the paths in
[settings.json](./.vscode/settings.json) to correspond with the configuration folders used.

[Taskfile.yml](./Taskfile.yml) contains the list of commands that can be run to format and lint the code,
and can be used as a starting point for your own project.

## Table of Contents

- [Task](#task)
- [Main Tools](#main-tools)
- [Using Docker](#using-docker)
- [Usage & Integrations](#usage--integrations)

## Task

A [Taskfile](./Taskfile.yml) is used to manage and summarize the different build system commands.
To display the available commands along with their descriptions, run:

    task --list

## Main Tools

- Go
  - [gofmt](https://pkg.go.dev/cmd/gofmt)
  - [vet](https://pkg.go.dev/cmd/vet)
  - [golangci-lint](https://github.com/golangci/golangci-lint)
- Python
  - [black](https://github.com/psf/black)
  - [isort](https://github.com/PyCQA/isort)
  - [prospector](https://github.com/PyCQA/prospector)
  - [pyright](https://github.com/microsoft/pyright)
  - [ruff](https://github.com/charliermarsh/ruff)
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
  - [typos](https://github.com/crate-ci/typos)
- Copy-Paste
  - [jscpd](https://github.com/kucherenko/jscpd)
- Groovy
  - [npm-groovy-lint](https://github.com/nvuillam/npm-groovy-lint)
  - [jflint](https://github.com/miyajan/jflint)
- Git
  - [gitlint](https://jorisroovers.com/gitlint)

Tools that are not linters or formatters, but are useful for development:

- [grip](https://github.com/joeyespo/grip)
- [ansible](https://github.com/ansible/ansible)
- [terraform](https://github.com/hashicorp/terraform)
- [just](https://github.com/casey/just)
- [sphinx](https://www.sphinx-doc.org/)
- [yq](https://github.com/mikefarah/yq)
- [yaml2json](https://github.com/bronze1man/yaml2json)

Compilers and interpreters:

- [python](https://www.python.org/)
- [go](https://golang.org/)
- [rust](https://www.rust-lang.org/)
- [gcc](https://gcc.gnu.org/)
- [clang](https://clang.llvm.org/)

## Using Docker

You can use the accompanying Docker image to run native tasks with full support for all commands listed in the Taskfile.
To launch the container and mount the workspace, run:

    docker compose run devenv

For more detailed instructions on how to use these tools, please refer to their respective documentation.

## Usage & Integrations

`devenv` can be used in one of the following ways:

- As a submodule, i.e., referenced in your project.
- As a globally available environment, running with `task -g`.
  This can be achieved by either utilizing the published Docker image,
  which contains the latest version in your home directory,
  or by installing this repository directly in your home directory.

Both the root `Taskfile` and the `docker-compose` file require `DEVENV` to be set to function correctly.
For this, the `.env` file should be appropriately configured and sourced.

`.github` contains a GitHub Actions workflow that can be used to run the linters, tests and build.

`.devcontainer` contains configurations to use the Docker image as a development container.

`.vscode` contains configurations for usage in VS Code.
