#!/bin/bash
#
## Date: 2022/07/06
## Pakaj: icaclient
## Package: icaclient ctxusb
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.citrix.com/
## Wikipedia: https://en.wikipedia.org/wiki/Citrix_Workspace
## Description: Citrix Workspace app for Linux
## Binaries: ls tail xargs rm reprepro grep mkdir wget basename sed file grep cut rm head

function oberpakaj_icaclient {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/icaclient"
   cd "$HOME/upload/icaclient"
   wget -q 'https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html' -O - | sed -e 's/"/\n/g;' | grep _amd64.deb > packages.txt
   
   url_icaclient=https:$(grep '/icaclient_.*_amd64.deb.__gda__=' packages.txt | head -1)   
   pkg_icaclient=$(basename $(echo $url_icaclient | sed -e 's/\?.*//;'))
   [ -s "${pkg_icaclient}" ] && { LANG=C file "${pkg_icaclient}" | grep -q 'Debian binary package' || rm -f "${pkg_icaclient}"; }
   [ -s "${pkg_icaclient}" ] || wget -q "${url_icaclient}" -O "${pkg_icaclient}"

   url_ctxusb=https:$(grep '/ctxusb_.*_amd64.deb.__gda__=' packages.txt | head -1)
   pkg_ctxusb=$(basename $(echo $url_ctxusb | sed -e 's/\?.*//;'))
   [ -s "${pkg_ctxusb}" ] && { LANG=C file "${pkg_ctxusb}" | grep -q 'Debian binary package' || rm -f "${pkg_ctxusb}"; }
   [ -s "${pkg_ctxusb}" ] || wget -q "${url_ctxusb}" -O "${pkg_ctxusb}"

   for package in "${pkg_icaclient}" "${pkg_ctxusb}"
   do
      [ -s "${package}" ] || continue
      LANG=C file "${package}" | grep -q 'Debian binary package' || continue
      [ $(ar t "${package}" | wc -l) -ge 3 ] || continue

      pkg_basename=$(echo ${package} | cut -f 1 -d '_')
      for dist in ${distrib}
      do
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" $HOME/upload/icaclient/${package} )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/${pkg_basename}"
      done
   done

   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/icaclient"
   ls -1t -- icaclient_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   ls -1t -- ctxusb_*.deb    2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
