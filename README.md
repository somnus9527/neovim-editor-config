### 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

#### 备注

1. lsp中增加的css_ls和cssmodule_ls,html两个server，需要手动通过命令安装`:LspInstall css_ls cssmodule_ls,html`

#### TODO
- [x] 需要尝试[grapple](https://github.com/cbochs/grapple.nvim)插件
> 不好用

#### 记录
- 目前发现cssls会在启动时解析代码，如果发现类似@import这种引入外部资源的代码，就回去发请求去获取，这就造成如果没有翻墙，这个请求一定会报错，导致lua error,然后就会出现一堆报错。目前没有发现解决办法，唯一的方案就是在启动neovim前，先保证终端能翻墙，就不会报错，后面有机会再尝试去解决
