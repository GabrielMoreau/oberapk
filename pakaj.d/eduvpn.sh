#!/bin/bash
#
## Date: 2025/01/17
## Pakaj: eduvpn
## Package: eduvpn-client eduvpn-client-data libeduvpn-common libeduvpn-common-dbgsym python3-eduvpn-client python3-eduvpn-common
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.eduvpn.org and https://github.com/eduvpn
## Description: VPN client for educational networks
## Binaries: ls tail xargs rm reprepro grep mkdir cut wget basename curl

function oberpakaj_eduvpn {
   local keep=$1; shift
   local distrib=$*

   for dist in ${distrib}
   do
      mkdir -p "$HOME/upload/eduvpn/${dist}"
      cd "$HOME/upload/eduvpn/${dist}"

      wget --timestamping "https://app.eduvpn.org/linux/v4/deb/dists/${dist}/main/binary-amd64/Packages"

      while read poolfile
      do
         package=$(basename ${poolfile})
         wget --timestamping "https://app.eduvpn.org/linux/v4/deb/${poolfile}"
         if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
         then
           #echo "Upload ${package}"
           ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" $HOME/upload/eduvpn/${dist}/${package} )
         fi

         # Clean old package
         basepkg=$(echo "${package}" | cut -f 1 -d '_')
         ls -1t -- ${basepkg}_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
      done < <(grep "^Filename: .*eduvpn-[^/]*.deb" Packages 2> /dev/null | cut -f 2 -d ' ' | sort -uR)
   done
   }
