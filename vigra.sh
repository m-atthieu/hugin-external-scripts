# ------------------
#     vigra
# ------------------
# $Id: pano13.sh 1904 2007-02-05 00:10:54Z ippei $
# Copyright (c) 2007, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv
  
# init
fail()
{
        echo "** Failed at $1 **"
        exit 1
}

case "$(basename $(pwd))" in
    'vigra-1.8.0')
	VIGRA_M='4'
	VIGRA_FULL='180'
	;;
    'vigra-1.9.0')
	VIGRA_M='4'
	VIGRA_FULL='190'
	;;
    *)
	fail "Unknown version"
	;;
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

    if [ $ARCH = "i386" -o $ARCH = "i686" ]
    then
	TARGET=$i386TARGET
	MACSDKDIR=$i386MACSDKDIR
	ARCHARGs="$i386ONLYARG"
	OSVERSION=$i386OSVERSION
	OPTIMIZE=$i386OPTIMIZE
	CC=$i386CC_MP
	CXX=$i386CXX_MP
	MARCH='-m32'
    elif [ $ARCH = "x86_64" ]; then
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION=$x64OSVERSION
	OPTIMIZE=$x64OPTIMIZE
	CC=$x64CC_MP
	CXX=$x64CXX_MP
	MARCH='-m64'
    fi
    
    mkdir -p build-$ARCH;
    cd build-$ARCH;
    rm -f CMakeCache.txt;

    cmake \
	-DCMAKE_VERBOSE_MAKEFILE:BOOL="ON" \
	-DCMAKE_INSTALL_PREFIX:PATH="$REPOSITORYDIR/arch/$ARCH" \
	-DCMAKE_BUILD_TYPE:STRING="Release" \
	-DCMAKE_C_FLAGS_RELEASE:STRING="$MARCH -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE" \
	-DCMAKE_CXX_FLAGS_RELEASE:STRING="$MARCH -mmacosx-version-min=$OSVERSION -isysroot $MACSDKDIR -DNDEBUG -O3 $OPTIMIZE" \
	-DJPEG_INCLUDE_DIR="$REPOSITORYDIR/include" \
	-DJPEG_LIBRARIES="$REPOSITORYDIR/lib/libjpeg.dylib" \
	-DPNG_INCLUDE_DIR="$REPOSITORYDIR/include" \
	-DPNG_LIBRARIES="$REPOSITORYDIR/lib/libpng.dylib" \
	-DTIFF_INCLUDE_DIR="$REPOSITORYDIR/include" \
	-DTIFF_LIBRARIES="$REPOSITORYDIR/lib/libtiff.dylib" \
	-DWITH_OPENEXR:BOOL="ON" \
	-DBoost_INCLUDE_DIR="$REPOSITORYDIR/include" \
	-DZLIB_INCLUDE_DIR="/usr/include" \
	-DZLIB_LIBRARIES="/usr/lib/libz.dylib" \
	.. || fail "configuring for $ARCH"
    
    make || fail "building for $ARCH"
    make install;
    
    cd ..
done

# merge libraries
merge_libraries "lib/libvigraimpex.$VIGRA_M.$VIGRA_FULL.dylib"
if [ -f "$REPOSITORYDIR/lib/libvigraimpex.$VIGRA_M.$VIGRA_FULL.dylib" ]; then
    install_name_tool -id "$REPOSITORYDIR/lib/libvigraimpex.$VIGRA_M.$VIGRA_FULL.dylib" "$REPOSITORYDIR/lib/libvigraimpex.$VIGRA_M.$VIGRA_FULL.dylib"
    ln -sfn libvigraimpex.$VIGRA_M.$VIGRA_FULL.dylib $REPOSITORYDIR/lib/libvigraimpex.$VIGRA_M.dylib
    ln -sfn libvigraimpex.$VIGRA_M.$VIGRA_FULL.dylib $REPOSITORYDIR/lib/libvigraimpex.dylib
fi

# copy includes
echo "copying includes"
rm -rf $REPOSITORYDIR/include/vigra-private
if [ $NUMARCH -eq 1 ] ; then
	cp -a $REPOSITORYDIR/arch/$ARCHS/include/vigra $REPOSITORYDIR/include/vigra-private
else
	cp -a $REPOSITORYDIR/arch/x86_64/include/vigra $REPOSITORYDIR/include/vigra-private
fi

# merge vigra-config
echo "merging vigra-config"
sed 's,/arch/x86_64,,g' < $REPOSITORYDIR/arch/x86_64/bin/vigra-config > $REPOSITORYDIR/bin/vigra-config
chmod +x $REPOSITORYDIR/bin/vigra-config

# clean
clean_build_directories

notify vigra