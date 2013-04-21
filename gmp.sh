mkdir -p build
cd build
env CC=$x64CC CXX=$x64CXX \
    ../configure --prefix=$REPOSITORYDIR/local-gcc --enable-cxx
make install
