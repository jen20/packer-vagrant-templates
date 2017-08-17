#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o xtrace

function mount_nfs()
{
	local host_ip
	local host_path
	local guest_path

	while read -r share; do
		host_ip=$(echo "${share}" | awk -F'[:]' '{ print $1 }')
		host_path=$(echo "${share}" | awk -F'[:]' '{ print $2 }')
		guest_path=$(echo "${share}" | awk -F'[:]' '{ print $3 }')

		if ! /usr/sbin/mount | grep "${guest_path}" ; then
			mkdir -p "${guest_path}"
			/usr/sbin/mount -F nfs "${host_ip}:${host_path}" "${guest_path}"
		fi
	done < /usbkey/config.inc/nfs_mounts
}

if [[ -f /usbkey/config.inc/nfs_mounts ]] ; then
	mount_nfs
fi
