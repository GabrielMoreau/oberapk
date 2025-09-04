#!/bin/bash
#
## Date: 2024/01/31
## Pakaj: veracrypt
## Package: veracrypt veracrypt-console
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.veracrypt.fr/
## Wikipedia: https://en.wikipedia.org/wiki/VeraCrypt
## Description: Disk encryption with strong security based on TrueCrypt
## Binaries: ls tail xargs rm reprepro curl head awk basename grep

function oberpakaj_veracrypt {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/veracrypt"
   cd "$HOME/upload/veracrypt"

   curl -s -L https://www.veracrypt.fr/en/Downloads.html | sed -s 's/"/\n/g; s/&#43;/+/g;' | grep '^https://.*Debian.*amd64.deb$' > Packages.txt
   if [ -s "Packages.txt" ]
   then
      for pkg in 'veracrypt' 'veracrypt-console'
      do
         for dist in ${distrib}
         do
            case "${dist}" in
               bookworm) DEBVERSION=12 ;;
               bullseye) DEBVERSION=11 ;;
               *) DEBVERSION=''
            esac
            url=$(grep "/${pkg}-[[:digit:]].*-Debian-${DEBVERSION}-amd64.deb" Packages.txt)
            pkgfile=$(basename "${url}")
            mkdir -p "$HOME/upload/veracrypt/${dist}"
            (cd "$HOME/upload/veracrypt/${dist}"; wget --timestamping "${url}")
            tmp_folder=$(mktemp --directory /tmp/veracrypt-XXXXXX)
            (cd "${tmp_folder}"
               if LANG=C file "$HOME/upload/veracrypt/${dist}/${pkgfile}" 2> /dev/null | grep -q 'Debian binary package'
               then
                  ar -x "$HOME/upload/veracrypt/${dist}/${pkgfile}"
                  tar -xzf control.tar.gz
                  VERSION=$(grep '^Version: ' control | cut -f 2 -d ' ')"-${DEBVERSION}"
                  sed -i -e "s/\(Version: \).*/\1${VERSION}/; s|^$|Homepage: https://www.veracrypt.fr/en/Home.html\n|;" control
                  tar --owner root --group root -czf control.tar.gz control md5sums prerm

                  if ! grep -q "${pkg}_${VERSION}_amd64.deb" "$HOME/upload/veracrypt/${dist}/timestamp.sig"
                  then
                     ar -r "$HOME/upload/veracrypt/${dist}/${pkg}_${VERSION}_amd64.deb" "${tmp_folder}/debian-binary" "${tmp_folder}/control.tar.gz" "${tmp_folder}/data.tar.gz" \
                        && echo "${pkg}_${VERSION}_amd64.deb" >> "$HOME/upload/veracrypt/${dist}/timestamp.sig"
                  fi
               fi
               )
            # Clean
            rm -rf "${tmp_folder}"

            # Upload
            if [ -s "$HOME/upload/veracrypt/${dist}/timestamp.sig" ]
            then
               package=$(grep "^${pkg}_" "$HOME/upload/veracrypt/${dist}/timestamp.sig" | tail -1)
               if LANG=C file "$HOME/upload/veracrypt/${dist}/${package}" 2> /dev/null | grep -q 'Debian binary package'
               then
                 # Upload package
                  ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                     ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/veracrypt/${dist}/${package}" )
                  ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/${package}"
               fi
            fi

            # Clean old package - keep last 4 (put 4+1=5)
            [ -d "$HOME/upload/veracrypt/${dist}" ] && (cd "$HOME/upload/veracrypt/${dist}"
               ls -1t -- ${pkg}-[123456789]*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
               ls -1t -- ${pkg}_*.deb            2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
               )
          done
      done
   fi
   }
