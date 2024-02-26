# neovim-editor-config

#### 配置流程

##### 前置安装

- Git & 加到Path中
- Node & Npm & 加到Path中
- Python & 加到Path中
- CMake & 加到Path中 & 下载地址：[CMake下载地址](https://cmake.org/download/)
- Clang & 加到Path中 & 安装方式：在Visual Studio中安装时选择C++ Clang tools for
  windows，或者已安装的，点修改增加安装
- scoop & 安装的powershell命令：`iwr -useb get.scoop.sh | iex`; &
  如果出现权限问题可以设置：`Set-ExecutionPolicy RemoteSigned -scope CurrentUser`
- neovim &
  [neovim下载地址](https://github.com/neovim/neovim/blob/master/INSTALL.md) &
  注意：下载安装包安装，不要用scoop下载
- neovide & [neovide下载地址](https://neovide.dev/)
- ripgrep & 命令：`scoop install ripgrep`
- sed & [sed下载地址](https://ftp.gnu.org/gnu/sed/)
- fd & 安装命令：`scoop install fd`
- lua-language-server & 安装命令：`scoop install lua-language-server`
- delta && 安装命令：`scoop install delta`
- fzf && 安装命令：`scoop install fzf`
- sad && 安装命令: `scoop install sad`
- deno && 安装命令: `irm https://deno.land/install.ps1 | iex`

#### 下载配置

[配置地址](https://github.com/somnus9527/neovim-editor-config.git)

#### npm安装(全局)

- eslint_d
- typescript
- typescript-language-server
- vscode-langservers-extracted
- cssmodules-language-server
- @vue/language-server
- yaml-language-server
- emmet-ls
- @tailwindcss/language-server
- jsonlint
- markdownlint-cli
- stylelint
- stylint

#### pip安装

- yamlfix `pip install yamlfix`
- yamllint `pip install yamllint`
- cmakelang `pip install cmakelang`
- cmake-language-server `pip install cmake-language-server`

#### rustup安装

- rust-analyzer `rustup component add rust-analyzer`
- rustfmt `rustup component add rustfmt`

#### cargo安装

- taplo-cli `cargo install taplo-cli --features lsp --locked`

#### 一切就绪可以打开配置目录，进行Lazy安装

#### 最后可以通过`:checkhealth` 命令进行检查，不同环境可能会有额外的支持需求或者配置问题，待发现，后续会记录

#### 问题记录

1. treesitter在windows上需要使用clang作为编译器,否则会报错
2. 如果你的项目中使用了**styled-components**，这种情况需要针对项目做处理
   > 1. 项目的dev-dependencies需要安装`@styled/typescript-styled-plugin`和`typescript`包，如果有可以忽略
   > 2. 项目的jsconfig.json或者tsconfig.json中需要增加配置,
      > 这样styled-components就可以有提示了，不需要改neovim配置, 配置如下 ： {
      > "compilerOptions": { "plugins": [ { "name":
      > "@styled/typescript-styled-plugin" } ] } }
3. [字体图标搜索地址](https://www.nerdfonts.com/cheat-sheet)
4. 出现一种场景，希望可以在null-ls和lsp的diagnostics服务按场景切换，暂时无法做到，[有一个自定义lsp.handlers的方法链接](https://github.com/neovim/nvim-lspconfig/issues/127)
5. luacheck设置了read-globals之后校验丢失？？？
6. null-ls通过condition设置具体使用哪种diagnostics服务，lsp这边也通过判断在必要的时候（比如null-ls不支持）发布lsp服务的diagnostics，而不是全部取消了
7. yamllint需要一个配置文件，我直接塞到neovim配置的根目录下了，但是问题就是每台新电脑都要去修改一下路径
8. json_tool由于和condition配置冲突，所以json使用了json_tool和jsonlint来处理，json_tool需要配置indent,每个项目不一样，需要注意 （不需要了，除非是Mac需要确认地址，window一路默认的话不需要修改了)
9. deno_fmt/deno_lint也是一样需要deno.json配置，同样写了一份默认的放在了neovim配置的根目录下
10. lazygit对于中文的支持一坨屎，一旦出现中文直接布局错乱，用不了一点
11. 对于为什么使用ini作为配置文件，因为ini可以不下任何包就能直接用，所以。。。
12. mini.starter需要先给git配置`git config --system core.longpaths true`,否则如果通过mini.startter创建的文件路径过长,会报错
13. treesitter有时候会报错`treesitter/highlight: Error executing lua xx/xx/treesitter/query.lua: query: invalid node type ad position xxx`,遇到的时候是通过`:TSInstall javascript typescript`,具体是什么语言，是看具体出错的语言对应的server是什么，重新install一下，不一定可行，本次问题解决了
14. vscode-js-debug安装的时候可能会出现报错，大部分情况是没有权限，这时候就需要手动安装，对应的操作就是用管理员权限的终端，逐个执行build里的命令即可，目前前几个命令执行正常，但是mv命令windows下肯定执行不了，所以需要把dist目录名改为out即可
15. 如果需要eslint的formatting能够支持vue的template，需要如下操作：
    1. `yarn add -D eslint eslint-plugin-vue`
    2. eslint配置文件中添加配置：

    ```javascript
        module.exports = {
            extends = [
                'plugin:vue/vue3-recommended'
            ],
            rules = {}
        }
    ```

16. 配合自定义lsp_handlers再加上luacheck有点问题，所以取消null-ls的luacheck，使用lsp的lua_ls的diagnostics

    ```lua
    local publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
    vim.lsp.handlers['textDocument/publishDiagnostics'] = function(...)
      local err, method, params, client_id = ...
      if tools.is_lua_conf_project() then
        publish_diagnostics(err, method, params, client_id)
      end
    end
    ```

17. lsp clangd server出现了一个warn：`warning: multiple different client offset_encodings detected for buffer, this is not supported yet #428`,issue上说是clangd的offsetEncoding问题，所以处理方式如下：

    ```lua
    local clangd_capabilities = require('cmp_nvim_lsp').default_capabilities()
    clangd_capabilities.textDocument.completion.completionItem.snippetSupport = true
    clangd_capabilities.offsetEncoding = { 'utf-16' }
    lsp.clangd.setup {
      capabilities = clangd_capabilities,
    }
    ```

18. null-ls 的clang-check会默认以c mode打开.h文件，所以一些cpp独有的东西会报错，所以需要为clang-check添加配置参数如下：

    ```lua
    nls.builtins.diagnostics.clang_check.with {
      diagnostics_format = diagnostics_fmt,
      extra_args = { '-X', 'cxx' }
    },
    ```

19. lsp的emmet_ls服务提供了snippets，但是这个snippets却一直出现在了nvim-cmp的最上面，所以需要处理，方式如下：

    ```lua
    -- 定义方法
    local cmp = require 'cmp'
    local types = require 'cmp.types'
    local function deprioritize_snippet(entry1, entry2)
      if entry1:get_kind() == types.lsp.CompletionItemKind.Snippet then
        return false
      end
      if entry2:get_kind() == types.lsp.CompletionItemKind.Snippet then
        return true
      end
    end
    -- 然后在nvim-cmp的配置中增加如下配置
    local opts = {
      -- ... 其它配置
      sorting = {
        priority_weight = 2,
        comparators = {
          deprioritize_snippet,
          -- the rest of the comparators are pretty much the defaults
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.scopes,
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
      -- ...其它配置
    }
    ```

20. lua-json5在windows上需要手动进去执行install.ps1，不知道为什么build没有效果
