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

function check_numarchs()
{
    let NUMARCH="0"
    for i in $ARCHS
    do
	NUMARCH=$(($NUMARCH + 1))
    done
    
    if [ $NUMARCH -gt 1 ]; then
	echo "Scripts can now compile for only one arch"
	exit -1
    fi
}

function compile_setenv()
{
    if [ $ARCH != "x86_64" ] ; then
	echo "\$ARCH is not x86_64"
	exit -1
    fi
    TARGET=$x64TARGET
    MACSDKDIR=$x64MACSDKDIR
    ARCHARGs="$x64ONLYARG"
    OSVERSION="$x64OSVERSION"
    CC=$x64CC
    CXX=$x64CXX
}
