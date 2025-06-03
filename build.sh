#!/bin/bash

. ./profile

[ -z "$REPO" ] && exit 1
[ -z "$TARGET_DEVICE" ] && exit 1
[ -z "$TARGET_ARCH" ] && exit 1
[ -z "$TARGET_CROSS_COMPILE" ] && exit 1
[ -z "$RELEASE" ] && exit 1

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

setup_tree () {
    checkout_repo
    apply_patches
    echo "Tree setup complete, ready to make Docker container or build directly"
}

# build_uboot() {
#     cd /u-boot
#     make ${TARGET_DEVICE}_defconfig
#     make ARCH=${TARGET_ARCH} CROSS_COMPILE=${TARGET_CROSS_COMPILE}
#     cp u-boot-with-spl.bin /out/u-boot-with-spl-${RELEASE}-$(date +'%Y%m%d').bin
# }

commands="
setup_tree
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
