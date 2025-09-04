#!/bin/bash
#
## Date: 2025/07/15
## Pakaj: ferdium
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://ferdium.org/ https://github.com/ferdium/ferdium-app
## Description: Messaging app for WhatsApp, Slack, Telegram, Gmail, Google Chat, and many more.
## Binaries: ls tail xargs rm reprepro grep mkdir wget ar tar awk basename sed mktemp cat file

function oberpakaj_ferdium {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/ferdium"
   cd "$HOME/upload/ferdium" || return
   [ -e "timestamp.sig" ] \
      || touch -t "$(date +%Y)01010000" timestamp.sig

   package=''
   # https://github.com/ferdium/ferdium-app/releases/download/v7.1.0/Ferdium-linux-7.1.0-amd64.deb
   url='https://github.com/'$(wget --quiet https://github.com/ferdium/ferdium-app/releases -O - | sed -e 's/"/\n/g;' | grep '^/ferdium/ferdium-app/releases/download/v.*/Ferdium-linux-.*-amd64.deb' | head -1)
   package_file=$(basename "${url}")
   before=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   wget --quiet --timestamping "${url}"
   LANG=C file "${package_file}" | grep -q 'Debian binary package' || return
   after=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   previous_package="$(cat timestamp.sig)"
   if [ "${after}" -gt "${before}" ] || [ ! -s "${previous_package}" ]
   then
      tmp_folder=$(mktemp --directory /tmp/ferdium-XXXXXX)
      (cd "${tmp_folder}" || return
         ar -x "$HOME/upload/ferdium/${package_file}"
         tar xzf control.tar.gz

         package=$(grep '^Package:' control | awk '{print $2}')
         VERSION=$(grep '^Version:' control | awk '{print $2}')

         # Create package (control before data)
         ln -f "$HOME/upload/ferdium/${package_file}" "$HOME/upload/ferdium/${package}_${VERSION}_amd64.deb" \
            && echo "${package}_${VERSION}_amd64.deb" > "$HOME/upload/ferdium/timestamp.sig"
         )

      # Clean
      rm -rf "${tmp_folder}"
   fi

   # Upload package
   package="$(cat timestamp.sig)"
   if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
   then
      for dist in ${distrib}
      do
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/ferdium/${package}" )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/ferdium"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- ferdium_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   ls -1t -- Ferdium-*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
