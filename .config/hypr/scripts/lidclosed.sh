#!/bin/bash

# if [ "$(acpi -a)" == "Adapter 0: on-line" ]; then
#   hyprctl keyword monitor "eDP-1, disable"
# fi

# Get the list of monitors from hyprctl
monitors=$(hyprctl monitors | grep "Monitor" | wc -l)

# Check if there is more than one monitor
if [ "$monitors" -gt 1 ]; then
  hyprctl keyword monitor "eDP-1, disable"
else
  echo "One or no monitor is connected."
fi
