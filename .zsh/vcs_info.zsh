# show Git/SVN branch info
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
function vcsinfo_precmd {
    psvar=()
    vcs_info
    [[ -n $vcs_info_msg_0_ ]] && psvar[1]="$vcs_info_msg_0_"
}
precmd_functions=($precmd_functions vcsinfo_precmd)
RPROMPT="%1(v|%F{red}%1v%f|)"

