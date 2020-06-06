# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import subprocess
import socket
from Xlib import display as xdisplay
from libqtile.config import Key, Screen, Group, Drag, Click
from libqtile.command import lazy
from libqtile.log_utils import logger
from libqtile import layout, bar, widget, hook

from typing import List  # noqa: F401

##### DEFINING SOME VARIABLES #####
mod = "mod4"                                     # Sets mod key to SUPER/WINDOWS
myTerm = "alacritty"                                    # My terminal of choice
# The Qtile config file location
myConfig = "/home/martin/.config/qtile/config.py"

batteryNames = ['BAT0', 'cw2015-battery']
backlightNames = ['intel_backlight', 'edp-backlight']

#### HELPER FUNCTIONS ####

batteryName = ''
for name in batteryNames:
    if os.path.exists("/sys/class/power_supply/" + name):
        batteryName = name

backlightName= ''
for name in backlightNames:
    if os.path.exists("/sys/class/backlight/" + name):
        backlightName = name


def get_num_monitors():
    num_monitors = 0
    try:
        display = xdisplay.Display()
        screen = display.screen()
        resources = screen.root.xrandr_get_screen_resources()

        for output in resources.outputs:
            monitor = display.xrandr_get_output_info(
                output, resources.config_timestamp)
            preferred = False
            if hasattr(monitor, "preferred"):
                preferred = monitor.preferred
            elif hasattr(monitor, "num_preferred"):
                preferred = monitor.num_preferred
            if preferred:
                num_monitors += 1
    except Exception:
        # always setup at least one monitor
        return 1
    else:
        return num_monitors

