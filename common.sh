#!/usr/bin/env bash
#
# Common script functions 
# Copyright (c) 2020 - SCPG <scpg-dev@protonmail.com>
#
# Credits:
#   Some ideas taken from:
#     * https://github.com/ralish/bash-script-template
#     * https://github.com/z017/shell-script-skeleton

#######################################
# CONSTANTS & VARIABLES
#######################################
# Verbose Levels
readonly VERBOSE_LEVELS=(none fatal error warning info debug)

# Level Colors
readonly LEVEL_COLORS=(39 31 31 33 32 36)

# Defaults Verbose Level - 0 none, 1 fatal, 2 error, 3 warning, 4 info, 5 debug
readonly VERBOSE_DEFAULT=5

# Current verbose level
declare -i verbose_level="$VERBOSE_DEFAULT"

#######################################
# FUNCTIONS
#######################################

# Print out error messages to STDERR.
function err() {
  [[ $verbose_level -ge 1 ]] \
    && echo -e "\033[0;${LEVEL_COLORS[1]}mERROR: $@\033[0m" >&2
}

# Shows an error if required tools are not installed.
function required {
  local e=0
  for tool in "$@"; do
    type $tool >/dev/null 2>&1 || {
      e=1 && err "$tool is required for running this script. Please install $tool and try again."
    }
  done
  [[ $e < 1 ]] || exit 2
}

# Version
function version() {
  echo "$SCRIPT_NAME version $VERSION"
}
# Help
function help() {
  echo "$@" >&2
  exit 1
}
