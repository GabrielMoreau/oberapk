## Date: 2024/04/03
## Pakaj: webex
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.webex.com/downloads.html
## Description: Webex for Linux
## Binaries: ls tail xargs rm reprepro grep mkdir wget ar tar awk basename sed mktemp cat file

function oberpakaj_webex {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/webex"
   cd "$HOME/upload/webex"

   package=''
   url='https://binaries.webex.com/WebexDesktop-Ubuntu-Official-Package/Webex.deb'
   package_file=$(basename ${url})
   before=$(stat -c %Y ${package_file} 2> /dev/null || echo 0)
   wget --quiet --timestamping "${url}"
   LANG=C file ${package_file} | grep -q 'Debian binary package' || return
   after=$(stat -c %Y ${package_file} 2> /dev/null || echo 0)
   previous_package="$(cat timestamp.sig)"
   if [ ${after} -gt ${before} ] || [ ! -s "${previous_package}" ]
   then
      tmp_folder=$(mktemp --directory /tmp/webex-XXXXXX)
      (cd ${tmp_folder}
         ar -x $HOME/upload/webex/${package_file}
         tar xzf control.tar.gz
         )

      version=$(grep '^Version:' ${tmp_folder}/control | awk '{print $2}')
      package=$(grep '^Package:' ${tmp_folder}/control | awk '{print $2}')_${version}_amd64.deb
      cp -a ${package_file} ${package}
      [ -s "${package}" ] && echo "${package}" > 'timestamp.sig'

      # Clean
      rm -rf ${tmp_folder}
   fi

   # Upload package
   [ -s 'timestamp.sig' ] && package="$(cat timestamp.sig)"
   if [ -s "${package}" ]
   then
      for dist in ${distrib}
      do
         # Upload package
         ( cd ${REPREPRO} ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/webex/${package} )
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep "^${dist}|.*/webex"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- webex_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
