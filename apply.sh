#!/bin/bash


UNAME=`uname`

if [[ $UNAME == 'Darwin' ]]; then # OS 
	INSTALL='brew install '
elif [[ $UNAME == 'Linux' ]]; then # assuming Ubuntu
	INSTALL='sudo apt-get install '
fi


### Copy files to home directory

rsync -av homedir/ ~/


### Changes in bashrc

BASHRC_PATH="${HOME}/.bashrc"
BASHRC_MORE="source ~/.bashrc_more"

grep "'${BASHRC_MORE}'" ${BASHRC_PATH}
if [ $? -ne 0 ]; then
	echo "# additional settings for bashrc" >> ${BASHRC_PATH}
	echo "${BASHRC_MORE}" >> ${BASHRC_PATH}
fi


### Install fundamental programs

$INSTALL vim git


### ZSH

# install zsh
$INSTALL zsh

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# install zsh plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

