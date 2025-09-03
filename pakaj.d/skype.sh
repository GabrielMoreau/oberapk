## Date: 2020/09/15
## Pakaj: skype
## Package: skypeforlinux
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.skype.com/
## Wikipedia: https://en.wikipedia.org/wiki/Skype
## Description: Skype is a proprietary telecommunications application for VoIP-based videotelephony, videoconferencing and voice calls
## Obsolete: 2025/05
## Binaries: ls tail xargs rm reprepro grep mkdir wget ar tar awk basename sed mktemp cat file

function oberpakaj_skype {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/skype"
   cd "$HOME/upload/skype"

   url="https://go.skype.com/skypeforlinux-64.deb"
   package_file=$(basename ${url})
   before=$(stat -c %Y ${package_file} 2> /dev/null || echo 0)
   wget --quiet --timestamping "${url}"
   LANG=C file ${package_file} | grep -q 'Debian binary package' || return
   after=$(stat -c %Y ${package_file} 2> /dev/null || echo 0)
   previous_package="$(cat timestamp.sig)"
   if [ ${after} -gt ${before} ] || [ ! -s "${previous_package}" ]
   then
      tmp_folder=$(mktemp --directory /tmp/skype-XXXXXX)
      (cd ${tmp_folder}
         ar -x $HOME/upload/skype/${package_file}
         tar xzf control.tar.gz

         version=$(grep '^Version:' control | awk '{print $2}')
         package=$(grep '^Package:' control | awk '{print $2}')_${version}_amd64.deb

         # Disable Microsoft Repository
         sed -i -e 's/nohup/# nohup/;' postinst

         tar --owner root --group root -czf control.tar.gz control md5sums postinst
         ar -r $HOME/upload/skype/${package} debian-binary control.tar.* data.tar.* \
            && echo "${package}" > "$HOME/upload/skype/timestamp.sig"
         )

      # Clean
      rm -rf ${tmp_folder}
   fi

   # Upload package
   package="$(cat timestamp.sig)"
   if [ -e "${package}" ]
   then
      for dist in ${distrib}
      do
         # Upload package
         ( cd ${REPREPRO} ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/skype/${package} )
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep "^${dist}|.*/skype"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- skypeforlinux_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
