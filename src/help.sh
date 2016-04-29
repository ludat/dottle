dottle_show_help () {
    cat << EOF
Usage: ./dottle COMMAND [FILE]

COMMANDS:
- `install`: should be called upon the first invocation of dottle.
    It will install things, create links, run shell commands,
    download things like git repos. It checks if it was called
    before and if it was it won't have any effect
- `update`: should be called after install was called at least one.
    It will update existing things, update links to new paths,
    pull git repos, run shell commands, etc. It checks if install
    was called at least one, otherwise it will refuse to do
    anything

FILE (default "."):
  path to the file that will be run (if it's a directory, a file
  'install.conf.yml' will be searched inside it) using the action
  selected.

The format of the file is a pseudo yaml. You can find out more
about it here (https://github.com/ludat/dottle).
Here are some examples:

```
# check if apt is installed and update packages
# interactively because sudo
if which apt
shell: interactive
    update packages: sudo apt update
endif
```

```
# install vim config using a symlink
link:
    ~/.vimrc: vimrc
endif
```
EOF
}
