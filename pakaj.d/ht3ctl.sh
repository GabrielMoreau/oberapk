#!/bin/bash
#
## Date: 2023/07/28
## Pakaj: ht3ctl
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ht3ctl
## Description: Enable or disable hyperthreading and boost on computer
## Binaries: ls tail xargs rm reprepro grep mkdir git cut make mktemp pod2man pod2html cp cat chmod tar ar

function oberpakaj_ht3ctl {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/ht3ctl" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ht3ctl.git
   fi

   if [ -d "${HOME}/upload/ht3ctl/.git" ]
   then
      cd "${HOME}/upload/ht3ctl"
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep '^export VERSION=' ht3ctl | cut -f 2 -d "=")
      PKG_VERSION=$(grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d "=")
      package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

      if [ ! -e "${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb" ]
      then
         make
         make pkg

         for dist in ${distrib}
         do
           ( cd "${REPREPRO}" || return ; reprepro includedeb ${dist} $HOME/upload/${PKG_NAME}/${package} )
         done
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep -i "/${PKG_NAME}"
      fi
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/ht3ctl" ]
   then
      cd "${HOME}/upload/ht3ctl"
      ls -1t -- ht3ctl_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   fi
   }
