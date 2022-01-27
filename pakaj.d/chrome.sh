# 2021/06/19
# chrome

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
            tar --owner root --group root -cJf control.tar.xz ./control ./postinst ./postrm ./prerm
            )
         ar -r "$HOME/upload/chrome/$(basename ${google_chrome})" ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.xz ${tmp_folder}/data.tar.xz
         rm -rf ${tmp_folder}

         if [ -e "$(basename ${google_chrome})" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/chrome/$(basename ${google_chrome}) )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/google-chrome-stable'
         fi
      fi
   fi
   
   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/chrome"
   ls -t google-chrome-stable_*.deb | tail -n +${keep} | xargs -r rm -f
   }
