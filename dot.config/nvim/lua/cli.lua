local M = {}

local severity_labels = {
  [vim.diagnostic.severity.ERROR] = "ERROR",
  [vim.diagnostic.severity.WARN] = "WARN",
  [vim.diagnostic.severity.INFO] = "INFO",
  [vim.diagnostic.severity.HINT] = "HINT",
}

function M.lint()
  vim.schedule(function()
    if vim.bo.filetype == "" then
      vim.cmd("filetype detect")
    end

    local ok, lint = pcall(require, "lint")
    if not ok then
      io.stderr:write("Error: nvim-lint is not available\n")
      vim.cmd("cq1")
      return
    end

    lint.try_lint()

    -- Poll until linters finish (timeout 30s)
    local done = vim.wait(30000, function()
      return #lint.get_running(0) == 0
    end, 200)

    if not done then
      io.stderr:write("Error: lint timed out\n")
      vim.cmd("cq1")
      return
    end

    local diagnostics = vim.diagnostic.get(0)
    if #diagnostics == 0 then
      vim.cmd("q!")
      return
    end

    local filename = vim.api.nvim_buf_get_name(0)
    for _, d in ipairs(diagnostics) do
      local sev = severity_labels[d.severity] or "UNKNOWN"
      local line = (d.lnum or 0) + 1
      local col = (d.col or 0) + 1
      io.stderr:write(string.format("%s:%d:%d: [%s] %s\n", filename, line, col, sev, d.message))
    end

    vim.cmd("cq1")
  end)
end

function M.format()
  vim.schedule(function()
    if vim.bo.filetype == "" then
      vim.cmd("filetype detect")
    end

    local ok, conform = pcall(require, "conform")
    if not ok then
      io.stderr:write("Error: conform.nvim is not available\n")
      vim.cmd("cq1")
      return
    end

    conform.format({
      async = false,
      timeout_ms = 10000,
      lsp_format = "fallback",
    })
    vim.cmd("wqa")
  end)
end

return M
