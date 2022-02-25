## Date: 2018/11/16
## Pakaj: grv
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/rgburke/grv
## Description: Git Repository Viewer is a terminal based interface for viewing Git repositories
## Binaries: ls tail xargs reprepro grep mkdir wget sed head basename cut mktemp cp chmod cp tar ar cat 

function oberpakaj_grv {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/grv"
   cd "$HOME/upload/grv"
   if wget https://github.com/rgburke/grv -O index.html
   then
      if [ -e "index.html" ]
      then
         url=$(grep 'wget -O grv' index.html | sed -e 's/.*\(https:\)/\1/;')
         binary=$(basename $(echo ${url}))
         version=$(echo ${binary} | cut -f 2 -d '_' | sed -e 's/^v//;')

         # Set Name and Version
         PKG_NAME=grv
         CODE_VERSION=$(echo ${binary} | cut -f 2 -d '_' | sed -e 's/^v//;')
         PKG_VERSION=1

         package=${PKG_NAME}_${CODE_VERSION}-${PKG_VERSION}_all.deb

         if [ \( -n "${binary}" -a ! -e "${binary}" \) -o \( -n "${package}" -a ! -e "${package}" \) ]
         then
            rm -f "${binary}" "${package}"
            if wget ${url}
            then
               tmp_folder=$(mktemp --directory /tmp/grv-XXXXXX)
               [ -n "${tmp_folder}" -a -d "${tmp_folder}" ] || exit 1

               # Create future tree
               mkdir -p ${tmp_folder}/usr/bin
               cp ${binary}  ${tmp_folder}/usr/bin/${PKG_NAME}
               chmod -R a+rx ${tmp_folder}/usr/bin/${PKG_NAME}

               # Data archive
               rm -f ${tmp_folder}/data.tar.gz
               (cd ${tmp_folder}; tar --owner root --group root -czf data.tar.gz ./usr)

               # Control file
               cat <<END > ${tmp_folder}/control
Package: ${PKG_NAME}
Version: ${CODE_VERSION}-${PKG_VERSION}
Section: utils
Tag: implemented-in::go, interface::commandline, role::program
Priority: optional
Depends: git
Architecture: all
Installed-Size: $(du -sk ${tmp_folder} | cut -f 1)
Maintainer: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Description: Git Repository Viewer
 GRV is a terminal based interface for viewing Git repositories.
 It allows refs, commits and diffs to be viewed, searched and filtered.
 The behaviour and style can be customised through configuration.
 A query language can be used to filter refs and commits
 .
 Features:
 * Commits and refs can be filtered using a query language.
 * Changes to the repository are captured by monitoring the filesystem allowing the UI to be updated automatically.
 * Organised as tabs and splits. Custom tabs and splits can be created using any combination of views.
 * Vi like keybindings by default, key bindings can be customised.
 * Custom themes can be created.
 * Mouse support.
 * Commit Graph.
Homepage: https://github.com/rgburke/grv
END

               # Control archive
               rm -f ${tmp_folder}/control.tar.gz
               (cd ${tmp_folder}; tar --owner root --group root -czf control.tar.gz control)

               # Format deb package
               echo 2.0 > ${tmp_folder}/debian-binary

               # Create package (control before data)
               ar -r ${package} ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.gz ${tmp_folder}/data.tar.gz
 
               # Clean
               rm -rf ${tmp_folder}

               # Upload package
               for dist in ${distrib}
               do
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/grv/${package} )
               done
               ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/grv'
               #( cd ${REPREPRO} ; reprepro remove stretch grv )
            fi
         fi
      fi   
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -t grv_*.deb | tail -n +${keep} | xargs -r rm -f
   }
