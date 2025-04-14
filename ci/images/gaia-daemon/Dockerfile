########################################################################################
# Build
########################################################################################

# Source: https://github.com/cosmos/gaia/blob/main/Dockerfile

FROM golang:1.23-alpine AS build

WORKDIR /app
COPY version /version

ENV PACKAGES="curl build-base git bash file linux-headers eudev-dev"
RUN apk add --no-cache $PACKAGES

ARG SRC_COMMIT=239907ae25cd17902d39fcb86a4f41bd028247e2
RUN VERSION="$(sed 's/-.*//' /version)" && \
  git init && \
  git remote add origin https://github.com/cosmos/gaia && \
  git fetch --depth 1 origin "v${VERSION}" && \
  git checkout $SRC_COMMIT

# See https://github.com/CosmWasm/wasmvm/releases
ARG WASMVM_VERSION=v2.2.3
ADD https://github.com/CosmWasm/wasmvm/releases/download/${WASMVM_VERSION}/libwasmvm_muslc.aarch64.a /lib/libwasmvm_muslc.aarch64.a
ADD https://github.com/CosmWasm/wasmvm/releases/download/${WASMVM_VERSION}/libwasmvm_muslc.x86_64.a /lib/libwasmvm_muslc.x86_64.a
RUN sha256sum /lib/libwasmvm_muslc.aarch64.a | grep 6641730781bb1adc4bdf04a1e0f822b9ad4fb8ed57dcbbf575527e63b791ae41
RUN sha256sum /lib/libwasmvm_muslc.x86_64.a | grep 32503fe35a7be202c5f7c3051497d6e4b3cd83079a61f5a0bf72a2a455b6d820
RUN cp "/lib/libwasmvm_muslc.$(uname -m).a" /lib/libwasmvm_muslc.a

# build
RUN go mod download
RUN LEDGER_ENABLED=false LINK_STATICALLY=true BUILD_TAGS=muslc make build
RUN echo "Ensuring binary is statically linked ..."  \
  && file /app/build/gaiad | grep "statically linked"

########################################################################################
# Deploy
########################################################################################

FROM alpine:3.21
RUN apk add --no-cache curl jq
COPY --from=build /app/build/gaiad /gaiad
COPY entrypoint.sh /entrypoint.sh
COPY app.toml /etc/gaia/app.toml
CMD ["/entrypoint.sh"]
