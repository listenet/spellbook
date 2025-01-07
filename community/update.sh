#!/usr/bin/env bash

set -e
set -o pipefail

COMMUNITY_DIR="$(dirname "${BASH_SOURCE[0]}")"

printf '=> Updating submodules\n'
(
  cd "${COMMUNITY_DIR}/"
  git submodule update --init --recursive
)

while read -r git_mod git_tag
do
  printf '=> Synchronizing %s to %s\n' "${git_mod}" "${git_tag}"
  (
    cd "${COMMUNITY_DIR}/${git_mod}"
    git fetch --tags origin
    git checkout "${git_tag}"
  )
done < "${COMMUNITY_DIR}/VERSIONS"
