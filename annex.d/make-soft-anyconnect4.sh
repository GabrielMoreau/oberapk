#!/bin/bash
#
# Script: make-soft-anyconnect4.sh
#
# 2022/06/24 Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>

# Install Cisco AnyConnect version 4
# Go on https://vpn.grenet.fr/+CSCOE+/logon.html
# Get script anyconnect-linux64-4.7.04056-core-vpn-webdeploy-k9.sh or newer
# Run it on a computer as root
# Install log are in /opt/cisco/anyconnect/anyconnect-linux64-*-core-vpn-webdeploy-k9-*.log
# find /etc /usr -name '*anyconnect*'
# Uninstall AnyConnect after running this script
# /opt/cisco/anyconnect/bin/anyconnect_uninstall.sh && rm -rf /opt/cisco/anyconnect && rmdir /opt/cisco

if [ ! -e "/opt/cisco/anyconnect/update.txt" ]
then
   echo "Error: install anyconnect before on this computer"
   exit 1
fi

pkg_version=$(grep '^[[:digit:]]' /opt/cisco/anyconnect/update.txt | sed -e s'/,/./g;')
pkg_name=anyconnect
package=${pkg_name}_${pkg_version}_amd64.deb

tmp_folder=$(mktemp --directory /tmp/anyconnect-XXXXXX)
(cd "${tmp_folder}" || exit 1

   # Data archive
   mkdir opt
   mkdir -p etc/systemd/system
   rsync -a --exclude 'temp' /opt/cisco  ./opt/
   rsync -a /opt/.cisco ./opt/
   rsync -a /etc/systemd/system/vpnagentd.service ./etc/systemd/system/

   rm -f ./opt/cisco/anyconnect/anyconnect-*.log
   rm -f ./opt/cisco/anyconnect/bin/*_uninstall.sh

   for file in /usr/share/applications/com.cisco.anyconnect.gui.desktop \
      /usr/share/icons/hicolor/128x128/apps/cisco-anyconnect.png \
      /usr/share/icons/hicolor/256x256/apps/cisco-anyconnect.png \
      /usr/share/icons/hicolor/48x48/apps/cisco-anyconnect.png \
      /usr/share/icons/hicolor/512x512/apps/cisco-anyconnect.png \
      /usr/share/icons/hicolor/64x64/apps/cisco-anyconnect.png \
      /usr/share/icons/hicolor/96x96/apps/cisco-anyconnect.png \
      /usr/share/desktop-directories/cisco-anyconnect.directory
   do
      mkdir -p ".$(dirname "${file}")"
      cp -p "${file}" ".${file}"
   done

   find . -perm /0100 -a -name '*.png'  -a -type f -exec chmod a-x {} \+
   find . -perm /0100 -a -name '*.so'   -a -type f -exec chmod a-x {} \+
   find . -perm /0100 -a -name '*.so.*' -a -type f -exec chmod a-x {} \+
   find . -type f -exec chmod u+rw,go+r {} \+
   find . -type d -exec chmod u+rwx,go+rx {} \+

   mkdir -p usr/bin
   (cd usr/bin || exit; ln -s ../../opt/cisco/anyconnect/bin/vpnui vpnui)

   tar --preserve-permissions --owner root --group root -cJf data.tar.xz ./etc ./usr ./opt

   depends=$(for lib in $(ldd /opt/cisco/anyconnect/bin/vpnui | grep -v /opt/ | grep '=>' | awk '{print $3}')
      do
        echo "${lib}" | grep -Eq '/(libsystemd.so|libstdc++.so|libgobject-2.0.so|libglib-2.0.so|libXext.so)' && continue
        # echo =========== $lib
        apt-file search "$lib"
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

   size=$(du -ks "${tmp_folder}" | cut -f 1)

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
Description: Cisco AnyConnect Secure Mobility Client
 The Cisco AnyConnect Secure Mobility Client enables remote workers to
 easily and securely access your network from anywhere, anytime, on any
 device, while protecting your business.
Homepage: https://www.cisco.com/c/en/us/support/security/secure-client-5/model.html
END

   tar --owner root --group root -czf control.tar.gz ./control ./postinst ./prerm
)

# Format deb package
echo 2.0 > "${tmp_folder}/debian-binary"

# Create package (control before data)
ar -r "${package}" "${tmp_folder}/debian-binary" "${tmp_folder}/control.tar.gz" "${tmp_folder}/data.tar.xz"

# Clean
# rm -rf ${tmp_folder}

# Final reprepo bonus
cat <<'END'
# Copy the package on the reprepo server and then
export REPO=/var/www/debian/
export DIST=bookworm
(cd "${REPO}" ; reprepro includedeb "${DIST}" "$HOME/${DIST}/${package})"
(cd "${REPO}" ; reprepro dumpreferences ) | grep anyconnect
# (cd "${REPO}" ; reprepro remove "${DIST}" anyconnect )

# Clean the temporary build folder
rm -rf "${tmp_folder}"
END
