## Date: 2021/10/07
## Pakaj: powershell
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://microsoft.com/powershell
## Wikipedia: https://en.wikipedia.org/wiki/PowerShell
## Description: PowerShell is a task automation and configuration management program from Microsoft, consisting of a command-line shell and the associated scripting language
## Binaries: ls tail xargs rm reprepro grep mkdir wget head awk

function oberpakaj_powershell {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/powershell"
   cd "$HOME/upload/powershell"
   PKG_VERSION=1
   if wget --timestamping "https://packages.microsoft.com/repos/microsoft-debian-buster-prod/dists/buster/main/binary-amd64/Packages.gz"
   then
      if [ -e "Packages.gz" ]
      then
         powershell=$(zgrep ^Filename Packages.gz | grep '/powershell/' | head -1 | awk '{print $2}')

         wget --timestamping "https://packages.microsoft.com/repos/microsoft-debian-buster-prod/${powershell}"

         if [ -e "$(basename ${powershell})" ]
         then
            # Upload package
            for dist in ${distrib}
            do
               ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/powershell/$(basename ${powershell}) )
            done
            ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/powershell'
         fi
      fi
   fi
   
   # Clean old package - kept last 4 (put 4+1=5)
   cd "$HOME/upload/powershell"
   ls -t powershell_*.deb | tail -n +${keep} | xargs -r rm -f
   }
