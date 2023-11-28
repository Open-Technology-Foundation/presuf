#!/bin/bash
# Module: presuf.bash
# Function: presuf
# Desc: Prepend/Append text to filenames in a list.
# Usage: presuf [-options] [prefix] [suffix] [<filenames]
# Options:
#   -s|--squeeze    Do not add separator space to prefix or suffix.
#   -X|--execute    Execute the output as a script.
#   -S|--shebang [shebang]
#                   Inserts !#shebang at top of output.
#                   If shebang not specified, default to "$BASH"
#   -V|--version    Print version. "$FUNCNAME $VERSION"
#   -h|--help       This docstring help.
# Example: ls *.txt | presuf nano +34

presuf() {
  # Function: presuf
  # Desc: Prepend and append text to each filename in a list.
  # Usage: presuf [-options] [prefix] [suffix] [<filenames]
  # Example: ls | presuf nano +34
  #
  local VERSION='0.4.20(7)'
  local -- prefix='' suffix='' shebang=''
  local -i squeeze=0 execute=0 prompt=1
  while(($#)); do case "$1" in
    -s|--squeeze)   squeeze=1 ;;
    -X|--execute)   execute=1 ;;
    -y|--no-prompt) prompt=0 ;;
    -S|--shebang)
        shebang="$BASH"
        (($# > 1)) && [[ ${2:0:1} != '-' ]] && {
          shift
          shebang="$1"
        }
        ;;
    -V|--version)   echo "$FUNCNAME $VERSION"; return 0 ;;
    -h|--help)
        # #canonical bash_docstring.lite (only reads script docstring, not function docstring within the script.)
        [[ $0 == 'bash' ]] && return 0
        while IFS= read -r line; do
          line=${line#"${line%%[![:space:]]*}"}
          [[ -z "$line" ]] && continue
          [[ ${line:0:1} == '#' ]] || break
          [[ $line == '#' ]] && { echo; continue; }
          [[ ${line:0:2} == '# ' ]] && echo "${line:2}"
        done <"$0"
        #bash_docstring -e "$0" "$FUNCNAME" | less -FXRS
        return 0
        ;;
    -[sXySVh]*) #shellcheck disable=SC2046 # de-aggregate aggregated short options
        set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -?|--*)
        >&2 echo "$FUNCNAME: error: Invalid option '$1'"; return 22 ;;
    *)  if [[ -z "$prefix" ]]; then
          prefix="$1"
        elif [[ -z "$suffix" ]]; then
          suffix="$1"
        else
          >&2 echo "$FUNCNAME: error: Invalid argument '$1'"; return 2;
        fi
  esac; shift; done

  ((squeeze)) || { prefix="$prefix "; suffix=" $suffix"; }
  [[ -t 0 ]] && exit 1
  [[ -n $shebang ]] && echo "#!$shebang"
  while read -r filename; do
    if ((execute)); then
      ( ${prefix}${filename}${suffix} ) </dev/tty
    else
      echo "${prefix}${filename}${suffix}"
    fi
  done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  presuf "$@"
fi

#fin
