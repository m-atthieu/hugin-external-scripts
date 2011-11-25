cd $REPOSITORYDIR
if [ ! -d lib-static ] ; then
  mkdir -p lib-static
fi
if [ -n "lib/*.a" ] ; then
  cp -f lib/*.a lib-static/
  rm lib/*.a
fi
if [ ! -d lib-static/wx ] ; then
  mv lib/{pkgconfig,wx} lib-static/
  cp -a ../lib-static/pkgconfig lib/pkgconfig
  cp -a ../lib-static/wx        lib/wx
fi