def getBatteryCapacity():
    icons = ['', '', '', '', '', '', '', '', '', '']
    capacity = int(subprocess.check_output(["cat", "/sys/class/power_supply/" + batteryName + "/capacity"]).decode("utf-8").strip())
    charging = subprocess.check_output(["cat", "/sys/class/power_supply/" + batteryName + "/status"]).decode("utf-8").strip()
    icon = ''
    if charging == 'Charging':
        icon = ''
    else:
        icon = icons[capacity // 10]
    return '{0} {1} %'.format(icon, capacity)



##### KEYBINDINGS #####
keys = [
    # The essentials
    Key(
        [mod], "Return",
        lazy.spawn(myTerm)                      # Open terminal
    ),
    Key(
        [mod, "shift"], "Return",              # Dmenu Run Launcher
        lazy.spawn("dmenu_run -p 'Run: '")
    ),
    Key(
        [mod], "Tab",
        lazy.next_layout()                      # Toggle through layouts
    ),
    Key(
        [mod, "shift"], "c",
        lazy.window.kill()                      # Kill active window
    ),
    Key(
        [mod, "shift"], "r",
        lazy.restart()                          # Restart Qtile
    ),
    Key(
        [mod, "shift"], "q",
        lazy.shutdown()                         # Shutdown Qtile
    ),
    # Switch focus to specific monitor (out of three)
    Key([mod], "w",
        # Keyboard focus to screen(0)
        lazy.to_screen(0)
        ),
    Key([mod], "e",
        # Keyboard focus to screen(1)
        lazy.to_screen(1)
        ),
    Key([mod], "r",
        # Keyboard focus to screen(2)
        lazy.to_screen(2)
        ),
    # Switch focus of monitors
    Key([mod], "period",
        lazy.next_screen()                      # Move monitor focus to next screen
        ),
    Key([mod], "comma",
        lazy.prev_screen()                      # Move monitor focus to prev screen
        ),
    # Treetab controls
    Key([mod, "control"], "k",
        lazy.layout.section_up()                # Move up a section in treetab
        ),
    Key([mod, "control"], "j",
        lazy.layout.section_down()              # Move down a section in treetab
        ),
    # Window controls
    Key(
        [mod], "k",
        lazy.layout.down()                      # Switch between windows in current stack pane
    ),
    Key(
        [mod], "j",
        lazy.layout.up()                        # Switch between windows in current stack pane
    ),
    Key(
        [mod, "shift"], "k",
        lazy.layout.shuffle_down()              # Move windows down in current stack
    ),
    Key(
        [mod, "shift"], "j",
        lazy.layout.shuffle_up()                # Move windows up in current stack
    ),
    Key(
        [mod], "h",
        lazy.layout.grow(),                     # Grow size of current window (XmonadTall)
        lazy.layout.increase_nmaster(),         # Increase number in master pane (Tile)
    ),
    Key(
        [mod], "l",
        lazy.layout.shrink(),                   # Shrink size of current window (XmonadTall)
        lazy.layout.decrease_nmaster(),         # Decrease number in master pane (Tile)
    ),
    Key(
        [mod], "n",
        lazy.layout.normalize()                 # Restore all windows to default size ratios
    ),
    Key(
        [mod], "m",
        # Toggle a window between minimum and maximum sizes
        lazy.layout.maximize()
    ),
    Key(
        [mod, "shift"], "f",
        lazy.window.toggle_floating()           # Toggle floating
    ),
    # Stack controls
    Key(
        [mod, "shift"], "space",
        lazy.layout.rotate(),                   # Swap panes of split stack (Stack)
        # Switch which side main pane occupies (XmonadTall)
        lazy.layout.flip()
    ),
    Key(
        [mod], "space",
        # Switch window focus to other pane(s) of stack
        lazy.layout.next()
    ),
    Key(
        [mod, "control"], "Return",
        # Toggle between split and unsplit sides of stack
        lazy.layout.toggle_split()
    ),
    # Dmenu scripts launched with ALT + CTRL + KEY
    Key(
        ["mod1", "control"], "e",
        lazy.spawn("./.dmenu/dmenu-edit-configs.sh")
    ),
    # My applications launched with SUPER + ALT + KEY
    Key(
        [mod], "s",
        lazy.spawn('pavucontrol-qt')
    ),
    # Special Keybindings
    Key(
        [], "XF86AudioRaiseVolume",
        lazy.spawn(
            'sh -c "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ +5%"')
    ),
    Key(
        [], "XF86AudioLowerVolume",
        lazy.spawn(
            'sh -c "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ -5%"')
    ),
    Key(
        [], "XF86AudioMute",
        lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    ),
    Key(
        [], "XF86MonBrightnessUp",
        lazy.spawn('light -A 10')
    ),
    Key(
        [], "XF86MonBrightnessDown",
        lazy.spawn(
            'light -U 10')
    ),
]


##### GROUPS #####
group_names = [("WWW", {'layout': 'monadtall'}),
               ("DEV", {'layout': 'monadtall'}),
               ("SYS", {'layout': 'monadtall'}),
               ("DOC", {'layout': 'monadtall'}),
               ("VBOX", {'layout': 'monadtall'}),
               ("CHAT", {'layout': 'monadtall'}),
               ("MUS", {'layout': 'monadtall'}),
               ("VID", {'layout': 'monadtall'}),
               ("GFX", {'layout': 'floating'})]

groups = [Group(name, **kwargs) for name, kwargs in group_names]

for i, (name, kwargs) in enumerate(group_names, 1):
    # Switch to another group
    keys.append(Key([mod], str(i), lazy.group[name].toscreen()))
    # Send current window to another group
    keys.append(Key([mod, "shift"], str(i), lazy.window.togroup(name)))


##### DEFAULT THEME SETTINGS FOR LAYOUTS #####
layout_theme = {"border_width": 2,
                "margin": 4,
                "border_focus": "#1793D1",
                "border_normal": "#1D2330"
                }

##### THE LAYOUTS #####
layouts = [
    layout.Max(),
    layout.Stack(num_stacks=2),
    # layout.MonadWide(**layout_theme),
    # layout.Bsp(**layout_theme),
    #layout.Stack(stacks=2, **layout_theme),
    # layout.Columns(**layout_theme),
    # layout.RatioTile(**layout_theme),
    # layout.VerticalTile(**layout_theme),
    #layout.Tile(shift_windows=True, **layout_theme),
    # layout.Matrix(**layout_theme),
    # layout.Zoomy(**layout_theme),
    layout.MonadTall(**layout_theme),
    layout.Floating(**layout_theme)
]

##### COLORS #####
colors = [["#282a36", "#282a36"],  # panel background
          ["#434758", "#434758"],  # background for current screen tab
          ["#ffffff", "#ffffff"],  # font color for group names
          ["#ff5555", "#ff5555"],  # background color for layout widget
          ["#3C6D7E", "#3C6D7E"],  # dark green gradiant for other screen tabs
          ["#0093DD", "#0093DD"]]  # background color for pacman widget

##### PROMPT #####
prompt = "{0}@{1}: ".format(os.environ["USER"], socket.gethostname())

##### DEFAULT WIDGET SETTINGS #####
widget_defaults = dict(
    font="MesloLGM Nerd Font",
    fontsize=12,
    padding=2,
    background=colors[2]
)
extension_defaults = widget_defaults.copy()

##### WIDGETS #####


def init_widgets_list():
    widgets_list = [
        widget.Sep(
            linewidth=0,
            padding=6,
            foreground=colors[2],
            background=colors[0]
        ),
        widget.GroupBox(
            fontsize=12,
            margin_y=4,
            margin_x=0,
            padding_y=4,
            padding_x=4,
            borderwidth=3,
            active=colors[2],
            inactive=colors[2],
            rounded=False,
            highlight_method="block",
            this_current_screen_border=colors[4],
            this_screen_border=colors[1],
            other_current_screen_border=colors[0],
            other_screen_border=colors[0],
            foreground=colors[2],
            background=colors[0]
        ),
        widget.Prompt(
            prompt=prompt,
            padding=10,
            foreground=colors[3],
            background=colors[1]
        ),
        widget.Sep(
            linewidth=0,
            padding=10,
            foreground=colors[2],
            background=colors[0]
        ),
        widget.WindowName(
            foreground=colors[4],
            background=colors[0],
            padding=5
        ),
        widget.Notify(
            padding=5,
            default_timeout=5,
            background=colors[5],
            foreground=colors[2]
        ),
        widget.TextBox(
            text='\ue0b2',
            font='Hack Nerd Font',
            background=colors[0],
            foreground=colors[4],
            padding=0,
            fontsize=18
        ),
        widget.TextBox(
            text=" ⟳",
            padding=5,
            foreground=colors[2],
            background=colors[4],
            fontsize=14
        ),
        widget.Pacman(
            execute="alacritty",
            update_interval=1800,
            foreground=colors[2],
            background=colors[4]
        ),
        widget.TextBox(
            text="Updates",
            padding=5,
            foreground=colors[2],
            background=colors[4]
        ),
        widget.TextBox(
            text='\ue0b2',
            font='Hack Nerd Font',
            background=colors[4],
            foreground=colors[5],
            padding=0,
            fontsize=18
        ),
        widget.TextBox(
            text=" 🖬",
            foreground=colors[2],
            background=colors[5],
            padding=0,
            fontsize=14
        ),
        widget.Memory(
            foreground=colors[2],
            background=colors[5],
            padding=5
        ),
        widget.TextBox(
            text='\ue0b2',
            font='Hack Nerd Font',
            background=colors[5],
            foreground=colors[4],
            padding=0,
            fontsize=18
        ),
        widget.CPUGraph(
            background=colors[4],
        ),
        widget.TextBox(
            text='\ue0b2',
            font='Hack Nerd Font',
            background=colors[4],
            foreground=colors[5],
            padding=0,
            fontsize=18
        ),
        widget.TextBox(
            text=" ↯",
            foreground=colors[2],
            background=colors[5],
            padding=0,
            fontsize=14
        ),
        widget.Net(
            foreground=colors[2],
            background=colors[5],
            padding=5
        ),
        widget.TextBox(
            text='\ue0b2',
            font='Hack Nerd Font',
            background=colors[5],
            foreground=colors[4],
            padding=0,
            fontsize=18
        ),
        widget.GenPollText(
            func=getBatteryCapacity,
            background=colors[4],
        ),
        widget.TextBox(
            text='\ue0b2',
            font='Hack Nerd Font',
            background=colors[4],
            foreground=colors[5],
            padding=0,
            fontsize=18
        ),
        widget.TextBox(
            text=" 🔊",
            foreground=colors[2],
            background=colors[5],
            padding=0,
            fontsize=14
        ),
        widget.PulseVolume(
            foreground=colors[2],
            background=colors[5],
            padding=5,
            limit_max_volume=True,
            volume_app="pavucontrol-qt"
        ),
        widget.TextBox(
            text='\ue0b2',
            font='Hack Nerd Font',
            background=colors[5],
            foreground=colors[4],
            padding=0,
            fontsize=18
        ),
        widget.Backlight(
            backlight_name='edp-backlight',
            change_command='light -S {0}',
            fmt=' {}',
            foreground=colors[2],
            background=colors[4],
            padding=5,
        ),
        widget.TextBox(
            text='\ue0b2',
            font='Hack Nerd Font',
            background=colors[4],
            foreground=colors[5],
            padding=0,
            fontsize=18
        ),
        widget.CurrentLayoutIcon(
            custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
            foreground=colors[2],
            background=colors[5],
            padding=0,
            scale=0.7
        ),
        widget.CurrentLayout(
            foreground=colors[2],
            background=colors[5],
            padding=5
        ),
        widget.TextBox(
            text='\ue0b2',
            font='Hack Nerd Font',
            background=colors[5],
            foreground=colors[4],
            padding=0,
            fontsize=18
        ),
        widget.TextBox(
            text=" 🕒",
            foreground=colors[2],
            background=colors[4],
            padding=5,
            fontsize=14
        ),
        widget.Clock(
            foreground=colors[2],
            background=colors[4],
            format="%a, %b %d - %H:%M"
        ),
        widget.Sep(
            linewidth=0,
            padding=5,
            foreground=colors[0],
            background=colors[4]
        ),
        widget.Systray(
            background=colors[0],
            padding=5
        ),
        widget.Sep(
            linewidth=0,
            padding=7,
            foreground=colors[0],
            background=colors[4]
        ),
    ]
    return widgets_list

# SCREENS ##### (TRIPLE MONITOR SETUP or ONE MONITOR)


def init_widgets_primary_screen():
    widgets = init_widgets_list()
    return widgets


def init_widgets_secoundary_screen():
    widgets = init_widgets_list()
    return widgets[:-1]


def init_screens(num_monitors):
    if num_monitors == 1:
        return [Screen(top=bar.Bar(widgets=init_widgets_primary_screen(), opacity=0.95, size=20))]
    elif num_monitors == 2:
        return [Screen(top=bar.Bar(widgets=init_widgets_secoundary_screen(), opacity=0.95, size=20)),
                Screen(top=bar.Bar(widgets=init_widgets_primary_screen(), opacity=0.95, size=20))]
    else:
        screens = [Screen(top=bar.Bar(widgets=init_widgets_secoundary_screen(), opacity=0.95, size=20)),
                   Screen(top=bar.Bar(widgets=init_widgets_primary_screen(), opacity=0.95, size=20))]
        for _ in range(num_monitors - 1):
            screens.append(Screen(top=bar.Bar(
                widgets=init_widgets_secoundary_screen(), opacity=0.95, size=20)))
        return screens


if __name__ in ["config", "__main__"]:
    num_monitors = get_num_monitors()
    logger.warning('number of screens: {0}'.format(num_monitors))
    screens = init_screens(num_monitors)

##### DRAG FLOATING WINDOWS #####

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    {'wmclass': 'confirm'},
    {'wmclass': 'dialog'},
    {'wmclass': 'download'},
    {'wmclass': 'error'},
    {'wmclass': 'file_progress'},
    {'wmclass': 'notification'},
    {'wmclass': 'splash'},
    {'wmclass': 'toolbar'},
    {'wmclass': 'confirmreset'},  # gitk
    {'wmclass': 'makebranch'},  # gitk
    {'wmclass': 'maketag'},  # gitk
    {'wname': 'branchdialog'},  # gitk
    {'wname': 'pinentry'},  # GPG key password entry
    {'wmclass': 'ssh-askpass'},  # ssh-askpass
])
auto_fullscreen = True
focus_on_window_activation = "smart"

##### STARTUP APPLICATIONS #####


@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])


# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
