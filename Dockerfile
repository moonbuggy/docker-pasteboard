ARG NODE_VERSION="16"
ARG FROM_IMAGE="moonbuggy2000/alpine-s6-node:${NODE_VERSION}"

ARG APP_PATH="/pasteboard"

## get the source code
#
ARG BUILDPLATFORM="linux/amd64"
FROM --platform="${BUILDPLATFORM}" moonbuggy2000/fetcher:latest AS fetcher

ARG APP_PATH
ARG PASTEBOARD_REPO="moonbuggy/pasteboard"
ARG PASTEBOARD_BRANCH="main"
RUN git clone --branch "${PASTEBOARD_BRANCH}" --depth 1 "https://github.com/${PASTEBOARD_REPO}.git" "${APP_PATH}"

## build the image
#
FROM "${FROM_IMAGE}" AS builder

RUN apk add -U --no-cache \
		g++ \
		make \
		python3

ARG APP_PATH
ENV APP_PATH="${APP_PATH}" \
	NODE_ENV="production" \
	NODE_PATH="/usr/local/lib/node_modules"

RUN npm install --location=global coffee-script@1.12.7

WORKDIR "/builder_root/${APP_PATH}"
COPY --from=fetcher "${APP_PATH}/" ./

RUN npm install --omit=dev \
	&& npm cache clean --force

# uncomment for development
# RUN npm audit --omit=dev || true \
#  	&& npm list --omit=dev --depth=3

WORKDIR /builder_root/
COPY root/ ./
RUN mkdir -p ./etc/periodic/daily/ \
	&& cp ".${APP_PATH}/pasteboard.cron" ./etc/periodic/daily/

ARG TARGET_TAG
RUN if [ "${TARGET_TAG}" = "latest" ]; then \
		rm -rf ./etc/nginx ./etc/s6-overlay/s6-rc.d/nginx; \
	else \
		mv healthcheck-nginx.sh healthcheck.sh; \
	fi

## build the final image
#
FROM "${FROM_IMAGE}"

ARG NODE_PORT="3000"
ENV NODE_ENV="production" \
	NODE_PATH="/usr/local/lib/node_modules" \
	NODE_PORT="${NODE_PORT}" \
	PB_ORIGIN="pasteboard.co" \
	PB_MAX="7"

RUN apk add -U --no-cache \
		git \
		imagemagick \
	&& npm install --location=global coffee-script@1.12.7

COPY --from=builder /builder_root/ /

ENTRYPOINT ["/init"]

HEALTHCHECK --start-period=10s --timeout=10s CMD /healthcheck.sh
