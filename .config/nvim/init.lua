local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Example using a list of specs with the default options
vim.g.mapleader = "," -- Make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "folke/trouble.nvim",
    }
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-calc",
      "ray-x/cmp-treesitter",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "hrsh7th/vim-vsnip-integ",
      "stevearc/vim-vsnip-snippets",
    }
  },
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  "tamago324/nlsp-settings.nvim",

  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    }
  },
  { "nvim-tree/nvim-web-devicons", lazy = true,                 opts = { default = true } },

  {
    "sotte/presenting.vim",
    ft = "markdown",
    init = function()
      --[[ vim.g.markdown_fenced_languages = ["vim", "json", "bash", "python", "html", "javascript", "typescript"] ]]
      vim.g.presenting_figlets = 1
      vim.g.presenting_figlets = 1
      vim.g.presenting_top_margin = 2
      vim.b.presenting_slide_separator = '\v(^|\n)\ze#{2} '

      vim.cmd([[
        augroup presentation
            autocmd!
        " Presentation mode
            au Filetype markdown nnoremap <buffer> <F10> :PresentingStart<CR>
        " ASCII art
            au Filetype markdown nnoremap <buffer> <F12> :.!toilet -w 200 -f term -F border<CR>
        augroup end
      ]])
    end
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/playground",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    opts = {
      autotag = { enable = true },
      --[[ ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" }, ]]
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
      playground = {
        enable = true,
        disable = {},
        updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
          toggle_query_editor = 'o',
          toggle_hl_groups = 'i',
          toggle_injected_languages = 't',
          toggle_anonymous_nodes = 'a',
          toggle_language_display = 'I',
          focus_language = 'f',
          unfocus_language = 'F',
          update = 'R',
          goto_node = '<cr>',
          show_help = '?',
        },
      }
    }
  },
  {
    "lambdalisue/fern.vim",
    dependencies = {
      "antoinemadec/FixCursorHold.nvim",
      "lambdalisue/fern-renderer-nerdfont.vim",
      "lambdalisue/fern-git-status.vim",
      "lambdalisue/nerdfont.vim",
      "lambdalisue/glyph-palette.vim",
    },
    keys = "<leader>nn",
    config = function()
      vim.cmd([[
        " Disable netrw.
        let g:loaded_netrw  = 1
        let g:loaded_netrwPlugin = 1
        let g:loaded_netrwSettings = 1
        let g:loaded_netrwFileHandlers = 1

        " augroup my-fern-hijack
        "   autocmd!
        "   autocmd BufEnter * ++nested call s:hijack_directory()
        " augroup END
        "
        " function! s:hijack_directory() abort
        "   let path = expand('%:p')
        "   if !isdirectory(path)
        "     return
        "   endif
        "   bwipeout %
        "   execute printf('Fern %s', fnameescape(path))
        " endfunction

        " CursorHold fix
        " in millisecond, used for both CursorHold and CursorHoldI,
        " use updatetime instead if not defined
        let g:cursorhold_updatetime = 100

        " Icons
        let g:fern#renderer = "nerdfont"

        " Custom settings and mappings.
        let g:fern#disable_default_mappings = 1

        noremap <silent> <Leader>nn :Fern . -drawer -right -reveal=% -toggle -width=35<CR><C-w>=

        function! FernInit() abort
          nmap <buffer><expr>
                \ <Plug>(fern-my-open-expand-collapse)
                \ fern#smart#leaf(
                \   "\<Plug>(fern-action-open:select)",
                \   "\<Plug>(fern-action-expand)",
                \   "\<Plug>(fern-action-collapse)",
                \ )
          nmap <buffer> <CR> <Plug>(fern-my-open-expand-collapse)
          nmap <buffer> <2-LeftMouse> <Plug>(fern-my-open-expand-collapse)
          nmap <buffer> n <Plug>(fern-action-new-path)
          nmap <buffer> d <Plug>(fern-action-remove)
          nmap <buffer> m <Plug>(fern-action-move)
          nmap <buffer> M <Plug>(fern-action-rename)
          nmap <buffer> h <Plug>(fern-action-hidden-toggle)
          nmap <buffer> r <Plug>(fern-action-reload)
          nmap <buffer> K <Plug>(fern-action-mark:toggle)
          nmap <buffer> b <Plug>(fern-action-open:split)
          nmap <buffer> v <Plug>(fern-action-open:vsplit)
          nmap <buffer><nowait> < <Plug>(fern-action-leave)
          nmap <buffer><nowait> > <Plug>(fern-action-enter)
        endfunction

        augroup FernGroup
          autocmd!
          autocmd FileType fern call FernInit()
        augroup END
      ]])
    end
  },

  "nvim-lualine/lualine.nvim",
  "nanozuki/tabby.nvim",

  {
    "voldikss/vim-floaterm",
    event = "VeryLazy",
    config = function()
      vim.g.floaterm_autoinsert = 1
      vim.g.floaterm_width = 0.8
      vim.g.floaterm_height = 0.8
      vim.g.floaterm_wintitle = 0
      vim.g.floaterm_autoclose = 2

      vim.keymap.set('n', "<leader>'", '<cmd>FloatermNew lazygit<cr>')
      vim.keymap.set('n', "<leader>d", '<cmd>FloatermNew lazydocker<cr>')
      vim.keymap.set('n', "<leader>z", '<cmd>FloatermNew')
    end
  },
  {
    "unblevable/quick-scope",
    keys = { "f", "F", "t", "T" },
    init = function()
      vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
      vim.g.qs_lazy_highlight = 1
      vim.g.qs_max_chars = 150
      vim.cmd([[
        augroup qs_colors
          autocmd!
          autocmd ColorScheme * highlight QuickScopePrimary guifg='#00C7DF' gui=underline ctermfg=155 cterm=underline
          autocmd ColorScheme * highlight QuickScopeSecondary guifg='#eF5F70' gui=underline ctermfg=81 cterm=underline
        augroup END
      ]])
    end
  },
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
    end
  },
  { "terryma/vim-expand-region",   event = "ModeChanged *:[vV]" },
  {
    "airblade/vim-gitgutter",
    config = function()
      vim.g.gitgutter_enabled = 1
      vim.keymap.set('n', '<leader>tg', '<cmd>GitGutterToggle<cr>', { silent = true })
    end
  },
  { "tpope/vim-fugitive",     event = "VeryLazy" },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {}
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    ft = {
      'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue', 'tsx', 'jsx',
      'rescript',
      'xml',
      'php',
      'markdown',
      'astro', 'glimmer', 'handlebars', 'hbs'
    }
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },
  {
    "christianchiarulli/nvcode-color-schemes.vim",
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.g.nvcode_termcolors = 256
      vim.cmd.colorscheme("nvcode")
    end,
  },

  { "diepm/vim-rest-console", ft = "rest" },
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app & yarn install",
  },
  {
    'nvim-telescope/telescope.nvim',
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>j",
        function() require("telescope.builtin").find_files() end,
      },
      {
        "<leader>g",
        function() require("telescope.builtin").live_grep() end,
      },
      {
        "<leader>r",
        function() require("telescope.builtin").grep_string() end,
      },
      {
        "<M-o>",
        function() require("telescope.builtin").buffers() end,
      },
      {
        "<leader>f",
        function() require("telescope.builtin").oldfiles() end,
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--trim", -- add this value
          "--hidden",
          "--glob",
          "!**/.git/*"
        }
      },
      pickers = {
        find_files = {
          -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
      },
    },
  },
  -- add telescope-fzf-native
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
    },
  },
  {
    "jamessan/vim-gnupg",
    event = "BufAdd *.gpg"
  },
  { "RaafatTurki/hex.nvim", ft = "xxd" },
})

