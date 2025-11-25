#!/bin/bash
#
## Date: 2025/11/14
## Pakaj: qrscan
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/sayanarijit/qrscan
## Description: Scan a QR code in the terminal using the system camera or a given image
## Binaries: ls tail xargs rm reprepro grep mkdir wget curl awk file

function oberpakaj_qrscan {
   local keep=$1; shift
   local distrib=$*

   pakajname=$(echo "${FUNCNAME[0]}" | sed -e 's/^oberpakaj_//; s/_/-/g;')
   mkdir -p "${HOME}/upload/${pakajname}"
   cd "${HOME}/upload/${pakajname}" || return

   VERSION=$(curl -s -L 'https://github.com/sayanarijit/qrscan/releases/latest' | sed 's/</\n/g;'| grep '^meta property.*og:title' | cut -f 5 -d ' ' | sed -e 's/^v//;')
   echo "${pakajname}: ${VERSION}"
   package="qrscan"
   url="https://github.com/sayanarijit/qrscan/releases/download/v${VERSION}/qrscan-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"
   package_file=$(basename "${url}")

   before=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   wget --timestamping "${url}"
   after=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   previous_package="$(cat timestamp.sig 2> /dev/null)"
   if [ "${after}" -gt "${before}" ] || [ ! -s "${previous_package}" ]
   then
      tmp_folder=$(mktemp --directory /tmp/${pakajname}-XXXXXX)
      (cd "${tmp_folder}"

         if [ -s "${HOME}/upload/${pakajname}/${package_file}" ]
         then
            tar xzf "${HOME}/upload/${pakajname}/${package_file}"
            [ -s "qrscan-${VERSION}/qrscan" ] || return

            mkdir -p usr/bin
            mv "qrscan-${VERSION}/qrscan" usr/bin/qrscan
            chmod 0755 usr/bin/qrscan

            # Control file
            cat <<END > control
Package: qrscan
Version: ${VERSION}
Section: graphics
Priority: optional
Depends: libc6
Architecture: amd64
Installed-Size: $(du -ks "${tmp_folder}/usr" | cut -f 1)
Maintainer: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Description: scan a QR code in the terminal using the system camera or a given image
 qrscan is a shell (terminal) tool that scans QR codes (using your webcam),
 displays an ASCII art version of the QR code, and then displays details
 about it (including the data/URL).
 .
 You can export an image of the scanned QR code in several formats (jpg,
 png, etc.), including an ASCII version.
 .
 You can also pass an image file of a QR code to qrscan to obtain the data.
Homepage: https://github.com/sayanarijit/qrscan
END

            rm -f data.tar.xz control.tar.gz
            tar --preserve-permissions --owner root --group root -cJf data.tar.xz ./usr
            tar --owner root --group root -czf control.tar.gz ./control
            echo 2.0 > "${tmp_folder}/debian-binary"

            # Create package (control before data)
            ar -r "$HOME/upload/${pakajname}/${package}_${VERSION}_amd64.deb" "${tmp_folder}/debian-binary" "${tmp_folder}/control.tar.gz" "${tmp_folder}/data.tar.xz" \
               && echo "${package}_${VERSION}_amd64.deb" > "$HOME/upload/${pakajname}/timestamp.sig"
         fi
      )

      # Clean
      rm -rf "${tmp_folder}"
   fi

   # Upload package
   package="$(cat timestamp.sig)"
   if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
   then
      # Upload package
      for dist in ${distrib}
      do
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/${pakajname}/${package}" )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/qrscan"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- qrscan_*.deb    | tail -n +$((2 * (keep+1))) | xargs -r rm -f
   }
