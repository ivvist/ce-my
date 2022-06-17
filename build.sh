#!/bin/bash

#set -Eeuo pipefail

[ -z ${1-} ] && { echo "use build.sh VersionCore [PreRelease]"; exit 1; }

BuildFolder=".build"

# Process arguments

VersionCore=$1
PreRelease=${2-}
[ -z ${PreRelease-} ] && SemVer=$VersionCore || SemVer=$VersionCore-$PreRelease
echo $SemVer > version

# Functions

cleanup() {      
  # Restore version
  git checkout -- version
}

build_os_arch() {

  [ $1 == "windows" ] && exeName="ce.exe" || exeName="ce"

  pushd . > /dev/null
  cd cli
  env GOOS=$1 GOARCH=$2 go build -o ../$BuildFolder/$exeName
  popd > /dev/null

  pushd $BuildFolder > /dev/null
  tar -czvf ce_v${SemVer}_$1_$2.tar.gz $exeName > /dev/null
  popd > /dev/null
  rm $BuildFolder/$exeName
}

# End of functions

sh cleanup EXIT

# Cleanup

rm -rf $BuildFolder
[ -d "$BuildFolder" ] || mkdir $BuildFolder

# Build os+arch

sh build_os_arch linux amd64
sh build_os_arch freebsd amd64
sh build_os_arch windows amd64

cp install/install.sh $BuildFolder
