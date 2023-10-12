-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
--
-- 
-- Auto resize panes when resizing nvim window
-- taken from https://faultnote.github.io/en/posts/nvchad-settings/

vim.opt.list = true

for i = 1, 9, 1 do
  -- Move to desired buffer line using Alt + 1-9 keys
  vim.keymap.set("n", string.format("<A-%s>", i), function()
    vim.api.nvim_set_current_buf(vim.t.bufs[i])
  end, { desc = "which_key_ignore" })
  -- Move to desired tab group instantly using Leader + 1-9 keys
  vim.keymap.set("n", string.format("<leader>%s", i), function()
    vim.api.nvim_set_current_tabpage(i)
  end, { desc = "which_key_ignore" })
end

