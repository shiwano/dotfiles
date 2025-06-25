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
local paths = {
  home = vim.fn.expand("$HOME"),
}

local function current_working_directory()
  local dir = vim.fn.getcwd() or ""
  local rel_dir = dir:gsub("^" .. paths.home, "~")
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
      vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile", "BufWritePost" }, {
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
        command = [[highlight default IdeographicSpace ctermbg=Gray guibg=]] .. colors.fg_gutter,
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
          vim.cmd([[highlight MsgArea ctermfg=Gray guifg=]] .. colors.fg_gutter)
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
      local colors = get_colors()

      fzf.setup({
        keymap = {
          fzf = { false },
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

      local function search_files()
        vim.ui.input({ prompt = "Search: " }, function(text)
          if text and #text > 0 then
            fzf.grep({ search = text })
          end
        end)
      end

      local function get_icon_by_filename(filename)
        local filetype = vim.filetype.match({ filename = filename })
        local icon = devicons.get_icon_by_filetype(filetype, { default = true })
        local _, rgb = devicons.get_icon_color_by_filetype(filetype, { default = true })
        return utils.ansi_from_rgb(rgb, icon .. " ")
      end

      local function preview_file_with_query(path, query)
        local line_number = nil
        if query and query ~= "" then
          local escaped_query = query:gsub("'", "'\\''")
          local result = vim.fn.systemlist(string.format("rg --no-heading --line-number --fixed-strings '%s' %s | head -n 1", escaped_query, path))
          if result and result[1] then
            local line = result[1]:match("^(%d+):")
            if line then
              line_number = tonumber(line)
            end
          end
        end
        if line_number then
          return vim.fn.systemlist(string.format("fzf-preview file %s:%d", path, line_number))
        else
          return vim.fn.systemlist(string.format("fzf-preview file %s", path))
        end
      end

      local function find_bookmark()
        local tag_prefix = "BOOKMARK: "

        -- BOOKMARK: bookmarks
        local entries = {
          { name = "rc", path = "~/.config/nvim/init.lua" },
          { name = "tag", path = "~/.config/nvim/init.lua", tag = "bookmarks" },
          { name = "lsp", path = "~/.config/nvim/init.lua", tag = "language_servers" },
          { name = "fmt", path = "~/.config/nvim/init.lua", tag = "formatters" },
          { name = "linters", path = "~/.config/nvim/init.lua", tag = "linters" },
          { name = "projections", path = "~/.config/nvim/init.lua", tag = "alternative_files" },
          { name = "ft", path = "~/.config/nvim/init.lua", tag = "filetypes" },
          { name = "ai-instructions", path = "~/.config/claude/CLAUDE.md" },
          { name = "ai-settings", path = "~/.config/claude/settings.json" },
          { name = "zsh", path = "~/.zshrc" },
          { name = "zshlocal", path = "~/.zshrc.local" },
          { name = "git", path = "~/.gitconfig" },
          { name = "gitignore", path = "~/.gitignore" },
          { name = "tmux", path = "~/.config/tmux/tmux.conf" },
          { name = "stylua", path = "~/dotfiles/.stylua.toml" },
          { name = "homebrew", path = "~/dotfiles/tools/Brewfile" },
          { name = "mise", path = "~/.config/mise/config.toml" },
          { name = "ghostty", path = "~/.config/ghostty/config" },
          { name = "hammerspoon", path = "~/.hammerspoon/init.lua" },
          { name = "bat", path = "~/.config/bat/config" },
        }

        local function find_entry(name)
          for _, entry in ipairs(entries) do
            if entry.name == name then
              return entry
            end
          end
          return nil
        end

        local function preview_entry(entry)
          local expanded_path = vim.fn.expand(entry.path)
          if entry.tag then
            return preview_file_with_query(expanded_path, tag_prefix .. entry.tag)
          else
            return preview_file_with_query(expanded_path, nil)
          end
        end

        local items = vim.tbl_map(function(entry)
          local icon = get_icon_by_filename(entry.path) or ""
          local path = utils.ansi_from_rgb(colors.blue, entry.path)
          if entry.tag and entry.tag ~= "" then
            local tag = utils.ansi_from_rgb(colors.dark5, "(" .. entry.tag .. ")")
            return string.format("%s%s: %s %s", icon, entry.name, path, tag)
          else
            return string.format("%s%s: %s", icon, entry.name, path)
          end
        end, entries)

        fzf.fzf_exec(items, {
          actions = {
            ["default"] = function(selected_items)
              local name = selected_items[1]:match("^[^%w%-]*([%w%-]+):")
              local entry = find_entry(name)
              if entry then
                vim.cmd("edit " .. vim.fn.expand(entry.path))
                if entry.tag and entry.tag ~= "" then
                  local tag = tag_prefix .. entry.tag
                  vim.fn.search(tag, "w") -- "w": wrap around
                end
              end
            end,
          },
          preview = function(selected_items, _, _)
            local name = selected_items[1]:match("^[^%w%-]*([%w%-]+):")
            local entry = find_entry(name)
            if entry then
              return preview_entry(entry)
            end
          end,
        })
      end

      local function search_selection_in_files()
        vim.cmd('silent normal! "zy')
        local text = vim.fn.getreg("z")
        if text and #text > 0 then
          fzf.grep({ search = text })
        end
      end

      local function search_memo_with_text()
        vim.ui.input({ prompt = "SearchMemo: " }, function(text)
          if text and #text > 0 then
            fzf.grep({ search = text, cwd = "~/Dropbox/Memo" })
          end
        end)
      end

      local function list_commands_and_keymaps()
        local init_path = vim.fn.stdpath("config") .. "/init.lua"
        local desc_prefix = "# "

        local map_by_lhs = {}
        local function collect_map(mode, map, scope)
          if map.desc and map.desc:find(desc_prefix) ~= nil then
            map_by_lhs[map.lhs] = map_by_lhs[map.lhs]
              or {
                lhs = map.lhs,
                desc = map.desc,
                modes = {},
                scopes = {},
              }
            table.insert(map_by_lhs[map.lhs].modes, mode)
            map_by_lhs[map.lhs].scopes[scope] = true
          end
        end
        for _, mode in ipairs({ "n", "v", "x", "i", "c", "t" }) do
          for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
            collect_map(mode, m, "global")
          end
          for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
            collect_map(mode, m, "buffer")
          end
        end

        local sorted_maps = {}
        for _, m in pairs(map_by_lhs) do
          table.insert(sorted_maps, m)
        end
        table.sort(sorted_maps, function(a, b)
          return a.lhs < b.lhs
        end)

        local sorted_commands = {}
        local function collect_command(cmd, scope)
          if cmd.definition and cmd.definition:find(desc_prefix) ~= nil then
            table.insert(sorted_commands, { name = cmd.name, desc = cmd.definition, scope = scope })
          end
        end
        for _, cmd in pairs(vim.api.nvim_get_commands({})) do
          collect_command(cmd, "global")
        end
        for _, cmd in pairs(vim.api.nvim_buf_get_commands(0, {})) do
          collect_command(cmd, "buffer")
        end
        table.sort(sorted_commands, function(a, b)
          return a.name < b.name
        end)

        local entries = {}
        for _, m in ipairs(sorted_maps) do
          local kind = utils.ansi_from_rgb(colors.blue, "MAP")
          local scopes = table.concat(vim.tbl_keys(m.scopes), ",")
          local modes = "(" .. table.concat(m.modes, ",") .. ")"
          local scopes_modes = utils.ansi_from_rgb(colors.comment, string.format("%s%-9s", scopes, modes))
          local name = m.lhs:gsub(" ", "<Space>")
          local desc = utils.ansi_from_rgb(colors.dark5, m.desc)
          local item = string.format("%s %-9s %s %s", kind, name, scopes_modes, desc)
          table.insert(entries, { item = item, desc = m.desc })
        end
        for _, c in pairs(sorted_commands) do
          local kind = utils.ansi_from_rgb(colors.orange, "CMD")
          local desc = utils.ansi_from_rgb(colors.dark5, c.desc)
          local scope = utils.ansi_from_rgb(colors.comment, c.scope)
          local item = string.format("%s %-16s %s   %s", kind, c.name, scope, desc)
          table.insert(entries, { item = item, desc = c.desc })
        end

        local items = vim.tbl_map(function(entry)
          return entry.item
        end, entries)

        local function preview_entry(entry)
          return preview_file_with_query(init_path, entry.desc)
        end

        local function find_entry(desc)
          for _, entry in ipairs(entries) do
            if entry.desc == desc then
              return entry
            end
          end
          return nil
        end

        fzf.fzf_exec(items, {
          actions = {
            ["default"] = function(selected_items)
              local desc = selected_items[1]:match("(#%s.-)%s*$")
              local entry = find_entry(desc)
              if entry then
                vim.cmd("edit " .. init_path)
                vim.fn.search(entry.desc, "w") -- "w": wrap around
              end
            end,
          },
          preview = function(selected_items, _, _)
            local desc = selected_items[1]:match("(#%s.-)%s*$")
            local entry = find_entry(desc)
            if entry then
              return preview_entry(entry)
            end
          end,
        })
      end

      vim.keymap.set("n", "<Leader>uf", find_files, { silent = true, desc = "# Find files from the current file's directory" })
      vim.keymap.set("n", "<Leader>uu", fzf.git_files, { silent = true, desc = "# Find files" })
      vim.keymap.set("n", "<Leader>ub", fzf.buffers, { silent = true, desc = "# Find buffers" })
      vim.keymap.set("n", "<Leader>ud", find_files_noignore, { silent = true, desc = "# Find files (no ignore)" })
      vim.keymap.set("n", "<Leader>um", fzf.oldfiles, { silent = true, desc = "# Find recent files" })
      vim.keymap.set("n", "<Leader>ue", fzf.diagnostics_workspace, { silent = true, desc = "# Show diagnostics" })
      vim.keymap.set("n", "<Leader>ug", search_files, { silent = true, desc = "# Search files" })
      vim.keymap.set("n", "<Leader>ut", find_bookmark, { silent = true, desc = "# Find bookmark" })
      vim.keymap.set("n", "<Leader>uh", list_commands_and_keymaps, { silent = true, desc = "# List commands and keymaps" })
      vim.keymap.set("v", "/g", search_selection_in_files, { silent = true, desc = "# Search selection in files" })

      vim.api.nvim_create_user_command("SearchMemo", search_memo_with_text, { desc = "# Search memos" })
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
          end, { silent = true, buffer = true, desc = "# Move up" })
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

      -- BOOKMARK: alternative_files
      local mappings = {
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
      }

      require("other-nvim").setup({
        rememberBuffers = false,
        mappings = mappings,
      })

      vim.api.nvim_create_user_command("A", function()
        require("other-nvim").open()
      end, { desc = "# Open alternative file" })
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

      local function has_words_before()
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
      local function rename()
        local current = vim.fn.expand("<cword>")
        vim.ui.input({ prompt = "New name: ", default = current }, function(text)
          if text and #text > 0 then
            vim.lsp.buf.rename(text)
          end
        end)
      end

      local function format()
        vim.lsp.buf.format({ async = true })
      end

      local function on_attach(_, bufnr)
        vim.keymap.set("n", "od", vim.lsp.buf.definition, { silent = true, buffer = true, desc = "# Jump to the definition (LSP)" })
        vim.keymap.set("n", "ot", vim.lsp.buf.type_definition, { silent = true, buffer = true, desc = "# Jump to the type definition (LSP)" })
        vim.keymap.set("n", "oi", vim.lsp.buf.implementation, { silent = true, buffer = true, desc = "# List implementations (LSP)" })
        vim.keymap.set("n", "of", vim.lsp.buf.references, { silent = true, buffer = true, desc = "# List references (LSP)" })
        vim.keymap.set("n", "on", rename, { silent = true, buffer = true, desc = "# Rename symbol (LSP)" })
        vim.keymap.set({ "n", "v" }, "os", vim.lsp.buf.code_action, { silent = true, buffer = true, desc = "# Execute code action (LSP)" })
        vim.keymap.set("n", "ok", vim.lsp.buf.hover, { silent = true, buffer = true, desc = "# Display information (LSP)" })

        vim.api.nvim_buf_create_user_command(bufnr, "LSPFormat", format, { desc = "# Format (LSP)" })
      end

      local caps = vim.lsp.protocol.make_client_capabilities()
      caps = require("cmp_nvim_lsp").default_capabilities(caps)

      vim.lsp.config("*", {
        on_attach = on_attach,
        capabilities = caps,
      })

      -- BOOKMARK: language_servers
      local ls = {
        go = "gopls",
        typescript = "ts_ls",
        dart = "dartls",
        lua = "lua_ls",
      }

      vim.lsp.config(ls.go, {
        cmd = { "gopls", "-remote=auto", "-remote.listen.timeout=180m" },
      })

      vim.lsp.config(ls.typescript, {
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)

          vim.api.nvim_buf_create_user_command(bufnr, "LSPOrganizeImports", function()
            client.exec_cmd({
              command = "_typescript.organizeImports",
              arguments = { vim.api.nvim_buf_get_name(0) },
            }, { bufnr = bufnr })
          end, { desc = "# Organize imports (LSP)" })
        end,
      })

      vim.lsp.config(ls.lua, {
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
              pathStrict = true,
              path = {
                "?.lua",
                "?/init.lua",
              },
            },
            workspace = {
              library = vim.list_extend(vim.api.nvim_get_runtime_file("lua", true), {
                "${3rd}/luv/library",
                "${3rd}/busted/library",
                "${3rd}/luassert/library",
              }),
              checkThirdParty = "Disable",
            },
          },
        },
      })

      local ls_names = {}
      for _, v in pairs(ls) do
        table.insert(ls_names, v)
      end
      vim.lsp.enable(ls_names)

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

  -----------------------------------------------------------------------------
  -- AI assistant
  -----------------------------------------------------------------------------
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
  {
    "coder/claudecode.nvim",
    config = true,
    opts = {
      terminal = {
        split_side = "left",
        split_width_percentage = 0.30,
        provider = "native",
      },
    },
    keys = {
      { "<Leader>aa", "<cmd>ClaudeCode<cr>", mode = "n", desc = "# Toggle Claude" },
      { "<Leader>aa", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "# Send to Claude" },
      { "<Leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "# Focus Claude" },
      { "<Leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "# Resume Claude" },
      { "<Leader>ac", "<cmd>ClaudeCode --continue<cr>", desc = "# Continue Claude" },
      { "<Leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "# Add current buffer to Claude" },
      { "<Leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "# Accept diff to Claude" },
      { "<Leader>an", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "# Deny diff to Claude" },
    },
  },

  -----------------------------------------------------------------------------
  -- Coding utilities
  -----------------------------------------------------------------------------
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "windwp/nvim-ts-autotag", event = { "BufReadPre", "BufNewFile" }, config = true },
  { "RRethy/nvim-treesitter-endwise", event = { "BufReadPre", "BufNewFile" } },
  { "buoto/gotests-vim", ft = { "go" } },
  { "folke/ts-comments.nvim", event = { "BufReadPre", "BufNewFile" } },
  { "thinca/vim-qfreplace", ft = "qf" },
  { "tiagofumo/dart-vim-flutter-layout", ft = "dart" },
  { "fabridamicelli/cronex.nvim", event = { "BufReadPre", "BufNewFile" } },
  {
    "Vonr/align.nvim",
    branch = "v2",
    cmd = { "Align" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local function align_selection(opts)
        if opts.range == 0 then
          vim.notify("Select a range in visual mode or use :<line1>,<line2>Align", vim.log.levels.WARN)
          return
        end
        vim.ui.input({ prompt = "Align text: " }, function(text)
          if text and #text > 0 then
            require("align").align(text, {
              preview = false,
              regex = false,
              marks = {
                sr = opts.line1,
                sc = 0,
                er = opts.line2,
                ec = math.max(unpack(vim.tbl_map(function(line)
                  return #line
                end, vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)))),
              },
            })
          end
        end)
      end

      vim.api.nvim_create_user_command("Align", align_selection, { range = true, desc = "# Align selection" })
    end,
  },
  {
    "arthurxavierx/vim-caser",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.caser_no_mappings = true

      local function change_case()
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

      vim.keymap.set("v", "oc", change_case, { silent = true, desc = "# Change case" })
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

      vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "# Paste after" })
      vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "# Paste before" })
      vim.keymap.set("n", "<C-p>", "<Plug>(YankyPreviousEntry)", { desc = "# Previous entry" })
      vim.keymap.set("n", "<C-n>", "<Plug>(YankyNextEntry)", { desc = "# Next entry" })
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
          vim.keymap.set("n", "odd", ":DlvDebug<CR>", { silent = true, buffer = true, desc = "# Run debug" })
          vim.keymap.set("n", "odt", ":DlvTest<CR>", { silent = true, buffer = true, desc = "# Run test" })
          vim.keymap.set("n", "odc", ":DlvClearAll<CR>", { silent = true, buffer = true, desc = "# Clear all breakpoints" })
          vim.keymap.set("n", "odb", ":DlvToggleBreakpoint<CR>", { silent = true, buffer = true, desc = "# Toggle breakpoint" })
          vim.keymap.set("n", "odr", ":DlvToggleTracepoint<CR>", { silent = true, buffer = true, desc = "# Toggle tracepoint" })
        end,
      })
    end,
  },

  -----------------------------------------------------------------------------
  -- Linting and code formatting
  -----------------------------------------------------------------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- BOOKMARK: linters
      require("lint").linters_by_ft = {
        go = { "golangcilint" },
        ["yaml.ghaction"] = { "actionlint" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      }

      vim.api.nvim_create_augroup("nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
        group = "nvim_lint",
        pattern = "*",
        callback = function()
          require("lint").try_lint()
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
        -- BOOKMARK: formatters
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
          json = { "jq" },
          toml = { "taplo" },
        },
        format_on_save = function(bufnr)
          if vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 5000, lsp_format = "fallback" }
        end,
      })

      vim.api.nvim_create_user_command("FormatDisable", function()
        vim.b.disable_autoformat = true
      end, { desc = "# Disable autoformat" })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
      end, { desc = "# Enable autoformat" })
    end,
  },

  -----------------------------------------------------------------------------
  -- Documentation
  -----------------------------------------------------------------------------
  {
    "toppair/peek.nvim",
    ft = { "markdown" },
    build = "deno task --quiet build:fast",
    config = function()
      local peek = require("peek")

      peek.setup({
        theme = "light",
      })

      vim.api.nvim_create_augroup("markdown_preview", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = "markdown_preview",
        pattern = "markdown",
        callback = function()
          vim.api.nvim_buf_create_user_command(0, "MarkdownPreview", peek.open, { desc = "# Open markdown preview" })
          vim.api.nvim_buf_create_user_command(0, "MarkdownPreviewClose", peek.close, { desc = "# Close markdown preview" })
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

      vim.api.nvim_create_augroup("term_close", { clear = true })
      vim.api.nvim_create_autocmd("TermClose", {
        group = "term_close",
        pattern = "*",
        command = "bdelete!",
      })

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
  { "nvim-lua/plenary.nvim", lazy = true },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local theme = require("lualine.themes.tokyonight-night")
      local colors = get_colors()

      theme.normal.c = { bg = colors.bg_dark, fg = theme.normal.a.bg }
      theme.insert.c = { bg = colors.bg_dark, fg = theme.insert.a.bg }
      theme.command.c = { bg = colors.bg_dark, fg = theme.command.a.bg }
      theme.visual.c = { bg = colors.bg_dark, fg = theme.visual.a.bg }
      theme.replace.c = { bg = colors.bg_dark, fg = theme.replace.a.bg }
      theme.terminal.c = { bg = colors.bg_dark, fg = theme.terminal.a.bg }
      theme.inactive.a = { bg = colors.bg_dark, fg = colors.fg_gutter }
      theme.inactive.b = { bg = colors.bg_dark, fg = colors.fg_gutter }
      theme.inactive.c = { bg = colors.bg_dark, fg = colors.fg_gutter }

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
            { "lsp_status", icon = "\u{e20f} " },
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
      bigfile = {
        enabled = true,
        notify = true,
        size = 5 * 1024 * 1024, -- 5MB
        line_length = 1000,
        setup = function(ctx)
          if vim.fn.exists(":NoMatchParen") ~= 0 then
            vim.cmd("NoMatchParen")
          end

          vim.bo[ctx.buf].syntax = ""
          vim.bo[ctx.buf].filetype = ""
          vim.bo[ctx.buf].swapfile = false
          vim.bo[ctx.buf].undofile = false

          vim.wo.wrap = false
          vim.wo.number = false
          vim.wo.relativenumber = false
          vim.wo.cursorline = false
          vim.wo.cursorcolumn = false
        end,
      },
      input = { enabled = true },
      picker = { enabled = true, ui_select = true },
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
vim.opt.undodir = paths.home .. "/.config/nvim/undo" -- Undo history directory.
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard.
vim.opt.shortmess:append("c") -- Don't pass messages to |ins-completion-menu|.
vim.opt.updatetime = 300 -- Avaid delays and poor user experienve (default is 4000 ms).
vim.opt.backupcopy = "yes" -- Make a copy of the file and overwrite the original one.
vim.opt.shada = "!,'5000,<50,s10,h" -- Save a lot of info in the shada file.
vim.opt.guicursor = "n-v-c:block" -- Block fixed and no blink.

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

-------------------------------------------------------------------------------
-- Diagnostics
-------------------------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = true, -- Display virtual text inline with the code
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "\u{f057} ",
      [vim.diagnostic.severity.WARN] = "\u{f071} ",
      [vim.diagnostic.severity.HINT] = "\u{f0335} ",
      [vim.diagnostic.severity.INFO] = "\u{f05a} ",
    },
  },
})

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
-- Provider settings
-------------------------------------------------------------------------------
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-------------------------------------------------------------------------------
-- Filetype detection
-------------------------------------------------------------------------------
vim.cmd("filetype plugin indent on")

