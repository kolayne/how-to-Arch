# I prefer global variables over universal variables.
#
# Universal variables are not present in any config, they are kept in
# the fish's internal `fish_variables` file, which also contains
# internal fish configuration and does not seem like a good file to
# be committed.
#
# I prefer bash-like environment variable setting style, as all the
# global variables that are set are explicitly there in the config.

set --export GOPATH "$HOME/.go"
set --export EDITOR helix
set --export VISUAL helix

fish_add_path --global --prepend $HOME/.local/bin/
