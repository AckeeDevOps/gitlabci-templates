#!/bin/sh

not_empty () {
  [ -z "${!1}" ] && { echo "${1} is required"; exit 1; }
}
