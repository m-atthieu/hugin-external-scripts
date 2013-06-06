# ------------------
#      nasm
# ------------------
# $Id:  $
# Copyright (c) 2007, 2011, Ippei Ukai, Matthieu DESILE

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
    
ARCHARGs=""
MACSDKDIR=""

compile_setenv

# nasm does not support building in another directory
#mkdir -p build-$ARCH
#cd build-$ARCH

env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    NEXT_ROOT="$MACSDKDIR" \
    ./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" || fail "configure step for $ARCH";

make clean;
make || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

# rename execs
mv $REPOSITORYDIR/bin/nasm $REPOSITORYDIR/bin/nasm2

make distclean