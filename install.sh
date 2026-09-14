#!/usr/bin/env bash
mkdir -p ~/.config/systemd/user/
mkdir -p ~/.local/bin/
cp ./hypr_remote.service ./hypr_remote.service.working
sed -i "s/RESU/$USER/g" ./hypr_remote.service.working
sed -i "s|GDX|$XDG_RUNTIME_DIR|g" ./hypr_remote.service.working
cp ./hypr_remote.service.working ~/.config/systemd/user/hypr_remote.service
cp ./hypr_remote.sh ~/.local/bin/hypr_remote.sh
systemctl --user daemon-reload
