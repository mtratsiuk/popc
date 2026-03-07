FROM ghcr.io/anomalyco/opencode:latest

RUN apk add --no-cache \
  tinyproxy \
  bubblewrap \
  iptables \
  git \
  bash

COPY --from=golang:1.26-alpine /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:/lib/go/bin:${PATH}"

RUN go env -w GOPATH=/lib/go \
  && go install golang.org/x/tools/gopls@v0.21.1

ARG UID=1000
ARG GID=1000

RUN addgroup -g $GID opencode \
  && adduser -G opencode -u $UID opencode -D

COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY tinyproxy-filter /etc/tinyproxy/filter
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
