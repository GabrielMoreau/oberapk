## Date: 2023/10/05
## Pakaj: protonmail
## Description: Proton Mail Bridge is a desktop application encrypting and decrypting messages
## Package: protonmail-bridge
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://proton.me
## Binaries: ls tail xargs rm reprepro grep mkdir sort cut wget basename

function oberpakaj_protonmail {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/protonmail"
   cd "$HOME/upload/protonmail"

   url=$(wget -q 'https://proton.me/download/current_version_linux.json' -O - | grep 'protonmail-bridge.*_amd64.deb' | cut -f 4 -d '"')
   version=$(echo ${url} | cut -f 2 -d '_')
   package=$(basename ${url})
   wget --timestamping "${url}"
   if [ -e "${package}" ]
   then
      for dist in ${distrib}
      do
         ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/protonmail/${package} )
      done
   fi

   # Clean old package
   basepkg=$(echo "${package}" | cut -f 1 -d '_')
   ls -1t -- ${basepkg}_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
   }
