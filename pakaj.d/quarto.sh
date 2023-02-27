## Date: 2023/02/15
## Pakaj: quarto
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/quarto-dev/quarto-cli
## Description: Quarto is an open-source scientific and technical publishing system built on Pandoc.
## Binaries: ls tail xargs rm reprepro grep mkdir cat wget awk mktemp tar gzip ar chmod

function oberpakaj_quarto {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/quarto"
   [ -e "$HOME/upload/quarto/version" ] || echo '0' > "$HOME/upload/quarto/version"
   cd "$HOME/upload/quarto"

   version_old=$(cat "$HOME/upload/quarto/version")
   version=$(wget --quiet 'https://github.com/quarto-dev/quarto-cli/releases/latest' -O - | grep 'title.Release' | awk '{print $2}' | cut -f 2 -d 'v')
   PKG_VERSION=1
   PKG_NAME=quarto
   package=quarto-${version}-linux-amd64.deb

   if [ "${version}_${PKG_VERSION}" != "${version_old}" ]
   then
      echo "${version}_${PKG_VERSION}" > "$HOME/upload/quarto/version"

      wget --timestamping "https://github.com/quarto-dev/quarto-cli/releases/download/v${version}/${package}"
      if file "${package}" | grep -q 'Debian binary package'
      then
         # Upload package
         for dist in ${distrib}
         do
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/quarto/${package} )
         done
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/quarto'
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -t quarto-*.deb | tail -n +${keep} | xargs -r rm -f
   }
