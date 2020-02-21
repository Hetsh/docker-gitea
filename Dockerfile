FROM library/alpine:20200122
RUN apk add --no-cache \
    gitea=1.11.1-r0 \
    openssh=8.2_p1-r0

ARG CONF_DIR="/etc/gitea"
ARG DATA_DIR="/var/lib/gitea"
ARG LOG_DIR="var/log/gitea"
ENV GITEA_WORK_DIR="$DATA_DIR"

ARG APP_UID="1360"
ARG APP_USER="gitea"
RUN addgroup --gid "$APP_UID" "$APP_USER" && \
    sed -i "s|$APP_USER:x:100:101|$APP_USER:x:$APP_UID:$APP_UID|" "/etc/passwd" && \
    echo -e "[repository]\nSCRIPT_TYPE = sh\n\n[server]\nSTART_SSH_SERVER = true\nSSH_PORT = 3022\nSTATIC_ROOT_PATH = /usr/share/webapps/gitea\nAPP_DATA_PATH    = /var/lib/gitea\n\n[log]\nROOT_PATH = /var/log/gitea" > "$CONF_DIR/app.ini" && \
    rm -r "$DATA_DIR/"* && \
    chown -R "$APP_USER":"$APP_USER" "$CONF_DIR" "$DATA_DIR" "$LOG_DIR"
VOLUME ["$DATA_DIR", "$LOG_DIR"]

EXPOSE 3022 3000
#      SSH  HTTP

USER "$APP_USER"
ENTRYPOINT exec /usr/bin/gitea web -c "/etc/gitea/app.ini"
