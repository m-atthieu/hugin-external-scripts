# ------------------
#     libjpeg
# ------------------
# $Id: libjpeg-8.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100121.0 sg Script updated for version 8
# 20100624.0 hvdw More robust error checking on compilation
# -------------------------------



fail()
{
        echo "** Failed at $1 **"
        exit 1
}

case "$(basename $(pwd))" in
    'jpeg-8d')
	JPEGLIBVER="8"
	;;
    'jpeg-9')
	JPEGLIBVER="9"
	;;
    *)
	fail "Unknown version"
esac

# init

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

NATIVE_SDKDIR="$(xcode-select -print-path)/SDKs/MacOSX$os_sdkvsn.sdk"
NATIVE_OSVERSION="10.$os_dotvsn"
NATIVE_ARCH=$uname_arch
NATIVE_OPTIMIZE=""

let NUMARCH="0"

for i in $ARCHS
do
  NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";


# compile

# update config.guess and config.sub -- locations vary by OS version
case $NATIVE_OSVERSION in
    10.4 )
	;;
    10.5 )
	cp /usr/share/libtool/config.{guess,sub} ./ 
	;;
    10.6 | 10.7 | 10.8 )
	cp /usr/share/libtool/config/config.{guess,sub} ./ 
		;;
    * )
	echo "Unknown OS version; Add code to support $NATIVE_OSVERSION"; 
		exit 1 
		;;
esac

for ARCH in $ARCHS
do
    
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";

    mkdir -p build-$ARCH
    cd build-$ARCH
    
    ARCHARGs=""
    MACSDKDIR=""
    
    if [ $ARCH = "i386" -o $ARCH = "i686" ] ; then
	TARGET=$i386TARGET
	MACSDKDIR=$i386MACSDKDIR
	ARCHARGs="$i386ONLYARG"
	OSVERSION="$i386OSVERSION"
	CC=$i386CC
	CXX=$i386CXX
    elif [ $ARCH = "ppc" -o $ARCH = "ppc750" -o $ARCH = "ppc7400" ] ; then
	TARGET=$ppcTARGET
	MACSDKDIR=$ppcMACSDKDIR
	ARCHARGs="$ppcONLYARG"
	OSVERSION="$ppcOSVERSION"
	CC=$ppcCC
	CXX=$ppcCXX
    elif [ $ARCH = "ppc64" -o $ARCH = "ppc970" ] ; then
	TARGET=$ppc64TARGET
	MACSDKDIR=$ppc64MACSDKDIR
	ARCHARGs="$ppc64ONLYARG"
	OSVERSION="$ppc64OSVERSION"
	CC=$ppc64CC
	CXX=$ppc64CXX
    elif [ $ARCH = "x86_64" ] ; then
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=$x64CC
	CXX=$x64CXX
    fi
    
    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include -I/usr/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
	NEXT_ROOT="$MACSDKDIR" \
	../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH \
	--enable-shared --enable-static || fail "configure step for $ARCH";
    
    make clean;
    make || fail "failed at make step of $ARCH";
    make install || fail "make install step of $ARCH";
    cd ..
done

# merge libjpeg
merge_libraries "lib/libjpeg.a" "lib/libjpeg.$JPEGLIBVER.dylib"
change_library_id "libjpeg.$JPEGLIBVER.dylib" libjpeg.dylib

# clean
clean_build_directories