#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1091,SC2154

set -vx

######################################################################################################################
### Setup Build System and GitHub

##apt install -y autopoint

wget -qO- uny.nu/pkg | bash -s buildsys

### Installing build dependencies
unyp install libjpeg-turbo libtiff libpng libxml2 xorg

#pip3_bin=(/uny/pkg/python/*/bin/pip3)
#"${pip3_bin[0]}" install --upgrade pip
#"${pip3_bin[0]}" install docutils pygments

### Getting Variables from files
UNY_AUTO_PAT="$(cat UNY_AUTO_PAT)"
export UNY_AUTO_PAT
GH_TOKEN="$(cat GH_TOKEN)"
export GH_TOKEN

source /uny/git/unypkg/fn
uny_auto_github_conf

######################################################################################################################
### Timestamp & Download

uny_build_date

mkdir -pv /uny/sources
cd /uny/sources || exit

pkgname="netpbm"
#pkggit="https://github.com/netpbm/netpbm.git refs/tags/*"
#gitdepth="--depth=1"

### Get version info from git remote
# shellcheck disable=SC2086
#latest_head="$(git ls-remote --refs --tags --sort="v:refname" $pkggit | grep -E "v[0-9.]+$" | tail --lines=1)"
pkg_release_tarball="$(wget -qS --spider --max-redirect=0 https://sourceforge.net/projects/netpbm/files/latest/download -O- 2>&1 | grep "location:" | grep -o "netpbm-.*\.tgz")"
latest_ver="$(echo "$pkg_release_tarball" | grep -o "netpbm-[0-9.]*" | sed -e "s|netpbm-||" -e "s|\.$||")"
latest_commit_id="$latest_ver"

version_details

# Release package no matter what:
echo "newer" >release-"$pkgname"

#git_clone_source_repo

wget -O netpbm.tgz https://sourceforge.net/projects/netpbm/files/super_stable/"$latest_ver"/netpbm-"$latest_ver".tgz
tar xf netpbm.tgz
rm netpbm.tgz
mv netpbm-"$latest_ver" netpbm

#cd "$pkgname" || exit
#./autogen.sh
#cd /uny/sources || exit

archiving_source

######################################################################################################################
### Build

# unyc - run commands in uny's chroot environment
# shellcheck disable=SC2154
unyc <<"UNYEOF"
set -vx
source /uny/git/unypkg/fn

pkgname="netpbm"

version_verbose_log_clean_unpack_cd
get_env_var_values
get_include_paths

####################################################
### Start of individual build script

unset LD_RUN_PATH

tee config.mk <<'EOF'
DEFAULT_TARGET = nonmerge
BUILD_FIASCO = Y
CC = cc
LD = $(CC)
LINKERISCOMPILER=Y
LINKER_CAN_DO_EXPLICIT_LIBRARY=N
INTTYPES_H = <inttypes.h>
HAVE_INT64 = Y
WANT_SSE = N
CC_FOR_BUILD = $(CC)
LD_FOR_BUILD = $(LD)
CFLAGS_FOR_BUILD = $(CFLAGS_CONFIG)
LDFLAGS_FOR_BUILD = $(LDFLAGS)
WINDRES = windres
INSTALL = $(SRCDIR)/buildtools/install.sh
STRIPFLAG = -s
SYMLINK = ln -s
MANPAGE_FORMAT = nroff
AR = ar
RANLIB = ranlib
LEX = flex
PKG_CONFIG = pkg-config
EXE =
LDSHLIB = -shared -Wl,-soname,$(SONAME)
LDRELOC = NONE
CFLAGS_SHLIB = 
SHLIB_CLIB = -lc
NEED_RUNTIME_PATH = N
RPATHOPTNAME = -rpath
NETPBMLIB_RUNTIME_PATH = 
TIFFLIB = NONE
TIFFHDR_DIR =
TIFFLIB_NEEDS_JPEG = Y
TIFFLIB_NEEDS_Z = Y
JPEGLIB = NONE
JPEGHDR_DIR =
PNGLIB = NONE
PNGHDR_DIR =
PNGVER = 
ZLIB = NONE
ZHDR_DIR = 
JBIGLIB = $(INTERNAL_JBIGLIB)
JBIGHDR_DIR = $(INTERNAL_JBIGHDR_DIR)
JASPERLIB = $(INTERNAL_JASPERLIB)
JASPERHDR_DIR = $(INTERNAL_JASPERHDR_DIR)
JASPERDEPLIBS =
URTLIB = $(BUILDDIR)/urt/librle.a
URTHDR_DIR = $(SRCDIR)/urt
X11LIB = NONE
X11HDR_DIR =
LINUXSVGALIB = NONE
LINUXSVGAHDR_DIR = 
WINICON_OBJECT =
OMIT_NETWORK =
NETWORKLD = 
DONT_HAVE_PROCESS_MGMT = N
PKGDIR_DEFAULT = /tmp/netpbm
RESULTDIR_DEFAULT = /tmp/netpbm-test
PKGMANDIR = man

