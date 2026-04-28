# Neovim 0.12.1 升级方案

本文记录当前 Neovim 配置升级到 `Neovim 0.12.1` 的完整执行方案。方案基于当前仓库配置、`lazy-lock.json`、本机已安装插件源码扫描，以及 Neovim 0.12 官方变更整理。

当前本机版本：

```sh
NVIM v0.11.5
```

目标版本：

```sh
NVIM v0.12.1
```

官方来源：

- Neovim 0.12 变更说明：https://neovim.io/doc/user/news-0.12/
- Neovim 0.12.1 Release：https://github.com/neovim/neovim/releases/tag/v0.12.1
- nvim-treesitter 文档：https://github.com/nvim-treesitter/nvim-treesitter
- mason-lspconfig 文档：https://github.com/mason-org/mason-lspconfig.nvim

## 总体结论

建议升级到 `Neovim 0.12.1`，但不要把所有生态迁移一次性做完。推荐分为两个阶段：

1. 第一阶段：升级 Neovim 到 `0.12.1`，同步插件，保留当前 `nvim-treesitter` 旧配置体系，并增加临时兼容层。
2. 第二阶段：单独迁移 `nvim-treesitter` 新 main 配置体系，并逐个验证依赖 Treesitter 的插件。

目前没有发现“明确无法支持 Neovim 0.12.1、必须永久替换”的插件。主要风险来自旧 API、Treesitter 主分支重构、以及 `mason-lspconfig.nvim` v2 行为变化。

## 第一阶段目标

第一阶段目标是让当前配置稳定运行在 `Neovim 0.12.1`，不做大规模重构。

第一阶段建议：

- 升级 Neovim 到 `0.12.1`。
- 执行 `Lazy sync` 更新插件。
- 暂时锁定 `nvim-treesitter` 和 `nvim-treesitter-textobjects` 的旧 `master` 分支。
- 给旧插件 API 加临时兼容层。
- 暂时不要强行升级 `mason.nvim` / `mason-lspconfig.nvim` 到 v2；如果要升 v2，必须同步调整配置。
- 完整执行 headless 检查和交互验证。

## 主要破坏性变更

Neovim 0.12 对当前配置和插件生态的主要影响如下。

| 变更 | 影响 |
| --- | --- |
| `vim.diff()` 改为 `vim.text.diff()` | 旧版 `conform.nvim`、`render-markdown.nvim`、`mini.nvim` 部分模块可能报错 |
| `vim.diagnostic.disable()` / `vim.diagnostic.is_disabled()` 被移除 | 旧插件或兼容分支可能报错 |
| 旧 `vim.lsp.semantic_tokens.start()` / `stop()` 被替换 | 当前配置未命中，但旧插件需要注意 |
| `Query:iter_matches(..., { all = ... })` 的旧参数形式不再可靠 | `rainbow-delimiters.nvim`、旧 Treesitter 插件可能受影响 |
| `:sign-define` / `sign_define()` 不再用于诊断 signs | 当前 LSP 诊断配置已使用 `vim.diagnostic.config()`，基本安全 |
| LSP JSON `null` 行为调整为 `vim.NIL` | 一般由插件处理，当前配置没有直接命中 |
| `nvim-treesitter` 新 main 配置体系重构 | 当前 `lua/plugins/treesitter.lua` 仍是旧配置方式，不能直接平滑迁移 |

## 当前配置判断

当前配置中有利于升级的部分：

- `lua/config/lsp.lua` 已使用 `vim.lsp.config()` 和 `vim.lsp.enable()`，符合 0.11+ / 0.12 的方向。
- 诊断 signs 已通过 `vim.diagnostic.config()` 配置，没有使用旧的 `sign_define()` 配置诊断 signs。
- 自有配置没有命中 `vim.diagnostic.disable()`、`vim.diagnostic.is_disabled()`、旧 `semantic_tokens.start()` / `stop()`。
- 补全已经使用 `blink.cmp`，不是旧 `nvim-cmp` 主路径。

