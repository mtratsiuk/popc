FROM fedora:42

RUN dnf install -y \
  curl \
  tar \
  file \
  which \
  ripgrep \
  gcc \
  gcc-c++ \
  mesa-libGL-devel libXi-devel libXcursor-devel libXrandr-devel libXinerama-devel wayland-devel libxkbcommon-devel \
  tinyproxy \
  iptables-nft \
  git \
  bash \
  && dnf clean all \
  && ln -sf /usr/sbin/iptables-nft /usr/sbin/iptables \
  && ln -sf /usr/sbin/ip6tables-nft /usr/sbin/ip6tables

RUN curl -L https://github.com/anomalyco/opencode/releases/download/v1.14.25/opencode-linux-x64.tar.gz | \
  tar -xz -C /usr/local/bin opencode

ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID opencode \
  && useradd -g opencode -u $UID opencode

ENV PATH="/usr/local/go/bin:/usr/local/bin:/lib/go/bin:/lib/opencode/bin:${PATH}"
ENV CGO_ENABLED=1

COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY tinyproxy-filter /etc/tinyproxy/filter
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
