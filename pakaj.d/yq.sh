# 2022/01/25
# yq
# See also https://github.com/mikefarah/yq

function oberpakaj_yq {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/yq"
   [ -e "$HOME/upload/yq/version" ] || echo '0' > "$HOME/upload/yq/version"
   cd "$HOME/upload/yq"

   version_old=$(cat "$HOME/upload/yq/version")
   version=$(wget --quiet 'https://github.com/mikefarah/yq/releases/latest' -O - | grep 'title.Release' | awk '{print $2}' | cut -f 2 -d 'v')
   PKG_VERSION=2
   PKG_NAME=yq
   package=${PKG_NAME}_${version}-${PKG_VERSION}_amd64.deb

   if [ "${version}_${PKG_VERSION}" != "${version_old}" ]
   then
      echo "${version}_${PKG_VERSION}" > "$HOME/upload/yq/version"

      wget --timestamping "https://github.com/mikefarah/yq/releases/download/v${version}/yq_linux_amd64.tar.gz"
      if [ -s "yq_linux_amd64.tar.gz" ]
      then
         tmp_folder=$(mktemp --directory /tmp/yq-XXXXXX)
         [ -n "${tmp_folder}" -a -d "${tmp_folder}" ] || exit 1

         # Create future tree
         mkdir -p ${tmp_folder}/usr/bin
         mkdir -p ${tmp_folder}/usr/share/man/man1

         (cd ${tmp_folder}/; tar xzf $HOME/upload/yq/yq_linux_amd64.tar.gz)

         gzip -c ${tmp_folder}/yq.1    > ${tmp_folder}/usr/share/man/man1/yq.1.gz
         mv ${tmp_folder}/yq_linux_amd64 ${tmp_folder}/usr/bin/yq
         chmod    a+rx ${tmp_folder}/usr/bin/yq
         chmod -R a+rX ${tmp_folder}/usr

         # Data archive
         rm -f ${tmp_folder}/data.tar.gz
         (cd ${tmp_folder}; tar --owner root --group root -czf data.tar.gz ./usr)

         # Control file
         cat <<END > ${tmp_folder}/control
Package: ${PKG_NAME}
Version: ${version}-${PKG_VERSION}
Section: text
Priority: optional
Depends: bash
Architecture: amd64
Installed-Size: $(du -ks ${tmp_folder}/usr|cut -f 1)
Maintainer: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Description: a lightweight and portable command-line YAML, JSON and XML processor.
 yq uses jq like syntax but works with yaml files as well as json and xml.
 It doesn't yet support everything jq does - but it does support the most
 common operations and functions, and more is being added continuously.
 .
 Features:
  * Detailed documentation with many examples
  * Written in portable go, so you can download a lovely dependency free binary
  * Uses similar syntax as jq but works with YAML, JSON and XML files
  * Fully supports multi document yaml files
  * Supports yaml front matter blocks (e.g. jekyll/assemble)
  * Colorized yaml output
  * Deeply data structures
  * Sort keys
  * Manipulate yaml comments, styling, tags and anchors and aliases.
  * Update inplace
  * Complex expressions to select and update
  * Keeps yaml formatting and comments when updating (though there are issues with whitespace)
  * Load content from other files
  * Convert to/from json
  * Convert to/from xml
  * Convert to properties
  * Convert to csv/tsv
  * Pipe data in by using '-'
  * General shell completion scripts (bash/zsh/fish/powershell)
  * Reduce to merge multiple files or sum an array or other fancy things.
  * Github Action to use in your automated pipeline
Homepage: https://github.com/mikefarah/yq
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
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/yq/${package} )
         done
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/yq'
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -t yq_*.deb | tail -n +${keep} | xargs -r rm -f
   }
