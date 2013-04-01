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

let NUMARCH="0"

for i in $ARCHS
do
    NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/bin";
mkdir -p "$REPOSITORYDIR/lib";
mkdir -p "$REPOSITORYDIR/include";


c++ "./Half/eLut.cpp" -o "./Half/eLut-native"
c++ "./Half/toFloat.cpp" -o "./Half/toFloat-native"

[ -f "./Half/Makefile.in-original" ] || mv "./Half/Makefile.in" "./Half/Makefile.in-original"
sed -e 's/\.\/eLut/\.\/eLut-native/' \
    -e 's/\.\/toFloat/\.\/toFloat-native/' \
    "./Half/Makefile.in-original" > "./Half/Makefile.in"

# compile

case "$(basename $(pwd))" in 
    "ilmbase-1.0.2")
	ILMVER_M="6"
	ILMVER_FULL="$ILMVER_M.0.0"
	;;
    "ilmbase-1.0.3")
	ILMVER_M="7"
	ILMVER_FULL="$ILMVER_M.0.0"
	;;
    *)
	fail "Unknown version"
esac

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

    rm -f libtool libtool-bk
    
    env \
	CC=$CC CXX=$CXX \
	CFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CXXFLAGS="-isysroot $MACSDKDIR -arch $ARCH $ARCHARGs $OTHERARGs -O3 -dead_strip" \
	CPPFLAGS="-I$REPOSITORYDIR/include" \
	LDFLAGS="-L$REPOSITORYDIR/lib -mmacosx-version-min=$OSVERSION -dead_strip" \
	NEXT_ROOT="$MACSDKDIR" \
	PKG_CONFIG_PATH="$REPOSITORYDIR/lib/pkgconfig" \
	./configure --prefix="$REPOSITORYDIR" --disable-dependency-tracking \
	--host="$TARGET" --exec-prefix=$REPOSITORYDIR/arch/$ARCH \
	--enable-shared --enable-static --cache-file=./$ARCHcache \
	|| fail "configure step for $ARCH";
    
    [ -f "libtool-bk" ] || mv "libtool" "libtool-bk"; # just move it once, fix it many times
    sed -e "s#-dynamiclib#-dynamiclib -arch $ARCH -isysroot $MACSDKDIR#g" libtool-bk > libtool;
    chmod +x libtool
    
    #hack for apple-gcc 4.2
	gcc_version=$(gcc --version |grep "(GCC)" |cut -d ' ' -f 3|cut -d '.' -f 1,2)
    if [ "$gcc_version" = "4.2" ] ; then
	for dir in Half Iex IlmThread Imath
	do
	    mv $dir/Makefile $dir/Makefile.bk
	    sed 's/-Wno-long-double//g' $dir/Makefile.bk > $dir/Makefile
	done
    fi
    
    make clean;
    make $OTHERMAKEARGs all || fail "failed at make step of $ARCH";
    make install || fail "make install step of $ARCH";
done

# merge
LIBNAMES="IlmThread Imath Iex IexMath Half"

merge_libraries $(for libname in $LIBNAMES; do echo "lib/lib$libname.a lib/lib$libname.$ILMVER_M.dylib "; done)

for libname in $LIBNAMES
do
    if [ -f "$REPOSITORYDIR/lib/lib$libname.$ILMVER_M.dylib" ]
    then
	install_name_tool -id "$REPOSITORYDIR/lib/lib$libname.$ILMVER_M.dylib" "$REPOSITORYDIR/lib/lib$libname.$ILMVER_M.dylib";
  
	for ARCH in $ARCHS
	do
	    for libname_two in $LIBNAMES
	    do
		install_name_tool \
		    -change "$REPOSITORYDIR/arch/$ARCH/lib/lib$libname_two.$ILMVER_M.dylib" \
		    "$REPOSITORYDIR/lib/lib$libname_two.$ILMVER_M.dylib" \
		    "$REPOSITORYDIR/lib/lib$libname.$ILMVER_M.dylib";
	    done
	done
	
	ln -sfn "lib$libname.$ILMVER_M.dylib" "$REPOSITORYDIR/lib/lib$libname.$ILMVER_FULL.dylib";
	ln -sfn "lib$libname.$ILMVER_M.dylib" "$REPOSITORYDIR/lib/lib$libname.dylib";
    fi
done


#pkgconfig
for ARCH in $ARCHS
do
    mkdir -p "$REPOSITORYDIR/lib/pkgconfig";
    sed 's/^exec_prefix.*$/exec_prefix=\$\{prefix\}/' "$REPOSITORYDIR/arch/$ARCH/lib/pkgconfig/IlmBase.pc" > "$REPOSITORYDIR/lib/pkgconfig/IlmBase.pc";
    break;
done

# clean
make distclean 1> /dev/null
