# BASE_IMAGE is required. The scratch image will fail.
ARG BASE_IMAGE="scratch"

FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y unminimize
RUN yes | unminimize

RUN apt-get install -y \
  apt-utils \
  bash-completion \
  curl \
  dialog \
  gpg \
  iproute2 \
  iputils-ping \
  jq \
  less \
  man-db \
  micro \
  nano \
  net-tools \
  net-tools \
  vim

COPY etc /etc

RUN chmod 600 /etc/ssh/ssh_host_*
RUN chmod 644 /etc/ssh/ssh_host_*.pub
RUN mkdir -p /run/sshd && chmod 0755 /run/sshd
RUN apt-get install -y openssh-server

RUN <<EOT bash
  #!/bin/bash
  echo -e 'p\np\n' | passwd
  for u in user{1..5} user{6..10}_admin; do
    useradd -m -s /bin/bash \$u
    echo -e 'p\np\n' | passwd
    [[ "\$u" == *"_admin" ]] && usermod -aG sudo \$u
  done
EOT


COPY entrypoint.sh /entrypoint.sh

EXPOSE 22

ENTRYPOINT [ "/entrypoint.sh" ]
