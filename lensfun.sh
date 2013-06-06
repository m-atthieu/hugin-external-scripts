# ------------------
#    lensfun 
# ------------------
# $Id: libpng.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007, Ippei Ukaia
# This script, 2012  HvdW


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20120307 hvdw initial lensfun based on svn 152
# 20120415.0 hvdw now builds correctly
# 20120429.0 hvdw compile x86_64 with gcc-4.6 for lion and up openmp compatibility
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

check_numarchs

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile
ARCH=$ARCHS
    
ARCHARGs=""
MACSDKDIR=""

TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
ARCHFLAG="-m64"

env \
    CC=$CC CXX=$CXX \
    CPPFLAGS="$ARCHFLAG -I$REPOSITORYDIR/include/glib-2.0 -I$REPOSITORYDIR/include/gio-unix-2.0 -I/usr/include \
         -I$REPOSITORYDIR/lib/glib-2.0/include -I$REPOSITORYDIR/lib/gio/include -I$REPOSITORYDIR/include" \
    NEXT_ROOT="$MACSDKDIR" \
    ./configure --prefix="$REPOSITORYDIR" --sdkdir="$REPOSITORYDIR" --mode="release" \
    --staticlibs=NO --verbose \
    --cflags="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip -I$REPOSITORYDIR/include/glib-2.0 -I$REPOSITORYDIR/include/gio-unix-2.0 \
         -I$REPOSITORYDIR/arch/$ARCH/lib/glib-2.0/include -I$REPOSITORYDIR/arch/$ARCH/lib/gio/include -I$REPOSITORYDIR/include" \
    --cxxflags="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip -I$REPOSITORYDIR/include/glib-2.0 -I$REPOSITORYDIR/include/gio-unix-2.0 \
         -I$REPOSITORYDIR/lib/glib-2.0/include -I$REPOSITORYDIR/lib/gio/include -I$REPOSITORYDIR/include" \
    --ldflags="$ARCHFLAG -L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
    || fail "configure step for $ARCH";


make lensfun || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

install_name_tool -id $REPOSITORYDIR/lib/liblensfun.dylib $REPOSITORYDIR/lib/liblensfun.dylib

# clean
make distclean 
