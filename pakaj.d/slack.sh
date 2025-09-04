#!/bin/bash
#
## Date: 2022/04/19
## Pakaj: slack
## Package: slack-desktop
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://slack.com/intl/fr-fr/downloads/linux
## Wikipedia: https://en.wikipedia.org/wiki/Slack_(software)
## Description: Slack Desktop
## Binaries: ls tail xargs rm reprepro grep mkdir wget curl head awk

function oberpakaj_slack {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/slack"
   cd "$HOME/upload/slack"

   wget --timestamping "https://packagecloud.io/slacktechnologies/slack/debian/dists/jessie/main/binary-amd64/Packages"
   if [ -s "Packages" ]
   then
      url='https://packagecloud.io/slacktechnologies/slack/debian/'$(grep ^Filename Packages | grep '/slack-desktop_' | awk '{print $2}' | tail -1)
      #package_file=$(basename ${url})
      package_file='slack-desktop-amd64.deb'
      before=$(stat -c %Y ${package_file} 2> /dev/null || echo 0)
      curl -# --time-cond ${package_file} -o ${package_file} -L "${url}"
      LANG=C file ${package_file} | grep -q 'Debian binary package' || return
      after=$(stat -c %Y ${package_file} 2> /dev/null || echo 0)
      previous_package="$(cat timestamp.sig)"
      if [ ${after} -gt ${before} ] || [ ! -s "${previous_package}" ]
      then
         tmp_folder=$(mktemp --directory /tmp/slack-XXXXXX)
         (cd ${tmp_folder}
            ar -x "$HOME/upload/slack/${package_file}"
            tar -xJf control.tar.xz 
            tar -xJf data.tar.xz
            rm -f data.tar.xz

            version=$(grep '^Version:' control | cut -f 2 -d ' ')
            package=slack-desktop_${version}_amd64.deb

            # On ne met pas le dossier etc dans data
            tar --owner root --group root -czf control.tar.gz control
            tar --owner root --group root -cJf data.tar.xz usr
            ar -r $HOME/upload/slack/${package} debian-binary control.tar.gz data.tar.xz \
               && echo "${package}" > "$HOME/upload/slack/timestamp.sig"
            )

         # Clean
         rm -rf ${tmp_folder}
      fi
   fi

   # Upload package
   package="$(cat timestamp.sig)"
   if [ -s "${package}" ]
   then
      for dist in ${distrib}
      do
         # Upload package
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb ${dist} $HOME/upload/slack/${package} )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep "^${dist}|.*/slack-desktop"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/slack/${dist}"
   ls -1t -- slack-desktop_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
