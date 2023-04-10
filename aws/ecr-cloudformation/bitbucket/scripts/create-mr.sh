#!/bin/bash
HEAD_COMMIT_MESSAGE=$(git log --format=%B -n 1)
CURRENT_BRANCH=$(git branch --show-current)

SOURCE_BRANCH=${2:-$CURRENT_BRANCH}

printf -v BODY '{
    "title": "%s",
    "description": "",
    "source": {
      "branch": {
        "name": "%s"
      }
    },
    "destination": {
      "branch": {
        "name": "%s"
      }
    },
    "close_source_branch": false,
    "reviewers": '[]'
  }' "$HEAD_COMMIT_MESSAGE" "$SOURCE_BRANCH" "$1"

RESPONSE=$(curl https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO_SLUG/pullrequests \
                -s -S -X POST \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer $BB_BEARER" \
                -d "$BODY")

MRID=$(echo $RESPONSE | jq '.id')

if [ "$MRID" = "null" ]; then
  >&2 echo "Error creating MR"
  >&2 echo $RESPONSE
  exit 1
fi

echo $MRID
