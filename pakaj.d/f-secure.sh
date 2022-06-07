## Date: 2022/06/07
## Pakaj: f-secure
## Package: f-secure-policy-manager-console f-secure-policy-manager-proxy f-secure-policy-manager-server
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.withsecure.com/en/support/product-support/business-suite/policy-manager
## Description: F-Secure Policy Manager
## Binaries: ls tail xargs rm reprepro grep mkdir git cut make pod2man pod2html mktemp cp ln cat chmod tar ar

function oberpakaj_f_secure {
   local keep=$1; shift
   local distrib=$*

   if [ ! -d "${HOME}/upload/f-secure" ]
   then
      mkdir -p "${HOME}/upload/f-secure"
   fi

   if [ -d "${HOME}/upload/f-secure/" ]
   then
      cd "${HOME}/upload/f-secure"
      wget https://download.f-secure.com/corpro/products.json -O - | sed -e 's/"/\n/g;' | egrep '_amd64.deb$' > package.txt

      for pkg in fspmc fspms fspmp
      do
         url=$(grep "/${pkg}_" package.txt | tail -1)
         package=$(basename ${url})

         if [ ! -e "${package}" ]
         then
            wget "https://download.f-secure.com/corpro/${url}"
            
            tmp_folder=$(mktemp --directory /tmp/f-secure-XXXXXX)

            rm -f control.tar.gz control
            (cd ${tmp_folder}
               ar -x ${HOME}/upload/f-secure/${package} control.tar.gz)
               tar -xzf control.tar.gz ./control
               )
            pkg_name=$(grep '^Package:' ${tmp_folder}/control | cut -f 2 -d ' ')
            pkg_vers=$(grep '^Version:' ${tmp_folder}/control | cut -f 2 -d ' ')
            pkg-real="${pkg_name}_${pkg_vers}_amd64.deb"
            # Create link to real name
            ln -s ${package} ${pkg_real}

            # Clean
            rm -rf ${tmp_folder}
         fi

         for dist in ${distrib}
         do
           ( cd ${REPREPRO} ; reprepro dumpreferences ) 2>/dev/null | grep -q "^${dist}|.*/${pkg_real}" || \
              ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/${pkg_real} )
         done
      done

      ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep -i "/f-secure"
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/f-secure" ]
   then
      cd "${HOME}/upload/f-secure"
      ls -t f-secure-*.deb | tail -n +${keep} | xargs -r rm -f
      ls -t fspm*.deb      | tail -n +${keep} | xargs -r rm -f
   fi
   }
