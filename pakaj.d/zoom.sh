## Date: 2020/04/28
## Pakaj: zoom
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://zoom.us/
## Wikipedia: https://en.wikipedia.org/wiki/Zoom_(software)
## Description: Zoom Meetings is a proprietary video teleconferencing software
## Binaries: ls tail xargs rm reprepro grep mkdir touch basename wget stat mktemp ar tar chmod md5sum du cut file

function oberpakaj_zoom {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/zoom"
   cd "$HOME/upload/zoom"
   [ -e "timestamp.sig" ] \
      || touch -t $(date +%Y)01010000 timestamp.sig

   PKG_VERSION=1
   url="https://zoom.us/client/latest/zoom_amd64.deb"
   package_file=$(basename ${url})
   before=$(stat -c %Y ${package_file} 2> /dev/null || echo 0)
   wget --timestamping "${url}"
   after=$(stat -c %Y ${package_file} 2> /dev/null || echo 0)
   if [ ${after} -gt ${before} ]
   then
      package=$(basename ${url} _amd64.deb)

      tmp_folder=$(mktemp --directory /tmp/zoom-XXXXXX)
      (cd ${tmp_folder}
         ar -x $HOME/upload/zoom/${package}_amd64.deb data.tar.xz control.tar.xz
         tar --preserve-permissions -xJf data.tar.xz
         tar -xJf control.tar.xz

         mkdir -p usr/bin
         cat <<'END' > ./usr/bin/zoom-stop
#!/bin/sh
# 2021/07/17 Gabriel Moreau
# kill zoom
kill $(pgrep --exact zoom -u $LOGNAME)
END
         chmod a+rx ./usr/bin/zoom-stop
         md5sum usr/bin/zoom-stop >> md5sums

         SIZE=$(du -ks --total ./usr ./opt | tail -1 | cut -f 1)
         sed -i -e "s/\(Version: .*\)/\1-${PKG_VERSION}/;
                    s/\(Installed-Size: \).*/\1${SIZE}/;" ./control
         VERSION=$(grep '^Version:' ./control | cut -f 2 -d ' ')

         tar --preserve-permissions --owner root --group root -cJf data.tar.xz ./usr ./opt
         tar --owner root --group root -cJf control.tar.xz ./control ./postinst ./postrm ./md5sums

         echo 2.0 > ${tmp_folder}/debian-binary

         # Create package (control before data)
         ar -r "$HOME/upload/zoom/${package}_${VERSION}_amd64.deb" ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.xz ${tmp_folder}/data.tar.xz \
            && echo "${package}_${VERSION}_amd64.deb" > "$HOME/upload/zoom/timestamp.sig"
            )

      # Clean
      rm -rf ${tmp_folder}
   fi

   # Upload package
   package="$(cat timestamp.sig)"
   if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
   then
      for dist in ${distrib}
      do
         ( cd ${REPREPRO} ; reprepro dumpreferences )  2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/zoom/${package} )
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep "^${dist}|.*/zoom"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -t zoom_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   }
