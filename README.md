# roojspacker
Javascript packer / compressor / and documentation tool

Used to build the roojs docs - here, and the library
https://roojs.org/roojs1/docs/

https://github.com/roojs/roojs1

---
Installation Procedure (Debian/Ubuntu)

Get the latest debian/ubuntu package from here.
https://www.dropbox.com/scl/fo/9gmglurw6s4qqwzc3xkvu/h?dl=0&rlkey=9x0o549ne7gyvii3yc93u3brc

---

Building it.
    
    git clone https://github.com/roojs/roojspacker.git

    apt-get install valac meson gcc libgee-0.8-dev   libtool libjson-glib-dev


## -- this is designed to run make from the 'build' directory.... - it's hard coded in configure (called from autogen)

    cd roojspacker
    meson setup build
    ninja -C build install
 

---

Notes on building a Debian package

Update Package details.
    
    dch -v {release version}

Build it..

    dpkg-buildpackage -rfakeroot -us -uc -b



    


