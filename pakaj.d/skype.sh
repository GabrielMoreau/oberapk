## Date: 2020/09/15
## Pakaj: skype
## Package: skypeforlinux
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.skype.com/
## Wikipedia: https://en.wikipedia.org/wiki/Skype
## Description: Skype is a proprietary telecommunications application for VoIP-based videotelephony, videoconferencing and voice calls
## Binaries: ls tail xargs rm reprepro grep mkdir wget ar tar awk basename sed

function oberpakaj_skype {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/skype"
   cd "$HOME/upload/skype"

   url="https://go.skype.com/skypeforlinux-64.deb"
   if wget --quiet --timestamping "${url}"
   then
      package=$(basename ${url})
      
      rm -f control control.tar.* data.tar.* debian-binary md5sums postinst
      ar -x ${package}
      tar xzf control.tar.gz

      version=$(grep '^Version:' control | awk '{print $2}')
      pkg=$(grep '^Package:' control | awk '{print $2}')_${version}_amd64.deb
      
      if [ ! -e "${pkg}" ]
      then
         # On ne rajoute pas le depot Microsoft sur la machine
         sed -i -e 's/nohup/# nohup/;' postinst
         tar --owner root --group root -czf control.tar.gz control md5sums postinst
         ar -r $HOME/upload/skype/${pkg} debian-binary control.tar.* data.tar.*

         for dist in ${distrib}
         do
            # Upload package
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/skype/${pkg} )
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/skype'
         done
      fi
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -t skypeforlinux_*.deb | tail -n +${keep} | xargs -r rm -f
   }
