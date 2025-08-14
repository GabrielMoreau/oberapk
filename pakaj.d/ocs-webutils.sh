## Date: 2022/01/27
## Pakaj: ocs-webutils
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ocs-webutils
## Description: DDT is a simple IP Address Management (IPAM) service
## Binaries: ls tail xargs rm reprepro grep mkdir git cut make pod2man pod2html mktemp cp ln cat chmod tar ar

function oberpakaj_ocs-webutils {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/ocs-webutils" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/ocs-webutils.git
   fi

   if [ -d "${HOME}/upload/ocs-webutils/.git" ]
   then
      cd "${HOME}/upload/ocs-webutils"
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep '__version__' ocs-pkgpush | cut -f 2 -d '"')
      PKG_VERSION=$(grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d "=")
      package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

      if [ ! -e "${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb" ]
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
   if [ -d "${HOME}/upload/ocs-webutils" ]
   then
      cd "${HOME}/upload/ocs-webutils"
      ls -t ocs-webutils_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   fi
   }
