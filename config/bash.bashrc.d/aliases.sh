alias cls='clear';
alias ll='ls -alF';
alias la='ls -A';
alias l='ls -CF';
alias h='history';

alias teams='flatpak run com.github.IsmaelMartinez.teams_for_linux &';
alias outlook='flatpak run io.github.mahmoudbahaa.outlook_for_linux &';
alias eclipse='flatpak install flathub org.eclipse.Java &';
alias peazip='flatpak run io.github.peazip.PeaZip &';
alias joplin='flatpak run net.cozic.joplin_desktop &';
alias b='exec /bin/bash -i';

if [[ -x '/usr/bin/dircolors' ]]; then
        if [[ -r "${HOME}/.dircolors" ]]; then
                eval "$(dircolors -b "${HOME}/.dircolors")";
        else
                eval "$(dircolors -b)";
        fi

    alias ls='ls --color=auto';
    alias dir='dir --color=auto';
    alias vdir='vdir --color=auto';
    alias grep='grep --color=auto';
    alias fgrep='fgrep --color=auto';
    alias egrep='egrep --color=auto';
fi

