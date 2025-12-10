#!/bin/bash


UNAME=`uname`

if [[ $UNAME == 'Darwin' ]]; then  # macOS
    defaults write -g ApplePressAndHoldEnabled -bool false
    defaults write -g com.apple.mouse.scaling -1

    # install brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    INSTALL='brew install '
elif [[ $UNAME == 'Linux' ]]; then # Linux (assuming Ubuntu)
    INSTALL='sudo apt-get install -y'
fi


### Copy files to home directory

rsync -av homedir/ ~/


### Changes in bashrc

BASHRC_PATH="${HOME}/.bashrc"
BASHRC_MORE="source ~/.bashrc_more"

grep "'${BASHRC_MORE}'" ${BASHRC_PATH}
if [ $? -ne 0 ]; then
    echo
    echo
    echo "# additional settings for bashrc" >> ${BASHRC_PATH}
    echo "${BASHRC_MORE}" >> ${BASHRC_PATH}
fi


### Install fundamental programs

$INSTALL vim
$INSTALL neovim
$INSTALL git
$INSTALL ripgrep

#### zoxide

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

#### tmux

echo "==== Setting up tmux"
git clone --single-branch https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f ~/.tmux/.tmux.conf ~
#cp ~/.tmux/.tmux.conf.local ~ # This is later replaced with a file in homedir/ so skip this

#### ZSH

echo "==== Setting up vim"

# install zsh
$INSTALL zsh

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# install zsh plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k


### Copy files to home directory again (for .zshrc)

rsync -av homedir/ ~/
