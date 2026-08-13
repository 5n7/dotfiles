# vi mode keymaps. Loaded from programs.zsh.initContent.
bindkey -v
bindkey -M viins "jj" vi-cmd-mode

# zsh's vi-compatible backspace stops where insert mode started and leaves
# Delete unbound; vim's `backspace=indent,eol,start` does not.
bindkey -M viins "^?" backward-delete-char
bindkey -M viins "^[[3~" delete-char
bindkey -M vicmd "^[[3~" delete-char

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins "^e" edit-command-line

# text objects (ci", da(, vi{) from the widgets zsh already ships
autoload -Uz select-bracketed select-quoted
zle -N select-bracketed
zle -N select-quoted
for c in {a,i}{'(',')','[',']','{','}','<','>',b,B}; do
    bindkey -M viopp $c select-bracketed
    bindkey -M visual $c select-bracketed
done
for c in {a,i}{\',\",\`}; do
    bindkey -M viopp $c select-quoted
    bindkey -M visual $c select-quoted
done
unset c

# hooked instead of `zle -N zle-keymap-select` because omp.zsh and the deferred
# plugins load after this file and would clobber the widget
autoload -Uz add-zle-hook-widget
keymap::cursor-shape() {
    case ${KEYMAP:-main} in
    vicmd | visual) print -n '\e[2 q' ;;
    *) print -n '\e[6 q' ;;
    esac
}
add-zle-hook-widget zle-keymap-select keymap::cursor-shape
add-zle-hook-widget zle-line-init keymap::cursor-shape
