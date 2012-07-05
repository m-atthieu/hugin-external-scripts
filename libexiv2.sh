# ------------------
#     libexiv2
# ------------------
# $Id: $
# Copyright (c) 2008, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script NOT tested but uses std boilerplate
# 20100111.0 sg Script tested for building dylib
# 20100121.0 sg Script updated for 0.19
# 20100624.0 hvdw More robust error checking on compilation
# 20111102.0 mde bump to version 0.22
# -------------------------------

# init

fail()
{
    echo "** Failed at $1 **"
    exit 1
}

case "$(basename $(pwd))" in
    "exiv2-0.19")
	EXIV2VER_M="6"
	EXIV2VER_FULL="$EXIV2VER_M.3.1"
	;;
    "exiv2-0.22")
	EXIV2VER_M="11"
	EXIV2VER_FULL="$EXIV2VER_M.3.1"
	;;
    *)
	fail "Unknown version"
esac


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
	LDFLAGS="-L$REPOSITORYDIR/lib -arch $ARCH -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
	NEXT_ROOT="$MACSDKDIR" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH \
	--enable-shared --with-libiconv-prefix=$REPOSITORYDIR --with-libintl-prefix=$REPOSITORYDIR \
	--enable-static  || fail "configure step for $ARCH";
    
    [ -f "libtool-bk" ] && rm libtool-bk; 
    mv "libtool" "libtool-bk"; 
    sed -e "s#-dynamiclib#-shared-libgcc -dynamiclib -arch $ARCH -isysroot $MACSDKDIR#g" \
	-e 's/-all_load//g' "libtool-bk" > "libtool";
    chmod +x libtool
    
    make clean;
    cd xmpsdk/src;
    make xmpsdk
    
    cd ../../src;    
    make $OTHERMAKEARGs || fail "failed at make step of $ARCH";
    make install || fail "make install step of $ARCH";
    cd ../;
done

# merge libexiv2
merge_libraries lib/libexiv2.a "lib/libexiv2.$EXIV2VER_M.dylib"
change_library_id "libexiv2.$EXIV2VER_M.dylib" libexiv2.dylib

# merge execs
merge_execs bin/exiv2

# Last step for exiv2. exiv2 is linked during build against it's own libexiv2.dylib and therefore has an install_name
# based on the arch/$ARCH directory. We need to change that. Unfortunately we need to do it for every arch even 
# though it is only mentioned once for one of the arc/$ARCHs.
for ARCH in $ARCHS
do
    install_name_tool -change $REPOSITORYDIR/arch/$ARCH/lib/libexiv2.$EXIV2VER_M.dylib $REPOSITORYDIR/lib/libexiv2.$EXIV2VER_M.dylib $REPOSITORYDIR/bin/exiv2
done

#pkgconfig
for ARCH in $ARCHS
do
    mkdir -p $REPOSITORYDIR/lib/pkgconfig
    sed 's/^exec_prefix.*$/exec_prefix=\$\{prefix\}/' $REPOSITORYDIR/arch/$ARCH/lib/pkgconfig/exiv2.pc > $REPOSITORYDIR/lib/pkgconfig/exiv2.pc
    break;
done

