## Date: 2022/04/21
## Pakaj: freskein
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/freskein
## Description: Recursive removal of execution rights on non-executable files
## Binaries: ls tail xargs rm reprepro grep mkdir git cut make pod2man pod2html mktemp cp ln cat chmod tar ar

function oberpakaj_freskein {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/freskein" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/freskein.git
   fi

   if [ -d "${HOME}/upload/freskein/.git" ]
   then
      cd "${HOME}/upload/freskein"
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep 'export VERSION=' freskein | cut -f 2 -d "=")
      PKG_VERSION=$(grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d "=")
      package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

      if [ ! -e "${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb" ]
      then
         make
         make pkg

         for dist in ${distrib}
         do
           ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
              ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/${PKG_NAME}/${package} )
         done
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep -i "/${PKG_NAME}"
      fi
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/freskein" ]
   then
      cd "${HOME}/upload/freskein"
      ls -t freskein_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   fi
   }
