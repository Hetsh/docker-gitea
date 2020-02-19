FROM alpine:3.11.3
RUN apk add --no-cache \
    gitea=1.10.1-r0 \
    openssh=8.1_p1-r0

ARG APP_UID="1360"
ARG APP_USER="gitea"

ARG CONF_DIR="/etc/gitea"
ARG DATA_DIR="/var/lib/gitea"
ARG LOG_DIR="var/log/gitea"

RUN addgroup --gid "$APP_UID" "$APP_USER" && \
    sed -i "s|$APP_USER:x:100:101|$APP_USER:x:$APP_UID:$APP_UID|" "/etc/passwd" && \
    sed -i "s|\[server\]|\[server\]\nSTART_SSH_SERVER = true\nSSH_PORT=2999|" "$CONF_DIR/app.ini" && \
    rm -r "$DATA_DIR/"* && \
    chown -R "$APP_USER":"$APP_USER" "$CONF_DIR" "$DATA_DIR" "$LOG_DIR"
VOLUME ["$DATA_DIR", "$LOG_DIR"]

EXPOSE 2999 3000
#      SSH  HTTP

USER "$APP_USER"
ENTRYPOINT exec /usr/bin/gitea web -c "/etc/gitea/app.ini"
