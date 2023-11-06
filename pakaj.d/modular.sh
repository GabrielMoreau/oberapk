## Date: 2023/11/06
## Pakaj: modular
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.modular.com/
## Wikipedia: https://en.wikipedia.org/wiki/Mojo_(programming_language)
## Description: Package manager for the Mojo programming language (largely compatible with Python)
## Binaries: ls tail xargs rm reprepro grep mkdir wget head awk

function oberpakaj_modular {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/modular"
   cd "$HOME/upload/modular"
   PKG_VERSION=1
   if wget --timestamping "https://dl.modular.com/public/installer/deb/debian/dists/wheezy/main/binary-amd64/Packages.gz"
   then
      if [ -e "Packages.gz" ]
      then
         modular=$(zgrep ^Filename Packages.gz | grep '/modular-' | head -1 | awk '{print $2}')
echo "https://dl.modular.com/public/installer/deb/debian/${modular}"
         wget --timestamping "https://dl.modular.com/public/installer/deb/debian/${modular}"

         if [ -e "$(basename ${modular})" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/modular/$(basename ${modular}) )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/modular'
         fi
      fi
   fi
   
   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/modular"
   ls -t modular_*.deb | tail -n +${keep} | xargs -r rm -f
   }
