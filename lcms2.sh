# ------------------
#     liblcms2
# ------------------
# $Id: liblcms.sh 1902 2008-01-02 22:27:47Z Harry $
# Copyright (c) 2007, Ippei Ukai
# script skeleton Copyright (c) 2007, Ippei Ukai
# lcms2 specifics 2012, Harry van der Wolf


# prepare

# -------------------------------
# 20120111.0 hvdw initial lcms2 (lcms version 2) script
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

LCMSVER="2"

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

env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include -isysroot $MACSDKDIR" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
    NEXT_ROOT="$MACSDKDIR" \
    ./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" \
    --enable-shared --with-zlib=$MACSDKDIR/usr/lib \
    || fail "configure step for $ARCH";

make clean
make || fail "failed at make step of $ARCH";
make $OTHERMAKEARGs install || fail "make install step of $ARCH";

notify lcms2