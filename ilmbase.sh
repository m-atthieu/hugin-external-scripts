# ------------------
#     openexr
# ------------------
# $Id: openexr.sh 2004 2007-05-11 00:17:50Z ippei $
# Copyright (c) 2007, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100624.0 hvdw More robust error checking on compilation
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

check_numarchs

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";

# compile
ARCH=$ARCHS
    
ARCHARGs=""
MACSDKDIR=""

TARGET=$x64TARGET
MACSDKDIR=$x64MACSDKDIR
ARCHARGs="$x64ONLYARG"
OSVERSION="$x64OSVERSION"
CC=$x64CC
CXX=$x64CXX

# ilmbase does not support building in another directory
#mkdir -p build-$ARCH
#cd build-$ARCH

env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include" \
    LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
    NEXT_ROOT="$MACSDKDIR" \
    PKG_CONFIG_PATH="$REPOSITORYDIR/lib/pkgconfig" \
    ./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET" \
    --enable-shared \
    || fail "configure step for $ARCH";

#[ -f "libtool-bk" ] || mv "libtool" "libtool-bk"; # just move it once, fix it many times
#sed -e "s#-dynamiclib#-dynamiclib -arch $ARCH -isysroot $MACSDKDIR#g" libtool-bk > libtool;
#chmod +x libtool
    
    #hack for apple-gcc 4.2
#gcc_version=$(gcc --version |grep "(GCC)" |cut -d ' ' -f 3|cut -d '.' -f 1,2)
#if [ "$gcc_version" = "4.2" ] ; then
#    for dir in Half Iex IlmThread Imath
#    do
#	mv $dir/Makefile $dir/Makefile.bk
#	sed 's/-Wno-long-double//g' $dir/Makefile.bk > $dir/Makefile
#    done
#fi

make clean;
make $OTHERMAKEARGs all || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";

# clean
make distclean 1> /dev/null
