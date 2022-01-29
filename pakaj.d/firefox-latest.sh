# 2018/03/28
# firefox
# See also https://stackoverflow.com/questions/48943416/bash-npm-command-not-found-in-debian-9-3

function oberpakaj_firefox_latest {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/firefox-latest"
   cd "$HOME/upload/firefox-latest"
   [ -e "timestamp.sig" ] \
      || touch -t $(date +%Y)01010000 timestamp.sig
   if wget --timestamping "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"
   then
      if [ $(stat -c '%Y' "index.html?product=firefox-latest&os=linux64&lang=en-US") -gt $(stat -c '%Y' "timestamp.sig") ]
      then
         rm -rf ./firefox
         tar xjf "$HOME/upload/firefox-latest/index.html?product=firefox-latest&os=linux64&lang=en-US" firefox/application.ini
         # Set Version
         CODE_VERSION=$(grep '^Version=' firefox/application.ini|cut -f 2 -d '=')
         PKG_VERSION=2
         package="firefox-latest_${CODE_VERSION}-${PKG_VERSION}_amd64.deb"

         tmp_folder=$(mktemp --directory /tmp/firefox-latest-XXXXXX)
         (cd ${tmp_folder}
            mkdir -p usr/lib/firefox-latest
            (cd usr/lib/firefox-latest
               tar xjf "$HOME/upload/firefox-latest/index.html?product=firefox-latest&os=linux64&lang=en-US"
               )

            # Data archive
            tar --preserve-permissions --owner root --group root -cJf data.tar.xz ./usr

            # Control file
            cat <<END > control
Package: firefox-latest
Version: ${CODE_VERSION}-${PKG_VERSION}
Section: web
Priority: optional
Provides: gnome-www-browser, www-browser
Depends: libasound2
Architecture: amd64
Installed-Size: $(du -ks ./usr|cut -f 1)
Maintainer: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Description: Mozilla Firefox web browser - Latest Release
 Firefox is a powerful, extensible web browser with support for modern
 web application technologies.
Homepage: https://mozilla.org/
END
#Conflicts: iceweasel

            # Post install script
            cat <<END > postinst
#!/bin/sh
# Make main bin accessible
ln --force --symbolic /usr/lib/firefox-latest/firefox/firefox /usr/bin/firefox-latest
END

            # Pre remove script
            cat <<END > prerm 
#!/bin/sh
# Remove link
rm --force \
   /usr/bin/firefox-latest
END
            chmod a+rx postinst prerm

            # Control archive
            tar --owner root --group root -cJf control.tar.xz ./control ./postinst ./prerm

            # Format deb package
            echo 2.0 > debian-binary
            )

         # Create package (control before data)
         ar -r ${package} ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.xz ${tmp_folder}/data.tar.xz \
            && echo "${package}" > timestamp.sig

         # Clean
         rm -rf ${tmp_folder}
      fi

         # Upload package
      if [ -e "$(cat timestamp.sig)" ]
      then
         for dist in ${distrib}
         do
            ( cd ${REPREPRO} ; reprepro dumpreferences )  2>/dev/null | grep -q "^${dist}|.*/${package}" || \
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/firefox-latest/${package} )
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep "^${dist}|.*/firefox-latest"
         done
      fi

      # Clean old package - kept last 4 (put 4+1=5)
      ls -t firefox-latest_*.deb | tail -n +${keep} | xargs -r rm -f
   fi
   }
