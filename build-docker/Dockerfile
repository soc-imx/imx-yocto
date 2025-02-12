# 📦 Yocto Docker Builder - Dockerfile

# Use an official Ubuntu base image
FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    gawk wget git-core diffstat unzip texinfo gcc-multilib \
    build-essential chrpath socat cpio python3 python3-pip \
    python3-pexpect xz-utils debianutils iputils-ping \
    python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
    xterm sudo && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/builder

# Set working directory
WORKDIR /home/builder

# Switch to the non-root user
USER builder

# Set environment variables
ENV YOCTO_DIR=/home/builder/yocto-build

# Create build directory
RUN mkdir -p ${YOCTO_DIR} && \
    echo "export YOCTO_DIR=${YOCTO_DIR}" >> ~/.bashrc

# Set entrypoint to bash
ENTRYPOINT ["/bin/bash"]