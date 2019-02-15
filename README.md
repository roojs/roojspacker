# roojspacker
Javascript packer / compressor (and possibly more) Was part of the jsdoc tools

Installation Procedure (Debian/Ubuntu)

git clone https://github.com/roojs/roojspacker.git

apt-get install valac cmake gcc libgee-0.8-dev make libtool libjson-glib-dev

cd roojspacker
./autogen.sh --prefix=/usr
sudo make install