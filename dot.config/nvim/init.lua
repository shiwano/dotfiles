local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

math.randomseed(os.time())
vim.env.LANG = "en_US.UTF-8"
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-------------------------------------------------------------------------------
-- Utilities
-------------------------------------------------------------------------------

local function current_working_directory()
  local dir = vim.fn.getcwd() or ""
  local home = vim.fn.expand("$HOME") or ""
  local rel_dir = dir:gsub("^" .. home, "~")
  local icon_repo = "\u{ea62} "

  local code_match = rel_dir:match("^~?/code/src/[^/]+/[^/]+/(.*)$")
  if code_match then
    return icon_repo .. code_match
  end
  local dotfiles_match = rel_dir:match("^~?/(dotfiles/?.*)$")
  if dotfiles_match then
    return icon_repo .. dotfiles_match
  end
  return rel_dir
end

local function get_colors()
  return require("tokyonight.colors").setup({ style = "night" })
end

-------------------------------------------------------------------------------
-- Plugins
-------------------------------------------------------------------------------
local pluginSpec = {
  -----------------------------------------------------------------------------
  -- Colorscheme
  -----------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-night]])

      local colors = get_colors()

      vim.api.nvim_create_augroup("highlight_idegraphic_space", {})
      vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
        group = "highlight_idegraphic_space",
        pattern = "*",
        callback = function()
          if vim.bo.buftype == "nofile" then
            return
          end
          vim.cmd([[call matchadd('IdeographicSpace', '[\u00A0\u2000-\u200B\u3000]')]])
        end,
      })
      vim.api.nvim_create_autocmd("VimEnter", {
        group = "highlight_idegraphic_space",
        pattern = "*",
        command = [[highlight default IdeographicSpace ctermbg=Gray guibg=]] .. colors.dark3,
      })

      vim.api.nvim_create_augroup("highlight_msg_area", {})
      vim.api.nvim_create_autocmd("CmdlineEnter", {
        group = "highlight_msg_area",
        pattern = "*",
        callback = function()
          vim.cmd([[highlight MsgArea ctermfg=Yellow guifg=]] .. colors.yellow)
          vim.cmd([[redraw]])
        end,
      })
      vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = "highlight_msg_area",
        pattern = "*",
        callback = function()
          vim.cmd([[highlight MsgArea ctermfg=Gray guifg=]] .. colors.dark3)
        end,
      })
    end,
  },

  -----------------------------------------------------------------------------
  -- Highlighting
  -----------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        modules = {},
        ensure_installed = "all",
        ignore_install = {},
        sync_install = false,
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        endwise = { enable = true },
      })
    end,
  },
  { "mechatroner/rainbow_csv", ft = { "csv" } },
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      enable_tailwind = true,
    },
  },

  -----------------------------------------------------------------------------
  -- File explorer
  -----------------------------------------------------------------------------
  {
    "ibhagwan/fzf-lua",
    config = function()
      local fzf = require("fzf-lua")
      local utils = require("fzf-lua.utils")
      local devicons = require("nvim-web-devicons")

      fzf.setup({
        keymap = {
          fzf = {
            ["tab"] = "down",
            ["shift-tab"] = "up",
            ["ctrl-a"] = "select-all",
            ["ctrl-l"] = "toggle",
            ["ctrl-h"] = "toggle",
            ["ctrl-w"] = "backward-kill-word",
            ["up"] = "preview-page-up",
            ["down"] = "preview-page-down",
            ["ctrl-u"] = "half-page-up",
            ["ctrl-d"] = "half-page-down",
          },
        },
        winopts = {
          split = "aboveleft new",
          height = 0.4,
          width = 1.0,
          row = 1,
          border = "none",
          preview = {
            border = "noborder",
            wrap = "nowrap",
            hidden = "nohidden",
            vertical = "up:50%",
            horizontal = "right:50%",
            layout = "flex",
            flip_columns = 120,
            title = true,
          },
        },
        files = {
          cmd = os.getenv("FZF_DEFAULT_COMMAND"),
          cwd_prompt = false,
        },
        grep = {
          rg_opts = "--sort=path --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        },
      })

      local function get_files_options()
        local cwd = vim.fn.getcwd()
        local filename = vim.api.nvim_buf_get_name(0)
        local abs_dir = vim.fn.fnamemodify(filename, ":p:h")

        if abs_dir == cwd then
          local prompt = current_working_directory() .. "/"
          return { prompt = prompt, cwd = cwd, query = " " }
        elseif vim.startswith(abs_dir, cwd .. "/") then
          local dir = vim.fn.fnamemodify(abs_dir, ":.")
          local prompt = current_working_directory() .. "/"
          return { prompt = prompt, cwd = cwd, query = dir .. "/ " }
        else
          local prompt = vim.fn.fnamemodify(abs_dir, ":t") .. "/"
          return { prompt = "[OUTSIDE] " .. prompt, cwd = abs_dir }
        end
      end

      local function find_files()
        local opts = get_files_options()
        fzf.files(opts)
      end

      local function find_files_noignore()
        local opts = get_files_options()
        opts.no_ignore = true
        opts.hidden = true
        opts.follow = true
        fzf.files(opts)
      end

      local function search_files_with_text()
        vim.ui.input({ prompt = "Search: " }, function(text)
          if text and #text > 0 then
            fzf.grep({ search = text, hidden = true })
          end
        end)
      end

      local function get_icon_by_filename(filename)
        local filetype = vim.filetype.match({ filename = filename })
        local icon = devicons.get_icon_by_filetype(filetype, { default = true })
        local _, rgb = devicons.get_icon_color_by_filetype(filetype, { default = true })
        return utils.ansi_from_rgb(rgb, icon .. " ")
      end

      local function find_bookmark()
        local bookmarks = require("bookmarks")
        local entries = {}
        for _, b in pairs(bookmarks) do
          table.insert(entries, { name = b.name, path = b.path })
        end

        local function find_entry(name)
          for _, entry in ipairs(entries) do
            if entry.name == name then
              return entry
            end
          end
          return nil
        end

        local items = vim.tbl_map(function(entry)
          local icon = get_icon_by_filename(entry.path)
          return entry.name .. ": " .. (icon or "") .. entry.path
        end, entries)

        fzf.fzf_exec(items, {
          actions = {
            ["default"] = function(item)
              local name = item[1]:match("^(.-):"):gsub("%s+$", "")
              local entry = find_entry(name)
              if entry then
                vim.cmd("edit " .. vim.fn.expand(entry.path))
              end
            end,
          },
          preview = function(item, fzf_lines, _)
            local name = item[1]:match("^(.-):"):gsub("%s+$", "")
            local entry = find_entry(name)
            if entry then
              local all_lines = vim.fn.systemlist("fzf-preview file " .. entry.path)
              local sliced = {}
              for i = 1, math.min(fzf_lines, #all_lines) do
                table.insert(sliced, all_lines[i])
              end
              return sliced
            end
          end,
        })
      end

      local function search_files_with_selected_text()
        vim.cmd('silent normal! "zy')
        local text = vim.fn.getreg("z")
        if text and #text > 0 then
          fzf.grep({ search = text, hidden = true })
        end
      end

      local function search_memo_with_text()
        vim.ui.input({ prompt = "SearchMemo: " }, function(text)
          if text and #text > 0 then
            fzf.grep({ search = text, cwd = "~/Dropbox/Memo" })
          end
        end)
      end

      vim.keymap.set("n", "<Leader>uf", find_files, { silent = true })
      vim.keymap.set("n", "<Leader>uu", fzf.git_files, { silent = true })
      vim.keymap.set("n", "<Leader>ub", fzf.buffers, { silent = true })
      vim.keymap.set("n", "<Leader>ud", find_files_noignore, { silent = true })
      vim.keymap.set("n", "<Leader>um", fzf.oldfiles, { silent = true })
      vim.keymap.set("n", "<Leader>ue", fzf.diagnostics_workspace, { silent = true })
      vim.keymap.set("n", "<Leader>ug", search_files_with_text, { silent = true })
      vim.keymap.set("n", "<Leader>ut", find_bookmark, { silent = true })
      vim.keymap.set("v", "/g", search_files_with_selected_text, { silent = true })

      vim.api.nvim_create_user_command("SearchMemo", search_memo_with_text, {})
    end,
  },
  { "kevinhwang91/nvim-bqf", ft = "qf" },
  {
    "mattn/vim-molder",
    init = function()
      vim.api.nvim_create_augroup("molder", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "molder",
        pattern = "molder",
        callback = function()
          vim.keymap.set("n", "<BS>", function()
            vim.call("molder#up")
          end, { silent = true, buffer = true })
        end,
      })
    end,
  },
  {
    "rgroli/other.nvim",
    cmd = "A",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local function p(pattern, ignorePattern)
        return function(file)
          if file:match(ignorePattern) then
            return nil
          end
          local match = { file:match(pattern) }
          return #match > 0 and match or nil
        end
      end

      require("other-nvim").setup({
        rememberBuffers = false,
        mappings = {
          "rails",
          "rust",
          -- Go
          { pattern = p("(.+)%.go$", "_test%.go$"), target = "%1_test.go" },
          { pattern = "(.+)_test%.go$", target = "%1.go" },
          -- TypeScript
          { pattern = p("(.+)%.ts$", "%.test%.ts$"), target = "%1.test.ts" },
          { pattern = "(.+)%.test%.ts$", target = "%1.ts" },
          { pattern = p("(.+)%.tsx$", "%.test%.tsx$"), target = "%1.test.tsx" },
          { pattern = "(.+)%.test%.tsx$", target = "%1.tsx" },
          -- JavaScript
          { pattern = p("(.+)%.js$", "%.test%.js$"), target = "%1.test.js" },
          { pattern = "(.+)%.test%.js$", target = "%1.js" },
          { pattern = p("(.+)%.jsx$", "%.test%.jsx$"), target = "%1.test.jsx" },
          { pattern = "(.+)%.test%.jsx$", target = "%1.jsx" },
          -- Flutter
          {
            pattern = p("lib/(.+)%.dart$", "%.g%.dart$"),
            target = {
              { context = "test", target = "test/%1_test.dart" },
              { context = "generated", target = "lib/%1.g.dart" },
            },
          },
          { pattern = "test/(.+)_test%.dart$", target = "lib/%1.dart" },
          { pattern = "lib/(.+)%.g%.dart$", target = "lib/%1.dart" },
          -- Python
          { pattern = p("(.+)/([^/]+)%.py$", "/test_[^/]+%.py$"), target = "%1/test_%2.py" },
          { pattern = "(.+)/test_(.+)%.py$", target = "%1/%2.py" },
          -- C
          { pattern = "(.+)%.c$", target = "%1.h" },
          { pattern = "(.+)%.h$", target = "%1.c" },
          -- C++
          { pattern = "(.+)%.cpp$", target = "%1.hpp" },
          { pattern = "(.+)%.hpp$", target = "%1.cpp" },
        },
      })

      vim.api.nvim_create_user_command("A", function()
        require("other-nvim").open()
      end, {})
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local actions = require("diffview.actions")

      local function select_diff_view()
        local items = {
          { name = "History of the current file", cmd = "DiffviewFileHistory " .. vim.fn.expand("%") },
          { name = "History of all files", cmd = "DiffviewFileHistory" },
          { name = "Current diff", cmd = "DiffviewOpen" },
        }

        vim.ui.select(items, {
          prompt = "Select One of:",
          format_item = function(item)
            return item.name
          end,
        }, function(choice)
          if choice then
            vim.cmd(choice.cmd)
          end
        end)
      end

      local function close()
        if vim.fn.tabpagenr("$") > 1 then
          vim.cmd("tabclose")
        end
      end

      local bufnr = nil
      local function goto_file_and_close()
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_delete(bufnr, {})
          bufnr = nil
        end
        actions.goto_file_split()
        bufnr = vim.api.nvim_get_current_buf()
        vim.keymap.set("n", "<C-c>", close, { silent = true, buffer = true })
        vim.cmd("wincmd =")
      end

      vim.keymap.set("n", "<Leader>d", select_diff_view, { silent = true })

      require("diffview").setup({
        view = {
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
            winbar_info = true,
          },
        },
        keymaps = {
          disable_defaults = true,
          view = {
            { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
            { "n", "N", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
            { "n", "n", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
            unpack(actions.compat.fold_cmds),
          },
          diff1 = {
            { "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
          },
          diff2 = {
            { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
          },
          diff3 = {
            { { "n", "x" }, "2do", actions.diffget("ours"), { desc = "Obtain the diff hunk from the OURS version of the file" } },
            { { "n", "x" }, "3do", actions.diffget("theirs"), { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
            { "n", "g?", actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
          },
          diff4 = {
            { { "n", "x" }, "1do", actions.diffget("base"), { desc = "Obtain the diff hunk from the BASE version of the file" } },
            { { "n", "x" }, "2do", actions.diffget("ours"), { desc = "Obtain the diff hunk from the OURS version of the file" } },
            { { "n", "x" }, "3do", actions.diffget("theirs"), { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
            { "n", "g?", actions.help({ "view", "diff4" }), { desc = "Open the help panel" } },
          },
          file_panel = {
            { "n", "<c-c>", close, { desc = "Close the panel" } },
            { "n", "j", actions.select_next_entry, { desc = "Bring the cursor to the next file entry" } },
            { "n", "<down>", actions.select_next_entry, { desc = "Bring the cursor to the next file entry" } },
            { "n", "k", actions.select_prev_entry, { desc = "Bring the cursor to the previous file entry" } },
            { "n", "<up>", actions.select_prev_entry, { desc = "Bring the cursor to the previous file entry" } },
            { "n", "N", actions.prev_conflict, { desc = "Go to the previous conflict" } },
            { "n", "n", actions.next_conflict, { desc = "Go to the next conflict" } },
            { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
            { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
            { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
            { "n", "R", actions.refresh_files, { desc = "Update stats and entries in the file list" } },
            { "n", "g?", actions.help("file_panel"), { desc = "Open the help panel" } },
          },
          file_history_panel = {
            { "n", "<c-c>", close, { desc = "Close the panel" } },
            { "n", "<cr>", goto_file_and_close, { desc = "Open the diff for the selected entry" } },
            { "n", "j", actions.select_next_entry, { desc = "Bring the cursor to the next file entry" } },
            { "n", "<down>", actions.select_next_entry, { desc = "Bring the cursor to the next file entry" } },
            { "n", "k", actions.select_prev_entry, { desc = "Bring the cursor to the previous file entry" } },
            { "n", "<up>", actions.select_prev_entry, { desc = "Bring the cursor to the previous file entry" } },
            { "n", "g!", actions.options, { desc = "Open the option panel" } },
            { "n", "y", actions.copy_hash, { desc = "Copy the commit hash of the entry under the cursor" } },
            { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
            { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
            { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
            { "n", "g?", actions.help("file_history_panel"), { desc = "Open the help panel" } },
          },
          option_panel = {
            { "n", "<tab>", actions.select_entry, { desc = "Change the current option" } },
            { "n", "q", actions.close, { desc = "Close the panel" } },
            { "n", "g?", actions.help("option_panel"), { desc = "Open the help panel" } },
          },
          help_panel = {
            { "n", "q", actions.close, { desc = "Close help menu" } },
            { "n", "<esc>", actions.close, { desc = "Close help menu" } },
          },
        },
      })
    end,
  },

  -----------------------------------------------------------------------------
  -- Code completion
  -----------------------------------------------------------------------------
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  { "hrsh7th/cmp-nvim-lsp", lazy = true },
  { "hrsh7th/cmp-path", lazy = true },
  { "hrsh7th/cmp-buffer", lazy = true },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      local types = require("cmp.types")

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        if col == 0 then
          return false
        end
        local line_text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
        return line_text:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.confirm({ select = true })
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        }),
        sources = cmp.config.sources({
          {
            name = "nvim_lsp",
            entry_filter = function(entry, _)
              local kind = types.lsp.CompletionItemKind[entry:get_kind()]
              if kind == "Text" then
                return false
              end
              return true
            end,
          },
          { name = "path" },
          { name = "buffer" },
          { name = "lazydev", group_index = 0 },
        }),
        preselect = cmp.PreselectMode.None,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lsp_status = require("lsp-status")
      lsp_status.register_progress()

      local on_attach = function(client, bufnr)
        lsp_status.on_attach(client)

        vim.keymap.set("n", "od", vim.lsp.buf.definition, { silent = true, buffer = true })
        vim.keymap.set("n", "ot", vim.lsp.buf.type_definition, { silent = true, buffer = true })
        vim.keymap.set("n", "oi", vim.lsp.buf.implementation, { silent = true, buffer = true })
        vim.keymap.set("n", "of", vim.lsp.buf.references, { silent = true, buffer = true })
        vim.keymap.set("n", "on", vim.lsp.buf.rename, { silent = true, buffer = true })
        vim.keymap.set({ "n", "v" }, "os", vim.lsp.buf.code_action, { silent = true, buffer = true })
        vim.keymap.set("n", "ok", vim.lsp.buf.hover, { silent = true, buffer = true })

        vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
          vim.lsp.buf.format({ async = true })
        end, {})

        if client.name == "ts_ls" then
          vim.api.nvim_buf_create_user_command(bufnr, "OrganizeImports", function()
            vim.lsp.buf.execute_command({
              command = "_typescript.organizeImports",
              arguments = { vim.api.nvim_buf_get_name(0) },
            })
          end, {})
        end
      end

      local caps = vim.lsp.protocol.make_client_capabilities()
      caps = require("cmp_nvim_lsp").default_capabilities(caps)
      caps = vim.tbl_extend("keep", caps, lsp_status.capabilities)

      local cfg = require("lspconfig")

      cfg.gopls.setup({
        cmd = { "gopls", "-remote=auto", "-remote.listen.timeout=180m" },
        on_attach = on_attach,
        capabilities = caps,
      })

      cfg.lua_ls.setup({ on_attach = on_attach, capabilities = caps })
      cfg.ts_ls.setup({ on_attach = on_attach, capabilities = caps })
      cfg.dartls.setup({ on_attach = on_attach, capabilities = caps })

      vim.api.nvim_create_augroup("lsp_diff_diagnostics_off", {})
      vim.api.nvim_create_autocmd("BufEnter", {
        group = "lsp_diff_diagnostics_off",
        pattern = "*",
        callback = function()
          if vim.opt.diff:get() then
            vim.diagnostic.enable(false)
          end
        end,
      })
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = { enabled = false },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          debounce = 100,
          keymap = {
            accept = "<C-l>",
            next = "<C-j>",
            prev = "<C-k>",
            dismiss = "<C-h>",
          },
        },
        filetypes = {
          yaml = true,
          markdown = true,
          gitcommit = true,
        },
        copilot_node_command = "node",
      })
    end,
  },

  -----------------------------------------------------------------------------
  -- Coding utilities
  -----------------------------------------------------------------------------
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, config = true },
  { "RRethy/nvim-treesitter-endwise", event = { "BufReadPre", "BufNewFile" } },
  { "buoto/gotests-vim", ft = { "go" } },
  { "vim-scripts/Align", event = { "BufReadPre", "BufNewFile" } },
  { "folke/ts-comments.nvim", event = { "BufReadPre", "BufNewFile" } },
  { "machakann/vim-sandwich", event = { "BufReadPre", "BufNewFile" } },
  { "thinca/vim-qfreplace", ft = "qf" },
  { "tiagofumo/dart-vim-flutter-layout", ft = "dart" },
  {
    "arthurxavierx/vim-caser",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.caser_no_mappings = true

      local function select_case()
        local items = {
          { name = "PascalCase", funcName = "MixedCase" },
          { name = "camelCase", funcName = "CamelCase" },
          { name = "snake_case", funcName = "SnakeCase" },
          { name = "MACRO_CASE", funcName = "UpperCase" },
          { name = "kebab-case", funcName = "KebabCase" },
          { name = "Train-Case", funcName = "TitleKebabCase" },
          { name = "dot.case", funcName = "DotCase" },
        }
        vim.ui.select(items, {
          prompt = "Select case style:",
          format_item = function(item)
            return item.name
          end,
        }, function(choice)
          if choice then
            vim.fn["caser#DoAction"](choice.funcName, vim.fn.visualmode())
          end
        end)
      end

      vim.keymap.set("v", "oc", select_case, { silent = true })
    end,
  },
  {
    "gbprod/yanky.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("yanky").setup({
        ring = {
          history_length = 100,
          storage = "memory",
        },
        system_clipboard = {
          sync_with_ring = true,
        },
        highlight = {
          on_put = false,
          on_yank = false,
        },
      })

      vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
      vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
      vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
      vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
      vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
      vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
    end,
  },

  -----------------------------------------------------------------------------
  -- Debugging
  -----------------------------------------------------------------------------
  {
    "sebdah/vim-delve",
    ft = { "go" },
    init = function()
      vim.api.nvim_create_augroup("delve", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "delve",
        pattern = "go",
        callback = function()
          vim.keymap.set("n", "odd", ":DlvDebug<CR>", { silent = true, buffer = true })
          vim.keymap.set("n", "odt", ":DlvTest<CR>", { silent = true, buffer = true })
          vim.keymap.set("n", "odc", ":DlvClearAll<CR>", { silent = true, buffer = true })
          vim.keymap.set("n", "odb", ":DlvToggleBreakpoint<CR>", { silent = true, buffer = true })
          vim.keymap.set("n", "odr", ":DlvToggleTracepoint<CR>", { silent = true, buffer = true })
        end,
      })
    end,
  },

  -----------------------------------------------------------------------------
  -- Linting and code formatting
  -----------------------------------------------------------------------------
  {
    "w0rp/ale",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.ale_linters = {
        go = { "gobuild", "golangci-lint" },
      }
      vim.g.ale_go_golangci_lint_options = ""
      vim.g.ale_go_golangci_lint_package = 1

      vim.keymap.set("n", "ol", ":ALEDetail<CR>", { silent = true })

      vim.api.nvim_create_augroup("ale", { clear = true })
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = "ale",
        pattern = "*/.github/*/*.y{,a}ml",
        callback = function()
          vim.b.ale_linters = { yaml = { "actionlint" } }
        end,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    cmd = { "FormatDisable", "FormatEnable" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go = { "goimports" },
          gomod = { "goimports" },
          c = { "clang-format" },
          cpp = { "clang-format" },
          objc = { "clang-format" },
          dart = { "dart_format" },
          lua = { "stylua" },
          python = { "isort", "black" },
          rust = { "rustfmt" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          markdown = { "markdownfmt" },
          sh = { "shfmt" },
        },
        format_on_save = function(bufnr)
          if vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 500, lsp_format = "fallback" }
        end,
      })

      vim.api.nvim_create_user_command("FormatDisable", function()
        vim.b.disable_autoformat = true
      end, {})
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
      end, {})
    end,
  },

  -----------------------------------------------------------------------------
  -- Documentation
  -----------------------------------------------------------------------------
  {
    "3rd/image.nvim",
    ft = { "markdown", "vimwiki", "neorg", "typst" },
    opts = {
      backend = "kitty",
      processor = "magick_rock",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = true,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          floating_windows = true,
          filetypes = { "markdown", "vimwiki" },
        },
        neorg = { enabled = true, filetypes = { "norg" } },
        typst = { enabled = true, filetypes = { "typst" } },
        html = { enabled = false },
        css = { enabled = false },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 90,
      window_overlap_clear_enabled = false,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      editor_only_render_when_focused = true,
      tmux_show_only_in_active_window = true,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.svg" },
    },
  },
  {
    "3rd/diagram.nvim",
    ft = { "markdown", "vimwiki", "neorg", "typst" },
    cmd = "DiagramCacheClear",
    config = function()
      local colors = get_colors()

      require("diagram").setup({
        integrations = {
          require("diagram.integrations.markdown"),
          require("diagram.integrations.neorg"),
        },
        renderer_options = {
          mermaid = { theme = "default", background = "'" .. colors.dark3 .. "'", width = 1200 },
          plantuml = { charset = "utf-8" },
          d2 = { theme_id = 1 },
          gnuplot = { theme = "dark", size = "800,600" },
        },
      })

      vim.api.nvim_create_user_command("DiagramCacheClear", function()
        local target = require("diagram").get_cache_dir()
        vim.fn.delete(target, "rf")
        vim.fn.mkdir(target, "p")
      end, {})
    end,
  },
  {
    "toppair/peek.nvim",
    ft = { "markdown" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()

      vim.api.nvim_create_augroup("markdown_preview", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "markdown_preview",
        pattern = "markdown",
        callback = function()
          vim.api.nvim_buf_create_user_command(0, "MarkdownPreview", require("peek").open, {})
          vim.api.nvim_buf_create_user_command(0, "MarkdownPreviewClose", require("peek").close, {})
        end,
      })
    end,
  },

  -----------------------------------------------------------------------------
  -- Terminal
  -----------------------------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    config = function()
      vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { silent = true })

      require("toggleterm").setup({
        size = 100,
        open_mapping = [[<C-z>]],
        hide_numbers = true,
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
      })
    end,
  },

  -----------------------------------------------------------------------------
  -- Misc
  -----------------------------------------------------------------------------
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvim-lua/lsp-status.nvim",
    lazy = true,
    config = function()
      require("lsp-status").config({
        status_symbol = "\u{e20f}",
        current_function = false,
        diagnostics = false,
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local theme = require("lualine.themes.tokyonight-night")
      local colors = get_colors()

      theme.normal.c = { bg = colors.bg, fg = theme.normal.a.bg }
      theme.insert.c = { bg = colors.bg, fg = theme.insert.a.bg }
      theme.command.c = { bg = colors.bg, fg = theme.command.a.bg }
      theme.visual.c = { bg = colors.bg, fg = theme.visual.a.bg }
      theme.replace.c = { bg = colors.bg, fg = theme.replace.a.bg }
      theme.terminal.c = { bg = colors.bg, fg = theme.terminal.a.bg }
      theme.inactive.a.fg = theme.inactive.c.fg
      theme.inactive.b.gui = nil
      theme.inactive.c.bg = colors.bg

      local function encoding()
        ---@diagnostic disable-next-line: undefined-field
        local result = vim.opt.fileencoding:get():upper()
        if vim.opt.bomb:get() then
          return result .. " [BOM]"
        end
        return result
      end

      local filename = {
        "filename",
        file_status = true,
        newfile_status = true,
        path = 1, -- Relative path
        shorting_target = 40,
        symbols = {
          modified = "[modified]",
          readonly = "[readonly]",
          newfile = "[new]",
          unnamed = "NO NAME",
        },
      }

      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = theme,
          disabled_filetypes = {
            statusline = { "fzf" },
            winbar = { "fzf" },
          },
          ignore_focus = {},
          always_divide_middle = true,
          always_show_tabline = true,
          globalstatus = false,
          refresh = { statusline = 100, tabline = 100, winbar = 100 },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { current_working_directory },
          lualine_c = { filename, "diagnostics" },
          lualine_x = {
            "require'lsp-status'.status()",
            { "filetype", icon_only = false },
            "fileformat",
            encoding,
            "branch",
          },
          lualine_y = { "selectioncount", "%1v", "%l/%L(%P)" },
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = { "mode" },
          lualine_b = { current_working_directory },
          lualine_c = { filename },
          lualine_x = { "%1v", "%l/%L(%P)" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      input = { enabled = true },
      picker = { ui_select = true },
      notifier = { enabled = true },
    },
  },
}

