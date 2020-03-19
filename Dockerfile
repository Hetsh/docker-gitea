FROM library/alpine:20200319
RUN apk add --no-cache \
    gitea=1.11.3-r0 \
    openssh=8.2_p1-r0

# App user
ARG APP_UID=1360
ARG APP_USER="gitea"
RUN addgroup --gid "$APP_UID" "$APP_USER" && \
    sed -i "s|$APP_USER:x:100:101|$APP_USER:x:$APP_UID:$APP_UID|" "/etc/passwd"

# Configuration
ARG CONF_DIR="/etc/gitea"
RUN echo -e "[repository]\nSCRIPT_TYPE = sh\n\n[server]\nSTART_SSH_SERVER = true\nSSH_PORT = 3022\nSTATIC_ROOT_PATH = /usr/share/webapps/gitea\n\n[log]\nROOT_PATH = /var/log/gitea" > "$CONF_DIR/app.ini" && \
    chown -R "$APP_USER":"$APP_USER" "$CONF_DIR"

# Volumes
ARG DATA_DIR="/gitea-data"
ARG LOG_DIR="var/log/gitea"
ARG PREV_HOME="/var/lib/gitea"
RUN sed -i "s|$PREV_HOME|$DATA_DIR|" "/etc/passwd" && \
    rm -r "$PREV_HOME" && \
    mkdir "$DATA_DIR" && \
    chown -R "$APP_USER":"$APP_USER" "$DATA_DIR" "$LOG_DIR"
VOLUME ["$DATA_DIR", "$LOG_DIR"]

#      SSH  HTTP
EXPOSE 3022 3000

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENV GITEA_WORK_DIR="$DATA_DIR"
ENTRYPOINT exec /usr/bin/gitea web -c "/etc/gitea/app.ini"
