FROM ubuntu:18.04

ENV APP_VERSION="1.3.0" \
    APP="tauri-app" \

LABEL app.name="${APP}" \
    app.version="${APP_VERSION}" \
    maintainer="DaOfficialWizard <pyr0ndet0s97@gmail.com>"

# Update default packages
RUN apt-get -qq update
RUN apt-get upgrade -y

# Get Ubuntu packages
RUN apt-get install -y -q \
    build-essential \
    curl

RUN mkdir -p /workspace && \
    apt install -y \
    libwebkit2gtk-4.0-dev \
    build-essential \
    curl \ 
    wget \
    libssl-dev \
    libgtk-3-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev && \
    apt update && \
    apt install -y \
    git \
    unzip && \ 
    apt-get \
    clean \
    autoclean &&\
    apt-get \
    autoremove \
    --yes && \
    rm -rf \
    /var/lib/{apt,dpkg,cache,log}/

# Update new packages
RUN apt-get update

# Get Node
ENV NODE_VERSION=16.13.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

# Get Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

#RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

ENV PATH="/root/.cargo/bin:${PATH}"

# Check cargo is visible
RUN cargo --help

USER 1001

WORKDIR /workspace

ENTRYPOINT ["tauri_script"]

#FROM rust:1.67
#
#WORKDIR /usr/src/myapp
#COPY . .
#
#RUN cargo install --path .
#
#CMD ["myapp"]