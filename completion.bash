# bash completion for oberapk

_oberapk() {
   local cur prev

   COMPREPLY=()
   #_get_comp_words_by_ref cur prev
   cur="${COMP_WORDS[COMP_CWORD]}"
   prev="${COMP_WORDS[COMP_CWORD-1]}"

   if [[ $COMP_CWORD -gt 1 ]]
   then
      case "${COMP_WORDS[1]}" in
         update)
            COMPREPLY=($(compgen -W "$($(which oberapk || echo /usr/bin/oberapk) list|xargs echo -n)" -- "$cur"))
            ;;
         upgrade)
            COMPREPLY=($(compgen -W "$($(which oberapk || echo /usr/bin/oberapk) kit|xargs echo -n)" -- "$cur"))
            ;;
      esac
   else
      COMPREPLY=($(compgen -W "$($(which oberapk || echo /usr/bin/oberapk) help|grep '^ oberapk [[:alpha:]]'|awk '{print $2}'|xargs echo -n)" -- "$cur"))
   fi

   } && complete -F _oberapk oberapk
