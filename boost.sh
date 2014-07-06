# ------------------
#      boost
# ------------------
# $Id: boost.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007-2008, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

case "$(basename $(pwd))" in
    "boost_1_46_0"|"boost_1_46_1")
	BOOST_VER="1_46"
	;;
    "boost_1_54_0")
	BOOST_VER="1_54"
	;;
    "boost_1_55_0")
	BOOST_VER="1_55"
	;;
    *)
	echo "Unknown boost version. Aborting"
	exit 1
esac

# Uncomment correct version

echo "\n## Version set to $BOOST_VER ##\n"

# install headers
echo "## First compiling bjam ##\n"
case "$BOOST_VER" in
    1_46)
	perl -p -i -e 's/-no-cpp-precomp//' tools/build/v2/tools/darwin.jam
	 cd "./tools/build/v2/engine/src"
	 sh "build.sh"
	 cd "../../../../../"
	 BJAM=$(ls ./tools/build/v2/engine/src/bin.mac*/bjam)
	 echo $BJAM
	 ;;
    1_47|1_48|1_49|1_50|1_51|1_53|1_54|1_55)
	perl -p -i -e 's/-no-cpp-precomp//' tools/build/v2/tools/darwin.jam
	 cd "./tools/build/v2/engine"
	 sh "build.sh"
	 cd "../../../../"
	 BJAM=$(ls ./tools/build/v2/engine/bin.mac*/bjam)
	 ;;
    *)
	echo "Unknown version, cannot compile bjam"
	exit 1
esac
echo "BJAM command is: $BJAM"
echo "## Done compiling bjam ##"

# init

if [ "$BOOST_VER" = "1_55" ]; then
	patch -F 0 -Np1 < ../scripts/patches/boost-1.55-storage.patch
fi

mkdir -p "$REPOSITORYDIR/lib";

# compile boost_thread, filesystem, system, regex, iostreams, date_time and signals
ARCH=$ARCHS

    echo "\n## Now building architecture $ARCH ##\n"
    rm -rf "bin.v2";
    
	MACSDKDIR=$x64MACSDKDIR
	OSVERSION=$x64OSVERSION
	OPTIMIZE=$x64OPTIMIZE
	boostARCHITECTURE="x86"
	boostADDRESSMODEL="64"
	export CC=$x64CC;
	export CXX=$x64CXX;
	export ARCHTARGET=$x86_64TARGET;
	ARCHFLAG="-m64"
    
    # env $myPATH
    
    SDKVRSION=$(echo $MACSDKDIR | sed 's/^[^1]*\([[:digit:]]*\.[[:digit:]]*\).*/\1/')
    
    echo "CXX should now be known: $CXX"
    if [ "$CXX" = "" -o "$CXX" = "g++" ] ; then
	#boostTOOLSET="--toolset=darwin"
	CXX="g++"
	echo "using darwin : : $(which $CXX) : <cxxflags>\"-isysroot $MACSDKDIR -mmacosx-version-min=$OSVERSION --stdlib=libstdc++ $OPTIMIZE\" <linkflags>\"--stdlib=libstdc++\" ;" > ./$ARCH-userconf.jam
    elif [ "$CXX" = "g++-4.7" ]; then
	echo "using darwin : : $(which $CXX) : <cxxflags>\"-isysroot $MACSDKDIR -mmacosx-version-min=$OSVERSION $OPTIMIZE\" ;" > ./$ARCH-userconf.jam
    elif [ "$CXX" = "g++-4.6" ]; then
	echo "using darwin : : $(which $CXX) : <cxxflags>\"-isysroot $MACSDKDIR -mmacosx-version-min=$OSVERSION $OPTIMIZE\" ;" > ./$ARCH-userconf.jam
    elif [ "$CXX" = "llvm-g++-4.2" ]; then
	echo "using darwin : : $(which $CXX) : <cxxflags>\"-isysroot $MACSDKDIR -mmacosx-version-min=$OSVERSION $OPTIMIZE\" ;" > ./$ARCH-userconf.jam
    else
	echo "using darwin : : $(which $CXX) : <cxxflags>\"-isysroot $MACSDKDIR -mmacosx-version-min=$OSVERSION $OPTIMIZE\" ;" > ./$ARCH-userconf.jam
    fi
    boostTOOLSET="--user-config=./$ARCH-userconf.jam"
        
    
    # hack that sends extra arguments to g++
    $BJAM -a --prefix=$REPOSITORYDIR $boostTOOLSET \
	--with-thread --with-filesystem --with-system --with-regex --with-iostreams \
	--with-date_time --with-signals --with-test \
	variant=release \
	architecture="$boostARCHITECTURE" address-model="$boostADDRESSMODEL" install

# install_name's are not set correctly
for name in date_time filesystem iostreams regex signals system thread; do
    install_name_tool -id $REPOSITORYDIR/lib/libboost_$name.dylib \
	$REPOSITORYDIR/lib/libboost_$name.dylib
done
# thus, link are incorrectly set also
for name in filesystem thread; do
    install_name_tool -change \
	libboost_system.dylib \
	$REPOSITORYDIR/lib/libboost_system.dylib \
	$REPOSITORYDIR/lib/libboost_$name.dylib
done

# clean
rm -rf stage-x86_64
