vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.tabstop = 4

-- Fold a C# region
vim.b.match_words = [[\s*#\s*region.*$:\s*#\s*endregion]]