-- BOOKMARK: filetypes
vim.filetype.add({
  extension = {
    prefab = "yaml",
    shader = "hlsl",
    jb = "ruby",
    ["sublime-syntax"] = "yaml",
  },
  filename = {
    ["dot.zshrc"] = "zsh",
    ["Guardfile"] = "ruby",
    ["Fastfile"] = "ruby",
    ["Appfile"] = "ruby",
  },
  pattern = {
    [".*/%.envrc.*"] = "sh",
    [".*/%.github/workflows/.*%.yaml"] = "yaml.ghaction",
    [".*/%.github/workflows/.*%.yml"] = "yaml.ghaction",
  },
})

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
vim.keymap.set("n", "aa", "@a", { desc = "# Execute macro" })
vim.keymap.set("n", "qa", "qa<Esc>", { desc = "# Start or stop recording macro" })
vim.keymap.set("n", "qq", "<Esc>") -- Disable recording with qq

-- File or URL open
vim.keymap.set("n", "gf", function()
  local cfile = vim.fn.expand("<cfile>")
  if cfile:match("^https?://") then
    vim.ui.open(cfile)
  else
    vim.cmd("normal! gF")
  end
end, { desc = "# Open file or URL" })

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
vim.keymap.set("v", "//", 'y/<C-R>=escape(@", "\\/.*$^~[]")<CR><CR>', { silent = true, desc = "# Search selection" })

