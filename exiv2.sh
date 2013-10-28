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
    "exiv2-0.23")
	EXIV2VER_M="12"
	EXIV2VER_FULL="$EXIV2VER_M.3.1"
	;;
    *)
	fail "Unknown version"
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

# still needs crt1.10.6.o
cp $MACSDKDIR/usr/lib/crt1.$OSVERSION.o $REPOSITORYDIR/lib

env \
    CC=$CC CXX=$CXX \
    CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
    CPPFLAGS="-I$REPOSITORYDIR/include -isysroot $MACSDKDIR" \
    LDFLAGS="-L${GCC_MP_LOCATION}/lib -L$REPOSITORYDIR/lib -arch $ARCH -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
    NEXT_ROOT="$MACSDKDIR" \
    ./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
    --host="$TARGET"  \
    --enable-shared --with-libiconv-prefix=$REPOSITORYDIR --with-libintl-prefix=$REPOSITORYDIR \
    || fail "configure step for $ARCH";

[ -f "libtool-bk" ] && rm libtool-bk; 
mv "libtool" "libtool-bk"; 
sed -e "s#-dynamiclib#-dynamiclib -arch $ARCH -isysroot $MACSDKDIR#g" \
    -e 's/-all_load//g' "libtool-bk" > "libtool";
chmod +x libtool

make clean;
cd xmpsdk/src;
make xmpsdk

cd ../../src;    
make $OTHERMAKEARGs || fail "failed at make step of $ARCH";
make install || fail "make install step of $ARCH";
cd ../;

[ -f $REPOSITORYDIR/crt1.$OSVERSION.o ] && rm $REPOSITORYDIR/lib/crt1.$OSVERSION.o

# clean
make distclean 1> /dev/null

notify exiv2