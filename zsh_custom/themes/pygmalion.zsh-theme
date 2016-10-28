# Yay! High voltage and arrows!


function virtualenv_prompt_info() {
    if [ -n "$VIRTUAL_ENV" ]; then
        if [ -f "$VIRTUAL_ENV/__name__" ]; then
            local name=`cat $VIRTUAL_ENV/__name__`
        elif [ `basename $VIRTUAL_ENV` = "__" ]; then
            local name=$(basename $(dirname $VIRTUAL_ENV))
        else
            local name=$(basename $VIRTUAL_ENV)
        fi
        echo "$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX$name$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
    fi
}


prompt_setup_pygmalion(){
  ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}git:"
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
  ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%}⚡%{$reset_color%}"
  ZSH_THEME_GIT_PROMPT_CLEAN=""

  ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚"
  ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[cyan]%} ⬆"
  ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[cyan]%} ⬇"
  ZSH_THEME_GIT_PROMPT_DIVERGED="%{$fg_bold[cyan]%} ⬍"
  ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✱"
  ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖"
  ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜"
  ZSH_THEME_GIT_PROMPT_STASHED='%{$fg[cyna]%} ✭'
  ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═"
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%} ◼"

  ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$fg[blue]%}venv:‹%{$fg[red]%}"
  ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="%{$fg[blue]%}›"

  user_prompt='%(!.%{$fg[red]%}.%{$fg[magenta]%})'
  host_prompt='%(!.%{$fg[magenta]%}.%{$fg[yellow]%})'

  base_prompt=$user_prompt'%n%{$reset_color%}%{$fg[cyan]%}@%{$reset_color%}'$host_prompt'%m%{$reset_color%}%{$fg[red]%}:%{$reset_color%}%{$fg[cyan]%}%0~%{$reset_color%}%{$fg[red]%}|$(virtualenv_prompt_info)%{$reset_color%}'
  #base_prompt='%{$fg[magenta]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$reset_color%}%{$fg[yellow]%}%m%{$reset_color%}%{$fg[red]%}:%{$reset_color%}%{$fg[cyan]%}%0~%{$reset_color%}%{$fg[red]%}|$(virtualenv_prompt_info)%{$reset_color%}'

  post_prompt='%(!.%{$fg[yellow]%}➜.%{$fg[cyan]%}⇒)%{$reset_color%}  '
  #post_prompt='%{$fg[cyan]%}⇒%{$reset_color%}  '

  base_prompt_nocolor=$(echo "$base_prompt" | perl -pe "s/%\{[^}]+\}//g")
  post_prompt_nocolor=$(echo "$post_prompt" | perl -pe "s/%\{[^}]+\}//g")
  precmd_functions+=(prompt_pygmalion_precmd)
}

prompt_pygmalion_precmd(){
  local gitinfo=$(git_prompt_info)
  local gitinfo_nocolor=$(echo "$gitinfo" | perl -pe "s/%\{[^}]+\}//g")
  local exp_nocolor="$(print -P \"$base_prompt_nocolor$gitinfo_nocolor$post_prompt_nocolor\")"
  local prompt_length=${#exp_nocolor}

  local nl=""

  if [[ $prompt_length -gt 40 ]]; then
    nl=$'\n%{\r%}';
  fi
  PROMPT="$base_prompt$gitinfo$nl$post_prompt"
  RPROMPT="%{$fg[red]%}%(?..⏎)%{$reset_color%}$(git_prompt_status)%{$reset_color%}"
}

prompt_setup_pygmalion


