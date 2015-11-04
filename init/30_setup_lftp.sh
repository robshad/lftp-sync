#!/bin/bash

cat >/script/lftp-sync-service.sh <<EOL
#!/bin/bash

trap "rm -f /tmp/lftp-sync.lock" SIGINT SIGTERM
if [ -e /tmp/lftp-sync.lock ]
then
  exit 1
else
  touch /tmp/lftp-sync.lock
  
  # 
  /config/lftp-sync.sh -s "$(printenv REMOTEDIR)" -t "/target"

  rm -f /tmp/lftp-sync.lock
  exit 0
fi

EOL
echo "Wrote /script/lftp-sync-service.sh"

wget -v -O /config/lftp-sync.sh https://raw.githubusercontent.com/robshad/lftp-sync/master/lftp-sync.sh
echo "Wrote /config/lftp-sync.sh"

wget -v -O /config/lftp-sync-defaults.cfg https://raw.githubusercontent.com/robshad/lftp-sync/master/lftp-sync-defaults.cfg
echo "Wrote /config/lftp-sync-default.cfg"

chown -R abc:abc /config
chown -R abc:abc /script
chmod -v +x /config/lftp-sync.sh
chmod -v +x /script/lftp-sync-service.sh

crontab -l | { cat; echo "$(printenv CRON) /script/lftp-sync-service.sh"; } | crontab -
