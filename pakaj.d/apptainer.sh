#!/bin/bash
#
## Date: 2022/01/25
## Pakaj: apptainer
## Package: apptainer apptainer-suid
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/apptainer/apptainer
## Description: Container platform focused on supporting Mobility of Compute formerly known as Singularity
## Binaries: ls tail xargs rm reprepro grep mkdir wget awk file

function oberpakaj_apptainer {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/apptainer"
   cd "$HOME/upload/apptainer"

   version=$(wget --quiet 'https://github.com/apptainer/apptainer/releases/latest' -O - | grep 'title.Release' | awk '{print $2}' | cut -f 2 -d 'v')
   wget --timestamping "https://github.com/apptainer/apptainer/releases/download/v${version}/apptainer_${version}_amd64.deb"
   wget --timestamping "https://github.com/apptainer/apptainer/releases/download/v${version}/apptainer-suid_${version}_amd64.deb"
   for package in apptainer_${version}_amd64.deb apptainer-suid_${version}_amd64.deb
   do
      if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
      then
         # Upload package
         for dist in ${distrib}
         do
            ( cd "${REPREPRO}" || return ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
               ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/apptainer/${package}" )
            ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/apptainer"
         done
      fi
   done

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- apptainer_*.deb      2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   ls -1t -- apptainer-suid_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
