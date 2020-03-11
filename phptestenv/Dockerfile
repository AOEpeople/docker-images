FROM ubuntu:18.04

RUN apt-get update \
  && apt-get install -y sudo curl git jq python3.8 docker.io make wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists \
  && wget -O/usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" \
  && chmod +x /usr/local/bin/docker-compose

