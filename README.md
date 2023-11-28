Module: presuf.bash
Function: presuf
Desc: Prepend/Append text to filenames in a list.
Usage: presuf [-options] [prefix] [suffix] [<filenames]
Options:
  -s|--squeeze    Do not add separator space to prefix or suffix.
  -X|--execute    Execute the output as a script.
  -S|--shebang [shebang]
                  Inserts !#shebang at top of output.
                  If shebang not specified, default to "$BASH"
  -V|--version    Print version. "$FUNCNAME $VERSION"
  -h|--help       This docstring help.
Example: ls *.txt | presuf nano +34
