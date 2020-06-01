import os
import shlex
from libqtile.widget import base

from typing import Dict  # noqa: F401


class Backlight(base.InLoopPollText):
    """A simple widget to show the current brightness of a monitor"""

    orientations = base.ORIENTATION_HORIZONTAL

    defaults = [
        ('get_brightness_cmd',
         "xrandr --verbose | awk '/Brightness/ { print $2; exit }'", 'The current brightness in percent'),
        ('update_interval', .2, 'The delay in seconds between updates'),
        ('step', 10, 'Percent of backlight every scroll changed'),
        ('format', '{icon}{percent: 2.0%}', 'Display format'),
        ('change_command',
         'xrandr --output eDP-1 --brightness {0}', 'Execute command to change value')
    ]

    icons = ['', '', '', '', '', '', '', '']

    def __init__(self, **config):
        base.InLoopPollText.__init__(self, **config)
        self.add_defaults(Backlight.defaults)
        self.future = None

    def _get_brightness(self):
        brightness = self.call_process(
            self.get_brightness_cmd, **{"shell": True})

        return float(brightness)

    def poll(self):
        try:
            brightness = self._get_brightness()
        except RuntimeError as e:
            return 'Error: {}'.format(e)

        return self.format.format(percent=brightness, icon=Backlight.icons[max(int(brightness*100//12.5)-1, 0)])

    def change_backlight(self, value):
        self.call_process(shlex.split(self.change_command.format(value)))

    def button_press(self, x, y, button):
        if self.future and not self.future.done():
            return
        try:
            brightness = self._get_brightness()
            new = now = brightness * 100
        except RuntimeError as e:
            new = now = 100
            return 'Error: {}'.format(e)
        if button == 5:  # down
            new = max(now - self.step, 0)
        elif button == 4:  # up
            new = min(now + self.step, 100)
        if new != now:
            self.future = self.qtile.run_in_executor(self.change_backlight,
                                                     new / 100)
