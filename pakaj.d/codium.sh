#!/bin/bash
#
## Date: 2018/08/30
## Pakaj: codium
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/VSCodium/vscodium
## Wikipedia: https://en.wikipedia.org/wiki/Visual_Studio_Code
## Description: Codium is the free par of the Visual Studio Code source-code editor
## Binaries: ls tail xargs rm reprepro grep mkdir wget cut head sed
#
# Orther https://carlchenet.com/you-think-the-visual-studio-code-binary-you-use-is-a-free-software-think-again/

function oberpakaj_codium {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/codium"
   cd "$HOME/upload/codium"
   [ -e "releases" ] && mv -f releases releases.old
   wget "https://github.com/VSCodium/vscodium/releases" -O releases
   if [ -e "releases" ]
   then
      codium=$(grep '/codium_.*_amd64.deb' releases | cut -f 2 -d '"' | head -1 | sed -e 's#^/##;')

      if wget --timestamping "https://github.com/${codium}"
      then
         if [ -e "$(basename "${codium}")" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/codium/$(basename "${codium}")" )
            done
            ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep '/codium'
         fi
      fi
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- codium_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
