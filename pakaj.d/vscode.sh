
function oberpakaj_vscode {
   local keep=$1; shift
   local distrib=$*

   # 2018/08/30
   # vscode
   # See also https://code.visualstudio.com/docs/setup/linux
   # Ticket 13897

   mkdir -p "$HOME/upload/vscode"
   cd "$HOME/upload/vscode"
   PKG_VERSION=1
   if wget --timestamping "https://packages.microsoft.com/repos/vscode/dists/stable/main/binary-amd64/Packages.gz"
   then
      if [ -e "Packages.gz" ]
      then
         codeonly=$(zgrep ^Filename Packages.gz | grep '/code/' | head -1 | awk '{print $2}')
         codeinsiders=$(zgrep ^Filename Packages.gz | grep '/code-insiders/' | head -1 | awk '{print $2}')

         wget --timestamping "https://packages.microsoft.com/repos/vscode/${codeonly}"
         wget --timestamping "https://packages.microsoft.com/repos/vscode/${codeinsiders}"

         if [ ! -e "Packages.gz" ]
         then
         # vscode
         tmp_folder=$(mktemp --directory /tmp/vscode-XXXXXX)
         (cd ${tmp_folder}
            ar -x "$HOME/upload/vscode/$(basename ${codeonly})"
            tar -xJf control.tar.xz 
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
         fi

         if [ -e "$(basename ${codeonly})" -a -e "$(basename ${codeinsiders})" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/vscode/$(basename ${codeonly})     )
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/vscode/$(basename ${codeinsiders}) )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/code'
         fi
      fi
   fi
   
   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/vscode"
   ls -t code-insiders_*.deb | tail -n +${keep} | xargs -r rm -f
   ls -t code_*.deb          | tail -n +${keep} | xargs -r rm -f
   }
