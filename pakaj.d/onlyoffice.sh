#!/bin/bash
#
## Date: 2018/08/30
## Pakaj: onlyoffice
## Package: onlyoffice-desktopeditors
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.onlyoffice.com/desktop.aspx
## Wikipedia: https://en.wikipedia.org/wiki/OnlyOffice
## Description: office suite
## Binaries: ls tail xargs rm reprepro grep mkdir wget cut head sed

function oberpakaj_onlyoffice {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/onlyoffice"
   cd "$HOME/upload/onlyoffice"
   [ -e "timestamp.sig" ] \
      || touch -t "$(date +%Y)01010000" timestamp.sig

   #PKG_VERSION=1
   url="https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb"
   package_file=$(basename "${url}")
   before=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   wget --timestamping "${url}"
   after=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   previous_package="$(cat timestamp.sig)"
   if [ "${after}" -gt "${before}" ] || [ ! -s "${previous_package}" ]
   then
      package=$(basename "${url}" _amd64.deb)

      tmp_folder=$(mktemp --directory /tmp/onlyoffice-XXXXXX)
      (cd "${tmp_folder}"
         ar -x "$HOME/upload/onlyoffice/${package}_amd64.deb"
         tar -xzf control.tar.gz
         VERSION=$(grep 'Version:' control | cut -f 2 -d ' ')

         # Create package (control before data)
         cp "$HOME/upload/onlyoffice/${package}_amd64.deb" "$HOME/upload/onlyoffice/${package}_${VERSION}_amd64.deb" \
            && echo "${package}_${VERSION}_amd64.deb" > "$HOME/upload/onlyoffice/timestamp.sig"
            )

      # Clean
      rm -rf "${tmp_folder}"
   fi

   # Upload package
   package="$(cat timestamp.sig)"
   if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
   then
      for dist in ${distrib}
      do
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/onlyoffice/${package}" )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/onlyoffice-desktopeditors"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- onlyoffice-desktopeditors_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
