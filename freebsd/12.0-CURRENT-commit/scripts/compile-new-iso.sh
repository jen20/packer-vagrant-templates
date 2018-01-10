#!/bin/sh

set -e

mkdir -p /compile

echo '    * Fetching FreeBSD source archive'
fetch -o /compile/source.zip "${PACKER_SOURCE_ARCHIVE_URL}"

echo '    * Unarchiving FreeBSD source'
mkdir -p /compile/freebsd-source
tar -x --strip-components 1 --directory /compile/freebsd-source -f /compile/source.zip
cd /compile/freebsd-source || exit 1

echo '    * Building world'
export MAKEOBJDIRPREFIX=/compile/freebsd-obj
make -j4 buildworld

echo "    * Building kernel (config: ${PACKER_KERNEL_CONFIG})"
make -j4 buildkernel KERNCONF="${PACKER_KERNEL_CONFIG}" -s

echo '    * Building ISO'
cd /compile/freebsd-source/release || exit 1

export KERNCONF="${PACKER_KERNEL_CONFIG}"
make -DNOSRC -DNOPORTS -DNODOC cdrom
