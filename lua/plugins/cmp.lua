-- lua/plugins/cmp.lua
-- nvim-cmp + luasnip 补全，替代原来的 coc.nvim
-- Tab 行为和原 vimrc 保持一致

return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",      -- LSP 补全源
      "hrsh7th/cmp-buffer",        -- 当前缓冲区单词
      "hrsh7th/cmp-path",          -- 文件路径
      "hrsh7th/cmp-cmdline",       -- 命令行补全
      "saadparwaiz1/cmp_luasnip",  -- snippet 源
      {
        "L3MON4D3/LuaSnip",        -- snippet 引擎（替代 ultisnips）
        build = "make install_jsregexp",
        dependencies = {
          "rafamadriz/friendly-snippets",  -- 预置 snippet 库（含 Android/Kotlin）
        },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      "onsails/lspkind.nvim",      -- 补全菜单图标
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- ============================================================
        -- 窗口外观：用 Pmenu 颜色取代默认 NormalFloat 作为窗口背景
        -- ============================================================
        window = {
          completion    = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
          documentation = {
            border = "rounded",
            winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
        },

        -- ============================================================
        -- 按键映射（对应原 vimrc 的 Tab/S-Tab/CR 行为）
        -- ============================================================
        mapping = cmp.mapping.preset.insert({
          -- Tab：有候选时选下一个，否则展开 snippet 或正常 Tab
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          -- S-Tab：选上一个
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          -- Ctrl+Space：强制触发补全（对应原 <c-space>）
          ["<C-Space>"] = cmp.mapping.complete(),

          -- CR：确认选中的候选项（对应原 complete_info 判断）
          ["<CR>"] = cmp.mapping.confirm({ select = false }),

          -- Ctrl+e：关闭补全菜单
          ["<C-e>"] = cmp.mapping.abort(),

          -- 文档滚动
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        }),

        -- ============================================================
        -- 补全来源（优先级从高到低）
        -- ============================================================
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750  },
          { name = "buffer",   priority = 500  },
          { name = "path",     priority = 250  },
        }),

        -- ============================================================
        -- 补全菜单图标（lspkind）
        -- ============================================================
        formatting = {
          format = lspkind.cmp_format({
            mode    = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
          }),
        },
      })

      -- 命令行 / 搜索补全（: 和 /）
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline" } }
        ),
      })
    end,
  },
}
