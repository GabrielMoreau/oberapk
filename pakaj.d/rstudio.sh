## Date: 2022/02/19
## Pakaj: rstudio
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.rstudio.com/
## Wikipedia: https://en.wikipedia.org/wiki/RStudio
## Description: RStudio is an Integrated Development Environment (IDE) for R
## Binaries: ls tail xargs rm reprepro grep mkdir wget sed head basename

# Only buster / bionic / bullseye
# https://download1.rstudio.org/desktop/bionic/amd64/rstudio-2022.02.0-443-amd64.deb

function oberpakaj_rstudio {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/rstudio"
   cd "$HOME/upload/rstudio"

   url=$(wget -q 'https://www.rstudio.com/products/rstudio/download/#download' -O - | sed 's/"/\n/g;' | egrep '^https://.*/rstudio-.*-amd64.deb$' | head -1)
   pkgfile=$(basename ${url})
   package=$(echo ${pkgfile} | sed 's/-/_/; s/-/+/;')
   wget --timestamping "${url}"
   if [ -e "${pkgfile}" ]
   then
      for dist in ${distrib}
      do
         ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/rstudio/${pkgfile} )
         ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/${package}"
      done
   fi

   # Clean old package
   basepkg=$(echo "${pkgfile}" | cut -f 1 -d '-')
   ls -t ${basepkg}-*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   }
