# Stage 1/3 - Insatll
FROM alpine:3.4
USER root
RUN apk update
# TODO: Remove this once these get fixed:
# - https://github.com/vercel/turborepo/issues/1097
# - https://github.com/vercel/turborepo/issues/1103
RUN apk add git 

# --------------------------------------------

# Stage 2/3 - Builder
FROM node:18-alpine AS pins-web-builder

WORKDIR /usr/src/app

COPY package.json .
COPY package-lock.json .
COPY turbo.json .


COPY app/src ./app/src

RUN npm ci --loglevel notice

ENV NODE_ENV=dev
ENV APP_RELEASE=true

RUN npm run build

# --------------------------------

# Stage 3/3 - App run
FROM node:18-alpine

WORKDIR /usr/src/app

COPY --from=pins-web-builder /usr/src/app ./

WORKDIR /usr/src/app/app/src

ENV NODE_ENV=dev
ENV APP_RELEASE=true

# TODO: Perhaps use `RUN npm ci --production` to shrink the size of the container

EXPOSE 8080

ENTRYPOINT npm run start
