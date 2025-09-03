## Date: 2024/07/12
## Pakaj: openfoam
## Package: openfoam openfoam-common openfoam-default openfoam-dev openfoam-source openfoam-tools openfoam-tutorials
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://openfoam.com
## Wikipedia: https://en.wikipedia.org/wiki/OpenFOAM
## Description: OpenFOAM is a free, open source computational fluid dynamics (CFD)
## Binaries: ls tail xargs rm reprepro grep mkdir cut wget basename curl

function oberpakaj_openfoam {
   local keep=$1; shift
   local distrib=$*

   for dist in ${distrib}
   do
      mkdir -p "$HOME/upload/openfoam/${dist}"
      cd "$HOME/upload/openfoam/${dist}"
      
      for arch in all amd64
      do
         #echo "https://dl.openfoam.com/repos/deb/dists/${dist}/main/binary-${arch}/Packages"
         curl -s --time-cond "Packages-${arch}" -o "Packages-${arch}" -L "https://dl.openfoam.com/repos/deb/dists/${dist}/main/binary-${arch}/Packages"
      done
      
      if [ -s "Packages-all" -o -s "Packages-amd64" ]
      then
         pkg_version=$(grep -E '^Filename: .*(openfoam).*.deb' Packages-all Packages-amd64 | cut -f 5 -d '/' | sort -uV | grep '^[[:digit:]][[:digit:]_]*$' | tail -1)
         #echo "${pkg_version}"
      fi

      echo "${pkg_version}" | grep -q '^[[:digit:]][[:digit:]_]*$' || continue
      while read poolfile
      do
         package=$(basename ${poolfile})
         wget --timestamping "https://dl.openfoam.com/repos/deb/${poolfile}"
         if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
         then
           #echo "Upload ${package}"
           ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/openfoam/${dist}/${package} )
         fi

         # Clean old package
         basepkg=$(echo "${package}" | cut -f 1 -d '_')
         ls -1t -- ${basepkg}_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
      done < <(grep "^Filename: .*/${pkg_version}/.*openfoam.*.deb" Packages-all Packages-amd64 | cut -f 2 -d ' ' | sort -u)
   done
   }
