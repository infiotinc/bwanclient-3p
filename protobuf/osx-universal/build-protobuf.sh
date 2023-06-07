#!/bin/bash

# The version of Protobuf to build.  It must match
# one of the values found in the releases section of the github repo.
# It can be set to "master" when building directly from the github repo.
PROTOBUF_VERSION=3.21.9
#PROTOBUF_VERSION=2.6.1

# Set to "YES" if you would like the build script to
# pause after each major section.
INTERACTIVE=NO

# A "YES" value will build the latest code from GitHub on the master branch.
# A "NO" value will use the 3.21.9 tarball downloaded from googlecode.com.
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
      PROTOBUF_VERSION=master
      ;;
    -h|--help)
      printf "\nThis will build universal binaries and static library for protobuf\n"
      printf "\n\trun build-protobuf.sh -i for interactive run"
      printf "\n\trun build-protobuf.sh -m for building master branch"
      printf "\n\tEdit the script to specific any specific tag to build. Default harded tag: PROTOBUF_VERSION=3.21.9"
      printf "\nLogs can be found at path: /tmp/protobuf_build.log"
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
echo "# Preparing to build Google Protobuf"
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

echo "Starting Google Protobuf Build:" > /tmp/protobuf_build.log

# The results will be stored relative to the location
# where you stored this script, **not** relative to
# the location of the protobuf git repo.
PREFIX=`pwd`/protobuf

if [ -d ${PREFIX} ]
then
    rm -rf "${PREFIX}"
    echo "Delete: ${PREFIX}-${PROTOBUF_VERSION}"
    rm -rf "${PREFIX}-${PROTOBUF_VERSION}"
fi
mkdir -p "${PREFIX}/platform"

PROTOBUF_GIT_URL=https://github.com/google/protobuf.git
PROTOBUF_GIT_DIRNAME=protobuf
#PROTOBUF_RELEASE_URL=https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-${PROTOBUF_VERSION}.tar.gz
PROTOBUF_RELEASE_URL=https://github.com/protocolbuffers/protobuf/archive/refs/tags/v${PROTOBUF_VERSION}.tar.gz
PROTOBUF_RELEASE_DIRNAME=protobuf-${PROTOBUF_VERSION}

BUILD_MACOSX_X86_64=YES
BUILD_MACOSX_ARM_64=YES

PROTOBUF_SRC_DIR=/tmp/protobuf

# 13.4.0 - Mavericks
# 14.0.0 - Yosemite
# 15.0.0 - El Capitan
DARWIN=darwin14.0.0
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

# NOTE: Google Protobuf does not currently build if you specify 'libstdc++'
# instead of `libc++` here.
STDLIB=libc++

CFLAGS="${CLANG_VERBOSE} ${SILENCED_WARNINGS} -DNDEBUG -O0 -pipe -fPIC -fcxx-exceptions"
CXXFLAGS="${CLANG_VERBOSE} ${CFLAGS} -std=c++11 -stdlib=${STDLIB}"

LDFLAGS="-stdlib=${STDLIB}"
LIBS="-lc++ -lc++abi"

echo "PREFIX ..................... ${PREFIX}"
echo "USE_GIT_MASTER ............. ${USE_GIT_MASTER}"
echo "PROTOBUF_GIT_URL ........... ${PROTOBUF_GIT_URL}"
echo "PROTOBUF_GIT_DIRNAME ....... ${PROTOBUF_GIT_DIRNAME}"
echo "PROTOBUF_VERSION ........... ${PROTOBUF_VERSION}"
echo "PROTOBUF_RELEASE_URL ....... ${PROTOBUF_RELEASE_URL}"
echo "PROTOBUF_RELEASE_DIRNAME ... ${PROTOBUF_RELEASE_DIRNAME}"
echo "BUILD_MACOSX_X86_64 ........ ${BUILD_MACOSX_X86_64}"
echo "PROTOBUF_SRC_DIR ........... ${PROTOBUF_SRC_DIR}"
echo "DARWIN ..................... ${DARWIN}"
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
echo "# Fetch Google Protobuf"
echo "###################################################################"
echo "$(tput sgr0)"

