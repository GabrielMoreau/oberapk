#!/bin/bash
#
# Script: make-soft-anyconnect5.sh
#
# 2024/09/06 Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>

# Install Cisco Secure Client (AnyConnect VPN) version 5
# Go on https://vpn.grenet.fr/+CSCOE+/logon.html
# Get script cisco-secure-client-linux64-5.1.5.65-core-vpn-webdeploy-k9.sh
# Run it on a computer as root
# Install log are in /opt/cisco/secureclient/cisco-secure-client-linux64-*-core-vpn-webdeploy-k9-12373306092024.log
# find /etc /usr -name '*secure*client*' -o -name '*anyconnect*'
# find /opt/cisco/ -name vpnui 
# Uninstall Cisco Secure Client (AnyConnect) after running this script
# /opt/cisco/secureclient/bin/vpn_uninstall.sh && rm -rf /opt/cisco/secureclient /opt/cisco/anyconnect && rmdir /opt/cisco

if [ ! -e "/opt/cisco/secureclient/update.txt" ]
then
   echo "Error: install anyconnect before on this computer"
   exit 1
fi

pkg_version=$(grep '^[[:digit:]]' /opt/cisco/secureclient/update.txt | sed -e s'/,/./g;')
pkg_name=anyconnect
package=${pkg_name}_${pkg_version}_amd64.deb

tmp_folder=$(mktemp --directory /tmp/anyconnect-XXXXXX)
(cd ${tmp_folder}

# Data archive
mkdir opt
mkdir -p etc/systemd/system
rsync -a --exclude 'temp' /opt/cisco  ./opt/
rsync -a /opt/.cisco ./opt/
rsync -a /etc/systemd/system/vpnagentd.service ./etc/systemd/system/

rm -f ./opt/cisco/secureclient/anyconnect-*.log
rm -f ./opt/cisco/secureclient/bin/*_uninstall.sh

for file in /etc/xdg/menus/applications-merged/cisco-secure-client.menu \
/usr/share/applications/com.cisco.secureclient.gui.desktop \
/usr/share/icons/hicolor/96x96/apps/cisco-secure-client.png \
/usr/share/icons/hicolor/512x512/apps/cisco-secure-client.png \
/usr/share/icons/hicolor/256x256/apps/cisco-secure-client.png \
/usr/share/icons/hicolor/48x48/apps/cisco-secure-client.png \
/usr/share/icons/hicolor/64x64/apps/cisco-secure-client.png \
/usr/share/icons/hicolor/128x128/apps/cisco-secure-client.png \
/usr/share/desktop-directories/cisco-secure-client.directory
do
   mkdir -p .$(dirname ${file})
   cp -p ${file} .${file}
done

find . -perm /0100 -a -name '*.png'  -a -type f -exec chmod a-x {} \+
find . -perm /0100 -a -name '*.so'   -a -type f -exec chmod a-x {} \+
find . -perm /0100 -a -name '*.so.*' -a -type f -exec chmod a-x {} \+
find . -type f -exec chmod u+rw,go+r {} \+
find . -type d -exec chmod u+rwx,go+rx {} \+

mkdir -p usr/bin
(cd usr/bin; ln -s ../../opt/cisco/secureclient/bin/vpnui vpnui)

tar --preserve-permissions --owner root --group root -cJf data.tar.xz ./etc ./usr ./opt

depends=$(for lib in $(ldd /opt/cisco/secureclient/bin/vpnui | grep -v /opt/ | grep '=>' | awk '{print $3}')
   do
      echo "${lib}" | egrep -q '/(libsystemd.so|libstdc++.so|libgobject-2.0.so|libglib-2.0.so|libXext.so)' && continue
      # echo =========== $lib
      apt-file search $lib
   done | cut -f 1 -d ':' | sort -u | paste -sd ','
   )

# Control archive
cat <<'END' > postinst
#!/bin/sh
# Updating GTK icon cache
#which gtk-update-icon-cache > /dev/null && gtk-update-icon-cache -f -t /usr/share/icons/hicolor
# use debian trigger
# Start VPN agent
systemctl status vpnagentd | grep -q 'Active: active' && systemctl stop vpnagentd
systemctl disable vpnagentd
systemctl enable vpnagentd
systemctl start vpnagentd
#ln -s /opt/cisco/anyconnect/bin/vpnui /usr/bin/vpnui
END

cat <<'END' > prerm
#!/bin/sh
#rm -f /usr/bin/vpnui
systemctl status vpnagentd | grep -q 'Active: active' && systemctl stop vpnagentd
systemctl disable vpnagentd
END

chmod a+rx ./postinst ./prerm

size=$(du -ks ${tmp_folder} | cut -f 1)

cat <<END > control
Package: ${pkg_name}
Version: ${pkg_version}
Section: utils
Priority: optional
Installed-Size: ${size}
Maintainer: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Architecture: amd64
Depends: systemd | systemctl,libsystemd0,libstdc++6,libglib2.0-0,libxext6,${depends}
Recommends: gtk-update-icon-cache
Description: Cisco Secure Client, Mobility AnyConnect VPN
 The Cisco Secure Client enables remote workers to easily and securely
 access your network from anywhere, anytime, on any device, while
 protecting your business.
 The old name was AnyConnect Secure Mobility Client.
Homepage: https://www.cisco.com/c/en/us/support/security/secure-client-5/model.html
END

tar --owner root --group root -czf control.tar.gz ./control ./postinst ./prerm
)

# Format deb package
echo 2.0 > ${tmp_folder}/debian-binary

# Create package (control before data)
ar -r ${package} ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.gz ${tmp_folder}/data.tar.xz

# Clean
# rm -rf ${tmp_folder}

#
echo '# Copy the package on the reprepo server and then'
echo 'export REPO=/var/www/debian/'
echo '(cd ${REPO} ; reprepro includedeb bullseye $HOME/bookworm/'"${package})"
echo '(cd ${REPO} ; reprepro dumpreferences ) | grep anyconnect'
echo '# (cd ${REPO} ; reprepro remove bookworm anyconnect )'
echo ''
echo '# Clean the temporary build folder'
echo "rm -rf ${tmp_folder}"
