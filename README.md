# u-boot-wrapper

Build and release the modern u-boot bootloader

## What this repo does

1. Used to create and publish a Docker image that is setup build the u-boot bootloader
2. Uses that image to build u-boot image binaries

## `profile` Configuration File

Specifies all configuration data: which repo (and commit of that repo) to build, the target device, architecture, and cross compiler

## Setting up the tree for creating a Docker image

Step 1 in [What this repo does section](#what-this-repo-does)

To: 
- clone the REPO specified in `profile`
- checkout the COMMIT specified in `profile`
- apply patches (if any exist)

Run: 

```
bash build.sh setup_tree
```

# TODO 

- ✅ change dockerfile so image includes profile and buildscript
- fix build-image workflow to also use sha in docker image name
- add gh action job to build image and publish to aws s3
    - build job:
        - checkout
        - ❌set build date
        - pull image
        - startup docker container
        - run build command
        - push artifacts to S3
- update gh action to run workflow only on release?
- update readme