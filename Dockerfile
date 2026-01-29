FROM amd64/alpine:20260127
ARG LAST_UPGRADE="2026-01-29T13:15:07+01:00"
RUN apk upgrade && \
	apk add --no-cache \
		gitea=1.25.3-r1 \
		openssh=10.2_p1-r0

# App user
ARG APP_UID=1360
ARG APP_GID="$APP_UID"
ARG APP_USER="gitea"
ARG APP_GROUP="$APP_USER"
ARG DATA_DIR="/gitea"
RUN deluser \
		--remove-home \
		"$APP_USER" && \
	adduser \
		--disabled-password \
		--uid "$APP_UID" \
		--home "$DATA_DIR" \
		--gecos "$APP_USER" \
		--shell /bin/ash \
		"$APP_USER"

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENV GITEA_CUSTOM="$DATA_DIR" \
	GITEA_WORK_DIR="$DATA_DIR"
ENTRYPOINT ["gitea", "--config", "config/app.ini", "web"]
