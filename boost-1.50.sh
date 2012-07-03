# ------------------
#      boost
# ------------------
# $Id: boost.sh 1902 2007-02-04 22:27:47Z ippei $
# Copyright (c) 2007-2008, Ippei Ukai

# prepare
source ../scripts/functions.sh
check_SetEnv

# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100121.0 sg Script updated for 1_41
# 20100121.1 sg Script reverted to 1_40
# 20100624.0 hvdw More robust error checking on compilation
# 20100831.0 hvdw Upgraded to 1_44
# 20100920.0 hvdw Add removed libboost_system again and add iostreams and regex
# 20100920.1 hvdw Add date_time as well
# -------------------------------

fail()
{
    echo "** Failed at $1 **"
    exit 1
}


BOOST_VER="1_50"

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
        cd "./tools/build/v2/engine/src"
        sh "build.sh"
        cd "../../../../../"
        BJAM=$(ls ./tools/build/v2/engine/src/bin.mac*/bjam)
       echo $BJAM
        ;;
  1_47|1_48|1_49|1_50)
        cd "./tools/build/v2/engine"
        sh "build.sh"
        cd "../../../../"
        BJAM=$(ls ./tools/build/v2/engine/bin.mac*/bjam)
        ;;
esac
echo "BJAM command is: $BJAM"
echo "## Done compiling bjam ##"

# init
let NUMARCH="0"

for i in $ARCHS
do
    NUMARCH=$(($NUMARCH + 1))
done

mkdir -p "$REPOSITORYDIR/lib";

# compile boost_thread, filesystem, system, regex, iostreams, date_time and signals

for ARCH in $ARCHS
do
    rm -rf "stage-$ARCH";
    mkdir -p "stage-$ARCH";

    if [ $ARCH = "i386" -o $ARCH = "i686" ]
    then
	MACSDKDIR=$i386MACSDKDIR
	OSVERSION=$i386OSVERSION
	OPTIMIZE=$i386OPTIMIZE
	boostARCHITECTURE="x86"
	boostADDRESSMODEL="32"
	ARCHFLAG="-m32"
	export CC=$i386CC;
	export CXX=$i386CXX;
    elif [ $ARCH = "x86_64" ]
    then
	MACSDKDIR=$x64MACSDKDIR
	OSVERSION=$x64OSVERSION
	OPTIMIZE=$x64OPTIMIZE
	boostARCHITECTURE="x86"
	boostADDRESSMODEL="64"
	ARCHFLAG="-m64"
	export CC=$x64CC;
	export CXX=$x64CXX;
    fi
        
    SDKVRSION=$(echo $MACSDKDIR | sed 's/^[^1]*\([[:digit:]]*\.[[:digit:]]*\).*/\1/')
    
    if [ "$CXX" = "" ] 
    then
	boostTOOLSET="--toolset=darwin"
	CXX="g++"
    else
	echo "using darwin : : $CXX ;" > ./TEMP-userconf.jam
	boostTOOLSET="--user-config=./TEMP-userconf.jam"
    fi
    
    # hack that sends extra arguments to g++
    $BJAM -a --stagedir="stage-$ARCH" --prefix=$REPOSITORYDIR $boostTOOLSET -n stage \
	--with-thread --with-filesystem --with-system --with-regex --with-iostreams --with-date_time --with-signals \
	variant=release \
	architecture="$boostARCHITECTURE" address-model="$boostADDRESSMODEL" \
	macosx-version="$SDKVRSION" macosx-version-min="$OSVERSION" \
	| grep "^    " | sed 's/"//g' | sed s/$CXX/$CXX\ "$OPTIMIZE"/  \
	| while read COMMAND
    do
	echo "running command: $COMMAND"
	$COMMAND
    done;
    
    for name in 'thread' 'filesystem' 'system' 'regex' 'iostreams' 'date_time' 'signals'; do
	for ext in 'a' 'dylib'; do
	    mv ./stage-$ARCH/lib/libboost_$name.$ext ./stage-$ARCH/lib/libboost_$name-$BOOST_VER.$ext || fail "failed moving $ARCH/lib/libboost_$name.$ext"
	done
    done
done

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
    for ARCH in $ARCHS; do
	if [ -f stage-$ARCH/$liba ] ; then
	    echo "Adding stage-$ARCH/$liba to bundle"
  	    LIPOARGs="$LIPOARGs stage-$ARCH/$liba"
	else
	    echo "File stage-$ARCH/$liba was not found. Aborting build";
	    exit 1;
	fi
    done
    
    lipo $LIPOARGs -create -output "$REPOSITORYDIR/$liba";
    # Power programming: if filename ends in "a" then ...
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
    install_name_tool -change "libboost_system.dylib" "$REPOSITORYDIR/lib/libboost_system-$BOOST_VER.dylib" "$REPOSITORYDIR/lib/libboost_filesystem-$BOOST_VER.dylib";
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
