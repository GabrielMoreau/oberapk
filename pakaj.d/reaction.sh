## Date: 2024/01/10
## Pakaj: reaction
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://framagit.org/ppom
## Description: A daemon that scans program outputs for repeated patterns, and takes action
## Binaries: ls tail xargs rm reprepro grep mkdir head awk wget basename

function oberpakaj_reaction {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/reaction"
   cd "$HOME/upload/reaction"
   PKG_VERSION=1
   version=$(curl -s --insecure -L 'https://framagit.org/api/v4/projects/90566/releases' | sed -e 's/,/\n/g;' | grep '"tag_name"' | cut -f 4 -d '"' | sed -e 's/^v//;' | head -1)
   if echo "${version}" | grep -q '^[[:digit:]][\.[:digit:]][\.[:digit:]]*$'
   then
      package=reaction_${version}_amd64.deb
      curl -s --time-cond --insecure -L "https://static.ppom.me/reaction/releases/v${version}/reaction.deb" -o ${package}

      if [ -e "${package}" ] && file "${package}" | grep 'Debian binary package'
      then
         # Upload package
         for dist in ${distrib}
         do
            ( cd ${REPREPRO} ; reprepro dumpreferences ) 2>/dev/null | grep -q "^${dist}|.*/${package}" || \
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/reaction/${package} )
         done
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/reaction'
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/reaction"
   ls -t reaction_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   }
