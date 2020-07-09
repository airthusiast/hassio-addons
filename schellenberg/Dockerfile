ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG BUILD_VERSION

LABEL maintainer "airthusiast"

ENV LANG C.UTF-8

WORKDIR /opt

# Install Git
RUN apk add --no-cache git nodejs nodejs-npm

# Install NodeJS modules
RUN npm install express base-64 https://github.com/airthusiast/schellenberg-rest-api#master

# Copy root filesystem
COPY rootfs /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
