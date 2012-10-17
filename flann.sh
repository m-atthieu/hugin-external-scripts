# ------------------
#     libexiv2
# ------------------
# $Id: $
# Copyright (c) 2008, Ippei Ukai


# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20120709.0 mde initial script for version 1.7.1
# -------------------------------

# init

fail()
{
    echo "** Failed at $1 **"
    exit 1
}

case "$(basename $(pwd))" in
    "flann-1.7.1")
	FLANNVER_M="1.7"
	FLANNVER_FULL="$FLANNVER_M.1"
	;;
    "flann.git")
	FLANNVER_M="1.7"
	FLANNVER_FULL="$FLANNVER_M.1"
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
    elif [ $ARCH = "x86_64" ] ; then
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=$x64CC
	CXX=$x64CXX
    fi
    
    mkdir -p build-$ARCH
    cd build-$ARCH
    rm -f CMakeCache.txt

    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -arch $ARCH -mmacosx-version-min=$OSVERSION -dead_strip -prebind" \
	NEXT_ROOT="$MACSDKDIR" \
	cmake -DCMAKE_INSTALL_PREFIX:PATH="$REPOSITORYDIR/arch/$ARCH" \
	-DLATEX_OUTPUT_PATH:PATH="$REPOSITORYDIR/arch/$ARCH/share/doc" \
	-DCMAKE_BUILD_TYPE:STRING='Release' \
	-DBUILD_C_BINDINGS:BOOL="OFF" \
	-DBUILD_PYTHON_BINDINGS:BOOL="OFF" \
	-DBUILD-MATLAB_BINDINGS:BOOL="OFF" \
	-DBUILD_CUDA_LIB:BOOL="OFF" \
	-DUSE_MPI:BOOL="OFF" .. || fail "configure step for $ARCH";
    
    make clean;
    make || fail "build step for $ARCH"
    make install || fail "make install step of $ARCH";
    cd ..
done

# merge 
merge_libraries "lib/libflann_cpp.$FLANNVER_FULL.dylib" "lib/libflann_cpp-gd.dylib" 
if [ -f "$REPOSITORYDIR/lib/libflann_cpp.$FLANNVER_FULL.dylib" ]; then
    install_name_tool -id "$REPOSITORYDIR/lib/libflann_cpp.$FLANNVER_FULL.dylib" "$REPOSITORYDIR/lib/libflann_cpp.$FLANNVER_FULL.dylib"
    ln -sfn libflann_cpp.$FLANNVER_M.dylib "$REPOSITORYDIR/lib/libflann_cpp.$FLANNVER_FULL.dylib"
    ln -sfn libflann_cpp.dylib "$REPOSITORYDIR/lib/libflann_cpp.$FLANNVER_FULL.dylib"
fi

#includes
if [ $NUMARCH -eq 1 ] ; then
    cp -a $REPOSITORYDIR/arch/$ARCHS/include/flann $REPOSITORYDIR/include
else
    cp -a $REPOSITORYDIR/arch/x86_64/include/flann $REPOSITORYDIR/include
fi
