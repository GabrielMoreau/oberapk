#!/bin/bash
#
## Date: 2025/01/13
## Pakaj: kopia
## Package: kopia kopia-ui
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/kopia/kopia
## Description: Fast and secure open source backup
## Binaries: ls tail xargs rm reprepro grep mkdir wget curl awk file

function oberpakaj_kopia {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/kopia"
   cd "$HOME/upload/kopia"

   version=$(curl -s -L 'https://github.com/kopia/kopia/releases/latest' | sed 's/</\n/g;'| grep '^meta property.*og:title' | cut -f 4 -d ' ' | sed -e 's/^v//;')
   for package in kopia_${version}_linux_amd64.deb kopia-ui_${version}_amd64.deb
   do
      wget --timestamping "https://github.com/kopia/kopia/releases/download/v${version}/${package}"
      if echo "${package}" | grep -q '_linux_'
      then
         ln -f kopia_${version}_linux_amd64.deb kopia_${version}_amd64.deb
         package=kopia_${version}_amd64.deb
      fi

      if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
      then
         # Upload package
         for dist in ${distrib}
         do
            ( cd "${REPREPRO}" || return ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
               ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" $HOME/upload/kopia/${package} )
            ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/kopia"
         done
      fi
   done

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- kopia_*.deb    | tail -n +$((2 * (${keep} + 1))) | xargs -r rm -f
   ls -1t -- kopia-ui_*.deb | tail -n +$((${keep} + 1))       | xargs -r rm -f
   }
