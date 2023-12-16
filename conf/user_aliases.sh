function main() {

    alias shutdown=poweroff;
    alias SHUTDOWN=poweroff;
    
    alias c=clear;
    alias C=c;
    alias cls=c;
    alias CLS=c;
    
    alias as=ash;
    alias AS=as;

    alias ll='ls -alF';
    alias LL=ll;

    alias la='ls -A';
    alias LA=la;

    alias l='ls -CF';
    alias L=l;

    alias e=echo
    alias E=e;

    alias r=reset;
    alias R=r;

    alias p=pwd;
    alias P=p;

    alias h=history;
    alias H=h;

    alias q=exit;
    alias Q=q;

    alias a=awk;
    alias A=a;

    alias g=grep;
    alias G=g;

    alias b='exec bash -i'
    alias B=b;

    alias w=whoami;
    alias W=w;

    if [ -x '/usr/bin/dircolors' ]; then
	[ -r "${HOME}/.dircolors" ] && eval "$(dircolors -b "${HOME}/.dircolors")" || eval "$(dircolors -b)";

        alias ls='ls --color=auto';
        alias LS=ls;

        alias vd='vd --color=auto';
        alias VD=vd;
        alias vdir=vd;
        alias VDIR=vd;

        alias d='dir --color=auto';
        alias D=d;
        alias dir=d;
        alias DIR=dir;

        alias g='grep --color=auto';
        alias G=g;
        alias grep=g;
        alias GREP=g;
        
        alias fg='fgrep --color=auto';
        alias FG=fg;
        alias fgrep=fg;
        alias FGREP=fg;
        
        alias eg='egrep --color=auto';
        alias EG=eg;
        alias egrep=eg;
        alias EGREP=eg;

    fi

    if command -v 'flatpak' &> '/dev/null'; then
        alias reader='flatpak run "com.adobe.Reader"';
        alias anydesk='flatpak run "com.anydesk.Anydesk"';
        alias bitwarden='flatpak run "com.bitwarden.desktop"';
        alias brave='flatpak run "com.brave.Browser"';
        alias discord='flatpak run "com.discordapp.Discord"';
        alias dropbox='flatpak run "com.dropbox.Client"';
        alias postman='flatpak run "com.getpostman.Postman"';
        alias teams='flatpak run "com.github.IsmaelMartinez.teams_for_linux"';
        alias jellyfin='flatpak run "com.github.iwalton3.jellyfin-media-player"';
        alias tor='flatpak run "com.github.micahflee.torbrowser-launcher"';
        alias video-downloader='flatpak run "com.github.unrud.VideoDownloader"';
        alias android='flatpak run "com.google.AndroidStudio"';
        alias idea='flatpak run "com.jetbrains.IntelliJ-IDEA-Community"';
        alias pycharm='flatpak run "com.jetbrains.PyCharm-Community"';
        alias edge='flatpak run "com.microsoft.Edge"';
        alias dev='flatpak run "com.microsoft.EdgeDev"';
        alias nextcloud='flatpak run "com.nextcloud.desktopclient.nextcloud"';
        alias obs='flatpak run "com.obsproject.Studio"';
        alias opera='flatpak run "com.opera.Opera"';
        alias proton='flatpak run "com.protonvpn.www"';
        alias black='flatpak run "com.raggesilver.BlackBox"';
        alias skype='flatpak run "com.skype.Client"';
        alias sublime='flatpak run "com.sublimetext.three"';
        alias transmission='flatpak run "com.transmissionbt.Transmission"';
        alias code='flatpak run "com.visualstudio.code"';
        alias vivaldi='flatpak run "com.vivaldi.Vivaldi"';
        alias discord-screenaudio='flatpak run "de.shorsh.discord-screenaudio"';
        alias figma='flatpak run "io.github.Figma_Linux.figma_linux"';
        alias youtube-downloader='flatpak run "io.github.aandrew_me.ytdn"';
        alias warehouse='flatpak run "io.github.flattool.Warehouse"';
        alias outlook='flatpak run "io.github.mahmoudbahaa.outlook_for_linux"';
        alias peazip='flatpak run "io.github.peazip.PeaZip"';
        alias github='flatpak run "io.github.shiftey.Desktop"';
        alias word='flatpak run "io.gitlab.o20.word"';
        alias obsidian='flatpak run "md.obsidian.Obsidian"';
        alias joplin='flatpak run "net.cozic.joplin_desktop"';
        alias jami='flatpak run "net.jami.Jami"';
        alias mega='flatpak run "nz.mega.MEGAsync"';
        alias audacity='flatpak run "org.audacityteam.Audacity"';
        alias blender='flatpak run "org.blender.Blender"';
        alias cryptomator='flatpak run "org.cryptomator.Cryptomator"';
        alias filezilla='flatpak run "org.filezillaproject.Filezilla"';
        alias flameshot='flatpak run "org.flameshot.Flameshot"';
        alias calculator='flatpak run "org.gnome.Calculator"';
        alias calendar='flatpak run "org.gnome.Calendar"';
        alias contacts='flatpak run "org.gnome.Contacts"';
        alias document-viewer='flatpak run "org.gnome.Evince"';
        alias extensions='flatpak run "org.gnome.Extensions"';
        alias logs='flatpak run "org.gnome.Logs"';
        alias weather='flatpak run "org.gnome.Weather"';
        alias disk-usage='flatpak run "org.gnome.baobab"';
        alias clocks='flatpak run "org.gnome.clocks"';
        alias fonts='flatpak run "org.gnome.font-viewer"';
        alias inkscape='flatpak run "org.inkscape.Inkscape"';
        alias kdenlive='flatpak run "org.kde.kdenlive"';
        alias konsole='flatpak run "org.kde.konsole"';
        alias krita='flatpak run "org.kde.krita"';
        alias libreoffice='flatpak run "org.libreoffice.LibreOffice"';
        alias thunderbird='flatpak run "org.mozilla.Thunderbird"';
        alias onlyoffice='flatpak run "org.onlyoffice.desktopeditors"';
        alias openshot='flatpak run "org.openshot.OpenShot"';
        alias dbbrowser='flatpak run "org.sqlitebrowser.sqlitebrowser"';
        alias vlc='flatpak run "org.videolan.VLC"';
        alias wireshark='flatpak run "org.wireshark.Wireshark"';

        alias office=libreoffice;
        alias libre=libreoffice;

        alias only=onlyoffice;

        alias pea=peazip;
        
        alias thunder=thunderbird;
        alias bird=thunderbird;

        alias db=dbbrowser;
    fi

    return 0;
}

main;
