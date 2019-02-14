#!/bin/sh

function not_empty {
  [ -z "${!1}" ] && { echo "${1} is required"; exit 1; }
}
