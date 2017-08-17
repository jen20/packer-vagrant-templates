#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o xtrace

function configure_authorized_keys()
{
	mkdir -p /usbkey/config.inc
	mv /tmp/authorized_keys /usbkey/config.inc/authorized_keys

	echo 'root_authorized_keys_file=authorized_keys' >> /usbkey/config
}

function configure_custom_smf()
{
	mkdir -p /opt/custom/smf/vagrant
	mv /tmp/vagrant_mount_nfs.xml /opt/custom/smf/vagrant/mount_nfs.xml

	mv /tmp/vagrant-mount-nfs.sh /opt/custom/bin/vagrant-mount-nfs.sh
	chmod +x /opt/custom/bin/vagrant-mount-nfs.sh
}

function configure_admin_nic_tag()
{
	if nictagadm exists admin ; then
		nictagadm delete admin
	fi

	echo 'admin_nic_autoselect=true' >> /usbkey/config
}

function global_zone_cleanup()
{
	rm -f /var/ssh/ssh_host*
	rm -f /var/adm/messages.*
	rm -f /var/log/syslog.*
	cp /dev/null /var/adm/messages
	cp /dev/null /var/log/syslog
	cp /dev/null /var/adm/wtmpx
	cp /dev/null /var/adm/utmpx
}

configure_authorized_keys
configure_custom_smf
configure_admin_nic_tag
global_zone_cleanup

