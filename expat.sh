# ------------------
#     libexpat
# ------------------
# $Id: $
# Copyright (c) 2008, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv
# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100624.0 hvdw More robust error checking on compilation
# -------------------------------

fail()
{
    echo "** Failed at $1 **"
    exit 1
}


# init
check_numarchs

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile
mkdir -p build-$ARCHS
cd build-$ARCHS

ARCHARGs=""
MACSDKDIR=""

TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX

env \
    CC=$x64CC CXX=$x64CXX \
    CFLAGS="-isysroot $x64MACSDKDIR -arch x86_64 $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $x64MACSDKDIR -arch x86_64 $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$x64OSVERSION -dead_strip -prebind" \
    NEXT_ROOT="$MACSDKDIR" \
    ../configure --prefix="$REPOSITORYDIR"  \
    --host="$TARGET" \
    --enable-shared || fail "configure step for $ARCHS";

make clean;
make $OTHERMAKEARGs buildlib || fail "failed at make step of $ARCH";
make installlib || fail "failed at make install step of $ARCH";

# clean
make distclean