#!/bin/bash
# shellcheck disable=SC2034

# This file will be sourced by scripts/build.sh to customize the build process


IMG_NAME="hetsh/gitea"
function test_image {
	docker run \
		--rm \
		--publish 3022:3022/tcp \
		--publish 3000:3000/tcp \
		--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
		"$IMG_ID"
}
