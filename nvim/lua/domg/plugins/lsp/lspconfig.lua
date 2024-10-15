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

    local keymap = vim.keymap -- for conciseness

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf, silent = true }

        -- set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

        opts.desc = "Show LSP settings"
        keymap.set("n", "<leader>ri", function()
          print(vim.inspect(vim.lsp.get_clients()[2].config.settings))
        end, opts) -- print lsp settings to `:messages`
      end,
    })

    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Function to load workspace-specific settings
    local function load_workspace_settings(server_name, root_dir)
      local settings_file = root_dir .. "/.nvim/lspconfig.lua"
      if vim.fn.filereadable(settings_file) == 1 then
        local ok, project_settings = pcall(dofile, settings_file)
        if ok then
          if project_settings[server_name] then
            -- Log that the workspace configuration was loaded
            vim.notify(
              "Loaded workspace settings for '" .. server_name .. "' from " .. settings_file,
              vim.log.levels.DEBUG
            )
            return project_settings[server_name]
          else
            -- Log that no settings were found for the server
            vim.notify(
              "No workspace settings found for '" .. server_name .. "' in " .. settings_file,
              vim.log.levels.DEBUG
            )
          end
        else
          -- Log error if the settings file couldn't be loaded
          vim.notify(
            "Error loading workspace settings from " .. settings_file .. ": " .. project_settings,
            vim.log.levels.ERROR
          )
        end
      else
        -- Optionally log that no settings file was found
        vim.notify("No workspace settings file found at " .. settings_file, vim.log.levels.DEBUG)
      end
      return {}
    end

    -- Common setup function
    local function common_setup(opts, server_name)
      -- used to enable autocompletion (assign to every lsp server config)
      opts.capabilities = cmp_nvim_lsp.default_capabilities()
      opts.on_new_config = function(new_config, root_dir)
        local workspace_settings = load_workspace_settings(server_name, root_dir)
        if next(workspace_settings) ~= nil then
          vim.notify("Applying workspace settings for '" .. server_name .. "'", vim.log.levels.DEBUG)
          -- Merge workspace settings with existing settings
          new_config.settings =
            vim.tbl_deep_extend("force", new_config.settings or {}, workspace_settings.settings or {})
        else
          vim.notify("Using default settings for '" .. server_name .. "'", vim.log.levels.DEBUG)
        end
      end
      return opts
    end

    mason_lspconfig.setup_handlers({
      -- default handler for all installed servers
      function(server_name)
        local opts = common_setup({
          on_attach = function(client, bufnr)
            -- default on_attach function or keybindings
          end,
          settings = {},
        }, server_name)
        lspconfig[server_name].setup(opts)
      end,
      ["rust_analyzer"] = function()
        local opts = common_setup({
          on_attach = function(client, bufnr)
            local opts = { buffer = bufnr, silent = true }
            -- Hover actions
            opts.desc = "Show documentation for what is under cursor"
            keymap.set("n", "<Leader>i", vim.lsp.buf.hover, opts)
          end,
          settings = {
            ["rust-analyzer"] = {
              -- Default rust-analyzer settings
            },
          },
        }, "rust_analyzer")
        lspconfig["rust_analyzer"].setup(opts)
      end,
      ["lua_ls"] = function()
        local opts = common_setup({
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
        }, "lua_ls")
        lspconfig["lua_ls"].setup(opts)
      end,
      ["yamlls"] = function()
        local opts = common_setup({
          settings = {
            yaml = {
              format = {
                enable = true,
              },
              schemaStore = {
                enable = true,
              },
              validate = true,
              hover = true,
              completion = true,
            },
          },
        }, "yamlls")
        lspconfig["yamlls"].setup(opts)
      end,
      ["jsonls"] = function()
        local opts = common_setup({
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        }, "jsonls")
        lspconfig["jsonls"].setup(opts)
      end,
    })
  end,
}
