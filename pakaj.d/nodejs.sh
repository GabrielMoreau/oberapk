## Date: 2018/09/07
## Pakaj: nodejs + npm
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://stackoverflow.com/questions/48943416/bash-npm-command-not-found-in-debian-9-3
## Wikipedia: https://en.wikipedia.org/wiki/Node.js
## Description: Node.js is an open-source, cross-platform, back-end JavaScript runtime environment that runs on the V8 engine and executes JavaScript code outside a web browser
## Binaries: ls tail xargs rm reprepro grep mkdir wget cut sort

function oberpakaj_nodejs {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/nodejs"
   cd "$HOME/upload/nodejs"
   if wget https://deb.nodesource.com/node_10.x/pool/main/n/nodejs/ -O index.html
   then
      if [ -e "index.html" ]
      then
         package=$(grep '_amd64.deb' index.html | cut -f 2 -d '"' | sort --version-sort --field-separator=_ --key=2 | tail -1)
         if [ -n "${package}" -a ! -e "${package}" ]
         then
            if wget --timestamping https://deb.nodesource.com/node_10.x/pool/main/n/nodejs/${package}
            then
               # Upload package
               for dist in ${distrib}
               do
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/nodejs/${package} )
               done
               ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/nodejs'
            fi
         fi
      fi
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -t nodejs_*.deb | tail -n +${keep} | xargs -r rm -f
   }
