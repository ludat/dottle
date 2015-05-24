# dottle

Manage your dotfiles anywhere with a super posix sh script.

![Show off](http://giant.gfycat.com/ScornfulBelovedCrow.gif)

## Motivation and Inspiration

I wanted to be able to install my dotfiles transparently onto (mostly) any system and it's a good way to practice my sh-foo. My main inspiration is [dotbot](https://github.com/anishathalye/dotbot) from which I stole the config yaml file. Sadly it's written in python and uses some argparse from python 2.7 so... nope.

Obviously if you find a bug or want a new feature just post an issue or make a pull request

## Requirements

It barely need an Unix OS but for the sake of lists:

* POSIX compatible shell in /bin/sh
* grep, sed, ln, mv, rm, mkdir, printf, etc. (all posix versions)
* git [optional] to get stuff from the internet
* curl and tar: in the future I'll implement some magic to get stuff from the internet without git

## Instalation

dottle needs an `install.conf.yml` which tells explicitly what files to symlink and what commands to run. we will talk about its syntax later. Once you have the dottle executable and the install.conf.yml in the same directory as your dotfiles you can run `./dottle install`.

## Config file

The config file a is kind of yaml without the dashes and all commands follows this structure:

```
COMMAND: [OPT] [OPT] [...]
    ARG1: ARG2
    [ARG1: ARG2]
    [ARG1: ARG2]
    ...
```

for example:

```
link: create force!
    ~/.zshrc: zshrc/zshrc
```

This will call the `link` command with the `force=false` and the `create=true`, `ARG1=~/.zshrc` and `ARG2=zshrc/zshrc`.

### Commands Available and options

#### link

Creates a symlink in ARG1 pointing to BASEDIR/ARG2

* command: link
* ARG1: Symlink file path which should be an absolute path (~ get expanded)
* ARG2: Path which will be appended by the dotfiles directory, should be relative to the directory of dottle.
* OPTIONS:
    * backup: (default true) if true when dottle finds the file it's trying to create it will move it to FILE.DATE.backup
    * ign_broken: (default false) if false dottle will refuse to create broken symlinks
    * relative: (default false) if true don't try to expand ARG2 to an absolute path. ign_broken will be ignored
    * create: (default true) if true dottle will create recursively the directories for ARG1
    * force: (default false) dottle will do its best to create the symlink

#### shell

Executes ARG2

* command: shell
* ARG1: Verbose description of command for humans
* ARG2: command that will be executed
* OPTIONS:
    * interactive: (default false) if false all output and input will be silenced. if true it should work but eval handles stdin and stdout weirdly (not to be trusted)

Note that this:

```
link: force
    ~/.vim: vim/vim
    ~/.vimrc: vim/vimrc
```

is exactly the same as this:

```
link: force
    ~/.vim: vim/vim
link: force
    ~/.vimrc: vim/vimrc
```

*If it's not submit an issue*

## Warnings

Since this is implemented in pure POSIX shell script there are a lot of hacks in the code and some `eval`s and I'm still working on this so maybe you souldn't trust it to manage your super critical production machine.