---@diagnostic disable-next-line: missing-fields
require("lazy").setup({
  spec = pluginSpec,
  install = { colorscheme = { "habamax" } },
  rocks = { enabled = true, hererocks = true },
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
      },
    },
  },
})

-------------------------------------------------------------------------------
-- General settings
-------------------------------------------------------------------------------
vim.opt.title = false -- Don't change the terminal title.
vim.opt.scrolloff = 5 -- Ensure that there are always 5 lines visible above and below the cursor.
vim.opt.writebackup = false -- Don't create backup files.
vim.opt.backup = false -- No backup.
vim.opt.swapfile = false -- No swap file.
vim.opt.autoread = true -- Automatically reload files changed outside of NeoVim.
vim.opt.hidden = true -- Allow switching buffers without saving.
vim.opt.backspace = "indent,eol,start" -- Allow backspacing over everything.
vim.opt.formatoptions = "lmoq" -- Automatically format text.
vim.opt.visualbell = false -- No visual bell.
vim.opt.whichwrap:append("b,s,h,l,<,>,[,]") -- Allow moving cursor from start and end of line.
vim.opt.magic = true -- Enable regular expressions.
vim.opt.foldenable = false -- No folding.
vim.opt.modeline = false -- No modeline.
vim.opt.undofile = true -- Save undo history to a file.
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undo" -- Undo history directory.
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard.
vim.opt.shortmess:append("c") -- Don't pass messages to |ins-completion-menu|.
vim.opt.updatetime = 300 -- Avaid delays and poor user experienve (default is 4000 ms).
vim.opt.backupcopy = "yes" -- Make a copy of the file and overwrite the original one.
vim.opt.shada = "!,'5000,<50,s10,h" -- Save a lot of info in the shada file.

