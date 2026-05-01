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
- Neovim 原生包与 `vim.pack` 文档：https://neovim.io/doc/user/pack/
- nvim-treesitter 文档：https://github.com/nvim-treesitter/nvim-treesitter
- mason-lspconfig 文档：https://github.com/mason-org/mason-lspconfig.nvim

## 总体结论

建议升级到 `Neovim 0.12.1`，但不要把所有生态迁移一次性做完。推荐分为三个阶段：

1. 第一阶段：升级 Neovim 到 `0.12.1`，同步插件，保留当前 `nvim-treesitter` 旧配置体系，并增加临时兼容层。
2. 第二阶段：单独迁移 `nvim-treesitter` 新 main 配置体系，并逐个验证依赖 Treesitter 的插件。
3. 第三阶段：可选迁移 `lazy.nvim` 到 Neovim 0.12 原生 `vim.pack`，并单独替换懒加载、构建钩子和锁文件流程。

目前没有发现“明确无法支持 Neovim 0.12.1、必须永久替换”的插件。主要风险来自旧 API、Treesitter 主分支重构、以及 `mason-lspconfig.nvim` v2 行为变化。

当前仓库没有实际使用完整的 `LazyVim` 配置发行版，真正使用的是 `folke/lazy.nvim` 插件管理器。因此后续如果说“取消 LazyVim”，实际需要处理的是“是否取消 `lazy.nvim`”。

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

## 关于 lazy.nvim、LazyVim 与 vim.pack

### 当前状态判断

当前配置使用的是 `lazy.nvim`，不是完整的 `LazyVim` 发行版：

- `lua/bootstrap.lua` 中通过 `require("lazy").setup()` 加载插件。
- `lazy-lock.json` 是 `lazy.nvim` 的插件锁文件。
- 仓库没有使用 `LazyVim/LazyVim`，也没有导入 `lazyvim.plugins`。
- `LazyVim` 相关内容只出现在少量注释里，不影响运行。

也就是说，当前没有必须“移除 LazyVim”的工作；真正的可选迁移项是从 `lazy.nvim` 迁到 Neovim 0.12 原生 `vim.pack`。

### vim.pack 能替代什么

Neovim 0.12 的 `vim.pack` 可以管理外部插件的安装、更新和删除，并会生成 `nvim-pack-lock.json` 锁文件。它适合替代 `lazy.nvim` 的插件下载、版本锁定和更新流程。

但官方文档仍把 `vim.pack` 标记为 experimental，虽然说明其已经足够日常使用。迁移时应把它当成“原生插件管理器”，不要当成 `lazy.nvim` 的无缝兼容层。

### vim.pack 不能直接替代什么

`vim.pack` 不会直接理解当前 `lua/plugins/*.lua` 里的 `lazy.nvim` 声明式字段，例如：

- `event`
- `cmd`
- `keys`
- `ft`
- `dependencies`
- `opts`
- `config`
- `init`
- `build`
- `priority`
- `enabled`
- `opts_extend`

这些能力如果还需要保留，必须改成显式的 Lua 加载逻辑、`autocmd`、`keymap`、`user command`、`packadd`、`PackChanged` 钩子或普通配置模块。

当前仓库有约 58 个 `lua/plugins/*.lua` 插件模块，且大量使用上述字段。因此不建议在第一阶段升级 Neovim 时同步迁移 `vim.pack`，否则排查范围会同时覆盖 Neovim 本体、插件 API、Treesitter、Mason 和插件管理器。

### 当前 lazy.nvim 专属依赖点

迁移前需要先处理当前自有配置里直接依赖 `lazy.nvim` API 的位置：

- `lua/bootstrap.lua`：`lazy.nvim` 的 bootstrap 和 `require("lazy").setup()` 入口。
- `lua/plugins/neotree.lua`：`require("lazy.util").open(...)`，需要替换为系统打开文件的自有工具方法。
- `lua/tools/tools.lua`：`require("lazy.core.config").headless()`，需要替换为不依赖 `lazy.nvim` 的 headless 判断。

注释里的 `LazyVim` 片段不需要作为阻塞项处理，可以在迁移时顺手清理。

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

## 第三阶段：迁移 lazy.nvim 到 vim.pack

第三阶段是可选项，不建议和 Neovim 本体升级、Treesitter 新 main 迁移同一轮执行。只有在 `Neovim 0.12.1` 已经稳定使用，并且第二阶段 Treesitter 迁移也完成或明确暂缓后，再开始处理插件管理器迁移。

迁移目标：

- 移除 `lua/bootstrap.lua` 中的 `lazy.nvim` bootstrap。
- 使用 `vim.pack.add()` 维护插件安装清单。
- 使用 `nvim-pack-lock.json` 替代 `lazy-lock.json`。
- 把 `lua/plugins/*.lua` 中的 `lazy.nvim` spec 拆成“插件清单”和“加载配置”两层。
- 用显式 `autocmd`、`keymap`、`user command` 和 `packadd` 保留必要的懒加载能力。
- 用 `PackChanged` autocmd 处理原 `build` 钩子。

### 建议目录结构

建议先新增一层原生插件管理入口，不要直接在 `init.lua` 中堆叠全部插件：

```text
lua/pack/
  index.lua
  specs.lua
  loaders.lua
  hooks.lua
```

建议职责：

- `lua/pack/specs.lua`：只维护 `vim.pack.add()` 需要的插件来源、名称和版本。
- `lua/pack/loaders.lua`：维护 `cmd`、`event`、`ft`、`keys` 等懒加载入口。
- `lua/pack/hooks.lua`：维护 `PackChanged` 安装和更新后的构建动作。
- `lua/pack/index.lua`：按顺序组装 specs、hooks 和 loaders。

### 迁移步骤

1. 新建 `lua/pack/specs.lua`，先把所有插件仓库地址从 `lua/plugins/*.lua` 提取为 `vim.pack.add()` 清单。
2. 新建 `lua/pack/index.lua`，只调用 `specs`，先不处理懒加载，确认 `vim.pack` 可以安装插件。
3. 在 `init.lua` 中临时保留 `lazy.nvim` 入口，通过条件开关切换 `lazy.nvim` 和 `vim.pack`，便于回滚。
4. 用 `vim.pack.add()` 生成并提交 `nvim-pack-lock.json`。
5. 把 `lua/plugins/*.lua` 中的 `opts`、`config`、`init` 逐步迁移为普通配置模块。
6. 把 `event`、`cmd`、`ft`、`keys` 逐步迁移到 `lua/pack/loaders.lua`。
7. 把 `build` 逐步迁移到 `lua/pack/hooks.lua` 的 `PackChanged` autocmd。
8. 替换所有直接依赖 `lazy.nvim` API 的自有代码。
9. 完整验证后，删除 `lua/bootstrap.lua` 和 `lazy-lock.json`。

### 第一轮建议先迁移的插件

第一轮不要直接迁移全部插件。建议先选择启动期或低懒加载复杂度的插件验证模式：

- 主题插件：`catppuccin`、`gruvbox`、`tokyonight.nvim`、`rose-pine`。
- 基础依赖：`plenary.nvim`、`nvim-web-devicons`、`nui.nvim`。
- 简单配置插件：`Comment.nvim`、`nvim-surround`、`mini.pairs`、`better-escape.nvim`。

等这些插件确认可安装、可加载、可配置后，再迁移 LSP、补全、Treesitter、文件树、搜索和 AI 相关插件。

### 需要重点改写的 lazy.nvim 字段

| lazy.nvim 字段 | vim.pack 迁移方式 |
| --- | --- |
| `dependencies` | 在 `vim.pack.add()` 清单中显式声明依赖插件，必要时调整配置加载顺序 |
| `opts` | 改成普通 Lua 表，并在对应配置模块中传给 `setup()` |
| `config` | 改成显式 `require("xxx").setup(opts)` 或自有配置函数 |
| `init` | 移到插件加载前执行的配置模块 |
| `event` | 改成 `nvim_create_autocmd()` 后再 `packadd` 和加载配置 |
| `cmd` | 改成占位 user command，首次执行时加载插件后转发命令 |
| `keys` | 改成占位 keymap，首次触发时加载插件后执行真实动作 |
| `ft` | 改成 `FileType` autocmd |
| `build` | 改成 `PackChanged` autocmd，根据 `ev.data.spec.name` 和 `ev.data.kind` 执行构建 |
| `priority` | 改成显式加载顺序，主题类插件优先加载 |
| `enabled` | 改成插件清单或加载器里的条件判断 |

### 必须先替换的自有 lazy.nvim API

`lua/plugins/neotree.lua` 中的系统打开逻辑需要替换：

