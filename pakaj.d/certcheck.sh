#!/bin/bash
#
## Date: 2023/07/28
## Pakaj: certcheck
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/certcheck
## Description: Checks the certificate chain
## Binaries: ls tail xargs rm reprepro grep mkdir git cut make mktemp pod2man pod2html cp cat chmod tar ar

function oberpakaj_certcheck {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/certcheck" ]
   then
      cd "${HOME}/upload/" || return
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/certcheck.git
   fi

   if [ -d "${HOME}/upload/certcheck/.git" ]
   then
      cd "${HOME}/upload/certcheck" || return
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep '^export VERSION=' certcheck | cut -f 2 -d "=")
      PKG_VERSION=$(grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d "=")
      package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

      if [ ! -s "${package}" ]
      then
         make
         make pkg
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
   if [ -d "${HOME}/upload/certcheck" ]
   then
      cd "${HOME}/upload/certcheck" || return
      ls -1t -- certcheck_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   fi
   }
