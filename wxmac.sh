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

ENABLE_DEBUG=""
if [ $# -eq 1 -a "$1" = "--enable-debug" ]; then
	ENABLE_DEBUG="--enable-debug --enable-debug_gdb"
fi

# only for 2.9.3
wx_version="$(basename $(pwd))"
if [ "$wx_version" = "wxWidgets-2.9.3" ]; then
	patch -Np1 < ../scripts/patches/wx-2.9.3-xh_toolb.diff
	patch -Np1 < ../scripts/patches/wxwidgets-2.9.3-clang.patch
fi

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile
ARCH=$ARCHS
mkdir -p "build-$ARCH"
cd "build-$ARCH"
    
# wxWidgets needs to be compiled against the 10.6 SDK
TARGET=$x64TARGET
MACSDKDIR=$MACSDKDIR106
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
    
ARCHARGs=$(echo $ARCHARGs | sed 's/-ftree-vectorize//;s/-fopenmp//g')

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
    --without-sdl --disable-sdltest ${ENABLE_DEBUG} \
    --enable-shared --disable-static --enable-aui || fail "configure step for $ARCH";

make --jobs=1 || fail "failed at make step of $ARCH";
make install  || fail "make install step of $ARCH";

if [ "$wx_version" = "wxWidgets-2.9.3" ]; then
	ln -sf libwx_osx_cocoau-2.9.3.0.0.dylib    $REPOSITORYDIR/lib/libwx_osx_cocoau-2.9.dylib
	ln -sf libwx_osx_cocoau_gl-2.9.3.0.0.dylib $REPOSITORYDIR/lib/libwx_osx_cocoau_gl-2.9.dylib
elif [ "$wx_version" = "wxWidgets-3.0.0" ]; then
	ln -sf libwx_osx_cocoau-3.0.0.0.0.dylib    $REPOSITORYDIR/lib/libwx_osx_cocoau-3.0.dylib
	ln -sf libwx_osx_cocoau_gl-3.0.0.0.0.dylib $REPOSITORYDIR/lib/libwx_osx_cocoau_gl-3.0.dylib
elif [ "$wx_version" = "wxWidgets-3.0.1" ]; then
	ln -sf libwx_osx_cocoau-3.0.0.1.0.dylib    $REPOSITORYDIR/lib/libwx_osx_cocoau-3.0.dylib
	ln -sf libwx_osx_cocoau_gl-3.0.0.1.0.dylib $REPOSITORYDIR/lib/libwx_osx_cocoau_gl-3.0.dylib
fi

# no clean (we want to keep object files for debugging purpose)
if [ -z "${ENABLE_DEBUG}" ]; then
	cd ..
	rm -rf build-$ARCH
fi
