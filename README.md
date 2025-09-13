# devenv

`devenv` is a repository offering a collection of common settings for linters and formatters, managed by Taskfiles.
Additionally, it builds and pushes a Docker image loaded with all the required tools to Docker Hub.

To use `devenv` in your project, include it as a submodule.

    git submodule add https://github.com/idelchi/devenv .devenv

[Taskfile.yml](./Taskfile.yml) contains the list of commands that can be run to format and lint the code,
and can be used as a starting point for your own project.

## Table of Contents

- [Task](#task)
- [Using Docker](#using-docker)

## Task

A [Taskfile](./Taskfile.yml) is used to manage and summarize the different build system commands.
To display the available commands along with their descriptions, run:

    task --list

## Using Docker

You can use the accompanying Docker image to run native tasks with full support for all commands listed in the Taskfile.
To launch the container and mount the workspace, run:

    task docker

For more detailed instructions on how to use these tools, please refer to their respective documentation.
