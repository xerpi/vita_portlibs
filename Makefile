FREETYPE             := freetype
FREETYPE_VERSION     := $(FREETYPE)-2.6.5
FREETYPE_SRC         := $(FREETYPE_VERSION).tar.bz2
FREETYPE_DOWNLOAD    := "http://sourceforge.net/projects/freetype/files/freetype2/2.6.5/freetype-2.6.5.tar.bz2"

LIBEXIF              := libexif
LIBEXIF_VERSION      := $(LIBEXIF)-0.6.21
LIBEXIF_SRC          := $(LIBEXIF_VERSION).tar.bz2
LIBEXIF_DOWNLOAD     := "http://sourceforge.net/projects/libexif/files/libexif/0.6.21/libexif-0.6.21.tar.bz2"

LIBJPEGTURBO         := libjpeg-turbo
LIBJPEGTURBO_VERSION := $(LIBJPEGTURBO)-1.5.0
LIBJPEGTURBO_SRC     := $(LIBJPEGTURBO_VERSION).tar.gz
LIBJPEGTURBO_DOWNLOAD := "http://sourceforge.net/projects/libjpeg-turbo/files/1.5.0/libjpeg-turbo-1.5.0.tar.gz"

LIBPNG               := libpng
LIBPNG_VERSION       := $(LIBPNG)-1.6.25
LIBPNG_SRC           := $(LIBPNG_VERSION).tar.xz
LIBPNG_DOWNLOAD      := "http://sourceforge.net/projects/libpng/files/libpng16/1.6.25/libpng-1.6.25.tar.xz"

SQLITE               := sqlite
SQLITE_VERSION       := $(SQLITE)-autoconf-3100000
SQLITE_SRC           := $(SQLITE_VERSION).tar.gz
SQLITE_DOWNLOAD      := "http://sqlite.org/2016/sqlite-autoconf-3100000.tar.gz"

ZLIB                 := zlib
ZLIB_VERSION         := $(ZLIB)-1.2.8
ZLIB_SRC             := $(ZLIB_VERSION).tar.xz
ZLIB_DOWNLOAD        := "http://sourceforge.net/projects/libpng/files/zlib/1.2.8/zlib-1.2.8.tar.xz"

LIBOGG               := libogg
LIBOGG_VERSION       := $(LIBOGG)-1.3.2
LIBOGG_SRC           := $(LIBOGG_VERSION).tar.xz
LIBOGG_DOWNLOAD      := "http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.xz"

LIBVORBIS            := libvorbis
LIBVORBIS_VERSION    := $(LIBVORBIS)-1.3.5
LIBVORBIS_SRC        := $(LIBVORBIS_VERSION).tar.xz
LIBVORBIS_DOWNLOAD   := "http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.5.tar.xz"

FLAC                 := flac
FLAC_VERSION         := $(FLAC)-1.3.2
FLAC_SRC             := $(FLAC_VERSION).tar.xz
FLAC_DOWNLOAD        := "http://downloads.xiph.org/releases/flac/flac-1.3.2.tar.xz"

export PORTLIBS        ?= $(VITASDK)/arm-vita-eabi
export PKG_CONFIG_PATH := $(PORTLIBS)/lib/pkgconfig
export CFLAGS          := -std=c99 -ftree-vectorize -O3 -ffat-lto-objects -flto \
                          -mword-relocations -fomit-frame-pointer -ffast-math
export CPPFLAGS        := -I$(PORTLIBS)/include
export LDFLAGS         := -L$(PORTLIBS)/lib

export AR              := arm-vita-eabi-gcc-ar
export RANLIB          := arm-vita-eabi-gcc-ranlib

# avoid building examples
LIBPNG_MAKE_QUIRKS := PROGRAMS= check_PROGRAMS=
LIBJPEGTURBO_MAKE_QUIRKS := PROGRAMS=

