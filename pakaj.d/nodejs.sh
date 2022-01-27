# 2018/09/07
# nodejs + npm
# See also https://stackoverflow.com/questions/48943416/bash-npm-command-not-found-in-debian-9-3

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
