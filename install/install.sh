#!/bin/bash

set -Eeuo pipefail

trap cleanup EXIT

function cleanup {      
  echo bye
}
