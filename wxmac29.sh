# ------------------
#     wxWidgets 2.9
# ------------------
# $Id: wxmac28.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007-2008, Ippei Ukai

# 2009-12-04.0 Remove unneeded arguments to make and make install; made make single threaded

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
#               Works Intel: 10.5, 10.6 & Powerpc 10.4, 10.5
# 20100624.0 hvdw More robust error checking on compilation
# -------------------------------

fail()
{
    echo "** Failed at $1 **"
    exit 1
}

# init
check_numarchs

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# for 10.6 compatibility, wx needs to be built against 10.6 sdk
SDK_BASE_PATH=$(xcode-select -print-path)/Platforms/MacOSX.platform
MACSDKDIR106="$SDK_BASE_PATH/Developer/SDKs/MacOSX10.6.sdk"

# compile
ARCH=$ARCHS
mkdir -p "build-$ARCH"
cd "build-$ARCH"
    
ARCHARGs=""
MACSDKDIR=""
    
TARGET=$x64TARGET
MACSDKDIR=$MACSDKDIR106 #$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
    
ARCHARGs=$(echo $ARCHARGs | sed 's/-ftree-vectorize//')

env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O2 -g -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O2 -g -dead_strip" \
    CPPFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O2 -g -dead_strip -I$REPOSITORYDIR/include" \
    OBJCFLAGS="-arch $ARCH" \
    OBJCXXFLAGS="-arch $ARCH" \
    LDFLAGS="-L$REPOSITORYDIR/lib -arch $ARCH -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    ../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" --with-macosx-sdk=$MACSDKDIR --with-macosx-version-min=$OSVERSION \
    --enable-monolithic --enable-unicode --with-opengl --disable-compat26 --enable-graphics_ctx --with-cocoa \
    --with-libiconv-prefix=$REPOSITORYDIR --with-libjpeg --with-libtiff --with-libpng --with-zlib \
    --without-sdl --disable-sdltest --enable-debug \
    --enable-shared --disable-static --enable-aui || fail "configure step for $ARCH";

make --jobs=1 || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

# no clean (we want to keep object files for debugging purpose)
#rm -rf osx-{i386,x86_64}-build
