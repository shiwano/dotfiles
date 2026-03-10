local M = {}

local function run_lint(lint, argc)
  for i = 1, argc do
    vim.cmd("argument " .. i)

    if vim.bo.filetype == "" then
      vim.cmd("filetype detect")
    end

    lint.try_lint()

    local done = vim.wait(30000, function()
      return #lint.get_running(0) == 0
    end, 200)

    if not done then
      io.stderr:write("Error: lint timed out\n")
      return false
    end
  end
  return true
end

local function wait_for_lsp(argc)
  if vim.env.NVIM_NO_LSP == "1" then
    return
  end

  local active_progress = 0
  local had_progress = false
  local last_diag_change = 0
  local last_attach = 0
  local augroup = vim.api.nvim_create_augroup("cli_lsp_wait", { clear = true })

  vim.api.nvim_create_autocmd("LspProgress", {
    group = augroup,
    callback = function(ev)
      local value = ev.data and ev.data.params and ev.data.params.value
      if value then
        if value.kind == "begin" then
          active_progress = active_progress + 1
          had_progress = true
        elseif value.kind == "end" then
          active_progress = active_progress - 1
        end
      end
    end,
  })

  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = augroup,
    callback = function()
      last_diag_change = vim.uv.now()
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup,
    callback = function()
      last_attach = vim.uv.now()
    end,
  })

  -- Wait for LSP clients to attach to all buffers (30s timeout)
  local lsp_attached = vim.wait(30000, function()
    local has_any = false
    for buf_i = 1, argc do
      local bufnr = vim.fn.bufnr(vim.fn.argv(buf_i - 1) --[[@as string]])
      if #vim.lsp.get_clients({ bufnr = bufnr }) > 0 then
        has_any = true
      end
    end
    if not has_any then
      return false
    end
    -- Wait until no new LspAttach events for 5s
    return (vim.uv.now() - last_attach) >= 5000
  end, 200)

  if lsp_attached then
    local attach_time = vim.uv.now()
    local progress_done_time = 0

    -- Wait for LSP analysis to complete (60s timeout)
    vim.wait(60000, function()
      -- If progress events were received but not yet complete, keep waiting
      if had_progress and active_progress > 0 then
        return false
      end
      -- Track when progress completed
      if had_progress and progress_done_time == 0 then
        progress_done_time = vim.uv.now()
      end
      -- Wait for diagnostics to stabilize (2s after last change)
      if last_diag_change > 0 then
        return (vim.uv.now() - last_diag_change) >= 2000
      end
      -- Progress completed but no diagnostics yet, wait up to 5s
      if progress_done_time > 0 then
        return (vim.uv.now() - progress_done_time) >= 5000
      end
      -- No signals at all, wait 10s after attach then give up
      return (vim.uv.now() - attach_time) >= 10000
    end, 200)
  end

  vim.api.nvim_del_augroup_by_name("cli_lsp_wait")
end

local function collect_diagnostics(argc)
  local severity_labels = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN] = "WARN",
    [vim.diagnostic.severity.INFO] = "INFO",
    [vim.diagnostic.severity.HINT] = "HINT",
  }

  local has_error = false
  for i = 1, argc do
    local bufnr = vim.fn.bufnr(vim.fn.argv(i - 1) --[[@as string]])
    local diagnostics = vim.diagnostic.get(bufnr)
    if #diagnostics > 0 then
      has_error = true
      local filename = vim.api.nvim_buf_get_name(bufnr)
      for _, d in ipairs(diagnostics) do
        local sev = severity_labels[d.severity] or "UNKNOWN"
        local line = (d.lnum or 0) + 1
        local col = (d.col or 0) + 1
        io.stderr:write(string.format("%s:%d:%d: [%s] %s\n", filename, line, col, sev, d.message))
      end
    end
  end
  return has_error
end

function M.lint()
  vim.schedule(function()
    local ok, lint = pcall(require, "lint")
    if not ok then
      io.stderr:write("Error: nvim-lint is not available\n")
      vim.cmd("cq1")
      return
    end

    local argc = vim.fn.argc()

    if not run_lint(lint, argc) then
      vim.cmd("cq1")
      return
    end

    wait_for_lsp(argc)

    if collect_diagnostics(argc) then
      vim.cmd("cq1")
    else
      vim.cmd("qa!")
    end
  end)
end

function M.format()
  vim.schedule(function()
    local ok, conform = pcall(require, "conform")
    if not ok then
      io.stderr:write("Error: conform.nvim is not available\n")
      vim.cmd("cq1")
      return
    end

    local argc = vim.fn.argc()

    for i = 1, argc do
      vim.cmd("argument " .. i)

      if vim.bo.filetype == "" then
        vim.cmd("filetype detect")
      end

      conform.format({
        async = false,
        timeout_ms = 10000,
        lsp_format = "fallback",
      })
    end

    vim.cmd("wqa")
  end)
end

return M
