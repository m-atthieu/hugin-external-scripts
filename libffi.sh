# ------------------
#     libffi
# ------------------
# $Id: libffi.sh 1902 2008-01-02 22:27:47Z Harry $
# Copyright (c) 2007, Ippei Ukai
# script skeleton Copyright (c) 2007, Ippei Ukai
# libffi specifics 2012, Harry van der Wolf

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
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fstrict-aliasing" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fstrict-aliasing" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -lresolv -bind_at_load" \
    NEXT_ROOT="$MACSDKDIR" \
    ../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" \
    --disable-static --enable-shared  || fail "configure step of $ARCH";
echo "## make ##"
make clean
make || fail "failed at make step of $ARCH"
make $OTHERMAKEARGs install || fail "make install step of $ARCH"

#make
cd ..
rm -rf build-$ARCH