-------------------------------------------------------------------------------
-- View
-------------------------------------------------------------------------------
vim.opt.showcmd = true -- Show last command in the status line.
vim.opt.number = true -- Show line numbers.
vim.opt.numberwidth = 6 -- Show 6 digits for line numbers.
vim.opt.ruler = true -- Show the line and column number of the cursor.
vim.opt.list = true -- Show special characters.
vim.opt.listchars = "tab:>.,trail:_,extends:>,precedes:<,nbsp:+" -- Specify characters for special characters.
vim.opt.display:append("uhex") -- Show hex value of the unprintable characters.
vim.opt.breakindent = true -- Wrapped long lines are indented.
vim.opt.showmode = false -- Hide mode message on the last line.
vim.opt.signcolumn = "yes" -- Always show the signcolumn.
vim.opt.colorcolumn = "81" -- Color column at 81 characters
vim.opt.background = "dark" -- Dark background
vim.opt.termguicolors = true -- Enable 24-bit RGB color in the terminal

-- Draw the cursor line.
vim.api.nvim_create_augroup("cch", { clear = true })
vim.api.nvim_create_autocmd("WinLeave", {
  group = "cch",
  pattern = "*",
  command = "set nocursorline",
})
vim.api.nvim_create_autocmd({ "WinEnter", "BufRead" }, {
  group = "cch",
  pattern = "*",
  command = "set cursorline",
})

