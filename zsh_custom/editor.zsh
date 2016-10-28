local edit='vi'

command -v vim >/dev/null 2>&1 || {
    edit='vim'
    alias vi=vim
}

export EDITOR=$edit