-- Replace the selected string
vim.keymap.set("v", "/r", '"xy:%s/<C-R>=escape(@x, "\\/.*$^~[]")<CR>/<C-R>=escape(@x, "\\/.*$^~[]")<CR>/gc<Left><Left><Left>', { desc = "# Replace selection" })

-- Comment toggle
vim.keymap.set("v", "<Leader>cs", "gc", { remap = true, desc = "# Comment out" })
vim.keymap.set("n", "<Leader>cs", "gcc", { remap = true, desc = "# Comment out" })
vim.keymap.set("v", "<Leader>c<Space>", "gc", { remap = true, desc = "# Comment in" })
vim.keymap.set("n", "<Leader>c<Space>", "gcc", { remap = true, desc = "# Comment in" })

-------------------------------------------------------------------------------
-- Custom commands
-------------------------------------------------------------------------------
-- Move to the directory where the current file is located
vim.api.nvim_create_user_command("Cd", function()
  vim.cmd("cd %:h")
end, { desc = "# Change directory to the current file's directory" })

-- Open a file with the specified encoding
vim.api.nvim_create_user_command("Enc", function(opts)
  vim.cmd("edit ++enc=" .. opts.args)
end, { nargs = 1, desc = "# Open a file with the specified encoding" })

-- Remove trailing spaces
vim.api.nvim_create_user_command("Rstrip", function()
  vim.cmd("silent! %s/\\s\\+$//e")
end, { desc = "# Remove trailing spaces" })

