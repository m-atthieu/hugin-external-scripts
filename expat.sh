# ------------------
#     libexpat
# ------------------
# $Id: $
# Copyright (c) 2008, Ippei Ukai


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


uname_release=$(uname -r)
uname_arch=$(uname -p)
[ $uname_arch = powerpc ] && uname_arch="ppc"
os_dotvsn=${uname_release%%.*}
os_dotvsn=$(($os_dotvsn - 4))
case $os_dotvsn in
    4 ) os_sdkvsn="10.4u" ;;
    5|6|7|8 ) os_sdkvsn=10.$os_dotvsn ;;
    * ) echo "Unhandled OS Version: 10.$os_dotvsn . Build aborted."; exit 1 ;;
esac

NATIVE_SDKDIR="$(xcode-select -print-path)"/SDKs/MacOSX"$os_sdkvsn".sdk
if [ $os_dotvsn -eq 7 -o $os_dotvsn -eq 8 ]; then
	NATIVE_OSVERSION="10.6"
else
	NATIVE_OSVERSION="10.$os_dotvsn"
fi
NATIVE_ARCH=$uname_arch
NATIVE_OPTIMIZE=""

# init

let NUMARCH="0"

for i in $ARCHS
do
    NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# Generated library claims to be 1.5.2 for the 2.0.1 sources 
EXPATVER_M="1"
EXPATVER_FULL="$EXPATVER_M.5.2"

# compile

for ARCH in $ARCHS
do
    
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
    mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";

    mkdir build-$ARCH
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
    
 # Configure is looking for a specific version of crt1.o based on what the compiler was built for
 # This library isn't in the search path, so copy it to lib
    case $NATIVE_OSVERSION in
	 10.4 )
   	    crt1obj="lib/crt1.o"
	    ;;
	10.5 | 10.6 | 10.7 | 10.8 )
	    crt1obj="lib/crt1.$NATIVE_OSVERSION.o"
	    ;;
	* )
	    echo "Unsupported OS Version: $NATIVE_OSVERSION";
	    exit 1;
	    ;;
    esac
    
    [ -f $REPOSITORYDIR/$crt1obj ] || cp $NATIVE_SDK/usr/$crt1obj $REPOSITORYDIR/$crt1obj ;
    # File exists for 10.5 and 10.6. 10.4 is now fixed
    [ -f $REPOSITORYDIR/$crt1obj ] || exit 1 ;
    
    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
	NEXT_ROOT="$MACSDKDIR" \
	../configure --prefix="$REPOSITORYDIR"  \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH \
	--enable-shared || fail "configure step for $ARCH";
    
    [ -f $REPOSITORYDIR/$crt1obj ] && rm  $REPOSITORYDIR/$crt1obj;
    make clean;
    make $OTHERMAKEARGs buildlib || fail "failed at make step of $ARCH";
    make installlib || fail "failed at make install step of $ARCH";
    cd ..
done

# merge libexpat
merge_libraries lib/libexpat.a lib/libexpat.$EXPATVER_M.dylib

if [ -f "$REPOSITORYDIR/lib/libexpat.$EXPATVER_M.dylib" ] ; then
    install_name_tool -id "$REPOSITORYDIR/lib/libexpat.$EXPATVER_M.dylib" "$REPOSITORYDIR/lib/libexpat.$EXPATVER_M.dylib"
    # 2.1.0 is straight libexpat.1.dylib
    #ln -sfn libexpat.$EXPATVER_FULL.dylib $REPOSITORYDIR/lib/libexpat.$EXPATVER_M.dylib;
    ln -sfn libexpat.$EXPATVER_M.dylib $REPOSITORYDIR/lib/libexpat.dylib;
fi

notify expat

# clean
rm -rf build-{i386,x86_64}

notify expat