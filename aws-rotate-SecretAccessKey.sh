#!/usr/bin/env bash
#
# AWS SecretAccessKey rotation script
# Copyright (c) 2020 - SCPG <scpg-dev@protonmail.com>
#
# Credits:
#   Some ideas taken from:
#     * https://github.com/ralish/bash-script-template
#     * https://github.com/z017/shell-script-skeleton


# Initialization
# Debug
if [[ ${DEBUG-} =~ ^yes|true$ ]]; then
    set -o xtrace # Trace the execution of the script (debug)
fi

# Paths and sources
scriptHome=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
commonFileName="common.sh"
commonFile="${scriptHome}/${commonFileName}"
[ -s "${commonFile}" ] && . "${commonFile}"

# Constants
readonly VERSION=0.0.1
readonly AUTHOR="scpg-dev@protonmail.com"
readonly GITHUB="https://github.com/scpg/aws-rotate-SecretAccessKey"

readonly SCRIPT_NAME=${0##*/}

# Requirements
readonly REQUIRED_TOOLS=(jq aws)
required "${REQUIRED_TOOLS[@]}" 

helpText="
USAGE:
  $SCRIPT_NAME <aws-user> 
"

if [ $# -ne 1 ]; then
  err "illegal number of parameters"
  help "$helpText"
fi

set -e
if [ -z "$1" ]; then
    exit
fi

awsUser="$1"
currentKey=$(aws iam list-access-keys --user-name "$awsUser")
currentKeyCount=$(echo "$currentKey" | jq '.AccessKeyMetadata | length' --raw-output)
if [ $currentKeyCount -ne 1 ]; then
  err "SecretAccessKey count for user '$awsUser' is '$currentKeyCount'. Expecting 1"
  exit 1
fi
currentKeyAccessKeyId=$(echo "$currentKey" | jq '.AccessKeyMetadata[0].AccessKeyId' --raw-output)
newKey=$(aws iam create-access-key --user-name "$awsUser")
newKeyAccessKeyId=$(echo "$newKey" | jq '.AccessKey.AccessKeyId' --raw-output)
newKeySecretAccessKey=$(echo "$newKey" | jq '.AccessKey.SecretAccessKey' --raw-output)

aws iam update-access-key --access-key-id $currentKeyAccessKeyId --status Inactive --user-name "$awsUser"
aws iam delete-access-key --access-key-id $currentKeyAccessKeyId --user-name "$awsUser"

aws configure set aws_access_key_id "$newKeyAccessKeyId"
aws configure set aws_secret_access_key "$newKeySecretAccessKey"