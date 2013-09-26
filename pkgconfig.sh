# ------------------
#      gnumake
# ------------------
# $Id:  $
# Copyright (c) 2007, Ippei Ukai

# download
# http://pkgconfig.freedesktop.org/releases/pkg-config-0.25.tar.gz

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20111025.0 sg first version 0.25, 0.26 requires glib, which is too much for just a utility
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

# patch
patch -Np0 < ../scripts/patches/pkgconfig-0.25-lion-clang.patch

# compile

# remove 64-bit archs from ARCHS
#remove_64bits_from_ARCH

for ARCH in $ARCHS
do
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";
    
    ARCHARGs=""
    MACSDKDIR=""

    compile_setenv

    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
	NEXT_ROOT="$MACSDKDIR" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH \
	|| fail "configure step for $ARCH";
    
    make clean;
    make || fail "failed at make step of $ARCH";
    make install || fail "make install step of $ARCH";
done


# merge execs
merge_execs bin/pkg-config

cd ../

make distclean 1> /dev/null

notify pkgconfig