-- Show the diff of the current buffer and the specified file
vim.api.nvim_create_user_command("Diff", function(opts)
  vim.cmd("vertical diffsplit " .. opts.args)
end, { nargs = 1, complete = "file", desc = "# Show the diff of the current buffer and the specified file" })

-- Change the line ending to LF and the encoding to UTF-8
vim.api.nvim_create_user_command("Normalize", function()
  vim.opt.fileformat = "unix"
  vim.opt.fileencoding = "utf-8"
end, { desc = "# Change the line ending to LF and the encoding to UTF-8" })

-- Save memo
vim.api.nvim_create_user_command("SaveMemo", function()
  local today = os.date("%Y%m%d")
  local rnd = tostring(math.random(100000, 999999))
  local filename = string.format("%s/Dropbox/Memo/%s-%s.md", paths.home, today, rnd)
  local success, err = pcall(function()
    vim.cmd("write " .. vim.fn.fnameescape(filename))
  end)
  if not success then
    vim.notify("Failed to save memo: " .. err, vim.log.levels.ERROR)
  end
end, { desc = "# Save memo" })

-------------------------------------------------------------------------------
-- Rename
-- original: https://github.com/danro/rename.vim (Vim License)
-------------------------------------------------------------------------------
local function sibling_files(arg_lead)
  local dir = vim.fn.expand("%:h") .. "/"
  local pattern = arg_lead .. "*"
  local all_paths = vim.fn.globpath(dir, pattern, false, true)
  local files = {}
  for _, path in ipairs(all_paths) do
    if vim.fn.isdirectory(path) == 0 then
      table.insert(files, vim.fn.fnamemodify(path, ":t"))
    end
  end
  return files
