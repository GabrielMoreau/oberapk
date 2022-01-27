# 2021/08/19
# spideroak

function oberpakaj_spideroak {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/spideroak"
   cd "$HOME/upload/spideroak"
   if wget --timestamping "https://apt.spideroak.com/ubuntu-spideroak-hardy/dists/release/restricted/binary-amd64/Packages.gz"
   then
      if [ -e "Packages.gz" ]
      then
         pkg_spideroak=$(zgrep ^Filename Packages.gz | grep '/spideroakone_' | head -1 | awk '{print $2}')

         wget --timestamping "https://apt.spideroak.com/ubuntu-spideroak-hardy/${pkg_spideroak}"

         if [ -e "$(basename ${pkg_spideroak})" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/spideroak/$(basename ${pkg_spideroak}) )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/spideroakone'
         fi
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/spideroak"
   ls -t spideroakone_*.deb | tail -n +${keep} | xargs -r rm -f
   }
