#!/bin/bash
#
## Date: 2020/03/11
## Pakaj: zotero
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.zotero.org/
## Wikipedia: https://en.wikipedia.org/wiki/Zotero
## Description: Zotero is a free and open-source reference management software to manage bibliographic data and related research materials
## Binaries: ls tail xargs reprepro grep mkdir curl sed cut head mktemp tar mv chmod rm tar ar cat

function oberpakaj_zotero {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/zotero"
   [ -e "$HOME/upload/zotero/version" ] || echo '0' > "$HOME/upload/zotero/version"
   cd "$HOME/upload/zotero" || return
   
   version_old=$(cat "$HOME/upload/zotero/version")
   version=$(curl --silent https://www.zotero.org/download/ -o - | grep  'standaloneVersions' | sed -e 's/,/\n/g;' | grep 'linux-x86_64' | cut -f 4 -d '"' | grep '^[[:digit:]]' | head -1)
   PKG_VERSION=3
   PKG_NAME=zotero-latest
   package=${PKG_NAME}_${version}-${PKG_VERSION}_amd64.deb

   if [ "${version}_${PKG_VERSION}" != "${version_old}" ]
   then
      echo "${version}_${PKG_VERSION}" > "$HOME/upload/zotero/version"

      curl "https://download.zotero.org/client/release/${version}/Zotero-${version}_linux-x86_64.tar.bz2" -o "Zotero-${version}_linux-x86_64.tar.bz2"

      if [ -s "Zotero-${version}_linux-x86_64.tar.bz2" ]
      then
         tmp_folder=$(mktemp --directory /tmp/zotero-XXXXXX)
         if [ -z "$tmp_folder" ] || [ ! -d "$tmp_folder" ]
         then
            return
         fi

         # Create future tree
         mkdir -p "${tmp_folder}/usr/bin"
         mkdir -p "${tmp_folder}/usr/lib"
         mkdir -p "${tmp_folder}/usr/share/applications"

         (cd "${tmp_folder}/usr/lib" || return; tar xjf "$HOME/upload/zotero/Zotero-${version}_linux-x86_64.tar.bz2")
         mv "${tmp_folder}/usr/lib/Zotero_linux-x86_64" "${tmp_folder}/usr/lib/zotero-latest"
         mv "${tmp_folder}/usr/lib/zotero-latest/zotero.desktop" "${tmp_folder}/usr/share/applications/"

         sed -i -e '
            s|^Exec=.*$|Exec=bash -c "/usr/bin/zotero -url %U"|;
            s|^Icon=.*$|Icon=/usr/lib/zotero-latest/chrome/icons/default/main-window.ico|;
            ' "${tmp_folder}/usr/share/applications/zotero.desktop"

         cat << 'END_EXEC' > "${tmp_folder}/usr/bin/zotero"
#!/bin/bash

CALLDIR="/usr/lib/zotero-latest"
exec "$CALLDIR/zotero-bin" -app "$CALLDIR/app/application.ini" "$@"
END_EXEC
         chmod    a+rx "${tmp_folder}/usr/bin/zotero"
         chmod -R a+rX "${tmp_folder}/usr"

         # Data archive
         rm -f "${tmp_folder}/data.tar.gz"
         (cd "${tmp_folder}" || return; tar --owner root --group root -czf data.tar.gz ./usr)

         # Control file
         cat <<END > "${tmp_folder}/control"
Package: zotero-latest
Version: ${version}-${PKG_VERSION}
Section: text
Priority: optional
Depends: firefox-esr | firefox, libegl1|libwayland-egl1, libegl-mesa0, libasound2, libatk1.0-0, libc6, libcairo-gobject2, libcairo2, libdbus-1-3, libdbus-glib-1-2, libfontconfig1, libfreetype6, libgdk-pixbuf2.0-0, libglib2.0-0, libgtk-3-0, libharfbuzz0b, libpango-1.0-0, libpangocairo-1.0-0, libstdc++6, libx11-6, libx11-xcb1, libxcb-shm0, libxcb1, libxcomposite1, libxcursor1, libxdamage1, libxext6, libxfixes3, libxi6, libxrandr2, libxrender1, libxtst6, gnupg
Architecture: amd64
Installed-Size: $(du -ks "${tmp_folder}/usr"|cut -f 1)
Maintainer: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Description: collect, organize and share your research sources (bibliography)
 Zotero helps you collect, manage, and cite your research sources.
 .
 Zotero allows you to store your libraries online, so that they can be
 accessed from any computer. Your online collections can also be shared with
 other Zotero users, letting you collaboratively create bibliographies and
 research notes. It can automatically gather bibliographic information about
 resources available in hundreds of databases, library catalogs and the web.
 .
 This package contains the standalone version of Zotero which does not
 run within the Firefox browser (though it still uses its engine).
Homepage: http://www.zotero.org/
END

         # Control archive
         rm -f "${tmp_folder}/control.tar.gz"
         (cd "${tmp_folder}" || return; tar --owner root --group root -czf control.tar.gz control)

         # Format deb package
         echo 2.0 > "${tmp_folder}/debian-binary"

         # Create package (control before data)
         ar -r "${package}" "${tmp_folder}/debian-binary" "${tmp_folder}/control.tar.gz" "${tmp_folder}/data.tar.gz"
 
         # Clean
         rm -rf "${tmp_folder}"
      fi
   fi

   if [ -s "${package}" ]
   then
      # Upload package
      for dist in ${distrib}
      do
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/zotero/${package}" )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/zotero"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- zotero-latest_*.deb           2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   ls -1t -- Zotero-*_linux-x86_64.tar.bz2 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
