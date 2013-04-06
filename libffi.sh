# ------------------
#     libffi
# ------------------
# $Id: libffi.sh 1902 2008-01-02 22:27:47Z Harry $
# Copyright (c) 2007, Ippei Ukai
# script skeleton Copyright (c) 2007, Ippei Ukai
# libffi specifics 2012, Harry van der Wolf


# prepare

# export REPOSITORYDIR="/PATH2HUGIN/mac/ExternalPrograms/repository" \
# ARCHS="ppc i386" \
#  ppcTARGET="powerpc-apple-darwin8" \
#  i386TARGET="i386-apple-darwin8" \
#  ppcMACSDKDIR="/Developer/SDKs/MacOSX10.4u.sdk" \
#  i386MACSDKDIR="/Developer/SDKs/MacOSX10.3.9.sdk" \
#  ppcONLYARG="-mcpu=G3 -mtune=G4" \
#  i386ONLYARG="-mfpmath=sse -msse2 -mtune=pentium-m -ftree-vectorize" \
#  OTHERARGs="";

# -------------------------------
# 20120411.0 HvdW Script tested
# -------------------------------

# init

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

# libffi-3.0.11
VERSION="6"

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

    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fstrict-aliasing" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip -fstrict-aliasing" \
	CPPFLAGS="-I$REPOSITORYDIR/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip -lresolv -bind_at_load" \
	NEXT_ROOT="$MACSDKDIR" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH \
	--enable-static --enable-shared  || fail "configure step of $ARCH";
    echo "## make ##"
    make clean
    make || fail "failed at make step of $ARCH"
    make $OTHERMAKEARGs install || fail "make install step of $ARCH"
done

# merge libffi
for liba in lib/libffi.a lib/libffi.$VERSION.dylib 
do
    
    if [ $NUMARCH -eq 1 ] ; then
	if [ -f $REPOSITORYDIR/arch/$ARCHS/$liba ] ; then
		 echo "Moving arch/$ARCHS/$liba to $liba"
  	 mv "$REPOSITORYDIR/arch/$ARCHS/$liba" "$REPOSITORYDIR/$liba";
	   #Power programming: if filename ends in "a" then ...
	   [ ${liba##*.} = a ] && ranlib "$REPOSITORYDIR/$liba";
  	 continue
	 else
		 echo "Program arch/$ARCHS/$liba not found. Aborting build";
		 exit 1;
	 fi
 fi

 LIPOARGs=""
 
 for ARCH in $ARCHS
 do
	if [ -f $REPOSITORYDIR/arch/$ARCH/$liba ] ; then
		echo "Adding arch/$ARCH/$liba to bundle"
		LIPOARGs="$LIPOARGs $REPOSITORYDIR/arch/$ARCH/$liba"
	else
		echo "File arch/$ARCH/$liba was not found. Aborting build";
		exit 1;
	fi
 done

 lipo $LIPOARGs -create -output "$REPOSITORYDIR/$liba";
 #Power programming: if filename ends in "a" then ...
 [ ${liba##*.} = a ] && ranlib "$REPOSITORYDIR/$liba";

done

if [ -f "$REPOSITORYDIR/lib/libffi.$VERSION.dylib" ] ; then
 install_name_tool -id "$REPOSITORYDIR/lib/libffi.$VERSION.dylib" "$REPOSITORYDIR/lib/libffi.$VERSION.dylib"
 ln -sfn libffi.$VERSION.dylib $REPOSITORYDIR/lib/libffi.dylib;
fi

# include
for ARCH in $ARCHS; do
	cp -a $REPOSITORYDIR/arch/$ARCH/lib/libffi-3.0.13 $REPOSITORYDIR/lib
done

# pkg-config
echo "pkg-config"
for ARCH in $ARCHS
do
    mkdir -p $REPOSITORYDIR/lib/pkgconfig
    sed 's/^exec_prefix.*$/exec_prefix=\$\{prefix\}/' $REPOSITORYDIR/arch/$ARCH/lib/pkgconfig/libffi.pc > $REPOSITORYDIR/lib/pkgconfig/libffi.pc
    break;
done
