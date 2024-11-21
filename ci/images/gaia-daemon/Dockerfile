########################################################################################
# Build
########################################################################################

# Source: https://github.com/cosmos/gaia/blob/main/Dockerfile

FROM golang:1.22-alpine AS build

WORKDIR /app
COPY version /version

ENV PACKAGES="curl make git libc-dev bash file gcc linux-headers eudev-dev python3"
RUN apk add --no-cache $PACKAGES

ARG SRC_COMMIT=7c0c4cbb7b26c48b235f60532223a74f4f68b830
RUN VERSION="$(sed 's/-.*//' /version)" && \
  git init && \
  git remote add origin https://github.com/cosmos/gaia && \
  git fetch --depth 1 origin "v${VERSION}" && \
  git checkout $SRC_COMMIT

# See https://github.com/CosmWasm/wasmvm/releases
ARG WASMVM_VERSION=v2.1.3
ADD https://github.com/CosmWasm/wasmvm/releases/download/${WASMVM_VERSION}/libwasmvm_muslc.aarch64.a /lib/libwasmvm_muslc.aarch64.a
ADD https://github.com/CosmWasm/wasmvm/releases/download/${WASMVM_VERSION}/libwasmvm_muslc.x86_64.a /lib/libwasmvm_muslc.x86_64.a
RUN sha256sum /lib/libwasmvm_muslc.aarch64.a | grep faea4e15390e046d2ca8441c21a88dba56f9a0363f92c5d94015df0ac6da1f2d
RUN sha256sum /lib/libwasmvm_muslc.x86_64.a | grep 8dab08434a5fe57a6fbbcb8041794bc3c31846d31f8ff5fb353ee74e0fcd3093
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
