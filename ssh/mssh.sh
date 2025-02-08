#!/usr/bin/env bash
[ -z "$1" ] && echo "Usage: $0 cmd" && exit 1

set -e

source os/ALL.sh

for vps in $ALL; do
  prefix="\033[32m $vps \$(basename \${BASH_SOURCE[0]}) \$(echo \"+\$LINENO\") ❯ \033[0m"

  ssh $vps <<EOF
#!/usr/bin/env zsh
PS4='$prefix' && set -ex && $1
EOF
done

# # VPS_LI="mi u3 sea u1 u2 uc m15"
# vps=$1
# sh=$2
#
# set -ex
#
# chmod +x $sh
# rfp=/tmp/mssh/$(basename $sh)
# # for vps in $VPS_LI; do
#
# prefix="\033[32m $vps \$(basename \${BASH_SOURCE[0]}) \$(echo \"+\$LINENO\") ❯ \033[0m"
#
# ssh $vps "mkdir -p $(dirname $rfp)"
# rsync -avz $sh $vps:$rfp
#
# echo $prefix
# ssh $vps <<EOF
# PS4='$prefix' $rfp && rm -rf $rfp
# EOF
#
# # done
