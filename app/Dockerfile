FROM node:18-alpine
WORKDIR /src/app
COPY package*.json ./
COPY app/src app/src


ENV NODE_ENV=dev
RUN npm ci

EXPOSE 3000

ENTRYPOINT npm run start
