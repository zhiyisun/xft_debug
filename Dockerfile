# Dockerfile for xFasterTransformer Development Environment
#
# NOTE: To build this you will need a docker version >= 19.03 and DOCKER_BUILDKIT=1
#
#       If you do not use buildkit you are not going to have a good time
#
#       For reference:
#           https://docs.docker.com/develop/develop-images/build_enhancements/
#
# This Dockerfile:
# 1. Sets up Ubuntu with necessary system packages
# 2. Configures a user with SSH access for GitHub
# 3. Installs Intel OneCCL for optimization
# 4. Sets up Conda with a Python environment for xFasterTransformer

FROM ubuntu:latest

# Environment variables
ENV container=docker
ENV TZ=Asia/Shanghai
ENV NOTVISIBLE="in users profile"
ENV PYTHON_VERSION=3

ARG DEBIAN_FRONTEND=noninteractive

ARG PUID=1001 # Default UID
ARG PGID=1001 # Default GID

ARG ssh_prv_key
ARG ssh_pub_key

# System packages needed for development
ARG PACKAGES="gpg-agent ca-certificates libnuma-dev openssh-server build-essential \
    curl git wget locales tzdata sudo gnupg ca-certificates cmake"

# Install system packages
RUN apt-get update -y && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --fix-missing \
    $PACKAGES

# Setup locale
RUN locale-gen en_US.UTF-8

# Setup timezone
RUN echo "export VISIBLE=now" >> /etc/profile && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Modify the existing ubuntu group and user
RUN groupmod -g ${PGID} ubuntu && \
    usermod -u ${PUID} ubuntu

RUN echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
USER ubuntu
WORKDIR /home/ubuntu

# Setup ssh
RUN mkdir -p $HOME/.ssh && \
    chmod 0700 $HOME/.ssh && \
    echo "$ssh_prv_key" > $HOME/.ssh/id_rsa && \
    echo "$ssh_pub_key" > $HOME/.ssh/authorized_keys && \
    chmod 600 $HOME/.ssh/id_rsa && \
    chmod 600 $HOME/.ssh/authorized_keys && \
    ssh-keyscan github.com > $HOME/.ssh/known_hosts

# Install OneCCL
USER root
RUN wget -qO - https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor -o /usr/share/keyrings/oneapi-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list && \
    apt-get update && \
    apt-get install -y intel-oneapi-ccl-devel
USER ubuntu

# Install conda
RUN wget --no-check-certificate "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3-$(uname)-$(uname -m).sh -b && \
    rm -rf Miniforge3-$(uname)-$(uname -m).sh && \
    ~/miniforge3/bin/conda init

# Fix for incorrect path (miniforge3 vs miniconda3)
ENV PATH=/home/ubuntu/miniforge3/bin:$PATH

# Create conda environment for xFasterTransformer
RUN . ./miniforge3/bin/activate && \
    conda create -y --name xft python=$PYTHON_VERSION && \
    conda activate xft && \
    echo "conda activate xft" >> ./.bashrc && \
    echo "source /opt/intel/oneapi/setvars.sh" >> ./.bashrc && \
    pip install --no-input --upgrade pip numpy && \
    pip install torch --index-url https://download.pytorch.org/whl/cpu

# Default command to keep container running
# Note: This is overridden by the interactive shell in setup.sh
CMD ["/usr/sbin/sshd", "-D"]