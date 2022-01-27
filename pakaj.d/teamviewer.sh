# 2020/09/15
# teamviewer

function oberpakaj_teamviewer {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/teamviewer"
   cd "$HOME/upload/teamviewer"

   url="https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
   if wget --quiet --timestamping "${url}"
   then
      package=$(basename ${url})
      
      rm -f control.tar.xz data.tar.xz debian-binary control.tar data.tar control
      ar -x ${package}

      # On ne rajoute pas le depot Teamviewer sur la machine
      unxz data.tar.xz
      tar --delete -f data.tar ./etc/apt/sources.list.d/teamviewer.list
      tar --delete -f data.tar ./etc/apt/sources.list.d
      tar --delete -f data.tar ./etc/apt
      xz data.tar 

      unxz control.tar.xz
      tar --delete  -f control.tar ./conffiles
      tar --extract -f control.tar ./control
      xz control.tar 

      version=$(grep '^Version:' control | awk '{print $2}')
      pkg=$(grep '^Package:' control | awk '{print $2}')_${version}_amd64.deb

      if [ ! -e "${pkg}" ]
      then
         ar -r $HOME/upload/teamviewer/${pkg} debian-binary control.tar.xz data.tar.xz

         for dist in ${distrib}
         do
            # Upload package
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/teamviewer/${pkg} )
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/teamviewer'
         done
      fi
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -t teamviewer_*.deb | tail -n +${keep} | xargs -r rm -f
   }
