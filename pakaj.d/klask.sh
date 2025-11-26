#!/bin/bash
#
## Date: 2022/01/27
## Pakaj: klask
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/klask
## Description: A tool dedicated to the mapping of the local network
## Binaries: ls tail xargs rm reprepro grep mkdir git cut make mktemp pod2man pod2html cp cat chmod tar ar

function oberpakaj_klask {
   local keep=$1; shift
   local distrib=$*

   pakajname=$(echo "${FUNCNAME[0]}" | sed -e 's/^oberpakaj_//; s/_/-/g;')
   if [ ! -d "${HOME}/upload/${pakajname}" ]
   then
      cd "${HOME}/upload/" || return
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/klask.git
   fi

   if [ -d "${HOME}/upload/${pakajname}/.git" ]
   then
      cd "${HOME}/upload/${pakajname}" || return
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep 'version->declare' klask | cut -f 2 -d "'")
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
               ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/${pakajname}/${package}" )
         done
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep -i "/${PKG_NAME}"
      fi
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/${pakajname}" ]
   then
      cd "${HOME}/upload/${pakajname}" || return
      ls -1t -- klask_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   fi
   }
