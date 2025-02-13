# 📦 Yocto Docker Builder - Dockerfile

# Use an official Ubuntu base image
FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies and locales
RUN apt-get update && apt-get install -y \
    gawk wget git-core diffstat unzip texinfo gcc-multilib \
    build-essential chrpath socat cpio python3 python3-pip \
    python3-pexpect xz-utils debianutils iputils-ping \
    python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
    xterm sudo file locales && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/builder

# Set working directory
WORKDIR /home/builder


# Generate and set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8


COPY sdk.sh /tmp/

RUN cd /tmp && \
    mkdir  -p /opt/poky && \
    chmod +x sdk.sh && \
    /tmp/sdk.sh -d /opt/poky && \
    rm -rf /tmp/sdk.sh


# Switch to the non-root user
USER builder

# Set environment variables
ENV YOCTO_DIR=/home/builder/yocto-build

# Create build directory
RUN mkdir -p ${YOCTO_DIR} && \
    echo "export YOCTO_DIR=${YOCTO_DIR}" >> ~/.bashrc

RUN echo "source /opt/poky/environment-setup-arm1176jzfshf-vfp-poky-linux-gnueabi" >> ~/.bashrc

# Set entrypoint to bash
ENTRYPOINT ["/bin/bash"]