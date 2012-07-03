# ------------------
#     libglew
# ------------------
# $Id: libglew.sh 1908 2007-02-05 14:59:45Z ippei $
# Copyright (c) 2007, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100110.0 sg Script enhanced to copy dynamic lib also
# 20100624.0 hvdw More robust error checking on compilation
# -------------------------------

GLEW_MAJOR=1
GLEW_MINOR=7
GLEW_REV=0

fail()
{
    echo "** Failed at $1 **"
    exit 1
}


# init
uname_release=$(uname -r)
uname_arch=$(uname -p)
[ $uname_arch = powerpc ] && uname_arch="ppc"
os_dotvsn=${uname_release%%.*}
os_dotvsn=$(($os_dotvsn - 4))
case $os_dotvsn in
    4 ) os_sdkvsn="10.4u" ;;
    5|6|7 ) os_sdkvsn=10.$os_dotvsn ;;
    * ) echo "Unhandled OS Version: 10.$os_dotvsn. Build aborted."; exit 1 ;;
esac

NATIVE_SDKDIR="$(xcode-select -print-path)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX$os_sdkvsn.sdk"
NATIVE_OSVERSION="10.$os_dotvsn"
NATIVE_ARCH=$uname_arch
NATIVE_OPTIMIZE=""

# update config.guess and config.sub -- locations vary by OS version
case $NATIVE_OSVERSION in
    10.4 )
	;;
    10.5 )
	cp -f /usr/share/libtool/config.{guess,sub} ./config/ 
	;;
    10.6 | 10.7 )
	cp -f /usr/share/libtool/config/config.{guess,sub} ./config/ 
	;;
    * )
	echo "Unknown OS version; Add code to support $NATIVE_OSVERSION"; 
	exit 1 
	;;
esac

# patch 1.7 for gcc 4.6
cp config/Makefile.darwin config/Makefile.darwin.org
cp config/Makefile.darwin-x86_64 config/Makefile.darwin-x86_64.org
sed 's/-no-cpp-precomp//' config/Makefile.darwin.org > config/Makefile.darwin
sed 's/-no-cpp-precomp//' config/Makefile.darwin-x86_64.org > config/Makefile.darwin-x86_64

let NUMARCH="0"
for i in $ARCHS
do
    NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";


# compile
for ARCH in $ARCHS
do
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";
    
    ARCHARGs=""
    MACSDKDIR=""
    
    if [ $ARCH = "i386" -o $ARCH = "i686" ] ; then
	TARGET=$i386TARGET
	MACSDKDIR=$i386MACSDKDIR
	ARCHARGs="$i386ONLYARG"
	CC=$i386CC
	CXX=$i386CXX
    elif [ $ARCH = "x86_64" ] ; then
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	CC=$x64CC
	CXX=$x64CXX
    fi
    
    make clean;
    make install \
	GLEW_DEST="$REPOSITORYDIR/arch/$ARCH" \
	CC="$CC -isysroot $MACSDKDIR -arch $ARCH $ARCHARGs -O3 -dead_strip" \
	LD="$CC -isysroot $MACSDKDIR -arch $ARCH $ARCHARGs -O3" \
	|| fail "failed at make step of $ARCH";
done

# merge libs
merge_libraries "lib/libGLEW.a" "lib/libGLEW.$GLEW_MAJOR.$GLEW_MINOR.$GLEW_REV.dylib"
change_library_id "libGLEW.$GLEW_MAJOR.$GLEW_MINOR.$GLEW_REV.dylib" "libGLEW.$GLEW_MAJOR.$GLEW_MINOR.dylib" "libGLEW.dylib"

# install includes
cp -R include/GL $REPOSITORYDIR/include/;
