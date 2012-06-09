if [ -f ~/.zsh/z.sh ]; then
    source ~/.zsh/z.sh
    function z_sh_precmd {
        _z --add "$(pwd -P)"
    }
    precmd_functions=($precmd_functions z_sh_precmd)
fi
