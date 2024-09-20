return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}
    opts.formatters.prettier = {
      condition = function(_, ctx)
        local eslint_conf_def = {
          ".eslintrc.js",
          ".eslintrc.cjs",
          ".eslintrc.yaml",
          ".eslintrc.yml",
          ".eslintrc.json",
        }
        -- 遍历查找当前目录下是否存在任意一个 ESLint 配置文件
        for _, config_file in ipairs(eslint_conf_def) do
          if vim.fn.filereadable(vim.fn.getcwd() .. "/" .. config_file) == 1 then
            return false -- 找到 ESLint 配置文件，则不使用 Prettier
          end
        end
        -- 没有找到 ESLint 配置文件时，检查是否有解析器
        return M.has_parser(ctx)
      end,
    }
  end,
}
