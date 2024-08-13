FROM node:18-alpine
WORKDIR /src/app
# ADD ./* ./
COPY package*.json ./
COPY app/src app/src

COPY app/src app/src

ENV NODE_ENV=dev
RUN npm ci

# relative to cwd
ENV SWAGGER_JSON_DIR=./src/server/openapi.json
ENV DATABASE_URL=$DATABASE_URL

WORKDIR /src/app
RUN npx prisma generate --schema='./src/database/schema.prisma'


EXPOSE 3000

ENTRYPOINT npm run start
