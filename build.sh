#!/usr/bin/env bash


# Abort on any error
set -eu

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh

# Check acces do docker daemon
assert_dependency "docker"
if ! docker version &> /dev/null; then
    echo "Docker daemon is not running or you have unsufficient permissions!"
    exit -1
fi

# Build the image
APP_NAME="gitea"
docker build --tag "$APP_NAME" .

if confirm_action "Test image?"; then
	# Set up temporary directory
	TMP_DIR=$(mktemp -d "/tmp/$APP_NAME-XXXXXXXXXX")
	add_cleanup "rm -rf $TMP_DIR"
	echo "[repository]
ROOT        = /var/lib/gitea/repos ;change this path to your repos
SCRIPT_TYPE = sh

[server]
START_SSH_SERVER = true
SSH_PORT         = 2999
STATIC_ROOT_PATH = /usr/share/webapps/gitea
APP_DATA_PATH    = /var/lib/gitea

[log]
ROOT_PATH = /var/log/gitea" > "$TMP_DIR/app.ini"

	# Apply permissions, UID matches process user
	APP_UID=1360
	chown -R "$APP_UID":"$APP_UID" "$TMP_DIR"

	# Start the test
	docker run \
	--rm \
	--interactive \
	--publish 2999:2999/tcp \
	--publish 3000:3000/tcp \
	--mount type=bind,source="$TMP_DIR/app.ini",target="/etc/gitea/app.ini" \
	--mount type=bind,source="$TMP_DIR",target="/var/lib/gitea" \
	--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
	--name "$APP_NAME" \
	"$APP_NAME"
fi