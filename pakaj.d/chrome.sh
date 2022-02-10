# 2021/06/19
# chrome
# bin: ls tail xargs reprepro wget head awk basename cut mktemp du sed tar ar rm grep

function oberpakaj_chrome {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/chrome"
   cd "$HOME/upload/chrome"
   if wget --timestamping "https://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/Packages.gz"
   then
      if [ -e "Packages.gz" ]
      then
         google_chrome=$(zgrep ^Filename Packages.gz | grep '/google-chrome-stable/' | head -1 | awk '{print $2}')

         wget --timestamping "https://dl.google.com/linux/chrome/deb/${google_chrome}"
         count=$(($(echo $(basename ${google_chrome}) | cut -f 4 -d '-' | cut -f 1 -d '_') + 1))
         version=$(basename ${google_chrome} | cut -f 3 -d '-' | cut -f 2 -d '_')
         package="google-chrome-stable_${version}-${count}_amd64.deb"

         # chrome
         tmp_folder=$(mktemp --directory /tmp/chrome-XXXXXX)
         (cd ${tmp_folder}
            ar -x "$HOME/upload/chrome/$(basename ${google_chrome})"
            tar -xJf control.tar.xz 
            sed -i 's/^\(#!\/bin\/\)sh/\1bash/; s/^\([[:space:]]*\)nohup /\1# nohup /;' postinst
            cat <<'END' >> postinst
if [ -e "/etc/cron.daily/google-chrome" ]; then
  rm -f /etc/cron.daily/google-chrome
fi
END
            size=$(du -ks ${tmp_folder} | cut -f 1)
            sed -i -e "s/^Installed-Size: .*$/Installed-Size: ${size}/;
                       s/^Version: .*$/Version: ${version}-${count}/;" control
            tar --owner root --group root -cJf control.tar.xz ./control ./postinst ./postrm ./prerm
            )
         ar -r "${package}" ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.xz ${tmp_folder}/data.tar.xz
         rm -rf ${tmp_folder}

         if [ -e "${package}" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro dumpreferences )  2>/dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/chrome/${package} )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/google-chrome-stable'
         fi
      fi
   fi
   
   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/chrome"
   ls -t google-chrome-stable_*.deb | tail -n +${keep} | xargs -r rm -f
   }
