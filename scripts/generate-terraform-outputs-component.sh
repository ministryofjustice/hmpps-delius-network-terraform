#!/usr/bin/env bash

if [ -d "${attributes_dir}" ]; then
    echo "${attributes_dir} found"
else
    echo "${attributes_dir} not found, creating"
    mkdir -p ${attributes_dir}
fi



mkdir -p "${inspec_profile_dir}/${COMPONENT}/files"
attrFile="${inspec_profile_dir}/${COMPONENT}/files/terraform.json"

echo "attrFile ${attrFile}"

rm -rf ${attrFile}
echo "Getting outputs for: ${ENVIRONMENT_NAME} ${COMPONENT}"

terragrunt output -json >> ${attrFile}
if [ "$?" -ne "0" ]; then
    echo "Outputs generation failed for ${attrFile}"
    exit 1
fi
