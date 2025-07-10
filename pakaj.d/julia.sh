## Date: 2025/07/10
## Pakaj: julia
## Package: julia-lts
## Author: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
## See-Also: https://julialang.org
## Wikipedia: https://en.wikipedia.org/wiki/Julia_(programming_language)
## Description: Julia is a dynamic programming language designed to be fast and productive, for data science, artificial intelligence, machine learning, modeling and simulation
## Binaries: ls tail xargs reprepro grep mkdir curl sed cut head mktemp tar mv chmod rm tar ar cat

function oberpakaj_julia {
   local keep=$1; shift
   local distrib=$*

   mkdir -p "$HOME/upload/julia"
   [ -e "$HOME/upload/julia/version" ] || echo '0' > "$HOME/upload/julia/version"
   cd "$HOME/upload/julia"
   
   version_old=$(cat "$HOME/upload/julia/version" 2> /dev/null)
   url=$(curl -sL 'https://julialang.org/downloads/' | grep -A 1000 '(LTS)' | sed -s 's/"/\n/g;' | grep '^https://.*/linux/x64/.*/julia-.*x86_64.tar.gz$' | head -1)
   version=$(basename "${url}" | cut -f 2 -d '-')
   archive=$(basename "${url}")
   PKG_VERSION=2
   PKG_NAME=julia-lts
   package=${PKG_NAME}_${version}-${PKG_VERSION}_amd64.deb

   if [ "${version}_${PKG_VERSION}" != "${version_old}" ]
   then
      echo "${version}_${PKG_VERSION}" > "$HOME/upload/julia/version"
      tmp_folder=$(mktemp --directory /tmp/julia-XXXXXX)
      { [ -n "${tmp_folder}" ] && [ -d "${tmp_folder}" ] ; } || return 1

      (cd "${tmp_folder}/"

         curl "${url}" -o "${archive}"

         if [ -s "${archive}" ] && file "${archive}" | grep -q 'gzip compressed data'
         then

            tar xzf "${archive}"
            [ -d "julia-${version}" ]  || return 2
            mkdir -p ./opt
            mv "julia-${version}" ./opt/julia

            # Data archive
            rm -f data.tar.gz
            tar --owner root --group root -czf data.tar.xz ./opt

            cat << 'END' > postinst
#!/bin/bash

ln -sf /opt/julia/bin/julia                        /usr/bin/julia
ln -sf /opt/julia/share/man/man1/julia.1           /usr/share/man/man1/julia.1
ln -sf /opt/julia/share/applications/julia.desktop /usr/share/applications/julia.desktop
END

            cat << 'END' > prerm
#!/bin/bash

for link in /usr/bin/julia /usr/share/man/man1/julia.1 /usr/share/applications/julia.desktop
do
 [ -h "${link}" ] && rm -f "${link}"
done
END

            chmod a+rx postinst prerm

            # Control file
            cat <<END > control
Package: julia-lts
Version: ${version}-${PKG_VERSION}
Section: text
Priority: optional
Depends: perl
Architecture: amd64
Installed-Size: $(du -ks "${tmp_folder}/opt" | cut -f 1)
Maintainer: Gabriel Moreau <Gabriel.Moreau@univ-grenoble-alpes.fr>
Description: high-level, high-performance dynamic programming language for technical computing
 Julia is a dynamic programming language designed to be fast and productive,
 for data science, artificial intelligence, machine learning, modeling and
 simulationotero helps you collect, manage, and cite your research sources.
 .
 Distinctive aspects of Julia's design include a type system with parametric
 polymorphism and the use of multiple dispatch as a core programming paradigm,
 a default just-in-time (JIT) compiler (with support for ahead-of-time
 compilation) and an efficient (multi-threaded) garbage collection
 implementation. Notably Julia does not support classes with encapsulated
 methods and instead it relies on structs with generic methods/functions
 not tied to them. 
Homepage: https://julialang.org/
END

            # Control archive
            rm -f control.tar.gz
            tar --owner root --group root -cJf control.tar.gz control postinst prerm

            # Format deb package
            echo 2.0 > debian-binary

            # Create package (control before data)
            ar -r "$HOME/upload/julia/${package}" debian-binary control.tar.gz data.tar.xz
         fi
      )
      # Clean
      rm -rf ${tmp_folder}
   fi

   if [ -s "${package}" ] && file "${package}" | grep -q 'Debian binary package'
   then
      # Upload package
      for dist in ${distrib}
      do
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep -q "^${dist}|.*/${package}" || \
            ( cd "${REPREPRO}" || return ; reprepro includedeb "${dist}" "$HOME/upload/julia/${package}" )
         ( cd "${REPREPRO}" || return ; reprepro dumpreferences ) 2> /dev/null | grep "^${dist}|.*/julia"
      done
   fi

   # Clean old package - kept last 4 (put 4+1=5)
   ls -t julia-lts_*.deb | tail -n +$((${keep} + 1)) | xargs -r rm -f
   }
