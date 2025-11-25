#!/bin/bash
#
## Date: 2021/10/07
## Pakaj: powershell
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://microsoft.com/powershell
## Wikipedia: https://en.wikipedia.org/wiki/PowerShell
## Description: PowerShell is a task automation and configuration management program from Microsoft, consisting of a command-line shell and the associated scripting language
## Binaries: ls tail xargs rm reprepro grep mkdir wget head awk

function oberpakaj_powershell {
   local keep=$1; shift
   local distrib=$*

   pakajname=$(echo "${FUNCNAME[0]}" | sed -e 's/^oberpakaj_//; s/_/-/g;')

   for dist in ${distrib}
   do
      mkdir -p "$HOME/upload/${pakajname}/${dist}"
      cd "$HOME/upload/${pakajname}/${dist}" || return
      #PKG_VERSION=1
      if wget --timestamping "https://packages.microsoft.com/repos/microsoft-debian-${dist}-prod/dists/${dist}/main/binary-amd64/Packages.gz"
      then
         if [ -e "Packages.gz" ]
         then
            url=$(zgrep ^Filename Packages.gz | grep '/powershell/' | head -1 | awk '{print $2}')
            if [ -z "${url}" ] && [ "${dist}" = "trixie" ]
            then
               url=$(zgrep ^Filename ../bookworm/Packages.gz 2> /dev/null | grep '/powershell/' | head -1 | awk '{print $2}')
               (mkdir -p ../bookworm; cd ../bookworm || return; wget --timestamping "https://packages.microsoft.com/repos/microsoft-debian-bookworm-prod/${url}")
               archive=$(basename "${url}")
               tmp_folder=$(mktemp --directory "/tmp/${pakajname}-XXXXXX")
               (cd "${tmp_folder}" || return
                  ar -x "$HOME/upload/${pakajname}/bookworm/${archive}"
                  tar xzf control.tar.gz
                  VERSION=$(grep '^Version:' control | awk '{print $2}' | sed -e 's/\.deb/-u13/;')
                  sed -i "s/^\(Version:[[:space:]]\).*/\1${VERSION}/; s/\(libicu74\)/libicu76|\1/;" control
                  tar --owner root --group root -czf control.tar.gz ./control ./md5sums ./postinst ./postrm

                  ar -r "$HOME/upload/${pakajname}/${dist}/${pakajname}_${VERSION}_amd64.deb" "${tmp_folder}/debian-binary" "${tmp_folder}/control.tar.gz" "${tmp_folder}/data.tar.gz" \
                     && echo "${pakajname}_${VERSION}_amd64.deb" > "$HOME/upload/${pakajname}/${dist}/timestamp.sig"
               )

               # Clean
               rm -rf "${tmp_folder}"

            else
               wget --timestamping "https://packages.microsoft.com/repos/microsoft-debian-${dist}-prod/${url}"
               basename "${url}" > "$HOME/upload/${pakajname}/${dist}/timestamp.sig"
            fi
         fi
      fi
   done

   # Upload package
   for dist in ${distrib}
   do
      cd "$HOME/upload/${pakajname}/${dist}" || continue
      package="$(cat timestamp.sig)"
      if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
      then
         # Upload package
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/${pakajname}/${dist}/${package}" )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/${package}"
      fi
   done

   for dist in ${distrib}
   do
      # Clean old package - kept last 4 (put 4+1=5)
      cd "$HOME/upload/${pakajname}/${dist}" || return
      ls -1t -- powershell_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   done
   }
