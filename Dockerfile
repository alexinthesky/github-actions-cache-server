FROM node:22-alpine AS builder

WORKDIR /app

RUN npm install -g pnpm@latest-10

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN --mount=type=cache,target=/root/.local/share/pnpm/store pnpm fetch --prod

COPY . .
RUN pnpm install --frozen-lockfile --prod --offline

ARG BUILD_HASH
ENV BUILD_HASH=${BUILD_HASH}
RUN pnpm run build

# --------------------------------------------

FROM node:22-alpine AS runner

ENV NITRO_CLUSTER_WORKERS=1

WORKDIR /app

COPY --from=builder /app/.output ./

CMD ["node", "/app/server/index.mjs"]