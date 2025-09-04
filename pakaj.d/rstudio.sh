#!/bin/bash
#
## Date: 2022/02/19
## Pakaj: rstudio
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.rstudio.com/
## Wikipedia: https://en.wikipedia.org/wiki/RStudio
## Description: RStudio is an Integrated Development Environment (IDE) for R
## Binaries: ls tail xargs rm reprepro grep mkdir wget curl sed head basename

# Only buster / bionic / bullseye
# https://download1.rstudio.org/desktop/bionic/amd64/rstudio-2022.02.0-443-amd64.deb

function oberpakaj_rstudio {
   local keep=$1; shift
   local distrib=$*

   pkg='rstudio'
   mkdir -p "$HOME/upload/rstudio"
   cd "$HOME/upload/rstudio"

   curl -s -L 'https://www.rstudio.com/products/rstudio/download/#download' | sed 's/"/\n/g;' | egrep '^https://.*/rstudio-.*-amd64.deb$' > Packages.txt
   if [ -s "Packages.txt" ]
   then
      for dist in ${distrib}
      do
         case "${dist}" in
            bookworm) DEBVERSION=12 ; DEBGREP='jammy' ;;
            bullseye) DEBVERSION=11 ; DEBGREP='focal' ;;
            *)        DEBVERSION='' ; DEBGREP=''
         esac

         url=$(grep "/${DEBGREP}/" Packages.txt | head -1)
         pkgfile=$(basename ${url})
         mkdir -p "$HOME/upload/rstudio/${dist}"
         (cd "$HOME/upload/rstudio/${dist}"; wget --timestamping "${url}")
         tmp_folder=$(mktemp --directory /tmp/rstudio-XXXXXX)
         (cd ${tmp_folder}
            if LANG=C file "$HOME/upload/rstudio/${dist}/${pkgfile}" 2> /dev/null | grep -q 'Debian binary package'
            then
               ar -x "$HOME/upload/rstudio/${dist}/${pkgfile}"
               tar -xzf control.tar.gz
               VERSION=$(grep '^Version: ' control | cut -f 2 -d ' ')"-${DEBVERSION}"
               sed -i -e "s/\(Version: \).*/\1${VERSION}/; s|^$|Homepage: https://posit.co/products/open-source/rstudio/\n|;" control
               tar --owner root --group root -czf control.tar.gz control md5sums postinst postrm

               if ! grep -q "${pkg}_${VERSION}_amd64.deb" "$HOME/upload/rstudio/${dist}/timestamp.sig"
               then
                  ar -r "$HOME/upload/rstudio/${dist}/${pkg}_${VERSION}_amd64.deb" ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.gz ${tmp_folder}/data.tar.xz \
                     && echo "${pkg}_${VERSION}_amd64.deb" >> "$HOME/upload/rstudio/${dist}/timestamp.sig"
               fi
            fi
            )
         # Clean
         rm -rf ${tmp_folder}

         # Upload
         if [ -s "$HOME/upload/rstudio/${dist}/timestamp.sig" ]
         then
            package=$(grep "^${pkg}_" "$HOME/upload/rstudio/${dist}/timestamp.sig" | tail -1)
            if LANG=C file "$HOME/upload/rstudio/${dist}/${package}" 2> /dev/null | grep -q 'Debian binary package'
            then
              # Upload package
               ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/rstudio/${dist}/${package} )
               ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/${package}"
            fi
         fi

         # Clean old package - keep last 4 (put 4+1=5)
         [ -d "$HOME/upload/rstudio/${dist}" ] && (cd "$HOME/upload/rstudio/${dist}"
            ls -1t -- ${pkg}-[123456789]*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
           ls -1t -- ${pkg}_*.deb            2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
            )
      done
   fi
   }
