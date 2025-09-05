#!/bin/bash
#
# Script: make-soft-xflr5.sh
#
# 2021/10/21 Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
#
## See-Also: http://www.xflr5.tech/xflr5.htm
## Decription: analysis tool for airfoils, wings and planes operating at low Reynolds Numbers.

# See https://github.com/polmes/xflr5-ubuntu

PKG_NAME=xflr5
PKG_VERSION=1
CODE_VERSION=$(curl -s 'https://raw.githubusercontent.com/polmes/xflr5-ubuntu/master/xflr5/xflr5v6/xflcore/gui_params.h' | grep 'define .*_VERSION' | awk '{print $3}' | paste -s -d '.')

# Debian package
sudo apt install qt5-qmake libgl1-mesa-dev qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools

tmp_folder=$(mktemp --directory /tmp/xflr5-XXXXXX)
cd "${tmp_folder}" || exit 1

git clone https://github.com/polmes/xflr5-ubuntu.git
cd xflr5-ubuntu/xflr5/ || exit 1

mkdir -p "${tmp_folder}/local/xflr5/usr"

LOCAL_VERSION=$(grep 'define .*_VERSION' xflr5v6/xflcore/gui_params.h | awk '{print $3}' | paste -s -d '.')
if [ "${LOCAL_VERSION}" -ne "${CODE_VERSION}" ]
then
   echo "Error: version problem on git clone"
   exit 1
fi

qmake PREFIX="${tmp_folder}/local/xflr5/usr"
make
make install

cd "${tmp_folder}/local/xflr5" || exit 1
find . -mtime -1

sed -i -e 's/\/local//;' ./usr/share/xflr5/xflr5.desktop
mkdir -p ./usr/share/applications
mv ./usr/share/xflr5/xflr5.desktop ./usr/share/applications/

# Data archive
rm -f data.tar.gz
tar --owner root --group root -czf data.tar.gz ./usr

# Control file
cat <<END > control
Package: ${PKG_NAME}
Version: ${CODE_VERSION}-${PKG_VERSION}
Architecture: amd64
Installed-Size: $(du -ks ./usr|cut -f 1)
Maintainer:Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Depends: libc6, libgcc1, libgl1-mesa-glx | libgl1, libqt5opengl5, libqt5xml5, libqt5core5a, libqt5gui5, libstdc++6
Section: science
Priority: extra
Homepage: http://www.xflr5.tech/xflr5.htm
Description: airfoil, wings and plane analysis tool
 XFLR5 is an analysis tool for airfoils, wings and planes operating
 at low Reynolds Numbers.
 It includes:
 .
  1. XFoil's Direct and Inverse analysis capabilities
  2. Wing design analysis based on the Lifiting Line Theory and the
    Vortex Lattice Method
END

# Control archive
rm -f "${tmp_folder}/control.tar.gz"
tar --owner root --group root -czf control.tar.gz control

# Format deb package
echo 2.0 >  debian-binary

# Create package (control before data)
ar -r "${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_amd64.deb" ./debian-binary ./control.tar.gz ./data.tar.gz


# Specific post-install / Copy on reprepro server
cat <<END
scp ${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_amd64.deb repuser@repserver:bullseye/

ssh repuser@repserver
export REPDIR=/var/www/debian
( cd \${REPDIR} ; reprepro includedeb bullseye   ~/bullseye/${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_amd64.deb )
( cd \${REPDIR} ; reprepro dumpreferences ) | grep '/${PKG_NAME}'
END
