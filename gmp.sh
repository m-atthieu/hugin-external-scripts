mkdir -p build
cd build
env CC=$x64CC CXX=$x64CXX \
    ../configure --prefix=$GCCMP_REPOSITORY_DIR --enable-cxx
make install
make distclean
