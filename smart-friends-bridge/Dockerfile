ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG BUILD_VERSION

LABEL maintainer "airthusiast"

ENV LANG C.UTF-8

WORKDIR /opt

# Copy root filesystem
COPY rootfs /
RUN chmod a+x /run.sh

# Install Git
RUN apk add --no-cache git nodejs-current nodejs-npm

# Install NodeJS modules
RUN npm install https://github.com/airthusiast/smart-friends-bridge#1.1.0 -g

CMD [ "/run.sh" ]
