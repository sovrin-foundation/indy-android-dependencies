#!/bin/bash

set -e

NDK_VERSION=android-ndk-r16b
RED="[0;31m"
GREEN="[0;32m"
BLUE="[0;34m"
NC="[0m"
ESCAPE="\033"
UNAME=$(uname | tr '[:upper:]' '[:lower:]')
NDK=${NDK_VERSION}-${UNAME}-$(uname -m)

if [ ! -d "${UNAME}-${NDK_VERSION}" ] ; then
    if [ ! -f "${NDK}.zip" ] ; then
        echo "Downloading ${NDK}"
        wget -q https://dl.google.com/android/repository/${NDK}.zip
    fi
    if [ ! -f "${NDK}.zip" ] ; then
        echo STDERR "Can't find ${NDK}"
        exit 1
    fi
    echo -e "${ESCAPE}${GREEN}Extracting ${NDK}${ESCAPE}${NC}"
    unzip -o -qq ${NDK}.zip
    mv ${NDK_VERSION} ${UNAME}-${NDK_VERSION}
fi
export ANDROID_NDK_ROOT="${PWD}/${UNAME}-${NDK_VERSION}"

SODIUM_VERSION=1.0.14

if [ ! -d "libsodium-${SODIUM_VERSION}" ] ; then
    if [ ! -f "libsodium-${SODIUM_VERSION}.tar.gz" ] ; then
        echo "Downloading libsodium-${SODIUM_VERSION}"
        wget -q https://github.com/jedisct1/libsodium/releases/download/${SODIUM_VERSION}/libsodium-${SODIUM_VERSION}.tar.gz || exit 1
    fi 
    if [ ! -f "libsodium-${SODIUM_VERSION}.tar.gz" ] ; then
        echo "Can't find libsodium-${SODIUM_VERSION}.tar.gz"
        exit 1
    fi
    echo "Extracting libsodium-${SODIUM_VERSION}"
    tar xf libsodium-${SODIUM_VERSION}.tar.gz
fi

if [ $# -gt 0 ] ; then
    archs=$@
else
    archs=(arm armv7 arm64 x86 x86_64)
fi

echo -e "${ESCAPE}${GREEN}Building for ${archs[@]}${ESCAPE}${NC}"
OLDPATH=${PATH}

for arch in ${archs[@]}; do
    case ${arch} in
        "arm")
            export CFLAGS="-Os -mthumb -marm -march=armv6"
            TARGET_HOST="arm-linux-androideabi"
            TARGET_ARCH="arm"
            NDK_API=16
            ;;
        "armv7")
            export CFLAGS="-Os -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -marm -march=armv7-a"
            export LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
            TARGET_HOST="arm-linux-androideabi"
            TARGET_ARCH="arm"
            NDK_API=16
            ;;
        "arm64")
            export CFLAGS="-Os -march=armv8-a"
            TARGET_HOST="aarch64-linux-android"
            TARGET_ARCH="arm64"
            NDK_API=21
            ;;
        "mips")
            export CFLAGS="-Os"
            TARGET_HOST="mipsel-linux-android"
            TARGET_ARCH="mips"
            NDK_API=16
            ;;
        "mips64")
            export CFLAGS="-Os -march=mips64r6"
            TARGET_HOST="mips64el-linux-android"
            TARGET_ARCH="mips64"
            NDK_API=21
            ;;
        "x86")
            export CFLAGS="-Os -march=i686"
	        TARGET_HOST="i686-linux-android"
            TARGET_ARCH="x86"
            NDK_API=16
            ;;
        "x86_64")
            export CFLAGS="-Os -march=westmere"
	        TARGET_HOST="x86_64-linux-android"
            TARGET_ARCH="x86_64"
            NDK_API=21
            ;;
        *)
            echo "Unknown architecture"
            exit 1
            ;;
    esac

    export NDK_TOOLCHAIN_DIR="${PWD}/${UNAME}-${TARGET_ARCH}"
    if [ ! -d "${NDK_TOOLCHAIN_DIR}" ] ; then
        echo "Creating toolchain directory ${NDK_TOOLCHAIN_DIR}"
        python3 ${ANDROID_NDK_ROOT}/build/tools/make_standalone_toolchain.py --arch ${TARGET_ARCH} --stl=gnustl --api ${NDK_API} --install-dir ${NDK_TOOLCHAIN_DIR} || exit 1
    fi
    export PATH=${NDK_TOOLCHAIN_DIR}/bin:${OLDPATH}
    TGT_DIR="${PWD}/prebuilt/libsodium_${arch}"
    rm -rf ${TGT_DIR}
    mkdir -p ${TGT_DIR}

    echo -e "${ESCAPE}${BLUE}Making ${arch}${ESCAPE}${NC}"

    command pushd "libsodium-${SODIUM_VERSION}" > /dev/null

    ./autogen.sh
    ./configure --prefix=${TGT_DIR} --disable-pie --disable-soname-versions --host=${TARGET_HOST}
    make clean
    make
    make install

    command popd > /dev/null

    rm -rf ${TGT_DIR}/lib/pkgconfig
    unset CFLAGS
    unset LDFLAGS
done
exit 0
