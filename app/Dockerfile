FROM node:18-alpine
WORKDIR /src/app
# COPY schema.prisma ./
COPY package*.json ./


ENV NODE_ENV=dev
RUN npm ci

# relative to cwd
ENV SWAGGER_JSON_DIR=./src/server/openapi.json
ENV DATABASE_URL=$DATABASE_URL

WORKDIR /src/app
# RUN npx prisma generate --schema='./schema.prisma'

EXPOSE 3000

ENTRYPOINT npm run start
