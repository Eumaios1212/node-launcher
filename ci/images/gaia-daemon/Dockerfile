########################################################################################
# Build
########################################################################################

FROM golang:1.21-bullseye AS build

WORKDIR /app
COPY version /version

ARG SRC_COMMIT=24f6d24f029328ee40b3d821cfd12dbcf40bbbe5
RUN git init && \
  git remote add origin https://github.com/cosmos/gaia && \
  git fetch --depth 1 origin "v$(cat /version)" && \
  git checkout $SRC_COMMIT && \
  make build


########################################################################################
# Deploy
########################################################################################

FROM debian:bullseye-slim
RUN apt-get update && apt-get install --no-install-recommends -y curl jq && \
  rm -rf /var/lib/apt/lists/*
COPY --from=build /app/build/gaiad /gaiad
COPY entrypoint.sh /entrypoint.sh
COPY app.toml /etc/gaia/app.toml
CMD ["/entrypoint.sh"]
