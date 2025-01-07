# DARMA Workflows

This repository unifies all CI/CD workflows and containers across the [DARMA-tasking](https://github.com/DARMA-tasking) organization.

Jump to:
- [Standard Workflows](standard-workflows)
- [Standard Containers](standard-containers)
    - [Creating Containers](creating-containers)
    - [Using Containers](using-containers)

## Standard Workflows

All DARMA-tasking repositories should include the following workflows:

* [*check-pr-fixes-issue*](https://github.com/DARMA-tasking/check-pr-fixes-issue) - checking if PR description contains phrase "Fixes #issue", and if PR title, description and branch mention the same issue number
* [*find-unsigned-commits*](https://github.com/DARMA-tasking/find-unsigned-commits) - checking if there are any unsigned commits in PR
* [*find-trailing-whitespace*](https://github.com/DARMA-tasking/find-trailing-whitespace) - checking if there are any trailing whitespaces in files
* [*check-commit-format*](https://github.com/DARMA-tasking/check-commit-format) - checking if commit message is properly formatted - either starts with "*Merge ...*" or fullfils template: "*#issue_number: short commit description*"
* [*action-git-diff-check*](https://github.com/joel-coffman/action-git-diff-check) - checking if changes introduce conflict markers or whitespace errors

> [!TIP]
> These workflows are included by default when a new repository is created based on [DARMA-tasking/template-repository](https://github.com/DARMA-tasking/template-repository).

This repository periodically runs a check ([`DARMA repositories check`](https://github.com/DARMA-tasking/workflows/actions/workflows/check-repositories.yml)) to locate all of the above workflows within every DARMA-tasking repository.
Any repositories that fail this check should be corrected as soon as possible to meet the requirements for DARMA-tasking.

> [!NOTE]
> To ignore a repository during this check, add it to the `EXCLUDE` list in `ci/list_repositories.sh`.

## Standard Containers

This repository builds and pushes Docker containers that should be used throughout all DARMA-tasking repositories for CI.

This section explains both 1) how to create a container within this repository and 2) how to use any created containers throughout the DARMA-tasking organization.

### 1. Creating New Containers

#### Overview

All test environments are defined in `ci/config.yaml`, which also includes commented documentation.

Some tools are provided as Python scripts:

- `ci/build-setup.py`: Generates setup shell scripts (one shell script for each test environment)
- `ci/build-matrix.py`: Constructs the list of available test environments as a JSON matrix file
- `ci/build-docker-image.py`: Build a Docker image from the list of available images described in the configuration file
    - This script includes interactive support for local builds as well as a non-interactive mode for CI

#### Step By Step

To create a new container, you only need to edit the `ci/config.yaml` file and run the `build` helper scripts above.

1. **Setup**: Add a new configuration to the `setup` section of `ci/config.yaml`.

2. **Image**: Add a new Docker image to the `images` section of `ci/config.yaml`, referencing the setup that you just defined.

3. **Runner**: Add a new runner to the `runners` section of `ci/config.yaml`, referencing the docker image tag you just defined.

4. **Generate**: Build the setup script and matrix file with:

```sh
python ci/build-setup.py
python ci/build-matrix.py
```

> [!NOTE]
> If you wish to build the new image locally, run `python ci/build-docker-image.py` and select the new image when prompted. Otherwise, the next step will build and push the image in CI.

5. **Merge**: The `build-docker-image.yml` workflow is triggered by a merge to `master`. This will 1) build all Docker containers defined by the matrices in the `shared/matrix` directory and 2) push to Dockerhub.

### 2. Using Containers

The following steps explain how to use the standardized Docker containers in the CI of other DARMA-tasking repositories.

1. Copy the YAML workflow/pipeline

    - **GitHub**: Copy/paste the contents of `docs/gh_build_and_test.yml` workflow into the `.github/workflows` directory of the desired repository.

    - **Azure**: Copy/paste the contents of `docs/azure_build_and-test.yml` workflow into the `.azure/pipelines` directory of the desired repository.

2. Update the definition of `CMD` in the "PR tests" step to reflect the correct build and test commands for the repository.
    - Search for "PR tests" in the workflow or pipeline file to find the `CMD` definition

3. Optional: You may also want to update other aspects of the file such as trigger events or selected test environments.

#### For Example...

The [test-ci-project](https://github.com/DARMA-tasking/test-ci-project) repository successfully implemented CI pipelines using the common Docker containers.
