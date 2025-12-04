### Somnus9527's Neovim Editor

#### 备注

##### .tmux.conf文件示例
```.tmux.conf
# 设置前缀
set -g prefix C-q
# 取消原前缀
unbind C-b
# 启用鼠标交互
set-option -g mouse on

set -g focus-events on

# 使用vi风格的按键绑定
setw -g mode-keys vi

# 进入复制模式时启动vi风格
bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel \; run "tmux save-buffer - | pbcopy"

# 行尾
bind-key -T copy-mode-vi '$' send -X end-of-line

# 行首
bind-key -T copy-mode-vi '0' send -X start-of-line

# 向后一个单词
bind-key -T copy-mode-vi 'w' send -X next-word

# 向前一个单词
bind-key -T copy-mode-vi 'b' send -X previous-word

# 到下一个单词末尾
bind-key -T copy-mode-vi 'e' send -X next-word-end

# 向上翻页
bind-key -T copy-mode-vi 'C-u' send -X page-up

# 向下翻页
bind-key -T copy-mode-vi 'C-d' send -X page-down
```

### 卡顿分析
- 通过 neovim命令输出日志分析
```
:profile start profile.log
:profile func *
:profile file *
```
- 一旦发现卡顿，就可以暂停记录，然后把当前目录下的profile.log文件交给GPT分析即可
`:profile stop`


