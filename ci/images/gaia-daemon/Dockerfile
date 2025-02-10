########################################################################################
# Build
########################################################################################

# Source: https://github.com/cosmos/gaia/blob/main/Dockerfile

FROM golang:1.22-alpine AS build

WORKDIR /app
COPY version /version

ENV PACKAGES="curl make git libc-dev bash file gcc linux-headers eudev-dev python3"
RUN apk add --no-cache $PACKAGES

ARG SRC_COMMIT=26eb150bf6b375d0cbe767b174005747fb57c82b
RUN VERSION="$(sed 's/-.*//' /version)" && \
  git init && \
  git remote add origin https://github.com/cosmos/gaia && \
  git fetch --depth 1 origin "v${VERSION}" && \
  git checkout $SRC_COMMIT

# See https://github.com/CosmWasm/wasmvm/releases
ARG WASMVM_VERSION=v2.1.5
ADD https://github.com/CosmWasm/wasmvm/releases/download/${WASMVM_VERSION}/libwasmvm_muslc.aarch64.a /lib/libwasmvm_muslc.aarch64.a
ADD https://github.com/CosmWasm/wasmvm/releases/download/${WASMVM_VERSION}/libwasmvm_muslc.x86_64.a /lib/libwasmvm_muslc.x86_64.a
RUN sha256sum /lib/libwasmvm_muslc.aarch64.a | grep 1bad0e3f9b72603082b8e48307c7a319df64ca9e26976ffc7a3c317a08fe4b1a
RUN sha256sum /lib/libwasmvm_muslc.x86_64.a | grep c6612d17d82b0997696f1076f6d894e339241482570b9142f29b0d8f21b280bf
RUN cp "/lib/libwasmvm_muslc.$(uname -m).a" /lib/libwasmvm_muslc.a

# build
RUN go mod download
RUN LEDGER_ENABLED=false LINK_STATICALLY=true BUILD_TAGS=muslc make build
RUN echo "Ensuring binary is statically linked ..."  \
  && file /app/build/gaiad | grep "statically linked"

########################################################################################
# Deploy
########################################################################################

FROM alpine:3.20
RUN apk add --no-cache curl jq
COPY --from=build /app/build/gaiad /gaiad
COPY entrypoint.sh /entrypoint.sh
COPY app.toml /etc/gaia/app.toml
CMD ["/entrypoint.sh"]
