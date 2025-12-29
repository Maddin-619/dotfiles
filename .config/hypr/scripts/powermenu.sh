#!/bin/sh

lock=" Lock"
exit="󰗼 Exit"
shutdown="󰐥 Poweroff"
reboot=" Reboot"
sleep=" Suspend"
yes="Yes"
no="No"


confirm() {
    res=$(echo -e "$no\n$yes" | rofi -dmenu -i -mesg "$1?")

    case $res in
        "$yes")
            eval $2
        ;;
        *)
            echo "$no"
        ;;
    esac
}

selected_option=$(echo "$lock
$exit
$sleep
$reboot
$shutdown" | rofi -dmenu -i )

case $selected_option in
    "$lock")
        hyprlock
        ;;
    "$exit")
        confirm "$exit" "hyprctl dispatch exit"
        ;;
    "$shutdown")
        confirm "$shutdown" "systemctl poweroff"
        ;;
    "$reboot")
        confirm "$reboot" "systemctl reboot"
        ;;
    "$sleep")
        confirm "$sleep" "systemctl suspend"
        ;;
    *)
        echo "No match"
        ;;
esac

