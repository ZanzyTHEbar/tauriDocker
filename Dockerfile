######################
# Base
# Base dependencies for all images
######################
FROM node:18-bullseye-slim AS base

ENV APP_VERSION="1.3.0" \
    APP="tauri_docker"

LABEL app.name="${APP}" \
    app.version="${APP_VERSION}" \
    maintainer="DaOfficialWizard <pyr0ndet0s97@gmail.com>"

WORKDIR /workspace

# Ensure rustup/cargo is in the path
ENV PATH="/root/.cargo/bin:${PATH}"

# Arguments
ARG PNPM_VERSION="8.5.1"
ARG TAURI_DEPENDENCIES="libgtk-3-dev git libwebkit2gtk-4.0-dev libappindicator3-dev libayatana-appindicator3-dev librsvg2-dev patchelf libxss-dev libssl-dev"

# Install dependencies
RUN apt update \
    # General build stuff
    && apt install -y wget curl libssl-dev pkg-config build-essential ${TAURI_DEPENDENCIES} \
    # Install rust
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && rustup update
    #&& mkdir -p src-tauri/.cargo \
    #&& echo '[registries.crates-io]\n\
    #protocol = "sparse"\n'\
    #>> src-tauri/.cargo/config.toml

RUN apt-get \
    clean \
    autoclean &&\
    apt-get \
    autoremove \
    --yes && \
    rm -rf \
    /var/lib/{apt,dpkg,cache,log}/

# Update new packages
RUN apt-get update && apt-get upgrade -y

# Install Tauri
RUN cargo install tauri-cli
RUN cargo install cargo-edit

#######################
## Chef
## Installs cargo-chef
#######################
#FROM base AS chef
#WORKDIR /workspace
#
#RUN cargo install cargo-chef
#
#######################
## Planner
## Prepares the recipe for the builder image
#######################
#FROM chef AS planner
##COPY . .
#RUN cd src-tauri && cargo chef prepare --recipe-path recipe.json
#
#######################
## Builder
## Builds the dependencies
#######################
#FROM chef AS builder
#COPY --from=planner /app/src-tauri/recipe.json recipe.json
#RUN cargo chef cook --release

######################
# Final
######################
FROM base as final
WORKDIR /workspace

# Install PNPM
RUN corepack enable \
    && corepack prepare pnpm@${PNPM_VERSION} --activate \
    && pnpm config set store-dir /usr/.pnpm-store

# Cache PNPM dependencies
#COPY pnpm-lock.yaml ./
#RUN pnpm fetch

# Copy source code
#COPY . .

ENTRYPOINT ["tauri_script"]

## Install dependencies
#RUN pnpm install -r --offline 

## Copy over the cached Rust dependencies
#COPY --from=builder /app/target src-tauri/target
#
## Build
#RUN pnpm tauri build
#
#######################
## Bundle
## Bundles the final binary
#######################
#FROM scratch
#COPY --from=final /app/src-tauri/target/release/bundle /bundle












#######################
## Previous version
#######################
#FROM ubuntu:18.04
#
#ENV NODE_VERSION="16.20.0"
#
#
#
## Update default packages
#RUN apt-get -qq update
#RUN apt-get upgrade -y
#
## Get Ubuntu packages
#RUN apt-get install -y -q \
#    build-essential \
#    curl
#
#RUN mkdir -p /workspace && \
#    apt install -y \
#    libwebkit2gtk-4.0-dev \
#    build-essential \
#    curl \ 
#    wget \
#    libssl-dev \
#    libgtk-3-dev \
#    libayatana-appindicator3-dev \
#    librsvg2-dev && \
#    apt update && \
#    apt install -y \
#    git \
#    unzip && \ 
#    apt-get \
#    clean \
#    autoclean &&\
#    apt-get \
#    autoremove \
#    --yes && \
#    rm -rf \
#    /var/lib/{apt,dpkg,cache,log}/
#
## Update new packages
#RUN apt-get update
#
## Get Node
#RUN apt install -y curl
#RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
#ENV NVM_DIR="/root/.nvm"
#RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
#RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
#RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
#RUN ls -la ${NVM_DIR}/versions
#ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin/:${PATH}"
#RUN node -v
#RUN npm -v
#
## Get Rust
#RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
#
##RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc
#
#ENV PATH="/root/.cargo/bin:${PATH}"
## Check cargo is visible
#RUN cargo --help
#
## Install Tauri
#RUN cargo install tauri-cli
#RUN cargo install cargo-edit
#
##USER 1000
#
#
#
#ENTRYPOINT ["tauri_script"]
#
##FROM rust:1.67
##
##WORKDIR /usr/src/myapp
##COPY . .
##
##RUN cargo install --path .
##
##CMD ["myapp"]