# ------------------
#     libiconv
# ------------------
# $Id: libiconv.sh 1902 2008-01-02 22:27:47Z Harry $
# Copyright (c) 2007, Ippei Ukai
# script skeleton Copyright (c) 2007, Ippei Ukai
# iconv specifics 2010, Harry van der Wolf

# -------------------------------
# 20100117.0 HvdW Script tested
# 20100624.0 hvdw More robust error checking on compilation
# -------------------------------

# init
source ../scripts/functions.sh
check_SetEnv

fail()
{
    echo "** Failed at $1 **"
    exit 1
}

check_numarchs

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

ARCH=$ARCHS
mkdir build-$ARCH
cd build-$ARCH

ARCHARGs=""
MACSDKDIR=""
    
TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
    
env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
    NEXT_ROOT="$MACSDKDIR" \
    ../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" \
    --disable-nls --enable-extra-encodings \
    --without-libiconv-prefix --without-libintl-prefix \
    --disable-static --enable-shared  || fail "configure step of $ARCH";

make clean
make || fail "failed at make step of $ARCH"
make $OTHERMAKEARGs install || fail "make install step of $ARCH"

make distclean
