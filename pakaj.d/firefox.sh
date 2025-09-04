#!/bin/bash
#
## Date: 2024/01/31
## Pakaj: firefox
## Package: firefox firefox-l10n-fr
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.mozilla.org/
## Wikipedia: https://en.wikipedia.org/wiki/Firefox
## Description: Mozilla Firefox is a free and open-source web browser (standart version)
## Binaries: ls tail xargs rm reprepro curl head awk basename grep

function oberpakaj_firefox {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/firefox"
   cd "$HOME/upload/firefox"

   curl -s --time-cond 'Packages-amd64' -o 'Packages-amd64' -L 'https://packages.mozilla.org/apt/dists/mozilla/main/binary-amd64/Packages'
   curl -s --time-cond 'Packages-all'   -o 'Packages-all'   -L 'https://packages.mozilla.org/apt/dists/mozilla/main/binary-all/Packages'
   if [ -s "Packages-amd64" ] && [ -s "Packages-all" ]
   then
      for pkg in 'firefox' 'firefox-l10n-fr'
      do
         url='https://packages.mozilla.org/apt/'$(grep -h ^Filename Packages-amd64 Packages-all | grep "/${pkg}_" | head -1 | awk '{print $2}')
         package=$(basename "${url}" | sed -e 's/_\(amd64\|all\)_.*\.deb/_\1.deb/;')

         LANG=C file "${package}" 2> /dev/null | grep -q 'Debian binary package' || curl -# -o "${package}" -L "${url}"

         if LANG=C file "${package}" 2> /dev/null | grep -q 'Debian binary package'
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/firefox/${package}" )
               ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/${package}"
            done
         fi
      done
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   cd "$HOME/upload/firefox"
   ls -1t -- firefox_*.deb         2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   ls -1t -- firefox-l10n-fr_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
