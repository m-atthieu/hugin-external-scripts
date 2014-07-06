# ------------------
# enblend-openmp 4.0   
# ------------------
# $Id: enblend3.sh 1908 2007-02-05 14:59:45Z ippei $
# Copyright (c) 2007, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20091209.0 sg Script enhanced to build Enblemd-Enfuse 4.0
# 20091210.0 hvdw Removed code that downgraded optimization from -O3 to -O2
# 20091223.0 sg Added argument to configure to locate missing TTF
#               Building enblend documentation requires tex. Check if possible.
# 20100402.0 hvdw Adapt to build openmp enabled versions. Needs the Setenv-leopard-openmp.txt file
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

# unhide vigra includes
if [ -d "$REPOSITORYDIR/include/vigra-private" ]; then
	mv $REPOSITORYDIR/include/vigra-private $REPOSITORYDIR/include/vigra
else 
    if [ -d "$REPOSITORYDIR/include/vigra" ]; then
	echo "last build surely ended in error, using $REPOSITORYDIR/include/vigra"
    else
	echo "vigra is not installed, aborting"
	exit -1
    fi
fi

# compile
ARCH=$ARCHS

ARCHARGs=""
MACSDKDIR=""

TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC_MP # $x64CC
CXX=$x64CXX_MP # $x64CXX
CPP=$x64CPP_MP
CXXCPP=$x64CXXCPP_MP
MARCH=-m64

mkdir -p build-$ARCH
cd build-$ARCH
rm -f CMakeCache.txt

env \
    CC=$CC CXX=$CXX CPP=$CPP CXXCPP=$CXXCPP \
    cmake \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL="OFF" \
    -DCMAKE_INSTALL_PREFIX:PATH="$REPOSITORYDIR" \
    -DCMAKE_BUILD_TYPE:STRING="Release" \
    -DCMAKE_C_FLAGS_RELEASE:STRING="-fopenmp $MARCH $ARCHARGs -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE -Wno-unused-local-typedefs" \
    -DCMAKE_CXX_FLAGS_RELEASE:STRING="-fopenmp $MARCH $ARCHARGs -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE -Wno-unused-local-typedefs" \
    -DJPEG_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DJPEG_LIBRARIES="$REPOSITORYDIR/lib/libjpeg.dylib" \
    -DPNG_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DPNG_LIBRARIES="$REPOSITORYDIR/lib/libpng.dylib" \
    -DTIFF_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DTIFF_LIBRARIES="$REPOSITORYDIR/lib/libtiff.dylib" \
    -DZLIB_INCLUDE_DIR="/usr/include" \
    -DZLIB_LIBRARIES="/usr/lib/libz.dylib" \
    -DVIGRA_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DVIGRA_LIBRARIES="$REPOSITORYDIR/lib/libvigraimpex.dylib" \
    -DDOC:BOOL='OFF' \
    -DENABLE_OPENCL:BOOL='ON' \
    -DENABLE_OPENMP:BOOL="ON" \
    -DENABLE_IMAGECACHE:BOOL="OFF" \
    -DENABLE_GPU:BOOL="OFF" \
    .. || fail "configuring for $ARCH"

perl -p -i -e 's,#define STRERROR_R_CHAR_P 1,//#define STRERROR_R_CHAR_P 1,' config.h
make clean || fail "make clean for $ARCH";
make all $extraBuild || fail "make all for $ARCH"
make install $extraInstall || fail "make install for $ARCH";

# hiding vigra includes
if [ -d "$REPOSITORYDIR/include/vigra" ]; then
    mv $REPOSITORYDIR/include/vigra $REPOSITORYDIR/include/vigra-private
fi

# clean
cd ..
rm -rf build-$ARCH
