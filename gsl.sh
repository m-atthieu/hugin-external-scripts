# ------------------
#     gsl 
# ------------------
# $Id: $
# Copyright (c) 2008, Ippei Ukai
# 2012, Harry van der Wolf


# prepare

# -------------------------------
# 20120111.0 initial version of gnu science library
# Dependency for new enblend after GSOC 2011
# -------------------------------

source ../scripts/functions.sh
check_SetEnv

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}


GSLVER="0"

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
    LDFLAGS="-L$REPOSITORYDIR/lib -arch $ARCH -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    NEXT_ROOT="$MACSDKDIR" \
    ./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" \
    --enable-shared --enable-static  || fail "configure step for $ARCH";

make clean;

make $OTHERMAKEARGs || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

# clean
make distclean 1> /dev/null

notify gsl
