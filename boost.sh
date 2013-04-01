# ------------------
#      boost
# ------------------
# $Id: boost.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007-2008, Ippei Ukai

# prepare

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100121.0 sg Script updated for 1_41
# 20100121.1 sg Script reverted to 1_40
# 20100624.0 hvdw More robust error checking on compilation
# 20100831.0 hvdw Upgraded to 1_44
# 20100920.0 hvdw Add removed libboost_system again and add iostreams and regex
# 20100920.1 hvdw Add date_time as well
# 20111230.0 hvdw Adapt for versions >= 1.46. slightly different source tree structure
# 20111230.1 hvdw Correct stupid typo
# -------------------------------

fail()
{
        echo "** Failed at $1 **"
        exit 1
}

case "$(basename $(pwd))" in
    "boost_1_44_0")
	BOOST_VER="1_44"
	;;
    "boost_1_45_0")
	BOOST_VER="1_45"
	;;
    "boost_1_46_0"|"boost_1_46_1")
	BOOST_VER="1_46"
	;;
    "boost_1_47_0")
	BOOST_VER="1_47"
	;;
    "boost_1_48_0")
	BOOST_VER="1_48"
	;;
    "boost_1_49_0")
	BOOST_VER="1_49"
	;;
    "boost_1_50_0")
	BOOST_VER="1_50"
	;;
    "boost_1_51_0")
	BOOST_VER="1_51"
	;;
    "boost_1_53_0")
	BOOST_VER="1_53"
	;;
    *)
	echo "Unknown boost version. Aborting"
	exit 1
esac

# Uncomment correct version

echo "\n## Version set to $BOOST_VER ##\n"

# install headers

mkdir -p "$REPOSITORYDIR/include"
rm -rf "$REPOSITORYDIR/include/boost";
echo "\n## First copying all boost includes to $REPOSITORYDIR/include/ ##"
echo "## This will take some time ##\n"
cp -R "./boost" "$REPOSITORYDIR/include/";

echo "## First compiling bjam ##\n"
case "$BOOST_VER" in
    1_44|1_45)
	 cd "./tools/jam/src";
	 sh "build.sh";
	 cd "../../../";
	 BJAM=$(ls ./tools/jam/src/bin.mac*/bjam)
	 ;;
    1_46)
	perl -p -i -e 's/-no-cpp-precomp//' tools/build/v2/tools/darwin.jam
	 cd "./tools/build/v2/engine/src"
	 sh "build.sh"
	 cd "../../../../../"
	 BJAM=$(ls ./tools/build/v2/engine/src/bin.mac*/bjam)
	 echo $BJAM
	 ;;
    1_47|1_48|1_49|1_50|1_51|1_53)
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

ORGPATH=$PATH

let NUMARCH="0"

for i in $ARCHS
do
    NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/lib";


# compile boost_thread, filesystem, system, regex, iostreams, date_time and signals