-- Move to last cursor position
vim.api.nvim_create_augroup("last_cursor", { clear = true })
vim.api.nvim_create_autocmd("BufRead", {
  group = "last_cursor",
  pattern = "*",
  callback = function()
    local last_pos = vim.fn.line("'\"")
    if last_pos > 0 and last_pos <= vim.fn.line("$") then
      vim.cmd('normal! g`"zz')
    end
  end,
})

-- Diagnostic signs
for type, icon in pairs({ Error = "\u{f057}", Warn = "\u{f071}", Hint = "\u{f0335}", Info = "\u{f05a}" }) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-------------------------------------------------------------------------------
-- Indent
-------------------------------------------------------------------------------
vim.opt.autoindent = false
vim.opt.smartindent = false
vim.opt.cindent = false
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true -- Use spaces instead of tabs.

-------------------------------------------------------------------------------
-- Command completion and history
-------------------------------------------------------------------------------
vim.opt.wildmenu = true -- Enable command completion.
vim.opt.wildchar = vim.api.nvim_replace_termcodes("<Tab>", true, true, true):byte() -- Use <Tab> for wildmenu.
vim.opt.wildmode = "list:full" -- Show all matches.
vim.opt.history = 1000 -- Maximum number of command history.

-------------------------------------------------------------------------------
-- Current buffer search
-------------------------------------------------------------------------------
vim.opt.wrapscan = false -- Don't wrap search.
vim.opt.ignorecase = true -- Ignore case when searching.
vim.opt.smartcase = true -- Don't ignore case if the search pattern starts with a capital letter.
vim.opt.incsearch = true -- Incremental search.
vim.opt.hlsearch = true -- Highlight search results.

