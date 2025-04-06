## immich-hdd-backup instructions

```bash
# /hdd/Media/Immich is owned by root, so sudo required to run script

# sudo mkdir -p /opt/scripts
# sudo cp /home/dpi0/scripts/immich/immich-hdd-backup.sh /opt/scripts/
# sudo chmod 755 /opt/scripts/immich-hdd-backup.sh

sudo ln -sf $HOME/scripts/immich/immich-hdd-backup.service /etc/systemd/system/immich-hdd-backup.service
sudo ln -sf $HOME/scripts/immich/immich-hdd-backup.timer /etc/systemd/system/immich-hdd-backup.timer

sudo systemctl daemon-reload
sudo systemctl enable --now immich-hdd-backup.timer
sudo systemctl status immich-hdd-backup.timer
```
