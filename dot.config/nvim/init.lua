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
-- Plugins
-------------------------------------------------------------------------------
local pluginSpec = {
  -----------------------------------------------------------------------------
  -- Colorscheme
  -----------------------------------------------------------------------------
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {} },

  -----------------------------------------------------------------------------
  -- Highlighting
  -----------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        modules = {},
        sync_install = false,
        ensure_installed = "all",
        auto_install = false,
        ignore_install = {},
        parser_install_dir = nil,
        highlight = { enable = true, disable = {} },
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
  { "junegunn/fzf" },
  {
    "junegunn/fzf.vim",
    init = function()
      vim.g.fzf_layout = { up = "~40%" }

      vim.g.fzf_action = {
        ["ctrl-q"] = "topleft copen",
        ["ctrl-t"] = "tab split",
        ["ctrl-x"] = "split",
        ["ctrl-v"] = "vsplit",
      }

      local function fzf_status_line()
        vim.api.nvim_set_hl(0, "fzf1", { fg = "#7aa2f7", bg = "#3b4261" })
        vim.api.nvim_set_hl(0, "fzf2", { fg = "#7aa2f7", bg = "#3b4261" })
        vim.api.nvim_set_hl(0, "fzf3", { fg = "#7aa2f7", bg = "#3b4261" })
        vim.opt_local.statusline = "%#fzf1# > %#fzf2#fz%#fzf3#f"
      end

      vim.api.nvim_create_augroup("fzf_status_line", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = "fzf_status_line",
        pattern = "FzfStatusLine",
        callback = fzf_status_line,
      })

      local function escape_pattern(text)
        return text:gsub("([^%w])", "%%%1")
      end

      local function get_buffer_dir()
        local git_root_output = vim.fn.systemlist("git rev-parse --show-toplevel")
        local git_root = (git_root_output and git_root_output[1]) or nil
        local root = vim.fn.expand("%:p:h")
        return (git_root and root:gsub(escape_pattern(git_root) .. "/?", "", 1)) or root
      end

      local function find_file_from_buffer_dir(custom_source)
        local opts = {
          options = { "--prompt=Files> ", "--scheme=path" },
          sink = function(selected)
            if selected and #selected > 0 then
              vim.cmd("edit " .. vim.fn.expand(selected))
            end
          end,
        }

        if custom_source then
          opts.source = custom_source
        end

        local buffer_dir = get_buffer_dir()
        if buffer_dir:match("^/") then
          opts.dir = buffer_dir
        else
          opts.dir = vim.fn.getcwd()
          if #buffer_dir > 0 then
            table.insert(opts.options, "--query=" .. buffer_dir .. "/ ")
          end
        end

        vim.fn["fzf#run"](vim.fn["fzf#wrap"](vim.call("fzf#vim#with_preview", opts)))
      end

      local function find_file_from_buffer_dir_default()
        find_file_from_buffer_dir(nil)
      end

      local function find_file_from_buffer_dir_noignore()
        local noignore_source = table.concat({
          "rg --files --hidden --follow --no-ignore --sort path",
          "-g '!**/.DS_Store'",
          "-g '!**/node_modules'",
          "-g '!**/__pycache__'",
          "-g '!**/.pub-cache'",
          "-g '!**/code/pkg/mod'",
          "-g '!**/code/pkg/sumdb'",
          "-g '!**/.asdf'",
          "-g '!**/.bundle'",
          "-g '!**/.android'",
          "-g '!**/.cocoapods'",
          "-g '!**/.gradle'",
          "-g '!**/.zsh_sessions'",
          "-g '!**/.git'",
        }, " ")
        find_file_from_buffer_dir(noignore_source)
      end

      local function search_files_with_text()
        local ok, text = pcall(vim.fn.input, "Search: ")
        if not ok then
          return
        end
        if #text > 0 then
          local escaped_text = vim.fn.escape(text, "\\.*$+?^[]\\(\\)\\{\\}\\|")
          vim.cmd("Rg " .. escaped_text)
        end
      end

      local function find_bookmark()
        local bookmarks = require("bookmarks")
        local source, pathByName = {}, {}
        for _, b in pairs(bookmarks) do
          table.insert(source, b.name .. ": " .. b.path)
          pathByName[b.name] = b.path
        end
        vim.fn["fzf#run"](vim.fn["fzf#wrap"]({
          source = source,
          options = {
            "--prompt=Bookmarks> ",
            "--preview=fzf-preview file $(echo {} | cut -d: -f2 | sed 's|^ ~|'$HOME'|')",
          },
          sink = function(selected)
            local path = pathByName[selected:match("^(.-):")]
            if path then
              vim.cmd("edit " .. vim.fn.expand(path))
            end
          end,
        }))
      end

      local function search_files_with_selected_text()
        vim.cmd('silent normal! "zy')
        local text = vim.fn.getreg("z")
        if #text > 0 then
          local escaped_text = vim.fn.escape(text, "\\.*$+?^[]\\(\\)\\{\\}\\|")
          vim.cmd("Rg " .. escaped_text)
        end
      end

      local function search_memo_with(text)
        local source = "rg --sortr path --column --line-number --no-heading --color=always --smart-case " .. " -- " .. vim.fn.shellescape(text) .. " ~/Dropbox/Memo"
        vim.call("fzf#vim#grep", source, 1, vim.call("fzf#vim#with_preview"))
      end

      vim.keymap.set("n", "<Leader>uf", find_file_from_buffer_dir_default, { silent = true })
      vim.keymap.set("n", "<Leader>uu", ":GFiles " .. vim.fn.getcwd() .. "<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>ub", ":Buffers<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>ua", find_file_from_buffer_dir_noignore, { silent = true })
      vim.keymap.set("n", "<Leader>um", ":History<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>ug", search_files_with_text, { silent = true })
      vim.keymap.set("n", "<Leader>ut", find_bookmark, { silent = true })
      vim.keymap.set("v", "/g", search_files_with_selected_text, { silent = true })

      vim.api.nvim_create_user_command("SearchMemo", function(opts)
        search_memo_with(opts.args)
      end, { nargs = "*" })
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
      end, { nargs = "*" })
    end,
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      local actions = require("diffview.actions")

      vim.keymap.set("n", "<Leader>us", ":DiffviewOpen<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>uc", ":DiffviewFileHistory<CR>", { silent = true })

      vim.keymap.set("n", "<Leader>ud", function()
        vim.cmd("DiffviewFileHistory " .. vim.fn.expand("%"))
      end, { silent = true })

      local function close()
        vim.cmd("tabclose")
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

      require("diffview").setup({
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
            { "n", "<cr>", goto_file_and_close, { desc = "Open the diff for the selected entry" } },
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
  { "folke/lazydev.nvim", ft = "lua", opts = {} },
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
  {
    "LeafCage/yankround.vim",
    init = function()
      vim.keymap.set("n", "p", "<Plug>(yankround-p)")
      vim.keymap.set("x", "p", "<Plug>(yankround-p)")
      vim.keymap.set("n", "P", "<Plug>(yankround-P)")
      vim.keymap.set("n", "gp", "<Plug>(yankround-gp)")
      vim.keymap.set("x", "gp", "<Plug>(yankround-gp)")
      vim.keymap.set("n", "gP", "<Plug>(yankround-gP)")
      vim.keymap.set("n", "<C-p>", "<Plug>(yankround-prev)")
      vim.keymap.set("x", "<C-p>", "<Plug>(yankround-prev)")
      vim.keymap.set("n", "<C-n>", "<Plug>(yankround-next)")
      vim.keymap.set("x", "<C-n>", "<Plug>(yankround-next)")
    end,
  },
  { "vim-scripts/Align", event = { "BufReadPre", "BufNewFile" } },
  { "folke/ts-comments.nvim", event = { "BufReadPre", "BufNewFile" } },
  { "machakann/vim-sandwich", event = { "BufReadPre", "BufNewFile" } },
  { "arthurxavierx/vim-caser", event = { "BufReadPre", "BufNewFile" } },
  { "thinca/vim-qfreplace", ft = "qf" },
  { "tiagofumo/dart-vim-flutter-layout", ft = "dart" },

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
    event = { "BufReadPre", "BufNewFile" },
    opts = {
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
      },
      format_on_save = {
        timeout_ms = 5000,
        lsp_format = "fallback",
      },
    },
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
      require("diagram").setup({
        integrations = {
          require("diagram.integrations.markdown"),
          require("diagram.integrations.neorg"),
        },
        renderer_options = {
          mermaid = { theme = "default", background = "'#545c7e'", width = 1200 },
          plantuml = { charset = "utf-8" },
          d2 = { theme_id = 1 },
          gnuplot = { theme = "dark", size = "800,600" },
        },
      })

      vim.api.nvim_create_user_command("DiagramCacheClear", function()
        local target = vim.fn.resolve(vim.fn.stdpath("cache") .. "/diagram-cache")
        vim.fn.delete(target, "rf")
        vim.fn.mkdir(target, "p")
      end, {})
    end,
  },
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("MarkdownPreview", function()
        require("peek").open()
        vim.fn.system("hs -c 'G.onMarkdownPreviewLaunch()'")
      end, {})
      vim.api.nvim_create_user_command("MarkdownPreviewClose", require("peek").close, {})
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
  {
    "ruanyl/vim-gh-line",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.gh_line_map_default = 0
      vim.g.gh_line_blame_map_default = 0
      vim.g.gh_line_map = "og"
      vim.g.gh_line_blame_map = "ob"
      vim.g.gh_use_canonical = 0
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "nvim-lua/lsp-status.nvim",
    lazy = true,
    config = function()
      require("lsp-status").config({
        status_symbol = "",
        current_function = false,
        diagnostics = false,
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "tokyonight",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
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
          lualine_b = {
            {
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
            },
          },
          lualine_c = { "diagnostics" },
          lualine_x = {
            "require'lsp-status'.status()",
            { "encoding", show_bomb = true },
            "fileformat",
            { "filetype", icon_only = false },
          },
          lualine_y = { "branch", "selectioncount", "%2v", "%l/%L(%P)" },
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              file_status = true,
              newfile_status = true,
              path = 1, -- Relative path
              shorting_target = 40,
              symbols = {
                modified = "[modified]",
                readonly = "[readonly]",
                unnamed = "NO NAME",
                newfile = "NEW",
              },
            },
          },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },
}

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
-- Colorscheme
-------------------------------------------------------------------------------
vim.opt.termguicolors = true
vim.o.background = "dark" -- or "light" for light mode
vim.o.colorcolumn = "81"

