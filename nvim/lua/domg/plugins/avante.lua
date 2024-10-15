return {
  "yetone/avante.nvim",
  commit = "f92c3a60f356ff1f9af19946f8675ade7e4b7b49",
  event = "VeryLazy",
  lazy = false,
  -- version = false, -- set this if you want to always pull the latest change
  opts = {
    provider = "claude",
    claude = {
      endpoint = "https://api.anthropic.com",
      model = "claude-3-5-sonnet-20240620",
      temperature = 0,
      max_tokens = 4096,
    },
    auto_suggestions_provider = "copilot",
  },
  keys = function(_, keys)
    ---@type avante.Config
    local opts =
      require("lazy.core.plugin").values(require("lazy.core.config").spec.plugins["avante.nvim"], "opts", false)

    -- Ensure opts.mappings exists
    if not opts.mappings then
      opts.mappings = {
        ask = "<leader>ua", -- ask
        edit = "<leader>ue", -- edit
        refresh = "<leader>ur", -- refresh
        sidebar = {
          switch_windows = "<S-Tab>", -- conficts with copilot completion
          reverse_switch_windows = "<C-S-Tab>",
        },
      }
    end

    -- use avante api to set keymaps
    local mappings = {
      {
        opts.mappings.ask,
        function()
          require("avante.api").ask()
        end,
        desc = "avante: ask",
        mode = { "n", "v" },
      },
      {
        opts.mappings.refresh,
        function()
          require("avante.api").refresh()
        end,
        desc = "avante: refresh",
        mode = "v",
      },
      {
        opts.mappings.edit,
        function()
          require("avante.api").edit()
        end,
        desc = "avante: edit",
        mode = { "n", "v" },
      },
    }
    mappings = vim.tbl_filter(function(m)
      return m[1] and #m[1] > 0
    end, mappings)
    return vim.list_extend(mappings, keys)
  end,
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  -- build = "make",
  build = "LUA_VERSION=luajit bash ./build.sh",
  -- -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
