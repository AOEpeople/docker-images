FROM alpine:3.7

RUN apk add --no-cache bash curl

COPY curl2prometheus.sh /

CMD ["/bin/bash", "curl2prometheus.sh"]
