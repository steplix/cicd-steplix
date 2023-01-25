#!/bin/bash

SOURCE="${CI_COMMIT_BRANCH}"
PRIVATE_TOKEN="${STEPLIX_GITLAB_ACCESS_TOKEN}";
DELETE_SOURCE_BRANCH=`if [[ "${DELETE_SOURCE_BRANCH}" == "true" ]]; then echo true; else echo false; fi`
TITLE=`if [ -z "${TITLE}" ]; then echo "Merge ${SOURCE} on ${TARGET}"; else echo ${TITLE}; fi`
BODY="{
    \"id\": ${CI_PROJECT_ID},
    \"source_branch\": \"${SOURCE}\",
    \"target_branch\": \"${TARGET}\",
    \"title\": \"${TITLE}\",
    \"assignee_id\": \"${GITLAB_USER_ID}\",
    \"remove_source_branch\": ${DELETE_SOURCE_BRANCH}
}";

echo "BODY TO SEND: ${BODY}";

URL=`echo ${CI_PROJECT_URL} | awk -F[/:] '{print $1"://"$4}'`"/api/v4/projects/${CI_PROJECT_ID}"
LIST_MR=`curl --silent "${URL}/merge_requests?state=opened" --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}"`;
COUNT_BRANCHES=`echo ${LIST_MR} | grep -o "\"source_branch\":\"${SOURCE}\"" | wc -l`;
CURL_RESPONSE='';

if [ ${COUNT_BRANCHES} -eq "0" ]; then
    CURL_RESPONSE=`curl -s -w '%{http_code}' --silent --output /dev/null -X POST "${URL}/merge_requests" --header "PRIVATE-TOKEN: ${PRIVATE_TOKEN}" --header "Content-Type: application/json" --data "${BODY}"`;

    if [ 0 -eq $? ]; then
        if [ "${CURL_RESPONSE}" == "201" ]; then
            echo -e "Opened a new merge request from ${SOURCE} into ${TARGET}";
            exit;
        fi
    fi
else
    echo -e "There is already an opened merge request with source branch ${SOURCE}";
    exit;
fi

echo -e "Cannot create the merge request";
echo "CURL Response = ${CURL_RESPONSE}";
exit 1;
