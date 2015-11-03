#!/bin/bash

cat >/script/lftp-sync-service.sh <<EOL
#!/bin/bash

/config/lftp-sync.sh -s \"$(printenv REMOTEDIR)\" -t \"/target\"
EOL
echo "Wrote /script/lftp-sync-service.sh"

crontab -l | { cat; echo "*/1 * * * * abc /script/lftp-sync-service.sh"; } | crontab -
