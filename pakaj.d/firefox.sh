## Date: 2021/08/19
## Pakaj: firefox
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

   curl -s --time-cond 'Packages' -o 'Packages' -L 'https://packages.mozilla.org/apt/dists/mozilla/main/binary-amd64/Packages'
   if [ -s "Packages" ]
   then
      url='https://packages.mozilla.org/apt/'$(grep ^Filename Packages | grep '/firefox_' | head -1 | awk '{print $2}')
      package=$(basename "${url}" | sed -e 's/_amd64_.*\.deb/_amd64.deb/;')

      LANG=C file "${package}" 2> /dev/null | grep -q 'Debian binary package' || curl -# -o "${package}" -L "${url}"

      if LANG=C file "${package}" 2> /dev/null | grep -q 'Debian binary package'
      then
         # Upload package
         for dist in ${distrib}
         do
            ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/firefox/${pkgfile} )
            ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/${package}"
         done
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/firefox"
   ls -t firefox_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   }
