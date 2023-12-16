#!/bin/bash


function main() {

    local HOMEDIR="$(getent passwd | awk -F ':' -v user="$(whoami)" '{ if ($1 ~ user) {printf $6}}')"  L;

    [[ -n "${BASH_VERSION}" ]] && mkdir -p "${HOMEDIR}"/{Downloads,Documents/{Languages/{VIM,SWIFT,JL,DART,SCALA,HS,KT,AHK,JAVA,CMD,BAT,SQL,SH,AWK,JS,PHP,PY,RB,PL,PS1,CS,C,CPP,ASM,CS,CSS},Serialization/{JSON,CSV,{HT,X,Y{,A}}ML},Projects,Plaintext/{CTB,TXT,LOG,PDF,MD,REF,RTF},Compression/{TAR/{TAR,XZ,GZ,BZ},XZ,GZ,BZ,7Z,ZIP,CAB,DEB,RAR},Archives/{FLATPAK,RPM,DEB,REPO,APK,JAR,EXE,C{F,ON{FIG,F}}},Office/{Powerpoint/PP{T,S}{,X},Spreadsheet/XLS{,X},Word/{DOC{,X},ODT}}},Pictures/{Screenshots/,Formats/{JP{,E}G,PNG,{JF,T,G,HE}IF,TIFF,SVG,{BM,WEB}P}},Music/{A{IFF,PE},{F,A}LAC,M{4A,P3,P2},W{MA,AW},OG{G,A}},Videos/{M{P{G,4},OV,KV},OGG,W{EBM,MV},HEVC}}

    for L in "Documents" "Pictures" "Videos" "Music"; do
       [[ -L "${HOMEDIR}/Downloads/${L}" ]] || ln -s "${HOMEDIR}/${L}" "${HOMEDIR}/Downloads/${L}";
    done

    return 0;
};: << 'EOF'

    ${HOMEDIR}/{
        Documents/{
            Languages/{VIM,SWIFT,JL,DART,SCALA,HS,KT,AHK,JAVA,CMD,BAT,SQL,SH,AWK,JS,PHP,PY,RB,PL,PS1,CS,C,CPP,ASM,CS,CSS},
            Serialization/{JSON,CSV,{HT,X,Y{,A}}ML},Projects,
            Plaintext/{CTB,TXT,LOG,PDF,MD,REF,RTF},
            Compression/{TAR/{TAR,XZ,GZ,BZ},XZ,GZ,BZ,7Z,ZIP,CAB,DEB,RAR},
            Archives/{FLATPAK,RPM,DEB,REPO,APK,JAR,EXE,C{F,ON{FIG,F}}},
            Office/{Powerpoint/PP{T,S}{,X},Spreadsheet/XLS{,X},Word/{DOC{,X},ODT}}},
        Pictures/{Screenshots/,Formats/{JP{,E}G,PNG,{JF,T,G,HE}IF,TIFF,SVG,{BM,WEB}P}},
        Music/{A{IFF,PE},{F,A}LAC,M{4A,P3,P2},W{MA,AW},OG{G,A}},
        Videos/{M{P{G,4},OV,KV},OGG,W{EBM,MV},HEVC}
    }

EOF

main;
