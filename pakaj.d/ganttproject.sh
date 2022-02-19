## Date: 2021/01/19
## Pakaj: ganttproject
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/bardsoftware/ganttproject

function oberpakaj_ganttproject {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/ganttproject"
   cd "$HOME/upload/ganttproject"

   url=$(wget --quiet https://dl.ganttproject.biz/ -O - | sed -e 's/Key/\nKey/g;' | grep '^Key>ganttproject-.*.deb' | cut -f 2 -d '>' | cut -f 1 -d '<' | tail -1)
   if wget --quiet --timestamping "https://dl.ganttproject.biz/${url}"
   then
      pkg=$(basename ${url})
      if [ -e "${pkg}" ]
      then
         for dist in ${distrib}
         do
            # Upload package
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/ganttproject/${pkg} )
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/ganttproject'
         done
      fi
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -t ganttproject_*.deb | tail -n +${keep} | xargs -r rm -f
   }
