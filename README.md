# roojspacker
Javascript packer / compressor (and possibly more) Was part of the jsdoc tools

Installation Procedure (Debian/Ubuntu)

git clone https://github.com/roojs/roojspacker.git

apt-get install valac cmake gcc libgee-0.8-dev   libtool libjson-glib-dev


## -- this is designed to run make from the 'build' directory.... - it's hard coded in configure (called from autogen)

cd roojspacker
./autogen.sh --prefix=/usr
cd build
sudo make install


Debian package build:
dpkg-buildpackage -kalan@roojs.com


