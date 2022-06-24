ARG NODE_VERSION="16"
ARG FROM_IMAGE="moonbuggy2000/alpine-s6-node-nginx:${NODE_VERSION}"

ARG TARGET_ARCH_TAG="amd64"

ARG APP_PATH="/pasteboard"

## get the source code
#
FROM moonbuggy2000/fetcher:latest AS fetcher

ARG APP_PATH
ARG PASTEBOARD_REPO="moonbuggy/pasteboard"
ARG PASTEBOARD_BRANCH="main"
RUN git clone --branch "${PASTEBOARD_BRANCH}" --depth 1 "https://github.com/${PASTEBOARD_REPO}.git" "${APP_PATH}"

## build the image
#
FROM "${FROM_IMAGE}" AS builder

# QEMU static binaries from pre_build
ARG QEMU_DIR
ARG QEMU_ARCH
COPY _dummyfile "${QEMU_DIR}/qemu-${QEMU_ARCH}-static*" /usr/bin/

# required for building the app on some platforms
ARG BUILD_DEPS="g++ make python3"

RUN apk add --no-cache \
		git \
		imagemagick \
		${BUILD_DEPS}

ARG APP_PATH
ENV APP_PATH="${APP_PATH}" \
	NODE_ENV="production" \
	NODE_PATH="/usr/local/lib/node_modules"

WORKDIR "${APP_PATH}"

RUN npm install --location=global coffee-script@1.12.7

COPY --from=fetcher "${APP_PATH}/" ./

RUN npm install --omit=dev \
	&& npm cache clean --force

# uncomment for development
# RUN npm audit --omit=dev || true \
#  	&& npm list --omit=dev --depth=3

# remove build dependencies
RUN apk del --no-cache ${BUILD_DEPS}

RUN cp pasteboard.cron /etc/periodic/daily/

# remove QEMU static binaries
RUN rm -f "/usr/bin/qemu-${QEMU_ARCH}-static" > /dev/null 2>&1

## build the final image
#
FROM "moonbuggy2000/scratch:${TARGET_ARCH_TAG}"

COPY --from=builder / /
COPY ./root/ /

ENV NODE_ENV="production" \
	NODE_PATH="/usr/local/lib/node_modules" \
	PB_ORIGIN="pasteboard.co" \
	PB_MAX="7"

ENTRYPOINT ["/init"]

HEALTHCHECK --start-period=10s --timeout=10s CMD /healthcheck.sh
