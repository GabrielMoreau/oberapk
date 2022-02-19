## Date: 2020/03/11
## Pakaj: zotero
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.zotero.org/

function oberpakaj_zotero {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/zotero"
   [ -e "$HOME/upload/zotero/version" ] || echo '0' > "$HOME/upload/zotero/version"
   cd "$HOME/upload/zotero"
   
   version_old=$(cat "$HOME/upload/zotero/version")
   version=$(curl --silent https://www.zotero.org/download/ -o - | grep  'standaloneVersions' | sed -e 's/,/\n/g;' | grep 'linux-x86_64' | cut -f 4 -d '"' | grep '^[[:digit:]]' | head -1)
   PKG_VERSION=2
   PKG_NAME=zotero-latest
   package=${PKG_NAME}_${version}-${PKG_VERSION}_amd64.deb

   if [ "${version}_${PKG_VERSION}" != "${version_old}" ]
   then
      echo "${version}_${PKG_VERSION}" > "$HOME/upload/zotero/version"

      curl "https://download.zotero.org/client/release/${version}/Zotero-${version}_linux-x86_64.tar.bz2" -o "Zotero-${version}_linux-x86_64.tar.bz2"

      if [ -s "Zotero-${version}_linux-x86_64.tar.bz2" ]
      then
         tmp_folder=$(mktemp --directory /tmp/zotero-XXXXXX)
         [ -n "${tmp_folder}" -a -d "${tmp_folder}" ] || exit 1

         # Create future tree
         mkdir -p ${tmp_folder}/usr/bin
         mkdir -p ${tmp_folder}/usr/lib
         mkdir -p ${tmp_folder}/usr/share/applications

         (cd ${tmp_folder}/usr/lib; tar xjf $HOME/upload/zotero/Zotero-${version}_linux-x86_64.tar.bz2)
         mv ${tmp_folder}/usr/lib/Zotero_linux-x86_64 ${tmp_folder}/usr/lib/zotero-latest
         mv ${tmp_folder}/usr/lib/zotero-latest/zotero.desktop ${tmp_folder}/usr/share/applications/

         sed -i -e '
            s|^Exec=.*$|Exec=bash -c "/usr/bin/zotero -url %U"|;
            s|^Icon=.*$|Icon=/usr/lib/zotero-latest/chrome/icons/default/main-window.ico|;
            ' ${tmp_folder}/usr/share/applications/zotero.desktop

         cat << 'END_EXEC' > ${tmp_folder}/usr/bin/zotero
#!/bin/bash

CALLDIR="/usr/lib/zotero-latest"
exec "$CALLDIR/zotero-bin" -app "$CALLDIR/application.ini" "$@"
END_EXEC
         chmod    a+rx ${tmp_folder}/usr/bin/zotero
         chmod -R a+rX ${tmp_folder}/usr

         # Data archive
         rm -f ${tmp_folder}/data.tar.gz
         (cd ${tmp_folder}; tar --owner root --group root -czf data.tar.gz ./usr)

         # Control file
         cat <<END > ${tmp_folder}/control
Package: zotero-latest
Version: ${version}-${PKG_VERSION}
Section: text
Priority: optional
Depends: firefox-esr | firefox
Architecture: amd64
Installed-Size: $(du -ks ${tmp_folder}/usr|cut -f 1)
Maintainer: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Description: organize and share your research sources (bibliography)
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
         rm -f ${tmp_folder}/control.tar.gz
         (cd ${tmp_folder}; tar --owner root --group root -czf control.tar.gz control)

         # Format deb package
         echo 2.0 > ${tmp_folder}/debian-binary

         # Create package (control before data)
         ar -r ${package} ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.gz ${tmp_folder}/data.tar.gz
 
         # Clean
         rm -rf ${tmp_folder}

         # Upload package
         for dist in ${distrib}
         do
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/zotero/${package} )
         done
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/zotero'
      fi
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -t zotero_*.deb                  | tail -n +${keep} | xargs -r rm -f
   ls -t Zotero-*_linux-x86_64.tar.bz2 | tail -n +${keep} | xargs -r rm -f
   }