end

local function rename(name)
  local new_name = vim.trim(name)
  if new_name == "" then
    vim.notify("New name empty", vim.log.levels.WARN)
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
      vim.notify("Failed to excute saveas: " .. err, vim.log.levels.ERROR)
      return
    end
  end

  local current_file = vim.fn.expand("%:p")
  if current_file ~= oldfile and vim.fn.filewritable(current_file) == 1 then
    vim.cmd("bwipe! " .. vim.fn.fnameescape(oldfile))
    local remove_ok, remove_err = pcall(os.remove, oldfile)
    if not remove_ok then
      vim.notify("Failed to remove the old file: " .. tostring(remove_err), vim.log.levels.ERROR)
    end
  end
end

vim.api.nvim_create_user_command("Rename", function(opts)
  rename(opts.args or "")
end, { nargs = "*", complete = sibling_files, desc = "# Rename the current file" })

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
                     Ⅲ:|:| V―ﾍ::::/-ﾙ |/ ﾊﾘ＼     Happy
                     !|:ﾊ:|,-=〟ヽ／,-=.ｿﾊﾘ H        Vimming♡
                     !ヽriｿ Uｿｿ    "ﾊUｿﾉ hNﾉｿ
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
  local ch = type(raw) == "number" and vim.fn.nr2char(raw) or tostring(raw)

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
    vim.notify("No remotes", vim.log.levels.WARN)
    return
  end

  local remote = remotes[1]
  local remote_url = vim.fn.systemlist("git config --get remote." .. remote .. ".url")[1]
  if not remote_url:find("github") then
    vim.notify("Not GitHub repository", vim.log.levels.WARN)
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
      vim.notify("Upstream branch not found", vim.log.levels.WARN)
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

