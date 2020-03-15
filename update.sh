#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Base image
update_image "library/alpine" "Alpine Linux" "false" "\d{8}"

# Packages
ARCH="x86_64"
BASE_PKG_URL="https://pkgs.alpinelinux.org/package/edge"
update_pkg "gitea" "Gitea" "true" "$BASE_PKG_URL/community/$ARCH" "(\d+\.)+\d+-r\d+"
update_pkg "openssh" "OpenSSH" "false" "$BASE_PKG_URL/main/$ARCH" "\d+\.\d+_p\d+-r\d+"

if ! updates_available; then
	echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi
