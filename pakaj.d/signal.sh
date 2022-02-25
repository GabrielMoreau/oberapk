## Date: 2021/08/19
## Pakaj: signal
## Package: signal-desktop
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://signal.org/
## Wikipedia: https://en.wikipedia.org/wiki/Signal_(software)
## Description: Signal is a cross-platform centralized encrypted instant messaging service
## Binaries: ls tail xargs rm reprepro wget head awk basename grep

function oberpakaj_signal {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/signal"
   cd "$HOME/upload/signal"
   if wget --timestamping "https://updates.signal.org/desktop/apt/dists/xenial/main/binary-amd64/Packages.gz"
   then
      if [ -e "Packages.gz" ]
      then
         pkg_signal=$(zgrep ^Filename Packages.gz | grep '/signal-desktop_' | head -1 | awk '{print $2}')

         wget --timestamping "https://updates.signal.org/desktop/apt/${pkg_signal}"

         if [ -e "$(basename ${pkg_signal})" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/signal/$(basename ${pkg_signal}) )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/signal-desktop'
         fi
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/signal"
   ls -t signal-desktop_*.deb | tail -n +${keep} | xargs -r rm -f
   }
