## Date: 2022/01/27
## Pakaj: project-meta
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/project-meta

function oberpakaj_project_meta {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/project-meta" ]
   then
      cd "${HOME}/upload/"
      git clone https://gricad-gitlab.univ-grenoble-alpes.fr/legi/soft/trokata/project-meta.git
   fi

   if [ -d "${HOME}/upload/project-meta/.git" ]
   then
      cd "${HOME}/upload/project-meta"
      git pull

      PKG_NAME=$(grep '^PKG_NAME=' make-package-debian | cut -f 2 -d "=")
      CODE_VERSION=$(grep 'version->declare' project-meta | cut -f 2 -d "'")
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
   if [ -d "${HOME}/upload/project-meta" ]
   then
      cd "${HOME}/upload/project-meta"
      ls -t project-meta_*.deb | tail -n +${keep} | xargs -r rm -f
   fi
   }
