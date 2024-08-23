#!/bin/bash

[ -d '/etc/bash.bashrc.d/' -a -w '/etc/bash.bashrc.d/' ] || {
    [ -e '/etc/bash.bashrc.d/' ] && rm -rf '/etc/bash.bashrc.d/';
    install -m 0755 -o root -g root -d '/etc/bash.bashrc.d/';
}

(
cat << 'EOF'
alias cls='clear';
alias CLS=cls;
alias ll='ls -alF';
alias la='ls -A';
alias l='ls -CF';
alias b='exec bash -i';
alias yscan='yay -Rns $(yay -Qtdq)';
alias pscan='pacman -Rns $(pacman -Qtdq)';

[[ -x '/usr/bin/dircolors' ]] && {

    [[ -r "${HOME}/.dircolors" ]] && eval "$(dircolors -b "${HOME}/.dircolors")" || eval "$(dircolors -b)";

    alias ls='ls --color=auto';
    alias dir='dir --color=auto';
    alias vdir='vdir --color=auto';
    alias grep='grep --color=auto';
    alias fgrep='fgrep --color=auto';
    alias egrep='egrep --color=auto';
}
EOF
) > '/etc/bash.bashrc.d/aliases.sh';

