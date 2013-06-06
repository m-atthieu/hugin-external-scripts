# ------------------
#     openexr
# ------------------
# $Id: openexr.sh 2004 2007-05-11 00:17:50Z ippei $
# Copyright (c) 2007, Ippei Ukai


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
ARCH=$ARCHS
TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX

mkdir -p build-$ARCH
cd build-$ARCH

env \
    CC="$CC" CXX="$CXX" \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    NEXT_ROOT="$MACSDKDIR" \
    PKG_CONFIG_PATH="$REPOSITORYDIR/lib/pkgconfig" \
    ../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" \
    --enable-shared --disable-static || fail "configure step for $ARCH";

make clean;
make $OTHERMAKEARGs all || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

# clean
make distclean
