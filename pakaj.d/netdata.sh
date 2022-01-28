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
            pool=$(zgrep 'netdata/netdata_'$(zgrep '^Version:' Packages.gz | awk '{print $2}' | sort -V | tail -1) Packages.gz | awk '{print $2}')
            upload_pkg=$(basename ${pool})
            package=$(echo ${upload_pkg} | sed -e "s/nightly/${dist}/;")

            if wget --timestamping "https://packagecloud.io/netdata/netdata-edge/debian/${pool}"
            then
               if [ -e "${upload_pkg}" ]
               then
                  if [ ! -e "${package}" ]
                  then
                     tmp_folder=$(mktemp --directory /tmp/netdata-XXXXXX)
                     (cd ${tmp_folder}
                        ar -x "$HOME/upload/netdata/${dist}/${upload_pkg}"
                        tar -xJf control.tar.xz
                        sed -i -e "s/nightly/${dist}/;" control
                        tar --owner root --group root -cJf control.tar.xz ./conffiles ./control ./md5sums ./postinst ./postrm ./preinst ./prerm
                        )
                     ar -r "$HOME/upload/netdata/${dist}/${package}" ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.xz ${tmp_folder}/data.tar.xz
                     rm -rf ${tmp_folder}
                  fi

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
