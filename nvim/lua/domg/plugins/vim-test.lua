return {
  "vim-test/vim-test",
  dependencies = {
    "christoomey/vim-tmux-runner",
  },
  config = function()
    -- Set the test strategy to use vim tmux pane
    vim.g["test#strategy"] = "vtr"
    -- Configure Jsx/Tsx
    vim.g["test#javascript#runner"] = "vitest"
    vim.g["test#javascript#vitest#file_pattern"] = "\\v(spec|test)\\.(js|jsx|ts|tsx)$"
    -- Configure vitest execution in nvim monorepo
    -- vim.g["test#javascript#vitest#executable"] = os.getenv("VITEST_EXECUTABLE_PATH") or "vitest"
    -- local vitest_config_path = os.getenv("VITEST_CONFIG_PATH")
    -- if vitest_config_path then
    --   vim.g["test#javascript#vitest#options"] = "--config " .. vim.fn.shellescape(vitest_config_path)
    -- end
    -- Keymaps
    vim.api.nvim_set_keymap("n", "<leader>h", ":TestNearest<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>y", ":TestFile<CR>", { noremap = true, silent = true })
  end,
}
