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

#patch -Np0 < ../scripts/lensfun-patch-pkgconfig.diff

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";


# compile
ARCHARGs=""
MACSDKDIR=""
    
TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
ARCHFLAG="-m64"

make clean >& /dev/null

mkdir -p build-$ARCH
cd build-$ARCH

env \
    CC="$CC -isysroot $MACSDKDIR" \
    CXX="$CXX -isysroot $MACSDKDIR" \
    CFLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip \
         -I$REPOSITORYDIR/include/glib-2.0 -I$REPOSITORYDIR/include/gio-unix-2.0 \
         -I$REPOSITORYDIR/include" \
    CXXFLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O3 -dead_strip \
         -I$REPOSITORYDIR/include/glib-2.0 -I$REPOSITORYDIR/include/gio-unix-2.0 \
         -I$REPOSITORYDIR/include" \
    CPPFLAGS="$ARCHFLAG -I$REPOSITORYDIR/include/glib-2.0 -I$REPOSITORYDIR/include/gio-unix-2.0 \
         -I/usr/include \
         -I$REPOSITORYDIR/include -isysroot $MACSDKDIR" \
    LDFLAGS="$ARCHFLAG -L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
    NEXT_ROOT="$MACSDKDIR" \
    cmake \
    -DCMAKE_INSTALL_PREFIX:PATH="$REPOSITORYDIR" \
    .. || fail "configure step for $ARCH";


make || fail "make for $ARCH"
make install || fail "make install for $ARCH"

cd ..

# clean
rm -rf build-$ARCH

notify lensfun
