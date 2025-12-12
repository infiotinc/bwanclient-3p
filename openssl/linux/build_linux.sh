#!/bin/bash
#
# This script file is used to build openssl for Linux.
# This script file requires following tools to be installed:
# ubuntu 18, gcc 7.5, make, wget
#
# Usage: ./build_linux.sh
#

DIR="$(dirname "${BASH_SOURCE[0]}")"
DIR="$(realpath "${DIR}")"

LIB_VER=openssl-3.0.7
OUT_DIR=${DIR}/out
LIB_PKG=${DIR}/${LIB_VER}.tar.gz

BUILD_ERR() {
    echo "********* ${LIB_VER} Build Failed! ************"
    exit 1
}

rm -rf ${OUT_DIR}
mkdir ${OUT_DIR}

if [ ! -f ${LIB_PKG} ]; then
    wget -O ${LIB_PKG} https://www.openssl.org/source/${LIB_VER}.tar.gz
fi

for CFG in release debug; do
    LIB_OUT=${OUT_DIR}/${CFG}
    LIB_DIR=${LIB_OUT}/${LIB_VER}

    rm -rf ${LIB_OUT}
    mkdir ${LIB_OUT}

    # Extract library
    pushd ${LIB_OUT}
    if [ ! -f ${LIB_PKG} ]; then
        BUILD_ERR
    fi
    tar -xzf ${LIB_PKG}
    popd

    pushd ${LIB_DIR}
    if [[ "$CFG" == "release" ]]; then
        ./config disable-shared no-autoload-config --prefix=${LIB_OUT} --openssldir=${LIB_OUT}/ssl
    else
        ./config -d disable-shared no-autoload-config no-asm no-sse2 -g3 -ggdb -gdwarf-4 -fno-inline -O0 -DDEBUG_SAFESTACK --prefix=${LIB_OUT} --openssldir=${LIB_OUT}/ssl
    fi
    if [[ $? != 0 ]]; then
        BUILD_ERR
    fi

    ./configdata.pm --dump

    make
    if [[ $? != 0 ]]; then
        BUILD_ERR
    fi

    make install
    if [[ $? != 0 ]]; then
        BUILD_ERR
    fi
    popd

    pushd ${LIB_OUT}
    tar -cvzf ${OUT_DIR}/${LIB_VER}-linux-x64-$CFG.tgz bin/ include lib/*.a lib/pkgconfig ssl/*.cnf
    if [[ $? != 0 ]]; then
        BUILD_ERR
    fi
    popd
done

