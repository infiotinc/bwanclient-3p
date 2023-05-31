#!/bin/bash

# The version of openssl to build.  It must match
# one of the values found in the releases section of the github repo.
# It can be set to "master" when building directly from the github repo.
OPENSSL_VERSION=3.0.7
#OPENSSL_VERSION=2.6.1

# Set to "YES" if you would like the build script to
# pause after each major section.
INTERACTIVE=NO

# A "YES" value will build the latest code from GitHub on the master branch.
# A "NO" value will use the 3.0.7 tarball downloaded from github.com/openssl/openssl/archive.
USE_GIT_MASTER=NO

while [[ $# > 0 ]]
do
  key="$1"

  case $key in
    -i|--interactive)
      INTERACTIVE=YES
      ;;
    -m|--master)
      USE_GIT_MASTER=YES
      OPENSSL_VERSION=master
      ;;
    -h|--help)
      printf "\nThis will build universal binaries and static library for openssl\n"
      printf "\n\trun build-openssl.sh -i for interactive run"
      printf "\n\trun build-openssl.sh -m for building master branch"
      printf "\n\tEdit the script to specific any specific tag to build. Default harded tag: OPENSSL_VERSION=3.0.7"
      printf "\nLogs can be found at path: /tmp/openssl_build.log"
      printf "\n\n"
      exit
      ;;
    *)
      # unknown option
      ;;
  esac
  shift # past argument or value
done

echo "$(tput setaf 2)"
echo "###################################################################"
echo "# Preparing to build openssl"
echo "###################################################################"
echo "$(tput sgr0)"

function conditionalPause {
  if [ "${INTERACTIVE}"  == "YES" ]
  then
    while true; do
        read -p "Proceed with next step in build? (y/n) " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
  fi
}

echo "Starting Openssl Build:" > /tmp/openssl_build.log
# The results will be stored relative to the location
# where you stored this script, **not** relative to
# the location of the openssl git repo.
PREFIX=`pwd`/openssl

if [ -d ${PREFIX} ]
then
    rm -rf "${PREFIX}"
    echo "Delete: ${PREFIX}-${OPENSSL_VERSION}"
    rm -rf "${PREFIX}-${OPENSSL_VERSION}"
fi
mkdir -p "${PREFIX}/platform"

OPENSSL_GIT_URL=https://github.com/openssl/openssl.git
OPENSSL_GIT_DIRNAME=openssl
OPENSSL_RELEASE_URL=https://github.com/openssl/openssl/archive/refs/tags/openssl-${OPENSSL_VERSION}.tar.gz
OPENSSL_RELEASE_DIRNAME=openssl-${OPENSSL_VERSION}

BUILD_MACOSX_X86_64=YES
BUILD_MACOSX_ARM_64=YES

OPENSSL_SRC_DIR=/tmp/openssl

# 13.4.0 - Mavericks
# 14.0.0 - Yosemite
# 15.0.0 - El Capitan
DARWIN_X86=darwin64-x86_64-cc
DARWIN_ARM=darwin64-arm64-cc

XCODEDIR=`xcode-select --print-path`

MACOSX_PLATFORM=${XCODEDIR}/Platforms/MacOSX.platform
MACOSX_SYSROOT=${MACOSX_PLATFORM}/Developer/MacOSX10.9.sdk

# Uncomment if you want to see more information about each invocation
# of clang as the builds proceed.
# CLANG_VERBOSE="--verbose"

CC=clang
CXX=clang

SILENCED_WARNINGS="-Wno-unused-local-typedef -Wno-unused-function"

# NOTE: openssl does not currently build if you specify 'libstdc++'
# instead of `libc++` here.
STDLIB=libc++

CFLAGS="${CLANG_VERBOSE} ${SILENCED_WARNINGS} -DNDEBUG -g -O0 -pipe -fPIC -fcxx-exceptions"
CXXFLAGS="${CLANG_VERBOSE} ${CFLAGS} -std=c++11 -stdlib=${STDLIB}"

LDFLAGS="-stdlib=${STDLIB}"
LIBS="-lc++ -lc++abi"

