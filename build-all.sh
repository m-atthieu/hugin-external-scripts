#! /bin/sh
# -------------------------------
# 20091206.0 sg Script tested and used to build 2009.4.0-RC3
# 20100110.0 sg Make libGLEW and libexiv2 dynamic
#               Update to enblend-enfuse-4.0 and panotools 2.9.15
# 20100112.0 sg Made libxmi dynamic. Created lib-static directory
# 20100117.0 sg Update for glew 1.5.2
# 20100119.0 HvdW Add libiconv
# 20100118.1 sg Fixed missing "" and named SVN directory for panotools libpano13-2.9.16
# 20100121.0 sg Updated for newer packages: boost,jpeg,png,tiff,exiv2,lcms
# 20100121.1 sg Backed out new version of boost
# -------------------------------

cd $HOME/hugin/external/scripts || exit 1
source SetEnv.txt

rm -rf $REPOSITORYDIR

function build()
{
    name="$1"
    dir="../$2"
    script="../scripts/$3"

    pre="<<<<<<<<<<<<<<<<<<<< building"
    pst=">>>>>>>>>>>>>>>>>>>>"

    echo "$pre $name $pst" \
	&& cd "$dir" \
	|| exit 1 && sh "$script"
}

# To start this script in the middle, uncomment the next 2 lines and move the "fi" line down as needed
#if [ -z "this will test will fail" ] ; then; fi
build expat     expat-2.1.0      libexpat.sh
build iconv     libiconv-1.14 	 libiconv.sh
build gettext   gettext-0.18.2   gettext.sh
build libjpeg   jpeg-8d          libjpeg.sh
build png       libpng-1.4.11    libpng14.sh
build tiff      tiff-3.9.5       libtiff.sh
build ilmbase   ilmbase-1.0.3    ilmbase.sh
build openexr   openexr-1.7.1    openexr17.sh
build libpano13 libpano13.hg     pano13.sh
build libexiv2  exiv2-0.23       libexiv2.sh
build liblcms   lcms-1.19        lcms.sh
build liblcms2  lcms-2.24        lcms2.sh
build libglew   glew-1.9.0       libglew.sh
build gnumake   gnumake-126.2    gnumake.sh
build wxmac     wxWidgets-2.9.4  wxmac29.sh

# enblend doesn't need libxmi anymore
build boost          boost_1_46_1         boost.sh
build gsl	     gsl-1.15		  gsl.sh # needed by enblend.hg, enblend-4.1 & >
build vigra          vigra-1.9.0          vigra.sh
build enblend-enfuse enblend-enfuse-4.1.1 enblend.sh

build tclap          tclap-1.2.1        tclap.sh
build zthread        ZThread-2.3.2      zthread.sh

build libffi  libffi-3.0.31 libffi.sh
build glib2   glib-2.28.8   libglib2.sh
build lensfun lensfun-0.2.6 lensfun.sh

build multiblend multiblend-0.4 multiblend.sh

# Following packages are optional. Uncomment if you are building them
#echo "$pre autopano-sift-C $pst" && cd ../autopano-sift-C    && sh ../scripts/autopano-sift-C.sh;
#echo "$pre panomatic $pst"       && cd ../panomatic-0.9.4    && sh ../scripts/panomatic.sh;

# Separate static libraries into their own directory. Needed to build static tools
sh ../scripts/static-separation.sh

echo "That's all, folks!!"
