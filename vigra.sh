# ------------------
#     vigra
# ------------------
# $Id: pano13.sh 1904 2007-02-05 00:10:54Z ippei $
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
mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";

TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION=$x64OSVERSION
OPTIMIZE=$x64OPTIMIZE
CC=$x64CC_MP
CXX=$x64CXX_MP
MARCH='-m64'

mkdir -p build-$ARCH;
cd build-$ARCH;
rm -f CMakeCache.txt;

cmake \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL="OFF" \
    -DCMAKE_INSTALL_PREFIX:PATH="$REPOSITORYDIR" \
    -DCMAKE_BUILD_TYPE:STRING="Release" \
    -DCMAKE_C_FLAGS_RELEASE:STRING="$MARCH -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE" \
    -DCMAKE_CXX_FLAGS_RELEASE:STRING="$MARCH -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE" \
    -DJPEG_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DJPEG_LIBRARIES="$REPOSITORYDIR/lib/libjpeg.dylib" \
    -DPNG_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DPNG_LIBRARIES="$REPOSITORYDIR/lib/libpng.dylib" \
    -DTIFF_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DTIFF_LIBRARIES="$REPOSITORYDIR/lib/libtiff.dylib" \
    -DWITH_OPENEXR:BOOL="ON" \
    -DBoost_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DZLIB_INCLUDE_DIR="/usr/include" \
    -DZLIB_LIBRARIES="/usr/lib/libz.dylib" \
    .. || fail "configuring for $ARCH"

make || fail "building for $ARCH"
make install;

# install_name_tool does not do its job
install_name_tool -id $REPOSITORYDIR/lib/libvigraimpex.4.dylib $REPOSITORYDIR/lib/libvigraimpex.4.dylib

# copy includes
echo "renaming includes"
mv $REPOSITORYDIR/include/vigra $REPOSITORYDIR/include/vigra-private

# clean
cd ..
rm -rf build-$ARCH
