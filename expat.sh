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

# init
mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# Generated library claims to be 1.5.2 for the 2.0.1 sources 
EXPATVER_M="1"
EXPATVER_FULL="$EXPATVER_M.5.2"

# compile
mkdir build-$ARCH
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
	CPPFLAGS="-I$REPOSITORYDIR/include -isysroot $MACSDKDIR" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
	NEXT_ROOT="$MACSDKDIR" \
	../configure --prefix="$REPOSITORYDIR"  \
        --host="$TARGET"  \
        --enable-shared || fail "configure step for $ARCH";

make clean;
make $OTHERMAKEARGs buildlib || fail "failed at make step of $ARCH";
make installlib || fail "failed at make install step of $ARCH";
cd ..

# clean
rm -rf build-{i386,x86_64}

notify expat