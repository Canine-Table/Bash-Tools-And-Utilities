(
cat << 'EOF'
runtime! archlinux.vim
set number
set tabstop=4
set shiftwidth=4
set expandtab
set cursorline
set cursorcolumn
set nowrap
set ignorecase
set incsearch
set smartcase
set showcmd
set showmode
set showmatch
set hlsearch
set history=10000
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set undodir=~/.vim/backup
set undofile
set undoreload=10000
set nocompatible
syntax on
colorscheme industry
filetype plugin indent on
EOF
) > '/etc/vimrc';

