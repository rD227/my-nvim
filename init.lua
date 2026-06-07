--~/.config/nvim/init.lua
--从 Termux vimrc 迁移而来，全 Lua 重构版
--结构: init.lua → lua/options.lua, lua/keymaps.lua, lua/plugins/init.lua

require("options")
require("keymaps")
require("plugins")