需要注意的部分：

- `lua/plugins/treesitter.lua` 仍使用 `require("nvim-treesitter.configs").setup(opts)`。
- `lua/config/opt.lua` 里 `foldexpr = "nvim_treesitter#foldexpr()"` 属于旧 Treesitter 体系。
- `lua/plugins/mason.lua` 当前锁定 `mason.nvim` / `mason-lspconfig.nvim` 的 `^1.0.0`，若升级 v2 需要改配置。
- 自有配置中仍有少量 `vim.loop` 使用；这不是第一阶段阻塞项，后续可逐步改为 `vim.uv`。

## 升级前准备

进入仓库根目录：

```sh
cd ~/.config/nvim
```

确认当前版本和工作区状态：

```sh
nvim --version
git status --short
```

建议新建升级分支：

```sh
git switch -c chore/nvim-0.12.1-upgrade
```

备份当前插件锁文件：

```sh
cp lazy-lock.json lazy-lock.nvim-0.11.5.json
```

如果当前工作区已有未提交改动，先确认这些改动是否与升级有关。无关改动不要混入升级提交。

## 第一阶段配置改动

### 新增临时兼容层

建议新增文件：

```text
lua/config/compat.lua
```

建议内容：

```lua
--[[
为 Neovim 0.12 兼容仍调用旧 API 的插件。
这些兼容代码只用于升级过渡，等相关插件全部适配后可以删除。
]]
if vim.text and vim.text.diff and not vim.diff then
	vim.diff = vim.text.diff
end

if vim.diagnostic then
	if not vim.diagnostic.disable then
		--[[
		兼容旧插件调用 vim.diagnostic.disable(bufnr, namespace) 的路径。
		Neovim 0.12 起应优先使用 vim.diagnostic.enable(false, opts)。
		]]
		function vim.diagnostic.disable(bufnr, namespace)
			vim.diagnostic.enable(false, { bufnr = bufnr, ns_id = namespace })
		end
	end

	if not vim.diagnostic.is_disabled then
		--[[
		兼容旧插件查询诊断禁用状态的路径。
		返回值保持旧 API 语义：true 表示诊断已禁用。
		]]
		function vim.diagnostic.is_disabled(bufnr, namespace)
			return not vim.diagnostic.is_enabled({ bufnr = bufnr, ns_id = namespace })
		end
	end
end
```

然后在 `lua/config/index.lua` 最前面加载：

```lua
require("config.compat")
require("config.global")
require("config.opt")
require("config.keymap")
require("config.operator")
require("config.effect")
require("config.autocmd")
```

### 暂时锁定 Treesitter 旧分支

第一阶段建议保持旧配置体系，避免 `nvim-treesitter` 新 main 的不兼容变化扩大升级范围。

建议调整 `lua/plugins/treesitter.lua`：

```lua
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
	version = false,
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "master",
		},
	},
	-- 其余配置暂时保持不变。
}
```

注意：这里不是最终形态，只是第一阶段降低风险。第二阶段再迁移新 main。

### Mason 处理策略

当前 `lua/plugins/mason.lua` 使用：

```lua
version = "^1.0.0"
```

第一阶段推荐保留 v1，不强行升级 Mason 体系。

如果后续决定升级到 v2，建议改为：

```lua
return {
	{
		"mason-org/mason.nvim",
		version = "^2.0.0",
		config = true,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		version = "^2.0.0",
		opts = {
			ensure_installed = {
				"lua_ls",
				"vtsls",
				"cssls",
				"bashls",
				"css_variables",
				"cssmodules_ls",
				"html",
				"tailwindcss",
				"jsonls",
				"svelte",
				"yamlls",
				"clangd",
				"cmake",
				"pyright",
				"ruff",
			},
			automatic_enable = false,
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
		end,
	},
}
```

`automatic_enable = false` 很关键。当前 LSP 已经在 `lua/config/lsp.lua` 中通过 `vim.lsp.config()` / `vim.lsp.enable()` 手动启用，如果 Mason v2 再自动启用，可能导致重复 attach 或行为难以排查。

