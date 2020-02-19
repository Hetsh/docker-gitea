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
register_current_version

# Alpine Linux
update_image "alpine" "Alpine" "x86_64" "(\d+\.)+\d+"

# Gitea
update_alpine_pkg "gitea" "Gitea" "true" "community" "(\d+\.)+\d+-r\d+"

# OpenSSH
update_alpine_pkg "openssh" "OpenSSH" "false" "main" "\d+\.\d+_p\d+-r\d+"

if ! updates_available; then
	echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1+}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1+}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi
