#!/bin/bash
#
## Date: 2023/04/15
## Pakaj: espanso
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://espanso.org and https://github.com/federico-terzi/espanso
## Description: Cross-platform Text Expander written in Rust
## Binaries: ls tail xargs rm reprepro grep mkdir wget ar tar awk basename sed mktemp cat file

function oberpakaj_espanso {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/espanso"
   cd "$HOME/upload/espanso"

   package=''
   url=$(wget -q https://espanso.org/docs/install/linux/ -O - | sed -e 's/[<>[:space:]]/\n/g;' | grep '^https://.*espanso-debian-x11-amd64.deb')
   package_file=$(basename ${url})
   before=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   wget --quiet --timestamping "${url}"
   LANG=C file ${package_file} | grep -q 'Debian binary package' || return
   after=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   if [ "${after}" -gt "${before}" ]
   then
      tmp_folder=$(mktemp --directory /tmp/espanso-XXXXXX)
      (cd ${tmp_folder}
         ar -x $HOME/upload/espanso/${package_file}
         tar xJf control.tar.xz
         )

      version=$(grep '^Version:' ${tmp_folder}/control | awk '{print $2}')
      package=$(grep '^Package:' ${tmp_folder}/control | awk '{print $2}')_${version}_amd64.deb
      cp -a ${package_file} ${package}

      # Clean
      rm -rf "${tmp_folder}"
   fi

   # Upload package
   if [ -s "${package}" ]
   then
      for dist in ${distrib}
      do
         # Upload package
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" $HOME/upload/espanso/${package} )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/espanso"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- espanso_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
