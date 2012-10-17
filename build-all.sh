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
build boost     boost_1_47_0    boost-1.47.0.sh
build expat     expat-2.0.1     libexpat.sh
build iconv     libiconv-1.13.1 libiconv-1.13.1.sh
build gettext   gettext-0.17    gettext-0.17.sh
build libjpeg-8 jpeg-8c         libjpeg.sh
build png       libpng-1.2.46   libpng-1.2.46.sh
build tiff      tiff-3.9.5      libtiff.sh
build ilmbase   ilmbase-1.0.2   ilmbase-1.0.2.sh
build openexr   openexr-1.7.0   openexr17.sh
build libpano13 libpano13.hg    pano13-trunk.sh
build libexiv2  exiv2-0.22      libexiv2-0.22.sh
build liblcms   lcms-1.19       lcms.sh
build libxmi    libxmi-1.2      libxmi.sh
build libglew   glew-1.5.8      libglew-1.5.8.sh
build gnumake   gnumake-126.2   gnumake-126.2.sh
build wxmac     wxMac-2.8.12    wxmac28.sh

build gsl		gsl-1.15		gsl.sh # enblend.hg dependnecy
# Correct funky name for the enblend-enfuse-4.0 directory
if [ ! -d ../enblend-enfuse-4.0 ] && [ -d ../enblend-enfuse-4.0-753b534c819d ] ; then
    ln -s enblend-enfuse-4.0-753b534c819d ../enblend-enfuse-4.0
fi
build enblend-enfuse enblend-enfuse-4.0 enblend.sh

build tclap          tclap-1.2.1        tclap.sh
build zthread        ZThread-2.3.2      zthread.sh

build glib2   glib-2.28.8   libglib2.sh
build lensfun lensfun-0.2.6 lensfun.sh

build multiblend multiblend-0.4 multiblend.sh

# Following packages are optional. Uncomment if you are building them
#echo "$pre autopano-sift-C $pst" && cd ../autopano-sift-C    && sh ../scripts/autopano-sift-C.sh;
#echo "$pre panomatic $pst"       && cd ../panomatic-0.9.4    && sh ../scripts/panomatic.sh;

# Separate static libraries into their own directory. Needed to build static tools
sh ../scripts/static-separation.sh

echo "That's all, folks!!"