for ARCH in $ARCHS
do
    echo "\n## Now building architecture $ARCH ##\n"
    rm -rf "stage-$ARCH";
    mkdir -p "stage-$ARCH";
    
    if [ $ARCH = "i386" -o $ARCH = "i686" ]; then
	MACSDKDIR=$i386MACSDKDIR
	OSVERSION=$i386OSVERSION
	OPTIMIZE=$i386OPTIMIZE
	boostARCHITECTURE="x86"
	boostADDRESSMODEL="32"
	export CC=$i386CC;
	export CXX=$i386CXX;
	export ARCHTARGET=$i386TARGET;
	myPATH=$ORGPATH
	ARCHFLAG="-m32"
    elif [ $ARCH = "x86_64" ]; then
	MACSDKDIR=$x64MACSDKDIR
	OSVERSION=$x64OSVERSION
	OPTIMIZE=$x64OPTIMIZE
	boostARCHITECTURE="x86"
	boostADDRESSMODEL="64"
	export CC=$x64CC;
	export CXX=$x64CXX;
	export ARCHTARGET=$x86_64TARGET;
	ARCHFLAG="-m64"
	#myPATH=/usr/local/bin:$PATH
    fi
    
    # env $myPATH
    
    SDKVRSION=$(echo $MACSDKDIR | sed 's/^[^1]*\([[:digit:]]*\.[[:digit:]]*\).*/\1/')
    
    echo "CXX should now be known: $CXX"
    if [ "$CXX" = "" ] ; then
	boostTOOLSET="--toolset=darwin"
	CXX="g++"
    else
	#macosx-version : -isysroot $(sdk)
	#macosx-version-min : -mmacosx-version-min=$(version)
	if [ "$CXX" = "g++-4.7" ]; then
	    echo "using darwin : : $(which $CXX) : <cxxflags> -isysroot $MACSDKDIR -mmacosx-version-min=$OSVERSION $OPTIMIZE ;" > ./$ARCH-userconf.jam
	elif [ "$CXX" = "g++-4.6" ]; then
	    echo "using darwin : : $(which $CXX) : <cxxflags> -isysroot $MACSDKDIR -mmacosx-version-min=$OSVERSION $OPTIMIZE ;" > ./$ARCH-userconf.jam
	elif [ "$CXX" = "llvm-g++-4.2" ]; then
	    echo "using darwin : : $(which $CXX) : <cxxflags> -isysroot $MACSDKDIR -mmacosx-version-min=$OSVERSION $OPTIMIZE ;" > ./$ARCH-userconf.jam
	else
	    echo "using darwin : : $(which $CXX) : <cxxflags> -isysroot $MACSDKDIR -mmacosx-version-min=$OSVERSION $OPTIMIZE ;" > ./$ARCH-userconf.jam
	fi
	boostTOOLSET="--user-config=./$ARCH-userconf.jam"
    fi
    
    
    # hack that sends extra arguments to g++
    $BJAM -a --stagedir="stage-$ARCH" --prefix=$REPOSITORYDIR $boostTOOLSET \
	--with-thread --with-filesystem --with-system --with-regex --with-iostreams \
	--with-date_time --with-signals \
	variant=release \
	architecture="$boostARCHITECTURE" address-model="$boostADDRESSMODEL" 

    mv ./stage-$ARCH/lib/libboost_thread.dylib ./stage-$ARCH/lib/libboost_thread-$BOOST_VER.dylib
    mv ./stage-$ARCH/lib/libboost_thread.a ./stage-$ARCH/lib/libboost_thread-$BOOST_VER.a
    mv ./stage-$ARCH/lib/libboost_filesystem.dylib ./stage-$ARCH/lib/libboost_filesystem-$BOOST_VER.dylib
    mv ./stage-$ARCH/lib/libboost_filesystem.a ./stage-$ARCH/lib/libboost_filesystem-$BOOST_VER.a
    mv ./stage-$ARCH/lib/libboost_system.dylib ./stage-$ARCH/lib/libboost_system-$BOOST_VER.dylib
    mv ./stage-$ARCH/lib/libboost_system.a ./stage-$ARCH/lib/libboost_system-$BOOST_VER.a
    mv ./stage-$ARCH/lib/libboost_regex.dylib ./stage-$ARCH/lib/libboost_regex-$BOOST_VER.dylib
    mv ./stage-$ARCH/lib/libboost_regex.a ./stage-$ARCH/lib/libboost_regex-$BOOST_VER.a
    mv ./stage-$ARCH/lib/libboost_iostreams.dylib ./stage-$ARCH/lib/libboost_iostreams-$BOOST_VER.dylib
    mv ./stage-$ARCH/lib/libboost_iostreams.a ./stage-$ARCH/lib/libboost_iostreams-$BOOST_VER.a
    mv ./stage-$ARCH/lib/libboost_date_time.dylib ./stage-$ARCH/lib/libboost_date_time-$BOOST_VER.dylib
    mv ./stage-$ARCH/lib/libboost_date_time.a ./stage-$ARCH/lib/libboost_date_time-$BOOST_VER.a
    mv ./stage-$ARCH/lib/libboost_signals.dylib ./stage-$ARCH/lib/libboost_signals-$BOOST_VER.dylib
    mv ./stage-$ARCH/lib/libboost_signals.a ./stage-$ARCH/lib/libboost_signals-$BOOST_VER.a
done

#read pipo

# merge libboost_thread libboost_filesystem libboost_system libboost_regex libboost_iostreams libboost_signals

