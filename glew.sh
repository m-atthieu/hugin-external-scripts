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


fail()
{
    echo "** Failed at $1 **"
    exit 1
}

case "$(basename $(pwd))" in
    "glew-1.9.0")
	GLEW_MAJOR=1
	GLEW_MINOR=9
	GLEW_REV=0
	;;
    *)
	fail "Unknown version"
	;;
esac

# init

# patch 1.7 for gcc 4.6
cp config/Makefile.darwin config/Makefile.darwin.org
cp config/Makefile.darwin-x86_64 config/Makefile.darwin-x86_64.org
sed 's/-no-cpp-precomp//' config/Makefile.darwin.org > config/Makefile.darwin
sed 's/-no-cpp-precomp//' config/Makefile.darwin-x86_64.org > config/Makefile.darwin-x86_64

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";


# compile
ARCHARGs=""
MACSDKDIR=""

TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
CC=$x64CC
CXX=$x64CXX

make clean;
make install \
    GLEW_DEST="$REPOSITORYDIR" \
    CC="$CC -isysroot $MACSDKDIR -arch $ARCH $ARCHARGs -O3 -dead_strip" \
    LD="$CC -isysroot $MACSDKDIR -arch $ARCH $ARCHARGs -O3" \
    || fail "failed at make step of $ARCH";

# clean
make distclean 1> /dev/null

notify glew