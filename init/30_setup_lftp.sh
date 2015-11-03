#!/bin/bash

cat >/script/lftp-sync-service.sh <<EOL
#!/bin/bash

/config/lftp-sync.sh -s "$(printenv REMOTEDIR)" -t "/target"
EOL
echo "Wrote /script/lftp-sync-service.sh"

wget -v -O /config/lftp-sync.sh https://raw.githubusercontent.com/robshad/lftp-sync/master/lftp-sync.sh
echo "Wrote /config/lftp-sync.sh"

wget -v -O /config/lftp-sync-defaults.cfg https://raw.githubusercontent.com/robshad/lftp-sync/master/lftp-sync-defaults.cfg
echo "Wrote /config/lftp-sync-default.cfg"

chmod -v +x /config/lftp-sync.sh
chmod -v +x /script/lftp-sync-service.sh

crontab -l | { cat; echo "*/1 * * * * /script/lftp-sync-service.sh"; } | crontab -
