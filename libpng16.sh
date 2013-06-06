# ------------------
#     libpng
# ------------------
# $Id: libpng.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv

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

mkdir -p build-$ARCH
cd build-$ARCH

TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
ARCHFLAG="-m64"
    
env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include -I/usr/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
    NEXT_ROOT="$MACSDKDIR" \
    ../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --with-zlib-prefix=$MACSDKDIR/usr \
    --host="$TARGET" \
    --enable-shared --disable-static || fail "configure step for $ARCH";

make clean
make || fail "faild at make step of $ARCH"
make install || fail "make install step of $ARCH"

make distclean