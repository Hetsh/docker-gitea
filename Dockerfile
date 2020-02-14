FROM alpine:3.11.3
RUN apk add --no-cache \
    gitea=1.10.1-r0

ARG APP_USER="gitea"
RUN sed -i "s|$APP_USER:x:100:101|$APP_USER:x:1360:1360|" "/etc/passwd" && \
    chown -R "$APP_USER" /var/lib/gitea /etc/gitea /var/log/gitea
USER "$APP_USER"

ARG REPO_DIR="/var/lib/gitea/repos"
VOLUME ["$REPO_DIR"]

EXPOSE 3000
#      HTTP

ENTRYPOINT /usr/bin/gitea web -c /etc/gitea/app.ini
