# ------------------
#      tclap
# ------------------
# $Id:  $
# Copyright (c) 2007, 2011, Ippei Ukai, Matthieu DESILE

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20111310.0 initial 2.0.4, based on pcre-8.13 (but not used)
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}


let NUMARCH="0"

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile
ARCHARGs=""
MACSDKDIR=""

compile_setenv
    
env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fpermissive" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fpermissive" \
    CPPFLAGS="-I$REPOSITORYDIR/include -isysroot $MACSDKDIR" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    NEXT_ROOT="$MACSDKDIR" \
    ./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" || fail "configure step for $ARCH";
    
make clean;
make || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

# clean
make distclean 1> /dev/null

notify tclap