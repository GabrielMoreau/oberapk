## Date: 2022/01/27
## Pakaj: oberapk
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/oberapk
## Binaries: ls tail xargs rm reprepro grep mkdir git cut pod2man mktemp cut chmod tar ar

function oberpakaj_oberapk {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/oberapk" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/oberapk.git
   fi

   if [ -d "${HOME}/upload/oberapk/.git" ]
   then
      cd "${HOME}/upload/oberapk"
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep '^VERSION=' oberapk | cut -f 2 -d "'")
      PKG_VERSION=$(grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d "=")
      package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

      if [ ! -e "${package}" ]
      then
         ./make-package-debian

         for dist in ${distrib}
         do
           ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/${PKG_NAME}/${package} )
         done
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep -i "/${PKG_NAME}"
      fi
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/oberapk" ]
   then
      cd "${HOME}/upload/oberapk"
      ls -t oberapk_*.deb | tail -n +${keep} | xargs -r rm -f
   fi
   }
