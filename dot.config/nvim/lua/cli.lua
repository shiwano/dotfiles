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

function M.format(check_only)
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

    if check_only then
      local lines_before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content_before = table.concat(lines_before, "\n")

      conform.format({
        async = false,
        timeout_ms = 10000,
        lsp_format = "fallback",
      })

      local lines_after = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content_after = table.concat(lines_after, "\n")

      if content_before ~= content_after then
        local filename = vim.api.nvim_buf_get_name(0)
        io.stderr:write(filename .. " needs formatting\n")
        vim.cmd("cq1")
      else
        vim.cmd("q!")
      end
    else
      conform.format({
        async = false,
        timeout_ms = 10000,
        lsp_format = "fallback",
      })
      vim.cmd("wqa")
    end
  end)
end

return M