echo "PREFIX ..................... ${PREFIX}"
echo "USE_GIT_MASTER ............. ${USE_GIT_MASTER}"
echo "OPENSSL_GIT_URL ........... ${OPENSSL_GIT_URL}"
echo "OPENSSL_GIT_DIRNAME ....... ${OPENSSL_GIT_DIRNAME}"
echo "OPENSSL_VERSION ........... ${OPENSSL_VERSION}"
echo "OPENSSL_RELEASE_URL ....... ${OPENSSL_RELEASE_URL}"
echo "OPENSSL_RELEASE_DIRNAME ... ${OPENSSL_RELEASE_DIRNAME}"
echo "BUILD_MACOSX_X86_64 ........ ${BUILD_MACOSX_X86_64}"
echo "OPENSSL_SRC_DIR ........... ${OPENSSL_SRC_DIR}"
echo "DARWIN_X86 ..................... ${DARWIN_X86}"
echo "DARWIN_ARM ..................... ${DARWIN_ARM}"
echo "XCODEDIR ................... ${XCODEDIR}"
echo "MACOSX_PLATFORM ............ ${MACOSX_PLATFORM}"
echo "MACOSX_SYSROOT ............. ${MACOSX_SYSROOT}"
echo "CC ......................... ${CC}"
echo "CFLAGS ..................... ${CFLAGS}"
echo "CXX ........................ ${CXX}"
echo "CXXFLAGS ................... ${CXXFLAGS}"
echo "LDFLAGS .................... ${LDFLAGS}"
echo "LIBS ....................... ${LIBS}"


conditionalPause

echo "$(tput setaf 2)"
echo "###################################################################"
echo "# Fetch openssl"
echo "###################################################################"
echo "$(tput sgr0)"

(
    if [ -d ${OPENSSL_SRC_DIR} ]
    then
        rm -rf ${OPENSSL_SRC_DIR}
    fi

    mkdir -p ${OPENSSL_SRC_DIR}

    #cd `dirname ${OPENSSL_SRC_DIR}`
    cd ${OPENSSL_SRC_DIR}

    if [ "${USE_GIT_MASTER}" == "YES" ]
    then
        git clone ${OPENSSL_GIT_URL}
    else
        if [ -d ${OPENSSL_RELEASE_DIRNAME} ]
        then
            rm -rf "${OPENSSL_RELEASE_DIRNAME}"
        fi
        curl --location ${OPENSSL_RELEASE_URL} --output ${OPENSSL_RELEASE_DIRNAME}.tar.gz
        tar xvf ${OPENSSL_RELEASE_DIRNAME}.tar.gz
        mv openssl-openssl-${OPENSSL_VERSION} openssl-${OPENSSL_VERSION}
        pwd

        rm ${OPENSSL_RELEASE_DIRNAME}.tar.gz

        # Remove the version of  Test included with the release.
        # We will replace it with version 1.7.0 in a later step.
#        if [ -d "${OPENSSL_SRC_DIR}/gtest" ]
#        then
#            rm -r "${OPENSSL_SRC_DIR}/gtest"
#        fi
    fi
)

conditionalPause


###################################################################
# This section contains the build commands to create the native
# openssl library for Mac OS X.  This is done first so we have
# a copy of the each binaries.  It will be used in all of the
# susequent universal builds.
###################################################################



if [ "${BUILD_MACOSX_ARM_64}" == "YES" ]
then
    echo "$(tput setaf 2)"
    echo "###################################################################"
    echo "# arm for Mac OS X"
    echo "###################################################################"
    echo "$(tput sgr0)"

    (   
        export MACOSX_DEPLOYMENT_TARGET=10.15 #/* arm64 only with Big Sur -> minimum might be 10.16 or 11.0 */)
        echo "MACOSX_DEPLOYMENT_TARGET : ${MACOSX_DEPLOYMENT_TARGET}"
        cd ${OPENSSL_SRC_DIR}/${OPENSSL_RELEASE_DIRNAME}
        make distclean

        mkdir -p ${PREFIX}/platform/arm64-osx

        #./configure --disable-shared --prefix=${PREFIX} --host=arm --exec-prefix=${PREFIX}/platform/arm64-osx "CC=${CC}" "CFLAGS=${CFLAGS} -arch arm64" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS}" "LDFLAGS=${LDFLAGS}" "LIBS=${LIBS}"
        printf "Running CONFIGURE Command with args: ./Configure enable-rc5 zlib ${DARWIN_ARM} no-asm shared --prefix=${PREFIX}/platform/arm64-osx \n\n"
        ./Configure enable-rc5 zlib ${DARWIN_ARM} no-asm shared --prefix=${PREFIX}/platform/arm64-osx
        printf "\n\nConfigure done. Running make for ARM_64 for Mac OS X. It will take around 5-10 mins to complete. Check logs at path: /tmp/openssl_build.log...\n\n"
        make >> /tmp/openssl_build.log
        make install >> /tmp/openssl_build.log
    )   
