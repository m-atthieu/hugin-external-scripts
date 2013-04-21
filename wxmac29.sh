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


uname_release=$(uname -r)
uname_arch=$(uname -p)
[ $uname_arch = powerpc ] && uname_arch="ppc"
os_dotvsn=${uname_release%%.*}
os_dotvsn=$(($os_dotvsn - 4))
case $os_dotvsn in
    4 ) os_sdkvsn="10.4u" ;;
    5|6|7|8 ) os_sdkvsn=10.$os_dotvsn ;;
    * ) echo "Unhandled OS Version: 10.$os_dotvsn. Build aborted."; exit 1 ;;
esac

NATIVE_SDKDIR="$(xcode-select -print-path)/SDKs/MacOSX${os_sdkvsn}.sdk"
NATIVE_OSVERSION="10.$os_dotvsn"
NATIVE_ARCH=$uname_arch
NATIVE_OPTIMIZE=""

#WXVER_FULL="$WXVER_COMP.5.0"  # for 2.8.8
#WXVER_FULL="$WXVER_COMP.6.0"  # for 2.8.10
#WXVER_FULL="$WXVER_COMP.7.0"   # for 2.8.11

case "$(basename $(pwd))" in
    "wxWidgets-2.9.3" | "wxPython-src-2.9.3.1")
	WXVERSION="2.9"
    #WXVER_COMP="$WXVERSION.0"
	WXVER_COMP="$WXVERSION.3"
	WXVER_FULL="$WXVER_COMP.0.0"
	;;
    "wxWidgets-2.9.4")
	WXVERSION="2.9"
	WXVER_COMP="$WXVERSION.4"      # for 2.9.4
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
fi
if [ "$(basename $(pwd))" = "wxPython-src-2.9.3.1" -a "$os_sdkvsn" = "10.8" ]; then
    patch -Np1 < ../scripts/patches/wxWidgets-2.9.3-10.6-10.8.diff
fi

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# for 10.6 compatibility, wx needs to be built against 10.6 sdk
SDK_BASE_PATH=$(xcode-select -print-path)/Platforms/MacOSX.platform
MACSDKDIR106="$SDK_BASE_PATH/Developer/SDKs/MacOSX10.6.sdk"


# compile
let NUMARCH="0"

for ARCH in $ARCHS
do
    echo "## compiling for $ARCH ##"

    mkdir -p "osx-$ARCH-build";
    cd "osx-$ARCH-build";
    
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";
    
    ARCHARGs=""
    MACSDKDIR=""
    
    if [ $ARCH = "i386" -o $ARCH = "i686" ] ; then
	TARGET=$i386TARGET
	MACSDKDIR=$MACSDKDIR106 #$i386MACSDKDIR
	ARCHARGs="$i386ONLYARG"
	OSVERSION="$i386OSVERSION"
	CC=$i386CC
	CXX=$i386CXX
    elif [ $ARCH = "x86_64" ] ; then
	TARGET=$x64TARGET
	MACSDKDIR=$MACSDKDIR106 #$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=$x64CC
	CXX=$x64CXX
    fi
    
    ARCHARGs=$(echo $ARCHARGs | sed 's/-ftree-vectorize//')
    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O2 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O2 -dead_strip" \
	CPPFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O2 -dead_strip -I$REPOSITORYDIR/include" \
	OBJCFLAGS="-arch $ARCH" \
	OBJCXXFLAGS="-arch $ARCH" \
	LDFLAGS="-L$REPOSITORYDIR/lib -arch $ARCH -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
	../configure --prefix="$REPOSITORYDIR" --exec-prefix=$REPOSITORYDIR/arch/$ARCH --disable-dependency-tracking \
	--host="$TARGET" --with-macosx-sdk=$MACSDKDIR --with-macosx-version-min=$OSVERSION \
	--enable-monolithic --enable-unicode --with-opengl --disable-compat26 --enable-graphics_ctx --with-cocoa \
	--with-libiconv-prefix=$REPOSITORYDIR --with-libjpeg --with-libtiff --with-libpng --with-zlib \
	--without-sdl --disable-sdltest \
	--enable-shared --disable-debug --enable-aui || fail "configure step for $ARCH";
    
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

    case $NATIVE_OSVERSION in
	10.4 )
	    dylib_name="dylib1.o"
	    ;;
	10.5 | 10.6 | 10.7 | 10.8)
	    dylib_name="dylib1.10.5.o"
	    ;;
	* )
	    echo "OS Version $NATIVE_OSVERSION not supported"; exit 1
	    ;;
    esac
    cp $NATIVE_SDKDIR/usr/lib/$dylib_name $REPOSITORYDIR/lib/
    
    # Need to build single-threaded. libwx_macu-2.8.dylib needs to be built before libwx_macu_gl-2.8 to avoid a link error.
    # This is only problematic for Intel builds, where jobs can be >1
    make --jobs=1 || fail "failed at make step of $ARCH";
    make install || fail "make install step of $ARCH";
    
    rm -f $REPOSITORYDIR/lib/$dylib_name;
    
    cd ../;
done

echo "## merging ##"

# merge libwx
merge_libraries "lib/libwx_osx_cocoau-$WXVER_FULL.dylib" "lib/libwx_osx_cocoau_gl-$WXVER_FULL.dylib"

