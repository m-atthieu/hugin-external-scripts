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
mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile
    mkdir -p build-$ARCH
    cd build-$ARCH
    
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
	CPPFLAGS="-I$REPOSITORYDIR/include -I/usr/include -isysroot $MACSDKDIR" \
	LDFLAGS="-L$REPOSITORYDIR/lib -L/usr/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
	NEXT_ROOT="$MACSDKDIR" \
	../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" \
	--enable-shared --enable-static || fail "configure step for $ARCH";
    
    make clean;
    make || fail "failed at make step of $ARCH";
    make install || fail "make install step of $ARCH";
    cd ..

# clean
clean_build_directories

notify jpeg