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
  { "RRethy/nvim-base16" },

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
      enable_named_colors = false,
      enable_tailwind = false,
    },
  },

  -----------------------------------------------------------------------------
  -- Finder and file explorer
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
          options = { "--prompt=Files> ", "--select-1", "--scheme=path" },
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
        local text = vim.fn.input("Search: ")
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
        local source = "rg --sortr path --column --line-number --no-heading --color=always --smart-case "
          .. " -- "
          .. vim.fn.shellescape(text)
          .. " ~/Dropbox/Memo"
        vim.call("fzf#vim#grep", source, 1, vim.call("fzf#vim#with_preview"))
      end

      vim.keymap.set("n", "<Leader>uf", find_file_from_buffer_dir_default, { silent = true })
      vim.keymap.set("n", "<Leader>uu", ":GFiles " .. vim.fn.getcwd() .. "<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>us", ":GFiles?<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>ub", ":Buffers<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>ud", find_file_from_buffer_dir_noignore, { silent = true })
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
    event = { "BufReadPre", "BufNewFile" },
    init = function()
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

  -----------------------------------------------------------------------------
  -- Code completion and LSP
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
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
          { name = "lazydev", group_index = 0 },
        }),
        preselect = cmp.PreselectMode.None,
        matching = {
          disallow_fuzzy_matching = true,
          disallow_fullfuzzy_matching = true,
          disallow_partial_fuzzy_matching = true,
          disallow_partial_matching = true,
          disallow_prefix_unmatching = true,
          disallow_symbol_nonprefix_matching = true,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local on_attach = function(client, bufnr)
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
          vim.keymap.set("n", "or", function()
            vim.lsp.buf.execute_command({
              command = "_typescript.organizeImports",
              arguments = { vim.api.nvim_buf_get_name(0) },
            })
          end, { silent = true, buffer = true })
        end
      end

      require("cmp").setup({ sources = { { name = "nvim_lsp" } } })
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      local lspconfig = require("lspconfig")

      lspconfig.gopls.setup({
        cmd = { "gopls", "-remote=auto", "-remote.listen.timeout=180m" },
        on_attach = on_attach,
        capabilities = capabilities,
      })

      lspconfig.lua_ls.setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig.ts_ls.setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig.dartls.setup({ on_attach = on_attach, capabilities = capabilities })
    end,
  },
  {
    "github/copilot.vim",
    init = function()
      vim.g.copilot_no_maps = true
      vim.g.copilot_filetypes = {
        gitcommit = true,
        markdown = true,
      }

      vim.keymap.set("i", "<C-l>", function()
        if vim.b._copilot and vim.b._copilot.suggestions and not vim.tbl_isempty(vim.b._copilot.suggestions) then
          return vim.fn["copilot#Accept"]("\\<CR>")
        else
          return vim.fn["copilot#Suggest"]()
        end
      end, { expr = true, silent = true, replace_keycodes = false })

      vim.keymap.set("i", "<C-j>", "copilot#Next()", { expr = true, silent = true })
      vim.keymap.set("i", "<C-k>", "copilot#Previous()", { expr = true, silent = true })
      vim.keymap.set("i", "<C-h>", "copilot#Dismiss()", { expr = true, silent = true })
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
    "kburdett/vim-nuuid",
    event = "InsertEnter",
    init = function()
      vim.g.nuuid_no_mappings = 1
    end,
  },
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
  { "danro/rename.vim", event = { "BufReadPre", "BufNewFile" } },
  { "arthurxavierx/vim-caser", event = { "BufReadPre", "BufNewFile" } },
  { "thinca/vim-qfreplace", ft = "qf" },

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
  {
    "thinca/vim-quickrun",
    init = function()
      vim.g.quickrun_config = vim.g.quickrun_config or {}
      vim.g.quickrun_config._ = {
        runner = "system",
        ["outputter/buffer/split"] = ":rightbelow 16sp",
        ["outputter/buffer/close_on_empty"] = 1,
      }

      vim.keymap.set("n", "<C-c>", function()
        if vim.fn["quickrun#session#exists()"]() == 0 then
          return "<C-c>"
        end
        vim.fn["quickrun#session#sweep()"]()
      end, { expr = true, silent = true })
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
      max_height_window_percentage = 50,
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
    config = function()
      require("diagram").setup({
        integrations = {
          require("diagram.integrations.markdown"),
          require("diagram.integrations.neorg"),
        },
        renderer_options = {
          mermaid = { theme = "forest" },
          plantuml = { charset = "utf-8" },
          d2 = { theme_id = 1 },
          gnuplot = { theme = "dark", size = "800,600" },
        },
      })
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && yarn install",
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    opts = {
      code = {
        enabled = true,
        sign = false,
        language_name = true,
        style = "full",
        border = "thick",
      },
      link = { enabled = true },
      pipe_table = { enabled = true },
      heading = { enabled = false },
      paragraph = { enabled = false },
      anti_conceal = { enabled = false },
      bullet = { enabled = false },
      inline_highlight = { enabled = false },
      checkbox = { enabled = false },
    },
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
  { "nvim-lua/lsp-status.nvim", lazy = true },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local colors = {
        bg = "#282a2e",
        alt_bg = "#373b41",
        dark_fg = "#969896",
        fg = "#b4b7b4",
        light_fg = "#c5c8c6",
        normal = "#969896",
        insert = "#b5bd68",
        visual = "#b294bb",
        replace = "#de935f",
        terminal = "#81a2ba",
      }
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = {
            normal = {
              a = { fg = colors.bg, bg = colors.normal },
              b = { fg = colors.light_fg, bg = colors.alt_bg },
              c = { fg = colors.fg, bg = colors.bg },
            },
            insert = {
              a = { fg = colors.bg, bg = colors.insert },
              b = { fg = colors.light_fg, bg = colors.alt_bg },
            },
            visual = {
              a = { fg = colors.bg, bg = colors.visual },
              b = { fg = colors.light_fg, bg = colors.alt_bg },
            },
            replace = {
              a = { fg = colors.bg, bg = colors.replace },
              b = { fg = colors.light_fg, bg = colors.alt_bg },
            },
            terminal = {
              a = { fg = colors.bg, bg = colors.terminal },
              b = { fg = colors.light_fg, bg = colors.alt_bg },
            },
            inactive = {
              a = { fg = colors.dark_fg, bg = colors.bg },
              b = { fg = colors.dark_fg, bg = colors.bg },
              c = { fg = colors.dark_fg, bg = colors.bg },
            },
          },
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
                unnamed = "NO NAME",
                newfile = "NEW",
              },
            },
          },
          lualine_c = { "filesize", "diagnostics" },
          lualine_x = {
            "require'lsp-status'.status()",
            { "encoding", show_bomb = true },
            "fileformat",
            "filetype",
          },
          lualine_y = { "branch", "diff" },
          lualine_z = { "selectioncount", "progress", "location" },
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

