FROM node:16.14 AS dependencies
LABEL maintainer="Tecca Yu <cyu81@myseneca.com>"
LABEL description="Fragments node.js microservice"
ENV NODE_ENV=production​

WORKDIR /app
COPY ./src ./src

# Copy the package.json and package-lock.json files into the working dir (/app)
COPY package.json package-lock.json .env ./
# Install node dependencies defined in package-lock.json
RUN npm ci 


FROM node:16.14-alpine@sha256:2c6c59cf4d34d4f937ddfcf33bab9d8bbad8658d1b9de7b97622566a52167f2b AS builder
WORKDIR /app
COPY --from=dependencies /app /app
# Copy source code into the image
COPY . .
RUN npm run build

FROM nginx:stable-alpine@sha256:74694f2de64c44787a81f0554aa45b281e468c0c58b8665fafceda624d31e556 AS deploy
COPY --from=builder /app/dist/ /usr/share/nginx/html/
ENV PORT=80

EXPOSE 80

HEALTHCHECK --interval=15s --start-period=5s --retries=3 --timeout=30s\
  CMD curl –-fail http://localhost:${PORT}/ || exit 1​