for liba in "lib/libboost_thread-$BOOST_VER.a" "lib/libboost_filesystem-$BOOST_VER.a" "lib/libboost_system-$BOOST_VER.a" "lib/libboost_regex-$BOOST_VER.a" "lib/libboost_iostreams-$BOOST_VER.a" "lib/libboost_date_time-$BOOST_VER.a" "lib/libboost_signals-$BOOST_VER.a" "lib/libboost_thread-$BOOST_VER.dylib"  "lib/libboost_filesystem-$BOOST_VER.dylib" "lib/libboost_system-$BOOST_VER.dylib" "lib/libboost_regex-$BOOST_VER.dylib"  "lib/libboost_iostreams-$BOOST_VER.dylib" "lib/libboost_date_time-$BOOST_VER.dylib" "lib/libboost_signals-$BOOST_VER.dylib"
do
    
    if [ $NUMARCH -eq 1 ] ; then
	if [ -f stage-$ARCHS/$liba ] ; then
	    echo "Moving stage-$ARCHS/$liba to $liba"
  	    mv "stage-$ARCHS/$liba" "$REPOSITORYDIR/$liba";
	    # Power programming: if filename ends in "a" then ...
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
	if [ -f stage-$ARCH/$liba ] ; then
	    echo "Adding stage-$ARCH/$liba to bundle"
  	    LIPOARGs="$LIPOARGs stage-$ARCH/$liba"
	else
	    echo "File stage-$ARCH/$liba was not found. Aborting build";
	    exit 1;
	fi
    done
    
    lipo $LIPOARGs -create -output "$REPOSITORYDIR/$liba";
 #Power programming: if filename ends in "a" then ...
    [ ${liba##*.} = a ] && ranlib "$REPOSITORYDIR/$liba";
    
done


if [ -f "$REPOSITORYDIR/lib/libboost_thread-$BOOST_VER.a" ] ; then
    ln -sfn libboost_thread-$BOOST_VER.a $REPOSITORYDIR/lib/libboost_thread.a;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_thread-$BOOST_VER.dylib" ] ; then
    install_name_tool -id "$REPOSITORYDIR/lib/libboost_thread-$BOOST_VER.dylib" "$REPOSITORYDIR/lib/libboost_thread-$BOOST_VER.dylib";
    ln -sfn libboost_thread-$BOOST_VER.dylib $REPOSITORYDIR/lib/libboost_thread.dylib;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_filesystem-$BOOST_VER.a" ] ; then
    ln -sfn libboost_filesystem-$BOOST_VER.a $REPOSITORYDIR/lib/libboost_fileystem.a;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_filesystem-$BOOST_VER.dylib" ]; then
    install_name_tool -id "$REPOSITORYDIR/lib/libboost_filesystem-$BOOST_VER.dylib" "$REPOSITORYDIR/lib/libboost_filesystem-$BOOST_VER.dylib";
    ln -sfn libboost_filesystem-$BOOST_VER.dylib $REPOSITORYDIR/lib/libboost_filesystem.dylib;
	# why ?
    install_name_tool -change "libboost_system.dylib" "@executable_path/../Libraries/libboost_system.dylib" "$REPOSITORYDIR/lib/libboost_filesystem-$BOOST_VER.dylib";
fi
if [ -f "$REPOSITORYDIR/lib/libboost_system-$BOOST_VER.a" ] ; then
    ln -sfn libboost_system-$BOOST_VER.a $REPOSITORYDIR/lib/libboost_system.a;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_system-$BOOST_VER.dylib" ]; then
    install_name_tool -id "$REPOSITORYDIR/lib/libboost_system-$BOOST_VER.dylib" "$REPOSITORYDIR/lib/libboost_system-$BOOST_VER.dylib";
    ln -sfn libboost_system-$BOOST_VER.dylib $REPOSITORYDIR/lib/libboost_system.dylib;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_regex-$BOOST_VER.a" ] ; then
    ln -sfn libboost_regex-$BOOST_VER.a $REPOSITORYDIR/lib/libboost_regex.a;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_regex-$BOOST_VER.dylib" ]; then
    install_name_tool -id "$REPOSITORYDIR/lib/libboost_regex-$BOOST_VER.dylib" "$REPOSITORYDIR/lib/libboost_regex-$BOOST_VER.dylib";
    ln -sfn libboost_regex-$BOOST_VER.dylib $REPOSITORYDIR/lib/libboost_regex.dylib;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_iostreams-$BOOST_VER.a" ] ; then
    ln -sfn libboost_iostreams-$BOOST_VER.a $REPOSITORYDIR/lib/libboost_iostreams.a;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_iostreams-$BOOST_VER.dylib" ]; then
    install_name_tool -id "$REPOSITORYDIR/lib/libboost_iostreams-$BOOST_VER.dylib" "$REPOSITORYDIR/lib/libboost_iostreams-$BOOST_VER.dylib";
    ln -sfn libboost_iostreams-$BOOST_VER.dylib $REPOSITORYDIR/lib/libboost_iostreams.dylib;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_date_time-$BOOST_VER.a" ] ; then
    ln -sfn libboost_date_time-$BOOST_VER.a $REPOSITORYDIR/lib/libboost_date_time.a;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_date_time-$BOOST_VER.dylib" ]; then
    install_name_tool -id "$REPOSITORYDIR/lib/libboost_date_time-$BOOST_VER.dylib" "$REPOSITORYDIR/lib/libboost_date_time-$BOOST_VER.dylib";
    ln -sfn libboost_date_time-$BOOST_VER.dylib $REPOSITORYDIR/lib/libboost_date_time.dylib;
fi
if [ -f "$REPOSITORYDIR/lib/libboost_signals-$BOOST_VER.dylib" ]; then
    install_name_tool -id "$REPOSITORYDIR/lib/libboost_signals-$BOOST_VER.dylib" "$REPOSITORYDIR/lib/libboost_signals-$BOOST_VER.dylib";
    ln -sfn libboost_signals-$BOOST_VER.dylib $REPOSITORYDIR/lib/libboost_signals.dylib;
fi


# clean
rm -rf stage-i386 stage-x86_64