-------------------------------------------------------------------------------
-- Encodings
-------------------------------------------------------------------------------
vim.opt.ffs = "unix,dos,mac"
vim.opt.fileencodings:append("iso-2022-jp-3")
vim.opt.fileencodings:append("cp932")
vim.opt.fileencodings:append("euc-jisx0213")
vim.opt.fileencodings:append("euc-jp")

-------------------------------------------------------------------------------
-- Filetype detection
-------------------------------------------------------------------------------
vim.cmd("filetype plugin indent on")

vim.api.nvim_create_augroup("filetype_detection", { clear = true })
for pattern, filetype in pairs({
  ["dot.zshrc"] = "zsh",
  ["dot.tmux.*"] = "tmux",
  ["dot.gitconfig"] = "gitconfig",
  ["*.prefab"] = "yaml",
  ["*.shader"] = "hlsl",
  ["Guardfile"] = "ruby",
  ["Fastfile"] = "ruby",
  ["Appfile"] = "ruby",
  [".envrc*"] = "sh",
  ["*.jb"] = "ruby",
}) do
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = "filetype_detection",
    pattern = pattern,
    command = "set filetype=" .. filetype,
  })
end

-------------------------------------------------------------------------------
-- Key mappings
-------------------------------------------------------------------------------
-- JK
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Jump
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "G", "Gzz")

