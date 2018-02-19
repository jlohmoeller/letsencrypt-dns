FROM alpine:latest

RUN apk update && apk upgrade && apk add bash certbot bind-tools && rm -rf /var/cache/apk/*

COPY scripts/ /
RUN crontab -l | { cat; echo "20    03       *       *       *       /renew.sh"; } | crontab -
RUN ln -s /certonly.sh /usr/bin/cert && ln -s /renew.sh /usr/bin/renew
VOLUME /etc/letsencrypt /certs
ENV TERM=xterm

ENTRYPOINT ["/entrypoint.sh"]
CMD ["crond", "-f", "-d", "8"]
