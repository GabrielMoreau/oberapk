## Date: 2018/08/30
## Pakaj: vscodium
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://github.com/VSCodium/vscodium
#
# Orther https://carlchenet.com/you-think-the-visual-studio-code-binary-you-use-is-a-free-software-think-again/

function oberpakaj_vscodium {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/vscodium"
   cd "$HOME/upload/vscodium"
   [ -e "releases" ] && mv -f releases releases.old
   wget "https://github.com/VSCodium/vscodium/releases" -O releases
   if [ -e "releases" ]
   then
      vscodium=$(grep '/codium_.*_amd64.deb' releases | cut -f 2 -d '"' | head -1 | sed -e 's#^/##;')

      if wget --timestamping "https://github.com/${vscodium}"
      then
         if [ -e "$(basename ${vscodium})" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/vscodium/$(basename ${vscodium}) )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/codium'
         fi
      fi
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -t codium_*.deb | tail -n +${keep} | xargs -r rm -f
   }