-- Macro recording
vim.keymap.set("n", "aa", "@a")
vim.keymap.set("n", "qa", "qa<Esc>")
vim.keymap.set("n", "qq", "<Esc>") -- Disable recording with qq

-- File or URL open
vim.keymap.set("n", "gf", function()
  local cfile = vim.fn.expand("<cfile>")
  if cfile:match("^https?://") then
    vim.ui.open(cfile)
  else
    vim.cmd("normal! gF")
  end
end)

-- Window navigation
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-h>", "<C-w>h")

-- No highlight
vim.keymap.set("n", "L", ":nohl<CR>", { silent = true })

-- Command history
vim.keymap.set("c", "<C-p>", "<Up>")
vim.keymap.set("c", "<C-n>", "<Down>")

-- Command mode
vim.keymap.set({ "n", "v" }, ";", ":")
vim.keymap.set({ "n", "v" }, ":", "q:")

-- Search the selected text
vim.keymap.set("v", "//", 'y/<C-R>=escape(@", "\\/.*$^~[]")<CR><CR>', { silent = true })

-- Count the number of occurrences of the selected string
vim.keymap.set("v", "/n", 'y:%s/<C-R>=escape(@", "\\/.*$^~[]")<CR>/&/gn<CR>', { silent = true })

-- Replace the selected string
vim.keymap.set("v", "/r", '"xy:%s/<C-R>=escape(@x, "\\/.*$^~[]")<CR>/<C-R>=escape(@x, "\\/.*$^~[]")<CR>/gc<Left><Left><Left>')

-- Comment toggle
vim.keymap.set("v", "<Leader>cs", "gc", { remap = true })
vim.keymap.set("n", "<Leader>cs", "gcc", { remap = true })
vim.keymap.set("v", "<Leader>c<Space>", "gc", { remap = true })
vim.keymap.set("n", "<Leader>c<Space>", "gcc", { remap = true })

-------------------------------------------------------------------------------
-- Custom commands
-------------------------------------------------------------------------------
-- Move to the directory where the current file is located
vim.api.nvim_create_user_command("Cd", function()
  vim.cmd("cd %:h")
end, {})

-- Open a file with the specified encoding
vim.api.nvim_create_user_command("Enc", function(opts)
  vim.cmd("edit ++enc=" .. opts.args)
end, { nargs = 1 })

-- Remove trailing spaces
vim.api.nvim_create_user_command("Rstrip", function()
  vim.cmd("silent! %s/\\s\\+$//e")
end, {})