if [ -f "$REPOSITORYDIR/lib/libwx_osx_cocoau-$WXVER_FULL.dylib" ]
then
    install_name_tool \
		-id "$REPOSITORYDIR/lib/libwx_osx_cocoau-$WXVER_COMP.dylib" \
		"$REPOSITORYDIR/lib/libwx_osx_cocoau-$WXVER_FULL.dylib";
    ln -sfn "libwx_osx_cocoau-$WXVER_FULL.dylib" "$REPOSITORYDIR/lib/libwx_osx_cocoau-$WXVER_COMP.dylib";
    ln -sfn "libwx_osx_cocoau-$WXVER_FULL.dylib" "$REPOSITORYDIR/lib/libwx_osx_cocoacu-$WXVERSION.dylib";
fi

if [ -f "$REPOSITORYDIR/lib/libwx_osx_cocoau_gl-$WXVER_FULL.dylib" ]
then
    install_name_tool \
	-id "$REPOSITORYDIR/lib/libwx_osx_cocoau_gl-$WXVER_COMP.dylib" \
	"$REPOSITORYDIR/lib/libwx_osx_cocoau_gl-$WXVER_FULL.dylib";
    for ARCH in $ARCHS
    do
	install_name_tool \
	    -change "$REPOSITORYDIR/arch/$ARCH/lib/libwx_osx_cocoau-$WXVER_COMP.dylib" \
	    "$REPOSITORYDIR/lib/libwx_osx_cocoau-$WXVER_COMP.dylib" \
	    "$REPOSITORYDIR/lib/libwx_osx_cocoau_gl-$WXVER_FULL.dylib";
    done
    ln -sfn "libwx_osx_cocoau_gl-$WXVER_FULL.dylib" "$REPOSITORYDIR/lib/libwx_osx_cocoau_gl-$WXVER_COMP.dylib";
    ln -sfn "libwx_osx_cocoau_gl-$WXVER_FULL.dylib" "$REPOSITORYDIR/lib/libwx_osx_cocoau_gl-$WXVERSION.dylib";
fi

echo "## merging setup.h ##"

# merge setup.h
for dummy in "wx/setup.h"
do
    wxmacconf="lib/wx/include/osx_cocoa-unicode-$WXVERSION/wx/setup.h"
    
    mkdir -p $(dirname "$REPOSITORYDIR/$wxmacconf")
    echo "" > $REPOSITORYDIR/$wxmacconf
    
    if [ $NUMARCH -eq 1 ] ; then
	ARCH=$ARCHS
	pushd $REPOSITORYDIR
	whereIsSetup=$(find ./arch/$ARCH/lib/wx -name setup.h -print)
	whereIsSetup=${whereIsSetup#./arch/*/}
	popd 
	cat "$REPOSITORYDIR/arch/$ARCH/$whereIsSetup" >>"$REPOSITORYDIR/$wxmacconf";
	continue
    fi
    
    for ARCH in $ARCHS
    do
	pushd $REPOSITORYDIR
 	whereIsSetup=$(find ./arch/$ARCH/lib/wx -name setup.h -print)
 	whereIsSetup=${whereIsSetup#./arch/*/}
 	popd 
	
	if [ $ARCH = "i386" -o $ARCH = "i686" ] ; then
	    echo "#if defined(__i386__)"                       >> "$REPOSITORYDIR/$wxmacconf";
	    echo ""                                            >> "$REPOSITORYDIR/$wxmacconf";
	    cat "$REPOSITORYDIR/arch/$ARCH/$whereIsSetup"      >> "$REPOSITORYDIR/$wxmacconf";
	    echo ""                                            >> "$REPOSITORYDIR/$wxmacconf";
	    echo "#endif"                                      >> "$REPOSITORYDIR/$wxmacconf";
	elif [ $ARCH = "x86_64" ] ; then
	    echo "#if defined(__x86_64__)"                     >> "$REPOSITORYDIR/$wxmacconf";
	    echo ""                                            >> "$REPOSITORYDIR/$wxmacconf";
	    cat "$REPOSITORYDIR/arch/$ARCH/$whereIsSetup"      >> "$REPOSITORYDIR/$wxmacconf";
	    echo ""                                            >> "$REPOSITORYDIR/$wxmacconf";
	    echo "#endif"                                      >> "$REPOSITORYDIR/$wxmacconf";
	else
	    echo "Unhandled ARCH: $ARCH. Aborting build."; exit 1
	fi
    done
done

echo "## merging wx-config ##"
for ARCH in $ARCHS
do
    if [ -L "$REPOSITORYDIR/arch/$ARCH/bin/wx-config" ]; then
	input=`ls -l $REPOSITORYDIR/arch/$ARCH/bin/wx-config|cut -d '>' -f 2`
    else
	input="$REPOSITORYDIR/arch/$ARCH/bin/wx-config"
    fi
    sed -e 's/^exec_prefix.*$/exec_prefix=\$\{prefix\}/' \
	-e 's/^is_cross \&\& target.*$//' \
	-e 's/-arch '$ARCH'//' \
	-e 's,include/i386-apple-darwin10-,include/,' \
	-e 's,-i386-apple-darwin10,,' \
	$input > $REPOSITORYDIR/bin/wx-config
    chmod +x $REPOSITORYDIR/bin/wx-config
    break;
done

# clean
rm -rf osx-{i386,x86_64}-build
