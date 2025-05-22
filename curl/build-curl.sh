#!/bin/bash
#
# This script file is used to build curl.
# This script file requires following tools to be installed:
# curl, xcode
#
# Usage: ./build_curl.sh
#

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

LIB_VER=curl-7.86.0
OUT_DIR=${DIR}/out
LIB_DIR=${OUT_DIR}/${LIB_VER}
LIB_PKG=${DIR}/${LIB_VER}.zip
LIB_RESULT=${DIR}/osx-universal
SSL_DIR_ORG=${DIR}/../openssl/osx-universal
SSL_DIR=${DIR}/openssl

BUILD_ERR() {
    echo "********* ${LIB_VER} Build Failed! ************"
    echo "$1"
    exit 1
}

rm -rf ${OUT_DIR}
rm -rf ${SSL_DIR}
rm -rf ${LIB_DIR}
rm -rf ${LIB_VER}.zip
rm -rf ${LIB_VER}
rm -rf ${LIB_RESULT}
mkdir ${OUT_DIR}
mkdir ${SSL_DIR}
mkdir ${SSL_DIR}/lib
mkdir ${LIB_RESULT}

cp ${SSL_DIR_ORG}/lib/release/static/* ${SSL_DIR}/lib
cp -rf ${SSL_DIR_ORG}/include ${SSL_DIR}/

if [ ! -f ${LIB_PKG} ]; then
    curl -o ${LIB_PKG} https://curl.se/download/${LIB_VER}.zip
fi

# build for arm64 and x86_64
for ARCH in arm64 x86_64; do

    LIB_OUT=${OUT_DIR}/osx-${ARCH}
    LIB_DIR=${LIB_OUT}/${LIB_VER}

    rm -rf ${LIB_OUT}
    mkdir ${LIB_OUT}

    # Extract library
    pushd ${LIB_OUT}
    if [ ! -f ${LIB_PKG} ]; then
        BUILD_ERR "Failed to Extract library"
    fi
    unzip ${LIB_PKG}
    popd

    pushd ${LIB_DIR}
    # https://curl.se/docs/install.html
    export ARCH
    export SDK=macosx
    export DEPLOYMENT_TARGET="10.15"
    export CFLAGS="-arch ${ARCH} -isysroot $(xcrun -sdk ${SDK} --show-sdk-path) -m${SDK}-version-min=${DEPLOYMENT_TARGET}"
    export CXXFLAGS="-arch ${ARCH}"
    export LDFLAGS="-arch ${ARCH}"

    ./configure --without-libidn2 --without-nghttp2 --host=${ARCH}-apple-darwin --prefix=${LIB_OUT} --with-openssl=${SSL_DIR}
    if [[ $? != 0 ]]; then
        BUILD_ERR "Failed to Configure libcurl for platform ${ARCH}"
    fi

    make -j8
    if [[ $? != 0 ]]; then
        BUILD_ERR "Failed to Make for platform ${ARCH}"
    fi

    make install
    if [[ $? != 0 ]]; then
        BUILD_ERR "Failed to Make Install for platform ${ARCH}"

    fi
    popd

done


pushd ${OUT_DIR}
# Create universal binaries
mkdir -p universal/lib
mkdir -p universal/bin
for FILE in lib/libcurl.a bin/curl; do
    lipo -create -arch arm64 ${OUT_DIR}/osx-arm64/${FILE} -arch x86_64 ${OUT_DIR}/osx-x86_64/${FILE} -output universal/${FILE}
    if [[ $? != 0 ]]; then
        BUILD_ERR "lipo -create failed"
    fi
done

tar -cvzf ${OUT_DIR}/${LIB_VER}-osx.tgz osx-arm64/include universal/bin universal/lib
if [[ $? != 0 ]]; then
    BUILD_ERR "Failed to extract universal osx bins"
fi
popd

echo "Copying universal macos bins to ${LIB_RESULT}"
cp -rf ${OUT_DIR}/universal/* ${LIB_RESULT}/
cp -rf ${OUT_DIR}/osx-arm64/include ${LIB_RESULT}/

rm -rf ${OUT_DIR}
rm -rf ${SSL_DIR}
rm -rf ${LIB_DIR}
rm -rf ${LIB_VER}
rm -rf ${LIB_VER}.zip


