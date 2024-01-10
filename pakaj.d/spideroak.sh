## Date: 2021/08/19
## Pakaj: spideroak
## Package: spideroakone
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://spideroak.com/
## Wikipedia: https://en.wikipedia.org/wiki/SpiderOak
## Description: SpiderOak is a US-based collaboration tool, online backup and file hosting service
## Binaries: ls tail xargs rm reprepro grep mkdir head awk wget basename

function oberpakaj_spideroak {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/spideroak"
   cd "$HOME/upload/spideroak"
   if wget --timestamping "https://apt.spideroak.com/ubuntu-spideroak-hardy/dists/release/restricted/binary-amd64/Packages.gz"
   then
      if [ -e "Packages.gz" ]
      then
         url=$(zgrep ^Filename Packages.gz | grep '/spideroakone_' | head -1 | awk '{print $2}')
         pkg=$(basename ${url})
         version=$(echo ${pkg} | cut -f 2 -d '_')'-1'
         package="spideroakone_${version}_amd64.deb"

         wget --timestamping "https://apt.spideroak.com/ubuntu-spideroak-hardy/${url}"

         if [ -e "${pkg}" ]
         then
            tmp_folder=$(mktemp --directory /tmp/spideroak-XXXXXX)
            (cd ${tmp_folder}
               ar -x "$HOME/upload/spideroak/${pkg}"
               tar -xzf control.tar.gz
               tar -xJf data.tar.xz

               # Remove apt source file
               rm -rf etc/apt
               grep -v spideroakone.list conffiles > conffiles.new
               mv conffiles conffiles.old
               mv conffiles.new conffiles

               # Build new package archives
               sed -i -e 's/^\(Version:.*\)$/\1-1/;' control
               rm -f control.tar.gz data.tar.xz
               tar --preserve-permissions --owner root --group root -cJf data.tar.xz ./usr ./etc ./opt
               tar --owner root --group root -czf control.tar.gz ./conffiles ./control ./postinst ./postrm
               )

            # Create package (control before data)
            ar -r ${package} ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.gz ${tmp_folder}/data.tar.xz
 
            # Clean
            rm -rf ${tmp_folder}
         fi

         if [ -e "${package}" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/spideroak/${package} )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/spideroakone'
         fi
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/spideroak"
   ls -t spideroakone_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   }
