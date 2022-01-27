# 2020/09/15
# teams

function oberpakaj_teams {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/teams"
   cd "$HOME/upload/teams"

   package=$(wget -q https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/ -O - \
      | cut -f 2 -d '"' \
      | grep '^teams_' \
      | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n \
      | tail -1 \
      | awk '{print $1}')


   if [ ! -e "${package}" ]
   then
      tmp_folder=$(mktemp --directory /tmp/teams-XXXXXX)
      cd ${tmp_folder}
      wget https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/${package}
      mkdir teams
      cd teams
      ar -x ../${package}
      tar xzf control.tar.gz

      # On ajoute le champs Section a la pace du champs Source qui ne sers a rien
      grep -q ^Section: control || sed -i -e 's/^Source:.*/Section: net/;' control

      # On ne met pas le script postinst qui ajoute le depot Microsoft
      tar --owner root --group root -czf control.tar.gz control
      ar -r $HOME/upload/teams/${package} debian-binary control.tar.gz data.tar.xz

      # Clean
      rm -rf ${tmp_folder}

      for dist in ${distrib}
      do
         # Upload package
         ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/teams/${package} )
         ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/teams'
      done
   fi
   # Clean old package - kept last 4 (put 4+1=5)
   ls -t teams_*.deb | tail -n +${keep} | xargs -r rm -f
   }
