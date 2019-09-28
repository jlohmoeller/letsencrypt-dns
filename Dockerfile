FROM alpine:latest

RUN apk add --no-cache bash certbot bind-tools

COPY scripts/ /scripts/
RUN crontab -l | { cat; echo "20    03       *       *       *       /renew.sh"; } | crontab -
RUN ln -s /scripts/certonly.sh /usr/bin/cert && ln -s /scripts/renew.sh /usr/bin/renew
VOLUME /etc/letsencrypt /certs

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["crond", "-f", "-d", "8"]
