#!/bin/bash
HEAD_COMMIT_MESSAGE=$(git log --format=%B -n 1)

TAG_ID=$(git rev-list --tags --max-count=1)
if [[ -z "$TAG_ID" ]]; then
    git fetch --all --tags
    TAG_ID=$(git rev-list --tags --max-count=1)
fi

LAST_TAG=$(if [[ -z "$TAG_ID" ]]; then echo "0.0.0"; else echo $(git describe --tags ${TAG_ID}); fi)

if [[ "$HEAD_COMMIT_MESSAGE" == *#major* ]]; then
    VERSION=$(echo "${LAST_TAG}" | awk -F. -v OFS=. '{$1 += 1; print $1".0.0"}');
elif [[ "$HEAD_COMMIT_MESSAGE" == *#minor* ]]; then
    VERSION=$(echo "${LAST_TAG}" | awk -F. -v OFS=. '{$2 += 1; print $1"."$2".0"}');
else
    VERSION=$(echo "${LAST_TAG}" | awk -F. -v OFS=. '{$3 += 1 ; print}');
fi

echo "$VERSION"