ARG PLAYWRIGHT_DOCKER_IMAGE=ghcr.io/xima-media/playwright:1.59.1
ARG KASMVNC_VERSION=1.4.0
ARG KASMVNC_DIST=noble
FROM ${PLAYWRIGHT_DOCKER_IMAGE}

ARG PLAYWRIGHT_DOCKER_IMAGE
ARG KASMVNC_VERSION
ARG KASMVNC_DIST
LABEL PARENT_IMAGE="${PLAYWRIGHT_DOCKER_IMAGE}"

# Debian images by default disable apt caching, so turn it on until we finish
# the build.
RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/docker-clean-disabled

# Install sudo and the mariadb client.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
      --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y sudo mariadb-client

# Install mkcert for the correct architecture.
ARG TARGETARCH
RUN mkdir -p /usr/local/bin && \
    curl --fail -JL -s -o /usr/local/bin/mkcert "https://dl.filippo.io/mkcert/latest?for=linux/${TARGETARCH}" && \
    chmod +x /usr/local/bin/mkcert

# Install a window manager.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
      --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y icewm xauth

# Enable universe repository for Ubuntu (needed for KasmVNC dependencies for some versions).
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository -y universe && apt-get update

# Install KasmVNC for remote access. Bundling this in the image avoids downloading
# the deb from GitHub at ddev add-on build time, which is prone to availability issues.
RUN wget https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_${KASMVNC_DIST}_${KASMVNC_VERSION}_${TARGETARCH}.deb && \
      apt-get install -y ./kasmvncserver*.deb && \
      rm -f kasmvncserver*.deb

# We're done with apt so disable caching again for the final image.
RUN mv /etc/apt/docker-clean-disabled /etc/apt/apt.conf.d/docker-clean
