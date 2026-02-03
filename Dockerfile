# Anki Desktop Docker - High Performance Browser-Based Anki
# Uses LinuxServer's KasmVNC for optimal streaming performance
# Supports latest Anki with launcher system (25.09+)
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

# Build arguments
ARG ANKI_LAUNCHER_VERSION="25.09"
ARG BUILD_DATE
ARG VERSION

# Labels
LABEL build_version="Anki Desktop Docker version: ${VERSION} Build-date: ${BUILD_DATE}"
LABEL maintainer="chrislongros"
LABEL org.opencontainers.image.description="Browser-accessible Anki Desktop with KasmVNC - Latest Version"

# Environment variables
ENV TITLE="Anki" \
    CUSTOM_PORT=3000 \
    CUSTOM_HTTPS_PORT=3001 \
    START_DOCKER=false \
    PUID=1000 \
    PGID=1000 \
    ANKI_LAUNCHER_VERSION=${ANKI_LAUNCHER_VERSION}

# Install Anki dependencies
RUN \
    echo "**** install dependencies ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        # Python (required for launcher)
        python3 \
        python3-pip \
        python3-venv \
        # Qt/X11 libraries (dependencies for Anki)
        libxcb-xinerama0 \
        libxcb-cursor0 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-render-util0 \
        libxcb-shape0 \
        libnss3 \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        libgbm1 \
        libasound2 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libatk1.0-0 \
        libatk-bridge2.0-0 \
        libcups2 \
        libdrm2 \
        libgtk-3-0 \
        libegl1 \
        libgl1 \
        libxkbcommon0 \
        libxkbcommon-x11-0 \
        libatomic1 \
        # Tools
        zstd \
        xdg-utils \
        curl \
        ca-certificates \
        # Fonts
        fonts-liberation \
        fonts-noto \
        fonts-noto-color-emoji \
    && \
    echo "**** download Anki launcher ${ANKI_LAUNCHER_VERSION} to staging ****" && \
    mkdir -p /opt/anki-launcher-staging && \
    curl -fLo /tmp/anki-launcher.tar.zst \
        "https://github.com/ankitects/anki/releases/download/${ANKI_LAUNCHER_VERSION}/anki-launcher-${ANKI_LAUNCHER_VERSION}-linux.tar.zst" && \
    cd /tmp && \
    tar --use-compress-program=unzstd -xf anki-launcher.tar.zst && \
    cp -a anki-launcher-${ANKI_LAUNCHER_VERSION}-linux/. /opt/anki-launcher-staging/ && \
    chmod +x /opt/anki-launcher-staging/anki && \
    ls -la /opt/anki-launcher-staging/ && \
    echo "${ANKI_LAUNCHER_VERSION}" > /opt/anki-launcher-staging/version.txt && \
    echo "**** cleanup ****" && \
    rm -rf /tmp/anki* && \
    apt-get remove -y zstd && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# Copy application config
COPY root/ /

# Expose ports (KasmVNC default ports)
EXPOSE 3000 3001

# Volume for Anki data persistence
VOLUME /config
