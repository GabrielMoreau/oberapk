#!/bin/bash
#
## Date: 2025/02/05
## Pakaj: udsclient3
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: http://www.udsenterprise.com
## Description: Client connector for Universal Desktop Services (UDS) Broker
## Binaries: ls tail xargs rm reprepro grep wget mkdir unxz ar tar xz awk

function oberpakaj_udsclient3 {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/udsclient3"
   cd "$HOME/upload/udsclient3"

   # https://mydesk.unimore.it/uds/page/client-download
   # https://mydesk.unimore.it/uds/page/client-download
   # https://mydesk.unimore.it/uds/page/client-download
   # https://polilabs.upv.es/uds/page/client-download

   version=3.6.0
   url="https://mydesk.unimore.it/uds/res/clients/udsclient3_${version}_all.deb"
   if wget --quiet --timestamping "${url}"
   then
      package=$(basename ${url})

      if [ -s "${package}" ] && LANG=C file "${package}" 2> /dev/null | grep -q 'Debian binary package'
      then
         for dist in ${distrib}
         do
            # Upload package
            ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd "${REPREPRO}" || return ; reprepro includedeb ${dist} $HOME/upload/udsclient3/${package} )
               ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/${package}"
         done
      fi
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- udsclient3_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