if vim.g.colors_name ~= "base16-tomorrow-night" then
  vim.cmd("colorscheme base16-tomorrow-night")
end

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
vim.keymap.set(
  "v",
  "/r",
  '"xy:%s/<C-R>=escape(@x, "\\/.*$^~[]")<CR>/<C-R>=escape(@x, "\\/.*$^~[]")<CR>/gc<Left><Left><Left>'
)

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

-- Insert a random number
vim.api.nvim_create_user_command("RandomNumber", function()
  local input_digit = vim.fn.input("Number of digits (default=10):")
  local digit = tonumber(input_digit) or 10

  if digit < 1 then
    vim.api.nvim_err_writeln("Invalid number")
    return
  end

  local max_num = tonumber("9" .. string.rep("0", digit - 1)) or 0
  local rand_num = math.random(0, max_num)
  local insert_text = tostring(rand_num)

  local line = vim.api.nvim_get_current_line()
  local col_idx = vim.fn.col(".") - 1

  local new_line = line:sub(1, col_idx) .. insert_text .. line:sub(col_idx + 1)
  vim.api.nvim_set_current_line(new_line)
  vim.api.nvim_win_set_cursor(0, { vim.fn.line("."), col_idx + #insert_text })
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
-- Terminal
-------------------------------------------------------------------------------
local term_buf_name = nil

local function open_terminal()
  if term_buf_name and vim.fn.bufexists(term_buf_name) ~= 0 then
    vim.cmd("buffer " .. term_buf_name)
  else
    vim.cmd("terminal")
    term_buf_name = vim.fn.bufname("%")
  end
  vim.cmd("startinsert")
end

local function close_terminal()
  local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
  vim.api.nvim_feedkeys(keys, "n", true)
  if vim.fn.bufname("#") ~= "" then
    vim.cmd("edit #")
  else
    vim.cmd("enew")
  end
end

vim.api.nvim_create_user_command("Terminal", open_terminal, {})
vim.cmd([[
  cnoreabbrev <expr> terminal getcmdtype() == ':' && getcmdline() =~ '^terminal\>' ? 'Terminal' : 'terminal'
]])

vim.keymap.set("n", "<C-z>", open_terminal, { silent = true })
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>", { silent = true })

vim.api.nvim_create_augroup("terminal_settings", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  group = "terminal_settings",
  pattern = "term://*/bin/zsh*",
  callback = function()
    vim.keymap.set("t", "<C-z>", "<NOP>", { buffer = true, silent = true })
    vim.keymap.set("t", "fg<CR>", close_terminal, { buffer = true, silent = true })
    vim.opt_local.scrollback = 1000
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
  group = "terminal_settings",
  pattern = "term://*",
  command = "startinsert",
})

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
