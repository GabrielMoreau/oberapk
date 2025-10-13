#!/bin/bash
#
## Date: 2022/01/27
## Pakaj: ocs-webutils
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ocs-webutils
## Description: DDT is a simple IP Address Management (IPAM) service
## Binaries: ls tail xargs rm reprepro grep mkdir git cut make pod2man pod2html mktemp cp ln cat chmod tar ar

function oberpakaj_ocs_webutils {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/ocs-webutils" ]
   then
      cd "${HOME}/upload/" || return
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ocs-webutils.git
   fi

   if [ -d "${HOME}/upload/ocs-webutils/.git" ]
   then
      cd "${HOME}/upload/ocs-webutils" || return
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep '__version__' ocs-pkgpush | cut -f 2 -d '"')
      PKG_VERSION=$(grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d "=")
      package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

      if [ ! -s "${package}" ]
      then
         ./make-package-debian
      fi

      if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
      then
         for dist in ${distrib}
         do
            ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
               ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/${PKG_NAME}/${package}" )
         done
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep -i "/${PKG_NAME}"
      fi
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/ocs-webutils" ]
   then
      cd "${HOME}/upload/ocs-webutils" || return
      ls -1t -- ocs-webutils_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   fi
   }
