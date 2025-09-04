#!/bin/bash
#
## Date: 2022/02/25
## Pakaj: tabby
## Description: A terminal for the modern age
## Package: tabby-terminal
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://tabby.sh/
## Binaries: ls tail xargs rm reprepro grep mkdir sort cut wget basename

function oberpakaj_tabby {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/tabby"
   cd "$HOME/upload/tabby"

   url=$(wget -q 'https://github.com/Eugeny/tabby/releases/latest' -O - | sed 's/[[:space:]]/\n/g;' | grep '^href=.*/tabby-.*-linux.deb' | cut -f 2 -d '"')
   version=$(echo ${url} | cut -f 2 -d '-')
   package=$(basename ${url})
   pkgname="tabby-terminal_${version}_amd64.deb"
   wget --timestamping "https://github.com/${url}"
   if [ -e "${package}" ]
   then
      for dist in ${distrib}
      do
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${pkgname}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" $HOME/upload/tabby/${package} )
      done
   fi

   # Clean old package
   basepkg=$(echo "${package}" | cut -f 1 -d '-')
   ls -1t -- ${basepkg}-*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
