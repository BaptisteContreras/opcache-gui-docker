FROM node:18-bullseye-slim AS builder-node

RUN  apt-get update \
     && apt-get install -y git \
     && apt-get install -y python3 \
     && apt-get install -y make \
     && apt-get install -y g++

RUN mkdir /app
WORKDIR /app

RUN git clone https://github.com/amnuts/opcache-gui.git
WORKDIR /app/opcache-gui

RUN npm install \
    && npm run compile-jsx \
    && npm run compile-scss

FROM php:8.1-fpm-bullseye AS builder-php

WORKDIR /app/opcache-gui

COPY --from=builder-node /app/opcache-gui ./

RUN echo 'exit 0' > /usr/bin/npm \
    && chmod +x /usr/bin/npm

RUN php build/build.php

FROM nginx:1.25.0-bullseye

WORKDIR /app

COPY --from=builder-php /app/opcache-gui/index.php ./

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/fastcgi.conf /etc/nginx/fastcgi.conf
COPY nginx/opcache-gui.conf /etc/nginx/conf.d/default.conf

ARG REMOTE_PHPFPM_HOST
ARG REMOTE_PHPFPM_PORT=9000

RUN echo 'upstream fastcgi_backend {' > /etc/nginx/fastcgi_upstream.conf \
    && echo "server $REMOTE_PHPFPM_HOST:$REMOTE_PHPFPM_PORT;" >> /etc/nginx/fastcgi_upstream.conf \
    && echo 'keepalive 8;' >> /etc/nginx/fastcgi_upstream.conf \
    && echo '}' >> /etc/nginx/fastcgi_upstream.conf

EXPOSE 80