.PHONY: all old_all install install-zlib clean \
        $(FREETYPE) \
        $(LIBEXIF) \
        $(LIBJPEGTURBO) \
        $(LIBPNG) \
        $(SQLITE) \
        $(ZLIB) \
        $(LIBOGG) \
        $(LIBVORBIS) \
        $(FLAC)
all: zlib install-zlib freetype libexif libjpeg-turbo libpng sqlite libogg libvorbis flac install
	@echo "Finished!"

old_all:
	@echo "Please choose one of the following targets:"
	@echo "  $(FREETYPE) (requires zlib to be installed)"
	@echo "  $(LIBEXIF)"
	@echo "  $(LIBJPEGTURBO)"
	@echo "  $(LIBPNG) (requires zlib to be installed)"
	@echo "  $(SQLITE)"
	@echo "  $(ZLIB)"
	@echo "  $(LIBOGG)"
	@echo "  $(LIBVORBIS) (requires libogg to be installed)"
	@echo "  $(FLAC) (requires libogg to be installed)"

$(FREETYPE): $(FREETYPE_SRC)
	@[ -d $(FREETYPE_VERSION) ] || tar -xf $<
	@cd $(FREETYPE_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-vita-eabi --disable-shared --enable-static --without-harfbuzz --without-bzip2
	@$(MAKE) -C $(FREETYPE_VERSION)

$(LIBEXIF): $(LIBEXIF_SRC)
	@[ -d $(LIBEXIF_VERSION) ] || tar -xf $<
	@cd $(LIBEXIF_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-vita-eabi --disable-shared --enable-static
	@$(MAKE) -C $(LIBEXIF_VERSION)

$(LIBJPEGTURBO): $(LIBJPEGTURBO_SRC)
	@[ -d $(LIBJPEGTURBO_VERSION) ] || tar -xf $<
	@cd $(LIBJPEGTURBO_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-vita-eabi --disable-shared --enable-static --without-simd
	@$(MAKE) CFLAGS='$(CFLAGS) -DNO_GETENV' -C $(LIBJPEGTURBO_VERSION) $(LIBJPEGTURBO_MAKE_QUIRKS)

$(LIBPNG): $(LIBPNG_SRC)
	@[ -d $(LIBPNG_VERSION) ] || tar -xf $<
	@cd $(LIBPNG_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-vita-eabi --enable-arm-neon --disable-shared --enable-static
	@$(MAKE) CPPFLAGS='$(CPPFLAGS) -DPNG_NO_CONSOLE_IO' -C $(LIBPNG_VERSION) $(LIBPNG_MAKE_QUIRKS)

# sqlite won't work with -ffast-math
$(SQLITE): $(SQLITE_SRC)
	@[ -d $(SQLITE_VERSION) ] || tar -xf $<
	@cd $(SQLITE_VERSION) && \
	 CFLAGS="$(filter-out -ffast-math,$(CFLAGS)) -DSQLITE_OS_OTHER=1" ./configure --disable-shared --disable-threadsafe --disable-dynamic-extensions --host=arm-vita-eabi --prefix=$(PORTLIBS)
	# avoid building sqlite3 shell
	@$(MAKE) -C $(SQLITE_VERSION) libsqlite3.la

$(ZLIB): $(ZLIB_SRC)
	@[ -d $(ZLIB_VERSION) ] || tar -xf $<
	@cd $(ZLIB_VERSION) && \
	 CHOST=arm-vita-eabi ./configure --static --prefix=$(PORTLIBS)
	 # avoid building zlib examples
	@$(MAKE) -C $(ZLIB_VERSION) libz.a

$(LIBOGG): $(LIBOGG_SRC)
	@[ -d $(LIBOGG_VERSION) ] || tar -xf $<
	@cd $(LIBOGG_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-vita-eabi --disable-shared --enable-static
	@$(MAKE) -C $(LIBOGG_VERSION)

$(LIBVORBIS): $(LIBVORBIS_SRC)
	@[ -d $(LIBVORBIS_VERSION) ] || tar -xf $<
	@cd $(LIBVORBIS_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-vita-eabi --disable-shared --enable-static
	@$(MAKE) -C $(LIBVORBIS_VERSION)/lib
	@$(MAKE) -C $(LIBVORBIS_VERSION)/include

$(FLAC): $(FLAC_SRC)
	@[ -d $(FLAC_VERSION) ] || tar -xf $<
	@cd $(FLAC_VERSION) && \
	 ./configure --prefix=$(PORTLIBS) --host=arm-vita-eabi --disable-shared --enable-static
	 # fix <memory.h> header include
	 sed -ie 's/#include <memory.h>/\/\/#include <memory.h>/g' $(FLAC_VERSION)/src/libFLAC/cpu.c
	 # avoid building flac examples
	@$(MAKE) -C $(FLAC_VERSION)/src/libFLAC
	@$(MAKE) -C $(FLAC_VERSION)/include

# Downloads
$(ZLIB_SRC):
	curl -o $@ -L $(ZLIB_DOWNLOAD)

$(FREETYPE_SRC):
	curl -o $@ -L $(FREETYPE_DOWNLOAD)

$(LIBEXIF_SRC):
	curl -o $@ -L $(LIBEXIF_DOWNLOAD)

$(LIBJPEGTURBO_SRC):
	curl -o $@ -L $(LIBJPEGTURBO_DOWNLOAD)

$(LIBPNG_SRC): install-zlib
	curl -o $@ -L $(LIBPNG_DOWNLOAD)

$(SQLITE_SRC):
	curl -o $@ -L $(SQLITE_DOWNLOAD)

$(LIBOGG_SRC):
	curl -o $@ -L $(LIBOGG_DOWNLOAD)

$(LIBVORBIS_SRC):
	curl -o $@ -L $(LIBVORBIS_DOWNLOAD)

$(FLAC_SRC):
	curl -o $@ -L $(FLAC_DOWNLOAD)

install-zlib:
	@$(MAKE) -C $(ZLIB_VERSION) install

install: install-zlib
	@[ ! -d $(FREETYPE_VERSION) ] || $(MAKE) -C $(FREETYPE_VERSION) install
	@[ ! -d $(LIBEXIF_VERSION) ] || $(MAKE) -C $(LIBEXIF_VERSION) install
	@[ ! -d $(LIBJPEGTURBO_VERSION) ] || $(MAKE) -C $(LIBJPEGTURBO_VERSION) $(LIBJPEGTURBO_MAKE_QUIRKS) install-libLTLIBRARIES install-data-am
	@[ ! -d $(LIBPNG_VERSION) ] || $(MAKE) -C $(LIBPNG_VERSION) $(LIBPNG_MAKE_QUIRKS) install-libLTLIBRARIES install-data-am install-exec-hook
	@[ ! -d $(SQLITE_VERSION) ] || $(MAKE) -C $(SQLITE_VERSION) install-libLTLIBRARIES install-data
	@[ ! -d $(LIBOGG_VERSION) ] || $(MAKE) -C $(LIBOGG_VERSION) install
	@[ ! -d $(LIBVORBIS_VERSION) ] || $(MAKE) -C $(LIBVORBIS_VERSION)/lib install && $(MAKE) -C $(LIBVORBIS_VERSION)/include install
	@[ ! -d $(FLAC_VERSION) ] || $(MAKE) -C $(FLAC_VERSION)/src/libFLAC install && $(MAKE) -C $(FLAC_VERSION)/include install

clean:
	@$(RM) -r $(FREETYPE_VERSION)
	@$(RM) -r $(LIBEXIF_VERSION)
	@$(RM) -r $(LIBJPEGTURBO_VERSION)
	@$(RM) -r $(LIBPNG_VERSION)
	@$(RM) -r $(SQLITE_VERSION)
	@$(RM) -r $(ZLIB_VERSION)
	@$(RM) -r $(LIBOGG_VERSION)
	@$(RM) -r $(LIBVORBIS_VERSION)
	@$(RM) -r $(FLAC_VERSION)
