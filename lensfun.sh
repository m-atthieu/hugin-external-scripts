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
    
TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
ARCHFLAG="-m64"

mkdir -p build-$ARCH
cd build-$ARCH

env \
    CC=$CC CXX=$CXX \
    CPPFLAGS="$ARCHFLAG -I$REPOSITORYDIR/include/glib-2.0 -I$REPOSITORYDIR/include/gio-unix-2.0 -I/usr/include \
         -I$REPOSITORYDIR/lib/glib-2.0/include -I$REPOSITORYDIR/lib/gio/include -I$REPOSITORYDIR/include" \
    NEXT_ROOT="$MACSDKDIR" \
    cmake \
    -DCMAKE_VERBOSE_MAKEFILE="OFF" \
    -DBUILD_TESTS="OFF" \
    -DCMAKE_INSTALL_PREFIX:PATH="$REPOSITORYDIR" \
    -DCMAKE_CXX_FLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip -DCONF_SYMBOL_VISIBILITY=1 -DCMAKE_COMPILER_IS_GNUCC=1" \
    -DCMAKE_C_FLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    -DCMAKE_EXE_LINKER_FLAGS="$ARCHFLAG -L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
    -DCMAKE_SHARED_LINKER_FLAGS="$ARCHFLAG -L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
    -DBUILD_FOR_SSE="ON" \
    -DBUILD_FOR_SSE2="ON" \
    .. || fail "configure step for $ARCH"

make || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

install_name_tool -id $REPOSITORYDIR/lib/liblensfun.dylib $REPOSITORYDIR/lib/liblensfun.dylib

# clean
cd ..
rm -rf build-$ARCH
