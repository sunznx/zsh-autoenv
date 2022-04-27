#!/usr/bin/env zsh

# Standarized $0 handling, following:
# https://z-shell.github.io/zsh-plugin-assessor/Zsh-Plugin-Standard
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"

: ${AUTOENV_ENTER_FILE:='.envrc'}
: ${AUTOENV_LEAVE_FILE:='.envrc.leave'}

local _enter_files="go.mod .nvmrc ${AUTOENV_ENTER_FILE}"
local _leave_files="${AUTOENV_LEAVE_FILE}"

function autoenv_file() {
    unsetopt local_options sh_word_split

    local _path=$1
    local _file=$2

    case $_file in
        "go.mod")
            autoenv_gomod $_path
            ;;
        ".nvmrc")
            autoenv_nvmrc $_path
            ;;
        $AUTOENV_ENTER_FILE)
            autoenv_envrc $_path
            ;;
        $AUTOENV_LEAVE_FILE)
            autoenv_envrc $_path
            ;;
        *)
            ;;
    esac
}

function autoenv_gomod() {
    local _path
    local _version
    local _root

    _path=$1

    if [ $_path ]; then
        _version=$(egrep -o 'go [0-9]+\.[0-9]+' $_path | egrep -o '[0-9]+\.[0-9]+')
    fi

    if [ $_version ]; then
        _root=$(brew --prefix go@$_version 2> /dev/null)
    fi

    if [ $_root ]; then
        autoenv_brew_install $_root go@$_version
        export GOROOT=$_root/libexec
        autoenv_add_path $_root/libexec/bin "go version"
    fi
}

function autoenv_nvmrc() {
    local _path
    local _version
    local _root

    _path=$1

    if [ $_path ]; then
        _version=$(egrep -o '[0-9]+\.[0-9]+' $_path | egrep -o '^[0-9]+')
    fi

    if [ $_version ]; then
        _root=$(brew --prefix node@$_version 2> /dev/null)
    fi

    if [ $_root ]; then
        autoenv_brew_install $_root node@$_version
        autoenv_add_path $_root/bin "node -v"
    fi
}


function autoenv_envrc() {
    local _path=$1
    . $_path
}

function autoenv_files() {
    setopt local_options sh_word_split
    local OLDIFS=$IFS
    local IFS=' '
    local _files=$1
    local _dir=$2

    for _f in $_files; do
        local _path=${_dir}/${_f}

        if [[ -f $_path ]]; then
            autoenv_file $_path $_f
        fi
    done

    IFS=$OLDIFS
    unsetopt local_options sh_word_split
}

function autoenv_chdir() {
    local OLDIFS=$IFS
    local IFS=/
    local old=( $(echo "$OLDPWD") )
    local new=( $(echo "$PWD") )
    old=( ${old:#} )
    new=( ${new:#} )

    local concat=( $old $(echo "${new#$old}") )
    concat=( ${concat[@]} )

    while [[ ! "$concat" == "$new" ]]; do
        autoenv_files $_leave_files "/${old}"

        old=( ${old[0,-2]} )
        concat=( ${old} $(echo "${new#$old}") )
        concat=( ${concat[@]} )
    done

    while [[ ! "$old" == "$new" ]]; do
        old+=(${new[((1 + $#old))]})
        autoenv_files $_enter_files "/${old}"
    done

    IFS=$OLDIFS
}

function autoenv_brew_install() {
    local _root=$1
    local _package=$2

    if [ ! -e $_root ]; then
        (nohup brew install $_package &> /dev/null &)
    fi
}

function autoenv_add_path() {
    local _new_path=$1
    local _cmd=$2

    diff <(eval $_cmd 2> /dev/null) <(eval $_new_path/$_cmd 2> /dev/null) &> /dev/null \
        || export PATH=$_new_path:$PATH
}

autoload -Uz autoenv_chdir

autoload -Uz add-zsh-hook
add-zsh-hook chpwd autoenv_chdir

OLDPWD=''
autoenv_chdir
