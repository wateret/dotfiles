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
