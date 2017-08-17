#!/bin/sh
	
set -e

echo '==> Configuring Machine...'

echo '    * Disabling boot screen'
cat <<'EOF' >> /boot/loader.conf
beastie_disable="YES"
EOF

echo '    * Decreasing tick frequency'
cat <<'EOF' >> /boot/loader.conf
kern.hz=50
EOF

echo '    * Bootstrapping pkg(1)'
ASSUME_ALWAYS_YES=yes pkg bootstrap

echo '    * Updating pkg(1) database'
sh -c 'cd /tmp && exec pkg-static update'

echo '    * Upgrading pkg(1) database'
sh -c 'cd /tmp && exec pkg-static upgrade -n'

echo '    * Initializing pkg(1) audit database'
sh -c 'cd /tmp && exec pkg-static audit -F'

echo '    * Installing OpenVM Tools'
pkg-static install -y open-vm-tools-nox11
sysrc vmware_guest_vmblock_enable=YES
sysrc vmware_guest_vmmemctl_enable=YES
sysrc vmware_guest_vmxnet_enable=YES
# Disable vmxnet in favor of whatever the OpenVM Tools are suggesting
#sed -i -e 's#^ifconfig_vmx0#ifconfig_em0#g' /etc/rc.conf
#sed -i -e '/^if_vmx_load=.*/d' /boot/loader.conf
sysrc vmware_guestd_enable=YES

echo '    * Setting up passwordless sudo for vagrant user'
pkg-static install -y sudo
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /usr/local/etc/sudoers.d/vagrant

echo '    * Setting up vagrant default SSH key'
mkdir -p ~vagrant/.ssh
chmod 0700 ~vagrant/.ssh
cat <<'EOF' > ~vagrant/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF
chown -R vagrant ~vagrant/.ssh
chmod 0600 ~vagrant/.ssh/authorized_keys

echo '    * Disabling SSH root login'
sed -i -e 's/^PermitRootLogin no/#PermitRootLogin yes/' /etc/ssh/sshd_config

echo '    * Enabling NFS Client'
sysrc rpcbind_enable="YES"
sysrc rpc_lockd_enable="YES"
sysrc nfs_client_enable="YES"

echo '    * Updating locate(1) database'
/etc/periodic/weekly/310.locate

echo '==> Machine configuration complete.'
