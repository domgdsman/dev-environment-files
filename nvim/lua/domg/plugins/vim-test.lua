return {
  "vim-test/vim-test",
  dependencies = {
    "christoomey/vim-tmux-runner",
  },
  config = function()
    -- Set the test strategy to use vim tmux pane
    vim.g["test#strategy"] = "vtr"
    -- Keymaps
    vim.api.nvim_set_keymap("n", "<leader>h", ":TestNearest<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>y", ":TestFile<CR>", { noremap = true, silent = true })
  end,
}
