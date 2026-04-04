# SAP specific settings
[[ $HOME != *578* && $HOME != */usr/sap* ]] && return

{
  local _a='' i pad
  for i in {0..99}; do
    pad=${(l:2::0:)i}
    _a+="alias db$i='sudo su - h${pad}adm -c';"
    _a+="alias dbc$i='hdbsql -i $i -u system -p manager -fj \"alter system clear traces (\\\"*\\\");\" && sudo su - h${pad}adm -c';"
    _a+="alias hs$i='hdbsql -i $i -u system -p manager -fj';"
    _a+="alias hsc$i='hdbsql -i $i -u system -p manager -fj \"alter system clear traces (\\\"*\\\");\" && hdbsql -i $i -u system -p manager -fj';"
  done
  eval "$_a"
}

export PATH="/data/i565578/.bin:$PATH"
export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH

[ -f ~/.HappyMake/etc/hminit.sh ] && source ~/.HappyMake/etc/hminit.sh
export CLAUDE_CODE_NO_FLICKER=1
alias clc="claude --model \"opus[1m]\""