-- Show the diff of the current buffer and the specified file
vim.api.nvim_create_user_command("Diff", function(opts)
  vim.cmd("vertical diffsplit " .. opts.args)
end, { nargs = 1, complete = "file" })

-- Change the line ending to LF and the encoding to UTF-8
vim.api.nvim_create_user_command("Normalize", function()
  vim.opt.fileformat = "unix"
  vim.opt.fileencoding = "utf-8"
end, {})

-- Format JSON (using jq)
vim.api.nvim_create_user_command("JSONFormat", function()
  vim.cmd("%!jq .")
end, {})

-- Save memo
vim.api.nvim_create_user_command("SaveMemo", function()
  local today = os.date("%Y%m%d")
  local rnd = tostring(math.random(100000, 999999))
  local filename = os.getenv("HOME") .. "/Dropbox/Memo/" .. today .. "-" .. rnd .. ".md"

  local success, err = pcall(function()
    vim.cmd("write " .. vim.fn.fnameescape(filename))
  end)

  if not success then
    vim.api.nvim_err_writeln("Failed to save memo: " .. err)
  end
end, {})

-------------------------------------------------------------------------------
-- Rename
-- original: https://github.com/danro/rename.vim (Vim License)
-------------------------------------------------------------------------------
local function sibling_files(arg_lead)
  local dir = vim.fn.expand("%:h") .. "/"
  local pattern = arg_lead .. "*"
  local paths = vim.fn.globpath(dir, pattern, false, true)
  local files = {}
  for _, path in ipairs(paths) do
    if vim.fn.isdirectory(path) == 0 then
      table.insert(files, vim.fn.fnamemodify(path, ":t"))
    end
  end
  return files
end

local function rename(name)
  local new_name = vim.trim(name)
  if new_name == "" then
    vim.api.nvim_err_writeln("New name empty")
    return
  end

  local oldfile = vim.fn.expand("%:p")
  local curdir = vim.fn.expand("%:h") .. "/"
  local newfile = curdir .. new_name

  local ok, err = pcall(function()
    vim.cmd("saveas" .. " " .. vim.fn.fnameescape(newfile))
  end)
  if not ok then
    if err and not err:match("E329") then
      vim.api.nvim_err_writeln("Failed to excute saveas: " .. err)
      return
    end
  end

  local current_file = vim.fn.expand("%:p")
  if current_file ~= oldfile and vim.fn.filewritable(current_file) == 1 then
    vim.cmd("bwipe! " .. vim.fn.fnameescape(oldfile))
    local remove_ok, remove_err = pcall(os.remove, oldfile)
    if not remove_ok then
      vim.api.nvim_err_writeln("Failed to remove the old file: " .. tostring(remove_err))
    end
  end
end

vim.api.nvim_create_user_command("Rename", function(opts)
  rename(opts.args or "")
end, { nargs = "*", complete = sibling_files })

vim.cmd('cabbrev rename <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "Rename" : "rename"<CR>')

