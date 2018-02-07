# macOS specific

## pbcopy & pbpaste for tmux(byobu)

Install the following.

```bash
brew install reattach-to-user-namespace --with-wrap-pbcopy-and-pbpaste
```

Prepend the following to the top of `~/.byobu/profile.tmux` (for tmux, `~/.tmux.conf`).

```
set-option -g default-command "reattach-to-user-namespace -l zsh"
```

### Reference

[unable-to-use-pbcopy-while-in-tmux-session](http://superuser.com/questions/231130/unable-to-use-pbcopy-while-in-tmux-session)

## Theme

- ZSH theme `powerlevel9k`
- iTerm Solarized Dark Color Scheme
- Vim Solarized Dark Color Scheme

### Reference

https://gist.github.com/kevin-smets/8568070
https://github.com/bhilburn/powerlevel9k#installation
http://ethanschoonover.com/solarized/vim-colors-solarized
