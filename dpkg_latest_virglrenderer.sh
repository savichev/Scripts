#!/bin/sh
# dpkg-depcheck -d ./configure

cd /usr/src
#git clone https://gitlab.freedesktop.org/virgl/virglrenderer
cd virglrenderer
git pull
#autoreconf -vfi

./configure \
    --prefix=/usr

####
pkgname=virglrenderer-dev
pkgversion=0.8.0
pkgarch=amd64
pkgrelease=0
pakdir=../deb

####
WORKNAME=${pkgname}_${pkgversion}-${pkgrelease}_${pkgarch}

WORKDIR=$PWD
TMP=tmp
TMPDIR=$PWD/$TMP

if [ -d "$TMPDIR" ]; then
    rm -rf $TMPDIR
fi

################
# Build deb
################

mkdir -p $TMPDIR/$WORKNAME
make DESTDIR=$TMPDIR/$WORKNAME install
mkdir $TMPDIR/$WORKNAME/DEBIAN
cat << EOF > $TMPDIR/$WORKNAME/DEBIAN/control
Package: ${pkgname}
Version: ${pkgversion}
Section: unknown
Priority: optional
Architecture: ${pkgarch}
Depends: gawk, libmagic1:amd64, mime-support, libudev-dev:amd64, x11proto-core-dev, libdrm-dev, \
libepoxy-dev:amd64, mesa-dev, libsigsegv2:amd64, libx11-dev:amd64, libperl5.22:amd64, \
libgbm-dev:amd64, libreadline6:amd64, perl-modules-5.22, file, cpio, libfakeroot:amd64, \
libglib2.0-0:amd64, pkg-config
Essential: no
Maintainer: Alexandr Savichev <savicheval@gmail.com>
Homepage: https://virgil3d.github.io/
Description: The virgil3d rendering library is a library used by qemu to implement 3D GPU support for the virtio GPU.

EOF

cd $TMP

echo "Все готово для создания пакета"
echo "Создаю пакет"
dpkg-deb --build $WORKNAME

mv $WORKNAME.deb $WORKDIR/$pakdir

cd $WORKDIR

echo "Очищаю за собой мусор"

rm -rf $TMPDIR
