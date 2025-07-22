#!/usr/bin/env bash
cp ./hypr_remote.service ./hypr_remote.service.working
sed -i "s/RESU/$USER/g" ./hypr_remote.service.working
sed -i "s|GDX|$XDG_RUNTIME_DIR|g" ./hypr_remote.service.working
sudo sh -c "cp ./hypr_remote.service.working /etc/systemd/system/hypr_remote.service; cp ./hypr_remote.sh /usr/local/bin/hypr_remote.sh; systemctl daemon-reload"

