# ------------------
#     libtiff
# ------------------
# $Id: libtiff.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100121.0 sg Script updated for 3.9.2
# 20100624.0 hvdw More robust error checking on compilation
# -------------------------------

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

case "$(basename $(pwd))" in 
    "tiff-3.9.5" | "tiff-3.9.7")
	TIFF_VER="3"
	;;
    "tiff-4.0.3")
	TIFF_VER="5"
	;;
    *)
	fail "Unknown version"
esac

# init
mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile
    ARCHARGs=""
    MACSDKDIR=""
    
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=$x64CC
	CXX=$x64CXX
        
    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include -isysroot $MACSDKDIR" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
	NEXT_ROOT="$MACSDKDIR" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" \
	--enable-static --enable-shared --with-apple-opengl-framework --without-x \
	|| fail "configure step for $ARCH" ;
    
    make clean;
    cd ./port; make $OTHERMAKEARGs || fail "failed at make step of $ARCH";
    cd ../libtiff; make $OTHERMAKEARGs install || fail "make libtiff install step of $ARCH";
    cd ../tools; make $OTHERMAKEARGs install || fail "make tools install step of $ARCH";
    cd ../;
    
    rm $REPOSITORYDIR/include/tiffconf.h;
    cp "./libtiff/tiffconf.h" "$REPOSITORYDIR/include/tiffconf.h";

# clean
#make distclean 1> /dev/null

notify tiff