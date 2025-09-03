## Date: 2022/03/24
## Pakaj: libpng12
## Package: libpng12-1
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: http://libpng.org/pub/png/libpng.html
## Description: PNG library - runtime version 12 needed by Ansys
## Binaries: ls tail xargs rm reprepro grep mkdir wget ar tar rm

function oberpakaj_libpng12 {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/libpng12"
   cd "$HOME/upload/libpng12"

   # carrefull with usrmerge compatibility / change -0 to -1
   version=1.2.54-1
   package=libpng12-1_${version}_amd64.deb

   if wget --timestamping http://ppa.launchpad.net/linuxuprising/libpng12/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1+1~ppa0~hirsute0_amd64.deb
   then
      ar -x libpng12-0_1.2.54-1ubuntu1.1+1~ppa0~hirsute0_amd64.deb
      tar xJf data.tar.xz
      tar xJf control.tar.xz
      rm -rf usr/share data.tar.xz control.tar.xz

      sed -i -e "s/^Package: .*/Package: libpng12-1/;
                 s/^Version: .*/Version: ${version}/;" control
      tar --owner root --group root -cJf control.tar.xz control
      tar --owner root --group root -cJf data.tar.xz usr
      ar -r $HOME/upload/libpng12/${package} debian-binary control.tar.* data.tar.*

      rm -rf control control.tar.xz data.tar.xz debian-binary md5sums shlibs triggers usr

      if [ -e "${package}" ]
      then
         for dist in ${distrib}
         do
            # Upload package
            ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/libpng12/${package} )
            ( cd ${REPREPRO} ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/libpng12"
         done
      fi
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -1t -- libpng12-*.deb 2> /dev/null | tail -n +$((keep+1)) | xargs -r rm -f --
}
