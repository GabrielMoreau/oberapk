#!/bin/bash
#
## Date: 2022/02/16
## Pakaj: qgis
## Package: libqgis python-qgis python3-qgis qgis
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: http://qgis.org/
## Wikipedia: https://en.wikipedia.org/wiki/QGIS
## Description: QGIS is a free and open-source cross-platform desktop geographic information system (GIS)
## Binaries: ls tail xargs rm reprepro grep mkdir cut wget basename

# beta quality - this packaging has not been test on a real life


function oberpakaj_qgis {
   local keep=$1; shift
   local distrib=$*

   for dist in ${distrib}
   do
      mkdir -p "$HOME/upload/qgis/${dist}"
      cd "$HOME/upload/qgis/${dist}"

      while read poolfile
      do
         package=$(basename ${poolfile})
         wget --timestamping "http://qgis.org/debian-ltr/${poolfile}"
         if [ -e "${package}" ]
         then
           ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" $HOME/upload/qgis/${dist}/${package} )
         fi

         # Clean old package
         basepkg=$(echo "${package}" | cut -f 1 -d '_')
         ls -1t -- ${basepkg}_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
      done < <(wget -q http://qgis.org/debian-ltr/dists/${dist}/main/binary-amd64/Packages.gz -O - | zgrep -E '^Filename: pool/main/q/qgis/(libqgis|python-qgis|python3-qgis|qgis).*.deb' | cut -f 2 -d ' ')
   done
   }
