#!/usr/bin/env bash

# http://www.yoone.eu/articles/2-good-practices-for-writing-shell-scripts.html
set -euo pipefail

REMOTE_PATH="Backups/blog/backup-$(date +"%m-%d-%Y-"%T"").tar.gz"

# cd to current directory, where `drive` is set up
cd "$(dirname ${BASH_SOURCE[0]})"

echo "stopping ghost instance"
ssh -i ~/.ssh/digitalocean_rsa root@blog "systemctl stop ghost"

echo "backing up ghost blog to Drive"

ssh -i ~/.ssh/digitalocean_rsa root@blog \
   "tar --exclude=node_modules -Pczpf - -C /var/www/ghost ." | \
   pv  | drive push -verbose -piped $REMOTE_PATH
echo "backup uploaded, you can find it at: ${REMOTE_PATH}"

echo "starting ghost instance"
ssh -i ~/.ssh/digitalocean_rsa root@blog "systemctl start ghost"

echo "done"
