-- lua/plugins/lsp.lua
-- nvim 0.11+ 原生 vim.lsp.config API（lspconfig 已弃用）
-- mason 负责安装可执行文件，vim.lsp.config 负责注册配置

return {
  -- mason：LSP 可执行文件安装器
  {
    "williamboman/mason.nvim",
    cmd  = "Mason",
    opts = { ui = { border = "rounded" } },
  },

  -- mason-lspconfig：把 mason 安装的服务器名映射到 vim.lsp.config 名
  {
    "williamboman/mason-lspconfig.nvim",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "pyright",
        "clangd",
        "kotlin_language_server",
        "jsonls",
        "html",
        "cssls",
        "ts_ls",
        "marksman",
      },
      automatic_installation = true,
    },
  },

  -- cmp-nvim-lsp（在 cmp.lua 里也有声明，这里作为 dependency 保证顺序）
  { "hrsh7th/cmp-nvim-lsp", lazy = true },

  -- 主 LSP 配置（保留 nvim-lspconfig 作 mason-lspconfig 的桥接，但不调用 lspconfig.xxx.setup）
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- ============================================================
      -- LspAttach autocmd：替代 on_attach 函数
      -- nvim 0.11 推荐写法，所有 buffer 统一处理
      -- ============================================================
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
        callback = function(ev)
          local bufnr = ev.buf
          local bopts = { noremap = true, silent = true, buffer = bufnr }
          local map   = vim.keymap.set

          map("n", "gd",  vim.lsp.buf.definition,      bopts)
          map("n", "gD",  function()
            vim.cmd("tab split")
            vim.lsp.buf.definition()
          end, bopts)
          map("n", "gy",  vim.lsp.buf.type_definition, bopts)
          map("n", "gi",  vim.lsp.buf.implementation,  bopts)
          map("n", "gr",  vim.lsp.buf.references,      bopts)
          map("n", "K",   vim.lsp.buf.hover,           bopts)
          map("n", "<leader>rn", vim.lsp.buf.rename,   bopts)
          map("n", "<leader>ca", vim.lsp.buf.code_action, bopts)
          map("n", "<leader>f",  function()
            vim.lsp.buf.format({ async = true })
          end, bopts)

          -- 光标悬停高亮（有能力才绑，避免报错）
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/documentHighlight") then
            vim.api.nvim_create_autocmd("CursorHold",  { buffer = bufnr, callback = vim.lsp.buf.document_highlight })
            vim.api.nvim_create_autocmd("CursorMoved", { buffer = bufnr, callback = vim.lsp.buf.clear_references  })
          end
        end,
      })

      -- ============================================================
      -- vim.lsp.config：nvim 0.11 新 API，替代 lspconfig.xxx.setup()
      -- ============================================================

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
            telemetry   = { enable = false },
          },
        },
      })

      vim.lsp.config("pyright", {
        capabilities = capabilities,
      })

      vim.lsp.config("clangd", {
        capabilities = capabilities,
        cmd = { "clangd", "--background-index", "--clang-tidy" },
      })

      vim.lsp.config("kotlin_language_server", {
        capabilities = capabilities,
        settings = {
          kotlin = {
            compiler     = { jvm = { target = "17" } },
            externalSources = { autoConvertToKotlin = true },
          },
        },
        init_options = {
          storagePath = vim.fn.stdpath("data") .. "/kotlin-ls",
        },
      })

      for _, server in ipairs({ "jsonls", "html", "cssls", "ts_ls", "marksman" }) do
        vim.lsp.config(server, { capabilities = capabilities })
      end

      -- 批量启用
      vim.lsp.enable({
        "lua_ls", "pyright", "clangd",
        "kotlin_language_server",
        "jsonls", "html", "cssls", "ts_ls", "marksman",
      })

      -- ============================================================
      -- Android SDK 工具命令
      -- ============================================================
      local sdk     = "/opt/android-sdk/cmdline-tools/latest/bin"
      local lint    = sdk .. "/lint"
      local apkanal = sdk .. "/apkanalyzer"

      vim.api.nvim_create_user_command("AndroidLint", function()
        local dir  = vim.fn.expand("%:p:h")
        local root = vim.fn.findfile("build.gradle", dir .. ";")
        if root == "" then root = vim.fn.findfile("build.gradle.kts", dir .. ";") end
        if root == "" then print("找不到 build.gradle"); return end
        vim.cmd("botright 15new")
        vim.fn.termopen(lint .. " --project " .. vim.fn.fnamemodify(root, ":h") .. " 2>&1 | head -50")
      end, { desc = "Android SDK lint" })

      vim.api.nvim_create_user_command("ApkInfo", function(a)
        if a.args == "" then print("用法: :ApkInfo <apk路径>"); return end
        vim.cmd("botright 20new")
        vim.fn.termopen(apkanal .. " apk summary " .. a.args)
      end, { nargs = 1, desc = "APK 信息" })

      -- ============================================================
      -- 诊断样式
      -- ============================================================
      vim.diagnostic.config({
        virtual_text  = { prefix = "●" },
        severity_sort = true,
        float         = { border = "rounded", source = true },
      })
    end,
  },
}
