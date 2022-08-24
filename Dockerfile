FROM golang:1.18-alpine3.16 AS go-builder
ARG BINARY_VERSION=v1.0.0-rc2

RUN set -eux

WORKDIR /code

# Install babyd binary
RUN echo "Installing pylonsd binary"
ADD https://github.com/Pylons-tech/pylons/archive/refs/tags/${BINARY_VERSION}.tar.gz /code/
RUN tar -xf ${BINARY_VERSION}.tar.gz -C /code/ --strip-components=1
RUN go build -o bin/pylonsd -mod=readonly ./cmd/pylonsd

#-------------------------------------------
FROM golang:1.18-alpine3.16

RUN apk add --no-cache git bash py3-pip jq curl
RUN pip install toml-cli

WORKDIR /

COPY --from=go-builder /code/bin/pylonsd /usr/bin/pylonsd
COPY --from=go-builder /code/bin/pylonsd /
COPY scripts/* /
RUN chmod +x /*.sh

RUN pylonsd init test --chain-id pylons-testnet-3
COPY networks/pylons-testnet-3/genesis.json /root/.pylons/config/genesis.json

# rest server
EXPOSE 1317
# tendermint rpc
EXPOSE 26657
# p2p address
EXPOSE 26656
# gRPC address
EXPOSE 9090

RUN mkdir -p /tmp/trace
RUN mkfifo /tmp/trace/trace.fifo
CMD ["/start.sh"]

