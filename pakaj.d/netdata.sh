# 2019/08/21
# netdata
# See also https://github.com/netdata/netdata and https://packagecloud.io/netdata/netdata-edge/install#manual-deb

function oberpakaj_netdata {
   local keep=$1; shift
   local distrib=$*

   for dist in ${distrib}
   do
      mkdir -p "$HOME/upload/netdata/${dist}"
      cd "$HOME/upload/netdata/${dist}"
      if wget --timestamping "https://packagecloud.io/netdata/netdata-edge/debian/dists/${dist}/main/binary-amd64/Packages.gz"
      then
         if [ -e 'Packages.gz' ]
         then
            pool=$(zgrep 'netdata/netdata_'$(zgrep '^Version:' Packages.gz |awk '{print $2}' | sort -V | tail -1) Packages.gz | awk '{print $2}')
            package=$(basename ${pool})

            if wget --timestamping "https://packagecloud.io/netdata/netdata-edge/debian/${pool}"
            then
               if [ -e "${package}" ]
               then
                  # Upload package
                  ( cd ${REPREPRO} ; reprepro dumpreferences )  2>/dev/null | grep -q "^${dist}|.*/${package}" || \
                     ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/netdata/${dist}/${package} )
                  ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep "^${dist}|.*/netdata"
               fi
            fi
         fi
      fi

      # Clean old package - kept last 4 (put 4+1=5)
      ls -t netdata_*.deb | tail -n +${keep} | xargs -r rm -f
   done
   }
