FROM alpine:3.11.3
RUN apk add --no-cache \
    gitea=1.10.1-r0

ARG APP_USER="gitea"
RUN adduser --disabled-password --uid 1360 "$APP_USER"
USER "$APP_USER"

ARG REPO_DIR="/var/lib/gitea/repos/"
VOLUME ["$REPO_DIR"]

EXPOSE 80       443
#      HTTP     HTTPS

ENTRYPOINT /usr/bin/gitea web -c /etc/gitea/app.ini