vim.cmd([[
if !exists("g:os")
  if has("win64") || has("win32") ||  has("win16")
    let g:os = "windows"
  else
    let g:os = substitute(system('uname'), '\n', '', '')
  endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=500

" Enable filetype plugins
filetype plugin on
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread
au FocusGained,BufEnter * checktime

" Fast saving
nmap <leader>w :w!<cr>

command! NW execute("noautocmd write")

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!

" vim-numbertoggle - Automatic toggling between 'hybrid' and absolute line numbers
" Maintainer:        <https://jeffkreeftmeijer.com>
" Version:           2.1.1

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END

:set number relativenumber

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Avoid garbled characters in Chinese language windows OS
let $LANG='en'
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" Turn on the Wild menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=.git\*,.hg\*,.svn\*
else
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
endif

"Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" Disable mode in command bar
set noshowmode

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
" set foldcolumn=1

if (g:os == "Windows")
  map <leader>tt :belowright 10split <cr>:terminal<cr>
else
  map <leader>tt :belowright 10split term://zsh<cr>
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on

set t_Co=256

hi! Normal guibg=NONE ctermbg=NONE
hi! NonText guibg=NONE ctermbg=NONE guifg=NONE ctermfg=NONE
hi! EndOfBuffer guibg=NONE ctermbg=NONE guifg=NONE ctermfg=NONE
hi! LineNr ctermbg=NONE guibg=NONE
hi! SignColumn ctermbg=NONE guibg=NONE

" Set extra options when running in GUI mode
if has("gui_running")
    set guioptions-=T
    set guioptions-=e
    set t_Co=256
    set guitablabel=%M\ %t
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git etc. anyway...
set nobackup
set nowb
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=2
set tabstop=2

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <space> ciw

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Smart way to move between windows
map <M-j> <C-W>j
map <M-k> <C-W>k
map <M-h> <C-W>h
map <M-l> <C-W>l

" Moving in terminal mode
tnoremap <M-h> <C-\><C-N><C-w>h
tnoremap <M-j> <C-\><C-N><C-w>j
tnoremap <M-k> <C-\><C-N><C-w>k
tnoremap <M-l> <C-\><C-N><C-w>l
inoremap <M-h> <C-\><C-N><C-w>h
inoremap <M-j> <C-\><C-N><C-w>j
inoremap <M-k> <C-\><C-N><C-w>k
inoremap <M-l> <C-\><C-N><C-w>l
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l

" Exit terminal mode
tnoremap <M-q> <C-\><C-n>

" Close the current buffer
map <leader>bd :Bclose<cr>:tabclose<cr>gT

" Close all the buffers
map <leader>ba :bufdo bd<cr>

map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <leader>L :tabnext<cr>
map <leader>H :tabprevious<cr>

" Let 'tl' toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

au BufRead,BufNewFile Jenkinsfile set filetype=groovy

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Move a line of text using CTRL+[jk] or Command+[jk] on mac
nmap <C-j> mz:m+<cr>`z
nmap <C-k> mz:m-2<cr>`z
vmap <C-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <C-k> :m'<-2<cr>`>my`<mzgv`yo`z

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.coffee :call CleanExtraSpaces()
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Spell checking
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set spelloptions=camel
" Pressing ,ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell! spelllang=en_us,de_de<cr>

" Shortcuts using <leader>
map <leader>sn ]s
map <leader>sp [s
map <leader>sa zg
map <leader>s? z=

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remove the Windows ^M - when the encodings gets messed up
noremap <Leader>m mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

" Quickly open a buffer for scribble
map <leader>q :e ~/buffer<cr>

" Quickly open a markdown buffer for scribble
noremap <leader>x :e ~/buffer.gpg<cr>

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

" Map jj to escape
inoremap jj <Esc>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    endif
    return ''
endfunction

function! CmdLine(str)
    call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("RG " . l:pattern )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

"##############################################################################
" Terminal Handling
"##############################################################################

" Set login shell for :terminal command so aliases work
if (g:os == "windows")
  let &shell = has('win32') ? 'powershell' : 'pwsh'
  let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
  let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
  let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
  set shellquote= shellxquote=
else
  set shell=/usr/bin/zsh
endif

" When term starts, auto go into insert mode
autocmd TermOpen * startinsert

" Turn off line numbers etc
autocmd TermOpen * setlocal listchars= nonumber norelativenumber

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => GUI related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set font and clipboard copy according to system
if has("mac") || has("macunix")
    set gfn=IBM\ Plex\ Mono:h14,Hack:h14,Source\ Code\ Pro:h15,Menlo:h15
elseif has("win16") || has("win32")
    set gfn=IBM\ Plex\ Mono:h14,Source\ Code\ Pro:h12,Bitstream\ Vera\ Sans\ Mono:h11
    set clipboard=unnamed
elseif has("gui_gtk2")
    set gfn=IBM\ Plex\ Mono\ 14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
elseif has("linux")
    set gfn=IBM\ Plex\ Mono\ 14,:Hack\ 14,Source\ Code\ Pro\ 12,Bitstream\ Vera\ Sans\ Mono\ 11
    set clipboard=unnamedplus
elseif has("unix")
    set gfn=Monospace\ 11
    set clipboard=unnamedplus
endif

if g:os == 'Linux'
    let lines = readfile("/proc/version")
    if lines[0] =~ "Microsoft"
      set clipboard=unnamed
    endif
endif

" Disable scrollbars (real hackers don't use scrollbars for navigation!)
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

" checks if your terminal has 24-bit color support
if (has("termguicolors"))
    set termguicolors
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Turn persistent undo on
"    means that you can undo even when you close a buffer/VIM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
try
    set undodir=~/.config/nvim/temp_dirs/undodir
    set undofile
catch
endtry


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General abbreviations
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
iab xdate <C-r>=strftime("%d/%m/%y %H:%M:%S")<cr>

" When you press gv you rg after the selected text
vnoremap <silent> gv :call VisualSelection('gv', '')<CR>

" Search word under cursor
" nnoremap <silent> <leader>r :RG <C-R><C-W><CR>

" When you press <leader>r you can search and replace the selected text
" vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

" Do :help cope if you are unsure what cope is. It's super useful!
"
" When you search with Ack, display your results in cope by doing:
"   <leader>cc
"
" To go to the next search result do:
"   <leader>n
"
" To go to the previous search results do:
"   <leader>p
"
map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
map <leader>n :cn<cr>
map <leader>p :cp<cr>
map <leader>c :cclose<cr>

" Make sure that enter is never overriden in the quickfix window
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
autocmd! FileType qf nnoremap <buffer> <leader><Enter> <C-w><Enter><C-w>L


""""""""""""""""""""""""""""""
" => Folding
""""""""""""""""""""""""""""""

" This function customises what is displayed on the folded line:
set foldtext=MyFoldText()
function! MyFoldText()
    let line = getline(v:foldstart)
    let linecount = v:foldend + 1 - v:foldstart
    let plural = ""
    if linecount != 1
        let plural = "s"
    endif
    let foldtext = printf(" +%s %d line%s: %s", v:folddashes, linecount, plural, line)
    return foldtext
endfunction
" This is the line that works the magic
set foldmarker=#ifdef\ LINUX,#else
set foldmethod=marker


""""""""""""""""""""""""""""""
" => Markdown
""""""""""""""""""""""""""""""
let vim_markdown_folding_disabled = 1

""""""""""""""""""""""""""""""
" => ZenCoding
""""""""""""""""""""""""""""""
" Enable all functions in all modes
let g:user_zen_mode='a'


""""""""""""""""""""""""""""""
" => Vim grep
""""""""""""""""""""""""""""""
set grepprg=rg\ --vimgrep
set grepformat=%f:%l:%c:%m


" NVR
if has('nvim')
  let $GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"
endif

autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

set updatetime=300


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Init Lua Configs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

endif
if (g:os == "windows")
  luafile ~/AppData/Local/nvim/lua/init.lua
else
  luafile ~/.config/nvim/lua/init.lua
endif
]])