fi

conditionalPause

if [ "${BUILD_MACOSX_X86_64}" == "YES" ]
then
    echo "$(tput setaf 2)"
    echo "###################################################################"
    echo "# x86_64 for Mac OS X"
    echo "###################################################################"
    echo "$(tput sgr0)"

    (
        export MACOSX_DEPLOYMENT_TARGET=10.9
        cd ${OPENSSL_SRC_DIR}/${OPENSSL_RELEASE_DIRNAME}
        make distclean >> /tmp/openssl_build.log

        printf "\n\n===================== Now Buolding for ARM64 =====================\n\n" >> /tmp/openssl_build.log

        mkdir -p ${PREFIX}/platform/x86_64-osx

        #\./configure --disable-shared --prefix=${PREFIX} --exec-prefix=${PREFIX}/platform/x86_64-osx "CC=${CC}" "CFLAGS=${CFLAGS} -arch x86_64" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch x86_64" "LDFLAGS=${LDFLAGS}" "LIBS=${LIBS}"
        printf "Running CONFIGURE Command with args: ./Configure ${DARWIN_X86} shared --prefix=${PREFIX}/platform/x86_64-osx \n\n"
        ./Configure ${DARWIN_X86} shared --prefix=${PREFIX}/platform/x86_64-osx
        printf "\n\nConfigure done. Running make for x86_64 for Mac OS X. It will take around 5-10 mins to complete. Check logs at path: /tmp/openssl_build.log...\n\n"
        make >> /tmp/openssl_build.log
        make install >> /tmp/openssl_build.log
    )
fi

conditionalPause

echo "$(tput setaf 2)"
echo "###################################################################"
echo "# Create Universal Libraries and Finalize the packaging"
echo "###################################################################"
echo "$(tput sgr0)"


(
    cd ${PREFIX}/platform
    mkdir universal
    lipo x86_64-osx/lib/libcrypto.a arm64-osx/lib/libcrypto.a -create -output universal/libcrypto.a
    lipo x86_64-osx/lib/libssl.a arm64-osx/lib/libssl.a -create -output universal/libssl.a
    lipo x86_64-osx/lib/libcrypto.3.dylib arm64-osx/lib/libcrypto.3.dylib -create -output universal/libcrypto.3.dylib
    lipo x86_64-osx/lib/libssl.3.dylib arm64-osx/lib/libssl.3.dylib -create -output universal/libssl.3.dylib
)

(
    cd ${PREFIX}/platform
    printf "\n\nUniversal Binaries and Library created at path: ${PREFIX}/platform/universal"
    printf "\n\tlibcrypto.a Info : "
    lipo -info universal/libcrypto.a
    printf "\n\tlibssl.a Info : "
    lipo -info universal/libssl.a
    printf "\n\t libcrypto.3.dylib Info : "
    lipo -info universal/libcrypto.3.dylib
    printf "\n\t libssl.3.dylib Info : "
    lipo -info universal/libssl.3.dylib
)

if [ "${USE_GIT_MASTER}" == "YES" ]
then
    if [ -d "${PREFIX}-master" ]
    then
        rm -rf "${PREFIX}-master"
    fi
    mv "${PREFIX}" "${PREFIX}-master"
else
    if [ -d "${PREFIX}-${OPENSSL_VERSION}" ]
    then
        rm -rf "${PREFIX}-${OPENSSL_VERSION}"
    fi
    mv "${PREFIX}" "${PREFIX}-${OPENSSL_VERSION}"
fi
printf  "\n\nDone. Contact vishalk@netskope.com for details!\n"

