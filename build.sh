#!/bin/bash

. ./profile

[ -z "$REPO" ] && exit 1
[ -z "$TARGET_DEVICE" ] && exit 1
[ -z "$TARGET_ARCH" ] && exit 1
[ -z "$TARGET_CROSS_COMPILE" ] && exit 1
[ -z "$UBOOT_RELEASE" ] && exit 1

REPO_NAME="u-boot"

checkout_repo() {
    echo "Checking out repository: $REPO"
    if [ ! -d "$REPO_NAME" ]; then
        git clone "$REPO" "$REPO_NAME"
    fi
    if [ ! -z "COMMIT" ]; then
        echo "Checking out commit: $COMMIT"
        cd "$REPO_NAME"
        git fetch origin
        git checkout "$COMMIT"
        cd -
    fi
}

apply_patches() {
    cd "$REPO_NAME"
    if [ -d "patches" ]; then
        echo "Applying patches"
        for patch in patches/*.patch; do
            if [ -f "$patch" ]; then
                git apply "$patch"
            fi
        done
    fi
    cd -
}

add_files() {
    cp profile "$REPO_NAME/"
    cp build.sh "$REPO_NAME/"
}

setup_tree () {
    checkout_repo
    apply_patches
    add_files
    echo "Tree setup complete, ready to make Docker container or build directly"
}

build_uboot() {
    # if already in u-boot directory, skip changing directory
    cwd=$(basename $PWD)
    if [ "$cwd" != "$REPO_NAME" ]; then
        cd $REPO_NAME
    fi

    echo "Building U-Boot for $TARGET_DEVICE"
    make ${TARGET_DEVICE}_defconfig
    eval "make ARCH=${TARGET_ARCH} CROSS_COMPILE=${TARGET_CROSS_COMPILE} ${COMPILE_FLAGS}"
    if [ $? -ne 0 ]; then
        echo "Build failed"
        exit 1
    fi

    echo "Build successful"
    mkdir -p output

    cp u-boot-with-spl.bin output/${TARGET_DEVICE}_u-boot-with-spl-${UBOOT_RELEASE}-$(date +'%Y%m%d').bin
}

commands="
setup_tree
build_uboot
"

usage() {
	local cmd

	echo "$0: "

	for cmd in $commands; do
		echo -e "\t$cmd"
	done
}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi

if [ "$(type -t $1)" != "function" ]; then
	echo "$1: function not found"
	usage
	exit 1
fi

cmd=$1
shift
$cmd $@
