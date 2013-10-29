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

case "$(basename $(pwd))" in
    "wxWidgets-2.9.5")
        WXVERSION="2.9"
        WXVER_COMP="$WXVERSION.5"
        WXVER_FULL="$WXVER_COMP.0.0"
        ;;
	"wxWidgets.git")
	WXVERSION="2.9"
	WXVER_COMP="$WXVERSION.5"
	WXVER_FULL="$WXVER_COMP.0.0"
	;;
    *)
	Fail "Unknown wx version"
esac

# When building on 10.8 with a 10.6 target, version 2.9.3 needs patch, borrowed from 2.9.4
if [ "$(basename $(pwd))" = "wxWidgets-2.9.3" -a "$os_sdkvsn" = "10.8" ]; then
    patch -Np0 < ../scripts/patches/wxWidgets-2.9.3-10.6-10.8.diff
    # see http://trac.wxwidgets.org/ticket/13888
    patch -Np0 < ../scripts/patches/wxWidgets-2.9-xh_toolb.diff
fi
if [ "$(basename $(pwd))" = "wxPython-src-2.9.3.1" -a "$os_sdkvsn" = "10.8" ]; then
    patch -Np1 < ../scripts/patches/wxWidgets-2.9.3-10.6-10.8.diff
    # see http://trac.wxwidgets.org/ticket/13888
    patch -Np0 < ../scripts/patches/wxWidgets-2.9-xh_toolb.diff
fi

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# for 10.6 compatibility, wx needs to be built against 10.6 sdk
SDK_BASE_PATH=$(xcode-select -print-path)/Platforms/MacOSX.platform
MACSDKDIR106="$SDK_BASE_PATH/Developer/SDKs/MacOSX10.6.sdk"

# compile
echo "## compiling for $ARCH ##"

mkdir -p "osx-$ARCH-build";
cd "osx-$ARCH-build";

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
    --enable-shared --enable-aui || fail "configure step for $ARCH";

    ### Setup.h is created by configure!
    # For all SDK; CP panel problem still exists.
    ## disable core graphics implementation for 10.3
    #if [[ $TARGET == *darwin7 ]]
    #then
    # need to find out where setup.h was created. This seems to vary if building on powerpc and
    # is different under 10.4 and 10.5
whereIsSetup=$(find . -name setup.h -print)
whereIsSetup=${whereIsSetup#./}
    # now building with osx_cocoa instead of cocoa, may not be useful anymore
    #echo '#ifndef wxMAC_USE_CORE_GRAPHICS'    >> $whereIsSetup
    #echo ' #define wxMAC_USE_CORE_GRAPHICS 1' >> $whereIsSetup
    #echo '#endif'                             >> $whereIsSetup
    #echo ''                                   >> $whereIsSetup
    #echo "patched ${whereIsSetup}"
    #fi
make clean;

    #hack
cp utils/wxrc/Makefile utils/wxrc/Makefile-copy;
echo "all: " > utils/wxrc/Makefile;
echo "" >> utils/wxrc/Makefile;
echo "install: " >> utils/wxrc/Makefile;
    #~hack


    # Need to build single-threaded. libwx_macu-2.8.dylib needs to be built before libwx_macu_gl-2.8 to avoid a link error.
    # This is only problematic for Intel builds, where jobs can be >1
make --jobs=1 || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

rm -f $REPOSITORYDIR/lib/$dylib_name;
cd ../;

ln -s x86_64-apple-darwin10-osx_cocoa-unicode-2.9 $REPOSITORYDIR/lib/wx/include/osx_cocoa-unicode-2.9

notify wxWidgets