```lua
require("lazy.util").open(state.tree:get_node().path, { system = true })
```

迁移时建议下沉为自有工具函数，例如 `tools.open_system(path)`，内部按 macOS 使用 `open`，其他系统再按需要补充。

`lua/tools/tools.lua` 中的 headless 判断需要替换：

```lua
require("lazy.core.config").headless()
```

迁移时建议改成不依赖插件管理器的判断，例如基于 `#vim.api.nvim_list_uis() == 0` 或启动参数做封装，避免工具层继续依赖 `lazy.nvim` 内部模块。

### 第三阶段验证命令

迁移期间建议保留 `lazy.nvim` 分支作为回滚点。每完成一组插件迁移后执行：

```sh
nvim --version
nvim --headless "+checkhealth" +qa
```

在 Neovim 内手动执行：

```vim
:lua vim.pack.update(nil, { offline = true })
```

用于查看当前 `vim.pack` 管理的插件状态，不直接联网更新。

完整迁移完成后，交互验证路径应至少覆盖第一阶段的所有检查项，并额外确认：

- 新机器或清理插件目录后，`nvim-pack-lock.json` 可以恢复插件版本。
- 原本依赖 `cmd` 的插件首次命令触发正常。
- 原本依赖 `event` / `ft` 的插件在对应事件触发后正常加载。
- 原本依赖 `keys` 的插件首次按键触发正常。
- Treesitter parser 更新、LuaSnip 构建、`json-to-types.nvim` 安装脚本等构建动作没有丢失。

## 最终建议

推荐执行顺序：

1. 先按第一阶段升级到 `Neovim 0.12.1`。
2. 保持 `nvim-treesitter` 旧 `master` 配置体系。
3. 保留临时兼容层，等所有插件验证通过后再考虑删除。
4. Mason 第一阶段先不升 v2；如果升 v2，必须设置 `automatic_enable = false`。
5. 稳定使用几天后，再单独迁移 `nvim-treesitter` 新 main。
6. `vim.pack` 迁移放到第三阶段单独做，不要和 Neovim 本体升级、Treesitter 新 main 迁移混在同一个提交里。

这样可以把 Neovim 本体升级风险、插件 API 风险、Treesitter 体系迁移风险拆开处理，便于定位和回滚。

## 执行记录

### 2026-05-01 第一阶段已完成

当前第一阶段已基本完成，并已进入短期试用观察状态。

已完成事项：

- 已将默认 `nvim` 切换到官方 macOS arm64 包 `NVIM v0.12.1`。
- 官方包安装位置为 `~/.local/opt/nvim-0.12.1`。
- 当前 `~/.local/bin/nvim` 指向 `~/.local/opt/nvim-0.12.1/bin/nvim`。
- Homebrew 版本仍保留为 `/opt/homebrew/bin/nvim` -> `0.11.5`，用于必要时回退。
- 已新增 `lua/config/compat.lua`，兼容 `vim.diff`、`vim.diagnostic.disable()`、`vim.diagnostic.is_disabled()` 旧 API。
- 已在 `lua/config/index.lua` 最前面加载 `config.compat`。
- 已将 `nvim-treesitter` 和 `nvim-treesitter-textobjects` 暂时锁定到 `master` 分支，继续使用旧配置体系。
- Mason 保持 v1，没有升级到 v2。
- 已执行 `Lazy! sync` 并更新 `lazy-lock.json`。
- 已备份原锁文件到 `lazy-lock.nvim-0.11.5.json`。
- 已执行 `TSUpdateSync`，结果为 `All parsers are up-to-date!`。
- 已执行 `MasonUpdate`，registry 更新成功。
- 已修复 `LuaSnip` 的 `deps/jsregexp` 子模块版本不一致问题。
- 已为 `rainbow-delimiters.nvim` 增加启用条件，跳过 `neo-tree`、`fzf-lua` 等无 Treesitter parser 的 UI buffer，避免 Neovim 0.12 下 `parser` 为 nil 的报错。

已验证事项：

- `nvim --version` 显示 `NVIM v0.12.1`。
- `nvim --headless "+lua require('config.index')" +qa` 通过。
- `nvim --headless "+checkhealth" +qa` 返回码为 0。
- `vim.deprecated` 健康检查没有发现已废弃函数调用。
- 核心插件 headless 冒烟加载通过，包括 `nvim-treesitter`、`render-markdown.nvim`、`conform.nvim`、`fzf-lua`、`neo-tree.nvim`、`trouble.nvim`、`gitsigns.nvim`、`flash.nvim`、`rainbow-delimiters.nvim`。
- `neo-tree` 和 `fzf` 类 UI buffer 已验证不会再触发 `rainbow-delimiters.nvim` 的 `parser` nil 报错。

已知非阻断事项：

- `checkhealth` 提示 `Nvim 0.12.2 is available`，但本阶段目标仍按本文执行到 `0.12.1`。
- `checkhealth` 中存在环境类告警，包括 `luarocks`、`wget`、部分语言运行时、Node / Perl / Ruby provider、tmux true color 检测等；当前没有作为本次升级阻断项处理。
- GitHub API rate limit 和部分 SSL fetch 中断曾在 `Lazy! sync` / `Lazy! check` 输出中出现；后续已核对锁文件和本地插件 HEAD，除已禁用的 `cmdline.nvim` 未安装外，其余插件与锁文件一致。
- `nv` 是 `nvim` alias。如果旧终端仍显示 `0.11.5`，需要在对应 shell 中执行 `rehash` 或重开终端，并确认 `~/.local/bin` 在 PATH 中早于 `/opt/homebrew/bin`。

下一阶段入口：

- 下一个会话从“第二阶段：迁移 nvim-treesitter 新 main”开始。
- 第二阶段开始前先确认第一阶段在日常使用中没有新的启动报错、文件打开报错、LSP attach 异常或 Treesitter 高亮异常。
- 第二阶段优先处理 `lua/plugins/treesitter.lua` 和 `lua/config/opt.lua` 中旧 `nvim_treesitter#foldexpr()` 的迁移。

### 2026-05-01 第二阶段已完成

当前第二阶段已完成，`nvim-treesitter` 已从旧 `master` 配置体系迁移到新版 `main` 配置体系。

已完成事项：

- 已将 `lua/plugins/treesitter.lua` 改为 `branch = "main"`、`lazy = false`，并使用 `require("nvim-treesitter").setup()` 与 `install()` 管理 parser。
- 已将 `nvim-treesitter-textobjects` 切换到 `main`，并改用新版 `select` / `move` 模块 API。
- 已将全局折叠表达式从 `nvim_treesitter#foldexpr()` 改为 `v:lua.vim.treesitter.foldexpr()`。
- 已将 Treesitter 缩进改为新版 `v:lua.require'nvim-treesitter'.indentexpr()`，并继续保留 Python 禁用缩进的历史策略。
- 已把自动 `console.log` 的节点读取逻辑从 `nvim-treesitter.ts_utils` 改为 Neovim 原生 `vim.treesitter.get_node()` / `get_node_text()`。
- 已禁用 `treesitter-outer`，原因是它依赖新版 `nvim-treesitter` 已移除的旧 `nvim-treesitter.query` 路径。
- 已为 `jsx-element.nvim` 关闭插件内旧 `TSTextobject*` 命令键位，并在 TSX/JSX buffer 中注册新版 textobjects keymap。
- 已设置 `vim.g.skip_ts_context_commentstring_module = true`，避免 `nvim-ts-context-commentstring` 走旧 Treesitter 模块注册路径。
- 已安装并确认 `tree-sitter-cli 0.26.8`，满足新版 `nvim-treesitter` 对 `0.26.1+` 的要求。
- 已安装新版 parser 与 query 到 `~/.local/share/nvim/site`，核心语言包括 `angular`、`bash`、`c`、`cpp`、`css`、`dart`、`dockerfile`、`go`、`graphql`、`html`、`javascript`、`json5`、`lua`、`markdown`、`python`、`scss`、`svelte`、`toml`、`tsx`、`typescript`、`vue`、`xml`、`yaml`。
- `lazy-lock.json` 已记录 `nvim-treesitter` main commit `4916d6592ede8c07973490d9322f187e07dfefac` 与 `nvim-treesitter-textobjects` main commit `851e865342e5a4cb1ae23d31caf6e991e1c99f1e`。

已验证事项：