vim.cmd([[colorscheme tokyonight-night]])

vim.api.nvim_create_augroup("highlight_idegraphic_space", {})
vim.api.nvim_create_autocmd({ "VimEnter", "WinEnter" }, {
  group = "highlight_idegraphic_space",
  pattern = { "*" },
  command = [[call matchadd('IdeographicSpace', '[\u00A0\u2000-\u200B\u3000]')]],
})
vim.api.nvim_create_autocmd("VimEnter", {
  group = "highlight_idegraphic_space",
  pattern = { "*" },
  command = [[highlight default IdeographicSpace ctermbg=DarkGreen guibg=DarkGreen]],
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
vim.opt.clipboard:append("unnamed") -- Use system clipboard.
vim.opt.shortmess:append("c") -- Don't pass messages to |ins-completion-menu|.
vim.opt.updatetime = 300 -- Avaid delays and poor user experienve (default is 4000 ms).
vim.opt.backupcopy = "yes" -- Make a copy of the file and overwrite the original one.

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
vim.opt.viminfo = "'5000" -- File history length
vim.opt.showmode = false -- Hide mode message on the last line.
vim.opt.signcolumn = "yes" -- Always show the signcolumn.

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

-------------------------------------------------------------------------------
-- Indent
-------------------------------------------------------------------------------
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
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

local filetype_mappings = {
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
}
vim.api.nvim_create_augroup("filetype_detection", { clear = true })
for pattern, filetype in pairs(filetype_mappings) do
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
-------------------------------------------------------------------------------
local function sibling_files(arg_lead)
  local dir = vim.fn.expand("%:h") .. "/"
  local pattern = arg_lead .. "*"
  local files = vim.fn.globpath(dir, pattern, false, true)
  local results = {}
  for _, path in ipairs(files) do
    table.insert(results, vim.fn.fnamemodify(path, ":t"))
  end
  return results
end

local function rename(opts)
  local new_name = vim.trim(opts.args or "")
  if new_name == "" then
    vim.api.nvim_err_writeln("New name empty")
    return
  end

  local bang = opts.bang and "!" or ""
  local oldfile = vim.fn.expand("%:p")
  local curdir = vim.fn.expand("%:h") .. "/"
  local newfile = curdir .. new_name

  local ok, err = pcall(function()
    vim.cmd("saveas" .. bang .. " " .. vim.fn.fnameescape(newfile))
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

vim.api.nvim_create_user_command("Rename", rename, { nargs = "*", bang = true, complete = sibling_files })
vim.cmd('cabbrev rename <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "Rename" : "rename"<CR>')

-------------------------------------------------------------------------------
-- Splash
-- ref: https://github.com/thinca/vim-splash
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
  vim.o.colorcolumn = ""

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
  vim.o.colorcolumn = colorcolumn

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
