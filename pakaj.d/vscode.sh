## Date: 2018/08/30
## Pakaj: vscode
## Package: code code-insiders
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/microsoft/vscode
## Wikipedia: https://en.wikipedia.org/wiki/Visual_Studio_Code
## Description: Visual Studio Code is a source-code editor
## Binaries: ls tail xargs rm reprepro grep mkdir wget sort awk ar tar sed cat rm mktemp

function oberpakaj_vscode {
   local keep=$1; shift
   local distrib=$*

   # See also https://code.visualstudio.com/docs/setup/linux
   # Ticket 13897

   mkdir -p "$HOME/upload/vscode"
   cd "$HOME/upload/vscode"
   PKG_VERSION=1
   if wget --timestamping "https://packages.microsoft.com/repos/vscode/dists/stable/main/binary-amd64/Packages.gz"
   then
      if [ -e "Packages.gz" ]
      then
         codeonly=$(zgrep ^Filename Packages.gz | grep '/code/' | sort -V | tail -1 | awk '{print $2}')
         codeinsiders=$(zgrep ^Filename Packages.gz | grep '/code-insiders/' | sort -V | tail -1 | awk '{print $2}')

         wget --timestamping "https://packages.microsoft.com/repos/vscode/${codeonly}"
         wget --timestamping "https://packages.microsoft.com/repos/vscode/${codeinsiders}"

         # vscode
         tmp_folder=$(mktemp --directory /tmp/vscode-XXXXXX)
         (cd ${tmp_folder}
            ar -x "$HOME/upload/vscode/$(basename ${codeonly})"
            tar -xJf control.tar.xz
            sed -i -e 's/^\(Version:.*\)$/\1.'${PKG_VERSION}'/;' control
            sed -i 's/^\([[:space:]]*\)eval /\1exit; eval /;' postinst
            cat <<'END' >> postrm

rm -f /etc/apt/sources.list.d/vscode.list
rm -f /etc/apt/trusted.gpg.d/microsoft.gpg

exit
END
            tar --owner root --group root -cJf control.tar.xz ./control ./postinst ./postrm ./prerm
            )
         ar -r "$HOME/upload/vscode/$(basename ${codeonly} _amd64.deb).${PKG_VERSION}_amd64.deb" ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.xz ${tmp_folder}/data.tar.xz
         rm -rf ${tmp_folder}

         # codeinsiders
         tmp_folder=$(mktemp --directory /tmp/codeinsiders-XXXXXX)
         (cd ${tmp_folder}
            ar -x "$HOME/upload/vscode/$(basename ${codeinsiders})"
            tar -xJf control.tar.xz 
            sed -i -e 's/^\(Version:.*\)$/\1.'${PKG_VERSION}'/;' control
            sed -i 's/^\([[:space:]]*\)eval /\1exit; eval /;' postinst
            cat <<'END' >> postrm

rm -f /etc/apt/sources.list.d/vscode.list
rm -f /etc/apt/trusted.gpg.d/microsoft.gpg

exit
END
            tar --owner root --group root -cJf control.tar.xz ./control ./postinst ./postrm ./prerm
            )
         ar -r "$HOME/upload/vscode/$(basename ${codeinsiders} _amd64.deb).${PKG_VERSION}_amd64.deb" ${tmp_folder}/debian-binary ${tmp_folder}/control.tar.xz ${tmp_folder}/data.tar.xz
         rm -rf ${tmp_folder}

         if [ -e "$(basename ${codeonly})" -a -e "$(basename ${codeinsiders})" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/vscode/$(basename ${codeonly} _amd64.deb).${PKG_VERSION}_amd64.deb     )
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/vscode/$(basename ${codeinsiders} _amd64.deb).${PKG_VERSION}_amd64.deb )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/code'
         fi
      fi
   fi
   
   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/vscode"
   ls -t code-insiders_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   ls -t code_*.deb          | tail -n +$((${keep} + 1)) | xargs -r rm -f
   }
