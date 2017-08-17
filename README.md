## Packer Templates for Vagrant

A variety of minimal Packer templates for Vagrant boxes for VMWare Fusion/Desktop, written in JSON5.

Use [cfgt](github.com/sean-/cfgt) to convert JSON5 into JSON for Packer.

### SmartOS - Global Zone

A global zone SmartOS base box with no further customization. Vagrant will modify the SSH keys used
for `root` in the global zone, and `vagrant ssh` will connect your to the global zone.
	
Most modifications to the root file system are _not persistent_, in keeping with the SmartOS
immutable deployment style, however customizations will survive a suspend/up cycle in Vagrant. The
directory in which the `Vagrantfile` exists is mounted using NFS at `/vagrant`, unless overriden in
the local `Vagrantfile`.

A custom SMF service with FMRI `svc://vagrant/mount-nfs` is defined  in `/opt/custom` to ensure that
the NFS share is mounted on reboot.

#### Building

```shell
$ cd smartos-global-zone
$ export ISO_URL=$(pwd)/../../iso/smartos-latest.iso
$ export ISO_MD5=$(md5 -q $(pwd)/../../iso/smartos-latest.iso)
$ cfgt --in template.json5 | packer build -
```

### FreeBSD

A FreeBSD 11.1-RELEASE base box with a ZFS root filesystem. No 32 bit compatibility libraries or
ports tree are installed.

Loosely based on [brd's templates](https://github.com/brd/packer-freebsd).

#### Building

```shell
$ cd freebsd/11.1-RELEASE
$ export ISO_URL=$(pwd)/../../iso/FreeBSD-11.1-RELEASE-amd64-disc1.iso
$ export ISO_MD5=$(md5 -q $(pwd)/../../iso/FreeBSD-11.1-RELEASE-amd64-disc1.iso)
$ cfgt --in template.json5 | packer build -
```
