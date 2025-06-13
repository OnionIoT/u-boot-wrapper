#!/bin/sh

REPO="https://github.com/OnionIoT/u-boot"
COMMIT="317613c4c42e882f310265d8a9e9e0c1dcb80085"
UBOOT_RELEASE="v2025.04"

TARGET_DEVICE="onion-omega2p"
TARGET_ARCH="mips"
TARGET_CROSS_COMPILE="mipsel-linux-gnu-"
COMPILE_FLAGS='KCFLAGS="-Os -pipe -fno-caller-saves"'
