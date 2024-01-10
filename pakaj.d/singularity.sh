## Date: 2023/02/27
## Pakaj: singularity
## Package: singularity-container
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://docs.sylabs.io/guides/3.0/user-guide/installation.html
## Wikipedia: https://en.wikipedia.org/wiki/Singularity_(software)
## Description: Container platform focused on supporting Mobility of Compute
## Binaries: ls tail xargs rm reprepro grep mkdir wget head awk

function oberpakaj_singularity {
   local keep=$1; shift
   local distrib=$*

   for dist in ${distrib}
   do
      mkdir -p "$HOME/upload/singularity/${dist}"
      cd "$HOME/upload/singularity/${dist}"

      if wget --timestamping "http://neurodeb.pirsquared.org/dists/${dist}/main/binary-amd64/Packages.gz"
      then
         if [ -e "Packages.gz" ]
         then
            url=$(zgrep ^Filename Packages.gz | grep '/singularity-container_' | head -1 | awk '{print $2}')
            package=$(basename ${url})

            if wget --timestamping "http://neurodeb.pirsquared.org/${url}"
            then
               tmp_folder=$(mktemp --directory /tmp/singularity-XXXXXX)
               (cd ${tmp_folder}
                  ar -x "$HOME/upload/singularity/${dist}/${package}"
                  tar xJf control.tar.xz
                  sed -i -e 's/neurodebian-popularity-contest, //;' control
                  tar --owner root --group root -cJf control.tar.xz ./control ./conffiles ./md5sums ./shlibs ./triggers
                  ar -r $HOME/upload/singularity/${dist}/${package} debian-binary control.tar.xz data.tar.xz
                  )
               rm -rf ${tmp_folder}
            fi

            if [ -e "${package}" ]
            then
               # Upload package
               ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/singularity/${dist}/${package} )
            fi
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '^${dist}|.*/singularity-container'
         fi
      fi

      # Clean old package - kept last 4 (put 4+1=5)
      cd "$HOME/upload/singularity/${dist}"
      ls -t singularity-container*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   done
   }
