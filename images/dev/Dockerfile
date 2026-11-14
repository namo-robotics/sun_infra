# Shared development tools; projects install Sun and their own native dependencies.
FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    ca-certificates \
    ccache \
    clang-20 \
    clang-format-20 \
    clangd-20 \
    cmake \
    curl \
    gdb \
    git \
    libclang-20-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libgtest-dev \
    libncurses-dev \
    libprotobuf-dev \
    libprotoc-dev \
    libxml2-dev \
    libzstd-dev \
    lld-20 \
    lldb-20 \
    llvm-20-dev \
    llvm-20-tools \
    locales \
    ninja-build \
    openssh-client \
    pkg-config \
    protobuf-compiler \
    python3 \
    python3-venv \
    sudo \
    zlib1g-dev \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Install the complete static-link toolchain, including the musl C++ runtime.
RUN mkdir -p /opt/cross \
    && curl --fail --location --retry 3 https://musl.cc/x86_64-linux-musl-cross.tgz \
       -o /tmp/x86_64-linux-musl-cross.tgz \
    && tar -xzf /tmp/x86_64-linux-musl-cross.tgz -C /opt/cross --no-same-owner \
    && rm /tmp/x86_64-linux-musl-cross.tgz \
    && /opt/cross/x86_64-linux-musl-cross/bin/x86_64-linux-musl-gcc --version
ENV PATH="/opt/cross/x86_64-linux-musl-cross/bin:${PATH}"

# Select the shared Clang toolchain and configure the development user.
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-20 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-20 100 \
    && update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-20 100 \
    && printf '%s\n' 'ubuntu ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 CCACHE_MAXSIZE=10G

USER ubuntu
WORKDIR /home/ubuntu

RUN mkdir -p \
    .vscode-server/data/User \
    .cache/ccache \
    .config/dconf
