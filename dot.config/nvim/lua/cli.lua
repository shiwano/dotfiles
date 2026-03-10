local M = {}

local severity_labels = {
  [vim.diagnostic.severity.ERROR] = "ERROR",
  [vim.diagnostic.severity.WARN] = "WARN",
  [vim.diagnostic.severity.INFO] = "INFO",
  [vim.diagnostic.severity.HINT] = "HINT",
}

function M.lint()
  vim.schedule(function()
    local ok, lint = pcall(require, "lint")
    if not ok then
      io.stderr:write("Error: nvim-lint is not available\n")
      vim.cmd("cq1")
      return
    end

    local argc = vim.fn.argc()
    local has_error = false

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
        vim.cmd("cq1")
        return
      end

      local diagnostics = vim.diagnostic.get(0)
      if #diagnostics > 0 then
        has_error = true
        local filename = vim.api.nvim_buf_get_name(0)
        for _, d in ipairs(diagnostics) do
          local sev = severity_labels[d.severity] or "UNKNOWN"
          local line = (d.lnum or 0) + 1
          local col = (d.col or 0) + 1
          io.stderr:write(string.format("%s:%d:%d: [%s] %s\n", filename, line, col, sev, d.message))
        end
      end
    end

    if has_error then
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
