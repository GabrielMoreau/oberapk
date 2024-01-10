## Date: 2023/01/23
## Pakaj: opensnitch
## Package: opensnitch python3-opensnitch-ui
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/evilsocket/opensnitch/
## Description: OpenSnitch is a GNU/Linux application firewall
## Binaries: ls tail xargs rm reprepro grep mkdir wget cut head sed

function oberpakaj_opensnitch {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/opensnitch"
   cd "$HOME/upload/opensnitch"
   [ -e "releases" ] && mv -f releases releases.old
   wget -q "https://github.com/evilsocket/opensnitch/releases" -O releases
   if [ -e "releases" ]
   then
      # opensnitch_1.5.2-1_amd64.deb
      # python3-opensnitch-ui_1.5.2-1_all.deb
      for pkg in opensnitch python3-opensnitch-ui
      do
         url=$(egrep "/${pkg}_.*_(amd64|all).deb" releases | cut -f 2 -d '"' | grep -v -- '-rc\.' | head -1)
         package=$(basename ${url})
         wget -q --timestamping "${url}"
         file ${package} | grep -q 'Debian binary package .format 2.0' || { rm -f "${package}"; continue; }
      done
   fi

   for pkg in opensnitch python3-opensnitch-ui
   do
      pkg_real=$(ls -1tr ${pkg}_*.deb | tail -1)
    
      if [ -e "${pkg_real}" ]
      then
         # Upload package
         for dist in ${distrib}
         do
            ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${pkg_real}" || \
              ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/opensnitch/${pkg_real} )
         done
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep 'opensnitch'
      fi
   done

   # Clean old package - kept last 4 (put 4+1=5)
   ls -t opensnitch_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   ls -t python3-opensnitch-ui_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   }
