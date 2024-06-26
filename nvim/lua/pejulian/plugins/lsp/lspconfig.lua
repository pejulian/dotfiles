return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import mason_lspconfig plugin
    local mason_lspconfig = require("mason-lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions

        local function on_list(options)
          vim.fn.setqflist({}, " ", {
            title = options.title,
            items = options.items,
            context = options.context,
          })

          vim.api.nvim_command("cfirst")
        end

        local wk = require("which-key")
        wk.register({
          g = {
            name = "LSP",
            R = { "<cmd>Telescope lsp_references<CR>", "Show LSP references" },
            D = {
              function()
                vim.lsp.buf.declaration({ on_list = on_list })
              end,
              "Go to declaration",
            },
            d = { "<cmd>Telescope lsp_definitions<CR>", "Show LSP definitions" },
            i = { "<cmd>Telescope lsp_implementations<CR>", "Show LSP implementations" },
            t = { "<cmd>Telescope lsp_type_definitions<CR>", "Show LSP type definitions" },
          },
          ["["] = {
            d = { vim.diagnostic.goto_prev, "Go to previous diagnostic" },
          },
          ["]"] = {
            d = { vim.diagnostic.goto_next, "Go to next diagnostic" },
          },
          K = { vim.lsp.buf.hover, "Show documentation for what is under cursor" },
        }, {
          mode = "n",
          buffer = ev.buf,
          silent = true,
        })

        wk.register({
          l = {
            name = "+lsp",
            c = {
              name = "+config",
              a = { vim.lsp.buf.code_action, "See available code actions" },
            },
          },
        }, {
          prefix = "<leader>",
          mode = "v",
          buffer = ev.buf,
          silent = true,
        })

        wk.register({
          l = {
            name = "+lsp",
            c = {
              name = "+config",
              r = { vim.lsp.buf.rename, "Smart rename" },
              a = { vim.lsp.buf.code_action, "See available code actions" },
              D = { "<cmd>Telescope diagnostics bufnr=0<CR>", "Show buffer diagnostics" },
              d = { vim.diagnostic.open_float, "Show line diagnostics" },
              s = { ":LspRestart<CR>", "Restart LSP" },
            },
          },
        }, { mode = "n", prefix = "<leader>", buffer = ev.buf, silent = true })
      end,
    })

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
    })
  end,
}
