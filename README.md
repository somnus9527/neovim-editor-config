# neovim-editor-config

#### 配置流程

##### 前置安装
- Git & 加到Path中
- Node & Npm & 加到Path中
- Python & 加到Path中
- CMake & 加到Path中 & 下载地址：[CMake下载地址](https://cmake.org/download/)
- Clang & 加到Path中 & 安装方式：在Visual Studio中安装时选择C++ Clang tools for windows，或者已安装的，点修改增加安装
- scoop & 安装的powershell命令：```iwr -useb get.scoop.sh | iex```; & 如果出现权限问题可以设置：```Set-ExecutionPolicy RemoteSigned -scope CurrentUser```
- neovim & [neovim下载地址](https://github.com/neovim/neovim/blob/master/INSTALL.md) & 注意：下载安装包安装，不要用scoop下载
- neovide & [neovide下载地址](https://neovide.dev/)
- ripgrep & 命令：```scoop install ripgrep```
- sed & [sed下载地址](https://ftp.gnu.org/gnu/sed/)
- fd & 安装命令：```scoop install fd```
- lua-language-server & 安装命令：```scoop install lua-language-server```
- delta && 安装命令：```scoop install delta```
- fzf && 安装命令：```scoop install fzf```
- sad && 安装命令: ```scoop install sad```

#### 下载配置
[配置地址](git@github.com:somnus9527/neovim-editor-config.git)

#### npm安装(全局)
- eslint_d
- typescript
- typescript-language-server
- vscode-langservers-extracted
- cssmodules-language-server
- @vue/language-server
- yaml-language-server
- emmet-ls 

#### 一切就绪可以打开配置目录，进行Lazy安装

#### 最后可以通过`:checkhealth` 命令进行检查，不同环境可能会有额外的支持需求或者配置问题，待发现，后续会记录

#### 问题记录
1. treesitter在windows上需要使用clang作为编译器,否则会报错
