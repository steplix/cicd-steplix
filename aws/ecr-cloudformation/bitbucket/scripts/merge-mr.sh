#!/bin/bash

printf -v BODY '{
    "type": "todo",
    "message": "Automated merge #%s",
    "close_source_branch": false
  }' "$BITBUCKET_BUILD_NUMBER"


RESPONSE=$(curl https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$BITBUCKET_REPO_SLUG/pullrequests/$1/merge \
                -s -S -X POST \
                -H 'Content-Type: application/json' \
                -H "Authorization: Bearer $BB_BEARER" \
                -d "$BODY")

if [ "$(echo $RESPONSE | jq -r '.type')" = "error" ]; then
  >&2 echo "Error merging MR"
  >&2 echo $RESPONSE
  exit 1
fi

echo $RESPONSE