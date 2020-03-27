#!/bin/bash

CONTENT_FILE=$1
DOCUMENT_NAME=$2
AWS_REGION=$3

aws ssm describe-document --name ${DOCUMENT_NAME} --region ${AWS_REGION} > /dev/null 2>&1
DOC_EXISTS=$(echo $?)

if [[ $DOC_EXISTS -ne 0 ]]; then
    aws ssm create-document  --content ${CONTENT_FILE}  --name "${DOCUMENT_NAME}"  --document-type "ChangeCalendar" --document-format TEXT --region ${AWS_REGION} && echo Success || exit $?
fi
