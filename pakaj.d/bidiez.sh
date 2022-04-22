## Date: 2022/04/21
## Pakaj: bidiez
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/bidiez
## Description: Start or stop computer based on temperature
## Binaries: ls tail xargs rm reprepro grep mkdir git cut make pod2man pod2html mktemp cp ln cat chmod tar ar

function oberpakaj_bidiez {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/bidiez" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/bidiez.git
   fi

   if [ -d "${HOME}/upload/bidiez/.git" ]
   then
      cd "${HOME}/upload/bidiez"
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep 'export VERSION=' bidiez | cut -f 2 -d "=")
      PKG_VERSION=$(grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d "=")
      package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

      if [ ! -e "${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb" ]
      then
         make
         make pkg

         for dist in ${distrib}
         do
           ( cd ${REPREPRO} ; reprepro dumpreferences ) 2>/dev/null | grep -q "^${dist}|.*/${package}" || \
              ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/${PKG_NAME}/${package} )
         done
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep -i "/${PKG_NAME}"
      fi
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/bidiez" ]
   then
      cd "${HOME}/upload/bidiez"
      ls -t bidiez_*.deb | tail -n +${keep} | xargs -r rm -f
   fi
   }
