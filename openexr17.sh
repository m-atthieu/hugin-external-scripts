# ------------------
#     openexr
# ------------------
# $Id: openexr.sh 2004 2007-05-11 00:17:50Z ippei $
# Copyright (c) 2007, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100624.0 hvdw More robust error checking on compilation
# -------------------------------

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

case "$(basename $(pwd))" in 
    'openexr-1.7.0')
	EXRVER_M="6"
	EXRVER_FULL="$EXRVER_M.0.0"
	;;
    'openexr-1.7.1')
	EXRVER_M="7"
	EXRVER_FULL="$EXRVER_M.0.0"
	;;
    *)
	fail "Unknown version"
esac

NATIVE_LIBHALF_DIR="$REPOSITORYDIR/lib"

uname_release=$(uname -r)
uname_arch=$(uname -p)
[ $uname_arch = powerpc ] && uname_arch="ppc"
os_dotvsn=${uname_release%%.*}
os_dotvsn=$(($os_dotvsn - 4))
case $os_dotvsn in
    4 ) os_sdkvsn="10.4u" ;;
    5|6|7|8|9 ) os_sdkvsn=10.$os_dotvsn ;;
    * ) echo "Unhandled OS Version: 10.$os_dotvsn. Build aborted."; exit 1 ;;
esac

NATIVE_SDKDIR="$(xcode-select -print-path)/SDKs/MacOSX$os_sdkvsn.sdk"
NATIVE_OSVERSION="10.$os_dotvsn"
NATIVE_ARCH="$uname_arch"
NATIVE_OPTIMIZE=""

# init
mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

NATIVE_CXXFLAGS="-isysroot $NATIVE_SDK -arch $NATIVE_ARCH $NATIVE_OPTIMIZE \
	-mmacos-version-min=$NATIVE_OSVERSION -D_THREAD_SAFE -O3 -dead_strip";

NATIVE_ARCH=x86_64 # workaround

c++ -DHAVE_CONFIG_H -I./IlmImf -I./config \
    -I$REPOSITORYDIR/include/OpenEXR -D_THREAD_SAFE \
    -I. -I./config  -I$REPOSITORYDIR/include \
    -I/usr/include -arch $NATIVE_ARCH $NATIVE_OPTIMIZE -ftree-vectorize \
    -mmacosx-version-min=$NATIVE_OSVERSION -O3 -dead_strip  -L$NATIVE_LIBHALF_DIR -lHalf \
    -o ./IlmImf/b44ExpLogTable-native ./IlmImf/b44ExpLogTable.cpp

if [ -f "./IlmImf/b44ExpLogTable-native" ] ; then
    echo "Created b44ExpLogTable-native"
else
    echo " Error Failed to create b44ExpLogTable-native"
    exit 1
fi

if [ -f "./IlmImf/Makefile.in-original" ]; then
    echo "original already exists!";
else
    mv "./IlmImf/Makefile.in" "./IlmImf/Makefile.in-original"
fi
sed -e 's/\.\/b44ExpLogTable/\.\/b44ExpLogTable-native/' \
    "./IlmImf/Makefile.in-original" > "./IlmImf/Makefile.in"

# compile
    TARGET=""
    ARCHARGs=""
    MACSDKDIR=""
    CC=""
    CXX=""
    
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=$x64CC
	CXX=$x64CXX
    
    # Patch configure to eliminate the -Wno-long-double
    mv "configure" "configure-bk"
    sed 's/-Wno-long-double//g' "configure-bk" > "configure"
    chmod +x configure
    
    env \
	CC="$CC" CXX="$CXX" \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include -isysroot $MACSDKDIR" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
	NEXT_ROOT="$MACSDKDIR" \
	PKG_CONFIG_PATH="$REPOSITORYDIR/lib/pkgconfig" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" \
	--enable-shared --enable-static || fail "configure step for $ARCH";
    
    [ -f "libtool-bk" ] || mv "libtool" "libtool-bk"; # just move it once, fix it many times
    sed -e "s#-dynamiclib#-dynamiclib -arch $ARCH -isysroot $MACSDKDIR#g" "libtool-bk" > "libtool";
    chmod +x libtool;
    
    [ -f $REPOSITORYDIR/$crt1obj ] && rm  $REPOSITORYDIR/$crt1obj;
    make clean;
    make $OTHERMAKEARGs all || fail "failed at make step of $ARCH";
    make install || fail "make install step of $ARCH";
    

# clean
make distclean 1> /dev/null

notify openexr