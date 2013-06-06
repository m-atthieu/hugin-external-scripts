# ------------------
#     levmar
# ------------------
# $Id: $
# Copyright (c) 2008, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20120709.0 mde initial script for version 1.7.1
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

patch -Np1 < ../scripts/patches/levmar-2.6-makefile.patch

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

    #mkdir -p build-$ARCH
    #cd build-$ARCH
    #rm -f CMakeCache.txt

env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -arch $ARCH -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    NEXT_ROOT="$MACSDKDIR" \
    make cleanall all || fail "configure step for $ARCH";

set -x
cp liblevmar.dylib $REPOSITORYDIR/lib
mkdir -p $REPOSITORYDIR/include/levmar
cp levmar.h $REPOSITORYDIR/include/levmar

install_name_tool -id $REPOSITORYDIR/lib/liblevmar.dylib $REPOSITORYDIR/lib/liblevmar.dylib
