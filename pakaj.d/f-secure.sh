#!/bin/bash
#
## Date: 2022/06/07
## Pakaj: f-secure
## Package: f-secure-policy-manager-console f-secure-policy-manager-proxy f-secure-policy-manager-server
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://www.withsecure.com/en/support/product-support/business-suite/policy-manager
## Description: F-Secure Policy Manager
## Binaries: ls tail xargs rm reprepro grep mkdir wget curl file cut sed tail mktemp ln tar ar xz

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
      curl -s -L 'https://download.f-secure.com/corpro/products.json' | sed -e 's/"/\n/g;' | grep '^pm_linux/pm_linux.*_amd64\.deb$' > package.txt

      for pkg in wspmc wspmp wspms
      do
         url=$(grep "/${pkg}_" package.txt | tail -1)
         package=$(basename ${url})

         if [ ! -e "${package}" ]
         then
            wget "https://download.f-secure.com/corpro/${url}"
            file ${package} | grep -q 'Debian binary package .format 2.0' || { rm -f "${package}"; continue; }

            tmp_folder=$(mktemp --directory /tmp/f-secure-XXXXXX)
            (cd ${tmp_folder}
               ar -x ${HOME}/upload/f-secure/${package} control.tar.xz
               tar -xJf control.tar.xz ./control
               #ar -x ${HOME}/upload/f-secure/${package} control.tar.gz
               #tar -xzf control.tar.gz ./control
               )
            pkg_name=$(grep '^Package:' ${tmp_folder}/control | cut -f 2 -d ' ')
            pkg_vers=$(grep '^Version:' ${tmp_folder}/control | cut -f 2 -d ' ')
            pkg_real="${pkg_name}_${pkg_vers}_amd64.deb"

            if egrep -q 'Package: (f-secure-policy-manager-proxy|f-secure-policy-manager-server)' ${tmp_folder}/control
            then
               (cd ${tmp_folder}
                  sed -i -e 's/^\(Depends:.*\)/\1,libstdc++6:i386/;' ./control
                  #gunzip control.tar.gz
                  xz -d control.tar.xz
                  tar --delete -f control.tar ./control
                  tar -uf control.tar ./control
                  #gzip control.tar
                  xz control.tar

                  cp -f ${HOME}/upload/f-secure/${package} ${HOME}/upload/f-secure/${pkg_real}
                  #ar -r ${HOME}/upload/f-secure/${pkg_real} control.tar.gz
                  ar -r ${HOME}/upload/f-secure/${pkg_real} control.tar.xz
                  )
            else # f-secure-policy-manager-console
               (cd ${tmp_folder}
                  ar -x ${HOME}/upload/f-secure/${package}
                  tar -xJf data.tar.xz
                  mkdir -p ./usr/bin
                  cat << END > ./usr/bin/fspmc
#!/bin/sh
exec /opt/f-secure/fspmc/fspmc
END
                  chmod a+rx ./usr/bin/fspmc
                  tar --owner root --group root -cJf data.tar.xz ./usr ./opt
                  #ar -r ${HOME}/upload/f-secure/${pkg_real} debian-binary control.tar.gz data.tar.xz
                  echo ar -r ${HOME}/upload/f-secure/${pkg_real} debian-binary control.tar.xz data.tar.xz
                  ar -r ${HOME}/upload/f-secure/${pkg_real} debian-binary control.tar.xz data.tar.xz
                  )
            fi

            # Clean
            rm -rf ${tmp_folder}
         fi
      done

      for pkg in f-secure-policy-manager-console f-secure-policy-manager-proxy f-secure-policy-manager-server
      do
         pkg_real=$(ls -1 ${pkg}_*.deb | tail -1)

         for dist in ${distrib}
         do
           ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${pkg_real}" || \
              ( cd "${REPREPRO}" || return ; reprepro includedeb ${dist} $HOME/upload/f-secure/${pkg_real} )
         done
      done

      ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) | grep -i "/f-secure"
   fi

   # Clean old package - keep last 4 (put 4+1=5)
   if [ -d "${HOME}/upload/f-secure" ]
   then
      cd "${HOME}/upload/f-secure"
      for pkg in fspmc fspmp fspms wspmc wspmp wspms f-secure-policy-manager-console f-secure-policy-manager-proxy f-secure-policy-manager-server
      do
         ls -1t -- ${pkg}_*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
      done
   fi
   }
