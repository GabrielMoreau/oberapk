## Date: 2021/01/19
## Pakaj: ganttproject
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/bardsoftware/ganttproject
## Wikipedia: https://en.wikipedia.org/wiki/GanttProject
## Description: GanttProject is GPL-licensed (free software) Java based, project management software
## Binaries: ls tail xargs rm reprepro grep mkdir wget sed cut tail basename

function oberpakaj_ganttproject {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/ganttproject"
   cd "$HOME/upload/ganttproject"

   url=$(wget --quiet https://dl.ganttproject.biz/ -O - | sed -e 's/Key/\nKey/g;' | grep '^Key>ganttproject-.*.deb' | cut -f 2 -d '>' | cut -f 1 -d '<' | tail -1)
   if wget --quiet --timestamping "https://dl.ganttproject.biz/${url}"
   then
      package=$(basename ${url})
      pkg_basename=$(echo ${package} | cut -f 1 -d '_')
      if [ -s "${package}" ] && LANG=C file "${package}" | grep -q 'Debian binary package' && [ $(ar t "${package}" | wc -l) -ge 3 ]
      then
         for dist in ${distrib}
         do
            # Upload package
            ( cd ${REPREPRO} ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/ganttproject/${package} )
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep "^${dist}|.*/${pkg_basename}"
         done
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- ganttproject_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
