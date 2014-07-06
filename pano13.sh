# ------------------
#     pano13
# ------------------
# $Id: pano13.sh 1904 2007-02-05 00:10:54Z ippei $
# Copyright (c) 2007, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100113.0 sg Script adjusted for libpano13-2.9.15
# 20100117.0 sg Move code for detecting which version of pano13 to top for visibility
# 20100119.0 sg Support the SVN version of panotools - 2.9.16
# 201004xx.0 hvdw support 2.9.17
# 20100624.0 hvdw More robust error checking on compilation
# 20110107.0 hvdw support for 2.9.18
# 20110427.0 hvdw compile x86_64 with gcc 4.6 for openmp compatibility on lion and up
# 20121010.0 hvdw remove openmp stuff to make it easier to build
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

# init
mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# for 10.6 compatibility, libpano needs to be built against 10.6 sdk
SDK_BASE_PATH=$(xcode-select -print-path)/Platforms/MacOSX.platform
MACSDKDIR106="$SDK_BASE_PATH/Developer/SDKs/MacOSX10.6.sdk"

# compile
ARCH=$ARCHS

ARCHARGs=""
MACSDKDIR=""
    
TARGET=$x64TARGET
MACSDKDIR=$MACSDKDIR106 #$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
ARCHFLAG="-m64"

mkdir -p build-$ARCH
cd build-$ARCH

env \
    CC=$CC CXX=$CXX \
    NEXT_ROOT="$MACSDKDIR" \
    PKGCONFIG="$REPOSITORYDIR/lib" \
    cmake \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL="OFF" \
    -DCMAKE_INSTALL_PREFIX:PATH="$REPOSITORYDIR" \
    -DCMAKE_BUILD_TYPE:STRING="Release" \
    -DCMAKE_C_FLAGS_RELEASE:STRING="-arch $ARCH -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE" \
    -DCMAKE_CXX_FLAGS_RELEASE:STRING="-arch $ARCH -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE" \
    -DJPEG_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DJPEG_LIBRARIES="$REPOSITORYDIR/lib/libjpeg.dylib" \
    -DPNG_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DPNG_LIBRARIES="$REPOSITORYDIR/lib/libpng.dylib" \
    -DTIFF_INCLUDE_DIR="$REPOSITORYDIR/include" \
    -DTIFF_LIBRARIES="$REPOSITORYDIR/lib/libtiff.dylib" \
    -DZLIB_INCLUDE_DIR="/usr/include" \
    -DZLIB_LIBRARIES="/usr/lib/libz.dylib" \
    .. || fail "configure for $ARCH"

    #Stupid libtool... (perhaps could be done by passing LDFLAGS to make and install)
#[ -f libtool-bk ] && rm libtool-bak
#mv "libtool" "libtool-bk"; # could be created each time we run configure
#sed -e "s#-dynamiclib#-dynamiclib $ARCHFLAG -isysroot $MACSDKDIR#g" "libtool-bk" > "libtool";
#chmod +x libtool

make clean;
make || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

install_name_tool -id $REPOSITORYDIR/lib/libpano13.3.dylib $REPOSITORYDIR/lib/libpano13.3.dylib

for bin in PTblender PTcrop PTinfo PTmasker PTmender PToptimizer PTroller PTtiff2psd PTtiffdump PTuncrop 
do
    install_name_tool -change libpano13.3.dylib $REPOSITORYDIR/lib/libpano13.3.dylib $REPOSITORYDIR/bin/$bin
done

# clean
cd ..
rm -rf build-$ARCH
