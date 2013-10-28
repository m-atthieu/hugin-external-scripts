# ------------------
#     libglib2
# ------------------
# $Id: libglib2.sh 1902 2008-01-02 22:27:47Z Harry $
# Copyright (c) 2007, Ippei Ukai
# script skeleton Copyright (c) 2007, Ippei Ukai
# libglib2 specifics 2012, Harry van der Wolf


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20120411.0 HvdW Script tested
# -------------------------------

# init

fail()
{
    echo "** Failed at $1 **"
    exit 1
}

ORGPATH="$PATH"

VERSION="2.0"
FULLVERSION="2.0.0"

#patch -Np0 < ../scripts/patches/glib-2.32-gcc-4.7.patch

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# since we're using a gcc version that does not understand block, 
# we must stay with version 10.6 of the SDK
SDK_BASE_PATH=$(xcode-select -print-path)/Platforms/MacOSX.platform
MACSDKDIR106="$SDK_BASE_PATH/Developer/SDKs/MacOSX10.6.sdk"

# compile
ARCHARGs=""
MACSDKDIR=""

TARGET=$x64TARGET
MACSDKDIR=$MACSDKDIR106 #$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
ARCHFLAG="-m64"

env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip -fstrict-aliasing" \
    CXXFLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip -fstrict-aliasing" \
    CPPFLAGS="-I$REPOSITORYDIR/include -isysroot $MACSDKDIR" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -L$MACSDKDIR/usr/lib -dead_strip -lresolv -bind_at_load $ARCHFLAG" \
    NEXT_ROOT="$MACSDKDIR" \
    ./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" \
    ZLIB_CFLAGS="-I$MACSDKDIR/usr/include" ZLIB_LIBS="-L$MACSDKDIR/usr/lib" \
    GETTEXT_CFLAGS="-I$REPOSITORYDIR/include" GETTEXT_LIBS="-L$REPOSITORYDIR/lib" \
    --disable-selinux --disable-fam --disable-xattr \
    --disable-gtk-doc --disable-gtk-doc-html --disable-gtk-doc-pdf \
    --disable-man --disable-dtrace --disable-systemtap \
    --enable-shared || fail "configure step of $ARCH"

make clean
make || fail "failed at make step of $ARCH"
make $OTHERMAKEARGs install || fail "make install step of $ARCH"

# clean
#clean_build_directories
echo "## distclean ##"
make distclean 1> /dev/null

notify glib2