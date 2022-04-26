# roojspacker
Javascript packer / compressor (and possibly more) Was part of the jsdoc tools

---
Installation Procedure (Debian/Ubuntu)

Get the latest debian/ubuntu package from here.
https://www.dropbox.com/scl/fo/9gmglurw6s4qqwzc3xkvu/h?dl=0&rlkey=9x0o549ne7gyvii3yc93u3brc

---

Building it.
    
    git clone https://github.com/roojs/roojspacker.git

    apt-get install valac cmake gcc libgee-0.8-dev   libtool libjson-glib-dev


## -- this is designed to run make from the 'build' directory.... - it's hard coded in configure (called from autogen)

    cd roojspacker
    ./autogen.sh --prefix=/usr
    cd build
    sudo make install
 

---

Notes on building a Debian package

Update Package details.
    
    dch -v {release version}

Build it..

    debuild -us -uc

    