-------------------------------------------------------------------------------
-- Splash
-- original: https://github.com/thinca/vim-splash (zlib License)
-------------------------------------------------------------------------------
local function splash()
  if vim.fn.argc() ~= 0 or vim.fn.bufnr("$") ~= 1 then
    return
  end
  local wrap = vim.opt_local.wrap
  local list = vim.opt_local.list
  local number = vim.opt_local.number
  local foldenable = vim.opt_local.foldenable
  local colorcolumn = vim.o.colorcolumn
  local orig_bufnr = vim.api.nvim_get_current_buf()

  vim.cmd("hide enew")
  vim.opt_local.buftype = "nofile"
  vim.opt_local.bufhidden = "wipe"
  vim.opt_local.wrap = false
  vim.opt_local.list = false
  vim.opt_local.number = false
  vim.opt_local.foldenable = false
  vim.opt.colorcolumn = ""

  local art = [[
                         ﾒ __-─-,-- _
                       ,ｲ >:::::::::::< ヽ〟
                 ヽ─イ /,::::,::::::::＼  ＞─r
                   ヾ〟//:!:::ﾊ::::::|:!:ヽ ,丿
                     ソ r:ﾘﾔ ハ::::::ﾊ:ﾊ::|rﾍ〟
                     Ⅲ:|:| V―ﾍ::::/-ﾙﾞ|/ ﾊﾘ＼     Happy
                     !|:ﾊ:|,-=〟ヽ／,-=.ｿﾊﾘ H        Vimming♡
                     !ヽriｿﾞUｿｿﾞ   "ﾊUｿﾉﾞhNﾉｿ
                     |!ﾊヾヾ｀      ｀´ﾉlﾘ´
                     ﾉ:ﾉﾊ ﾊ      丶     ｸﾊ        ____
      _＿_______(ヽ/(ヾ/ﾊ,:ヽ    冖   ∠||ヽ _-==|リリ!)
  ,-´￢￢─-─／＼＼ ＼ﾉ:ﾊ＼ゝ =- ハvﾉリ:ヾ丿::(⊃´ ｲ==-──´
 ((-====Ξ二二::-´＼ヾ ＼-ヾ::``丶^ )／|:!)!:::<(___/卜-'ヾ=-―´
／ｿ  ／ﾊ／ ∠/ --===(  ) ⊂)ヽへ:::)==Η!ηv 》:!>====|≡≡)
! ｀ !/ﾘ  ﾘ/:-=="ヽ:ヽ'"   |,   -ﾘﾘﾉ  |!＼乂  ヾ:ﾙ | ﾙ=-"ヾヽ
     | | ハヽ-=/:ﾘヽ::(>___|) -=='" =-v-"===ヽ》|| ﾊ ||ヾ)ﾊ
     ﾊ ! !!ヾ !:/ﾘ/ヽ:ヽ   |/    ‖   /＼ Vim ヽ》 ! ||   ﾘ
_＿／ｿ    V   //／'|ヽ:ﾊ) |Ｙ   ‖   /:::＼ !  }‖  !||   /
             ‖  | |/ヽ!ﾘ | |   |   / |:::|＼ヽＶ   |||  (
                 ＼＼ハ|| | |   |   ! |:::| ＼(!＼   ﾘ|   `
                   ＼＼!| | | | |   / |:::|  ＼＼＼__!ﾉ
                       )! | ヾ! /  /  ^::::^   ﾍ ヾ
                      <,/ |  " /  / __!--==-!__ ﾊ ヽ=-- __
                  __====>ヾ／／ ／三二＝＝＝二三!＼＼--    =-- __
               (-== イ    ／    ‖/ / /   | | ＼＼ ＼   ＼ ＼_=-|
               ＼    ＼,∠     ‖/ / /    | |   ＼＼＼＼  ｀/  /
                 ＼ ／ ＼      ﾙ ／      仝    !  ＼＼＼,／ ＼/
                 (       >   ////    i   ||  |  i|  ＼＼＼    )
                  ヽ ／_      //     |   ||  |   |   ヽヽ ゞ"
                    ヽヽ/￢/- <" - _ |   Ｙ  |   ||   ヽヽ＜
                      ^"  /"  '  ||  》 /  __|  _||    >  >
                       > > |     || <_____=--_=--->_=->_=ﾞ
                        ヾ_|    /::ヽ_   /    //   !   > >
                            |／":::::ヽ=/,   //    /<=-´
                            |:::::|:::| |===//-===/´
                            ヽ::::|:::|/:::::::::/
                             |::::|:::ﾘ:::::/:::/
                             |::::|::::ﾘ:::/:::/
]]

  local content = {}
  for line in art:gmatch("[^\n]+") do
    table.insert(content, line)
  end

  local sw, sh = vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0)
  local top_pad = math.floor((sh - #content) / 2)
  local max_width = 0
  for _, line in ipairs(content) do
    local w = vim.fn.strdisplaywidth(line)
    if w > max_width then
      max_width = w
    end
  end
  local left_pad = string.rep(" ", math.floor((sw - max_width) / 2))

  local lines = {}
  for _ = 1, top_pad do
    lines[#lines + 1] = ""
  end
  for _, line in ipairs(content) do
    lines[#lines + 1] = left_pad .. line
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd("redraw")

  local raw = vim.fn.getchar()
  local ch = type(raw) == "number" and vim.fn.nr2char(raw) or raw

  local new_bufnr = vim.api.nvim_get_current_buf()
  vim.cmd("silent! " .. (orig_bufnr == new_bufnr and "enew" or orig_bufnr .. " buffer"))
  vim.opt_local.wrap = wrap
  vim.opt_local.list = list
  vim.opt_local.number = number
  vim.opt_local.foldenable = foldenable
  vim.opt.colorcolumn = colorcolumn

  vim.api.nvim_feedkeys("\x1B", "n", false) -- <ESC>
  vim.api.nvim_input(ch)
end

vim.api.nvim_create_augroup("splash", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", { group = "splash", callback = splash })
vim.api.nvim_create_autocmd("StdinReadPre", {
  group = "splash",
  callback = function()
    vim.api.nvim_clear_autocmds({ group = "splash", event = "VimEnter" })
  end,
})

-------------------------------------------------------------------------------
-- Open GitHub line URL
-- original: https://github.com/ruanyl/vim-gh-line (MIT License)
-------------------------------------------------------------------------------
local function open_github_line_url()
  local remotes = vim.fn.systemlist("git remote")
  if #remotes == 0 then
    print("no remotes")
    return
  end

  local remote = remotes[1]
  local remote_url = vim.fn.systemlist("git config --get remote." .. remote .. ".url")[1]
  if not remote_url:find("github") then
    print("not GitHub repository")
    return
  end

  local base_url = remote_url
  base_url = base_url:gsub("^ssh://", "")
  base_url = base_url:gsub("^([^@]+)@([^:/]+)[:/](.+)$", "https://%2/%3")
  base_url = base_url:gsub("%.git$", "")

  local commit_id = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]

  local remote_branches = vim.fn.systemlist("git branch -r")
  local branch_exists = false
  for _, branch in ipairs(remote_branches) do
    branch = branch:gsub("^%s+", ""):gsub("%s+$", "")
    if branch == remote .. "/" .. commit_id then
      branch_exists = true
      break
    end
  end

  if not branch_exists then
    local upstream_branch = vim.fn.systemlist("git rev-parse --abbrev-ref @{u}")[1]
    if not upstream_branch or upstream_branch == "" then
      print("upstream branch not found")
      return
    end
    commit_id = upstream_branch:gsub("^origin/", "")
  end

  local full_path = vim.fn.expand("%:p")
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  local relative_path = full_path:sub(#git_root + 1)
  local line_num = vim.fn.line(".")

  local url = base_url .. "/blob/" .. commit_id .. relative_path .. "#" .. "L" .. line_num
  vim.fn.system("open " .. url)
end

vim.keymap.set("n", "og", open_github_line_url, { silent = true })

-------------------------------------------------------------------------------
-- Abbreviations for insert mode
-------------------------------------------------------------------------------
function _G._new_uuid()
  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  return string
    .gsub(template, "[xy]", function(c)
      local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
      return string.format("%x", v)
    end)
    :upper()
end

function _G._new_random()
  local digit = 10
  local max_num = tonumber("9" .. string.rep("0", digit - 1)) or 0
  local rand_num = math.random(0, max_num)
  return tostring(rand_num)
end

function _G._new_password()
  local length = 16
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()"
  local password = {}
  for _ = 1, length do
    local rand = math.random(1, #chars)
    table.insert(password, chars:sub(rand, rand))
  end
  return table.concat(password)
end

function _G._new_hex_color()
  return string.format("#%06X", math.random(0, 0xFFFFFF))
end

function _G._new_random_date()
  local year = math.random(2000, 2030)
  local month = math.random(1, 12)
  local day = math.random(1, 28)
  return string.format("%04d-%02d-%02d", year, month, day)
end

vim.cmd("inoreabbrev <expr> nuuid v:lua._new_uuid()")
vim.cmd("inoreabbrev <expr> nrand v:lua._new_random()")
vim.cmd("inoreabbrev <expr> npass v:lua._new_password()")
vim.cmd("inoreabbrev <expr> ncolor v:lua._new_hex_color()")
vim.cmd("inoreabbrev <expr> ndate v:lua._new_random_date()")
