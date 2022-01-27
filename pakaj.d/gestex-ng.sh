# 2022/01/27
# gestex
# See also https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/gestex

function oberpakaj_gestex_ng {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/gestex" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/gestex.git
   fi

   if [ -d "${HOME}/upload/gestex/.git" ]
   then
      cd "${HOME}/upload/gestex"
      git checkout devel
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")"-ng"
      CODE_VERSION=$(grep GESTEX_VERSION module/base-functions.php | cut -f 4 -d "'")'.'$(date '+%y%j')
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
   if [ -d "${HOME}/upload/gestex" ]
   then
      cd "${HOME}/upload/gestex"
      ls -t gestex-ng_*.deb | tail -n +${keep} | xargs -r rm -f
   fi
   }