# binaries (pbmmake, etc)
INSTALL_PERM_BIN =  755       # u=rwx,go=rx
# shared libraries (libpbm.so, etc)
INSTALL_PERM_LIBD = 755       # u=rwx,go=rx
# static libraries (libpbm.a, etc)
INSTALL_PERM_LIBS = 644       # u=rw,go=r
# header files (pbm.h, etc)
INSTALL_PERM_HDR =  644       # u=rw,go=r
# man pages (pbmmake.1, etc)
INSTALL_PERM_MAN =  644       # u=rw,go=r
# data files (pnmtopalm color maps, etc)
INSTALL_PERM_DATA = 644       # u=rw,go=r

SUFFIXMANUALS1 = 1
SUFFIXMANUALS3 = 3
SUFFIXMANUALS5 = 5

NETPBMLIBTYPE = unixshared
NETPBMLIBSUFFIX = so
STATICLIB_TOO = Y
STATICLIBSUFFIX = a
SHLIBPREFIXLIST = lib
NETPBMSHLIBPREFIX = $(firstword $(SHLIBPREFIXLIST))
DLLVER =
NETPBM_DOCURL = http://netpbm.sourceforge.net/doc/
RGB_DB_PATH = /usr/local/netpbm/rgb.txt:/usr/share/netpbm/rgb.txt:/etc/X11/rgb.txt:/usr/lib/X11/rgb.txt:/usr/share/X11/rgb.txt:/usr/X11R6/lib/X11/rgb.txt

####Lines above were copied from config.mk.in by 'configure'.
####Lines below were added by 'configure' based on the GNU platform.
DEFAULT_TARGET = nonmerge
NETPBMLIBTYPE=unixshared
NETPBMLIBSUFFIX=so
STATICLIB_TOO=Y
CFLAGS = -O3 -ffast-math  -pedantic -fno-common -Wall -Wno-uninitialized -Wmissing-declarations -Wimplicit -Wwrite-strings -Wmissing-prototypes -Wundef -Wno-unknown-pragmas -Wno-strict-overflow
CFLAGS_MERGE = -Wno-missing-declarations -Wno-missing-prototypes
LDRELOC = ld --reloc
LINKER_CAN_DO_EXPLICIT_LIBRARY=Y
LINKERISCOMPILER = Y
CFLAGS_SHLIB += -fPIC
TIFFLIB = libtiff.so
JPEGLIB = libjpeg.so
PNGHDR_DIR = USE_PKG_CONFIG.a
PNGLIB = USE_PKG_CONFIG.a
ZLIB = libz.so
X11LIB = libX11.so
NETPBM_DOCURL = http://netpbm.sourceforge.net/doc/
WANT_SSE = Y
EOF

make -j"$(nproc)"
make package pkgdir=/uny/pkg/"$pkgname"/"$pkgver"

####################################################
### End of individual build script

add_to_paths_files
dependencies_file_and_unset_vars
cleanup_verbose_off_timing_end
UNYEOF

######################################################################################################################
### Packaging

package_unypkg
