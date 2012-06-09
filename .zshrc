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

alias ls='ls --color=auto'
alias l='ls -lahF --color=auto'
alias ll='ls -lhF --color=auto'
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

[ -f ~/.zsh/zshrc.local ] && source ~/.zsh/zshrc.local