vim.keymap.set("n", "og", open_github_line_url, { silent = true, desc = "# Open GitHub line URL" })

-------------------------------------------------------------------------------
-- Surrounding
-------------------------------------------------------------------------------
local function change_surrounding()
  local surround_pairs = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ["<"] = ">",
  }

  local items = {
    { name = 'Double quotes: "  "', bun = '"' },
    { name = "Single quotes: '  '", bun = "'" },
    { name = "Parentheses: (  )", bun = "(" },
    { name = "Brackets: [  ]", bun = "[" },
    { name = "Braces: {  }", bun = "{" },
    { name = "Angle brackets: <  >", bun = "<" },
    { name = "Backticks: `  `", bun = "`" },
    { name = "Asterisks: *  *", bun = "*" },
    { name = "Double Asterisks: **  **", bun = "**" },
    { name = "Tildes: ~  ~", bun = "~" },
    { name = "Code block: ```\\n  \\n```", bun = "codeblock" },
    { name = "Custom surround...", bun = "custom" },
    { name = "Remove surrounding", bun = "remove" },
  }

  vim.ui.select(items, {
    prompt = "Select surrounding action:",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if not choice then
      return
    end

    local buf = 0
    local s = vim.fn.getpos("'<")
    local e = vim.fn.getpos("'>")
    local sr, sc = s[2] - 1, s[3] - 1 -- 0-based
    local er, ec = e[2] - 1, e[3]

    if choice.bun == "remove" then
      local max_len = math.min(5, sc)
      local to_remove = 0

      for len = max_len, 1, -1 do
        local ok1, pre = pcall(vim.api.nvim_buf_get_text, buf, sr, sc - len, sr, sc, {})
        local ok2, post = pcall(vim.api.nvim_buf_get_text, buf, er, ec, er, ec + len, {})
        if ok1 and ok2 then
          local a, b = pre[1], post[1]
          if len == 1 then
            if (surround_pairs[a] == b) or (a == b) then
              to_remove = 1
              break
            end
          else
            if a == b then
              to_remove = len
              break
            end
          end
        end
      end

      if to_remove > 0 then
        vim.api.nvim_buf_set_text(buf, er, ec, er, ec + to_remove, {})
        vim.api.nvim_buf_set_text(buf, sr, sc - to_remove, sr, sc, {})
      else
        vim.notify("No surrounding characters found to remove", vim.log.levels.WARN)
      end
    elseif choice.bun == "codeblock" then
      vim.api.nvim_buf_set_lines(buf, sr, sr, false, { "```" })
      vim.api.nvim_buf_set_lines(buf, er + 2, er + 2, false, { "```" })
    elseif choice.bun == "custom" then
      vim.ui.input({ prompt = "Surround characters: " }, function(text)
        if text and #text > 0 then
          vim.api.nvim_buf_set_text(buf, er, ec, er, ec, { text })
          vim.api.nvim_buf_set_text(buf, sr, sc, sr, sc, { text })
        end
      end)
    else
      local open = choice.bun
      local close = surround_pairs[open] or open
      vim.api.nvim_buf_set_text(buf, er, ec, er, ec, { close })
      vim.api.nvim_buf_set_text(buf, sr, sc, sr, sc, { open })
    end
  end)
end

vim.keymap.set("v", "ox", change_surrounding, { silent = true, desc = "# Change surrounding characters" })

-------------------------------------------------------------------------------
-- Yank with context
-------------------------------------------------------------------------------
local function yank_with_context()
  local mode = vim.fn.mode()
  local filename = vim.fn.expand("%:t")
  local filedir = vim.fn.expand("%:h")

  local filepath
  if filedir == "." then
    filepath = filename
  else
    filepath = filedir .. "/" .. filename
  end

  if mode == "v" or mode == "V" or mode == "\22" then
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")
    local start_line = math.min(start_pos[2], end_pos[2])
    local end_line = math.max(start_pos[2], end_pos[2])

    local context_text
    if start_line == end_line then
      context_text = string.format("@%s#L%d\n", filepath, start_line)
    else
      context_text = string.format("@%s#L%d-L%d\n", filepath, start_line, end_line)
    end

    vim.fn.setreg("+", context_text)
    vim.notify(string.format("Yanked with context: %s:%d-%d", filename, start_line, end_line))
  else
    local context_text = string.format("@%s\n", filepath)

    vim.fn.setreg("+", context_text)
    vim.notify(string.format("Yanked with context: %s", filename))
  end
end

vim.keymap.set({ "n", "v" }, "<Leader>y", yank_with_context, { desc = "# Yank with file path and line number" })

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
  local current_year = tonumber(os.date("%Y")) or 2001
  local year = math.random(current_year - 5, current_year)
  local month = math.random(1, 12)
  local max_day = tonumber(os.date("%d", os.time({
    year = month == 12 and year + 1 or year,
    month = month == 12 and 1 or month + 1,
    day = 1,
  }) - 86400)) or 28
  local day = math.random(1, max_day)
  return string.format("%04d-%02d-%02d", year, month, day)
end

vim.cmd("inoreabbrev <expr> nuuid v:lua._new_uuid()")
vim.cmd("inoreabbrev <expr> nrand v:lua._new_random()")
vim.cmd("inoreabbrev <expr> npass v:lua._new_password()")
vim.cmd("inoreabbrev <expr> ncolor v:lua._new_hex_color()")
vim.cmd("inoreabbrev <expr> ndate v:lua._new_random_date()")
