#!/usr/bin/env bash


# Abort on any error
set -eu

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Current version of docker image
CURRENT_VERSION=$(git describe --tags --abbrev=0)
register_current_version "$CURRENT_VERSION"

# Alpine Linux
IMAGE_PKG="alpine"
IMAGE_NAME="Alpine"
IMAGE_REGEX="(\d+\.)+\d+"
IMAGE_TAGS=$(curl -L -s "https://registry.hub.docker.com/v2/repositories/library/$IMAGE_PKG/tags" | jq '."results"[]["name"]' | grep -P -o "$IMAGE_REGEX")
IMAGE_VERSION=$(echo "$IMAGE_TAGS" | sort --version-sort | tail -n 1)
CURRENT_IMAGE_VERSION=$(cat "Dockerfile" | grep -P -o "FROM $IMAGE_PKG:\K$IMAGE_REGEX")
if [ "$CURRENT_IMAGE_VERSION" != "$IMAGE_VERSION" ]; then
	echo "$IMAGE_NAME $IMAGE_VERSION available!"
	update_release
fi

# TV-Headend
TVH_PKG="tvheadend"
TVH_NAME="TV-Headend"
TVH_REGEX="(\d+\.)+\d+-r\d+"
TVH_VERSION=$(curl -L -s "https://pkgs.alpinelinux.org/package/v${IMAGE_VERSION%.*}/community/x86_64/$TVH_PKG" | grep -m 1 -P -o "$TVH_REGEX")
CURRENT_TVH_VERSION=$(cat "Dockerfile" | grep -P -o "$TVH_PKG=\K$TVH_REGEX")
if [ "$CURRENT_TVH_VERSION" != "$TVH_VERSION" ]; then
	echo "$TVH_NAME $TVH_VERSION available!"

	# Dont update version if only release counter changed
	if [ "${CURRENT_TVH_VERSION%-*}" != "${TVH_VERSION%-*}" ]; then
		update_version "${TVH_VERSION%-*}"
	else
		update_release
	fi
fi

if ! updates_available; then
	echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1+}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	if [ "$CURRENT_IMAGE_VERSION" != "$IMAGE_VERSION" ]; then
		sed -i "s|FROM $IMAGE_PKG:$CURRENT_IMAGE_VERSION|FROM $IMAGE_PKG:$IMAGE_VERSION|" Dockerfile
		CHANGELOG+="$IMAGE_NAME $CURRENT_IMAGE_VERSION -> $IMAGE_VERSION, "
	fi
	if [ "$CURRENT_TVH_VERSION" != "$TVH_VERSION" ]; then
		sed -i "s|$TVH_PKG=$CURRENT_TVH_VERSION|$TVH_PKG=$TVH_VERSION|" Dockerfile
		CHANGELOG+="$TVH_NAME $CURRENT_TVH_VERSION -> $TVH_VERSION, "
	fi
	CHANGELOG="${CHANGELOG%,*}"

	if [ "${1+}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes "$CHANGELOG"
	fi
fi
