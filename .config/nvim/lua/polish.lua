-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE


vim.opt.wrap = true          -- enable line wrapping
vim.opt.linebreak = true     -- wrap at word boundaries, not mid-word
vim.opt.breakindent = true   -- preserve indentation in wrapped lines
vim.opt.showbreak = '↪ '    -- visual indicator for wrapped lines
vim.opt.relativenumber = false

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
