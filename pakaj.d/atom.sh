## Date: 2022/02/17
## Pakaj: atom
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/atom/atom
## Binaries: ls tail xargs rm reprepro grep mkdir sort cut wget basename

# beta quality - this packaging has not been test on a real life


function oberpakaj_atom {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/atom"
   cd "$HOME/upload/atom"

   poolfile=$(wget -q 'https://packagecloud.io/AtomEditor/atom/any/dists/any/main/binary-amd64/Packages.gz' -O - | zgrep '^Filename: pool/any/main/a/atom/atom_.*.deb' | sort -u | tail -1 | cut -f 2 -d ' ')
   package=$(basename ${poolfile})
   wget --timestamping "https://packagecloud.io/AtomEditor/atom/any/${poolfile}"
   if [ -e "${package}" ]
   then
      for dist in ${distrib}
      do
         ( cd ${REPREPRO} ; reprepro dumpreferences ) 2>/dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/atom/${package} )
      done
   fi

   # Clean old package
   basepkg=$(echo "${package}" | cut -f 1 -d '_')
   ls -t ${basepkg}_*.deb | tail -n +${keep} | xargs -r rm -f
   }
