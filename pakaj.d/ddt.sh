#!/bin/bash
#
## Date: 2022/01/27
## Pakaj: ddt
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ddt
## Description: DDT is a simple IP Address Management (IPAM) service
## Binaries: ls tail xargs rm reprepro grep mkdir git cut make pod2man pod2html mktemp cp ln cat chmod tar ar

function oberpakaj_ddt {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/ddt" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ddt.git
   fi

   if [ -d "${HOME}/upload/ddt/.git" ]
   then
      cd "${HOME}/upload/ddt"
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep 'version->declare' ddt | cut -f 2 -d "'")
      PKG_VERSION=$(grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d "=")
      package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

      if [ ! -e "${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb" ]
      then
         make
         make pkg

         for dist in ${distrib}
         do
           ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/${PKG_NAME}/${package}" )
         done
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep -i "/${PKG_NAME}"
      fi
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/ddt" ]
   then
      cd "${HOME}/upload/ddt"
      ls -1t -- ddt_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   fi
   }
