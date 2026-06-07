-- lua/keymaps.lua
-- 对应原 vimrc 里的 nnoremap / inoremap / nmap 等

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader 键（默认 \，可改成空格：vim.g.mapleader = " "）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================
-- 文件树（原 NERDTree <leader>e）
-- ============================================================
map("n", "<leader>e", ":Neotree toggle<CR>", opts)

-- ============================================================
-- LSP 导航（对应原 coc.nvim 的 gd / gD / gy / gi / gr）
-- 实际 handler 在 plugins/lsp.lua 里绑，这里只做备用
-- ============================================================
-- gd, gD, gy, gi, gr 由 nvim-lspconfig 的 on_attach 绑定

-- ============================================================
-- 重命名（原 <leader>rn）
-- ============================================================
map("n", "<leader>rn", vim.lsp.buf.rename, opts)

-- ============================================================
-- 格式化（原 <leader>f）
-- ============================================================
map("n", "<leader>f", vim.lsp.buf.format, opts)
map("v", "<leader>f", vim.lsp.buf.format, opts)

-- ============================================================
-- 文档悬浮（原 K）
-- ============================================================
map("n", "K", vim.lsp.buf.hover, opts)

-- ============================================================
-- 快速运行（原 <C-i> 编译/运行，避免和 jump-forward 冲突，改为 <F5>）
-- ============================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "c",
  callback = function()
    map("n", "<F5>", ":w<CR>:!gcc % -o /tmp/a.out -g && /tmp/a.out<CR>", { buffer = true })
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "cpp",
  callback = function()
    map("n", "<F5>", ":w<CR>:!g++ % -o /tmp/a.out -g && /tmp/a.out<CR>", { buffer = true })
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    map("n", "<F5>", ":w<CR>:!python3 %<CR>", { buffer = true })
  end,
})
-- Kotlin/Java（Android 开发）
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "kotlin", "java" },
  callback = function()
    -- 用 Gradle wrapper 构建（如果项目有）
    map("n", "<F5>", ":w<CR>:!./gradlew assembleDebug<CR>", { buffer = true })
    -- 安装到已连接设备
    map("n", "<F6>", ":w<CR>:!./gradlew installDebug<CR>", { buffer = true })
  end,
})

-- ============================================================
-- CMake 辅助（原 Gcmake 命令）
-- ============================================================
vim.api.nvim_create_user_command("Gcmake", function()
  if vim.fn.glob("CMakeLists.txt") == "" then
    print("找不到 CMakeLists.txt")
    return
  end
  if vim.fn.glob(".vscode") == "" then
    vim.fn.system("mkdir .vscode")
  end
  vim.fn.system("cmake -DCMAKE_BUILD_TYPE=debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -S . -B .vscode")
  print("compile_commands.json 已生成在 .vscode/")
end, {})

-- ============================================================
-- 清除搜索高亮
-- ============================================================
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- ============================================================
-- 窗口跳转（Ctrl+hjkl）
-- ============================================================
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- ============================================================
-- 缓冲区切换
-- ============================================================
map("n", "<Tab>",   ":bnext<CR>",     opts)
map("n", "<S-Tab>", ":bprevious<CR>", opts)
map("n", "<leader>bd", ":bdelete<CR>", opts)

-- ============================================================
-- 诊断跳转
-- ============================================================
map("n", "[d", vim.diagnostic.goto_prev, opts)
map("n", "]d", vim.diagnostic.goto_next, opts)
map("n", "<leader>d", vim.diagnostic.open_float, opts)
