# DARMA Workflows

This repository unifies all CI/CD workflows and containers across the DARMA-tasking organization.

Jump to:
- [Standard Workflows](standard-workflows)
- [Standard Containers](standard-containers)

## Standard Workflows

All DARMA-tasking repositories should include the following workflows:

* [*check-pr-fixes-issue*](https://github.com/DARMA-tasking/check-pr-fixes-issue) - checking if PR description contains phrase "Fixes #issue", and if PR title, description and branch mention the same issue number
* [*find-unsigned-commits*](https://github.com/DARMA-tasking/find-unsigned-commits) - checking if there are any unsigned commits in PR
* [*find-trailing-whitespace*](https://github.com/DARMA-tasking/find-trailing-whitespace) - checking if there are any trailing whitespaces in files
* [*check-commit-format*](https://github.com/DARMA-tasking/check-commit-format) - checking if commit message is properly formatted - either starts with "*Merge ...*" or fullfils template: "*#issue_number: short commit description*"
* [*action-git-diff-check*](https://github.com/joel-coffman/action-git-diff-check) - checking if changes introduce conflict markers or whitespace errors

These workflows are included by default when a new repository is created based on [DARMA-tasking/template-repository](https://github.com/DARMA-tasking/template-repository).

This repository periodically runs the `check_repository` action (`check-repositories.yml`), which locates all of the aforementioned workflows within every DARMA-tasking repository.
Any repositories that fail this check should be corrected as soon as possible to meet the requirements for DARMA-tasking.

## Standard Containers

This repository builds and pushes Docker containers that should be used throughout all DARMA-tasking repositories for CI.

### General Overview

All test environments are defined in `ci/config.yaml`, which also includes commented documentation.

Some tools are provided as Python scripts:

- `ci/build-matrix.py`: Constructs the list of available test environments as a JSON matrix file
- `ci/build-setup.py`: Generates setup shell scripts (one shell script for each test environment)
- `ci/build-docker-image.py`: Build a Docker image from the list of available images described in the configuration file
    - This script includes interactive support for local builds as well as a non-interactive mode for CI

### How To Use

The following steps explain how to use the standardized Docker containers in the CI of other DARMA-tasking repositories.

1. Copy the YAML workflow/pipeline

    - **GitHub**: Copy/paste the contents of `gh_build_and_test.yml` workflow from the `docs` directory into the `.github/workflows` directory of the desired repository.

    - **Azure**: Copy/paste the contents of `azure_build_and-test.yml` workflow from the `docs` directory into the `.azure/pipelines` directory of the desired repository.

2. Update the definition of `CMD` in the "PR tests" step to reflect the correct build and test commands for the repository.
    - Search for "PR tests" in the workflow or pipeline file to find the `CMD` definition

3. Optional: You may also want to update other aspects of the file such as trigger events or selected test environments.

### For Example...

[PR 2](https://github.com/DARMA-tasking/test-ci-project/pull/2) from the DARMA-tasking/test-ci-project repository successfully implemented CI pipelines using the unified Docker containers.
