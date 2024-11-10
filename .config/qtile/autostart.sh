#! /bin/bash
autorandr -c &
nitrogen --restore &
picom -b &
nm-applet &
blueman-applet &
optimus-manager-qt &
powerkit &
indicator-sound-switcher &
# clight-gui --tray &
/usr/lib/pam_kwallet_init &
ssh-add -q ~/.ssh/id_rsa ~/.ssh/cmtkprod_rsa ~/.ssh/id_rsa_cel_balluff < /dev/null &