(
    if [ -d ${PROTOBUF_SRC_DIR} ]
    then
        rm -rf ${PROTOBUF_SRC_DIR}
    fi

    mkdir -p ${PROTOBUF_SRC_DIR}

    #cd `dirname ${PROTOBUF_SRC_DIR}`
    cd ${PROTOBUF_SRC_DIR}

    if [ "${USE_GIT_MASTER}" == "YES" ]
    then
        git clone ${PROTOBUF_GIT_URL}
    else
        if [ -d ${PROTOBUF_RELEASE_DIRNAME} ]
        then
            rm -rf "${PROTOBUF_RELEASE_DIRNAME}"
        fi
        curl --location ${PROTOBUF_RELEASE_URL} --output ${PROTOBUF_RELEASE_DIRNAME}.tar.gz
        tar xvf ${PROTOBUF_RELEASE_DIRNAME}.tar.gz

        pwd

        rm ${PROTOBUF_RELEASE_DIRNAME}.tar.gz

        # Remove the version of Google Test included with the release.
        # We will replace it with version 1.7.0 in a later step.
#        if [ -d "${PROTOBUF_SRC_DIR}/gtest" ]
#        then
#            rm -r "${PROTOBUF_SRC_DIR}/gtest"
#        fi
    fi
)

conditionalPause


echo "$(tput setaf 2)"
echo "###################################################################"
echo "# Run autogen.sh to prepare for build."
echo "###################################################################"
echo "$(tput sgr0)"

(
  #cd ${PROTOBUF_SRC_DIR}
  cd ${PROTOBUF_SRC_DIR}/${PROTOBUF_RELEASE_DIRNAME}
  ( exec ./autogen.sh )
)
conditionalPause


###################################################################
# This section contains the build commands to create the native
# protobuf library for Mac OS X.  This is done first so we have
# a copy of the binaries.  It will be used in all of the
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
        cd ${PROTOBUF_SRC_DIR}/${PROTOBUF_RELEASE_DIRNAME}
        echo "Folder: ${PROTOBUF_SRC_DIR}/${PROTOBUF_RELEASE_DIRNAME}"
        make distclean

        mkdir -p ${PREFIX}/platform/arm64-osx
        
       # echo "Debug for Vishal..."
       ## IOS Config ARM64 copied: ./configure --build=x86_64-apple-${DARWIN} --host=arm --with-protoc=${PROTOC} --disable-shared --prefix=${PREFIX} --exec-prefix=${PREFIX}/platform/arm64-ios "CC=${CC}" "CFLAGS=${CFLAGS} -miphoneos-version-min=${MIN_SDK_VERSION} -arch arm64 -isysroot ${IPHONEOS_SYSROOT}" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -miphoneos-version-min=${MIN_SDK_VERSION} -arch arm64 -isysroot ${IPHONEOS_SYSROOT}" LDFLAGS="-arch arm64 -miphoneos-version-min=${MIN_SDK_VERSION} ${LDFLAGS}" "LIBS=${LIBS}"
        #
        printf "Running CONFIGURE Command with args: ./configure --disable-shared --prefix=${PREFIX} --host=arm --exec-prefix=${PREFIX}/platform/arm64-osx \"CC=${CC}\" \"CFLAGS=${CFLAGS} -arch arm64\" \"CXX=${CXX}\" \"CXXFLAGS=${CXXFLAGS}\" \"LDFLAGS=${LDFLAGS}\" \"    LIBS=${LIBS}\"\n\n"
        ./configure --disable-shared --prefix=${PREFIX} --host=arm --exec-prefix=${PREFIX}/platform/arm64-osx "CC=${CC}" "CFLAGS=${CFLAGS} -arch arm64" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS}" "LDFLAGS=${LDFLAGS}" "LIBS=${LIBS}"
        printf "\n\nConfigure done. Running make for ARM_64 for Mac OS X. It will take around 5 mins to complete. Check logs at path: /tmp/protobuf_build.log...\n\n"
        make >>  /tmp/protobuf_build.log 
        make check
        make install >> /tmp/protobuf_build.log
    )   
