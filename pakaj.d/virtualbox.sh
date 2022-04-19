## Date: 2022/04/19
## Pakaj: virtualbox
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.virtualbox.org/wiki/Linux_Downloads
## Wikipedia: https://en.wikipedia.org/wiki/VirtualBox
## Description: VirtualBox is a powerful PC virtualization solution allowing you to run a wide range of PC operating systems on your Linux system.
## Binaries: ls tail xargs rm reprepro grep mkdir wget head awk

function oberpakaj_virtualbox {
   local keep=$1; shift
   local distrib=$*

   for dist in ${distrib}
   do
      mkdir -p "$HOME/upload/virtualbox/${dist}"
      cd "$HOME/upload/virtualbox/${dist}"

      if wget --timestamping "https://download.virtualbox.org/virtualbox/debian/dists/${dist}/contrib/binary-amd64/Packages.gz"
      then
         if [ -e "Packages.gz" ]
         then
            url=$(zgrep ^Filename Packages.gz | grep '/virtualbox-' | head -1 | awk '{print $2}')
            package=$(basename ${url})

            wget --timestamping "https://download.virtualbox.org/virtualbox/debian/${url}"

            if [ -e "${package}" ]
            then
               # Upload package
               ( cd ${REPREPRO} ; reprepro dumpreferences ) 2>/dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/virtualbox/${package} )
            fi
         fi
      fi

      # Clean old package - kept last 4 (put 4+1=5)
      cd "$HOME/upload/virtualbox/${dist}"
      ls -t virtualbox*.deb | tail -n +${keep} | xargs -r rm -f
   done
   }
