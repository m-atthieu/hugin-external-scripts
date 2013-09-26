# ------------------
#     libiconv
# ------------------
# $Id: libiconv.sh 1902 2008-01-02 22:27:47Z Harry $
# Copyright (c) 2007, Ippei Ukai
# script skeleton Copyright (c) 2007, Ippei Ukai
# iconv specifics 2010, Harry van der Wolf

# -------------------------------
# 20100117.0 HvdW Script tested
# 20100624.0 hvdw More robust error checking on compilation
# -------------------------------

# init
source ../scripts/functions.sh
check_SetEnv

fail()
{
    echo "** Failed at $1 **"
    exit 1
}

let NUMARCH="0"

for i in $ARCHS
do
    NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

ICONVVER="2"
CHARSETVER="1"

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
    
    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
	NEXT_ROOT="$MACSDKDIR" \
	../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH \
	--disable-nls --enable-extra-encodings \
	--without-libiconv-prefix --without-libintl-prefix \
	--enable-static --enable-shared  || fail "configure step of $ARCH";
    
    make clean
    make || fail "failed at make step of $ARCH"
    make $OTHERMAKEARGs install || fail "make install step of $ARCH"
    cd ..
done

# merge libiconv
merge_libraries lib/libiconv.a "lib/libiconv.$ICONVVER.dylib" "lib/libcharset.a" "lib/libcharset.$CHARSETVER.dylib"

change_library_id libiconv.$ICONVVER.dylib libiconv.dylib
change_library_id libcharset.$CHARSETVER.dylib libcharset.dylib

# merge execs
merge_execs "bin/iconv"

# clean
clean_build_directories

notify libiconv