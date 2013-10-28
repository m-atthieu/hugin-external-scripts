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

case "$(basename $(pwd))" in
    'vigra-1.8.0')
	VIGRA_M='4'
	VIGRA_FULL='180'
	;;
    'vigra-1.9.0')
	VIGRA_M='4'
	VIGRA_FULL='190'
	;;
    *)
	fail "Unknown version"
	;;
esac

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";


# compile
ARCHARGs=""
MACSDKDIR=""

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
    -DCMAKE_VERBOSE_MAKEFILE:BOOL="ON" \
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
    
cd ..

# clean
clean_build_directories

notify vigra