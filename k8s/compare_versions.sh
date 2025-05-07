#!/bin/bash

compare_versions() {
  VERSION_1=$1
  VERSION_2=$2
  if [ "$(echo -e "$VERSION_1\n$VERSION_2" | sort -V | head -n1)" != "$VERSION_1" ]; then
    return 1  # VERSION_1 is less than VERSION_2
  else
    return 0  # VERSION_1 is greater than or equal to VERSION_2
  fi
}