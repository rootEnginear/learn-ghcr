ARG NODE_VERSION=22
FROM node:22-alpine AS base

# PNPM
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
RUN corepack use pnpm@9.14.2

COPY . /app
WORKDIR /app

# Production Dependencies
FROM base AS prod-deps
RUN pnpm install --prod --frozen-lockfile

# Build server
FROM base AS build
RUN pnpm install
RUN pnpm build

# Run the server
FROM base
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/dist /app/dist

USER node

EXPOSE 3000
CMD pnpm start
