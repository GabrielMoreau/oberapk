## Date: 2022/01/27
## Pakaj: kannad
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/kannad

function oberpakaj_kannad {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/kannad" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/kannad.git
   fi

   if [ -d "${HOME}/upload/kannad/.git" ]
   then
      cd "${HOME}/upload/kannad"
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep '^VERSION=' kannad | cut -f 2 -d "'")
      PKG_VERSION=$(grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d "=")
      package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

      if [ ! -e "${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb" ]
      then
         make
         make pkg

         for dist in ${distrib}
         do
           ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/${PKG_NAME}/${package} )
         done
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep -i "/${PKG_NAME}"
      fi
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/kannad" ]
   then
      cd "${HOME}/upload/kannad"
      ls -t kannad_*.deb | tail -n +${keep} | xargs -r rm -f
   fi
   }
