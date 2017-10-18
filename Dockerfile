FROM alpine:3.5
MAINTAINER johannes@lmlr.de

RUN apk update && apk upgrade && apk add bash certbot && rm -rf /var/cache/apk/*

COPY renew.sh /renew.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /renew.sh
RUN crontab -l | { cat; echo "20    03       *       *       *       /renew.sh"; } | crontab -
VOLUME /etc/letsencrypt /certs
ENV TERM=xterm

ENTRYPOINT ["/entrypoint.sh"]
CMD ["crond", "-f", "-d", "8"]
