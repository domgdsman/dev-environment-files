return {
  "mg979/vim-visual-multi",
  config = function()
    -- keybinds
    vim.keymap.set("n", "<M-Down>", "<Plug>(VM-Add-Cursor-Down)")
    vim.keymap.set("n", "<M-Up>", "<Plug>(VM-Add-Cursor-Up)")
  end,
}