## 插件处理清单

### 必须重点关注

| 插件 | 当前判断 | 第一阶段处理 |
| --- | --- | --- |
| `nvim-treesitter` | 主分支已有不兼容重构，当前配置仍是旧体系 | 暂时锁 `master`，第二阶段单独迁移 |
| `nvim-treesitter-textobjects` | 依赖 Treesitter 配置体系 | 暂时锁 `master`，第二阶段和 Treesitter 一起迁移 |
| `rainbow-delimiters.nvim` | 命中旧 `iter_matches(..., { all = ... })` 使用 | 先升级插件；若仍报错，临时禁用 |
| `conform.nvim` | 当前安装版本命中 `vim.diff()` | 升级插件，并保留临时 `vim.diff` 兼容层 |
| `render-markdown.nvim` | 当前安装版本命中 `vim.diff()` | 升级插件，并保留临时 `vim.diff` 兼容层 |
| `mini.nvim` | 部分可选模块命中旧 API | 升级插件；当前主要作为依赖，风险较低 |
| `LuaSnip` | 可选 snippet list 命中旧 diagnostic API | 升级插件，并保留 diagnostic 兼容层 |
| `mason-lspconfig.nvim` | v2 行为变化明显 | 第一阶段保留 v1；若升 v2，配置 `automatic_enable = false` |

### 建议同步升级并重点验证

这些插件预计支持 0.12，但需要在升级后验证核心路径：

- `lazy.nvim`
- `nvim-lspconfig`
- `blink.cmp`
- `blink-cmp-env`
- `nvim-lint`
- `schemastore.nvim`
- `codecompanion.nvim`
- `fzf-lua`
- `gitsigns.nvim`
- `diffview.nvim`
- `neo-tree.nvim`
- `trouble.nvim`
- `noice.nvim`
- `nui.nvim`
- `nvim-notify`
- `fidget.nvim`
- `lualine.nvim`
- `bufferline.nvim`
- `incline.nvim`
- `barbecue.nvim`
- `nvim-navic`
- `render-markdown.nvim`
- `nvim-ts-autotag`
- `nvim-ts-context-commentstring`
- `flash.nvim`
- `jsx-element.nvim`
- `treesitter-outer`

### 低风险插件

这些插件预计不需要特殊配置，随 `Lazy sync` 更新即可：

- `Comment.nvim`
- `nvim-surround`
- `mini.pairs`
- `mini.splitjoin`
- `better-escape.nvim`
- `vim-cursorword`
- `vim-visual-multi`
- `neoscroll.nvim`
- `toggleterm.nvim`
- `nvim-spectre`
- `bookmarks.nvim`
- `convert.nvim`
- `json-to-types.nvim`
- `copy_with_context.nvim`
- `neogen`
- `numb.nvim`
- `lastplace.nvim`
- `persistence.nvim`
- `visual-whitespace.nvim`
- `colorful-winsep.nvim`
- `nvim-scrollbar`
- `nvim-colorizer.lua`
- `emmet-vim`
- `kulala.nvim`
- `codesnap.nvim`
- `git-log.nvim`
- `blame-column.nvim`
- `todo-comments.nvim`

### 主题和基础依赖

这些插件基本只需要同步更新：

- `catppuccin`
- `gruvbox`
- `tokyonight.nvim`
- `rose-pine`
- `evergarden`
- `yoda.nvim`
- `zenbones.nvim`
- `lush.nvim`
- `omega.nvim`
- `plenary.nvim`
- `nvim-web-devicons`
- `friendly-snippets`

### 已禁用插件

`lua/plugins/cmdline.lua` 当前 `enabled = false`，本轮升级不需要处理。

## 执行步骤

### 1. 修改配置

完成第一阶段配置改动：

