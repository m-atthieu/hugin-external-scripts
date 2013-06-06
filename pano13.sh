# ------------------
#     pano13
# ------------------
# $Id: pano13.sh 1904 2007-02-05 00:10:54Z ippei $
# Copyright (c) 2007, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100113.0 sg Script adjusted for libpano13-2.9.15
# 20100117.0 sg Move code for detecting which version of pano13 to top for visibility
# 20100119.0 sg Support the SVN version of panotools - 2.9.16
# 201004xx.0 hvdw support 2.9.17
# 20100624.0 hvdw More robust error checking on compilation
# 20110107.0 hvdw support for 2.9.18
# 20110427.0 hvdw compile x86_64 with gcc 4.6 for openmp compatibility on lion and up
# 20121010.0 hvdw remove openmp stuff to make it easier to build
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

# init
check_numarchs

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# for 10.6 compatibility, libpano needs to be built against 10.6 sdk
SDK_BASE_PATH=$(xcode-select -print-path)/Platforms/MacOSX.platform
MACSDKDIR106="$SDK_BASE_PATH/Developer/SDKs/MacOSX10.6.sdk"

# compile
ARCH=$ARCHS
mkdir -p "$REPOSITORYDIR/arch/$ARCH/bin";
mkdir -p "$REPOSITORYDIR/arch/$ARCH/lib";
mkdir -p "$REPOSITORYDIR/arch/$ARCH/include";

ARCHARGs=""
MACSDKDIR=""
    
TARGET=$x64TARGET
MACSDKDIR=$MACSDKDIR106 #$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX
ARCHFLAG="-m64"

mkdir -p build-$ARCH
cd build-$ARCH

env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O2 -dead_strip $ARCGFLAG" \
    CXXFLAGS="-isysroot $MACSDKDIR $ARCHFLAG $ARCHARGs $OTHERARGs -O2 -dead_strip $ARCGFLAG" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -prebind $ARCGFLAG" \
    NEXT_ROOT="$MACSDKDIR" \
    PKGCONFIG="$REPOSITORYDIR/lib" \
    ../configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" \
    --without-java \
    --with-zlib=/usr \
    --with-png=$REPOSITORYDIR \
    --with-jpeg=$REPOSITORYDIR \
    --with-tiff=$REPOSITORYDIR \
    --enable-shared --disable-static || fail "configure step for $ARCH";

    #Stupid libtool... (perhaps could be done by passing LDFLAGS to make and install)
#[ -f libtool-bk ] && rm libtool-bak
#mv "libtool" "libtool-bk"; # could be created each time we run configure
#sed -e "s#-dynamiclib#-dynamiclib $ARCHFLAG -isysroot $MACSDKDIR#g" "libtool-bk" > "libtool";
#chmod +x libtool

make clean;
make || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

# clean
make distclean
