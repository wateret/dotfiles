# SAP specific settings

for i in {0..99}; do
    alias db$i="sudo su - h$(printf '%02d' $i)adm -c"
    alias dbc$i="hdbsql -i ${i} -u system -p manager -fj \"alter system clear traces ('*');\" && sudo su - h$(printf '%02d' $i)adm -c"
    alias hs$i="hdbsql -i ${i} -u system -p manager -fj"
    alias hsc$i="hdbsql -i ${i} -u system -p manager -fj \"alter system clear traces ('*');\" && hdbsql -i ${i} -u system -p manager -fj"
done

export PATH="/data/i565578/.bin:$PATH"
export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH

source /data/i565578/.HappyMake/etc/hminit.sh
export CLAUDE_CODE_NO_FLICKER=1
alias clc="claude --model \"opus[1m]\""