- 新增 `lua/config/compat.lua`。
- 在 `lua/config/index.lua` 顶部加载 `config.compat`。
- 给 `nvim-treesitter` 和 `nvim-treesitter-textobjects` 暂时锁定 `master` 分支。
- Mason 暂时保留 v1；如果选择 v2，则同步修改 `automatic_enable = false`。

### 2. 同步插件

执行：

```sh
nvim --headless "+Lazy! sync" +qa
```

如果网络或插件下载失败，先不要继续升级 Neovim，优先解决插件同步问题。

### 3. 更新 Treesitter parser

执行：

```sh
nvim --headless "+TSUpdateSync" +qa
```

如果某个 parser 编译失败，记录失败语言。前端主路径至少需要确认这些 parser 可用：

- `javascript`
- `typescript`
- `tsx`
- `vue`
- `html`
- `css`
- `scss`
- `json5`
- `lua`
- `markdown`

### 4. 更新 Mason registry

执行：

```sh
nvim --headless "+MasonUpdate" +qa
```

如需重新安装 LSP，可在 Neovim 中打开：

```vim
:Mason
```

重点确认：

- `lua-language-server`
- `vtsls`
- `vue-language-server`
- `css-lsp`
- `html-lsp`
- `tailwindcss-language-server`
- `json-lsp`
- `yaml-language-server`
- `pyright`
- `ruff`
- `clangd`
- `cmake-language-server`

### 5. 升级 Neovim

如果使用 Homebrew：

```sh
brew update
brew upgrade neovim
nvim --version
```

如果 Homebrew 没有提供 `0.12.1`，建议使用官方 macOS 包。先确认架构：

```sh
uname -m
```

- `arm64` 使用 `nvim-macos-arm64.tar.gz`
- `x86_64` 使用 `nvim-macos-x86_64.tar.gz`

### 6. Headless 验证

执行：

```sh
nvim --version
nvim --headless "+Lazy! check" +qa
nvim --headless "+checkhealth" +qa
```

如果 `checkhealth` 有历史遗留告警，只关注是否新增阻断项。

### 7. 交互验证

启动：

```sh
nvim
```

至少验证以下路径：

- 打开 `lua` 文件，确认启动无报错，`:messages` 无新增异常。
- 打开 `.tsx` / `.ts` 文件，确认 `vtsls` attach、补全、跳转可用。
- 打开 `.vue` 文件，确认 `vue_ls` 和 `vtsls` 行为正常，补全过滤逻辑未失效。
- 打开 `.md` 文件，确认 `render-markdown.nvim` 不报错。
- 执行 `<leader>f`，确认 `conform.nvim` 格式化路径正常。
- 执行 `:FzfLua files`，确认搜索可用。
- 执行 `:Neotree`，确认文件树可用。
- 执行 `:Trouble diagnostics`，确认诊断列表可用。
- 打开 Git 项目文件，确认 `gitsigns.nvim` 正常显示。
- 触发 `flash.nvim` 的 `ss` 和 `sS`，确认 Treesitter 跳转不报错。
- 打开括号较多的 Lua / TS 文件，确认 `rainbow-delimiters.nvim` 不报错。
- 使用一次 `CodeCompanion` chat 和 inline，确认交互确认、提交、接受变更流程可用。
- 使用一次 LuaSnip 片段展开，确认 `<Tab>` / `<S-Tab>` 逻辑正常。

## 出错处理

### `vim.diff` 报错

现象通常类似：

```text
attempt to call field 'diff'
```

处理：

- 确认 `lua/config/compat.lua` 已加载在所有插件之前。
- 更新 `conform.nvim`、`render-markdown.nvim`、`mini.nvim`。
- 若仍出现，定位报错插件后临时禁用该插件。

### `vim.diagnostic.disable` 或 `is_disabled` 报错

处理：

- 确认 diagnostic 兼容层已加载。
- 更新报错插件。
- 如果来自不常用可选功能，先禁用对应功能。

### `iter_matches` / Treesitter 报错

处理顺序：