- `nvim --version` 显示 `NVIM v0.12.1`。
- `tree-sitter --version` 显示 `tree-sitter 0.26.8`。
- `luac -p` 已覆盖本阶段修改过的 Lua 配置文件。
- `nvim --headless "+lua require('config.index')" +qa` 通过。
- `nvim --headless "+Lazy! check" +qa` 返回码为 0。
- `nvim --headless "+checkhealth" +qa` 返回码为 0。
- `checkhealth` 中 `nvim-treesitter`、`vim.deprecated`、`vim.treesitter` 均为通过状态。
- 已用 headless 冒烟脚本验证 Lua、TypeScript、TSX、Vue、Markdown buffer 可以启动 Treesitter parser 和高亮。
- 已验证新版 `nvim-treesitter-textobjects.select`、`nvim-treesitter-textobjects.move` 可加载。
- 已验证 TSX buffer 中 `it` JSX 元素 textobject keymap 可以注册。

已知非阻断事项：

- `checkhealth` 仍提示 `Nvim 0.12.2 is available`，当前目标版本仍按本文保持为 `0.12.1`。
- `checkhealth` 仍存在环境类告警：Lazy rocks 未安装、Mason v1 版本提示、`wget` / `go` / `composer` / `php` / `luarocks` / `julia` 缺失、tmux true color 检测、Node / Perl / Ruby provider 等；这些不是本阶段 Treesitter 迁移阻断项。
- `Lazy! check` 仍可能出现 GitHub `LibreSSL SSL_connect: SSL_ERROR_SYSCALL` 抖动，但本次返回码为 0。
- `~/.local/share/nvim/lazy/LuaSnip` 插件安装目录存在本地改动。
- `~/.local/share/nvim/lazy/rainbow-delimiters.nvim` 插件安装目录存在子模块元数据异常，`git status` 会报 `Could not access submodule 'test/bin'`，本阶段没有擅自重置该目录。

下一阶段入口：

- 第三阶段仍是可选项：迁移 `lazy.nvim` 到 Neovim 原生 `vim.pack`。
- 建议先日常使用第二阶段结果，确认 Treesitter 高亮、折叠、缩进、JSX textobject、Markdown 渲染、注释上下文和自动标签没有新问题，再决定是否进入第三阶段。

### 2026-05-01 第三阶段待执行交接

当前升级进度：

- 第一阶段已完成：Neovim 已切换到 `0.12.1`，兼容层、插件同步和基础健康检查已完成。
- 第二阶段已完成：`nvim-treesitter` 和 `nvim-treesitter-textobjects` 已迁移到 `main`，核心 Treesitter 冒烟验证已通过。
- 当前尚未开始第三阶段：`lazy.nvim` 到 Neovim 原生 `vim.pack` 的迁移仍未执行。

下个 session 入口：

- 从“第三阶段：迁移 lazy.nvim 到 vim.pack”开始。
- 开始前先执行 `git status --short`，确认当前第二阶段改动、`lazy-lock.nvim-0.11.5.json`、`lua/config/compat.lua`、`nvim.log` 等工作区状态。
- 优先处理 `lua/bootstrap.lua`、`lua/plugins/neotree.lua`、`lua/tools/tools.lua` 中对 `lazy.nvim` API 的直接依赖。
- 第三阶段建议先做可回滚的条件开关，不要一次性删除 `lazy.nvim` 入口和 `lazy-lock.json`。

### 2026-05-01 第三阶段第一轮已开始

当前第三阶段已开始，但尚未切换默认插件管理器，默认启动路径仍保留 `lazy.nvim`。

已完成事项：

- 已在 `init.lua` 增加迁移期开关：默认使用 `lazy.nvim`，设置 `NVIM_PLUGIN_MANAGER=pack` 或 `vim.g.nvim_plugin_manager = "pack"` 后走 `vim.pack` 分支。
- 已新增 `lua/pack/index.lua`、`lua/pack/specs.lua`、`lua/pack/hooks.lua`、`lua/pack/loaders.lua`。
- `lua/pack/specs.lua` 已整理当前启用插件的 `vim.pack.add()` 清单，排除了 `lazy.nvim`、已禁用的 `cmdline.nvim`、已禁用的 `treesitter-outer`，也排除了当前未实际安装的可选 `blink.compat`。
- `lua/pack/hooks.lua` 已迁移第一批构建钩子：`LuaSnip` 的 `make install_jsregexp`、`json-to-types.nvim` 的安装脚本、`nvim-treesitter` 的 `TSUpdateSync`。
- 已增加 `NVIM_PACK_SKIP_ADD=1`，用于在不联网、不安装插件的情况下验证 `vim.pack` 启动分支。
- 已在 `lua/tools/tools.lua` 增加 `is_headless()`，替换原先对 `require("lazy.core.config").headless()` 的直接依赖。
- 已在 `lua/tools/tools.lua` 增加 `open_system(path)`，并将 `lua/plugins/neotree.lua` 中的 `require("lazy.util").open(...)` 替换为自有工具方法。
- 已执行真实 `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim --headless +qa`，通过 `vim.pack.add()` 安装 `74` 个启用插件。
- 已生成 `nvim-pack-lock.json`，作为后续替代 `lazy-lock.json` 的原生 pack 锁文件。
- 已确认 `LuaSnip` 的 `deps/jsregexp/jsregexp.so` 和 `json-to-types.nvim/node_modules` 已生成。
- 已在 `lua/pack/loaders.lua` 迁移第一批低复杂度插件加载：`rose-pine`、`Comment.nvim`、`nvim-surround`、`mini.pairs`、`better-escape.nvim`。

已验证事项：

