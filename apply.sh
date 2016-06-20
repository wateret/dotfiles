#!/bin/bash

# Copy files to home directory

cp -rTv homedir ~


# Changes in bashrc

BASHRC_PATH="${HOME}/.bashrc"
BASHRC_MORE="source ~/.bashrc_more"

grep "'${BASHRC_MORE}'" ${BASHRC_PATH}
if [ $? -ne 0 ]; then
	echo "# additional settings for bashrc" >> ${BASHRC_PATH}
	echo "${BASHRC_MORE}" >> ${BASHRC_PATH}
fi
