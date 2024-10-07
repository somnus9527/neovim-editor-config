-- ---@param bufnr integer
-- ---@param ... string
-- ---@return string
-- local function first(bufnr, ...)
--   local conform = require "conform"
--   for i = 1, select("#", ...) do
--     local formatter = select(i, ...)
--     if conform.get_formatter_info(formatter, bufnr).available then
--       return formatter
--     end
--   end
--   return select(1, ...)
-- end

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    less = { "prettier" },
    scss = { "prettier" },
    html = { "prettier" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    vue = { "prettier" },
    markdown = { "prettier" },
    -- html = function(bufnr)
    --   return { first(bufnr, "eslint_d", "eslint", "prettierd", "prettier"), "injected" }
    -- end,
    -- javascript = function(bufnr)
    --   return { first(bufnr, "eslint_d", "eslint", "prettierd", "prettier"), "injected" }
    -- end,
    -- javascriptreact = function(bufnr)
    --   return { first(bufnr, "eslint_d", "eslint", "prettierd", "prettier"), "injected" }
    -- end,
    -- typescript = function(bufnr)
    --   return { first(bufnr, "eslint_d", "eslint", "prettierd", "prettier"), "injected" }
    -- end,
    -- typescriptreact = function(bufnr)
    --   return { first(bufnr, "eslint_d", "eslint", "prettierd", "prettier"), "injected" }
    -- end,
    -- markdown = function(bufnr)
    --   return { first(bufnr, "prettierd", "prettier"), "injected" }
    -- end,
  },
  -- Set default options
  default_format_opts = {
    lsp_format = "fallback",
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
