FROM trini/u-boot-gitlab-ci-runner:jammy-20250404-29Apr2025

USER root
WORKDIR /u-boot-wrapper
COPY --chown=uboot:uboot . /u-boot-wrapper
RUN chown uboot:uboot /u-boot-wrapper \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      gcc-mipsel-linux-gnu binutils-mipsel-linux-gnu \
 && rm -rf /var/lib/apt/lists/*

# Debian drops the binaries in /usr/bin
ENV PATH=/usr/bin:$PATH
WORKDIR /u-boot-wrapper/u-boot
USER uboot
CMD ["bash"]