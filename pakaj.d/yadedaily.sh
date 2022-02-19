# 2019/04/26
## Pakaj: yadedaily
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: http://www.yade-dem.org/packages/

function oberpakaj_yadedaily {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/yadedaily"
   cd "$HOME/upload/yadedaily"
   for dist in ${distrib}
   do
      [ -s "${dist}" ] && mv -f ${dist} ${dist}.old
      
      wget "http://www.yade-dem.org/packages/dists/${dist}/main/binary-amd64/Packages" -O - | grep '^Filename:' > ${dist}
      
      # FILE exists and has a size greater than zero
      if [ -s "${dist}" ]
      then
         # Filename: pool/main/y/yadedaily/libyadedaily_20200327-3657~b92082c~stretch1-1_amd64.deb
         # Filename: pool/main/y/yadedaily/python3-yadedaily_20200327-3657~b92082c~stretch1-1_amd64.deb
         # Filename: pool/main/y/yadedaily/yadedaily_20200327-3657~b92082c~stretch1-1_amd64.deb
         # Filename: pool/main/y/yadedaily/yadedaily-doc_20200327-3657~b92082c~stretch1-1_all.deb
         yadedaily=$(grep "/yadedaily_.*${dist}.*_amd64.deb"         ${dist} | awk '{print $2}' | head -1)
         pytyade=$(  grep "/python3-yadedaily_.*${dist}.*_amd64.deb" ${dist} | awk '{print $2}' | head -1)
         libyade=$(  grep "/libyadedaily_.*${dist}.*_amd64.deb"      ${dist} | awk '{print $2}' | head -1)

         for pkg in ${yadedaily} ${pytyade} ${libyade}
         do
            if wget --timestamping "http://www.yade-dem.org/packages/${pkg}"
            then
               shortpkg=$(echo ${pkg} | xargs -r basename)
               if [ -e "${shortpkg}" ]
               then
                  # Upload package
                  ( cd ${REPREPRO} ; reprepro includedeb ${dist} $HOME/upload/yadedaily/${shortpkg} )
                  ( cd ${REPREPRO} ; reprepro dumpreferences ) | grep '/yadedaily'
               fi
            fi
         done
      fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -t libyadedaily_*.deb      | tail -n +${keep} | xargs -r rm -f
   ls -t python3-yadedaily_*.deb | tail -n +${keep} | xargs -r rm -f
   ls -t yadedaily_*.deb         | tail -n +${keep} | xargs -r rm -f
   done
   }
