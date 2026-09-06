FROM node:22-alpine AS builder

WORKDIR /app
# npm 10 (встроенный в node:22-alpine) падает с "Cannot read properties of null
# (reading 'edgesOut')" на резолве Nuxt. Апгрейдим до npm 11.
RUN npm install -g npm@11
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:22-alpine
WORKDIR /app
COPY --from=builder /app/.output .output
EXPOSE 3000
ENV NITRO_HOST=0.0.0.0
ENV NITRO_PORT=3000
CMD ["node", ".output/server/index.mjs"]
