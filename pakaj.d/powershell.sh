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

   for dist in ${distrib}
   do
      mkdir -p "$HOME/upload/powershell/${dist}"
      cd "$HOME/upload/powershell/${dist}" || return
      #PKG_VERSION=1
      if wget --timestamping "https://packages.microsoft.com/repos/microsoft-debian-${dist}-prod/dists/${dist}/main/binary-amd64/Packages.gz"
      then
         if [ -e "Packages.gz" ]
         then
            url=$(zgrep ^Filename Packages.gz | grep '/powershell/' | head -1 | awk '{print $2}')
            if [ -z "${url}" ] && [ "${dist}" = "trixie" ]
            then
                url=$(zgrep ^Filename ../bookworm/Packages.gz 2> /dev/null | grep '/powershell/' | head -1 | awk '{print $2}')
            fi
            package=$(basename "${url}")

            wget --timestamping "https://packages.microsoft.com/repos/microsoft-debian-${dist}-prod/${url}"

            if [ -s "${package}" ]
            then
               # Upload package
               ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/powershell/${dist}/${package}" )
               ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/${package}"
            fi
         fi
      fi
   done

   for dist in ${distrib}
   do
      # Clean old package - kept last 4 (put 4+1=5)
      cd "$HOME/upload/powershell/${dist}" || return
      ls -1t -- powershell_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   done
   }
