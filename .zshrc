local RED=$'%{\e[1;31m%}'
local GREEN=$'%{\e[0;32m%}'
local YELLOW=$'%{\e[0;33m%}'
local BLUE=$'%{\e[1;34m%}'
local PURPLE=$'%{\e[1;35m%}'
local WATER=$'%{\e[1;36m%}'
local DEFAULT=$'%{\e[00m%}'

autoload -U compinit
compinit

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# command completion when sudo
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

setopt AUTO_LIST
setopt AUTO_PUSHD
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt LIST_TYPES
setopt NO_BEEP
setopt SHARE_HISTORY

PROMPTHOST="%m"
[ -z "${SSH_CONNECTION}" ] || PROMPTHOST="${RED}%m"
PROMPTTTY=`tty | sed -e 's/^\/dev\///'`
PROMPTUSER="${BLUE}%n"
PROMPT="${DEFAULT}[${GREEN}%~$fg[black]%b] ${PROMPTUSER}${DEFAULT}@${PROMPTHOST} ${DEFAULT}<${PROMPTTTY}%b>%E
%b%(?.%#.${RED}%#${DEFAULT}) "
SPROMPT="${RED}[!]${DEFAULT}Correct ${BLACK}> '%r' [%BY%bes %BN%bo %BA%bbort %BE%bdit] ? "

# Ctrl-W conf
WORDCHARS='*?-.[]~=&;!#$%^(){}<>'

case "${OSTYPE}" in
darwin*)
    # Note: should install GNU version by 'brew install coreutils'
    if [ -f /usr/local/bin/gls ]; then
        alias ls='gls -A --color=auto'
        alias l='gls -lAhF --color=auto'
        alias ll='gls -1AhF --color=auto'
    else
        alias ls='ls -AG'
        alias l='ls -lAhFG'
        alias ll='ls -1AhFG'
    fi
  ;;
linux*)
    alias ls='ls -A --color=auto'
    alias l='ls -lAhF --color=auto'
    alias ll='ls -1AhF --color=auto'
  ;;
esac

alias pd=popd
alias tmux='tmux -2' # to enable 256 colors

alias gd='dirs -v; echo -n "select number: "; read newdir; cd +"$newdir"'

findg () { find . -type f -print | xargs grep -n --binary-files=without-match $@ }

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
bindkey "^[^[" send-break

function use-auto-fu() {
    if [ -f ~/.zsh/auto-fu.zsh ]; then
        source ~/.zsh/auto-fu.zsh
        function zle-line-init () {
            auto-fu-init
        }
        zle -N zle-line-init
        zstyle ':completion:*' completer _oldlist _complete
    fi
}

function use-dircolors-solarized() {
    DIRCOLORS=dircolors
    if [ -f /usr/local/bin/gdircolors ]; then
        DIRCOLORS=gdircolors
    fi
    if [ -f ~/.zsh/dircolors.256dark ]; then
        eval $($DIRCOLORS ~/.zsh/dircolors.256dark)
        zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    fi
}

function ls_abbrev() {
    if [[ ! -r $PWD ]]; then
        return
    fi
    # -a : Do not ignore entries starting with ..
    # -C : Force multi-column output.
    # -F : Append indicator (one of */=>@|) to entries.
    local cmd_ls='ls'
    local -a opt_ls
    opt_ls=('-aCF' '--color=always')
    case "${OSTYPE}" in
        freebsd*|darwin*)
            if type gls > /dev/null 2>&1; then
                cmd_ls='gls'
            else
                # -G : Enable colorized output.
                opt_ls=('-aCFG')
            fi
            ;;
    esac

    local ls_result
    ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

    local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

    if [ $ls_lines -gt 7 ]; then
        echo "$ls_result" | head -n 3
        echo '...'
        echo "$ls_result" | tail -n 3
        echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
    else
        echo "$ls_result"
    fi
}

function print-git-status() {
    if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
        echo
        echo -e "\e[0;33m--- git status ---\e[0m"
        git status -sb
    fi
}

chpwd() {
    ls_abbrev
    print-git-status
}

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

