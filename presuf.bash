#!/bin/bash
# # Module: presuf.bash
#
# ## Function: presuf
#
# ### Desc:
#   Prepend/Append text to filenames in a stream list.
#
# ### Usage:
#     presuf [-options] [prefix] [suffix] [<filenames]
#
# ### Options:
#     -z|--squeeze  Do not add separator space to prefix or suffix.
#     -X|--execute  Execute the output as a script.
#     -Q|--quote ['|"]
#                   Wraps filename in quotes.
#                   If 'quote' not specified, defaults to "'"
#     -s|--shebang [shebang]
#                   Inserts !#shebang at top of output.
#                   If 'shebang' not specified, defaults to "$BASH"
#     -V|--version  Print version.
#     -h|--help     This docstring help.
#
# ### Examples:
#     ls *.txt | presuf vi +34
#     find -name '*.sh' | presuf "$EDITOR" '+1' -Qs >myscript
#     findgrep ~/scripts -name 'bash'  | presuf "$EDITOR" -Qs

_bash_docstring.lite() {
  # bash_docstring.lite (only reads script docstring, not function docstring within the script.)
  [[ $0 == 'bash' ]] && return 0
  while IFS= read -r line; do
    line=${line#"${line%%[![:space:]]*}"}
    [[ -z "$line" ]] && continue
    [[ ${line:0:1} == '#' ]] || break
    [[ $line == '#' ]] && { echo; continue; }
    [[ ${line:0:2} == '# '  || ${line:0:2} == '#@' ]] && echo "${line:2}"
  done <"$0"
  return 0
}
declare -fx 'bash_docstring.lite'

presuf() {
  # Function: presuf
  # Desc: Prepend and append text to each filename in a list.
  # Usage: presuf [-options] [prefix] [suffix] [<filenames]
  # Example: ls | presuf nano +34
  #
  local VERSION='0.4.20(9)'
  local -- prefix='' suffix='' shebang='' quote=''
  local -i squeeze=0 execute=0 prompt=1
  while(($#)); do case "$1" in
    -z|--squeeze)   squeeze=1 ;;
    -X|--execute)   execute=1 ;;
    -Q|--quote)
        (($# > 1)) && [[ ${2:0:1} != '-' ]] && {
          shift; quote="$1"
        }
        [[ -z "$quote" ]] && quote="'"
        ;;
    -s|--shebang)
        (($# > 1)) && [[ ${2:0:1} != '-' ]] && {
          shift; shebang="${1/\#\!/}"
        }
        [[ -z "$shebang" ]] && shebang="$BASH"
        ;;
    -V|--version)   echo "$FUNCNAME $VERSION"; return 0 ;;
    -h|--help)
        _bash_docstring.lite "$0" "$FUNCNAME" | less -FXRS

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
    -[zXQsVh]*) #shellcheck disable=SC2046 # de-aggregate aggregated short options
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
    filename="${prefix}${quote}${filename}${quote}${suffix}"
    if ((execute)); then
      ( $filename ) </dev/tty
    else
      echo "$filename"
    fi
  done
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  presuf "$@"
fi

#fin
