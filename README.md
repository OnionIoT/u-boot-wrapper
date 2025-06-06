# u-boot-wrapper

Build and release the modern u-boot bootloader

## What this repo does

Primarily:
1. Setup the u-boot tree (at a specific commit)
2. Build u-boot for the Omega2. Output is an image that can be flashed to the device

Additionally, this repo:
- Can be used to create (and publish) a Docker Image to build the u-boot bootloader. This Docker image can be multi-architecture

See below for more details on using this repo

## Output of this Repo and CI

This repo is configured to automatically run a GitHub actions workflow when a new release is created.

The workflow will:
- Build u-boot for the Omega2
- Publish the u-boot image to: http://repo.onioniot.com/omega2/bootloader/[UBOOT_RELEASE]/ (where `UBOOT_RELEASE` is defined in the `profile` configuration file)
  - Currently, images will be published to: http://repo.onioniot.com/omega2/bootloader/v2025.04/
- Publish a Docker Image with the u-boot tree and all pre-requisites for compiling u-boot to Docker Hub. Images are available for x86 and ARM architectures. See https://hub.docker.com/r/onion/u-boot-builder

## `profile` Configuration File

Specifies all configuration data: which repo (and commit of that repo) to build, the target device, architecture, and cross compiler

## Using the build.sh script to build u-boot

> Note this section assumes the host computer has all of the pre-requisites needed to compile u-boot. If not, see the "Using Docker" section below.

An overview of what the build.sh script does

### Step 1: Setting up the u-boot tree

To: 
- clone the REPO specified in `profile`
- checkout the COMMIT specified in `profile`
- apply patches (if any exist in the `patches` directory)

Run: 

```
bash build.sh setup_tree
```

The u-boot tree will be available at `./u-boot`

### Step 2: Building u-boot

To then use the u-boot tree to build u-boot for the Omega2, run:

```
bash build.sh build_uboot
```

The compiled image can be found in `u-boot/output`

## Using Docker 

U-boot can be built using Docker in two ways:
1. Using this repo to build your own Docker Image
2. Using the Docker Image published by Onion 

Method 1 allows you to customize your image, in case you have any changes you want to make to the u-boot tree.

Method 2 is quicker since it uses a ready-to-go container that just needs to be pulled from Docker Hub. This is the better option if you don't need customization.

### Method 1: Building your own Docker Image

This repo contains a Dockerfile that can be used to create a Docker image that has all of the software packages, utilities, and cross compilers required to compile u-boot for the Omega2.

Follow these instructions to compile with Docker:

#### Step 1: Setting up the u-boot tree

To: 
- clone the REPO specified in `profile`
- checkout the COMMIT specified in `profile`
- apply patches (if any exist in the `patches` directory)

Run: 

```
bash build.sh setup_tree
```

The u-boot tree will be available at `./u-boot`

#### Step 2: Build the Docker Image

Next, build a Docker image that:
- contains the u-boot tree setup in the previous step
- has all of the prerequisites for building u-boot installed

> Note this Docker image is based on Tom Rini's Docker image and on the [u-boot docker documentation](https://docs.u-boot.org/en/latest/build/docker.html)

To build the Docker Image:

```
docker build -t u-boot-builder .
```

Where `u-boot-builder` is the name of the image. 


#### Step 3: Launch the Docker Container

Then, start a Docker container based on the Image:

```
docker run --rm -it uboot-builder-with-srcu-boot-builder bash
```

#### Step 4: Build u-boot in the Docker container

Once inside the Docker container, build u-boot by running:

```
bash /u-boot-wrapper/build.sh build_uboot
```

The compiled image can be found in the Docker container at `/u-boot-wrapper/u-boot/output/`

> To copy the compiled image out to your host computer, see the Docker documentation on the [copy command](https://docs.docker.com/reference/cli/docker/container/cp/) or on [mounting volumes](https://docs.docker.com/engine/storage/volumes/).

### Method 2: Using Onion's Docker Image

#### Step 1: Pull the Docker Image

Pull Onion's Docker Image from Dockerhub:

```
docker pull onion/u-boot-builder:latest
```

#### Step 2: Launch the Docker Container

Then, start a Docker container based on the Image:

```
docker run --rm -it uboot-builder-with-srcu-boot-builder bash
```

#### Step 3: Build u-boot in the Docker container

Once inside the Docker container, build u-boot by running:

```
bash /u-boot-wrapper/build.sh build_uboot
```

The compiled image can be found in the Docker container at `/u-boot-wrapper/u-boot/output/`

> To copy the compiled image out to your host computer, see the Docker documentation on the [copy command](https://docs.docker.com/reference/cli/docker/container/cp/) or on [mounting volumes](https://docs.docker.com/engine/storage/volumes/).

## Creating Multi-Arch Docker Images

Onion uses this repo to create Docker Images for multiple architectures. 

**This section is for reference, users of this repo can follow the "Using Docker" section above for their own building needs - their host computer will automatically build a Docker Image for the host computer architecture.**

Instructions assume a Ubuntu system:

```
sudo apt update
sudo apt install -y docker.io docker-buildx git

sudo groupadd -f docker
sudo usermod -aG docker "$USER"
```

Log out and in, then continue

```
sudo systemctl enable --now docker
```

Register QEMU user-mode emulators (needed for multi-arch builds):
```
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

Create & bootstrap a Buildx builder (runs BuildKit in a container:
```
docker buildx create --name uboot-builder --driver docker-container --use
docker buildx inspect --bootstrap
```

To build images for x86 and ARM:

```
docker buildx build \
  --platform linux/amd64,linux/arm64/v8 \
  -t [IMAGE_TAG] \
  --load \
  .
```