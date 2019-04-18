#!/bin/sh

# USAGE:
#   check_empty NON_EXISTING_VARIABLE => exits with status 1

check_empty () {
  # $1 is variable name
  
  # Write status
  echo "checking variable ${1} ..."
  
  # check if variable is empty - unset or ''
  if [ -z "$(eval echo \$"$1")" ]; then
    echo "${1} is empty!"
    exit 1
  fi
}

# USAGE:
#   check_empty_vars NON_EXISTING_VARIABLE1 NON_EXISTING_VARIABLE2 NON_EXISTING_VARIABLE3 => exits with status 1 after
#   the first iteration
check_empty_vars () {
  for var in "$@"
  do
    check_empty "${var}"
  done
}
