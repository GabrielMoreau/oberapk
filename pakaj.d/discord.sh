## Date: 2020/04/27
## Pakaj: discord
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://discord.com/
## Wikipedia: https://en.wikipedia.org/wiki/Discord_(software)
## Description: Discord is a VoIP, instant messaging and digital distribution platform
## Binaries: ls tail xargs rm reprepro grep mkdir wget seq basename mktemp ar tar cat chmod du sed cut rm 

function oberpakaj_discord {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/discord"
   cd "$HOME/upload/discord"

   PKG_VERSION=4
   for index in $(seq 16 19)
   do
      [ -s "discord-0.0.${index}-${PKG_VERSION}.deb" ] && continue
      url="https://dl.discordapp.net/apps/linux/0.0.${index}/discord-0.0.${index}.deb"
      if wget --quiet --timestamping "${url}"
      then
         package=$(basename ${url} .deb)

         tmp_folder=$(mktemp --directory /tmp/discord-XXXXXX)
         (cd ${tmp_folder}
            ar -x $HOME/upload/discord/${package}.deb data.tar.gz control.tar.gz
            tar --preserve-permissions -xzf data.tar.gz
            tar -xzf control.tar.gz

            mkdir -p usr/bin
            cat <<'END' > ./usr/bin/discord-stop
#!/bin/sh
# 2020/04/27 Gabriel Moreau
# kill discord
ps faux | grep /usr/share/discord | grep -v grep | awk '{print $2}' | xargs -r kill
END
            chmod a+rx ./usr/bin/discord-stop

            SIZE=$(du -ks ./usr|cut -f 1)
            sed -i -e "s/\(Version: .*\)/\1-${PKG_VERSION}/;
                       s/\(Installed-Size: \).*/\1${SIZE}/;" ./control
            
            tar --preserve-permissions --owner root --group root -czf data.tar.gz ./usr
            tar --owner root --group root -czf control.tar.gz ./control ./postinst

            # Format deb package
            echo 2.0 > ${tmp_folder}/debian-binary
            )

         # Create package (control before data)
         ar -r ${package}-${PKG_VERSION}.deb ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.gz ${tmp_folder}/data.tar.gz
 
         # Clean
         rm -rf ${tmp_folder}

         for dist in ${distrib}
         do
            # Upload package
            ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/discord/${package}-${PKG_VERSION}.deb )
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/discord'
         done
      fi
   done
   # Clean old package - kept last 4 (put 4+1=5)
   ls -t discord-*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   }
