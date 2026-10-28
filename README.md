# DARMA-tasking template repository

Template repository with base configuration.

Included workflows:
* [*check-pr-fixes-issue*](https://github.com/DARMA-tasking/check-pr-fixes-issue) - checking if PR description contains phrase "Fixes #issue", and if PR title, description and branch mention the same issue number
* [*find-unsigned-commits*](https://github.com/DARMA-tasking/find-unsigned-commits) - checking if there are any unsigned commits in PR
* [*find-trailing-whitespace*](https://github.com/DARMA-tasking/find-trailing-whitespace) - checking if there are any trailing whitespaces in files
* [*check-commit-format*](https://github.com/DARMA-tasking/check-commit-format) - checking if commit message is properly formatted - either starts with "*Merge ...*" or fullfils template: "*#issue_number: short commit description*"
* [*action-git-diff-check*](https://github.com/joel-coffman/action-git-diff-check) - checking if changes introduce conflict markers or whitespace errors
* *check-setup-fmt* - checking that a repository's `setup_fmt.cmake` matches the golden copy in this repository
* [*check-build-matrix*](.github/workflows/check-build-matrix.yml) - running
`ci/build-matrix.py` to verify that `azure.json` and `github.json` match the
current CI configuration, and failing the check if either generated file is out
of date

## `check-build-matrix`

Check fails if differences appear in the CI log. To fix this, run the script
locally and include the updated JSON files in your changes.

```sh
# First-time setup
python3 -m venv /tmp/darma-workflows-venv
/tmp/darma-workflows-venv/bin/python -m pip install PyYAML

# Generate both JSON files
/tmp/darma-workflows-venv/bin/python ci/build-matrix.py

# Check for differences
git diff --exit-code -- ci/shared/matrix/azure.json ci/shared/matrix/github.json
# No output -> Both files are up to date
# Differences shown -> The script updated the files, review and include them
```
