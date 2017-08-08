FROM frolvlad/alpine-glibc:alpine-3.6

MAINTAINER https://github.com/dtandersen/docker_factorio_server

ARG VERSION
ARG SHA1

# Install Ruby
RUN apk update && apk upgrade && apk --update add \
    ruby ruby-irb ruby-rake ruby-io-console ruby-bigdecimal ruby-json ruby-bundler \
    libstdc++ tzdata bash ca-certificates \
    git \
    &&  echo 'gem: --no-document' > /etc/gemrc

# Install Factorio
RUN mkdir /opt && \
    apk add --update --no-cache tini pwgen && \
    apk add --update --no-cache --virtual .build-deps curl && \
    curl -sSL https://www.factorio.com/get-download/$VERSION/headless/linux64 \
        -o /tmp/factorio_headless_x64_$VERSION.tar.xz && \
    echo "$SHA1  /tmp/factorio_headless_x64_$VERSION.tar.xz" | sha1sum -c && \
    tar xf /tmp/factorio_headless_x64_$VERSION.tar.xz --directory /opt && \
    rm /tmp/factorio_headless_x64_$VERSION.tar.xz && \
    ln -s /factorio/saves /opt/factorio/saves && \
    ln -s /factorio/mods /opt/factorio/mods && \
    ln -s /factorio/config /opt/factorio/config && \
    apk del .build-deps

# Get Factorio Mod Updater
RUN mkdir /opt/factorio-mod-updater && \
    chown `whoami` /opt/factorio-mod-updater && \
    git clone https://github.com/astevens/factorio-mod-updater /opt/factorio-mod-updater

VOLUME /factorio

EXPOSE 34197/udp 27015/tcp

COPY ./run.sh /

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/run.sh"]

COPY mods /opt/factorio/mods
COPY scenarios /opt/factorio/scenarios
COPY config /opt/factorio/config