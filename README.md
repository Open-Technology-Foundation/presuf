# Module: presuf.bash

## Function: presuf

### Desc:
  Prepend/Append text to filenames in a stream list.

### Usage:
    presuf [-options] [prefix] [suffix] [<filenames]

### Options:
    -z|--squeeze  Do not add separator space to prefix or suffix.
    -X|--execute  Execute the output as a script.
    -Q|--quote ['|"]
                  Wraps filename in quotes.
                  If 'quote' not specified, defaults to "'"
    -s|--shebang [shebang]
                  Inserts !#shebang at top of output.
                  If 'shebang' not specified, defaults to "$BASH"
    -V|--version  Print version.
    -h|--help     This docstring help.

### Examples:
    ls *.txt | presuf vi +34
    find -name '*.sh' | presuf "$EDITOR" '+1' -Qs >myscript
    findgrep ~/scripts -name 'bash'  | presuf "$EDITOR" -Qs