fi


if [ "${BUILD_MACOSX_X86_64}" == "YES" ]
then
    echo "$(tput setaf 2)"
    echo "###################################################################"
    echo "# x86_64 for Mac OS X"
    echo "###################################################################"
    echo "$(tput sgr0)"

    (
        cd ${PROTOBUF_SRC_DIR}/${PROTOBUF_RELEASE_DIRNAME}
        make distclean
        printf "Running CONFIGURE Command with args: ./configure --disable-shared --prefix=${PREFIX} --exec-prefix=${PREFIX}/platform/x86_64-osx \"CC=${CC}\" \"CFLAGS=${CFLAGS} -arch x86_64\" \"CXX=${CXX}\" \"CXXFLAGS=${CXXFLAGS} \" \"LDFLAGS=${LDFLAGS}\" \"LIBS=${LIBS}\"\n\n"
        ./configure --disable-shared --prefix=${PREFIX} --exec-prefix=${PREFIX}/platform/x86_64-osx "CC=${CC}" "CFLAGS=${CFLAGS}" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch x86_64" "LDFLAGS=${LDFLAGS}" "LIBS=${LIBS}"
        printf "\n\nConfigure done. Running make for x86_64 for Mac OS X. It will take around 5 mins to complete. Check logs at path: /tmp/protobuf_build.log...\n\n"
        make >> /tmp/protobuf_build.log
        make check
        make install >> /tmp/protobuf_build.log
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
    lipo x86_64-osx/lib/libprotobuf.a arm64-osx/lib/libprotobuf.a -create -output universal/libprotobuf.a
    lipo x86_64-osx/lib/libprotoc.a arm64-osx/lib/libprotoc.a -create -output universal/libprotoc.a
    lipo x86_64-osx/lib/libprotobuf-lite.a arm64-osx/lib/libprotobuf-lite.a -create -output universal/libprotobuf-lite.a
    lipo x86_64-osx/bin/protoc arm64-osx/bin/protoc -create -output universal/protoc
)

(
    cd ${PREFIX}/platform
#    cd ${PREFIX}
#    mkdir bin
#    mkdir lib
#    cp -r platform/x86_64-osx/bin/protoc bin
#    cp -r platform/x86_64-osx/lib/* lib
#    cp -r platform/universal/* lib
#    rm -rf platform
    printf "\n\nUniversal Binaries and Library created at path: ${PREFIX}/platform/universal"
    printf "\n\tlibprotobuf.a: Info : "
    lipo -info universal/libprotobuf.a
    printf "\n\tlibprotoc.a: Info : "
    lipo -info universal/libprotoc.a
    printf "\n\tlibprotobuf-lie.a: Info : "
    lipo -info universal/libprotobuf-lite.a
    printf "\n\tprotoc Info : "
    lipo -info universal/protoc
)

if [ "${USE_GIT_MASTER}" == "YES" ]
then
    if [ -d "${PREFIX}-master" ]
    then
        rm -rf "${PREFIX}-master"
    fi
    mv "${PREFIX}" "${PREFIX}-master"
else
    if [ -d "${PREFIX}-${PROTOBUF_VERSION}" ]
    then
        rm -rf "${PREFIX}-${PROTOBUF_VERSION}"
    fi
    mv "${PREFIX}" "${PREFIX}-${PROTOBUF_VERSION}"
fi
printf  "\n\nDone. Contact vishalk@netskope.com for details!\n"

