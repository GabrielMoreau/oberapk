#!/bin/bash
#
## Date: 2025/06/12
## Pakaj: drawio
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://app.diagrams.net/ and https://github.com/jgraph/drawio-desktop/
## Description: Configurable diagramming / whiteboarding visualization application
## Binaries: ls tail xargs rm reprepro grep mkdir wget ar tar awk basename sed mktemp cat file

function oberpakaj_drawio {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/drawio"
   cd "$HOME/upload/drawio"
   [ -e "timestamp.sig" ] \
      || touch -t "$(date +%Y)01010000" timestamp.sig

   package=''
   url=$(wget --quiet https://github.com/jgraph/drawio-desktop/releases -O - | sed -e 's/"/\n/g;' | grep '^https://github.com/.*/drawio-amd64-.*.deb' | head -1)
   package_file=$(basename "${url}")
   before=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   wget --quiet --timestamping "${url}"
   LANG=C file "${package_file}" | grep -q 'Debian binary package' || return
   after=$(stat -c %Y "${package_file}" 2> /dev/null || echo 0)
   previous_package="$(cat timestamp.sig)"
   if [ "${after}" -gt "${before}" ] || [ ! -s "${previous_package}" ]
   then
      tmp_folder=$(mktemp --directory /tmp/drawio-XXXXXX)
      (cd "${tmp_folder}"
         ar -x "$HOME/upload/drawio/${package_file}"
         tar xzf control.tar.gz

         package='drawio'
         VERSION=$(grep '^Version:' control | awk '{print $2}')

         sed -i -e 's/^Package:.*/Package: drawio/;' control
         tar --owner root --group root -czf control.tar.gz ./control ./postinst ./postrm ./md5sums

         # Create package (control before data)
         ar -r "$HOME/upload/drawio/${package}_${VERSION}_amd64.deb" "${tmp_folder}/debian-binary" "${tmp_folder}/control.tar.gz" "${tmp_folder}/data.tar.xz" \
            && echo "${package}_${VERSION}_amd64.deb" > "$HOME/upload/drawio/timestamp.sig"
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
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/drawio/${package}" )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/drawio"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- drawio_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   ls -1t -- drawio-*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
