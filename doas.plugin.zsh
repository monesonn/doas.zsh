# author: monesonn <git.io/monesonn>
# description: doas before the command; triggered by double esc.
# credit: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/doas/doas.plugin.zsh

__doas-replace-buffer() {
    local old=$1 new=$2 space=${2:+ }
    if [[ ${#LBUFFER} -le ${#old} ]]; then
        RBUFFER="${space}${BUFFER#$old }"
        LBUFFER="${new}"
    else
        LBUFFER="${new}${space}${LBUFFER#$old }"
    fi
}

doas-command-line() {
    [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
    # save beginning space
    local WHITESPACE=""
    if [[ ${LBUFFER:0:1} = " " ]]; then
        WHITESPACE=" "
        LBUFFER="${LBUFFER:1}"
    fi
    # get the first part of the typed command
    local cmd="${${(Az)BUFFER}[1]}"
    # convert if alias
    doasedit="doas $(alias $cmd | sed -r "s/.*='(.*)'/\1/;s/.*=(.*)/\1/")"

    if [[ -n $cmd && $BUFFER = $cmd\ * ]]; then
        __doas-replace-buffer "$cmd" "$doasedit"
    elif [[ -n $cmd && $BUFFER = \$cmd\ * ]]; then
        __doas-replace-buffer "\$cmd" "$doasedit"
    elif [[ $BUFFER = "doas $cmd"\ * ]]; then
        __doas-replace-buffer "$doasedit" "$cmd"
    elif [[ $BUFFER = doas\ * ]]; then
        __doas-replace-buffer "doas" ""
    else
        LBUFFER="doas $LBUFFER"
    fi
    # preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"
}

zle -N doas-command-line
# defined shortcut keys: [esc] [esc]
bindkey -M emacs '\e\e' doas-command-line
bindkey -M vicmd '\e\e' doas-command-line
bindkey -M viins '\e\e' doas-command-line
