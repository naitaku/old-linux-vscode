ARG BASE_IMAGE=ubuntu:16.04
FROM ubuntu:latest AS toolchain

RUN apt-get update && \
 apt-get install -y gcc g++ gperf bison flex texinfo help2man make libncurses5-dev \
python3-dev autoconf automake libtool libtool-bin gawk wget bzip2 xz-utils unzip \
patch rsync meson ninja-build

# Install crosstool-ng
RUN wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.26.0.tar.bz2
RUN tar -xjf crosstool-ng-1.26.0.tar.bz2
RUN cd crosstool-ng-1.26.0 && ./configure --prefix=/crosstool-ng-1.26.0/out && make && make install

# Build the toolchain
RUN mkdir toolchain-dir && wget -O toolchain-dir/.config https://raw.githubusercontent.com/microsoft/vscode-linux-build-agent/refs/heads/main/x86_64-gcc-8.5.0-glibc-2.28.config
RUN cd toolchain-dir && CT_ALLOW_BUILD_AS_ROOT=y CT_ALLOW_BUILD_AS_ROOT_SURE=y /crosstool-ng-1.26.0/out/bin/ct-ng build
RUN mkdir /opt/toolchains && mv /toolchain-dir/x86_64-linux-gnu/x86_64-linux-gnu /opt/toolchains

# Install patchelf
RUN cd /opt/toolchains && \
    wget https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz && \
    tar -xzf patchelf-0.18.0-x86_64.tar.gz && \
    rm patchelf-0.18.0-x86_64.tar.gz

# Copy the toolchain to a new image
FROM ${BASE_IMAGE}
COPY --chown=root:root --from=toolchain /opt/toolchains /opt/toolchains

# Environment variables for VS Code
# https://code.visualstudio.com/docs/remote/faq#_can-i-run-vs-code-server-on-older-linux-distributions
ENV VSCODE_SERVER_PATCHELF_PATH=/opt/toolchains/bin/patchelf
ENV VSCODE_SERVER_CUSTOM_GLIBC_LINKER=/opt/toolchains/x86_64-linux-gnu/sysroot/lib/ld-2.28.so
ENV VSCODE_SERVER_CUSTOM_GLIBC_PATH=/opt/toolchains/x86_64-linux-gnu/sysroot/lib
