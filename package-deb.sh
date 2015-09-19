#!/bin/bash
set -ex
#Install Pre-req
gem install fpm
apt-get install -y \
  autotools-dev \
  automake \
  bison \
  flex

export DIR=${PWD#}
export PACKAGE="openrov-avrdude"
export PACKAGE_VERSION=1:5.11.1-2~${BUILD_NUMBER}.ad04c42
export REPO=https://github.com/kcuzner/avrdude.git
export GITHASH=ad04c429a90f4c34f000ea4ae11db2705915a31f
export REPLACES="avrdude"

ARCH=`uname -m`
if [ ${ARCH} = "armv7l" ]
then
  ARCH="armhf"
fi

rm -rf avrdude || true
git clone $REPO
cd avrdude
git reset -- hard $GITHASH
cd ..

echo Building avrdude
cd avrdude/avrdude
PATH=/usr/:$PATH
./bootstrap
./configure --prefix=/usr/ --localstatedir=/var/ --sysconfdir=/etc/ --enable-linuxgpio
make --jobs=8
make install DESTDIR=${DIR}/avrdude_install

#package
fpm -f -m info@openrov.com -s dir -t deb -a $ARCH \
	-n ${PACKAGE} \
	-v ${PACKAGE_VERSION} \
  --replaces ${REPLACES} \
  --after-install=./install_lib/openrov-avrdude-afterinstall.sh \
	--description "OpenROV avrdude" \
	-C ${DIR}/avrdude_install .