- `luac -p init.lua lua/tools/tools.lua lua/plugins/neotree.lua lua/pack/specs.lua lua/pack/hooks.lua lua/pack/loaders.lua lua/pack/index.lua` 通过。
- `lua/pack/specs.lua` 当前返回 `74` 个启用插件规格。
- 默认 `lazy.nvim` 启动路径 `nvim --headless +qa` 通过。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_SKIP_ADD=1 nvim --headless +qa` 通过，说明新的 `vim.pack` 分支在不安装插件时可加载。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim --headless +qa` 在真实 pack 安装后通过。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim --headless "+checkhealth" +qa` 返回码为 0。
- `NVIM_PLUGIN_MANAGER=pack` 打开 `lua/tools/tools.lua` 后已确认 `Comment.nvim`、`nvim-surround` 和 `rose-pine` 已加载。
- 已通过手动触发 `InsertEnter` / `InsertCharPre` 验证 `mini.pairs` 与 `better-escape.nvim` 的 pack 分支加载入口可用。
- `~/.local/share/nvim/site/pack/core/opt` 下已存在 `74` 个 `vim.pack` 管理的插件目录。
- `nvim --headless "+checkhealth" +qa` 返回码为 0。
- `nvim --headless "+Lazy! check" +qa` 在沙箱外重跑后返回码为 0。

已知非阻断事项：

- 当前 `vim.pack` 分支只完成安装清单、构建钩子和全局开关；`lua/plugins/*.lua` 中的 `opts`、`config`、`init`、`event`、`cmd`、`keys` 尚未迁移为原生加载器。
- `nvim-pack-lock.json` 首次生成时有 `10` 个插件 revision 与当前 `lazy-lock.json` 不一致：`LuaSnip`、`mason.nvim`、`mason-lspconfig.nvim`、`nvim-ts-autotag`、`plenary.nvim`、`rainbow-delimiters.nvim`、`render-markdown.nvim`、`rose-pine`、`schemastore.nvim`、`tokyonight.nvim`。默认仍走 `lazy.nvim`，切换默认插件管理器前需要决定是否对齐这些 revision。
- `Lazy! check` 仍提示 `rainbow-delimiters.nvim` 插件目录存在本地改动和 `test/bin` 子模块元数据异常，这是第二阶段已经记录过的非阻断项，本轮没有重置外部插件目录。

下一步：

- 继续迁移第二批插件加载：基础 UI 组件、状态栏、搜索、Git、诊断列表等中等复杂度插件。
- 在切换默认插件管理器前，对齐或明确接受 `nvim-pack-lock.json` 与 `lazy-lock.json` 的 revision 差异。
- 逐步迁移 LSP、补全、Treesitter、文件树、搜索和 AI 相关插件，并在每一批后继续用 `NVIM_PLUGIN_MANAGER=pack` 单独验证。

### 2026-05-01 第三阶段第二批已完成

当前第二批 pack 加载迁移已完成，默认启动路径仍保留 `lazy.nvim`，仅在 `NVIM_PLUGIN_MANAGER=pack` 或 `vim.g.nvim_plugin_manager = "pack"` 时启用新分支。

已完成事项：

- 已明确接受 `nvim-pack-lock.json` 与 `lazy-lock.json` 当前 revision 差异，本轮不再做对齐或回退。
- 已新增 `lua/pack/lazy_bridge.lua`，用于迁移期复用现有 `lua/plugins/*.lua` 中的 `opts`、`config`、`init`、`keys` 字段。
- 已在 `lua/pack/loaders.lua` 迁移第二批加载入口：基础 UI、状态栏、搜索、Git、诊断列表。
- 已迁移基础 UI：`nvim-web-devicons`、`noice.nvim`、`nvim-notify`、`fidget.nvim`、`colorful-winsep.nvim`、`nvim-scrollbar`、`nvim-colorizer.lua`。
- 已迁移状态栏与导航展示：`lualine.nvim`、`bufferline.nvim`、`incline.nvim`、`barbecue.nvim`、`nvim-navic`。
- 已迁移搜索入口：`fzf-lua`、`nvim-spectre`。
- 已迁移 Git 入口：`gitsigns.nvim`、`diffview.nvim`、`git-log.nvim`、`blame-column.nvim`。
- 已迁移诊断与 TODO 列表：`trouble.nvim`、`todo-comments.nvim`。
- 已为 `Diffview*` 与 `BlameColumnToggle` 增加命令占位加载，首次执行时先 `packadd` 并转发到真实命令。
- 已在 headless 场景跳过 `fzf-lua` UI 初始化，避免沙箱或 CI 中 `serverstart()` 无法创建 socket 时影响无界面验证。

已验证事项：

- `luac -p lua/pack/lazy_bridge.lua lua/pack/loaders.lua` 通过。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_SKIP_ADD=1 nvim -i NONE --headless +qa` 通过。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim -i NONE --headless +qa` 通过。
- 手动触发 `VimEnter`、`BufReadPre`、`WinLeave` 后，`lualine`、`bufferline`、`incline`、`noice`、`trouble`、`gitsigns`、`barbecue` 等第二批模块已确认可加载。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim -i NONE --headless "+DiffviewOpen" "+DiffviewClose" +qa` 通过。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim -i NONE --headless "+BlameColumnToggle" +qa` 通过。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- 默认 `lazy.nvim` 启动路径 `nvim -i NONE --headless +qa` 通过。

已知非阻断事项：

- 第二批为了降低迁移风险，仍通过 `lua/pack/lazy_bridge.lua` 复用现有 lazy spec 中的配置函数；后续可以继续把这些配置拆到纯 pack 配置模块中。
- `fzf-lua` 在真实交互会话中仍按 pack 分支加载；headless 下跳过的是 UI 初始化，不影响本轮无界面验证。
- 默认插件管理器仍未切到 `vim.pack`，需要等 LSP、补全、Treesitter、文件树和 AI 相关插件迁移完成后再决定。

下一步：

- 继续迁移第三批：LSP、补全、Treesitter、文件树、格式化、lint、Markdown 渲染和 AI 相关插件。
- 迁移完成前继续保留 `lazy.nvim` 回滚分支和 `lazy-lock.json`。

### 2026-05-01 第三阶段第三批已完成

当前第三批 pack 加载迁移已完成，默认启动路径仍保留 `lazy.nvim`，仅在 `NVIM_PLUGIN_MANAGER=pack` 或 `vim.g.nvim_plugin_manager = "pack"` 时启用 `vim.pack` 分支。

已完成事项：

- 已扩展 `lua/pack/lazy_bridge.lua`，支持递归查找 `dependencies` 中的嵌套 lazy spec，用于复用 `LuaSnip`、`nvim-treesitter-textobjects` 等依赖插件的 `opts` / `config`。
- 已在 `lua/pack/loaders.lua` 迁移第三批核心插件加载入口：LSP、补全、Treesitter、文件树、格式化、lint、Markdown 渲染和 CodeCompanion。
- 已迁移 LSP 入口：`mason.nvim`、`mason-lspconfig.nvim`、`schemastore.nvim`、`nvim-lspconfig` 和现有 `config.lsp`。
- 已迁移补全入口：`blink.cmp`、`blink-cmp-env`、`LuaSnip`、`friendly-snippets`、`blink.indent`。
- 已为 pack 分支补充 `blink.cmp` fuzzy 原生库的 `package.cpath` 前置处理，避免误加载 `codesnap.nvim` 的动态库。
- 已迁移 Treesitter 相关入口：`nvim-treesitter`、`nvim-treesitter-textobjects`、`rainbow-delimiters.nvim`、`nvim-ts-autotag`、`jsx-element.nvim`、`flash.nvim`。
- 已迁移文件树入口：`neo-tree.nvim`，包括 `Neotree` 命令占位、`<leader>e` 键位和 `nvim <directory>` 场景的目录参数加载。
- 已迁移格式化与 lint：`conform.nvim` 的 `ConformInfo` 命令和 `<leader>f`，以及 `nvim-lint` 的原有自动触发逻辑。
- 已迁移 Markdown / AI 入口：`render-markdown.nvim` 在 `markdown` / `codecompanion` filetype 下加载，`CodeCompanion*` 命令和现有 AI 键位通过占位入口加载。
- 已支持带 range 的命令占位转发，供 visual 模式下的 `CodeCompanion` 类命令继续使用。

已验证事项：

- `luac -p lua/pack/lazy_bridge.lua lua/pack/loaders.lua` 通过。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_SKIP_ADD=1 nvim -i NONE --headless +qa` 通过。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim -i NONE --headless +qa` 通过。
- 默认 `lazy.nvim` 启动路径 `nvim -i NONE --headless +qa` 通过。
- 已用 pack 分支打开 `lua/tools/tools.lua`，确认 `blink.cmp`、`config.lsp`、`nvim-lint`、`nvim-treesitter`、`rainbow-delimiters.nvim`、`flash.nvim` 加载入口可用。
- 已用 pack 分支打开 `README.md`，确认 `render-markdown.nvim` 在 Markdown filetype 下加载。
- 已用 pack 分支打开临时 TSX buffer，确认 `jsx-element.nvim` 在 `typescriptreact` filetype 下加载。
- 已验证 `ConformInfo` 命令占位可加载 `conform.nvim`。
- 已验证 `Neotree close` 命令占位可加载 `neo-tree.nvim`。
- 已验证 `CodeCompanionChat Toggle` 命令占位可加载 `codecompanion.nvim`，且不再触发 `blink_cmp_fuzzy` 误加载 `codesnap` 动态库的问题。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- 默认 `lazy.nvim` 路径的 `nvim -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- 默认 `lazy.nvim` 路径的 `nvim -i NONE --headless "+Lazy! check" +qa` 返回码为 0。

已知非阻断事项：

- 默认插件管理器仍未切到 `vim.pack`，当前仍保留 `lazy.nvim` 回滚分支和 `lazy-lock.json`。
- `CodeCompanionActions` 会打开 fzf 交互界面，不适合作为 headless 验证命令；本轮改用 `CodeCompanionChat Toggle` 验证插件加载。
- `Lazy! check` 仍可能出现 GitHub `LibreSSL SSL_connect: SSL_ERROR_SYSCALL` 抖动，但本次最终返回码为 0。
- `Lazy! check` 仍提示 `LuaSnip` 与 `rainbow-delimiters.nvim` 的 lazy 安装目录存在本地改动，这是前序阶段已记录的非阻断项，本轮没有重置外部插件目录。
- `vim.pack` 分支仍有未迁移的低风险工具类插件入口，例如 `bookmarks.nvim`、`convert.nvim`、`copy_with_context.nvim`、`neogen`、`toggleterm.nvim`、`codesnap.nvim`、`kulala.nvim` 等。

下一步：

- 继续迁移剩余低风险工具类插件和语言/编辑辅助插件。
- 迁移完成后再统一决定是否将默认插件管理器从 `lazy.nvim` 切到 `vim.pack`。

### 2026-05-01 第三阶段第四批已完成

当前第四批 pack 加载迁移已完成，默认启动路径仍保留 `lazy.nvim`，仅在 `NVIM_PLUGIN_MANAGER=pack` 或 `vim.g.nvim_plugin_manager = "pack"` 时启用 `vim.pack` 分支。

已完成事项：

- 已扩展 `lua/pack/lazy_bridge.lua` 的 `apply_keys()`，支持传入额外 keymap 选项，并过滤 lazy.nvim 专属的 `ft` 字段，便于迁移 filetype 局部按键。
- 已在 `lua/pack/loaders.lua` 迁移剩余低风险工具类与编辑辅助插件：`mini.splitjoin`、`vim-cursorword`、`vim-visual-multi`、`neoscroll.nvim`、`toggleterm.nvim`、`bookmarks.nvim`、`convert.nvim`、`json-to-types.nvim`、`copy_with_context.nvim`、`neogen`、`numb.nvim`、`lastplace.nvim`、`persistence.nvim`、`visual-whitespace.nvim`、`emmet-vim`、`kulala.nvim`、`codesnap.nvim`。
- 已为 `ConvertFindCurrent`、`ConvertFindNext`、`ConvertAll`、`ConvertJSONtoLang`、`ConvertJSONtoLangBuffer`、`CodeSnap`、`CodeSnapHighlight` 增加命令占位加载。
- 已为 `persistence.nvim` 的 `<leader>sl` / `<leader>ss` 增加带加载保护的 session 快捷键。
- 已补充 CSS/LESS/SCSS、JSON、HTML/Vue/JSX/TSX、HTTP filetype 加载入口，分别覆盖单位转换、JSON 类型生成、Emmet 和 Kulala。
- 已补充备用主题插件加载，使 pack 分支下仍可手动切换当前仓库中保留的主题插件。
- 已在 pack 分支触发并安装 `kulala_http` Treesitter parser。

已验证事项：

- `luac -p lua/pack/lazy_bridge.lua lua/pack/loaders.lua` 通过。
- 默认 `lazy.nvim` 启动路径 `nvim -i NONE --headless +qa` 返回码为 0。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_SKIP_ADD=1 nvim -i NONE --headless +qa` 返回码为 0。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim -i NONE --headless +qa` 返回码为 0。
- 已用 pack 分支打开 CSS、JSON、Vue、HTTP 临时 buffer，确认 `convert.nvim`、`json-to-types.nvim`、`emmet-vim`、`kulala.nvim` 入口可加载。
- 已用 pack 分支打开 Lua 文件，确认 `toggleterm.nvim`、`lastplace.nvim`、`mini.splitjoin`、`neoscroll.nvim`、`copy_with_context.nvim`、`neogen`、`numb.nvim`、`persistence.nvim` 入口可加载。
- 已确认 `vim-cursorword`、`vim-visual-multi`、`visual-whitespace.nvim` 已进入 pack 分支 runtimepath。
- `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_CONFIRM=0 nvim -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- 默认 `lazy.nvim` 路径的 `nvim -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- 默认 `lazy.nvim` 路径的 `nvim -i NONE --headless "+Lazy! check" +qa` 在沙箱外返回码为 0。

已知非阻断事项：

- 默认插件管理器仍未切到 `vim.pack`，当前仍保留 `lazy.nvim` 回滚分支和 `lazy-lock.json`。
- 本轮仍通过 `lua/pack/lazy_bridge.lua` 复用现有 lazy spec 中的配置函数；后续如要彻底移除 `lazy.nvim`，需要继续把配置拆到纯 pack 配置模块中。
- 在沙箱内直接使用默认 `~/.local/state` / `~/.cache` 路径运行 Neovim 时，仍可能出现日志文件写入权限提示；改用 `/tmp` 下的 `XDG_STATE_HOME` / `XDG_CACHE_HOME` 后验证通过。
- `kulala.nvim` 首次打开 HTTP buffer 会触发 `kulala_http` parser 编译；本轮已在沙箱外完成安装。
- `Lazy! check` 仍可能出现 GitHub `LibreSSL SSL_connect: SSL_ERROR_SYSCALL` 抖动，并继续提示 `LuaSnip` 与 `rainbow-delimiters.nvim` 的 lazy 安装目录存在本地改动；本轮没有重置外部插件目录。

下一步：

- 统一核对 `vim.pack` 分支是否还有未覆盖的 lazy.nvim 行为差异。
- 若没有新增问题，再决定是否将默认插件管理器从 `lazy.nvim` 切到 `vim.pack`。

### 2026-05-01 第三阶段默认切换已完成

当前第三阶段已完成默认插件管理器切换。默认启动路径已从 `lazy.nvim` 切到 Neovim 原生 `vim.pack`，但仍保留 `lazy.nvim` 回滚分支。

已完成事项：

- 已核对 lazy.nvim 实际插件图：去掉 `lazy.nvim` 自身后共有 `74` 个实际启用插件。
- 已核对 `lua/pack/specs.lua`：当前 `vim.pack` 清单共有 `74` 个插件，和实际 lazy.nvim 插件图一致。
- 已确认实际 lazy.nvim 插件图中没有 `vim.pack` 缺失项。
- 已确认 `blink.compat` 是 lazy.nvim 中 `optional = true` 的未启用依赖，当前 `sources.compat = {}`，不需要加入 pack 清单。
- 已确认 `lush.nvim` 是 `zenbones.nvim` 的依赖，已在 pack 清单中显式声明。
- 已将 `init.lua` 默认插件管理器从 `"lazy"` 切换为 `"pack"`。
- 已保留回滚入口：设置 `NVIM_PLUGIN_MANAGER=lazy` 或 `vim.g.nvim_plugin_manager = "lazy"` 时仍走 `lazy.nvim` 分支。

已验证事项：

- `luac -p init.lua lua/pack/index.lua lua/pack/specs.lua lua/pack/hooks.lua lua/pack/lazy_bridge.lua lua/pack/loaders.lua` 通过。
- 默认 pack 启动路径 `NVIM_PACK_CONFIRM=0 nvim -i NONE --headless +qa` 返回码为 0。
- lazy 回滚路径 `NVIM_PLUGIN_MANAGER=lazy nvim -i NONE --headless +qa` 返回码为 0。
- pack 无安装冒烟路径 `NVIM_PLUGIN_MANAGER=pack NVIM_PACK_SKIP_ADD=1 nvim -i NONE --headless +qa` 返回码为 0。
- 默认 pack 路径 `nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- lazy 回滚路径 `NVIM_PLUGIN_MANAGER=lazy nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- 默认 pack 路径下已确认 `FzfLua`、`Trouble`、`Neotree`、`ConformInfo`、`CodeCompanionChat`、`ConvertAll`、`ConvertJSONtoLang`、`CodeSnap` 命令存在。
- 默认 pack 路径下已确认 HTTP filetype 会加载 `kulala.nvim`，并注册 `<leader>rs` 请求发送键位。
- lazy 回滚路径 `NVIM_PLUGIN_MANAGER=lazy nvim -i NONE --headless "+Lazy! check" +qa` 已在沙箱外返回码为 0。

已知非阻断事项：

- pack 分支仍通过 `lua/pack/lazy_bridge.lua` 复用现有 lazy spec 中的配置函数；这不阻塞默认切换，但后续若要彻底移除 `lazy.nvim`，仍需要继续把配置拆成纯 pack 配置模块。
- `Lazy! check` 仍会提示 `rainbow-delimiters.nvim` 的 `test/bin` 子模块元数据异常，这是前序阶段已记录的外部插件目录状态，本轮没有重置该目录。
- 为避免沙箱内写入 `~/.bookmarks`、`~/.local/state`、`~/.cache` 等路径，本轮部分 headless 验证使用了 `/tmp` 下的 XDG 路径；这不影响真实交互启动路径。
- pack 分支在 headless 下仍会跳过 `fzf-lua` UI 初始化，避免无界面环境中 `serverstart()` 权限问题；真实交互会话仍按普通 pack 分支加载。

下一步：

- 日常使用默认 `vim.pack` 分支，重点观察启动、文件打开、LSP attach、补全、Treesitter、文件树、搜索、格式化、Markdown 渲染和 CodeCompanion。
- 如果默认 pack 分支稳定，再单独处理“彻底移除 lazy.nvim / lazy-lock.json”或继续拆除 `lazy_bridge` 的后续清理。

### 2026-05-01 第三阶段 lazy.nvim 运行时入口已移除

当前已完成默认 `vim.pack` 分支后的第一轮清理：`lazy.nvim` 不再作为运行时回滚入口保留。

已完成事项：

- 已将 `init.lua` 简化为只加载 `config.index` 和 `pack.index`。
- 已删除 `lua/bootstrap.lua`，移除 `lazy.nvim` bootstrap 和 `require("lazy").setup()` 入口。
- 已删除主锁文件 `lazy-lock.json`，后续使用 `nvim-pack-lock.json` 作为插件锁文件。
- 已清理 `lua/pack/loaders.lua` 中关于默认 lazy 回滚分支的过期注释。
- 已保留 `lua/pack/lazy_bridge.lua`，原因是当前 pack 分支仍复用历史 `lua/plugins/*.lua` 配置表；它不再依赖 `lazy.nvim` 运行时。

已验证事项：

- `luac -p init.lua lua/pack/index.lua lua/pack/specs.lua lua/pack/hooks.lua lua/pack/lazy_bridge.lua lua/pack/loaders.lua lua/tools/tools.lua lua/plugins/neotree.lua` 通过。
- `env XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_SKIP_ADD=1 nvim -i NONE --headless +qa` 返回码为 0。
- `env XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -i NONE --headless +qa` 返回码为 0。
- `env XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- 已确认 `Neotree`、`ConformInfo`、`CodeCompanionChat`、`ConvertAll`、`ConvertJSONtoLang`、`CodeSnap`、`DiffviewOpen`、`BlameColumnToggle` 命令存在。
- 已确认 `:Lazy` 命令不再存在。
- 已确认 `init.lua` / `lua/` 中不再存在 `require("lazy")`、`require("bootstrap")` 或 `NVIM_PLUGIN_MANAGER` 回滚开关引用。

已知非阻断事项：

- `lazy-lock.nvim-0.11.5.json` 仍作为升级前锁文件备份保留。
- `lua/pack/lazy_bridge.lua` 和 `lua/plugins/*.lua` 中仍保留历史 lazy spec 结构；这是后续“拆除 lazy_bridge”的清理范围，不影响当前 `vim.pack` 运行路径。
- `UPGRADE.md` 前文仍包含历史阶段中的 `Lazy! check` 和 lazy 回滚验证记录，属于执行记录，不代表当前入口仍存在。

下一步：

- 单独评估是否继续拆除 `lazy_bridge`，把 `lua/plugins/*.lua` 中的历史 lazy spec 逐步整理成纯 pack 配置模块。

### 2026-05-01 第三阶段 lazy_bridge 第一批清理已完成

当前已开始拆除 `lazy_bridge` 的后续清理。本轮只处理低风险工具类与编辑辅助插件，复杂的 LSP、补全、Treesitter、文件树、搜索、Markdown 和 AI 插件仍暂时保留 `lazy_bridge` 复用路径。

已完成事项：

- 已新增 `lua/pack/configs/`，用于承载纯 `vim.pack` 配置模块。
- 已迁移 `mini.splitjoin`、`neoscroll.nvim`、`toggleterm.nvim`、`bookmarks.nvim`、`convert.nvim`、`json-to-types.nvim`、`copy_with_context.nvim`、`neogen`、`numb.nvim`、`lastplace.nvim`、`persistence.nvim`、`kulala.nvim` 的配置或快捷键注册。
- 已将 `lua/pack/loaders.lua` 中上述插件的 `setup_lazy_plugin(...)` / `apply_lazy_keys(...)` 调用替换为 `pack.configs.*` 模块调用。
- 已保留 `lua/plugins/*.lua` 中的历史 lazy spec 文件，当前只是让 pack 默认路径不再依赖这些插件的历史 spec。
- 已将本轮新增快捷键描述和注释统一为中文。

已验证事项：

- `luac -p lua/pack/loaders.lua lua/pack/configs/*.lua` 通过。
- `env XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -i NONE --headless +qa` 返回码为 0。
- 已用默认 pack 分支打开 Lua 文件，确认 `mini.splitjoin`、`neoscroll.nvim`、`copy_with_context.nvim`、`numb.nvim` 等入口可加载。
- 已用默认 pack 分支触发 `http` filetype，确认 `kulala.nvim` 的 `<leader>rs` 请求发送键位可注册。
- 已用默认 pack 分支触发 `css` / `json` filetype，确认 `convert.nvim` 与 `json-to-types.nvim` 的核心键位可注册。
- `env XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。

已知非阻断事项：

- `lua/pack/lazy_bridge.lua` 仍被 UI、搜索、Git、LSP、补全、Treesitter、文件树、格式化、Markdown、CodeCompanion 等复杂插件路径使用，本轮没有一次性拆除。
- 不要并发运行多个会执行 `vim.pack.add()` 的 headless Neovim 进程；它们会同时读写 `nvim-pack-lock.json`，可能导致短暂锁文件读取错误。后续验证应串行执行或使用 `NVIM_PACK_SKIP_ADD=1`。

下一步：

- 继续拆除 `lazy_bridge` 的第二批，优先选择 UI / 状态栏 / Git / 诊断列表等中等复杂度插件。
- 每拆一批都继续执行 `luac -p`、默认 pack 启动冒烟和 `checkhealth`。

### 2026-05-01 第三阶段 lazy_bridge 第二批清理已完成

当前已继续拆除 `lazy_bridge` 的第二批。本轮处理 UI、状态栏、搜索、Git、诊断列表等中等复杂度插件，并顺手迁移了仍依赖历史 spec 的 `vim-visual-multi` 配置。

已完成事项：

- 已新增第二批纯 pack 配置模块：`devicons.lua`、`colorschemes.lua`、`noice.lua`、`lualine.lua`、`bufferline.lua`、`incline.lua`、`barbecue.lua`、`fidget.lua`、`colorful_winsep.lua`、`scrollbar.lua`、`colorizer.lua`、`fzf.lua`、`spectre.lua`、`gitsigns.lua`、`diffview.lua`、`git_log.lua`、`blame_column.lua`、`trouble.lua`、`todo_comments.lua`、`visual_multi.lua`。
- 已将上述插件在 `lua/pack/loaders.lua` 中的 `setup_lazy_plugin(...)` 或 `apply_lazy_keys(...)` 调用替换为 `pack.configs.*` 模块调用。
- 已把 `lualine.nvim` 的启动期 statusline 处理迁移到 `pack.configs.lualine.apply_startup_statusline()`。
- 已将 `noice.nvim`、`fzf-lua`、`trouble.nvim` 的快捷键改为带加载保护的 pack 回调，避免首次按键时直接依赖历史 lazy spec。
- 已将 `diffview.nvim` 的快捷键迁移为纯 pack 注册，继续通过 `Diffview*` 命令占位触发真实加载。
- 已将 `gitsigns.nvim`、`todo-comments.nvim`、`git-log.nvim`、`blame-column.nvim`、`vim-visual-multi` 的配置移入纯 pack 配置模块。

已验证事项：

- `luac -p lua/pack/loaders.lua lua/pack/configs/*.lua` 通过。
- `env XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -i NONE --headless +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless lua/tools/tools.lua "+doautocmd VimEnter" "+lua ..." +qa` 返回码为 0，并确认 `bufferline`、`lualine`、`gitsigns`、`scrollbar`、`todo-comments`、`trouble`、`noice`、`fidget` 已加载。
- 已在沙箱外强制 `packadd nvim-web-devicons` / `packadd fzf-lua` 并执行 `pack.configs.fzf.setup()`，确认新的 fzf 配置模块可初始化。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+DiffviewOpen" "+DiffviewClose" "+BlameColumnToggle" +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_SKIP_ADD=1 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。

已知非阻断事项：

- `lua/pack/lazy_bridge.lua` 仍被 Mason / LSP、blink.cmp / LuaSnip、Treesitter、文件树、格式化、lint、Markdown、CodeCompanion 等复杂路径使用，本轮没有拆这些核心链路。
- headless 下仍保留 `fzf-lua` UI 初始化跳过策略；真实交互会话不受影响。
- 为避免沙箱内写入 `~/.bookmarks`，涉及 `VimEnter` 的本轮验证使用 `HOME=/tmp`，同时显式指定 `XDG_DATA_HOME=/Users/somnuszyy9527/.local/share` 复用本机已安装插件。

下一步：

- 继续拆除 `lazy_bridge` 的第三批，优先处理相对独立的核心链路，例如 Mason / LSP、格式化 / lint，或文件树与 Markdown 渲染。
- blink.cmp / LuaSnip、Treesitter 和 CodeCompanion 的配置耦合更高，建议单独分批处理并保留更细的验证命令。

### 2026-05-01 第三阶段 lazy_bridge 第三批清理已完成

当前已继续拆除 `lazy_bridge` 的第三批。本轮处理相对独立的核心链路：Mason / LSP、格式化 / lint、文件树和 Markdown 渲染。

已完成事项：

- 已新增第三批纯 pack 配置模块：`mason.lua`、`lsp.lua`、`conform.lua`、`lint.lua`、`neotree.lua`、`render_markdown.lua`。
- 已将 `lua/pack/loaders.lua` 中 Mason / LSP、`conform.nvim`、`nvim-lint`、`neo-tree.nvim`、`render-markdown.nvim` 的 `setup_lazy_plugin(...)` 调用替换为 `pack.configs.*` 模块调用。
- 已将 Neo-tree 的 `<leader>e` 快捷键和 `nvim <directory>` 目录参数启动逻辑迁移到 `pack.configs.neotree`。
- 已将 Conform 的 `<leader>f` 格式化后触发 lint 的流程迁移到 `pack.configs.conform`，继续通过 `setup_lint()` 按需加载 `nvim-lint`。
- 已将 `nvim-lint` 的 ESLint 配置探测、本地 eslint 优先策略、`linters_by_ft` 和自动触发逻辑迁移到 `pack.configs.lint`。
- 已将 render-markdown 保持为空配置的默认初始化逻辑迁移到 `pack.configs.render_markdown`。

已验证事项：

- `luac -p lua/pack/loaders.lua lua/pack/configs/mason.lua lua/pack/configs/lsp.lua lua/pack/configs/conform.lua lua/pack/configs/lint.lua lua/pack/configs/neotree.lua lua/pack/configs/render_markdown.lua` 通过。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- 已在沙箱外打开 Lua 文件并断言 `mason`、`mason-lspconfig`、`config.lsp`、`lint` 均已加载，返回码为 0。
- 已验证 `ConformInfo` 命令占位可加载 `conform.nvim`，`Neotree close` 命令占位可加载 `neo-tree.nvim`。
- 已打开 `UPGRADE.md` 并断言 `render-markdown` 在 Markdown filetype 下加载成功。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_SKIP_ADD=1 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。

已知非阻断事项：

- `lua/pack/lazy_bridge.lua` 仍被 `blink.cmp` / LuaSnip、Treesitter、`rainbow-delimiters.nvim`、`nvim-ts-autotag`、`jsx-element.nvim`、Flash 快捷键和 CodeCompanion 使用，本轮没有拆这些高耦合链路。
- 在普通沙箱内打开 Lua 文件时，`lua-language-server` 会尝试写入 Mason 安装目录下的自身缓存并触发 `Operation not permitted`；已按权限要求在沙箱外重跑同一验证并通过。真实交互环境不受本次沙箱限制影响。

下一步：

- 继续拆除 `lazy_bridge` 的第四批，建议优先处理 Treesitter 相关链路或 blink.cmp / LuaSnip；CodeCompanion 仍建议最后单独处理。
- 每拆一批继续执行 `luac -p`、默认 pack 启动冒烟、目标插件触发验证和 `checkhealth`。

### 2026-05-01 第三阶段 lazy_bridge 第四批清理已完成

当前已继续拆除 `lazy_bridge` 的第四批。本轮处理 Treesitter 相关链路和 Flash 快捷键，`blink.cmp` / LuaSnip 与 CodeCompanion 仍保留到后续单独处理。

已完成事项：

- 已新增第四批纯 pack 配置模块：`treesitter.lua`、`rainbow_delimiters.lua`、`ts_autotag.lua`、`jsx_element.lua`、`flash.lua`。
- 已将 `nvim-treesitter` main 的 parser 安装、FileType 启动、高亮、折叠、缩进逻辑迁移到 `pack.configs.treesitter`。
- 已将 `nvim-treesitter-textobjects` main 的 `select` / `move` 配置迁移到 `pack.configs.treesitter.setup_textobjects()`。
- 已将 `rainbow-delimiters.nvim` 的 parser 可用性过滤、策略、query、priority 和 highlight 配置迁移到 `pack.configs.rainbow_delimiters`。
- 已将 `nvim-ts-autotag` 默认初始化迁移到 `pack.configs.ts_autotag`。
- 已将 `jsx-element.nvim` 的旧命令键位关闭配置和 TSX/JSX buffer 局部 textobject 键位迁移到 `pack.configs.jsx_element`。
- 已将 `flash.nvim` 的 `ss` / `sS` 快捷键迁移为纯 pack 回调，首次按键会先加载插件再执行 `jump` 或 `treesitter`。
- 已将 `lua/pack/loaders.lua` 中上述插件的 `setup_lazy_plugin(...)` / `apply_lazy_keys(...)` 调用替换为 `pack.configs.*` 模块调用。

已验证事项：

- `luac -p lua/pack/loaders.lua lua/pack/configs/treesitter.lua lua/pack/configs/rainbow_delimiters.lua lua/pack/configs/ts_autotag.lua lua/pack/configs/jsx_element.lua lua/pack/configs/flash.lua` 通过。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_SKIP_ADD=1 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- 已用默认 pack 分支打开 Lua 文件，确认 `nvim-treesitter`、`rainbow-delimiters`、`flash.nvim` 和 `ss` 键位入口可用。
- 已用默认 pack 分支触发 `typescriptreact` filetype，确认 `jsx-element.nvim` 加载成功，`it` 与 `]t` 等 JSX textobject 键位可注册。
- 已用默认 pack 分支触发 `InsertEnter`，确认 `nvim-ts-autotag` 可加载。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。

已知非阻断事项：

- `lua/pack/lazy_bridge.lua` 仍被 `blink.cmp` / LuaSnip 和 CodeCompanion 使用，本轮已不再覆盖 Treesitter、rainbow、autotag、JSX 或 Flash。
- 在 `HOME=/tmp` 的 headless 验证中，`lua_ls` 仍可能输出退出提示；本轮目标命令返回码为 0，且这属于前序阶段已记录的沙箱化验证限制。

下一步：

- 继续拆除 `lazy_bridge` 的第五批，建议优先处理 `blink.cmp` / LuaSnip。
- CodeCompanion 仍建议最后单独处理，因为它同时依赖 Treesitter、fzf-lua、blink.cmp、prompt library 和多组命令入口。

### 2026-05-01 第三阶段 lazy_bridge 第五批清理已完成

当前已继续拆除 `lazy_bridge` 的第五批。本轮处理 `blink.cmp` / LuaSnip 补全链路，CodeCompanion 仍保留到最后单独处理。

已完成事项：

- 已新增纯 pack 配置模块 `lua/pack/configs/blink.lua`。
- 已将 LuaSnip 的 `history`、区域检查、删除检查、`InsertLeave` 自动 `unlink_current()` 和本地 `lua/snippets` 片段加载逻辑迁移到 `pack.configs.blink.setup_luasnip()`。
- 已将 `blink.cmp` 的补全配置迁移到 `pack.configs.blink.setup()`，包括 LuaSnip snippet preset、菜单展示、文档浮窗、ghost text、命令行补全和 Alt 系列补全快捷键。
- 已保留 Vue script 区域的 vtsls 补全过滤逻辑，继续避免 Vue template / style 区域的补全来源污染 script 补全。
- 已保留 CodeCompanion 补全 provider、Skills 补全 provider 和环境变量补全 provider。
- 已保留 compat source 扩展逻辑，当前 `compat` 列表仍为空，但后续如恢复 `blink.compat` 可继续复用同一初始化流程。
- 已将 `lua/pack/loaders.lua` 中 `LuaSnip` 与 `blink.cmp` 的 `setup_lazy_plugin(...)` 调用替换为 `pack.configs.blink` 模块调用。

已验证事项：

- `luac -p lua/pack/loaders.lua lua/pack/configs/blink.lua` 通过。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_SKIP_ADD=1 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- 已用默认 pack 分支打开 Lua 文件并触发 `VimEnter`，确认 `blink.cmp` 和 `LuaSnip` 已加载。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。

已知非阻断事项：

- `lua/pack/lazy_bridge.lua` 当前只剩 CodeCompanion 路径使用：`setup_lazy_plugin("plugins.codecompanion", "codecompanion.nvim", "codecompanion")` 和 `apply_lazy_keys("plugins.codecompanion", "codecompanion.nvim")`。
- 在 `HOME=/tmp` 的 headless 验证中，`lua_ls` 仍可能输出退出提示；本轮目标命令返回码为 0，且这属于前序阶段已记录的沙箱化验证限制。

下一步：

- 拆除 `lazy_bridge` 的最后一批：单独迁移 CodeCompanion 配置和按键入口。
- CodeCompanion 迁移完成并验证后，可以删除 `lua/pack/lazy_bridge.lua`，再评估是否保留或删除历史 `lua/plugins/*.lua`。

### 2026-05-01 第三阶段 lazy_bridge 最后一批清理已完成

当前已完成 `lazy_bridge` 的最后一批清理。本轮单独迁移 CodeCompanion，默认 `vim.pack` 路径不再依赖历史 lazy spec 桥接层。

已完成事项：

- 已新增纯 pack 配置模块 `lua/pack/configs/codecompanion.lua`。
- 已将 CodeCompanion 的 Codex / Kimi / ACP adapter 配置迁移到 `pack.configs.codecompanion`。
- 已将 CodeCompanion 的 rules、slash commands、chat tools、prompt library、history 扩展占位配置迁移到 `pack.configs.codecompanion`。
- 已将 CodeCompanion 的 `<localLeader>:`、`<localLeader>,`、`<localLeader>a` 和可视模式 `<localLeader>l` 入口迁移为纯 pack 快捷键注册。
- 已将 `lua/pack/loaders.lua` 中最后的 `setup_lazy_plugin(...)` 和 `apply_lazy_keys(...)` 调用替换为 `pack.configs.codecompanion` 模块调用。
- 已删除 `lua/pack/lazy_bridge.lua`。
- 已确认 `init.lua` / `lua/` 中不再存在 `lazy_bridge`、`setup_lazy_plugin` 或 `apply_lazy_keys` 引用。

已验证事项：

- `luac -p lua/pack/loaders.lua lua/pack/configs/codecompanion.lua` 通过。
- `luac -p lua/pack/*.lua lua/pack/configs/*.lua` 通过。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_SKIP_ADD=1 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- 已用默认 pack 分支断言 `CodeCompanion` / `CodeCompanionChat` 命令占位存在，且 `<localLeader>,` / `<localLeader>a` 快捷键已注册。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+CodeCompanionChat Toggle" +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。

已知非阻断事项：

- `CodeCompanionChat Toggle` 的 headless 验证使用 `HOME=/tmp`，因此 rules 模块会提示 `/tmp/.config/agents/rules/frontend` 不存在；这是隔离 HOME 的验证环境差异，真实交互环境仍会使用用户 home 下的规则目录。
- `lua/plugins/*.lua` 中仍保留历史 lazy spec 文件；当前默认 pack 路径已经不依赖 `lazy_bridge`，后续是否删除这些历史文件应单独评估。

下一步：

- 评估是否删除或归档历史 `lua/plugins/*.lua`。
- 若继续清理，优先先核对 `lua/plugins/*.lua` 中是否仍有被文档、脚本或人工回退流程依赖的配置内容。

### 2026-05-01 第三阶段历史 lazy spec 已删除

当前已完成历史 `lua/plugins/*.lua` 的删除清理。默认 `vim.pack` 路径继续以 `lua/pack/specs.lua`、`lua/pack/loaders.lua` 和 `lua/pack/configs/` 作为唯一运行时配置来源。

已完成事项：

- 已核对运行时代码中不再存在 `require("plugins...")`、`plugins.`、`lazy_bridge`、`setup_lazy_plugin`、`apply_lazy_keys`、`require("lazy")`、`require("bootstrap")` 或 `NVIM_PLUGIN_MANAGER` 引用。
- 已确认 `lua/plugins/*.lua` 只剩历史 lazy spec，不再被文档、脚本或运行时回退流程依赖。
- 已删除 `lua/plugins/*.lua` 下的历史 lazy spec 文件。
- 已保留 `lazy-lock.nvim-0.11.5.json` 作为升级前锁文件备份。
- `lua/plugins/.DS_Store` 是本地 macOS 元数据，并已由全局 gitignore 忽略，不属于仓库变更。

已验证事项：

- `luac -p init.lua lua/config/index.lua lua/config/compat.lua lua/pack/*.lua lua/pack/configs/*.lua` 通过。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_SKIP_ADD=1 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。

已知非阻断事项：

- `UPGRADE.md` 前文仍保留迁移过程中的 lazy.nvim、Lazy 命令和 `lua/plugins/*.lua` 历史描述，属于升级过程记录，不代表当前运行入口仍存在。
- 当前仓库仍有大量第三阶段迁移改动未提交，本轮没有做提交或回滚操作。

下一步：

- 做一次最终差异审查，重点核对 `lua/pack/specs.lua`、`lua/pack/loaders.lua`、`lua/pack/configs/` 与已删除历史 spec 的覆盖关系。
- 如审查无新增问题，第三阶段可以进入收尾：整理 `UPGRADE.md` 状态、确认 `nvim-pack-lock.json` 和备份锁文件保留策略，并准备提交。

### 2026-05-01 第三阶段最终差异审查已完成

当前已完成第三阶段收尾前的最终差异审查。默认运行路径继续使用 Neovim 原生 `vim.pack`，历史 lazy 运行入口、桥接层和插件 spec 均已移除。

已完成事项：

- 已清理运行时代码中的 LazyVim 残留：移除 `lua/config/global.lua` 中已无意义的 `g.lazyvim_check_order`。
- 已删除 `lua/tools/tools.lua` 中未再使用的 `on_very_lazy()` / `VeryLazy` helper。
- 已将 `lua/tools/tools.lua` 与 `lua/tools/const.lua` 中本轮涉及的 `vim.loop` 调用改为 `vim.uv`。
- 已清理 `lua/pack/loaders.lua`、`lua/pack/specs.lua`、`lua/pack/hooks.lua`、`lua/pack/configs/codecompanion.lua` 中过期的 lazy 迁移期注释。
- 已确认 `lua/pack/specs.lua` 的插件清单数量为 `74`，`nvim-pack-lock.json` 中插件锁定数量也为 `74`。
- 已确认运行时代码中不再存在 `require("plugins...")`、`plugins.`、`lazy_bridge`、`setup_lazy_plugin`、`apply_lazy_keys`、`require("lazy")`、`require("bootstrap")`、`NVIM_PLUGIN_MANAGER`、`VeryLazy`、`on_very_lazy`、`lazyvim`、`LazyVim` 或 `lazy.nvim` 引用。

已验证事项：

- `luac -p init.lua lua/config/global.lua lua/tools/tools.lua lua/tools/const.lua lua/pack/*.lua lua/pack/configs/*.lua` 通过。
- `nvim -u NONE -i NONE --headless "+lua ..."` 已确认 `specs=74 lock=74`。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_SKIP_ADD=1 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。

已知非阻断事项：

- `lazy-lock.nvim-0.11.5.json` 继续作为升级前锁文件备份保留。
- `lua/plugins/.DS_Store` 仍是本地 macOS 元数据，并由全局 gitignore 忽略，不属于仓库变更。
- `UPGRADE.md` 前文保留 lazy.nvim、Lazy 命令和 `lua/plugins/*.lua` 的历史迁移记录，属于过程记录，不代表当前运行入口仍存在。

下一步：

- 第三阶段已具备提交条件；提交前可按需再做一次真实交互启动验证，重点检查启动消息、LSP attach、补全、文件树、搜索、格式化、Markdown 渲染和 CodeCompanion。

### 2026-05-01 第三阶段提交前验证已完成

当前已完成第三阶段提交前的最后一轮验证。默认运行路径继续使用 Neovim 原生 `vim.pack`，本轮没有发现新的运行时阻断问题。

已完成事项：

- 已确认 `nvim --version` 为 `NVIM v0.12.1`。
- 已确认 `tree-sitter --version` 为 `tree-sitter 0.26.8`。
- 已确认 `lua/pack/specs.lua` 的插件清单数量为 `74`，`nvim-pack-lock.json` 中 `plugins` 锁定数量为 `74`。
- 已确认运行时代码中不再存在 `require("plugins...")`、`plugins.`、`lazy_bridge`、`setup_lazy_plugin`、`apply_lazy_keys`、`require("lazy")`、`require("bootstrap")`、`NVIM_PLUGIN_MANAGER`、`VeryLazy`、`on_very_lazy`、`lazyvim`、`LazyVim` 或 `lazy.nvim` 引用。

已验证事项：

- `luac -p init.lua lua/config/global.lua lua/tools/tools.lua lua/tools/const.lua lua/pack/index.lua lua/pack/specs.lua lua/pack/hooks.lua lua/pack/loaders.lua lua/pack/configs/codecompanion.lua` 通过。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_SKIP_ADD=1 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless +qa` 返回码为 0。
- `env HOME=/tmp XDG_CONFIG_HOME=/Users/somnuszyy9527/.config XDG_DATA_HOME=/Users/somnuszyy9527/.local/share XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+checkhealth" +qa` 返回码为 0。
- 已用 headless 冒烟脚本确认 `Neotree`、`FzfLua`、`ConformInfo`、`CodeCompanionChat`、`RenderMarkdown` 命令入口存在，并确认 TSX buffer 中 `it` 与 `]t` JSX textobject 键位可注册。
- 已在真实 HOME 下沙箱外执行 `NVIM_PACK_CONFIRM=0 nvim -u init.lua -i NONE --headless "+CodeCompanionChat Toggle" +qa`，返回码为 0 且无输出错误。

已知非阻断事项：

- 隔离 `HOME=/tmp` 验证 CodeCompanion chat 时，规则目录和 ACP 会因隔离环境输出告警；真实 HOME 下沙箱外验证已通过。
- `lazy-lock.nvim-0.11.5.json` 继续作为升级前锁文件备份保留。
- `UPGRADE.md` 前文保留 lazy.nvim、Lazy 命令和 `lua/plugins/*.lua` 的历史迁移记录，属于过程记录，不代表当前运行入口仍存在。

下一步：

- 第三阶段已具备提交条件；如需提交，建议提交前再做一次真实交互启动，人工确认 `:messages`、LSP attach、补全、文件树、搜索、格式化、Markdown 渲染和 CodeCompanion 交互体验。
