function check_SetEnv()
{
    if [ -z "$REPOSITORYDIR" ]; then
	echo "SetEnv.txt is not sourced"
	exit 1
    fi
    #if [[ ! "$(pwd)" =~ "$(dirname $REPOSITORYDIR)" ]]; then
	#echo "you shall not compile here !"
	#exit -1
    #fi
}

function clean_build_directories()
{
    for ARCH in $ARCHS; do
	rm -rf build-$ARCH
    done
}

function compile_setenv()
{
    if [ $ARCH = "i386" -o $ARCH = "i686" ] ; then
	TARGET=$i386TARGET
	MACSDKDIR=$i386MACSDKDIR
	ARCHARGs="$i386ONLYARG"
	OSVERSION="$i386OSVERSION"
	CC=$i386CC
	CXX=$i386CXX
    elif [ $ARCH = "ppc" -o $ARCH = "ppc750" -o $ARCH = "ppc7400" ] ; then
	TARGET=$ppcTARGET
	MACSDKDIR=$ppcMACSDKDIR
	ARCHARGs="$ppcONLYARG"
	OSVERSION="$ppcOSVERSION"
	CC=$ppcCC
	CXX=$ppcCXX
    elif [ $ARCH = "ppc64" -o $ARCH = "ppc970" ] ; then
	TARGET=$ppc64TARGET
	MACSDKDIR=$ppc64MACSDKDIR
	ARCHARGs="$ppc64ONLYARG"
	OSVERSION="$ppc64OSVERSION"
	CC=$ppc64CC
	CXX=$ppc64CXX
    elif [ $ARCH = "x86_64" ] ; then
	TARGET=$x64TARGET
	MACSDKDIR=$x64MACSDKDIR
	ARCHARGs="$x64ONLYARG"
	OSVERSION="$x64OSVERSION"
	CC=$x64CC
	CXX=$x64CXX
    fi
}

function remove_64bits_from_ARCH
{
    ARCHS_TMP=$ARCHS
    ARCHS=""
    for ARCH in $ARCHS_TMP
    do
	if [ $ARCH = "i386" -o $ARCH = "i686" -o $ARCH = "ppc" -o $ARCH = "ppc750" -o $ARCH = "ppc7400" ]
	then
	    NUMARCH=$(($NUMARCH + 1))
	    if [ -n "$ARCHS" ]
	    then
		ARCHS="$ARCHS $ARCH"
	    else
		ARCHS=$ARCH
	    fi
	fi
    done
}

function merge_libraries()
{
    for liba in $*
    do
	if [ $NUMARCH -eq 1 ] ; then
	    if [ -f "$REPOSITORYDIR/arch/$ARCHS/$liba" ] ; then
		echo "Moving arch/$ARCHS/$liba to $liba"
  		mv "$REPOSITORYDIR/arch/$ARCHS/$liba" "$REPOSITORYDIR/$liba";
	        # Power programming: if filename ends in "a" then ...
		[ ${liba##*.} = a ] && ranlib "$REPOSITORYDIR/$liba";
  		continue
	    else
		echo "Library arch/$ARCHS/$liba not found in $REPOSITORYDIR. Aborting build"
		exit 1;
	    fi
	fi
	
	LIPOARGs=""
	for ARCH in $ARCHS
	do
	    if [ -f "$REPOSITORYDIR/arch/$ARCH/$liba" ] ; then
		echo "Adding arch/$ARCH/$liba to bundle"
		LIPOARGs="$LIPOARGs $REPOSITORYDIR/arch/$ARCH/$liba"
	    else
		echo "File arch/$ARCH/$liba was not found. Aborting build";
		exit 1;
	fi
	done
	
	lipo $LIPOARGs -create -output "$REPOSITORYDIR/$liba";
        # Power programming: if filename ends in "a" then ...
	[ ${liba##*.} = a ] && ranlib "$REPOSITORYDIR/$liba";
    done
}

function change_library_id()
{
    if [ -f "$REPOSITORYDIR/lib/$1" ]; then
	install_name_tool -id "$REPOSITORYDIR/lib/$1" "$REPOSITORYDIR/lib/$1"
	ln -sfn "$1" "$REPOSITORYDIR/lib/$2";
	if [ "$3" != "" ]; then
	    ln -sfn "$1" "$REPOSITORYDIR/lib/$3";
	fi
    else
	echo "Library $REPOSITORYDIR/lib/$1 not found. Cannot set id"
    fi
}

function merge_execs()
{
    check_SetEnv
    for program in $*
    do
        if [ ! -z "$NUMARCH" ]; then
	    if [ $NUMARCH -eq 1 ] ; then
		if [ -f "$REPOSITORYDIR/arch/$ARCHS/$program" ] ; then
		    echo "Moving arch/$ARCHS/$program to $program"
		    mv "$REPOSITORYDIR/arch/$ARCHS/$program" "$REPOSITORYDIR/$program";
		    strip -x "$REPOSITORYDIR/$program";
		    continue
		else
		    echo "Program arch/$ARCHS/$program not found. Aborting build";
		    exit 1;
		fi
	    fi
	fi
	
	LIPOARGs=""
	
	for ARCH in $ARCHS
	do
            if [ -f "$REPOSITORYDIR/arch/$ARCH/$program" ] ; then
		echo "Adding arch/$ARCH/$program to bundle"
		LIPOARGs="$LIPOARGs $REPOSITORYDIR/arch/$ARCH/$program"
            else
		echo "File arch/$ARCH/$program was not found. Aborting build";
            exit 1;
            fi
	done
	
	lipo $LIPOARGs -create -output "$REPOSITORYDIR/$program";
	strip -x "$REPOSITORYDIR/$program";
    done
}

function hugin_install_name()
{
    verbose=false
    if [ $1 = '-v' ]; then 
	verbose=true
	shift
    fi
    if [ -z "$myREPOSITORYDIR" ]; then
	exit -1
    fi
    
    for exec in $*; do
	if [ -f "$exec" -a ! -L "$exec" ]; then
	    if [ $verbose = "true" ]; then
		echo "re-ldd $exec\nbefore"
		otool -L $exec
	    fi
	    otool -L $exec | grep "$myREPOSITORYDIR" | awk '{print $1}' | while read lib; do
		libname=$(basename $lib)
		if [ $verbose = "true" ]; then
		    echo "relocating $lib ($libname)"
		fi
		install_name_tool -change "$lib" "@executable_path/../lib/$libname" "$exec"
	    done
	    if [ $verbose = "true" ]; then
		echo "after"
		otool -L $exec
            fi
	fi
    done
}
