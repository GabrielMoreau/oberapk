#!/bin/bash
#
## Date: 2020/04/14
## Pakaj: tixeoclient
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.tixeo.com/
## Description: Video conferencing technology certified and qualified by the ANSSI
## Binaries: ls tail xargs rm reprepro grep wget mkdir awk sort
#
# Other (CNRS) https://aide.core-cloud.net/si/tixeo/SitePages/FAQ.aspx
#
# Filename: pool/non-free/t/tixeoclient/tixeoclient_15.0.4.0_amd64.deb

function oberpakaj_tixeoclient {
   local keep=$1; shift
   local distrib=$*

   for dist in ${distrib}
   do
      mkdir -p "$HOME/upload/tixeoclient/${dist}"
      cd "$HOME/upload/tixeoclient/${dist}"
      if wget --timestamping "http://repos.tixeo.com/debian/dists/${dist}/non-free/binary-amd64/Packages.gz"
      then
         if [ -e 'Packages.gz' ]
         then
            pool=$(zgrep 'tixeoclient/tixeoclient_'"$(zgrep '^Version:' Packages.gz | awk '{print $2}' | sort -V | tail -1)" Packages.gz | awk '{print $2}')
            tixeoclient=$(basename "${pool}")

            if wget --timestamping "http://repos.tixeo.com/debian/${pool}"
            then
               if [ -e "${tixeoclient}" ]
               then
                  # Upload package
                  ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/tixeoclient/${dist}/${tixeoclient}" )
                  ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep '/tixeoclient'
               fi
            fi
         fi
      fi
      # Clean old package - kept last 4 (put 4+1=5)
      ls -1t -- tixeoclient_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   done
   }
