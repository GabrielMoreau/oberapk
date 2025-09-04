#!/bin/bash
#
## Date: 2020/03/12
## Pakaj: yed
## Package: yed-latest
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.yworks.com/products/yed
## Wikipedia: https://en.wikipedia.org/wiki/YEd
## Description: yEd is a powerful desktop application that can be used to quickly and effectively generate high-quality diagrams
## Binaries: ls tail xargs rm reprepro grep mkdir cat curl sed head mktemp unzip chmod tar ar

function oberpakaj_yed {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/yed"
   [ -e "$HOME/upload/yed/version" ] || echo '0' > "$HOME/upload/yed/version"
   cd "$HOME/upload/yed"
   
   version_old=$(cat "$HOME/upload/yed/version")
   version=$(curl --silent https://www.yworks.com/products/yed/download -o - | sed -e 's#[[:space:]/_]#\n#g;' | grep -E '^yEd-[[:digit:]]' | head -1 | cut -f 2 -d '-')
   PKG_VERSION=2
   PKG_NAME=yed-latest
   package=${PKG_NAME}_${version}-${PKG_VERSION}_all.deb

   if [ "${version}_${PKG_VERSION}" != "${version_old}" ]
   then
      echo "${version}_${PKG_VERSION}" > "$HOME/upload/yed/version"

      curl "https://www.yworks.com/resources/yed/demo/yEd-${version}.zip" -o "yEd-${version}.zip"

      if [ -s "yEd-${version}.zip" ]
      then
         tmp_folder=$(mktemp --directory /tmp/yed-XXXXXX)
         [ -n "${tmp_folder}" -a -d "${tmp_folder}" ] || exit 1

         # Create future tree
         mkdir -p "${tmp_folder}/usr/bin"
         mkdir -p "${tmp_folder}/usr/lib"
         mkdir -p "${tmp_folder}/usr/share/applications"

         (cd "${tmp_folder}/usr/lib"; unzip -q "$HOME/upload/yed/yEd-${version}.zip")
         mv "${tmp_folder}/usr/lib/yed-${version}" "${tmp_folder}/usr/lib/yed-latest"

         cat << 'END_DESK' > "${tmp_folder}/usr/share/applications/yed.desktop"
[Desktop Entry]
Name=yEd Graph Editor
Exec=bash -c "yed %f"
Icon=/usr/lib/yed-latest/icons/yed.ico
Type=Application
Terminal=false
Categories=Graphics;2DGraphics;FlowChart;VectorGraphics;
MimeType=application/graphml+xml
END_DESK

         cat << 'END_EXEC' > "${tmp_folder}/usr/bin/yed"
#!/bin/bash
#
exec java -jar /usr/lib/yed-latest/yed.jar
END_EXEC
         chmod    a+rx "${tmp_folder}/usr/bin/yed"
         chmod -R a+rX "${tmp_folder}/usr"

         # Data archive
         rm -f "${tmp_folder}/data.tar.gz"
         (cd "${tmp_folder}"; tar --owner root --group root -czf data.tar.gz ./usr)

         # Control file
         cat <<END > "${tmp_folder}/control"
Package: ${PKG_NAME}
Version: ${version}-${PKG_VERSION}
Section: graphics
Priority: optional
Depends: default-jre | java6-runtime
Architecture: all
Installed-Size: $(du -ks "${tmp_folder}/usr"|cut -f 1)
Maintainer: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Description: yEd Graph Editor
 yEd is a powerful desktop application that can be used to quickly
 and effectively generate high-quality diagrams.
 Create diagrams manually, or import your external data for analysis.
 Our automatic layout algorithms arrange even large data sets with
 just the press of a button.
 .
 yEd is freely available and runs on all major platforms: Windows,
 Unix/Linux, and macOS.
Homepage: https://www.yworks.com/products/yed
Tag: implemented-in::java, interface::graphical, interface::x11,
 x11::application
END

         # Control archive
         rm -f "${tmp_folder}/control.tar.gz"
         (cd "${tmp_folder}"; tar --owner root --group root -czf control.tar.gz control)

         # Format deb package
         echo 2.0 > "${tmp_folder}/debian-binary"

         # Create package (control before data)
         ar -r "${package}" "${tmp_folder}/debian-binary" "${tmp_folder}/control.tar.gz" "${tmp_folder}/data.tar.gz"
 
         # Clean
         rm -rf "${tmp_folder}"

         # Upload package
         # Upload package
         for dist in ${distrib}
         do
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/yed/${package}" )
         done
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep '/yed'
      fi
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- ${PKG_NAME}_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   ls -1t -- yEd-*.zip 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
