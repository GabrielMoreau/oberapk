#!/bin/bash
#
## Date: 2021/10/07
## Pakaj: master-pdf-editor
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://code-industry.net/free-pdf-editor/
## Description: Master PDF Editor is the optimal solution for editing PDF files in Linux
## Binaries: ls tail xargs reprepro grep mkdir wget sed head basename

# Other https://www.linuxuprising.com/2019/04/download-master-pdf-editor-4-for-linux.html

function oberpakaj_masterpdf {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/masterpdf"
   cd "$HOME/upload/masterpdf"
   # Version 4
   package=master-pdf-editor-4.3.89_qt5.amd64.deb
   url="http://code-industry.net/public/${package}"
   # Version 5
   #url=$(wget -q https://code-industry.net/free-pdf-editor/ -O - | sed -e 's/"/\n/g;' | grep '^https://.*master-pdf-editor.*.deb$' | head -1)
   #package=$(basename "${url}")
   if wget --timestamping "${url}"
   then
      if [ -e "${package}" ]
      then
         # Upload package
         for dist in ${distrib}
         do
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/masterpdf/${package}" )
         done
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep '/master-pdf-editor'
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/masterpdf"
   ls -1t -- master-pdf-editor-*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
