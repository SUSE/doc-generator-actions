#!/usr/bin/env bash

# Copyright 2020 SUSE
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit -o nounset -o pipefail

prs=$(
  curl \
    --fail \
    --request GET \
    --header "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${REPOSITORY}/pulls?state=open&head=${REPOSITORY_OWNER}:${BRANCH}" \
    | jq -r length
)

if [ "${prs}" -gt 0 ]; then
  >&2 echo "Pull request already exists for '${BRANCH}'"
  exit 0
fi

body=$(jq -r -c . <<EOF
{
  "title": "${COMMIT_TITLE}",
  "head": "${BRANCH}",
  "base": "${BASE_REF}",
  "maintainer_can_modify": true
}
EOF
)

curl \
  --fail \
  --silent \
  --request POST \
  --header "Authorization: Bearer ${GITHUB_TOKEN}" \
  --header "Content-Type: application/json" \
  --header "Accept: application/vnd.github.v3+json" \
  --data "${body}" \
  "https://api.github.com/repos/${REPOSITORY}/pulls"
