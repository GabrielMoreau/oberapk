#!/bin/bash
#
## Date: 2024/06/07
## Pakaj: xpipe
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://xpipe.io
## Description: Your entire server infrastructure at your fingertips with XPipe
## Binaries: ls tail xargs rm reprepro grep mkdir touch basename wget stat mktemp ar tar file

function oberpakaj_xpipe {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/xpipe"
   cd "$HOME/upload/xpipe"
   [ -e "timestamp.sig" ] \
      || touch -t "$(date +%Y)01010000" timestamp.sig

   PKG_VERSION=1
   url="https://github.com/xpipe-io/xpipe/releases/latest/download/xpipe-installer-linux-x86_64.deb"
   package_file=$(basename ${url})
   before=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   wget --timestamping "${url}"
   after=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   if [ "${after}" -gt "${before}" ] && file "${package_file}" | grep -q 'Debian binary package'
   then
      tmp_folder=$(mktemp --directory /tmp/xpipe-XXXXXX)
      (cd ${tmp_folder}
         ar -x $HOME/upload/xpipe/${package_file} control.tar.gz
         tar -xzf control.tar.gz

         VERSION=$(grep '^Version:' ./control | cut -f 2 -d ' ')
         package=xpipe_${VERSION}_amd64.deb

         # Create package (control before data)
         ln --force "$HOME/upload/xpipe/${package_file}" "$HOME/upload/xpipe/${package}" \
            && echo "${package}" > "$HOME/upload/xpipe/timestamp.sig"
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
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" $HOME/upload/xpipe/${package} )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/xpipe"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- xpipe_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
