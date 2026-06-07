-- lua/options.lua
-- 对应原 vimrc 里所有 set 命令

local opt = vim.opt

-- 行号
opt.number         = true
opt.relativenumber = false  -- 如果你喜欢相对行号可改 true

-- 界面
opt.ruler          = true
opt.showcmd        = true
opt.showmode       = false   -- lightline/lualine 已经显示模式了
opt.laststatus     = 2
opt.signcolumn     = "yes"
opt.cursorline     = true
opt.termguicolors  = true
--opt.t_Co           = 256     -- 兼容性保留

-- 鼠标 & 剪贴板
opt.mouse          = "a"
opt.clipboard      = "unnamedplus"   -- Linux 下用 unnamedplus 才对应系统剪贴板

-- 超时（对应 notimeout）
opt.timeout        = false
opt.ttimeout       = true
opt.ttimeoutlen    = 50

-- 缩进（4空格，和原来一样）
opt.tabstop        = 4
opt.softtabstop    = 4
opt.shiftwidth     = 4
opt.expandtab      = true
opt.smartindent    = true
opt.cindent        = true

-- 括号匹配
opt.showmatch      = true
opt.matchtime      = 5

-- 补全行为
opt.completeopt    = { "menu", "menuone", "noselect" }

-- 搜索
opt.ignorecase     = true
opt.smartcase      = true
opt.hlsearch       = true
opt.incsearch      = true

-- 文件
opt.encoding       = "utf-8"
opt.fileencoding   = "utf-8"
opt.swapfile       = false
opt.backup         = false
opt.undofile       = true    -- 持久化 undo，重启后还能撤销

-- 外观
opt.scrolloff      = 8       -- 光标距屏幕边缘保持 8 行
opt.wrap           = false
opt.splitright     = true
opt.splitbelow     = true
