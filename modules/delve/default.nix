{ ... }:

{
  home.file.".config/dlv/config.yml".text = ''
# Configuration file for the delve debugger.

# This is the default configuration file. Available options are provided, but disabled.
# Delete the leading hash mark to enable an item.

# Uncomment the following line and set your preferred ANSI color for source
# line numbers in the (list) command. The default is 34 (dark blue). See
# https://en.wikipedia.org/wiki/ANSI_escape_code#3/4_bit
# source-list-line-color: "\x1b[34m"

# Uncomment the following lines to change the colors used by syntax highlighting.
# source-list-keyword-color: "\x1b[0m"
# source-list-string-color: "\x1b[92m"
# source-list-number-color: "\x1b[0m"
# source-list-comment-color: "\x1b[95m"
# source-list-arrow-color: "\x1b[93m"
# source-list-tab-color: "\x1b[90m"

# Uncomment to change what is printed instead of '\t'.
# tab: "... "

# Uncomment to change the number of lines printed above and below cursor when
# listing source code.
# source-list-line-count: 5

# Provided aliases will be added to the default aliases for a given command.
aliases:
  # command: ["alias1", "alias2"]

# Define sources path substitution rules. Can be used to rewrite a source path stored
# in program's debug information, if the sources were moved to a different place
# between compilation and debugging.
# Note that substitution rules will not be used for paths passed to "break" and "trace"
# commands.
# See also Documentation/cli/substitutepath.md.
substitute-path:
  # - {from: path, to: path}
  
# Maximum number of elements loaded from an array.
max-array-values: 20000

# Maximum loaded string length.
max-string-len: 20000

# Output evaluation.
# max-variable-recurse: 1

# Uncomment the following line to make the whatis command also print the DWARF location expression of its argument.
# show-location-expr: true

# Allow user to specify output syntax flavor of assembly, one of this list "intel"(default), "gnu", "go".
# disassemble-flavor: intel

# List of directories to use when searching for separate debug info files.
debug-info-directories: ["/usr/lib/debug/.build-id"]
  '';
}
