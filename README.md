Vita Portlibs
============

Here is a Makefile for building various portlibs for the PSVita.

Type:

    $ make
or:

    $ make all

to download and install all the libraries at once.

You can build and install the libraries separately:

    $ make zlib
    $ make install-zlib
    $ make <targets>
    $ make install

This will install the portlibs to `$VITASDK`. If this is a
privileged location, you will need to `sudo make install-zlib` and `sudo make
install` in order for the portlibs to be installed.

Currently supports the following portlibs:

* freetype (requires zlib)
* libexif
* libjpeg-turbo
* libpng (requires zlib)
* sqlite
* zlib

Download links:

* [freetype-2.6.1.tar.bz2] (http://sourceforge.net/projects/freetype/files/freetype2/2.6.1/freetype-2.6.1.tar.bz2)
* [libexif-0.6.21.tar.bz2] (http://sourceforge.net/projects/libexif/files/libexif/0.6.21/libexif-0.6.21.tar.bz2)
* [libjpeg-turbo-1.4.2.tar.gz] (http://sourceforge.net/projects/libjpeg-turbo/files/1.4.2/libjpeg-turbo-1.4.2.tar.gz)
* [libpng-1.6.18.tar.xz] (http://sourceforge.net/projects/libpng/files/libpng16/1.6.18/libpng-1.6.18.tar.xz)
* [sqlite-autoconf-3090100.tar.gz] (http://sqlite.org/2015/sqlite-autoconf-3090100.tar.gz)
* [zlib-1.2.8.tar.xz] (http://sourceforge.net/projects/libpng/files/zlib/1.2.8/zlib-1.2.8.tar.xz)
