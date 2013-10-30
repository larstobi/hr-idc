#!/bin/sh
#

if [ $# -ne 1 ]; then
	echo "usage: $0 <path to idcbatch dir>"
	exit 1
fi



BUILDDIR=$1
PREFIX='EX'
cd `dirname $0`
NAME=idcbatch
PKG=${PREFIX}${NAME}
PKGDIR=`pwd`
REPO='http://pkg.example.com/solaris10'
PKGSPOOL=$PKGDIR/pkg
RELEASE=1.1
BUILDDIR=$PKGDIR/${NAME}-${RELEASE}
INSTALL=opt/$PKG/

PROTOTYPE=$PKGDIR/prototype

cp $PROTOTYPE.head $PROTOTYPE
TARBALL=${NAME}-$RELEASE.tar

function locate_wget {
    # Locate a wget
    if [ -x /usr/bin/wget ]; then
	WGET=/usr/bin/wget;
    elif  [ -x /usr/local/bin/wget ]; then
	WGET=/usr/local/bin/wget;
    elif [ -x /opt/csw/bin/wget ]; then
	WGET=/opt/csw/bin/wget;
    elif [ -x /opt/csw/libexec/pkgutil/wget ]; then
	WGET="/opt/csw/libexec/pkgutil/wget";
    else
	echo "ERROR: wget not found.";
	exit 1;
    fi;
}

if [ ! -f ${TARBALL} ]; then
	locate_wget
    $WGET ${REPO}/${TARBALL}
fi

tar xf ${TARBALL}
chown -R root:root ${NAME}-${RELEASE}

if [ ! -d $BUILDDIR ]; then
#        locate_wget
	echo "ERROR: ${TARBALL} not found."
	echo "       You must download the ${TARBALL} distribution file and unpack it"
	exit 1
fi

pkgproto $BUILDDIR=$INSTALL | \
	sed "s/${USER} ${USER}/root root/" >> $PROTOTYPE

if [ ! -d $PKGSPOOL ]; then
    mkdir $PKGSPOOL
fi
pkgmk -o -d $PKGSPOOL
pkgtrans $PKGSPOOL `pwd`/$PKG.pkg $PKG

rm -rf $PKGSPOOL
rm -rf $BUILDDIR
rm -f $PKGDIR/prototype