1. 更新 `nvim-treesitter` parser。
2. 更新 `rainbow-delimiters.nvim`。
3. 如果仍报错，临时禁用 `rainbow-delimiters.nvim`。
4. 如果报错来自 `jsx-element.nvim` 或 `treesitter-outer`，先临时禁用对应插件，不要阻塞主升级。

### LSP 重复 attach 或行为异常

重点检查 `mason-lspconfig.nvim` 是否升级到了 v2。

如果已升级 v2，确认配置中存在：

```lua
automatic_enable = false
```

当前 LSP 应继续由 `lua/config/lsp.lua` 中的以下逻辑统一启用：

```lua
for server, config in pairs(servers) do
	vim.lsp.config(server, config)
	vim.lsp.enable(server)
end
```

### Markdown 渲染异常

处理：

- 更新 `render-markdown.nvim`。
- 确认 `mini.nvim` 已同步更新。
- 确认 `vim.diff` 兼容层存在。
- 如果仍影响编辑，临时禁用 `render-markdown.nvim`。

### CodeCompanion 行为异常

Neovim 0.12 新增原生 inline completion，`codecompanion.nvim` 对 0.12 有相关能力。升级后重点验证：

- chat buffer 是否能提交。
- inline 变更是否能接受和拒绝。
- `blink.cmp` provider 是否仍可用。
- confirm 流程是否受 `noice.nvim` 或命令行 UI 影响。

## 回滚方案

如果升级后不可接受，先回滚配置和插件锁：

```sh
git restore lua lazy-lock.json
cp lazy-lock.nvim-0.11.5.json lazy-lock.json
nvim --headless "+Lazy! restore" +qa
```

如果 Neovim 二进制也需要回滚：

- Homebrew 场景下优先使用本地保留的旧版本或版本管理器切换。
- 如果使用官方 tarball，切回旧 tarball 的 `bin/nvim` 软链接即可。

回滚后重新验证：

```sh
nvim --version
nvim --headless "+Lazy! check" +qa
nvim --headless "+checkhealth" +qa
```

## 第二阶段：迁移 nvim-treesitter 新 main

第二阶段不建议和 Neovim 本体升级同一轮做。

迁移目标：

- 移除旧 `require("nvim-treesitter.configs").setup(opts)` 配置方式。
- 改用新版 `nvim-treesitter` 安装和启动方式。
- 把旧的高亮、缩进、折叠、textobjects 逻辑拆开处理。
- 逐个验证依赖 Treesitter 的插件。

需要重点处理：

1. `lua/plugins/treesitter.lua`
2. `lua/config/opt.lua` 中的 `foldexpr`
3. `nvim-treesitter-textobjects`
4. `rainbow-delimiters.nvim`
5. `jsx-element.nvim`
6. `treesitter-outer`
7. `flash.nvim` 的 Treesitter 跳转
8. `nvim-ts-autotag`
9. `nvim-ts-context-commentstring`
10. `render-markdown.nvim`

新版折叠表达式参考：

```lua
--[[
使用 Neovim 原生 Treesitter 折叠表达式。
该写法用于替代旧的 nvim_treesitter#foldexpr()。
]]
vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.wo[0][0].foldmethod = "expr"
```

如果 `jsx-element.nvim` 或 `treesitter-outer` 无法适配新版 Treesitter，建议先停用。它们属于增强体验插件，不应阻塞 Neovim 主版本升级。

## 最终建议

推荐执行顺序：

1. 先按第一阶段升级到 `Neovim 0.12.1`。
2. 保持 `nvim-treesitter` 旧 `master` 配置体系。
3. 保留临时兼容层，等所有插件验证通过后再考虑删除。
4. Mason 第一阶段先不升 v2；如果升 v2，必须设置 `automatic_enable = false`。
5. 稳定使用几天后，再单独迁移 `nvim-treesitter` 新 main。

这样可以把 Neovim 本体升级风险、插件 API 风险、Treesitter 体系迁移风险拆开处理，便于定位和回滚。
