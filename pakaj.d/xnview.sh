#!/bin/bash
#
## Date: 2025/06/27
## Pakaj: xnview
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.xnview.com
## Description: Graphic viewer, browser, converter (XnView MP distribution)
## Binaries: ls tail xargs rm reprepro grep mkdir wget ar tar awk basename sed mktemp cat file

function oberpakaj_xnview {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/xnview"
   cd "$HOME/upload/xnview"
   [ -e "timestamp.sig" ] \
      || touch -t "$(date +%Y)01010000" timestamp.sig

   package=''
   url=https://download.xnview.com/XnViewMP-linux-x64.deb
   package_file=$(basename ${url})
   before=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   wget --quiet --timestamping "${url}"
   LANG=C file ${package_file} | grep -q 'Debian binary package' || return
   after=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   previous_package="$(cat timestamp.sig)"
   if [ "${after}" -gt "${before}" ] || [ ! -s "${previous_package}" ]
   then
      tmp_folder=$(mktemp --directory /tmp/xnview-XXXXXX)
      (cd ${tmp_folder}
         ar -x $HOME/upload/xnview/${package_file}
         tar xzf control.tar.gz

         package='xnview'
         VERSION=$(grep '^Version:' control | awk '{print $2}')

         #sed -i -e 's/^Package:.*/Package: xnview/;' control
         tar --owner root --group root -czf control.tar.gz ./control ./postinst

         # Create package (control before data)
         ln --force "$HOME/upload/xnview/${package_file}" "$HOME/upload/xnview/${package}_${VERSION}_amd64.deb" \
            && echo "${package}_${VERSION}_amd64.deb" > "$HOME/upload/xnview/timestamp.sig"
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
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" $HOME/upload/xnview/${package} )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/xnview"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- xnview_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
