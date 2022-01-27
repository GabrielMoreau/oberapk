# 2022/01/27
# klask
# See also https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/klask

function oberpakaj_klask {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/klask" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/klask.git
   fi

   if [ -d "${HOME}/upload/klask/.git" ]
   then
      cd "${HOME}/upload/klask"
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep 'version->declare' klask | cut -f 2 -d "'")
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
   if [ -d "${HOME}/upload/klask" ]
   then
      cd "${HOME}/upload/klask"
      ls -t klask_*.deb | tail -n +${keep} | xargs -r rm -f
   fi
   }
