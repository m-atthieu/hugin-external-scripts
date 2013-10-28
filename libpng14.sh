# ------------------
#     libpng
# ------------------
# $Id: libpng.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100121.0 sg Script updated for 1.2.40
# 201005xx.0 hvdw Adapted for 1.2.43
# 20100624.0 hvdw More robust error checking on compilation
# 20100831.0 hvdw upgrade to 1.2.44
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

#libraries created:
# libpng.3.1.2.42 <- (libpng.3, libpng)
# libpng12.12.1.2.42 <- (libpng12.12, libpng12)
# libpng12.a <- libpng.a
case "$(basename $(pwd))" in
    'libpng-1.4.11' | 'libpng-1.4.12')
	PNGVER_M="14"
	PNGVER_FULL="$PNGVER_M.14"
	;;
    'libpng-1.5.14')
	PNGVER_M="15"
	PNGVER_FULL="$PNGVER_M.1"
	;;
    *) 
	fail "Unknown version"
	;;
esac

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
ARCHFLAG="-m64"

    # makefile.darwin
    # includes hack for libpng bug #2009836
sed -e 's/-dynamiclib/-dynamiclib \$\(GCCLDFLAGS\)/g' \
    scripts/makefile.darwin > makefile;

make clean;
make $OTHERMAKEARGs install-static install-shared \
    prefix="$REPOSITORYDIR" \
    ZLIBLIB="$MACSDKDIR/usr/lib" \
    ZLIBINC="$MACSDKDIR/usr/include" \
    CC="$CC" CXX="$CXX" \
    CFLAGS="-isysroot $MACSDKDIR $ARCHFLAG -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    OBJCFLAGS="-arch $ARCH" \
    OBJCXXFLAGS="-arch $ARCH" \
    LDFLAGS="-L$REPOSITORYDIR/lib -L. -L$ZLIBLIB -lz -mmacosx-version-min=$OSVERSION" \
    NEXT_ROOT="$MACSDKDIR" \
    LIBPATH="$REPOSITORYDIR/lib" \
    BINPATH="$REPOSITORYDIR/bin" \
    GCCLDFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs" \
    || fail "failed at make step of $ARCH";

    # This libpng.dylib is installed as libpng15.15..dylib, so we have to rename them
    # I assume this will be corrected in 1.5.11 or so
mv -v $REPOSITORYDIR/lib/libpng$PNGVER_FULL..dylib \
    $REPOSITORYDIR/lib/libpng$PNGVER_FULL.dylib \
    || fail "failed moving $REPOSITORYDIR/lib/libpng$PNGVER_FULL..dylib"

ln -sf libpng$PNGVER_M.$PNGVER_M.dylib $REPOSITORYDIR/lib/libpng$PNGVER_M.dylib

notify libpng